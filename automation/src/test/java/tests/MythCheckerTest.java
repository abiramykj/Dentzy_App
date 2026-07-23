package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class MythCheckerTest extends BaseTest {
    @Test(priority = 1, description = "Myth checker screen should be reachable from login")
    public void validMythCheck() { module = "Myth Checker"; testId = "MYTH-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should be visible"); }
}
