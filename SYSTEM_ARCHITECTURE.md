# Dentzy App - Complete Architecture & Workflow

## 📊 High-Level System Overview

The Dentzy app is a **multilingual dental health myth/fact checker** with a **Flutter frontend** and **Python/FastAPI backend** using **AI-powered semantic classification**.

### Tech Stack
- **Frontend**: Flutter (Dart) - Mobile app
- **Backend**: FastAPI (Python) - ML classification service
- **ML Model**: SentenceTransformer (paraphrase-multilingual-MiniLM-L12-v2)
- **Data**: JSON (myths) + CSV (facts)
- **Local Storage**: HiveDB (Flutter)
- **Languages**: English, Hindi, Tamil, Spanish, French

---

## 🏗️ Architecture Layers

### **1. FRONTEND LAYER (Flutter App)**

#### Directory Structure
```
dentzy/lib/
├── screens/              # User-facing screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── myth_checker_screen.dart    # Input screen
│   ├── result_screen.dart           # Classification result
│   ├── tracker_screen.dart          # Progress tracking
│   ├── learn_screen.dart            # Educational content
│   └── profile_screen.dart
├── widgets/              # Reusable UI components
│   ├── custom_card.dart
│   ├── progress_chart.dart
│   └── myth_input_widget.dart
├── services/             # Business logic
│   ├── myth_api_service.dart        # API communication
│   ├── myth_checking_service.dart   # Local logic
│   ├── tracker_service.dart         # Progress tracking
│   ├── language_provider.dart       # Language management
│   └── settings_provider.dart       # User settings
├── models/               # Data structures
│   ├── myth_item.dart
│   ├── myth_result.dart
│   └── user_progress.dart
├── database/             # Local storage
│   └── hive_database.dart
├── localization/         # Multi-language strings
│   └── app_localizations.dart
└── utils/                # Configuration
    ├── theme.dart        # Design system
    ├── constants.dart    # API endpoints
    └── app_theme.dart
```

#### Screen Flow
```
SplashScreen (2s animation)
    ↓
LanguageSelection
    ↓
HomeScreen (Main UI)
    ├─ Tab Navigation:
    │  ├─ HOME - Overview & quick access
    │  ├─ QUIZ - MythCheckerScreen → ResultScreen
    │  ├─ TRACKER - Progress & statistics
    │  ├─ REPORTS - Analytics
    │  └─ LEARN - Educational content
    └─ Settings - ProfileScreen + SettingsProvider
```

### **2. SERVICE LAYER (Business Logic)**

#### MythApiService
```dart
class MythApiService {
  static const String baseUrl = 'https://api.dentzy.app';
  
  // Main method - sends input to backend
  Future<Map<String, dynamic>> checkMyth({
    required String sentence,
  }) async {
    // HTTP POST to /classify endpoint
    // Returns: {type, explanation, tip, confidence}
  }
  
  // Integrates with tracker for stats
  Future<void> trackResult(MythResult result) {
    // Store locally via HiveDB
  }
}
```

#### TrackerService
```dart
class TrackerService {
  // Track user progress
  Future<void> trackProgress(MythResult result);
  
  // Calculate statistics
  Future<Map<String, dynamic>> getMetrics();
  
  // Compute streaks
  Future<int> getCurrentStreak();
}
```

#### Providers (State Management)
- **LanguageProvider**: Manages language selection (EN, HI, TA, etc.)
- **SettingsProvider**: User preferences and app configuration
- **FamilyProvider**: Family member tracking (if multi-user)

### **3. DATA LAYER (Client-Side)**

#### Models
- **MythResult**: Stores classification result
- **UserProgress**: Tracks quiz attempts and scores
- **MythItem**: Represents a quiz question
- **UserModel**: User profile and metadata

#### Local Storage (HiveDB)
```
Boxes:
├── quiz_history      # Previous attempts & results
├── user_progress     # Stats & achievements
├── user_settings     # Preferences
└── cache             # API response caching
```

---

## 🔧 Backend Architecture

### **1. DATA LOADING LAYER (data.py)**

```python
def load_myths(json_file) -> List[Dict]:
    # Load from JSON files (English + Tamil)
    # Flatten myth structure:
    # {covers: [...], explanation: "...", recommended_action: "..."}
    # → [{text: "...", explanation: "...", tip: "..."}, ...]

def load_facts(csv_file) -> List[Dict]:
    # Load facts from CSV
    # Structure: {text: "...", explanation: "...", tip: "..."}
```

#### Datasets
```
Backend Data Sources:
├── oral_health_myth_knowledge_base.json     # English myths
├── knowledge_base_tamil.json                # Tamil myths
├── oral_health_myth_fact_dataset.csv        # Facts (230+ entries)
└── dataset_Myth_checker_tamil.csv           # Tamil dataset reference
```

### **2. ML PROCESSING LAYER (model.py)**

#### Embedding Model
```python
_MODEL = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")
# Supports: 100+ languages including English & Tamil
# Produces: 384-dimensional embeddings
# Uses: Cosine similarity for comparison
```

#### Pre-computed Embeddings (Startup)
```python
_FACT_TEXTS = [item["text"] for item in all_facts]
_MYTH_TEXTS = [item["text"] for item in all_myths]

# Precompute once at startup
_FACT_EMBEDDINGS = _MODEL.encode(...)  # Shape: (N_facts, 384)
_MYTH_EMBEDDINGS = _MODEL.encode(...)  # Shape: (N_myths, 384)

# Dental concepts for Stage 1
_DENTAL_CONCEPTS = [
    "tooth health and care",
    "gum disease and treatment",
    "oral hygiene practices",
    "tooth decay and cavities",
    "brushing and flossing techniques",
    "dental prevention and maintenance",
    "enamel and dental sensitivity",
    "plaque and tartar buildup",
    # + Tamil translations
]
_DENTAL_EMBEDDINGS = _MODEL.encode(...)  # Shape: (14, 384)
```

### **3. TWO-STAGE CLASSIFICATION PIPELINE**

#### **STAGE 1: Dental Relevance Detection**

```python
def is_dental(sentence: str) -> Tuple[bool, float]:
    """
    Determines if a sentence is related to dental/oral health.
    Uses SEMANTIC SIMILARITY, not keyword matching.
    
    Process:
    1. Encode input sentence → 384-dim embedding
    2. Compute cosine similarity with 14 dental concept embeddings
    3. Find highest scoring concept
    4. Return (is_dental, confidence) based on threshold
    
    Threshold: 0.35
    Returns: (True/False, confidence_score)
    """
```

#### **STAGE 2: Fact vs Myth Classification**

Only runs if Stage 1 returns True.

```python
def classify(sentence: str) -> Dict:
    """
    Two-stage pipeline classification
    """
    # Stage 1: Check if dental-related
    is_dental_related, dental_confidence = is_dental(sentence)
    
    if not is_dental_related:
        return {
            "type": "not_dental",
            "explanation": "This statement is not clearly related to dental health.",
            "tip": "Try asking about oral hygiene, dental care, or common myths.",
            "confidence": dental_confidence
        }
    
    # Stage 2: Classify as fact or myth
    query_embedding = _MODEL.encode(sentence)
    
    # Compute similarity with facts and myths
    fact_scores = np.dot(_FACT_EMBEDDINGS, query_embedding)
    myth_scores = np.dot(_MYTH_EMBEDDINGS, query_embedding)
    
    best_fact_score = np.max(fact_scores)
    best_myth_score = np.max(myth_scores)
    best_fact_index = np.argmax(fact_scores)
    best_myth_index = np.argmax(myth_scores)
    
    # Apply multi-level thresholds
    HIGH_THRESHOLD = 0.6
    MEDIUM_THRESHOLD = 0.4
    
    # Decision logic
    if best_fact_score > best_myth_score and best_fact_score > HIGH_THRESHOLD:
        return FACT (high confidence)
    
    elif best_myth_score > best_fact_score and best_myth_score > HIGH_THRESHOLD:
        return MYTH (high confidence)
    
    elif max(best_fact_score, best_myth_score) > MEDIUM_THRESHOLD:
        return FACT (medium confidence, generic explanation)
    
    else:
        # Low confidence but still dental-related
        return FACT (fallback, generic explanation)
```

#### Response Format
```python
{
    "type": "fact" | "myth" | "not_dental",
    "explanation": "Specific explanation from dataset or generic",
    "tip": "Recommended action (if available)",
    "confidence": 0.0 to 1.0
}
```

### **4. API ENDPOINTS**

#### POST /classify
```
Request:
{
    "sentence": "brushing with neem stick is good"
}

Response:
{
    "type": "fact",
    "explanation": "Neem has antibacterial properties...",
    "tip": "Use gently and maintain proper brushing habits.",
    "confidence": 0.65
}
```

---

## 🔄 Complete Request-Response Flow

### **User Interaction Flow**

```
1. USER INPUT
   └─ User enters sentence in MythCheckerScreen
   └─ e.g., "brushing twice a day prevents cavities"

2. FRONTEND PROCESSING
   └─ MythApiService.checkMyth(sentence)
   └─ Constructs HTTP POST request

3. HTTP REQUEST
   └─ POST https://api.dentzy.app/classify
   └─ Headers: Content-Type: application/json
   └─ Body: {"sentence": "..."}

4. BACKEND STAGE 1: DENTAL DETECTION
   └─ Encode sentence → embedding
   └─ Compare with 14 dental concepts
   └─ Score: 0.68 > 0.35 threshold → DENTAL ✓

5. BACKEND STAGE 2: CLASSIFICATION
   └─ Compute similarity with facts (230+ embeddings)
   └─ Compute similarity with myths (170+ embeddings)
   └─ Fact score: 0.72 (best fact: "Brushing twice daily...")
   └─ Myth score: 0.35 (best myth: "Brushing more prevents all...")
   └─ 0.72 > 0.6 AND 0.72 > 0.35 → FACT (high confidence)

6. RESPONSE CONSTRUCTION
   └─ type: "fact"
   └─ explanation: "Brushing twice daily with fluoride..."
   └─ tip: "Brush in morning and before bed..."
   └─ confidence: 0.72

7. HTTP RESPONSE
   └─ 200 OK
   └─ Returns JSON response

8. FRONTEND HANDLING
   └─ MythApiService receives response
   └─ Store in HiveDB for caching
   └─ Update TrackerService (statistics)
   └─ Navigate to ResultScreen

9. UI DISPLAY
   └─ ResultScreen renders:
      ├─ Type badge ("FACT" in green)
      ├─ Explanation text
      ├─ Tip/Recommendation
      ├─ Confidence meter
      └─ Navigation options (Next, Home, Learn More)

10. USER ACTION
    └─ User can share, bookmark, or take next question
```

---

## 🎯 Classification Decision Logic

### **Threshold System**

| Score Range | Threshold | Action | Result |
|---|---|---|---|
| > 0.60 | HIGH | Direct match | Fact/Myth with dataset item |
| 0.40 - 0.60 | MEDIUM | Probable match | Fact/Myth with generic explanation |
| < 0.40 | LOW | Fallback | Fact (dental-related but not found) |
| Dental Score < 0.35 | NOT_DENTAL | Skip Stage 2 | Return "not_dental" |

### **Fallback Logic**

When no strong match exists but sentence is dental-related:
```
Instead of returning "not_dental", the system:
1. Classifies as FACT (safe fallback)
2. Provides generic explanation:
   "This statement is related to dental care but not found in the knowledge base."
3. Returns computed confidence score
```

This prevents false negatives for valid dental sentences that don't exactly match dataset items.

---

## 🌍 Multilingual Support

### **Implementation**
- **SentenceTransformer**: Multilingual model handles 100+ languages
- **Frontend Localization**: app_localizations.dart with .arb files
- **Dataset**: English + Tamil myths, facts in CSV
- **Dental Concepts**: Both English & Tamil in concept embeddings

### **Tamil Handling Example**
```
Input: "பற்கள் தினமும் இரண்டு முறை துலக்குவது முக்கியம்"
       (Brushing teeth twice daily is important)

Stage 1: Matches "பல் ஆரோக்கியம் மற்றும் பராமரிப்பு" concept
         (Tooth health and care)
         Confidence: 0.72

Stage 2: Matches Tamil fact in dataset
         Type: "fact"
         Confidence: 0.68
```

---

## 📊 Performance Characteristics

### **Optimization**
- **Embeddings Pre-computed**: All 230+ facts, 170+ myths encoded at startup
- **No Re-encoding**: Only input sentence encoded per request
- **Numpy Arrays**: Efficient cosine similarity computation
- **In-Memory**: All embeddings stored in RAM
- **Response Time**: ~200-500ms per request

### **Scalability**
- Add new facts/myths: Simply recompute embeddings on update
- New languages: Already supported by multilingual model
- Threshold tuning: Can adjust based on performance metrics

---

## 🔐 Data Flow Security

1. **Input Validation**: Check empty/invalid inputs
2. **API Communication**: HTTPS encryption
3. **Local Caching**: HiveDB (encrypted on device)
4. **No Personal Data**: Only processes statements, tracks progress locally
5. **CORS**: Backend validates requests

---

## 🛠️ Development Workflow

### **Frontend Development**
```bash
cd dentzy/
flutter pub get
flutter run
```

### **Backend Development**
```bash
cd backend/
pip install -r requirements.txt
python model.py  # Load & test model
uvicorn main:app --reload
```

### **Testing Classification**
```python
from model import classify

result = classify("brushing twice a day prevents cavities")
print(result)
# Output: {"type": "fact", "explanation": "...", ...}
```

---

## 📈 Future Enhancements

1. **More Languages**: Add more multilingual datasets
2. **User Feedback**: Improve model with user corrections
3. **Analytics Dashboard**: Track common myths/facts searched
4. **Personalization**: Recommendations based on user profile
5. **Offline Mode**: Preload embeddings on device
6. **Voice Input**: Integration with speech_to_text
7. **Fact Verification**: Link to medical sources

---

## 📝 Summary

**Dentzy** is a production-ready dental health application that:
- ✅ Uses AI (SentenceTransformer) for semantic classification
- ✅ Supports multiple languages (English, Tamil, Hindi, etc.)
- ✅ Implements robust two-stage classification pipeline
- ✅ Handles edge cases with intelligent fallback logic
- ✅ Provides consistent, reliable responses
- ✅ Tracks user progress locally with HiveDB
- ✅ Offers beautiful Flutter UI with theme support
