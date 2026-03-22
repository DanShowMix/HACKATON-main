/// Deal model
class Deal {
  final String id;
  final String employeeId;
  final String clientName;
  final String productType;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deal({
    required this.id,
    required this.employeeId,
    required this.clientName,
    required this.productType,
    required this.amount,
    this.status = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'clientName': clientName,
      'productType': productType,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      clientName: json['clientName'] as String,
      productType: json['productType'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
    );
  }
}

/// DailyResult model
class DailyResult {
  final String id;
  final String employeeId;
  final String date;
  final int dealsCount;
  final double volume;
  final int productsCount;
  final DateTime createdAt;

  DailyResult({
    required this.id,
    required this.employeeId,
    required this.date,
    this.dealsCount = 0,
    this.volume = 0,
    this.productsCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date,
      'dealsCount': dealsCount,
      'volume': volume,
      'productsCount': productsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DailyResult.fromJson(Map<String, dynamic> json) {
    return DailyResult(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: json['date'] as String,
      dealsCount: json['dealsCount'] as int? ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
      productsCount: json['productsCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }
}

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int pointsReward;
  final String tier;
  final int target;
  final int progress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.pointsReward = 0,
    this.tier = 'bronze',
    this.target = 0,
    this.progress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconEmoji': iconEmoji,
      'pointsReward': pointsReward,
      'tier': tier,
      'target': target,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconEmoji: json['iconEmoji'] as String,
      pointsReward: json['pointsReward'] as int? ?? 0,
      tier: json['tier'] as String? ?? 'bronze',
      target: json['target'] as int? ?? 0,
      progress: json['progress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt'] as String) 
          : null,
    );
  }
}

/// Notification model
class Notification {
  final String id;
  final String employeeId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'dateTime': createdAt.toIso8601String(),
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }
}

/// Product model
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double? minRate;
  final double? maxRate;
  final int? minTerm;
  final int? maxTerm;
  final double? minAmount;
  final double? maxAmount;
  final String? iconEmoji;
  final bool isPopular;
  final int pointsMultiplier;
  final List<String> features;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.minRate,
    this.maxRate,
    this.minTerm,
    this.maxTerm,
    this.minAmount,
    this.maxAmount,
    this.iconEmoji,
    this.isPopular = false,
    this.pointsMultiplier = 1,
    this.features = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'minRate': minRate,
      'maxRate': maxRate,
      'minTerm': minTerm,
      'maxTerm': maxTerm,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'iconEmoji': iconEmoji,
      'isPopular': isPopular,
      'pointsMultiplier': pointsMultiplier,
      'features': features,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      minRate: (json['minRate'] as num?)?.toDouble(),
      maxRate: (json['maxRate'] as num?)?.toDouble(),
      minTerm: json['minTerm'] as int?,
      maxTerm: json['maxTerm'] as int?,
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      iconEmoji: json['iconEmoji'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      pointsMultiplier: json['pointsMultiplier'] as int? ?? 1,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : json['featuresStr'] != null
              ? (json['featuresStr'] as String).split('|').toList()
              : const [],
    );
  }
}

/// ChatMessage model
class ChatMessage {
  final String id;
  final String employeeId;
  final String text;
  final bool isFromUser;
  final String status;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.employeeId,
    required this.text,
    required this.isFromUser,
    this.status = 'sent',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'text': text,
      'isFromUser': isFromUser,
      'status': status,
      'timestamp': createdAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      text: json['text'] as String,
      isFromUser: json['isFromUser'] as bool,
      status: json['status'] as String? ?? 'sent',
      createdAt: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }
}

/// RatingDetail model
class RatingDetail {
  final String id;
  final String employeeId;
  final int volumePoints;
  final int dealsPoints;
  final int bankSharePoints;
  final int productsPoints;
  final int totalPoints;
  final DateTime calculatedAt;

  RatingDetail({
    required this.id,
    required this.employeeId,
    this.volumePoints = 0,
    this.dealsPoints = 0,
    this.bankSharePoints = 0,
    this.productsPoints = 0,
    this.totalPoints = 0,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'volume': {'points': volumePoints, 'info': '1 млн ₽ = 1 балл'},
      'deals': {'points': dealsPoints, 'info': '1 сделка = 2 балла'},
      'bankShare': {'points': bankSharePoints, 'info': '1% доли = 0.5 балла'},
      'products': {'points': productsPoints, 'info': '1 продукт = 1 балл'},
      'totalPoints': totalPoints,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory RatingDetail.fromJson(Map<String, dynamic> json) {
    return RatingDetail(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      volumePoints: json['volumePoints'] as int? ?? 0,
      dealsPoints: json['dealsPoints'] as int? ?? 0,
      bankSharePoints: json['bankSharePoints'] as int? ?? 0,
      productsPoints: json['productsPoints'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'] as String)
          : DateTime.now(),
    );
  }
}

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
  final DateTime calculatedAt;

  FinancialEffect({
    required this.id,
    required this.employeeId,
    this.bonusIncome = 0,
    this.mortgageSavings = 0,
    this.cashback = 0,
    this.dmsCost = 0,
    this.totalBenefit = 0,
    this.period = '2026',
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

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
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

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
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// MonthlyTask model - задача месяца
class MonthlyTask {
  final String id;
  final String employeeId;
  final String title;
  final String description;
  final int rewardPoints; // Награда в баллах
  final int targetValue; // Целевое значение
  final int currentValue; // Текущий прогресс
  final String deadline; // Дедлайн (например, "31 марта 2026")
  final bool isCompleted;
  final DateTime createdAt;

  MonthlyTask({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.description,
    this.rewardPoints = 0,
    this.targetValue = 0,
    this.currentValue = 0,
    this.deadline = '',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progressPercent => targetValue > 0 ? (currentValue / targetValue) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'title': title,
      'description': description,
      'rewardPoints': rewardPoints,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'progressPercent': progressPercent,
      'deadline': deadline,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MonthlyTask.fromJson(Map<String, dynamic> json) {
    return MonthlyTask(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rewardPoints: json['rewardPoints'] as int? ?? 0,
      targetValue: json['targetValue'] as int? ?? 0,
      currentValue: json['currentValue'] as int? ?? 0,
      deadline: json['deadline'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

/// MonthlyPlan model - планы на месяц
class MonthlyPlan {
  final String id;
  final String employeeId;
  final String month;
  final double volumePlan;
  final int dealsPlan;
  final double bankShareTarget;

  MonthlyPlan({
    required this.id,
    required this.employeeId,
    required this.month,
    this.volumePlan = 10.0,
    this.dealsPlan = 10,
    this.bankShareTarget = 50.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'month': month,
      'volumePlan': volumePlan,
      'dealsPlan': dealsPlan,
      'bankShareTarget': bankShareTarget,
    };
  }

  factory MonthlyPlan.fromJson(Map<String, dynamic> json) {
    return MonthlyPlan(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      month: json['month'] as String,
      volumePlan: (json['volumePlan'] as num?)?.toDouble() ?? 10.0,
      dealsPlan: json['dealsPlan'] as int? ?? 10,
      bankShareTarget: (json['bankShareTarget'] as num?)?.toDouble() ?? 50.0,
    );
  }
}

/// LoanApplication model - заявка на кредит
class LoanApplication {
  final String id;
  final String employeeId;
  final String clientName;
  final String productType;
  final double? amount;
  final String status; // submitted, approved, rejected

  LoanApplication({
    required this.id,
    required this.employeeId,
    required this.clientName,
    required this.productType,
    this.amount,
    this.status = 'submitted',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'clientName': clientName,
      'productType': productType,
      'amount': amount,
      'status': status,
    };
  }

  factory LoanApplication.fromJson(Map<String, dynamic> json) {
    return LoanApplication(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      clientName: json['clientName'] as String,
      productType: json['productType'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'submitted',
    );
  }
}

/// MonthlyRating model - ежемесячный рейтинг
class MonthlyRating {
  final String id;
  final String employeeId;
  final String month;
  final double volumeFact;
  final double volumePlan;
  final double volumeIndex;
  final int dealsFact;
  final int dealsPlan;
  final double dealsIndex;
  final double bankShareFact;
  final double bankShareTarget;
  final double bankShareIndex;
  final double conversionRate;
  final double conversionIndex;
  final double totalScore;
  final String level;

  MonthlyRating({
    required this.id,
    required this.employeeId,
    required this.month,
    this.volumeFact = 0,
    this.volumePlan = 10,
    this.volumeIndex = 0,
    this.dealsFact = 0,
    this.dealsPlan = 10,
    this.dealsIndex = 0,
    this.bankShareFact = 0,
    this.bankShareTarget = 50,
    this.bankShareIndex = 0,
    this.conversionRate = 0,
    this.conversionIndex = 0,
    this.totalScore = 0,
    this.level = 'Silver',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'month': month,
      'volume': {
        'fact': volumeFact,
        'plan': volumePlan,
        'index': volumeIndex,
      },
      'deals': {
        'fact': dealsFact,
        'plan': dealsPlan,
        'index': dealsIndex,
      },
      'bankShare': {
        'fact': bankShareFact,
        'target': bankShareTarget,
        'index': bankShareIndex,
      },
      'conversion': {
        'rate': conversionRate,
        'index': conversionIndex,
      },
      'totalScore': totalScore,
      'level': level,
    };
  }

  factory MonthlyRating.fromJson(Map<String, dynamic> json) {
    return MonthlyRating(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      month: json['month'] as String,
      volumeFact: (json['volumeFact'] as num?)?.toDouble() ?? 0,
      volumePlan: (json['volumePlan'] as num?)?.toDouble() ?? 10,
      volumeIndex: (json['volumeIndex'] as num?)?.toDouble() ?? 0,
      dealsFact: json['dealsFact'] as int? ?? 0,
      dealsPlan: json['dealsPlan'] as int? ?? 10,
      dealsIndex: (json['dealsIndex'] as num?)?.toDouble() ?? 0,
      bankShareFact: (json['bankShareFact'] as num?)?.toDouble() ?? 0,
      bankShareTarget: (json['bankShareTarget'] as num?)?.toDouble() ?? 50,
      bankShareIndex: (json['bankShareIndex'] as num?)?.toDouble() ?? 0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0,
      conversionIndex: (json['conversionIndex'] as num?)?.toDouble() ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0,
      level: json['level'] as String? ?? 'Silver',
    );
  }
}

/// EmployeeBenefit model - привилегии сотрудника
class EmployeeBenefit {
  final String id;
  final String employeeId;
  final bool hasSubscription;
  final List<String> subscriptionCategories;
  final double bonusPercent;
  final bool hasMortgage;
  final double mortgageRemaining;
  final double mortgageRate;
  final double mortgageDiscountPercent;
  final int dmsCompensation;

  EmployeeBenefit({
    required this.id,
    required this.employeeId,
    this.hasSubscription = false,
    this.subscriptionCategories = const [],
    this.bonusPercent = 0,
    this.hasMortgage = false,
    this.mortgageRemaining = 0,
    this.mortgageRate = 0,
    this.mortgageDiscountPercent = 0,
    this.dmsCompensation = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'hasSubscription': hasSubscription,
      'subscriptionCategories': subscriptionCategories,
      'bonusPercent': bonusPercent,
      'hasMortgage': hasMortgage,
      'mortgageRemaining': mortgageRemaining,
      'mortgageRate': mortgageRate,
      'mortgageDiscountPercent': mortgageDiscountPercent,
      'dmsCompensation': dmsCompensation,
    };
  }

  factory EmployeeBenefit.fromJson(Map<String, dynamic> json) {
    return EmployeeBenefit(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      hasSubscription: json['hasSubscription'] as bool? ?? false,
      subscriptionCategories: json['subscriptionCategories'] != null
          ? List<String>.from(json['subscriptionCategories'] as List)
          : [],
      bonusPercent: (json['bonusPercent'] as num?)?.toDouble() ?? 0,
      hasMortgage: json['hasMortgage'] as bool? ?? false,
      mortgageRemaining: (json['mortgageRemaining'] as num?)?.toDouble() ?? 0,
      mortgageRate: (json['mortgageRate'] as num?)?.toDouble() ?? 0,
      mortgageDiscountPercent: (json['mortgageDiscountPercent'] as num?)?.toDouble() ?? 0,
      dmsCompensation: json['dmsCompensation'] as int? ?? 0,
    );
  }
}

/// MonthlyBenefit model - ежемесячная выгода
class MonthlyBenefit {
  final String id;
  final String employeeId;
  final String month;
  final int bonusIncome;
  final int mortgageSavings;
  final int dmsCompensation;
  final int totalMonthlyBenefit;
  int yearTotalBenefit;

  MonthlyBenefit({
    required this.id,
    required this.employeeId,
    required this.month,
    this.bonusIncome = 0,
    this.mortgageSavings = 0,
    this.dmsCompensation = 0,
    this.totalMonthlyBenefit = 0,
    this.yearTotalBenefit = 0,
  });

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
    };
  }

  factory MonthlyBenefit.fromJson(Map<String, dynamic> json) {
    return MonthlyBenefit(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      month: json['month'] as String,
      bonusIncome: json['bonusIncome'] as int? ?? 0,
      mortgageSavings: json['mortgageSavings'] as int? ?? 0,
      dmsCompensation: json['dmsCompensation'] as int? ?? 0,
      totalMonthlyBenefit: json['totalMonthlyBenefit'] as int? ?? 0,
      yearTotalBenefit: json['yearTotalBenefit'] as int? ?? 0,
    );
  }
}
