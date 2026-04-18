import '../models/myth_data.dart';

class MythCheckingService {
  // Dental-related keywords for initial classification
  static const List<String> dentalKeywords = [
    'tooth',
    'teeth',
    'dental',
    'dentist',
    'brushing',
    'brush',
    'gum',
    'gums',
    'floss',
    'flossing',
    'cavity',
    'cavities',
    'plaque',
    'tartar',
    'enamel',
    'decay',
    'decaying',
    'root canal',
    'whitening',
    'bleaching',
    'mouthwash',
    'toothpaste',
    'toothbrush',
    'mouth',
    'oral',
    'bite',
    'bite',
    'crown',
    'braces',
    'orthodontic',
    'implant',
    'veneer',
    'filling',
    'extraction',
    'wisdom tooth',
    'canine',
    'molar',
    'incisor',
    'pulp',
    'periodontal',
    'gingivitis',
    'periodontitis',
    'halitosis',
    'bad breath',
    'fluoride',
    'calcium',
  ];

  // Predefined myths and facts database
  static final List<MythData> mythDatabase = [
    // MYTHS
    MythData(
      id: 'myth_1',
      text: 'Brushing your teeth immediately after eating acidic foods is good for your teeth',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. Acidic foods soften the enamel, and brushing immediately can damage it. Wait 30-60 minutes before brushing.',
      category: 'Brushing',
      keywords: [
        'acidic',
        'immediately',
        'after eating',
        'acid',
        'soda',
        'lemon',
        'citrus'
      ],
    ),
    MythData(
      id: 'myth_2',
      text: 'Sugar is the only cause of tooth decay and cavities',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. While sugar promotes decay, acids and bacteria are the main culprits. Poor oral hygiene and lack of fluoride also contribute.',
      category: 'Decay',
      keywords: [
        'sugar',
        'only cause',
        'cavities',
        'candy',
        'sweets',
        'decay'
      ],
    ),
    MythData(
      id: 'myth_3',
      text: 'You should brush your teeth as hard as possible for better cleaning',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. Aggressive brushing damages gums and enamel. Use gentle, circular motions with a soft toothbrush.',
      category: 'Brushing',
      keywords: [
        'hard',
        'aggressive',
        'force',
        'pressure',
        'rough',
        'scrub'
      ],
    ),
    MythData(
      id: 'myth_4',
      text: 'Flossing is not necessary if you brush regularly',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. Flossing removes food and plaque between teeth that brushing cannot reach. It is essential for gum health.',
      category: 'Flossing',
      keywords: [
        'flossing not necessary',
        'skip flossing',
        'floss optional',
        'brush only'
      ],
    ),
    MythData(
      id: 'myth_5',
      text: 'Whiter teeth are always healthier teeth',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. Tooth color does not determine health. Whitening is cosmetic. Healthy teeth have strong enamel and healthy gums.',
      category: 'Cosmetics',
      keywords: [
        'whiter teeth',
        'white teeth',
        'bright teeth',
        'yellowing',
        'discolored'
      ],
    ),
    MythData(
      id: 'myth_6',
      text: 'Chewing gum can replace brushing your teeth',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. Gum with xylitol can help, but it cannot replace brushing. Brushing removes plaque and bacteria; gum only stimulates saliva.',
      category: 'Brushing',
      keywords: [
        'gum replaces brushing',
        'chewing gum instead',
        'gum substitute',
        'skip brushing'
      ],
    ),
    MythData(
      id: 'myth_7',
      text: 'You only need to visit the dentist if your teeth hurt',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. Regular checkups detect problems early before pain occurs. Pain often means advanced decay. Visit your dentist every 6 months.',
      category: 'Dental Visits',
      keywords: [
        'only if pain',
        'dentist when hurt',
        'visit only if pain',
        'checkup unnecessary'
      ],
    ),
    MythData(
      id: 'myth_8',
      text: 'Milk teeth do not need proper care since they fall out anyway',
      isMythOrFact: true,
      explanation:
          'This is a MYTH. Baby teeth guide permanent teeth and maintain jawbone structure. Poor care leads to infections and misalignment.',
      category: 'Children',
      keywords: [
        'milk teeth',
        'baby teeth',
        'primary teeth',
        'fall out',
        'temporary teeth'
      ],
    ),

    // FACTS
    MythData(
      id: 'fact_1',
      text: 'You should brush your teeth twice a day for two minutes each time',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Brushing twice daily (morning and night) for 2 minutes removes plaque and prevents decay.',
      category: 'Brushing',
      keywords: ['brush twice', '2 minutes', 'daily brushing', 'morning and night'],
    ),
    MythData(
      id: 'fact_2',
      text: 'Fluoride helps strengthen tooth enamel and prevent cavities',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Fluoride is proven to strengthen enamel and reduce decay risk by up to 40%.',
      category: 'Prevention',
      keywords: [
        'fluoride',
        'strengthen enamel',
        'prevent cavities',
        'remineralize'
      ],
    ),
    MythData(
      id: 'fact_3',
      text: 'Flossing daily helps prevent gum disease and cavities',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Flossing removes food and plaque between teeth, preventing gum disease (gingivitis and periodontitis).',
      category: 'Flossing',
      keywords: [
        'floss daily',
        'flossing prevents',
        'prevent gum disease',
        'interdental cleaning'
      ],
    ),
    MythData(
      id: 'fact_4',
      text: 'Regular dental checkups can detect problems early',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Biannual (6-month) checkups detect cavities, gum disease, and oral cancer early for better outcomes.',
      category: 'Dental Visits',
      keywords: [
        'checkups',
        'detect early',
        'dental visit',
        'professional cleaning',
        'examination'
      ],
    ),
    MythData(
      id: 'fact_5',
      text: 'A balanced diet low in sugar supports healthy teeth',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Sugar feeds cavity-causing bacteria. Foods rich in calcium and phosphorus strengthen enamel.',
      category: 'Diet',
      keywords: [
        'diet',
        'calcium',
        'low sugar',
        'healthy food',
        'nutrition',
        'phosphorus'
      ],
    ),
    MythData(
      id: 'fact_6',
      text: 'Saliva naturally protects teeth from decay',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Saliva buffers acids, remineralizes enamel, and has antimicrobial properties that protect teeth.',
      category: 'Oral Health',
      keywords: [
        'saliva',
        'protect',
        'antimicrobial',
        'buffer acids',
        'natural protection'
      ],
    ),
    MythData(
      id: 'fact_7',
      text: 'Using a soft-bristled toothbrush is better for your gums',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Soft bristles clean effectively without damaging gums or wearing away enamel.',
      category: 'Brushing',
      keywords: [
        'soft bristled',
        'soft toothbrush',
        'gentle',
        'bristle softness',
        'gum health'
      ],
    ),
    MythData(
      id: 'fact_8',
      text: 'Mouthwash can supplement but not replace brushing and flossing',
      isMythOrFact: false,
      explanation:
          'This is a FACT. Mouthwash kills bacteria and freshens breath but cannot remove plaque like brushing and flossing do.',
      category: 'Oral Hygiene',
      keywords: [
        'mouthwash',
        'rinse',
        'supplement',
        'supplement but not replace',
        'antiseptic'
      ],
    ),
  ];

  /// Check if user input is dental-related
  static bool isDentalRelated(String input) {
    final lowerInput = input.toLowerCase();
    return dentalKeywords
        .any((keyword) => lowerInput.contains(keyword.toLowerCase()));
  }

  /// Calculate similarity between two strings (0.0 to 1.0)
  /// Uses simple token overlap and word distance metrics
  static double calculateSimilarity(String input1, String input2) {
    final tokens1 = _tokenize(input1);
    final tokens2 = _tokenize(input2);

    if (tokens1.isEmpty || tokens2.isEmpty) return 0.0;

    // Calculate Jaccard similarity
    final intersection = tokens1.where((t) => tokens2.contains(t)).length;
    final union = tokens1.length + tokens2.length - intersection;

    if (union == 0) return 0.0;
    final jaccardScore = intersection / union;

    // Bonus for length similarity (not drastically different)
    final lengthRatio =
        (input1.length.toDouble() / input2.length).clamp(0.5, 2.0);
    final lengthBonus = 1.0 - (lengthRatio - 1).abs() * 0.2;

    return (jaccardScore * 0.7 + lengthBonus * 0.3);
  }

  /// Tokenize text into lowercase words
  static List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[.,!?;:]'), '') // Remove punctuation
        .split(RegExp(r'\s+')) // Split by whitespace
        .where((token) => token.isNotEmpty && token.length > 2) // Filter shorts
        .toList();
  }

  /// Main function: Check user input against myth database
  static MythCheckResult checkInput(String userInput) {
    if (userInput.trim().isEmpty) {
      return MythCheckResult(
        type: 'Unknown',
        explanation: 'Please enter a dental-related statement to check.',
        similarityScore: 0.0,
        category: 'Input Validation',
      );
    }

    // Step 1: Check if dental-related
    if (!isDentalRelated(userInput)) {
      return MythCheckResult(
        type: 'Not Dental',
        explanation:
            'This statement does not appear to be related to dental health. Please ask about teeth, brushing, flossing, or other dental topics.',
        similarityScore: 0.0,
        category: 'Non-Dental',
      );
    }

    // Step 2: Find best matching myth/fact
    double bestScore = 0.0;
    MythData? bestMatch;

    for (final mythData in mythDatabase) {
      final score = calculateSimilarity(userInput, mythData.text);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = mythData;
      }
    }

    // Step 3: Determine result based on similarity threshold
    if (bestMatch == null) {
      return MythCheckResult(
        type: 'Unknown',
        explanation:
            'I could not find a matching myth or fact in the database. The statement might be too unique or ambiguous.',
        similarityScore: 0.0,
        category: 'Unknown',
      );
    }

    // Use 0.35 as threshold for confident matches
    if (bestScore < 0.35) {
      return MythCheckResult(
        type: 'Unknown',
        explanation:
            'The statement is similar to: "${bestMatch.text}"\n\n${bestMatch.explanation}',
        similarityScore: bestScore,
        matchedText: bestMatch.text,
        category: bestMatch.category,
      );
    }

    // Strong match found
    return MythCheckResult(
      type: bestMatch.isMythOrFact ? 'Myth' : 'Fact',
      explanation: bestMatch.explanation,
      similarityScore: bestScore,
      matchedText: bestMatch.text,
      category: bestMatch.category,
    );
  }
}
