import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final List<_Video> _videos = [
    _Video(
      id: '1',
      title: 'Proper Brushing Technique',
      description: 'Learn the correct way to brush your teeth',
      duration: '12:45',
      instructor: 'Dr. Sarah Johnson',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      views: 15420,
    ),
    _Video(
      id: '2',
      title: 'Understanding Tooth Decay',
      description: 'Discover the science behind cavity formation',
      duration: '8:30',
      instructor: 'Dr. Mike Chen',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      views: 9852,
    ),
    _Video(
      id: '3',
      title: 'Gum Health Essentials',
      description: 'Guide to maintaining healthy gums',
      duration: '10:15',
      instructor: 'Dr. Emily Rodriguez',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      views: 7234,
    ),
    _Video(
      id: '4',
      title: 'Flossing Like a Pro',
      description: 'Master the art of flossing',
      duration: '6:20',
      instructor: 'Dr. David Lee',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      views: 5623,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Video Lessons'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          if (_videos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFeaturedVideoCard(context, _videos[0]),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'More Videos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _videos.length - 1,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildVideoCard(context, _videos[index + 1]),
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
              color: AppTheme.primaryColor.withOpacity(0.1),
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
              color: AppTheme.primaryColor.withOpacity(0.1),
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
      if (await canLaunchUrl(Uri.parse(video.youtubeUrl))) {
        await launchUrl(Uri.parse(video.youtubeUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open video: $e')));
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
