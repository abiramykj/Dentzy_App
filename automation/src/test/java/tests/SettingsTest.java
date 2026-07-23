package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class SettingsTest extends BaseTest {
    @Test(priority = 1, description = "Settings flow should show the app shell")
    public void openSettings() { module = "Settings"; testId = "SET-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should be visible in settings flow"); }
}
