#!/usr/bin/env bash
# NexusPanel Installer v1.0.0
# Usage: bash install.sh
set -euo pipefail

R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m'
W='\033[1;37m' DIM='\033[2m' NC='\033[0m' BOLD='\033[1m'

NEXUS_VERSION="1.0.0"
NEXUS_REPO="https://github.com/spacessh/NexusPanel"
IS_ROOT=false
[ "$EUID" -eq 0 ] && IS_ROOT=true

if $IS_ROOT; then
    INSTALL_DIR="/var/www/nexuspanel"
    LOG_FILE="/tmp/nexuspanel-install.log"
    CREDS_FILE="/root/.nexuspanel_credentials"
else
    INSTALL_DIR="$HOME/nexuspanel"
    LOG_FILE="$HOME/nexuspanel-install.log"
    CREDS_FILE="$HOME/.nexuspanel_credentials"
fi

log()   { echo -e "${G}  [OK]${NC}  $1" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${Y}  [!!]${NC}  $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${R}  [ERR]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
step()  { echo -e "\n${BOLD}${C}--- $1 ---${NC}" | tee -a "$LOG_FILE"; }
info()  { echo -e "${C}  -->  $1${NC}" | tee -a "$LOG_FILE"; }

banner() {
    clear
    echo -e "${C}"
    echo '  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗'
    echo '  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝'
    echo '  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗'
    echo '  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║'
    echo '  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║'
    echo '  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝'
    echo -e "${NC}"
    echo -e "  ${BOLD}${W}PANEL${NC} ${DIM}v${NEXUS_VERSION}${NC}"
    echo -e "  ${DIM}${NEXUS_REPO}${NC}"
    echo ""
    if $IS_ROOT; then
        echo -e "  ${G}Mode root${NC} — install dans ${INSTALL_DIR}"
    else
        echo -e "  ${Y}Mode utilisateur${NC} — install dans ${BOLD}${INSTALL_DIR}${NC}"
    fi
    echo -e "  ${DIM}Log: ${LOG_FILE}${NC}"
    echo ""
}

detect_os() {
    step "Detecting OS"
    [ -f /etc/os-release ] || error "Cannot detect OS"
    . /etc/os-release
    OS="$ID"
    OS_VER="${VERSION_ID%%.*}"
    case "$OS" in
        ubuntu|debian)          PKG="apt" ;;
        rocky|almalinux|centos) PKG="dnf" ;;
        *)                      PKG="unknown" ;;
    esac
    log "OS: $PRETTY_NAME"
}

check_commands() {
    step "Checking required tools"
    local missing=()
    for cmd in git curl node npm php composer; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        warn "Manquants: ${missing[*]}"
        if ! $IS_ROOT; then
            echo ""
            echo -e "  ${Y}Installe les outils manquants avec sudo, puis relance.${NC}"
            echo -e "  ${DIM}sudo dnf install -y git curl nodejs npm php php-cli composer${NC}"
            echo ""
            read -rp "  Continuer quand même ? [y/N]: " CONT
            [[ "${CONT:-n}" =~ ^[Yy]$ ]] || exit 0
        fi
    else
        log "Tous les outils sont disponibles"
    fi
}

collect_config() {
    echo ""
    echo -e "  ${BOLD}${W}Configuration${NC} ${DIM}(Entrée = valeur par défaut)${NC}"
    echo ""

    read -rp "  Domaine / IP [$(hostname -I | awk '{print $1}')]: " NEXUS_DOMAIN
    NEXUS_DOMAIN="${NEXUS_DOMAIN:-$(hostname -I | awk '{print $1}')}"

    DB_PASS_DEFAULT=$(openssl rand -base64 18 | tr -d '=/+' | head -c 16)
    read -rp "  Mot de passe BDD [${DB_PASS_DEFAULT}]: " DB_PASS
    DB_PASS="${DB_PASS:-$DB_PASS_DEFAULT}"

    read -rp "  Email admin [admin@nexuspanel.io]: " ADMIN_EMAIL
    ADMIN_EMAIL="${ADMIN_EMAIL:-admin@nexuspanel.io}"

    ADMIN_PASS_DEFAULT=$(openssl rand -base64 12 | tr -d '=/+' | head -c 12)
    read -rp "  Mot de passe admin [${ADMIN_PASS_DEFAULT}]: " ADMIN_PASS
    ADMIN_PASS="${ADMIN_PASS:-$ADMIN_PASS_DEFAULT}"

    if $IS_ROOT; then
        read -rp "  SSL Let's Encrypt ? [y/N]: " SETUP_SSL
        SETUP_SSL="${SETUP_SSL:-n}"
    else
        SETUP_SSL="n"
    fi

    echo ""
    echo -e "  ${DIM}Dossier:  ${W}${INSTALL_DIR}${NC}"
    echo -e "  ${DIM}Domaine:  ${W}${NEXUS_DOMAIN}${NC}"
    echo -e "  ${DIM}Admin:    ${W}${ADMIN_EMAIL}${NC}"
    echo ""
    read -rp "  Lancer l'installation ? [Y/n]: " CONFIRM
    [[ "${CONFIRM:-y}" =~ ^[Yy]$ ]] || { echo "Annulé."; exit 0; }
}

find_free_port() {
    local port
    while true; do
        port=$(( RANDOM % 5000 + 4000 ))
        ! ss -tuln 2>/dev/null | grep -q ":${port} " && echo "$port" && return
    done
}

install_panel() {
    step "Downloading NexusPanel"

    if [ -d "$INSTALL_DIR" ]; then
        warn "Suppression du dossier existant..."
        rm -rf "$INSTALL_DIR"
    fi
    mkdir -p "$(dirname "$INSTALL_DIR")"

    info "Clonage du repository..."
    git clone --depth=1 "$NEXUS_REPO" "$INSTALL_DIR" 2>&1 | tee -a "$LOG_FILE"
    log "Repository cloné"

    cd "$INSTALL_DIR"

    step "Installing Node dependencies"
    info "npm ci en cours..."
    npm ci 2>&1 | tee -a "$LOG_FILE"
    log "Node dependencies OK"

    step "Building frontend"
    info "npm run build en cours..."
    npm run build 2>&1 | tee -a "$LOG_FILE"
    log "Frontend built"

    step "Configuring application"
    cp .env.example .env
    sed -i "s|APP_URL=.*|APP_URL=http://${NEXUS_DOMAIN}|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|"     .env
    sed -i "s|DB_HOST=.*|DB_HOST=127.0.0.1|"             .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|"            .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|"             .env

    if command -v php &>/dev/null && [ -f artisan ]; then
        php artisan key:generate --force 2>&1 | tee -a "$LOG_FILE"
        log "App key générée"
    fi

    chmod -R 755 "$INSTALL_DIR/storage" 2>/dev/null || true
    log "Panel installé dans ${INSTALL_DIR}"
}

setup_dev_server() {
    $IS_ROOT && return 0
    step "Setting up dev server"

    VITE_PORT=$(find_free_port)
    PHP_PORT=$(find_free_port)
    while [ "$PHP_PORT" = "$VITE_PORT" ]; do PHP_PORT=$(find_free_port); done

    echo "VITE_PORT=${VITE_PORT}" > "$INSTALL_DIR/.nexuspanel_ports"
    echo "PHP_PORT=${PHP_PORT}"  >> "$INSTALL_DIR/.nexuspanel_ports"
    log "Ports choisis — Frontend: ${VITE_PORT} | Backend: ${PHP_PORT}"

    cat > "$INSTALL_DIR/start.sh" <<START
#!/usr/bin/env bash
cd "\$(dirname "\$0")"
source .nexuspanel_ports 2>/dev/null || { VITE_PORT=4173; PHP_PORT=8000; }
echo ""
echo -e "\033[0;36m  Démarrage de NexusPanel...\033[0m"
echo ""

if command -v php &>/dev/null && [ -f artisan ]; then
    php artisan serve --host=0.0.0.0 --port=\$PHP_PORT &
    echo -e "\033[0;32m  [OK] Backend:  http://0.0.0.0:\$PHP_PORT\033[0m"
fi

npm run dev -- --host 0.0.0.0 --port \$VITE_PORT &
echo -e "\033[0;32m  [OK] Frontend: http://0.0.0.0:\$VITE_PORT\033[0m"
echo ""
echo -e "  \033[1mPanel accessible sur :\033[0m"
echo -e "  \033[0;36mhttp://\$(hostname -I | awk '{print \$1}'):\$VITE_PORT\033[0m"
echo ""
echo "  Ctrl+C pour arrêter"
trap "pkill -f 'artisan serve'; pkill -f 'vite'; exit" INT TERM
wait
START
    chmod +x "$INSTALL_DIR/start.sh"

    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/nexuspanel" <<CLI
#!/usr/bin/env bash
INSTALL_DIR="${INSTALL_DIR}"
source "\$INSTALL_DIR/.nexuspanel_ports" 2>/dev/null || { VITE_PORT=4173; PHP_PORT=8000; }
case "\${1:-help}" in
    start)   bash "\$INSTALL_DIR/start.sh" ;;
    stop)    pkill -f "artisan serve" 2>/dev/null; pkill -f "vite" 2>/dev/null; echo "Stopped." ;;
    update)
        cd "\$INSTALL_DIR"
        git fetch origin main
        git reset --hard origin/main
        npm ci && npm run build
        echo "Updated."
        ;;
    logs)    tail -f "\$INSTALL_DIR/storage/logs/laravel.log" 2>/dev/null || echo "No logs yet." ;;
    info)
        echo "NexusPanel v${NEXUS_VERSION}"
        echo "Dir:      \$INSTALL_DIR"
        echo "Frontend: http://\$(hostname -I | awk '{print \$1}'):\$VITE_PORT"
        echo "Backend:  http://\$(hostname -I | awk '{print \$1}'):\$PHP_PORT"
        ;;
    *)
        echo "nexuspanel start    — Démarrer"
        echo "nexuspanel stop     — Arrêter"
        echo "nexuspanel update   — Mettre à jour"
        echo "nexuspanel logs     — Logs"
        echo "nexuspanel info     — Infos + ports"
        ;;
esac
CLI
    chmod +x "$HOME/.local/bin/nexuspanel"

    if ! grep -q '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    export PATH="$HOME/.local/bin:$PATH"
    log "Commande nexuspanel installée"
}

save_credentials() {
    cat > "$CREDS_FILE" <<CREDS
# NexusPanel — $(date)
PANEL_DIR=${INSTALL_DIR}
ADMIN_EMAIL=${ADMIN_EMAIL}
ADMIN_PASSWORD=${ADMIN_PASS}
DB_PASSWORD=${DB_PASS}
CREDS
    chmod 600 "$CREDS_FILE"
}

print_summary() {
    source "$INSTALL_DIR/.nexuspanel_ports" 2>/dev/null || VITE_PORT="voir nexuspanel info"
    echo ""
    echo -e "${G}${BOLD}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║   NexusPanel installé avec succès ! ⚡   ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${C}Dossier:${NC}     ${INSTALL_DIR}"
    echo -e "  ${C}Credentials:${NC} ${CREDS_FILE}"
    echo ""
    echo -e "  ${Y}Pour démarrer :${NC}"
    echo -e "  ${BOLD}${C}nexuspanel start${NC}"
    echo -e "  ${DIM}ou${NC}  bash ${INSTALL_DIR}/start.sh"
    echo ""
    echo -e "  ${Y}Panel sur :${NC}"
    echo -e "  ${BOLD}http://$(hostname -I | awk '{print $1}'):${VITE_PORT}${NC}"
    echo ""
    echo -e "  ${DIM}Recharge ton shell : source ~/.bashrc${NC}"
    echo ""
}

main() {
    : > "$LOG_FILE"
    banner
    detect_os
    check_commands
    collect_config
    install_panel
    setup_dev_server
    save_credentials
    print_summary
}

main "$@"
