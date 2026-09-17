// Kafka broker hosting the order status event topic
configurable string kafkaBootstrapServers = "kafka.cswholesale.wso2demos.com:9092";
configurable string orderEventsTopic = "order-status-events";
// A record with a null value kills the consumer and the group cannot advance past it.
// Recovery is to use a group name that does not exist yet: a fresh group starts at the
// topic head and skips everything behind it, nulls included.
configurable string consumerGroupId = "order-events-ws-bridge";

// SASL_SSL credentials. The broker presents a Let's Encrypt certificate, so the
// JVM's default trust store validates it and no cert file is needed here.
configurable string kafkaUser = "csws-bridge";
configurable string kafkaPassword = ?;

// Port the WebSocket endpoint listens on
configurable int wsPort = 9091;
