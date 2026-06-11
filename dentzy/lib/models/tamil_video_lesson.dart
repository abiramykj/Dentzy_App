class TamilVideoLesson {
  final String title;
  final String subtitle;
  final String youtubeId;
  final String? videoUrlOverride;
  final String? thumbnailUrlOverride;

  const TamilVideoLesson({
    required this.title,
    required this.subtitle,
    required this.youtubeId,
    this.videoUrlOverride,
    this.thumbnailUrlOverride,
  });

  factory TamilVideoLesson.fromApi(
    Map<String, dynamic> json, {
    TamilVideoLesson? fallback,
  }) {
    final title = _firstNonEmptyString(
      json['title'],
      fallback?.title,
      'வீடியோ',
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

    return TamilVideoLesson(
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

const List<TamilVideoLesson> tamilOralHealthVideos = [
  TamilVideoLesson(
    title: 'பல் சுத்தம் ஏன் அவசியம்?',
    subtitle: 'தினசரி பல் பராமரிப்பு',
    youtubeId: '5KxRzRJ5ibY',
  ),
  TamilVideoLesson(
    title: 'சொத்தை பல்லை சரி செய்வது எப்படி?',
    subtitle: 'பல் சொத்தை தடுக்கும் வழிகள்',
    youtubeId: 'cmpq37aDRxQ',
  ),
  TamilVideoLesson(
    title: 'பல் இடுக்குகளை சுத்தம் செய்ய!',
    subtitle: 'பற்களை சரியாக சுத்தம் செய்வது',
    youtubeId: 'oZ2OEniOr7E',
  ),
  TamilVideoLesson(
    title: 'மஞ்சள் படிவம் வராமல் பல் துலக்குவது எப்படி?',
    subtitle: 'மஞ்சள் படிவம் வராமல் பாதுகாப்பு',
    youtubeId: 'ApRfmdqQ63A',
  ),
  TamilVideoLesson(
    title: 'ஈறில் இரத்தம் வருவது ஏன்? சிகிச்சை என்ன?',
    subtitle: 'ஈறு நோய் பற்றிய விழிப்புணர்வு',
    youtubeId: 'iziQ22xvt8o',
  ),
  TamilVideoLesson(
    title: 'பற்களின் பாதுகாப்பிற்கு இதை செய்யாதீர்கள்',
    subtitle: 'பற்களின் பாதுகாப்பு குறிப்புகள்',
    youtubeId: 'ft81iy8Xopo',
  ),
  TamilVideoLesson(
    title: 'பல் சொத்தை பற்றி குழந்தைகள் தெரிந்துகொள்ள வேண்டியது',
    subtitle: 'குழந்தைகளுக்கான பல் பராமரிப்பு',
    youtubeId: 'biD0tE-hYRE',
  ),
  TamilVideoLesson(
    title: 'ஈறுகளில் இரத்தக்கசிவா?',
    subtitle: 'ஈறு இரத்தக்கசிவு காரணங்கள்',
    youtubeId: 'iR92ycRDXXc',
  ),
];