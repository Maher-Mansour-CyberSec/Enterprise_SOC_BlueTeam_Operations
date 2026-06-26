# Security Frameworks & Compliance Mapping

> Comprehensive mapping of cybersecurity frameworks relevant to SOC operations
> and detection engineering, with focus on Saudi Arabian market requirements.

---

## 🎯 Purpose

This document maps the Enterprise SOC Lab's detection coverage, controls, and
operational procedures against globally recognized cybersecurity frameworks.
This demonstrates comprehensive understanding of security governance beyond
technical implementation.

---

## 📊 Framework Coverage Matrix

| Framework | Coverage | Status | Priority |
|-----------|----------|--------|----------|
| **MITRE ATT&CK** | 22+ Techniques | ✅ Implemented | Critical |
| **NIST CSF 2.0** | All 6 Functions | ✅ Mapped | Critical |
| **NIST SP 800-61** | All Phases | ✅ Implemented | High |
| **ISO 27001:2022** | 8 Control Areas | ✅ Mapped | High |
| **CIS Controls v8** | 14 Control Groups | ✅ Mapped | High |
| **Cyber Kill Chain** | All 7 Phases | ✅ Mapped | Medium |
| **NCA ECC** | 4 Domains | 🟡 Familiar | Critical (KSA) |
| **SAMA CSF** | 6 Domains | 🟡 Familiar | Critical (KSA) |
| **PCI-DSS 4.0** | 12 Requirements | 🟡 Familiar | High (Banking) |
| **OWASP Top 10** | Web Security | 🟡 Familiar | Medium |

---

## 1️⃣ MITRE ATT&CK Framework

### Coverage Summary

The lab's detection rules cover **22+ MITRE ATT&CK techniques** across **9 tactical
objectives**, providing comprehensive visibility across the adversary kill chain.

### Tactic-by-Tactic Coverage

#### 🔵 TA0001 - Initial Access
- T1190 - Exploit Public-Facing Application (Suricata)
- T1078 - Valid Accounts (SMB Detection)

#### 🔵 TA0002 - Execution
- **T1059.001** - PowerShell (Sigma + SPL)
- **T1047** - WMI (Sigma + SPL)

#### 🔵 TA0003 - Persistence
- **T1547.001** - Registry Run Keys (Sigma)
- **T1053.005** - Scheduled Tasks (Sigma)

#### 🔵 TA0004 - Privilege Escalation
- T1546.003 - WMI Event Subscription (YARA)
- T1055 - Process Injection (Sigma)

#### 🔵 TA0005 - Defense Evasion
- **T1027** - Obfuscated Files (Sigma)
- **T1055.002** - CreateRemoteThread (Sigma)
- **T1562.001** - Disable Defender (Sigma)

#### 🔵 TA0006 - Credential Access
- **T1003.001** - LSASS Memory (Sigma + SPL)
- **T1110** - Brute Force (SPL)
- **T1558.003** - Kerberoasting (Sigma + SPL)

#### 🔵 TA0007 - Discovery
- T1046 - Network Service Scanning
- T1087 - Account Discovery

#### 🔵 TA0008 - Lateral Movement
- **T1021.002** - SMB Admin Shares (Sigma + SPL)
- **T1550.003** - Pass-the-Hash (Sigma)

#### 🔵 TA0011 - Command and Control
- **T1071.001** - Web Protocols (Sigma)
- **T1071.004** - DNS (Sigma + SPL)
- T1090 - Proxy/Tunneling
- T1568.002 - DGA

#### 🔵 TA0040 - Impact
- T1486 - Data Encrypted for Impact (SPL)
- T1490 - Inhibit System Recovery (SPL)

---

## 2️⃣ NIST Cybersecurity Framework (CSF) 2.0

### Function Coverage

#### 🛡️ GOVERN (NEW in CSF 2.0)
- ✅ Organizational Context documented
- ✅ Risk Management Strategy
- ✅ Roles, Responsibilities, Authorities
- ✅ Policies, Processes, Procedures
- ✅ Oversight & Governance

#### 🔍 IDENTIFY
- ✅ Asset Management (pfSense, Splunk inventory)
- ✅ Business Environment (lab scope documented)
- ✅ Risk Assessment (vulnerability tracking)
- ✅ Risk Management Strategy
- ✅ Supply Chain Risk Management

#### 🛡️ PROTECT
- ✅ Identity Management & Access Control (AD, pfSense)
- ✅ Awareness & Training (Certifications listed)
- ✅ Data Security (encryption, integrity)
- ✅ Platform Security (hardening)
- ✅ Technology Infrastructure Resilience

#### 🔍 DETECT
- ✅ **Anomalies and Events** (Sigma Rules)
- ✅ **Continuous Monitoring** (SIEM 24/7)
- ✅ **Detection Processes** (SOC runbooks)
- ✅ **Detection Coverage Analysis** (MITRE mapping)

#### ⚡ RESPOND
- ✅ **Incident Response Plan** (runbooks)
- ✅ **Incident Analysis** (case management)
- ✅ **Incident Response Communication** (escalation matrix)
- ✅ **Incident Mitigation** (isolation procedures)
- ✅ **Incident Response Improvements** (lessons learned)

#### 🔄 RECOVER
- ✅ Recovery Planning
- ✅ Improvements (CHANGELOG.md)
- ✅ Communication (stakeholder updates)

---

## 3️⃣ NIST SP 800-61 (Incident Response)

### Phase Coverage

#### Phase 1: Preparation
- ✅ SOC L1/L2 Procedures documented
- ✅ Tool inventory (SIEM, EDR, Forensics)
- ✅ Communication plans (escalation matrix)

#### Phase 2: Detection & Analysis
- ✅ **25 detection rules** covering multiple threat types
- ✅ **TheHive case management** workflow
- ✅ **MISP threat intelligence** integration

#### Phase 3: Containment, Eradication, Recovery
- ✅ Network isolation procedures
- ✅ Credential rotation playbook
- ✅ System restoration procedures

#### Phase 4: Post-Incident Activity
- ✅ Lessons learned documentation
- ✅ Detection rule improvements
- ✅ Runbook updates

---

## 4️⃣ ISO 27001:2022

### Control Areas Covered

#### A.5 Organizational Controls
- A.5.1 Information security policies
- A.5.2 Information security roles & responsibilities
- A.5.7 Threat intelligence
- A.5.24 Incident management planning
- A.5.25 Assessment & decision on information security events
- A.5.26 Response to information security incidents

#### A.6 People Controls
- A.6.3 Information security awareness & education
- A.6.8 Information security event reporting

#### A.7 Physical Controls
- A.7.9 Security of assets off-premises

#### A.8 Technological Controls
- **A.8.1 User endpoint devices** (Sysmon, Defender)
- **A.8.2 Privileged access rights** (LAPS concepts)
- **A.8.5 Secure authentication** (MFA awareness)
- **A.8.6 Capacity management** (SIEM tuning)
- **A.8.7 Protection against malware** (YARA Rules)
- **A.8.8 Management of technical vulnerabilities**
- **A.8.15 Logging** (comprehensive)
- **A.8.16 Monitoring activities** (24/7 SOC)
- **A.8.20 Networks security** (pfSense, Suricata)
- **A.8.21 Security of network services**
- **A.8.22 Segregation of networks** (DMZ, VLANs)
- **A.8.23 Web filtering**
- **A.8.25 Secure development life cycle**
- **A.8.28 Secure coding**

#### A.5.31 & 5.34 (NEW 2022)
- Legal, statutory, regulatory & contractual requirements
- Privacy & protection of personally identifiable information (PII)

---

## 5️⃣ CIS Critical Security Controls v8

### Implementation Group 1 (Basic)

| Control | Description | Status |
|---------|-------------|--------|
| 1 | Inventory of Enterprise Assets | ✅ |
| 2 | Inventory of Software Assets | ✅ |
| 3 | Data Protection | ✅ |
| 4 | Secure Configuration | ✅ |
| 5 | Account Management | ✅ |
| 6 | Access Control Management | ✅ |

### Implementation Group 2 (Foundational)

| Control | Description | Status |
|---------|-------------|--------|
| 7 | Continuous Vulnerability Management | ✅ |
| 8 | Audit Log Management | ✅ (24/7 SIEM) |
| 9 | Email & Web Browser Protections | ✅ |
| 10 | Malware Defenses | ✅ |
| 11 | Data Recovery | ✅ |
| 12 | Network Infrastructure Management | ✅ |
| 13 | Network Monitoring & Defense | ✅ |

### Implementation Group 3 (Organizational)

| Control | Description | Status |
|---------|-------------|--------|
| 14 | Security Awareness & Skills Training | ✅ |
| 15 | Service Provider Management | 🟡 |
| 16 | Application Software Security | 🟡 |
| 17 | Incident Response Management | ✅ |
| 18 | Penetration Testing | ✅ (Purple Team) |

---

## 6️⃣ Lockheed Martin Cyber Kill Chain

### Phase Coverage

1. **Reconnaissance** ✅ Detected via Suricata logs
2. **Weaponization** ✅ Threat intel (MISP)
3. **Delivery** ✅ Email/web filtering concepts
4. **Exploitation** ✅ Detection rules for exploits
5. **Installation** ✅ Persistence detection
6. **Command & Control** ✅ DNS/network detection
7. **Actions on Objectives** ✅ Data exfiltration detection

---

## 🇸🇦 Saudi Arabia Specific Frameworks

### NCA Essential Cybersecurity Controls (ECC)

#### Subdomains Covered

**1. Cybersecurity Governance**
- ✅ Policies & procedures
- ✅ Roles & responsibilities
- ✅ Risk management
- 🟡 Awareness & training

**2. Cybersecurity Defense**
- ✅ Asset management
- ✅ Identity & access management
- ✅ Information & document security
- ✅ Cybersecurity event management (SIEM)
- ✅ Cybersecurity incident management
- ✅ Cybersecurity operations
- ✅ Cybersecurity threat management
- ✅ Cybersecurity architecture

**3. Cybersecurity Resilience**
- ✅ Business continuity
- ✅ Disaster recovery
- ✅ Backup management
- ✅ Crisis management

**4. Third-Party & Cloud Cybersecurity**
- ✅ Third-party management
- 🟡 Cloud computing security

### SAMA Cybersecurity Framework (Banks)

#### Domains Covered

1. **Cyber Risk Management & Oversight**
2. **Cybersecurity Operations**
3. **Cyber Incident Management**
4. **Information Security**
5. **IT Asset Management**
6. **Third-Party Cyber Risk Management**

---

## 📋 Compliance Mapping Summary

### Detection Coverage by Compliance Requirement

| Requirement | Detection Mechanism | Evidence Location |
|-------------|---------------------|-------------------|
| Log monitoring (24/7) | Splunk + ELK | siem/ |
| Anomaly detection | Sigma Rules | detection-rules/sigma/ |
| Incident logging | TheHive | soc-operations/ |
| Threat intelligence | MISP | threat-intelligence/ |
| Network monitoring | Suricata, Zeek | firewall-ids_ips/ |
| Endpoint monitoring | Sysmon | siem/splunk/ |
| Access control | AD, RBAC | architecture/ |
| Vulnerability management | CVE tracking | detection-rules/ |
| Encryption | TLS, IPsec | architecture/ |

---

## 🎓 Continuous Improvement

### Quarterly Reviews
- [ ] Review detection rule effectiveness
- [ ] Update MITRE ATT&CK coverage
- [ ] Update compliance mappings
- [ ] Review incident trends
- [ ] Update runbooks

### Annual Updates
- [ ] Full framework coverage assessment
- [ ] Compliance audit preparation
- [ ] Skills gap analysis
- [ ] Tool evaluation

---

## 📚 References

- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [NIST CSF 2.0](https://www.nist.gov/cyberframework)
- [NIST SP 800-61 Rev. 2](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final)
- [ISO/IEC 27001:2022](https://www.iso.org/standard/27001)
- [CIS Controls v8](https://www.cisecurity.org/controls/v8)
- [NCA ECC (Saudi Arabia)](https://nca.gov.sa/)
- [SAMA CSF](https://www.sama.gov.sa/)

---

*Last Updated: November 2025*
*Document Author: Maher Mansour Mahyoub Ghaleb*
