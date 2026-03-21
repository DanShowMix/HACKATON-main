# Локальная разработка - Инструкция по запуску

## Быстрый старт

### Шаг 1: Запуск Backend сервера

Откройте **отдельный терминал** и запустите backend:

```bash
cd D:\HACKATON-main\backend
dart pub get
dart run bin/server.dart
```

✅ Backend запущен на `http://localhost:8080`

---

### Шаг 2: Запуск Flutter Web (режим разработки)

Откройте **второй терминал** и запустите Flutter:

```bash
cd D:\HACKATON-main\HACKATON
flutter pub get
flutter run -d chrome
```

✅ Приложение откроется в браузере на `http://localhost:XXXX`

---

## Детальная инструкция

### Требования

- **Flutter SDK 3.11+** - [Скачать](https://docs.flutter.dev/get-started/install)
- **Dart SDK 3.11+** - [Скачать](https://dart.dev/get-dart)
- **Google Chrome** - для запуска веб-приложения

### Проверка установки

```bash
# Проверить Flutter
flutter doctor

# Проверить Dart
dart --version
```

### Запуск Backend (Терминал 1)

```bash
# Перейти в директорию backend
cd D:\HACKATON-main\backend

# Установить зависимости
dart pub get

# Запустить сервер
dart run bin/server.dart
```

**Ожидаемый вывод:**
```
🚀 Starting Dealer Partner Backend Server...
📍 Host: 0.0.0.0
🔌 Port: 8080

🚀 Server started on http://0.0.0.0:8080
📱 Flutter Web: http://localhost:8080
🔌 API: http://localhost:8080/api
```

### Запуск Flutter Web (Терминал 2)

```bash
# Перейти в директорию HACKATON
cd D:\HACKATON-main\HACKATON

# Установить зависимости
flutter pub get

# Запустить в режиме разработки
flutter run -d chrome
```

**Или запустить на конкретном порту:**
```bash
flutter run -d chrome --web-port=3000
```

**Ожидаемый вывод:**
```
Launching lib\main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...
This app is linked to the debug service: ws://localhost:XXXX
Debug service listening on ws://127.0.0.1:XXXX
💪 Running with sound null safety
```

---

## Тестирование приложения

### Демо доступ

Для быстрого тестирования используйте готовый аккаунт:

- **Email:** `demo@dealer.ru`
- **Пароль:** `password123`

### Регистрация нового пользователя

1. Откройте приложение
2. Нажмите **"Нет аккаунта? Зарегистрироваться"**
3. Заполните форму:
   - ФИО: `Иванов Иван`
   - Email: `test@test.ru`
   - Пароль: `password123`
   - Код дилера: `DC-TEST` (необязательно)
   - Должность: `Менеджер` (необязательно)
4. Нажмите **"Зарегистрироваться"**

---

## Проверка API

### Health check
```bash
curl http://localhost:8080/api/health
```

### Логин
```bash
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"demo@dealer.ru\",\"password\":\"password123\"}"
```

### Регистрация
```bash
curl -X POST http://localhost:8080/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"new@test.ru\",\"password\":\"password123\",\"fullName\":\"Test User\"}"
```

---

## Частые проблемы

### Ошибка: "Port 8080 already in use"

**Решение:**
```bash
# Найти процесс на порту 8080
netstat -ano | findstr :8080

# Убить процесс (замените PID на ваш)
taskkill /F /PID <PID>
```

### Ошибка: "Flutter not found"

**Решение:**
- Установите Flutter: https://docs.flutter.dev/get-started/install
- Добавьте Flutter в PATH
- Перезапустите терминал

### Ошибка: "Failed to connect to backend"

**Решение:**
- Убедитесь, что backend запущен (Терминал 1)
- Проверьте, что порт 8080 свободен
- Проверьте логи backend сервера

### Ошибка: "Target Chrome not found"

**Решение:**
```bash
# Запустить без Chrome (откроется браузер по умолчанию)
flutter run -d web-server

# Или установить Chrome и указать путь
flutter run -d chrome --browser-binary="C:\Program Files\Google\Chrome\Application\chrome.exe"
```

### Горячая перезагрузка

Во время разработки используйте:
- **`r`** - Hot Reload (быстрая перезагрузка)
- **`R`** - Hot Restart (полная перезагрузка)
- **`q`** - Quit (выход)

---

## Структура проекта

```
D:\HACKATON-main\
├── backend/                 # Backend сервер (Dart Shelf)
│   ├── bin/
│   │   └── server.dart     # Точка входа backend
│   ├── lib/
│   │   ├── handlers/       # API обработчики
│   │   ├── models/         # Модели данных
│   │   ├── repositories/   # Репозитории
│   │   └── database/       # База данных
│   └── pubspec.yaml
│
└── HACKATON/               # Flutter Web frontend
    ├── lib/
    │   ├── main.dart       # Точка входа frontend
    │   ├── screens/        # Экраны
    │   ├── services/       # API сервисы
    │   └── models/         # Модели
    └── pubspec.yaml
```

---

## Остановка приложения

### Остановить Backend
В терминале 1 нажмите: **`Ctrl+C`**

### Остановить Flutter Web
В терминале 2 нажмите: **`Ctrl+C`**

---

## Production сборка

Для создания production версии:

```bash
# Собрать Flutter Web
cd D:\HACKATON-main\HACKATON
flutter build web --release

# Собрать Backend
cd D:\HACKATON-main\backend
dart compile exe bin/server.dart -o bin/server
```

Файлы будут в:
- Flutter: `HACKATON/build/web/`
- Backend: `backend/bin/server.exe`

---

## Полезные команды

```bash
# Очистить кэш Flutter
flutter clean

# Обновить зависимости
flutter pub get
dart pub get

# Проверить код на ошибки
flutter analyze

# Запустить тесты
flutter test
```

---

## Контакты

По вопросам разработки обращайтесь к команде проекта.
