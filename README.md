# Enterprise SOC Lab


## ⚠️ Important Notice
All IP addresses and network configurations in this project (code, diagrams, screenshots, and documentation) are **placeholders**.
Do **not** use them directly in a live environment. Please configure your own IPs before running the project.

![Enterprise SOC Lab](https://maher-mansour-cybersec.github.io/Enterprise_SOC_BlueTeam_Operations/assets/diagrams/lab-banner-v2.png)



<p align="center">
  <a href="#architecture"><img src="https://img.shields.io/badge/Architecture-Enterprise-blue?style=for-the-badge&logo=vmware"/></a>
  <a href="#siem"><img src="https://img.shields.io/badge/SIEM-ELK%20|%20Splunk-green?style=for-the-badge&logo=elastic"/></a>
  <a href="#threat-intelligence"><img src="https://img.shields.io/badge/Threat%20Intel-MISP-red?style=for-the-badge"/></a>
  <a href="#attack-defense"><img src="https://img.shields.io/badge/MITRE-ATT%26CK-orange?style=for-the-badge"/></a>
  <a href="#validation"><img src="https://img.shields.io/badge/Defense-Validation%20%26%20Testing-lightgrey?style=for-the-badge"/></a>
</p>


<p align="center">
  <b>Production-Grade Enterprise SOC Lab for Blue Team Operations, Detection Engineering, and Security Control Validation</b>
</p>


---

## Executive Summary

The **Enterprise SOC Lab** is a comprehensive, production-grade cybersecurity environment designed for:

- **Security Operations Centers (SOC)**: Real-time monitoring, alert triage, and incident response
- **Detection Engineering**: Custom rule development with MITRE ATT&CK alignment
- **Threat Intelligence**: Operational MISP integration for proactive defense
- **Purple Team Operations**: Validated attack simulations with measurable outcomes
- **Professional Development**: Portfolio-ready demonstration of enterprise security skills

### Key Differentiators

| Feature | Implementation |
|---------|---------------|
| **Dual SIEM Modes** | Run ELK Stack OR Splunk Enterprise independently |
| **Defense in Depth** | Network IDS/IPS + Endpoint Monitoring + SIEM Correlation |
| **MITRE ATT&CK Coverage** | 20+ techniques with validated detection rules |
| **Threat Intelligence** | Real-time IOC enrichment via MISP |
| **Production Ready** | High availability, backup, and operational procedures |

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Infrastructure Components](#infrastructure-components)
3. [SIEM Deployment Modes](#siem-deployment-modes)
4. [Network Segmentation](#network-segmentation)
5. [Detection Coverage](#detection-coverage)
6. [Quick Start Guide](#quick-start-guide)
7. [Repository Structure](#repository-structure)
8. [Documentation Index](#documentation-index)
9. [Production Readiness](#production-readiness)
10. [Skills & Career Value](#skills--career-value)

---

## Architecture Overview

### High-Level Architecture

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

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA COLLECTION FLOW                            │
└─────────────────────────────────────────────────────────────────────────────┘

  Windows Endpoints ──────┐
  (Winlogbeat, Sysmon)    │
                          ▼
  Linux Endpoints ────────┐    ┌──────────────┐    ┌──────────────┐
  (Auditbeat, Filebeat)   ├───►│  Logstash    ├───►│ Elasticsearch│
                          │    │  (Parsing)   │    │  (Storage)   │
                          │    └──────────────┘    └──────┬───────┘
                          │                               │
  Network Traffic ────────┤                               ▼
  (Packetbeat, Suricata)  │                        ┌──────────────┐
                          │                        │   Kibana     │
  Firewall Logs ──────────┘                        │(Dashboards)  │
  (pfSense Syslog)                                 └──────────────┘

  OR (Alternative Mode):

  Windows/Linux ──────────┐    ┌──────────────┐    ┌──────────────┐
  (Splunk UF)             ├───►│   Splunk     ├───►│   Splunk     │
                          │    │  Indexer     │    │   Search     │
  Network Traffic ────────┤    └──────────────┘    └──────────────┘
  (Suricata Syslog)       │
                          ▼
                   ┌──────────────┐
                   │   Splunk     │
                   │  Dashboards  │
                   └──────────────┘
```

For detailed architecture documentation, see [Architecture Overview](./architecture/architecture-overview.md).

---

## Infrastructure Components

### Core Infrastructure

| Component | Platform | IP Address | Role |
|-----------|----------|------------|------|
| **pfSense Firewall** | pfSense CE 2.7.x | 192.168.1.251 | NGFW, Suricata IDS/IPS, VPN |
| **Domain Controller** | Windows Server 2019 | 192.168.2.2 | Active Directory, DNS, DHCP, CA |
| **Client Workstation** | Windows 10 Enterprise | 192.168.2.101 | Domain endpoint with Sysmon |
| **Purple Kali** | Kali Linux | 192.168.2.9 | SIEM, threat intel, monitoring |
| **Red Kali** | Kali Linux | 192.168.2.50 | Attack simulation platform |

### Security & Monitoring Stack

| Platform | Version | Purpose | Deployment Mode |
|----------|---------|---------|-----------------|
| **Elasticsearch** | 8.x | Log storage & search | ELK Mode |
| **Logstash** | 8.x | Log parsing & enrichment | ELK Mode |
| **Kibana** | 8.x | Visualization & dashboards | ELK Mode |
| **Fleet Server** | 8.x | Agent management | ELK Mode |
| **Splunk Enterprise** | 9.x | SIEM & analytics | Splunk Mode |
| **Splunk Universal Forwarder** | 9.x | Log forwarding | Splunk Mode |
| **MISP** | 2.4.x | Threat intelligence | Both Modes |
| **Suricata** | 6.x | Network IDS/IPS | Both Modes |

### Red Team & Deception Tools

| Tool | Purpose | Integration |
|------|---------|-------------|
| **Red Team Canary** | Deception tokens & honeypots | Deployed across network |
| **Atomic Red Team** | MITRE ATT&CK test emulation | Run on Red Kali |
| **Caldera** | Adversary emulation platform | Optional deployment |
| **Metasploit** | Exploitation framework | Pre-installed on Red Kali |

---

## SIEM Deployment Modes

### Mode 1: ELK Stack Deployment

Run the complete Elastic Stack for log aggregation and analysis.

**Services:**
- Elasticsearch (data storage)
- Logstash (log parsing)
- Kibana (visualization)
- Fleet Server (agent management)

**When to use:**
- Learning open-source SIEM technologies
- Building custom detection rules
- Cost-conscious environments
- Integration with Elastic Security

```bash
# Switch to ELK Mode
sudo systemctl stop splunk
sudo systemctl disable splunk
sudo systemctl start elasticsearch logstash kibana
```

### Mode 2: Splunk Deployment

Run Splunk Enterprise as your SIEM platform.

**Services:**
- Splunk Enterprise (indexer + search head)
- Splunk Universal Forwarders on endpoints
- Splunk Deployment Server

**When to use:**
- Learning commercial SIEM platforms
- Enterprise environment simulation
- Splunk certification preparation
- Integration with Splunk ES

```bash
# Switch to Splunk Mode
sudo systemctl stop elasticsearch logstash kibana
sudo systemctl disable elasticsearch logstash kibana
sudo systemctl start splunk
```

### Feature Comparison

| Feature | ELK Stack | Splunk |
|---------|-----------|--------|
| Cost | Free (open source) | Trial/Enterprise license |
| Detection Rules | Custom YAML/KQL | SPL + Saved Searches |
| Dashboards | Kibana | Splunk Dashboards |
| Agent Management | Fleet | Deployment Server |
| Learning Curve | Moderate | Moderate |

---

## Network Segmentation

### Security Zones

| Zone | Subnet | VLAN | Trust Level | Purpose |
|------|--------|------|-------------|---------|
| **Corporate** | 192.168.2.0/24 | 20 | High | AD domain, workstations |
| **SOC/Monitoring** | 192.168.2.0/24 | 20 | Medium | SIEM, threat intel |
| **DMZ/Public** | 192.168.4.0/24 | 40 | Low | Web services, external |

### Firewall Rules Summary

| Rule | Source | Destination | Service | Action |
|------|--------|-------------|---------|--------|
| 100 | Corporate | Any | DNS (53) | Allow |
| 110 | Corporate | Any | HTTP/HTTPS | Allow |
| 120 | Corporate | SOC | Syslog (514) | Allow |
| 130 | DMZ | Corporate | Any | Block |
| 140 | Any | DMZ | HTTP/HTTPS | Allow |
| 999 | Any | Any | Any | Block |

---

## Detection Coverage

### MITRE ATT&CK Coverage

| Tactic | Technique | Detection Source |
|--------|-----------|------------------|
| Initial Access | T1190 - Exploit Public-Facing | Suricata, Web Logs |
| Execution | T1059.001 - PowerShell | Sysmon Event 1, Windows 4103/4104 |
| Persistence | T1547.001 - Registry Run Keys | Sysmon Event 12/13 |
| Privilege Escalation | T1134.001 - Token Impersonation | Sysmon Event 10, 25 |
| Credential Access | T1003.001 - LSASS Memory | Sysmon Event 10 |
| Discovery | T1046 - Network Service Scanning | Suricata |
| Lateral Movement | T1021.002 - SMB/Admin Shares | Windows Event 4624, 5140 |
| Command and Control | T1071.001 - Web Protocols | Suricata, Packetbeat |

For complete MITRE mapping, see [MITRE ATT&CK Mapping](./attack-defense/mitre-mapping.md).

---

## Quick Start Guide

### Prerequisites

- VMware Workstation Pro 17+ or ESXi 7.0+
- Minimum 32GB RAM (64GB recommended)
- 500GB+ available storage (SSD recommended)
- 4+ CPU cores with virtualization support

### Deployment Order

1. **Infrastructure Foundation**
   - Deploy pfSense firewall
   - Configure network segments
   - Verify routing and NAT

2. **Active Directory Domain**
   - Install Windows Server 2019
   - Promote to Domain Controller
   - Configure DNS and DHCP

3. **Endpoint Deployment**
   - Join Windows 10 to domain
   - Install Sysmon and logging agents

4. **Security Stack** (Choose ONE mode)
   - **ELK Mode**: Deploy Purple Kali with ELK Stack
   - **Splunk Mode**: Deploy Purple Kali with Splunk

5. **Red Team Tools**
   - Deploy Red Team Canary tokens
   - Install Atomic Red Team
   - Configure Caldera (optional)

6. **Attack Surface**
   - Deploy DVWA and WebSRV
   - Configure Suricata rules

7. **Validation**
   - Execute test attacks
   - Verify detection and alerting
   - Document baseline behavior

---

## Repository Structure

```
enterprise-soc-lab/
│
├── README.md                          # This file
├── LICENSE                            # MIT License
├── CONTRIBUTING.md                    # Contribution guidelines
├── CHANGELOG.md                       # Version history
│
├── architecture/                      # Architecture documentation
│   ├── architecture-overview.md       # Detailed architecture
│   ├── network-reference.md           # IP addressing and VLANs
│   └── data-flow.md                   # Data flow documentation
│
├── siem/                              # SIEM documentation
│   ├── elk/                           # ELK Stack (Mode 1)
│   │   ├── elk-setup.md               # Installation guide
│   │   ├── logstash-pipelines.md      # Pipeline configurations
│   │   ├── dashboards.md              # Dashboard imports
│   │   └── detection-rules.md         # KQL detection rules
│   └── splunk/                        # Splunk (Mode 2)
│       ├── splunk-setup.md            # Installation guide
│       ├── forwarders.md              # UF configuration
│       ├── dashboards.md              # Dashboard configs
│       └── saved-searches.md          # SPL detection rules
│
├── threat-intelligence/               # Threat intel documentation
│   ├── misp-setup.md                  # MISP installation
│   ├── feed-configuration.md          # Feed setup
│   └── ioc-enrichment.md              # Enrichment procedures
│
├── firewall-ids/                      # Network security
│   ├── pfsense-setup.md               # pfSense configuration
│   ├── suricata-rules.md              # IDS/IPS rules
│   └── vpn-configuration.md           # VPN setup
│
├── red-team/                          # Red Team tools
│   ├── canary-deployment.md           # Deception tokens
│   ├── atomic-red-team.md             # ATT&CK emulation
│   └── caldera-setup.md               # Adversary emulation
│
├── attack-defense/                    # Attack scenarios
│   ├── mitre-mapping.md               # ATT&CK technique mapping
│   ├── attack-scenarios.md            # Documented attacks
│   └── detection-validation.md        # Purple team validation
│
├── soc-operations/                    # SOC procedures
│   ├── soc-l1-procedures.md           # Tier 1 analyst workflows
│   ├── soc-l2-procedures.md           # Tier 2 analyst workflows
│   ├── runbooks.md                    # Operational runbooks
│   └── escalation-matrix.md           # Escalation procedures
│
├── docs/                              # Additional documentation
│   ├── production-readiness.md        # HA, DR, monitoring
│   ├── skills-matrix.md               # Career alignment
│   └── certification-guide.md         # Cert study guide
│
└── assets/                            # Visual assets
    ├── diagrams/                      # Architecture diagrams
    └── images/                        # Screenshots
```

---

## Documentation Index

### Getting Started
- [Architecture Overview](./architecture/architecture-overview.md)
- [Network Reference](./architecture/network-reference.md)
- [Data Flow Documentation](./architecture/data-flow.md)

### SIEM Configuration
**ELK Stack Mode:**
- [ELK Setup Guide](./siem/elk/elk-setup.md)
- [Logstash Pipelines](./siem/elk/logstash-pipelines.md)
- [Detection Rules (KQL)](./siem/elk/detection-rules.md)

**Splunk Mode:**
- [Splunk Setup Guide](./siem/splunk/splunk-setup.md)
- [Universal Forwarders](./siem/splunk/forwarders.md)
- [Saved Searches (SPL)](./siem/splunk/saved-searches.md)

### Threat Intelligence
- [MISP Setup](./threat-intelligence/misp-setup.md)
- [Feed Configuration](./threat-intelligence/feed-configuration.md)

### Network Security
- [pfSense Setup](./firewall-ids/pfsense-setup.md)
- [Suricata Rules](./firewall-ids/suricata-rules.md)

### Attack & Defense
- [MITRE ATT&CK Mapping](./attack-defense/mitre-mapping.md)
- [Attack Scenarios](./attack-defense/attack-scenarios.md)
- [Detection Validation](./attack-defense/detection-validation.md)

### SOC Operations
- [L1 Analyst Procedures](./soc-operations/soc-l1-procedures.md)
- [L2 Analyst Procedures](./soc-operations/soc-l2-procedures.md)
- [Operational Runbooks](./soc-operations/runbooks.md)

---

## Production Readiness

This lab is designed with production-grade standards:

| Aspect | Implementation |
|--------|---------------|
| **High Availability** | Elasticsearch cluster, Splunk indexer clustering |
| **Backup & Recovery** | Automated snapshots, documented restore procedures |
| **Monitoring** | Health checks, alerting thresholds, dashboards |
| **Security** | TLS encryption, access controls, audit logging |
| **Scalability** | Horizontal scaling guides, capacity planning |

For complete details, see [Production Readiness](./docs/production-readiness.md).

---

## Skills & Career Value

This project demonstrates expertise aligned with industry roles:

| Role | Skills Demonstrated |
|------|-------------------|
| **SOC Analyst** | Log analysis, alert triage, incident response |
| **Detection Engineer** | Rule development, MITRE mapping, validation |
| **SIEM Engineer** | Platform deployment, pipeline configuration |
| **Threat Intel Analyst** | MISP operation, IOC enrichment |
| **Security Architect** | Infrastructure design, defense in depth |

### Certification Alignment

- CompTIA Security+, CySA+
- (ISC)² CISSP
- GIAC GCIH, GCIA, GMON
- Splunk Core Certified
- Elastic Certified Engineer

For detailed career guidance, see [Skills Matrix](./docs/skills-matrix.md).

---

## Contributing & License

### Contributing

Contributions to improve documentation, add attack scenarios, or enhance detection capabilities are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### License

This project is released under the MIT License for educational use. See [LICENSE](LICENSE) for details.

### Disclaimer

This lab environment is intended for **authorized security testing and educational purposes only**. All attacks and testing should be conducted within this isolated lab environment. Never use these techniques on systems without explicit authorization.

---

<p align="center">
  <i>Built for defenders. Validated through purple team operations. Ready for enterprise deployment.</i>
</p>

<p align="center">
  <a href="https://github.com/Maher-Mansour-CyberSec/Enterprise_SOC_BlueTeam_Operations">
    <img src="https://img.shields.io/badge/GitHub-View%20Repository-blue?style=for-the-badge&logo=github"/>
  </a>
</p>