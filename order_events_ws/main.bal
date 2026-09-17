import ballerina/log;
import ballerina/websocket;

listener websocket:Listener wsListener = new (wsPort);

# Pushes order status events to connected clients as they arrive on the Kafka topic.
service /orders on wsListener {

    resource function get events() returns websocket:Service|websocket:UpgradeError {
        return new OrderEventsConnection();
    }
}

service class OrderEventsConnection {
    *websocket:Service;

    remote function onOpen(websocket:Caller caller) {
        registerClient(caller);
        websocket:Error? ack = caller->writeMessage({
            'type: "connected",
            raw: string `Subscribed to ${orderEventsTopic}`
        });
        if ack is websocket:Error {
            log:printWarn("Failed to acknowledge new client", ack);
        }
    }

    // Clients only receive; anything they send is ignored beyond a debug log.
    remote function onMessage(websocket:Caller caller, string text) {
        log:printDebug("Ignoring inbound client message", connectionId = caller.getConnectionId());
    }

    remote function onClose(websocket:Caller caller, int statusCode, string reason) {
        deregisterClient(caller);
    }

    remote function onError(websocket:Caller caller, error err) {
        log:printWarn("WebSocket connection error", err, connectionId = caller.getConnectionId());
        deregisterClient(caller);
    }
}
