# MISP Setup Guide

## Overview

This guide provides step-by-step instructions for deploying MISP (Malware Information Sharing Platform) as the threat intelligence platform.

---

## Prerequisites

- Ubuntu Server 22.04 LTS
- Root or sudo access
- Static IP address: 192.168.2.9
- Minimum 4GB RAM, 2 CPU cores
- 50GB+ available storage

---

## Installation

### Step 1: Update System

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git gcc make openssl redis-server
```

### Step 2: Install Dependencies

```bash
sudo apt install -y apache2 mysql-server php php-mysql php-curl php-gd php-pear php-xml php-mbstring php-bcmath
```

### Step 3: Configure MySQL

```bash
sudo mysql_secure_installation

# Create MISP database
sudo mysql -u root -p
```

```sql
CREATE DATABASE misp;
CREATE USER 'misp'@'localhost' IDENTIFIED BY 'YourSecurePassword123!';
GRANT ALL PRIVILEGES ON misp.* TO 'misp'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 4: Install MISP

```bash
# Clone repository
cd /var/www
git clone https://github.com/MISP/MISP.git
cd MISP
git checkout v2.4.170

# Set permissions
sudo chown -R www-data:www-data /var/www/MISP
sudo chmod -R 750 /var/www/MISP

# Install Python dependencies
sudo -u www-data python3 -m pip install -r requirements.txt
```

### Step 5: Configure Apache

```bash
sudo nano /etc/apache2/sites-available/misp.conf
```

```apache
<VirtualHost *:80>
    ServerName misp.cyberlab.local
    DocumentRoot /var/www/MISP/app/webroot

    <Directory /var/www/MISP/app/webroot>
        Options -Indexes
        AllowOverride all
        Order allow,deny
        allow from all
    </Directory>

    LogLevel warn
    ErrorLog /var/log/apache2/misp_error.log
    CustomLog /var/log/apache2/misp_access.log combined
</VirtualHost>
```

```bash
sudo a2ensite misp.conf
sudo a2enmod rewrite ssl
sudo systemctl restart apache2
```

### Step 6: Configure MISP

```bash
cd /var/www/MISP/app/Config
cp -a config.default.php config.php
cp -a database.default.php database.php
cp -a core.default.php core.php
```

Edit `database.php`:
```php
class DATABASE_CONFIG {
    public $default = array(
        'datasource' => 'Database/Mysql',
        'persistent' => false,
        'host' => 'localhost',
        'login' => 'misp',
        'password' => 'YourSecurePassword123!',
        'database' => 'misp',
        'prefix' => '',
        'encoding' => 'utf8',
    );
}
```

### Step 7: Initialize Database

```bash
cd /var/www/MISP
sudo -u www-data app/Console/cake Admin runUpdates
```

---

## Access MISP

Open browser: `http://192.168.2.9`

Default credentials:
- Username: `admin@admin.test`
- Password: `admin`

**Change password immediately!**

---

## Configuration

### Enable API Access

1. Go to **Administration** → **List Users**
2. Click on admin user
3. Generate API key
4. Copy and save the key

### Configure Feeds

1. Go to **Sync Actions** → **List Feeds**
2. Enable desired feeds:
   - CIRCL OSINT Feed
   - Abuse.ch Malware Bazaar
   - Abuse.ch URLhaus
   - AlienVault OTX

### Set Base URL

```bash
sudo -u www-data /var/www/MISP/app/Console/cake Baseurl http://192.168.2.9
```

---

## API Usage

### Get Events

```bash
curl -H "Authorization: YOUR_API_KEY" \
  -H "Accept: application/json" \
  http://192.168.2.9/events/index
```

### Search IOCs

```bash
curl -H "Authorization: YOUR_API_KEY" \
  -H "Accept: application/json" \
  -X POST \
  http://192.168.2.9/attributes/restSearch/json \
  -d '{"value":"192.168.1.1"}'
```

---

## Troubleshooting

### Check Logs

```bash
sudo tail -f /var/log/apache2/misp_error.log
sudo tail -f /var/www/MISP/app/tmp/logs/error.log
```

### Fix Permissions

```bash
sudo chown -R www-data:www-data /var/www/MISP
sudo chmod -R 750 /var/www/MISP
sudo chmod -R 777 /var/www/MISP/app/tmp
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
