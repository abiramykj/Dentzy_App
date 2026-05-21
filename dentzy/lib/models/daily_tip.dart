class DailyTip {
  final String id;
  final String tipEn;
  final String tipTa;
  final String categoryEn;
  final String categoryTa;
  final String iconType; // 'brush', 'floss', 'food', 'prevention', 'habit'
  final DateTime dateCreated;
  bool isViewed;

  DailyTip({
    required this.id,
    required this.tipEn,
    required this.tipTa,
    required this.categoryEn,
    required this.categoryTa,
    required this.iconType,
    required this.dateCreated,
    this.isViewed = false,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['id'] ?? '',
      tipEn: json['tipEn'] ?? '',
      tipTa: json['tipTa'] ?? '',
      categoryEn: json['categoryEn'] ?? '',
      categoryTa: json['categoryTa'] ?? '',
      iconType: json['iconType'] ?? 'brush',
      dateCreated: DateTime.parse(json['dateCreated'] ?? DateTime.now().toString()),
      isViewed: json['isViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipEn': tipEn,
      'tipTa': tipTa,
      'categoryEn': categoryEn,
      'categoryTa': categoryTa,
      'iconType': iconType,
      'dateCreated': dateCreated.toString(),
      'isViewed': isViewed,
    };
  }
}
