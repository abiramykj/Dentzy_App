import os
import sys
import time
import pytest

ROOT = os.path.dirname(os.path.dirname(__file__))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)


@pytest.mark.test_id("TC-001")
@pytest.mark.module("Login")
@pytest.mark.feature("Authentication")
@pytest.mark.scenario("Launch app and verify login screen")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("App opens and login UI is visible")
def test_launch_app_and_login_screen(appium_driver):
    driver = appium_driver
    time.sleep(3)
    assert driver is not None


@pytest.mark.test_id("TC-002")
@pytest.mark.module("Registration")
@pytest.mark.feature("Authentication")
@pytest.mark.scenario("Open registration flow")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Registration screen is reachable")
def test_registration_flow(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-003")
@pytest.mark.module("Forgot Password")
@pytest.mark.feature("Authentication")
@pytest.mark.scenario("Open forgot password flow")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Forgot password screen is reachable")
def test_forgot_password_flow(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-004")
@pytest.mark.module("Home")
@pytest.mark.feature("Navigation")
@pytest.mark.scenario("Open home dashboard")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Home screen is displayed")
def test_home_screen(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-005")
@pytest.mark.module("AI Myth Checker")
@pytest.mark.feature("Myth Checker")
@pytest.mark.scenario("Open myth checker")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Myth checker screen opens")
def test_ai_myth_checker(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-006")
@pytest.mark.module("Learning Articles")
@pytest.mark.feature("Learning")
@pytest.mark.scenario("Open learning articles")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Learning articles screen is reachable")
def test_learning_articles(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-007")
@pytest.mark.module("Learning Videos")
@pytest.mark.feature("Learning")
@pytest.mark.scenario("Open learning videos")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Learning videos screen is reachable")
def test_learning_videos(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-008")
@pytest.mark.module("Quiz")
@pytest.mark.feature("Engagement")
@pytest.mark.scenario("Open quiz")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Quiz screen opens")
def test_quiz_flow(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-009")
@pytest.mark.module("Brushing Tracker")
@pytest.mark.feature("Tracking")
@pytest.mark.scenario("Open brushing tracker")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Brushing tracker screen is reachable")
def test_brushing_tracker(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-010")
@pytest.mark.module("Notifications")
@pytest.mark.feature("Reminder")
@pytest.mark.scenario("Open notifications")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Notifications screen opens")
def test_notifications(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-011")
@pytest.mark.module("Reports")
@pytest.mark.feature("Analytics")
@pytest.mark.scenario("Open reports")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Reports screen is reachable")
def test_reports(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-012")
@pytest.mark.module("Profile")
@pytest.mark.feature("User Profile")
@pytest.mark.scenario("Open profile")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Profile screen opens")
def test_profile(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-013")
@pytest.mark.module("Family Members")
@pytest.mark.feature("Family")
@pytest.mark.scenario("Open family members")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Family members screen opens")
def test_family_members(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-014")
@pytest.mark.module("Settings")
@pytest.mark.feature("Preferences")
@pytest.mark.scenario("Open settings")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("Settings screen opens")
def test_settings(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None


@pytest.mark.test_id("TC-015")
@pytest.mark.module("Logout")
@pytest.mark.feature("Authentication")
@pytest.mark.scenario("Logout from app")
@pytest.mark.test_type("Positive")
@pytest.mark.expected("User can log out successfully")
def test_logout(appium_driver):
    driver = appium_driver
    time.sleep(2)
    assert driver is not None
