#!/bin/bash
set -e
# Apa? Mau nyolong?? 😹😹
# ============================================================
# SKRIP INI DIBUAT OLEH MIRZZXX OFFICIAL
# TELEGRAM: @Mirzzxx_stecu
# DISARANKAN GAK USAH NYOLONG!
# LEBIH BAIK LANGSUNG PAKE AJA, KALO EROR BIAR GW (MIRZX) YANG BENERINNYA, LU TINGGAL LAPOR AJA KE TELEGRAM.
# ============================================================

# Reset
NC='\033[0m'

# Style
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
HIDDEN='\033[8m'

# Foreground (Text Color Normal)
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Foreground (Text Color Bright/Bold)
BRIGHT_BLACK='\033[90m'
BRIGHT_RED='\033[91m'
BRIGHT_GREEN='\033[92m'
BRIGHT_YELLOW='\033[93m'
BRIGHT_BLUE='\033[94m'
BRIGHT_MAGENTA='\033[95m'
BRIGHT_CYAN='\033[96m'
BRIGHT_WHITE='\033[97m'

# Background Colors (Normal)
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Background Colors (Bright)
BG_BRIGHT_BLACK='\033[100m'
BG_BRIGHT_RED='\033[101m'
BG_BRIGHT_GREEN='\033[102m'
BG_BRIGHT_YELLOW='\033[103m'
BG_BRIGHT_BLUE='\033[104m'
BG_BRIGHT_MAGENTA='\033[105m'
BG_BRIGHT_CYAN='\033[106m'
BG_BRIGHT_WHITE='\033[107m'

if [ "$EUID" -ne 0 ]; then
  print_error "Akses Ditolak! Skrip ini wajib dijalankan sebagai root."
  return 1
fi

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1
export DEBCONF_NONINTERACTIVE_SEEN=true
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"

[ -f /etc/needrestart/needrestart.conf ] && sed -i -E "s/#?\$nrconf\{restart\} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf

unset DATABASE_URL DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD

log_info() {
  echo -e "${BOLD}${CYAN}$1${NC}"
}

log_success() {
  echo -e "${BOLD}${GREEN}$1${NC}"
}

log_error() {
  echo -e "${BOLD}${RED}$1${NC}"
}

print_info() {
  echo -e "\n  ${BG_BLUE}${BRIGHT_WHITE}${BOLD} INFO ${NC} ${BOLD}$1${NC}\n"
}

print_success() {
  echo -e "\n  ${BG_GREEN}${BRIGHT_WHITE}${BOLD} SUCCESS ${NC} ${BOLD}$1${NC}\n"
}

print_warning() {
  echo -e "\n  ${BG_YELLOW}${BRIGHT_WHITE}${BOLD} WARNING ${NC} ${BOLD}$1${NC}\n"
}

print_error() {
  echo -e "\n  ${BG_RED}${BRIGHT_WHITE}${BOLD} ERROR ${NC} ${BOLD}$1${NC}\n"
}

print_banner() {
  local title="$1"
  local border_color="${2:-$BLUE}" # Parameter 2: Warna bingkai (default biru)
  local text_style="${3:-$border_color}" # Parameter 3: Style teks tengah (default ikuti bingkai)
  local width=50 # Panjang banner
  local char="=" # Simbol garis

  local border=$(printf '%*s' "$width" "")
  border=${border// /$char}
  local title_len=${#title}
  local pad_len=$(( (width - title_len) / 2 ))
  local pad_left=$(printf '%*s' "$pad_len" "")
  local pad_right=$(printf '%*s' $((width - title_len - pad_len)) "")

  echo -e "\n${BOLD}${border_color}[+] ${border} [+]${NC}"
  echo -e "${BOLD}${border_color}[+]${NC} ${text_style}${pad_left}${title}${pad_right}${NC} ${BOLD}${border_color}[+]${NC}"
  echo -e "${BOLD}${border_color}[+] ${border} [+]\n${NC}"
}

safe_apt_update() {
    local UPDATE_LOG=$(apt-get update --allow-releaseinfo-change -y 2>&1)
    if echo "$UPDATE_LOG" | grep -q "NO_PUBKEY"; then
        print_warning "Terdeteksi GPG Key yang hilang! Mencoba memperbaiki otomatis..."
        echo "$UPDATE_LOG" | grep -o 'NO_PUBKEY [0-9A-F]*' | awk '{print $2}' | sort -u | xargs -r -I {} apt-key adv --keyserver keyserver.ubuntu.com --recv-keys {} >/dev/null 2>&1
        apt-get update --allow-releaseinfo-change -y || true
        print_success "GPG Key berhasil dipulihkan."
    fi
}

start_script() {
  clear
  echo -e ""
  echo -e "${BOLD}${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BOLD}${BLUE}[+]                                                 [+]${NC}"
  echo -e "${BOLD}${BLUE}[+]                 AUTO INSTALLER THEME             [+]${NC}"
  echo -e "${BOLD}${BLUE}[+]                  © MIRZZXX OFFICIAL                [+]${NC}"
  echo -e "${BOLD}${BLUE}[+]                                                 [+]${NC}"
  echo -e "${BOLD}${BLUE}[+] =============================================== [+]${NC}"
  echo -e ""
  echo -e "Script ini dibuat untuk mempermudah penginstalasian tema pterodactyl."
  echo -e "Mengalami eror? Lapor ke admin agar diperbaiki."
  echo -e ""
  echo -e "𝗧𝗘𝗟𝗘𝗚𝗥𝗔𝗠: @Mirzzxx_stecu"
  sleep 2

  print_info "Menginstall dan mengupdate jq..."

  safe_apt_update
  apt-get install -y jq

  if [ $? -eq 0 ]; then
    print_success "Install jq berhasil."
  else
    print_error "Install jq gagal."
    exit 1
  fi
  echo -e "                                                       "
  sleep 1
  clear
}

check_token() {
  print_banner "MIRZZXX OFFICIAL LICENSE"
  echo -e "${BOLD}${YELLOW}MASUKKAN AKSES TOKEN: ${NC}"
  read -r USER_TOKEN

  if [ "$USER_TOKEN" = "mirzxganteng" ]; then
    echo -e "${BOLD}${GREEN}AKSES BERHASIL${NC}}"
  else
    echo -e "${BOLD}${GREEN}Token yang anda masukkan salah.${NC}"
    exit 1
  fi
  clear
}

install_base_dependencies() {
  local CLI_VER=$1
  local WEB_VER=$2

  apt-get install -y \
    ca-certificates curl gnupg zip unzip git wget redis-server \
    php${CLI_VER}-{common,cli,gd,mbstring,bcmath,xml,curl,zip,intl,sqlite3,mysql,fpm,redis} \
    php${WEB_VER}-{common,cli,gd,mbstring,bcmath,xml,curl,zip,intl,sqlite3,mysql,fpm,redis}
}

setup_nodejs() {
  print_info "Memeriksa versi Node.js..."
  local NODE_VER=$(node -v 2>/dev/null | cut -d'.' -f1 | sed 's/v//')

  if [ "$NODE_VER" == "22" ]; then
    print_success "Node.js v22 sudah terinstall."
  else
    [ -z "$NODE_VER" ] && print_warning "Node.js tidak terdeteksi. Memulai instalasi Node.js v22..." || print_warning "Versi Node.js tidak sesuai (Terdeteksi: v$NODE_VER). Menginstall Node.js v22..."

    unset NVM_DIR
    apt-get remove -y nodejs npm libnode-dev nodejs-doc || true
    apt-get purge -y nodejs npm libnode-dev nodejs-doc || true
    apt-get autoremove -y || true

    rm -f /usr/bin/node /usr/local/bin/node /usr/bin/npm /usr/local/bin/npm
    rm -f /etc/apt/sources.list.d/nodesource*.list
    rm -f /usr/share/keyrings/nodesource*.gpg /etc/apt/keyrings/nodesource*.gpg
    rm -rf "$HOME/.nvm"

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor --yes | tee /etc/apt/keyrings/nodesource.gpg >/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

    safe_apt_update
    apt-get install -y nodejs
  fi

  hash -r
  npm i -g yarn
}

clear_artisan_cache() {
  print_info "Membersihkan cache sistem..."
  for cmd in optimize view config route cache; do php artisan $cmd:clear; done
}

install_theme() {
  # Format: "Nama Tema;URL Tema;Tipe Aksi (normal/timpa)"
  local STANDARD_THEMES=(
    "Stellar;https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/stellar.zip;normal"
    "Billing;https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/billing.zip;normal"
    "Enigma;https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/enigma.zip;normal"
    "Elysium;https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/elysium.zip;normal"
    "Frostcore (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/frostcore.zip;normal"
    "Nightcore (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/nightcore.zip;normal"
    "IceMinecraft (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/iceMinecraft.zip;normal"
    "Noobe (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/noobe.zip;normal"
    "Reviactyl;https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz;timpa"
    "NookTheme;https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz;timpa"
  )

  local BLUEPRINT_THEMES=(
    "Nebula V1.8-3;https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/nebula_v1.8-3.zip;normal"
    "Nebula V2.0-1;https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/nebula_v2.0-1.zip;normal"
    "Recolor (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/recolor.zip;normal"
    "NavySeals;https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/navyseals.zip;normal"
    "LememTheme (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/lemem.zip;normal"
    "Darkenate (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/darkenate.zip;normal"
    "AbyssPurple (Original Style);https://cdn.jsdelivr.net/gh/Bangsano/themeinstaller@main/theme/abysspurple.zip;normal"
  )

  local SELECT_THEME
  local THEME_NAME
  local THEME_URL

  while true; do
    clear
    print_banner "SELECT THEME" "$BLUE" "${BG_BLUE}${BRIGHT_WHITE}${BOLD}"
    echo -e "${BRIGHT_CYAN}${BOLD}--- STANDARD THEME ---${NC}"
    for i in "${!STANDARD_THEMES[@]}"; do
      IFS=';' read -r name url type <<< "${STANDARD_THEMES[$i]}"
      echo -e " ${BRIGHT_WHITE}${BOLD}[$((i+1))]${NC} ${WHITE}$name${NC}"
    done
    echo " "
    echo -e "${BRIGHT_MAGENTA}${BOLD}--- BLUEPRINT THEME ---${NC}"
    echo -e "${BG_RED}${BRIGHT_WHITE} (!) WAJIB INSTALL BLUEPRINT DULU (OPSI #2 DI MENU UTAMA) ${NC}"
    for i in "${!BLUEPRINT_THEMES[@]}"; do
      IFS=';' read -r name url type <<< "${BLUEPRINT_THEMES[$i]}"
      echo -e " ${BRIGHT_WHITE}${BOLD}[b$((i+1))]${NC} ${WHITE}$name${NC}"
    done
    echo " "
    echo -e " ${BRIGHT_WHITE}${BOLD}[x]${NC} ${WHITE}Kembali ke Menu Utama${NC}"
    echo " "
    echo -n -e "${BOLD}Masukkan pilihan (1-${#STANDARD_THEMES[@]}/b1-${#BLUEPRINT_THEMES[@]} atau x)${NC}${BOLD}: ${NC}"
    read SELECT_THEME

    if [[ "$SELECT_THEME" =~ ^[0-9]+$ ]] && [ "$SELECT_THEME" -ge 1 ] && [ "$SELECT_THEME" -le "${#STANDARD_THEMES[@]}" ]; then
      IFS=';' read -r THEME_NAME THEME_URL type <<< "${STANDARD_THEMES[$((SELECT_THEME-1))]}"
      if [ "$type" == "timpa" ]; then
        install_timpa "$THEME_URL" "$THEME_NAME"
        return
      else
        break
      fi
    elif [[ "$SELECT_THEME" =~ ^[bB]([0-9]+)$ ]]; then
      local b_idx="${BASH_REMATCH[1]}"
      if [ "$b_idx" -ge 1 ] && [ "$b_idx" -le "${#BLUEPRINT_THEMES[@]}" ]; then
        IFS=';' read -r THEME_NAME THEME_URL type <<< "${BLUEPRINT_THEMES[$((b_idx-1))]}"
        break
      else
        print_error "Pilihan Blueprint tidak valid. Silakan coba lagi."
      fi
    elif [[ "${SELECT_THEME,,}" == "x" ]]; then
      echo -e "${BOLD}Instalasi dibatalkan.${NC}"
      return
    else
      print_error "Pilihan tidak valid. Silakan coba lagi."
    fi
  done

  echo " "
  echo -n -e "${BOLD}Anda memilih tema '$THEME_NAME'. Lanjutkan? (y/n): ${NC}"
  read confirmation
  if [[ "$confirmation" != [yY] ]]; then echo -e "${BOLD}Instalasi dibatalkan.${NC}"; return; fi

  if [ "$SELECT_THEME" == "3" ]; then # Khusus Enigma
    echo -n -e "${BOLD}Masukkan link kontak admin (diawali https://): ${NC}"; read LINK_ADMIN
    echo -n -e "${BOLD}Masukkan link channel whatsapp/telegram/lainnya (diawali https://): ${NC}"; read LINK_CHANNEL
    echo -n -e "${BOLD}Masukkan link grup whatsapp/telegram/lainnya (diawali https://): ${NC}"; read LINK_GROUP
  fi

  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf -- "$TEMP_DIR"' EXIT
  cd "$TEMP_DIR"

  print_info "Memulai instalasi tema $THEME_NAME..."

  safe_apt_update
  apt-get install -y ca-certificates curl gnupg zip unzip git wget

  print_info "[1/4] Mengunduh file tema..."
  wget -q "$THEME_URL"
  local THEME_ZIP_FILE=$(basename "$THEME_URL")

  print_info "[2/4] Mengekstrak file tema..."
  if [[ "$THEME_ZIP_FILE" == *.tar.gz ]]; then
    tar -xzf "$THEME_ZIP_FILE"
  else
    unzip -oq "$THEME_ZIP_FILE" || true
  fi

  rm -f "$THEME_ZIP_FILE"

  if [[ "$SELECT_THEME" == [bB]* ]]; then
    # --- JALUR BLUEPRINT ---
    print_info "[3/4] Menyiapkan Blueprint..."

    if ! command -v blueprint >/dev/null 2>&1 && [ ! -f "/var/www/pterodactyl/blueprint.sh" ] && [ ! -f "/var/www/pterodactyl/blueprint/blueprint.sh" ]; then
      print_error "Blueprint belum terinstall."
      return 1
    fi

    FOUND_FILE=$(find . -maxdepth 1 -name "*.blueprint" -print -quit)

    if [ -z "$FOUND_FILE" ]; then
        print_error "File .blueprint tidak ditemukan dalam zip!"
        return 1
    fi

    BLUEPRINT_FILENAME=$(basename "$FOUND_FILE")
    IDENTIFIER="${BLUEPRINT_FILENAME%.*}"
    mv "$BLUEPRINT_FILENAME" /var/www/pterodactyl/

    print_info "[4/4] Menginstall via Blueprint..."
    cd /var/www/pterodactyl

    if command -v blueprint >/dev/null 2>&1; then
      blueprint -i "$IDENTIFIER" || blueprint install "$IDENTIFIER" || bash blueprint.sh -install "$IDENTIFIER" || true
    elif [ -f "blueprint.sh" ]; then
      bash blueprint.sh -i "$IDENTIFIER" || true
    elif [ -f "blueprint/blueprint.sh" ]; then
      bash blueprint/blueprint.sh -i "$IDENTIFIER" || true
    fi

    rm -f "/var/www/pterodactyl/$BLUEPRINT_FILENAME"

    print_success "Tema '$THEME_NAME' berhasil diinstall."
  else
    # --- JALUR MANUAL ---
    if [ "$SELECT_THEME" == "3" ]; then
      print_info "Mengkonfigurasi variabel Enigma..."
      sed -i "s|LINK_ADMIN|$LINK_ADMIN|g" pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
      sed -i "s|LINK_CHANNEL|$LINK_CHANNEL|g" pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
      sed -i "s|LINK_GROUP|$LINK_GROUP|g" pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    fi

    print_info "[3/4] Menyalin file..."
    cp -rfT pterodactyl /var/www/pterodactyl
    cd /var/www/pterodactyl

    setup_nodejs

    print_info "Mengaktifkan Corepack untuk kompatibilitas Yarn..."
    export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
    corepack enable || true

    print_info "Mengatur toleransi jaringan Yarn..."
    yarn config set network-timeout 300000 -g

    print_info "Menginstal dependensi build..."
    MISSING_PKGS=""
    for pkg in cross-env react-feather; do
      jq -e ".dependencies[\"$pkg\"] or .devDependencies[\"$pkg\"]" package.json > /dev/null || MISSING_PKGS=
