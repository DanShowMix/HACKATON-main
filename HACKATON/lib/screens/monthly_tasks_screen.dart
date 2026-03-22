import 'package:flutter/material.dart';
import '../models/monthly_task.dart';
import '../services/api_service.dart';

/// Screen for displaying monthly tasks
class MonthlyTasksScreen extends StatefulWidget {
  const MonthlyTasksScreen({super.key});

  @override
  State<MonthlyTasksScreen> createState() => _MonthlyTasksScreenState();
}

class _MonthlyTasksScreenState extends State<MonthlyTasksScreen> {
  List<MonthlyTask> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService().getMonthlyTasks();
      setState(() {
        _tasks = (data as List).map((e) => MonthlyTask.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки задач';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи месяца'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTasks,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _tasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTasksList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Нет задач на этот месяц',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Задачи появятся здесь в начале месяца',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    // Separate completed and active tasks
    final activeTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeTasks.isNotEmpty) ...[
            const Text(
              'Активные задачи',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...activeTasks.map((task) => _buildTaskCard(task)),
          ],
          
          if (completedTasks.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Выполнено',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ...completedTasks.map((task) => _buildTaskCard(task)),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(MonthlyTask task) {
    final progressPercent = task.progressPercent;
    final isOverdue = !task.isCompleted && _isOverdue(task.deadline);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? Colors.green
              : isOverdue
                  ? Colors.red.withOpacity(0.3)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: task.isCompleted
              ? LinearGradient(
                  colors: [Colors.green.shade50, Colors.green.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and reward
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? Colors.green
                          : isOverdue
                              ? Colors.red
                              : Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      task.isCompleted
                          ? Icons.check_circle
                          : isOverdue
                              ? Icons.warning
                              : Icons.task,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? Colors.green.shade800
                                : null,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildRewardBadge(task.rewardPoints),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Прогресс: ${task.currentValue} / ${task.targetValue}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${progressPercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(progressPercent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progressPercent),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Deadline
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isOverdue ? Colors.red : Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Дедлайн: ${task.deadline}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '+$points',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 100) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }

  bool _isOverdue(String deadline) {
    try {
      // Simple check: if deadline contains current month name, it's not overdue
      final now = DateTime.now();
      final currentMonth = _getMonthName(now.month);
      return !deadline.contains(currentMonth) && !deadline.contains('2026');
    } catch (e) {
      return false;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return months[month];
  }
}
