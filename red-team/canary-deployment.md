# Red Team Canary Deployment

## Overview

This document describes the deployment of deception tokens (canaries) for early breach detection.

---

## What are Canary Tokens

Canary tokens are digital tripwires that alert you when an attacker accesses them. They appear as:
- AWS API keys
- Slack webhooks
- Database connection strings
- PDF documents
- Windows folders

---

## Deployment

### Step 1: Generate Tokens

Visit: https://canarytokens.org/

Generate tokens for:
- AWS API Key
- Slack Webhook
- Database Connection String
- PDF Document
- Windows Folder

### Step 2: Deploy Tokens

#### AWS API Key Token

```bash
# Create fake AWS credentials file
cat > /home/user/.aws/credentials << 'EOF'
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF

# Set permissions
chmod 600 /home/user/.aws/credentials
```

#### Windows Folder Token

1. Generate token on canarytokens.org
2. Create folder with unique name
3. Place token file in folder
4. Monitor for access alerts

### Step 3: Monitor Alerts

When a canary is triggered:
1. Email alert sent
2. Webhook notification (optional)
3. Log entry created

---

## Integration with SIEM

### Forward Alerts to Splunk

Configure canarytokens.org to send webhooks to Splunk HEC.

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
