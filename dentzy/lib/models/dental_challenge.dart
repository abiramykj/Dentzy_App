class DentalChallenge {
  final String id;
  final String titleEn;
  final String titleTa;
  final String descriptionEn;
  final String descriptionTa;
  final String benefitsEn;
  final String benefitsTa;
  final int durationDays;
  final String iconType;
  int currentDay;
  bool isActive;
  bool isCompleted;
  int completionPercentage;

  DentalChallenge({
    required this.id,
    required this.titleEn,
    required this.titleTa,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.benefitsEn,
    required this.benefitsTa,
    required this.durationDays,
    required this.iconType,
    this.currentDay = 0,
    this.isActive = false,
    this.isCompleted = false,
    this.completionPercentage = 0,
  });

  factory DentalChallenge.fromJson(Map<String, dynamic> json) {
    return DentalChallenge(
      id: json['id'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleTa: json['titleTa'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      descriptionTa: json['descriptionTa'] ?? '',
      benefitsEn: json['benefitsEn'] ?? '',
      benefitsTa: json['benefitsTa'] ?? '',
      durationDays: json['durationDays'] ?? 7,
      iconType: json['iconType'] ?? 'challenge',
      currentDay: json['currentDay'] ?? 0,
      isActive: json['isActive'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      completionPercentage: json['completionPercentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleTa': titleTa,
      'descriptionEn': descriptionEn,
      'descriptionTa': descriptionTa,
      'benefitsEn': benefitsEn,
      'benefitsTa': benefitsTa,
      'durationDays': durationDays,
      'iconType': iconType,
      'currentDay': currentDay,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'completionPercentage': completionPercentage,
    };
  }
}
