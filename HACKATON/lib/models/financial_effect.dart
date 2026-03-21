/// FinancialEffect model - личный финансовый эффект сотрудника
class FinancialEffect {
  final String id;
  final String employeeId;
  final int bonusIncome; // Доп. доход от бонусов
  final int mortgageSavings; // Экономия по ипотеке
  final int cashback; // Кэшбэк
  final int dmsCost; // Стоимость ДМС
  final int totalBenefit; // Общая выгода
  final String period; // Период (например, "2026")

  FinancialEffect({
    required this.id,
    required this.employeeId,
    this.bonusIncome = 0,
    this.mortgageSavings = 0,
    this.cashback = 0,
    this.dmsCost = 0,
    this.totalBenefit = 0,
    this.period = '2026',
  });

  factory FinancialEffect.fromJson(Map<String, dynamic> json) {
    return FinancialEffect(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      bonusIncome: json['bonusIncome'] as int? ?? 0,
      mortgageSavings: json['mortgageSavings'] as int? ?? 0,
      cashback: json['cashback'] as int? ?? 0,
      dmsCost: json['dmsCost'] as int? ?? 0,
      totalBenefit: json['totalBenefit'] as int? ?? 0,
      period: json['period'] as String? ?? '2026',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'bonusIncome': bonusIncome,
      'mortgageSavings': mortgageSavings,
      'cashback': cashback,
      'dmsCost': dmsCost,
      'totalBenefit': totalBenefit,
      'period': period,
    };
  }
}
