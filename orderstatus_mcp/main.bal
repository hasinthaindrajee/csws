import ballerina/mcp;
import ballerina/http;

listener http:Listener httpListener = http:getDefaultListener();
listener mcp:Listener mcpListener = new (httpListener);

@mcp:ServiceConfig {
    info: {
        name: "OrderStatusMCPServer",
        version: "1.0.0"
    },
    options: {
        instructions: "This server provides order management tools. Use 'getOrderDetails' to retrieve full order information including status, items, shipping, and payment details by providing an order ID (e.g. ORD-10001). Use 'listOrders' to see all available order IDs."
    }
}
service mcp:Service /mcp on mcpListener {

    # Retrieves full details of an order given its order ID (e.g. ORD-10001).
    # Returns a JSON string with order status, customer info, line items,
    # pricing breakdown, payment status, and shipping information.
    # If the order is not found, returns an error message with available order IDs.
    #
    # + orderId - The unique order identifier (e.g. ORD-10001)
    # + return - Order details as a JSON string, or a not-found message
    isolated remote function getOrderDetails(string orderId) returns string {
        OrderDetails|string result = lookupOrder(orderId);
        if result is string {
            return result;
        }
        return result.toJsonString();
    }

    # Lists all available order IDs that can be queried using getOrderDetails.
    # Returns a comma-separated list of order IDs.
    #
    # + return - Comma-separated list of available order IDs
    isolated remote function listOrders() returns string {
        string[] keys = orderCatalog.keys();
        return string:'join(", ", ...keys);
    }
}
