# Network Reference

## Table of Contents

1. [Network Overview](#network-overview)
2. [IP Addressing Scheme](#ip-addressing-scheme)
3. [VLAN Configuration](#vlan-configuration)
4. [Firewall Rules](#firewall-rules)
5. [DNS Configuration](#dns-configuration)
6. [DHCP Configuration](#dhcp-configuration)
7. [VPN Configuration](#vpn-configuration)

---

## Network Overview

### Network Topology Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              NETWORK TOPOLOGY                                │
└─────────────────────────────────────────────────────────────────────────────┘

                                    INTERNET
                                       │
                                       ▼
                              ┌─────────────────┐
                              │  ISP Router     │
                              │  192.168.1.1    │
                              └────────┬────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PFSENSE FIREWALL                                   │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐             │
│  │     WAN      │     LAN      │    OPT1      │    OPT2      │             │
│  │ 192.168.1.251│ 192.168.2.1  │ 192.168.4.1  │  (unused)    │             │
│  │   /24        │   /24        │   /24        │              │             │
│  └──────────────┴──────────────┴──────────────┴──────────────┘             │
└─────────────────────────────────────────────────────────────────────────────┘
         │                  │                  │
         │                  │                  │
         ▼                  ▼                  ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   VMNET0        │  │   VMNET2        │  │   VMNET4        │
│  (Bridged)      │  │  (Host-Only)    │  │  (Host-Only)    │
│                 │  │                 │  │                 │
│  External       │  │  Corporate      │  │  DMZ            │
│  Access         │  │  Network        │  │  Network        │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## IP Addressing Scheme

### Corporate Network (192.168.2.0/24)

| IP Address | Hostname | Role | OS |
|------------|----------|------|-----|
| 192.168.2.1 | pfSense-LAN | Gateway | pfSense |
| 192.168.2.2 | DC01 | Domain Controller | Windows Server 2019 |
| 192.168.2.9 | PurpleKali | SIEM/Monitoring | Kali Linux |
| 192.168.2.50 | RedKali | Attack Platform | Kali Linux |
| 192.168.2.101 | Client01 | Workstation | Windows 10 |
| 192.168.2.102 | Client02 | Workstation (Optional) | Windows 10 |
| 192.168.2.201-254 | DHCP Pool | Dynamic Assignment | Various |

### DMZ Network (192.168.4.0/24)

| IP Address | Hostname | Role | OS |
|------------|----------|------|-----|
| 192.168.4.1 | pfSense-OPT1 | Gateway | pfSense |
| 192.168.4.10 | DVWA | Vulnerable Web App | Linux |
| 192.168.4.20 | WebSRV | Baseline Server | Linux |
| 192.168.4.201-254 | DHCP Pool | Dynamic Assignment | Various |

### WAN Network (192.168.1.0/24)

| IP Address | Hostname | Role | Notes |
|------------|----------|------|-------|
| 192.168.1.1 | ISP-Router | Gateway | External router |
| 192.168.1.251 | pfSense-WAN | Firewall WAN | DHCP or Static |

---

## VLAN Configuration

### VMware Virtual Network Editor

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VMWARE VIRTUAL NETWORK CONFIGURATION                      │
└─────────────────────────────────────────────────────────────────────────────┘

VMnet0 (Bridged)
├── Type: Bridged
├── Bridged to: Physical NIC (Wi-Fi or Ethernet)
├── DHCP: Disabled (handled by external router)
└── Purpose: WAN/Internet access

VMnet2 (Host-Only)
├── Type: Host-only
├── Subnet: 192.168.2.0/24
├── DHCP: Enabled (192.168.2.201-254)
├── NAT: Disabled
└── Purpose: Corporate network

VMnet4 (Host-Only)
├── Type: Host-only
├── Subnet: 192.168.4.0/24
├── DHCP: Enabled (192.168.4.201-254)
├── NAT: Disabled
└── Purpose: DMZ network
```

### VLAN Assignment

| VLAN ID | Name | Subnet | Purpose |
|---------|------|--------|---------|
| 10 | CORPORATE | 192.168.2.0/24 | Internal workstations |
| 20 | SOC | 192.168.2.0/24 | Security operations |
| 40 | DMZ | 192.168.4.0/24 | Public-facing services |

---

## Firewall Rules

### pfSense Rule Configuration

#### WAN Interface Rules

| Rule # | Action | Protocol | Source | Destination | Port | Description |
|--------|--------|----------|--------|-------------|------|-------------|
| 100 | Block | IPv4* | RFC1918 networks | * | * | Block private networks |
| 200 | Block | IPv4* | Bogons | * | * | Block bogon networks |
| 300 | Pass | TCP | * | WAN address | 443 | Allow HTTPS admin access |
| 400 | Pass | TCP | * | WAN address | 1194 | Allow OpenVPN (optional) |
| 999 | Block | IPv4* | * | * | * | Default deny |

#### LAN Interface Rules

| Rule # | Action | Protocol | Source | Destination | Port | Description |
|--------|--------|----------|--------|-------------|------|-------------|
| 100 | Pass | TCP/UDP | LAN net | * | 53 | Allow DNS queries |
| 110 | Pass | TCP | LAN net | * | 80,443 | Allow HTTP/HTTPS |
| 120 | Pass | TCP/UDP | LAN net | PurpleKali | 5044,8089,9997 | Allow SIEM ingestion |
| 130 | Pass | TCP/UDP | LAN net | PurpleKali | 443 | Allow MISP access |
| 140 | Pass | TCP | LAN net | DMZ net | 80,443 | Allow DMZ web access |
| 150 | Block | IPv4* | DMZ net | LAN net | * | Block DMZ to LAN |
| 999 | Block | IPv4* | * | * | * | Default deny |

#### OPT1 (DMZ) Interface Rules

| Rule # | Action | Protocol | Source | Destination | Port | Description |
|--------|--------|----------|--------|-------------|------|-------------|
| 100 | Pass | TCP/UDP | DMZ net | * | 53 | Allow DNS queries |
| 110 | Pass | TCP | DMZ net | * | 80,443 | Allow HTTP/HTTPS outbound |
| 120 | Pass | TCP/UDP | DMZ net | PurpleKali | 514,5044 | Allow log forwarding |
| 130 | Block | IPv4* | DMZ net | LAN net | * | Block DMZ to LAN |
| 140 | Block | IPv4* | DMZ net | CORP net | * | Block DMZ to Corporate |
| 999 | Block | IPv4* | * | * | * | Default deny |

### Suricata Rules

```suricata
# Custom rules for lab environment

# Detect port scanning
alert tcp any any -> $HOME_NET any (msg:"ET SCAN Potential Port Scan"; flags:S; threshold:type both, track by_src, count 10, seconds 60; sid:1000001; rev:1;)

# Detect SMB brute force
alert tcp any any -> $HOME_NET 445 (msg:"ET SCAN SMB Brute Force Attempt"; flow:to_server,established; detection_filter:track by_src, count 5, seconds 60; sid:1000002; rev:1;)

# Detect RDP brute force
alert tcp any any -> $HOME_NET 3389 (msg:"ET SCAN RDP Brute Force Attempt"; flow:to_server,established; detection_filter:track by_src, count 5, seconds 60; sid:1000003; rev:1;)

# Detect PowerShell Empire C2
drop tls $HOME_NET any -> any any (msg:"ET MALWARE Possible Empire C2"; tls.sni; content:".cloudfront.net"; nocase; detection_filter:track by_src, count 4, seconds 60; sid:1000004; rev:1;)

# Detect Mimikatz usage
alert tcp $HOME_NET any -> $HOME_NET [135,445] (msg:"ET ATTACK Possible Mimikatz Activity"; flow:to_server,established; content:"|5c|pipe|5c|lsarpc"; fast_pattern; sid:1000005; rev:1;)
```

---

## DNS Configuration

### Active Directory DNS

#### Forward Lookup Zones

| Zone | Type | Purpose |
|------|------|---------|
| cyberlab.local | Primary AD | Domain zone |
| 2.168.192.in-addr.arpa | Reverse | Corporate reverse |
| 4.168.192.in-addr.arpa | Reverse | DMZ reverse |

#### DNS Records

| Name | Type | IP Address | Purpose |
|------|------|------------|---------|
| dc01 | A | 192.168.2.2 | Domain Controller |
| purplekali | A | 192.168.2.9 | SIEM Server |
| redkali | A | 192.168.2.50 | Attack Platform |
| client01 | A | 192.168.2.101 | Workstation |
| dvwa | A | 192.168.4.10 | Vulnerable Web App |
| websrv | A | 192.168.4.20 | Baseline Server |
| siem | CNAME | purplekali | SIEM alias |
| misp | CNAME | purplekali | MISP alias |

### pfSense DNS Resolver

```
General Settings:
├── Enable DNS Resolver: Yes
├── Listen Port: 53
├── Network Interfaces: All
├── Outgoing Network Interfaces: WAN
├── DNSSEC: Enabled
├── DNS Query Forwarding: Disabled
└── DHCP Registration: Enabled

Host Overrides:
├── Host: dvwa
│   ├── Domain: cyberlab.local
│   ├── IP: 192.168.4.10
│   └── Description: DVWA Web App
├── Host: websrv
│   ├── Domain: cyberlab.local
│   ├── IP: 192.168.4.20
│   └── Description: Baseline Web Server
└── Host: misp
    ├── Domain: cyberlab.local
    ├── IP: 192.168.2.9
    └── Description: MISP Platform
```

---

## DHCP Configuration

### pfSense DHCP Server

#### LAN DHCP (Corporate Network)

| Setting | Value |
|---------|-------|
| Enable | Yes |
| Range | 192.168.2.201 - 192.168.2.254 |
| Subnet Mask | 255.255.255.0 |
| Gateway | 192.168.2.1 |
| DNS Servers | 192.168.2.2, 192.168.2.1 |
| Domain | cyberlab.local |
| Lease Time | 86400 seconds (1 day) |

#### OPT1 DHCP (DMZ Network)

| Setting | Value |
|---------|-------|
| Enable | Yes |
| Range | 192.168.4.201 - 192.168.4.254 |
| Subnet Mask | 255.255.255.0 |
| Gateway | 192.168.4.1 |
| DNS Servers | 192.168.2.2, 192.168.4.1 |
| Domain | cyberlab.local |
| Lease Time | 86400 seconds (1 day) |

### Static DHCP Mappings

| MAC Address | IP Address | Hostname | Description |
|-------------|------------|----------|-------------|
| 00:50:56:01:02:02 | 192.168.2.2 | dc01 | Domain Controller |
| 00:50:56:01:02:09 | 192.168.2.9 | purplekali | SIEM Server |
| 00:50:56:01:02:50 | 192.168.2.50 | redkali | Attack Platform |
| 00:50:56:01:02:65 | 192.168.2.101 | client01 | Workstation |
| 00:50:56:01:04:10 | 192.168.4.10 | dvwa | DVWA Server |
| 00:50:56:01:04:20 | 192.168.4.20 | websrv | Web Server |

---

## VPN Configuration

### OpenVPN Server (Optional)

```
General Information:
├── Mode: Remote Access (SSL/TLS + User Auth)
├── Protocol: UDP
├── Device Mode: tun
├── Interface: WAN
├── Local Port: 1194
├── Description: SOC Lab VPN

Cryptographic Settings:
├── TLS Configuration: Use a TLS Key
├── TLS Key Usage Mode: TLS Authentication
├── Peer Certificate Authority: cyberlab-ca
├── Server Certificate: vpn-server-cert
├── DH Parameters Length: 2048 bit
├── ECDH Curve: secp256r1
├── Data Encryption Algorithms: AES-256-GCM, AES-128-GCM
├── Fallback Data Encryption Algorithm: AES-256-CBC
├── Auth Digest Algorithm: SHA256
└── Hardware Crypto: No Hardware Crypto Acceleration

Tunnel Settings:
├── IPv4 Tunnel Network: 10.8.0.0/24
├── IPv4 Local Network/s: 192.168.2.0/24, 192.168.4.0/24
├── Concurrent Connections: 10
├── Compression: LZ4 Compression
├── Type-of-Service: Disabled
└── Inter-client Communication: Enabled

Client Settings:
├── Dynamic IP: Enabled
├── Address Pool: Enabled
├── Topology: Subnet
├── DNS Default Domain: Enabled
│   └── Default Domain: cyberlab.local
├── DNS Server Enable: Enabled
│   └── DNS Servers: 192.168.2.2
└── NTP Server Enable: Disabled
```

### VPN Client Export

| Package | Platform | File |
|---------|----------|------|
| Windows Installer | Windows 10/11 | openvpn-install.exe |
| Android | Android | cyberlab-android.ovpn |
| iOS | iPhone/iPad | cyberlab-ios.ovpn |
| Archive | Generic | cyberlab-configs.zip |

---

*Document Version: 2.0*  
*Last Updated: 2026-02-12*  
*Author: Enterprise Security Architecture Team*
