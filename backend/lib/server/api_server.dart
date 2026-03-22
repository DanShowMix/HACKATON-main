import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../handlers/auth_handler.dart';
import '../handlers/employee_handler.dart';
import '../handlers/deal_handler.dart';
import '../handlers/daily_handler.dart';
import '../handlers/achievement_handler.dart';
import '../handlers/notification_handler.dart';
import '../handlers/product_handler.dart';
import '../handlers/chat_handler.dart';
import '../handlers/rating_handler.dart';
import '../handlers/monthly_tasks_handler.dart';
import '../handlers/new_rating_handler.dart';

/// Main API server using Shelf framework
class ApiServer {
  final String host;
  final int port;
  late final HttpServer _server;
  late final Router _router;

  ApiServer({
    this.host = '0.0.0.0',
    this.port = 8080,
  }) {
    _router = _setupRoutes();
  }

  /// Set up all API routes
  Router _setupRoutes() {
    final router = Router();

    // Health check
    router.get('/api/health', (Request req) {
      return Response.ok(jsonEncode({
        'status': 'ok',
        'timestamp': DateTime.now().toIso8601String(),
      }), headers: {'Content-Type': 'application/json'});
    });

    // Auth routes
    router.post('/api/auth/login', AuthHandler.login);
    router.post('/api/auth/register', AuthHandler.register);
    router.post('/api/auth/logout', AuthHandler.logout);
    router.get('/api/auth/me', AuthHandler.getCurrentUser);

    // Employee routes
    router.get('/api/employee', EmployeeHandler.getProfile);
    router.put('/api/employee', EmployeeHandler.updateProfile);

    // Deal routes
    router.get('/api/deals', DealHandler.list);
    router.post('/api/deals', DealHandler.create);
    router.get('/api/deals/<id>', DealHandler.get);

    // Daily results routes
    router.get('/api/daily/today', DailyHandler.getToday);
    router.post('/api/daily', DailyHandler.submit);
    router.put('/api/daily', DailyHandler.update);

    // Achievement routes
    router.get('/api/achievements', AchievementHandler.list);

    // Notification routes
    router.get('/api/notifications', NotificationHandler.list);
    router.put('/api/notifications/<id>/read', NotificationHandler.markAsRead);
    router.put('/api/notifications/read-all', NotificationHandler.markAllAsRead);
    router.delete('/api/notifications/read', NotificationHandler.deleteRead);

    // Product routes
    router.get('/api/products', ProductHandler.list);
    router.get('/api/products/categories', ProductHandler.categories);

    // Chat routes
    router.get('/api/chat', ChatHandler.history);
    router.post('/api/chat', ChatHandler.send);

    // Rating routes (new formula)
    router.get('/api/rating', NewRatingHandler.getCurrentRating);
    router.get('/api/rating/old', RatingHandler.getDetails);

    // Financial effect routes (new calculation)
    router.get('/api/financial-effect', NewRatingHandler.getFinancialEffect);

    // Monthly tasks routes
    router.get('/api/monthly-tasks', MonthlyTasksHandler.getTasks);
    router.post('/api/monthly-tasks', MonthlyTasksHandler.createTask);
    router.put('/api/monthly-tasks', MonthlyTasksHandler.updateTask);

    // Static files for Flutter Web
    router.get('/', (Request req) => _serveStaticFile('index.html'));
    router.get('/<path|.*>', (Request req) {
      final path = req.params['path'] ?? '';
      if (path.startsWith('api/')) {
        return Response.notFound('API endpoint not found');
      }
      return _serveStaticFile(path);
    });

    return router;
  }

  /// Serve static files from build/web directory
  Response _serveStaticFile(String path) {
    if (path.isEmpty) path = 'index.html';
    
    // Security: prevent directory traversal
    if (path.contains('..') || path.contains('\\')) {
      return Response.forbidden('Invalid path');
    }

    final filePath = Directory.current.path.endsWith('/backend')
        ? '../HACKATON/build/web/$path'
        : 'HACKATON/build/web/$path';

    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return Response.notFound('File not found');
      }

      final contentType = _getContentType(path);
      return Response.ok(
        file.openRead(),
        headers: {'Content-Type': contentType},
      );
    } catch (e) {
      return Response.internalServerError(body: 'Error loading file');
    }
  }

  String _getContentType(String path) {
    if (path.endsWith('.html')) return 'text/html';
    if (path.endsWith('.js')) return 'application/javascript';
    if (path.endsWith('.css')) return 'text/css';
    if (path.endsWith('.json')) return 'application/json';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.gif')) return 'image/gif';
    if (path.endsWith('.svg')) return 'image/svg+xml';
    if (path.endsWith('.ico')) return 'image/x-icon';
    if (path.endsWith('.woff2')) return 'font/woff2';
    if (path.endsWith('.woff')) return 'font/woff';
    return 'application/octet-stream';
  }

  /// Start the server
  Future<void> start() async {
    final handler = Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addMiddleware(_jsonMiddleware())
        .addMiddleware(_jsonResponseMiddleware())
        .addHandler(_router.call);

    _server = await shelf_io.serve(handler, host, port);
    _server.autoCompress = true;

    print('🚀 Server started on http://$host:$port');
    print('📱 Flutter Web: http://localhost:$port');
    print('🔌 API: http://localhost:$port/api');
  }

  /// Middleware to parse JSON bodies
  Middleware _jsonMiddleware() {
    return (innerHandler) {
      return (request) async {
        final contentType = request.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          try {
            final body = await request.readAsString();
            final json = body.isNotEmpty ? jsonDecode(body) : null;
            request = request.change(context: {'body': json, 'rawBody': body});
          } catch (e) {
            return Response.badRequest(body: jsonEncode({'error': 'Invalid JSON: $e'}));
          }
        }
        return innerHandler(request);
      };
    };
  }

  /// Middleware to convert responses to JSON
  Middleware _jsonResponseMiddleware() {
    return (innerHandler) {
      return (request) async {
        final response = await innerHandler(request);
        
        // Skip if already has content-type or is empty
        if (response.headers.containsKey('content-type') || response.statusCode == 204) {
          return response;
        }
        
        return response;
      };
    };
  }

  /// Stop the server
  Future<void> stop() async {
    await _server.close();
    print('Server stopped');
  }
}
