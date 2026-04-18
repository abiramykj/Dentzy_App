import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/family_member.dart';

class FamilyProvider extends ChangeNotifier {
  List<FamilyMember> _familyMembers = [];
  FamilyMember? _selectedMember;
  SharedPreferences? _prefs;

  List<FamilyMember> get familyMembers => _familyMembers;
  FamilyMember? get selectedMember => _selectedMember;

  // Initialize provider and load saved data
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFamilyMembers();
  }

  // Load family members from SharedPreferences
  Future<void> _loadFamilyMembers() async {
    try {
      final membersJson = _prefs?.getStringList('family_members') ?? [];
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
      notifyListeners();
    } catch (e) {
      print('Error loading family members: $e');
      _familyMembers = [];
      notifyListeners();
    }
  }

  // Save family members to SharedPreferences
  Future<void> _saveFamilyMembers() async {
    final membersJson = _familyMembers
        .map((member) => jsonEncode(member.toJson()))
        .toList();
    await _prefs?.setStringList('family_members', membersJson);
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
}
