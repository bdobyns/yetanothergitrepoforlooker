package org.cirrostratus.sequoia.logscraper.datacollector;

import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

/**
 * Created by Will on 1/11/2016.
 */
public class LogParser {
    private static ObjectMapper mapper = new ObjectMapper();

    public static JsonNode parse(S3Object object) throws IOException, AssertionError {
        JsonNode node;
        S3ObjectInputStream s3OIS = object.getObjectContent();
        node = mapper.readTree(s3OIS);
        assert(!node.isNull());
        assert(node.isContainerNode());
        assert(node.has("eventtype"));
        return node;
    }
}
