#!/bin/bash
# ==============================================
# AUTO INSTALLER THEMA PTERODACTYL - NODE.JS 20 LTS
# ==============================================

# Warna
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NC='\033[0m'

# Tampilan Selamat Datang
display_welcome() {
  echo -e ""
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                                                 [+]${NC}"
  echo -e "${WHITE}[+]           AUTO INSTALLER THEMA PTERODACTYL      [+]${NC}"
  echo -e "${WHITE}[+]                © Mirzxinstaler                  [+]${NC}"
  echo -e "${BLUE}[+]                                                 [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e ""
  echo -e "Script untuk mempermudah penginstalasian tema Pterodactyl"
  echo -e ""
  echo -e "TELEGRAM : @Mirzzxx_stecu"
  echo -e "CREDITS : @Mirzzxx_stecu"
  sleep 3
  clear
}

# Update & Pasang jq
install_jq() {
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]             UPDATE & INSTALL JQ                 [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  
  sudo apt update -y && sudo apt install -y jq
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] ✅ JQ BERHASIL DIPASANG${NC}"
  else
    echo -e "${RED}[+] ❌ GAGAL MEMASANG JQ${NC}"
    exit 1
  fi
  sleep 1
  clear
}

# Cek Token Akses
check_token() {
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]               CEK AKSES TOKEN                    [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${YELLOW}Masukkan Token Akses: ${NC}"
  read -r USER_TOKEN

  if [ "$USER_TOKEN" = "mirzxganteng" ]; then
    echo -e "${GREEN}✅ AKSES DITERIMA${NC}"
  else
    echo -e "${RED}❌ Token Salah!${NC}"
    echo -e "${YELLOW}Beli dulu ke:${NC}"
    echo -e "Telegram: @Mirzzxx_stecu"
    echo -e "WhatsApp: 6281353473241"
    echo -e "Harga: 10K (gratis update jika ada token baru)"
    exit 1
  fi
  sleep 1
  clear
}

# Fungsi Bantuan - Cek Direktori Panel
check_panel_dir() {
  if [ ! -d "/var/www/pterodactyl" ]; then
    echo -e "${RED}[!] Direktori /var/www/pterodactyl TIDAK DITEMUKAN!${NC}"
    echo -e "${YELLOW}Pastikan panel sudah terpasang.${NC}"
    exit 1
  fi
}

# Pasang Tema - Node.js 20 LTS
install_theme() {
  while true; do
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "${WHITE}[+]              PILIH TEMA PTERODACTYL             [+]${NC}"
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e ""
    echo "1. Stellar"
    echo "2. Billing"
    echo "3. Enigma"
    echo "x. Kembali ke Menu"
    echo -e "Masukkan pilihan (1/2/3/x):"
    read -r SELECT_THEME

    case "$SELECT_THEME" in
      1) THEME_URL="https://github.com/gitfdil1248/thema/raw/main/C2.zip"; THEME_NAME="Stellar"; break ;;
      2) THEME_URL="https://github.com/DITZZ112/foxxhostt/raw/main/C1.zip"; THEME_NAME="Billing"; break ;;
      3) THEME_URL="https://github.com/gitfdil1248/thema/raw/main/C3.zip"; THEME_NAME="Enigma"; break ;;
      x) return ;;
      *) echo -e "${RED}Pilihan tidak valid!${NC}" ;;
    esac
  done

  check_panel_dir

  # Hapus folder sementara jika ada
  [ -d /root/pterodactyl ] && sudo rm -rf /root/pterodactyl
  cd /root || exit 1

  # Unduh tema
  echo -e "${YELLOW}[+] Mengunduh tema ${THEME_NAME}...${NC}"
  wget -q "$THEME_URL" -O theme.zip
  [ $? -ne 0 ] && { echo -e "${RED}❌ Gagal mengunduh tema!${NC}"; exit 1; }

  # Ekstrak
  sudo unzip -o theme.zip -d /root/pterodactyl >/dev/null 2>&1
  [ $? -ne 0 ] && { echo -e "${RED}❌ Gagal mengekstrak tema!${NC}"; exit 1; }

  # Khusus Enigma: minta info
  if [ "$SELECT_THEME" = "3" ]; then
    echo -e "${YELLOW}Masukkan link WA (https://wa.me/...): ${NC}"; read -r LINK_WA
    echo -e "${YELLOW}Masukkan link Grup: ${NC}"; read -r LINK_GROUP
    echo -e "${YELLOW}Masukkan link Channel: ${NC}"; read -r LINK_CHNL
    
    sudo sed -i "s|LINK_WA|$LINK_WA|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    sudo sed -i "s|LINK_GROUP|$LINK_GROUP|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    sudo sed -i "s|LINK_CHNL|$LINK_CHNL|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
  fi

  # Salin ke direktori panel
  echo -e "${YELLOW}[+] Menyalin file tema...${NC}"
  sudo cp -rfT /root/pterodactyl /var/www/pterodactyl

  # ⭐ DIPERBARUI: Pasang Node.js 20 LTS
  if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}[+] Memasang Node.js 20 LTS...${NC}"
    curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
  fi

  if ! command -v yarn &> /dev/null; then
    echo -e "${YELLOW}[+] Memasang Yarn...${NC}"
    sudo npm i -g yarn
  fi

  # Build tema
  cd /var/www/pterodactyl || exit 1
  echo -e "${YELLOW}[+] Membangun tema...${NC}"
  
  yarn add react-feather
  
  if [ "$SELECT_THEME" = "2" ]; then
    php artisan billing:install stable
  fi
  
  php artisan migrate --force
  yarn build:production
  php artisan view:clear

  # Bersihkan
  sudo rm -f /root/theme.zip
  sudo rm -rf /root/pterodactyl

  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]        TEMA ${THEME_NAME} BERHASIL DIPASANG!    [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  sleep 3
  clear
}

# Hapus Tema
uninstall_theme() {
  echo -e "${BLUE}[+] Menghapus tema...${NC}"
  check_panel_dir
  bash <(curl -s https://raw.githubusercontent.com/gitfdil1248/thema/main/repair.sh)
  echo -e "${GREEN}✅ Tema dikembalikan ke bawaan!${NC}"
  sleep 2; clear
}

# Pasang Tema Stellar Langsung - Node.js 20 LTS
install_themeSteeler() {
  check_panel_dir
  cd /root || exit 1
  
  [ -f C2.zip ] && rm -f C2.zip
  [ -d /root/pterodactyl ] && rm -rf /root/pterodactyl

  wget -qO C2.zip https://github.com/gitfdil1248/thema/raw/main/C2.zip
  unzip -q C2.zip -d /root/pterodactyl
  sudo cp -rfT /root/pterodactyl /var/www/pterodactyl

  # ⭐ DIPERBARUI: Pasang Node.js 20 LTS jika belum ada
  if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}[+] Memasang Node.js 20 LTS...${NC}"
    curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
  fi

  if ! command -v yarn &> /dev/null; then
    sudo npm i -g yarn
  fi

  cd /var/www/pterodactyl || exit 1
  yarn add react-feather
  php artisan migrate --force
  yarn build:production
  php artisan view:clear

  rm -f /root/C2.zip
  rm -rf /root/pterodactyl

  echo -e "${GREEN}✅ Stellar berhasil dipasang dengan Node.js 20 LTS!${NC}"
  sleep 2; clear; exit 0
}

# Buat Node & Lokasi
create_node() {
  check_panel_dir
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]              BUAT NODE & LOKASI                 [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"

  read -p "Nama Lokasi: " location_name
  read -p "Deskripsi Lokasi: " location_desc
  read -p "Domain Node (contoh: node1.domain.com): " domain
  read -p "Nama Node: " node_name
  read -p "RAM (MB): " ram
  read -p "Disk (MB): " disk_space
  read -p "ID Lokasi (locid): " locid

  cd /var/www/pterodactyl || exit 1

  echo -e "${YELLOW}[+] Membuat lokasi...${NC}"
  php artisan p:location:make <<EOF
$location_name
$location_desc
EOF

  echo -e "${YELLOW}[+] Membuat node...${NC}"
  php artisan p:node:make <<EOF
$node_name
$location_desc
$locid
https
$domain
yes
no
no
$ram
$ram
$disk_space
$disk_space
100
8080
2022
/var/lib/pterodactyl/volumes
EOF

  echo -e "${GREEN}✅ Node & Lokasi Berhasil Dibuat!${NC}"
  sleep 2; clear
}

# Konfigurasi Wings
configure_wings() {
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]             KONFIGURASI WINGS                   [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${YELLOW}Salin perintah dari panel lalu tempel di bawah:${NC}"
  echo -e "${YELLOW}(Biasanya diawali dengan: mkdir -p /etc/pterodactyl ...)${NC}"
  echo ""
  read -r -p "Perintah: " wings_cmd
  
  if [[ -z "$wings_cmd" ]]; then
    echo -e "${RED}❌ Perintah kosong!${NC}"
    return
  fi

  echo -e "${YELLOW}[+] Menjalankan konfigurasi...${NC}"
  eval "$wings_cmd"
  sudo systemctl enable --now wings
  sudo systemctl start wings

  echo -e "${GREEN}✅ Wings Berjalan!${NC}"
  sudo systemctl status wings --no-pager
  sleep 3; clear
}

# Tambah Akun Admin
hackback_panel() {
  check_panel_dir
  cd /var/www/pterodactyl || exit 1
  
  echo -e "${BLUE}[+] TAMBAH AKUN ADMIN${NC}"
  read -p "Username: " user
  read -p "Email: " email
  read -s -p "Password: " psswdhb; echo ""

  php artisan p:user:make <<EOF
yes
$email
$user
$user
$user
$psswdhb
EOF

  echo -e "${GREEN}✅ Akun Admin Ditambahkan!${NC}"
  sleep 2; clear
}

# Ganti Password VPS
ubahpw_vps() {
  echo -e "${BLUE}[+] GANTI PASSWORD ROOT${NC}"
  read -s -p "Password Baru: " pw1; echo ""
  read -s -p "Ulangi Password: " pw2; echo ""

  if [ "$pw1" != "$pw2" ]; then
    echo -e "${RED}❌ Password tidak sama!${NC}"
    return
  fi

  echo "root:$pw1" | sudo chpasswd
  echo -e "${GREEN}✅ Password Berhasil Diubah!${NC}"
  sleep 2; clear
}

# Hapus Panel
uninstall_panel() {
  echo -e "${RED}[!] PERINGATAN: Ini akan MENGHAPUS PANEL SECARA TOTAL!${NC}"
  read -p "Ketik YA untuk melanjutkan: " confirm
  if [ "$confirm" != "YA" ]; then
    echo -e "${YELLOW}Dibatalkan.${NC}"; return
  fi
  
  bash <(curl -s https://pterodactyl-installer.se) <<EOF
y
y
y
y
EOF
  echo -e "${GREEN}✅ Panel Dihapus!${NC}"
  sleep 2; clear
}

# ================= MENU UTAMA =================
display_welcome
install_jq
check_token

while true; do
  clear
  echo -e "${RED}        _,gggggggggg.                              ${NC}"
  echo -e "${RED}    ,ggggggggggggggggg.                            ${NC}"
  echo -e "${RED}  ,ggggg        gggggggg.                          ${NC}"
  echo -e "${RED} ,ggg'               'ggg.                         ${NC}"
  echo -e "${RED}',gg       ,ggg.      'ggg:                        ${NC}"
  echo -e "${RED}'ggg      ,gg'''  .    ggg      Auto Installer      ${NC}"
  echo -e "${RED}gggg      gg     ,     ggg                         ${NC}"
  echo -e "${WHITE}ggg:     gg.     -   ,ggg       WA: 628135347241   ${NC}"
  echo -e "${WHITE} ggg:     ggg._    _,ggg        © Mirzxinstaler    ${NC}"
  echo -e "${WHITE}  'ggg    '-.__                                    ${NC}"
  echo -e "${WHITE}    ggg                                            ${NC}"
  echo -e ""
  echo -e "${BLUE}=== DAFTAR MENU ===${NC}"
  echo "1. Pasang Tema"
  echo "2. Hapus Tema"
  echo "3. Konfigurasi Wings"
  echo "4. Buat Node"
  echo "5. Hapus Panel"
  echo "6. Pasang Tema Stellar"
  echo "7. Tambah Akun Admin"
  echo "8. Ganti Password VPS"
  echo "x. Keluar"
  echo -e "Pilih: "
  read -r MENU_CHOICE

  case "$MENU_CHOICE" in
    1) install_theme ;;
    2) uninstall_theme ;;
    3) configure_wings ;;
    4) create_node ;;
    5) uninstall_panel ;;
    6) install_themeSteeler ;;
    7) hackback_panel ;;
    8) ubahpw_vps ;;
    x) echo "Keluar..."; exit 0 ;;
    *) echo -e "${RED}Pilihan tidak valid!${NC}"; sleep 1 ;;
  esac
done
