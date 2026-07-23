package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class NotificationsTest extends BaseTest {
    @Test(priority = 1, description = "Notifications flow should show the app shell")
    public void openNotifications() { module = "Notifications"; testId = "NOTI-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should be visible in notifications flow"); }
}
