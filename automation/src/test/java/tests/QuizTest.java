package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;

public class QuizTest extends BaseTest {
    @Test(priority = 1, description = "Quiz entry should see the app shell")
    public void openQuiz() { module = "Quiz"; testId = "QUIZ-001"; priority = "P1"; Assert.assertTrue(assertScreenContainsText("Dentzy"), "App shell should be visible from quiz entry"); }
}
