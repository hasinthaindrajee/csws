// Represents a row in the inventory table
type InventoryItem record {|
    string sku;
    string product_name;
    int quantity_on_hand;
|};

// Request body for creating a new inventory item
type InventoryCreateRequest record {|
    string sku;
    string product_name;
    int quantity_on_hand;
|};

// Generic JSON error response body
type ErrorResponse record {|
    string message;
|};
