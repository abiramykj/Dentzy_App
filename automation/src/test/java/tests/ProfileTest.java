package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class ProfileTest extends BaseTest {
    @Test(priority = 1, description = "Profile flow should show the app shell")
    public void openProfile() { module = "Profile"; testId = "PROF-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should be visible in profile flow"); }
}
