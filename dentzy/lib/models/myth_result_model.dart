class MythResultModel {
  final String id;
  final String mythId;
  final String mythTitle;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final DateTime checkedAt;
  final double confidenceScore;
  final String explanation;
  final String category;

  MythResultModel({
    required this.id,
    required this.mythId,
    required this.mythTitle,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.checkedAt,
    required this.confidenceScore,
    required this.explanation,
    required this.category,
  });

  factory MythResultModel.fromJson(Map<String, dynamic> json) {
    return MythResultModel(
      id: json['id'] ?? '',
      mythId: json['mythId'] ?? '',
      mythTitle: json['mythTitle'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      checkedAt: DateTime.parse(json['checkedAt'] ?? DateTime.now().toIso8601String()),
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mythId': mythId,
      'mythTitle': mythTitle,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'checkedAt': checkedAt.toIso8601String(),
      'confidenceScore': confidenceScore,
      'explanation': explanation,
      'category': category,
    };
  }
}
