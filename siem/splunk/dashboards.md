# Splunk Dashboards

## Overview

Pre-built Splunk dashboards for the Enterprise SOC Lab.

---

## Dashboard Import

### Method 1: Via Splunk Web

1. Go to **Dashboards** → **Create New Dashboard**
2. Click **Clone from Dashboard**
3. Import XML configuration

### Method 2: Via XML Import

Save dashboard XML to:
```
/opt/splunk/etc/apps/search/local/data/ui/views/
```

---

## Available Dashboards

### 1. SOC Overview

**Purpose**: High-level security metrics

**Panels**:
- Event volume trend
- Alert severity distribution
- Top source IPs
- Authentication success/failure ratio

**XML:**
```xml
<dashboard>
  <label>SOC Overview</label>
  <row>
    <panel>
      <title>Event Volume (Last 24h)</title>
      <chart>
        <search>
          <query>index=* earliest=-24h | timechart span=1h count</query>
        </search>
        <option name="charting.chart">line</option>
      </chart>
    </panel>
  </row>
</dashboard>
```

### 2. Windows Security

**Purpose**: Windows authentication monitoring

**Panels**:
- Failed logons by user
- Successful logons by source IP
- Privilege escalation events
- Service installations

### 3. Network Security

**Purpose**: IDS alert analysis

**Panels**:
- Suricata alerts by category
- Top attacked ports
- Geographic attack map
- Protocol distribution

---

## Creating Custom Dashboards

### Using Simple XML

```xml
<dashboard>
  <label>Custom Dashboard</label>
  <description>My custom security dashboard</description>
  
  <row>
    <panel>
      <title>Panel Title</title>
      <table>
        <search>
          <query>index=windows EventCode=4625 | stats count by AccountName</query>
          <earliest>-24h</earliest>
          <latest>now</latest>
        </search>
      </table>
    </panel>
  </row>
</dashboard>
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
