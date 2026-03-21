import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

const _uuid = Uuid();

/// Daily results handler
class DailyHandler {
  static final DailyResultRepository _repo = DailyResultRepository();

  /// Get today's results
  static Future<Response> getToday(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final result = await _repo.getToday(userId);
      if (result == null) {
        return ok(null);
      }

      return ok(result.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Submit daily results
  static Future<Response> submit(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final body = req.context['body'] as Map<String, dynamic>?;
      if (body == null) {
        return badRequest('Invalid request body');
      }

      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      var existing = await _repo.getToday(userId);
      if (existing != null) {
        return badRequest('Results already submitted for today');
      }

      final result = DailyResult(
        id: 'daily-${_uuid.v4()}',
        employeeId: userId,
        date: todayStr,
        dealsCount: body['deals'] as int? ?? 0,
        volume: (body['volume'] as num?)?.toDouble() ?? 0,
        productsCount: body['products'] as int? ?? 0,
      );

      await _repo.create(result);
      return ok(result.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Update daily results
  static Future<Response> update(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final body = req.context['body'] as Map<String, dynamic>?;
      if (body == null) {
        return badRequest('Invalid request body');
      }

      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      var result = await _repo.getToday(userId);
      
      if (result == null) {
        return notFound('No results found for today');
      }

      result = DailyResult(
        id: result.id,
        employeeId: userId,
        date: todayStr,
        dealsCount: body['deals'] as int? ?? result.dealsCount,
        volume: (body['volume'] as num?)?.toDouble() ?? result.volume,
        productsCount: body['products'] as int? ?? result.productsCount,
      );

      await _repo.update(result);
      return ok(result.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
