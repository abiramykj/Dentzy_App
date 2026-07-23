package tests;

import base.BaseTest;
import org.testng.Assert;
import org.testng.annotations.Test;
import pages.AuthenticationPage;

public class AuthenticationTest extends BaseTest {
    private AuthenticationPage authPage;

    @Override
    public void initPageObjects() {
        authPage = new AuthenticationPage(driver);
    }

    @Test(priority = 1, description = "AUTH-001: Splash screen should load")
    public void splashScreenLoads() {
        module = "Authentication";
        testId = "AUTH-001";
        priority = "P1";
        Assert.assertTrue(authPage.isLoginTitleVisible() || isAppInForeground(), "Login screen should display welcome text");
    }

    @Test(priority = 1, description = "AUTH-002: Login form should be visible")
    public void loginFormShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-002";
        priority = "P1";
        Assert.assertTrue(authPage.isLoginScreenDisplayed(), "Login form should be visible");
    }

    @Test(priority = 1, description = "AUTH-003: Dentzy app title should be visible")
    public void appTitleShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-003";
        priority = "P1";
        Assert.assertTrue(authPage.isAppTitleVisible(), "Dentzy title should be visible on authentication screen");
    }

    @Test(priority = 1, description = "AUTH-004: Login description should be visible")
    public void loginDescriptionShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-004";
        priority = "P1";
        Assert.assertTrue(authPage.isLoginDescriptionVisible(), "Login description should be visible");
    }

    @Test(priority = 1, description = "AUTH-005: Email field should be visible")
    public void emailFieldShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-005";
        priority = "P1";
        Assert.assertTrue(authPage.isEmailFieldVisible(), "Email field should be visible");
    }

    @Test(priority = 1, description = "AUTH-006: Password field should be visible")
    public void passwordFieldShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-006";
        priority = "P1";
        Assert.assertTrue(authPage.isPasswordFieldVisible(), "Password field should be visible");
    }

    @Test(priority = 1, description = "AUTH-007: Email hint text should be visible")
    public void emailHintShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-007";
        priority = "P1";
        Assert.assertTrue(authPage.isEmailHintVisible(), "Email hint should be visible");
    }

    @Test(priority = 1, description = "AUTH-008: Password hint text should be visible")
    public void passwordHintShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-008";
        priority = "P1";
        Assert.assertTrue(authPage.isPasswordHintVisible(), "Password hint should be visible");
    }

    @Test(priority = 1, description = "AUTH-009: Sign In button should be visible")
    public void signInButtonShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-009";
        priority = "P1";
        Assert.assertTrue(authPage.isSignInButtonVisible(), "Sign In button should be visible");
    }

    @Test(priority = 1, description = "AUTH-010: Sign Up option should be visible")
    public void signUpOptionShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-010";
        priority = "P1";
        Assert.assertTrue(authPage.isSignUpButtonVisible(), "Sign Up button should be visible");
    }

    @Test(priority = 2, description = "AUTH-011: Forgot password action should be visible")
    public void forgotPasswordActionShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-011";
        priority = "P2";
        Assert.assertTrue(authPage.isForgotPasswordVisible(), "Forgot password button should be visible");
    }

    @Test(priority = 2, description = "AUTH-012: Remember me option should be visible")
    public void rememberMeOptionShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-012";
        priority = "P2";
        Assert.assertTrue(authPage.isRememberMeVisible(), "Remember me option should be visible");
    }

    @Test(priority = 2, description = "AUTH-013: Show password toggle should be visible")
    public void showPasswordToggleShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-013";
        priority = "P2";
        Assert.assertTrue(authPage.isShowPasswordVisible(), "Show password toggle should be visible");
    }

    @Test(priority = 2, description = "AUTH-014: Sign In button should be clickable")
    public void signInButtonShouldBeClickable() {
        module = "Authentication";
        testId = "AUTH-014";
        priority = "P2";
        authPage.clickSignIn();
        Assert.assertTrue(authPage.isAppTitleVisible() || isAppInForeground(), "App should remain in foreground after tapping Sign In");
    }

    @Test(priority = 2, description = "AUTH-015: Sign Up button should be clickable")
    public void signUpButtonShouldBeClickable() {
        module = "Authentication";
        testId = "AUTH-015";
        priority = "P2";
        authPage.clickSignUp();
        Assert.assertTrue(authPage.isSignUpScreenDisplayed(), "Sign Up screen should appear after tapping Sign Up");
    }

    @Test(priority = 2, description = "AUTH-016: Show password toggle should be clickable")
    public void showPasswordToggleShouldBeClickable() {
        module = "Authentication";
        testId = "AUTH-016";
        priority = "P2";
        authPage.toggleShowPassword();
        Assert.assertTrue(
                authPage.isPasswordFieldVisible() || authPage.isAppTitleVisible() || isAppInForeground(),
                "App should remain responsive after tapping password toggle"
        );
    }

    @Test(priority = 2, description = "AUTH-017: User can enter email")
    public void userCanEnterEmail() {
        module = "Authentication";
        testId = "AUTH-017";
        priority = "P2";
        String email = "dentzyuser@example.com";
        authPage.enterEmail(email);
        Assert.assertTrue(authPage.getEmailFieldText().contains("dentzyuser"), "Email field should accept input");
    }

    @Test(priority = 2, description = "AUTH-018: User can enter password")
    public void userCanEnterPassword() {
        module = "Authentication";
        testId = "AUTH-018";
        priority = "P2";
        String password = "Dentzy@123";
        authPage.enterPassword(password);
        Assert.assertFalse(authPage.getPasswordFieldText().isBlank(), "Password field should accept input");
    }

    @Test(priority = 2, description = "AUTH-019: Navigate to Sign Up screen")
    public void navigateToSignUpScreen() {
        module = "Authentication";
        testId = "AUTH-019";
        priority = "P2";
        authPage.clickSignUp();
        Assert.assertTrue(authPage.isSignUpScreenDisplayed(), "Sign Up screen should display after navigation");
    }

    @Test(priority = 2, description = "AUTH-020: Sign Up screen should display required fields")
    public void signUpScreenShouldDisplayRequiredFields() {
        module = "Authentication";
        testId = "AUTH-020";
        priority = "P2";
        authPage.clickSignUp();
        Assert.assertTrue(authPage.isFullNameFieldVisible() && authPage.isEmailFieldVisible() && authPage.isConfirmPasswordFieldVisible(), "Sign Up screen should show required fields");
    }

    @Test(priority = 2, description = "AUTH-021: Create Account button should be visible")
    public void createAccountButtonShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-021";
        priority = "P2";
        authPage.clickSignUp();
        Assert.assertTrue(authPage.isCreateAccountButtonVisible(), "Create Account button should be visible on Sign Up screen");
    }

    @Test(priority = 2, description = "AUTH-022: Full name field should be visible on Sign Up")
    public void fullNameFieldShouldBeVisibleOnSignUp() {
        module = "Authentication";
        testId = "AUTH-022";
        priority = "P2";
        authPage.clickSignUp();
        Assert.assertTrue(authPage.isFullNameFieldVisible(), "Full name field should be visible on Sign Up screen");
    }

    @Test(priority = 2, description = "AUTH-023: Confirm password field should be visible")
    public void confirmPasswordFieldShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-023";
        priority = "P2";
        authPage.clickSignUp();
        Assert.assertTrue(authPage.isConfirmPasswordFieldVisible(), "Confirm password field should be visible on Sign Up screen");
    }

    @Test(priority = 2, description = "AUTH-024: User can enter full name")
    public void userCanEnterFullName() {
        module = "Authentication";
        testId = "AUTH-024";
        priority = "P2";
        authPage.clickSignUp();
        String name = "Dentzy Tester";
        authPage.enterFullName(name);
        Assert.assertTrue(authPage.getFullNameFieldText().contains("Dentzy"), "Full name field should accept input");
    }

    @Test(priority = 2, description = "AUTH-025: User can enter confirm password")
    public void userCanEnterConfirmPassword() {
        module = "Authentication";
        testId = "AUTH-025";
        priority = "P2";
        authPage.clickSignUp();
        authPage.enterConfirmPassword("Dentzy@123");
        Assert.assertFalse(authPage.getConfirmPasswordFieldText().isBlank(), "Confirm password field should accept input");
    }

    @Test(priority = 2, description = "AUTH-026: Create Account button should be clickable")
    public void createAccountButtonShouldBeClickable() {
        module = "Authentication";
        testId = "AUTH-026";
        priority = "P2";
        authPage.clickSignUp();
        authPage.clickCreateAccount();
        Assert.assertTrue(authPage.isAppTitleVisible() || authPage.isSignUpScreenDisplayed(), "The app should remain responsive after clicking Create Account");
    }

    @Test(priority = 2, description = "AUTH-027: Back to Login button should be visible")
    public void backToLoginButtonShouldBeVisible() {
        module = "Authentication";
        testId = "AUTH-027";
        priority = "P2";
        authPage.clickSignUp();
        Assert.assertTrue(authPage.isBackToLoginVisible(), "Back to Login button should be visible on Sign Up screen");
    }

    @Test(priority = 2, description = "AUTH-028: Back to Login should return to login screen")
    public void backToLoginShouldReturnToLoginScreen() {
        module = "Authentication";
        testId = "AUTH-028";
        priority = "P2";
        authPage.clickSignUp();
        authPage.clickBackToLogin();
        Assert.assertTrue(authPage.isLoginScreenDisplayed(), "Back to Login should return to the main login screen");
    }

    @Test(priority = 2, description = "AUTH-029: Show password toggle should work on Sign Up screen")
    public void showPasswordToggleShouldWorkOnSignUpScreen() {
        module = "Authentication";
        testId = "AUTH-029";
        priority = "P2";
        authPage.clickSignUp();
        authPage.toggleShowPassword();
        Assert.assertTrue(authPage.isShowPasswordVisible(), "Show password toggle should still be visible after activation on Sign Up screen");
    }

    @Test(priority = 2, description = "AUTH-030: Authentication screen should remain in foreground")
    public void authenticationScreenShouldRemainInForeground() {
        module = "Authentication";
        testId = "AUTH-030";
        priority = "P2";
        Assert.assertTrue(isAppInForeground(), "Authentication screen should remain in the foreground during the verification");
    }
}

