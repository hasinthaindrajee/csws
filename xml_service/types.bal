// Incoming request payload
type InventoryRequest record {|
    string sku;
|};

// Distribution center info
type DistributionCenter record {|
    string name;
    string code;
|};

// Stock levels
type Stock record {|
    int quantityOnHand;
    string unit;
    int reorderPoint;
    int reorderQuantity;
|};

// Warehouse location
type Location record {|
    string aisle;
    string bay;
    string shelf;
|};

// Supplier info
type Supplier record {|
    string name;
    string supplierId;
    int leadTimeDays;
|};

// Full inventory record for hardcoded data
type InventoryItem record {|
    string sku;
    string description;
    string lastUpdated;
    DistributionCenter distributionCenter;
    Stock stock;
    Location location;
    Supplier supplier;
|};