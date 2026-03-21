import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Current values
  double deals = 15;
  double volume = 27.5;
  double bankShare = 35;
  double products = 5;
  
  // Target values
  double targetDeals = 20;
  double targetVolume = 35;
  double targetBankShare = 45;
  double targetProducts = 8;

  // Level thresholds
  static const int silverThreshold = 0;
  static const int goldThreshold = 100;
  static const int blackThreshold = 200;

  int calculatePoints(double deals, double volume, double bankShare, double products) {
    // Formula: 
    // - 2 балла за сделку
    // - 1 балл за 1 млн ₽ объёма
    // - 0.5 балла за 1% доли банка
    // - 1 балл за доп. продукт
    return (deals * 2).toInt() +
        volume.toInt() +
        (bankShare / 5).toInt() +
        products.toInt();
  }

  int get currentPoints => calculatePoints(deals, volume, bankShare, products);
  int get targetPoints => calculatePoints(targetDeals, targetVolume, targetBankShare, targetProducts);

  String getLevel(int points) {
    if (points < goldThreshold) return 'Silver';
    if (points < blackThreshold) return 'Gold';
    return 'Black';
  }

  Color getLevelColor(String level) {
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

  int get pointsDifference => targetPoints - currentPoints;
  int get additionalIncome => (targetPoints - currentPoints) * 5000;
  int get mortgageBenefit => (targetPoints - currentPoints) * 10000;

  // Update target values if they become less than current values
  void _updateTargetIfNeeded() {
    setState(() {
      if (targetDeals < deals) targetDeals = deals;
      if (targetVolume < volume) targetVolume = volume;
      if (targetBankShare < bankShare) targetBankShare = bankShare;
      if (targetProducts < products) targetProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = getLevel(currentPoints);
    final targetLevel = getLevel(targetPoints);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сценарный калькулятор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetValues,
            tooltip: 'Сбросить',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status card
            _buildCurrentStatusCard(currentLevel, currentPoints),
            const SizedBox(height: 16),

            // Target level selector
            _buildTargetLevelSelector(targetLevel),
            const SizedBox(height: 16),

            // Sliders section
            const Text(
              'Текущие показатели',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSlider(
              '📋 Сделки (шт)',
              deals,
              0,
              50,
              (v) {
                setState(() => deals = v);
                _updateTargetIfNeeded();
              },
              '2 балла за сделку',
            ),
            _buildSlider(
              '💰 Объём (млн ₽)',
              volume,
              0,
              100,
              (v) {
                setState(() => volume = v);
                _updateTargetIfNeeded();
              },
              '1 балл за 1 млн ₽',
            ),
            _buildSlider(
              '📊 Доля банка (%)',
              bankShare,
              0,
              100,
              (v) {
                setState(() => bankShare = v);
                _updateTargetIfNeeded();
              },
              '0.5 балла за 1%',
            ),
            _buildSlider(
              '🎁 Доп. продукты',
              products,
              0,
              20,
              (v) {
                setState(() => products = v);
                _updateTargetIfNeeded();
              },
              '1 балл за продукт',
            ),

            const SizedBox(height: 24),

            // Target sliders
            const Text(
              'Целевые показатели',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSlider(
              '📋 Сделки (шт)',
              targetDeals,
              deals, // min = current value
              50,
              (v) => setState(() => targetDeals = v),
              'Цель: ${targetDeals.toInt()} шт',
              isTarget: true,
            ),
            _buildSlider(
              '💰 Объём (млн ₽)',
              targetVolume,
              volume, // min = current value
              100,
              (v) => setState(() => targetVolume = v),
              'Цель: ${targetVolume.toStringAsFixed(1)} млн',
              isTarget: true,
            ),
            _buildSlider(
              '📊 Доля банка (%)',
              targetBankShare,
              bankShare, // min = current value
              100,
              (v) => setState(() => targetBankShare = v),
              'Цель: ${targetBankShare.toInt()}%',
              isTarget: true,
            ),
            _buildSlider(
              '🎁 Доп. продукты',
              targetProducts,
              products, // min = current value
              20,
              (v) => setState(() => targetProducts = v),
              'Цель: ${targetProducts.toInt()} шт',
              isTarget: true,
            ),

            const SizedBox(height: 32),

            // Results card
            _buildResultsCard(currentLevel, targetLevel),
            
            const SizedBox(height: 16),

            // Recommendations
            _buildRecommendationsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(String level, int points) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Текущий уровень',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                level,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Column(
            children: [
              const Text(
                'Текущие баллы',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '$points',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Column(
            children: [
              const Text(
                'До Black',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${blackThreshold - points}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetLevelSelector(String targetLevel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Целевой уровень',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLevelChip(
                    'Silver',
                    silverThreshold,
                    targetLevel == 'Silver',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLevelChip(
                    'Gold',
                    goldThreshold,
                    targetLevel == 'Gold',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLevelChip(
                    'Black',
                    blackThreshold,
                    targetLevel == 'Black',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelChip(String level, int threshold, bool isSelected) {
    final color = getLevelColor(level);
    return GestureDetector(
      onTap: () {
        setState(() {
          // Auto-set target values based on level
          switch (level) {
            case 'Gold':
              targetDeals = (goldThreshold / 2).clamp(deals, 50.0);
              targetVolume = (goldThreshold / 3).clamp(volume, 100.0);
              break;
            case 'Black':
              targetDeals = (blackThreshold / 2).clamp(deals, 50.0);
              targetVolume = (blackThreshold / 3).clamp(volume, 100.0);
              break;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              level,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$threshold+ баллов',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white70 : color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    String hint, {
    bool isTarget = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTarget ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                Text(
                  value.toStringAsFixed(value.toInt() == value ? 0 : 1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isTarget ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: max.toInt(),
              activeColor: isTarget ? Colors.green : Colors.green.shade700,
              onChanged: onChanged,
            ),
            Text(
              hint,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(String currentLevel, String targetLevel) {
    final levelUp = currentLevel != targetLevel;
    
    return Card(
      color: levelUp ? Colors.amber.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentLevel,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 20),
                Text(
                  targetLevel,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: getLevelColor(targetLevel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem(
                  Icons.arrow_upward,
                  '+$pointsDifference баллов',
                  'Рост',
                  Colors.green,
                ),
                _buildResultItem(
                  Icons.account_balance_wallet,
                  '+${additionalIncome ~/ 1000}K ₽',
                  'Доход/год',
                  Colors.amber,
                ),
                _buildResultItem(
                  Icons.home,
                  '+${mortgageBenefit ~/ 1000}K ₽',
                  'Ипотека',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
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
            fontSize: 16,
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
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    final recommendations = _getRecommendations();
    
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Рекомендации',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];
    
    if (targetDeals > deals) {
      recommendations.add(
        'Увеличьте количество сделок на ${targetDeals - deals} для достижения цели',
      );
    }
    
    if (targetVolume > volume) {
      recommendations.add(
        'Привлеките клиентов на объём ${(targetVolume - volume).toStringAsFixed(1)} млн ₽',
      );
    }
    
    if (targetBankShare > bankShare) {
      recommendations.add(
        'Предлагайте продукты банка каждому ${((targetBankShare - bankShare) / 5).toInt()} клиенту',
      );
    }
    
    if (targetProducts > products) {
      recommendations.add(
        'Добавьте ${targetProducts - products} доп. продукта к сделкам',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Вы достигли целевых показателей! 🎉');
    }
    
    return recommendations;
  }

  void _resetValues() {
    setState(() {
      deals = 15;
      volume = 27.5;
      bankShare = 35;
      products = 5;
      targetDeals = 20;
      targetVolume = 35;
      targetBankShare = 45;
      targetProducts = 8;
    });
  }
}
