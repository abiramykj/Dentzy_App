package utilities;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

public class ConfigReader {
    private static final Properties properties = new Properties();
    private static final String projectRoot = findProjectRoot();

    static {
        Path configPath = Paths.get(projectRoot, "config", "config.properties");
        try (FileInputStream input = new FileInputStream(configPath.toFile())) {
            properties.load(input);
        } catch (IOException e) {
            throw new RuntimeException("Unable to load config.properties from " + configPath, e);
        }
    }

    public static String getProjectRoot() {
        return projectRoot;
    }

    public static String getProperty(String key) {
        return properties.getProperty(key);
    }

    public static int getInt(String key) {
        return Integer.parseInt(properties.getProperty(key));
    }

    private static String findProjectRoot() {
        Path current = Paths.get(System.getProperty("user.dir")).toAbsolutePath().normalize();
        if (Files.exists(current.resolve("pom.xml")) && Files.isDirectory(current.resolve("config")) && Files.isDirectory(current.resolve("src"))) {
            return current.toString();
        }
        Path candidate = current.resolve("automation");
        if (Files.exists(candidate.resolve("pom.xml")) && Files.isDirectory(candidate.resolve("config")) && Files.isDirectory(candidate.resolve("src"))) {
            return candidate.toString();
        }
        Path parent = current.getParent();
        if (parent != null) {
            Path parentCandidate = parent.resolve("automation");
            if (Files.exists(parentCandidate.resolve("pom.xml")) && Files.isDirectory(parentCandidate.resolve("config")) && Files.isDirectory(parentCandidate.resolve("src"))) {
                return parentCandidate.toString();
            }
        }
        return current.toString();
    }
}
