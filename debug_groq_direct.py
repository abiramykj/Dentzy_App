#!/usr/bin/env python3
"""Debug GROQ API errors with detailed request/response logging"""

import os
import json
import httpx
from dotenv import load_dotenv

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY", "").strip()
GROQ_MODEL = "llama-3.3-70b-versatile"
GROQ_BASE_URL = "https://api.groq.com/openai/v1"

SYSTEM_PROMPT = """You are an advanced multilingual dental myth classification assistant.

You fluently understand:
- English
- Tamil
- Tanglish (Tamil written in English letters)

Your task:
Classify the user's statement into ONLY one category:
- FACT
- MYTH
- NOT_DENTAL

Definitions:
FACT = scientifically correct dental/oral health information
MYTH = false or misleading dental/oral health information
NOT_DENTAL = unrelated to teeth, gums, mouth, or oral health

IMPORTANT:
- If the input is Tamil, respond fully in Tamil.
- If the input is English, respond in English.
- Keep explanations short and natural.
- Understand mixed Tamil + English sentences.

Return ONLY valid JSON.

Example:
{
  "type": "FACT",
  "confidence": 95,
  "explanation": "ஒரு நாளில் இரண்டு முறை பல் துலக்குவது பல் ஆரோக்கியத்திற்கு நல்லது."
}

No markdown.
No extra text."""

def test_groq_direct(text: str):
    """Test GROQ API directly with minimal configuration"""
    
    print(f"\n{'=' * 80}")
    print(f"Testing GROQ with text: {text}")
    print(f"Model: {GROQ_MODEL}")
    print(f"{'=' * 80}\n")
    
    # Try WITH JSON mode
    print("Attempt 1: WITH response_format (JSON mode)")
    print("-" * 40)
    
    payload_with_json_mode = {
        "model": GROQ_MODEL,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": text},
        ],
        "temperature": 0.1,
        "max_tokens": 120,
        "response_format": {"type": "json_object"},
    }
    
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json; charset=utf-8",
    }
    
    url = f"{GROQ_BASE_URL}/chat/completions"
    
    print(f"URL: {url}")
    print(f"Payload:\n{json.dumps(payload_with_json_mode, indent=2, ensure_ascii=False)[:500]}...")
    
    try:
        response = httpx.post(url, headers=headers, json=payload_with_json_mode, timeout=30)
        print(f"Status: {response.status_code}")
        print(f"Response:\n{response.text[:500]}")
        
        if response.status_code == 200:
            data = response.json()
            content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
            print(f"✅ Success! Content: {content}")
            return
        else:
            print(f"❌ Error: HTTP {response.status_code}")
            if "error" in response.text:
                error_data = response.json()
                print(f"Error message: {error_data.get('error', {}).get('message', response.text)}")
    
    except Exception as e:
        print(f"❌ Exception: {e}")
    
    # Try WITHOUT JSON mode (fallback)
    print("\n\nAttempt 2: WITHOUT response_format (regular mode)")
    print("-" * 40)
    
    payload_without_json_mode = {
        "model": GROQ_MODEL,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": text},
        ],
        "temperature": 0.1,
        "max_tokens": 120,
    }
    
    print(f"Payload:\n{json.dumps(payload_without_json_mode, indent=2, ensure_ascii=False)[:500]}...")
    
    try:
        response = httpx.post(url, headers=headers, json=payload_without_json_mode, timeout=30)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
            print(f"Response content:\n{content}")
            print(f"✅ Success!")
            return
        else:
            print(f"❌ Error: HTTP {response.status_code}")
            print(f"Response:\n{response.text[:500]}")
            if "error" in response.text:
                error_data = response.json()
                print(f"Error message: {error_data.get('error', {}).get('message', response.text)}")
    
    except Exception as e:
        print(f"❌ Exception: {e}")

def main():
    if not GROQ_API_KEY:
        print("❌ GROQ_API_KEY not configured")
        return
    
    test_cases = [
        "பல் துலக்குவது நல்லது",  # Tamil FACT
        "Brushing teeth is good",  # English FACT
    ]
    
    for text in test_cases:
        test_groq_direct(text)

if __name__ == "__main__":
    main()
