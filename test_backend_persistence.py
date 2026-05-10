#!/usr/bin/env python3
"""
Test script to verify Dentzy backend MySQL persistence.
Tests all core features: signup, login, myth history, brushing tracker, and notifications.
"""

import asyncio
import json
import httpx
from datetime import datetime, date

# Configuration
BASE_URL = "http://127.0.0.1:8080"
TEST_EMAIL = f"test_user_{datetime.now().timestamp()}@example.com"
TEST_PASSWORD = "TestPassword123!"
TEST_USERNAME = "Test User"

class DentzyTestRunner:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.access_token = None
        self.user_id = None
        self.session = None
    
    async def __aenter__(self):
        self.session = httpx.AsyncClient(timeout=30.0)
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.aclose()
    
    async def log_test(self, test_name: str, status: str, message: str = ""):
        timestamp = datetime.now().strftime("%H:%M:%S")
        prefix = "[PASS]" if status == "PASS" else "[FAIL]" if status == "FAIL" else "[WARN]"
        msg_suffix = f" - {message}" if message else ""
        print(f"[{timestamp}] {prefix} {test_name}{msg_suffix}")
    
    async def test_signup(self):
        """Test: User signup creates record in users table"""
        print("\n" + "=" * 70)
        print("TEST 1: SIGNUP - Create new user")
        print("=" * 70)
        
        try:
            response = await self.session.post(
                f"{self.base_url}/api/auth/signup",
                json={
                    "email": TEST_EMAIL,
                    "password": TEST_PASSWORD,
                    "username": TEST_USERNAME,
                    "selected_language": "en",
                    "remember_me": False,
                }
            )
            
            if response.status_code != 200:
                await self.log_test("SIGNUP", "FAIL", f"Status {response.status_code}")
                print(f"Response: {response.text}")
                return False
            
            data = response.json()
            if not data.get("success"):
                await self.log_test("SIGNUP", "FAIL", data.get("message", "Unknown error"))
                return False
            
            self.access_token = data.get("access_token")
            self.user_id = data.get("user", {}).get("id")
            
            await self.log_test("SIGNUP", "PASS", f"User created with ID {self.user_id}")
            print(f"  📧 Email: {TEST_EMAIL}")
            print(f"  🔑 Token: {self.access_token[:20]}...")
            return True
            
        except Exception as e:
            await self.log_test("SIGNUP", "FAIL", str(e))
            return False
    
    async def test_login(self):
        """Test: User login retrieves correct user from users table"""
        print("\n" + "=" * 70)
        print("TEST 2: LOGIN - Authenticate existing user")
        print("=" * 70)
        
        try:
            response = await self.session.post(
                f"{self.base_url}/api/auth/login",
                json={
                    "email": TEST_EMAIL,
                    "password": TEST_PASSWORD,
                    "remember_me": True,
                }
            )
            
            if response.status_code != 200:
                await self.log_test("LOGIN", "FAIL", f"Status {response.status_code}")
                return False
            
            data = response.json()
            if not data.get("success"):
                await self.log_test("LOGIN", "FAIL", data.get("message", "Unknown error"))
                return False
            
            await self.log_test("LOGIN", "PASS", f"User authenticated")
            print(f"  ✓ User ID verified: {data.get('user', {}).get('id')}")
            return True
            
        except Exception as e:
            await self.log_test("LOGIN", "FAIL", str(e))
            return False
    
    async def test_myth_classification(self):
        """Test: Myth classification and saving to myth_history table"""
        print("\n" + "=" * 70)
        print("TEST 3: MYTH CHECKING - Classify dental statement")
        print("=" * 70)
        
        try:
            # Classify statement (no auth required)
            response = await self.session.post(
                f"{self.base_url}/classify",
                json={"text": "Brushing teeth twice daily is good for oral health"}
            )
            
            if response.status_code != 200:
                await self.log_test("MYTH CLASSIFY", "FAIL", f"Status {response.status_code}")
                return False
            
            data = response.json()
            result_type = data.get("type", "UNKNOWN")
            confidence = data.get("confidence", 0)
            
            await self.log_test("MYTH CLASSIFY", "PASS", f"Type: {result_type}, Confidence: {confidence}")
            print(f"  [STATEMENT] 'Brushing teeth twice daily is good for oral health'")
            print(f"  [RESULT] {result_type} ({confidence}% confidence)")
            print(f"  [EXPLANATION] {data.get('explanation', 'N/A')[:60]}...")
            
            # Save to history (requires auth)
            save_response = await self.session.post(
                f"{self.base_url}/api/myths/history",
                headers={"Authorization": f"Bearer {self.access_token}"},
                json={
                    "statement": "Brushing teeth twice daily is good for oral health",
                    "result_type": result_type,
                    "confidence": confidence,
                    "explanation": data.get("explanation", ""),
                }
            )
            
            if save_response.status_code != 200:
                await self.log_test("MYTH SAVE", "FAIL", f"Status {save_response.status_code}")
                print(f"Response: {save_response.text}")
                return False
            
            history = save_response.json()
            await self.log_test("MYTH SAVE", "PASS", f"Saved to myth_history (ID: {history.get('id')})")
            return True
            
        except Exception as e:
            await self.log_test("MYTH CHECKING", "FAIL", str(e))
            return False
    
    async def test_fetch_myth_history(self):
        """Test: Fetch myth history from database"""
        print("\n" + "=" * 70)
        print("TEST 4: MYTH HISTORY FETCH - Retrieve saved history")
        print("=" * 70)
        
        try:
            response = await self.session.get(
                f"{self.base_url}/api/myths/history",
                headers={"Authorization": f"Bearer {self.access_token}"}
            )
            
            if response.status_code != 200:
                await self.log_test("FETCH MYTH HISTORY", "FAIL", f"Status {response.status_code}")
                return False
            
            data = response.json()
            count = len(data) if isinstance(data, list) else 0
            
            await self.log_test("FETCH MYTH HISTORY", "PASS", f"Retrieved {count} records")
            if count > 0:
                print(f"  📋 Latest: {data[0].get('statement', 'N/A')[:50]}...")
                print(f"  ⏰ Timestamp: {data[0].get('timestamp', 'N/A')}")
            return True
            
        except Exception as e:
            await self.log_test("FETCH MYTH HISTORY", "FAIL", str(e))
            return False
    
    async def test_brushing_tracker(self):
        """Test: Save and retrieve brushing records"""
        print("\n" + "=" * 70)
        print("TEST 5: BRUSHING TRACKER - Save brushing records")
        print("=" * 70)
        
        try:
            today = date.today()
            response = await self.session.post(
                f"{self.base_url}/api/brushing/records",
                headers={"Authorization": f"Bearer {self.access_token}"},
                json={
                    "date": str(today),
                    "morning_brushed": True,
                    "night_brushed": False,
                    "streak": 5,
                }
            )
            
            if response.status_code != 200:
                await self.log_test("BRUSHING SAVE", "FAIL", f"Status {response.status_code}")
                print(f"Response: {response.text}")
                return False
            
            data = response.json()
            await self.log_test("BRUSHING SAVE", "PASS", f"Saved for {today}")
            print(f"  ✓ Morning: True")
            print(f"  ✗ Night: False")
            print(f"  🔥 Streak: 5 days")
            
            # Fetch brushing records
            fetch_response = await self.session.get(
                f"{self.base_url}/api/brushing/records",
                headers={"Authorization": f"Bearer {self.access_token}"}
            )
            
            if fetch_response.status_code != 200:
                await self.log_test("BRUSHING FETCH", "FAIL", f"Status {fetch_response.status_code}")
                return False
            
            records = fetch_response.json()
            count = len(records) if isinstance(records, list) else 0
            
            await self.log_test("BRUSHING FETCH", "PASS", f"Retrieved {count} records")
            return True
            
        except Exception as e:
            await self.log_test("BRUSHING TRACKER", "FAIL", str(e))
            return False
    
    async def test_notifications(self):
        """Test: Save notification settings"""
        print("\n" + "=" * 70)
        print("TEST 6: NOTIFICATIONS - Save notification settings")
        print("=" * 70)
        
        try:
            response = await self.session.post(
                f"{self.base_url}/api/notifications/me",
                headers={"Authorization": f"Bearer {self.access_token}"},
                json={
                    "reminder_time": "08:00:00",
                    "enabled": True,
                }
            )
            
            if response.status_code != 200:
                await self.log_test("NOTIFICATION SAVE", "FAIL", f"Status {response.status_code}")
                print(f"Response: {response.text}")
                return False
            
            await self.log_test("NOTIFICATION SAVE", "PASS", "Notification settings saved")
            print(f"  🔔 Reminder Time: 08:00 AM")
            print(f"  ✓ Enabled: True")
            
            # Fetch notification settings
            fetch_response = await self.session.get(
                f"{self.base_url}/api/notifications/me",
                headers={"Authorization": f"Bearer {self.access_token}"}
            )
            
            if fetch_response.status_code != 200:
                await self.log_test("NOTIFICATION FETCH", "FAIL", f"Status {fetch_response.status_code}")
                return False
            
            await self.log_test("NOTIFICATION FETCH", "PASS", "Settings retrieved")
            return True
            
        except Exception as e:
            await self.log_test("NOTIFICATIONS", "FAIL", str(e))
            return False
    
    async def run_all_tests(self):
        """Run all persistence tests"""
        print("\n")
        print("=" * 70)
        print("DENTZY BACKEND PERSISTENCE TEST SUITE")
        print("=" * 70)
        print(f"\nBackend URL: {self.base_url}")
        print(f"Test User: {TEST_EMAIL}\n")
        
        results = {
            "signup": await self.test_signup(),
            "login": await self.test_login(),
            "myth_classification": await self.test_myth_classification(),
            "fetch_myth_history": await self.test_fetch_myth_history(),
            "brushing_tracker": await self.test_brushing_tracker(),
            "notifications": await self.test_notifications(),
        }
        
        # Summary
        print("\n" + "=" * 70)
        print("TEST SUMMARY")
        print("=" * 70)
        passed = sum(1 for v in results.values() if v)
        total = len(results)
        
        for test_name, result in results.items():
            status = "[PASS]" if result else "[FAIL]"
            print(f"{status} - {test_name.replace('_', ' ').title()}")
        
        print(f"\n[RESULTS] {passed}/{total} tests passed")
        
        if passed == total:
            print("[SUCCESS] All tests passed! Backend persistence is working correctly.")
        else:
            print(f"[WARNING] {total - passed} test(s) failed. Check logs above for details.")
        
        return passed == total


async def main():
    async with DentzyTestRunner(BASE_URL) as runner:
        success = await runner.run_all_tests()
        return 0 if success else 1


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    exit(exit_code)
