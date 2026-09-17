import ballerina/log;
import ballerinax/kafka;

listener kafka:Listener orderEventsListener = check new (kafkaBootstrapServers, {
    groupId: consumerGroupId,
    topics: [orderEventsTopic],
    // Only new events reach clients; restarting the bridge does not replay history
    offsetReset: kafka:OFFSET_RESET_LATEST,
    pollingInterval: 1,
    securityProtocol: kafka:PROTOCOL_SASL_SSL,
    auth: {
        mechanism: kafka:AUTH_SASL_SCRAM_SHA_512,
        username: kafkaUser,
        password: kafkaPassword
    }
});

service on orderEventsListener {

    // Each message is parsed individually so one malformed publish cannot fail
    // the batch. Note: a record with a null value (a tombstone) cannot be bound
    // and fails in the connector before reaching here - publish with the `value`
    // field, not `content`, or the broker stores nulls.
    remote function onConsumerRecord(string[] messages) {
        foreach string raw in messages {
            OrderStatusEvent|error event = raw.fromJsonStringWithType(OrderStatusEvent);
            if event is OrderStatusEvent {
                broadcast({'type: "orderStatusEvent", event: event});
            } else {
                log:printWarn("Record did not match OrderStatusEvent; forwarding raw", payload = raw);
                broadcast({'type: "raw", raw: raw});
            }
        }
    }

    remote function onError(kafka:Error err) {
        log:printError("Kafka consumer error", err);
    }
}
