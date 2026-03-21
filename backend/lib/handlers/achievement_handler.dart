import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../repositories/repositories.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

/// Achievement handler
class AchievementHandler {
  static final AchievementRepository _repo = AchievementRepository();

  /// List all achievements for current employee
  static Future<Response> list(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final achievements = await _repo.getByEmployeeId(userId);
      return ok(achievements.map((a) => a.toJson()).toList());
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
