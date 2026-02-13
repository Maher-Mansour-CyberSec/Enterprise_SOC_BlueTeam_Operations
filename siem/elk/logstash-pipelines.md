# Logstash Pipeline Configuration

## Overview

This document provides detailed Logstash pipeline configurations for ingesting and processing logs from various sources in the Enterprise SOC Lab.

---

## Pipeline Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LOGSTASH PIPELINE ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────────────────────┘

  INPUTS                    FILTERS                    OUTPUTS
  ──────                    ───────                    ───────
  
  Beats (5044)    ──┐
                    │
  Syslog (514)    ──┼──▶  Parsing/Grok    ──▶  Elasticsearch
                    │      Enrichment
  HTTP (8080)     ──┤      GeoIP
                    │      Mutate
  Filebeat        ──┘      Date
```

---

## Main SIEM Pipeline

### Configuration File

**Location:** `/etc/logstash/conf.d/siem-pipeline.conf`

```ruby
# ===================================
# INPUT SECTION
# ===================================
input {
  # Winlogbeat from Windows endpoints
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/logstash/certs/logstash.crt"
    ssl_key => "/etc/logstash/certs/logstash.key"
    ssl_certificate_authorities => ["/etc/logstash/certs/ca.crt"]
    type => "winlogbeat"
  }

  # Syslog from pfSense
  syslog {
    port => 514
    type => "firewall"
  }

  # HTTP input for Suricata
  http {
    port => 8080
    type => "suricata"
    additional_codecs => { "application/json" => "json" }
  }

  # Filebeat for web logs
  beats {
    port => 5045
    type => "filebeat"
  }
}

# ===================================
# FILTER SECTION
# ===================================
filter {
  # Windows Event Log Processing
  if [type] == "winlogbeat" {
    # Parse Windows Security Events
    if [winlog][channel] == "Security" {
      mutate { add_field => { "[@metadata][index]" => "windows-security" } }
      
      # Extract Event ID
      mutate { add_field => { "event_id" => "%{[winlog][event_id]}" } }
      
      # Parse specific event types
      if [winlog][event_id] == 4625 {
        grok {
          match => { "[winlog][event_data][IpAddress]" => "%{IP:source_ip}" }
        }
        mutate { add_tag => ["failed_logon", "brute_force_candidate"] }
      }
      
      if [winlog][event_id] == 4624 {
        grok {
          match => { "[winlog][event_data][IpAddress]" => "%{IP:source_ip}" }
        }
        mutate { add_tag => ["successful_logon"] }
      }
      
      if [winlog][event_id] == 4688 {
        mutate { 
          add_field => { 
            "process_name" => "%{[winlog][event_data][NewProcessName]}"
            "parent_process" => "%{[winlog][event_data][ParentProcessName]}"
            "command_line" => "%{[winlog][event_data][CommandLine]}"
          }
        }
      }
    }
    
    # Parse Sysmon Events
    if [winlog][channel] == "Microsoft-Windows-Sysmon/Operational" {
      mutate { add_field => { "[@metadata][index]" => "sysmon" } }
      mutate { add_field => { "sysmon_event_id" => "%{[winlog][event_id]}" } }
      
      # Event ID 1 - Process Create
      if [winlog][event_id] == 1 {
        mutate {
          add_field => {
            "process_guid" => "%{[winlog][event_data][ProcessGuid]}"
            "process_id" => "%{[winlog][event_data][ProcessId]}"
            "image" => "%{[winlog][event_data][Image]}"
            "command_line" => "%{[winlog][event_data][CommandLine]}"
            "parent_image" => "%{[winlog][event_data][ParentImage]}"
            "hashes" => "%{[winlog][event_data][Hashes]}"
          }
        }
        
        # Detect encoded commands
        if [command_line] =~ /-enc|-encodedcommand|FromBase64String/i {
          mutate { add_tag => ["encoded_command", "suspicious"] }
        }
        
        # Detect LOLBAS techniques
        if [image] =~ /certutil|bitsadmin|mshta|regsvr32|rundll32/i {
          mutate { add_tag => ["lolbas", "suspicious"] }
        }
      }
      
      # Event ID 3 - Network Connection
      if [winlog][event_id] == 3 {
        mutate {
          add_field => {
            "source_ip" => "%{[winlog][event_data][SourceIp]}"
            "source_port" => "%{[winlog][event_data][SourcePort]}"
            "destination_ip" => "%{[winlog][event_data][DestinationIp]}"
            "destination_port" => "%{[winlog][event_data][DestinationPort]}"
            "protocol" => "%{[winlog][event_data][Protocol]}"
          }
        }
        
        # GeoIP enrichment for external connections
        if [destination_ip] and [destination_ip] !~ /^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)/ {
          geoip {
            source => "destination_ip"
            target => "geoip"
          }
        }
      }
      
      # Event ID 10 - Process Access (LSASS)
      if [winlog][event_id] == 10 {
        mutate {
          add_field => {
            "source_image" => "%{[winlog][event_data][SourceImage]}"
            "target_image" => "%{[winlog][event_data][TargetImage]}"
            "granted_access" => "%{[winlog][event_data][GrantedAccess]}"
          }
        }
        
        # Detect LSASS access (credential dumping)
        if [target_image] =~ /lsass\.exe/i and [granted_access] =~ /0x1010|0x1038|0x1438|0x143a|0x100000/i {
          mutate { add_tag => ["lsass_access", "credential_dumping", "critical"] }
        }
      }
    }
  }

  # Suricata EVE.JSON Processing
  if [type] == "suricata" {
    mutate { add_field => { "[@metadata][index]" => "suricata-alerts" } }
    
    if [alert] {
      mutate {
        add_field => {
          "alert_signature" => "%{[alert][signature]}"
          "alert_category" => "%{[alert][category]}"
          "alert_severity" => "%{[alert][severity]}"
        }
      }
    }
    
    # GeoIP enrichment
    if [src_ip] {
      geoip {
        source => "src_ip"
        target => "src_geoip"
      }
    }
  }

  # pfSense Firewall Log Processing
  if [type] == "firewall" {
    mutate { add_field => { "[@metadata][index]" => "firewall-logs" } }
    
    grok {
      match => { 
        "message" => "<%{NUMBER:syslog_priority}>%{SYSLOGTIMESTAMP:syslog_timestamp} filterlog: %{NUMBER:rule_number},%{DATA:sub_rule},%{DATA:anchor},%{NUMBER:tracker},%{DATA:interface},%{DATA:reason},%{DATA:action},%{DATA:direction},%{NUMBER:ip_version},%{DATA:tos},%{DATA:ecn},%{DATA:ttl},%{NUMBER:id},%{DATA:offset},%{DATA:flags},%{NUMBER:protocol_id},%{DATA:protocol},%{NUMBER:length},%{IP:src_ip},%{IP:dest_ip},%{NUMBER:src_port},%{NUMBER:dest_port},%{GREEDYDATA:remaining}"
      }
    }
    
    if [action] == "block" {
      mutate { add_tag => ["blocked_traffic"] }
    }
  }

  # Common timestamp processing
  date {
    match => [ "timestamp", "ISO8601", "yyyy-MM-dd HH:mm:ss" ]
    target => "@timestamp"
  }

  # Remove unnecessary fields
  mutate {
    remove_field => [ "host", "agent", "ecs", "log", "input", "@version" ]
  }
}

# ===================================
# OUTPUT SECTION
# ===================================
output {
  elasticsearch {
    hosts => ["https://192.168.2.9:9200"]
    index => "%{[@metadata][index]}-%{+YYYY.MM.dd}"
    ssl => true
    ssl_certificate_verification => true
    cacert => "/etc/logstash/certs/ca.crt"
    user => "logstash_system"
    password => "${LOGSTASH_PASSWORD}"
  }
}
```

---

## Pipeline Monitoring

### Check Pipeline Status

```bash
# View pipeline stats
curl -s localhost:9600/_node/stats/pipelines | jq

# View hot threads
curl -s localhost:9600/_node/hot_threads
```

### Common Pipeline Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| High memory usage | Large batch sizes | Reduce `pipeline.batch.size` |
| Slow processing | Complex filters | Simplify grok patterns |
| Connection refused | Elasticsearch down | Check ES health |
| Certificate errors | Wrong cert path | Verify certificate locations |

---

## Performance Tuning

### JVM Options

```bash
sudo nano /etc/logstash/jvm.options
```

```
-Xms2g
-Xmx2g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
```

### Pipeline Settings

```bash
sudo nano /etc/logstash/logstash.yml
```

```yaml
pipeline.workers: 4
pipeline.batch.size: 125
pipeline.batch.delay: 50
queue.type: persisted
queue.max_bytes: 1gb
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
