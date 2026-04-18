import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/brushing_record.dart';

class BrushingService {
  static const String _storageKey = 'brushing_records';
  SharedPreferences? _prefs;

  // Map<memberId, Map<date, {morning: bool, night: bool}>>
  late Map<String, Map<String, Map<String, bool>>> _brushingData;

  BrushingService() {
    _brushingData = {};
  }

  // Initialize service and load data
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  // Load brushing data from SharedPreferences
  Future<void> _loadData() async {
    try {
      // Get JSON string with default empty map if not found
      final jsonString = _prefs?.getString(_storageKey) ?? '{}';
      
      // Safely decode JSON
      final Map<String, dynamic> decodedData = jsonDecode(jsonString) as Map<String, dynamic>? ?? {};
      _brushingData = {};
      
      // Parse each member's data
      decodedData.forEach((memberId, dateMap) {
        _brushingData[memberId] = {};
        
        if (dateMap is Map) {
          dateMap.forEach((date, brushingStatus) {
            if (date is! String) return;
            if (brushingStatus is Map) {
              _brushingData[memberId]![date] = {
                'morning': brushingStatus['morning'] as bool? ?? false,
                'night': brushingStatus['night'] as bool? ?? false,
              };
            }
          });
        }
      });
    } catch (e) {
      print('Error loading brushing data: $e');
      _brushingData = {};
    }
  }

  // Save brushing data to SharedPreferences
  Future<void> _saveData() async {
    final jsonString = jsonEncode(_brushingData);
    await _prefs?.setString(_storageKey, jsonString);
  }

  // Mark morning brushing for a member
  Future<void> markMorningBrushing(String memberId) async {
    final date = BrushingRecord.getTodayDate();
    _brushingData.putIfAbsent(memberId, () => {});
    _brushingData[memberId]!.putIfAbsent(date, () => {'morning': false, 'night': false});
    _brushingData[memberId]![date]!['morning'] = true;
    await _saveData();
  }

  // Mark night brushing for a member
  Future<void> markNightBrushing(String memberId) async {
    final date = BrushingRecord.getTodayDate();
    _brushingData.putIfAbsent(memberId, () => {});
    _brushingData[memberId]!.putIfAbsent(date, () => {'morning': false, 'night': false});
    _brushingData[memberId]![date]!['night'] = true;
    await _saveData();
  }

  // Unmark morning brushing for a member
  Future<void> unmarkMorningBrushing(String memberId) async {
    final date = BrushingRecord.getTodayDate();
    _brushingData.putIfAbsent(memberId, () => {});
    _brushingData[memberId]!.putIfAbsent(date, () => {'morning': false, 'night': false});
    _brushingData[memberId]![date]!['morning'] = false;
    await _saveData();
  }

  // Unmark night brushing for a member
  Future<void> unmarkNightBrushing(String memberId) async {
    final date = BrushingRecord.getTodayDate();
    _brushingData.putIfAbsent(memberId, () => {});
    _brushingData[memberId]!.putIfAbsent(date, () => {'morning': false, 'night': false});
    _brushingData[memberId]![date]!['night'] = false;
    await _saveData();
  }

  // Get today's brushing status for a member
  Map<String, bool> getTodayStatus(String memberId) {
    final date = BrushingRecord.getTodayDate();
    return _brushingData[memberId]?[date] ?? {'morning': false, 'night': false};
  }

  // Get weekly stats (last 7 days)
  Map<String, dynamic> getWeeklyStats(String memberId) {
    int totalBrushing = 0;
    final weeklyData = <String, Map<String, bool>>{};

    for (int i = 6; i >= 0; i--) {
      final date = BrushingRecord.getDateNDaysAgo(i);
      final status = _brushingData[memberId]?[date] ?? {'morning': false, 'night': false};
      weeklyData[date] = status;

      if (status['morning'] == true) totalBrushing++;
      if (status['night'] == true) totalBrushing++;
    }

    return {
      'total': totalBrushing,
      'max': 14,
      'percentage': (totalBrushing / 14 * 100).toStringAsFixed(1),
      'data': weeklyData,
    };
  }

  // Get monthly stats (last 30 days)
  Map<String, dynamic> getMonthlyStats(String memberId) {
    int totalBrushing = 0;
    final monthlyData = <String, Map<String, bool>>{};

    for (int i = 29; i >= 0; i--) {
      final date = BrushingRecord.getDateNDaysAgo(i);
      final status = _brushingData[memberId]?[date] ?? {'morning': false, 'night': false};
      monthlyData[date] = status;

      if (status['morning'] == true) totalBrushing++;
      if (status['night'] == true) totalBrushing++;
    }

    return {
      'total': totalBrushing,
      'max': 60,
      'percentage': (totalBrushing / 60 * 100).toStringAsFixed(1),
      'data': monthlyData,
    };
  }

  // Get all data (for debugging and achievements)
  Map<String, Map<String, Map<String, bool>>> getData() {
    return _brushingData;
  }

  // Load brushing data from SharedPreferences (for one-time access)
  Future<Map<String, Map<String, Map<String, bool>>>> loadBrushingData() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _loadData();
      return _brushingData;
    } catch (e) {
      print('Error in loadBrushingData: $e');
      return _brushingData.isEmpty ? {} : _brushingData;
    }
  }

  // Get all data (for debugging)
  Map<String, Map<String, Map<String, bool>>> getAllData() {
    return _brushingData;
  }

  // Clear all data
  Future<void> clearAllData() async {
    _brushingData = {};
    await _saveData();
  }

  // Delete member data
  Future<void> deleteMemberData(String memberId) async {
    _brushingData.remove(memberId);
    await _saveData();
  }
}
