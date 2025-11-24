#!/bin/bash
# ...existing code...
set -euo pipefail
trap 'echo "[ERROR] Script failed on line $LINENO"; exit 1' ERR

echo "Welcome to Aws Auto Setup Script"
echo "=================================="
echo ""

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root sudo"
    exit 1
fi

read -r -p "[?] Is your project made with Python or NodeJS? (python/nodejs): " project_type
read -r -p "[?] Enter your GitHub project link: " github_link
read -r -p "[?] Enter your domain name (for Nginx setup, leave blank to skip): " domain_name
read -r -p "[?] Enter the port your application runs on (default 3000): " app_port
# Ask por python free ssl 
# ask for certbot python3-certbot-nginx
read -r -p "[?] Do you want to set up SSL with Let's Encrypt? (y/n): " setup_ssl_choice
if [[ "$setup_ssl_choice" =~ ^[Yy]$ ]]; then
    setup_ssl=true
else
    setup_ssl=false
fi

# if ssl is true ask for email for certbot
if [ "$setup_ssl" = true ]; then
    read -r -p "[?] Enter your email for Let's Encrypt notifications: " ssl_email
fi

read -r -p "---------------------------------- Press Enter to start the setup ----------------------------------"

app_port=${app_port:-3000}

if [[ "$project_type" != "python" && "$project_type" != "nodejs" ]]; then
    echo "[-] Invalid input. Please enter 'python' or 'nodejs'."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[+] Updating and upgrading the system..."
apt-get update -y
apt-get upgrade -y
echo "[+] System updated and upgraded."

if [ "$project_type" = "python" ]; then
    echo "[+] Installing Python and related packages..."
    apt-get install -y python3 python3-pip python3-venv gunicorn
    echo "[+] Python packages installed."
    echo "[!] Python project setup not fully automated in this script."
    exit 0

elif [ "$project_type" = "nodejs" ]; then
    echo "[+] Installing Node.js and npm..."
    
    apt-get install -y nodejs
    # Ensure npm is available
    npm --version >/dev/null 2>&1 || { echo "npm not found"; exit 1; }

    echo "[+] Installing PM2 globally..."
    npm install -g pm2

    if [ -z "$github_link" ]; then
        echo "[-] GitHub link cannot be empty."
        exit 1
    fi

    echo "[+] Preparing repository..."
    repo_name=$(basename "$github_link" .git)

    if [ -d "$repo_name" ]; then
        echo "[!] Directory '$repo_name' already exists — updating repository (git pull)..."
        git -C "$repo_name" pull --rebase || { echo "[-] Failed to update existing repo '$repo_name'"; exit 1; }
    else
        echo "[+] Cloning the GitHub repository..."
        git clone "$github_link" || { echo "[-] git clone failed"; exit 1; }
    fi

    if [ ! -d "$repo_name" ]; then
        echo "[-] Failed to clone or find repo directory: $repo_name"
        exit 1
    fi
    cd "$repo_name" || { echo "[-] Failed to enter the project directory."; exit 1; }

    echo "[+] Installing project dependencies..."
    npm install --production=false
    echo "[+] Dependencies installed."

    if [ ! -f .env ] && [ -f .demo.env ]; then
        echo "[+] Creating a .env file from .demo.env..."
        cp .demo.env .env
    fi

    # Build the project if a build script exists
    if npm run | grep -q ' build'; then
        echo "[+] Building the project..."
        npm run build
        echo "[+] Project built."
    fi
    
    echo "[+] Starting the application using PM2..."
    pm2 start npm --name "$repo_name" -- start
    pm2 save

    echo "[+] Installing and configuring Nginx..."
    apt-get install -y nginx
    if [ -f /etc/nginx/sites-enabled/default ]; then
        rm -f /etc/nginx/sites-enabled/default
    fi

    nginx_server_name="_"
    if [ -n "${domain_name:-}" ]; then
    nginx_server_name="$domain_name www.$domain_name"
    fi
    nginx_port="${app_port:-3000}"

    cat > /etc/nginx/sites-available/"$repo_name" <<EOL
server {
    listen 80;
    server_name $nginx_server_name;
    location / {
        proxy_pass http://localhost:$nginx_port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

    ln -sf /etc/nginx/sites-available/"$repo_name" /etc/nginx/sites-enabled/"$repo_name"
    systemctl restart nginx
    echo "[+] Nginx configured as a reverse proxy (port 80)."
fi

if [ "$setup_ssl" = true ] && [ -n "${domain_name:-}" ]; then
    echo "[+] Setting up SSL with Let's Encrypt..."
    apt-get install -y certbot python3-certbot-nginx
    certbot --nginx -d "$domain_name" -d "www.$domain_name" --non-interactive --agree-tos -m "$ssl_email"
    echo "[+] SSL setup completed."
else
    echo "[!] SSL setup skipped."
fi

echo ""
echo "[+] Setup completed successfully!"
echo "=================================="
# ...existing code...
