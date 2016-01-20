package org.cirrostratus.sequoia.logscraper.datacollector;


import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.*;
import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.sql.Connection;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class LogLineProcessor {

    private Connection connection;

    private static final String COMMON_ID_FIELDNAME = "_id";
    private static final DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    private static final DateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
    private static final DateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//    static {
//        dateTimeFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
//    }
    private final ObjectMapper objectMapper = new ObjectMapper()
        .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
        .configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false)
                /*.configure(DeserializationFeature.USE_JAVA_ARRAY_FOR_JSON_ARRAY, true)*/;

    public LogLineProcessor(Connection connection) {
        this.connection = connection;
    }

    public String[] preferredIdFields = new String[]{"uuid", "id", "requestId"};

    public void processLine(String logLine) throws IOException {
        // Current naming rules for the know data.
        JsonNode node = objectMapper.readTree(logLine);
        assert(node.isObject());
        processLine((ObjectNode) node, new HashMap(), "origin", "eventtype");
    }

    public void processLine(ObjectNode node, Map<String, JsonNode> keyChain, String... tableNameFields) throws IOException {

        // Determine the table to be used and get TableAppender
        String tableName = determineTableName(tableNameFields, node);
        TableAppender tableAppender = new TableAppender(tableName, connection);

        // To be sent to the TableAppender.
        Map<String, Object> logMap = new LinkedHashMap<>();

        // Set keys in keyChain to the be added and include new id field.
        Map<String, JsonNode> updatedKeyChain = addKeyValues(node, tableName, keyChain, logMap);

        // Object of mixed types
        Iterator<String> names = node.fieldNames();
        while (names.hasNext()) {
            String fieldName = names.next();
            JsonNode currentNode = node.path(fieldName);
            if(currentNode == null
                    || currentNode.isNull()  // Shouldn't happen
                    || currentNode.isMissingNode()) {
                // handle bad input; may never happen...
                continue;
            }
            if(currentNode.isValueNode()) {
                // Include this data in this entry.
                logMap.put(fieldName.replace('-','_'), validateValue((ValueNode)currentNode));
            } else if (currentNode.size() > 0) {// non empty array or object
                try {
                    if(currentNode.isArray()) {
                        if(isArrayOfValues(currentNode)) { // Each item in array should be new line in new table.
                            currentNode = convertValuesToObjects(fieldName, (ArrayNode) currentNode);
                        }
                        for(JsonNode shouldBeObjectNode : currentNode) {
                            processLine((ObjectNode)shouldBeObjectNode, updatedKeyChain, tableName, fieldName);
                        }
                    } else {// Must be an ObjectNode
                        // in the situation that all the keys in the object are of the same length,
                        // then we assume that this object should be treated as an array
                        boolean similarObjects = false;
                        if(currentNode.size() > 1) {
                            int previous = 0;
                            Iterator<String> mapKeys = currentNode.fieldNames();
                            while (mapKeys.hasNext()) {
                                String key = mapKeys.next();
                                previous = previous == 0 ? key.length() : previous;
                                if(previous == key.length()) {
                                    similarObjects = true;
                                } else {
                                    similarObjects = false;
                                    break;
                                }
                            }
                        }
                        if(similarObjects) {
                            currentNode = convertToArrayOfObjects(fieldName, (ObjectNode) currentNode);
                            for(JsonNode shouldBeObjectNode : currentNode) {
                                processLine((ObjectNode)shouldBeObjectNode, updatedKeyChain, tableName, fieldName);
                            }
                        } else {
                            // regular object with varying keys.
                            processLine((ObjectNode) currentNode, updatedKeyChain, tableName, fieldName);
                        }
                    }
                } catch (AssertionError error) {
                    System.out.println(error.getMessage());
                }
            }
        }
        if(!logMap.isEmpty()) tableAppender.append(logMap);
    }

    private ArrayNode convertToArrayOfObjects(String fieldName, ObjectNode currentNode) {
        ArrayNode ret = JsonNodeFactory.instance.arrayNode();
        Iterator<String> fields = currentNode.fieldNames();
        while(fields.hasNext()) {
            String idFieldName = fields.next();
            if(!currentNode.get(idFieldName).isNull()) {
                ObjectNode nodeToAdd = JsonNodeFactory.instance.objectNode();
                nodeToAdd.put(fieldName + COMMON_ID_FIELDNAME, idFieldName);
                nodeToAdd.put(fieldName, currentNode.get(idFieldName));
                ret.add(nodeToAdd);
            }
        }
        return ret;
    }

    private Map<String, JsonNode> addKeyValues(ObjectNode node, String tableName, Map<String, JsonNode> keyChain, Map<String, Object> logMap) {
        // Include all the previous keys in the keychain to the be written to the database.
        for(Map.Entry<String, JsonNode> entry : keyChain.entrySet()) {
            logMap.put(entry.getKey().replace('-','_'), entry.getValue().textValue());
        }
        // Include a newly created id for this item and add  it to the future key chains.
        JsonNode uuidNode = JsonNodeFactory.instance.textNode(UUID.randomUUID().toString());
        logMap.put(COMMON_ID_FIELDNAME, uuidNode.textValue());
        keyChain.put(trimTo64Chars(1, tableName+COMMON_ID_FIELDNAME), uuidNode);
        return new HashMap(keyChain);
    }

    private ArrayNode convertValuesToObjects(String fieldName, ArrayNode arrayNode) {
        assert(isArrayOfValues(arrayNode));
        ArrayNode newNode = JsonNodeFactory.instance.arrayNode();
        for(JsonNode subNode : arrayNode) {
            ObjectNode object = JsonNodeFactory.instance.objectNode();
            object.put(fieldName, subNode);
            newNode.add(object);
        }
        return newNode;
    }

    private ObjectNode convertToObjectNode(String fieldName, ValueNode node) {
        ObjectNode ret = JsonNodeFactory.instance.objectNode();
        if(node.isValueNode()) {
            ret.put(fieldName, node);
        }
        return ret;
    }

    private boolean isArrayOfValues(JsonNode currentNode) {
        return currentNode.isContainerNode()
                && currentNode.isArray()
                && currentNode.size() > 0
                && currentNode.iterator().next().isValueNode();
    }

    private String setIdField(String idFieldName, ContainerNode node, Map<String, Object> keyChain, Map<String, Object> logMap) throws IOException {
        try {
            verifyHasValidField(idFieldName, node);
            logMap.put(COMMON_ID_FIELDNAME, validateValue((ValueNode) node.get(idFieldName)));
            return idFieldName;
        } catch (AssertionError error) {
            System.out.println(error.getMessage());
        }
        logMap.put(idFieldName, validateValue((ValueNode) node.get(idFieldName)));
        return idFieldName;
    }

    private Object validateValue(ValueNode node) throws IOException {
        if(node.isNumber()){
            if(node.canConvertToInt() || node.isIntegralNumber()) {
                return node.intValue();
            } else if(node.isBigDecimal()){
                return node.decimalValue();
            } else if(node.isBigInteger()) {
                return node.bigIntegerValue();
            } else if(node.isDouble()){
                return node.doubleValue();
            } else if(node.isFloatingPointNumber()){
                return Float.valueOf(node.asText());
            } else if(node.isLong()){
                return node.asLong();
            }
        } else if(node.isBinary()){ // Base64 encoded binary, isTextual will be false.
            return Base64.getDecoder().decode(node.binaryValue());
        } else if(node.isBoolean()) {
            return node.asText(); // returns literal 'true' or 'false'
        } else if(node.isTextual()){
            return node.asText();// returns actual text
        } else if(node.isPojo()){
            // Not sure how to handle this.
            // I would assume that this would have been cast as a Container Node.
            return node;
        }
        return node;
    }

    /**
     * Verifies and builds the table name based on the given field names.
     * If a field name is present in the ObjectNode, the value of the field is used in
     * the table name. Otherwise the field name itself is used.
     * @param tableNameFields
     * @param topNode
     * @return
     */
    private String determineTableName(String[] tableNameFields, ObjectNode topNode) {
        String tableName = "error";
        for(String nameField : tableNameFields) {
            String nameToAdd = verifyHasValidField(nameField, topNode)
                    ? topNode.get(nameField).textValue()
                    : nameField;
            tableName = tableName.equals("error") ? nameToAdd
                    : tableName + '_' + nameToAdd;
        }
        return trimTo64Chars(0, tableName);
    }

    /**
     * Recursive function to trim down '_' (underscore) delimited string values.
     * @param split
     * @param tableName
     * @return
     */
    private String trimTo64Chars(int split, String tableName) {
        if(tableName.length() > 64) {
            String[] sections = tableName.split("_");
            if(sections.length > split) {
                //TODO test this. Might want to use StringUtils.abbreviate(tableName, 64);
                sections[sections.length-1-split] = sections[sections.length-1-split].substring(0, 1);
            }
            split++;
            tableName = StringUtils.join(sections, '_');
            tableName = trimTo64Chars(split, tableName);
        }
        return tableName;
    }

    /**
     * verify that the field is present and populated with textual data.
     * @param fieldName
     * @param topNode
     */
    private boolean verifyHasValidField(String fieldName, ContainerNode topNode) {
        return fieldName != null
            && topNode.has(fieldName)
            && !topNode.path(fieldName).isNull()
            && !topNode.path(fieldName).isMissingNode()
            && topNode.get(fieldName).isValueNode();
    }

    public void processLine_old(String logLine) throws IOException {
//        System.out.println(tableName + " -> " + logLine);
        if (startsWithLevel(logLine)) {
            String[] words = logLine.split("  *", 5);
            if ((words.length == 5) && "-".equals(words[3])) {
                String level = words[0];
                String className = words[2];
                String message = words[4];
                if (level.endsWith(":")) {
                    level = level.substring(0, level.length() - 1);
                }
                Map<String,Object> map;
                if (message.charAt(0) == '{') {
                    map = new HashMap<String, Object>(objectMapper.readValue(message, new TypeReference<Map<String, Object>>(){}));
                } else {
                    map = new HashMap<String, Object>();
                    map.put("msg", message);
                }
                map.put("LogLevel", level);
                map.put("SourceClass", className);
                processMessage(map);
                return;
            }
            words = logLine.split("  *", 6);
            if ((words.length == 6) && "-".equals(words[4])) {
                String level = words[0];
                String date = words[1];
                String time = words[2];
                String className = words[3];
                String message = words[5];

                if (level.endsWith(":")) {
                    level = level.substring(0, level.length() - 1);
                }
                String millies = "0";
                words = time.split(",", 2);
                if (words.length == 2) {
                    time = words[0];
                    millies = words[1];
                }
                Date dateTime = getDate(date + ' ' + time);

                Map<String,Object> map;
                if (message.charAt(0) == '{') {
                    map = new HashMap<String, Object>(objectMapper.readValue(message, new TypeReference<Map<String, Object>>(){}));
                } else {
                    map = new HashMap<String, Object>();
                    map.put("msg", message);
                }
                map.put("LogLevel", level);
                map.put("DateTime", dateTime);
                map.put("Millies", Integer.parseInt(millies));
                map.put("SourceClass", className);
                processMessage(map);
                return;
            }
        } else if (startsWithTime(logLine)) {
            String[] words = logLine.split("  *", 6);
            if ((words.length == 6) && "-".equals(words[4])) {
                String time = words[0];
                String level = words[2];
                String className = words[3];
                String message = words[5];
                if (level.endsWith(":")) {
                    level = level.substring(0, level.length() - 1);
                }
                String millies = "0";
                words = time.split("\\.", 2);
                if (words.length == 2) {
                    time = words[0];
                    millies = words[1];
                }
                Date dateTime = getTime(time);
                Map<String,Object> map;
                if (message.charAt(0) == '{') {
                    map = new HashMap<String, Object>(objectMapper.readValue(message, new TypeReference<Map<String, Object>>(){}));
                } else {
                    map = new HashMap<String, Object>();
                    map.put("msg", message);
                }
                map.put("LogLevel", level);
                map.put("DateTime", dateTime);
                map.put("Millies", Integer.parseInt(millies));
                map.put("SourceClass", className);
                processMessage(map);
                return;
            }
        }
        Map<String,Object> map = new HashMap<String, Object>(objectMapper.readValue(logLine, new TypeReference<Map<String, Object>>() {}));
//        map.put("msg", logLine);
        processMessage(map);
    }

    private void processMessage(Map<String, Object> map) {
//        tableAppender.append(map);
    }

    private static Date getDate(String dateTime) {
        try {
            return dateTimeFormat.parse(dateTime);
        } catch (ParseException e) {
            return new Date();
        }
    }

    private static Date getTime(String time) {
        return getDate(dateFormat.format(new Date()) + " " + time);
    }


    private static final String[] levelStarts = {
            "INFO", "WARN", "ERR", "FATAL", "DEB", "TRACE", "FINE",
    };

    private static boolean startsWithLevel(String line) {
        for (String levelStart : levelStarts) {
            if (line.startsWith(levelStart)) {
                return true;
            }
        }
        return false;
    }

    private static boolean startsWithTime(String line) {
        return (line.length() > 8) && (line.charAt(2) == ':') && (line.charAt(5) == ':');
    }
}
