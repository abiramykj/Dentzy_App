package pages;

import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import utilities.WaitUtils;

import java.util.List;

public class AuthenticationPage {
    private final AndroidDriver driver;
    private final WaitUtils waitUtils;

    private final By dentzyTitle = By.xpath("//*[contains(@content-desc,'Dentzy') or contains(@text,'Dentzy')]");
    private final By welcomeBackTitle = By.xpath("//*[contains(@content-desc,'Welcome Back!') or contains(@text,'Welcome Back!')]");
    private final By loginDescription = By.xpath("//*[contains(@content-desc,'Manage your dental health smarter.') or contains(@text,'Manage your dental health smarter.')]");
    private final By emailField = By.xpath("//android.widget.EditText[@hint='Enter your email']");
    private final By passwordField = By.xpath("//android.widget.EditText[@hint='Enter your password']");
    private final By passwordFieldOnSignUp = By.xpath("//android.widget.EditText[@hint='Enter your password']");
    private final By confirmPasswordField = By.xpath("//android.widget.EditText[@hint='Confirm password']");
    private final By showPasswordToggle = By.xpath("//android.widget.Button[@content-desc='Show' or @text='Show']");
    private final By hidePasswordToggle = By.xpath("//android.widget.Button[@content-desc='Hide' or @text='Hide']");
    private final By rememberMeLabel = By.xpath("//*[contains(@content-desc,'Remember me') or contains(@text,'Remember me')]");
    private final By forgotPasswordLink = By.xpath("//android.widget.Button[@content-desc='Forgot password?' or @text='Forgot password?']");
    private final By signInButton = By.xpath("//android.widget.Button[@content-desc='Sign In' or @text='Sign In']");
    private final By signUpButton = By.xpath("//android.widget.Button[@content-desc='Sign Up' or @text='Sign Up']");
    private final By createAccountButton = By.xpath("//android.widget.Button[@content-desc='Create Account' or @text='Create Account']");
    private final By createAccountTitle = By.xpath("//*[contains(@content-desc,'Create Account') or contains(@text,'Create Account')]");
    private final By backToLoginButton = By.xpath("//android.widget.Button[@content-desc='Back to Login' or @text='Back to Login']");
    private final By fullNameField = By.xpath("//android.widget.EditText[@hint='Full name']");
    private final By confirmPasswordHint = By.xpath("//android.widget.EditText[@hint='Confirm password']");
    private final By emailHintText = By.xpath("//*[contains(@hint,'Enter your email') or contains(@text,'Enter your email') or contains(@content-desc,'Enter your email')]");
    private final By passwordHintText = By.xpath("//*[contains(@hint,'Enter your password') or contains(@text,'Enter your password') or contains(@content-desc,'Enter your password')]");

    public AuthenticationPage(AndroidDriver driver) {
        if (driver == null) {
            throw new IllegalArgumentException("AuthenticationPage requires a valid AndroidDriver but received null");
        }
        this.driver = driver;
        this.waitUtils = new WaitUtils(driver);
    }

    public boolean isLoginScreenDisplayed() {
        return isVisible(welcomeBackTitle) && isVisible(signInButton) && isVisible(emailField);
    }

    public boolean isSignInButtonVisible() {
        return isVisible(signInButton);
    }

    public boolean isSignUpButtonVisible() {
        return isVisible(signUpButton);
    }

    public boolean isEmailFieldVisible() {
        return isVisible(emailField);
    }

    public boolean isPasswordFieldVisible() {
        return isVisible(passwordField);
    }

    public boolean isShowPasswordVisible() {
        return isVisible(showPasswordToggle) || isVisible(hidePasswordToggle);
    }

    public boolean isRememberMeVisible() {
        return isVisible(rememberMeLabel);
    }

    public boolean isForgotPasswordVisible() {
        return isVisible(forgotPasswordLink);
    }

    public boolean isAppTitleVisible() {
        return isVisible(dentzyTitle);
    }

    public boolean isLoginTitleVisible() {
        return isVisible(welcomeBackTitle);
    }

    public boolean isLoginDescriptionVisible() {
        return isVisible(loginDescription);
    }

    public boolean isEmailHintVisible() {
        return isVisible(emailHintText);
    }

    public boolean isPasswordHintVisible() {
        return isVisible(passwordHintText);
    }

    public boolean isSignUpScreenDisplayed() {
        return isVisible(createAccountTitle) && isVisible(fullNameField) && isVisible(confirmPasswordField);
    }

    public boolean isFullNameFieldVisible() {
        return isVisible(fullNameField);
    }

    public boolean isConfirmPasswordFieldVisible() {
        return isVisible(confirmPasswordField);
    }

    public boolean isCreateAccountButtonVisible() {
        return isVisible(createAccountButton);
    }

    public boolean isBackToLoginVisible() {
        return isVisible(backToLoginButton);
    }

    public void clickSignUp() {
        waitUtils.waitForClickable(signUpButton).click();
    }

    public void clickSignIn() {
        waitUtils.waitForClickable(signInButton).click();
    }

    public void clickForgotPassword() {
        waitUtils.waitForClickable(forgotPasswordLink).click();
    }

    public void clickBackToLogin() {
        waitUtils.waitForClickable(backToLoginButton).click();
    }

    public void clickCreateAccount() {
        waitUtils.waitForClickable(createAccountButton).click();
    }

    public void toggleShowPassword() {
        waitUtils.waitForClickable(showPasswordToggle).click();
    }

    public void enterEmail(String email) {
        WebElement element = waitUtils.waitForVisibility(emailField);
        element.clear();
        element.sendKeys(email);
    }

    public void enterPassword(String password) {
        WebElement element = waitUtils.waitForVisibility(passwordField);
        element.clear();
        element.sendKeys(password);
    }

    public void enterConfirmPassword(String password) {
        WebElement element = waitUtils.waitForVisibility(confirmPasswordField);
        element.clear();
        element.sendKeys(password);
    }

    public void enterFullName(String name) {
        WebElement element = waitUtils.waitForVisibility(fullNameField);
        element.clear();
        element.sendKeys(name);
    }

    public String getEmailFieldText() {
        return getFieldText(emailField);
    }

    public String getPasswordFieldText() {
        return getFieldText(passwordField);
    }

    public String getFullNameFieldText() {
        return getFieldText(fullNameField);
    }

    public String getConfirmPasswordFieldText() {
        return getFieldText(confirmPasswordField);
    }

    public boolean isValidationMessageVisible(String text) {
        try {
            By validationLocator = By.xpath("//*[contains(@content-desc,'" + text + "') or contains(@text,'" + text + "')]");
            List<WebElement> elements = driver.findElements(validationLocator);
            return elements.stream().anyMatch(WebElement::isDisplayed);
        } catch (Exception e) {
            return false;
        }
    }

    private String getFieldText(By locator) {
        try {
            WebElement element = waitUtils.waitForVisibility(locator);
            String value = element.getAttribute("text");
            return value == null ? "" : value.trim();
        } catch (Exception e) {
            return "";
        }
    }

    private boolean isVisible(By locator) {
        try {
            return waitUtils.isVisible(locator);
        } catch (Exception e) {
            return false;
        }
    }
}
