from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class SignupPage(BasePage):
    # Locators
    FULL_NAME_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'name') or contains(@text, 'name') or contains(@hint, 'Name') or contains(@text, 'Name')]")
    EMAIL_INPUT = (AppiumBy.XPATH, "(//android.widget.EditText[contains(@hint, 'email') or contains(@text, 'email') or contains(@hint, 'Email') or contains(@text, 'Email')])[1]")
    PASSWORD_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'password') or contains(@text, 'password') or contains(@hint, 'Password') or contains(@text, 'Password')][not(contains(@hint, 'Confirm'))]")
    CONFIRM_PASSWORD_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Confirm') or contains(@text, 'Confirm') or contains(@hint, 'confirm') or contains(@text, 'confirm')]")
    CREATE_ACCOUNT_BUTTON = (AppiumBy.XPATH, "//*[@content-desc='Create Account' or @text='Create Account']")
    BACK_TO_LOGIN_BUTTON = (AppiumBy.XPATH, "//*[@content-desc='Back to Login' or @text='Back to Login']")

    def enter_full_name(self, name):
        self.send_keys(*self.FULL_NAME_INPUT, text=name)

    def enter_email(self, email):
        self.send_keys(*self.EMAIL_INPUT, text=email)

    def enter_password(self, password):
        self.send_keys(*self.PASSWORD_INPUT, text=password)

    def enter_confirm_password(self, password):
        self.send_keys(*self.CONFIRM_PASSWORD_INPUT, text=password)

    def click_create_account(self):
        self.click(*self.CREATE_ACCOUNT_BUTTON)

    def click_back_to_login(self):
        self.click(*self.BACK_TO_LOGIN_BUTTON)

    def perform_signup(self, name, email, password, confirm_password):
        self.enter_full_name(name)
        self.enter_email(email)
        self.enter_password(password)
        self.enter_confirm_password(confirm_password)
        self.hide_keyboard()
        self.click_create_account()
