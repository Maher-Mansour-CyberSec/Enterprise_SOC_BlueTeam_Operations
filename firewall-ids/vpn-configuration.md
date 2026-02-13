# VPN Configuration

## Overview

This document provides VPN configuration for secure remote access to the SOC Lab.

---

## OpenVPN Server

### pfSense Configuration

1. Go to **VPN** → **OpenVPN** → **Wizards**
2. Select **Local User Access**
3. Configure:

| Setting | Value |
|---------|-------|
| Interface | WAN |
| Protocol | UDP |
| Port | 1194 |
| Description | SOC Lab VPN |
| Tunnel Network | 10.8.0.0/24 |
| Local Network | 192.168.2.0/24,192.168.4.0/24 |
| Concurrent Connections | 10 |
| DNS Server | 192.168.2.2 |

### Client Export

1. Go to **VPN** → **OpenVPN** → **Client Export**
2. Select configuration:
   - Most Clients: Inline Configurations
   - Windows: Windows Installer
   - Mobile: Android/iOS

---

## Client Configuration

### Windows Client

1. Download OpenVPN client from: https://openvpn.net/community-downloads/
2. Install and run
3. Import configuration file
4. Connect

### Linux Client

```bash
# Install OpenVPN
sudo apt install openvpn

# Copy config
sudo cp client.ovpn /etc/openvpn/client.conf

# Start
sudo systemctl start openvpn@client
```

---

## Troubleshooting

### Connection Issues

```bash
# Check OpenVPN logs
sudo tail -f /var/log/openvpn.log

# Verify firewall rules
sudo pfctl -sr | grep 1194
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
