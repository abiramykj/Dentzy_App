package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class BrushingTest extends BaseTest {
    @Test(priority = 1, description = "Brushing screen should show the app shell")
    public void openBrushingTimer() { module = "Brushing"; testId = "BRUSH-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should be visible in brushing flow"); }
}
