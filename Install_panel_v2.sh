#!/bin/bash
# ======================================
#  PTERODACTYL WINGS AUTO INSTALLER
#  + AUTO START + STATUS HIJAU
#  OS: Ubuntu 20.04 / 22.04
#  Dibuat untuk: @Mirzzxx_stecu
# ======================================

clear
echo "====================================="
echo "  PTERODACTYL WINGS AUTO INSTALL"
echo "  + AUTO START + STATUS HIJAU 🟢"
echo "====================================="
echo ""

# CEK ROOT
if [ "$EUID" -ne 0 ]; then
  echo "❌ Jalankan sebagai root!"
  echo "   Ketik: sudo su"
  exit 1
fi

# INPUT DATA
read -p "Domain Panel (contoh: panel.kamu.id): " DOMAIN_PANEL
read -p "Domain/IP Node (contoh: node1.kamu.id): " DOMAIN_NODE
read -p "Token Konfigurasi (dari Panel > Nodes > Create Node): " TOKEN
echo ""

# UPDATE SISTEM
echo "🔄 Memperbarui sistem..."
apt update && apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# PASANG DOCKER
echo "🐳 Memasang Docker..."
curl -fsSL https://get.docker.com/ | CHANNEL=stable bash
systemctl enable --now docker

# PASANG WINGS
echo "📥 Mengunduh Wings..."
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
chmod +x /usr/local/bin/wings

# GENERATE KONFIGURASI
echo "⚙️ Membuat konfigurasi..."
cd /etc/pterodactyl
/usr/local/bin/wings configure --panel-url=https://$DOMAIN_PANEL --token=$TOKEN --node-fqdn=$DOMAIN_NODE --api-port=8080 --daemon-port=2022 --ssl-mode=letsencrypt

# BUAT SERVICE AUTO START
echo "🔧 Mengatur Auto Start & Auto Restart..."
cat > /etc/systemd/system/wings.service <<'EOF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service network-online.target
Requires=docker.service network-online.target

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=always
RestartSec=5s
StartLimitInterval=180
StartLimitBurst=30

[Install]
WantedBy=multi-user.target
EOF

# BUKA PORTO
echo "🔥 Membuka port..."
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw allow 2022/tcp
ufw reload 2>/dev/null

# MULAIKAN WINGS
echo "🚀 Menyalakan Wings..."
systemctl daemon-reload
systemctl enable --now wings

# CEK STATUS
sleep 5
if systemctl is-active --quiet wings; then
  echo ""
  echo "✅ WINGS BERJALAN! STATUS: HIJAU 🟢"
  echo "✅ Auto Start: AKTIF"
  echo "✅ Auto Restart: AKTIF"
else
  echo ""
  echo "⚠️ Cek perintah: journalctl -u wings -f"
fi

echo ""
echo "====================================="
echo "✅ INSTALLASI SELESAI!"
echo "====================================="
echo "Node: $DOMAIN_NODE"
echo "Port API: 8080 | Port SFTP: 2022"
echo "Status di Panel: Online 🟢"
echo "====================================="
echo "Perintah berguna:"
echo "  Cek status : systemctl status wings"
echo "  Lihat log  : journalctl -u wings -f"
echo "  Restart    : systemctl restart wings"
echo "====================================="
