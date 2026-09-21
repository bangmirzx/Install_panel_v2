#!/bin/bash
set -e
# ============================================================
#  AUTO INSTALLER THEME PTERODACTYL
#  VERSI : MIRZX OFFICIAL
#  TELEGRAM : @MirzxOfficial
#  EMAIL : Mirzx_stecu@gmail.com
# ============================================================

# ====== KONFIGURASI (GANTI SESUAI PUNYA KAMU) ======
ACCESS_TOKEN="mirzxganteng"          # Token akses (ganti bebas)
TELEGRAM_ADMIN="@MirzxOfficial"      # Telegram admin
# Theme repo kamu (nanti upload zip tema ke repo sendiri)
THEME_BASE="https://cdn.jsdelivr.net/gh/MirzxOfficial/themeinstaller@main/theme"
# ============================================================

# Reset & Style
NC='\033[0m'; BOLD='\033[1m'
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; WHITE='\033[0;37m'
BG_BLUE='\033[44m'; BG_GREEN='\033[42m'; BG_RED='\033[41m'; BG_YELLOW='\033[43m'
BRIGHT_WHITE='\033[97m'

if [ "$EUID" -ne 0 ]; then
  echo -e "\n  ${BG_RED}${BRIGHT_WHITE}${BOLD} ERROR ${NC} ${BOLD}Akses Ditolak! Jalankan sebagai root.${NC}\n"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1
export DEBCONF_NONINTERACTIVE_SEEN=true
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0

log_info()    { echo -e "${BOLD}${CYAN}$1${NC}"; }
log_success() { echo -e "${BOLD}${GREEN}$1${NC}"; }
log_error()   { echo -e "${BOLD}${RED}$1${NC}"; }

print_info()    { echo -e "\n  ${BG_BLUE}${BRIGHT_WHITE}${BOLD} INFO ${NC} ${BOLD}$1${NC}\n"; }
print_success() { echo -e "\n  ${BG_GREEN}${BRIGHT_WHITE}${BOLD} SUCCESS ${NC} ${BOLD}$1${NC}\n"; }
print_warning() { echo -e "\n  ${BG_YELLOW}${BRIGHT_WHITE}${BOLD} WARNING ${NC} ${BOLD}$1${NC}\n"; }
print_error()   { echo -e "\n  ${BG_RED}${BRIGHT_WHITE}${BOLD} ERROR ${NC} ${BOLD}$1${NC}\n"; }

print_banner() {
  local title="$1" width=46 char="="
  local border=$(printf '%*s' "$width" "" | tr ' ' "$char")
  local pad=$(( (width - ${#title}) / 2 ))
  local padL=$(printf '%*s' "$pad" "")
  local padR=$(printf '%*s' $((width - ${#title} - pad)) "")
  echo -e "\n${BOLD}${BLUE}[+] ${border} [+]${NC}"
  echo -e "${BOLD}${BLUE}[+]${NC} ${BOLD}${padL}${title}${padR}${NC} ${BOLD}${BLUE}[+]${NC}"
  echo -e "${BOLD}${BLUE}[+] ${border} [+]\n${NC}"
}

safe_apt_update() {
  apt-get update --allow-releaseinfo-change -y 2>&1 | grep -q "NO_PUBKEY" && {
    print_warning "GPG Key hilang, mencoba perbaiki otomatis..."
    apt-get update --allow-releaseinfo-change -y 2>&1 | grep -o 'NO_PUBKEY [0-9A-F]*' | awk '{print $2}' | sort -u | xargs -r -I {} apt-key adv --keyserver keyserver.ubuntu.com --recv-keys {} >/dev/null 2>&1 || true
  }
  apt-get update --allow-releaseinfo-change -y >/dev/null 2>&1 || true
}

setup_nodejs() {
  print_info "Memeriksa Node.js v22..."
  local v=$(node -v 2>/dev/null | cut -d'.' -f1 | sed 's/v//')
  if [ "$v" == "22" ]; then
    log_success "Node.js v22 sudah terinstall."
  else
    print_warning "Menginstall Node.js v22..."
    apt-get remove -y nodejs npm libnode-dev nodejs-doc >/dev/null 2>&1 || true
    apt-get purge -y nodejs npm libnode-dev nodejs-doc >/dev/null 2>&1 || true
    rm -f /usr/bin/node /usr/local/bin/node /usr/bin/npm /usr/local/bin/npm
    rm -f /etc/apt/sources.list.d/nodesource*.list
    rm -f /etc/apt/keyrings/nodesource*.gpg
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor --yes | tee /etc/apt/keyrings/nodesource.gpg >/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list >/dev/null
    safe_apt_update
    apt-get install -y nodejs >/dev/null 2>&1
  fi
  hash -r
  npm i -g yarn >/dev/null 2>&1 || true
}

clear_cache() {
  print_info "Membersihkan cache..."
  cd /var/www/pterodactyl
  for c in optimize view config route cache; do php artisan $c:clear >/dev/null 2>&1; done
}

check_token() {
  print_banner "MIRZX OFFICIAL LICENSE"
  echo -e "${BOLD}${YELLOW}MASUKKAN AKSES TOKEN: ${NC}"
  read -r USER_TOKEN
  if [ "$USER_TOKEN" = "$ACCESS_TOKEN" ]; then
    echo -e "${BOLD}${GREEN}AKSES BERHASIL${NC}"
    sleep 1
  else
    log_error "Token salah! Hubungi ${TELEGRAM_ADMIN}"
    exit 1
  fi
}

install_theme() {
  # Format: "Nama Tema;Nama File Zip" (upload zip ke folder theme/ di repo kamu)
  local THEMES=(
    "Stellar;stellar.zip"
    "Billing;billing.zip"
    "Enigma;enigma.zip"
    "Elysium;elysium.zip"
    "Frostcore;frostcore.zip"
    "Nightcore;nightcore.zip"
  )
  while true; do
    clear
    print_banner "PILIH TEMA" "$BLUE"
    for i in "${!THEMES[@]}"; do
      IFS=';' read -r name file <<< "${THEMES[$i]}"
      echo -e " ${BRIGHT_WHITE}${BOLD}[$((i+1))]${NC} ${WHITE}$name${NC}"
    done
    echo -e " ${BRIGHT_WHITE}${BOLD}[x]${NC} ${WHITE}Kembali${NC}"
    echo -n -e "${BOLD}Pilihan (1-${#THEMES[@]} / x): ${NC}"
    read sel
    [[ "${sel,,}" == "x" ]] && return
    if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#THEMES[@]}" ]; then
      IFS=';' read -r TNAME TFILE <<< "${THEMES[$((sel-1))]}"
      break
    fi
    print_error "Pilihan tidak valid!"; sleep 1
  done

  echo -n -e "${BOLD}Install tema '$TNAME'? (y/n): ${NC}"; read cf
  [[ "$cf" != [yY] ]] && { log_info "Dibatalkan."; return; }

  local TMP=$(mktemp -d); cd "$TMP"
  print_info "[1/4] Mengunduh tema $TNAME..."
  wget -q "$THEME_BASE/$TFILE" || { print_error "Gagal unduh tema! Cek repo/theme kamu."; cd /; rm -rf "$TMP"; return; }
  print_info "[2/4] Ekstrak..."
  unzip -oq "$TFILE" || tar -xzf "$TFILE" 2>/dev/null || true
  rm -f "$TFILE"
  print_info "[3/4] Menyalin file ke panel..."
  cp -rfT pterodactyl /var/www/pterodactyl 2>/dev/null || { print_error "Struktur zip salah! Harus ada folder pterodactyl/ di dalam zip."; cd /; rm -rf "$TMP"; return; }
  cd /var/www/pterodactyl
  setup_nodejs
  corepack enable >/dev/null 2>&1 || true
  yarn config set network-timeout 300000 -g >/dev/null 2>&1
  print_info "[4/4] Build assets (yarn install + build)..."
  yarn install --network-timeout 300000 >/dev/null 2>&1
  yarn build:production >/dev/null 2>&1
  clear_cache
  chown -R www-data:www-data /var/www/pterodactyl/*
  print_success "Tema $TNAME berhasil diinstall!"
  cd /; rm -rf "$TMP"
}

install_blueprint() {
  print_info "Menginstall Blueprint..."
  cd /var/www/pterodactyl
  wget -q https://blueprint.zip/dist/blueprint -O blueprint.sh && chmod +x blueprint.sh
  bash blueprint.sh <<< $'y\ny\n' || bash blueprint.sh -y || true
  clear_cache
  print_success "Blueprint berhasil diinstall!"
}

reset_panel() {
  echo -n -e "${BOLD}${YELLOW}Reset panel ke tampilan default? (y/n): ${NC}"; read cf
  [[ "$cf" != [yY] ]] && return
  print_info "Reset panel..."
  cd /var/www/pterodactyl
  git checkout -- . 2>/dev/null || true
  php artisan view:clear config:clear cache:clear >/dev/null 2>&1
  yarn build:production >/dev/null 2>&1 || true
  chown -R www-data:www-data /var/www/pterodactyl/*
  print_success "Panel berhasil direset!"
}

uninstall_panel() {
  echo -n -e "${BOLD}${RED}Uninstall panel PTERODACTYL? (y/n): ${NC}"; read cf
  [[ "$cf" != [yY] ]] && return
  print_warning "Menghapus panel..."
  bash <(curl -s https://pterodactyl-installer.se) <<< $'7\ny\ny\n' || true
  systemctl stop wings pteroq 2>/dev/null || true
  rm -rf /var/www/pterodactyl /etc/pterodactyl /srv/daemon 2>/dev/null || true
  print_success "Uninstall selesai!"
}

start_wings() {
  print_info "Restart Wings..."
  systemctl daemon-reload
  systemctl enable --now wings
  systemctl restart wings
  sleep 2
  systemctl is-active --quiet wings && print_success "Wings AKTIF!" || print_error "Wings gagal start! Cek: journalctl -u wings"
}

create_node() {
  print_info "Membuat Node & Location otomatis..."
  cd /var/www/pterodactyl

  php artisan p:location:make --short=SG --long="Singapore - Mirzx" >/dev/null 2>&1 || true

  local RAM=$(free -m | awk '/Mem:/{print $2}')
  local IPVPS=$(curl -s ifconfig.me)

  # Buat node (SEMUA flag wajib diisi agar tidak interaktif)
  php artisan p:node:make \
    --name=NODES \
    --locationId=1 \
    --fqdn="$IPVPS" \
    --scheme=http \
    --memory="$RAM" \
    --disk="$RAM" \
    --uploadSize=100 \
    --daemonSftp=2022 \
    --daemonListen=8080 || true

  # Buat allocation untuk node ID 1
  php artisan p:node:allocation:make 1 --ip="$IPVPS" --port=25565-25665 || true

  print_success "Node & Location berhasil dibuat!"
}

reset_admin() {
  print_info "Reset password admin panel..."
  cd /var/www/pterodactyl
  php artisan p:user:make --email=Mirzx_stecu@gmail.com --username=admin --name-first=admin --name-last=admin --password=admin123 --admin=1 2>/dev/null || \
  php artisan tinker --execute="\$u=Pterodactyl\Models\User::where('email','Mirzx_stecu@gmail.com')->first(); if(\$u){\$u->password=bcrypt('admin123');\$u->save(); echo 'OK';}" 2>/dev/null || true
  print_success "Admin: Mirzx_stecu@gmail.com / admin123"
}

change_vps_pass() {
  echo -n -e "${BOLD}Password VPS baru: ${NC}"; read -s NEWPASS; echo
  echo "root:$NEWPASS" | chpasswd
  print_success "Password root VPS berhasil diubah!"
}

main_menu() {
  while true; do
    clear
    print_banner "MIRZX OFFICIAL INSTALLER" "$GREEN"
    echo -e " ${BRIGHT_WHITE}${BOLD}[1]${NC} ${WHITE}Install Tema${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[2]${NC} ${WHITE}Install Blueprint${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[3]${NC} ${WHITE}Reset Panel (default)${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[4]${NC} ${WHITE}Uninstall Panel${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[5]${NC} ${WHITE}Start / Restart Wings${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[6]${NC} ${WHITE}Create Node & Location${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[7]${NC} ${WHITE}Reset Password Admin${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[8]${NC} ${WHITE}Ubah Password VPS${NC}"
    echo -e " ${BRIGHT_WHITE}${BOLD}[x]${NC} ${WHITE}Keluar${NC}"
    echo ""
    echo -e " ${CYAN}Telegram: ${TELEGRAM_ADMIN}${NC}"
    echo -n -e "${BOLD}Pilih menu: ${NC}"
    read menu
    case "$menu" in
      1) install_theme ;;
      2) install_blueprint ;;
      3) reset_panel ;;
      4) uninstall_panel ;;
      5) start_wings ;;
      6) create_node ;;
      7) reset_admin ;;
      8) change_vps_pass ;;
        x|X) echo -e "${BOLD}${GREEN}Keluar dari menu...${NC}"; break ;;
  *) print_error "Menu tidak ada!"; sleep 1 ;;
    esac
    echo -n -e "${BOLD}Tekan ENTER untuk kembali...${NC}"; read
  done
}

# ====== MULAI ======
clear
echo -e "${BOLD}${BLUE}"
echo "  [+] ========================================= [+]"
echo "  [+]       AUTO INSTALLER MIRZX OFFICIAL       [+]"
echo "  [+] ========================================= [+]"
echo -e "${NC}"
echo -e " ${WHITE}Telegram: ${TELEGRAM_ADMIN}${NC}"
sleep 1

print_info "Memeriksa dependencies (jq, curl, unzip)..."
safe_apt_update
apt-get install -y jq curl wget zip unzip git >/dev/null 2>&1
log_success "Dependencies siap."
sleep 1

check_token
main_menu
