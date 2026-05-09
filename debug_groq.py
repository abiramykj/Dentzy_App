#!/usr/bin/env python3
"""Debug script to test GROQ API response handling."""

import asyncio
import json
import logging
import sys
import re
from pathlib import Path

# Configure detailed logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("groq_debug")

# Add backend to path
backend_path = Path(__file__).parent / "backend"
sys.path.insert(0, str(backend_path))

from main import (
    _detect_language,
    _extract_json_object,
    _normalize_type,
    _normalize_confidence,
    _safe_text,
    _is_dental_related,
    _classify_with_groq,
)


def test_json_extraction():
    """Test JSON extraction from various GROQ response formats."""
    test_cases = [
        # Case 1: Clean JSON
        (
            '{"type": "FACT", "confidence": 95, "explanation": "This is correct"}',
            "Clean JSON",
            True
        ),
        # Case 2: JSON with markdown wrapper
        (
            '```json\n{"type": "MYTH", "confidence": 80, "explanation": "This is false"}\n```',
            "JSON with markdown wrapper",
            True
        ),
        # Case 3: JSON with extra text
        (
            'The classification is:\n{"type": "NOT_DENTAL", "confidence": 0, "explanation": "Not about teeth"}',
            "JSON with surrounding text",
            True
        ),
        # Case 4: Tamil explanation
        (
            '{"type": "FACT", "confidence": 90, "explanation": "பல் துலக்குவது நல்லது"}',
            "JSON with Tamil explanation",
            True
        ),
        # Case 5: Malformed JSON
        (
            '{"type": "FACT" "confidence": 95}',  # Missing comma
            "Malformed JSON",
            False
        ),
    ]
    
    print("\n" + "=" * 80)
    print("JSON EXTRACTION TESTS")
    print("=" * 80)
    
    for test_input, description, should_pass in test_cases:
        print(f"\n▶ Test: {description}")
        print(f"Input: {test_input[:100]}..." if len(test_input) > 100 else f"Input: {test_input}")
        
        result = _extract_json_object(test_input)
        
        if should_pass:
            if result:
                print(f"✅ PASS - Extracted: {result}")
            else:
                print(f"❌ FAIL - Expected to extract JSON but got None")
        else:
            if result is None:
                print(f"✅ PASS - Correctly returned None for malformed JSON")
            else:
                print(f"❌ FAIL - Expected None but got: {result}")


def test_language_detection():
    """Test language detection."""
    test_cases = [
        ("பல் மிகவும் குண்டாகிவிட்டால் தேய்த்தால் சரியாகும்", "tamil"),
        ("Brushing twice daily is important", "english"),
        ("Flossing ஈறுகளை பாதுகாக்க உதவும்", "mixed"),
    ]
    
    print("\n" + "=" * 80)
    print("LANGUAGE DETECTION TESTS")
    print("=" * 80)
    
    for text, expected_lang in test_cases:
        detected = _detect_language(text)
        status = "✅" if detected == expected_lang else "❌"
        print(f"{status} Expected: {expected_lang:10} | Got: {detected:10} | Text: {text[:50]}")


def test_normalization():
    """Test normalization functions."""
    print("\n" + "=" * 80)
    print("NORMALIZATION TESTS")
    print("=" * 80)
    
    # Type normalization
    print("\n▶ Type Normalization:")
    type_tests = [
        ("FACT", "FACT"),
        ("fact", "FACT"),
        ("Fact", "FACT"),
        ("myth", "MYTH"),
        ("NOT_DENTAL", "NOT_DENTAL"),
        ("not-dental", "NOT_DENTAL"),
        ("invalid", "NOT_DENTAL"),
    ]
    
    for input_val, expected in type_tests:
        result = _normalize_type(input_val)
        status = "✅" if result == expected else "❌"
        print(f"  {status} Input: {input_val:15} | Expected: {expected:15} | Got: {result}")
    
    # Confidence normalization
    print("\n▶ Confidence Normalization:")
    conf_tests = [
        (95, 95),
        (0.95, 95),
        (1.0, 100),
        (0.5, 50),
        ("85", 85),
        (None, 0),
    ]
    
    for input_val, expected in conf_tests:
        result = _normalize_confidence(input_val)
        status = "✅" if result == expected else "❌"
        print(f"  {status} Input: {str(input_val):15} | Expected: {expected:3} | Got: {result}")


def test_dental_detection():
    """Test dental-related detection."""
    test_cases = [
        ("பல் மிகவும் குண்டாகிவிட்டால் தேய்த்தால் சரியாகும்", True),
        ("விமானம் தண்ணீரில் ஓடும்", False),
        ("Brushing teeth is important", True),
        ("The sky is blue", False),
        ("Flossing ஈறுகளை பாதுகாக்க உதவும்", True),
    ]
    
    print("\n" + "=" * 80)
    print("DENTAL DETECTION TESTS")
    print("=" * 80)
    
    for text, expected in test_cases:
        result = _is_dental_related(text)
        status = "✅" if result == expected else "❌"
        expected_str = "Dental" if expected else "Not Dental"
        result_str = "Dental" if result else "Not Dental"
        print(f"{status} Expected: {expected_str:12} | Got: {result_str:12} | Text: {text[:45]}")


async def test_groq_integration():
    """Test actual GROQ API integration."""
    test_statements = [
        "Brushing twice daily is important",  # English
        "பல் துலக்குவது நல்லது",  # Tamil (Brushing is good)
        "Flossing ஈறுகளை பாதுகாக்க உதவும்",  # Mixed (Flossing helps protect gums)
    ]
    
    print("\n" + "=" * 80)
    print("GROQ API INTEGRATION TEST")
    print("=" * 80)
    
    for statement in test_statements:
        print(f"\n▶ Testing: {statement[:60]}")
        print(f"  Language: {_detect_language(statement)}")
        print(f"  Is Dental: {_is_dental_related(statement)}")
        print("  Calling GROQ API...")
        
        try:
            result = await _classify_with_groq(statement)
            print(f"  ✅ Result: type={result.get('type')}, confidence={result.get('confidence')}")
            print(f"     Explanation: {result.get('explanation', '')[:80]}")
        except Exception as e:
            print(f"  ❌ Error: {e}")


def main():
    """Run all tests."""
    print("\n")
    print("█" * 80)
    print("GROQ BACKEND DEBUGGING SUITE")
    print("█" * 80)
    
    # Run synchronous tests
    test_json_extraction()
    test_language_detection()
    test_normalization()
    test_dental_detection()
    
    # Run async tests
    print("\n" + "=" * 80)
    print("ASYNC TESTS - GROQ INTEGRATION")
    print("=" * 80)
    print("Starting GROQ integration tests (these require network access)...")
    print("Note: If GROQ_API_KEY is not set, these will fail gracefully.\n")
    
    try:
        asyncio.run(test_groq_integration())
    except Exception as e:
        print(f"\n❌ GROQ integration test failed: {e}")
        print("This is expected if GROQ_API_KEY is not configured.")
    
    print("\n" + "█" * 80)
    print("DEBUG TEST SUITE COMPLETE")
    print("█" * 80 + "\n")


if __name__ == "__main__":
    main()
