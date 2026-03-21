import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../repositories/repositories.dart';
import '../utils/response_helpers.dart';

/// Product handler
class ProductHandler {
  static final ProductRepository _repo = ProductRepository();

  /// List all products (optionally filtered by category)
  static Future<Response> list(Request req) async {
    try {
      final category = req.url.queryParameters['category'];
      final products = await _repo.getAll(category: category);
      return ok(products.map((p) => p.toJson()).toList());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Get all product categories
  static Future<Response> categories(Request req) async {
    try {
      final categories = await _repo.getCategories();
      return ok(categories);
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
