class InteractiveActivity {
  final String id;
  final String titleEn;
  final String titleTa;
  final String descriptionEn;
  final String descriptionTa;
  final String activityType; // 'sorting', 'checklist', 'matching', 'challenge'
  final String iconType;
  final int durationMinutes;
  final List<String> itemsEn;
  final List<String> itemsTa;
  final List<String> correctAnswers;
  bool isCompleted;
  int score;

  InteractiveActivity({
    required this.id,
    required this.titleEn,
    required this.titleTa,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.activityType,
    required this.iconType,
    required this.durationMinutes,
    required this.itemsEn,
    required this.itemsTa,
    required this.correctAnswers,
    this.isCompleted = false,
    this.score = 0,
  });

  factory InteractiveActivity.fromJson(Map<String, dynamic> json) {
    return InteractiveActivity(
      id: json['id'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleTa: json['titleTa'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      descriptionTa: json['descriptionTa'] ?? '',
      activityType: json['activityType'] ?? 'sorting',
      iconType: json['iconType'] ?? 'games',
      durationMinutes: json['durationMinutes'] ?? 10,
      itemsEn: List<String>.from(json['itemsEn'] ?? []),
      itemsTa: List<String>.from(json['itemsTa'] ?? []),
      correctAnswers: List<String>.from(json['correctAnswers'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleTa': titleTa,
      'descriptionEn': descriptionEn,
      'descriptionTa': descriptionTa,
      'activityType': activityType,
      'iconType': iconType,
      'durationMinutes': durationMinutes,
      'itemsEn': itemsEn,
      'itemsTa': itemsTa,
      'correctAnswers': correctAnswers,
      'isCompleted': isCompleted,
      'score': score,
    };
  }
}
