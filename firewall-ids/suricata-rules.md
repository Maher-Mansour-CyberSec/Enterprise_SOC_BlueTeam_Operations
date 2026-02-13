# Suricata Rules

## Overview

This document provides Suricata IDS/IPS rules for the Enterprise SOC Lab.

---

## Default Rules

Suricata uses Emerging Threats (ET) Open rules by default.

### Rule Categories

| Category | Description |
|----------|-------------|
| ET SCAN | Port scanning detection |
| ET ATTACK | Known attack signatures |
| ET MALWARE | Malware C2 detection |
| ET TROJAN | Trojan detection |
| ET WEB_SERVER | Web attack detection |
| ET POLICY | Policy violations |

---

## Custom Rules

### Port Scan Detection

```suricata
alert tcp any any -> $HOME_NET any (
    msg:"ET SCAN Potential Port Scan";
    flags:S;
    threshold:type both, track by_src, count 10, seconds 60;
    classtype:attempted-recon;
    sid:1000001;
    rev:1;
)
```

### SMB Brute Force

```suricata
alert tcp any any -> $HOME_NET 445 (
    msg:"ET SCAN SMB Brute Force Attempt";
    flow:to_server,established;
    detection_filter:track by_src, count 5, seconds 60;
    classtype:attempted-admin;
    sid:1000002;
    rev:1;
)
```

### RDP Brute Force

```suricata
alert tcp any any -> $HOME_NET 3389 (
    msg:"ET SCAN RDP Brute Force Attempt";
    flow:to_server,established;
    detection_filter:track by_src, count 5, seconds 60;
    classtype:attempted-admin;
    sid:1000003;
    rev:1;
)
```

### Mimikatz Detection

```suricata
alert tcp $HOME_NET any -> $HOME_NET [135,445] (
    msg:"ET ATTACK Possible Mimikatz Activity";
    flow:to_server,established;
    content:"|5c|pipe|5c|lsarpc";
    fast_pattern;
    classtype:credential-theft;
    sid:1000004;
    rev:1;
)
```

### C2 Communication

```suricata
drop tls $HOME_NET any -> any any (
    msg:"ET MALWARE Possible C2 Communication";
    tls.sni;
    content:".cloudfront.net";
    nocase;
    detection_filter:track by_src, count 4, seconds 60;
    classtype:trojan-activity;
    sid:1000005;
    rev:1;
)
```

---

## Rule Management

### Update Rules

```bash
# Via pfSense UI
Services → Suricata → Updates → Update Rules

# Via command line
suricata-update
```

### Enable/Disable Rules

1. Go to **Services** → **Suricata** → **Rules**
2. Select category
3. Toggle rules on/off
4. Save changes

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
