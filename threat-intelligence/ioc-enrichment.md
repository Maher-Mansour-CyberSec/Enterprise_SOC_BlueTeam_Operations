# IOC Enrichment

## Overview

This document describes how to enrich security events with threat intelligence from MISP.

---

## Enrichment Methods

### Method 1: Splunk Lookup

**Create lookup table:**
```bash
# Export MISP IOCs to CSV
curl -H "Authorization: YOUR_API_KEY" \
  http://192.168.2.9/attributes/restSearch/csv \
  > /opt/splunk/etc/apps/search/lookups/misp_iocs.csv
```

**Configure lookup:**
```ini
# transforms.conf
[misp_ip_lookup]
filename = misp_iocs.csv
case_sensitive_match = false
match_type = WILDCARD(ip)
```

**Use in search:**
```spl
index=network 
| lookup misp_ip_lookup ip as src_ip OUTPUT description as misp_description
| where isnotnull(misp_description)
```

### Method 2: Logstash Enrichment

```ruby
# Add to Logstash pipeline
filter {
  if [src_ip] {
    http {
      url => "http://192.168.2.9/attributes/restSearch/json"
      headers => {
        "Authorization" => "YOUR_API_KEY"
        "Accept" => "application/json"
      }
      query => {
        "value" => "%{src_ip}"
        "type" => "ip-src"
      }
      target_body => "misp_response"
    }
    
    if [misp_response][response][Attribute] {
      mutate {
        add_field => { "misp_match" => "true" }
        add_field => { "misp_event_id" => "%{[misp_response][response][Attribute][0][event_id]}" }
      }
    }
  }
}
```

---

## Enrichment Fields

| Field | Description |
|-------|-------------|
| misp_match | Boolean indicating IOC match |
| misp_event_id | MISP event ID |
| misp_threat_level | Threat level (1-4) |
| misp_category | IOC category |
| misp_description | Event description |

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
