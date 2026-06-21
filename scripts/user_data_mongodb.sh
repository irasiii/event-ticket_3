#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== [MongoDB Node] Starting setup ==="

# ── System update ──────────────────────────────────────────────────────────────
apt-get update -y
apt-get upgrade -y
apt-get install -y curl gnupg wget

# ── Install MongoDB 7.0 ────────────────────────────────────────────────────────
echo "--- Installing MongoDB 7.0 ---"
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc \
  | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] \
  https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
  | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt-get update -y
apt-get install -y mongodb-org

# ── Configure MongoDB to listen on all interfaces ──────────────────────────────
# (the security group restricts external access to the app node only)
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

# ── Enable and start MongoDB ───────────────────────────────────────────────────
systemctl daemon-reload
systemctl enable mongod
systemctl start mongod

# Wait for MongoDB to be ready
sleep 5
echo "--- MongoDB status ---"
systemctl status mongod --no-pager

echo "=== [MongoDB Node] Setup complete ==="
