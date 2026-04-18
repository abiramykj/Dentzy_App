import '../models/myth_item.dart';

class AdvancedMythChecker {
  // Dental-related keywords
  static const List<String> dentalKeywords = [
    'tooth', 'teeth', 'dental', 'dentist', 'brush', 'brushing', 'gum', 'gums',
    'floss', 'cavity', 'cavities', 'caries', 'decay', 'enamel', 'plaque',
    'tartar', 'scale', 'scaling', 'clean', 'cleaning', 'toothpaste',
    'toothbrush', 'mouth', 'oral', 'bite', 'crown', 'filling', 'whitening',
    'implant', 'root', 'canal', 'periodontal', 'gingiv', 'halitosis', 'breath',
    'fluoride', 'mouthwash', 'orthodont', 'braces', 'extraction', 'neem',
    'miswak', 'datun', 'chewing stick', 'tooth stick'
  ];

  // Priority rules for high-confidence classifications
  static final List<PriorityRule> priorityRules = [
    // Fact rules
    PriorityRule(
      regex: RegExp(r'twice\s+a\s+day|2\s+times\s+a\s+day|two\s+times\s+a\s+day', caseSensitive: false),
      label: 'Fact',
      confidence: 95,
      reason: 'Standard recommendation for daily brushing',
    ),
    PriorityRule(
      regex: RegExp(r'fluoride.*strengthen|strengthen.*enamel|fluoride.*prevent', caseSensitive: false),
      label: 'Fact',
      confidence: 90,
      reason: 'Proven benefit of fluoride',
    ),
    PriorityRule(
      regex: RegExp(r'floss.*daily|daily.*floss|floss.*prevent', caseSensitive: false),
      label: 'Fact',
      confidence: 88,
      reason: 'Flossing removes interdental plaque',
    ),
    PriorityRule(
      regex: RegExp(r'soft.*bristle|gentle.*brush|circular.*motion', caseSensitive: false),
      label: 'Fact',
      confidence: 85,
      reason: 'Recommended brushing technique',
    ),
    PriorityRule(
      regex: RegExp(r'regular.*checkup|dental.*visit|professional.*cleaning', caseSensitive: false),
      label: 'Fact',
      confidence: 85,
      reason: 'Professional dental care recommendation',
    ),

    // Myth rules
    PriorityRule(
      regex: RegExp(r'immediately\s+after.*acidic|acidic.*immediately.*brush', caseSensitive: false),
      label: 'Myth',
      confidence: 95,
      reason: 'Acidic foods soften enamel - wait 30-60 minutes',
    ),
    PriorityRule(
      regex: RegExp(r'hard.*brush|brush.*hard|strong.*pressure|aggressive.*brush', caseSensitive: false),
      label: 'Myth',
      confidence: 90,
      reason: 'Aggressive brushing damages gums and enamel',
    ),
    PriorityRule(
      regex: RegExp(r'gum.*bleed.*stop|bleed.*stop.*brush', caseSensitive: false),
      label: 'Myth',
      confidence: 85,
      reason: 'Bleeding gums need gentle, continued brushing',
    ),
    PriorityRule(
      regex: RegExp(r'scaling.*damage|scaling.*weaken|professional.*cleaning.*gap', caseSensitive: false),
      label: 'Myth',
      confidence: 90,
      reason: 'Professional scaling is safe and beneficial',
    ),
    PriorityRule(
      regex: RegExp(r'baby.*teeth.*not.*care|milk.*teeth.*not.*important|primary.*teeth.*problem', caseSensitive: false),
      label: 'Myth',
      confidence: 92,
      reason: 'Baby teeth are important for development',
    ),
    PriorityRule(
      regex: RegExp(r'floss.*create.*gap|floss.*unnecessary|skip.*floss', caseSensitive: false),
      label: 'Myth',
      confidence: 88,
      reason: 'Flossing is essential and does not create gaps',
    ),
    PriorityRule(
      regex: RegExp(r'mouthwash.*replace.*brush|mouthwash.*alone|only.*mouthwash', caseSensitive: false),
      label: 'Myth',
      confidence: 85,
      reason: 'Mouthwash cannot replace brushing and flossing',
    ),
    PriorityRule(
      regex: RegExp(r'more.*toothpaste|extra.*toothpaste|full.*brush', caseSensitive: false),
      label: 'Myth',
      confidence: 85,
      reason: 'Pea-sized amount is sufficient for cleaning',
    ),
  ];

  /// Classify user input using comprehensive matching
  static Future<MythCheckResult> classify(
    String userInput,
    List<MythItem> database,
  ) async {
    // Check for empty input
    if (userInput.trim().isEmpty) {
      return MythCheckResult(
        label: 'Not Dental',
        explanation: 'Please enter a statement to check',
        confidence: 0,
        category: 'Input Validation',
        reason: 'Empty input',
      );
    }

    // Check priority rules first
    final priorityMatch = _checkPriorityRules(userInput);
    if (priorityMatch != null) {
      return priorityMatch;
    }

    // Check if dental-related
    if (!_isDentalRelated(userInput)) {
      return MythCheckResult(
        label: 'Not Dental',
        explanation:
            'This statement does not appear to be about dental health. Please ask about teeth, brushing, gums, cavities, or other dental topics.',
        confidence: 100,
        category: 'Non-Dental',
        reason: 'No dental keywords detected',
      );
    }

    // Find best matching items
    final normalized = MythDataLoader.normalizeText(userInput);
    double bestScore = 0.0;
    MythItem? bestMatch;
    var details = '';

    for (final item in database) {
      final itemNormalized = MythDataLoader.normalizeText(item.text);
      final score = _calculateSimilarity(normalized, itemNormalized);

      if (score > bestScore) {
        bestScore = score;
        bestMatch = item;
        details = 'Matched with: "$itemNormalized"';
      }
    }

    if (bestMatch == null) {
      return MythCheckResult(
        label: 'Unknown',
        explanation:
            'This seems dental-related, but the knowledge base is unavailable.',
        confidence: 0,
        category: 'Unknown',
        reason: 'No items loaded for matching',
      );
    }

    // Apply confidence thresholds
    int confidence = 0;
    String reason = '';

    if (bestScore < 0.5) {
      confidence = (bestScore * 100).round();
      return MythCheckResult(
        label: 'Unknown',
        explanation:
            'This is dental-related, but we could not confidently match it to our knowledge base. Please rephrase or add more detail.',
        confidence: confidence,
        category: 'Unknown',
        reason:
            'Low confidence match (score: ${(bestScore * 100).toStringAsFixed(0)}%)',
      );
    } else if (bestScore >= 0.5 && bestScore < 0.65) {
      confidence = (bestScore * 100).toInt();
      reason = 'Uncertain match - Similar to: ${bestMatch!.text}';
    } else {
      confidence = (bestScore * 100).toInt();
      reason = details;
    }

    return MythCheckResult(
      label: bestMatch!.label,
      explanation: bestMatch.explanation,
      confidence: confidence,
      matchedText: bestMatch.text,
      category: bestMatch.category,
      reason: reason,
    );
  }

  /// Check priority rules for quick classification
  static MythCheckResult? _checkPriorityRules(String input) {
    for (final rule in priorityRules) {
      if (rule.regex.hasMatch(input)) {
        return MythCheckResult(
          label: rule.label,
          explanation:
              'This matches a known dental principle. ${rule.reason}',
          confidence: rule.confidence,
          category: 'Priority Rule',
          reason: 'Matched priority rule: ${rule.reason}',
        );
      }
    }
    return null;
  }

  /// Check if input contains dental keywords
  static bool _isDentalRelated(String input) {
    final normalized = input.toLowerCase();
    return dentalKeywords.any((keyword) => normalized.contains(keyword));
  }

  /// Calculate similarity using multiple metrics
  static double _calculateSimilarity(String input, String dbStatement) {
    final inputTokens = _tokenize(input);
    final dbTokens = _tokenize(dbStatement);

    if (inputTokens.isEmpty || dbTokens.isEmpty) return 0.0;

    // 1. Jaccard similarity
    final intersection = inputTokens
        .where((token) => dbTokens.contains(token))
        .toList()
        .length;
    final union =
        inputTokens.length + dbTokens.length - intersection;
    final jaccardScore = intersection / union;

    // 2. Phrase matching (boost if key phrases match)
    final phraseBonus = _calculatePhraseBonus(input, dbStatement);

    // 3. Length similarity
    final lengthRatio = (input.length.toDouble() / dbStatement.length)
        .clamp(0.5, 2.0);
    final lengthBonus = 1.0 - (lengthRatio - 1).abs() * 0.15;

    // 4. Keyword overlap density
    final keywordBonus = _calculateKeywordBonus(inputTokens, dbTokens);

    // Combined score (weighted)
    final finalScore = (jaccardScore * 0.50) +
        (phraseBonus * 0.25) +
        (lengthBonus * 0.15) +
        (keywordBonus * 0.10);

    return finalScore.clamp(0.0, 1.0);
  }

  /// Boost score if key phrases match
  static double _calculatePhraseBonus(String input, String dbStatement) {
    const keyPhrases = [
      'twice a day',
      'hard brush',
      'soft bristle',
      'gentle circular',
      'immediately after',
      'acidic foods',
      'gum disease',
      'cavity prevention',
      'plaque removal',
      'daily floss',
    ];

    final inputLower = input.toLowerCase();
    final dbLower = dbStatement.toLowerCase();

    int matchedPhrases = 0;
    for (final phrase in keyPhrases) {
      if (inputLower.contains(phrase) && dbLower.contains(phrase)) {
        matchedPhrases++;
      }
    }

    return (matchedPhrases * 0.15).clamp(0.0, 1.0);
  }

  /// Calculate keyword bonus
  static double _calculateKeywordBonus(
    List<String> inputTokens,
    List<String> dbTokens,
  ) {
    // Prioritize important dental keywords
    const importantKeywords = [
      'fluoride', 'cavity', 'plaque', 'enamel', 'gum', 'floss', 'brush',
      'tooth', 'decay', 'cleaning', 'gentle', 'twice'
    ];

    int importantMatches = 0;
    for (final keyword in importantKeywords) {
      if (inputTokens.contains(keyword) && dbTokens.contains(keyword)) {
        importantMatches++;
      }
    }

    return (importantMatches * 0.08).clamp(0.0, 1.0);
  }

  /// Tokenize text
  static List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty && token.length > 1)
        .toList();
  }
}

/// Priority rule structure
class PriorityRule {
  final RegExp regex;
  final String label;
  final int confidence;
  final String reason;

  PriorityRule({
    required this.regex,
    required this.label,
    required this.confidence,
    required this.reason,
  });
}
