#!/usr/bin/env bash
set -euo pipefail

REPO="klokom/step-npm-cert"
RAW_URL="https://raw.githubusercontent.com/$REPO/main"
SCRIPT_NAME="step-npm-cert"
INSTALL_PATH="/usr/local/bin/$SCRIPT_NAME"
CONFIG_PATH="/etc/step-npm-cert.conf"

echo "== step-npm-cert Installer =="
echo

# Detect run mode
if [[ -f "./$SCRIPT_NAME" ]]; then
    SOURCE_SCRIPT="./$SCRIPT_NAME"
    echo "[*] Using local script: $SOURCE_SCRIPT"
else
    SOURCE_SCRIPT="$(mktemp)" || exit 1
    trap 'rm -f "$SOURCE_SCRIPT"' EXIT INT TERM
    echo "[*] Downloading $SCRIPT_NAME from GitHub..."
    curl -fsSL "$RAW_URL/$SCRIPT_NAME" -o "$SOURCE_SCRIPT"
fi

[[ -s "$SOURCE_SCRIPT" ]] || { echo "ERROR: Script is empty or missing"; exit 1; }

echo "[*] Installing to $INSTALL_PATH ..."
sudo cp "$SOURCE_SCRIPT" "$INSTALL_PATH"
sudo chmod 755 "$INSTALL_PATH"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "[*] Creating default config at $CONFIG_PATH ..."
    sudo tee "$CONFIG_PATH" > /dev/null << 'EOF'
# step-npm-cert configuration (all optional)
#RENEW_DAYS=30
#AUTO_RELOAD_NPM=0
#NOT_AFTER="8760h"
#CA_URL="https://ca.lab:9000"
#PROV_PW_FILE="/root/.step/secrets/password"
#CERTDIR="/data/nginx/certificates"
#NPM_SERVICE="npm.service"
#LOCKFILE="/tmp/step-npm-cert.lock"
EOF
    sudo chmod 644 "$CONFIG_PATH"
else
    echo "[*] Config already exists → $CONFIG_PATH"
fi

echo
echo "[+] Installation complete!"
echo "    Binary: $INSTALL_PATH"
echo "    Config: $CONFIG_PATH"
echo
echo "Run: $SCRIPT_NAME --help"
