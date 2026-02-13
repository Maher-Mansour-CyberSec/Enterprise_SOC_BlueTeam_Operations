# Escalation Matrix

## Overview

This document defines escalation procedures for security incidents.

---

## Severity Levels

| Level | Description | Examples |
|-------|-------------|----------|
| Critical | Confirmed compromise | Malware, data breach, ransomware |
| High | Likely malicious | Brute force, suspicious activity |
| Medium | Anomalous | Policy violation, unusual behavior |
| Low | Informational | Scanning, reconnaissance |

---

## Response Times

| Severity | Initial Response | Investigation | Escalation |
|----------|-----------------|---------------|------------|
| Critical | Immediate | 15 minutes | Immediate |
| High | 15 minutes | 30 minutes | 1 hour |
| Medium | 1 hour | 2 hours | End of shift |
| Low | 4 hours | Same day | Weekly review |

---

## Escalation Path

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ESCALATION PATH                                      │
└─────────────────────────────────────────────────────────────────────────────┘

  L1 Analyst
       │
       ├── Critical ──▶ L2 Analyst ──▶ SOC Manager ──▶ CISO
       │                    │
       ├── High ────────────┤
       │                    │
       ├── Medium ──────────┤
       │                    │
       └── Low ─────────────┘
```

---

## Contact Information

| Role | Contact | Availability |
|------|---------|--------------|
| SOC Manager | soc-manager@cyberlab.local | 24/7 |
| L2 Analyst | l2-team@cyberlab.local | Business hours |
| CISO | ciso@cyberlab.local | On-call |

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
