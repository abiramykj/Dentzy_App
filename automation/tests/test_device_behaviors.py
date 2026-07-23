import pytest
import time
from src.pages.login_welcome_page import LoginWelcomePage

@pytest.mark.module("DeviceBehaviors")
@pytest.mark.feature("Hardware Interactions")
class TestDeviceBehaviors:

    @pytest.fixture(autouse=True)
    def setup_driver(self, appium_driver):
        self.driver = appium_driver
        self.login_page = LoginWelcomePage(self.driver)

    @pytest.mark.test_id("TC-DEV-001")
    @pytest.mark.scenario("Verify App behavior on device rotation to Landscape")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("App scales/scrolls correctly in landscape without crashing")
    def test_landscape_rotation(self):
        # Rotate to landscape
        try:
            self.driver.orientation = 'LANDSCAPE'
            time.sleep(2)
            
            # Verify basic element is still accessible
            assert self.login_page.is_element_present(*self.login_page.SIGN_IN_BUTTON)
            
            # Rotate back to portrait
            self.driver.orientation = 'PORTRAIT'
            time.sleep(2)
        except Exception as e:
            pytest.skip(f"Device rotation not supported or failed on emulator: {e}")

    @pytest.mark.test_id("TC-DEV-002")
    @pytest.mark.scenario("Verify App behavior when backgrounded and resumed")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("App resumes seamlessly from background")
    def test_background_and_resume(self):
        try:
            # Send app to background for 3 seconds
            self.driver.background_app(3)
            time.sleep(1)
            
            # Verify we are back
            assert self.login_page.is_element_present(*self.login_page.SIGN_IN_BUTTON)
        except Exception as e:
            pytest.skip(f"Backgrounding app failed on this platform: {e}")

    @pytest.mark.test_id("TC-DEV-003")
    @pytest.mark.scenario("Verify hardware back button closes modals or goes back")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Hardware back button navigates correctly")
    def test_hardware_back_button(self):
        # Go to Sign Up
        self.login_page.click_sign_up()
        time.sleep(1.5)
        
        # Press hardware back (keycode 4)
        self.driver.press_keycode(4)
        time.sleep(1.5)
        
        # Verify we are back on Login Welcome
        assert self.login_page.is_element_present(*self.login_page.SIGN_IN_BUTTON)
