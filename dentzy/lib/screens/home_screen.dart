import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../services/language_provider.dart';
import '../services/app_tour_service.dart';
import '../l10n/app_localizations.dart';
import 'brushing_timer_screen.dart';
import 'dental_quiz_page.dart';
import 'learn_screen.dart';
import 'myth_checker_screen.dart';
import 'video_screen.dart';
import 'brushing_tracker_screen.dart';
import 'tracker_screen.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

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
  bool _tourInitiated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tourInitiated) {
      _tourInitiated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowTour();
      });
    }
  }

  Future<void> _checkAndShowTour() async {
    final hasSeenTour = await AppTourService.hasSeenTour();
    if (!hasSeenTour && mounted) {
      await AppTourService.showAppTour(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MythCheckerScreen()),
        ),
        icon: const Icon(Icons.auto_awesome),
        label: Text(loc.mythChecker),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const _HomeBackdrop(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.welcome,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                loc.readyForQuiz,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        _IconBubble(
                          icon: Icons.notifications_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _IconBubble(
                          icon: Icons.person_outline,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfilePage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE9FBF7), Color(0xFFDFF6F4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    loc.appName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                  Text(
                                    loc.quiz,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    loc.testYourKnowledgeAI,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 18),
                                  FilledButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const DentalQuizPage(),
                                      ),
                                    ),
                                    icon: const Icon(Icons.quiz_rounded),
                                    label: Text(loc.startQuiz),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const _HeroIllustration(),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: Text(
                      loc.quickActions,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate.fixed([
                      _buildActionCard(
                        context,
                        icon: Icons.auto_fix_high_rounded,
                        title: loc.mythChecker,
                        subtitle: loc.testYourKnowledge,
                        accent: AppTheme.primaryColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MythCheckerScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.menu_book_rounded,
                        title: loc.learn,
                        subtitle: loc.educationalContent,
                        accent: AppTheme.secondaryDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearnScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.timer_rounded,
                        title: loc.brushingTimer,
                        subtitle: loc.twoMinuteGuidedBrush,
                        accent: AppTheme.successColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BrushingTimerScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.brush_rounded,
                        title: loc.brushingTracker,
                        subtitle: loc.trackDailyBrushing,
                        accent: AppTheme.successColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BrushingTrackerScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.analytics_rounded,
                        title: loc.progress,
                        subtitle: loc.trackYourStats,
                        accent: AppTheme.successColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrackerScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.video_library_rounded,
                        title: loc.videos,
                        subtitle: loc.videoLessons,
                        accent: AppTheme.primaryDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VideoScreen(),
                          ),
                        ),
                      ),
                    ]),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          accent.withOpacity(0.18),
          Colors.white,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 26, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HomeBackdrop extends StatelessWidget {
  const _HomeBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FCFC), Color(0xFFF3FBFA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _SoftOrb(color: AppTheme.primaryLight.withOpacity(0.24)),
          ),
          Positioned(
            top: 180,
            left: -50,
            child: _SoftOrb(color: AppTheme.secondaryLight.withOpacity(0.22), size: 150),
          ),
        ],
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftOrb({required this.color, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBubble({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFBDF5EA), Color(0xFF8ED9D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tag_faces_rounded, color: Colors.white, size: 46),
          SizedBox(height: 10),
          Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
