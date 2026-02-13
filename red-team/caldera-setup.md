# Caldera Setup

## Overview

Caldera is an adversary emulation platform for running automated attack scenarios.

---

## Installation

### Requirements

- Python 3.7+
- Node.js

### Install on Purple Kali

```bash
# Clone repository
git clone https://github.com/mitre/caldera.git
cd caldera

# Install dependencies
pip3 install -r requirements.txt

# Build UI
cd ui
npm install
npm run build
cd ..

# Start server
python3 server.py --insecure
```

---

## Configuration

### Default Credentials

- Username: `admin`
- Password: `admin`

**Change immediately!**

### Access Web UI

Open browser: `http://192.168.2.9:8888`

---

## Running Operations

### Create Adversary

1. Go to **Adversaries**
2. Click **Create Adversary**
3. Add abilities (ATT&CK techniques)
4. Save

### Deploy Agent

1. Go to **Agents**
2. Click **Deploy an Agent**
3. Select platform (Windows/Linux)
4. Copy and run command on target

### Run Operation

1. Go to **Operations**
2. Click **Create Operation**
3. Select adversary and agents
4. Click **Start**

---

## Integration with SIEM

Caldera operations generate logs that can be forwarded to SIEM for detection validation.

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
