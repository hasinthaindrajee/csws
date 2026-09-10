// Hardcoded inventory catalog
final map<InventoryItem> inventoryCatalog = {
    "GRC-88213": {
        sku: "GRC-88213",
        description: "Canned Tomatoes 24ct",
        lastUpdated: "2026-09-10T08:45:00Z",
        distributionCenter: {name: "Keene NH DC", code: "DC-KEENE-NH"},
        stock: {quantityOnHand: 1240, unit: "CASE", reorderPoint: 300, reorderQuantity: 800},
        location: {aisle: "A12", bay: "04", shelf: "3"},
        supplier: {name: "Hunt's Foods Inc.", supplierId: "SUP-2291", leadTimeDays: 5}
    },
    "GRC-40021": {
        sku: "GRC-40021",
        description: "Olive Oil Extra Virgin 1L 12ct",
        lastUpdated: "2026-09-09T14:20:00Z",
        distributionCenter: {name: "Manchester NH DC", code: "DC-MANCH-NH"},
        stock: {quantityOnHand: 540, unit: "CASE", reorderPoint: 150, reorderQuantity: 400},
        location: {aisle: "B07", bay: "02", shelf: "1"},
        supplier: {name: "Mediterranean Imports LLC", supplierId: "SUP-1145", leadTimeDays: 10}
    },
    "GRC-55102": {
        sku: "GRC-55102",
        description: "Whole Grain Pasta 500g 20ct",
        lastUpdated: "2026-09-08T11:00:00Z",
        distributionCenter: {name: "Concord NH DC", code: "DC-CONC-NH"},
        stock: {quantityOnHand: 870, unit: "CASE", reorderPoint: 200, reorderQuantity: 600},
        location: {aisle: "C03", bay: "09", shelf: "2"},
        supplier: {name: "Barilla Group", supplierId: "SUP-3378", leadTimeDays: 7}
    }
};

// Builds a success XML response for a found inventory item
function buildSuccessResponse(InventoryItem item) returns xml {
    DistributionCenter dc = item.distributionCenter;
    Stock stockInfo = item.stock;
    Location loc = item.location;
    Supplier sup = item.supplier;
    return xml `<inventoryResponse>
    <sku>${item.sku}</sku>
    <description>${item.description}</description>
    <lastUpdated>${item.lastUpdated}</lastUpdated>
    <distributionCenter>
        <name>${dc.name}</name>
        <code>${dc.code}</code>
    </distributionCenter>
    <stock>
        <quantityOnHand>${stockInfo.quantityOnHand}</quantityOnHand>
        <unit>${stockInfo.unit}</unit>
        <reorderPoint>${stockInfo.reorderPoint}</reorderPoint>
        <reorderQuantity>${stockInfo.reorderQuantity}</reorderQuantity>
    </stock>
    <location>
        <aisle>${loc.aisle}</aisle>
        <bay>${loc.bay}</bay>
        <shelf>${loc.shelf}</shelf>
    </location>
    <supplier>
        <name>${sup.name}</name>
        <supplierId>${sup.supplierId}</supplierId>
        <leadTimeDays>${sup.leadTimeDays}</leadTimeDays>
    </supplier>
</inventoryResponse>`;
}

// Builds a NOT_FOUND XML response
function buildNotFoundResponse(string sku) returns xml {
    return xml `<inventoryResponse>
    <sku>${sku}</sku>
    <status>NOT_FOUND</status>
</inventoryResponse>`;
}