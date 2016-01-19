package org.cirrostratus.sequoia.logscraper.datacollector;

import org.owasp.esapi.ESAPI;
import org.owasp.esapi.Encoder;
import org.owasp.esapi.codecs.Codec;
import org.owasp.esapi.codecs.OracleCodec;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class SQLQueryBuilder {

    private static final String DEFAULT_TYPE = "MEDIUMTEXT";

    private static Encoder encoder = ESAPI.encoder();
    private static Codec codec = new OracleCodec();

    private static final DateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");


    public static String createTable(String table, List<String> names, List<Class> types) {
        StringBuilder buf = new StringBuilder();
        buf.append("CREATE TABLE ");
        buf.append(table);
        buf.append(' ');
        names = new ArrayList<>(names);
        types = new ArrayList<>(types);
//        names.add(0, "eventtime");
//        types.add(0, Date.class);
        appendNamesAndTypes(buf, names, types);
        buf.append(" ENGINE = MYISAM;");
        return buf.toString();
    }

    public static String buildAddIndexQuery(String table) {
        StringBuilder buf = new StringBuilder();
        buf.append("ALTER TABLE ");
        buf.append(table);
        buf.append(" ADD INDEX ( `_id` );");
        return buf.toString();
    }

    public static String buildAddColumnsQuery(String table, List<String> newColumnNames, List<Class> types) {
        StringBuilder buf = new StringBuilder();
        buf.append("ALTER TABLE ");
        buf.append(table);
        buf.append(" ADD ");
        appendNamesAndTypes(buf, newColumnNames, types);
        buf.append(';');
        return buf.toString();
    }

    public static String showTable(String tableName) {
        return "SHOW TABLES LIKE '" + tableName + "';";
    }

    public static String describeTable(String tableName) {
        return "DESCRIBE " + tableName + ";";
    }

    public static String dropTable(String tableName) {
        return "DROP TABLE " + tableName + ";";
    }

    public static String insert(String table, List<Object> values) {
        return insert(table, null, values);
    }

    public static String insert(String table, Map<String, Object> map) {
        int size = map.size();
        List<String> names = new ArrayList<String>(size);
        List<Object> values = new ArrayList<Object>(size);
        extractNamesAndValues(map, names, values);
        return insert(table, names, values);
    }

    private static void extractNamesAndValues(Map<String,Object> map, List<String> names, List<Object> values) {
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            names.add(entry.getKey());
            values.add(entry.getValue());
        }
    }

    public static String insert(String table, List<String> names, List<Object> values) {
        StringBuilder buf = new StringBuilder();
        buf.append("INSERT INTO ");
        buf.append(table);
        buf.append(' ');
        if (names != null) {
            appendNames(buf, names);
        }
        buf.append(" VALUES ");
        appendValues(buf, values);
        buf.append(';');
        return buf.toString();
    }

    static void appendNames(StringBuilder buf, List<String> names) {
        int n = 0;
        for (String name : names) {
            buf.append((n++ == 0) ? "(" : ", ");
            buf.append(nameFixup(name));
        }
        buf.append((n == 0) ? "( )" : ")");
    }

    static void appendValues(StringBuilder buf, List<Object> values) {
        int n = 0;
        for (Object value : values) {
            buf.append((n++ == 0) ? "(" : ", ");
            if (value == null) {
                buf.append(value);
            } else if (value instanceof Number) {
                buf.append(value);
            } else if (value instanceof Date) {
                quote(buf, safeSQL((dateTimeFormat.format((Date) value))));
            } else {
                quote(buf, safeSQL(value.toString()));
            }
        }
        buf.append((n == 0) ? "( )" : ")");
    }

    static void appendNamesAndTypes(StringBuilder buf, List<String> names, List<Class> types) {
        appendNamesAndTypes(buf, names, types, null);
    }

    static void appendNamesAndTypes(StringBuilder buf, List<String> names, List<Class> types, String initial) {
        String delimiter = "(";
        if (initial != null) {
            buf.append(delimiter);
            delimiter = ", ";
            buf.append(initial);
        }
        int i = 0;
        for (String name : names) {
            buf.append(delimiter);
            delimiter = ", ";
            buf.append(nameFixup(name));
            buf.append(' ');
            buf.append((types == null) ? DEFAULT_TYPE : safeSQL(getSqlType(name, types.get(i))));
            i += 1;
        }
        buf.append(((initial == null) && (i == 0)) ? "( )" : ")");
    }

    private static String getSqlType(String columnName, Class clazz) {
        if("_id".equals(columnName.toLowerCase())) {
            return "VARCHAR(36)";
        }
        if ("eventtime".equals(columnName.toLowerCase())) {
            return "TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP";
        }
        if (Date.class.isAssignableFrom(clazz)) {
            return "DATETIME";
        }
        if (Integer.class.isAssignableFrom(clazz)) {
            return "INTEGER";
        }
        if (Double.class.isAssignableFrom(clazz)) {
            return "DOUBLE";
        }
        if ("params".equals(columnName.toLowerCase())) {
            return "MEDIUMTEXT";
        }
        return DEFAULT_TYPE;
    }

    private static void quote(StringBuilder buf, String s) {
        buf.append('\'');
        buf.append(s);
        buf.append('\'');
    }

    private static String fixupRegex = "[-~`!@#\\$%^&\\*(){}+=\\[\\]|\\\\:\";'<>,./?]";

    private static String nameFixup(String name) {
        return '`' + safeSQL(name.trim().replaceAll(fixupRegex, "_")) + '`';
    }

    private static String safeSQL(String sql) {
        return encoder.encodeForSQL(codec, sql);
    }

    public static void main(String[] args) {
        System.out.println("Hello world");

        List<String> names = new ArrayList<String>();
        names.add("Name");
        names.add("Number1");
        names.add("Number2");
        names.add("City");
        List<String> types = new ArrayList<String>();
        types.add("TEXT");
        types.add("INTEGER");
        types.add("DOUBLE");
        types.add("BLOB");
        System.out.println(SQLQueryBuilder.createTable("data_table1", names, null));

        List<Object> objects = new ArrayList<Object>();
        objects.add("valueString1");
        objects.add(42);
        objects.add(3.14);
        objects.add("Grover's Mill");
        System.out.println(SQLQueryBuilder.insert("data_table1", objects));
    }
}
