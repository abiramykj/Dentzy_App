from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class BrushingTrackerPage(BasePage):
    # Locators
    MARK_MORNING_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Morning') or contains(@text, 'Morning') or contains(@content-desc, 'morning') or contains(@text, 'morning')]")
    MARK_NIGHT_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Night') or contains(@text, 'Night') or contains(@content-desc, 'night') or contains(@text, 'night')]")
    
    WEEKLY_TAB = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Weekly') or contains(@text, 'Weekly') or contains(@content-desc, 'weekly') or contains(@text, 'weekly')]")
    MONTHLY_TAB = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Monthly') or contains(@text, 'Monthly') or contains(@content-desc, 'monthly') or contains(@text, 'monthly')]")
    DAILY_TAB = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Daily') or contains(@text, 'Daily') or contains(@content-desc, 'daily') or contains(@text, 'daily')]")

    MEMBER_DROPDOWN = (AppiumBy.CLASS_NAME, "android.widget.Spinner") # Spinner/Dropdown on Android

    def click_mark_morning(self):
        self.click(*self.MARK_MORNING_BUTTON)

    def click_mark_night(self):
        self.click(*self.MARK_NIGHT_BUTTON)

    def switch_to_weekly(self):
        self.click(*self.WEEKLY_TAB)

    def switch_to_monthly(self):
        self.click(*self.MONTHLY_TAB)

    def switch_to_daily(self):
        self.click(*self.DAILY_TAB)
