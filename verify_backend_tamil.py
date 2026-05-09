#!/usr/bin/env python3
"""
Verify Tamil support in the running backend
"""

import httpx
import json

print("=" * 80)
print("BACKEND TAMIL CLASSIFICATION TEST")
print("=" * 80)
print()

test_cases = [
    ("Tamil FACT", "பல் துலக்குவது நல்லது"),
    ("Tamil MYTH", "பல் மிகவும் பெரிதாக இருந்தால் தேய்த்தால் சரியாகும்"),
    ("Tamil NOT_DENTAL", "விமானம் தண்ணீரில் ஓடும்"),
    ("English FACT", "Brushing teeth twice daily is good for dental health"),
    ("English MYTH", "All extracted teeth must be replaced with implants"),
    ("Mixed Language", "பல் health is very important for overall wellness"),
]

passed = 0
failed = 0

for name, text in test_cases:
    print(f"Test: {name}")
    print(f"Input: {text}")
    
    try:
        response = httpx.post(
            "http://localhost:8080/classify",
            json={"text": text},
            timeout=30,
            headers={"Content-Type": "application/json; charset=utf-8"}
        )
        
        if response.status_code != 200:
            print(f"❌ HTTP {response.status_code}")
            print(f"Error: {response.text[:200]}")
            failed += 1
        else:
            data = response.json()
            result_type = data.get("type", "UNKNOWN")
            confidence = data.get("confidence", 0)
            explanation = data.get("explanation", "")[:100]
            
            # Validate response
            valid_types = {"FACT", "MYTH", "NOT_DENTAL"}
            if result_type in valid_types and isinstance(confidence, int) and 0 <= confidence <= 100:
                print(f"✅ PASS")
                print(f"   Type: {result_type}")
                print(f"   Confidence: {confidence}%")
                print(f"   Explanation: {explanation}...")
                passed += 1
            else:
                print(f"❌ FAIL - Invalid response format")
                print(f"   Type: {result_type} (valid: {valid_types})")
                print(f"   Confidence: {confidence} (expected 0-100)")
                failed += 1
    
    except httpx.ConnectError:
        print(f"❌ FAIL - Cannot connect to backend (is it running?)")
        failed += 1
    except Exception as e:
        print(f"❌ FAIL - Exception: {str(e)[:100]}")
        failed += 1
    
    print()

print("=" * 80)
print(f"RESULTS: {passed} passed, {failed} failed out of {len(test_cases)} tests")
print("=" * 80)

if failed == 0:
    print("✅ Tamil support is working correctly!")
else:
    print(f"⚠️ {failed} test(s) failed - check backend logs")
