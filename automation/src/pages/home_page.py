from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class HomePage(BasePage):
    # Locators
    WELCOME_TEXT = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Welcome') or contains(@text, 'Welcome') or contains(@content-desc, 'Hello') or contains(@text, 'Hello')]")
    PROFILE_ICON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'person') or contains(@text, 'person') or contains(@content-desc, 'Profile') or contains(@text, 'Profile') or @class='android.widget.ImageView' and @index='2']") # standard profile bubble
    NOTIFICATIONS_ICON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'notifications') or contains(@text, 'notifications')]")
    
    # Quick action buttons
    MYTH_CHECKER_FAB = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Myth Checker') or contains(@text, 'Myth Checker') or contains(@content-desc, 'checker') or contains(@text, 'checker')]")
    START_QUIZ_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Start Quiz') or contains(@text, 'Start Quiz')]")
    
    MYTH_CHECKER_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Myth Checker') or contains(@text, 'Myth Checker')]")
    LEARN_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Learn') or contains(@text, 'Learn')]")
    BRUSHING_TIMER_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Brushing Timer') or contains(@text, 'Brushing Timer')]")
    BRUSHING_TRACKER_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Brushing Tracker') or contains(@text, 'Brushing Tracker')]")
    PROGRESS_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Progress') or contains(@text, 'Progress')]")
    VIDEOS_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Videos') or contains(@text, 'Videos')]")

    def wait_for_home(self):
        """Wait for home screen welcome message."""
        return self.find_visible_element(*self.WELCOME_TEXT)

    def click_profile(self):
        # We can find profile icon by checking for persona or using coordinates/xpath
        self.click(*self.PROFILE_ICON)

    def click_notifications(self):
        self.click(*self.NOTIFICATIONS_ICON)

    def click_myth_checker_fab(self):
        self.click(*self.MYTH_CHECKER_FAB)

    def click_start_quiz(self):
        self.click(*self.START_QUIZ_BUTTON)

    def navigate_to_myth_checker(self):
        self.click(*self.MYTH_CHECKER_CARD)

    def navigate_to_learn(self):
        self.click(*self.LEARN_CARD)

    def navigate_to_brushing_timer(self):
        self.click(*self.BRUSHING_TIMER_CARD)

    def navigate_to_brushing_tracker(self):
        self.click(*self.BRUSHING_TRACKER_CARD)

    def navigate_to_progress(self):
        self.click(*self.PROGRESS_CARD)

    def navigate_to_videos(self):
        self.click(*self.VIDEOS_CARD)
