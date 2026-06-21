#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== [App Node] Starting setup ==="

# Injected by Terraform templatefile()
MONGODB_PRIVATE_IP="${mongodb_private_ip}"
MONGODB_PORT="${mongodb_port}"
APP_PORT="${app_port}"

# ── System update ──────────────────────────────────────────────────────────────
apt-get update -y
apt-get upgrade -y
apt-get install -y curl gnupg wget git nginx

# ── Install Node.js 20 LTS ─────────────────────────────────────────────────────
echo "--- Installing Node.js 20 LTS ---"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

echo "Node version: $(node -v)"
echo "npm version:  $(npm -v)"

# ── Install PM2 (process manager for Node.js) ─────────────────────────────────
npm install -g pm2

# ── Write environment config ───────────────────────────────────────────────────
mkdir -p /opt/app
cat > /opt/app/.env << ENV
NODE_ENV=production
PORT=$APP_PORT
MONGODB_URI=mongodb://$MONGODB_PRIVATE_IP:$MONGODB_PORT/myapp
ENV

# ── Configure Nginx as a reverse proxy ────────────────────────────────────────
cat > /etc/nginx/sites-available/app << NGINX_CONF
server {
    listen 80;
    server_name _;

    # Serve React build (static files)
    root /opt/app/client/build;
    index index.html;

    # React client-side routing fallback
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Proxy API requests to Node.js backend
    location /api/ {
        proxy_pass         http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade \$http_upgrade;
        proxy_set_header   Connection 'upgrade';
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_cache_bypass \$http_upgrade;
    }
}
NGINX_CONF

ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable nginx
systemctl restart nginx

# ── Enable PM2 on boot ─────────────────────────────────────────────────────────
pm2 startup systemd -u ubuntu --hp /home/ubuntu
systemctl enable pm2-ubuntu

echo "=== [App Node] Setup complete ==="
echo "MongoDB URI: mongodb://$MONGODB_PRIVATE_IP:$MONGODB_PORT/myapp"
echo "App will run on port: $APP_PORT"
