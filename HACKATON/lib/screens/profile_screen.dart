import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
        appBar: AppBar(title: const Text('Профиль')),
        body: const Center(child: Text('Ошибка загрузки данных')),
      );
    }

    final employee = _employee!;
    final fullName = employee['fullName'] as String? ?? 'Не указано';
    final dealerCode = employee['dealerCode'] as String? ?? 'Не указано';
    final position = employee['position'] as String? ?? 'Не указано';
    final level = employee['level'] as String? ?? 'Silver';
    final phone = employee['phone'] as String? ?? 'Не указан';
    final email = employee['email'] as String? ?? 'Не указана';
    final createdAt = employee['createdAt'] as String?;
    
    // Calculate time in program
    String timeInProgram = 'Не указано';
    if (createdAt != null) {
      try {
        final regDate = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(regDate);
        if (difference.inDays > 365) {
          timeInProgram = '${(difference.inDays / 365).toStringAsFixed(1)} лет';
        } else if (difference.inDays > 30) {
          timeInProgram = '${(difference.inDays / 30).toStringAsFixed(1)} мес';
        } else {
          timeInProgram = '${difference.inDays} дн';
        }
      } catch (_) {}
    }

    final regDateStr = createdAt != null
        ? DateTime.parse(createdAt).toString().split(' ')[0]
        : 'Не указана';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
            tooltip: 'Настройки',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Аватар и имя
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.green.shade100,
              child: Text(
                fullName.isNotEmpty ? fullName[0] : 'П',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              '$position | ДЦ: $dealerCode',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _buildLevelBadge(level),
            const SizedBox(height: 24),

            // Информация
            Card(
              child: Column(
                children: [
                  _buildInfoTile(
                    Icons.badge,
                    'Код ДЦ',
                    dealerCode,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.work,
                    'Должность',
                    position,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(Icons.phone, 'Телефон', phone),
                  const Divider(height: 1),
                  _buildInfoTile(Icons.email, 'Почта', email),
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.calendar_today,
                    'В программе',
                    timeInProgram,
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    Icons.event,
                    'Дата регистрации',
                    regDateStr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка Sber ID
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔐 Вход через Sber ID')),
                  );
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text('Войти через Sber ID'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Кнопка поддержки
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/support');
                },
                icon: const Icon(Icons.support),
                label: const Text('Служба поддержки'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(String level) {
    Color color;
    switch (level) {
      case 'Silver':
        color = Colors.grey.shade700;
        break;
      case 'Gold':
        color = Colors.amber.shade700;
        break;
      case 'Black':
        color = Colors.black;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Уровень: $level',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green, size: 20),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из приложения?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
