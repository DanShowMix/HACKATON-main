# Dealer Partner - Сбер Хакатон

Приложение для сотрудников дилерского центра Сбербанка.

## 📱 Возможности

### Для сотрудников

- **Мониторинг статуса** - отслеживание текущего уровня (Silver/Gold/Black)
- **Сценарный калькулятор** - моделирование роста показателей
- **Личный финансовый эффект** - просмотр выгоды от программы
- **Привилегии уровня** - информация о доступных преимуществах
- **Рейтинг** - позиция в рейтинге среди коллег
- **Результаты дня** - внесение ежедневных показателей
- **Обучение** - прохождение обучающих модулей
- **Профиль** - информация о сотруднике
- **Уведомления** - важные события и изменения
- **Поддержка** - чат со службой поддержки

## 🚀 Быстрый старт

### Локальная разработка (2 терминала)

**Терминал 1 - Backend:**
```bash
cd D:\HACKATON-main\backend
dart pub get
dart run bin/server.dart
```

**Терминал 2 - Flutter Web:**
```bash
cd D:\HACKATON-main\HACKATON
flutter pub get
flutter run -d chrome
```

📖 Подробная инструкция: [LOCAL_RUN.md](LOCAL_RUN.md)

### Запуск через Docker

```bash
# Сборка и запуск
docker build -t dealer-partner .
docker run -d -p 80:80 --name dealer-app dealer-partner

# Или через docker-compose
docker-compose up -d --build
```

## 📁 Структура проекта

```
HACKATON-main/
├── HACKATON/              # Flutter Web приложение
│   ├── lib/
│   │   ├── main.dart      # Точка входа
│   │   ├── models/        # Модели данных
│   │   ├── screens/       # Экраны приложения
│   │   ├── services/      # Сервисы (API, auth)
│   │   └── widgets/       # Виджеты
│   ├── build/web/         # Собранный веб
│   └── pubspec.yaml
│
├── backend/               # Dart Shelf сервер
│   ├── bin/
│   │   └── server.dart    # Точка входа
│   ├── lib/
│   │   ├── server/        # Конфигурация сервера
│   │   ├── handlers/      # API обработчики
│   │   ├── models/        # Модели данных
│   │   ├── repositories/  # Репозитории
│   │   └── database/      # База данных
│   └── pubspec.yaml
│
├── docker-compose.yml     # Docker конфигурация
├── Dockerfile             # Docker образ
├── DEPLOYMENT.md          # Инструкция по деплою
└── start.sh              # Скрипт запуска
```

## 🔌 API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Вход через Sber ID |
| POST | `/api/auth/logout` | Выход |
| GET | `/api/auth/me` | Текущий пользователь |

### Employee

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/employee` | Профиль сотрудника |
| PUT | `/api/employee` | Обновление профиля |

### Deals

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/deals` | Список сделок |
| POST | `/api/deals` | Создать сделку |
| GET | `/api/deals/:id` | Получить сделку |

### Daily Results

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/daily/today` | Результаты за сегодня |
| POST | `/api/daily` | Внести результаты |
| PUT | `/api/daily` | Обновить результаты |

### Achievements

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/achievements` | Список достижений |

### Notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notifications` | Список уведомлений |
| PUT | `/api/notifications/:id/read` | Прочитать уведомление |
| PUT | `/api/notifications/read-all` | Прочитать все |
| DELETE | `/api/notifications/read` | Удалить прочитанные |

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | Список продуктов |
| GET | `/api/products/categories` | Категории продуктов |

### Chat

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/chat` | История чата |
| POST | `/api/chat` | Отправить сообщение |

### Rating

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/rating` | Детализация рейтинга |

### System

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Проверка здоровья |

## 📊 Модель данных

### Employee (Сотрудник)

```json
{
  "id": "emp-001",
  "fullName": "Иванов Иван Иванович",
  "dealerCode": "DC-123",
  "position": "Менеджер по продажам",
  "level": "Silver",
  "currentPoints": 62,
  "nextLevelPoints": 100,
  "dealsCount": 15,
  "volume": 27.5,
  "bankShare": 35,
  "annualBenefit": 312400
}
```

### Deal (Сделка)

```json
{
  "id": "deal-001",
  "employeeId": "emp-001",
  "clientName": "Иванов Пётр",
  "productType": "Автокредит",
  "amount": 1200000,
  "status": "approved"
}
```

## 🎨 Экраны приложения

1. **Dashboard** - Главная страница с метриками
2. **Status** - Текущий статус и прогресс
3. **Calculator** - Сценарный калькулятор
4. **Rating** - Рейтинг и детализация
5. **Daily Results** - Результаты дня
6. **Achievements** - Достижения
7. **Products** - Продукты банка
8. **Support** - Чат поддержки
9. **Profile** - Профиль сотрудника
10. **Notifications** - Уведомления

## 🔐 Аутентификация

Приложение использует mock-аутентификацию через Sber ID. В production необходимо интегрировать OAuth 2.0 поток Сбера.

### Mock вход

```json
POST /api/auth/login
{
  "sberId": "employee-code"
}
```

## 📈 Система баллов

Рейтинг рассчитывается по формуле:

```
Баллы = (Сделки × 2) + (Объём в млн) + (Доля банка / 5) + (Доп. продукты)
```

### Уровни

| Уровень | Баллы | Привилегии |
|---------|-------|------------|
| Silver | 0-99 | Базовые |
| Gold | 100-199 | Повышенные |
| Black | 200+ | Максимальные |

## 🛠 Технологии

### Frontend
- Flutter 3.11+
- Material 3 Design
- HTTP client
- Shared Preferences

### Backend
- Dart 3.11+
- Shelf (HTTP сервер)
- Shelf Router (маршрутизация)
- SQLite (база данных)
- UUID (генерация ID)

### DevOps
- Docker
- Docker Compose
- Nginx (reverse proxy)

## 📝 Деплой

Подробная инструкция по развертыванию на VPS доступна в [DEPLOYMENT.md](DEPLOYMENT.md).

### Команды для деплоя

```bash
# Docker (рекомендуется)
docker-compose up -d --build

# Manual
./start.sh prod

# Development
./start.sh dev
```

## 🧪 Тестирование

```bash
# Тестирование API
curl http://localhost:8080/api/health
curl http://localhost:8080/api/employee
curl http://localhost:8080/api/products

# Тестирование Flutter Web
# Открыть http://localhost:8080 в браузере
```

## 📋 Чеклист перед запуском

- [ ] Flutter Web собран (`flutter build web`)
- [ ] Backend собран (`dart compile exe`)
- [ ] Порты 80 и 8080 свободны
- [ ] Docker запущен (если используется)
- [ ] Переменные окружения настроены

## 🐛 Troubleshooting

### Порт уже занят

```bash
# Windows
netstat -ano | findstr :8080
taskkill /F /PID <PID>

# Linux
lsof -i :8080
kill -9 <PID>
```

### Ошибки сборки Flutter

```bash
flutter clean
flutter pub get
flutter build web
```

### Ошибки компиляции Dart

```bash
cd backend
dart clean
dart pub get
dart run bin/server.dart
```

## 📞 Поддержка

По вопросам интеграции и поддержки обращайтесь:
- Email: hackathon-support@sberbank.ru
- Чат в приложении

## 📄 Лицензия

Проект создан для хакатона Сбербанка. Все права защищены.

---

**Версия:** 1.0.0  
**Дата:** Март 2024  
**Команда:** HACKATON-main
