from appium.webdriver.common.appiumby import AppiumBy
from .base_page import BasePage

class MythCheckerPage(BasePage):
    # Locators
    STATEMENT_INPUT = (AppiumBy.XPATH, "//android.widget.TextField | //android.widget.EditText")
    CHECK_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Check') or contains(@text, 'Check') or contains(@content-desc, 'Check statement') or contains(@text, 'Check statement')]")
    RESULT_EXPLANATION = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Explanation') or contains(@text, 'Explanation')]/following-sibling::android.view.View | //*[contains(@content-desc, 'Explanation') or contains(@text, 'Explanation')]/..")
    RESULT_LABEL = (AppiumBy.XPATH, "//*[contains(@content-desc, 'Fact') or contains(@text, 'Fact') or contains(@content-desc, 'Myth') or contains(@text, 'Myth') or contains(@content-desc, 'Not Dental') or contains(@text, 'Not Dental') or contains(@content-desc, 'NOT_DENTAL') or contains(@text, 'NOT_DENTAL')]")
    VIEW_HISTORY_BUTTON = (AppiumBy.XPATH, "//*[contains(@content-desc, 'View History') or contains(@text, 'View History')]")

    def enter_statement(self, text):
        self.send_keys(*self.STATEMENT_INPUT, text=text)

    def click_check(self):
        self.click(*self.CHECK_BUTTON)

    def get_result_label(self, timeout=15):
        # AI response can take a few seconds
        try:
            return self.get_element_text(self.RESULT_LABEL[0], self.RESULT_LABEL[1], timeout=timeout)
        except Exception:
            return "Error: Result label not found"

    def get_result_explanation(self, timeout=15):
        try:
            return self.get_element_text(self.RESULT_EXPLANATION[0], self.RESULT_EXPLANATION[1], timeout=timeout)
        except Exception:
            return "Error: Explanation not found"

    def click_view_history(self):
        self.click(*self.VIEW_HISTORY_BUTTON)
