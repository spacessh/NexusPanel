# ⚡ NexusPanel

Ultimate server management panel combining the best of Pterodactyl, Pelican, PhysGun and Revictyl.

## Features

- **Server Management** — Create, start, stop, restart game servers (Pterodactyl-style)
- **File Manager** — Browse, edit, upload files directly (Pelican-style)
- **Real-Time Console** — WebSocket-powered live console with command history
- **Monitoring** — CPU, RAM, Network charts with live updates (PhysGun-style)
- **Backups** — Automated and manual server backups
- **Admin Panel** — Full Filament admin dashboard
- **Animated UI** — Dark theme with falling green bands animation

## Stack

- **Backend**: Laravel 11 + PHP 8.2
- **Frontend**: React 19 + TypeScript + Vite
- **Database**: MariaDB / MySQL
- **Cache/Queue**: Redis
- **WebSockets**: Laravel WebSockets (Pusher protocol)
- **Admin**: Filament v3

## Quick Install (Linux)

```bash
# Ubuntu / Debian / Rocky Linux / AlmaLinux
curl -sSL https://raw.githubusercontent.com/nexuspanel/nexuspanel/main/install.sh | sudo bash
```

## Docker

```bash
cp .env.example .env
# Edit .env with your settings
docker-compose up -d
docker-compose exec nexuspanel php artisan migrate --force
docker-compose exec nexuspanel php artisan key:generate
```

## Manual Install

```bash
composer install
npm install && npm run build
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

## Compatibility

| OS | Version | Status |
|----|---------|--------|
| Ubuntu | 20.04, 22.04, 24.04 | ✅ |
| Debian | 11, 12 | ✅ |
| Rocky Linux | 8, 9 | ✅ |
| AlmaLinux | 8, 9 | ✅ |
| CentOS Stream | 9 | ✅ |
| Windows | WSL2 | ✅ |
| Docker | Any | ✅ |
