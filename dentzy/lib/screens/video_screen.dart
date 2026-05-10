import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late final Map<String, List<_Video>> videoData = {
    'en': [
      _Video(
        id: '1',
        title: 'Proper Brushing Technique',
        description: 'Learn the correct way to brush your teeth effectively',
        duration: '5:32',
        instructor: 'Dr. Smith',
        youtubeUrl: 'https://www.youtube.com/watch?v=3oG6Y9cFz6k',
        views: 45000,
      ),
      _Video(
        id: '2',
        title: 'How to Choose Toothpaste',
        description: 'Find the right toothpaste for your dental needs',
        duration: '4:15',
        instructor: 'Dr. Johnson',
        youtubeUrl: 'https://www.youtube.com/watch?v=Jf9Zz1nRZ8c',
        views: 32000,
      ),
      _Video(
        id: '3',
        title: 'Oral Hygiene Basics',
        description: 'Master the fundamentals of oral hygiene',
        duration: '6:20',
        instructor: 'Dr. Lee',
        youtubeUrl: 'https://www.youtube.com/watch?v=7dJ7k8b9g1k',
        views: 58000,
      ),
      _Video(
        id: '4',
        title: 'Flossing Correctly',
        description: 'Perfect your flossing technique',
        duration: '3:45',
        instructor: 'Dr. Brown',
        youtubeUrl: 'https://www.youtube.com/watch?v=wxM7QvHc8s8',
        views: 29000,
      ),
      _Video(
        id: '5',
        title: 'Prevent Tooth Decay',
        description: 'Effective strategies to prevent cavities',
        duration: '7:10',
        instructor: 'Dr. Williams',
        youtubeUrl: 'https://www.youtube.com/watch?v=VhP8Xz0s2f4',
        views: 67000,
      ),
      _Video(
        id: '6',
        title: 'Morning & Night Routine',
        description: 'Establish a healthy daily oral care routine',
        duration: '5:00',
        instructor: 'Dr. Miller',
        youtubeUrl: 'https://www.youtube.com/watch?v=8F3m7gX2k3s',
        views: 51000,
      ),
      _Video(
        id: '7',
        title: 'Toothpaste Ingredients Explained',
        description: 'Understand what makes good toothpaste',
        duration: '4:50',
        instructor: 'Dr. Davis',
        youtubeUrl: 'https://www.youtube.com/watch?v=R6nYk8f3L0o',
        views: 38000,
      ),
      _Video(
        id: '8',
        title: 'Common Brushing Mistakes',
        description: 'Avoid these common dental hygiene errors',
        duration: '3:30',
        instructor: 'Dr. Garcia',
        youtubeUrl: 'https://www.youtube.com/watch?v=9gH2JkL4m2A',
        views: 44000,
      ),
      _Video(
        id: '9',
        title: 'Kids Dental Care',
        description: 'Tips for keeping children\'s teeth healthy',
        duration: '6:15',
        instructor: 'Dr. Martinez',
        youtubeUrl: 'https://www.youtube.com/watch?v=Q7kT2F9n3s8',
        views: 72000,
      ),
      _Video(
        id: '10',
        title: 'Healthy Teeth Tips',
        description: 'General guidance for maintaining healthy teeth',
        duration: '4:40',
        instructor: 'Dr. Taylor',
        youtubeUrl: 'https://www.youtube.com/watch?v=Z8kF3gL9p1Q',
        views: 55000,
      ),
    ],
    'ta': [
      _Video(
        id: '11',
        title: 'சரியான பல் துலக்கும் முறை',
        description: 'பல் துலக்கும் சரியான முறையை கற்றுக்கொள்ளுங்கள்',
        duration: '5:32',
        instructor: 'ডॉ. ஸ்மிથ்',
        youtubeUrl: 'https://www.youtube.com/watch?v=2fKzQxXvG6Q',
        views: 42000,
      ),
      _Video(
        id: '12',
        title: 'பல் துலக்கும் முக்கியம்',
        description: 'தினந்தோறும் பல் துலக்குவதின் महत्ता',
        duration: '4:20',
        instructor: 'ডॉ. जонсन',
        youtubeUrl: 'https://www.youtube.com/watch?v=5dR9kJ2nL8Y',
        views: 35000,
      ),
      _Video(
        id: '13',
        title: 'வாய்நலம் பராமரிப்பு',
        description: 'வாய்நலத்தை பராமரிப்பதற்கான வழிகள்',
        duration: '6:00',
        instructor: 'ডॉ. லீ',
        youtubeUrl: 'https://www.youtube.com/watch?v=8gT2LkF3P1Q',
        views: 48000,
      ),
      _Video(
        id: '14',
        title: 'பல் கெடுதல் தவிர்ப்பது எப்படி',
        description: 'பல் கெடுவதை தவிர்ப்பதற்கான टिप्स',
        duration: '5:45',
        instructor: 'ডॉ. ब्राউन',
        youtubeUrl: 'https://www.youtube.com/watch?v=7kJ2L9M4N0A',
        views: 38000,
      ),
      _Video(
        id: '15',
        title: 'நல்ல பல் பழக்கங்கள்',
        description: 'ஆரோக்கியமான பல் பழக்கங்களை பின்பற்றுங்கள்',
        duration: '4:55',
        instructor: 'ডॉ. williams',
        youtubeUrl: 'https://www.youtube.com/watch?v=4pK9F3G2L8M',
        views: 41000,
      ),
      _Video(
        id: '16',
        title: 'இரவு பல் துலக்கும் அவசியம்',
        description: 'இரவு பல் துலக்குவதின் महत्ता',
        duration: '3:50',
        instructor: 'ডॉ. மिller',
        youtubeUrl: 'https://www.youtube.com/watch?v=3F2kL9N8Q1X',
        views: 33000,
      ),
      _Video(
        id: '17',
        title: 'பல் மருத்துவர் ஆலோசனை',
        description: 'पल मरुत्वुवर एलोचनै',
        duration: '5:30',
        instructor: 'ডॉ. davis',
        youtubeUrl: 'https://www.youtube.com/watch?v=6J8kF3M2P0L',
        views: 36000,
      ),
      _Video(
        id: '18',
        title: 'பல் பாதுகாப்பு வழிகள்',
        description: 'पल पाधुकप्पु वलिगल',
        duration: '6:10',
        instructor: 'ডौ. garcia',
        youtubeUrl: 'https://www.youtube.com/watch?v=9K2L4F8G1M0',
        views: 39000,
      ),
      _Video(
        id: '19',
        title: 'பல் துலக்கும் தவறுகள்',
        description: 'पल दुलक्कुम तवरुकल',
        duration: '4:25',
        instructor: 'ডॉ. martinez',
        youtubeUrl: 'https://www.youtube.com/watch?v=1F8K3L2M9Q0',
        views: 34000,
      ),
      _Video(
        id: '20',
        title: 'வாய்நலம் முக்கியம்',
        description: 'वय नलम मुक्कियम',
        duration: '5:00',
        instructor: 'ডॉ. taylor',
        youtubeUrl: 'https://www.youtube.com/watch?v=5K2L9F3G8M1',
        views: 43000,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final String selectedLanguage = Localizations.localeOf(context).languageCode == 'ta' ? 'ta' : 'en';
    final List<_Video> videos = videoData[selectedLanguage] ?? videoData['en'] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.videoLessons),
        elevation: 0,
      ),
      body: ListView(
        children: [
          if (videos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFeaturedVideoCard(context, videos.first),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context)?.videoLessons ?? 'More Videos', // TODO: add specific key for "More Videos"
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: videos.isNotEmpty ? videos.length - 1 : 0,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildVideoCard(context, videos[index + 1]),
              );
            },
          ),
        ],
      ),
    );
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
    try {
      final Uri videoUri = Uri.parse(video.youtubeUrl);
      
      // Validate YouTube URL
      if (!_isValidYouTubeUrl(videoUri)) {
        _showErrorSnackBar(AppLocalizations.of(context)?.error ?? 'Invalid YouTube URL'); // TODO: add specific key
        return;
      }

      // Check if URL can be launched
      if (!await canLaunchUrl(videoUri)) {
        _showErrorSnackBar(AppLocalizations.of(context)?.error ?? 'No app available to open this video'); // TODO: add specific key
        return;
      }

      // Launch the URL
      final bool launched = await launchUrl(
        videoUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showErrorSnackBar(AppLocalizations.of(context)?.error ?? 'Could not open video'); // TODO: add specific key
      }
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)?.error ?? 'Error opening video: $e');
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
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
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
