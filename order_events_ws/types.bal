// An order status change published to the Kafka topic
public type OrderStatusEvent record {|
    string eventId?;
    string orderId;
    string customerId?;
    string previousStatus?;
    string status;
    string carrier?;
    string trackingNumber?;
    string estimatedDelivery?;
    string timestamp?;
|};

// Wrapper pushed to clients. Messages that do not match OrderStatusEvent are
// forwarded as `raw` so a malformed publish never breaks the stream.
public type OutboundMessage record {|
    string 'type;
    OrderStatusEvent event?;
    string raw?;
|};
