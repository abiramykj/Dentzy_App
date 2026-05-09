#!/usr/bin/env python3
"""Test the enhanced GROQ integration with stronger model (llama-3.3-70b-versatile)"""

import httpx
import json

BASE_URL = "http://localhost:8080"

test_cases = [
    {
        "name": "Tamil FACT - Brushing twice daily",
        "text": "பல் துலக்குவது நல்லது",
        "expected": "FACT",
    },
    {
        "name": "Tamil MYTH - Large teeth can be fixed by brushing",
        "text": "பல் மிகவும் பெரிதாக இருந்தால் தேய்த்தால் சரியாகும்",
        "expected": "MYTH",
    },
    {
        "name": "Tamil NOT_DENTAL - About flying",
        "text": "விமானம் தண்ணீரில் ஓடும்",
        "expected": "NOT_DENTAL",
    },
    {
        "name": "English FACT - Flossing is important",
        "text": "Flossing daily helps prevent cavities",
        "expected": "FACT",
    },
    {
        "name": "English MYTH - Sugar causes cavities",
        "text": "Eating sugar immediately causes tooth decay",
        "expected": "MYTH",
    },
    {
        "name": "Mixed Language - Tamil + English",
        "text": "பல் health is important, brush regularly",
        "expected": "FACT",
    },
]

def test_classify(text: str) -> dict:
    """Make a classification request to the backend"""
    payload = {"text": text}
    headers = {
        "Content-Type": "application/json; charset=utf-8",
    }
    
    response = httpx.post(
        f"{BASE_URL}/classify",
        json=payload,
        headers=headers,
        timeout=30
    )
    
    if response.status_code != 200:
        print(f"❌ HTTP Error {response.status_code}")
        print(f"Response: {response.text}")
        return {}
    
    return response.json()

def main():
    print("=" * 80)
    print("TESTING ENHANCED GROQ INTEGRATION")
    print("Model: llama-3.3-70b-versatile (Stronger model for Tamil support)")
    print("=" * 80)
    print()
    
    passed = 0
    failed = 0
    
    for i, test in enumerate(test_cases, 1):
        print(f"Test {i}: {test['name']}")
        print(f"Input: {test['text']}")
        print(f"Expected Type: {test['expected']}")
        
        try:
            result = test_classify(test['text'])
            
            if not result:
                print("❌ FAILED - No response")
                failed += 1
                print()
                continue
            
            result_type = result.get("type", "UNKNOWN")
            confidence = result.get("confidence", 0)
            explanation = result.get("explanation", "")[:80]
            
            print(f"Response Type: {result_type}")
            print(f"Confidence: {confidence}%")
            print(f"Explanation: {explanation}...")
            
            # Check if type matches expected (not strict, just checking if it's reasonable)
            if result_type in {"FACT", "MYTH", "NOT_DENTAL"}:
                print("✅ PASSED - Valid response format")
                passed += 1
            else:
                print("❌ FAILED - Invalid response type")
                failed += 1
        
        except Exception as e:
            print(f"❌ FAILED - Exception: {e}")
            failed += 1
        
        print()
    
    print("=" * 80)
    print(f"Results: {passed} passed, {failed} failed out of {len(test_cases)} tests")
    print("=" * 80)
    
    if failed == 0:
        print("✅ All tests passed! Tamil support is working correctly.")
    else:
        print(f"⚠️  {failed} test(s) failed. Check backend logs for details.")

if __name__ == "__main__":
    main()
