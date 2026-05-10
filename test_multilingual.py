#!/usr/bin/env python3
"""
Comprehensive multilingual myth checker test suite.
Tests: English, Tamil, Tanglish, and NOT_DENTAL edge cases.
"""

import asyncio
import json
import time
from typing import Any

import httpx


API_URL = "http://localhost:8080/classify"
TIMEOUT = 30.0


test_cases = [
    {
        "name": "English FACT - Brushing twice daily",
        "text": "Brushing twice daily is healthy",
        "expected_type": "FACT",
        "language": "english",
    },
    {
        "name": "English MYTH - Hard brushing cleans teeth better",
        "text": "Hard brushing cleans teeth better",
        "expected_type": "MYTH",
        "language": "english",
    },
    {
        "name": "English NOT_DENTAL - Cars fly underwater",
        "text": "Cars can fly underwater",
        "expected_type": "NOT_DENTAL",
        "language": "english",
    },
    {
        "name": "Tamil FACT - Daily brushing twice",
        "text": "தினமும் இரண்டு முறை பல் துலக்க வேண்டும்.",
        "expected_type": "FACT",
        "language": "tamil",
    },
    {
        "name": "Tamil MYTH - Sugar doesn't affect teeth",
        "text": "சர்க்கரை பற்களுக்கு பாதிப்பு இல்லை.",
        "expected_type": "MYTH",
        "language": "tamil",
    },
    {
        "name": "Tamil NOT_DENTAL - Mountains are chocolate",
        "text": "மலைகள் சாக்லேட்டால் ஆனவை",
        "expected_type": "NOT_DENTAL",
        "language": "tamil",
    },
    {
        "name": "Tanglish FACT - Flossing is good",
        "text": "Floss பயன்படுத்துவது பற்களுக்கு நல்லது",
        "expected_type": "FACT",
        "language": "mixed",
    },
    {
        "name": "English - Whitening teeth",
        "text": "Teeth whitening is safe",
        "expected_type": "FACT",
        "language": "english",
    },
    {
        "name": "Tamil - Tooth pain treatment",
        "text": "பல் வலி உள்ளவர்கள் மருத்துவரை பார்க்க வேண்டும்",
        "expected_type": "FACT",
        "language": "tamil",
    },
]


async def test_classification(text: str, expected_type: str, test_name: str) -> dict[str, Any]:
    """Test a single classification."""
    start_time = time.time()
    
    try:
        async with httpx.AsyncClient(timeout=TIMEOUT) as client:
            response = await client.post(
                API_URL,
                json={"text": text},
            )
        
        elapsed = time.time() - start_time
        
        if response.status_code != 200:
            return {
                "test_name": test_name,
                "status": "FAILED",
                "error": f"HTTP {response.status_code}",
                "elapsed_ms": round(elapsed * 1000, 2),
            }
        
        data = response.json()
        classification_type = data.get("type", "UNKNOWN")
        confidence = data.get("confidence", 0)
        explanation = data.get("explanation", "")
        
        # Check if result matches expected type
        passed = classification_type == expected_type
        
        return {
            "test_name": test_name,
            "status": "PASSED" if passed else "FAILED",
            "input_text": text[:50] + "..." if len(text) > 50 else text,
            "expected": expected_type,
            "got": classification_type,
            "confidence": confidence,
            "explanation": explanation[:80] + "..." if len(explanation) > 80 else explanation,
            "elapsed_ms": round(elapsed * 1000, 2),
        }
    
    except asyncio.TimeoutError:
        elapsed = time.time() - start_time
        return {
            "test_name": test_name,
            "status": "TIMEOUT",
            "elapsed_ms": round(elapsed * 1000, 2),
        }
    except Exception as e:
        elapsed = time.time() - start_time
        return {
            "test_name": test_name,
            "status": "ERROR",
            "error": str(e),
            "elapsed_ms": round(elapsed * 1000, 2),
        }


async def main():
    """Run all test cases."""
    print("\n" + "=" * 100)
    print("DENTZY MULTILINGUAL MYTH CHECKER TEST SUITE")
    print("=" * 100)
    print(f"Testing {len(test_cases)} cases across: English, Tamil, Tanglish\n")
    
    # Run all tests
    results = []
    for test_case in test_cases:
        result = await test_classification(
            text=test_case["text"],
            expected_type=test_case["expected_type"],
            test_name=test_case["name"],
        )
        results.append(result)
    
    # Print results
    passed_count = 0
    failed_count = 0
    error_count = 0
    timeout_count = 0
    
    print(f"\n{'TEST NAME':<50} {'STATUS':<10} {'EXPECTED':<12} {'GOT':<12} {'CONFIDENCE':<12} {'TIME':<10}")
    print("-" * 120)
    
    for result in results:
        status = result["status"]
        if status == "PASSED":
            passed_count += 1
            mark = "✅"
        elif status == "FAILED":
            failed_count += 1
            mark = "❌"
        elif status == "TIMEOUT":
            timeout_count += 1
            mark = "⏱️ "
        else:
            error_count += 1
            mark = "⚠️ "
        
        expected = result.get("expected", "N/A")
        got = result.get("got", "N/A")
        confidence = f"{result.get('confidence', 0)}%" if "confidence" in result else "N/A"
        elapsed = f"{result['elapsed_ms']}ms"
        
        test_name = result["test_name"][:48]
        
        print(f"{mark} {test_name:<48} {status:<10} {expected:<12} {got:<12} {confidence:<12} {elapsed:<10}")
    
    # Summary
    total = len(results)
    print("-" * 120)
    print(f"\nSUMMARY:")
    print(f"  ✅ Passed:  {passed_count}/{total}")
    print(f"  ❌ Failed:  {failed_count}/{total}")
    print(f"  ⏱️  Timeout: {timeout_count}/{total}")
    print(f"  ⚠️  Errors:  {error_count}/{total}")
    print(f"\nSuccess Rate: {(passed_count / total * 100):.1f}%")
    print("=" * 100 + "\n")
    
    # Detailed failures
    if failed_count > 0:
        print("\nDETAILED FAILURES:")
        for result in results:
            if result["status"] == "FAILED":
                print(f"\n  ❌ {result['test_name']}")
                print(f"     Input: {result.get('input_text', 'N/A')}")
                print(f"     Expected: {result['expected']}")
                print(f"     Got: {result['got']} (confidence: {result.get('confidence', 'N/A')}%)")
                print(f"     Explanation: {result.get('explanation', 'N/A')}")
    
    return passed_count, total


if __name__ == "__main__":
    passed, total = asyncio.run(main())
    exit(0 if passed == total else 1)
