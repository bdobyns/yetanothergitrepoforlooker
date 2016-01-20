package org.cirrostratus.sequoia;

import org.cirrostratus.sequoia.logscraper.datacollector.LogLineProcessor;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import static org.junit.Assert.assertEquals;
import static org.mockito.Matchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Created by Will on 1/13/2016.
 */
public class LogLineProcessorTest {
    private static String arrayOfValues = "[\"arrayValue1\",\"arrayValue2\",\"arrayValue3\"]";
    private static String arrayOfObjects =
            "[{\"objectKey1\": \"objectValue1.1\",\"objectKey2\": \"objectValue1.2\",\"objectKey3\": \"objectValue1.3\"}," +
            "{\"objectKey1\": \"objectValue2.1\",\"objectKey2\": \"objectValue2.2\",\"objectKey3\": \"objectValue2.3\"}," +
            "{\"objectKey1\": \"objectValue3.1\",\"objectKey2\": \"objectValue3.2\",\"objectKey3\": \"objectValue3.3\"}]";
    private static String simpleObject = "{\"objectKey1\": \"objectValue1.1\",\"objectKey2\": \"objectValue1.2\",\"objectKey3\": \"objectValue1.3\"}";
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
    private static final String sample2 = "{\n" +
            "\t\"eventid\": \"7c9581f1-943e-4b3d-af5d-974d583fb5ca\",\n" +
            "\t\"sessionid\": \"a4faa23bc409469f97738b4ec2325475\",\n" +
            "\t\"item_doi\": \"10.2307/20793969\",\n" +
            "\t\"user_agent\": \"Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F70 Safari/600.1.4 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)\",\n" +
            "\t\"referer\": null,\n" +
            "\t\"log_made_by\": \"event_planner\",\n" +
            "\t\"reason_for_authorization\": [\"license\"],\n" +
            "\t\"journal_iid\": \"59bfa620-2718-31a3-acbd-014fa6bd1376\",\n" +
            "\t\"tstamp_usec\": 1451606316886451,\n" +
            "\t\"c4_title\": \"BROMUS GROSSUS S.L. ET B. SECALINUS S.L. EN BELGIQUE ET AU GRAND-DUCH? DE LUXEMBOURG\",\n" +
            "\t\"c4_host\": \"www.jstor.org\",\n" +
            "\t\"uuid\": \"3619710a-6cdc-46b9-9309-aa4784205188\",\n" +
            "\t\"requestid\": \"excelsior:7dc5230e824ee43827cc40b497ac27f6\",\n" +
            "\t\"c4_primary_publisher\": \"Royal Botanical Society of Belgium\",\n" +
            "\t\"lit_subsessionid\": null,\n" +
            "\t\"lit_sessionid\": null,\n" +
            "\t\"c4_database\": \"JSTOR\",\n" +
            "\t\"item_id\": \"cb9ff1cd-1444-3e59-b065-2b607f6ae33e\",\n" +
            "\t\"c4_content_type\": \"journal\",\n" +
            "\t\"c4_journal_issn\": \"00379557\",\n" +
            "\t\"c4_year\": \"1983\",\n" +
            "\t\"uri\": \"/stable/pdf/20793969.pdf?acceptTC=true&coverpage=false\",\n" +
            "\t\"delivered_by\": \"sequoia\",\n" +
            "\t\"user_relation_map\": [],\n" +
            "\t\"c4_journal_e_issn\": null,\n" +
            "\t\"tstamp_iso8601\": \"2015-12-31T23:58:36.886451Z\",\n" +
            "\t\"entitlement_map\": {\n" +
            "\t\t\"0a094de5-39c9-4428-ba99-38e25d6cd1f7\": [],\n" +
            "\t\t\"3ea49b6b-971d-4f96-a02c-42e0a02f39f7\": [],\n" +
            "\t\t\"7bd1c90c-1e1e-4174-bf9c-146163a607db\": [{\n" +
            "\t\t\t\"licenseType\": \"Standard\",\n" +
            "\t\t\t\"license_legacy_id\": \"38245\",\n" +
            "\t\t\t\"displayFormats\": [],\n" +
            "\t\t\t\"license_priority\": 0,\n" +
            "\t\t\t\"entitlement\": \"16124\",\n" +
            "\t\t\t\"license\": \"2fa9e876-d92e-3cea-b3ea-b2b1250416ea\",\n" +
            "\t\t\t\"fulfillment_order_id\": null,\n" +
            "\t\t\t\"dda_threshold\": {\n" +
            "\t\t\t\t\"pdf_download\": 0,\n" +
            "\t\t\t\t\"view_item\": 0\n" +
            "\t\t\t},\n" +
            "\t\t\t\"licenseSubType\": null,\n" +
            "\t\t\t\"licenseTags\": null\n" +
            "\t\t}],\n" +
            "\t\t\"0126cc66-e802-4756-a46d-9f6c9bd4ed93\": [],\n" +
            "\t\t\"2db3b5bd-5a18-4142-8fb4-8742a4e44e81\": [],\n" +
            "\t\t\"3e33967e-b302-41e3-af20-aa419bb190a2\": [],\n" +
            "\t\t\"9e807dec-f37b-4c75-ac82-0c189a5cb0a0\": [],\n" +
            "\t\t\"3ef30194-1d31-4b99-a5a9-f17d9c357263\": [],\n" +
            "\t\t\"620d2199-119d-4470-ac23-8dc03f7c68ef\": []\n" +
            "\t},\n" +
            "\t\"origin\": \"article-view-ui\",\n" +
            "\t\"c4_search_type\": \"other\",\n" +
            "\t\"star_uuid\": null,\n" +
            "\t\"c4_sitenames\": [],\n" +
            "\t\"eventtype\": \"pdf_download\",\n" +
            "\t\"dests\": [\"CAPTAINS_LOG\",\n" +
            "\t\"ARTICLE_VIEW_CAPTAINS_LOG\",\n" +
            "\t\"COUNTER4\"],\n" +
            "\t\"c4_journal_title\": \"Bulletin de la Soci?t? Royale de Botanique de Belgique / Bulletin van de Koninklijke Belgische Botanische Vereniging\"\n" +
            "}";
    private LogLineProcessor instance;
    Connection  mockConnection = mock(Connection.class);
    Statement mockStatement = mock(Statement.class);

    @Before
    public void before() throws IOException, SQLException {
        instance = new LogLineProcessor(mockConnection);
        when(mockConnection.createStatement()).thenReturn(mockStatement);
        when(mockStatement.executeQuery(anyString())).thenReturn(mock(ResultSet.class));
    }

    @Test
    public void testLogLine() throws IOException {
        instance.processLine(sample2);
    }

    @Test
    public void testNoChildren() {

    }
    @Test
    public void testObjectChild() {

    }
    @Test
    public void testArrayOfValuesChild() {

    }
    @Test
    public void testArrayOfObjectChild() {

    }
    @Test
    public void  testGrandChild() {

    }

/*    @Test // the answer is NO!
    public void canObjectNodeHaveMultipleIdenticalKeys() {
        ObjectNode node = new ObjectMapper().createObjectNode();
        for(int i : new int[]{0, 1, 2, 3, 4}) {
            node.put("sameFieldName", i);
        }
        assertEquals(5, node.size()); // the answer is NO!
    }*/
}
