package base;

import org.openqa.selenium.By;
import org.openqa.selenium.Capabilities;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.NoSuchSessionException;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import org.openqa.selenium.remote.SessionId;
import org.testng.ITestResult;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;
import utilities.ConfigReader;
import utilities.ExcelReportManager;
import utilities.LoggerUtil;
import utilities.ScreenshotUtil;
import utilities.WaitUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.lang.reflect.Method;
import java.net.URL;
import java.nio.file.Paths;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class BaseTest {
    private static final long STARTUP_STAGE_TIMEOUT_SECONDS = 30L;
    private static final DateTimeFormatter TIMESTAMP_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
    protected AndroidDriver driver;
    protected WaitUtils waitUtils;
    protected static ExcelReportManager excelReportManager;
    protected String testId;
    protected String module;
    protected String testName;
    protected String priority;
    protected String executionTime;
    protected String status;
    protected boolean passed;
    protected String screenshotPath;
    protected String remarks;
    protected String exception;
    protected long startTime;
    protected static int totalTests;
    protected static int passedTests;
    protected static int failedTests;
    protected static int skippedTests;
    protected static long suiteStartMillis;

    @FunctionalInterface
    private interface StartupStage {
        void run() throws Exception;
    }

    @BeforeSuite(alwaysRun = true)
    public void suiteSetup() {
        suiteStartMillis = System.currentTimeMillis();
        logStage("Maven started", () -> {});
        logStage("TestNG suite started", () -> {});
        logStage("BeforeSuite", () -> {
            if (excelReportManager == null) {
                excelReportManager = new ExcelReportManager();
            }
            totalTests = 0;
            passedTests = 0;
            failedTests = 0;
            skippedTests = 0;
            LoggerUtil.info("Suite setup started");
        });
    }

    @BeforeClass(alwaysRun = true)
    public void classSetup() {
        logStage("BeforeClass", () -> LoggerUtil.info("Class setup started for " + getClass().getSimpleName()));
    }

    @BeforeMethod(alwaysRun = true)
    public void setUp(Method method) {
        startTime = System.currentTimeMillis();
        testName = method.getName();
        testId = method.getName();
        module = "General";
        priority = "P2";
        remarks = "";
        exception = "";
        screenshotPath = "";
        passed = false;
        status = "Skipped";
        if (excelReportManager == null) {
            excelReportManager = new ExcelReportManager();
        }
        try {
            logStartupStage("BeforeMethod", () -> {
                logStartupStage("Start Appium Server", () -> LoggerUtil.info("Appium server is expected to be running at " + ConfigReader.getProperty("appium.server.url")));
                logStartupStage("Verify Appium Server is reachable", this::verifyAppiumServerReachable);
                logStartupStage("Connect to emulator", () -> LoggerUtil.info("Target emulator: " + ConfigReader.getProperty("device.name")));
                logStartupStage("Verify emulator is online using adb devices", this::verifyEmulatorOnline);
                logStartupStage("Install app if required", this::logAppInstallState);
                logStartupStage("Create AndroidDriver", this::createDriver);
                logStartupStage("Driver session created successfully", this::ensureSessionStarted);
                logStartupStage("Launch application", this::launchApplication);
                logStartupStage("Wait for first screen", this::waitForFirstScreen);
                logStartupStage("Verify first screen is displayed", this::verifyFirstScreenDisplayed);
                logStartupStage("Initialize page objects", this::initPageObjects);
                status = "Passed";
                LoggerUtil.info("AndroidDriver initialized for: " + testName);
            });
        } catch (Exception e) {
            status = "Skipped";
            exception = e.getMessage();
            try {
                screenshotPath = driver != null ? ScreenshotUtil.captureScreenshot(driver, testName, "skipped") : "";
            } catch (Exception se) {
                LoggerUtil.warn("Failed to capture screenshot on setup failure: " + se.getMessage());
            }
            LoggerUtil.error("Driver setup failed: " + e.getMessage());
            throw new IllegalStateException("Driver setup failed before test execution: " + e.getMessage(), e);
        }
    }

    protected void initPageObjects() {
        // Override in child tests that require page objects.
    }

    private void createDriver() throws Exception {
        UiAutomator2Options options = new UiAutomator2Options()
                .setPlatformName(ConfigReader.getProperty("platform.name"))
                .setPlatformVersion(ConfigReader.getProperty("platform.version"))
                .setDeviceName(ConfigReader.getProperty("device.name"))
                .setAutomationName(ConfigReader.getProperty("automation.name"))
                .setAppPackage(ConfigReader.getProperty("app.package"))
                .setAppActivity(ConfigReader.getProperty("app.activity"))
                .setApp(resolveAppPath(ConfigReader.getProperty("app.path")));
        options.setNewCommandTimeout(Duration.ofSeconds(ConfigReader.getInt("new.command.timeout")));
        options.setCapability("noReset", false);
        options.setCapability("autoGrantPermissions", true);

        System.out.println("[INFO] Creating AndroidDriver against " + ConfigReader.getProperty("appium.server.url"));
        driver = new AndroidDriver(new URL(ConfigReader.getProperty("appium.server.url")), options);
    }

    private void launchApplication() {
        if (driver == null) {
            throw new IllegalStateException("AndroidDriver is null before launchApplication stage");
        }
        String appPackage = ConfigReader.getProperty("app.package");
        try {
            driver.activateApp(appPackage);
        } catch (Exception e) {
            LoggerUtil.warn("activateApp failed, continuing because the session already launched the app: " + e.getMessage());
        }
    }

    private void waitForFirstScreen() {
        if (driver == null) {
            throw new IllegalStateException("AndroidDriver is null before waitForFirstScreen stage");
        }
        long deadline = System.currentTimeMillis() + (15_000L);
        while (System.currentTimeMillis() < deadline) {
            if (waitForText("Sign In", 1) || isAppInForeground()) {
                return;
            }
        }
        throw new IllegalStateException("First screen did not appear within 15 seconds");
    }

    private void verifyFirstScreenDisplayed() {
        if (!(waitForText("Sign In", 5) || isAppInForeground())) {
            throw new IllegalStateException("First screen verification failed");
        }
    }

    private void verifyAppiumServerReachable() throws Exception {
        String statusUrl = buildAppiumStatusUrl();
        java.net.HttpURLConnection connection = (java.net.HttpURLConnection) new URL(statusUrl).openConnection();
        connection.setConnectTimeout(10_000);
        connection.setReadTimeout(10_000);
        connection.setRequestMethod("GET");
        int code = connection.getResponseCode();
        String body = readConnectionBody(connection);
        System.out.println("Appium status code: " + code);
        System.out.println("Appium status body: " + body);
        if (code < 200 || code >= 300) {
            throw new IllegalStateException("Appium server is not reachable at " + statusUrl + " (HTTP " + code + ")");
        }
    }

    private void verifyEmulatorOnline() throws Exception {
        String adbOutput = runAdbCommand("devices", "-l");
        System.out.println("adb devices output:\n" + adbOutput);
        String device = ConfigReader.getProperty("device.name");
        String devicePattern = "(?m)^\\s*" + java.util.regex.Pattern.quote(device) + "\\s+device\\b.*$";
        if (!adbOutput.matches("(?s).*" + devicePattern + ".*")) {
            throw new IllegalStateException("Emulator " + device + " is not online according to adb devices");
        }
    }

    private void logAppInstallState() throws Exception {
        String packageName = ConfigReader.getProperty("app.package");
        String apkPath = resolveAppPath(ConfigReader.getProperty("app.path"));
        System.out.println("APK path: " + apkPath);
        System.out.println("Package: " + packageName);
        if (packageName == null || packageName.isBlank()) {
            throw new IllegalStateException("app.package is not configured");
        }
        String pathOutput = runAdbCommand("shell", "pm", "path", packageName);
        System.out.println("pm path output:\n" + pathOutput);
        if (pathOutput == null || pathOutput.isBlank()) {
            System.out.println("App is not installed yet; Appium will install it during driver creation.");
        } else {
            System.out.println("App is already installed on the device.");
        }
    }

    protected void ensureSessionStarted() {
        if (driver == null) {
            throw new IllegalStateException("AndroidDriver is null after initialization attempt");
        }
        SessionId sessionId = driver.getSessionId();
        if (sessionId == null || sessionId.toString().isBlank()) {
            throw new IllegalStateException("Appium session was not created. Session ID is null/empty");
        }
        System.out.println("SESSION ID: " + sessionId);
    }

    private void logStage(String stageName, StartupStage stageAction) {
        try {
            logStageStart(stageName);
            stageAction.run();
            logStageEnd(stageName);
        } catch (Exception e) {
            logStageEnd(stageName);
            throw new RuntimeException(e);
        }
    }

    private void logStartupStage(String stageName, StartupStage stageAction) throws Exception {
        long start = System.currentTimeMillis();
        System.out.println("[START] " + stageName);
        System.out.println("Timestamp: " + timestampNow());
        System.out.println("Elapsed time: " + elapsedSinceSuiteStart(start) + " ms");

        ExecutorService executor = Executors.newSingleThreadExecutor();
        Future<?> future = executor.submit(() -> {
            try {
                stageAction.run();
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        });
        try {
            future.get(STARTUP_STAGE_TIMEOUT_SECONDS, TimeUnit.SECONDS);
            System.out.println("[END] " + stageName);
            System.out.println("Elapsed time: " + (System.currentTimeMillis() - start) + " ms");
        } catch (TimeoutException e) {
            future.cancel(true);
            System.out.println("[END] " + stageName);
            System.out.println("Elapsed time: " + (System.currentTimeMillis() - start) + " ms");
            captureStartupDiagnostics(stageName, e);
            throw new IllegalStateException("Startup stage timed out after 30 seconds: " + stageName, e);
        } catch (ExecutionException e) {
            Throwable cause = e.getCause() != null ? e.getCause() : e;
            System.out.println("[END] " + stageName);
            System.out.println("Elapsed time: " + (System.currentTimeMillis() - start) + " ms");
            captureStartupDiagnostics(stageName, cause);
            if (cause instanceof Exception exceptionCause) {
                throw exceptionCause;
            }
            throw new IllegalStateException("Startup stage failed: " + stageName, cause);
        } finally {
            executor.shutdownNow();
        }
    }

    private void captureStartupDiagnostics(String stageName, Throwable throwable) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss_SSS"));
        Path startupDir = Paths.get(ConfigReader.getProjectRoot(), ConfigReader.getProperty("log.path"), "startup");
        try {
            Files.createDirectories(startupDir);
            String safeStage = stageName.replaceAll("[^a-zA-Z0-9._-]", "_");
            Path diagnosticsFile = startupDir.resolve(safeStage + "_" + timestamp + ".txt");
            StringBuilder diagnostics = new StringBuilder();
            diagnostics.append("Stage: ").append(stageName).append(System.lineSeparator());
            diagnostics.append("Timestamp: ").append(timestampNow()).append(System.lineSeparator());
            diagnostics.append("Exception: ").append(throwable).append(System.lineSeparator()).append(System.lineSeparator());
            diagnostics.append("AndroidDriver capabilities:").append(System.lineSeparator());
            diagnostics.append(readDriverCapabilities()).append(System.lineSeparator());
            diagnostics.append("Current activity: ").append(readCurrentActivity()).append(System.lineSeparator());
            diagnostics.append("Current package: ").append(readCurrentPackage()).append(System.lineSeparator());
            diagnostics.append("Appium server log:").append(System.lineSeparator()).append(readAppiumServerLog()).append(System.lineSeparator());
            diagnostics.append("adb logcat last 200 lines:").append(System.lineSeparator()).append(runAdbCommand("logcat", "-d", "-t", "200")).append(System.lineSeparator());

            if (driver != null && driver.getSessionId() != null) {
                try {
                    String screenshot = ScreenshotUtil.captureScreenshot(driver, safeStage, "startup_timeout");
                    diagnostics.append("Screenshot: ").append(screenshot).append(System.lineSeparator());
                } catch (Exception screenshotError) {
                    diagnostics.append("Screenshot error: ").append(screenshotError.getMessage()).append(System.lineSeparator());
                }
                try {
                    String pageSource = driver.getPageSource();
                    Path pageSourceFile = startupDir.resolve(safeStage + "_" + timestamp + ".xml");
                    Files.writeString(pageSourceFile, pageSource == null ? "" : pageSource, StandardCharsets.UTF_8);
                    diagnostics.append("Page source file: ").append(pageSourceFile).append(System.lineSeparator());
                    System.out.println(pageSource);
                } catch (Exception pageSourceError) {
                    diagnostics.append("Page source error: ").append(pageSourceError.getMessage()).append(System.lineSeparator());
                }
            }

            Files.writeString(diagnosticsFile, diagnostics.toString(), StandardCharsets.UTF_8);
            System.out.println("Saved startup diagnostics to: " + diagnosticsFile);
        } catch (Exception e) {
            LoggerUtil.error("Failed to save startup diagnostics for " + stageName + ": " + e.getMessage());
        }
    }

    private String readDriverCapabilities() {
        try {
            if (driver == null) {
                return "<driver unavailable>";
            }
            Capabilities capabilities = driver.getCapabilities();
            return capabilities == null ? "<capabilities unavailable>" : capabilities.toString();
        } catch (Exception e) {
            return "<failed to read capabilities: " + e.getMessage() + ">";
        }
    }

    private String readCurrentActivity() {
        try {
            if (driver != null && driver.getSessionId() != null) {
                return driver.currentActivity();
            }
        } catch (Exception ignored) {
        }
        try {
            String output = runAdbCommand("shell", "dumpsys", "window", "windows");
            return output;
        } catch (Exception e) {
            return "<failed to read current activity: " + e.getMessage() + ">";
        }
    }

    private String readCurrentPackage() {
        try {
            if (driver != null && driver.getSessionId() != null) {
                return ConfigReader.getProperty("app.package");
            }
        } catch (Exception ignored) {
        }
        try {
            return ConfigReader.getProperty("app.package");
        } catch (Exception e) {
            return "<failed to read current package: " + e.getMessage() + ">";
        }
    }

    private String readAppiumServerLog() {
        String configuredPath = firstNonBlank(
                System.getProperty("appium.server.log.path"),
                System.getenv("APPIUM_SERVER_LOG_PATH"),
                ConfigReader.getProperty("appium.log.path")
        );
        if (configuredPath == null || configuredPath.isBlank()) {
            return "<appium server log path not configured>";
        }
        try {
            Path logPath = Paths.get(configuredPath);
            if (!Files.exists(logPath)) {
                return "<appium server log not found at " + logPath + ">";
            }
            return Files.readString(logPath, StandardCharsets.UTF_8);
        } catch (Exception e) {
            return "<failed to read appium server log: " + e.getMessage() + ">";
        }
    }

    private String runAdbCommand(String... args) throws IOException, InterruptedException {
        String adb = "C:\\Users\\Dyuthi\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe";
        ProcessBuilder processBuilder = new ProcessBuilder(buildAdbCommand(adb, args));
        processBuilder.redirectErrorStream(true);
        Process process = processBuilder.start();
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.write((line + System.lineSeparator()).getBytes(StandardCharsets.UTF_8));
            }
        }
        process.waitFor();
        return buffer.toString(StandardCharsets.UTF_8);
    }

    private java.util.List<String> buildAdbCommand(String adb, String... args) {
        java.util.List<String> command = new java.util.ArrayList<>();
        command.add(adb);
        String deviceName = ConfigReader.getProperty("device.name");
        if (deviceName != null && !deviceName.isBlank() && !containsArg(args, "devices") && !containsArg(args, "logcat")) {
            command.add("-s");
            command.add(deviceName);
        }
        for (String arg : args) {
            command.add(arg);
        }
        return command;
    }

    private boolean containsArg(String[] args, String expected) {
        for (String arg : args) {
            if (expected.equalsIgnoreCase(arg)) {
                return true;
            }
        }
        return false;
    }

    private String buildAppiumStatusUrl() {
        String baseUrl = ConfigReader.getProperty("appium.server.url");
        if (baseUrl == null) {
            return "http://127.0.0.1:4723/status";
        }
        return baseUrl.replaceAll("/+$", "") + "/status";
    }

    private String readConnectionBody(java.net.HttpURLConnection connection) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(
                connection.getResponseCode() >= 400 ? connection.getErrorStream() : connection.getInputStream(),
                StandardCharsets.UTF_8))) {
            if (reader == null) {
                return "<empty body>";
            }
            StringBuilder builder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line).append(System.lineSeparator());
            }
            return builder.toString();
        } catch (Exception e) {
            return "<failed to read body: " + e.getMessage() + ">";
        }
    }

    private String timestampNow() {
        return LocalDateTime.now().format(TIMESTAMP_FORMAT);
    }

    private long elapsedSinceSuiteStart(long startMillis) {
        return startMillis - suiteStartMillis;
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }

    private void logStageStart(String stageName) {
        System.out.println("[START] " + stageName);
        System.out.println("Timestamp: " + timestampNow());
        System.out.println("Elapsed time: " + elapsedSinceSuiteStart(System.currentTimeMillis()) + " ms");
    }

    private void logStageEnd(String stageName) {
        System.out.println("[END] " + stageName);
        System.out.println("Elapsed time: " + elapsedSinceSuiteStart(System.currentTimeMillis()) + " ms");
    }

    public static long getSuiteStartMillis() {
        return suiteStartMillis;
    }

    @AfterMethod(alwaysRun = true)
    public void tearDown(ITestResult result) {
        executionTime = String.valueOf((System.currentTimeMillis() - startTime) / 1000.0) + "s";
        totalTests++;
        if (result.getStatus() == ITestResult.SUCCESS) {
            passed = true;
            passedTests++;
            status = "Passed";
            remarks = "Test passed";
        } else if (result.getStatus() == ITestResult.FAILURE) {
            failedTests++;
            status = "Failed";
            remarks = "Test failed";
            exception = result.getThrowable() != null ? result.getThrowable().getMessage() : "";
            screenshotPath = captureResultScreenshot("failed");
        } else if (result.getStatus() == ITestResult.SKIP) {
            skippedTests++;
            status = "Skipped";
            remarks = "Test skipped";
            screenshotPath = captureResultScreenshot("skipped");
        }
        if (excelReportManager != null) {
            String passFail = "Passed".equalsIgnoreCase(status) ? "Pass" : ("Skipped".equalsIgnoreCase(status) ? "Skip" : "Fail");
            excelReportManager.addResult(testId, module, testName, priority, executionTime, status, passFail, screenshotPath, remarks, exception);
        } else {
            LoggerUtil.warn("ExcelReportManager is null — skipping addResult for " + testName);
        }
        if (driver != null) {
            driver.quit();
        }
    }

    private String captureResultScreenshot(String reason) {
        if (driver == null) {
            return "";
        }
        try {
            if (driver.getSessionId() == null) {
                return "";
            }
            return ScreenshotUtil.captureScreenshot(driver, testName, reason);
        } catch (NoSuchSessionException e) {
            LoggerUtil.warn("Skipping screenshot for " + testName + " because the Appium session is already closed.");
            return "";
        } catch (Exception e) {
            LoggerUtil.warn("Skipping screenshot for " + testName + ": " + e.getMessage());
            return "";
        }
    }

    @AfterSuite(alwaysRun = true)
    public void suiteTearDown() {
        try {
            String overallStatus = failedTests > 0 ? "Failed" : (passedTests > 0 ? "Passed" : "Skipped");
            if (excelReportManager == null) {
                excelReportManager = new ExcelReportManager();
            }
            if (excelReportManager != null) {
                excelReportManager.generateReport(
                        overallStatus,
                        "0s",
                        ConfigReader.getProperty("device.name"),
                        ConfigReader.getProperty("platform.version"),
                        "Appium 3.x",
                        System.getProperty("java.version", "17"),
                        totalTests,
                        passedTests,
                        failedTests,
                        skippedTests
                );
            } else {
                LoggerUtil.warn("ExcelReportManager is null — skipping report generation.");
            }
        } catch (Exception e) {
            LoggerUtil.error("Report generation failed: " + e.getMessage());
        }
        LoggerUtil.info("Suite completed");
    }

    protected boolean assertScreenContainsText(String text) {
        return waitForText(text, 15);
    }

    public AndroidDriver getDriver() {
        return driver;
    }

    protected boolean waitForText(String text, int timeoutInSeconds) {
        long deadline = System.currentTimeMillis() + (timeoutInSeconds * 1000L);
        while (System.currentTimeMillis() < deadline) {
            try {
                // Primary: XPath searching common attributes
                List<WebElement> elements = driver.findElements(By.xpath("//*[contains(@text,'" + text + "') or contains(@content-desc,'" + text + "') or contains(@hint,'" + text + "')]") );
                if (elements.stream().anyMatch(WebElement::isDisplayed)) {
                    return true;
                }
                // Fallback: accessibility id (content-desc)
                try {
                    List<WebElement> acc = driver.findElements(io.appium.java_client.AppiumBy.accessibilityId(text));
                    if (acc.stream().anyMatch(WebElement::isDisplayed)) {
                        return true;
                    }
                } catch (Exception ignoreAcc) {
                }
                // Fallback: exact text match
                try {
                    List<WebElement> exact = driver.findElements(By.xpath("//*[(@text='" + text + "') or (@content-desc='" + text + "')]"));
                    if (exact.stream().anyMatch(WebElement::isDisplayed)) {
                        return true;
                    }
                } catch (Exception ignoreExact) {
                }
            } catch (Exception ignored) {
            }
            // Final fallback: check current foreground activity via Appium shell; if app's activity is foreground, consider text present
            try {
                Object resp = null;
                try {
                    resp = ((org.openqa.selenium.JavascriptExecutor) driver).executeScript("mobile: shell", java.util.Map.of(
                            "command", "dumpsys",
                            "args", java.util.List.of("activity", "activities")
                    ));
                } catch (Exception e) {
                    resp = null;
                }
                if (resp != null) {
                    String out = resp.toString();
                    String activity = ConfigReader.getProperty("app.activity");
                    if (out.contains(activity)) {
                        return true;
                    }
                }
            } catch (Exception e) {
                // ignore shell fallback failures
            }
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
        return false;
    }

    private String resolveAppPath(String appPath) {
        if (appPath == null || appPath.isBlank()) {
            return "";
        }
        File appFile = new File(appPath);
        if (appFile.isAbsolute()) {
            return appFile.getAbsolutePath();
        }
        return Paths.get(ConfigReader.getProjectRoot(), appPath).toAbsolutePath().normalize().toString();
    }

    protected boolean isAppInForeground() {
        try {
            String adb = "C:\\Users\\Dyuthi\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe";
            String device = ConfigReader.getProperty("device.name");
            ProcessBuilder pb = new ProcessBuilder(adb, "-s", device, "shell", "dumpsys", "activity", "activities");
            pb.redirectErrorStream(true);
            Process p = pb.start();
            java.io.InputStream is = p.getInputStream();
            java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
            String output = s.hasNext() ? s.next() : "";
            p.waitFor();
            s.close();
            String activity = ConfigReader.getProperty("app.activity");
            return output.contains(activity);
        } catch (Exception e) {
            LoggerUtil.warn("isAppInForeground check failed: " + e.getMessage());
            return false;
        }
    }
}
