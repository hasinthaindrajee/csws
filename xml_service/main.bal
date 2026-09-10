import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /inventory on httpDefaultListener {

    resource function post InventoryLookupService(@http:Payload xml requestPayload)
            returns xml|http:BadRequest {
        // Extract the <sku> child element text from <inventoryRequest>
        xml skuElement = requestPayload/<sku>;
        string skuValue = (skuElement/*).toString();
        if skuValue.trim() == "" {
            return <http:BadRequest>{
                body: xml `<error>Invalid request: missing or empty sku element</error>`
            };
        }
        InventoryItem? inventoryItem = inventoryCatalog[skuValue];
        if inventoryItem is InventoryItem {
            return buildSuccessResponse(inventoryItem);
        }
        return buildNotFoundResponse(skuValue);
    }
}
