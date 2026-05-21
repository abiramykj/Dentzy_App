class Bookmark {
  final String id;
  final String resourceId;
  final String resourceType; // 'article', 'pdf', 'activity', 'challenge'
  final String resourceTitle;
  final DateTime bookmarkedDate;

  Bookmark({
    required this.id,
    required this.resourceId,
    required this.resourceType,
    required this.resourceTitle,
    required this.bookmarkedDate,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? '',
      resourceId: json['resourceId'] ?? '',
      resourceType: json['resourceType'] ?? '',
      resourceTitle: json['resourceTitle'] ?? '',
      bookmarkedDate: DateTime.parse(json['bookmarkedDate'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resourceId': resourceId,
      'resourceType': resourceType,
      'resourceTitle': resourceTitle,
      'bookmarkedDate': bookmarkedDate.toString(),
    };
  }
}
