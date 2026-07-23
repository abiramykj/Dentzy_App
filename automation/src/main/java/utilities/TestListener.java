package utilities;

import base.BaseTest;
import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import org.openqa.selenium.WebDriver;
import org.testng.IAnnotationTransformer;
import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;
import org.testng.annotations.ITestAnnotation;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.atomic.AtomicBoolean;

public class TestListener implements ITestListener, IAnnotationTransformer {
    private static final long TEST_TIMEOUT_MS = 60_000L;
    private static final AtomicBoolean firstTestMethodLogged = new AtomicBoolean(false);
    private static ExtentReports extent;
    private static ThreadLocal<ExtentTest> test = new ThreadLocal<>();

    static {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        Path dir = Paths.get(ConfigReader.getProjectRoot(), "reports", "Extent_" + timestamp);
        dir.toFile().mkdirs();
        ExtentSparkReporter spark = new ExtentSparkReporter(dir.resolve("AutomationReport.html").toString());
        extent = new ExtentReports();
        extent.attachReporter(spark);
    }

    public void onTestStart(ITestResult result) {
        if (firstTestMethodLogged.compareAndSet(false, true)) {
            long start = System.currentTimeMillis();
            System.out.println("[START] Execute first test method");
            System.out.println("Timestamp: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS")));
            System.out.println("Elapsed time: " + (start - BaseTest.getSuiteStartMillis()) + " ms");
            result.setAttribute("firstTestMethodStart", start);
        }
        ExtentTest extentTest = extent.createTest(result.getMethod().getMethodName());
        test.set(extentTest);
        LoggerUtil.info("Starting test: " + result.getMethod().getMethodName());
    }

    public void onTestSuccess(ITestResult result) {
        test.get().log(Status.PASS, "Test Passed");
        finishFirstTestMethod(result);
        extent.flush();
    }

    public void onTestFailure(ITestResult result) {
        captureTimeoutDiagnosticsIfNeeded(result);
        test.get().log(Status.FAIL, result.getThrowable());
        finishFirstTestMethod(result);
        extent.flush();
    }

    public void onTestSkipped(ITestResult result) {
        test.get().log(Status.SKIP, "Test Skipped");
        finishFirstTestMethod(result);
        extent.flush();
    }

    public void onFinish(ITestContext context) {
        extent.flush();
    }

    @Override
    public void transform(ITestAnnotation annotation, Class testClass, Constructor testConstructor, Method testMethod) {
        if (annotation != null) {
            annotation.setTimeOut(TEST_TIMEOUT_MS);
        }
    }

    private void captureTimeoutDiagnosticsIfNeeded(ITestResult result) {
        Throwable throwable = result.getThrowable();
        if (!isTimeoutThrowable(throwable)) {
            return;
        }

        String qualifiedMethod = result.getMethod().getQualifiedName();
        LoggerUtil.error("Test timed out after 60 seconds: " + qualifiedMethod);

        Object instance = result.getInstance();
        if (!(instance instanceof BaseTest baseTest)) {
            LoggerUtil.warn("Timeout diagnostics skipped because the test instance is not BaseTest: " + qualifiedMethod);
            return;
        }

        WebDriver driver = baseTest.getDriver();
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String safeName = qualifiedMethod.replaceAll("[^a-zA-Z0-9._-]", "_");
        Path timeoutDir = Paths.get(ConfigReader.getProjectRoot(), "reports", "timeouts");
        try {
            Files.createDirectories(timeoutDir);
            Path diagnosticFile = timeoutDir.resolve(safeName + "_" + timestamp + ".txt");
            StringBuilder diagnostics = new StringBuilder();
            diagnostics.append("Test Method: ").append(qualifiedMethod).append(System.lineSeparator());
            diagnostics.append("Timestamp: ").append(timestamp).append(System.lineSeparator());
            diagnostics.append("Exception: ").append(throwable).append(System.lineSeparator()).append(System.lineSeparator());
            diagnostics.append("Stack Trace:").append(System.lineSeparator());
            StringWriter stackTrace = new StringWriter();
            throwable.printStackTrace(new PrintWriter(stackTrace));
            diagnostics.append(stackTrace);

            if (driver != null) {
                try {
                    String screenshotPath = ScreenshotUtil.captureScreenshot(driver, safeName, "timeout");
                    diagnostics.append(System.lineSeparator()).append("Screenshot: ").append(screenshotPath == null ? "" : screenshotPath);
                    LoggerUtil.info("Timeout screenshot captured for " + qualifiedMethod + ": " + screenshotPath);
                } catch (Exception screenshotError) {
                    diagnostics.append(System.lineSeparator()).append("Screenshot error: ").append(screenshotError.getMessage());
                }

                try {
                    String pageSource = driver.getPageSource();
                    Path pageSourceFile = timeoutDir.resolve(safeName + "_" + timestamp + ".xml");
                    Files.writeString(pageSourceFile, pageSource == null ? "" : pageSource, StandardCharsets.UTF_8);
                    diagnostics.append(System.lineSeparator()).append("Page Source File: ").append(pageSourceFile);
                    System.out.println("PAGE SOURCE for " + qualifiedMethod + ":");
                    System.out.println(pageSource);
                } catch (Exception pageSourceError) {
                    diagnostics.append(System.lineSeparator()).append("Page source error: ").append(pageSourceError.getMessage());
                    LoggerUtil.warn("Failed to capture page source for " + qualifiedMethod + ": " + pageSourceError.getMessage());
                }
            } else {
                diagnostics.append(System.lineSeparator()).append("Driver: null");
            }

            Files.writeString(diagnosticFile, diagnostics.toString(), StandardCharsets.UTF_8);
            LoggerUtil.info("Timeout diagnostics written to " + diagnosticFile);
        } catch (Exception diagnosticError) {
            LoggerUtil.error("Failed to write timeout diagnostics for " + qualifiedMethod + ": " + diagnosticError.getMessage());
        }
    }

    private boolean isTimeoutThrowable(Throwable throwable) {
        if (throwable == null) {
            return false;
        }
        Throwable current = throwable;
        while (current != null) {
            String className = current.getClass().getSimpleName().toLowerCase();
            String message = current.getMessage() == null ? "" : current.getMessage().toLowerCase();
            if (className.contains("timeout") || message.contains("timed out") || message.contains("timeout")) {
                return true;
            }
            current = current.getCause();
        }
        return false;
    }

    private void finishFirstTestMethod(ITestResult result) {
        Object startValue = result.getAttribute("firstTestMethodStart");
        if (startValue instanceof Long start) {
            System.out.println("[END] Execute first test method");
            System.out.println("Elapsed time: " + (System.currentTimeMillis() - start) + " ms");
        }
    }
}
