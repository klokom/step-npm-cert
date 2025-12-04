# **step-npm-cert**

**Bash certificate automation utility for Smallstep step-ca and Nginx Proxy Manager.**
Provides CSR/key regeneration, SAN building with range expansion, renewal orchestration, bulk wildcard issuance, config-driven behavior, and systemd-aware NPM reload.

---

## 🚀 Features

* Issue new certificates with SANs
* Renew one or all certificates automatically
* Wildcard certificate support
* Bulk wildcard issuing from file
* DNS/IP SAN range expansion (`pve[1-5].lab`, `192.168.0.80-90`)
* Config file overrides (`/etc/step-npm-cert.conf`)
* Quiet mode + color control
* Automatic Nginx Proxy Manager (`npm.service`) reload
* Safe locking to prevent concurrent execution

---

## 📦 Requirements

* **Smallstep CLI (`step`)**
* **step-ca** running as your Certificate Authority
* **openssl**
* systemd (optional, for NPM reload)

---

## ⚙ Configuration

Configuration is optional and stored in:

```
/etc/step-npm-cert.conf
```

Example config (all values commented out):

```bash
#RENEW_DAYS=45
#AUTO_RELOAD_NPM=1
#COLOR=auto
#QUIET=false

#CA_URL="https://ca.lab:9000"
#PROV_PW_FILE="/root/.step/secrets/password"
#CERTDIR="/data/nginx/certificates"
#NPM_SERVICE="npm.service"
#LOCKFILE="/tmp/step-npm-cert.lock"
#NOT_AFTER="8760h"
```

Precedence:

1. CLI arguments
2. `/etc/step-npm-cert.conf`
3. Internal defaults

---

## 🔧 Usage

### Issue a certificate

```
step-npm-cert --domain example.lab
```

### Issue with SANs

```
step-npm-cert -d example.lab \
  --san '*.example.lab' \
  --san 192.168.0.10
```

### Renew a single certificate

```
step-npm-cert --renew example.lab
```

### Renew all certificates expiring soon (default ≤ 30 days)

```
step-npm-cert --renew-all
```

### Change renewal threshold

```
step-npm-cert --renew-all --renew-days 10
```

### Bulk wildcard issuing

```
step-npm-cert --bulk-wildcards domains.txt
```

`domains.txt` example:

```
apps.lab
k3s.lab
internal.lab
```

---

## 🌐 SAN Range Expansion

Supported formats:

* `pve[1-5].lab` → `pve1.lab`, `pve2.lab`, …
* `192.168.0.80-90` → multiple IP SANs

---

## 🔄 Automatic NPM Reload

Enable via config:

```
AUTO_RELOAD_NPM=1
```

Or via CLI:

```
step-npm-cert --reload-npm ...
```

---

## 🔒 Locking

A lockfile prevents parallel execution:

```
/tmp/step-npm-cert.lock
```

---

## 📜 License

GPL-3.0 license.
