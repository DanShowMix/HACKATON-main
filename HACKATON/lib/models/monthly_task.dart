/// MonthlyTask model - задача месяца
class MonthlyTask {
  final String id;
  final String employeeId;
  final String title;
  final String description;
  final int rewardPoints; // Награда в баллах
  final int targetValue; // Целевое значение
  final int currentValue; // Текущий прогресс
  final String deadline; // Дедлайн
  final bool isCompleted;

  MonthlyTask({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.description,
    this.rewardPoints = 0,
    this.targetValue = 0,
    this.currentValue = 0,
    this.deadline = '',
    this.isCompleted = false,
  });

  double get progressPercent => targetValue > 0 ? (currentValue / targetValue) * 100 : 0;

  factory MonthlyTask.fromJson(Map<String, dynamic> json) {
    return MonthlyTask(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      targetValue: json['targetValue'] as int? ?? 0,
      currentValue: json['currentValue'] as int? ?? 0,
      deadline: json['deadline'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'title': title,
      'description': description,
      'rewardPoints': rewardPoints,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'deadline': deadline,
      'isCompleted': isCompleted,
    };
  }
}
