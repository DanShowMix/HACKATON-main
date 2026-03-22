import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';
import '../repositories/repositories.dart';
import '../models/models.dart';
import '../utils/response_helpers.dart';
import 'auth_handler.dart';

const _uuid = Uuid();

/// Monthly tasks handler
class MonthlyTasksHandler {
  static final MonthlyTaskRepository _repo = MonthlyTaskRepository();

  /// Get all monthly tasks for current employee
  static Future<Response> getTasks(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final tasks = await _repo.getByEmployeeId(userId);

      return ok(tasks.map((t) => t.toJson()).toList());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Create a new monthly task
  static Future<Response> createTask(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final body = req.context['body'] as Map<String, dynamic>?;
      
      final task = MonthlyTask(
        id: 'task-${_uuid.v4()}',
        employeeId: userId,
        title: body?['title'] as String? ?? 'Новая задача',
        description: body?['description'] as String? ?? '',
        rewardPoints: body?['rewardPoints'] as int? ?? 0,
        targetValue: body?['targetValue'] as int? ?? 0,
        currentValue: body?['currentValue'] as int? ?? 0,
        deadline: body?['deadline'] as String? ?? '',
        isCompleted: body?['isCompleted'] as bool? ?? false,
      );

      await _repo.create(task);

      return ok(task.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }

  /// Update task progress
  static Future<Response> updateTask(Request req) async {
    try {
      final userId = AuthHandler.getUserId(req);
      if (userId == null) {
        return unauthorized();
      }

      final body = req.context['body'] as Map<String, dynamic>?;
      final taskId = body?['id'] as String?;

      if (taskId == null) {
        return badRequest('Task ID is required');
      }

      final tasks = await _repo.getByEmployeeId(userId);
      final task = tasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));

      final updatedTask = MonthlyTask(
        id: task.id,
        employeeId: task.employeeId,
        title: task.title,
        description: task.description,
        rewardPoints: task.rewardPoints,
        targetValue: task.targetValue,
        currentValue: body?['currentValue'] as int? ?? task.currentValue,
        deadline: task.deadline,
        isCompleted: body?['isCompleted'] as bool? ?? task.isCompleted,
      );

      await _repo.update(updatedTask);

      return ok(updatedTask.toJson());
    } catch (e) {
      return serverError(e.toString());
    }
  }
}
