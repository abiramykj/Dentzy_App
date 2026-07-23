from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class LoginWelcomePage(BasePage):
    # Locators
    EMAIL_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'email') or contains(@text, 'email') or contains(@hint, 'Email') or contains(@text, 'Email')]")
    PASSWORD_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'password') or contains(@text, 'password') or contains(@hint, 'Password') or contains(@text, 'Password')]")
    REMEMBER_ME = (AppiumBy.CLASS_NAME, "android.widget.CheckBox")
    SIGN_IN_BUTTON = (AppiumBy.XPATH, "//*[@content-desc='Sign In' or @text='Sign In']")
    SIGN_UP_BUTTON = (AppiumBy.XPATH, "//*[@content-desc='Sign Up' or @text='Sign Up']")
    FORGOT_PASSWORD = (AppiumBy.XPATH, "//*[@content-desc='Forgot password?' or @text='Forgot password?']")

    def enter_email(self, email):
        self.send_keys(self.EMAIL_INPUT[0], self.EMAIL_INPUT[1], email)

    def enter_password(self, password):
        self.send_keys(self.PASSWORD_INPUT[0], self.PASSWORD_INPUT[1], password)

    def toggle_remember_me(self):
        self.click(*self.REMEMBER_ME)

    def click_sign_in(self):
        self.click(*self.SIGN_IN_BUTTON)

    def click_sign_up(self):
        self.click(*self.SIGN_UP_BUTTON)

    def click_forgot_password(self):
        self.click(*self.FORGOT_PASSWORD)

    def perform_login(self, email, password):
        self.enter_email(email)
        self.enter_password(password)
        self.hide_keyboard()
        self.click_sign_in()
