import 'dart:io';
import '../database/database_helper.dart';
import '../models/employee.dart';
import '../models/models.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

const _uuid = Uuid();

/// Repository for user authentication operations
class UserRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<User?> getByEmail(String email) async {
    final db = _db.database;
    final result = db.select('SELECT * FROM users WHERE email = ?', [email.toLowerCase()]);
    if (result.isEmpty) return null;
    return _rowToUser(result.first);
  }

  Future<User?> getById(String id) async {
    final db = _db.database;
    final result = db.select('SELECT * FROM users WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    return _rowToUser(result.first);
  }

  Future<User> create(User user) async {
    final db = _db.database;
    db.execute('''
      INSERT INTO users (id, email, password_hash, employee_id)
      VALUES (?, ?, ?, ?)
    ''', [
      user.id,
      user.email.toLowerCase(),
      user.passwordHash,
      user.employeeId,
    ]);
    return user;
  }

  Future<bool> emailExists(String email) async {
    final db = _db.database;
    final result = db.select('SELECT COUNT(*) as count FROM users WHERE email = ?', [email.toLowerCase()]);
    return (result.first['count'] as int) > 0;
  }

  /// Hash password using SHA256 (in production use bcrypt)
  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Verify password
  bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }

  User _rowToUser(Map<String, Object?> row) {
    return User(
      id: row['id'] as String,
      email: row['email'] as String,
      passwordHash: row['password_hash'] as String,
      employeeId: row['employee_id'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}

/// Repository for employee data operations
class EmployeeRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Employee?> getById(String id) async {
    final db = _db.database;
    final result = db.select('SELECT * FROM employees WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    return _rowToEmployee(result.first);
  }

  Future<Employee> create(Employee employee) async {
    final db = _db.database;
    db.execute('''
      INSERT INTO employees (id, full_name, dealer_code, position, phone, email, 
        level, current_points, next_level_points, deals_count, volume, bank_share, annual_benefit)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      employee.id,
      employee.fullName,
      employee.dealerCode,
      employee.position,
      employee.phone,
      employee.email,
      employee.level,
      employee.currentPoints,
      employee.nextLevelPoints,
      employee.dealsCount,
      employee.volume,
      employee.bankShare,
      employee.annualBenefit,
    ]);
    return employee;
  }

  Future<Employee> update(Employee employee) async {
    final db = _db.database;
    db.execute('''
      UPDATE employees SET 
        full_name = ?, dealer_code = ?, position = ?, phone = ?, email = ?,
        level = ?, current_points = ?, next_level_points = ?, deals_count = ?,
        volume = ?, bank_share = ?, annual_benefit = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    ''', [
      employee.fullName,
      employee.dealerCode,
      employee.position,
      employee.phone,
      employee.email,
      employee.level,
      employee.currentPoints,
      employee.nextLevelPoints,
      employee.dealsCount,
      employee.volume,
      employee.bankShare,
      employee.annualBenefit,
      employee.id,
    ]);
    return employee;
  }

  Employee _rowToEmployee(Map<String, Object?> row) {
    return Employee(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      dealerCode: row['dealer_code'] as String,
      position: row['position'] as String,
      phone: row['phone'] as String?,
      email: row['email'] as String?,
      level: row['level'] as String,
      currentPoints: row['current_points'] as int,
      nextLevelPoints: row['next_level_points'] as int,
      dealsCount: row['deals_count'] as int,
      volume: (row['volume'] as num).toDouble(),
      bankShare: (row['bank_share'] as num).toDouble(),
      annualBenefit: row['annual_benefit'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}

/// Repository for deal data operations
class DealRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Deal>> getByEmployeeId(String employeeId) async {
    final db = _db.database;
    final results = db.select(
      'SELECT * FROM deals WHERE employee_id = ? ORDER BY created_at DESC',
      [employeeId],
    );
    return results.map(_rowToDeal).toList();
  }

  Future<Deal> create(Deal deal) async {
    final db = _db.database;
    db.execute('''
      INSERT INTO deals (id, employee_id, client_name, product_type, amount, status)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      deal.id,
      deal.employeeId,
      deal.clientName,
      deal.productType,
      deal.amount,
      deal.status,
    ]);
    return deal;
  }

  Deal _rowToDeal(Map<String, Object?> row) {
    return Deal(
      id: row['id'] as String,
      employeeId: row['employee_id'] as String,
      clientName: row['client_name'] as String,
      productType: row['product_type'] as String,
      amount: (row['amount'] as num).toDouble(),
      status: row['status'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}

/// Repository for daily results
class DailyResultRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<DailyResult?> getToday(String employeeId) async {
    final db = _db.database;
    final today = _getTodayString();
    final results = db.select(
      'SELECT * FROM daily_results WHERE employee_id = ? AND date = ?',
      [employeeId, today],
    );
    if (results.isEmpty) return null;
    return _rowToResult(results.first);
  }

  Future<DailyResult> create(DailyResult result) async {
    final db = _db.database;
    db.execute('''
      INSERT INTO daily_results (id, employee_id, date, deals_count, volume, products_count)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      result.id,
      result.employeeId,
      result.date,
      result.dealsCount,
      result.volume,
      result.productsCount,
    ]);
    return result;
  }

  Future<DailyResult> update(DailyResult result) async {
    final db = _db.database;
    db.execute('''
      UPDATE daily_results SET 
        deals_count = ?, volume = ?, products_count = ?
      WHERE employee_id = ? AND date = ?
    ''', [
      result.dealsCount,
      result.volume,
      result.productsCount,
      result.employeeId,
      result.date,
    ]);
    return result;
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DailyResult _rowToResult(Map<String, Object?> row) {
    return DailyResult(
      id: row['id'] as String,
      employeeId: row['employee_id'] as String,
      date: row['date'] as String,
      dealsCount: row['deals_count'] as int,
      volume: (row['volume'] as num).toDouble(),
      productsCount: row['products_count'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// Repository for achievements
class AchievementRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Achievement>> getByEmployeeId(String employeeId) async {
    final db = _db.database;
    final results = db.select('''
      SELECT a.*, ea.progress, ea.is_unlocked, ea.unlocked_at
      FROM achievements a
      LEFT JOIN employee_achievements ea ON a.id = ea.achievement_id AND ea.employee_id = ?
      ORDER BY ea.is_unlocked DESC, a.tier
    ''', [employeeId]);
    return results.map(_rowToAchievement).toList();
  }

  Achievement _rowToAchievement(Map<String, Object?> row) {
    return Achievement(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      iconEmoji: row['icon_emoji'] as String,
      pointsReward: row['points_reward'] as int,
      tier: row['tier'] as String,
      target: row['target'] as int,
      progress: row['progress'] as int? ?? 0,
      isUnlocked: (row['is_unlocked'] as int) == 1,
      unlockedAt: row['unlocked_at'] != null 
          ? DateTime.parse(row['unlocked_at'] as String) 
          : null,
    );
  }
}

/// Repository for notifications
class NotificationRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Notification>> getByEmployeeId(String employeeId) async {
    final db = _db.database;
    final results = db.select(
      'SELECT * FROM notifications WHERE employee_id = ? ORDER BY created_at DESC',
      [employeeId],
    );
    return results.map(_rowToNotification).toList();
  }

  Future<void> markAsRead(String id) async {
    final db = _db.database;
    db.execute('UPDATE notifications SET is_read = 1 WHERE id = ?', [id]);
  }

  Future<void> markAllAsRead(String employeeId) async {
    final db = _db.database;
    db.execute('UPDATE notifications SET is_read = 1 WHERE employee_id = ?', [employeeId]);
  }

  Future<void> deleteRead(String employeeId) async {
    final db = _db.database;
    db.execute('DELETE FROM notifications WHERE employee_id = ? AND is_read = 1', [employeeId]);
  }

  Notification _rowToNotification(Map<String, Object?> row) {
    return Notification(
      id: row['id'] as String,
      employeeId: row['employee_id'] as String,
      title: row['title'] as String,
      message: row['message'] as String,
      type: row['type'] as String,
      isRead: (row['is_read'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// Repository for products
class ProductRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Product>> getAll({String? category}) async {
    final db = _db.database;
    List<Object?> args = [];
    String query = 'SELECT * FROM products';
    if (category != null && category != 'Все') {
      query += ' WHERE category = ?';
      args = [category];
    }
    query += ' ORDER BY is_popular DESC, name';
    final results = db.select(query, args);
    return results.map(_rowToProduct).toList();
  }

  Future<List<String>> getCategories() async {
    final db = _db.database;
    final results = db.select('SELECT DISTINCT category FROM products ORDER BY category');
    return results.map((r) => r['category'] as String).toList();
  }

  Product _rowToProduct(Map<String, Object?> row) {
    return Product(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      category: row['category'] as String,
      minRate: (row['min_rate'] as num?)?.toDouble(),
      maxRate: (row['max_rate'] as num?)?.toDouble(),
      minTerm: row['min_term'] as int?,
      maxTerm: row['max_term'] as int?,
      minAmount: (row['min_amount'] as num?)?.toDouble(),
      maxAmount: (row['max_amount'] as num?)?.toDouble(),
      iconEmoji: row['icon_emoji'] as String?,
      isPopular: (row['is_popular'] as int) == 1,
      pointsMultiplier: row['points_multiplier'] as int? ?? 1,
      features: row['features'] != null 
          ? (row['features'] as String).split('|') 
          : const [],
    );
  }
}

/// Repository for chat messages
class ChatMessageRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<ChatMessage>> getByEmployeeId(String employeeId) async {
    final db = _db.database;
    final results = db.select(
      'SELECT * FROM chat_messages WHERE employee_id = ? ORDER BY created_at ASC',
      [employeeId],
    );
    return results.map(_rowToMessage).toList();
  }

  Future<ChatMessage> create(ChatMessage message) async {
    final db = _db.database;
    db.execute('''
      INSERT INTO chat_messages (id, employee_id, text, is_from_user, status)
      VALUES (?, ?, ?, ?, ?)
    ''', [
      message.id,
      message.employeeId,
      message.text,
      message.isFromUser ? 1 : 0,
      message.status,
    ]);
    return message;
  }

  ChatMessage _rowToMessage(Map<String, Object?> row) {
    return ChatMessage(
      id: row['id'] as String,
      employeeId: row['employee_id'] as String,
      text: row['text'] as String,
      isFromUser: (row['is_from_user'] as int) == 1,
      status: row['status'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

/// Repository for rating details
class RatingRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<RatingDetail?> getByEmployeeId(String employeeId) async {
    final db = _db.database;
    final results = db.select(
      'SELECT * FROM rating_details WHERE employee_id = ?',
      [employeeId],
    );
    if (results.isEmpty) return null;
    return _rowToRating(results.first);
  }

  RatingDetail _rowToRating(Map<String, Object?> row) {
    return RatingDetail(
      id: row['id'] as String,
      employeeId: row['employee_id'] as String,
      volumePoints: row['volume_points'] as int,
      dealsPoints: row['deals_points'] as int,
      bankSharePoints: row['bank_share_points'] as int,
      productsPoints: row['products_points'] as int,
      totalPoints: row['total_points'] as int,
      calculatedAt: DateTime.parse(row['calculated_at'] as String),
    );
  }
}
