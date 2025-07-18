#!/bin/bash

# === Initial Prompt and Consent ===
echo "========================================"
echo "DISCLAIMER: This script performs a CIS Benchmark audit of NGINX."
echo "Ensure you have sufficient privileges and consent to proceed."
echo "========================================"
read -p "Do you consent to run this script? (yes/no): " consent
if [ "$consent" != "yes" ]; then
    echo "Aborting script."
    exit 1
fi

# Banner
echo "========================================"
echo "CIS Benchmark for Nginx Configuration Audit"
echo "========================================"

# === Variables ===
OUTPUT_HTML="nginx_cis_audit_report.html"
NGINX_DIR="/etc/nginx"
NGINX_CONF="/etc/nginx/nginx.conf"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
CONFIG_FILES=$(find $NGINX_DIR -type f -name '*.conf')

# === HTML Report Initialization ===
cat > "$OUTPUT_HTML" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CIS Benchmark NGINX Audit - $DATE</title>
    <style>
        body { font-family: Arial; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 8px; }
        th { background: #f4f4f4; }
        .pass { background-color: #c8e6c9; }
        .fail { background-color: #ffcdd2; }
    </style>
</head>
<body>
    <h1>CIS Benchmark Audit - NGINX</h1>
    <p>Generated on: $DATE</p>
    <table>
        <tr>
            <th>ID</th><th>Description</th><th>Risk</th><th>Fix Type</th><th>Status</th><th>Remediation</th>
        </tr>
EOF

add_finding() {
    echo "    <tr class=\"$5\"><td>$1</td><td>$2</td><td>$3</td><td>$4</td><td>$5</td><td>$6</td></tr>" >> "$OUTPUT_HTML"
}

# === Utility Functions ===
verlte() { [ "$1" = "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" ]; }
check_directive() {
    local pattern="$1"
    grep -Eir "^\s*$pattern" $CONFIG_FILES | grep -vE '^\s*#' > /dev/null
}
check_directive_value() {
    local key="$1"
    local value="$2"
    grep -Eir "^\s*$key\s+$value;" $CONFIG_FILES | grep -vE '^\s*#' > /dev/null
}

# === 1.0.1: Version Check ===
REQUIRED_VERSION="1.14.0"
INSTALLED_VERSION=$(nginx -v 2>&1 | sed -n 's/^.*\///p')
desc="Ensure NGINX version is $REQUIRED_VERSION or newer"
risk="High"
fix="Involved"
if verlte "$REQUIRED_VERSION" "$INSTALLED_VERSION"; then
    add_finding "1.0.1" "$desc" "$risk" "$fix" "pass" "N/A"
else
    add_finding "1.0.1" "$desc" "$risk" "$fix" "fail" "Upgrade to at least version $REQUIRED_VERSION"
fi

# === Sample Checks ===

declare -A checks=(
    ["1.1.1"]="server_tokens off"
    ["1.2.1"]="ssl_certificate"
    ["1.2.2"]="ssl_ciphers HIGH:!aNULL:!MD5:!RC4"
    ["1.2.3"]="ssl_protocols TLSv1.2 TLSv1.3"
    ["1.2.4"]="add_header Strict-Transport-Security"
    ["1.3.1"]="limit_except GET POST"
    ["1.3.2"]="client_body_buffer_size 1m"
    ["1.3.3"]="client_max_body_size 10m"
    ["1.4.1"]="access_log"
    ["1.4.2"]="error_log"
    ["1.5.1"]="user nginx"
    ["1.6.1"]="client_header_buffer_size 1k"
    ["1.6.2"]="large_client_header_buffers 4 8k"
    ["1.7.1"]="limit_req_zone"
    ["1.7.2"]="limit_conn_zone"
    ["1.8.1"]="autoindex off"
    ["1.8.2"]="server_name"
    ["1.9.1"]="ssl_session_cache shared:SSL:10m"
    ["1.9.2"]="ssl_session_timeout 10m"
    ["1.10.1"]="proxy_buffering on"
    ["1.10.2"]="proxy_buffer_size 8k"
    ["1.11.1"]="gzip on"
    ["1.11.2"]="gzip_types text/html text/plain"
    ["1.12.1"]="worker_processes auto"
    ["1.12.2"]="worker_connections 1024"
    ["1.13.1"]="multi_accept off"
    ["1.14.1"]="keepalive_timeout 65"
    ["1.15.1"]="sendfile on"
    ["1.16.1"]="tcp_nodelay on"
)

for id in "${!checks[@]}"; do
    key_value="${checks[$id]}"
    key="$(echo "$key_value" | cut -d' ' -f1)"
    value="$(echo "$key_value" | cut -d' ' -f2-)"

    desc="Ensure $key is set to $value"
    risk="Medium"
    fix="Quick"
    if check_directive_value "$key" "$value"; then
        add_finding "$id" "$desc" "$risk" "$fix" "pass" "N/A"
    else
        add_finding "$id" "$desc" "$risk" "$fix" "fail" "Set '$key $value;' in the correct context."
    fi

    # Add special cases or override logic here if needed

done

# === Finalize HTML ===
echo "    </table></body></html>" >> "$OUTPUT_HTML"
echo "Audit complete. Report saved to $OUTPUT_HTML"
