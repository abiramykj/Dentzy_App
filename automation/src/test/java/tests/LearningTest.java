package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class LearningTest extends BaseTest {
    @Test(priority = 1, description = "Learning view should expose the app shell")
    public void openArticles() { module = "Learning"; testId = "LEARN-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should remain visible"); }
}
