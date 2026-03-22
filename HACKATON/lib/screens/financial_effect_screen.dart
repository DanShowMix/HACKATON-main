import 'package:flutter/material.dart';
import '../models/financial_effect.dart';
import '../services/api_service.dart';

/// Screen for displaying personal financial effect (new calculation)
class FinancialEffectScreen extends StatefulWidget {
  const FinancialEffectScreen({super.key});

  @override
  State<FinancialEffectScreen> createState() => _FinancialEffectScreenState();
}

class _FinancialEffectScreenState extends State<FinancialEffectScreen> {
  FinancialEffect? _effect;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFinancialEffect();
  }

  Future<void> _loadFinancialEffect() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService().getFinancialEffect();
      setState(() {
        _effect = FinancialEffect.fromJson(data);
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
        title: const Text('Личный финансовый эффект'),
        centerTitle: true,
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
                        onPressed: _loadFinancialEffect,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_effect == null) {
      return const Center(
        child: Text('Данные о финансовом эффекте отсутствуют'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main total benefit card - YEAR TOTAL
          _buildTotalBenefitCard(),
          
          const SizedBox(height: 24),
          
          // Month info
          Center(
            child: Text(
              'Месяц: ${_formatMonth(_effect!.month)} ${_effect!.period} года',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Breakdown section
          const Text(
            'Детализация выгоды',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Breakdown cards
          _buildBreakdownCard(
            'Доп. доход от бонусов',
            _effect!.bonusIncome,
            'Подписка + категории трат',
            Icons.card_giftcard,
            Colors.orange,
          ),
          
          const SizedBox(height: 12),
          
          _buildBreakdownCard(
            'Экономия по ипотеке',
            _effect!.mortgageSavings,
            'Снижение ставки на 1%',
            Icons.home,
            Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          _buildBreakdownCard(
            'ДМС компенсация',
            _effect!.dmsCompensation,
            'Годовая стоимость / 12',
            Icons.medical_services,
            Colors.red,
          ),
          
          const SizedBox(height: 24),
          
          // Monthly benefit info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Выгода за месяц:',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  _formatCurrency(_effect!.totalMonthlyBenefit),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBenefitCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Ваша общая выгода',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'нарастающим итогом в ${_effect!.period} году',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(_effect!.yearTotalBenefit),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(
    String label,
    int amount,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ₽';
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
}
