package org.cirrostratus.sequoia.logscraper.datacollector;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.*;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.cirrostratus.sequoia.logscraper.config.WatchableWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import rx.Observable;
import rx.functions.Func1;
import rx.schedulers.Schedulers;

import javax.annotation.PostConstruct;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

import static rx.Observable.defer;
import static rx.Observable.just;

/**
 * Created by Will on 1/11/2016.
 */
@Component
public class LogScrapper {
    public static Logger logger = LogManager.getLogger(LogScrapper.class);
    public static Executor pool = Executors.newFixedThreadPool(50);

    private static Date newYear;
    private static AtomicInteger checked;
    private static AtomicInteger found;
    private static AtomicInteger downloaded;
    private static String lastLog;
    private static List<String> buckets;
    private Thread runningThread;
    LogFileReader logReader;

    @Autowired
    private AmazonS3Client s3;

    @PostConstruct
    public void init() throws ParseException, SQLException {
        newYear = new SimpleDateFormat("MMM dd yyyy ZZZ").parse("Jan 01 2016 UTC");
//        s3 = new AmazonS3Client(getCredentials());
        logReader = new LogFileReader(new LogLineProcessor(DatabaseConnection.getConnection()));
        checked = new AtomicInteger();
        found = new AtomicInteger();
        downloaded = new AtomicInteger();
        buckets = new ArrayList<>();
    }

    private static AWSCredentials getCredentials() {
        return new AWSCredentials() {
            public String getAWSAccessKeyId() {
                return "AKIAJFNM5OSE4LU7BSHA";
            }
            public String getAWSSecretKey() {
                return "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";
            }
        };
    }

    public boolean startCheckingBuckets() throws ParseException {
        if(runningThread ==null || !runningThread.isAlive()) {
            runningThread = new Thread(() -> {
                buckets.addAll(Arrays.asList(bucketPrefixes()));
                Observable.from(bucketPrefixes())
                        .toBlocking()
                        .forEach(prefix -> {
                            buckets.remove(prefix);
                            String marker = null;
                            do{
                                marker = listLogFolders(prefix, marker);
                            } while(marker != null);
                        });
            }, "bucketChecker1");
            runningThread.start();
            return false;
        }
        return true;
    }

    public boolean stopThread() {
        if(runningThread.isAlive()) {
            runningThread.interrupt();
            return true;
        }
        return false;
    }

    private String listLogFolders(String prefix, String marker) {
        ObjectListing objectListing = s3.listObjects(new ListObjectsRequest()
                .withBucketName("kafka-logs")
                .withPrefix("prod/" + prefix)
                .withMarker(marker));
        Observable.from(objectListing.getObjectSummaries()).subscribeOn(Schedulers.from(pool))
                .flatMap((summary) -> defer(() -> just(fetchObject(summary))).subscribeOn(Schedulers.from(pool)))
                .subscribe();
        return objectListing.isTruncated()
                ? objectListing.getNextMarker()
                : null;
    }

    private Void fetchObject(S3ObjectSummary o) {

        String key = o.getKey();
        lastLog = key;
        logger.info(checked.incrementAndGet() + " Check Key " + key);
        if (key.contains("captain") && o.getLastModified().after(newYear)) {
            logger.info(found.incrementAndGet() + "Found file to download " + key);
   /*         if(WatchableWrapper.getBit(WatchableWrapper.DP.storeFilesLocally)) {
                File file = new File("D:\\log_dump\\" + key.replaceAll("/", "\\\\"));
                if (!file.exists()) {
                    logger.info(downloaded.incrementAndGet() + "Saving to path " + file.getAbsoluteFile());
                    GetObjectRequest gor = new GetObjectRequest("kafka-logs", key);
                    s3.getObject(gor, file);
                } else {
                    logger.info("file already exists" + file.getAbsoluteFile());
                }
            } else {*/
                GetObjectRequest gor = new GetObjectRequest("kafka-logs", key);
                S3Object object = s3.getObject(gor);
                try {
                    logReader.processFile(object.getObjectContent());
                    logger.info(downloaded.incrementAndGet() + "Saving to database "+key);
                } catch (IOException e) {
                    logger.warn(e);
                }
//            }
        }
        return null;
    }

    private static String[] bucketPrefixes() {
        return new String[] {
//                "access-log-correlation",
//                "ahead-of-print",
//                "ale-management-service",
//                "ale-query-service",
//                "analytics-jasper",
//                "apdexcalculator",
//                "apps-gateway-manager",
//                "apps-gateway-practice",
//                "apps-gateway",
//                "article-view-counter-logger",
//                "article-view-service",
                "article-view-ui",
//                "availability-markers",
//                "beta-counter-reports-service",
//                "beta-counter-ui",
//                "birch-search",
//                "bolt-admin-ui",
                "bolt-books-service",
//                "bolt-cats-iac-audit",
                "bolt-csp-service",
                "bolt-gateway",
                "bolt-jpass-service",
                "bolt-monitor-service",
//                "bolt-notification-service",
                "bolt-service",
//                "bolt-sugar-iac-audit",
//                "bolt-ui-deposits",
//                "bolt-ui-web-app",
//                "bolt-ui",
                "bolt-workflow-service",
                "book-view",
//                "book-workflow-cleanup-kevin",
                "browse-ui",
//                "bsys-discipline-pages",
//                "bsys-drupal-forms-prod",
//                "bsys-drupal-forms",
//                "bsys-sugar-util",
//                "bsys-sugar",
/*                "captains-log-injector", */ // Don't use! Doesn't store captains logs.
/*                "captains-log-validator", */ // Don't use! Doesn't store captains logs.
//                "captcha-abuse",
//                "cash",
//                "cats-daf-service",
//                "cats-rest-api",
//                "cats",
//                "catslegacywebservices",
//                "catsservice",
//                "cedar-delivery-service",
//                "cedar-mediator-service",
//                "cedar-mediator2-service",
//                "cedar-update-service",
                "chappy-view",
//                "chicago-iap-service",
//                "citation-export",
//                "citation-service-ng",
//                "citation-service",
                "collection-view",
//                "content-reprocess",
//                "cottonwood-reports-service",
//                "counter-logger-staging",
//                "counter-logger",
//                "counter-reports-service",
//                "counter-ui",
                "counterstrike",
//                "crossref-service",
//                "csp-ftp-service",
//                "csp-pub-ui",
//                "ctn-reports-service",
//                "cupid",
//                "cyp-one-thousand-two",
//                "cypress-slide-deck",
//                "dashboard",
                "dda-service",
//                "deposits-packaging",
//                "dfr-dataset-builder",
//                "dfr-service",
//                "dynamodb-monitor",
//                "e-commerce",
//                "eme-abnormalizer-web",
//                "eme-bastion-service",
//                "eme-canonical-next",
//                "eme-canonical-read-master",
//                "eme-canonical-service-swt",
//                "eme-canonical-service",
//                "eme-cloudsearch-service",
//                "eme-content-service",
//                "eme-create-update-refactortest",
//                "eme-create-update-service",
//                "eme-health-monitor-swt",
//                "eme-health-monitor",
//                "eme-manage-service",
//                "eme-performant-next",
//                "eme-performant-service",
//                "eme-xwc-service",
//                "ericprodtest",
//                "ericpylibs",
//                "error-pages",
//                "etl-executor",
//                "eureka-status-monitor",
//                "evaluator-service",
                "event-planner-service",
//                "excelsior",
//                "ezproxy-61",
//                "ezproxyaas-61",
//                "file-events-messager",
//                "flag-registry",
//                "franz",
//                "freeciteror",
//                "ftp-message-router",
//                "graphite-at",
//                "graphite",
//                "graphite4kafka",
//                "haproxy",
//                "iac-aaa-ipauth",
//                "iac-aaa-v1",
                "iac-aaa",
//                "iac-export-service-for-bolt-ui",
//                "iac-export-service-full",
                "iac-export-service",
//                "iac-mailer",
//                "iac-marker-monitoring",
//                "iac-service-load",
                "iac-service",
//                "iac-session-service",
//                "iac-ucm",
//                "iac-update-service-load",
//                "iac-update-service",
//                "id-service-migr",
//                "id-service",
//                "index-service",
//                "index-update-full",
//                "index-update",
//                "indexer-service-a-v1",
//                "indexer-service-a-v2",
//                "indexer-service-a",
//                "indexer-service-b-v1",
//                "indexer-service-b-v2",
//                "indexer-service-b-v3",
//                "indexer-service-current",
//                "indexer-service-new",
//                "indexer-service-solr-v1",
//                "indexer-service-solr-v2",
//                "indexer-service-solr-v3",
//                "indexer-service-v4",
//                "indexer-service-v5",
//                "indexer-service-v6",
//                "indexer-service",
//                "inspectorservice",
//                "institution-finder",
//                "integration-azkaban",
//                "interact-beta-3",
//                "interact-beta",
//                "interact",
//                "jenkins",
//                "kafka-manager",
//                "kafka-offset",
//                "kafka",
//                "labs-main",
//                "labs-site",
//                "labs",
//                "labscms",
//                "literatum-update-service",
                "llip",
//                "login-ui",
//                "logjammer",
//                "lumberjack",
//                "mds-admin-ui",
//                "mds-delivery-service",
//                "meta-a",
//                "meta",
//                "myjstor",
//                "mysql-monitor",
//                "nudge",
//                "omni-simulator",
//                "pdf-delivery-service",
//                "personalization-ui",
//                "primarysource-perf-test",
                "primarysource",
//                "prod-rajesh2",
//                "prod-search-service",
//                "ps-pub-ui",
//                "pub-view",
                "publisher-service",
//                "publisher-services",
//                "publishing-service",
//                "puppet",
//                "qa-gateway",
//                "qa-prod-cluster-spot",
//                "qa-prod-cluster",
//                "qa-simple-java",
                "report-service",
//                "reporting-azkaban-prod",
//                "reporting-azkaban",
//                "reporting-jasper",
//                "reporting-outpost",
                "reporting-service",
                "reporting-ui",
                "reports-ui",
                "request-validator",
//                "revive",
//                "roadrunner",
//                "rs-bsys-drupal-forms",
//                "sagoku",
//                "sasstom",
                "search-gateway",
//                "search-service-staging",
//                "search-service-sycamore",
                "search-service",
//                "search-solr-b",
                "search-ui-cdn",
//                "search-ui-cdn2",
//                "search-ui-elb",
//                "search-ui-scale-up",
//                "search-ui-staging-b",
//                "search-ui-staging",
//                "search-ui-staging1",
//                "search-ui-staging2",
//                "search-ui-temp",
                "search-ui",
//                "seas",
//                "secor-captains-log",
//                "secor-raw-logs",
//                "semantic-indexer-farm",
//                "semantic-indexing-bastion",
//                "service-locator-test-service",
//                "service-locator-the-service",
                "shelf-service",
//                "simple-django-27",
//                "simple-django-33",
//                "simple-java-nosl",
//                "simple-transfer",
                "site-mapper",
//                "sldp",
//                "smalik-simple-web",
//                "sql-auditor",
//                "sslcert-info",
//                "styleguide",
//                "sugar-update-health-monitor",
//                "sugar-update-service",
//                "sugarstorage",
//                "sugartrain-kevin-update-service",
//                "sugartrain-update-service",
//                "super-dashboard",
//                "sycamore-demo",
//                "sycamore-slide-deck",
//                "syslog-logbuffer",
//                "te-admin",
//                "teachable-local",
//                "teachable",
//                "terms-and-conditions",
//                "throttle-service",
                "toc-view-ui",
//                "transfer-service",
//                "ui-log",
//                "value-map-service",
//                "xrcr",
//                "yarn",
//                "zipperator-service",
//                "zookeeper-tester",
//                "zookeeper"
        };
    }

    public Map<String, String> checkStatus() {
        return new HashMap<String, String>(){{
                put("logsChecked", Integer.toString(checked.intValue()));
                put("logsFound", Integer.toString(found.intValue()));
                put("logsProcessed", Integer.toString(downloaded.intValue()));
                put("lastLogChecked", lastLog);
                put("bucketsRemaining", buckets.toString());
            }};

    }
}
