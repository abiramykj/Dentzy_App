class EducationalArticle {
  final String id;
  final String titleEn;
  final String titleTa;
  final String categoryEn;
  final String categoryTa;
  final String summaryEn;
  final String summaryTa;
  final String contentEn;
  final String contentTa;
  final int readTimeMinutes;
  final String imageUrl;
  final DateTime createdDate;
  final List<String> tagsEn;
  final List<String> tagsTa;
  bool isBookmarked;
  bool isRead;
  int readProgress;

  EducationalArticle({
    required this.id,
    required this.titleEn,
    required this.titleTa,
    required this.categoryEn,
    required this.categoryTa,
    required this.summaryEn,
    required this.summaryTa,
    required this.contentEn,
    required this.contentTa,
    required this.readTimeMinutes,
    required this.imageUrl,
    required this.createdDate,
    required this.tagsEn,
    required this.tagsTa,
    this.isBookmarked = false,
    this.isRead = false,
    this.readProgress = 0,
  });

  factory EducationalArticle.fromJson(Map<String, dynamic> json) {
    return EducationalArticle(
      id: json['id'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleTa: json['titleTa'] ?? '',
      categoryEn: json['categoryEn'] ?? '',
      categoryTa: json['categoryTa'] ?? '',
      summaryEn: json['summaryEn'] ?? '',
      summaryTa: json['summaryTa'] ?? '',
      contentEn: json['contentEn'] ?? '',
      contentTa: json['contentTa'] ?? '',
      readTimeMinutes: json['readTimeMinutes'] ?? 5,
      imageUrl: json['imageUrl'] ?? '',
      createdDate: DateTime.parse(json['createdDate'] ?? DateTime.now().toString()),
      tagsEn: List<String>.from(json['tagsEn'] ?? []),
      tagsTa: List<String>.from(json['tagsTa'] ?? []),
      isBookmarked: json['isBookmarked'] ?? false,
      isRead: json['isRead'] ?? false,
      readProgress: json['readProgress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleTa': titleTa,
      'categoryEn': categoryEn,
      'categoryTa': categoryTa,
      'summaryEn': summaryEn,
      'summaryTa': summaryTa,
      'contentEn': contentEn,
      'contentTa': contentTa,
      'readTimeMinutes': readTimeMinutes,
      'imageUrl': imageUrl,
      'createdDate': createdDate.toString(),
      'tagsEn': tagsEn,
      'tagsTa': tagsTa,
      'isBookmarked': isBookmarked,
      'isRead': isRead,
      'readProgress': readProgress,
    };
  }
}
