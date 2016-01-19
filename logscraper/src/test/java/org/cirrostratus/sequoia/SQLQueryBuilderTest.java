package org.cirrostratus.sequoia;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.cirrostratus.sequoia.logscraper.datacollector.SQLQueryBuilder;
import org.junit.Test;

import java.io.IOException;
import java.util.Map;

/**
 * Created by Will on 1/13/2016.
 */
public class SQLQueryBuilderTest {
    private static String sampleLogLine = // this is from an article-view-ui captains log
            "{" +
                    "\"delivered_by\": \"sequoia\"," +
                    " \"origin\": \"article-view-ui\"," +
                    " \"eventid\": \"b27ce5be-3491-4922-a2bb-f909b299f066\"," +
                    " \"journal_iid\": \"f32cc844-fb17-38fa-9c89-a3a461f36da6\"," +
                    " \"c4_sitenames\": []," +
                    " \"c4_journal_title\": \"Gnomon\"," +
                    " \"user_relation_map\": []," +
                    " \"uuid\": \"95d28a48-00f8-4971-aae3-3db7b175f4d5\"," +
                    " \"lit_sessionid\": null," +
                    " \"c4_year\": \"2005\"," +
                    " \"c4_host\": \"www.jstor.org\"," +
                    " \"lit_subsessionid\": null," +
                    " \"c4_search_type\": \"other\"," +
                    " \"c4_primary_publisher\": \"Verlag C.H.Beck\"," +
                    " \"entitlement_map\": {" +
                    "\"994b3395-f9a5-4920-88ae-29df818cf3da\": []," +
                    " \"9e807dec-f37b-4c75-ac82-0c189a5cb0a0\": []," +
                    " \"4616090a-3e12-477f-8054-13554b96ed51\": []}, " +
                    "\"log_made_by\": \"event_planner\"," +
                    " \"uri\": \"/stable/40494148\"," +
                    " \"star_uuid\": null," +
                    " \"item_id\": \"31ded01e-ffd5-3abb-a747-5d655ead6720\"," +
                    " \"tstamp_usec\": 1451607518237997," +
                    " \"referer\": null," +
                    " \"c4_journal_issn\": \"00171417\"," +
                    " \"eventtype\": \"unauth_item\"," +
                    " \"dests\": [\"CAPTAINS_LOG\", \"COUNTER4\", \"ARTICLE_VIEW_CAPTAINS_LOG\"]," +
                    " \"item_doi\": \"10.2307/40494148\"," +
                    " \"tstamp_iso8601\": \"2016-01-01T00:18:38.237997Z\"," +
                    " \"c4_database\": \"JSTOR\"," +
                    " \"c4_title\": null," +
                    " \"sessionid\": \"3e9ebc7f198444d7889999d3a118001a\"," +
                    " \"c4_journal_e_issn\": null," +
                    " \"user_agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36\"," +
                    " \"requestid\": \"excelsior:91be7b3156a83b1f9977a37c8dfb49de\"," +
                    " \"c4_content_type\": \"journal\"}\n";

    @Test
    public void testLine() throws IOException {
        ObjectMapper mapper = new ObjectMapper()
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                .configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false)
                .configure(DeserializationFeature.USE_JAVA_ARRAY_FOR_JSON_ARRAY, true);
        Map<String, Object> row = mapper.readValue(sampleLogLine, new TypeReference<Map<String, Object>>(){});
        String actual = SQLQueryBuilder.insert("testTable", row);
        System.out.println(actual);
    }
}
