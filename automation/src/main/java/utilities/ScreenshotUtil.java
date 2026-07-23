package utilities;

import org.apache.commons.io.FileUtils;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ScreenshotUtil {
    public static String captureScreenshot(WebDriver driver, String testName, String status) {
        try {
            File source = ((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
            Path folder = Paths.get(ConfigReader.getProjectRoot(), "screenshots", status.toLowerCase());
            Files.createDirectories(folder);
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String fileName = testName.replaceAll("[^a-zA-Z0-9._-]", "_") + "_" + timestamp + ".png";
            Path target = folder.resolve(fileName);
            FileUtils.copyFile(source, target.toFile());
            return target.toString();
        } catch (IOException e) {
            LoggerUtil.error("Screenshot capture failed: " + e.getMessage());
            return "";
        }
    }
}
