# Deployment Guide - Dealer Partner Application

## Overview

This guide covers deploying the Dealer Partner Flutter Web application with Dart Shelf backend to a VPS server.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Nginx (80)    │────▶│  Dart Backend    │────▶│   SQLite DB     │
│   Flutter Web   │     │  (Shelf API)     │     │   (in-memory)   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## Prerequisites

- VPS with Ubuntu 20.04+ or Debian 11+
- Domain name (optional, for HTTPS)
- Root or sudo access

## Option 1: Docker Deployment (Recommended)

### Step 1: Install Docker

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### Step 2: Upload Project

```bash
# Clone or upload your project
scp -r D:\HACKATON-main\ user@your-vps-ip:/opt/dealer-app
# Or use git
git clone <your-repo-url> /opt/dealer-app
```

### Step 3: Build and Run

```bash
cd /opt/dealer-app

# Build Docker image
docker build -t dealer-partner .

# Run container
docker run -d \
  --name dealer-app \
  -p 80:80 \
  --restart unless-stopped \
  dealer-partner
```

### Step 4: Verify

```bash
# Check container status
docker ps

# View logs
docker logs -f dealer-app

# Test API
curl http://localhost/api/health
```

## Option 2: Manual Deployment

### Step 1: Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Dart SDK
sudo apt install -y apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
sudo apt update
sudo apt install -y dart

# Install Flutter (for web build)
sudo apt install -y curl git unzip xz-utils zip
git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter
export PATH="$PATH:/opt/flutter/bin"

# Install Nginx
sudo apt install -y nginx

# Install SQLite
sudo apt install -y libsqlite3-dev sqlite3
```

### Step 2: Build Flutter Web

```bash
cd /opt/dealer-app/HACKATON
export PATH="$PATH:/opt/flutter/bin"
flutter pub get
flutter build web --release
```

### Step 3: Build Backend

```bash
cd /opt/dealer-app/backend
dart pub get
dart compile exe bin/server.dart -o bin/server
```

### Step 4: Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/dealer-app
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    root /opt/dealer-app/HACKATON/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/dealer-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 5: Create Systemd Service

```bash
sudo nano /etc/systemd/system/dealer-backend.service
```

Add this content:

```ini
[Unit]
Description=Dealer Partner Backend API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/dealer-app/backend
ExecStart=/opt/dealer-app/backend/bin/server --host 127.0.0.1 --port 8080
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable dealer-backend
sudo systemctl start dealer-backend
sudo systemctl status dealer-backend
```

### Step 6: Test

```bash
# Test Flutter Web
curl http://localhost/

# Test Backend API
curl http://localhost/api/health
curl http://localhost/api/employee
```

## Option 3: Docker Compose (Separate Containers)

```bash
cd /opt/dealer-app
docker-compose up -d --build
```

## HTTPS Setup (Optional but Recommended)

### Using Let's Encrypt

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal is configured automatically
# Test renewal
sudo certbot renew --dry-run
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 8080 | Backend API port |
| HOST | 0.0.0.0 | Backend API host |

## Monitoring

### View Logs

```bash
# Backend logs (Docker)
docker logs -f dealer-app

# Backend logs (Systemd)
sudo journalctl -u dealer-backend -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Health Check

```bash
curl http://localhost/api/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2024-03-21T12:00:00.000Z"
}
```

## Backup

### Database Backup

Since SQLite is in-memory, data is reset on restart. For production, modify `database_helper.dart` to use a file:

```dart
final db = sqlite3.open('/app/data/dealer.db');
```

Then backup:

```bash
# Backup database
cp /app/data/dealer.db /backup/dealer-$(date +%Y%m%d).db

# Backup entire app
tar -czf /backup/dealer-app-$(date +%Y%m%d).tar.gz /opt/dealer-app
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 8080
sudo lsof -i :8080

# Kill process
sudo kill -9 <PID>
```

### Permission Issues

```bash
# Fix ownership
sudo chown -R www-data:www-data /opt/dealer-app

# Fix permissions
sudo chmod -R 755 /opt/dealer-app
```

### Service Won't Start

```bash
# Check logs
sudo journalctl -u dealer-backend -n 50

# Test binary manually
/opt/dealer-app/backend/bin/server --help
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/health | Health check |
| POST | /api/auth/login | Login with Sber ID |
| POST | /api/auth/logout | Logout |
| GET | /api/employee | Get employee profile |
| GET | /api/deals | List deals |
| POST | /api/deals | Create deal |
| GET | /api/daily/today | Get today's results |
| POST | /api/daily | Submit daily results |
| GET | /api/achievements | List achievements |
| GET | /api/notifications | List notifications |
| GET | /api/products | List products |
| GET | /api/chat | Get chat history |
| POST | /api/chat | Send message |
| GET | /api/rating | Get rating details |

## Security Recommendations

1. **Enable HTTPS** - Use Let's Encrypt for free SSL certificates
2. **Firewall** - Only allow ports 80, 443, and SSH
3. **Regular Updates** - Keep system packages updated
4. **Backup** - Regular automated backups
5. **Monitoring** - Set up monitoring and alerts

## Performance Tuning

### Nginx Optimization

```nginx
# Add to nginx config
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
gzip_min_length 1000;

# Cache static assets
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Backend Optimization

For high load, consider:
- Using PostgreSQL instead of SQLite
- Adding Redis for caching
- Horizontal scaling with load balancer

## Support

For issues or questions:
1. Check logs first
2. Review API documentation
3. Contact technical support
