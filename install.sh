#!/usr/bin/env bash
# =============================================================================
#  NexusPanel Installer — v1.0.0
#  Usage: curl -fsSL https://raw.githubusercontent.com/spacessh/NexusPanel/main/install.sh -o install.sh && bash install.sh
#
#  Mode user (sans root) : installe dans ~/nexuspanel
#  Mode root             : installe dans /var/www/nexuspanel avec Nginx/systemd
# =============================================================================
set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m'
W='\033[1;37m' DIM='\033[2m' NC='\033[0m' BOLD='\033[1m'

# ── Config ────────────────────────────────────────────────────────────────────
NEXUS_VERSION="1.0.0"
NEXUS_REPO="https://github.com/spacessh/NexusPanel"
IS_ROOT=false
[ "$EUID" -eq 0 ] && IS_ROOT=true

# Dossier d'install selon le mode
if $IS_ROOT; then
    INSTALL_DIR="/var/www/nexuspanel"
    LOG_FILE="/tmp/nexuspanel-install.log"
    CREDS_FILE="/root/.nexuspanel_credentials"
else
    INSTALL_DIR="$HOME/nexuspanel"
    LOG_FILE="$HOME/nexuspanel-install.log"
    CREDS_FILE="$HOME/.nexuspanel_credentials"
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
log()   { echo -e "${G}  ✓${NC}  $1" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${Y}  ⚠${NC}  $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${R}  ✗${NC}  $1" | tee -a "$LOG_FILE"; exit 1; }
step()  { echo -e "\n${BOLD}${C}  ┌─ $1${NC}" | tee -a "$LOG_FILE"; }
run_q() { "$@" >> "$LOG_FILE" 2>&1; }

spinner() {
    local pid=$1 msg=$2
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${C}${frames[$((i % 10))]}${NC}  ${DIM}%s...${NC}" "$msg"
        sleep 0.1; ((i++))
    done
    printf "\r  ${G}✓${NC}  %-40s\n" "$msg"
}

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
    echo -e "  ${BOLD}${W}PANEL${NC} ${DIM}v${NEXUS_VERSION} — Ultimate Server Management${NC}"
    echo -e "  ${DIM}${NEXUS_REPO}${NC}"
    echo ""
    if $IS_ROOT; then
        echo -e "  ${G}Mode: root${NC} — installation complète avec Nginx + systemd"
    else
        echo -e "  ${Y}Mode: utilisateur${NC} — installation dans ${BOLD}${INSTALL_DIR}${NC}"
        echo -e "  ${DIM}(Pour Nginx/systemd, relancer en root)${NC}"
    fi
    echo -e "  ${DIM}Log: ${LOG_FILE}${NC}"
    echo ""
}

# ── OS Detection ──────────────────────────────────────────────────────────────
detect_os() {
    step "Detecting OS"
    [ -f /etc/os-release ] || error "Cannot detect OS"
    . /etc/os-release
    OS="$ID"
    OS_VER="${VERSION_ID%%.*}"

    case "$OS" in
        ubuntu|debian)           PKG="apt" ;;
        rocky|almalinux|centos)  PKG="dnf" ;;
        *)                       PKG="unknown" ;;
    esac
    log "OS: ${BOLD}${PRETTY_NAME}${NC}"
}

# ── Check commands ────────────────────────────────────────────────────────────
check_commands() {
    step "Checking required tools"
    local missing=()
    for cmd in git curl node npm php composer; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    if [ ${#missing[@]} -gt 0 ]; then
        warn "Missing: ${missing[*]}"
        if $IS_ROOT; then
            install_deps
        else
            echo ""
            echo -e "  ${Y}Ces outils sont manquants : ${missing[*]}${NC}"
            echo -e "  Demande à ton admin de les installer, ou relance en sudo :"
            echo -e "  ${C}sudo bash $0${NC}"
            echo ""
            echo -e "  ${DIM}Sur Rocky Linux :${NC}"
            echo -e "  ${DIM}sudo dnf install -y git curl nodejs npm php php-cli php-fpm php-mysqlnd php-mbstring php-xml php-bcmath php-gd php-zip php-redis php-curl php-sockets${NC}"
            echo -e "  ${DIM}curl -sS https://getcomposer.org/installer | php -- --install-dir=~/.local/bin --filename=composer${NC}"
            echo ""
            read -rp "  Continuer quand même ? [y/N]: " CONT
            [[ "${CONT:-n}" =~ ^[Yy]$ ]] || exit 0
        fi
    else
        log "All tools available"
    fi
}

# ── Install deps (root only) ──────────────────────────────────────────────────
install_deps() {
    step "Installing system packages"
    case "$PKG" in
        apt)
            (apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
                curl wget git unzip zip nginx redis-server mariadb-server \
                software-properties-common certbot python3-certbot-nginx) &
            spinner $! "Installing base packages"

            (add-apt-repository -y ppa:ondrej/php >> "$LOG_FILE" 2>&1
             apt-get update -qq >> "$LOG_FILE" 2>&1
             DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
                php8.2-fpm php8.2-cli php8.2-mysql php8.2-mbstring php8.2-xml \
                php8.2-bcmath php8.2-gd php8.2-zip php8.2-redis php8.2-curl \
                php8.2-sockets php8.2-opcache >> "$LOG_FILE" 2>&1) &
            spinner $! "Installing PHP 8.2"

            (curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >> "$LOG_FILE" 2>&1
             apt-get install -y -qq nodejs >> "$LOG_FILE" 2>&1) &
            spinner $! "Installing Node.js 20"
            ;;
        dnf)
            (dnf install -y epel-release >> "$LOG_FILE" 2>&1
             dnf install -y curl wget git unzip zip nginx redis mariadb-server \
                certbot python3-certbot-nginx >> "$LOG_FILE" 2>&1) &
            spinner $! "Installing base packages"

            (dnf install -y "https://rpms.remirepo.net/enterprise/remi-release-${OS_VER}.rpm" >> "$LOG_FILE" 2>&1
             dnf module reset php -y >> "$LOG_FILE" 2>&1
             dnf module enable php:remi-8.2 -y >> "$LOG_FILE" 2>&1
             dnf install -y php php-fpm php-mysqlnd php-mbstring php-xml \
                php-bcmath php-gd php-zip php-redis php-curl php-sockets php-opcache >> "$LOG_FILE" 2>&1) &
            spinner $! "Installing PHP 8.2"

            (curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - >> "$LOG_FILE" 2>&1
             dnf install -y nodejs >> "$LOG_FILE" 2>&1) &
            spinner $! "Installing Node.js 20"
            ;;
    esac

    # Composer
    if ! command -v composer &>/dev/null; then
        (curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer >> "$LOG_FILE" 2>&1) &
        spinner $! "Installing Composer"
    fi
}

# ── Interactive Config ─────────────────────────────────────────────────────────
collect_config() {
    echo ""
    echo -e "  ${BOLD}${W}Configuration${NC}"
    echo -e "  ${DIM}Appuie sur Entrée pour garder la valeur par défaut${NC}"
    echo ""

    read -rp "  $(echo -e "${C}Domaine / IP${NC} [$(hostname -I | awk '{print $1}')]: ")" NEXUS_DOMAIN
    NEXUS_DOMAIN="${NEXUS_DOMAIN:-$(hostname -I | awk '{print $1}')}"

    DB_PASS_DEFAULT=$(openssl rand -base64 18 | tr -d '=/+' | head -c 16)
    read -rp "  $(echo -e "${C}Mot de passe BDD${NC} [${DB_PASS_DEFAULT}]: ")" DB_PASS
    DB_PASS="${DB_PASS:-$DB_PASS_DEFAULT}"

    read -rp "  $(echo -e "${C}Email admin${NC} [admin@nexuspanel.io]: ")" ADMIN_EMAIL
    ADMIN_EMAIL="${ADMIN_EMAIL:-admin@nexuspanel.io}"

    ADMIN_PASS_DEFAULT=$(openssl rand -base64 12 | tr -d '=/+' | head -c 12)
    read -rp "  $(echo -e "${C}Mot de passe admin${NC} [${ADMIN_PASS_DEFAULT}]: ")" ADMIN_PASS
    ADMIN_PASS="${ADMIN_PASS:-$ADMIN_PASS_DEFAULT}"

    if $IS_ROOT; then
        read -rp "  $(echo -e "${C}SSL Let's Encrypt ?${NC} [y/N]: ")" SETUP_SSL
        SETUP_SSL="${SETUP_SSL:-n}"
    else
        SETUP_SSL="n"
    fi

    echo ""
    echo -e "  ${DIM}──────────────────────────────────────${NC}"
    echo -e "  Dossier:  ${W}${INSTALL_DIR}${NC}"
    echo -e "  Domaine:  ${W}${NEXUS_DOMAIN}${NC}"
    echo -e "  DB Pass:  ${W}${DB_PASS}${NC}"
    echo -e "  Admin:    ${W}${ADMIN_EMAIL}${NC}"
    echo -e "  ${DIM}──────────────────────────────────────${NC}"
    echo ""
    read -rp "  $(echo -e "${Y}Lancer l'installation ?${NC} [Y/n]: ")" CONFIRM
    [[ "${CONFIRM:-y}" =~ ^[Yy]$ ]] || { echo "Annulé."; exit 0; }
}

# ── Database ──────────────────────────────────────────────────────────────────
setup_database() {
    step "Setting up MariaDB"
    systemctl start mariadb >> "$LOG_FILE" 2>&1
    systemctl enable mariadb >> "$LOG_FILE" 2>&1

    mysql -u root <<SQL >> "$LOG_FILE" 2>&1
CREATE DATABASE IF NOT EXISTS nexuspanel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'nexuspanel'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
CREATE USER IF NOT EXISTS 'nexuspanel'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON nexuspanel.* TO 'nexuspanel'@'127.0.0.1';
GRANT ALL PRIVILEGES ON nexuspanel.* TO 'nexuspanel'@'localhost';
FLUSH PRIVILEGES;
SQL
    log "Base de données nexuspanel créée"
}

# ── Panel Install ─────────────────────────────────────────────────────────────
install_panel() {
    step "Downloading NexusPanel"
    mkdir -p "$INSTALL_DIR"

    # Toujours repartir propre
    if [ -d "$INSTALL_DIR" ]; then
        warn "Dossier existant supprimé pour installation propre"
        rm -rf "$INSTALL_DIR"
    fi
    mkdir -p "$INSTALL_DIR"

    (git clone --depth=1 "$NEXUS_REPO" "$INSTALL_DIR" >> "$LOG_FILE" 2>&1) &
    spinner $! "Cloning repository"

    cd "$INSTALL_DIR"

    step "Installing dependencies"

    if command -v composer &>/dev/null; then
        (composer install --no-dev --optimize-autoloader --no-interaction >> "$LOG_FILE" 2>&1) &
        spinner $! "PHP dependencies"
    else
        warn "Composer non trouvé — skip PHP deps"
    fi

    (npm ci >> "$LOG_FILE" 2>&1) &
    spinner $! "Node dependencies"

    (npm run build >> "$LOG_FILE" 2>&1) &
    spinner $! "Building frontend"

    step "Configuring application"
    cp .env.example .env

    sed -i "s|APP_URL=.*|APP_URL=http://${NEXUS_DOMAIN}|"  .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|"       .env
    sed -i "s|DB_HOST=.*|DB_HOST=127.0.0.1|"               .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|"              .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|"               .env

    if command -v php &>/dev/null; then
        php artisan key:generate --force >> "$LOG_FILE" 2>&1
        log "App key générée"
        if $IS_ROOT; then
            (php artisan migrate --force >> "$LOG_FILE" 2>&1) &
            spinner $! "Database migrations"
            run_q php artisan storage:link
        fi
    fi

    if $IS_ROOT; then
        chown -R www-data:www-data "$INSTALL_DIR" 2>/dev/null || \
        chown -R nginx:nginx "$INSTALL_DIR" 2>/dev/null || true
    fi

    chmod -R 755 "$INSTALL_DIR/storage" 2>/dev/null || true
    log "Panel installé dans ${BOLD}${INSTALL_DIR}${NC}"
}

# ── Nginx (root only) ─────────────────────────────────────────────────────────
setup_nginx() {
    $IS_ROOT || return 0
    step "Configuring Nginx"

    local PHP_SOCK
    PHP_SOCK=$(find /var/run/php/ -name "php8.2-fpm.sock" 2>/dev/null | head -1 || echo "127.0.0.1:9000")

    cat > /etc/nginx/sites-available/nexuspanel 2>/dev/null || \
    cat > /etc/nginx/conf.d/nexuspanel.conf <<NGINX
server {
    listen 80;
    server_name ${NEXUS_DOMAIN};
    root ${INSTALL_DIR}/public;
    index index.php;
    client_max_body_size 100M;

    location / { try_files \$uri \$uri/ /index.php?\$query_string; }

    location ~ \.php$ {
        fastcgi_pass unix:${PHP_SOCK};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|ico|svg|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

    [ -d /etc/nginx/sites-enabled ] && \
        ln -sf /etc/nginx/sites-available/nexuspanel /etc/nginx/sites-enabled/nexuspanel
    rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true

    nginx -t >> "$LOG_FILE" 2>&1 && systemctl restart nginx && systemctl enable nginx >> "$LOG_FILE" 2>&1
    log "Nginx configuré"
}

# ── Services (root only) ──────────────────────────────────────────────────────
setup_services() {
    $IS_ROOT || return 0
    step "Setting up services"

    systemctl enable --now redis-server 2>/dev/null || systemctl enable --now redis >> "$LOG_FILE" 2>&1
    systemctl enable --now php8.2-fpm 2>/dev/null || systemctl enable --now php-fpm >> "$LOG_FILE" 2>&1

    cat > /etc/systemd/system/nexuspanel-queue.service <<SVC
[Unit]
Description=NexusPanel Queue Worker
After=network.target mariadb.service redis.service

[Service]
User=www-data
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SVC

    cat > /etc/systemd/system/nexuspanel-ws.service <<SVC
[Unit]
Description=NexusPanel WebSocket Server
After=network.target

[Service]
User=www-data
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/php artisan websockets:serve --port=6001
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    systemctl enable --now nexuspanel-queue nexuspanel-ws >> "$LOG_FILE" 2>&1
    log "Services démarrés"
}

# ── Dev server (user mode) ────────────────────────────────────────────────────
setup_dev_server() {
    $IS_ROOT && return 0
    step "Setting up dev server"

    # Trouver un port libre aléatoire entre 4000 et 9000
    find_free_port() {
        local port
        while true; do
            port=$(( RANDOM % 5000 + 4000 ))
            ! ss -tuln 2>/dev/null | grep -q ":${port} " && echo "$port" && return
        done
    }

    VITE_PORT=$(find_free_port)
    PHP_PORT=$(find_free_port)
    # S'assurer que les deux ports sont différents
    while [ "$PHP_PORT" = "$VITE_PORT" ]; do PHP_PORT=$(find_free_port); done

    log "Frontend port: ${BOLD}${VITE_PORT}${NC}"
    log "Backend port:  ${BOLD}${PHP_PORT}${NC}"

    # Sauvegarder les ports dans .nexuspanel_ports
    echo "VITE_PORT=${VITE_PORT}" > "$INSTALL_DIR/.nexuspanel_ports"
    echo "PHP_PORT=${PHP_PORT}"  >> "$INSTALL_DIR/.nexuspanel_ports"

    # Créer un script de démarrage
    cat > "$INSTALL_DIR/start.sh" <<START
#!/usr/bin/env bash
cd "\$(dirname "\$0")"
source .nexuspanel_ports 2>/dev/null || { VITE_PORT=4173; PHP_PORT=8000; }

echo -e "\033[0;36m  → Starting NexusPanel...\033[0m"

if command -v php &>/dev/null; then
    php artisan serve --host=0.0.0.0 --port=\$PHP_PORT &
    PHP_PID=\$!
    echo -e "\033[0;32m  ✓ Backend:  http://0.0.0.0:\$PHP_PORT\033[0m"
fi

npm run dev -- --host 0.0.0.0 --port \$VITE_PORT &
VITE_PID=\$!
echo -e "\033[0;32m  ✓ Frontend: http://0.0.0.0:\$VITE_PORT\033[0m"

echo ""
echo -e "  \033[1mPanel accessible sur :\033[0m"
echo -e "  \033[0;36mhttp://\$(hostname -I | awk '{print \$1}'):\$VITE_PORT\033[0m"
echo ""
echo "  Ctrl+C pour arrêter"
trap "kill \$PHP_PID \$VITE_PID 2>/dev/null; exit" INT TERM
wait
START
    chmod +x "$INSTALL_DIR/start.sh"

    # Commande nexuspanel dans ~/.local/bin
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
        git pull origin main
        npm ci && npm run build
        echo "Updated."
        ;;
    logs)    tail -f "\$INSTALL_DIR/storage/logs/laravel.log" ;;
    info)
        echo "NexusPanel v${NEXUS_VERSION}"
        echo "Dir: \$INSTALL_DIR"
        echo "Frontend: http://\$(hostname -I | awk '{print \$1}'):\$VITE_PORT"
        echo "Backend:  http://\$(hostname -I | awk '{print \$1}'):\$PHP_PORT"
        ;;
    *)
        echo "nexuspanel start    — Démarrer le panel"
        echo "nexuspanel stop     — Arrêter le panel"
        echo "nexuspanel update   — Mettre à jour"
        echo "nexuspanel logs     — Voir les logs"
        echo "nexuspanel info     — Infos + ports"
        ;;
esac
CLI
    chmod +x "$HOME/.local/bin/nexuspanel"

    # Ajouter ~/.local/bin au PATH si pas déjà là
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi

    log "Script de démarrage créé"
}

# ── Save credentials ──────────────────────────────────────────────────────────
save_credentials() {
    cat > "$CREDS_FILE" <<CREDS
# NexusPanel — $(date)
PANEL_DIR=${INSTALL_DIR}
ADMIN_EMAIL=${ADMIN_EMAIL}
ADMIN_PASSWORD=${ADMIN_PASS}
DB_NAME=nexuspanel
DB_USER=nexuspanel
DB_PASSWORD=${DB_PASS}
CREDS
    chmod 600 "$CREDS_FILE"
}

# ── Summary ───────────────────────────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "${G}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║   NexusPanel installé avec succès !  ⚡          ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${C}Dossier:${NC}        ${BOLD}${INSTALL_DIR}${NC}"
    echo -e "  ${C}Credentials:${NC}    ${CREDS_FILE}"
    echo -e "  ${C}Log install:${NC}    ${LOG_FILE}"
    echo ""

    if $IS_ROOT; then
        echo -e "  ${C}Panel URL:${NC}      ${BOLD}http://${NEXUS_DOMAIN}${NC}"
        echo -e "  ${C}Admin:${NC}          ${BOLD}${ADMIN_EMAIL}${NC} / ${ADMIN_PASS}"
        echo ""
        echo -e "  ${Y}Commandes :${NC}"
        echo -e "  ${DIM}nexuspanel status${NC}   — État des services"
        echo -e "  ${DIM}nexuspanel update${NC}   — Mise à jour"
        echo -e "  ${DIM}nexuspanel logs${NC}     — Logs en direct"
    else
        source "$INSTALL_DIR/.nexuspanel_ports" 2>/dev/null || VITE_PORT="voir nexuspanel info"
        echo -e "  ${Y}Pour démarrer le panel :${NC}"
        echo -e "  ${C}nexuspanel start${NC}"
        echo -e "  ${DIM}ou${NC}"
        echo -e "  ${C}bash ${INSTALL_DIR}/start.sh${NC}"
        echo ""
        echo -e "  ${Y}Panel accessible sur :${NC}"
        echo -e "  ${BOLD}http://$(hostname -I | awk '{print $1}'):${VITE_PORT}${NC}"
        echo ""
        echo -e "  ${DIM}Note: recharge ton shell pour avoir la commande nexuspanel :${NC}"
        echo -e "  ${C}source ~/.bashrc${NC}"
    fi
    echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    : > "$LOG_FILE"
    banner
    detect_os
    check_commands
    collect_config

    if $IS_ROOT; then
        setup_database
    fi

    install_panel
    setup_nginx
    setup_services
    setup_dev_server
    save_credentials
    print_summary
}

main "$@"
