class PDFResource {
  final String id;
  final String titleEn;
  final String titleTa;
  final String descriptionEn;
  final String descriptionTa;
  final String categoryEn;
  final String categoryTa;
  final String pdfUrl;
  final String thumbnailUrl;
  final int pages;
  final DateTime uploadDate;
  bool isDownloaded;
  bool isBookmarked;
  int readPages;

  PDFResource({
    required this.id,
    required this.titleEn,
    required this.titleTa,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.categoryEn,
    required this.categoryTa,
    required this.pdfUrl,
    required this.thumbnailUrl,
    required this.pages,
    required this.uploadDate,
    this.isDownloaded = false,
    this.isBookmarked = false,
    this.readPages = 0,
  });

  factory PDFResource.fromJson(Map<String, dynamic> json) {
    return PDFResource(
      id: json['id'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleTa: json['titleTa'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      descriptionTa: json['descriptionTa'] ?? '',
      categoryEn: json['categoryEn'] ?? '',
      categoryTa: json['categoryTa'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      pages: json['pages'] ?? 0,
      uploadDate: DateTime.parse(json['uploadDate'] ?? DateTime.now().toString()),
      isDownloaded: json['isDownloaded'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      readPages: json['readPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleTa': titleTa,
      'descriptionEn': descriptionEn,
      'descriptionTa': descriptionTa,
      'categoryEn': categoryEn,
      'categoryTa': categoryTa,
      'pdfUrl': pdfUrl,
      'thumbnailUrl': thumbnailUrl,
      'pages': pages,
      'uploadDate': uploadDate.toString(),
      'isDownloaded': isDownloaded,
      'isBookmarked': isBookmarked,
      'readPages': readPages,
    };
  }
}
