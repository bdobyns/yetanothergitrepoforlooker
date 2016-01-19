package org.cirrostratus.sequoia.logscraper.datacollector;

import org.apache.commons.cli.*;
import org.owasp.esapi.ESAPI;
import org.owasp.esapi.codecs.Codec;
import org.owasp.esapi.codecs.OracleCodec;

import java.sql.*;

/*
#DB URL will be constructed as follows:
# [protocol]//[host]:[port]/[database]
#db.protocol=jdbc:mysql:
#db.host=localhost
#db.port=3306
#db.database=test
#db.user=al-dash-user
#db.pass=al-dash-pw
#db.driver=com.mysql.jdbc.Driver


db.protocol=jdbc:mysql:
db.host=po-cesspool.c8x4c5fq4lwc.us-east-1.rds.amazonaws.com
db.port=3306
db.database=sequoia
db.user=cloudyclouds
db.pass=cl0udycl0uds
db.driver=com.mysql.jdbc.Driver
 */

public class DataCollector {

    private boolean isVerbose;

    private String protocol, host, port, database, user, password, driver;
    private String table;

    String[] parseOptions(String[] args) {
        Options options = new Options();
        options.addOption("H", "help", false, "print this message");
        options.addOption("v", false, "verbose");

        options.addOption("c", true, "protocol");
        options.addOption("h", true, "host");
        options.addOption("p", true, "port");
        options.addOption("d", true, "database");
        options.addOption("u", true, "user");
        options.addOption("x", true, "password");
        options.addOption("r", true, "driver");

        options.addOption("t", true, "table");

        CommandLineParser parser = new BasicParser();
        CommandLine line;
        try {
            line = parser.parse(options, args);
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }

        isVerbose = line.hasOption("v");
        if (line.hasOption("help")) {
            printHelpMessage(options);
            return line.getArgs();
        }

        protocol = line.getOptionValue("c", "jdbc:mysql:");
        host = line.getOptionValue("h", "localhost");
        port = line.getOptionValue("p", "3306");
        database = line.getOptionValue("d", "test");
        user = line.getOptionValue("u", null);
        password = line.getOptionValue("x", null);
        driver = line.getOptionValue("r", "com.mysql.jdbc.Driver");

        table = line.getOptionValue("t", "dataTable");

        if (isVerbose) {
            System.err.println("protocol=" + protocol
                    + " host=" + host
                    + " port=" + port
                    + " database=" + database
                    + " user=" + user
                    + " password=" + password
                    + " driver=" + driver
                    + " table=" + table
            );
        }
        return line.getArgs();
    }

    Connection getConnection() throws SQLException {
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String dbUrl = protocol + "//" + host + ":" + port + "/" + database;
        return DriverManager.getConnection(dbUrl, user, password);
    }

    public static void main(String[] args) throws SQLException {
        System.out.println("Hello world!");
        DataCollector dc = new DataCollector();
        args = dc.parseOptions(args);

        Connection connection = dc.getConnection();

        Statement st = connection.createStatement();

        String query = "SHOW TABLES LIKE '" + dc.table + "';";
        ResultSet tables = st.executeQuery(query);
        if (!tables.next()) {
            query = "CREATE TABLE '" + dc.table + "' " +
                    "( eventtime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ) ENGINE = MYISAM;";
            st.executeUpdate(query);
            query = "ALTER TABLE '" + dc.table + "' ADD INDEX ( eventtime ) ;" ;
            st.executeUpdate(query);
        }


    }

    private static void printHelpMessage(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        System.out.println("\n");
        formatter.printHelp( "datacollector.jar", options );
    }

    private String fixupRegex = "[-~`!@#\\$%^&\\*(){}+=\\[\\]|\\\\:\";'<>,./?]";

    private String nameFixup(String name) {
        return safeSQL(name.trim().replaceAll(fixupRegex, "_"));
    }

    private String fullTablename(String namespace, String tablename) {
        return safeSQL(namespace + "_" + tablename).trim();
    }

    private String safeSQL(String sql) {
        Codec codec = new OracleCodec();
        return ESAPI.encoder().encodeForSQL( codec, sql);
    }
}
