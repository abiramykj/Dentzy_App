#!/usr/bin/env python
"""
Test script to verify myth classifier fixes.
Tests statements that were previously misclassified.
"""

import asyncio
import sys
from pathlib import Path

# Add backend to path
backend_path = Path(__file__).parent / "backend"
sys.path.insert(0, str(backend_path))

from services.myth_classifier_service import classify_statement, _has_dental_keywords

# Test cases that should NOT be classified as NOT_DENTAL
TEST_CASES = [
    {
        "statement": "Sugar alone causes cavities.",
        "expected_type": "MYTH",
        "reason": "Clearly dental - uses 'cavities' keyword",
    },
    {
        "statement": "Milk teeth do not matter because they fall out.",
        "expected_type": "MYTH",
        "reason": "Clearly dental - uses 'milk teeth' and 'teeth'",
    },
    {
        "statement": "Bleeding gums are completely normal.",
        "expected_type": "MYTH",
        "reason": "Clearly dental - uses 'bleeding gums'",
    },
    {
        "statement": "Brushing twice daily is good for oral health.",
        "expected_type": "FACT",
        "reason": "Clearly dental - uses 'brushing' and 'oral health'",
    },
    {
        "statement": "Flossing removes plaque from teeth.",
        "expected_type": "FACT",
        "reason": "Clearly dental - uses 'flossing' and 'plaque'",
    },
    {
        "statement": "You should see a dentist only if you have pain.",
        "expected_type": "MYTH",
        "reason": "Clearly dental - uses 'dentist'",
    },
    {
        "statement": "Cavities can be prevented with proper brushing.",
        "expected_type": "FACT",
        "reason": "Clearly dental - uses 'cavities'",
    },
    {
        "statement": "The sky is blue.",
        "expected_type": "NOT_DENTAL",
        "reason": "NOT dental - no dental keywords",
    },
]


def test_keyword_detection():
    """Test that dental keywords are properly detected."""
    print("\n" + "=" * 70)
    print("KEYWORD DETECTION TEST")
    print("=" * 70)
    
    for test in TEST_CASES:
        statement = test["statement"]
        has_keywords, keyword = _has_dental_keywords(statement)
        
        status = "✓ PASS" if (has_keywords and test["expected_type"] != "NOT_DENTAL") or (not has_keywords and test["expected_type"] == "NOT_DENTAL") else "✗ FAIL"
        print(f"\n{status}")
        print(f"Statement: '{statement}'")
        print(f"Has dental keywords: {has_keywords}")
        if keyword:
            print(f"Matched keyword: '{keyword}'")
        print(f"Expected type: {test['expected_type']}")
        print(f"Reason: {test['reason']}")


async def test_classification():
    """Test the full classification pipeline."""
    print("\n" + "=" * 70)
    print("FULL CLASSIFICATION TEST")
    print("=" * 70)
    
    passed = 0
    failed = 0
    
    for test in TEST_CASES:
        statement = test["statement"]
        expected = test["expected_type"]
        reason = test["reason"]
        
        try:
            result = await classify_statement(statement)
            actual = result.get("type", "ERROR")
            confidence = result.get("confidence", 0)
            explanation = result.get("explanation", "")[:60]
            
            # For now, just check that NOT_DENTAL is not wrongly assigned to dental statements
            is_correct = (expected != "NOT_DENTAL" and actual != "NOT_DENTAL") or (expected == "NOT_DENTAL" and actual == "NOT_DENTAL")
            
            status = "✓ PASS" if is_correct else "✗ FAIL"
            
            if is_correct:
                passed += 1
            else:
                failed += 1
            
            print(f"\n{status}")
            print(f"Statement: '{statement}'")
            print(f"Expected: {expected}, Got: {actual}")
            print(f"Confidence: {confidence}%")
            print(f"Explanation: {explanation}...")
            print(f"Reason: {reason}")
            
        except Exception as e:
            print(f"\n✗ EXCEPTION")
            print(f"Statement: '{statement}'")
            print(f"Error: {e}")
            failed += 1
    
    print("\n" + "=" * 70)
    print(f"RESULTS: {passed} passed, {failed} failed out of {len(TEST_CASES)} tests")
    print("=" * 70)
    
    return failed == 0


async def main():
    """Run all tests."""
    print("\n" + "=" * 70)
    print("MYTH CLASSIFIER FIX VERIFICATION")
    print("=" * 70)
    
    # Test keyword detection
    test_keyword_detection()
    
    # Test full classification
    success = await test_classification()
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    asyncio.run(main())
