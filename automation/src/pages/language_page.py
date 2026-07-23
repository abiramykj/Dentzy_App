from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class LanguagePage(BasePage):
    # Locators
    ENGLISH_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'English') or contains(@text, 'English')]")
    TAMIL_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'தமிழ்') or contains(@text, 'தமிழ்') or contains(@content-desc, 'Tamil') or contains(@text, 'Tamil')]")
    CONTINUE_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Continue') or contains(@text, 'Continue')]")

    def select_english(self):
        self.click(*self.ENGLISH_CARD)

    def select_tamil(self):
        self.click(*self.TAMIL_CARD)

    def click_continue(self):
        self.click(*self.CONTINUE_BUTTON)
