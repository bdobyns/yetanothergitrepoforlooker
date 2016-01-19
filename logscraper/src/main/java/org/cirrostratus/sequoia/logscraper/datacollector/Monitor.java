package org.cirrostratus.sequoia.logscraper.datacollector;

import com.wordnik.swagger.annotations.Api;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.text.ParseException;
import java.util.Map;

/**
 * Created by Will on 1/18/2016.
 */
@Controller
@RequestMapping("/")
@Api(value="Base Monitor Class")
public class Monitor {

    @Autowired
    LogScrapper logScrapper;

    @ResponseBody
    @RequestMapping(value="/logsProcessed")
    public Map<String, String> checkNumberOfLogsProcessed() {
        return logScrapper.checkStatus();
    }

    @ResponseBody
    @RequestMapping(value="/start")
    public Boolean start() throws ParseException {
        return logScrapper.startCheckingBuckets();
    }
    @ResponseBody
    @RequestMapping(value="/stop")
    public Boolean stop() throws ParseException {
        return logScrapper.stopThread();
    }

    @ResponseBody
    @RequestMapping(value="/healthcheck")
    public Integer healthcheck() {
        return 200;
    }
}
