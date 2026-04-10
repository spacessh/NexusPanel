# ⚡ NexusPanel

> Ultimate server management panel — combines Pterodactyl · Pelican · PhysGun · Revictyl

![License](https://img.shields.io/badge/license-MIT-green)
![PHP](https://img.shields.io/badge/PHP-8.2-blue)
![Node](https://img.shields.io/badge/Node-20-green)
![Version](https://img.shields.io/badge/version-1.0.0-brightgreen)

---

## Installation (one command)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/spacessh/NexusPanel/main/install.sh)
```

> Run as root on your server. The installer will ask you a few questions then do everything automatically.

---

## Supported OS

| OS | Version |
|----|---------|
| Ubuntu | 20.04, 22.04, 24.04 |
| Debian | 11, 12 |
| Rocky Linux | 8, 9 |
| AlmaLinux | 8, 9 |
| CentOS Stream | 9 |
| Docker | Any OS |

---

## What the installer does

1. Detects your OS automatically
2. Asks for domain, DB password, admin email/password
3. Installs PHP 8.2, Node 20, Nginx, MariaDB, Redis
4. Clones this repo to `/var/www/nexuspanel`
5. Installs all dependencies and builds the frontend
6. Configures Nginx, systemd services, firewall
7. Optionally sets up SSL via Let's Encrypt
8. Creates your admin account
9. Installs the `nexuspanel` CLI tool

---

## CLI Commands (after install)

```bash
nexuspanel status     # Check all services
nexuspanel update     # Update to latest version
nexuspanel logs       # Follow live logs
nexuspanel backup     # Backup the database
nexuspanel restart    # Restart all services
nexuspanel info       # Show panel info
```

---

## Docker

```bash
git clone https://github.com/spacessh/NexusPanel.git
cd NexusPanel
cp .env.example .env
# Edit .env
docker-compose up -d
docker-compose exec nexuspanel php artisan migrate --force
docker-compose exec nexuspanel php artisan key:generate
```

---

## Features

- **Server Management** — Create, start, stop, restart game servers
- **Real-Time Console** — WebSocket live console with command history
- **File Manager** — Browse, edit, upload files on your servers
- **Monitoring** — Live CPU, RAM, Network charts
- **Backups** — Automated and manual backups
- **Admin Panel** — Full Filament admin dashboard
- **Animated UI** — Dark theme with falling green bands

## Stack

- Backend: Laravel 11 + PHP 8.2
- Frontend: React 19 + TypeScript + Vite
- Database: MariaDB / MySQL
- Cache/Queue: Redis
- WebSockets: Laravel WebSockets
- Admin: Filament v3
