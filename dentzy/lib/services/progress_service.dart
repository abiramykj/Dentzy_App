import 'package:intl/intl.dart';
import 'brushing_service.dart';

class ProgressService {
  // Calculate daily progress (0/2, 1/2, or 2/2 converted to percentage)
  static Map<String, dynamic> getDailyProgress(
    String memberId,
    Map<String, Map<String, Map<String, bool>>> brushingData,
  ) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final memberData = brushingData[memberId];
    if (memberData == null) {
      return {
        'completed': 0,
        'total': 2,
        'percentage': 0,
        'display': '0%',
      };
    }

    final todayData = memberData[todayStr];
    int completed = 0;

    if (todayData != null) {
      if (todayData['morning'] == true) completed++;
      if (todayData['night'] == true) completed++;
    }

    int percentage = (completed / 2 * 100).toInt();

    return {
      'completed': completed,
      'total': 2,
      'percentage': percentage,
      'display': '$percentage%',
      'status': '${completed}/2',
    };
  }

  // Calculate weekly progress (total out of 14)
  static Map<String, dynamic> getWeeklyProgress(
    String memberId,
    Map<String, Map<String, Map<String, bool>>> brushingData,
  ) {
    final memberData = brushingData[memberId];
    if (memberData == null) {
      return {
        'completed': 0,
        'total': 14,
        'percentage': 0,
        'display': '0%',
      };
    }

    int total = 0;
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final dateData = memberData[dateStr];
      if (dateData != null) {
        if (dateData['morning'] == true) total++;
        if (dateData['night'] == true) total++;
      }
    }

    int percentage = (total / 14 * 100).toInt();

    return {
      'completed': total,
      'total': 14,
      'percentage': percentage,
      'display': '$percentage%',
      'status': '$total/14',
    };
  }

  // Calculate monthly progress (total out of 60)
  static Map<String, dynamic> getMonthlyProgress(
    String memberId,
    Map<String, Map<String, Map<String, bool>>> brushingData,
  ) {
    final memberData = brushingData[memberId];
    if (memberData == null) {
      return {
        'completed': 0,
        'total': 60,
        'percentage': 0,
        'display': '0%',
      };
    }

    int total = 0;
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final dateData = memberData[dateStr];
      if (dateData != null) {
        if (dateData['morning'] == true) total++;
        if (dateData['night'] == true) total++;
      }
    }

    int percentage = (total / 60 * 100).toInt();

    return {
      'completed': total,
      'total': 60,
      'percentage': percentage,
      'display': '$percentage%',
      'status': '$total/60',
    };
  }

  // Get all progress at once
  static Map<String, Map<String, dynamic>> getAllProgress(
    String memberId,
    Map<String, Map<String, Map<String, bool>>> brushingData,
  ) {
    return {
      'daily': getDailyProgress(memberId, brushingData),
      'weekly': getWeeklyProgress(memberId, brushingData),
      'monthly': getMonthlyProgress(memberId, brushingData),
    };
  }
}
