/// Employee model
class Employee {
  final String id;
  final String fullName;
  final String dealerCode;
  final String position;
  final String? phone;
  final String? email;
  final String level;
  final int currentPoints;
  final int nextLevelPoints;
  final int dealsCount;
  final double volume;
  final double bankShare;
  final int annualBenefit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.fullName,
    required this.dealerCode,
    required this.position,
    this.phone,
    this.email,
    this.level = 'Silver',
    this.currentPoints = 0,
    this.nextLevelPoints = 100,
    this.dealsCount = 0,
    this.volume = 0,
    this.bankShare = 0,
    this.annualBenefit = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get pointsToNextLevel => nextLevelPoints - currentPoints;

  double get progressPercent => (currentPoints / nextLevelPoints) * 100;

  String getNextLevel() {
    switch (level) {
      case 'Silver':
        return 'Gold';
      case 'Gold':
        return 'Black';
      default:
        return 'Platinum';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dealerCode': dealerCode,
      'position': position,
      'phone': phone,
      'email': email,
      'level': level,
      'currentPoints': currentPoints,
      'nextLevelPoints': nextLevelPoints,
      'dealsCount': dealsCount,
      'volume': volume,
      'bankShare': bankShare,
      'annualBenefit': annualBenefit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pointsToNextLevel': pointsToNextLevel,
      'progressPercent': progressPercent,
      'nextLevel': getNextLevel(),
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      dealerCode: json['dealerCode'] as String,
      position: json['position'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      level: json['level'] as String? ?? 'Silver',
      currentPoints: json['currentPoints'] as int? ?? 0,
      nextLevelPoints: json['nextLevelPoints'] as int? ?? 100,
      dealsCount: json['dealsCount'] as int? ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
      bankShare: (json['bankShare'] as num?)?.toDouble() ?? 0,
      annualBenefit: json['annualBenefit'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
    );
  }
}

/// User model for authentication
class User {
  final String id;
  final String email;
  final String passwordHash;
  final String? employeeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    this.employeeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'employeeId': employeeId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      employeeId: json['employeeId'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
    );
  }
}
