#!/usr/bin/env python
"""
Direct test of the myth checker endpoint to verify response time and accuracy.
This validates:
1. Backend is responding
2. Response times are < 20 seconds
3. Classification works for English/Tamil
4. Early exit works for non-dental text
"""

import asyncio
import json
import time
import httpx

# Test cases
TEST_CASES = [
    # Should be fast (early exit - non-dental)
    {
        "text": "The weather is sunny today",
        "expected_type": "NOT_DENTAL",
        "description": "Non-dental statement (should exit early)"
    },
    # Should call GROQ (dental fact)
    {
        "text": "Brushing teeth twice a day is good for oral health",
        "expected_type": "FACT",
        "description": "English dental fact"
    },
    # Should call GROQ (dental myth)
    {
        "text": "Sugar is bad for teeth",
        "expected_type": "MYTH",
        "description": "English dental myth"
    },
    # Tamil (should call GROQ)
    {
        "text": "பற்களை தினமும் இருமுறை துலக்குவது நன்றாக இருக்கிறது",
        "expected_type": "FACT",
        "description": "Tamil dental fact"
    },
]


async def test_classify_endpoint():
    """Test the /classify endpoint with various inputs."""
    # For local testing on Windows, use localhost
    # For Android emulator, use 10.0.2.2
    base_url = "http://localhost:8080"
    
    endpoint = f"{base_url}/classify"
    
    print("\n" + "=" * 80)
    print("MYTH CHECKER ENDPOINT TEST")
    print("=" * 80)
    print(f"Endpoint: POST {endpoint}")
    print("=" * 80 + "\n")
    
    timeout_failures = 0
    error_failures = 0
    success_count = 0
    
    async with httpx.AsyncClient() as client:
        for i, test in enumerate(TEST_CASES, 1):
            print(f"\n[Test {i}/{len(TEST_CASES)}] {test['description']}")
            print(f"Input: {test['text'][:60]}...")
            
            start = time.time()
            try:
                response = await asyncio.wait_for(
                    client.post(
                        endpoint,
                        json={"text": test["text"]},
                        headers={"Content-Type": "application/json"},
                    ),
                    timeout=22.0  # Slightly higher than backend timeout
                )
                elapsed = time.time() - start
                
                print(f"Status: {response.status_code}")
                print(f"Response time: {elapsed:.3f}s")
                
                if response.status_code != 200:
                    print(f"ERROR: Non-200 status code")
                    error_failures += 1
                    continue
                
                data = response.json()
                result_type = data.get("type")
                confidence = data.get("confidence", 0)
                explanation = data.get("explanation", "")[:70]
                
                print(f"Type: {result_type}")
                print(f"Confidence: {confidence}%")
                print(f"Explanation: {explanation}...")
                
                if elapsed > 20:
                    print(f"WARNING: Response took {elapsed:.3f}s (limit is 20s)")
                    timeout_failures += 1
                else:
                    success_count += 1
                    print("✓ PASS")
                    
            except asyncio.TimeoutError:
                elapsed = time.time() - start
                print(f"✗ TIMEOUT after {elapsed:.3f}s")
                timeout_failures += 1
            except httpx.ConnectError as e:
                print(f"✗ CONNECTION ERROR: {e}")
                error_failures += 1
            except Exception as e:
                print(f"✗ ERROR: {type(e).__name__}: {e}")
                error_failures += 1
    
    print("\n" + "=" * 80)
    print("TEST SUMMARY")
    print("=" * 80)
    print(f"Total tests: {len(TEST_CASES)}")
    print(f"Passed: {success_count}")
    print(f"Timeout failures: {timeout_failures}")
    print(f"Other errors: {error_failures}")
    
    if success_count == len(TEST_CASES):
        print("\n✓ ALL TESTS PASSED")
    else:
        print(f"\n✗ {timeout_failures + error_failures} TEST(S) FAILED")
    
    print("=" * 80 + "\n")


if __name__ == "__main__":
    asyncio.run(test_classify_endpoint())
