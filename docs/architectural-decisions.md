# Architectural Decisions

## Overview

This document records the key architectural decisions made during the design and implementation of the Enterprise SOC Lab. These decisions reflect enterprise-grade thinking, trade-off analysis, and alignment with industry best practices.

---

## Decision Log

### ADR-001: Dual SIEM Deployment Modes

**Status**: Accepted

**Context**:
Organizations have different SIEM preferences and licensing constraints. Some prefer open-source solutions (ELK Stack) for cost and flexibility, while others require commercial platforms (Splunk) for enterprise features and support.

**Decision**:
Implement dual deployment modes where the lab can run either ELK Stack OR Splunk Enterprise independently, with a simple switch mechanism.

**Consequences**:
- **Positive**: Flexibility for different organizational needs; learners can practice on both platforms
- **Positive**: No vendor lock-in; skills transfer between platforms
- **Negative**: Increased documentation complexity
- **Negative**: Some features may differ between modes

**Alternatives Considered**:
- Single SIEM only: Too restrictive
- Both SIEMs simultaneously: Resource intensive, confusing for learners

---

### ADR-002: Network Segmentation with Three Zones

**Status**: Accepted

**Context**:
Security requires network isolation to contain breaches and limit lateral movement. The lab needs to simulate real enterprise network architecture.

**Decision**:
Implement three security zones with distinct trust levels:
1. **Corporate Zone** (High Trust): Domain controllers, workstations
2. **SOC Zone** (Medium Trust): SIEM, monitoring, attack simulation
3. **DMZ Zone** (Low Trust): Public-facing services, vulnerable applications

**Consequences**:
- **Positive**: Defense in depth with clear trust boundaries
- **Positive**: Realistic enterprise network simulation
- **Positive**: Attack scenarios can demonstrate lateral movement
- **Negative**: Increased network configuration complexity
- **Negative**: More VMs required

**Alternatives Considered**:
- Flat network: Simpler but unrealistic, no security boundaries
- More zones: Overly complex for lab purposes

---

### ADR-003: VMware Virtualization Platform

**Status**: Accepted

**Context**:
The lab requires virtualization for multiple operating systems and network segments. Platform choice affects compatibility, performance, and ease of use.

**Decision**:
Use VMware Workstation Pro (or ESXi) as the primary virtualization platform with virtual network editor for custom segments.

**Consequences**:
- **Positive**: Industry-standard platform with excellent Windows support
- **Positive**: Virtual Network Editor enables custom network segments
- **Positive**: Snapshot functionality for rollback
- **Negative**: Licensing cost for Workstation Pro
- **Negative**: Not open source

**Alternatives Considered**:
- VirtualBox: Free but limited network configuration
- Proxmox: Open source but steeper learning curve
- Hyper-V: Windows-only, limited Linux guest support

---

### ADR-004: Sysmon for Windows Endpoint Monitoring

**Status**: Accepted

**Context**:
Windows endpoints need comprehensive monitoring for process execution, network connections, and file system activity.

**Decision**:
Use Microsoft Sysmon as the primary Windows endpoint monitoring agent with a hardened configuration optimized for threat detection.

**Consequences**:
- **Positive**: Free, from Microsoft, widely adopted
- **Positive**: Rich event types (27 different event IDs)
- **Positive**: Integrates with both ELK and Splunk
- **Negative**: Requires careful tuning to avoid log flooding
- **Negative**: No built-in alerting; requires SIEM integration

**Alternatives Considered**:
- Windows Event Log only: Insufficient detail
- Commercial EDR: Cost prohibitive for lab
- OSQuery: Good for queries, not real-time monitoring

---

### ADR-005: Suricata for Network IDS/IPS

**Status**: Accepted

**Context**:
Network traffic analysis requires signature-based detection and protocol analysis capabilities.

**Decision**:
Use Suricata as the network IDS/IPS, deployed inline on pfSense for real-time detection and blocking.

**Consequences**:
- **Positive**: Open source, high performance, multi-threaded
- **Positive**: Compatible with Snort rules
- **Positive**: EVE.JSON output for easy SIEM integration
- **Negative**: Rule management complexity
- **Negative**: False positive potential without tuning

**Alternatives Considered**:
- Snort: Older, single-threaded
- Zeek: Better for protocol analysis, weaker signature detection
- Commercial NGFW: Cost prohibitive

---

### ADR-006: MISP for Threat Intelligence

**Status**: Accepted

**Context**:
Threat intelligence requires IOC management, feed integration, and sharing capabilities.

**Decision**:
Use MISP (Malware Information Sharing Platform) as the threat intelligence platform with automated feed ingestion.

**Consequences**:
- **Positive**: Open source, industry standard for TI sharing
- **Positive**: Rich API for SIEM integration
- **Positive**: Active community with many feeds
- **Negative**: Resource intensive (PHP/MySQL)
- **Negative**: Learning curve for effective use

**Alternatives Considered**:
- OpenCTI: Newer, GraphQL-based, but less mature
- Commercial TI platforms: Cost prohibitive
- Manual IOC lists: Not scalable

---

### ADR-007: Elastic Agent with Fleet Server

**Status**: Accepted

**Context**:
ELK Stack requires agent management for configuration deployment and updates.

**Decision**:
Use Elastic Agent with Fleet Server for centralized agent management in ELK mode.

**Consequences**:
- **Positive**: Centralized configuration management
- **Positive**: Single agent for all data sources
- **Positive**: Automatic updates
- **Negative**: Requires Fleet Server infrastructure
- **Negative**: Newer technology with evolving documentation

**Alternatives Considered**:
- Beats individually: More complex management
- Logstash as shipper: Heavier resource usage

---

### ADR-008: Splunk Universal Forwarder

**Status**: Accepted

**Context**:
Splunk requires efficient log forwarding from endpoints to indexers.

**Decision**:
Use Splunk Universal Forwarder with Deployment Server for configuration management in Splunk mode.

**Consequences**:
- **Positive**: Industry standard for Splunk environments
- **Positive**: Lightweight, efficient forwarding
- **Positive**: Deployment Server for configuration management
- **Negative**: Splunk licensing considerations
- **Negative**: Separate configuration from ELK mode

**Alternatives Considered**:
- Syslog forwarding: Less reliable, no compression
- HTTP Event Collector: Good for apps, not endpoints

---

### ADR-009: pfSense as Network Gateway

**Status**: Accepted

**Context**:
Network perimeter requires firewall, NAT, VPN, and routing capabilities.

**Decision**:
Use pfSense Community Edition as the network gateway and firewall platform.

**Consequences**:
- **Positive**: Free, feature-rich, enterprise-grade
- **Positive**: Suricata package for IDS/IPS
- **Positive**: Strong community and documentation
- **Negative**: BSD-based, different from Linux
- **Negative**: Hardware compatibility considerations

**Alternatives Considered**:
- OPNsense: Fork of pfSense, similar features
- IPFire: Simpler, less enterprise features
- Commercial firewall: Cost prohibitive

---

### ADR-010: Atomic Red Team for Attack Simulation

**Status**: Accepted

**Context**:
Detection validation requires reliable, repeatable attack simulations aligned with MITRE ATT&CK.

**Decision**:
Use Atomic Red Team as the primary attack simulation framework with custom atomic tests.

**Consequences**:
- **Positive**: MITRE ATT&CK aligned
- **Positive**: Open source, community-driven
- **Positive**: Easy to run and customize
- **Negative**: Limited to atomic tests (single techniques)
- **Negative**: Requires manual chaining for complex scenarios

**Alternatives Considered**:
- Caldera: Full adversary emulation, more complex
- Metasploit: More exploit-focused
- Custom scripts: Harder to maintain and share

---

### ADR-011: Red Team Canary for Deception

**Status**: Accepted

**Context**:
Early breach detection benefits from deception technology to identify attacker presence.

**Decision**:
Use Red Team Canary tokens (AWS keys, API tokens, etc.) deployed across the network.

**Consequences**:
- **Positive**: Early warning of compromise
- **Positive**: Low false positive rate
- **Positive**: Easy to deploy
- **Negative**: Limited to token-based detection
- **Negative**: Requires integration for alerting

**Alternatives Considered**:
- Commercial honeypots: Cost and complexity
- Custom honeypots: Maintenance overhead
- No deception: Missed detection opportunity

---

### ADR-012: Windows Server 2019 for Domain Controller

**Status**: Accepted

**Context**:
Active Directory is central to enterprise Windows environments and attack scenarios.

**Decision**:
Use Windows Server 2019 as the Domain Controller with AD DS, DNS, and DHCP roles.

**Consequences**:
- **Positive**: Current Windows Server version
- **Positive**: Supports modern authentication protocols
- **Positive**: Well-documented attack vectors
- **Negative**: Licensing requirements
- **Negative**: Resource intensive

**Alternatives Considered**:
- Windows Server 2022: Similar, less attack documentation
- Samba AD: Free but less realistic

---

### ADR-013: Kali Linux for Attack Platform

**Status**: Accepted

**Context**:
Attack simulation requires a comprehensive toolkit with regular updates.

**Decision**:
Use Kali Linux as the attack platform with two instances: Red Kali (attacker) and Purple Kali (SOC/monitoring).

**Consequences**:
- **Positive**: Industry-standard penetration testing distribution
- **Positive**: Pre-installed tools
- **Positive**: Regular updates
- **Negative**: Large ISO/download size
- **Negative: Many tools not needed for specific scenarios

**Alternatives Considered**:
- Parrot OS: Similar, lighter
- Custom Linux: More work to maintain

---

### ADR-014: DVWA for Web Application Testing

**Status**: Accepted

**Context**:
Web application attacks require intentionally vulnerable targets for safe testing.

**Decision**:
Use DVWA (Damn Vulnerable Web Application) as the primary web application target.

**Consequences**:
- **Positive**: Multiple vulnerability types
- **Positive**: Adjustable security levels
- **Positive**: Well-documented
- **Negative**: PHP/MySQL stack only
- **Negative**: Limited to OWASP Top 10 basics

**Alternatives Considered**:
- WebGoat: More educational, less realistic
- Mutillidae: Similar to DVWA
- Custom vulnerable app: Maintenance overhead

---

## Design Patterns

### Pattern: Defense in Depth

**Application**: Multiple security layers (network IDS, endpoint monitoring, SIEM correlation)

**Rationale**: No single control is sufficient; layered defense provides redundancy

### Pattern: Zero Trust

**Application**: Network segmentation, no implicit trust based on location

**Rationale**: Assume breach; verify all access attempts

### Pattern: Visibility-First

**Application**: Comprehensive logging from all components

**Rationale**: You can't detect what you can't see

### Pattern: Separation of Concerns

**Application**: Distinct components for networking, monitoring, attack simulation

**Rationale**: Easier to understand, maintain, and troubleshoot

---

## Technology Stack Summary

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| Virtualization | VMware Workstation Pro | 17+ | Infrastructure platform |
| Firewall/Router | pfSense CE | 2.7.x | Network gateway |
| IDS/IPS | Suricata | 6.x | Network detection |
| Domain Controller | Windows Server | 2019 | Active Directory |
| Endpoint OS | Windows | 10 Enterprise | Workstation |
| Endpoint Monitoring | Sysmon | Latest | Process/network monitoring |
| SIEM (Mode 1) | ELK Stack | 8.x | Log aggregation |
| SIEM (Mode 2) | Splunk Enterprise | 9.x | Log aggregation |
| Threat Intel | MISP | 2.4.x | IOC management |
| Attack Platform | Kali Linux | Latest | Penetration testing |
| Attack Framework | Atomic Red Team | Latest | ATT&CK emulation |
| Deception | Red Team Canary | Latest | Token-based detection |

---

## Future Considerations

### Potential Enhancements

1. **Cloud Integration**: Extend to AWS/Azure for hybrid scenarios
2. **Container Security**: Add Kubernetes cluster for container monitoring
3. **SOAR Platform**: Implement automated response workflows
4. **User Behavior Analytics**: Add UEBA for anomaly detection
5. **Threat Hunting**: Dedicated hunting workstation with Jupyter notebooks

### Deprecated Decisions

None at this time.

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*  
*Author: Enterprise Security Architecture Team*
