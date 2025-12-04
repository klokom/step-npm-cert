#!/usr/bin/env bash
set -euo pipefail

REPO="klokom/step-npm-cert"
RAW_URL="https://raw.githubusercontent.com/$REPO/main"

SCRIPT_MAIN="step-npm-cert"
SCRIPT_IMPORTER="step-npm-cert-importer"

INSTALL_MAIN="/usr/local/bin/$SCRIPT_MAIN"
INSTALL_IMPORTER="/usr/local/bin/$SCRIPT_IMPORTER"

CONFIG_PATH="/etc/step-npm-cert.conf"

echo "== step-npm-cert Suite Installer =="

# ---------------------- Dependency Checks ----------------------
command -v step >/dev/null    || { echo "ERROR: 'step' CLI is required"; exit 1; }
command -v openssl >/dev/null || { echo "ERROR: 'openssl' is required"; exit 1; }
command -v jq >/dev/null      || { echo "ERROR: 'jq' is required (apt install jq)"; exit 1; }

# ---------------------- Global Cleanup Trap --------------------
TMPFILES=()
cleanup() {
    for f in "${TMPFILES[@]}"; do
        rm -f "$f" 2>/dev/null || true
    done
}
trap cleanup EXIT INT TERM

# ---------------------- Fetch or Use Local ---------------------
download_or_use_local() {
    local name="$1"
    if [[ -f "./$name" ]]; then
        echo "[*] Using local $name"
        echo "./$name"
    else
        echo "[*] Downloading $name..."
        local tmp
        tmp="$(mktemp)" || exit 1
        TMPFILES+=("$tmp")
        curl -fsSL "$RAW_URL/$name" -o "$tmp" || { echo "ERROR: Failed to download $name"; exit 1; }
        echo "$tmp"
    fi
}

SRC_MAIN="$(download_or_use_local "$SCRIPT_MAIN")"
SRC_IMPORTER="$(download_or_use_local "$SCRIPT_IMPORTER")"

# ---------------------- Install Scripts ------------------------
echo "[*] Installing $SCRIPT_MAIN → $INSTALL_MAIN"
sudo cp "$SRC_MAIN" "$INSTALL_MAIN"
sudo chmod 755 "$INSTALL_MAIN"

echo "[*] Installing $SCRIPT_IMPORTER → $INSTALL_IMPORTER"
sudo cp "$SRC_IMPORTER" "$INSTALL_IMPORTER"
sudo chmod 755 "$INSTALL_IMPORTER"

# ---------------------- Config File ----------------------------
if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "[*] Creating config → $CONFIG_PATH"
    sudo tee "$CONFIG_PATH" >/dev/null << 'EOF'
# step-npm-cert configuration
#RENEW_DAYS=30
#AUTO_RELOAD_NPM=0
#NOT_AFTER="8760h"
#CA_URL="https://ca.lab:9000"
#PROV_PW_FILE="/root/.step/secrets/password"
#CERTDIR="/data/nginx/certificates"
#NPM_SERVICE="npm.service"
#NPM_API_URL="http://127.0.0.1:81/api"
#NPM_USER="admin@example.com"
#NPM_PASSWORD="changeme"
#COLOR="auto"
#QUIET="false"
EOF
    sudo chmod 644 "$CONFIG_PATH"
else
    echo "[*] Config already exists → $CONFIG_PATH"
fi

# ---------------------- Finish ----------------------------
echo
echo "[+] Installation complete!"
echo "    $INSTALL_MAIN"
echo "    $INSTALL_IMPORTER"
echo "    Config: $CONFIG_PATH"
echo
echo "Run:"
echo "    $SCRIPT_MAIN --help"
echo "    $SCRIPT_IMPORTER --help"
