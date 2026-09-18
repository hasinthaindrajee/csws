import ballerina/http;
import ballerina/sql;

listener http:Listener httpDefaultListener = check new http:Listener(9095);

service /inventory on httpDefaultListener {

    // Returns all inventory items as a JSON array
    resource function get .() returns InventoryItem[]|http:InternalServerError {
        InventoryItem[] itemList = [];
        stream<InventoryItem, sql:Error?> resultStream = dbClient->query(
            `SELECT sku, product_name, quantity_on_hand FROM inventory`
        );
        error? iterateError = from InventoryItem inventoryItem in resultStream
            do {
                itemList.push(inventoryItem);
            };
        if iterateError is error {
            return <http:InternalServerError>{
                body: <ErrorResponse>{message: "Failed to retrieve inventory: " + iterateError.message()}
            };
        }
        return itemList;
    }

    // Returns a single inventory item by SKU, or 404 if not found
    resource function get [string sku]() returns InventoryItem|http:NotFound|http:InternalServerError {
        InventoryItem|sql:Error result = dbClient->queryRow(
            `SELECT sku, product_name, quantity_on_hand FROM inventory WHERE sku = ${sku}`
        );
        if result is sql:NoRowsError {
            return <http:NotFound>{
                body: <ErrorResponse>{message: string `SKU '${sku}' not found`}
            };
        }
        if result is sql:Error {
            return <http:InternalServerError>{
                body: <ErrorResponse>{message: "Database error: " + result.message()}
            };
        }
        return result;
    }

    // Creates a new inventory item; returns 201 with the created record, or 409 if SKU already exists
    resource function post .(@http:Payload InventoryCreateRequest newItem)
            returns http:Created|http:Conflict|http:InternalServerError {
        string skuValue = newItem.sku;
        string productNameValue = newItem.product_name;
        int quantityValue = newItem.quantity_on_hand;

        sql:ExecutionResult|sql:Error insertResult = dbClient->execute(
            `INSERT INTO inventory (sku, product_name, quantity_on_hand)
             VALUES (${skuValue}, ${productNameValue}, ${quantityValue})`
        );
        if insertResult is sql:Error {
            string errMsg = insertResult.message();
            // MySQL error code 1062 indicates a duplicate entry (unique/primary key violation)
            if errMsg.includes("Duplicate entry") || errMsg.includes("1062") {
                return <http:Conflict>{
                    body: <ErrorResponse>{message: string `SKU '${skuValue}' already exists`}
                };
            }
            return <http:InternalServerError>{
                body: <ErrorResponse>{message: "Failed to insert inventory item: " + errMsg}
            };
        }
        InventoryItem createdItem = {
            sku: skuValue,
            product_name: productNameValue,
            quantity_on_hand: quantityValue
        };
        return <http:Created>{body: createdItem};
    }
}
