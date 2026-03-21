import 'package:shelf/shelf.dart';
import '../repositories/repositories.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

/// Financial effect handler
class FinancialEffectHandler {
  static final FinancialEffectRepository _repo = FinancialEffectRepository();

  /// Get financial effect for current employee
  static Future<Response> getEffect(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final effect = await _repo.getByEmployeeId(userId);

      if (effect == null) {
        return notFound('Financial effect not found');
      }

      return ok(effect.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
