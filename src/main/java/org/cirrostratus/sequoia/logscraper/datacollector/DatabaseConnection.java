package org.cirrostratus.sequoia.logscraper.datacollector;

import org.cirrostratus.sequoia.logscraper.config.WatchableWrapper;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String DEFAULT_PROTOCOL = "jdbc:mysql:";
    private static final String DEFAULT_HOST = "logjammer-rds01.barry.cirrostratus.org";
    private static final String DEFAULT_PORT = "3306";
    private static final String DEFAULT_DATABASE = "logjammer";
    private static final String DEFAULT_USER = "cloudyclouds";
    private static final String DEFAULT_PASSWORD = "cl0udycl0uds";
    private static final String DEFAULT_DRIVER = "com.mysql.jdbc.Driver";

    private static String protocol = DEFAULT_PROTOCOL;
    private static String host = DEFAULT_HOST;
    private static String port = DEFAULT_PORT;
    private static String database = DEFAULT_DATABASE;
    private static String user = DEFAULT_USER;
    private static String password = DEFAULT_PASSWORD;
    private static String driver = DEFAULT_DRIVER;


    public static Connection getConnection() throws SQLException {

        String user2 = WatchableWrapper.getStringValue(WatchableWrapper.PV.databaseUserName);
        String password2 = WatchableWrapper.getStringValue(WatchableWrapper.PV.databasePW);
        String host2 = WatchableWrapper.getStringValue(WatchableWrapper.PV.databaseHostname);
        String database2 = WatchableWrapper.getStringValue(WatchableWrapper.PV.databaseDB);

        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String dbUrl = protocol + "//" + host2 + ":" + port + "/" + database2;
        return DriverManager.getConnection(dbUrl, user2, password2);
    }
}
