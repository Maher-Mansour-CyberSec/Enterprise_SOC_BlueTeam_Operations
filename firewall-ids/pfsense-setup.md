# pfSense Setup Guide

## Overview

This guide provides step-by-step instructions for deploying pfSense as the network gateway and firewall.

---

## Prerequisites

- VMware Workstation Pro or ESXi
- pfSense CE 2.7.x ISO
- 2GB RAM, 2 CPU cores
- 20GB disk space
- 3 network interfaces

---

## Installation

### Step 1: Create VM

- Type: Other (FreeBSD)
- RAM: 2GB
- CPU: 2 cores
- Disk: 20GB
- Network: 3 adapters (VMnet0, VMnet2, VMnet4)

### Step 2: Install pfSense

1. Boot from ISO
2. Select **Install**
3. Choose **Auto (UFS)**
4. Complete installation
5. Reboot

### Step 3: Initial Configuration

```
WAN (vtnet0): DHCP or 192.168.1.251/24
LAN (vtnet1): 192.168.2.1/24
OPT1 (vtnet2): 192.168.4.1/24
```

---

## Web Configuration

### Access Web UI

1. Browser: `http://192.168.2.1`
2. Default credentials:
   - Username: `admin`
   - Password: `pfsense`

### Setup Wizard

1. Click **Next** through wizard
2. Set hostname: `pfSense`
3. Set domain: `cyberlab.local`
4. Configure DNS: `192.168.2.2`
5. Set timezone
6. Complete wizard

---

## Firewall Rules

### LAN Rules

| Action | Protocol | Source | Destination | Port | Description |
|--------|----------|--------|-------------|------|-------------|
| Pass | TCP/UDP | LAN net | * | 53 | DNS |
| Pass | TCP | LAN net | * | 80,443 | HTTP/HTTPS |
| Pass | TCP/UDP | LAN net | PurpleKali | 5044,9997 | SIEM |
| Block | * | DMZ net | LAN net | * | Block DMZ to LAN |

### DMZ Rules

| Action | Protocol | Source | Destination | Port | Description |
|--------|----------|--------|-------------|------|-------------|
| Pass | TCP/UDP | DMZ net | * | 53 | DNS |
| Pass | TCP | DMZ net | * | 80,443 | HTTP/HTTPS |
| Block | * | DMZ net | LAN net | * | Block to LAN |
| Block | * | DMZ net | CORP net | * | Block to CORP |

---

## Suricata Installation

### Install Package

1. Go to **System** → **Package Manager**
2. Click **Available Packages**
3. Find **Suricata**
4. Click **Install**

### Configure Suricata

1. Go to **Services** → **Suricata**
2. Add interface: LAN
3. Enable: **Inline IPS Mode**
4. Download rules: **ET Open**
5. Save and start

---

## VPN Configuration

### OpenVPN Server

1. Go to **VPN** → **OpenVPN** → **Wizards**
2. Select **Local User Access**
3. Configure:
   - Interface: WAN
   - Protocol: UDP
   - Port: 1194
   - Tunnel Network: 10.8.0.0/24
   - Local Network: 192.168.2.0/24,192.168.4.0/24
4. Complete wizard

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
