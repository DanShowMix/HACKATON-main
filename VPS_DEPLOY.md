# 📱 Полная инструкция по деплою и запуску на VPS

## Шаг 1: Подготовка VPS сервера

### 1.1 Аренда сервера

**Рекомендуемые параметры:**
- **CPU:** 1-2 ядра
- **RAM:** 2-4 GB
- **Disk:** 20-40 GB SSD
- **OS:** Ubuntu 22.04 LTS

**Провайдеры:**
- Timeweb Cloud (Россия)
- Selectel (Россия)
- Reg.ru (Россия)
- DigitalOcean (международный)
- Hetzner (Европа)

**Цена:** ~300-600 руб/месяц

### 1.2 Подключение к серверу

После покупки сервера вы получите:
- **IP адрес:** например, `185.123.45.67`
- **Логин:** `root`
- **Пароль** или SSH ключ

**Подключение через PowerShell (Windows):**
```powershell
ssh root@185.123.45.67
```

Введите пароль (символы не отображаются).

---

## Шаг 2: Установка Docker на сервер

```bash
# Обновление системы
apt update && apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
apt install docker-compose -y

# Проверка установки
docker --version
docker-compose --version
```

---

## Шаг 3: Загрузка проекта на сервер

### Вариант A: Через Git (рекомендуется)

```bash
# На сервере
cd /opt
git clone <ваш-repo-url> dealer-app
cd dealer-app
```

### Вариант B: Через SCP (с вашего компьютера)

```powershell
# На вашем компьютере (Windows PowerShell)
scp -r D:\HACKATON-main root@185.123.45.67:/opt/dealer-app
```

### Вариант C: Через FileZilla

1. Установите [FileZilla](https://filezilla-project.org/)
2. Подключитесь к серверу:
   - Host: `sftp://185.123.45.67`
   - Username: `root`
   - Password: ваш пароль
3. Перетащите папку `HACKATON-main` в `/opt/dealer-app`

---

## Шаг 4: Настройка и запуск приложения

### 4.1 Перейдите в директорию проекта

```bash
cd /opt/dealer-app
```

### 4.2 Запуск через Docker Compose

```bash
# Сборка и запуск
docker-compose up -d --build

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

### 4.3 Проверка работы

Откройте в браузере:
```
http://185.123.45.67:8080
```

Должно открыться ваше приложение!

---

## Шаг 5: Настройка домена и HTTPS (рекомендуется)

### 5.1 Покупка домена (опционально)

Купите домен (например, `dealer-app.ru`) на reg.ru или timeweb.ru.

### 5.2 Настройка DNS

В панели управления доменом создайте A-запись:
- **Type:** A
- **Name:** @
- **Value:** 185.123.45.67
- **TTL:** 3600

Подождите 15-60 минут для применения.

### 5.3 Установка SSL сертификата (бесплатно)

```bash
# Установка Certbot
apt install certbot python3-certbot-nginx -y

# Получение сертификата
certbot --nginx -d dealer-app.ru

# Автоматическое обновление
certbot renew --dry-run
```

Теперь приложение доступно по HTTPS:
```
https://dealer-app.ru
```

---

## Шаг 6: Доступ с мобильного устройства

### 6.1 Подключение через интернет

**Вариант A: По IP адресу**
1. Откройте браузер на телефоне
2. Введите: `http://185.123.45.67:8080`
3. Добавьте на главный экран (Safari: "Поделиться" → "На экран «Домой»")

**Вариант B: По домену**
1. Откройте браузер на телефоне
2. Введите: `https://dealer-app.ru`
3. Добавьте на главный экран

### 6.2 Создание тестового аккаунта

1. Откройте приложение на телефоне
2. Нажмите **"Нет аккаунта? Зарегистрироваться"**
3. Заполните:
   - Email: `your@email.com`
   - Пароль: `password123`
   - ФИО: `Ваше Имя`
4. Нажмите **"Зарегистрироваться"**

### 6.3 Вход с телефона

1. Откройте приложение
2. Введите email и пароль
3. Нажмите **"Войти"**

---

## Шаг 7: Управление приложением

### Просмотр логов

```bash
# Логи приложения
docker-compose logs -f

# Только backend
docker-compose logs -f backend

# Только frontend
docker-compose logs -f frontend
```

### Перезапуск приложения

```bash
# Перезапуск
docker-compose restart

# Полная пересборка
docker-compose down
docker-compose up -d --build
```

### Остановка приложения

```bash
# Остановка
docker-compose down

# Остановка с удалением данных
docker-compose down -v
```

### Обновление приложения

```bash
# Если используете Git
cd /opt/dealer-app
git pull
docker-compose up -d --build

# Если загружаете файлы
# Загрузите новые файлы через SCP/FileZilla
docker-compose up -d --build
```

---

## Шаг 8: База данных

### Расположение базы данных

База данных хранится в Docker volume:
```
/var/lib/docker/volumes/dealer-app_backend-data/_data/dealer.db
```

### Резервное копирование

```bash
# Создание бэкапа
docker cp dealer-app:/app/dealer.db ./backup-$(date +%Y%m%d).db

# Восстановление из бэкапа
docker cp ./backup-20260321.db dealer-app:/app/dealer.db
docker-compose restart
```

### Экспорт данных

```bash
# Копирование базы на ваш компьютер
scp root@185.123.45.67:/opt/dealer-app/backup-*.db ./
```

---

## Шаг 9: Безопасность

### 1. Настройка фаервола

```bash
# Установка UFW
apt install ufw -y

# Разрешение SSH
ufw allow 22/tcp

# Разрешение HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Включение фаервола
ufw enable
ufw status
```

### 2. Смена SSH порта (опционально)

```bash
# Редактирование конфига
nano /etc/ssh/sshd_config

# Изменение порта
Port 2222

# Перезапуск SSH
systemctl restart sshd
```

Теперь подключайтесь: `ssh -p 2222 root@185.123.45.67`

### 3. Регулярные обновления

```bash
# Обновление системы
apt update && apt upgrade -y

# Обновление Docker образов
docker-compose pull
docker-compose up -d
```

---

## 📱 Быстрый старт для работы с телефона

### 1. Запуск на сервере

```bash
cd /opt/dealer-app
docker-compose up -d
```

### 2. Открыть на телефоне

```
http://185.123.45.67:8080
```

### 3. Зарегистрироваться

1. Нажмите **"Нет аккаунта? Зарегистрироваться"**
2. Введите email и пароль
3. Заполните профиль

### 4. Добавить на главный экран

**iPhone (Safari):**
1. Нажмите кнопку "Поделиться" (квадрат со стрелкой)
2. Выберите "На экран «Домой»"
3. Нажмите "Добавить"

**Android (Chrome):**
1. Нажмите меню (три точки)
2. Выберите "Добавить на главный экран"
3. Нажмите "Добавить"

Теперь приложение выглядит как нативное! 📱

---

## 🔧 Решение проблем

### Ошибка: "Port already in use"

```bash
# Проверка занятых портов
netstat -tulpn | grep :8080

# Убить процесс
kill -9 <PID>
```

### Ошибка: "Docker not found"

```bash
# Переустановка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

### Ошибка: "Connection refused"

```bash
# Проверка статуса
docker-compose ps

# Проверка логов
docker-compose logs

# Перезапуск
docker-compose restart
```

### Приложение не открывается с телефона

1. Проверьте, что сервер доступен:
   ```bash
   curl http://localhost:8080/api/health
   ```

2. Проверьте фаервол:
   ```bash
   ufw status
   ```

3. Откройте порт 8080:
   ```bash
   ufw allow 8080/tcp
   ```

---

## 📊 Мониторинг

### Проверка использования ресурсов

```bash
# Использование Docker
docker stats

# Использование диска
df -h

# Использование памяти
free -h
```

### Настройка автозапуска

```bash
# Создание systemd сервиса
nano /etc/systemd/system/dealer-app.service
```

Добавьте:
```ini
[Unit]
Description=Dealer App Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/dealer-app
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down

[Install]
WantedBy=multi-user.target
```

Активируйте:
```bash
systemctl enable dealer-app
systemctl start dealer-app
systemctl status dealer-app
```

Теперь приложение запускается автоматически при перезагрузке сервера! 🎉

---

## 💰 Примерная стоимость

| Компонент | Стоимость |
|-----------|-----------|
| VPS (2 ядра, 4GB) | 400-600 руб/мес |
| Домен (.ru) | 200-500 руб/год |
| SSL сертификат | Бесплатно (Let's Encrypt) |
| **Итого** | **~500-700 руб/мес** |

---

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker-compose logs -f`
2. Проверьте статус: `docker-compose ps`
3. Перезапустите: `docker-compose restart`

Удачи в использовании! 🚀
