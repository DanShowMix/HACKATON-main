import 'package:sqlite3/sqlite3.dart';

/// Database helper class for managing SQLite connections
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  Database? _database;
  
  DatabaseHelper._internal();

  /// Get database connection, creating it if necessary
  Database get database {
    _database ??= _initDatabase();
    return _database!;
  }

  /// Initialize database connection and create tables
  Database _initDatabase() {
    // Use file-based database for persistence
    final db = sqlite3.open('dealer.db');
    
    // Enable foreign keys
    db.execute('PRAGMA foreign_keys = ON');
    
    // Create tables
    _createTables(db);
    
    // Seed initial data (only if empty)
    _seedData(db);
    
    return db;
  }

  /// Create all database tables
  void _createTables(Database db) {
    // Users table for authentication
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        employee_id TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id)
      )
    ''');

    // Employees table
    db.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        dealer_code TEXT NOT NULL,
        position TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        level TEXT DEFAULT 'Silver',
        current_points INTEGER DEFAULT 0,
        next_level_points INTEGER DEFAULT 100,
        deals_count INTEGER DEFAULT 0,
        volume REAL DEFAULT 0,
        bank_share REAL DEFAULT 0,
        annual_benefit INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Deals table
    db.execute('''
      CREATE TABLE IF NOT EXISTS deals (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        client_name TEXT NOT NULL,
        product_type TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id)
      )
    ''');

    // Daily results table
    db.execute('''
      CREATE TABLE IF NOT EXISTS daily_results (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        date TEXT NOT NULL,
        deals_count INTEGER DEFAULT 0,
        volume REAL DEFAULT 0,
        products_count INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id),
        UNIQUE(employee_id, date)
      )
    ''');

    // Achievements table
    db.execute('''
      CREATE TABLE IF NOT EXISTS achievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon_emoji TEXT NOT NULL,
        points_reward INTEGER DEFAULT 0,
        tier TEXT DEFAULT 'bronze',
        target INTEGER DEFAULT 0
      )
    ''');

    // Employee achievements (progress tracking)
    db.execute('''
      CREATE TABLE IF NOT EXISTS employee_achievements (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        achievement_id TEXT NOT NULL,
        progress INTEGER DEFAULT 0,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id),
        FOREIGN KEY (achievement_id) REFERENCES achievements(id),
        UNIQUE(employee_id, achievement_id)
      )
    ''');

    // Notifications table
    db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id)
      )
    ''');

    // Products table
    db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        min_rate REAL,
        max_rate REAL,
        min_term INTEGER,
        max_term INTEGER,
        min_amount REAL,
        max_amount REAL,
        icon_emoji TEXT,
        is_popular INTEGER DEFAULT 0,
        points_multiplier INTEGER DEFAULT 1,
        features TEXT
      )
    ''');

    // Chat messages table
    db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        text TEXT NOT NULL,
        is_from_user INTEGER NOT NULL,
        status TEXT DEFAULT 'sent',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id)
      )
    ''');

    // Rating details table
    db.execute('''
      CREATE TABLE IF NOT EXISTS rating_details (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        volume_points INTEGER DEFAULT 0,
        deals_points INTEGER DEFAULT 0,
        bank_share_points INTEGER DEFAULT 0,
        products_points INTEGER DEFAULT 0,
        total_points INTEGER DEFAULT 0,
        calculated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id)
      )
    ''');

    // Financial effects table
    db.execute('''
      CREATE TABLE IF NOT EXISTS financial_effects (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        bonus_income INTEGER DEFAULT 0,
        mortgage_savings INTEGER DEFAULT 0,
        cashback INTEGER DEFAULT 0,
        dms_cost INTEGER DEFAULT 0,
        total_benefit INTEGER DEFAULT 0,
        period TEXT DEFAULT '2026',
        calculated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id)
      )
    ''');

    // Monthly tasks table
    db.execute('''
      CREATE TABLE IF NOT EXISTS monthly_tasks (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        reward_points INTEGER DEFAULT 0,
        target_value INTEGER DEFAULT 0,
        current_value INTEGER DEFAULT 0,
        deadline TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (employee_id) REFERENCES employees(id)
      )
    ''');
  }

  /// Seed initial data for demo purposes (only if empty)
  void _seedData(Database db) {
    // Check if data already exists
    final result = db.select('SELECT COUNT(*) as count FROM employees');
    if ((result.first['count'] as int) > 0) {
      return; // Data already exists, skip seeding
    }

    // Insert demo employee (for demo@dealer.ru login)
    db.execute('''
      INSERT INTO employees (id, full_name, dealer_code, position, phone, email, 
        level, current_points, next_level_points, deals_count, volume, bank_share, annual_benefit)
      VALUES ('emp-001', 'Иванов Иван Иванович', 'DC-123', 'Менеджер по продажам', 
        '+7 (999) 123-45-67', 'ivanov@dealer.ru', 'Silver', 62, 100, 15, 27.5, 35, 312400)
    ''');

    // Insert demo user (demo@dealer.ru / password123)
    db.execute('''
      INSERT INTO users (id, email, password_hash, employee_id)
      VALUES ('user-001', 'demo@dealer.ru', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'emp-001')
    ''');

    // Insert test employee 2 - Gold level
    db.execute('''
      INSERT INTO employees (id, full_name, dealer_code, position, phone, email, 
        level, current_points, next_level_points, deals_count, volume, bank_share, annual_benefit)
      VALUES ('emp-002', 'Петрова Анна Сергеевна', 'DC-456', 'Старший менеджер', 
        '+7 (999) 234-56-78', 'petrova@dealer.ru', 'Gold', 145, 200, 42, 85.3, 48, 890000)
    ''');

    // Insert test user 2 (petrova@dealer.ru / password123)
    db.execute('''
      INSERT INTO users (id, email, password_hash, employee_id)
      VALUES ('user-002', 'petrova@dealer.ru', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'emp-002')
    ''');

    // Insert test employee 3 - KCO
    db.execute('''
      INSERT INTO employees (id, full_name, dealer_code, position, phone, email, 
        level, current_points, next_level_points, deals_count, volume, bank_share, annual_benefit)
      VALUES ('emp-003', 'Сидоров Алексей Петрович', 'DC-789', 'КСО', 
        '+7 (999) 345-67-89', 'sidorov@dealer.ru', 'Silver', 38, 100, 8, 12.1, 22, 156000)
    ''');

    // Insert test user 3 (sidorov@dealer.ru / password123)
    db.execute('''
      INSERT INTO users (id, email, password_hash, employee_id)
      VALUES ('user-003', 'sidorov@dealer.ru', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'emp-003')
    ''');

    // Insert test employee 4 - Black level
    db.execute('''
      INSERT INTO employees (id, full_name, dealer_code, position, phone, email, 
        level, current_points, next_level_points, deals_count, volume, bank_share, annual_benefit)
      VALUES ('emp-004', 'Козлов Дмитрий Владимирович', 'DC-101', 'РОП', 
        '+7 (999) 456-78-90', 'kozlov@dealer.ru', 'Black', 245, 300, 78, 156.8, 67, 1850000)
    ''');

    // Insert test user 4 (kozlov@dealer.ru / password123)
    db.execute('''
      INSERT INTO users (id, email, password_hash, employee_id)
      VALUES ('user-004', 'kozlov@dealer.ru', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'emp-004')
    ''');

    // Insert test employee 5 - Director
    db.execute('''
      INSERT INTO employees (id, full_name, dealer_code, position, phone, email, 
        level, current_points, next_level_points, deals_count, volume, bank_share, annual_benefit)
      VALUES ('emp-005', 'Морозова Елена Александровна', 'DC-202', 'Директор ДЦ', 
        '+7 (999) 567-89-01', 'morozova@dealer.ru', 'Gold', 178, 200, 56, 112.4, 58, 1240000)
    ''');

    // Insert test user 5 (morozova@dealer.ru / password123)
    db.execute('''
      INSERT INTO users (id, email, password_hash, employee_id)
      VALUES ('user-005', 'morozova@dealer.ru', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'emp-005')
    ''');

    // Insert achievements
    db.execute('''
      INSERT INTO achievements (id, title, description, icon_emoji, points_reward, tier, target) VALUES
        ('ach-001', 'Первые шаги', 'Совершите первую сделку', '🎯', 10, 'bronze', 1),
        ('ach-002', 'Десяточка', 'Достигните 10 сделок', '🏆', 20, 'silver', 10),
        ('ach-003', 'Миллионер', 'Достигните объёма 1 млн ₽', '💰', 25, 'silver', 1),
        ('ach-004', 'Золотой статус', 'Достигните Gold уровня', '👑', 50, 'gold', 100),
        ('ach-005', 'Супер продавец', 'Оформите 50 сделок за месяц', '⭐', 100, 'gold', 50),
        ('ach-006', 'Легенда', 'Достигните Black уровня', '💎', 200, 'platinum', 200)
    ''');

    // Insert employee achievements
    db.execute('''
      INSERT INTO employee_achievements (id, employee_id, achievement_id, progress, is_unlocked) VALUES
        ('ea-001', 'emp-001', 'ach-001', 1, 1),
        ('ea-002', 'emp-001', 'ach-002', 10, 1),
        ('ea-003', 'emp-001', 'ach-003', 27, 1),
        ('ea-004', 'emp-001', 'ach-004', 62, 0),
        ('ea-005', 'emp-001', 'ach-005', 15, 0),
        ('ea-006', 'emp-001', 'ach-006', 62, 0)
    ''');

    // Insert products
    db.execute('''
      INSERT INTO products (id, name, description, category, min_rate, max_rate, 
        min_term, max_term, min_amount, max_amount, icon_emoji, is_popular, points_multiplier, features) VALUES
        ('prod-001', 'Автокредит', 'Кредит на покупку нового или подержанного автомобиля', 
          'Автокредиты', 5.9, 16.9, 12, 84, 0.1, 30, '🚗', 1, 2, 
          'Без первоначального взноса|Без КАСКО|Быстрое решение'),
        ('prod-002', 'Потребительский кредит', 'Кредит на любые цели без залога и поручителей', 
          'Потребительские', 14.5, 24.9, 12, 60, 0.05, 5, '💳', 0, 1, 
          'Без справок о доходе|Решение за 5 минут|Доставка карты'),
        ('prod-003', 'Ипотека', 'Кредит на покупку жилья на первичном или вторичном рынке', 
          'Ипотека', 5.3, 16.5, 36, 360, 0.5, 50, '🏠', 1, 3, 
          'Господдержка|Семейная ипотека|Материнский капитал'),
        ('prod-004', 'Рефинансирование', 'Объедините кредиты из других банков в один с меньшей ставкой', 
          'Рефинансирование', 13.5, 19.9, 12, 84, 0.1, 10, '🔄', 0, 1, 
          'До 5 кредитов|Кэшбэк 5000 ₽|Без визита в офис'),
        ('prod-005', 'Кредитная карта', 'Карта с льготным периодом до 120 дней и кэшбэком', 
          'Карты', 0, 39.9, 0, 0, 0.01, 1, '💳', 0, 1, 
          '120 дней без %|Кэшбэк до 30%|Бесплатное обслуживание'),
        ('prod-006', 'Автокредит с господдержкой', 'Льготная ставка для семей с детьми и работников бюджетной сферы', 
          'Автокредиты', 3.5, 8.9, 12, 60, 0.1, 20, '🚙', 0, 2, 
          'Льготная ставка|Для семей с детьми|Российское авто')
    ''');

    // Insert sample deals
    db.execute('''
      INSERT INTO deals (id, employee_id, client_name, product_type, amount, status) VALUES
        ('deal-001', 'emp-001', 'Иванов Пётр', 'Автокредит', 1200000, 'approved'),
        ('deal-002', 'emp-001', 'Смирнова Анна', 'Ипотека', 5500000, 'pending'),
        ('deal-003', 'emp-001', 'Кузнецов Алексей', 'Потребительский', 500000, 'approved'),
        ('deal-004', 'emp-001', 'Попова Мария', 'Рефинансирование', 800000, 'rejected'),
        ('deal-005', 'emp-001', 'Васильев Дмитрий', 'Автокредит', 2100000, 'financed')
    ''');

    // Insert notifications
    db.execute('''
      INSERT INTO notifications (id, employee_id, title, message, type, is_read) VALUES
        ('notif-001', 'emp-001', 'Новый уровень!', 'Осталось 38 баллов до получения Gold статуса', 'level', 0),
        ('notif-002', 'emp-001', 'Сделка одобрена', 'Кредит на 1.2 млн ₽ по заявке №4521 профинансирован', 'deal', 0),
        ('notif-003', 'emp-001', 'Акция месяца', 'Двойные баллы за все автокредиты до конца марта', 'promotion', 0),
        ('notif-004', 'emp-001', 'Достижение разблокировано', '«Первые 10 сделок» — получено 20 бонусных баллов', 'achievement', 1),
        ('notif-005', 'emp-001', 'Обновление условий', 'Изменились ставки по продукту «Автокредит»', 'system', 1)
    ''');

    // Insert rating details
    db.execute('''
      INSERT INTO rating_details (id, employee_id, volume_points, deals_points, bank_share_points, products_points, total_points)
      VALUES ('rating-001', 'emp-001', 32, 18, 12, 0, 62)
    ''');

    // Insert sample chat messages
    db.execute('''
      INSERT INTO chat_messages (id, employee_id, text, is_from_user, status) VALUES
        ('msg-001', 'emp-001', 'Здравствуйте! Чем могу помочь?', 0, 'read'),
        ('msg-002', 'emp-001', 'Как получить доступ к новым продуктам?', 1, 'read'),
        ('msg-003', 'emp-001', 'Для доступа к новым продуктам необходимо пройти обучение и сертификацию', 0, 'read')
    ''');

    // Insert financial effects for emp-001
    db.execute('''
      INSERT INTO financial_effects (id, employee_id, bonus_income, mortgage_savings, cashback, dms_cost, total_benefit, period)
      VALUES ('fe-001', 'emp-001', 150000, 120000, 24400, 18000, 312400, '2026')
    ''');

    // Insert monthly tasks for emp-001
    db.execute('''
      INSERT INTO monthly_tasks (id, employee_id, title, description, reward_points, target_value, current_value, deadline, is_completed)
      VALUES 
        ('task-001', 'emp-001', 'Сделать 3 сделки', 'Оформите и получите одобрение по 3 сделкам', 4, 3, 1, '31 марта 2026', 0),
        ('task-002', 'emp-001', 'Увеличить долю банка до 50%', 'Доведите долю банка в сделках до 50%', 6, 50, 35, '31 марта 2026', 0),
        ('task-003', 'emp-001', 'Продать 2 доп. продукта', 'Подключите 2 дополнительных продукта к сделкам', 3, 2, 0, '31 марта 2026', 0)
    ''');
  }

  /// Close database connection
  void close() {
    _database?.dispose();
    _database = null;
  }
}
