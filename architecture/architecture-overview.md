# Architecture Overview

## Table of Contents

1. [Design Principles](#design-principles)
2. [High-Level Architecture](#high-level-architecture)
3. [Network Architecture](#network-architecture)
4. [Security Zones](#security-zones)
5. [Component Interactions](#component-interactions)
6. [Data Flow Patterns](#data-flow-patterns)
7. [Mermaid Diagrams](#mermaid-diagrams)

---

## Design Principles

The Enterprise SOC Lab follows enterprise-grade design principles:

### Defense in Depth
Multiple security layers provide overlapping protection:
- Network segmentation with VLAN isolation
- Host-based monitoring (Sysmon, Elastic Agent)
- Network-based detection (Suricata IDS/IPS)
- Centralized log aggregation and analysis

### Zero Trust Architecture
- No implicit trust based on network location
- Continuous verification of all access attempts
- Micro-segmentation between network zones
- Comprehensive logging for all traffic flows

### Visibility-First Approach
- Full packet capture capability (Suricata, Packetbeat)
- Process execution monitoring (Sysmon)
- Authentication event logging (Windows Event Log)
- Network flow analysis (NetFlow)

### Purple Team Integration
- Attack and defense capabilities in single environment
- Real-time detection validation
- MITRE ATT&CK framework alignment
- Continuous detection engineering

---

## High-Level Architecture

### ASCII Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           INTERNET / EXTERNAL                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PFSENSE FIREWALL (NGFW)                              │
│                    Suricata IDS/IPS | NAT | VPN | Rules                      │
│                         WAN: 192.168.1.251                                   │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
           ┌───────────────────────────┼───────────────────────────┐
           │                           │                           │
           ▼                           ▼                           ▼
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   CORPORATE ZONE    │  │   SOC/BLUE ZONE     │  │   DMZ/PUBLIC ZONE   │
│   192.168.2.0/24    │  │   192.168.2.0/24    │  │   192.168.4.0/24    │
│   (High Trust)      │  │   (Medium Trust)    │  │   (Low Trust)       │
│                     │  │                     │  │                     │
│  ┌───────────────┐  │  │  ┌───────────────┐  │  │  ┌───────────────┐  │
│  │  Domain Ctrl  │  │  │  │  Purple Kali  │  │  │  │     DVWA      │  │
│  │  192.168.2.2  │  │  │  │  192.168.2.9  │  │  │  │  192.168.4.10 │  │
│  │   (Win2019)   │  │  │  │               │  │  │  │               │  │
│  │  AD/DNS/DHCP  │  │  │  │ • ELK/Splunk  │  │  │  │  Vulnerable   │  │
│  └───────────────┘  │  │  │ • MISP TI     │  │  │  │  Web App      │  │
│                     │  │  │ • Fleet/DS    │  │  │  └───────────────┘  │
│  ┌───────────────┐  │  │  │ • Canary      │  │  │                     │
│  │   Client01    │  │  │  │ • Atomic Red  │  │  │  ┌───────────────┐  │
│  │ 192.168.2.101 │  │  │  │   Team        │  │  │  │    WebSRV     │  │
│  │   (Win10)     │  │  │  └───────────────┘  │  │  │  192.168.4.20 │  │
│  │  Sysmon + UF  │  │  │                     │  │  │               │  │
│  └───────────────┘  │  │  ┌───────────────┐  │  │  │   Baseline    │  │
│                     │  │  │   Red Kali    │  │  │  │   Server      │  │
│  ┌───────────────┐  │  │  │  192.168.2.50 │  │  │  └───────────────┘  │
│  │   Red Kali    │  │  │  │               │  │  │                     │
│  │  (Attacker)   │  │  │  │  Attack Sim   │  │  └─────────────────────┘
│  │ 192.168.2.50  │  │  │  │  Platform     │  │
│  └───────────────┘  │  │  └───────────────┘  │
└─────────────────────┘  └─────────────────────┘
```

---

## Network Architecture

### Physical/Virtual Topology

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           VMWARE INFRASTRUCTURE                              │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      VMNET0 - BRIDGED NETWORK                        │   │
│  │                         (192.168.1.0/24)                             │   │
│  │                                                                      │   │
│  │   ┌─────────────┐         ┌─────────────┐         ┌─────────────┐   │   │
│  │   │   pfSense   │◄───────►│   Host OS   │◄───────►│   Internet  │   │   │
│  │   │   WAN NIC   │         │             │         │             │   │   │
│  │   └──────┬──────┘         └─────────────┘         └─────────────┘   │   │
│  │          │                                                           │   │
│  │          │ LAN (192.168.2.1)                                         │   │
│  │          ▼                                                           │   │
│  │   ┌─────────────────────────────────────────────────────────────┐   │   │
│  │   │              VMNET2 - INTERNAL NETWORK                       │   │   │
│  │   │                   (192.168.2.0/24)                           │   │   │
│  │   │                                                              │   │   │
│  │   │   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐     │   │   │
│  │   │   │  DC01   │   │Client01 │   │PurpleKali│   │RedKali  │     │   │   │
│  │   │   │.2.2     │   │.2.101   │   │.2.9     │   │.2.50    │     │   │   │
│  │   │   └─────────┘   └─────────┘   └─────────┘   └─────────┘     │   │   │
│  │   └─────────────────────────────────────────────────────────────┘   │   │
│  │                              │                                       │   │
│  │                              │ OPT1 (192.168.4.1)                    │   │
│  │                              ▼                                       │   │
│  │   ┌─────────────────────────────────────────────────────────────┐   │   │
│  │   │              VMNET4 - DMZ NETWORK                            │   │   │
│  │   │                   (192.168.4.0/24)                           │   │   │
│  │   │                                                              │   │   │
│  │   │   ┌─────────┐   ┌─────────┐                                 │   │   │
│  │   │   │  DVWA   │   │ WebSRV  │                                 │   │   │
│  │   │   │.4.10    │   │.4.20    │                                 │   │   │
│  │   │   └─────────┘   └─────────┘                                 │   │   │
│  │   └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Network Interface Configuration

| VM Name | Interface | Network | IP Address | Gateway | Purpose |
|---------|-----------|---------|------------|---------|---------|
| pfSense | WAN | VMnet0 (Bridged) | DHCP / 192.168.1.251 | 192.168.1.1 | External connectivity |
| pfSense | LAN | VMnet2 (Internal) | 192.168.2.1 | - | Corporate network gateway |
| pfSense | OPT1 | VMnet4 (Internal) | 192.168.4.1 | - | DMZ network gateway |
| DC01 | eth0 | VMnet2 (Internal) | 192.168.2.2 | 192.168.2.1 | Domain controller |
| Client01 | eth0 | VMnet2 (Internal) | 192.168.2.101 | 192.168.2.1 | Domain workstation |
| PurpleKali | eth0 | VMnet2 (Internal) | 192.168.2.9 | 192.168.2.1 | SOC/SIEM server |
| RedKali | eth0 | VMnet2 (Internal) | 192.168.2.50 | 192.168.2.1 | Attack platform |
| DVWA | eth0 | VMnet4 (Internal) | 192.168.4.10 | 192.168.4.1 | Vulnerable web app |
| WebSRV | eth0 | VMnet4 (Internal) | 192.168.4.20 | 192.168.4.1 | Baseline web server |

---

## Security Zones

### Trust Boundary Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TRUST BOUNDARY MODEL                               │
└─────────────────────────────────────────────────────────────────────────────┘

    HIGH TRUST                          MEDIUM TRUST                        LOW TRUST
    ┌─────────┐                        ┌─────────┐                        ┌─────────┐
    │  CORP   │◄────── Firewall ─────►│   SOC   │◄────── Firewall ─────►│   DMZ   │
    │  ZONE   │      (Stateful)        │  ZONE   │      (Restricted)      │  ZONE   │
    └────┬────┘                        └────┬────┘                        └────┬────┘
         │                                    │                                    │
         │  • Domain Controllers              │  • SIEM Servers                    │  • Web Servers
         │  • Workstations                    │  • Threat Intel                    │  • Public Services
         │  • Internal Apps                   │  • Log Aggregators                 │  • Guest Access
         │                                    │                                    │
    ┌────┴────┐                          ┌────┴────┐                          ┌────┴────┐
    │ Access  │                          │ Monitor │                          │ Expose  │
    │ Control │                          │  Only   │                          │ Minimal │
    └─────────┘                          └─────────┘                          └─────────┘
```

### Zone Characteristics

#### Corporate Zone (192.168.2.0/24) - High Trust
- **Purpose**: Internal user workstations and domain services
- **Access**: Authenticated domain users only
- **Monitoring**: Full endpoint monitoring, all logs forwarded
- **Outbound**: Restricted internet access via proxy
- **Inbound**: Blocked from DMZ, limited from SOC

#### SOC Zone (192.168.2.0/24) - Medium Trust
- **Purpose**: Security operations and monitoring infrastructure
- **Access**: SOC analysts, security tools service accounts
- **Monitoring**: Self-monitoring, audit logging
- **Outbound**: Limited to update servers, threat feeds
- **Inbound**: Log ingestion from all zones, admin access only

#### DMZ Zone (192.168.4.0/24) - Low Trust
- **Purpose**: Public-facing services and vulnerable applications
- **Access**: Unauthenticated internet access allowed
- **Monitoring**: Network monitoring, limited endpoint logs
- **Outbound**: Blocked to Corporate, limited to SOC for logs
- **Inbound**: HTTP/HTTPS from internet, blocked to internal

---

## Component Interactions

### Authentication Flow

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Client  │────►│   DC    │────►│   AD    │────►│  SYSVOL │
│   01    │     │  (DNS)  │     │   DS    │     │  (GPO)  │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
     │               │               │               │
     │  1. DNS Query │               │               │
     │──────────────►│               │               │
     │               │               │               │
     │  2. SRV Record│               │               │
     │◄──────────────│               │               │
     │               │               │               │
     │  3. Kerberos AS-REQ           │               │
     │──────────────────────────────►│               │
     │               │               │               │
     │  4. TGT (AS-REP)              │               │
     │◄──────────────────────────────│               │
     │               │               │               │
     │  5. TGS-REQ (Service Ticket)  │               │
     │──────────────────────────────►│               │
     │               │               │               │
     │  6. Service Ticket (TGS-REP)  │               │
     │◄──────────────────────────────│               │
```

### Log Ingestion Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Windows   │     │   Sysmon    │     │  Winlogbeat │     │ Logstash/   │
│   Events    │────►│   (ETW)     │────►│  (Agent)    │────►│  Beats      │
└─────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
                                                                    │
┌─────────────┐     ┌─────────────┐     ┌─────────────┐            │
│   Linux     │     │   Auditd    │     │  Filebeat   │────────────┤
│   Events    │────►│   (Audit)   │────►│  (Agent)    │            │
└─────────────┘     └─────────────┘     └─────────────┘            │
                                                                    │
┌─────────────┐     ┌─────────────┐     ┌─────────────┐            │
│   Network   │     │   Suricata  │     │  Evebox/    │────────────┤
│   Traffic   │────►│   (IDS)     │────►│  Filebeat   │            │
└─────────────┘     └─────────────┘     └─────────────┘            │
                                                                    ▼
                                                           ┌─────────────┐
                                                           │Elasticsearch│
                                                           │  (Storage)  │
                                                           └──────┬──────┘
                                                                  │
                                                                  ▼
                                                           ┌─────────────┐
                                                           │   Kibana    │
                                                           │(Dashboards) │
                                                           └─────────────┘
```

---

## Data Flow Patterns

### Normal Operations Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         NORMAL OPERATIONS DATA FLOW                          │
└─────────────────────────────────────────────────────────────────────────────┘

  USER WORKFLOW                              MONITORING WORKFLOW
  ─────────────                              ─────────────────

┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  User   │───►│  Login  │───►│  Access │    │  Event  │───►│  SIEM   │
│ Request │    │ (AD/Kerb)│   │ Resource│    │  Logged │    │ Ingested│
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
                                                                  │
                                                                  ▼
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Response│◄───│ Process │◄───│ Validate│◄───│  Alert  │◄───│  Check  │
│  Sent   │    │ Request │    │  Access │    │ Trigger │    │  Rules  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### Attack Detection Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ATTACK DETECTION FLOW                               │
└─────────────────────────────────────────────────────────────────────────────┘

  ATTACK CHAIN                               DETECTION CHAIN
  ────────────                               ──────────────

┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Recon   │───►│ Initial │───►│ Lateral │    │  IDS/   │───►│  SIEM   │
│ (Nmap)  │    │ Access  │    │ Movement│    │ Endpoint│    │ Correl. │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
     │               │               │                              │
     │               │               │                              ▼
     │               │               │                       ┌─────────┐
     │               │               │                       │  Alert  │
     │               │               │                       │ Created │
     │               │               │                       └────┬────┘
     │               │               │                            │
     ▼               ▼               ▼                            ▼
┌─────────┐    ┌─────────┐    ┌─────────┐                   ┌─────────┐
│ Suricata│    │ Windows │    │ Windows │                   │  SOC    │
│  Alert  │    │  Event  │    │  Event  │                   │ Analyst │
│ Generated│   │  4625   │    │  4648   │                   │ Notified│
└─────────┘    └─────────┘    └─────────┘                   └─────────┘
```

---

## Mermaid Diagrams

### Network Topology

```mermaid
graph TB
    subgraph Internet["Internet"]
        EXT["External Network"]
    end

    subgraph VMware["VMware Infrastructure"]
        subgraph Management["Management Network (VMnet0)"]
            PFS_WAN["pfSense WAN<br/>192.168.1.251"]
        end

        subgraph Corporate["Corporate Network (192.168.2.0/24)"]
            PFS_LAN["pfSense LAN<br/>192.168.2.1"]
            DC01["DC01 - Domain Controller<br/>Windows Server 2019<br/>192.168.2.2"]
            CLIENT01["Client01 - Workstation<br/>Windows 10<br/>192.168.2.101"]
            PURPLE["Purple Kali<br/>SIEM & Monitoring<br/>192.168.2.9"]
            RED["Red Kali<br/>Attack Platform<br/>192.168.2.50"]
        end

        subgraph DMZ["DMZ Network (192.168.4.0/24)"]
            PFS_OPT1["pfSense OPT1<br/>192.168.4.1"]
            DVWA["DVWA<br/>Vulnerable Web App<br/>192.168.4.10"]
            WEBSRV["WebSRV<br/>Baseline Server<br/>192.168.4.20"]
        end
    end

    EXT <---> PFS_WAN
    PFS_WAN <---> PFS_LAN
    PFS_LAN <---> DC01
    PFS_LAN <---> CLIENT01
    PFS_LAN <---> PURPLE
    PFS_LAN <---> RED
    PFS_LAN <---> PFS_OPT1
    PFS_OPT1 <---> DVWA
    PFS_OPT1 <---> WEBSRV

    style EXT fill:#ff9999
    style PFS_WAN fill:#ffcc99
    style PFS_LAN fill:#99ccff
    style PURPLE fill:#cc99ff
    style RED fill:#ff6666
    style DVWA fill:#ffcc66
```

### SIEM Data Flow

```mermaid
flowchart LR
    subgraph Sources["Log Sources"]
        WIN["Windows Events<br/>Winlogbeat"]
        SYS["Sysmon<br/>Process Monitoring"]
        LIN["Linux Logs<br/>Filebeat"]
        NET["Network Traffic<br/>Packetbeat/Suricata"]
        FIRE["Firewall Logs<br/>Syslog"]
    end

    subgraph Ingestion["Log Ingestion"]
        LS["Logstash<br/>Parsing & Enrichment"]
        FS["Fleet Server<br/>Agent Management"]
    end

    subgraph Storage["Data Storage"]
        ES["Elasticsearch<br/>Log Storage"]
    end

    subgraph Analysis["Analysis & Visualization"]
        KB["Kibana<br/>Dashboards"]
        AL["Alerting<br/>Watcher/Detection Rules"]
    end

    subgraph Response["Response"]
        SOC["SOC Analyst"]
        SOAR["SOAR Platform<br/>(Optional)"]
    end

    WIN --> LS
    SYS --> LS
    LIN --> LS
    NET --> LS
    FIRE --> LS

    LS --> ES
    FS --> ES

    ES --> KB
    ES --> AL

    KB --> SOC
    AL --> SOC
    AL --> SOAR
```

### MITRE ATT&CK Coverage

```mermaid
mindmap
  root((MITRE ATT&CK<br/>Coverage))
    Initial_Access
      T1566_Phishing["T1566 - Phishing"]
      T1190_Exploit_Public_Facing["T1190 - Exploit Public-Facing"]
    Execution
      T1059_Command_Scripting["T1059 - Cmd/Scripting"]
      T1569_System_Services["T1569 - System Services"]
    Persistence
      T1547_Boot_Autostart["T1547 - Boot/Autostart"]
      T1136_Create_Account["T1136 - Create Account"]
    Privilege_Escalation
      T1078_Valid_Accounts["T1078 - Valid Accounts"]
    Defense_Evasion
      T1070_Indicator_Removal["T1070 - Indicator Removal"]
    Credential_Access
      T1110_Brute_Force["T1110 - Brute Force"]
      T1003_OS_Credential_Dump["T1003 - OS Credential Dump"]
    Discovery
      T1046_Network_Service_Scan["T1046 - Network Service Scan"]
      T1087_Account_Discovery["T1087 - Account Discovery"]
    Lateral_Movement
      T1021_Remote_Services["T1021 - Remote Services"]
    Collection
      T1005_Data_Local_System["T1005 - Data from Local System"]
    Command_and_Control
      T1071_Application_Layer["T1071 - App Layer Protocol"]
    Exfiltration
      T1041_Exfiltration_C2["T1041 - Exfil over C2"]
```

### Attack Lifecycle with Detections

```mermaid
sequenceDiagram
    participant Attacker as Red Kali
    participant Target as Windows 10
    participant DC as Domain Controller
    participant IDS as Suricata IDS
    participant SIEM as ELK Stack
    participant Analyst as SOC Analyst

    Note over Attacker,Analyst: Phase 1: Reconnaissance
    Attacker->>Target: Nmap scan (T1046)
    IDS->>SIEM: Alert: Network Scan Detected
    SIEM->>Analyst: Low Severity Alert

    Note over Attacker,Analyst: Phase 2: Initial Access
    Attacker->>Target: Hydra brute force (T1110)
    Target->>DC: Failed auth attempts
    DC->>SIEM: Windows Event 4625
    SIEM->>Analyst: Medium Severity: Brute Force

    Note over Attacker,Analyst: Phase 3: Execution
    Attacker->>Target: PsExec execution (T1569)
    Target->>SIEM: Sysmon Event 1 (Process Create)
    Target->>SIEM: Windows Event 4688
    SIEM->>Analyst: High Severity: PsExec Detected

    Note over Attacker,Analyst: Phase 4: Lateral Movement
    Attacker->>DC: CrackMapExec (T1021)
    DC->>SIEM: Windows Event 4624 (Logon)
    IDS->>SIEM: SMB Anomaly Detected
    SIEM->>Analyst: High Severity: Lateral Movement
```

---

## VMware Configuration

### Virtual Network Editor Settings

| VMnet | Type | Subnet | DHCP | Purpose |
|-------|------|--------|------|---------|
| VMnet0 | Bridged | N/A | No | WAN/Internet access |
| VMnet2 | Host-only | 192.168.2.0/24 | Yes | Corporate network |
| VMnet4 | Host-only | 192.168.4.0/24 | Yes | DMZ network |

### VM Resource Allocation

| VM | vCPU | RAM | Disk | Network |
|----|------|-----|------|---------|
| pfSense | 2 | 2GB | 20GB | VMnet0, VMnet2, VMnet4 |
| DC01 | 2 | 4GB | 60GB | VMnet2 |
| Client01 | 2 | 4GB | 40GB | VMnet2 |
| Purple Kali | 4 | 8GB | 100GB | VMnet2 |
| Red Kali | 2 | 4GB | 60GB | VMnet2 |
| DVWA | 1 | 2GB | 20GB | VMnet4 |
| WebSRV | 1 | 2GB | 20GB | VMnet4 |

---

## Security Controls Matrix

| Control Layer | Technology | Coverage | Detection Capability |
|---------------|------------|----------|---------------------|
| Network Perimeter | pfSense + Suricata | All traffic | Protocol anomalies, signatures |
| Endpoint (Windows) | Sysmon | Process/DNS/Network | Process injection, driver load |
| Endpoint (Linux) | Auditd + Auditbeat | System calls | Privilege escalation, file access |
| Identity | Windows Event Log | Authentication | Brute force, anomalous logons |
| Application | DVWA logs | Web attacks | SQLi, XSS, LFI attempts |
| Centralized | ELK/Splunk | All sources | Correlation, ML-based detection |

---

*Document Version: 2.0*  
*Last Updated: 2026-02-12*  
*Author:Engineer Maher Mansour*
