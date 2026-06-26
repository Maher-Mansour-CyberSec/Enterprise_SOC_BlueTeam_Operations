# Detection Rules Library

> Production-ready detection rules developed and validated in the Enterprise SOC & Blue Team Operations Lab.

[![Sigma Rules](https://img.shields.io/badge/Sigma-12%20Rules-blue?style=flat-square)](sigma/)
[![SPL Queries](https://img.shields.io/badge/SPL-8%20Queries-green?style=flat-square)](spl/)
[![YARA Rules](https://img.shields.io/badge/YARA-5%20Rules-orange?style=flat-square)](yara/)

---

## 📊 Library Overview

| Category | Count | Format | MITRE Coverage |
|----------|-------|--------|----------------|
| **Sigma Rules** | 12 | YAML (.yml) | 9 Tactics |
| **SPL Queries** | 8 | Splunk SPL (.spl) | 8 Tactics |
| **YARA Rules** | 5 | YARA (.yar) | 4 Tactics |
| **Total Detection Files** | **25** | Multiple | **22+ Techniques** |

---

## 📂 Directory Structure

```
detection-rules/
├── sigma/           # 12 Sigma rules (universal detection format)
├── spl/             # 8 Splunk SPL queries (production-ready)
├── yara/            # 5 YARA rules (malware detection)
└── README.md        # This file
```

---

## 🎯 Sigma Rules (12)

Universal detection format compatible with multiple SIEM platforms.

### Windows Detections (10)

| # | Rule | MITRE | Severity | Status |
|---|------|-------|----------|--------|
| 01 | PowerShell Encoded Command | T1059.001 | HIGH | ✅ Stable |
| 02 | LSASS Memory Access | T1003.001 | CRITICAL | ✅ Stable |
| 03 | Registry Run Keys Persistence | T1547.001 | HIGH | ✅ Stable |
| 04 | Suspicious Scheduled Task | T1053.005 | HIGH | ✅ Stable |
| 05 | SMB Lateral Movement | T1021.002 | HIGH | ✅ Stable |
| 06 | WMI Lateral Execution | T1047 | HIGH | ✅ Stable |
| 07 | Pass-the-Hash (NTLM) | T1550.003 | MEDIUM | ✅ Stable |
| 08 | Kerberoasting Attack | T1558.003 | HIGH | ✅ Stable |
| 09 | Process Injection | T1055.002 | CRITICAL | ✅ Stable |
| 10 | Disable Windows Defender | T1562.001 | CRITICAL | ✅ Stable |

### Network Detections (2)

| # | Rule | MITRE | Severity | Status |
|---|------|-------|----------|--------|
| 11 | DNS C2 Exfiltration | T1071.004 | HIGH | ✅ Stable |
| 12 | Outbound C2 Beacons | T1071.001 | HIGH | ✅ Stable |

**Location:** [`sigma/`](sigma/)

---

## 📊 SPL Queries (8)

Production-ready Splunk SPL queries with detailed comments.

| # | Query | Use Case | MITRE |
|---|-------|----------|-------|
| 01 | Brute Force Detection | Password attacks | T1110 |
| 02 | LSASS Credential Dumping | Credential theft | T1003.001 |
| 03 | PowerShell Suspicious Activity | Execution anomalies | T1059.001 |
| 04 | Kerberoasting Detection | AD attacks | T1558.003 |
| 05 | SMB Lateral Movement | Network pivoting | T1021.002 |
| 06 | DNS Exfiltration & DGA | C2/tunneling | T1071.004 |
| 07 | WMI Lateral Execution | Stealth execution | T1047 |
| 08 | Ransomware Indicators | Pre-encryption detection | T1486 |

**Location:** [`spl/`](spl/)

---

## 🦠 YARA Rules (5)

Malware detection and classification rules.

| # | Rule | Detects | Severity |
|---|------|---------|----------|
| 01 | Mimikatz Detection | Credential dumping tools | CRITICAL |
| 02 | PowerShell Suspicious | Obfuscated payloads | HIGH |
| 03 | Cobalt Strike Beacon | C2 frameworks | CRITICAL |
| 04 | Reverse Shell & Web Shell | Remote access | CRITICAL |
| 05 | Persistence Mechanisms | Scheduled tasks, WMI, services | HIGH |

**Location:** [`yara/`](yara/)

---

## 🔄 Conversion & Compatibility

### Sigma → Splunk SPL
Use [sigmac](https://github.com/SigmaHQ/sigma-cli) or [uncoder.io](https://uncoder.io):

```bash
# Install sigma-cli
pip install sigma-cli

# Convert Sigma to Splunk SPL
sigma convert -t splunk sigma/win_susp_powershell_encoded_command.yml
```

### Sigma → Elasticsearch KQL
```bash
sigma convert -t es-qs sigma/win_susp_powershell_encoded_command.yml
```

### Sigma → Other SIEMs
Supports: Splunk, Elasticsearch, QRadar, Sentinel, Chronicle, Sumo Logic, etc.

---

## 📊 MITRE ATT&CK Coverage

```
Tactic                 | Detection Files | Coverage
-----------------------|-----------------|----------
Execution (TA0002)     | 3               | ████████ 80%
Persistence (TA0003)   | 2               | ████████ 80%
Privilege Escalation   | 1               | ████░░░░ 40%
Defense Evasion (TA0005)| 3              | ██████░░ 60%
Credential Access      | 3               | █████████ 90%
Discovery (TA0007)     | 1               | ███░░░░░ 30%
Lateral Movement       | 3               | ████████ 80%
Command and Control    | 3               | ████████ 80%
Impact (TA0040)        | 2               | ████████ 80%

Overall Coverage: ~65% of relevant techniques
```

---

## 🚀 Usage Examples

### Deploying Sigma Rules

#### Splunk
```bash
# Convert and deploy
sigma convert -t splunk sigma/*.yml > splunk_detections.spl
# Review and deploy to Splunk
```

#### Elasticsearch
```bash
sigma convert -t es-qs sigma/*.yml > kibana_detections.ndjson
# Import into Kibana Detection Engine
```

#### TheHive
```bash
sigma convert -t thehive sigma/*.yml > thehive_alerts.json
# Import to TheHive alert feeders
```

### Deploying SPL Queries

```bash
# Copy to Splunk saved searches
cp spl/*.spl /opt/splunk/etc/apps/SA-soc/local/savedsearches.conf.d/

# Restart Splunk
/opt/splunk/bin/splunk restart
```

### Deploying YARA Rules

```bash
# Scan with YARA
yara -r yara/*.yar /path/to/scan/

# Integrate with EDR/AV
# Follow your EDR vendor's YARA integration guide
```

---

## 🧪 Testing & Validation

All detection rules have been validated using:

1. **Atomic Red Team** — Automated TTP execution
2. **Purple Team Exercises** — Manual validation
3. **Production Simulation** — Real-world scenarios
4. **False Positive Analysis** — Tuning documented

### Test Results Summary
```
Detection Rate (Critical): 100%
Detection Rate (High): 95%+
False Positive Rate: <10%
Mean Time to Detect: 3.1 minutes (average)
```

---

## 📚 Related Documentation

- [Main Project README](../README.md)
- [MITRE ATT&CK Mapping](../attack-defense/mitre-mapping.md)
- [Attack Scenarios](../attack-defense/attack-scenarios.md)
- [Detection Validation](../attack-defense/detection-validation.md)
- [Saudi Market Targeting](../docs/saudi-market-targeting.md)

---

## 🤝 Contributing

Want to add detection rules? See [CONTRIBUTING.md](../CONTRIBUTING.md) for:
- Sigma rule standards
- SPL query best practices
- YARA rule guidelines
- Submission process

---

## 📜 License

MIT License — See [LICENSE](../LICENSE) for details.

---

*Maintained by: Maher Mansour Mahyoub Ghaleb*
*Last Updated: November 2025*
