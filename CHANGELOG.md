# Changelog

All notable changes to the Enterprise SOC Lab project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-02-12

### Strategic Consolidation Release

This release represents a major architectural consolidation, combining the best elements from multiple project versions into a unified, enterprise-grade SOC lab environment.

### Added

#### Architecture & Design
- **Dual SIEM Deployment Modes**: Support for running ELK Stack OR Splunk Enterprise independently
- **Three-Zone Network Architecture**: Corporate, SOC, and DMZ zones with defined trust boundaries
- **Defense in Depth Strategy**: Layered security controls across network, endpoint, and application layers
- **Zero Trust Principles**: Network segmentation with no implicit trust based on location
- **Architectural Decision Records (ADRs)**: Documented rationale for key design decisions

#### Infrastructure Components
- **pfSense Firewall**: NGFW with Suricata IDS/IPS integration
- **Windows Server 2019 Domain Controller**: Full AD DS, DNS, DHCP, and CA services
- **Windows 10 Enterprise Workstations**: Domain-joined endpoints with Sysmon monitoring
- **Kali Linux Platforms**: Separate Red (attack) and Purple (SOC) instances
- **DVWA & WebSRV**: Vulnerable and baseline web applications for comparison

#### SIEM & Monitoring
- **ELK Stack Mode**: Elasticsearch, Logstash, Kibana, and Fleet Server
- **Splunk Mode**: Splunk Enterprise with Universal Forwarders and Deployment Server
- **Sysmon Integration**: Hardened configuration with 27 event types monitored
- **Suricata IDS/IPS**: Network detection with custom rules for lab scenarios
- **Packetbeat**: Network protocol analysis and flow monitoring

#### Threat Intelligence
- **MISP Platform**: Malware Information Sharing Platform with automated feeds
- **IOC Enrichment**: Real-time threat intelligence matching in SIEM
- **Feed Integration**: CIRCL, AlienVault OTX, Abuse.ch, and more

#### Attack Simulation
- **Atomic Red Team**: MITRE ATT&CK aligned atomic tests
- **Caldera Integration**: Optional adversary emulation platform
- **Red Team Canary**: Deception tokens for early breach detection
- **Custom Attack Scenarios**: Documented purple team exercises

#### Detection Engineering
- **20+ Detection Rules**: Mapped to MITRE ATT&CK techniques
- **SPL Queries**: Splunk saved searches for common attack patterns
- **KQL Queries**: Elasticsearch detection rules
- **False Positive Management**: Tuning procedures and documentation

#### Documentation
- **Comprehensive README**: Professional GitHub-ready entry point
- **Architecture Overview**: Detailed system design with Mermaid diagrams
- **Network Reference**: Complete IP addressing and VLAN configuration
- **MITRE ATT&CK Mapping**: Full technique coverage matrix
- **Production Readiness**: HA, DR, monitoring, and compliance guidance
- **Skills Matrix**: Career alignment and certification mapping
- **Operational Runbooks**: Step-by-step procedures for SOC analysts

#### Visual Assets
- **Architecture Diagrams**: Professional network topology visualizations
- **Data Flow Diagrams**: Log pipeline and event flow illustrations
- **MITRE Coverage Heatmap**: Visual detection coverage representation
- **Lab Banner**: Professional repository header image

### Changed

- **Folder Structure**: Reorganized into logical component directories
- **Documentation Style**: Standardized on enterprise technical writing standards
- **Naming Conventions**: Consistent lowercase-with-hyphens format
- **Code Organization**: Modular configuration files for maintainability

### Removed

- Redundant documentation from merged versions
- Duplicate configuration examples
- Outdated tool references

### Security

- TLS 1.2+ encryption for all data in transit
- LUKS encryption for data at rest
- Role-based access control matrix
- Audit logging enabled across all components
- Network segmentation with firewall rules

---

## [1.2.0] - 2025-12-15

### Added
- Fleet Server integration for Elastic Agent management
- Additional MITRE ATT&CK techniques (T1134, T1558)
- Caldera adversary emulation platform setup
- Red Team Canary token deployment guide

### Changed
- Updated Suricata to version 6.x
- Improved Logstash pipeline performance
- Enhanced MISP feed configuration

### Fixed
- DNS resolution issues in DMZ zone
- Sysmon configuration for Windows 11 compatibility

---

## [1.1.0] - 2025-09-20

### Added
- Splunk Enterprise deployment mode
- Splunk Universal Forwarder configuration
- Cross-platform detection rules (SPL and KQL)
- VMware ESXi deployment instructions

### Changed
- Refactored network segmentation for better isolation
- Updated Windows Server to 2019
- Improved documentation structure

### Fixed
- Elasticsearch cluster formation issues
- MISP API authentication problems

---

## [1.0.0] - 2025-06-01

### Initial Release

- ELK Stack SIEM deployment
- Windows Active Directory domain
- Sysmon endpoint monitoring
- Suricata network IDS
- Basic MITRE ATT&CK coverage
- Initial attack scenarios

---

## Release Notes Template

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security improvements
```

---

## Contributors

Thank you to all contributors who have helped improve this project:

- Enterprise Security Architecture Team
- Community contributors (see GitHub contributors page)

---

*For the complete list of changes, see the [GitHub commit history](https://github.com/yourusername/enterprise-soc-lab/commits/main).*
