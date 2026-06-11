import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/video_lesson.dart';
import '../models/tamil_video_lesson.dart';
import '../services/learning_content_api_service.dart';
import '../services/tracker_service.dart';
import '../utils/theme.dart';
import '../widgets/custom_card.dart';
import '../widgets/video_card.dart';
import '../widgets/tamil_video_card.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  List<VideoLesson> _englishVideos = englishOralHealthVideos;
  List<TamilVideoLesson> _tamilVideos = tamilOralHealthVideos;
  String? _loadedLanguageCode;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = _languageCodeFromContext(context);
    if (_loadedLanguageCode != languageCode) {
      _loadedLanguageCode = languageCode;
      unawaited(_loadVideosForLanguage(languageCode));
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  String _languageCodeFromContext(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ta' ? 'ta' : 'en';
  }

  Future<void> _loadVideosForLanguage(String languageCode) async {
    try {
      final apiItems = await LearningContentApiService.instance.fetchVideos(language: languageCode);
      if (!mounted) {
        return;
      }

      if (languageCode == 'ta') {
        final tamilVideos = apiItems.map((item) => TamilVideoLesson.fromApi(item)).toList();
        setState(() {
          _tamilVideos = tamilVideos;
        });
        return;
      }

      final englishVideos = apiItems.map((item) => VideoLesson.fromApi(item)).toList();
      setState(() {
        _englishVideos = englishVideos;
      });
    } catch (error) {
      debugPrint('[VideoScreen] API failed, using fallback: $error');
      if (!mounted) {
        return;
      }

      setState(() {
        if (languageCode == 'ta') {
          _tamilVideos = tamilOralHealthVideos;
        } else {
          _englishVideos = englishOralHealthVideos;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final String selectedLanguage =
        Localizations.localeOf(context).languageCode == 'ta' ? 'ta' : 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(loc.videoLessons),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: selectedLanguage == 'ta'
          ? _buildTamilContent(context)
          : _buildEnglishContent(context),
    );
  }

  Widget _buildEnglishContent(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oral health learning videos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Curated YouTube lessons for brushing, hygiene, cavities, flossing, and dental awareness.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.videoLessons,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        for (int index = 0; index < _englishVideos.length; index++) ...[
          VideoCard(
            video: _englishVideos[index],
            onTap: () => _openEnglishVideo(_englishVideos[index]),
            animation: CurvedAnimation(
              parent: _entryController,
              curve: Interval(
                0.08 + (index * 0.07),
                1.0,
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
          if (index != _englishVideos.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildTamilContent(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final videos = _tamilVideos;

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'தமிழ் பல் நல வீடியோக்கள்',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'பல் பராமரிப்பு, ஈறு நலம், சொத்தைத் தடுப்பு, மற்றும் தினசரி சுத்தம் பற்றிய சிறிய விளக்கங்கள்.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.videoLessons,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        for (int index = 0; index < videos.length; index++) ...[
          TamilVideoCard(
            video: videos[index],
            onTap: () => _openTamilVideo(videos[index]),
            animation: CurvedAnimation(
              parent: _entryController,
              curve: Interval(
                0.08 + (index * 0.08),
                1.0,
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
          if (index != videos.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Future<void> _openTamilVideo(TamilVideoLesson video) async {
    await _openYouTubeUrl(video.videoUrl, videoId: video.youtubeId);
  }

  Future<void> _openEnglishVideo(VideoLesson video) async {
    await _openYouTubeUrl(video.videoUrl, videoId: video.youtubeId);
  }

  Future<void> _openYouTubeUrl(String youtubeUrl, {required String videoId}) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final localizations = AppLocalizations.of(context);
    final invalidMessage = localizations?.error ?? 'Invalid YouTube URL';
    final unavailableMessage = localizations?.error ?? 'No app available to open this video';
    final failedMessage = localizations?.error ?? 'Could not open video';
    final exceptionPrefix = localizations?.error ?? 'Error opening video';

    try {
      final Uri videoUri = Uri.parse(youtubeUrl);

      if (!_isValidYouTubeUrl(videoUri)) {
        _showErrorSnackBar(messenger, invalidMessage);
        return;
      }

      if (!await canLaunchUrl(videoUri)) {
        _showErrorSnackBar(messenger, unavailableMessage);
        return;
      }

      final bool launched = await launchUrl(
        videoUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showErrorSnackBar(messenger, failedMessage);
      } else {
        unawaited(TrackerService.instance.markVideoWatched(videoId));
      }
    } catch (e) {
      _showErrorSnackBar(messenger, '$exceptionPrefix: $e');
    }
  }

  Widget _buildFeaturedVideoCard(BuildContext context, _Video video) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      onTap: () => _openVideo(video),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 180,
              color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 80, color: AppTheme.primaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            video.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            video.description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(video.instructor, style: const TextStyle(fontSize: 12))),
              Icon(Icons.visibility, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${(video.views / 1000).toStringAsFixed(1)}K', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, _Video video) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      onTap: () => _openVideo(video),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 60,
              color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
              child: const Icon(Icons.play_circle_outline, size: 30, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(video.instructor, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(video.duration, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(width: 8),
                    Icon(Icons.visibility, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text('${(video.views / 1000).toStringAsFixed(1)}K',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVideo(_Video video) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final localizations = AppLocalizations.of(context);
    final invalidMessage = localizations?.error ?? 'Invalid YouTube URL';
    final unavailableMessage = localizations?.error ?? 'No app available to open this video';
    final failedMessage = localizations?.error ?? 'Could not open video';
    final exceptionPrefix = localizations?.error ?? 'Error opening video';

    try {
      final Uri videoUri = Uri.parse(video.youtubeUrl);
      
      // Validate YouTube URL
      if (!_isValidYouTubeUrl(videoUri)) {
        _showErrorSnackBar(messenger, invalidMessage); // TODO: add specific key
        return;
      }

      // Check if URL can be launched
      if (!await canLaunchUrl(videoUri)) {
        _showErrorSnackBar(messenger, unavailableMessage); // TODO: add specific key
        return;
      }

      // Launch the URL
      final bool launched = await launchUrl(
        videoUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showErrorSnackBar(messenger, failedMessage); // TODO: add specific key
      }
    } catch (e) {
      _showErrorSnackBar(messenger, '$exceptionPrefix: $e');
    }
  }

  /// Validates if a URI is a valid YouTube URL
  bool _isValidYouTubeUrl(Uri uri) {
    final String host = uri.host.toLowerCase();
    final String path = uri.path;

    // Check for various YouTube URL formats
    if (host.contains('youtube.com')) {
      // Standard YouTube video: youtube.com/watch?v=VIDEO_ID
      return uri.queryParameters.containsKey('v') && 
             uri.queryParameters['v']!.isNotEmpty;
    } else if (host.contains('youtu.be')) {
      // Shortened YouTube URL: youtu.be/VIDEO_ID
      return path.isNotEmpty && path.length > 1;
    }

    return false;
  }

  /// Shows error message in a SnackBar
  void _showErrorSnackBar(ScaffoldMessengerState? messenger, String message) {
    if (mounted && messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _Video {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String instructor;
  final String youtubeUrl;
  final int views;

  _Video({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.instructor,
    required this.youtubeUrl,
    required this.views,
  });
}
