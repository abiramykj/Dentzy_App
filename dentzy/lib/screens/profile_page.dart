import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/family_provider.dart';
import '../services/settings_provider.dart';
import '../services/brushing_service.dart';
import '../services/achievement_service.dart';
import '../services/progress_service.dart';
import '../services/app_tour_service.dart';
import '../services/language_provider.dart';
import '../models/family_member.dart';
import '../models/achievement.dart';
import 'startup_flow_screen.dart';

class ProfilePage extends StatefulWidget {
  final LanguageProvider languageProvider;

  const ProfilePage({
    super.key,
    required this.languageProvider,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Initialize FamilyProvider when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.profileFamily),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.myProfile,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.yourStatistics,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomCard(
                          child: Column(
                            children: [
                              const Text('125',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                                Text(loc.mythsChecked,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomCard(
                          child: Column(
                            children: [
                              const Text('82.5%',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.successColor)),
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
                              const Text('12',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentColor)),
                              const SizedBox(height: 4),
                                Text(loc.dayStreak,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Family Members Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.familyMembers,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddFamilyMemberDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(loc.add),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Family Members List
            Consumer<FamilyProvider>(
              builder: (context, familyProvider, _) {
                if (familyProvider.familyMembers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.noFamilyMembersYet,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.addFamilyMembersTrackBrushing,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: familyProvider.familyMembers
                        .map((member) =>
                            _buildFamilyMemberCard(context, member, familyProvider))
                        .toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Achievements Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${loc.achievements} 🏆',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<List<Achievement>>(
                future: _loadAchievements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(child: Text(loc.noAchievements));
                  }

                  final achievements = snapshot.data!;
                  final unlockedCount =
                      achievements.where((a) => a.unlocked).length;

                  return Column(
                    children: [
                      // Achievement count
                      CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                '$unlockedCount / ${achievements.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc.achievementsUnlocked,
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Achievement badges
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: achievements.map((achievement) {
                          return GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(achievement.title),
                                  content: Text(achievement.description),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: Text(loc.close),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 80,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: achievement.unlocked
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: achievement.unlocked
                                      ? AppTheme.primaryColor
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    achievement.icon,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievement.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Progress Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${loc.brushingProgress} 📊',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<FamilyProvider>(
                builder: (context, familyProvider, _) {
                  if (familyProvider.selectedMember == null) {
                    return CustomCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            loc.selectFamilyMember,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }

                  final memberId = familyProvider.selectedMember!.id;
                  final brushingService = BrushingService();

                  return FutureBuilder<Map<String, Map<String, Map<String, bool>>>>(
                    future: brushingService.loadBrushingData(),
                    builder: (context, snapshot) {
                      // Check for errors
                      if (snapshot.hasError) {
                        return CustomCard(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                loc.errorLoadingProgressData,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        );
                      }

                      // Show loading indicator
                      if (!snapshot.hasData) {
                        return CustomCard(
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      final brushingData = snapshot.data ?? {};

                      // Check if this member has any brushing data
                      if (brushingData.isEmpty || brushingData[memberId] == null) {
                        return CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  loc.noBrushingDataAvailable,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  loc.startBrushingToSeeProgress,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Get progress with safe defaults
                      final progress =
                          ProgressService.getAllProgress(memberId, brushingData);

                      // Safely access progress values with defaults
                      final dailyStatus =
                          progress['daily']?['status'] as String? ?? '0/2';
                      final dailyDisplay =
                          progress['daily']?['display'] as String? ?? '0%';
                      final weeklyStatus =
                          progress['weekly']?['status'] as String? ?? '0/14';
                      final weeklyDisplay =
                          progress['weekly']?['display'] as String? ?? '0%';
                      final monthlyStatus =
                          progress['monthly']?['status'] as String? ?? '0/60';
                      final monthlyDisplay =
                          progress['monthly']?['display'] as String? ?? '0%';

                      return Column(
                        children: [
                          // Daily
                          CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.today,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dailyStatus,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  dailyDisplay,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Weekly
                          CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.thisWeek,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      weeklyStatus,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  weeklyDisplay,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Monthly
                          CustomCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.thisMonth,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      monthlyStatus,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  monthlyDisplay,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Reminders Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${loc.reminders} ⏰',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<SettingsProvider>(
                builder: (context, settingsProvider, _) {
                  return Column(
                    children: [
                      // Enable/Disable Reminders
                      CustomCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.enableReminders,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.receiveBrushingNotifications,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Switch(
                              value: settingsProvider.remindersEnabled,
                              onChanged: (value) {
                                settingsProvider.toggleReminders(value);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value
                                          ? '🔔 ${loc.remindersEnabled}'
                                          : '🔕 ${loc.remindersDisabled}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Morning time picker
                      CustomCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: settingsProvider.morningReminderTime,
                            );
                            if (picked != null) {
                              await settingsProvider
                                  .setMorningReminderTime(picked);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.morningReminder,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.tapToChangeTime,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  settingsProvider.morningTimeDisplay,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Night time picker
                      CustomCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: settingsProvider.nightReminderTime,
                            );
                            if (picked != null) {
                              await settingsProvider
                                  .setNightReminderTime(picked);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.nightReminder,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.tapToChangeTime,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  settingsProvider.nightTimeDisplay,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // App Tour Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${loc.appTour} 🎯',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomCard(
                onTap: () async {
                  await AppTourService.resetTour();
                  if (mounted) {
                    await AppTourService.showAppTour(context);
                  }
                },
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.primaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.replayAppTour,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Learn all features step-by-step',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Logout Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                loc.preferences,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomCard(
                onTap: _showLogoutConfirmation,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF7F7), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0x1AF05A5A),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.logout,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE74C3C),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.logoutSubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFE57373)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final loc = AppLocalizations.of(context)!;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(loc.logoutConfirmTitle),
          content: Text(loc.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(loc.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
              child: Text(loc.logout),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await AuthService.initialize();
    await AuthService.setLoggedOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => StartupFlowScreen(languageProvider: widget.languageProvider),
      ),
      (route) => false,
    );
  }

  Widget _buildFamilyMemberCard(
    BuildContext context,
    FamilyMember member,
    FamilyProvider familyProvider,
  ) {
    final loc = AppLocalizations.of(context)!;
    final isSelected = familyProvider.selectedMember?.id == member.id;

    return GestureDetector(
      onTap: () {
        familyProvider.selectFamilyMember(member);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.name} ${loc.selectedForTracking}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryLight.withOpacity(0.1),
                ],
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (member.relation != null)
                        Text(
                          _localizeRelation(member.relation!, loc),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.age}: ${member.age} ${loc.years}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(loc.edit),
                  onTap: () => _showEditFamilyMemberDialog(context, member),
                ),
                PopupMenuItem(
                  child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
                  onTap: () => _confirmDelete(context, member, familyProvider),
                ),
              ],
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
              ),
          ],
        ),
      ),
    );
  }

  void _showAddFamilyMemberDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String? selectedRelation;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.addFamilyMember),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.name,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: loc.age,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRelation,
                  decoration: InputDecoration(
                    labelText: loc.relationOptional,
                    border: OutlineInputBorder(),
                  ),
                  items: _relationKeys
                      .map((relation) => DropdownMenuItem(
                            value: relation,
                            child: Text(_localizeRelation(relation, loc)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRelation = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  ageController.text.isNotEmpty) {
                context.read<FamilyProvider>().addFamilyMember(
                      name: nameController.text,
                      age: int.parse(ageController.text),
                      relation: selectedRelation,
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: Text(loc.add),
          ),
        ],
      ),
    );
  }

  static const List<String> _relationKeys = [
    'Father',
    'Mother',
    'Child',
    'Sibling',
    'Grandparent',
    'Aunt/Uncle',
    'Cousin',
    'Friend',
  ];

  String _localizeRelation(String relation, AppLocalizations loc) {
    switch (relation) {
      case 'Father':
        return loc.father;
      case 'Mother':
        return loc.mother;
      case 'Child':
        return loc.child;
      case 'Sibling':
        return loc.sibling;
      case 'Grandparent':
        return loc.grandparent;
      case 'Aunt/Uncle':
        return loc.auntUncle;
      case 'Cousin':
        return loc.cousin;
      case 'Friend':
        return loc.friend;
      default:
        return relation;
    }
  }

  void _showEditFamilyMemberDialog(BuildContext context, FamilyMember member) {
    final loc = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: member.name);
    final ageController = TextEditingController(text: member.age.toString());
    String? selectedRelation = member.relation;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.editFamilyMember),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.name,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: loc.age,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRelation,
                  decoration: InputDecoration(
                    labelText: loc.relationOptional,
                    border: OutlineInputBorder(),
                  ),
                  items: _relationKeys
                      .map((relation) => DropdownMenuItem(
                            value: relation,
                            child: Text(_localizeRelation(relation, loc)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRelation = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  ageController.text.isNotEmpty) {
                context.read<FamilyProvider>().updateFamilyMember(
                      member.copyWith(
                        name: nameController.text,
                        age: int.parse(ageController.text),
                        relation: selectedRelation,
                      ),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: Text(loc.update),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FamilyMember member,
      FamilyProvider familyProvider) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.deleteMemberQuestion),
        content: Text(loc.confirmRemoveMember(member.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              familyProvider.deleteFamilyMember(member.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
  }

  // Load achievements for selected member
  Future<List<Achievement>> _loadAchievements() async {
    final familyProvider = context.read<FamilyProvider>();
    final brushingService = BrushingService();

    if (familyProvider.selectedMember == null) {
      return AchievementService.allAchievements;
    }

    final memberId = familyProvider.selectedMember!.id;
    final brushingData = await brushingService.loadBrushingData();

    return AchievementService.checkAchievements(memberId, brushingData);
  }
}
