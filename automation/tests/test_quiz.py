import pytest
import time
from src.pages.quiz_page import QuizPage

# Different demographic inputs for validations
INVALID_DEMOGRAPHICS = [
    ("", "25", "Missing name"),
    ("John Doe", "", "Missing age"),
    ("John Doe", "abc", "Non-numeric age"),
    ("John Doe", "200", "Invalid age bounds"),
]

# A parameterized way to do the quiz and get a specific simulated score
# E.g., choosing option 1 for all questions, option 2 for all, etc.
QUIZ_CHOICE_PATTERNS = [
    (1, "All option 1 selected"),
    (2, "All option 2 selected"),
    (3, "All option 3 selected"),
]

@pytest.mark.module("Quiz")
@pytest.mark.feature("Assessment")
class TestQuizFlows:

    @pytest.fixture(autouse=True)
    def setup_quiz_page(self, appium_driver):
        self.driver = appium_driver
        self.quiz_page = QuizPage(self.driver)

    @pytest.mark.test_id("TC-QZ-001")
    @pytest.mark.scenario("Verify Quiz Demographics Form elements")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Name, Age, Area and Start button are visible")
    def test_verify_quiz_form_elements(self):
        assert self.quiz_page.is_element_present(*self.quiz_page.NAME_INPUT)
        assert self.quiz_page.is_element_present(*self.quiz_page.AGE_INPUT)
        assert self.quiz_page.is_element_present(*self.quiz_page.START_ASSESSMENT_BUTTON)

    @pytest.mark.parametrize("name,age,desc", INVALID_DEMOGRAPHICS, ids=[f"TC-QZ-INV-{x[2].replace(' ', '_')}" for x in INVALID_DEMOGRAPHICS])
    @pytest.mark.test_type("Negative")
    @pytest.mark.expected("Cannot start assessment with invalid details")
    def test_invalid_demographics(self, name, age, desc):
        self.quiz_page.enter_details(name, age)
        self.quiz_page.hide_keyboard()
        
        time.sleep(1)
        # Verify the user is not taken to the first question (Start button remains)
        assert self.quiz_page.is_element_present(*self.quiz_page.START_ASSESSMENT_BUTTON)

    @pytest.mark.parametrize("choice_idx,desc", QUIZ_CHOICE_PATTERNS, ids=[f"TC-QZ-FLOW-{x[1].replace(' ', '_')}" for x in QUIZ_CHOICE_PATTERNS])
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Complete quiz and reach results page")
    def test_complete_quiz_flow(self, choice_idx, desc):
        # 1. Start assessment
        self.quiz_page.enter_details("Test User", "25")
        self.quiz_page.hide_keyboard()
        time.sleep(1)
        
        # 2. Answer questions (Assuming 10 questions in a loop)
        for i in range(10):
            # If we reached the result button early, break
            if self.quiz_page.is_element_present(*self.quiz_page.VIEW_RESULT_BUTTON, timeout=2):
                break
            
            # Click an option
            self.quiz_page.select_option(choice_idx)
            
            # Click Next or View Result
            if self.quiz_page.is_element_present(*self.quiz_page.NEXT_BUTTON, timeout=1):
                self.quiz_page.click_next()
            time.sleep(1)
            
        # 3. Finally click View Result if we are on the last question
        if self.quiz_page.is_element_present(*self.quiz_page.VIEW_RESULT_BUTTON, timeout=2):
            self.quiz_page.click_view_result()
            
        time.sleep(2)
        
        # 4. Verify results screen (Retake or PDF Export buttons exist)
        assert (self.quiz_page.is_element_present(*self.quiz_page.RETAKE_BUTTON) or 
                self.quiz_page.is_element_present(*self.quiz_page.EXPORT_PDF_BUTTON))
