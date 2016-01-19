package org.cirrostratus.sequoia.logscraper.config;

import org.apache.commons.lang.StringUtils;
import org.cirrostratus.sequoia.dipswitches.DipSwitch;
import org.cirrostratus.sequoia.dipswitches.DipSwitchFactory;
import org.cirrostratus.sequoia.persistentvariable.PersistentVariable;
import org.cirrostratus.sequoia.persistentvariable.PersistentVariableFactory;
import org.cirrostratus.sequoia.structuredlogging.DestinationCategory;
import org.cirrostratus.sequoia.structuredlogging.IStructuredLogger;
import org.cirrostratus.sequoia.structuredlogging.OriginCategory;
import org.cirrostratus.sequoia.structuredlogging.StructuredLoggerFactory;
import org.cirrostratus.sequoia.watchable.WatchableListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.support.CronTrigger;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.TimeZone;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Created by Will on 1/18/2016.
 */
public class WatchableWrapper {
    private static final IStructuredLogger logger = StructuredLoggerFactory.getLogger(WatchableWrapper.class,
            DestinationCategory.SYSTEM, new OriginCategory("SearchPV"));
    @Autowired
    private PersistentVariableFactory pvf;
    @Autowired
    private DipSwitchFactory dsf;

    @PostConstruct
    public void init() {
        for (final PV pv : PV.values()) {
            pv.variable = pvf.newPersistentVariable(pv.name, pv.type, pv.defaultValue);
            pv.addListener(arg0 ->
                    logger.info("Persistent variable [" + pv.name
                            + "] was changed to: " + WatchableWrapper.getStringValue(pv)));
            pv.subscribeToAll();
        }
        for(final DP dp : DP.values()) {
            dp.dSwitch = dsf.newDipSwitch(dp.name, dp.defaultValue);
        }
    }

    public enum DP {
        storeFilesLocally("scraperStoreLocally", false),
        ;
        private final String name;
        private final boolean defaultValue;
        private DipSwitch dSwitch;

        public DipSwitch getSwitch() {
            return dSwitch;
        }

        public boolean getDefaultValue(){
            return defaultValue;
        }

        DP(String name, boolean defaultValue){
            this.name = name;
            this.defaultValue = defaultValue;
        }
    }

    public enum PV {
        databaseHostname("scraperHostname", "String", "bolt-prod-db-new.c8x4c5fq4lwc.us-east-1.rds.amazonaws.com"), //"jstorlogs.ctettyk01gpi.us-west-2.rds.amazonaws.com"),
        databasePW("scraperPW", "String", "cl0udycl0uds"),//"fWJ41sDzhXJr"
        databaseUserName("scraperUser", "String", "cloudyclouds"),//"jstorlogs"
        databaseDB("scraperDB", "String", "logs"),
        ;
        private final String name;
        private final String type;
        private final String defaultValue;
        private PersistentVariable variable;
        private List<WatchableListener> listeners = new LinkedList<>();

        PV(String name, String type, String defaultValue){
            this.name = name;
            this.type = type;
            this.defaultValue = defaultValue;
        }

        public String getValue(){
            return variable.getValue();
        }
        public void subscribe(WatchableListener listener) {
            this.variable.subscribe(listener);
        }
        public void subscribeToAll(){
            listeners.forEach(this::subscribe);
        }
        public void addListener(WatchableListener listener) {
            if(this.variable != null) {
                subscribe(listener);
            }
            this.listeners.add(listener);
        }
    }
    public static String getStringValue(PV pv) {
        try{
            return pv.getValue();
        } catch(NullPointerException e){
            logger.warn(e.getMessage()
                    + ". Using default persistence value. "
                    + pv.name + " = " + pv.defaultValue);
            return pv.defaultValue;
        }
    }

    public static Integer getIntValue(PV pv) {
        try {
            return Integer.parseInt(pv.getValue());
        } catch (Exception e) {
            logger.warn(e.getMessage()
                    + ". Using default persistence value. "
                    + pv.name + " = " + pv.defaultValue);
        }
        return Integer.parseInt(pv.defaultValue);
    }

    /**
     * @param pv
     * @return
     */
    public static boolean getBit(PV pv) {
        return Boolean.parseBoolean(pv.getValue());
    }

    public static boolean getBit(DP dipswitch){
        boolean ret = dipswitch.getDefaultValue();
        try{
            AtomicBoolean bit = dipswitch.getSwitch().getBit();
            ret = (bit != null) && bit.get();
        } catch(NullPointerException e){
            logger.warn(e.getMessage()+". Using default value. "+
                    dipswitch.name() + " = " + dipswitch.getDefaultValue());
            ret = dipswitch.getDefaultValue();
        }
        return ret;
    }

    public static List<String> getListValue(PV pv) {
        List<String> list = new ArrayList<>();
        String listString = WatchableWrapper.getStringValue(pv);
        String[] split = StringUtils.split(listString, ",");
        for(String s : split) {
            list.add(s.trim());
        }
        return list;
    }

    public static CronTrigger getCronTrigger(PV pv, TimeZone timezone) {
        try {
            return new CronTrigger(getStringValue(pv), timezone);
        } catch (IllegalArgumentException e) {
            logger.error(String.format(
                    "Invalid Cron expression set for PV: %s  Using defaultValue: %s  Cause: %s",
                    pv.name, pv.defaultValue, e));
        }
        return new CronTrigger(pv.defaultValue, timezone);
    }
}