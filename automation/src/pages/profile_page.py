from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class ProfilePage(BasePage):
    # Locators
    LOGOUT_CARD = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Logout') or contains(@text, 'Logout') or contains(@content-desc, 'Log out') or contains(@text, 'Log out')]")
    LOGOUT_CONFIRM_BUTTON = (AppiumBy.XPATH, "//android.widget.Button[contains(@content-desc, 'Logout') or contains(@text, 'Logout')]")
    LOGOUT_CANCEL_BUTTON = (AppiumBy.XPATH, "//*[@content-desc='Cancel' or @text='Cancel']")
    
    ADD_FAMILY_MEMBER_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Add') or contains(@text, 'Add')]")
    DIALOG_NAME_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Name') or contains(@text, 'Name') or contains(@hint, 'name') or contains(@text, 'name')]")
    DIALOG_AGE_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Age') or contains(@text, 'Age') or contains(@hint, 'age') or contains(@text, 'age')]")
    DIALOG_ADD_SUBMIT = (AppiumBy.XPATH, "//android.widget.Button[@text='Add' or @content-desc='Add']")
    
    MYTHS_CHECKED_TEXT = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Myths Checked') or contains(@text, 'Myths Checked')]/preceding-sibling::android.view.View")
    STREAK_TEXT = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Day Streak') or contains(@text, 'Day Streak')]/preceding-sibling::android.view.View")

    def click_logout(self):
        self.swipe_up(percentage=0.5) # ensure visible
        self.click(*self.LOGOUT_CARD)

    def confirm_logout(self):
        self.click(*self.LOGOUT_CONFIRM_BUTTON)

    def cancel_logout(self):
        self.click(*self.LOGOUT_CANCEL_BUTTON)

    def perform_logout(self):
        self.click_logout()
        self.confirm_logout()

    def click_add_family_member(self):
        self.click(*self.ADD_FAMILY_MEMBER_BUTTON)

    def enter_member_details(self, name, age):
        self.send_keys(self.DIALOG_NAME_INPUT[0], self.DIALOG_NAME_INPUT[1], name)
        self.send_keys(self.DIALOG_AGE_INPUT[0], self.DIALOG_AGE_INPUT[1], age)
        self.click(*self.DIALOG_ADD_SUBMIT)

    def get_myths_checked_count(self):
        try:
            return self.get_element_text(*self.MYTHS_CHECKED_TEXT)
        except Exception:
            return "0"

    def get_streak_count(self):
        try:
            return self.get_element_text(*self.STREAK_TEXT)
        except Exception:
            return "0"
