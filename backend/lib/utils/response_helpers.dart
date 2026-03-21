import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Helper functions for creating JSON responses
Response ok(dynamic data) {
  return Response.ok(jsonEncode(data), headers: {'content-type': 'application/json'});
}

Response badRequest(String message) {
  return Response(400, body: jsonEncode({'error': message}), headers: {'content-type': 'application/json'});
}

Response unauthorized([String? message]) {
  return Response(401, body: jsonEncode({'error': message ?? 'Unauthorized'}), headers: {'content-type': 'application/json'});
}

Response notFound(String message) {
  return Response(404, body: jsonEncode({'error': message}), headers: {'content-type': 'application/json'});
}

Response serverError(String message) {
  return Response(500, body: jsonEncode({'error': message}), headers: {'content-type': 'application/json'});
}

Response created(dynamic data) {
  return Response(201, body: jsonEncode(data), headers: {'content-type': 'application/json'});
}

Response noContent() {
  return Response(204);
}
