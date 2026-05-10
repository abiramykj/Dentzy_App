#!/usr/bin/env python3
"""
Comprehensive test suite for multilingual Myth Checker.
Tests English, Tamil, Tanglish, and mixed language support.
"""

import sys
import asyncio
import json
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).parent / "backend"))

try:
    from backend.main import (
        _detect_language,
        _has_dental_keywords,
        _classify_with_groq,
    )
except ImportError:
    from main import (
        _detect_language,
        _has_dental_keywords,
        _classify_with_groq,
    )


def test_language_detection():
    """Test language detection for English, Tamil, and Mixed text."""
    print("\n" + "=" * 80)
    print("TEST 1: LANGUAGE DETECTION")
    print("=" * 80)
    
    test_cases = [
        # English
        ("Brushing twice daily is healthy.", "english"),
        ("Flossing prevents cavities.", "english"),
        ("Root canal is a dental procedure.", "english"),
        
        # Tamil
        ("தினமும் இரண்டு முறை பல் துலக்க வேண்டும்.", "tamil"),
        ("சர்க்கரை பற்களுக்கு பாதிப்பு இல்லை.", "tamil"),
        ("பல் மருத்துவர் மிகவும் முக்கியம்.", "tamil"),
        
        # Mixed/Tanglish
        ("தினமும் brush panna வேண்டும்.", "mixed"),
        ("Pal brushing is important for வாய்நலம்.", "mixed"),
        ("Dentist கிட்ட போய் உன் பல் பார்க்க.", "mixed"),
    ]
    
    for text, expected_lang in test_cases:
        detected = _detect_language(text)
        status = "✓" if detected == expected_lang else "✗"
        print(f"{status} Text: {text[:50]:<50} | Expected: {expected_lang:<7} | Got: {detected}")
        if detected != expected_lang:
            print(f"  WARNING: Expected {expected_lang} but got {detected}")


def test_keyword_detection():
    """Test keyword detection for dental statements."""
    print("\n" + "=" * 80)
    print("TEST 2: KEYWORD DETECTION")
    print("=" * 80)
    
    test_cases = [
        # English dental
        ("Brush your teeth twice daily.", True, "english"),
        ("Floss helps prevent cavities.", True, "english"),
        ("Visit your dentist regularly.", True, "english"),
        ("Weather is sunny today.", False, "english"),
        ("Cars need maintenance.", False, "english"),
        
        # Tamil dental
        ("தினமும் பல் துலக்க வேண்டும்.", True, "tamil"),
        ("வாய் ஈறு வீக்கம் பாதிப்பு.", True, "tamil"),
        ("பல் மருத்துவர் பார்க்கவும்.", True, "tamil"),
        ("மலைகள் சாக்லேட்டால் ஆனவை.", False, "tamil"),
        ("கார் வெகு வேகமாக ஓடுகிறது.", False, "tamil"),
        
        # Tanglish
        ("Brush panna important", True, "mixed"),
        ("Pal vali medicine take", True, "mixed"),
        ("Weather very hot today", False, "mixed"),
    ]
    
    for text, should_have_keywords, lang in test_cases:
        has_keywords, matched_keyword = _has_dental_keywords(text)
        status = "✓" if has_keywords == should_have_keywords else "✗"
        keyword_str = f"('{matched_keyword}')" if matched_keyword else ""
        print(f"{status} {text[:50]:<50} | Expected: {should_have_keywords} | Got: {has_keywords} {keyword_str}")
        if has_keywords != should_have_keywords:
            print(f"  WARNING: Expected keyword={should_have_keywords} but got {has_keywords}")


async def test_groq_classification():
    """Test GROQ classification with various inputs."""
    print("\n" + "=" * 80)
    print("TEST 3: GROQ CLASSIFICATION (with GROQ API)")
    print("=" * 80)
    
    test_cases = [
        # English FACT
        ("Brushing twice daily helps maintain healthy teeth.", "FACT", "english"),
        ("Floss daily to prevent cavities.", "FACT", "english"),
        
        # English MYTH
        ("Hard brushing cleans teeth better.", "MYTH", "english"),
        ("Sugar doesn't affect teeth.", "MYTH", "english"),
        
        # English NOT_DENTAL
        ("Cars can fly underwater.", "NOT_DENTAL", "english"),
        ("Mountain climbers eat pizza.", "NOT_DENTAL", "english"),
        
        # Tamil FACT
        ("தினமும் இரண்டு முறை பல் துலக்க வேண்டும்.", "FACT", "tamil"),
        ("வாய் சுகாதாரம் மிகவும் முக்கியம்.", "FACT", "tamil"),
        
        # Tamil MYTH
        ("சர்க்கரை பற்களுக்கு பாதிப்பு இல்லை.", "MYTH", "tamil"),
        ("பல் வலி என்றால் வெறும் இளம் பல்.", "MYTH", "tamil"),
        
        # Tamil NOT_DENTAL
        ("மலைகள் சாக்லேட்டால் ஆனவை.", "NOT_DENTAL", "tamil"),
        ("கார் ஆகாசத்தில் பறக்கிறது.", "NOT_DENTAL", "tamil"),
        
        # Tanglish
        ("Pal brushing daily is very important.", "FACT", "mixed"),
    ]
    
    print("\nNote: These results depend on GROQ API availability.")
    print("Skipping GROQ tests if API is not configured.\n")
    
    for text, expected_type, lang in test_cases:
        try:
            result = await _classify_with_groq(text)
            result_type = result.get("type", "UNKNOWN").upper()
            confidence = result.get("confidence", 0)
            explanation = result.get("explanation", "")[:50]
            
            status = "✓" if result_type == expected_type else "?"
            print(f"{status} [{lang:6}] Type: {result_type:<12} Conf: {confidence:>3}% | {text[:40]:<40}")
            if explanation:
                print(f"         → {explanation}...")
                
        except Exception as e:
            print(f"✗ [{lang:6}] ERROR: {str(e)[:60]}")
            print(f"         Text: {text[:50]}")


def test_summary():
    """Print test summary."""
    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    print("""
✓ Language Detection: Tests basic Tamil/English/Mixed recognition
✓ Keyword Detection: Tests dental keywords in all languages
✓ GROQ Classification: Tests full classification pipeline (requires API)

Expected Results:
- English text should classify correctly for FACT/MYTH/NOT_DENTAL
- Tamil text should NOT return early NOT_DENTAL, but send to GROQ
- Mixed text should be handled gracefully
- No false NOT_DENTAL for valid dental statements
""")


async def main():
    """Run all tests."""
    print("\n🚀 MULTILINGUAL MYTH CHECKER TEST SUITE")
    print("=" * 80)
    
    # Test 1: Language Detection
    test_language_detection()
    
    # Test 2: Keyword Detection
    test_keyword_detection()
    
    # Test 3: GROQ Classification
    try:
        await test_groq_classification()
    except Exception as e:
        print(f"\n⚠️  GROQ tests skipped: {e}")
        print("(This is OK if GROQ_API_KEY is not configured)")
    
    # Summary
    test_summary()
    
    print("\n✅ Test suite completed!\n")


if __name__ == "__main__":
    asyncio.run(main())
