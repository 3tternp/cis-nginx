#!/bin/bash

# Banner
echo "========================================"
echo "CIS Benchmark for Nginx Configuration Audit"
echo "========================================"

# Variables
OUTPUT_HTML="nginx_cis_audit_report.html"
NGINX_CONF="/etc/nginx/nginx.conf"
NGINX_DIR="/etc/nginx"
NGINX_LOGS="/var/log/nginx"
NGINX_USER=$(ps -C nginx -o user --no-headers 2>/dev/null || echo "nginx")
DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Start HTML file
cat > "$OUTPUT_HTML" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>CIS Benchmark Nginx Audit Report - $DATE</title>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .pass { background-color: #90ee90; }
        .fail { background-color: #ff6347; }
    </style>
</head>
<body>
    <h1>CIS Benchmark Nginx Audit Report</h1>
    <p>Generated on: $DATE</p>
    <table>
        <tr>
            <th>Finding ID</th>
            <th>Description</th>
            <th>Risk Rating</th>
            <th>Fix Type</th>
            <th>Status</th>
            <th>Remediation</th>
        </tr>
EOF

# Function to add finding to HTML
add_finding() {
    local id=$1
    local desc=$2
    local risk=$3
    local fix_type=$4
    local status=$5
    local remediation=$6
    cat >> "$OUTPUT_HTML" <<EOF
        <tr class="$status">
            <td>$id</td>
            <td>$desc</td>
            <td>$risk</td>
            <td>$fix_type</td>
            <td>$status</td>
            <td>$remediation</td>
        </tr>
EOF
}

# 1.1.1: Ensure server tokens are disabled
desc="Ensure server tokens are disabled to prevent version disclosure"
risk="Medium"
fix_type="Quick"
if grep -q "server_tokens off;" "$NGINX_CONF" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'server_tokens off;' in the http block of nginx.conf."
fi
add_finding "1.1.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.1.2: Ensure server header is not customized
desc="Ensure server header is not customized to prevent information leakage"
risk="Low"
fix_type="Quick"
if grep -q "server_tokens on;" "$NGINX_CONF" 2>/dev/null || grep -q "server_names_hash_bucket_size" "$NGINX_CONF" 2>/dev/null; then
    status="fail"
    remediation="Remove or comment out 'server_tokens on;' and avoid custom server header settings."
else
    status="pass"
    remediation="N/A"
fi
add_finding "1.1.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.2.1: Ensure SSL/TLS is configured
desc="Ensure SSL/TLS is configured for secure connections"
risk="High"
fix_type="Involved"
if grep -r "ssl_certificate" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Configure SSL/TLS by adding 'ssl_certificate' and 'ssl_certificate_key' in server blocks with a valid certificate."
fi
add_finding "1.2.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.2.2: Ensure strong SSL ciphers are used
desc="Ensure weak SSL ciphers are disabled"
risk="Critical"
fix_type="Involved"
if grep -r "ssl_ciphers" "$NGINX_DIR" 2>/dev/null | grep -q "HIGH:!aNULL:!MD5:!RC4"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'ssl_ciphers HIGH:!aNULL:!MD5:!RC4;' in the server block with SSL."
fi
add_finding "1.2.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.2.3: Ensure SSL protocols are restricted
desc="Ensure only TLS 1.2 or higher is enabled"
risk="High"
fix_type="Involved"
if grep -r "ssl_protocols" "$NGINX_DIR" 2>/dev/null | grep -q "TLSv1.2 TLSv1.3"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'ssl_protocols TLSv1.2 TLSv1.3;' in the server block with SSL."
fi
add_finding "1.2.3" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.2.4: Ensure HSTS is enabled
desc="Ensure HTTP Strict Transport Security (HSTS) is enabled"
risk="High"
fix_type="Involved"
if grep -r "add_header Strict-Transport-Security" "$NGINX_DIR" 2>/dev/null | grep -q "max-age=31536000"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;' in the server block with SSL."
fi
add_finding "1.2.4" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.3.1: Ensure unnecessary HTTP methods are restricted
desc="Ensure unnecessary HTTP methods are restricted"
risk="Medium"
fix_type="Planned"
if grep -r "limit_except GET POST" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'limit_except GET POST { deny all; }' in location blocks to restrict methods."
fi
add_finding "1.3.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.3.2: Ensure client body buffer size is set
desc="Ensure client body buffer size is configured to prevent overflow"
risk="Medium"
fix_type="Quick"
if grep -r "client_body_buffer_size" "$NGINX_DIR" 2>/dev/null | grep -q "1m"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'client_body_buffer_size 1m;' in the http block."
fi
add_finding "1.3.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.3.3: Ensure client max body size is set
desc="Ensure client max body size is limited"
risk="Medium"
fix_type="Quick"
if grep -r "client_max_body_size" "$NGINX_DIR" 2>/dev/null | grep -q "10m"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'client_max_body_size 10m;' in the http block or server block."
fi
add_finding "1.3.3" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.4.1: Ensure access logging is enabled
desc="Ensure access logging is enabled"
risk="Low"
fix_type="Quick"
if grep -q "access_log" "$NGINX_CONF" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'access_log /var/log/nginx/access.log;' in the http or server block."
fi
add_finding "1.4.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.4.2: Ensure error logging is enabled
desc="Ensure error logging is enabled"
risk="Low"
fix_type="Quick"
if grep -q "error_log" "$NGINX_CONF" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'error_log /var/log/nginx/error.log;' in the http or server block."
fi
add_finding "1.4.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.4.3: Ensure log rotation is configured
desc="Ensure log rotation is configured for Nginx logs"
risk="Low"
fix_type="Involved"
if [ -f "/etc/logrotate.d/nginx" ]; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Create a logrotate configuration file at /etc/logrotate.d/nginx with appropriate rotation settings."
fi
add_finding "1.4.3" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.5.1: Ensure Nginx runs as non-root user
desc="Ensure Nginx runs as a non-root user"
risk="High"
fix_type="Involved"
if [ "$NGINX_USER" != "root" ]; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Configure Nginx to run as a non-root user (e.g., 'nginx' user) in the service file or startup script."
fi
add_finding "1.5.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.6.1: Ensure Nginx configuration files have correct permissions
desc="Ensure Nginx configuration files have 640 or more restrictive permissions"
risk="Medium"
fix_type="Quick"
if [ -f "$NGINX_CONF" ] && [ "$(stat -c %a "$NGINX_CONF" 2>/dev/null)" -le 640 ]; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set permissions to 640 or more restrictive with 'chmod 640 $NGINX_CONF' and ensure ownership by root."
fi
add_finding "1.6.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.6.2: Ensure Nginx directory has correct permissions
desc="Ensure Nginx directory has 755 or more restrictive permissions"
risk="Medium"
fix_type="Quick"
if [ -d "$NGINX_DIR" ] && [ "$(stat -c %a "$NGINX_DIR" 2>/dev/null)" -le 755 ]; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set permissions to 755 or more restrictive with 'chmod 755 $NGINX_DIR' and ensure ownership by root."
fi
add_finding "1.6.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.6.3: Ensure log directory has correct permissions
desc="Ensure Nginx log directory has 750 or more restrictive permissions"
risk="Medium"
fix_type="Quick"
if [ -d "$NGINX_LOGS" ] && [ "$(stat -c %a "$NGINX_LOGS" 2>/dev/null)" -le 750 ]; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set permissions to 750 or more restrictive with 'chmod 750 $NGINX_LOGS' and ensure ownership by root."
fi
add_finding "1.6.3" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.7.1: Ensure buffer overflow protection is enabled
desc="Ensure buffer overflow protection with client_header_buffer_size"
risk="High"
fix_type="Quick"
if grep -r "client_header_buffer_size" "$NGINX_DIR" 2>/dev/null | grep -q "1k"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'client_header_buffer_size 1k;' in the http block."
fi
add_finding "1.7.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.7.2: Ensure large_client_header_buffers is set
desc="Ensure large_client_header_buffers is configured"
risk="High"
fix_type="Quick"
if grep -r "large_client_header_buffers" "$NGINX_DIR" 2>/dev/null | grep -q "4 8k"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'large_client_header_buffers 4 8k;' in the http block."
fi
add_finding "1.7.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.8.1: Ensure rate limiting is configured
desc="Ensure rate limiting is configured to prevent DoS"
risk="Medium"
fix_type="Planned"
if grep -r "limit_req_zone" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;' and 'limit_req zone=mylimit burst=20;' in http and server blocks."
fi
add_finding "1.8.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.8.2: Ensure connection limits are set
desc="Ensure connection limits are set to prevent abuse"
risk="Medium"
fix_type="Planned"
if grep -r "limit_conn_zone" "$NGINX_DIR" 2>/dev/null | grep -q "zone=addr:10m"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'limit_conn_zone $binary_remote_addr zone=addr:10m;' and 'limit_conn addr 5;' in http and server blocks."
fi
add_finding "1.8.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.9.1: Ensure autoindex is disabled
desc="Ensure autoindex is disabled to prevent directory listing"
risk="Medium"
fix_type="Quick"
if grep -r "autoindex off;" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'autoindex off;' in location blocks."
fi
add_finding "1.9.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.9.2: Ensure server_name is set
desc="Ensure server_name is set to prevent default behavior"
risk="Low"
fix_type="Quick"
if grep -r "server_name" "$NGINX_DIR" 2>/dev/null | grep -v "^#"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'server_name yourdomain.com;' in server blocks."
fi
add_finding "1.9.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.10.1: Ensure SSL session caching is enabled
desc="Ensure SSL session caching is enabled for performance"
risk="Low"
fix_type="Involved"
if grep -r "ssl_session_cache" "$NGINX_DIR" 2>/dev/null | grep -q "shared:SSL:10m"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'ssl_session_cache shared:SSL:10m;' in the server block with SSL."
fi
add_finding "1.10.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.10.2: Ensure SSL session timeout is set
desc="Ensure SSL session timeout is configured"
risk="Low"
fix_type="Involved"
if grep -r "ssl_session_timeout" "$NGINX_DIR" 2>/dev/null | grep -q "10m"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'ssl_session_timeout 10m;' in the server block with SSL."
fi
add_finding "1.10.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.11.1: Ensure proxy buffering is enabled
desc="Ensure proxy buffering is enabled for reverse proxy"
risk="Low"
fix_type="Quick"
if grep -r "proxy_buffering on;" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'proxy_buffering on;' in proxy server blocks."
fi
add_finding "1.11.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.11.2: Ensure proxy buffer size is set
desc="Ensure proxy buffer size is configured"
risk="Low"
fix_type="Quick"
if grep -r "proxy_buffer_size" "$NGINX_DIR" 2>/dev/null | grep -q "8k"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'proxy_buffer_size 8k;' in proxy server blocks."
fi
add_finding "1.11.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.12.1: Ensure gzip compression is enabled
desc="Ensure gzip compression is enabled for performance"
risk="Information"
fix_type="Quick"
if grep -r "gzip on;" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'gzip on;' in the http block with appropriate gzip settings."
fi
add_finding "1.12.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.12.2: Ensure gzip types are restricted
desc="Ensure gzip types are restricted to safe content types"
risk="Low"
fix_type="Quick"
if grep -r "gzip_types" "$NGINX_DIR" 2>/dev/null | grep -q "text/html text/plain"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'gzip_types text/html text/plain text/css;' in the http block."
fi
add_finding "1.12.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.13.1: Ensure worker processes are limited
desc="Ensure worker_processes is set to auto or a fixed number"
risk="Low"
fix_type="Quick"
if grep -r "worker_processes" "$NGINX_CONF" 2>/dev/null | grep -E "auto|[0-9]+"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'worker_processes auto;' or a fixed number in nginx.conf."
fi
add_finding "1.13.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.13.2: Ensure worker connections are limited
desc="Ensure worker_connections is set to a reasonable limit"
risk="Low"
fix_type="Quick"
if grep -r "worker_connections" "$NGINX_DIR" 2>/dev/null | grep -q "1024"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'worker_connections 1024;' in the events block."
fi
add_finding "1.13.2" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.14.1: Ensure multi_accept is disabled
desc="Ensure multi_accept is disabled for security"
risk="Low"
fix_type="Quick"
if grep -r "multi_accept off;" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'multi_accept off;' in the events block."
fi
add_finding "1.14.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.15.1: Ensure keepalive timeout is set
desc="Ensure keepalive_timeout is set to a reasonable value"
risk="Low"
fix_type="Quick"
if grep -r "keepalive_timeout" "$NGINX_DIR" 2>/dev/null | grep -q "65"; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Set 'keepalive_timeout 65;' in the http block."
fi
add_finding "1.15.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.16.1: Ensure sendfile is enabled
desc="Ensure sendfile is enabled for performance"
risk="Information"
fix_type="Quick"
if grep -r "sendfile on;" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'sendfile on;' in the http block."
fi
add_finding "1.16.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# 1.17.1: Ensure TCP_NODELAY is enabled
desc="Ensure TCP_NODELAY is enabled for performance"
risk="Information"
fix_type="Quick"
if grep -r "tcp_nodelay on;" "$NGINX_DIR" 2>/dev/null; then
    status="pass"
    remediation="N/A"
else
    status="fail"
    remediation="Add 'tcp_nodelay on;' in the http block."
fi
add_finding "1.17.1" "$desc" "$risk" "$fix_type" "$status" "$remediation"

# End HTML file
cat >> "$OUTPUT_HTML" <<EOF
    </table>
</body>
</html>
EOF

echo "Audit completed. Report generated: $OUTPUT_HTML"
