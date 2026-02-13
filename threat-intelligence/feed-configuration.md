# MISP Feed Configuration

## Overview

This document provides configuration for threat intelligence feeds in MISP.

---

## Default Feeds

| Feed Name | URL | Type | Update Frequency |
|-----------|-----|------|-----------------|
| CIRCL OSINT | https://www.circl.lu/doc/misp/feed-osint | MISP Feed | Daily |
| Abuse.ch Malware Bazaar | https://bazaar.abuse.ch/downloads/misp/ | MISP Feed | Hourly |
| Abuse.ch URLhaus | https://urlhaus.abuse.ch/downloads/misp/ | MISP Feed | Hourly |
| AlienVault OTX | API Key Required | OTX Feed | Daily |

---

## Enabling Feeds

### Via MISP Web UI

1. Go to **Sync Actions** → **List Feeds**
2. Click **Load default feed metadata**
3. Enable desired feeds by clicking **Enable**
4. Click **Fetch and store all feed data**

### Via Command Line

```bash
# Fetch all feeds
sudo -u www-data /var/www/MISP/app/Console/cake Server fetchFeed 1

# Fetch specific feed
sudo -u www-data /var/www/MISP/app/Console/cake Server fetchFeed [feed_id]
```

---

## Custom Feed Configuration

### Adding Custom Feed

1. Go to **Sync Actions** → **List Feeds**
2. Click **Add Feed**
3. Configure:
   - Name: Custom Feed Name
   - URL: Feed URL
   - Source Format: MISP Feed or CSV
   - Enabled: Check
   - Distribution: Your Organization Only

---

## Feed Caching

### Enable Feed Caching

```bash
# Add to crontab
sudo crontab -e
```

```
# Fetch feeds every hour
0 * * * * sudo -u www-data /var/www/MISP/app/Console/cake Server fetchFeed 1
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
