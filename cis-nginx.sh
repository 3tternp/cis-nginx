#!/bin/bash

NGINX_CONF="/etc/nginx/nginx.conf"
OUT="cis_nginx_audit_report.html"

# Banner
echo "<html><head><title>CIS Benchmark for NGINX - Audit Report</title></head><body>" > $OUT
echo "<h1 style='color: navy;'>CIS Benchmark for NGINX - Audit Report</h1>" >> $OUT
echo "<table border='1' cellpadding='5'><tr>
<th>Finding ID</th>
<th>Description</th>
<th>Risk</th>
<th>Fix Type</th>
<th>Status</th>
<th>Remediation</th>
</tr>" >> $OUT

###########################################
# Begin Checks
###########################################

# 1.1.1 Ensure NGINX is installed
if command -v nginx >/dev/null 2>&1; then
  status="Pass"
else
  status="Fail"
fi
echo "<tr>
<td>1.1.1</td>
<td>Ensure NGINX is installed</td>
<td>Critical</td>
<td>Quick</td>
<td>$status</td>
<td>Install NGINX using your OS package manager.</td>
</tr>" >> $OUT

# 2.3.1 Ensure NGINX directories and files are owned by root
owner=$(stat -c %U /etc/nginx/nginx.conf 2>/dev/null)
if [ "$owner" == "root" ]; then
  status="Pass"
else
  status="Fail"
fi
echo "<tr>
<td>2.3.1</td>
<td>Ensure NGINX config files owned by root</td>
<td>High</td>
<td>Quick</td>
<td>$status</td>
<td>Run 'chown root:root /etc/nginx/nginx.conf'</td>
</tr>" >> $OUT

# 2.4.3 Ensure keepalive_timeout is 10 seconds or less, but not 0
timeout=$(grep -E '^\s*keepalive_timeout' $NGINX_CONF | awk '{print $2}' | tr -d ';')
if [[ ! -z "$timeout" && "$timeout" -le 10 && "$timeout" -ne 0 ]]; then
  status="Pass"
else
  status="Fail"
fi
echo "<tr>
<td>2.4.3</td>
<td>Check keepalive_timeout &le; 10s and not 0</td>
<td>Medium</td>
<td>Planned</td>
<td>$status</td>
<td>Edit nginx.conf: 'keepalive_timeout 10;'</td>
</tr>" >> $OUT

# 3.2 Ensure access logging is enabled
access_log=$(grep -E '^\s*access_log' $NGINX_CONF)
if [[ ! -z "$access_log" ]]; then
  status="Pass"
else
  status="Fail"
fi
echo "<tr>
<td>3.2</td>
<td>Ensure access logging is enabled</td>
<td>Medium</td>
<td>Planned</td>
<td>$status</td>
<td>Add 'access_log /var/log/nginx/access.log;' in nginx.conf</td>
</tr>" >> $OUT

# 4.1.1 Ensure HTTP is redirected to HTTPS
http_conf=$(grep -E "listen\s+80;" $NGINX_CONF)
redirect_conf=$(grep -E "return\s+301\s+https://" $NGINX_CONF)
if [[ ! -z "$http_conf" && ! -z "$redirect_conf" ]]; then
  status="Pass"
else
  status="Fail"
fi
echo "<tr>
<td>4.1.1</td>
<td>Redirect HTTP to HTTPS</td>
<td>High</td>
<td>Involved</td>
<td>$status</td>
<td>Add 'return 301 https://$host$request_uri;' in server block for port 80</td>
</tr>" >> $OUT

# Additional checks can be added here following the structure above

###########################################
# End Report
###########################################
echo "</table>
<p><em>Report generated: $(date)</em></p>
</body></html>" >> $OUT
