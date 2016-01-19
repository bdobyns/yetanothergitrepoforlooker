package org.cirrostratus.sequoia;

import org.cirrostratus.sequoia.logscraper.datacollector.TableAppender;
import org.junit.Before;
import org.junit.Test;

import java.sql.Connection;

import static org.mockito.Mockito.mock;

/**
 * Created by Will on 1/13/2016.
 */
public class TableAppenderTest {
    private TableAppender instance;

    @Before
    public void init() {
        instance = new TableAppender("testTable", mock(Connection.class));
    }
    @Test
    public void first() {

    }
}
