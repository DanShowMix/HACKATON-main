import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../repositories/repositories.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

/// Notification handler
class NotificationHandler {
  static final NotificationRepository _repo = NotificationRepository();

  /// List all notifications for current employee
  static Future<Response> list(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final notifications = await _repo.getByEmployeeId(userId);
      return ok(notifications.map((n) => n.toJson()).toList());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Mark notification as read
  static Future<Response> markAsRead(Request req, String id) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      await _repo.markAsRead(id);
      return ok({'success': true});
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Mark all notifications as read
  static Future<Response> markAllAsRead(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      await _repo.markAllAsRead(userId);
      return ok({'success': true});
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Delete read notifications
  static Future<Response> deleteRead(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      await _repo.deleteRead(userId);
      return ok({'success': true});
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
