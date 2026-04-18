import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/family_provider.dart';
import '../services/settings_provider.dart';
import '../services/brushing_service.dart';
import '../services/achievement_service.dart';
import '../services/progress_service.dart';
import '../models/family_member.dart';
import '../models/achievement.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
        title: const Text('Profile & Family'),
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
                  const Text(
                    'My Profile',
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
                    'Your Statistics',
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
                              Text('Myths Checked',
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
                              Text('Accuracy',
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
                              Text('Day Streak',
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
                    'Family Members',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddFamilyMemberDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
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
                            'No family members yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add family members to track their brushing habits',
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
                'Achievements 🏆',
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
                    return const Center(child: Text('No achievements'));
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
                                'Achievements Unlocked',
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
                                      child: const Text('Close'),
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
                'Brushing Progress 📊',
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
                            'Select a family member to view progress',
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

                      final brushingData = snapshot.data!;
                      final progress =
                          ProgressService.getAllProgress(memberId, brushingData);

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
                                    const Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      progress['daily']!['status'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  progress['daily']!['display'],
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
                                    const Text(
                                      'This Week',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      progress['weekly']!['status'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  progress['weekly']!['display'],
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
                                    const Text(
                                      'This Month',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      progress['monthly']!['status'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  progress['monthly']!['display'],
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
                'Reminders ⏰',
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
                                  'Enable Reminders',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Receive brushing notifications',
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
                                          ? '🔔 Reminders enabled'
                                          : '🔕 Reminders disabled',
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
                                  const Text(
                                    'Morning Reminder',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to change time',
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
                                  const Text(
                                    'Night Reminder',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to change time',
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(
    BuildContext context,
    FamilyMember member,
    FamilyProvider familyProvider,
  ) {
    final isSelected = familyProvider.selectedMember?.id == member.id;

    return GestureDetector(
      onTap: () {
        familyProvider.selectFamilyMember(member);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.name} selected for tracking'),
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
                          member.relation!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${member.age} years',
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
                  child: const Text('Edit'),
                  onTap: () => _showEditFamilyMemberDialog(context, member),
                ),
                PopupMenuItem(
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String? selectedRelation;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Family Member'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRelation,
                  decoration: const InputDecoration(
                    labelText: 'Relation (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Father',
                    'Mother',
                    'Child',
                    'Sibling',
                    'Grandparent',
                    'Aunt/Uncle',
                    'Cousin',
                    'Friend',
                  ]
                      .map((relation) => DropdownMenuItem(
                            value: relation,
                            child: Text(relation),
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
            child: const Text('Cancel'),
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditFamilyMemberDialog(BuildContext context, FamilyMember member) {
    final nameController = TextEditingController(text: member.name);
    final ageController = TextEditingController(text: member.age.toString());
    String? selectedRelation = member.relation;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Family Member'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRelation,
                  decoration: const InputDecoration(
                    labelText: 'Relation (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Father',
                    'Mother',
                    'Child',
                    'Sibling',
                    'Grandparent',
                    'Aunt/Uncle',
                    'Cousin',
                    'Friend',
                  ]
                      .map((relation) => DropdownMenuItem(
                            value: relation,
                            child: Text(relation),
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
            child: const Text('Cancel'),
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FamilyMember member,
      FamilyProvider familyProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Member?'),
        content: Text('Are you sure you want to remove ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              familyProvider.deleteFamilyMember(member.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
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
