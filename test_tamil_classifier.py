#!/usr/bin/env python3
"""Test script for Tamil language classification."""

import sys
import re
from pathlib import Path

# Add backend to path
backend_path = Path(__file__).parent / "backend"
sys.path.insert(0, str(backend_path))

# Test language detection
def detect_language(text: str) -> str:
    """Detect whether text is English, Tamil, or mixed."""
    if not text or not text.strip():
        return "english"
    
    # Tamil Unicode ranges: U+0B80 to U+0BFF
    tamil_pattern = re.compile(r'[\u0B80-\u0BFF]')
    english_pattern = re.compile(r'[a-zA-Z]')
    
    has_tamil = bool(tamil_pattern.search(text))
    has_english = bool(english_pattern.search(text))
    
    if has_tamil and has_english:
        return "mixed"
    elif has_tamil:
        return "tamil"
    else:
        return "english"


def test_language_detection():
    """Test language detection."""
    test_cases = [
        ("பல் மிகவும் குண்டாகிவிட்டால் தேய்த்தால் சரியாகும்", "tamil"),
        ("ஒரு நாளில் இரண்டு முறை பல் துலக்க வேண்டும்", "tamil"),
        ("விமானம் தண்ணீரில் ஓடும்", "tamil"),
        ("Flossing ஈறுகளை பாதுகாக்க உதவும்", "mixed"),
        ("Flossing helps protect your gums", "english"),
        ("Brushing twice daily is important", "english"),
    ]
    
    print("=" * 80)
    print("LANGUAGE DETECTION TESTS")
    print("=" * 80)
    
    for text, expected_lang in test_cases:
        detected = detect_language(text)
        status = "✅ PASS" if detected == expected_lang else "❌ FAIL"
        print(f"{status} | Expected: {expected_lang:10} | Got: {detected:10} | Text: {text[:50]}")


def is_dental_related(sentence: str) -> bool:
    """Check if sentence is related to dental health (English, Tamil, and Tanglish)."""
    text = (sentence or "").lower()
    
    # English keywords
    english_keywords = (
        "tooth",
        "teeth",
        "dental",
        "dentist",
        "brush",
        "brushing",
        "floss",
        "gum",
        "gums",
        "cavity",
        "cavities",
        "plaque",
        "tartar",
        "enamel",
        "mouth",
        "oral",
        "fluoride",
        "toothpaste",
        "toothbrush",
        "whitening",
        "cleaning",
        "decay",
    )
    
    # Tamil keywords (in Tamil script)
    tamil_keywords = (
        "பல்",  # tooth/paal
        "ஈறு",  # gums/iru
        "ஈறுகளை",  # gums (accusative)
        "துலக்க",  # brush/sweep
        "வாய்",  # mouth
        "ஆரோக்கியம்",  # health
        "சுளுவ",  # cavity
        "சுளுவு",  # cavity
        "நோய்",  # disease
    )
    
    # Check English keywords
    has_english_keyword = any(keyword in text for keyword in english_keywords)
    
    # Check Tamil keywords (case-sensitive for Unicode)
    has_tamil_keyword = any(keyword in sentence for keyword in tamil_keywords)
    
    return has_english_keyword or has_tamil_keyword


def test_dental_detection():
    """Test dental health detection."""
    test_cases = [
        ("பல் மிகவும் குண்டாகிவிட்டால் தேய்த்தால் சரியாகும்", True, "Tamil with 'பல்'"),
        ("ஒரு நாளில் இரண்டு முறை பல் துலக்க வேண்டும்", True, "Tamil with 'பல்' and 'துலக்க'"),
        ("விமானம் தண்ணீரில் ஓடும்", False, "Tamil NOT dental"),
        ("Flossing ஈறுகளை பாதுகாக்க உதவும்", True, "Mixed with 'Flossing' and 'ஈறுகளை'"),
        ("Flossing helps protect your gums", True, "English dental"),
        ("The airplane flies in the sky", False, "English NOT dental"),
    ]
    
    print("\n" + "=" * 80)
    print("DENTAL DETECTION TESTS")
    print("=" * 80)
    
    for text, expected, description in test_cases:
        detected = is_dental_related(text)
        status = "✅ PASS" if detected == expected else "❌ FAIL"
        print(f"{status} | {description:40} | Text: {text[:45]}")


if __name__ == "__main__":
    test_language_detection()
    test_dental_detection()
    print("\n" + "=" * 80)
    print("Tests completed!")
    print("=" * 80)
