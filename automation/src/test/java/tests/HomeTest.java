package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class HomeTest extends BaseTest {
    @Test(priority = 1, description = "App title should be visible")
    public void homeScreenLoads() { module = "Home"; testId = "HOME-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App title should be visible"); }

    @Test(priority = 1, description = "Welcome text should be visible")
    public void navigateToMythChecker() { module = "Home"; testId = "HOME-002"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Welcome Back!"), "Welcome text should be visible"); }
}
