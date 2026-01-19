// Enum para Status do Desafio
enum ChallengeStatus {
  ASSIGNED,
  COMPLETED,
  SKIPPED,
  FAILED;

  static ChallengeStatus fromString(String value) {
    return ChallengeStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ChallengeStatus.ASSIGNED,
    );
  }
}

class DashboardModel {
  final String displayName;
  final String? avatar;
  final String motivationQuote;
  final String date;
  final ProgressModel progress;
  final List<UserDailyChallengeModel> dailyChallenges;

  DashboardModel({
    required this.displayName,
    this.avatar,
    required this.motivationQuote,
    required this.date,
    required this.progress,
    required this.dailyChallenges,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      displayName: json['displayName'] ?? 'User',
      avatar: json['avatar'],
      motivationQuote: json['motivationQuote'] ?? '',
      date: json['date'] ?? '',
      progress: ProgressModel.fromJson(json['progress']),
      dailyChallenges: (json['dailyChallenges'] as List)
          .map((e) => UserDailyChallengeModel.fromJson(e))
          .toList(),
    );
  }
}

class ProgressModel {
  final int level;
  final int currentXp;
  final int xpForNextLevel;
  final double progressPercentage;
  final int currentStreak;

  ProgressModel({
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.progressPercentage,
    required this.currentStreak,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      xpForNextLevel: json['xpForNextLevel'] ?? 100,
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
    );
  }
}

class UserDailyChallengeModel {
  final String id; // ID da atribuição (usado para completar/pular)
  final ChallengeDetailModel challenge;
  final String status; // String vinda da API
  final ChallengeStatus statusEnum; // Enum facilitador
  final DateTime updatedAt;

  UserDailyChallengeModel({
    required this.id,
    required this.challenge,
    required this.status,
    required this.statusEnum,
    required this.updatedAt,

  });

  factory UserDailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return UserDailyChallengeModel(
      id: json['id'],
      challenge: ChallengeDetailModel.fromJson(json['challenge']),
      status: json['status'],
      statusEnum: ChallengeStatus.fromString(json['status']),
      // Parse da String ISO 8601 para DateTime
      // Fallback para 'now' caso venha nulo para evitar crash
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ChallengeDetailModel {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final String categoryName;
  final String icon;

  ChallengeDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.categoryName,
    required this.icon,
  });

  factory ChallengeDetailModel.fromJson(Map<String, dynamic> json) {
    return ChallengeDetailModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      xpReward: json['xpReward'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}
