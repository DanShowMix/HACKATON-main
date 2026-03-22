import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'status_screen.dart';
import 'rating_screen.dart';
import 'new_rating_screen.dart';
import 'daily_screen.dart';
import 'notifications_screen.dart';
import 'financial_effect_screen.dart';
import 'monthly_tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_employee == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Ошибка загрузки данных'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployeeData,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployeeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            _buildGreetingCard(_employee!),
            const SizedBox(height: 16),

            // Быстрые метрики
            _buildQuickMetrics(_employee!),
            const SizedBox(height: 16),

            // Прогресс до следующего уровня
            _buildLevelProgressCard(_employee!),
            const SizedBox(height: 16),

            // Быстрые действия
            _buildQuickActions(context),
            const SizedBox(height: 16),

            // Последние уведомления
            _buildRecentNotifications(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard(Map<String, dynamic> employee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Добрый день,',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    employee['fullName'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  employee['level'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(Icons.shopping_cart, '${employee['dealsCount']}', 'Сделки'),
              const SizedBox(width: 8),
              _buildStatChip(Icons.trending_up, '${employee['volume']}', 'млн ₽'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetrics(Map<String, dynamic> employee) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Баллы',
            '${employee['currentPoints']}',
            Icons.star,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Доля банка',
            '${employee['bankShare']}%',
            Icons.pie_chart,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Выгода',
            '${(employee['annualBenefit'] / 1000).toInt()}K',
            Icons.account_balance_wallet,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard(Map<String, dynamic> employee) {
    final nextLevel = employee['nextLevel'] as String? ?? 'Gold';
    final pointsToNext = employee['pointsToNextLevel'] as int? ?? 38;
    final progressPercent = employee['progressPercent'] as double? ?? 62.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Прогресс',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$pointsToNext баллов',
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'До $nextLevel осталось $pointsToNext баллов (${progressPercent.toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Быстрые действия',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Итоги дня',
                    Icons.check_circle,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DailyScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Калькулятор',
                    Icons.calculate,
                    () => Navigator.pushNamed(context, '/calculator'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Рейтинг',
                    Icons.analytics,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewRatingScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Статус',
                    Icons.star,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatusScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Фин. эффект',
                    Icons.account_balance_wallet,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FinancialEffectScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Задачи',
                    Icons.task,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MonthlyTasksScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.green.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotifications(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Уведомления',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
                  child: const Text('Все'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildNotificationItem(
              'Новый уровень!',
              'Осталось несколько баллов до следующего уровня',
              Icons.arrow_upward,
              Colors.orange,
            ),
            _buildNotificationItem(
              'Сделка одобрена',
              'Кредит профинансирован',
              Icons.check_circle,
              Colors.green,
            ),
            _buildNotificationItem(
              'Акция месяца',
              'Двойные баллы за автокредиты',
              Icons.local_offer,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
