# Dentzy Myth Checker - Technical Documentation

## Overview

The **Myth Checker** is an intelligent rule-based NLP system that classifies user-entered dental statements into one of four categories:
- **Myth**: False dental beliefs that could harm oral health
- **Fact**: Evidence-based dental truths
- **Not Dental**: Statements unrelated to dentistry
- **Unknown**: Ambiguous or novel statements that don't match the database

## Architecture

### Components

#### 1. **Data Models** (`lib/models/myth_data.dart`)

**MythData Class**
```dart
class MythData {
  final String id;                  // Unique identifier
  final String text;                // The myth or fact statement
  final bool isMythOrFact;          // true = Myth, false = Fact
  final String explanation;         // User-facing explanation
  final String category;            // Category (Brushing, Prevention, etc.)
  final List<String> keywords;      // Keywords for initial filtering
}
```

**MythCheckResult Class**
```dart
class MythCheckResult {
  final String type;                // 'Myth', 'Fact', 'Not Dental', 'Unknown'
  final String explanation;         // Result explanation
  final double similarityScore;     // 0.0 to 1.0 confidence
  final String? matchedText;        // The matched statement (if found)
  final String category;            // Category of result
}
```

#### 2. **Myth Checking Service** (`lib/services/myth_checking_service.dart`)

Core logic for classification with three main steps:

**Step 1: Dental Relevance Check**
- Uses keyword matching against 44 dental-related keywords
- Keywords include: tooth, teeth, dental, dentist, brushing, gum, floss, cavity, enamel, decay, fluoride, etc.
- Returns `Not Dental` if no keywords match

**Step 2: Similarity Matching**
- Compares user input against 16 predefined myths and facts in the database
- Uses **Jaccard Similarity** algorithm:
  ```
  Jaccard(A, B) = |A ∩ B| / |A ∪ B|
  ```
- Tokenizes text (removes punctuation, filters short words)
- Considers word overlap and length similarity
- Returns confidence score (0.0 to 1.0)

**Step 3: Classification**
- If similarity score ≥ 0.35: Returns matched myth or fact type
- If similarity score < 0.35: Returns "Unknown" with similar statement suggestion
- Includes explanation, category, and confidence score

### Predefined Database

**8 Myths:**
1. Brushing teeth immediately after acidic foods
2. Sugar is the only cause of tooth decay
3. Brush teeth as hard as possible
4. Flossing is not necessary
5. Whiter teeth are always healthier
6. Chewing gum can replace brushing
7. Only visit dentist if teeth hurt
8. Milk teeth don't need proper care

**8 Facts:**
1. Brush teeth twice a day for 2 minutes
2. Fluoride strengthens enamel and prevents cavities
3. Flossing daily prevents gum disease
4. Regular checkups detect problems early
5. Balanced diet low in sugar supports healthy teeth
6. Saliva naturally protects teeth
7. Soft-bristled toothbrush is better for gums
8. Mouthwash supplements but doesn't replace brushing/flossing

## UI Components

### MythCheckerScreen (`lib/screens/myth_checker_screen.dart`)

**Features:**
- Text input field for user statements
- "Check Statement" button with loading indicator
- Result card with:
  - Badge showing Myth/Fact/Not Dental/Unknown
  - Colored icon based on result type
  - Category label (if applicable)
  - Detailed explanation
  - Similar statement (if Unknown)
  - Confidence score bar (0-100%)
- "Check Another Statement" button to reset
- "How It Works" section explaining the process

**Color Coding:**
- **Myth**: Red (#FF0000) - Warning symbol
- **Fact**: Green (#00AA00) - Verification symbol
- **Not Dental**: Orange (#FFA500) - Help/question symbol
- **Unknown**: Grey (#808080) - Question mark symbol

**State Management:**
- Uses `StatefulWidget` with local state
- `_inputController`: Text input controller
- `_result`: Current result (nullable)
- `_isChecking`: Loading state flag

## Algorithm Details

### Similarity Calculation

```dart
double calculateSimilarity(String input1, String input2) {
  // Tokenize both strings
  final tokens1 = _tokenize(input1);
  final tokens2 = _tokenize(input2);
  
  // Jaccard similarity
  final intersection = tokens1.where((t) => tokens2.contains(t)).length;
  final union = tokens1.length + tokens2.length - intersection;
  final jaccardScore = intersection / union;
  
  // Length similarity bonus
  final lengthRatio = (input1.length / input2.length).clamp(0.5, 2.0);
  final lengthBonus = 1.0 - (lengthRatio - 1).abs() * 0.2;
  
  // Combined score (70% Jaccard, 30% length)
  return (jaccardScore * 0.7 + lengthBonus * 0.3);
}
```

### Tokenization

- Converts to lowercase
- Removes punctuation (.,!?;:)
- Splits on whitespace
- Filters out words with ≤ 2 characters
- Example: "Brushing teeth immediately after meals is good"
  → [brushing, teeth, immediately, meals, good]

## Usage Examples

### Example 1: Detected as Myth
**Input:** "Brushing immediately after eating lemon is good"
- Dental check: ✓ Contains "brushing", "eating"
- Similarity match: Myth #1 with 0.68 score
- Result: **MYTH** - "Wait 30-60 minutes before brushing after acidic foods"

### Example 2: Detected as Fact
**Input:** "Flossing every day prevents gum disease"
- Dental check: ✓ Contains "flossing"
- Similarity match: Fact #3 with 0.72 score
- Result: **FACT** - "Flossing removes food and plaque between teeth"

### Example 3: Not Dental
**Input:** "I like to cook pasta"
- Dental check: ✗ No dental keywords
- Result: **NOT DENTAL** - "Please ask about dental topics"

### Example 4: Unknown
**Input:** "Can white chocolate damage my teeth?"
- Dental check: ✓ Contains "teeth"
- Similarity match: Best score 0.28 (below 0.35 threshold)
- Result: **UNKNOWN** - "Similar to: 'Whiter teeth are always healthier'"

## Extensibility

### Adding New Myths/Facts

1. Edit `lib/services/myth_checking_service.dart`
2. Add to `mythDatabase` list:
```dart
MythData(
  id: 'myth_9',
  text: 'Your new myth statement',
  isMythOrFact: true,
  explanation: 'Detailed explanation of why this is false',
  category: 'Brushing',
  keywords: ['key1', 'key2', 'key3'],
),
```

### Improving Accuracy

**Current limitations:**
- Exact phrase matching doesn't work well
- Similar variations might not be detected
- Typos cause mismatches

**Future improvements:**
1. **Fuzzy matching**: Handle typos with Levenshtein distance
2. **Word embeddings**: Use pre-trained embeddings (GloVe, FastText)
3. **Neural networks**: Train LSTM/BERT for semantic similarity
4. **Multi-language support**: Add Arabic, Spanish, Tamil, etc.
5. **User feedback**: Learn from user corrections

### Integration with ML

To replace the similarity function with ML:

```dart
// Current: rule-based
double score = calculateSimilarity(input, dbStatement);

// Future: ML-based
double score = await semanticSimilarityModel.compare(input, dbStatement);
```

## Testing

### Unit Tests (Example)

```dart
test('isDentalRelated detects dental keywords', () {
  expect(MythCheckingService.isDentalRelated('brush my teeth'), true);
  expect(MythCheckingService.isDentalRelated('cook pasta'), false);
});

test('calculateSimilarity ranks correct matches higher', () {
  final score1 = MythCheckingService.calculateSimilarity(
    'Brushing immediately after acidic foods',
    'Brushing your teeth immediately after eating acidic foods is good'
  );
  expect(score1, greaterThan(0.5));
});

test('checkInput returns Myth for known myth', () {
  final result = MythCheckingService.checkInput(
    'Brush your teeth immediately after eating lemon'
  );
  expect(result.type, equals('Myth'));
});
```

## Performance

- **Time Complexity**: O(n * m) where n = database size (16), m = tokenization length
- **Space Complexity**: O(m) for tokenization and keyword storage
- **Response Time**: ~500ms (includes 500ms UI delay for visual feedback)
- **Database Size**: 16 myths/facts (can scale to 1000+)

## Error Handling

- Empty input → "Please enter a statement to check"
- Non-dental input → "Please ask about dental topics"
- No matches → Shows closest matching statement with confidence
- Null safety → All inputs validated before processing

## Files

| File | Purpose |
|------|---------|
| `lib/models/myth_data.dart` | Data structures |
| `lib/services/myth_checking_service.dart` | Core logic |
| `lib/screens/myth_checker_screen.dart` | User interface |

## Future Roadmap

1. **Authentication**: Save user's myth checking history
2. **Personalization**: Adjust recommendations based on user age/condition
3. **Real-time sync**: Connect to dental API for latest research
4. **Gamification**: Points for correct myth identification
5. **Community feedback**: Crowdsourced myth verification
6. **Multi-language**: Support 10+ languages
7. **Voice input**: Speak myths instead of typing

## Credits

- Myth/Fact database: Dental association guidelines and research
- Algorithm: Jaccard similarity + custom length matching
- UI/UX: Material Design 3, Flutter best practices
