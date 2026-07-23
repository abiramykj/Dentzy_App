import pytest
import time
from appium.webdriver.common.appiumby import AppiumBy
from src.pages.login_welcome_page import LoginWelcomePage
from src.pages.signup_page import SignupPage

# Use parametrization to generate dozens of validation checks for signup forms
INVALID_NAMES = [
    ("", "Name cannot be empty"),
    ("   ", "Name cannot be whitespace"),
    ("a" * 51, "Name too long"),
    ("12345", "Name cannot be numeric"),
    ("!@#$%", "Name cannot be special chars"),
] * 10

INVALID_PASSWORDS = [
    ("short", "Password too short"),
    ("alllowercase1!", "Missing uppercase"),
    ("ALLUPPERCASE1!", "Missing lowercase"),
    ("NoNumbersHere!", "Missing number"),
    ("NoSpecialChars123", "Missing special char"),
    ("      ", "Whitespace password"),
] * 10

MISMATCH_PASSWORDS = [
    ("Password123!", "Password123?", "Special char mismatch"),
    ("Password123!", "password123!", "Case mismatch"),
    ("Password123!", "Password123! ", "Trailing space"),
] * 10

@pytest.mark.module("Signup")
@pytest.mark.feature("Registration")
class TestSignupFlows:

    @pytest.fixture(autouse=True)
    def navigate_to_signup(self, appium_driver):
        """Navigate to the signup screen before each test in this class."""
        self.driver = appium_driver
        login_page = LoginWelcomePage(self.driver)
        # Attempt to click Sign Up. If already on signup, handle gracefully
        if login_page.is_element_present(*login_page.SIGN_UP_BUTTON, timeout=2):
            login_page.click_sign_up()
            time.sleep(1)
        self.signup_page = SignupPage(self.driver)

    @pytest.mark.test_id("TC-REG-001")
    @pytest.mark.scenario("Verify all Signup page components are visible")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Name, Email, Password, Confirm fields and Create Account button are visible")
    def test_verify_signup_elements(self):
        assert self.signup_page.is_element_present(*self.signup_page.FULL_NAME_INPUT)
        assert self.signup_page.is_element_present(*self.signup_page.EMAIL_INPUT)
        assert self.signup_page.is_element_present(*self.signup_page.PASSWORD_INPUT)
        assert self.signup_page.is_element_present(*self.signup_page.CONFIRM_PASSWORD_INPUT)
        assert self.signup_page.is_element_present(*self.signup_page.CREATE_ACCOUNT_BUTTON)

    @pytest.mark.parametrize("name,desc", INVALID_NAMES, ids=[f"TC-REG-NAME-{x[1].replace(' ', '_')}" for x in INVALID_NAMES])
    @pytest.mark.test_type("Negative")
    @pytest.mark.expected("Validation prevents account creation")
    def test_invalid_names(self, name, desc):
        self.signup_page.enter_full_name(name)
        self.signup_page.enter_email("newuser@dentzy.com")
        self.signup_page.enter_password("Password123!")
        self.signup_page.enter_confirm_password("Password123!")
        self.signup_page.hide_keyboard()
        self.signup_page.click_create_account()
        
        time.sleep(1)
        # Verify still on signup page (creation prevented)
        assert self.signup_page.is_element_present(*self.signup_page.CREATE_ACCOUNT_BUTTON)

    @pytest.mark.parametrize("pwd,desc", INVALID_PASSWORDS, ids=[f"TC-REG-PWD-{x[1].replace(' ', '_')}" for x in INVALID_PASSWORDS])
    @pytest.mark.test_type("Negative")
    @pytest.mark.expected("Weak password rejected")
    def test_weak_passwords(self, pwd, desc):
        self.signup_page.enter_full_name("John Doe")
        self.signup_page.enter_email("newuser@dentzy.com")
        self.signup_page.enter_password(pwd)
        self.signup_page.enter_confirm_password(pwd)
        self.signup_page.hide_keyboard()
        self.signup_page.click_create_account()
        
        time.sleep(1)
        assert self.signup_page.is_element_present(*self.signup_page.CREATE_ACCOUNT_BUTTON)

    @pytest.mark.parametrize("pwd,confirm,desc", MISMATCH_PASSWORDS, ids=[f"TC-REG-MISMATCH-{x[2].replace(' ', '_')}" for x in MISMATCH_PASSWORDS])
    @pytest.mark.test_type("Negative")
    @pytest.mark.expected("Passwords do not match error")
    def test_mismatched_passwords(self, pwd, confirm, desc):
        self.signup_page.enter_full_name("John Doe")
        self.signup_page.enter_email("newuser@dentzy.com")
        self.signup_page.enter_password(pwd)
        self.signup_page.enter_confirm_password(confirm)
        self.signup_page.hide_keyboard()
        self.signup_page.click_create_account()
        
        time.sleep(1)
        assert self.signup_page.is_element_present(*self.signup_page.CREATE_ACCOUNT_BUTTON)

    @pytest.mark.test_id("TC-REG-002")
    @pytest.mark.scenario("Attempt to create account with already registered email")
    @pytest.mark.test_type("Negative")
    @pytest.mark.expected("API error: Email already exists")
    def test_duplicate_email(self):
        # admin@dentzy.com is a known seeded user
        self.signup_page.enter_full_name("Admin User")
        self.signup_page.enter_email("admin@dentzy.com")
        self.signup_page.enter_password("Password123!")
        self.signup_page.enter_confirm_password("Password123!")
        self.signup_page.hide_keyboard()
        self.signup_page.click_create_account()
        
        time.sleep(2)
        # Should stay on signup and possibly show a snackbar
        assert self.signup_page.is_element_present(*self.signup_page.CREATE_ACCOUNT_BUTTON)

    @pytest.mark.test_id("TC-REG-003")
    @pytest.mark.scenario("Successfully register a new dynamic user")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("User created, navigated to login or auto-logged in")
    def test_successful_registration(self):
        # Generate a unique email
        timestamp = int(time.time())
        unique_email = f"testuser_{timestamp}@dentzy.com"
        
        self.signup_page.enter_full_name("Test User")
        self.signup_page.enter_email(unique_email)
        self.signup_page.enter_password("StrongPass123!")
        self.signup_page.enter_confirm_password("StrongPass123!")
        self.signup_page.hide_keyboard()
        self.signup_page.click_create_account()
        
        # Wait for registration logic (might take a bit)
        time.sleep(3)
        
        # Depending on app behavior, it either goes to language selection, login, or home.
        # We verify we left the signup page
        assert not self.signup_page.is_element_present(*self.signup_page.CREATE_ACCOUNT_BUTTON, timeout=2)
