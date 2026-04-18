import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import 'brushing_service.dart';

class AchievementService {
  static const String _achievementsKey = 'achievements';

  // Achievement definitions
  static final List<Achievement> _allAchievements = [
    Achievement(
      id: 'first_brush',
      title: 'First Step',
      description: 'Complete your first brushing session',
      icon: '🦷',
    ),
    Achievement(
      id: 'perfect_day',
      title: 'Perfect Day',
      description: 'Brush both morning and night in one day',
      icon: '⭐',
    ),
    Achievement(
      id: 'week_warrior',
      title: '7 Day Warrior',
      description: 'Maintain a 7-day brushing streak',
      icon: '🔥',
    ),
    Achievement(
      id: 'month_master',
      title: 'Month Master',
      description: 'Brush regularly for a full month',
      icon: '👑',
    ),
    Achievement(
      id: '50_brushes',
      title: '50 Brushes',
      description: 'Complete 50 total brushing sessions',
      icon: '💪',
    ),
    Achievement(
      id: '100_brushes',
      title: 'Century Club',
      description: 'Complete 100 total brushing sessions',
      icon: '🏆',
    ),
  ];

  // Public getter for all achievements
  static List<Achievement> get allAchievements => _allAchievements;

  // Load achievements from SharedPreferences
  static Future<List<Achievement>> loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_achievementsKey);

      if (jsonString == null || jsonString.isEmpty) {
        // First time - initialize all as locked
        await saveAchievements(_allAchievements);
        return _allAchievements;
      }

      final dynamic decoded = jsonDecode(jsonString);
      final List<dynamic> jsonList = decoded is List ? decoded : [];
      
      if (jsonList.isEmpty) {
        return _allAchievements;
      }
      
      return jsonList
          .map((json) {
            if (json is Map<String, dynamic>) {
              return Achievement.fromJson(json);
            }
            return null;
          })
          .whereType<Achievement>()
          .toList();
    } catch (e) {
      print('Error loading achievements: $e');
      return _allAchievements;
    }
  }

  // Save achievements to SharedPreferences
  static Future<void> saveAchievements(List<Achievement> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          jsonEncode(achievements.map((a) => a.toJson()).toList());
      await prefs.setString(_achievementsKey, jsonString);
    } catch (e) {
      print('Error saving achievements: $e');
    }
  }

  // Check and unlock achievements based on brushing data
  static Future<List<Achievement>> checkAchievements(
    String memberId,
    Map<String, Map<String, Map<String, bool>>> brushingData,
  ) async {
    List<Achievement> achievements = await loadAchievements();

    if (brushingData.isEmpty) return achievements;

    final memberData = brushingData[memberId];
    if (memberData == null) return achievements;

    // Get today's date
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    int totalBrushes = 0;
    int consecutiveDays = 0;
    bool perfectTodayExists = false;

    // Calculate total brushes
    for (var dateData in memberData.values) {
      if (dateData['morning'] == true) totalBrushes++;
      if (dateData['night'] == true) totalBrushes++;
    }

    // Check for perfect day (today)
    final todayData = memberData[todayStr];
    if (todayData != null &&
        todayData['morning'] == true &&
        todayData['night'] == true) {
      perfectTodayExists = true;
    }

    // Calculate consecutive days (streak)
    var checkDate = now;
    for (int i = 0; i < 365; i++) {
      final dateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      final dateData = memberData[dateStr];

      if (dateData != null &&
          dateData['morning'] == true &&
          dateData['night'] == true) {
        consecutiveDays++;
      } else {
        break;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Unlock achievements
    achievements = achievements.map((achievement) {
      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_brush':
          shouldUnlock = totalBrushes > 0;
          break;
        case 'perfect_day':
          shouldUnlock = perfectTodayExists;
          break;
        case 'week_warrior':
          shouldUnlock = consecutiveDays >= 7;
          break;
        case 'month_master':
          shouldUnlock = consecutiveDays >= 30;
          break;
        case '50_brushes':
          shouldUnlock = totalBrushes >= 50;
          break;
        case '100_brushes':
          shouldUnlock = totalBrushes >= 100;
          break;
      }

      if (shouldUnlock && !achievement.unlocked) {
        return achievement.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        );
      }

      return achievement;
    }).toList();

    // Save updated achievements
    await saveAchievements(achievements);
    return achievements;
  }
}
