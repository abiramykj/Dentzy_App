class MythLearningCard {
  final String id;
  final String mythEn;
  final String mythTa;
  final String truthEn;
  final String truthTa;
  final String explanationEn;
  final String explanationTa;
  final String sourceEn;
  final String sourceTa;
  final List<String> scientificFactsEn;
  final List<String> scientificFactsTa;
  final String iconType;
  bool isExpanded;
  bool isLearned;

  MythLearningCard({
    required this.id,
    required this.mythEn,
    required this.mythTa,
    required this.truthEn,
    required this.truthTa,
    required this.explanationEn,
    required this.explanationTa,
    required this.sourceEn,
    required this.sourceTa,
    required this.scientificFactsEn,
    required this.scientificFactsTa,
    required this.iconType,
    this.isExpanded = false,
    this.isLearned = false,
  });

  factory MythLearningCard.fromJson(Map<String, dynamic> json) {
    return MythLearningCard(
      id: json['id'] ?? '',
      mythEn: json['mythEn'] ?? '',
      mythTa: json['mythTa'] ?? '',
      truthEn: json['truthEn'] ?? '',
      truthTa: json['truthTa'] ?? '',
      explanationEn: json['explanationEn'] ?? '',
      explanationTa: json['explanationTa'] ?? '',
      sourceEn: json['sourceEn'] ?? '',
      sourceTa: json['sourceTa'] ?? '',
      scientificFactsEn: List<String>.from(json['scientificFactsEn'] ?? []),
      scientificFactsTa: List<String>.from(json['scientificFactsTa'] ?? []),
      iconType: json['iconType'] ?? 'lightbulb',
      isExpanded: json['isExpanded'] ?? false,
      isLearned: json['isLearned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mythEn': mythEn,
      'mythTa': mythTa,
      'truthEn': truthEn,
      'truthTa': truthTa,
      'explanationEn': explanationEn,
      'explanationTa': explanationTa,
      'sourceEn': sourceEn,
      'sourceTa': sourceTa,
      'scientificFactsEn': scientificFactsEn,
      'scientificFactsTa': scientificFactsTa,
      'iconType': iconType,
      'isExpanded': isExpanded,
      'isLearned': isLearned,
    };
  }
}
