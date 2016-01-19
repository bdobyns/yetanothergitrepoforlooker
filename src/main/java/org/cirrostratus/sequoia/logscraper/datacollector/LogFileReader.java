package org.cirrostratus.sequoia.logscraper.datacollector;

import java.io.*;
import java.sql.Connection;
import java.sql.SQLException;

public class LogFileReader {

    private final LogLineProcessor processor;

    public LogFileReader(LogLineProcessor processor) {
        this.processor = processor;
    }

    public void processFile(InputStream stream) throws IOException {
        processFile(new InputStreamReader(stream));
    }

    public void processFile(String pathname) throws IOException {
        processFile(new FileReader(pathname));
    }

    public void processFile(Reader reader) throws IOException {
        BufferedReader in = new BufferedReader(reader);
        try {
            String line;
            while ((line = in.readLine()) != null) {
                processor.processLine(line);
            }
        } finally {
            try {
                in.close();
            } catch (IOException e) {
                // ignore
            }
        }
    }

    public static void main(String[] args) throws IOException {
        LogFileReader logFileReader = new LogFileReader(new LogLineProcessor(getConnection()));
        for (String pathname : args) {
            File toCheck = new File(pathname);
            if(toCheck.isDirectory()) {
                scanDirectory(toCheck, logFileReader);
            } else {
                try {
                    logFileReader.processFile(pathname);
                } catch (FileNotFoundException e) {
                    System.err.println("File not found: " + pathname);
                }
            }

        }
    }

    private static void scanDirectory(File directory, LogFileReader logFileReader) {
        File[] files = directory.listFiles();
        for(File file : files) {
            if(file.isDirectory()) {
                scanDirectory(file, logFileReader);
            }
            String pathname = file.getAbsolutePath();
            try {
                logFileReader.processFile(pathname);
            } catch (Exception e) {
                System.err.println("File not found: " + pathname);
            }
        }
    }

    static Connection getConnection() {
        try {
            return DatabaseConnection.getConnection();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
