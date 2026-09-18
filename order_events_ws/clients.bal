import ballerina/log;
import ballerina/websocket;

// Connected WebSocket clients, keyed by connection ID. Written on connect and
// disconnect, read whenever a Kafka message arrives.
isolated map<websocket:Caller> connectedClients = {};

isolated function registerClient(websocket:Caller caller) {
    lock {
        connectedClients[caller.getConnectionId()] = caller;
    }
    log:printInfo("Client connected", connectionId = caller.getConnectionId(), total = clientCount());
}

isolated function deregisterClient(websocket:Caller caller) {
    lock {
        _ = connectedClients.removeIfHasKey(caller.getConnectionId());
    }
    log:printInfo("Client disconnected", connectionId = caller.getConnectionId(), total = clientCount());
}

isolated function clientCount() returns int {
    lock {
        return connectedClients.length();
    }
}

// Pushes a message to every connected client. A write failure means the peer is
// gone, so the client is dropped rather than retried.
//
// Writes happen inside the lock because `websocket:Caller` is not Cloneable and
// so cannot be copied out of it. Fine at demo scale; revisit if client counts
// grow enough that serialised broadcasts matter.
isolated function broadcast(OutboundMessage message) {
    int delivered = 0;
    int dropped = 0;
    lock {
        string[] dead = [];
        foreach [string, websocket:Caller] [id, caller] in connectedClients.entries() {
            websocket:Error? writeResult = caller->writeMessage(message.cloneReadOnly());
            if writeResult is websocket:Error {
                dead.push(id);
            } else {
                delivered += 1;
            }
        }
        foreach string id in dead {
            _ = connectedClients.removeIfHasKey(id);
        }
        dropped = dead.length();
    }

    log:printInfo("Broadcast", messageType = message.'type, delivered = delivered, dropped = dropped);
    if delivered == 0 {
        // The usual cause of "I published but saw nothing": nobody was listening.
        log:printWarn("Broadcast reached no clients - none were connected");
    }
    if dropped > 0 {
        log:printWarn("Dropped unreachable clients", count = dropped);
    }
}
