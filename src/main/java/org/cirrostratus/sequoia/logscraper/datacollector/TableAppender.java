package org.cirrostratus.sequoia.logscraper.datacollector;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class TableAppender {

    private Connection connection;

    private final String tableName;

    private List<String> columnNames;

    public TableAppender(String tableName, Connection connection) {
        this.connection = connection;
        this.tableName = tableName.replace('-', '_');
    }

    /**
     * Appends the specified row to this table, adding columns if necessary.
     *
     * @param row map of name/value pairs
     */
    public void append(Map<String, Object> row) {
        String insertCommand = "(not yet)";
        try {
            ensureTableColumns(row);
            insertCommand = SQLQueryBuilder.insert(tableName, row);
            System.out.println(insertCommand);
            Statement st = connection.createStatement();
            st.executeUpdate(insertCommand);
        } catch (SQLException e) {
            System.err.println(insertCommand);
            throw new RuntimeException(e);
        }
    }

    /**
     * Ensures that the table contains the specified columns.
     *
     * @param row map with column name keys
     * @throws SQLException
     */
    private void ensureTableColumns(Map<String, Object> row) throws SQLException {
        if (columnNames == null) {
            if (!tableExists(connection, tableName)) {
                columnNames = new ArrayList<>(row.keySet());
                createTable(connection, tableName, columnNames, getOrderedTypes(columnNames, row));
                addIndex(connection, tableName);
                return;
            }
            columnNames = getTableColumns(connection, tableName);
        }
        List<String> newColumnNames = getNewColumnNames(row.keySet(), columnNames);
        if ((newColumnNames != null) && (newColumnNames.size() > 0)) {
            addNewColumns(connection, tableName, newColumnNames);
            columnNames.addAll(newColumnNames);
        }
    }

    /**
     * Returns a list of types of values from the specified map,
     * ordered in accordance with the specified list of keys.
     *
     * @param orderedKeys
     * @param map
     * @return ordered list of types
     */
    private List<Class> getOrderedTypes(List<String> orderedKeys, Map<String, Object> map) {
        List<Class> types = new ArrayList<Class>(orderedKeys.size());
        try {
            for (String key : orderedKeys) {
                types.add(getTheClass(map.get(key)));
            }
        } catch (RuntimeException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            System.err.println("orderedKeys: " + orderedKeys);
            System.err.println("map: " + map);
            throw e;
        }
        return types;
    }

    private Class getTheClass(Object object) {
        return (object == null) ? String.class : object.getClass();
    }

    /**
     * Returns a list of the new column names that don't exist
     * in the list of existing column names.
     *
     * @param columnNames prospective column names
     * @param existingColumnNames already existing column names
     * @return the difference, or null if no new column names
     */
    private List<String> getNewColumnNames(Set<String> columnNames, List<String> existingColumnNames) {
        List<String> newColumnNames = null;
        for (String columnName : columnNames) {
            if (!existingColumnNames.contains(columnName)) {
                if (newColumnNames == null) {
                    newColumnNames = new ArrayList<String>();
                }
                newColumnNames.add(columnName);
            }
        }
        return newColumnNames;
    }

    private boolean tableExists(Connection connection, String tableName) throws SQLException {
        return connection.createStatement().executeQuery(SQLQueryBuilder.showTable(tableName)).next();
    }

    private List<String> getTableColumns(Connection connection, String tableName) throws SQLException {
        ResultSet resultSet = connection.createStatement().executeQuery(SQLQueryBuilder.describeTable(tableName));
        List<String> columnNames = new ArrayList<String>();
        while (resultSet.next()) {
            columnNames.add(resultSet.getString("Field"));
        }
        return columnNames;
    }

    private void createTable(Connection connection, String tableName, List<String>columnNames, List<Class> types)
            throws SQLException {
        connection.createStatement().executeUpdate(SQLQueryBuilder.createTable(tableName, columnNames, types));
    }

    private void addIndex(Connection connection, String tableName)
            throws SQLException {
        connection.createStatement().executeUpdate(SQLQueryBuilder.buildAddIndexQuery(tableName));
    }

    private void dropTable(Connection connection, String tableName) throws SQLException {
        connection.createStatement().executeUpdate(SQLQueryBuilder.dropTable(tableName));
    }

    private void addNewColumns(Connection connection, String tableName, List<String> newColumnNames)
            throws SQLException {
        connection.createStatement().executeUpdate(SQLQueryBuilder.buildAddColumnsQuery(tableName, newColumnNames, null));
    }
}
