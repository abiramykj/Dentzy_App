package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class ReportsTest extends BaseTest {
    @Test(priority = 1, description = "Reports flow should show the app shell")
    public void openReports() { module = "Reports"; testId = "REP-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should be visible in reports flow"); }
}
