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
