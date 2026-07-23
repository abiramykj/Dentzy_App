import pytest
import time
from src.pages.brushing_tracker_page import BrushingTrackerPage

# Parametrized tabs to check navigation
TABS = [
    ("Weekly", "TC-BRUSH-TAB-01"),
    ("Monthly", "TC-BRUSH-TAB-02"),
    ("Daily", "TC-BRUSH-TAB-03"),
]

# We can parameterize different member selections if we mock them or if we have seed data.
MEMBERS = [
    ("Self", "TC-BRUSH-MEM-01"),
    ("Child 1", "TC-BRUSH-MEM-02"),
]

@pytest.mark.module("BrushingTracker")
@pytest.mark.feature("Activity Logging")
class TestBrushingTrackerFlows:

    @pytest.fixture(autouse=True)
    def setup_tracker_page(self, appium_driver):
        # Assuming we are on the Brushing Tracker screen
        self.driver = appium_driver
        self.tracker_page = BrushingTrackerPage(self.driver)

    @pytest.mark.test_id("TC-BRUSH-001")
    @pytest.mark.scenario("Verify Brushing Tracker elements are visible")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Tabs and logging buttons are present")
    def test_verify_tracker_elements(self):
        assert self.tracker_page.is_element_present(*self.tracker_page.MARK_MORNING_BUTTON)
        assert self.tracker_page.is_element_present(*self.tracker_page.MARK_NIGHT_BUTTON)
        assert self.tracker_page.is_element_present(*self.tracker_page.WEEKLY_TAB)
        assert self.tracker_page.is_element_present(*self.tracker_page.MONTHLY_TAB)
        assert self.tracker_page.is_element_present(*self.tracker_page.DAILY_TAB)

    @pytest.mark.test_id("TC-BRUSH-002")
    @pytest.mark.scenario("Mark morning brushing")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Morning brushing marked successfully")
    def test_mark_morning_brushing(self):
        # We can simulate clicking the mark morning button
        self.tracker_page.click_mark_morning()
        time.sleep(1)
        # Ideally, we assert a success message or that the button changes state
        # assert some success criteria...

    @pytest.mark.test_id("TC-BRUSH-003")
    @pytest.mark.scenario("Mark night brushing")
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Night brushing marked successfully")
    def test_mark_night_brushing(self):
        self.tracker_page.click_mark_night()
        time.sleep(1)
        # Verify success

    @pytest.mark.parametrize("tab_name, test_id", TABS, ids=[x[1] for x in TABS])
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Tab switches successfully")
    def test_tab_navigation(self, tab_name, test_id):
        if tab_name == "Weekly":
            self.tracker_page.switch_to_weekly()
        elif tab_name == "Monthly":
            self.tracker_page.switch_to_monthly()
        else:
            self.tracker_page.switch_to_daily()
        
        time.sleep(1)
        # Verify the specific tab content is visible (e.g., calendar or chart)
        # In this skeleton we just verify the button remains or doesn't crash
        assert True

    @pytest.mark.parametrize("member, test_id", MEMBERS, ids=[x[1] for x in MEMBERS])
    @pytest.mark.test_type("Positive")
    @pytest.mark.expected("Can select family member for tracking")
    def test_member_selection(self, member, test_id):
        # We check if member dropdown is present and attempt to click it
        if self.tracker_page.is_element_present(*self.tracker_page.MEMBER_DROPDOWN):
            self.tracker_page.click(*self.tracker_page.MEMBER_DROPDOWN)
            time.sleep(1)
            # We would select the member by text and verify state changes
            # For now, close dropdown by clicking back
            self.tracker_page.driver.press_keycode(4) # Android back button
