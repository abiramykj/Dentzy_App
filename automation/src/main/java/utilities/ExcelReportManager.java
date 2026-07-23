package utilities;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xddf.usermodel.chart.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ExcelReportManager {
    private final String reportPath;
    private final List<Map<String, String>> results = new ArrayList<>();
    private final Map<String, Map<String, Integer>> moduleStats = new LinkedHashMap<>();

    public ExcelReportManager() {
        Path basePath = Paths.get(ConfigReader.getProjectRoot(), "reports");
        this.reportPath = basePath.resolve(ConfigReader.getProperty("excel.report.name")).toString();
        try {
            Files.createDirectories(basePath);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public void addResult(String testId, String module, String testName, String priority, String executionTime,
                          String status, String passFail, String screenshotPath, String remarks, String exception) {
        Map<String, String> row = new LinkedHashMap<>();
        row.put("Test ID", testId);
        row.put("Module", module);
        row.put("Test Case Name", testName);
        row.put("Priority", priority);
        row.put("Execution Time", executionTime);
        row.put("Status", status);
        row.put("Pass/Fail", passFail);
        row.put("Screenshot Path", screenshotPath);
        row.put("Remarks", remarks);
        row.put("Exception", exception);
        results.add(row);
        moduleStats.computeIfAbsent(module, k -> new LinkedHashMap<>());
        Map<String, Integer> stats = moduleStats.get(module);
        stats.put("Total", stats.getOrDefault("Total", 0) + 1);
        if ("Pass".equalsIgnoreCase(passFail) || "Passed".equalsIgnoreCase(status)) {
            stats.put("Pass", stats.getOrDefault("Pass", 0) + 1);
        } else if ("Fail".equalsIgnoreCase(passFail) || "Failed".equalsIgnoreCase(status)) {
            stats.put("Fail", stats.getOrDefault("Fail", 0) + 1);
        } else if ("Skip".equalsIgnoreCase(passFail) || "Skipped".equalsIgnoreCase(status)) {
            stats.put("Skip", stats.getOrDefault("Skip", 0) + 1);
        }
    }

    public void generateReport(String overallStatus, String executionTime, String deviceName, String androidVersion,
                               String appiumVersion, String javaVersion, int total, int passed, int failed, int skipped) {
        try (Workbook workbook = new XSSFWorkbook()) {
            createDashboardSheet(workbook, overallStatus, executionTime, deviceName, androidVersion, appiumVersion, javaVersion, total, passed, failed, skipped);
            createResultsSheet(workbook);
            createFailedSheet(workbook);
            createSummarySheet(workbook, total, passed, failed, skipped);
            createCharts(workbook, passed, failed, skipped);
            try (FileOutputStream out = new FileOutputStream(reportPath)) {
                workbook.write(out);
            }
            System.out.println("Execution Completed Successfully");
            System.out.println("Total Test Cases: " + total);
            System.out.println("Passed: " + passed);
            System.out.println("Failed: " + failed);
            System.out.println("Skipped: " + skipped);
            System.out.println("Excel Report Location: " + reportPath);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void createDashboardSheet(Workbook workbook, String overallStatus, String executionTime, String deviceName,
                                      String androidVersion, String appiumVersion, String javaVersion,
                                      int total, int passed, int failed, int skipped) {
        Sheet sheet = workbook.createSheet("Dashboard");
        Row header = sheet.createRow(0);
        String[] headers = {"Project Name", "Dentzy Automation", "Execution Date", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")), "Execution Time", executionTime};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle(workbook));
        }
        Object[][] data = {
                {"Device Name", deviceName},
                {"Android Version", androidVersion},
                {"Appium Version", appiumVersion},
                {"Java Version", javaVersion},
                {"Total Test Cases", total},
                {"Passed", passed},
                {"Failed", failed},
                {"Skipped", skipped},
                {"Pass %", formatPercent(passed, total)},
                {"Fail %", formatPercent(failed, total)},
                {"Skip %", formatPercent(skipped, total)},
                {"Overall Status", overallStatus}
        };
        int rowIndex = 2;
        for (Object[] rowData : data) {
            Row row = sheet.createRow(rowIndex++);
            row.createCell(0).setCellValue(rowData[0].toString());
            row.createCell(1).setCellValue(rowData[1].toString());
        }
        sheet.createFreezePane(0, 1);
        styleSheet(sheet);
        Cell statusCell = sheet.getRow(13).getCell(1);
        statusCell.setCellValue(overallStatus);
        if ("Passed".equalsIgnoreCase(overallStatus)) {
            statusCell.setCellStyle(greenStyle(workbook));
        } else if ("Failed".equalsIgnoreCase(overallStatus)) {
            statusCell.setCellStyle(redStyle(workbook));
        } else {
            statusCell.setCellStyle(yellowStyle(workbook));
        }
    }

    private void createResultsSheet(Workbook workbook) {
        Sheet sheet = workbook.createSheet("Test Case Results");
        String[] headers = {"Test ID", "Module", "Test Case Name", "Priority", "Execution Time", "Status", "Pass/Fail", "Screenshot Path", "Remarks", "Exception"};
        Row header = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle(workbook));
        }
        int rowIndex = 1;
        for (Map<String, String> result : results) {
            Row row = sheet.createRow(rowIndex++);
            row.createCell(0).setCellValue(result.get("Test ID"));
            row.createCell(1).setCellValue(result.get("Module"));
            row.createCell(2).setCellValue(result.get("Test Case Name"));
            row.createCell(3).setCellValue(result.get("Priority"));
            row.createCell(4).setCellValue(result.get("Execution Time"));
            row.createCell(5).setCellValue(result.get("Status"));
            row.createCell(6).setCellValue(result.get("Pass/Fail"));
            row.createCell(7).setCellValue(result.get("Screenshot Path"));
            row.createCell(8).setCellValue(result.get("Remarks"));
            row.createCell(9).setCellValue(result.get("Exception"));
            String status = result.get("Status");
            if ("Pass".equalsIgnoreCase(status)) {
                for (int i = 0; i < 10; i++) row.getCell(i).setCellStyle(greenStyle(workbook));
            } else if ("Fail".equalsIgnoreCase(status)) {
                for (int i = 0; i < 10; i++) row.getCell(i).setCellStyle(redStyle(workbook));
            } else {
                for (int i = 0; i < 10; i++) row.getCell(i).setCellStyle(yellowStyle(workbook));
            }
        }
        styleSheet(sheet);
    }

    private void createFailedSheet(Workbook workbook) {
        Sheet sheet = workbook.createSheet("Failed Test Cases");
        String[] headers = {"Test ID", "Module", "Test Name", "Failure Reason", "Screenshot", "Exception", "Timestamp"};
        Row header = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle(workbook));
        }
        int rowIndex = 1;
        for (Map<String, String> result : results) {
            String status = result.get("Status");
            String passFail = result.get("Pass/Fail");
            if (!"Fail".equalsIgnoreCase(status) && !"Failed".equalsIgnoreCase(status) && !"Fail".equalsIgnoreCase(passFail)) continue;
            Row row = sheet.createRow(rowIndex++);
            row.createCell(0).setCellValue(result.get("Test ID"));
            row.createCell(1).setCellValue(result.get("Module"));
            row.createCell(2).setCellValue(result.get("Test Case Name"));
            row.createCell(3).setCellValue(result.get("Exception"));
            row.createCell(4).setCellValue(result.get("Screenshot Path"));
            row.createCell(5).setCellValue(result.get("Exception"));
            row.createCell(6).setCellValue(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        styleSheet(sheet);
    }

    private void createSummarySheet(Workbook workbook, int total, int passed, int failed, int skipped) {
        Sheet sheet = workbook.createSheet("Summary");
        String[] headers = {"Module", "Total", "Pass", "Fail", "Skip", "Pass %"};
        Row header = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = header.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle(workbook));
        }
        int rowIndex = 1;
        List<String> modules = new ArrayList<>(moduleStats.keySet());
        for (String module : modules) {
            Map<String, Integer> stats = moduleStats.get(module);
            Row row = sheet.createRow(rowIndex++);
            row.createCell(0).setCellValue(module);
            row.createCell(1).setCellValue(stats.getOrDefault("Total", 0));
            row.createCell(2).setCellValue(stats.getOrDefault("Pass", 0));
            row.createCell(3).setCellValue(stats.getOrDefault("Fail", 0));
            row.createCell(4).setCellValue(stats.getOrDefault("Skip", 0));
            row.createCell(5).setCellValue(formatPercent(stats.getOrDefault("Pass", 0), stats.getOrDefault("Total", 1)));
        }
        styleSheet(sheet);
    }

    private void createCharts(Workbook workbook, int passed, int failed, int skipped) {
        Sheet sheet = workbook.createSheet("Charts");
        Row row1 = sheet.createRow(0);
        row1.createCell(0).setCellValue("Status");
        row1.createCell(1).setCellValue("Count");
        Row row2 = sheet.createRow(1); row2.createCell(0).setCellValue("Passed"); row2.createCell(1).setCellValue(passed);
        Row row3 = sheet.createRow(2); row3.createCell(0).setCellValue("Failed"); row3.createCell(1).setCellValue(failed);
        Row row4 = sheet.createRow(3); row4.createCell(0).setCellValue("Skipped"); row4.createCell(1).setCellValue(skipped);
        styleSheet(sheet);
    }

    private CellStyle headerStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        Font font = workbook.createFont();
        font.setBold(true); font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle greenStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.THIN); style.setBorderBottom(BorderStyle.THIN); style.setBorderLeft(BorderStyle.THIN); style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle redStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setFillForegroundColor(IndexedColors.ROSE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.THIN); style.setBorderBottom(BorderStyle.THIN); style.setBorderLeft(BorderStyle.THIN); style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private CellStyle yellowStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        style.setFillForegroundColor(IndexedColors.YELLOW.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.THIN); style.setBorderBottom(BorderStyle.THIN); style.setBorderLeft(BorderStyle.THIN); style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private void styleSheet(Sheet sheet) {
        if (sheet.getPhysicalNumberOfRows() == 0) {
            return;
        }
        Row headerRow = sheet.getRow(0);
        if (headerRow == null) {
            return;
        }
        int lastCellIndex = headerRow.getLastCellNum();
        if (lastCellIndex <= 0) {
            return;
        }
        String lastColumn = convertColumnNumberToName(lastCellIndex);
        sheet.setAutoFilter(CellRangeAddress.valueOf("A1:" + lastColumn + "1"));
        sheet.createFreezePane(0, 1);
        for (int r = 0; r <= sheet.getLastRowNum(); r++) {
            Row row = sheet.getRow(r);
            if (row == null) continue;
            for (int c = 0; c < row.getLastCellNum(); c++) {
                Cell cell = row.getCell(c);
                if (cell == null) continue;
                sheet.autoSizeColumn(c);
            }
        }
    }

    private String convertColumnNumberToName(int columnNumber) {
        StringBuilder columnName = new StringBuilder();
        int current = columnNumber;
        while (current > 0) {
            int remainder = (current - 1) % 26;
            columnName.insert(0, (char) ('A' + remainder));
            current = (current - 1) / 26;
        }
        return columnName.toString();
    }

    private String formatPercent(int numerator, int denominator) {
        if (denominator <= 0) return "0%";
        return (numerator * 100 / denominator) + "%";
    }
}
