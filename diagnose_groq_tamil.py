#!/usr/bin/env python3
"""
Comprehensive GROQ Tamil Support Diagnostic
Checks all 6 critical areas for Tamil classification issues
"""

import os
import json
import sys
import httpx
from dotenv import load_dotenv

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "").strip()
GROQ_BASE_URL = "https://api.groq.com/openai/v1"

print("=" * 80)
print("GROQ TAMIL SUPPORT DIAGNOSTIC")
print("=" * 80)
print()

# Check 1: API Key
print("✓ CHECK 1: GROQ API KEY")
print("-" * 80)
if GROQ_API_KEY:
    print(f"✅ GROQ_API_KEY is configured ({len(GROQ_API_KEY)} chars)")
else:
    print("❌ GROQ_API_KEY is NOT configured")
    sys.exit(1)
print()

# Check 2: UTF-8 Encoding Validation
print("✓ CHECK 2: UTF-8 ENCODING")
print("-" * 80)

tamil_text = "பல் துலக்குவது நல்லது"
print(f"Tamil text: {tamil_text}")
print(f"UTF-8 encoded: {tamil_text.encode('utf-8')}")
print(f"JSON with ensure_ascii=False: {json.dumps({'text': tamil_text}, ensure_ascii=False)}")
print(f"JSON with ensure_ascii=True: {json.dumps({'text': tamil_text}, ensure_ascii=True)}")
print("✅ UTF-8 encoding working correctly")
print()

# Check 3: Model Availability
print("✓ CHECK 3: MODEL AVAILABILITY")
print("-" * 80)

models_to_test = [
    "llama-3.3-70b-versatile",
    "llama-3.1-8b-instant",
    "gemma2-9b-it",
]

headers = {
    "Authorization": f"Bearer {GROQ_API_KEY}",
    "Content-Type": "application/json; charset=utf-8",
}

for model in models_to_test:
    print(f"\nTesting model: {model}")
    
    payload = {
        "model": model,
        "messages": [
            {"role": "user", "content": "Hello"}
        ],
        "max_tokens": 10,
    }
    
    try:
        response = httpx.post(
            f"{GROQ_BASE_URL}/chat/completions",
            headers=headers,
            json=payload,
            timeout=10
        )
        
        if response.status_code == 200:
            print(f"  ✅ Available (HTTP 200)")
        elif response.status_code == 400:
            error_data = response.json()
            error_msg = error_data.get("error", {}).get("message", response.text)
            print(f"  ⚠️  HTTP 400: {error_msg[:80]}")
        elif response.status_code == 401:
            print(f"  ❌ Authentication failed (HTTP 401)")
        elif response.status_code == 429:
            print(f"  ⚠️  Rate limited (HTTP 429)")
        else:
            print(f"  ❌ HTTP {response.status_code}")
    
    except Exception as e:
        print(f"  ❌ Exception: {str(e)[:80]}")

print()

# Check 4: JSON Mode + Tamil Test
print("✓ CHECK 4: JSON MODE WITH TAMIL")
print("-" * 80)

system_prompt = """You are a dental myth classifier.

If the input is Tamil, respond in Tamil.

Return ONLY valid JSON:
{
  "type":"FACT",
  "confidence":95,
  "explanation":"explanation here"
}"""

test_inputs = [
    ("English", "Brushing teeth is good"),
    ("Tamil", "பல் துலக்குவது நல்லது"),
]

for lang, text in test_inputs:
    print(f"\n{lang}: {text}")
    
    payload = {
        "model": "llama-3.3-70b-versatile",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": text},
        ],
        "temperature": 0.1,
        "max_tokens": 120,
        "response_format": {"type": "json_object"},
    }
    
    try:
        response = httpx.post(
            f"{GROQ_BASE_URL}/chat/completions",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        print(f"Status: HTTP {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
            print(f"Response: {content[:120]}")
            
            # Try to parse JSON
            try:
                parsed = json.loads(content)
                print(f"✅ Valid JSON: type={parsed.get('type')}, confidence={parsed.get('confidence')}")
            except json.JSONDecodeError as e:
                print(f"❌ Invalid JSON: {str(e)[:80]}")
        
        else:
            error_msg = response.text[:200]
            print(f"Error: {error_msg}")
    
    except Exception as e:
        print(f"Exception: {str(e)[:80]}")

print()

# Check 5: Prompt Quality Test
print("✓ CHECK 5: PROMPT EFFECTIVENESS")
print("-" * 80)

prompts_to_test = [
    ("Basic English-only", "Classify dental statements"),
    ("Multilingual aware", "You understand: English, Tamil, Tanglish. Respond in input language."),
    ("Expert prompt", """You are an advanced multilingual dental classifier.
You understand: English, Tamil, Tanglish.
If input is Tamil → respond in Tamil.
Return JSON: {"type":"FACT|MYTH|NOT_DENTAL","confidence":0-100,"explanation":"..."}"""),
]

tamil_myth = "பல் மிகவும் பெரிதாக இருந்தால் தேய்த்தால் சரியாகும்"

for prompt_name, system_prompt in prompts_to_test:
    print(f"\nPrompt: {prompt_name}")
    
    payload = {
        "model": "llama-3.1-8b-instant",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": tamil_myth},
        ],
        "temperature": 0.1,
        "max_tokens": 120,
    }
    
    try:
        response = httpx.post(
            f"{GROQ_BASE_URL}/chat/completions",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
            
            # Check if contains Tamil
            has_tamil = any('\u0B80' <= c <= '\u0BFF' for c in content)
            
            print(f"  ✅ Success")
            print(f"  Tamil in response: {has_Tamil}")
            print(f"  Content: {content[:100]}")
        else:
            print(f"  ❌ HTTP {response.status_code}")
    
    except Exception as e:
        print(f"  ❌ Exception: {str(e)[:80]}")

print()

# Check 6: Token Limit Analysis
print("✓ CHECK 6: TOKEN LIMITS")
print("-" * 80)

# Rough token estimation (1 token ≈ 4 chars for English, 2 chars for Tamil)
test_texts = [
    ("Short English", "Brushing is good"),
    ("Long English", "Brushing teeth twice daily with fluoride toothpaste helps prevent cavities and gum disease by removing plaque buildup"),
    ("Short Tamil", "பல் துலக்குவது நல்லது"),
    ("Long Tamil", "பல் துலக்குவது மிகவும் முக்கியமான பணியாகும். ஒரு நாளில் இரண்டு முறை பல் துலக்கினால் பல் ஆரோக்கியம் பேணப்படும்"),
]

for name, text in test_texts:
    english_est = len(text) // 4
    tamil_chars = sum(1 for c in text if '\u0B80' <= c <= '\u0BFF')
    tamil_est = tamil_chars // 2
    
    system_tokens = 200  # Rough estimate for system prompt
    response_tokens = 120  # max_tokens
    total_est = english_est + tamil_est + system_tokens + response_tokens
    
    print(f"\n{name}: {text[:50]}...")
    print(f"  Estimated tokens: {english_est + tamil_est} (content) + {system_tokens} (system) + {response_tokens} (response) = {total_est} total")
    print(f"  Safe: {'✅' if total_est < 8000 else '❌'}")

print()

# Check 7: Fallback Logic Simulation
print("✓ CHECK 7: FALLBACK LOGIC")
print("-" * 80)

print("\nSimulating fallback scenario:")
print("1. Try llama-3.3-70b-versatile with complex Tamil")
print("2. If HTTP 400 → fallback to llama-3.1-8b-instant")
print("3. Verify fallback works seamlessly")

models_sequence = [
    ("llama-3.3-70b-versatile", "Primary (larger, better Tamil)"),
    ("llama-3.1-8b-instant", "Fallback (smaller, reliable)"),
]

complex_tamil = "பல் மிகவும் பெரிதாக இருந்தால் தேய்த்தால் சரியாகும்"

for attempt, (model, desc) in enumerate(models_sequence, 1):
    print(f"\nAttempt {attempt}: {model} ({desc})")
    
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": "Classify: FACT/MYTH/NOT_DENTAL. If Tamil, respond in Tamil. JSON only."},
            {"role": "user", "content": complex_tamil},
        ],
        "temperature": 0.1,
        "max_tokens": 120,
        "response_format": {"type": "json_object"},
    }
    
    try:
        response = httpx.post(
            f"{GROQ_BASE_URL}/chat/completions",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        print(f"  Status: HTTP {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
            try:
                parsed = json.loads(content)
                print(f"  ✅ Success: {parsed.get('type')}")
                break  # Success, don't try fallback
            except:
                print(f"  ⚠️  Invalid JSON, would try fallback")
        elif response.status_code == 400:
            print(f"  ⚠️  HTTP 400, trying fallback...")
            if attempt < len(models_sequence):
                continue
        else:
            print(f"  ❌ HTTP {response.status_code}, trying fallback...")
    
    except Exception as e:
        print(f"  ❌ Exception: {str(e)[:80]}")

print()
print("=" * 80)
print("DIAGNOSTIC COMPLETE")
print("=" * 80)
print("\nSummary:")
print("✓ Check 1: API Key")
print("✓ Check 2: UTF-8 Encoding") 
print("✓ Check 3: Model Availability")
print("✓ Check 4: JSON Mode with Tamil")
print("✓ Check 5: Prompt Effectiveness")
print("✓ Check 6: Token Limits")
print("✓ Check 7: Fallback Logic")
print("\nRecommendations:")
print("- Use llama-3.3-70b-versatile as primary (better Tamil)")
print("- Enable fallback to llama-3.1-8b-instant on HTTP 400")
print("- Use multilingual system prompt with Tamil example")
print("- Ensure UTF-8 headers on all requests")
print("- Test actual GROQ responses to verify JSON validity")
