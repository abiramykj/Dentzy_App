import time
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from appium.webdriver.common.appiumby import AppiumBy

class BasePage:
    def __init__(self, driver):
        self.driver = driver
        self.timeout = 10

    def find_element(self, by, locator, timeout=None):
        """Wait for and find an element."""
        t = timeout if timeout is not None else self.timeout
        try:
            return WebDriverWait(self.driver, t).until(
                EC.presence_of_element_located((by, locator))
            )
        except Exception as e:
            raise Exception(f"Element not found within {t}s: {by}={locator}. Error: {e}")

    def find_visible_element(self, by, locator, timeout=None):
        """Wait for and find a visible element."""
        t = timeout if timeout is not None else self.timeout
        try:
            return WebDriverWait(self.driver, t).until(
                EC.visibility_of_element_located((by, locator))
            )
        except Exception as e:
            raise Exception(f"Element not visible within {t}s: {by}={locator}. Error: {e}")

    def click(self, by, locator, timeout=None):
        """Wait for element to be clickable and click it."""
        t = timeout if timeout is not None else self.timeout
        try:
            element = WebDriverWait(self.driver, t).until(
                EC.element_to_be_clickable((by, locator))
            )
            element.click()
        except Exception as e:
            raise Exception(f"Failed to click element: {by}={locator} within {t}s. Error: {e}")

    def send_keys(self, by, locator, text, timeout=None, clear_first=True):
        """Wait for element, clear if requested, and type text."""
        t = timeout if timeout is not None else self.timeout
        try:
            element = self.find_visible_element(by, locator, t)
            if clear_first:
                element.clear()
            element.send_keys(text)
        except Exception as e:
            raise Exception(f"Failed to send keys to element: {by}={locator} within {t}s. Error: {e}")

    def is_element_present(self, by, locator, timeout=3):
        """Check if element is present in DOM without throwing exceptions."""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located((by, locator))
            )
            return True
        except:
            return False

    def is_element_visible(self, by, locator, timeout=3):
        """Check if element is visible on screen without throwing exceptions."""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.visibility_of_element_located((by, locator))
            )
            return True
        except:
            return False

    def swipe(self, start_x, start_y, end_x, end_y, duration_ms=800):
        """Perform a basic swipe using W3C actions API."""
        try:
            self.driver.swipe(start_x, start_y, end_x, end_y, duration_ms)
        except Exception as e:
            raise Exception(f"Swipe failed: from ({start_x}, {start_y}) to ({end_x}, {end_y}). Error: {e}")

    def swipe_up(self, percentage=0.6, duration_ms=800):
        """Swipe up the screen."""
        size = self.driver.get_window_size()
        width = size['width']
        height = size['height']
        
        start_x = width // 2
        start_y = int(height * (0.5 + percentage / 2))
        end_x = width // 2
        end_y = int(height * (0.5 - percentage / 2))
        self.swipe(start_x, start_y, end_x, end_y, duration_ms)

    def swipe_down(self, percentage=0.6, duration_ms=800):
        """Swipe down the screen."""
        size = self.driver.get_window_size()
        width = size['width']
        height = size['height']
        
        start_x = width // 2
        start_y = int(height * (0.5 - percentage / 2))
        end_x = width // 2
        end_y = int(height * (0.5 + percentage / 2))
        self.swipe(start_x, start_y, end_x, end_y, duration_ms)

    def hide_keyboard(self):
        """Safely hide keyboard if open."""
        try:
            if self.driver.is_keyboard_shown():
                self.driver.hide_keyboard()
        except:
            pass

    def get_element_text(self, by, locator, timeout=None):
        """Get text or content-desc of an element."""
        element = self.find_visible_element(by, locator, timeout)
        text = element.text
        if not text:
            text = element.get_attribute("content-desc")
        return text or ""
