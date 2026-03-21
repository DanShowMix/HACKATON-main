# Quick Start Guide - Хакатон Сбер

## Запуск за 2 минуты

### Вариант 1: Локальная разработка (2 терминала)

**Терминал 1 - Запуск Backend:**
```bash
cd D:\HACKATON-main\backend
dart pub get
dart run bin/server.dart
```

**Терминал 2 - Запуск Flutter Web:**
```bash
cd D:\HACKATON-main\HACKATON
flutter pub get
flutter run -d chrome
```

**Готово!** Приложение откроется в браузере

---

### Вариант 2: Docker (production)

```bash
# 1. Перейти в директорию проекта
cd D:\HACKATON-main

# 2. Запустить Docker
docker-compose up -d --build

# 3. Открыть браузер
http://localhost
```

## Тестирование API

### Проверка здоровья сервера
```bash
curl http://localhost:8080/api/health
```

### Вход в систему (email/пароль)
```bash
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"demo@dealer.ru\",\"password\":\"password123\"}"
```

### Регистрация нового пользователя
```bash
curl -X POST http://localhost:8080/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@test.ru\",\"password\":\"password123\",\"fullName\":\"Иван Тестов\"}"
```

### Получение профиля сотрудника
```bash
curl http://localhost:8080/api/employee
```

### Получение продуктов банка
```bash
curl http://localhost:8080/api/products
```

## Демонстрация функционала

### 1. Вход в приложение
- Откройте приложение (http://localhost:XXXX в режиме разработки)
- Введите email: `demo@dealer.ru`
- Введите пароль: `password123`
- Нажмите **"Войти"**
- Или нажмите **"Нет аккаунта? Зарегистрироваться"** для создания нового

### 2. Главный экран (Dashboard)
- Приветствие сотрудника
- Быстрые метрики (баллы, доля банка, выгода)
- Прогресс до следующего уровня
- Быстрые действия

### 3. Сценарный калькулятор
- Перейдите в "Калькулятор"
- Измените показатели (сделки, объем, доля)
- Увидите прогноз роста дохода

### 4. Результаты дня
- Нажмите "Итоги дня"
- Внесите данные за сегодня
- Сохраните результаты

### 5. Рейтинг
- Откройте экран "Рейтинг"
- Посмотрите детализацию баллов
- Нажмите "Смоделировать рост"

### 6. Продукты
- Перейдите в "Продукты"
- Выберите категорию
- Откройте карточку продукта

### 7. Поддержка
- Откройте чат поддержки
- Отправьте сообщение
- Получите ответ от бота

### 8. Профиль
- Откройте "Профиль"
- Посмотрите информацию о сотруднике
- Нажмите "Выйти" для выхода

## Структура проекта

```
D:\HACKATON-main\
├── HACKATON/           # Flutter Web frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/    # 10 экранов
│   │   ├── services/   # API сервис
│   │   └── models/
│   └── build/web/      # Собранный веб
│
├── backend/            # Dart Shelf backend
│   ├── bin/
│   │   └── server.dart
│   ├── lib/
│   │   ├── handlers/   # API обработчики
│   │   ├── models/
│   │   └── repositories/
│   └── database/       # SQLite
│
├── docker-compose.yml
├── Dockerfile
└── DEPLOYMENT.md
```

## API Endpoints (кратко)

| Endpoint | Описание |
|----------|----------|
| POST /api/auth/login | Вход (email/пароль) |
| POST /api/auth/register | Регистрация |
| GET /api/employee | Профиль |
| GET /api/deals | Сделки |
| POST /api/daily | Результаты дня |
| GET /api/products | Продукты |
| GET /api/achievements | Достижения |
| GET /api/notifications | Уведомления |
| POST /api/chat | Чат поддержки |
| GET /api/rating | Рейтинг |

## Возможные проблемы

### Порт 8080 занят
```bash
# Найти процесс
netstat -ano | findstr :8080

# Убить процесс
taskkill /F /PID <номер>
```

### Ошибка Flutter
```bash
flutter clean
flutter pub get
flutter build web
```

### Ошибка Dart
```bash
cd backend
dart clean
dart pub get
```

## Деплой на VPS

См. подробную инструкцию в [DEPLOYMENT.md](DEPLOYMENT.md)

### Быстрый деплой
```bash
# На VPS сервере
docker-compose up -d --build
```

## Контакты для поддержки

- Техническая документация: DEPLOYMENT.md
- API документация: README.md
- Исходный код: D:\HACKATON-main

---

**Приложение готово к демонстрации!** 🚀
