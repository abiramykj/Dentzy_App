class LearningResource {
  final String id;
  final String title;
  final String category;
  final String description;
  final String url;

  const LearningResource({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.url,
  });

  factory LearningResource.fromApi(
    Map<String, dynamic> json, {
    LearningResource? fallback,
  }) {
    final title = _firstNonEmptyString(
      json['title'],
      fallback?.title,
      'Untitled resource',
    );
    final description = _firstNonEmptyString(
      json['summary'],
      json['content'],
      fallback?.description,
      title,
    );
    final category = _firstNonEmptyString(
      json['category'],
      fallback?.category,
      'General',
    );
    final url = _firstNonEmptyString(
      json['url'],
      json['article_url'],
      fallback?.url,
      _fallbackSearchUrl(title),
    );
    final id = _firstNonEmptyString(
      json['id']?.toString(),
      fallback?.id,
      title,
    );

    return LearningResource(
      id: id,
      title: title,
      category: category,
      description: description,
      url: url,
    );
  }
}

String _fallbackSearchUrl(String title) {
  return 'https://www.google.com/search?q=${Uri.encodeComponent(title)}';
}

String _firstNonEmptyString([Object? value1, Object? value2, Object? value3, Object? value4, Object? value5]) {
  for (final candidate in [value1, value2, value3, value4, value5]) {
    final text = candidate?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '';
}