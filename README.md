# cis-nginx
This is a Bash-based auditing tool that checks your NGINX server against the CIS Benchmark best practices. It performs configuration validations and generates a clean, user-friendly HTML report.

🚀 Features

✅ Checks for over 30+ NGINX CIS controls

📜 Parses all .conf files under /etc/nginx

🧠 False positive-resistant directive validation

📈 HTML report generation

🔐 Verifies SSL/TLS config, logging, buffer limits, and hardening

📦 Lightweight and portable

📂 Output Example

HTML report: nginx_cis_audit_report.html

🛠️ Prerequisites
```
Bash shell

Root or sudo privileges

NGINX installed (1.14+ recommended)
```
📦 Installation
```
git clone https://github.com/your-username/nginx-cis-audit.git
cd nginx-cis-audit
chmod +x cis-nginx.sh
```
🚦 Usage
```
sudo ./cis-nginx.sh
🔒 You'll be asked for consent before the script runs.
```
# Usage 
<img width="823" height="191" alt="image" src="https://github.com/user-attachments/assets/769a3bdf-67f8-401c-8cf4-515dfcfcb1ba" />


# output 
<img width="1357" height="512" alt="image" src="https://github.com/user-attachments/assets/e3a84342-4e28-40cd-bfdf-81eb7a232dcc" />


