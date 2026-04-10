#!/usr/bin/env bash
# =============================================================================
#  NexusPanel Installer — v1.0.0
#  Usage: bash <(curl -fsSL https://raw.githubusercontent.com/spacessh/NexusPanel/main/install.sh)
#
#  Supports: Ubuntu 20/22/24 · Debian 11/12 · Rocky Linux 8/9
#            AlmaLinux 8/9 · CentOS Stream 9
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

# ── Colors ────────────────────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m'
B='\033[0;34m' M='\033[0;35m' W='\033[1;37m' DIM='\033[2m' NC='\033[0m'
BOLD='\033[1m'

# ── Config ────────────────────────────────────────────────────────────────────
NEXUS_VERSION="1.0.0"
NEXUS_REPO="https://github.com/spacessh/NexusPanel"
NEXUS_RAW="https://raw.githubusercontent.com/spacessh/NexusPanel/main"
INSTALL_DIR="/var/www/nexuspanel"
PANEL_USER="nexuspanel"
LOG_FILE="/tmp/nexuspanel-install.log"
CREDS_FILE="/root/.nexuspanel_credentials"

# ── Helpers ───────────────────────────────────────────────────────────────────
log()     { echo -e "${G}  ✓${NC}  $1" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${Y}  ⚠${NC}  $1" | tee -a "$LOG_FILE"; }
error()   { echo -e "${R}  ✗${NC}  $1" | tee -a "$LOG_FILE"; exit 1; }
info()    { echo -e "${C}  →${NC}  $1" | tee -a "$LOG_FILE"; }
step()    { echo -e "\n${BOLD}${C}  ┌─ $1${NC}" | tee -a "$LOG_FILE"; }
run()     { "$@" >> "$LOG_FILE" 2>&1 || error "Command failed: $*"; }
run_q()   { "$@" >> "$LOG_FILE" 2>&1; }

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
        ubuntu|debian)
            PKG="apt"
            PHP_INSTALL="apt"
            ;;
        rocky|almalinux|centos)
            PKG="dnf"
            PHP_INSTALL="remi"
            ;;
        *)
            error "Unsupported OS: $OS $VERSION_ID\nSupported: Ubuntu 20/22/24, Debian 11/12, Rocky/Alma/CentOS 8/9"
            ;;
    esac
    log "OS: ${BOLD}$PRETTY_NAME${NC}"
}

check_root() {
    [ "$EUID" -eq 0 ] || error "Run as root:  sudo bash install.sh"
}

check_requirements() {
    step "Checking requirements"
    local ram_mb
    ram_mb=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
    local disk_gb
    disk_gb=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')

    [ "$ram_mb" -ge 512 ]  || warn "Low RAM: ${ram_mb}MB (512MB minimum recommended)"
    [ "$disk_gb" -ge 5 ]   || warn "Low disk: ${disk_gb}GB (5GB minimum recommended)"

    log "RAM: ${ram_mb}MB  |  Disk free: ${disk_gb}GB"
}

# ── Interactive Config ─────────────────────────────────────────────────────────
collect_config() {
    echo ""
    echo -e "  ${BOLD}${W}Configuration${NC}"
    echo -e "  ${DIM}Press Enter to use defaults${NC}"
    echo ""

    # Domain
    read -rp "  $(echo -e "${C}Domain / IP${NC} [$(hostname -I | awk '{print $1}')]: ")" NEXUS_DOMAIN
    NEXUS_DOMAIN="${NEXUS_DOMAIN:-$(hostname -I | awk '{print $1}')}"

    # DB password
    DB_PASS_DEFAULT=$(openssl rand -base64 18 | tr -d '=/+' | head -c 16)
    read -rp "  $(echo -e "${C}Database password${NC} [${DB_PASS_DEFAULT}]: ")" DB_PASS
    DB_PASS="${DB_PASS:-$DB_PASS_DEFAULT}"

    # Admin email
    read -rp "  $(echo -e "${C}Admin email${NC} [admin@nexuspanel.io]: ")" ADMIN_EMAIL
    ADMIN_EMAIL="${ADMIN_EMAIL:-admin@nexuspanel.io}"

    # Admin password
    ADMIN_PASS_DEFAULT=$(openssl rand -base64 12 | tr -d '=/+' | head -c 12)
    read -rp "  $(echo -e "${C}Admin password${NC} [${ADMIN_PASS_DEFAULT}]: ")" ADMIN_PASS
    ADMIN_PASS="${ADMIN_PASS:-$ADMIN_PASS_DEFAULT}"

    # SSL
    echo ""
    read -rp "  $(echo -e "${C}Setup SSL with Let's Encrypt?${NC} [y/N]: ")" SETUP_SSL
    SETUP_SSL="${SETUP_SSL:-n}"

    echo ""
    echo -e "  ${DIM}──────────────────────────────────────${NC}"
    echo -e "  Domain:   ${W}${NEXUS_DOMAIN}${NC}"
    echo -e "  DB Pass:  ${W}${DB_PASS}${NC}"
    echo -e "  Admin:    ${W}${ADMIN_EMAIL}${NC}"
    echo -e "  SSL:      ${W}${SETUP_SSL}${NC}"
    echo -e "  ${DIM}──────────────────────────────────────${NC}"
    echo ""
    read -rp "  $(echo -e "${Y}Proceed with installation?${NC} [Y/n]: ")" CONFIRM
    [[ "${CONFIRM:-y}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
}

# ── Package Installation ───────────────────────────────────────────────────────
install_deps_apt() {
    step "Installing system packages"

    (apt-get update -qq) &
    spinner $! "Updating package lists"

    (DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        curl wget git unzip zip tar \
        nginx redis-server \
        mariadb-server mariadb-client \
        software-properties-common apt-transport-https \
        ca-certificates gnupg lsb-release \
        certbot python3-certbot-nginx \
        supervisor) &
    spinner $! "Installing base packages"

    # PHP 8.2
    (add-apt-repository -y ppa:ondrej/php >> "$LOG_FILE" 2>&1
     apt-get update -qq >> "$LOG_FILE" 2>&1
     DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        php8.2-fpm php8.2-cli php8.2-mysql php8.2-mbstring \
        php8.2-xml php8.2-bcmath php8.2-gd php8.2-zip \
        php8.2-redis php8.2-curl php8.2-sockets php8.2-opcache >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing PHP 8.2"

    # Node.js 20
    (curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >> "$LOG_FILE" 2>&1
     apt-get install -y -qq nodejs >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing Node.js 20"
}

install_deps_dnf() {
    step "Installing system packages"

    (dnf install -y epel-release >> "$LOG_FILE" 2>&1) &
    spinner $! "Enabling EPEL"

    (dnf install -y curl wget git unzip zip tar nginx redis mariadb-server \
        certbot python3-certbot-nginx supervisor >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing base packages"

    # PHP 8.2 via Remi
    (dnf install -y "https://rpms.remirepo.net/enterprise/remi-release-${OS_VER}.rpm" >> "$LOG_FILE" 2>&1
     dnf module reset php -y >> "$LOG_FILE" 2>&1
     dnf module enable php:remi-8.2 -y >> "$LOG_FILE" 2>&1
     dnf install -y php php-fpm php-mysqlnd php-mbstring php-xml \
        php-bcmath php-gd php-zip php-redis php-curl php-sockets php-opcache >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing PHP 8.2 (Remi)"

    (curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - >> "$LOG_FILE" 2>&1
     dnf install -y nodejs >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing Node.js 20"
}

install_composer() {
    step "Installing Composer"
    (curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer >> "$LOG_FILE" 2>&1) &
    spinner $! "Downloading Composer"
    log "Composer $(composer --version 2>/dev/null | awk '{print $3}')"
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

    log "Database ${BOLD}nexuspanel${NC} created"
}

# ── Panel Install ─────────────────────────────────────────────────────────────
install_panel() {
    step "Downloading NexusPanel"

    id -u "$PANEL_USER" &>/dev/null || useradd -r -s /bin/false -d "$INSTALL_DIR" "$PANEL_USER"
    mkdir -p "$INSTALL_DIR"

    if [ -d "$INSTALL_DIR/.git" ]; then
        warn "Existing installation found — updating"
        (git -C "$INSTALL_DIR" pull origin main >> "$LOG_FILE" 2>&1) &
        spinner $! "Pulling latest changes"
    else
        (git clone --depth=1 "$NEXUS_REPO" "$INSTALL_DIR" >> "$LOG_FILE" 2>&1) &
        spinner $! "Cloning repository"
    fi

    cd "$INSTALL_DIR"

    step "Installing dependencies"

    (composer install --no-dev --optimize-autoloader --no-interaction >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing PHP dependencies"

    (npm ci >> "$LOG_FILE" 2>&1) &
    spinner $! "Installing Node dependencies"

    (npm run build >> "$LOG_FILE" 2>&1) &
    spinner $! "Building frontend assets"

    step "Configuring application"

    cp .env.example .env

    # Write config
    sed -i "s|APP_URL=.*|APP_URL=http://${NEXUS_DOMAIN}|"     .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|"          .env
    sed -i "s|DB_HOST=.*|DB_HOST=127.0.0.1|"                   .env
    sed -i "s|APP_ENV=.*|APP_ENV=production|"                  .env
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|"                   .env

    php artisan key:generate --force >> "$LOG_FILE" 2>&1
    log "App key generated"

    (php artisan migrate --force >> "$LOG_FILE" 2>&1) &
    spinner $! "Running database migrations"

    run_q php artisan storage:link

    # Permissions
    chown -R "$PANEL_USER":"$PANEL_USER" "$INSTALL_DIR"
    chmod -R 755 "$INSTALL_DIR/storage"
    chmod -R 755 "$INSTALL_DIR/bootstrap/cache" 2>/dev/null || true

    log "Panel installed to ${BOLD}${INSTALL_DIR}${NC}"
}

# ── Nginx ─────────────────────────────────────────────────────────────────────
setup_nginx() {
    step "Configuring Nginx"

    local PHP_SOCK
    PHP_SOCK=$(find /var/run/php/ -name "php8.2-fpm.sock" 2>/dev/null | head -1 || echo "127.0.0.1:9000")

    cat > /etc/nginx/sites-available/nexuspanel <<NGINX
server {
    listen 80;
    server_name ${NEXUS_DOMAIN};
    root ${INSTALL_DIR}/public;
    index index.php;

    client_max_body_size 100M;
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:${PHP_SOCK};
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location ~ /\.(?!well-known).* { deny all; }
}
NGINX

    # Enable site
    mkdir -p /etc/nginx/sites-enabled
    ln -sf /etc/nginx/sites-available/nexuspanel /etc/nginx/sites-enabled/nexuspanel
    rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true

    # Rocky/Alma: use conf.d instead
    if [ "$PKG" = "dnf" ]; then
        cp /etc/nginx/sites-available/nexuspanel /etc/nginx/conf.d/nexuspanel.conf
    fi

    nginx -t >> "$LOG_FILE" 2>&1 || error "Nginx config test failed — check $LOG_FILE"
    systemctl restart nginx && systemctl enable nginx >> "$LOG_FILE" 2>&1
    log "Nginx configured for ${BOLD}${NEXUS_DOMAIN}${NC}"
}

# ── SSL ───────────────────────────────────────────────────────────────────────
setup_ssl() {
    [[ "${SETUP_SSL:-n}" =~ ^[Yy]$ ]] || return 0
    step "Setting up SSL (Let's Encrypt)"

    # Domain must resolve to this server
    certbot --nginx -d "$NEXUS_DOMAIN" --non-interactive --agree-tos \
        -m "$ADMIN_EMAIL" --redirect >> "$LOG_FILE" 2>&1 \
        && log "SSL certificate installed" \
        || warn "SSL setup failed — run manually: certbot --nginx -d ${NEXUS_DOMAIN}"
}

# ── Systemd Services ──────────────────────────────────────────────────────────
setup_services() {
    step "Setting up services"

    # Redis
    systemctl enable --now redis-server 2>/dev/null || systemctl enable --now redis >> "$LOG_FILE" 2>&1
    log "Redis started"

    # PHP-FPM
    systemctl enable --now php8.2-fpm 2>/dev/null || systemctl enable --now php-fpm >> "$LOG_FILE" 2>&1
    log "PHP-FPM started"

    # Queue worker
    cat > /etc/systemd/system/nexuspanel-queue.service <<SVC
[Unit]
Description=NexusPanel Queue Worker
After=network.target mariadb.service redis.service

[Service]
User=${PANEL_USER}
Group=${PANEL_USER}
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SVC

    # WebSocket server
    cat > /etc/systemd/system/nexuspanel-ws.service <<SVC
[Unit]
Description=NexusPanel WebSocket Server
After=network.target

[Service]
User=${PANEL_USER}
Group=${PANEL_USER}
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/php artisan websockets:serve --port=6001
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    systemctl enable --now nexuspanel-queue nexuspanel-ws >> "$LOG_FILE" 2>&1
    log "Queue worker & WebSocket server started"
}

# ── Admin Account ─────────────────────────────────────────────────────────────
create_admin() {
    step "Creating admin account"
    cd "$INSTALL_DIR"

    php artisan tinker --no-interaction <<PHP >> "$LOG_FILE" 2>&1
\$user = \App\Models\User::updateOrCreate(
    ['email' => '${ADMIN_EMAIL}'],
    [
        'name'     => 'Admin',
        'password' => bcrypt('${ADMIN_PASS}'),
    ]
);
\$user->assignRole('admin');
echo "Admin created: " . \$user->email;
PHP

    log "Admin account: ${BOLD}${ADMIN_EMAIL}${NC}"
}

# ── Save Credentials ──────────────────────────────────────────────────────────
save_credentials() {
    cat > "$CREDS_FILE" <<CREDS
# NexusPanel Credentials — $(date)
# Keep this file secure!

PANEL_URL=http://${NEXUS_DOMAIN}
ADMIN_EMAIL=${ADMIN_EMAIL}
ADMIN_PASSWORD=${ADMIN_PASS}
DB_NAME=nexuspanel
DB_USER=nexuspanel
DB_PASSWORD=${DB_PASS}
INSTALL_DIR=${INSTALL_DIR}
CREDS
    chmod 600 "$CREDS_FILE"
}

# ── Summary ───────────────────────────────────────────────────────────────────
print_summary() {
    local url="http://${NEXUS_DOMAIN}"
    [[ "${SETUP_SSL:-n}" =~ ^[Yy]$ ]] && url="https://${NEXUS_DOMAIN}"

    echo ""
    echo -e "${G}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║                                                  ║"
    echo "  ║   NexusPanel installed successfully!  ⚡         ║"
    echo "  ║                                                  ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${C}Panel URL:${NC}      ${BOLD}${url}${NC}"
    echo -e "  ${C}Admin email:${NC}    ${BOLD}${ADMIN_EMAIL}${NC}"
    echo -e "  ${C}Admin password:${NC} ${BOLD}${ADMIN_PASS}${NC}"
    echo -e "  ${C}Install dir:${NC}    ${INSTALL_DIR}"
    echo -e "  ${C}Credentials:${NC}    ${CREDS_FILE}"
    echo -e "  ${C}Install log:${NC}    ${LOG_FILE}"
    echo ""
    echo -e "  ${Y}Useful commands:${NC}"
    echo -e "  ${DIM}nexuspanel update${NC}          — Update to latest version"
    echo -e "  ${DIM}nexuspanel status${NC}          — Check services status"
    echo -e "  ${DIM}nexuspanel logs${NC}            — View application logs"
    echo -e "  ${DIM}nexuspanel backup${NC}          — Backup database"
    echo -e "  ${DIM}systemctl status nexuspanel-queue${NC}"
    echo -e "  ${DIM}systemctl status nexuspanel-ws${NC}"
    echo ""
}

# ── CLI Tool ──────────────────────────────────────────────────────────────────
install_cli() {
    cat > /usr/local/bin/nexuspanel <<'CLI'
#!/usr/bin/env bash
INSTALL_DIR="/var/www/nexuspanel"
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' NC='\033[0m' BOLD='\033[1m'

case "${1:-help}" in
    update)
        echo -e "${C}Updating NexusPanel...${NC}"
        cd "$INSTALL_DIR"
        git pull origin main
        composer install --no-dev --optimize-autoloader --no-interaction
        npm ci && npm run build
        php artisan migrate --force
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
        systemctl restart nexuspanel-queue nexuspanel-ws
        echo -e "${G}✓ Updated successfully${NC}"
        ;;
    status)
        echo -e "${BOLD}NexusPanel Services${NC}"
        for svc in nginx php8.2-fpm redis nexuspanel-queue nexuspanel-ws; do
            status=$(systemctl is-active "$svc" 2>/dev/null || echo "not-found")
            [ "$status" = "active" ] \
                && echo -e "  ${G}●${NC} $svc" \
                || echo -e "  ${R}●${NC} $svc (${status})"
        done
        ;;
    logs)
        journalctl -u nexuspanel-queue -u nexuspanel-ws -f --no-pager
        ;;
    backup)
        TS=$(date +%Y%m%d_%H%M%S)
        FILE="/root/nexuspanel_backup_${TS}.sql.gz"
        source "$INSTALL_DIR/.env"
        mysqldump -u nexuspanel -p"$DB_PASSWORD" nexuspanel | gzip > "$FILE"
        echo -e "${G}✓ Backup saved: ${FILE}${NC}"
        ;;
    restart)
        systemctl restart nexuspanel-queue nexuspanel-ws nginx php8.2-fpm
        echo -e "${G}✓ Services restarted${NC}"
        ;;
    info)
        source "$INSTALL_DIR/.env"
        echo -e "${BOLD}NexusPanel v$(cat $INSTALL_DIR/package.json | grep '"version"' | head -1 | awk -F'"' '{print $4}')${NC}"
        echo -e "  URL:  ${APP_URL}"
        echo -e "  Dir:  ${INSTALL_DIR}"
        echo -e "  PHP:  $(php -r 'echo PHP_VERSION;')"
        echo -e "  Node: $(node -v)"
        ;;
    help|*)
        echo -e "${BOLD}nexuspanel${NC} — NexusPanel CLI"
        echo ""
        echo "  ${C}nexuspanel update${NC}    Update panel to latest version"
        echo "  ${C}nexuspanel status${NC}    Show services status"
        echo "  ${C}nexuspanel logs${NC}      Follow live logs"
        echo "  ${C}nexuspanel backup${NC}    Backup database"
        echo "  ${C}nexuspanel restart${NC}   Restart all services"
        echo "  ${C}nexuspanel info${NC}      Show panel info"
        ;;
esac
CLI
    chmod +x /usr/local/bin/nexuspanel
    log "CLI tool installed: ${BOLD}nexuspanel${NC}"
}

# ── Firewall ──────────────────────────────────────────────────────────────────
setup_firewall() {
    step "Configuring firewall"
    if command -v ufw &>/dev/null; then
        ufw allow 22/tcp  >> "$LOG_FILE" 2>&1
        ufw allow 80/tcp  >> "$LOG_FILE" 2>&1
        ufw allow 443/tcp >> "$LOG_FILE" 2>&1
        ufw allow 6001/tcp >> "$LOG_FILE" 2>&1
        log "UFW rules added (22, 80, 443, 6001)"
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --add-service=http  >> "$LOG_FILE" 2>&1
        firewall-cmd --permanent --add-service=https >> "$LOG_FILE" 2>&1
        firewall-cmd --permanent --add-port=6001/tcp >> "$LOG_FILE" 2>&1
        firewall-cmd --reload >> "$LOG_FILE" 2>&1
        log "firewalld rules added"
    else
        warn "No firewall detected — open ports 80, 443, 6001 manually"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    : > "$LOG_FILE"
    banner
    check_root
    detect_os
    check_requirements
    collect_config

    case "$PKG" in
        apt) install_deps_apt ;;
        dnf) install_deps_dnf ;;
    esac

    install_composer
    setup_database
    install_panel
    setup_nginx
    setup_ssl
    setup_services
    setup_firewall
    create_admin
    install_cli
    save_credentials
    print_summary
}

main "$@"
