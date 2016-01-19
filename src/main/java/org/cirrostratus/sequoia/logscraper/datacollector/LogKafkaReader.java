package org.cirrostratus.sequoia.logscraper.datacollector;

public class LogKafkaReader {
/*
    private static final int THREAD_COUNT = 1;

    private static final ConcurrentHashMap<String, LogKafkaReader> logKafkaReaders
            = new ConcurrentHashMap<String, LogKafkaReader>();

    private final String topicName;

    private final LogLineProcessor processor;

    private volatile boolean stop = false;
    private volatile boolean running = false;


    public static LogKafkaReader getLogKafkaReader(String topicName) {
        synchronized (logKafkaReaders) {
            LogKafkaReader logKafkaReader = logKafkaReaders.get(topicName);
            if (logKafkaReader == null) {
                logKafkaReader = new LogKafkaReader(topicName, new LogLineProcessor(topicName));
                logKafkaReaders.put(topicName, logKafkaReader);
            }
            return logKafkaReader;
        }
    }


    public LogKafkaReader(String topicName, LogLineProcessor processor) {
        this.topicName = topicName;
        this.processor = processor;
    }

    public void startTopicReader() {
        if (running) {
            return;
        }
        running = true;

        // specify some consumer properties
        Properties props = new Properties();
        String zookeeperConfigSpec = Zookeeper.getConfigSpec();
        System.out.println("zookeeperConfigSpec:" + zookeeperConfigSpec);
        props.put("zookeeper.connect", zookeeperConfigSpec);
        props.put("zookeeper.connectiontimeout.ms", "1000000");
        props.put("group.id", topicName + "_LKR");

        System.err.println(zookeeperConfigSpec);

        // Create the connection to the cluster
        ConsumerConfig consumerConfig = new ConsumerConfig(props);
        ConsumerConnector consumerConnector = Consumer.createJavaConsumerConnector(consumerConfig);

        // create THREAD_COUNT partitions of the stream for topic, to allow THREAD_COUNT threads to consume
        Map<String, Integer> testMap = new HashMap<String, Integer>();
        testMap.put(topicName, THREAD_COUNT);
        Map<String, List<KafkaStream<byte[], byte[]>>> topicMessageStreams =
                consumerConnector.createMessageStreams(Collections.unmodifiableMap(testMap));
        List<KafkaStream<byte[], byte[]>> streams = topicMessageStreams.get(topicName);

        // create list of THREAD_COUNT threads to consume from each of the partitions
        ExecutorService executor = Executors.newFixedThreadPool(THREAD_COUNT);

        // consume the messages in the threads
        for(final KafkaStream<byte[], byte[]> stream: streams) {
            executor.submit(new Runnable() {
                public void run() {
                    try {
                        System.err.println("reading from kafka stream");
                        for(MessageAndMetadata msgAndMetadata: stream) {
                            try {
                                processor.processLine(new String((byte[]) msgAndMetadata.message()));
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            if (stop) {
                                break;
                            }
                        }
                    } finally {
                        stop = false;
                        running = false;
                        System.err.println("stopped " + topicName);
                    }
                }
            });
        }
    }

    public void stopTopicReader() {
        if (!running) {
            return;
        }
        stop = true;
        // TODO: interrupt reader
        System.err.println("stopping " + topicName);
    }

    public static void main(String[] args) {
        for (String topic : args) {
            System.err.println("subscribing to " + topic);
            LogKafkaReader logKafkaReader = new LogKafkaReader(topic, new LogLineProcessor(topic));
            logKafkaReader.startTopicReader();
        }
        System.err.println("done with main");
    }*/
}
