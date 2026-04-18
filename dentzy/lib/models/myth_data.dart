/// Model for storing dental myths and facts
class MythData {
  final String id;
  final String text;
  final bool isMythOrFact; // true = Myth, false = Fact
  final String explanation;
  final String category;
  final List<String> keywords;

  MythData({
    required this.id,
    required this.text,
    required this.isMythOrFact,
    required this.explanation,
    required this.category,
    required this.keywords,
  });

  factory MythData.fromJson(Map<String, dynamic> json) {
    return MythData(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isMythOrFact: json['isMythOrFact'] ?? false,
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isMythOrFact': isMythOrFact,
      'explanation': explanation,
      'category': category,
      'keywords': keywords,
    };
  }
}

/// Result model for myth checking
class MythCheckResult {
  final String type; // 'Myth', 'Fact', 'Not Dental', 'Unknown'
  final String explanation;
  final double similarityScore; // 0.0 to 1.0
  final String? matchedText; // The matched myth/fact if found
  final String category;

  MythCheckResult({
    required this.type,
    required this.explanation,
    required this.similarityScore,
    this.matchedText,
    required this.category,
  });
}
