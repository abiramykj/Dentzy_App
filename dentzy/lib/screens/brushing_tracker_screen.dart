import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../services/family_provider.dart';
import '../services/brushing_service.dart';
import '../models/family_member.dart';

class BrushingTrackerScreen extends StatefulWidget {
  const BrushingTrackerScreen({super.key});

  @override
  State<BrushingTrackerScreen> createState() => _BrushingTrackerScreenState();
}

class _BrushingTrackerScreenState extends State<BrushingTrackerScreen> {
  late BrushingService _brushingService;
  String? _selectedMemberId;
  int _selectedViewIndex = 0; // 0=Daily, 1=Weekly, 2=Monthly

  @override
  void initState() {
    super.initState();
    _brushingService = BrushingService();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _brushingService.initialize();
    setState(() {
      // Set default selected member to first family member if available
      final familyProvider = context.read<FamilyProvider>();
      if (familyProvider.familyMembers.isNotEmpty) {
        _selectedMemberId = familyProvider.familyMembers[0].id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = context.watch<FamilyProvider>();

    if (familyProvider.familyMembers.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Brushing Tracker'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No family members added',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Add family members in the Profile section to start tracking',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Ensure selected member exists
    if (_selectedMemberId == null ||
        !familyProvider.familyMembers.any((m) => m.id == _selectedMemberId)) {
      _selectedMemberId = familyProvider.familyMembers[0].id;
    }

    final selectedMember = familyProvider.familyMembers
        .firstWhere((m) => m.id == _selectedMemberId);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Brushing Tracker'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Member Selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: DropdownButton<String>(
                  value: _selectedMemberId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: familyProvider.familyMembers
                      .map((member) => DropdownMenuItem(
                            value: member.id,
                            child: Text(
                              member.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMemberId = value;
                      });
                    }
                  },
                ),
              ),
            ),

            // View Selector Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabButton('Daily', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('Weekly', 1),
                  const SizedBox(width: 8),
                  _buildTabButton('Monthly', 2),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content based on selected view
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildViewContent(selectedMember),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedViewIndex == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedViewIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppTheme.primaryColor
              : AppTheme.dividerColor,
          foregroundColor: isSelected ? Colors.white : AppTheme.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildViewContent(FamilyMember member) {
    switch (_selectedViewIndex) {
      case 0:
        return _buildDailyView(member);
      case 1:
        return _buildWeeklyView(member);
      case 2:
        return _buildMonthlyView(member);
      default:
        return _buildDailyView(member);
    }
  }

  Widget _buildDailyView(FamilyMember member) {
    final todayStatus = _brushingService.getTodayStatus(member.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Status Card
        CustomCard(
          padding: const EdgeInsets.all(20),
          gradient: AppTheme.primaryGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Brushing Status",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusColumn(
                    'Morning',
                    todayStatus['morning'] ?? false,
                  ),
                  _buildStatusColumn(
                    'Night',
                    todayStatus['night'] ?? false,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Mark Brushing Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (todayStatus['morning'] ?? false) {
                    await _brushingService.unmarkMorningBrushing(member.id);
                  } else {
                    await _brushingService.markMorningBrushing(member.id);
                  }
                  setState(() {});
                },
                icon: Icon(
                  todayStatus['morning'] ?? false
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                label: const Text('Mark Morning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: todayStatus['morning'] ?? false
                      ? AppTheme.successColor
                      : AppTheme.dividerColor,
                  foregroundColor:
                      todayStatus['morning'] ?? false ? Colors.white : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (todayStatus['night'] ?? false) {
                    await _brushingService.unmarkNightBrushing(member.id);
                  } else {
                    await _brushingService.markNightBrushing(member.id);
                  }
                  setState(() {});
                },
                icon: Icon(
                  todayStatus['night'] ?? false
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                label: const Text('Mark Night'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: todayStatus['night'] ?? false
                      ? AppTheme.successColor
                      : AppTheme.dividerColor,
                  foregroundColor:
                      todayStatus['night'] ?? false ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Tips Section
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Brushing Tips',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '• Brush for at least 2 minutes\n'
                '• Brush twice daily (morning & night)\n'
                '• Use gentle, circular motions\n'
                '• Don\'t forget the back teeth\n'
                '• Floss after brushing',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyView(FamilyMember member) {
    final weeklyStats = _brushingService.getWeeklyStats(member.id);
    final weeklyData = weeklyStats['data'] as Map<String, Map<String, bool>>;
    final total = weeklyStats['total'] as int;
    final percentage = weeklyStats['percentage'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Summary
        CustomCard(
          padding: const EdgeInsets.all(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.accentColor.withOpacity(0.8),
              AppTheme.accentColor.withOpacity(0.4),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total/14',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('brushings'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('completion'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total / 14,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Weekly Details
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last 7 Days',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...weeklyData.entries.map((entry) {
                final date = entry.key;
                final status = entry.value;
                final displayDate = _formatDateShort(date);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(displayDate)),
                      _buildStatusBadge(status['morning'] ?? false, 'M'),
                      const SizedBox(width: 8),
                      _buildStatusBadge(status['night'] ?? false, 'N'),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyView(FamilyMember member) {
    final monthlyStats = _brushingService.getMonthlyStats(member.id);
    final total = monthlyStats['total'] as int;
    final percentage = monthlyStats['percentage'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Summary
        CustomCard(
          padding: const EdgeInsets.all(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.successColor.withOpacity(0.8),
              AppTheme.successColor.withOpacity(0.4),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Progress',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total/60',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('brushings'),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('completion'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total / 60,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Monthly Summary
        CustomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Total Brushings', '$total/60'),
              const Divider(),
              _buildStatRow('Completion Rate', '$percentage%'),
              const Divider(),
              _buildStatRow('Days Tracked', '30 days'),
              const Divider(),
              _buildStatRow('Average per Day', (total / 30).toStringAsFixed(1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusColumn(String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.successColor
                : Colors.grey[300],
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.close,
            color: isCompleted ? Colors.white : Colors.grey[600],
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildStatusBadge(bool isCompleted, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.successColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isCompleted ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDateShort(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final day = parts[2];
        final month = parts[1];
        final monthNames = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        final monthName = monthNames[int.parse(month)];
        return '$monthName $day';
      }
    } catch (e) {
      // Ignore
    }
    return date;
  }
}
