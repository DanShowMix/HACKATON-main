class Employee {
  final String fullName;
  final String dealerCode;
  final String position;
  final String level; // Silver, Gold, Black
  final int currentPoints;
  final int nextLevelPoints;
  final int dealsCount;
  final double volume; // в млн руб
  final double bankShare; // в %
  final int annualBenefit; // в рублях

  Employee({
    required this.fullName,
    required this.dealerCode,
    required this.position,
    required this.level,
    required this.currentPoints,
    required this.nextLevelPoints,
    required this.dealsCount,
    required this.volume,
    required this.bankShare,
    required this.annualBenefit,
  });

  int get pointsToNextLevel => nextLevelPoints - currentPoints;

  double get progressPercent => (currentPoints / nextLevelPoints) * 100;
}
