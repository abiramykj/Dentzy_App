class UserProgress {
  final String id;
  final int articlesRead;
  final int activitiesCompleted;
  final int challengesCompleted;
  final int pdfsRead;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final int totalPoints;
  final Map<String, int> categoryProgress; // category -> progress percentage

  UserProgress({
    required this.id,
    this.articlesRead = 0,
    this.activitiesCompleted = 0,
    this.challengesCompleted = 0,
    this.pdfsRead = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActivityDate,
    this.totalPoints = 0,
    this.categoryProgress = const {},
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] ?? '',
      articlesRead: json['articlesRead'] ?? 0,
      activitiesCompleted: json['activitiesCompleted'] ?? 0,
      challengesCompleted: json['challengesCompleted'] ?? 0,
      pdfsRead: json['pdfsRead'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivityDate: DateTime.parse(json['lastActivityDate'] ?? DateTime.now().toString()),
      totalPoints: json['totalPoints'] ?? 0,
      categoryProgress: Map<String, int>.from(json['categoryProgress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articlesRead': articlesRead,
      'activitiesCompleted': activitiesCompleted,
      'challengesCompleted': challengesCompleted,
      'pdfsRead': pdfsRead,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate.toString(),
      'totalPoints': totalPoints,
      'categoryProgress': categoryProgress,
    };
  }
}
