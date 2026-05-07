import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../services/language_provider.dart';
import '../l10n/app_localizations.dart';
import 'dental_quiz_page.dart';
import 'myth_checker_screen.dart';
import 'learn_screen.dart';
import 'video_screen.dart';
import 'tracker_screen.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'brushing_timer_screen.dart';
import 'brushing_tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  final LanguageProvider languageProvider;

  const HomeScreen({
    super.key,
    required this.languageProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.appName),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.welcome,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.readyForQuiz,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DentalQuizPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(loc.startQuiz),
                  ),
                ],
              ),
            ),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppTheme.successColor, size: 32),
                          const SizedBox(height: 8),
                          const Text('25',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(loc.checked,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      child: Column(
                        children: [
                          const Icon(Icons.trending_up,
                              color: AppTheme.accentColor, size: 32),
                          const SizedBox(height: 8),
                          const Text('80%',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(loc.accuracy,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomCard(
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: AppTheme.errorColor, size: 32),
                          const SizedBox(height: 8),
                          const Text('7',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(loc.streak,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                loc.quickActions,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.quiz,
                  title: loc.mythChecker,
                  subtitle: loc.testYourKnowledge,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MythCheckerScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.book,
                  title: loc.learn,
                  subtitle: loc.educationalContent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LearnScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.trending_up,
                  title: loc.progress,
                  subtitle: loc.trackYourStats,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TrackerScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.video_library,
                  title: loc.videos,
                  subtitle: loc.videoLessons,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VideoScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.timer,
                  title: loc.brushingTimer,
                  subtitle: loc.twoMinuteGuidedBrush,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BrushingTimerScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.calendar_today,
                  title: loc.brushingTracker,
                  subtitle: loc.trackDailyBrushing,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BrushingTrackerScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryColor.withOpacity(0.8),
          AppTheme.primaryLight.withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
