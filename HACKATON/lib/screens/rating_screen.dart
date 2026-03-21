import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'calculator_screen.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  Map<String, dynamic>? _ratingData;
  Map<String, dynamic>? _employee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = ApiService();
      final rating = await apiService.getRatingDetails();
      final employee = await apiService.getEmployeeData();
      setState(() {
        _ratingData = rating;
        _employee = employee;
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

    // Mock data if API fails
    final ratingData = _ratingData ?? {
      'Объём': {'points': 32, 'info': '1 млн ₽ = 1 балл', 'tip': 'Увеличьте сумму кредитов'},
      'Сделки': {'points': 18, 'info': '1 сделка = 2 балла', 'tip': 'Оформляйте больше заявок'},
      'Доля банка': {'points': 12, 'info': '1% доли = 0.5 балла', 'tip': 'Предлагайте продукты банка чаще'},
    };

    final totalPoints = _employee?['currentPoints'] as int? ?? 62;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детализация рейтинга'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Общая сумма баллов
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Ваш рейтинг', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '$totalPoints баллов',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Детализация по показателям
            Expanded(
              child: ListView(
                children: [
                  _buildRatingCard(
                    context,
                    'Объём',
                    (_employee?['volume'] as num?)?.toInt() ?? 32,
                    '1 млн ₽ = 1 балл',
                    'Увеличьте сумму кредитов',
                  ),
                  _buildRatingCard(
                    context,
                    'Сделки',
                    (_employee?['dealsCount'] as int? ?? 15) * 2,
                    '1 сделка = 2 балла',
                    'Оформляйте больше заявок',
                  ),
                  _buildRatingCard(
                    context,
                    'Доля банка',
                    ((_employee?['bankShare'] as num?)?.toInt() ?? 35) ~/ 2,
                    '1% доли = 0.5 балла',
                    'Предлагайте продукты банка чаще',
                  ),
                ],
              ),
            ),

            // Кнопка "Смоделировать рост"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalculatorScreen()),
                ),
                icon: const Icon(Icons.trending_up),
                label: const Text('Смоделировать рост'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(
    BuildContext context,
    String title,
    int points,
    String info,
    String tip,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '$points балл.',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Как рассчитывается: $info',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Как увеличить: $tip',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Как считается рейтинг'),
        content: const Text(
          'Рейтинг рассчитывается ежедневно на основе:\n\n'
          '• Объёма профинансированных сделок\n'
          '• Количества сделок\n'
          '• Доли банка в портфеле дилера',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
