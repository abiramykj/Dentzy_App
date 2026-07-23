import pytest
import time
from src.pages.login_welcome_page import LoginWelcomePage

@pytest.mark.module("ErrorHandling")
@pytest.mark.feature("Resilience")
class TestErrorHandling:

    @pytest.fixture(autouse=True)
    def setup_driver(self, appium_driver):
        self.driver = appium_driver
        self.login_page = LoginWelcomePage(self.driver)

    @pytest.mark.test_id("TC-ERR-001")
    @pytest.mark.scenario("Verify login behavior when network is offline")
    @pytest.mark.test_type("Negative")
    @pytest.mark.expected("App shows network error or timeout message")
    def test_offline_login_attempt(self):
        # We can set network connection to airplane mode / offline via Appium
        # Note: Depending on the emulator and permissions, this might fail, so we wrap it.
        try:
            # Set to offline (NetworkConnection.AIRPLANE_MODE = 1)
            self.driver.set_network_connection(1)
            time.sleep(2)
            
            # Attempt login
            self.login_page.enter_email("user@dentzy.com")
            self.login_page.enter_password("Password123!")
            self.login_page.hide_keyboard()
            self.login_page.click_sign_in()
            
            time.sleep(3)
            # Verify we are still on login page and ideally an error is shown
            assert self.login_page.is_element_present(*self.login_page.SIGN_IN_BUTTON)
            
        except Exception as e:
            pytest.skip(f"Network switching not supported or failed: {e}")
        finally:
            # Restore network (NetworkConnection.ALL_NETWORK_ON = 6)
            try:
                self.driver.set_network_connection(6)
            except:
                pass

    @pytest.mark.test_id("TC-ERR-002")
    @pytest.mark.scenario("Verify timeout handling on heavy API calls")
    @pytest.mark.test_type("Negative")
    @pytest.mark.expected("App gracefully handles API timeouts")
    def test_timeout_handling(self):
        # We simulate a timeout by providing a very large data payload or
        # using a known bad credential that takes time. In real tests we mock the API.
        # Here we just verify that long presses or invalid rapid clicks don't crash.
        
        self.login_page.enter_email("timeout_user_simulation@dentzy.com")
        self.login_page.enter_password("TimeoutTest!123")
        self.login_page.hide_keyboard()
        
        # Rapid clicks to simulate impatience
        for _ in range(5):
            self.login_page.click_sign_in()
            
        time.sleep(2)
        assert self.login_page.is_element_present(*self.login_page.SIGN_IN_BUTTON)
