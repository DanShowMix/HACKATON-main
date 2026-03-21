import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../repositories/repositories.dart';
import '../models/employee.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

/// Employee profile handler
class EmployeeHandler {
  static final EmployeeRepository _repo = EmployeeRepository();

  /// Get employee profile
  static Future<Response> getProfile(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final employee = await _repo.getById(userId);
      if (employee == null) {
        return notFound('Employee not found');
      }

      return ok(employee.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Update employee profile
  static Future<Response> updateProfile(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final body = req.context['body'] as Map<String, dynamic>?;
      if (body == null) {
        return badRequest('Invalid request body');
      }

      var employee = await _repo.getById(userId);
      if (employee == null) {
        return notFound('Employee not found');
      }

      // Update fields
      employee = Employee(
        id: employee.id,
        fullName: body['fullName'] as String? ?? employee.fullName,
        dealerCode: body['dealerCode'] as String? ?? employee.dealerCode,
        position: body['position'] as String? ?? employee.position,
        phone: body['phone'] as String? ?? employee.phone,
        email: body['email'] as String? ?? employee.email,
        level: body['level'] as String? ?? employee.level,
        currentPoints: body['currentPoints'] as int? ?? employee.currentPoints,
        nextLevelPoints: body['nextLevelPoints'] as int? ?? employee.nextLevelPoints,
        dealsCount: body['dealsCount'] as int? ?? employee.dealsCount,
        volume: (body['volume'] as num?)?.toDouble() ?? employee.volume,
        bankShare: (body['bankShare'] as num?)?.toDouble() ?? employee.bankShare,
        annualBenefit: body['annualBenefit'] as int? ?? employee.annualBenefit,
      );

      await _repo.update(employee);

      return ok(employee.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
