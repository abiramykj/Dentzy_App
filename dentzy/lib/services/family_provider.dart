import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/family_member.dart';
import 'session_manager.dart';

class FamilyProvider extends ChangeNotifier {
  List<FamilyMember> _familyMembers = [];
  FamilyMember? _selectedMember;
  SharedPreferences? _prefs;
  int _lastLoadedSessionEpoch = -1;
  bool _initializing = false;
  int _initializedSessionEpoch = -1;

  FamilyProvider() {
    AuthSessionService.instance.addListener(_handleSessionChanged);
  }

  List<FamilyMember> get familyMembers => _familyMembers;
  FamilyMember? get selectedMember => _selectedMember;

  String? _currentStorageKey() {
    final email = AuthSessionService.instance.currentLoggedInUserEmail;
    if (email == null || email.isEmpty) {
      return null;
    }

    return AuthSessionService.userScopedKey(email, 'family_members');
  }

  // Initialize provider and load saved data
  Future<void> initialize() async {
    final currentEpoch = AuthSessionService.instance.sessionEpoch;
    if (_initializing || _initializedSessionEpoch == currentEpoch) {
      debugPrint('[FAMILY] initialize skipped epoch=$currentEpoch initializing=$_initializing');
      return;
    }

    _initializing = true;
    _prefs = await SharedPreferences.getInstance();
    debugPrint('[FAMILY] initialize user=${AuthSessionService.instance.currentLoggedInUserEmail}');
    try {
      await _loadFamilyMembers();
      _initializedSessionEpoch = currentEpoch;
    } finally {
      _initializing = false;
    }
  }

  void _handleSessionChanged() {
    debugPrint('[FAMILY] session changed user=${AuthSessionService.instance.currentLoggedInUserEmail} epoch=${AuthSessionService.instance.sessionEpoch}');
    _familyMembers = [];
    _selectedMember = null;
    notifyListeners();
    initialize();
  }

  // Load family members from SharedPreferences
  Future<void> _loadFamilyMembers() async {
    try {
      final loadEpoch = AuthSessionService.instance.sessionEpoch;
      _selectedMember = null;
      final storageKey = _currentStorageKey();
      if (storageKey == null) {
        _familyMembers = [];
        notifyListeners();
        return;
      }

      if (loadEpoch != AuthSessionService.instance.sessionEpoch) {
        debugPrint('[FAMILY] Ignoring stale load for epoch=$loadEpoch current=${AuthSessionService.instance.sessionEpoch}');
        return;
      }

      debugPrint('[STORAGE] Loading key=$storageKey');
      final membersJson = _prefs?.getStringList(storageKey) ?? [];
      _familyMembers = membersJson
          .map((json) {
            try {
              return FamilyMember.fromJson(jsonDecode(json) as Map<String, dynamic>? ?? {});
            } catch (e) {
              print('Error parsing family member: $e');
              return null;
            }
          })
          .whereType<FamilyMember>()
          .toList();
      _lastLoadedSessionEpoch = loadEpoch;
      notifyListeners();
    } catch (e) {
      print('Error loading family members: $e');
      _familyMembers = [];
      notifyListeners();
    }
  }

  // Save family members to SharedPreferences
  Future<void> _saveFamilyMembers() async {
    final storageKey = _currentStorageKey();
    if (storageKey == null) {
      debugPrint('[FAMILY] save skipped: no active session');
      return;
    }

    final membersJson = _familyMembers
        .map((member) => jsonEncode(member.toJson()))
        .toList();
    debugPrint('[STORAGE] Saving key=$storageKey');
    _lastLoadedSessionEpoch = AuthSessionService.instance.sessionEpoch;
    await _prefs?.setStringList(storageKey, membersJson);
  }

  // Add a new family member
  Future<void> addFamilyMember({
    required String name,
    required int age,
    String? relation,
  }) async {
    final newMember = FamilyMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      relation: relation,
      addedDate: DateTime.now(),
    );
    _familyMembers.add(newMember);
    await _saveFamilyMembers();
    notifyListeners();
  }

  // Update an existing family member
  Future<void> updateFamilyMember(FamilyMember updatedMember) async {
    final index = _familyMembers.indexWhere((m) => m.id == updatedMember.id);
    if (index != -1) {
      _familyMembers[index] = updatedMember;
      await _saveFamilyMembers();
      notifyListeners();
    }
  }

  // Delete a family member
  Future<void> deleteFamilyMember(String id) async {
    _familyMembers.removeWhere((m) => m.id == id);
    if (_selectedMember?.id == id) {
      _selectedMember = null;
    }
    await _saveFamilyMembers();
    notifyListeners();
  }

  // Select a family member
  void selectFamilyMember(FamilyMember member) {
    _selectedMember = member;
    notifyListeners();
  }

  // Get member by ID
  FamilyMember? getMemberById(String id) {
    try {
      return _familyMembers.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    AuthSessionService.instance.removeListener(_handleSessionChanged);
    super.dispose();
  }
}
