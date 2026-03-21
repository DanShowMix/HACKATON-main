import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'calculator_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Map<String, dynamic>? _employee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final apiService = ApiService();
      final data = await apiService.getEmployeeData();
      setState(() {
        _employee = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Мой статус')),
        body: const Center(child: Text('Ошибка загрузки данных')),
      );
    }

    final level = _employee!['level'] as String;
    final nextLevel = _employee!['nextLevel'] as String? ?? 'Gold';
    final pointsToNext = _employee!['pointsToNextLevel'] as int? ?? 38;
    final progressPercent = _employee!['progressPercent'] as double? ?? 62.0;
    final annualBenefit = _employee!['annualBenefit'] as int? ?? 312400;

    // Calculate financial projections for next level
    final incomeGrowth = (pointsToNext * 5000).toInt();
    final mortgageBenefit = (pointsToNext * 10000).toInt();

    return Scaffold(
      appBar: AppBar(title: const Text('Мой статус')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Бейдж уровня
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getLevelColor(level),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                level.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Прогресс-бар
            Text(
              'До $nextLevel осталось $pointsToNext баллов',
              style: const TextStyle(fontSize: 16),
            ),
            LinearProgressIndicator(
              value: progressPercent / 100,
              minHeight: 10,
            ),
            Text('${progressPercent.toStringAsFixed(1)}%'),

            const SizedBox(height: 30),

            // Финансовый прогноз
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'При переходе на $nextLevel:',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProjectionItem(
                        Icons.trending_up,
                        '+${(incomeGrowth / 1000).toInt()}K ₽',
                        'Рост дохода/год',
                        Colors.green,
                      ),
                      _buildProjectionItem(
                        Icons.home,
                        '+${(mortgageBenefit / 1000).toInt()}K ₽',
                        'Экономия на ипотеке',
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Текущий годовой доход: ${(annualBenefit / 1000).toInt()}K ₽',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Кнопка
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                ),
                icon: const Icon(Icons.trending_up),
                label: const Text('Как ускорить переход'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Silver':
        return Colors.grey.shade700;
      case 'Gold':
        return Colors.amber.shade700;
      case 'Black':
        return Colors.black;
      default:
        return Colors.blue;
    }
  }
}
