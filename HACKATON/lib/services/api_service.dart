import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling API calls to the backend server
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Backend server URL - change for production
  String _baseUrl = kReleaseMode 
      ? '' // Same origin in production (served by backend)
      : 'http://localhost:8080/api';

  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;

  // Set base URL (for testing or different environments)
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  String get baseUrl => _baseUrl;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Load auth state from storage
  Future<void> loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('current_user');
      
      if (token != null && userJson != null) {
        _isAuthenticated = true;
        _currentUser = jsonDecode(userJson) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading auth state: $e');
    }
  }

  /// Save auth state to storage
  Future<void> _saveAuthState(String token, Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('current_user', jsonEncode(user));
    } catch (e) {
      debugPrint('Error saving auth state: $e');
    }
  }

  /// Clear auth state from storage
  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_user');
    } catch (e) {
      debugPrint('Error clearing auth state: $e');
    }
  }

  /// Get headers for authenticated requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Generic HTTP GET
  Future<dynamic> _get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await http.get(url, headers: _headers);
    return _handleResponse(response);
  }

  /// Generic HTTP POST
  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Generic HTTP PUT
  Future<dynamic> _put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Generic HTTP DELETE
  Future<dynamic> _delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final response = await http.delete(url, headers: _headers);
    return _handleResponse(response);
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      _isAuthenticated = false;
      _currentUser = null;
      throw ApiException('Unauthorized', 401);
    } else {
      String message = 'Request failed';
      try {
        final body = jsonDecode(response.body);
        message = body['error'] as String? ?? message;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  // ==================== AUTH ====================

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await _post('/auth/login', {
        'email': email,
        'password': password,
      });
      _isAuthenticated = result['success'] as bool;
      _currentUser = result['employee'] as Map<String, dynamic>;
      await _saveAuthState(result['token'] as String, _currentUser!);
      return _currentUser!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed: $e', 500);
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? dealerCode,
    String? position,
  }) async {
    try {
      final result = await _post('/auth/register', {
        'email': email,
        'password': password,
        'fullName': fullName,
        'dealerCode': dealerCode,
        'position': position,
      });
      _isAuthenticated = result['success'] as bool;
      _currentUser = result['employee'] as Map<String, dynamic>;
      await _saveAuthState(result['token'] as String, _currentUser!);
      return _currentUser!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Registration failed: $e', 500);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _post('/auth/logout', {});
    } catch (_) {
      // Ignore errors on logout
    }
    _isAuthenticated = false;
    _currentUser = null;
    await _clearAuthState();
  }

  /// Get current user data
  Future<Map<String, dynamic>> getEmployeeData() async {
    final result = await _get('/employee');
    return result as Map<String, dynamic>;
  }

  // ==================== DAILY RESULTS ====================

  /// Submit daily results
  Future<void> submitDailyResults({
    required int deals,
    required int volume,
    required int products,
  }) async {
    await _post('/daily', {
      'deals': deals,
      'volume': volume.toDouble(),
      'products': products,
    });
  }

  /// Get today's results
  Future<Map<String, dynamic>?> getTodayResults() async {
    final result = await _get('/daily/today');
    return result as Map<String, dynamic>?;
  }

  // ==================== RATING ====================

  /// Get rating details
  Future<Map<String, dynamic>> getRatingDetails() async {
    final result = await _get('/rating');
    return result as Map<String, dynamic>;
  }

  // ==================== NOTIFICATIONS ====================

  /// Get notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final result = await _get('/notifications');
    return (result as List).map((e) => e as Map<String, dynamic>).toList();
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String id) async {
    await _put('/notifications/$id/read', {});
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    await _put('/notifications/read-all', {});
  }

  // ==================== ACHIEVEMENTS ====================

  /// Get achievements
  Future<List<Map<String, dynamic>>> getAchievements() async {
    final result = await _get('/achievements');
    return (result as List).map((e) => e as Map<String, dynamic>).toList();
  }

  // ==================== PRODUCTS ====================

  /// Get products
  Future<List<Map<String, dynamic>>> getProducts() async {
    final result = await _get('/products');
    return (result as List).map((e) => e as Map<String, dynamic>).toList();
  }

  // ==================== DEALS ====================

  /// Get deals
  Future<List<Map<String, dynamic>>> getDeals() async {
    final result = await _get('/deals');
    return (result as List).map((e) => e as Map<String, dynamic>).toList();
  }

  /// Create deal
  Future<Map<String, dynamic>> createDeal(Map<String, dynamic> deal) async {
    final result = await _post('/deals', deal);
    return result as Map<String, dynamic>;
  }

  // ==================== CHAT ====================

  /// Get chat history
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final result = await _get('/chat');
    return (result as List).map((e) => e as Map<String, dynamic>).toList();
  }

  /// Send message
  Future<Map<String, dynamic>> sendMessage(String text) async {
    final result = await _post('/chat', {'text': text});
    return result as Map<String, dynamic>;
  }

  /// Get bot response (for mock mode)
  Future<String> getBotResponse(String message) async {
    try {
      final result = await sendMessage(message);
      final botResponse = result['botResponse'] as Map<String, dynamic>;
      return botResponse['text'] as String;
    } catch (e) {
      // Fallback to mock response
      final lowerMessage = message.toLowerCase();
      if (lowerMessage.contains('спасибо')) {
        return 'Всегда рады помочь! 😊';
      }
      if (lowerMessage.contains('проблем') || lowerMessage.contains('ошибк')) {
        return 'Опишите подробнее, какая проблема возникла?';
      }
      return 'Спасибо за обращение! Специалист ответит в течение 5 минут.';
    }
  }

  // ==================== FINANCIAL EFFECT ====================

  /// Get financial effect
  Future<Map<String, dynamic>> getFinancialEffect() async {
    final result = await _get('/financial-effect');
    return result as Map<String, dynamic>;
  }

  // ==================== MONTHLY TASKS ====================

  /// Get monthly tasks
  Future<List<Map<String, dynamic>>> getMonthlyTasks() async {
    final result = await _get('/monthly-tasks');
    return (result as List).map((e) => e as Map<String, dynamic>).toList();
  }

  /// Create monthly task
  Future<Map<String, dynamic>> createMonthlyTask(Map<String, dynamic> task) async {
    final result = await _post('/monthly-tasks', task);
    return result as Map<String, dynamic>;
  }

  /// Update monthly task
  Future<Map<String, dynamic>> updateMonthlyTask(Map<String, dynamic> task) async {
    final result = await _put('/monthly-tasks', task);
    return result as Map<String, dynamic>;
  }
}

/// API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
