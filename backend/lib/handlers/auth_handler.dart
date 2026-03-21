import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../repositories/repositories.dart';
import '../models/employee.dart';
import '../models/models.dart';
import '../utils/response_helpers.dart';

const _uuid = Uuid();

/// Authentication handler with email/password
class AuthHandler {
  static final UserRepository _userRepo = UserRepository();
  static final EmployeeRepository _employeeRepo = EmployeeRepository();
  static final RatingRepository _ratingRepo = RatingRepository();

  // Mock authenticated user ID
  static String? _authenticatedUserId;

  /// Login with email and password
  static Future<Response> login(Request req) async {
    try {
      final body = req.context['body'] as Map<String, dynamic>?;
      final email = body?['email'] as String?;
      final password = body?['password'] as String?;

      if (email == null || email.isEmpty) {
        return badRequest('Email is required');
      }
      if (password == null || password.isEmpty) {
        return badRequest('Password is required');
      }

      // Find user by email
      final user = await _userRepo.getByEmail(email);

      if (user == null) {
        return unauthorized('Invalid email or password');
      }

      // Verify password
      if (!_userRepo.verifyPassword(password, user.passwordHash)) {
        return unauthorized('Invalid email or password');
      }

      // Get employee data
      Employee? employee;
      if (user.employeeId != null) {
        employee = await _employeeRepo.getById(user.employeeId!);
      }

      if (employee == null) {
        return notFound('Employee profile not found');
      }

      _authenticatedUserId = employee.id;

      return ok({
        'success': true,
        'employee': employee.toJson(),
        'token': 'mock-token-${employee.id}',
      });
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Register new user
  static Future<Response> register(Request req) async {
    try {
      final body = req.context['body'] as Map<String, dynamic>?;
      final email = body?['email'] as String?;
      final password = body?['password'] as String?;
      final fullName = body?['fullName'] as String?;
      final dealerCode = body?['dealerCode'] as String?;
      final position = body?['position'] as String?;

      // Validate input
      if (email == null || email.isEmpty || !email.contains('@')) {
        return badRequest('Valid email is required');
      }
      if (password == null || password.length < 6) {
        return badRequest('Password must be at least 6 characters');
      }
      if (fullName == null || fullName.isEmpty) {
        return badRequest('Full name is required');
      }

      // Check if email already exists
      final existingUser = await _userRepo.getByEmail(email);
      if (existingUser != null) {
        return badRequest('Email already registered');
      }

      // Create employee profile
      final employee = Employee(
        id: 'emp-${_uuid.v4()}',
        fullName: fullName,
        dealerCode: dealerCode ?? 'DC-NEW',
        position: position ?? 'Менеджер',
        email: email,
        level: 'Silver',
        currentPoints: 0,
        nextLevelPoints: 100,
        dealsCount: 0,
        volume: 0,
        bankShare: 0,
        annualBenefit: 0,
      );

      await _employeeRepo.create(employee);

      // Create user account
      final user = User(
        id: 'user-${_uuid.v4()}',
        email: email,
        passwordHash: _userRepo.hashPassword(password),
        employeeId: employee.id,
      );

      await _userRepo.create(user);

      // Create rating details with zero points for new employee
      final ratingDetail = RatingDetail(
        id: 'rating-${_uuid.v4()}',
        employeeId: employee.id,
        volumePoints: 0,
        dealsPoints: 0,
        bankSharePoints: 0,
        productsPoints: 0,
        totalPoints: 0,
        calculatedAt: DateTime.now(),
      );
      await _ratingRepo.create(ratingDetail);

      // Auto-login after registration
      _authenticatedUserId = employee.id;

      return ok({
        'success': true,
        'employee': employee.toJson(),
        'token': 'mock-token-${employee.id}',
      });
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Logout
  static Future<Response> logout(Request req) async {
    _authenticatedUserId = null;
    return ok({'success': true});
  }

  /// Get current authenticated user
  static Future<Response> getCurrentUser(Request req) async {
    if (_authenticatedUserId == null) {
      return unauthorized();
    }

    final employee = await _employeeRepo.getById(_authenticatedUserId!);
    if (employee == null) {
      return notFound('Employee not found');
    }

    return ok(employee.toJson());
  }

  /// Get authenticated user ID from request
  static String? getUserId(Request req) {
    return _authenticatedUserId;
  }

  /// Check if user is authenticated
  static bool isAuthenticated(Request req) {
    return _authenticatedUserId != null;
  }
}
