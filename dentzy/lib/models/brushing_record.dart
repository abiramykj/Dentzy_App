class BrushingRecord {
  final String memberId;
  final String date; // Format: yyyy-MM-dd
  final bool morning;
  final bool night;

  BrushingRecord({
    required this.memberId,
    required this.date,
    required this.morning,
    required this.night,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'date': date,
      'morning': morning,
      'night': night,
    };
  }

  // Create from JSON
  factory BrushingRecord.fromJson(Map<String, dynamic> json) {
    return BrushingRecord(
      memberId: json['memberId'] as String,
      date: json['date'] as String,
      morning: json['morning'] as bool,
      night: json['night'] as bool,
    );
  }

  // Get today's date in yyyy-MM-dd format
  static String getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Get date for n days ago
  static String getDateNDaysAgo(int days) {
    final date = DateTime.now().subtract(Duration(days: days));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
