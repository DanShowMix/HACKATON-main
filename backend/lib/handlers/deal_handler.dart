import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

const _uuid = Uuid();

/// Deal handler
class DealHandler {
  static final DealRepository _repo = DealRepository();

  /// List all deals for current employee
  static Future<Response> list(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final deals = await _repo.getByEmployeeId(userId);
      return ok(deals.map((d) => d.toJson()).toList());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Get single deal
  static Future<Response> get(Request req, String id) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final deals = await _repo.getByEmployeeId(userId);
      final deal = deals.where((d) => d.id == id).firstOrNull;
      
      if (deal == null) {
        return notFound('Deal not found');
      }

      return ok(deal.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Create new deal
  static Future<Response> create(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final body = req.context['body'] as Map<String, dynamic>?;
      if (body == null) {
        return badRequest('Invalid request body');
      }

      final deal = Deal(
        id: 'deal-${_uuid.v4()}',
        employeeId: userId,
        clientName: body['clientName'] as String,
        productType: body['productType'] as String,
        amount: (body['amount'] as num).toDouble(),
        status: body['status'] as String? ?? 'pending',
      );

      await _repo.create(deal);

      return ok(deal.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
