import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../repositories/repositories.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

/// Rating handler
class RatingHandler {
  static final RatingRepository _repo = RatingRepository();

  /// Get rating details for current employee
  static Future<Response> getDetails(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final rating = await _repo.getByEmployeeId(userId);
      
      if (rating == null) {
        return notFound('Rating details not found');
      }

      return ok(rating.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
