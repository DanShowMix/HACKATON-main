import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Screen for displaying rating with new formula
class NewRatingScreen extends StatefulWidget {
  const NewRatingScreen({super.key});

  @override
  State<NewRatingScreen> createState() => _NewRatingScreenState();
}

class _NewRatingScreenState extends State<NewRatingScreen> {
  Map<String, dynamic>? _rating;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService().getRatingDetails();
      setState(() {
        _rating = data as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки данных';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рейтинг'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRating,
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
                        onPressed: _loadRating,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_rating == null) {
      return const Center(
        child: Text('Данные о рейтинге отсутствуют'),
      );
    }

    final level = _rating!['level'] as String? ?? 'Silver';
    final totalScore = (_rating!['totalScore'] as num?)?.toDouble() ?? 0;
    final month = _rating!['month'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level badge and total score
          _buildLevelCard(level, totalScore, month),
          
          const SizedBox(height: 24),
          
          // Formula explanation
          _buildFormulaCard(),
          
          const SizedBox(height: 24),
          
          // Metrics breakdown
          const Text(
            'Ваши показатели',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Volume metric
          _buildMetricCard(
            'Объём сделок',
            _rating!['volume'] as Map<String, dynamic>?,
            'млн ₽',
            Icons.trending_up,
            Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          // Deals metric
          _buildMetricCard(
            'Количество сделок',
            _rating!['deals'] as Map<String, dynamic>?,
            'шт',
            Icons.shopping_cart,
            Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          // Bank share metric
          _buildMetricCard(
            'Доля банка',
            _rating!['bankShare'] as Map<String, dynamic>?,
            '%',
            Icons.pie_chart,
            Colors.orange,
          ),
          
          const SizedBox(height: 12),
          
          // Conversion metric
          _buildMetricCard(
            'Конверсия',
            _rating!['conversion'] as Map<String, dynamic>?,
            '%',
            Icons.check_circle,
            Colors.purple,
          ),
          
          const SizedBox(height: 24),
          
          // Level thresholds
          _buildLevelThresholdsCard(level),
        ],
      ),
    );
  }

  Widget _buildLevelCard(String level, double totalScore, String month) {
    final levelColor = _getLevelColor(level);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [levelColor, levelColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ваш уровень',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            totalScore.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'баллов',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (month.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Месяц: ${_formatMonth(month)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormulaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Формула расчёта',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '0,35 × объём + 0,25 × количество + 0,25 × доля + 0,15 × конверсия',
                    style: TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Объём = (факт/план) × 100 (макс. 120)',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '• Количество = (сделки/план) × 100',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '• Доля = (факт/цель) × 100',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '• Конверсия = (одобрено/подано) × 100',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    Map<String, dynamic>? data,
    String unit,
    IconData icon,
    Color color,
  ) {
    final fact = data?['fact'] as num? ?? 0;
    final plan = data?['plan'] as num? ?? 0;
    final index = data?['index'] as num? ?? 0;
    final weightedScore = index * _getWeight(label);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Факт: ${_formatNumber(fact, unit)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'План: ${_formatNumber(plan, unit)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              Text(
                '+${weightedScore.toStringAsFixed(1)} балл',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (index / 120).clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  double _getWeight(String label) {
    switch (label) {
      case 'Объём сделок':
        return 0.35;
      case 'Количество сделок':
        return 0.25;
      case 'Доля банка':
        return 0.25;
      case 'Конверсия':
        return 0.15;
      default:
        return 0;
    }
  }

  Widget _buildLevelThresholdsCard(String currentLevel) {
    final levels = [
      {'name': 'Silver', 'min': 0, 'max': 70, 'color': Colors.grey},
      {'name': 'Gold', 'min': 70, 'max': 90, 'color': Colors.amber},
      {'name': 'Black', 'min': 90, 'max': 150, 'color': Colors.black87},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Пороги уровней',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...levels.map((level) => _buildLevelThreshold(
              level['name'] as String,
              level['min'] as int,
              level['max'] as int,
              level['color'] as Color,
              currentLevel,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelThreshold(
    String name,
    int min,
    int max,
    Color color,
    String currentLevel,
  ) {
    final isCurrent = name == currentLevel;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? color : Colors.grey.shade300,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? color : Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            '$min - $max баллов',
            style: TextStyle(
              fontSize: 13,
              color: isCurrent ? color : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Black':
        return Colors.black87;
      case 'Gold':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatMonth(String month) {
    const months = [
      '', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    try {
      final monthNum = int.parse(month.split('-')[1]);
      return months[monthNum];
    } catch (e) {
      return month;
    }
  }

  String _formatNumber(num value, String unit) {
    if (unit == 'млн ₽') {
      return '${value.toStringAsFixed(1)} $unit';
    }
    return '${value.toString()} $unit';
  }
}
