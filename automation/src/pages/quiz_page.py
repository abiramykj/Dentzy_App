from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class QuizPage(BasePage):
    # Locators
    NAME_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Name') or contains(@text, 'Name') or contains(@hint, 'name') or contains(@text, 'name')]")
    AGE_INPUT = (AppiumBy.XPATH, "//android.widget.EditText[contains(@hint, 'Age') or contains(@text, 'Age') or contains(@hint, 'age') or contains(@text, 'age')]")
    AREA_DROPDOWN = (AppiumBy.XPATH, "//android.widget.Button[contains(@content-desc, 'Urban') or contains(@content-desc, 'Rural') or contains(@content-desc, 'Area') or @class='android.widget.Button' and @index='2']")
    START_ASSESSMENT_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Assessment') or contains(@text, 'Assessment') or contains(@content-desc, 'Start') or contains(@text, 'Start')]")
    
    OPTION_RADIO = (AppiumBy.XPATH, "//android.widget.RadioButton | //android.widget.RadioListTile | //android.view.View[contains(@content-desc, 'Option') or contains(@text, 'Option')]")
    NEXT_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Next') or contains(@text, 'Next')]")
    PREVIOUS_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Previous') or contains(@text, 'Previous')]")
    VIEW_RESULT_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Result') or contains(@text, 'Result')]")
    EXPORT_PDF_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'PDF') or contains(@text, 'PDF')]")
    RETAKE_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Retake') or contains(@text, 'Retake') or contains(@content-desc, 'retake') or contains(@text, 'retake')]")

    def enter_details(self, name, age):
        self.send_keys(self.NAME_INPUT[0], self.NAME_INPUT[1], name)
        self.send_keys(self.AGE_INPUT[0], self.AGE_INPUT[1], age)
        self.click_start_assessment()

    def click_start_assessment(self):
        self.click(*self.START_ASSESSMENT_BUTTON)

    def select_option(self, index=1):
        # click specific option index
        options = self.driver.find_elements(*self.OPTION_RADIO)
        if options:
            options[min(index - 1, len(options) - 1)].click()
        else:
            # fallback xpath
            self.click(AppiumBy.XPATH, f"(//android.widget.RadioButton)[{index}]")

    def click_next(self):
        self.click(*self.NEXT_BUTTON)

    def click_view_result(self):
        self.click(*self.VIEW_RESULT_BUTTON)
