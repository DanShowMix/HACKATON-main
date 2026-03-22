# Deployment Guide - Dealer Partner Application

## Overview

Полная инструкция по развёртыванию приложения Dealer Partner на VPS с поддержкой HTTPS и APK.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Nginx (80/443)│────▶│  Dart Backend    │────▶│   SQLite DB     │
│   Flutter Web   │     │  (Shelf API)     │     │   (file-based)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │
         └──────────────▶  APK (Android)
```

---

## 📋 Prerequisites

- VPS с Ubuntu 20.04+ или Debian 11+
- Доменное имя (для HTTPS)
- Root или sudo доступ

---

## 🚀 Quick Start (Docker Compose)

### Шаг 1: Установка Docker на VPS

```bash
# Подключись к VPS по SSH
ssh user@your-vps-ip

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Проверка
docker --version
docker-compose --version
```

### Шаг 2: Загрузка проекта на VPS

**Вариант A: Через Git**
```bash
cd /var/www
sudo git clone https://github.com/DanShowMix/HACKATON-main.git dealer-app
sudo chown -R $USER:$USER dealer-app
cd dealer-app
git checkout other_points
```

**Вариант B: Через SCP**
```bash
# Локально (Windows PowerShell)
scp -r D:\HACKATON-main\* user@vps-ip:/var/www/dealer-app
```

### Шаг 3: Сборка Flutter Web

```bash
cd /var/www/dealer-app/HACKATON

# Установка Flutter (если нет локально)
# Лучше собрать локально и загрузить build/web

# Или на VPS:
git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter
export PATH="$PATH:/opt/flutter/bin"

flutter pub get
flutter build web --release
```

### Шаг 4: Настройка Nginx конфигурации

```bash
cd /var/www/dealer-app

# Копирование конфига
cp nginx.conf /var/www/dealer-app/nginx.conf

# Для HTTPS (после получения SSL)
# Раскомментируй HTTPS секцию в nginx.conf
```

### Шаг 5: Запуск через Docker Compose

```bash
cd /var/www/dealer-app

# Сборка и запуск
docker-compose up -d --build

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

### Шаг 6: Проверка работы

```bash
# Health check
curl http://localhost/api/health

# Проверка веб-интерфейса
curl http://localhost/
```

---

## 🔒 HTTPS Setup (Let's Encrypt)

### Шаг 1: Установка Certbot

```bash
sudo apt install -y certbot
```

### Шаг 2: Получение SSL сертификата

```bash
sudo certbot certonly --standalone -d твой-домен.ru -d www.твой-домен.ru
```

### Шаг 3: Настройка SSL в nginx.conf

Открой `nginx.conf` и раскомментируй HTTPS секцию:

```nginx
server {
    listen 443 ssl http2;
    server_name твой-домен.ru;

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    # ... остальная конфигурация
}
```

### Шаг 4: Копирование сертификатов

```bash
sudo mkdir -p /var/www/dealer-app/ssl
sudo cp /etc/letsencrypt/live/твой-домен.ru/fullchain.pem /var/www/dealer-app/ssl/
sudo cp /etc/letsencrypt/live/твой-домен.ru/privkey.pem /var/www/dealer-app/ssl/
sudo cp /etc/letsencrypt/live/твой-домен.ru/chain.pem /var/www/dealer-app/ssl/

# Перезапуск Nginx
docker-compose restart nginx
```

### Шаг 5: Авто-обновление сертификата

```bash
# Добавь в crontab
sudo crontab -e

# Добавь строку:
0 3 1 * * certbot renew --quiet && docker-compose restart nginx
```

---

## 📱 APK Сборка

### Шаг 1: Изменение API URL

В файле `HACKATON/lib/services/api_service.dart`:

```dart
String _baseUrl = kReleaseMode
    ? 'https://твой-домен.ru/api'  // Твой VPS
    : 'http://localhost:8080/api';
```

### Шаг 2: Сборка APK

```bash
cd HACKATON

# Для ARM (большинство телефонов)
flutter build apk --release

# Или универсальный APK
flutter build apk --split-per-abi
```

APK будет в: `build/app/outputs/flutter-apk/app-release.apk`

### Шаг 3: Разрешение HTTP трафика (если нет HTTPS)

В `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

---

## 📊 Monitoring & Logs

### Просмотр логов

```bash
# Все логи
docker-compose logs -f

# Только backend
docker-compose logs -f backend

# Только nginx
docker-compose logs -f nginx
```

### Health Check

```bash
curl https://твой-домен.ru/api/health
```

Ожидаемый ответ:
```json
{
  "status": "ok",
  "timestamp": "2024-03-21T12:00:00.000Z"
}
```

---

## 🗄️ Database

База данных SQLite хранится в `backend/dealer.db` и сохраняется через volume.

### Backup базы данных

```bash
# Создать backup
cp /var/www/dealer-app/backend/dealer.db /backup/dealer-$(date +%Y%m%d).db

# Автоматизация (cron)
0 2 * * * cp /var/www/dealer-app/backend/dealer.db /backup/dealer-$(date +\%Y\%m\%d).db
```

---

## 🔧 Troubleshooting

### Порт уже занят

```bash
# Найти процесс
sudo lsof -i :80

# Остановить контейнеры
docker-compose down

# Запустить заново
docker-compose up -d
```

### Ошибки сборки Flutter

```bash
cd HACKATON
flutter clean
flutter pub get
flutter build web
```

### Backend не запускается

```bash
# Проверь логи
docker-compose logs backend

# Пересобери
docker-compose build backend
docker-compose up -d backend
```

### Нет доступа к API из APK

1. Проверь что URL в `api_service.dart` правильный
2. Проверь firewall на VPS:
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   ```
3. Проверь что HTTPS работает:
   ```bash
   curl https://твой-домен.ru/api/health
   ```

---

## 📝 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/health | Проверка здоровья |
| POST | /api/auth/login | Вход |
| POST | /api/auth/register | Регистрация |
| GET | /api/employee | Профиль сотрудника |
| GET | /api/rating | Рейтинг (новая формула) |
| GET | /api/financial-effect | Фин. эффект |
| GET | /api/monthly-tasks | Задачи месяца |
| GET | /api/deals | Сделки |
| POST | /api/deals | Создать сделку |
| GET | /api/daily/today | Итоги дня |
| POST | /api/daily | Внести итоги дня |
| GET | /api/achievements | Достижения |
| GET | /api/notifications | Уведомления |
| GET | /api/products | Продукты |
| GET | /api/chat | Чат |
| POST | /api/chat | Отправить сообщение |

---

## ✅ Checklist перед запуском

- [ ] Docker установлен
- [ ] Проект загружен на VPS
- [ ] Flutter Web собран (`build/web`)
- [ ] `nginx.conf` настроен
- [ ] Домен указывает на VPS
- [ ] SSL сертификат получен (для HTTPS)
- [ ] APK собран с правильным URL
- [ ] Firewall настроен (80, 443, 22)
- [ ] Логи в порядке

---

## 🆘 Support

При проблемах:
1. Проверь логи: `docker-compose logs -f`
2. Проверь health endpoint: `curl https://твой-домен.ru/api/health`
3. Проверь что все контейнеры запущены: `docker-compose ps`
