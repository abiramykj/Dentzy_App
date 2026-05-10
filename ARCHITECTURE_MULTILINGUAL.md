# Multilingual Myth Checker - Architecture & Flow

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                            │
│                   (Sends text statements)                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    POST /classify
                    (InputText)
                             │
        ┌────────────────────▼────────────────────┐
        │   FastAPI Backend (main.py)             │
        │                                         │
        │  ┌─────────────────────────────────────┐│
        │  │ 1. LANGUAGE DETECTION               ││
        │  │    _detect_language()               ││
        │  │    - Detects: English/Tamil/Mixed  ││
        │  │    - Uses: Character ratio analysis││
        │  └─────────────────────────────────────┘│
        │                   │                      │
        │  ┌────────────────▼──────────────────────┐
        │  │ 2. KEYWORD DETECTION                 │
        │  │    _has_dental_keywords()            │
        │  │    - Unicode normalization (NFC)     │
        │  │    - 44 English keywords             │
        │  │    - 50+ Tamil keywords              │
        │  │    - 23 Tanglish keywords            │
        │  └────────────────┬─────────────────────┘
        │                   │
        │  ┌────────────────▼──────────────────────┐
        │  │ 3. ROUTING DECISION                  │
        │  │                                      │
        │  │ IF English + No Keywords             │
        │  │   → EARLY EXIT: Return NOT_DENTAL   │
        │  │   (Fast path)                       │
        │  │                                      │
        │  │ IF Tamil/Mixed (Any status)          │
        │  │   → PERMISSIVE MODE: Send to GROQ   │
        │  │   (Accurate path)                   │
        │  │                                      │
        │  │ IF Keywords Found                    │
        │  │   → Send to GROQ                     │
        │  └────────────────┬─────────────────────┘
        │                   │
        │  ┌────────────────▼──────────────────────┐
        │  │ 4. GROQ CLASSIFICATION               │
        │  │    _classify_with_groq()             │
        │  │                                      │
        │  │ System Prompt determines:            │
        │  │ - Is it dental-related?              │
        │  │ - FACT or MYTH?                      │
        │  │                                      │
        │  │ Models tried:                        │
        │  │ 1. llama-3.3-70b-versatile (primary) │
        │  │ 2. llama-3.1-8b-instant (fallback)   │
        │  └────────────────┬─────────────────────┘
        │                   │
        │  ┌────────────────▼──────────────────────┐
        │  │ 5. RESPONSE NORMALIZATION            │
        │  │                                      │
        │  │ - type: FACT|MYTH|NOT_DENTAL         │
        │  │ - confidence: 0-100                  │
        │  │ - explanation: UTF-8 string          │
        │  │   (Language preserved)               │
        │  └────────────────┬─────────────────────┘
        │                   │
        └───────────────────┼─────────────────────┘
                            │
                    JSON Response
                            │
        ┌───────────────────▼─────────────────────┐
        │    Flutter Mobile App                   │
        │   (Displays result to user)             │
        └─────────────────────────────────────────┘
```

---

## 🔄 Language-Specific Flows

### English Text Flow (Fast Path)
```
"Brush your teeth twice daily"
        │
        ├─→ Language Detection: english ✓
        │
        ├─→ Keyword Detection: "teeth" found ✓
        │
        ├─→ Send to GROQ
        │
        └─→ Response: FACT (100%)
```

### Tamil Text Flow (Accurate Path)
```
"தினமும் பல் துலக்க வேண்டும்."
        │
        ├─→ Language Detection: tamil ✓
        │
        ├─→ Keyword Detection: "பல்" found ✓
        │
        ├─→ PERMISSIVE MODE: Send to GROQ
        │   (Even if no keywords found)
        │
        └─→ Response: FACT (100%)
            [In Tamil]
```

### Mixed Language (Tanglish) Flow
```
"Pal brushing daily is important for வாய்நலம்"
        │
        ├─→ Language Detection: mixed ✓
        │
        ├─→ Keyword Detection: "brush" + "வாய்" found ✓
        │
        ├─→ Send to GROQ
        │
        └─→ Response: FACT (100%)
```

### Non-Dental English (Early Exit)
```
"Cars can fly underwater"
        │
        ├─→ Language Detection: english ✓
        │
        ├─→ Keyword Detection: No keywords ✗
        │
        ├─→ EARLY EXIT (English optimization)
        │
        └─→ Response: NOT_DENTAL (100%)
            [Immediate, no GROQ call]
```

### Non-Dental Tamil (Permissive Mode)
```
"மலைகள் சாக்லேட்டால் ஆனவை"
        │
        ├─→ Language Detection: tamil ✓
        │
        ├─→ Keyword Detection: No keywords ✗
        │
        ├─→ PERMISSIVE MODE: Still send to GROQ
        │   (Because Tamil detection is less reliable)
        │
        └─→ Response: NOT_DENTAL (100%)
            [GROQ determines it's non-dental]
```

---

## 🔑 Key Components & Their Roles

### 1. `_detect_language(text)`
```python
# Returns: "english" | "tamil" | "mixed"
# Uses: Character ratio analysis
# Tamil Unicode: U+0B80 to U+0BFF
# Treats as Tamil if >= 20% Tamil characters
```

### 2. `_has_dental_keywords(text)`
```python
# Returns: (has_keywords: bool, matched_keyword: str|None)
# Uses: Unicode normalization (NFC)
# Checks: English keywords
#         Tamil keywords (Unicode-safe)
#         Tanglish keywords
# Logs: Which keyword matched for debugging
```

### 3. `_classify_with_groq(sentence)`
```python
# Main classification function
# 
# Logic:
# 1. Detect language
# 2. Check keywords
# 3. Route decision:
#    - English + no keywords → NOT_DENTAL (early exit)
#    - Tamil/mixed → Send to GROQ (permissive mode)
#    - Keywords found → Send to GROQ
# 4. Call GROQ with system prompt
# 5. Parse and normalize response
```

### 4. `SYSTEM_PROMPT`
```
Instructs GROQ to:
1. First: Determine if statement is dental-related
2. If not dental → Return NOT_DENTAL
3. If dental → Classify as FACT or MYTH

Supports all three languages and returns explanations
in the language of the input.
```

---

## 📊 Data Structures

### Keyword Lists

**English Keywords (44 total)**
```python
[
    "tooth", "teeth", "brush", "brushing", "toothpaste", 
    "floss", "gum", "gums", "mouth", "oral", "dental", 
    "dentist", "cavity", "plaque", "enamel", "mouthwash",
    "oral hygiene", "tooth decay", "bad breath", 
    "bleeding gums", "cavity filling", "root canal",
    "orthodontics", "whitening", "cleaning", "periodontist",
    "gingivitis", "periodontitis", "canker sore", 
    "mouth ulcer", "tartar", "calculus", "sensitivity", 
    "fluoride", "smile", "bite", "malocclusion", "braces", 
    "implant", "crown", "bridge", "dentures", "extraction", 
    "prophylaxis", "scaling", "root planing", "deep clean", 
    "professional clean"
]
```

**Tamil Keywords (50+ total)**
```python
[
    "பல்", "பற்கள்", "பற்களை", "பல்லு", "வாய்", "ஈறு",
    "பற்பசை", "துலக்கு", "பல் மருத்துவர்", "வாய்நலம்",
    "பல் வலி", "கேவிட்டி", "பாக்டீரியா", "வாய்துர்நாற்றம்",
    "ஈறு வீக்கம்", "வாய் சுகாதாரம்", "பற்கள் சுகாதாரம்",
    ... (and more specific dental terms)
]
```

**Tanglish Keywords (23 total)**
```python
[
    "pal", "pallu", "pall", "brush panna", "tooth paste", 
    "toothpaste", "dentist paakanum", "pal vali", "vay nalam",
    "pal brushing", "paal", "brush", "teeth", "tooth", "oral",
    "dental", "kaviti", "bacteria", "vay", "mouth", "gum",
    "brush panikal", "pal brushing", "tooth cleaning"
]
```

---

## ⚡ Performance Characteristics

| Scenario | Path | Time | GROQ Calls |
|----------|------|------|-----------|
| English, no keywords | Early Exit | <1ms | 0 |
| English, keywords | GROQ | ~300-500ms | 1 |
| Tamil, keywords | GROQ | ~300-500ms | 1 |
| Tamil, no keywords | GROQ (Permissive) | ~300-500ms | 1 |
| Mixed language | GROQ | ~300-500ms | 1 |

**Timeout:** 18 seconds total per request (15s GROQ timeout)

---

## 🧪 Testing Strategy

### Unit Tests: Language Detection
- ✓ English texts
- ✓ Tamil texts
- ✓ Mixed/Tanglish texts

### Unit Tests: Keyword Detection
- ✓ English keywords
- ✓ Tamil keywords (Unicode)
- ✓ Tanglish keywords
- ✓ Non-dental texts

### Integration Tests: GROQ Classification
- ✓ English FACT/MYTH/NOT_DENTAL
- ✓ Tamil FACT/MYTH/NOT_DENTAL
- ✓ Tanglish FACT/MYTH
- ✓ Response time < 1s

All tests in: `test_multilingual_myth_checker.py`

---

## 🎯 Design Principles

1. **Unicode-First:** All text processing is Unicode-aware
2. **Language-Aware Routing:** Different logic for different languages
3. **Permissive for Non-English:** Tamil/mixed text gets more chances
4. **Efficient for English:** Early exit for clearly non-dental English
5. **Comprehensive Keywords:** Covers common terms in all languages
6. **Debug Transparency:** Logs show exactly what's happening
7. **Graceful Degradation:** Fallback models, timeout handling
8. **Response Consistency:** Always returns valid JSON structure

---

## ✅ Validation Checklist

- ✅ Language detection works for all 3 types
- ✅ Keyword matching uses Unicode normalization
- ✅ Tamil statements reach GROQ (not early-exit)
- ✅ English statements still use early-exit (efficient)
- ✅ GROQ responses properly normalized
- ✅ All existing features preserved
- ✅ Debug logging comprehensive
- ✅ Test suite all passing
- ✅ Backend compiles without errors
- ✅ API endpoints functional

---

**Result: Professional, reliable, multilingual Myth Checker system** ✨
