import 'dart:convert';
import 'package:flutter/services.dart';

/// Unified data model for myth/fact items
class MythItem {
  final String id;
  final String text;
  final String label; // 'Myth' or 'Fact'
  final String explanation;
  final String category;
  final List<String> keywords;

  MythItem({
    required this.id,
    required this.text,
    required this.label,
    required this.explanation,
    required this.category,
    required this.keywords,
  });

  factory MythItem.fromJson(Map<String, dynamic> json) {
    return MythItem(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      label: json['label'] ?? 'Unknown',
      explanation: json['explanation'] ?? '',
      category: json['category'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'label': label,
      'explanation': explanation,
      'category': category,
      'keywords': keywords,
    };
  }
}

/// Myth checking result
class MythCheckResult {
  final String label; // 'Myth', 'Fact', 'Not Dental'
  final String explanation;
  final int confidence; // 0-100%
  final String? matchedText;
  final String category;
  final String reason; // Why this result

  MythCheckResult({
    required this.label,
    required this.explanation,
    required this.confidence,
    this.matchedText,
    required this.category,
    required this.reason,
  });
}

/// Data loader service
class MythDataLoader {
  static List<MythItem> _cachedData = [];
  static bool _isLoaded = false;

  /// Load all datasets (English + Tamil)
  static Future<List<MythItem>> loadAllDatasets() async {
    if (_isLoaded) return _cachedData;

    final englishJson = await _loadEnglishJson();
    final englishCsv = await _loadEnglishCsv();
    final tamilJson = await _loadTamilJson();
    final tamilCsv = await _loadTamilCsv();

    _cachedData = [
      ...englishJson,
      ...englishCsv,
      ...tamilJson,
      ...tamilCsv,
    ];

    // Remove duplicates based on normalized text
    final seen = <String>{};
    _cachedData.removeWhere((item) {
      final normalized = normalizeText(item.text);
      if (seen.contains(normalized)) {
        return true;
      }
      seen.add(normalized);
      return false;
    });

    _isLoaded = true;
    return _cachedData;
  }

  /// Load English JSON knowledge base
  static Future<List<MythItem>> _loadEnglishJson() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/oral_health_myth_knowledge_base.json');
      final jsonData = jsonDecode(jsonString) as List;

      final items = <MythItem>[];
      for (final myth in jsonData) {
        final covers = List<String>.from(myth['covers'] ?? []);
        final explanation = myth['explanation'] ?? '';
        final category = myth['category'] ?? 'General';
        final id = myth['id'] ?? 'en_${items.length}';

        // Extract keywords from covers
        final keywords = _extractKeywords(covers.join(' '));

        for (final statement in covers) {
          items.add(MythItem(
            id: '$id-${items.length}',
            text: statement,
            label: 'Myth',
            explanation: explanation,
            category: category,
            keywords: keywords,
          ));
        }
      }

      return items;
    } catch (e) {
      print('Error loading English JSON: $e');
      return [];
    }
  }

  /// Load English CSV dataset
  static Future<List<MythItem>> _loadEnglishCsv() async {
    try {
      final csvString =
          await rootBundle.loadString('assets/oral_health_myth_fact_dataset.csv');
      final lines = csvString.split('\n');

      final items = <MythItem>[];
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Parse CSV line
        final parts = _parseCSVLine(line);
        if (parts.length < 2) continue;

        final text = parts[0];
        final label = parts[1].toLowerCase().trim();

        if (label != 'fact' && label != 'myth') continue;

        final keywords = _extractKeywords(text);

        items.add(MythItem(
          id: 'csv_en_${items.length}',
          text: text,
          label: label == 'fact' ? 'Fact' : 'Myth',
          explanation: parts.length > 2 ? parts[2] : '',
          category: 'General',
          keywords: keywords,
        ));
      }

      return items;
    } catch (e) {
      print('Error loading English CSV: $e');
      return [];
    }
  }

  /// Load Tamil JSON knowledge base
  static Future<List<MythItem>> _loadTamilJson() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/knowledge_base_tamil.json');
      final jsonData = jsonDecode(jsonString) as List;

      final items = <MythItem>[];
      for (final myth in jsonData) {
        final covers = List<String>.from(myth['covers'] ?? []);
        final explanation = myth['explanation_ta'] ?? myth['explanation'] ?? '';
        final category = myth['category_ta'] ?? myth['category'] ?? 'General';
        final id = myth['id'] ?? 'ta_${items.length}';

        final keywords = _extractKeywords(covers.join(' '));

        for (final statement in covers) {
          items.add(MythItem(
            id: '$id-${items.length}',
            text: statement,
            label: 'Myth',
            explanation: explanation,
            category: category,
            keywords: keywords,
          ));
        }
      }

      return items;
    } catch (e) {
      print('Error loading Tamil JSON: $e');
      return [];
    }
  }

  /// Load Tamil CSV dataset
  static Future<List<MythItem>> _loadTamilCsv() async {
    try {
      final csvString =
          await rootBundle.loadString('assets/dataset_Myth_checker_tamil.csv');
      final lines = csvString.split('\n');

      final items = <MythItem>[];
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = _parseCSVLine(line);
        if (parts.length < 2) continue;

        final text = parts[0];
        final label = parts[1].toLowerCase().trim();

        if (label != 'fact' && label != 'myth' && label != 'சத்திய' && label != 'கட்டுக்கதை') continue;

        final isFact = label.contains('fact') || label.contains('சத்திய');
        final keywords = _extractKeywords(text);

        items.add(MythItem(
          id: 'csv_ta_${items.length}',
          text: text,
          label: isFact ? 'Fact' : 'Myth',
          explanation: parts.length > 2 ? parts[2] : '',
          category: 'General',
          keywords: keywords,
        ));
      }

      return items;
    } catch (e) {
      print('Error loading Tamil CSV: $e');
      return [];
    }
  }

  /// Parse CSV line (handle quoted fields)
  static List<String> _parseCSVLine(String line) {
    final parts = <String>[];
    var current = '';
    var inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        parts.add(current.replaceAll('"', '').trim());
        current = '';
      } else {
        current += char;
      }
    }

    if (current.isNotEmpty) {
      parts.add(current.replaceAll('"', '').trim());
    }

    return parts;
  }

  /// Extract and normalize keywords from text
  static List<String> _extractKeywords(String text) {
    final normalized = normalizeText(text);
    final words = normalized.split(RegExp(r'\s+'));
    return words
        .where((w) => w.length > 2 && !_isStopword(w))
        .toList();
  }

  /// Check if word is a stopword
  static bool _isStopword(String word) {
    const stopwords = [
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'from', 'is', 'are', 'was', 'were', 'be', 'been',
      'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
      'could', 'should', 'can', 'may', 'might', 'must', 'shall'
    ];
    return stopwords.contains(word.toLowerCase());
  }

  /// Normalize text for comparison (public for advanced checker)
  static String normalizeText(String text) {
    // Convert to lowercase
    var normalized = text.toLowerCase();

    // Remove punctuation
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), '');

    // Number normalization
    normalized = normalized
        .replaceAll(RegExp(r'\b2\s+times?\b'), 'twice')
        .replaceAll(RegExp(r'\btwo\s+times?\b'), 'twice')
        .replaceAll(RegExp(r'\b3\s+times?\b'), 'thrice')
        .replaceAll(RegExp(r'\bthree\s+times?\b'), 'thrice')
        .replaceAll(RegExp(r'\b1\s+times?\b'), 'once')
        .replaceAll(RegExp(r'\bone\s+times?\b'), 'once');

    // Word normalization (synonyms)
    normalized = normalized
        .replaceAll(RegExp(r'\bbrushing?\b'), 'brush')
        .replaceAll(RegExp(r'\bteeth?\b'), 'tooth')
        .replaceAll(RegExp(r'\bflossing?\b'), 'floss')
        .replaceAll(RegExp(r'\bscaling?\b'), 'scale')
        .replaceAll(RegExp(r'\bcleaning?\b'), 'clean')
        .replaceAll(RegExp(r'\bcavities?\b'), 'cavity')
        .replaceAll(RegExp(r'\bdecay?\b'), 'caries')
        .replaceAll(RegExp(r'\benamel?\b'), 'enamel')
        .replaceAll(RegExp(r'\bgums?\b'), 'gum')
        .replaceAll(RegExp(r'\bplaque?\b'), 'plaque');

    // Remove extra spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalized;
  }

  /// Get cached data
  static List<MythItem> getCachedData() => _cachedData;
}
