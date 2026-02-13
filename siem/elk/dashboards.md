# Kibana Dashboards

## Overview

This document provides pre-built Kibana dashboards for the Enterprise SOC Lab.

---

## Dashboard Import

### Method 1: Import via Kibana UI

1. Go to **Stack Management** → **Saved Objects**
2. Click **Import**
3. Select the dashboard NDJSON file
4. Click **Import**

### Method 2: Import via API

```bash
curl -X POST "https://192.168.2.9:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  -u elastic:password \
  --form file=@dashboards.ndjson
```

---

## Available Dashboards

### 1. SOC Overview Dashboard

**Purpose**: High-level view of security posture

**Visualizations**:
- Event volume over time
- Alert count by severity
- Top source IPs
- Top targeted users
- MITRE ATT&CK technique coverage

**Export:**
```json
{
  "attributes": {
    "title": "SOC Overview",
    "hits": 0,
    "description": "High-level security posture overview",
    "panelsJSON": "[...]",
    "optionsJSON": "{\"useMargins\":true,\"syncColors\":false,\"hidePanelTitles\":false}",
    "version": 1,
    "timeRestore": false,
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"query\":{\"language\":\"kuery\",\"query\":\"\"},\"filter\":[]}}"
    }
  }
}
```

### 2. Windows Security Dashboard

**Purpose**: Windows authentication and process monitoring

**Visualizations**:
- Failed vs successful logons
- Logon types distribution
- Process execution timeline
- Suspicious command lines
- Privilege escalation attempts

### 3. Network Security Dashboard

**Purpose**: Network traffic and IDS alert analysis

**Visualizations**:
- Suricata alerts by category
- Top destination ports
- Geographic distribution of traffic
- Protocol distribution
- Blocked connections

### 4. Endpoint Monitoring Dashboard

**Purpose**: Sysmon event analysis

**Visualizations**:
- Process creation events
- Network connections by process
- DNS query patterns
- File creation activity
- Registry modifications

---

## Creating Custom Dashboards

### Step 1: Create Index Pattern

1. Go to **Stack Management** → **Index Patterns**
2. Click **Create index pattern**
3. Enter pattern: `sysmon-*`
4. Select `@timestamp` as time field
5. Click **Create index pattern**

### Step 2: Create Visualization

1. Go to **Visualize Library**
2. Click **Create visualization**
3. Select visualization type (Lens recommended)
4. Configure data source and aggregations
5. Save visualization

### Step 3: Add to Dashboard

1. Go to **Dashboard**
2. Click **Create dashboard**
3. Click **Add from library**
4. Select visualizations to add
5. Arrange and resize panels
6. Save dashboard

---

## Sample Visualizations

### Brute Force Detection Chart

```json
{
  "type": "lens",
  "attributes": {
    "title": "Failed Logon Attempts",
    "visualizationType": "lnsXY",
    "state": {
      "datasourceStates": {
        "indexpattern": {
          "layers": {
            "layer1": {
              "columnOrder": ["x", "y"],
              "columns": {
                "x": {
                  "dataType": "date",
                  "isBucketed": true,
                  "label": "@timestamp",
                  "operationType": "date_histogram",
                  "sourceField": "@timestamp"
                },
                "y": {
                  "dataType": "number",
                  "isBucketed": false,
                  "label": "Count",
                  "operationType": "count"
                }
              }
            }
          }
        }
      },
      "filters": [
        {
          "query": {
            "match": {
              "event.code": "4625"
            }
          }
        }
      ]
    }
  }
}
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
