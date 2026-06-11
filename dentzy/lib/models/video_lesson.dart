class VideoLesson {
  final String title;
  final String subtitle;
  final String youtubeId;
  final String? videoUrlOverride;
  final String? thumbnailUrlOverride;

  const VideoLesson({
    required this.title,
    required this.subtitle,
    required this.youtubeId,
    this.videoUrlOverride,
    this.thumbnailUrlOverride,
  });

  factory VideoLesson.fromApi(
    Map<String, dynamic> json, {
    VideoLesson? fallback,
  }) {
    final title = _firstNonEmptyString(
      json['title'],
      fallback?.title,
      'Video lesson',
    );
    final subtitle = _firstNonEmptyString(
      json['description'],
      json['summary'],
      fallback?.subtitle,
      title,
    );
    final videoUrl = _firstNonEmptyString(
      json['video_url'],
      json['videoUrl'],
      fallback?.youtubeUrl,
      '',
    );
    final thumbnailUrl = _firstNonEmptyString(
      json['thumbnail_url'],
      json['thumbnailUrl'],
      fallback?.thumbnailUrl,
      '',
    );
    final youtubeId = _extractYouTubeId(videoUrl) ?? fallback?.youtubeId ?? '';

    return VideoLesson(
      title: title,
      subtitle: subtitle,
      youtubeId: youtubeId,
      videoUrlOverride: videoUrl.trim().isNotEmpty ? videoUrl.trim() : null,
      thumbnailUrlOverride: thumbnailUrl.trim().isNotEmpty ? thumbnailUrl.trim() : null,
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  String get thumbnailUrl => thumbnailUrlOverride ?? 'https://img.youtube.com/vi/$youtubeId/0.jpg';

  String get videoUrl => videoUrlOverride ?? youtubeUrl;
}

String? _extractYouTubeId(String url) {
  final normalized = url.trim();
  if (normalized.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(normalized);
  if (uri == null) {
    return null;
  }

  final host = uri.host.toLowerCase();
  if (host.contains('youtube.com')) {
    final videoId = uri.queryParameters['v']?.trim() ?? '';
    return videoId.isEmpty ? null : videoId;
  }

  if (host.contains('youtu.be')) {
    final segments = uri.pathSegments.where((segment) => segment.trim().isNotEmpty).toList();
    if (segments.isNotEmpty) {
      return segments.first.trim();
    }
  }

  return null;
}

String _firstNonEmptyString([Object? value1, Object? value2, Object? value3, Object? value4]) {
  for (final candidate in [value1, value2, value3, value4]) {
    final text = candidate?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '';
}

const List<VideoLesson> englishOralHealthVideos = [
  VideoLesson(
    title: 'Proper Brushing Techniques',
    subtitle: 'Proper brushing for healthy teeth',
    youtubeId: '7kGXQDwT6IA',
  ),
  VideoLesson(
    title: 'Oral Health Care Routine',
    subtitle: 'Daily oral care habits',
    youtubeId: '5J89gCDt_rk',
  ),
  VideoLesson(
    title: 'Kids Oral Care',
    subtitle: 'Fun dental care for children',
    youtubeId: 'aOebfGGcjVw',
  ),
  VideoLesson(
    title: 'Oral Hygiene',
    subtitle: 'Complete oral hygiene basics',
    youtubeId: '9fI_hEz2oM0',
  ),
  VideoLesson(
    title: 'Oral and General Health Animation',
    subtitle: 'Connection between oral and body health',
    youtubeId: 'Ge9WGTp5y3o',
  ),
  VideoLesson(
    title: 'How Cavities Develop From Tooth Decay',
    subtitle: 'Understand cavity formation',
    youtubeId: '79VQZueHn9o',
  ),
  VideoLesson(
    title: 'Flossing Technique',
    subtitle: 'Correct flossing method',
    youtubeId: 'm3pBA4cgdxw',
  ),
  VideoLesson(
    title: 'Gum Disease',
    subtitle: 'Learn about gum infections',
    youtubeId: 'f8aqBbEtsz0',
  ),
  VideoLesson(
    title: 'Dental Awareness',
    subtitle: 'Improve dental health awareness',
    youtubeId: '9Qa2K1CC3Hw',
  ),
];