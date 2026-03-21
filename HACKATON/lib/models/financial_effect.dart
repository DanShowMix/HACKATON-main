/// FinancialEffect model - личный финансовый эффект сотрудника (new calculation)
class FinancialEffect {
  final String id;
  final String employeeId;
  final String month;
  final int bonusIncome; // Доп. доход от бонусов (подписка * категории)
  final int mortgageSavings; // Экономия по ипотеке (1% скидка / 12 месяцев)
  final int dmsCompensation; // ДМС компенсация (годовая / 12)
  final int totalMonthlyBenefit; // Общая месячная выгода
  final int yearTotalBenefit; // Нарастающий итог за год
  final String period; // Год периода

  FinancialEffect({
    required this.id,
    required this.employeeId,
    required this.month,
    this.bonusIncome = 0,
    this.mortgageSavings = 0,
    this.dmsCompensation = 0,
    this.totalMonthlyBenefit = 0,
    this.yearTotalBenefit = 0,
    this.period = '2026',
  });

  factory FinancialEffect.fromJson(Map<String, dynamic> json) {
    return FinancialEffect(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      month: json['month'] as String,
      bonusIncome: json['bonusIncome'] as int? ?? 0,
      mortgageSavings: json['mortgageSavings'] as int? ?? 0,
      dmsCompensation: json['dmsCompensation'] as int? ?? 0,
      totalMonthlyBenefit: json['totalMonthlyBenefit'] as int? ?? 0,
      yearTotalBenefit: json['yearTotalBenefit'] as int? ?? json['yearTotalBenefit'] as int? ?? 0,
      period: json['period'] as String? ?? '2026',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'month': month,
      'bonusIncome': bonusIncome,
      'mortgageSavings': mortgageSavings,
      'dmsCompensation': dmsCompensation,
      'totalMonthlyBenefit': totalMonthlyBenefit,
      'yearTotalBenefit': yearTotalBenefit,
      'period': period,
    };
  }
}
