// Hardcoded sample order catalog
final readonly & map<OrderDetails> orderCatalog = {
    "ORD-10001": {
        orderId: "ORD-10001",
        orderDate: "2026-09-01T10:30:00Z",
        status: "DELIVERED",
        customer: {
            customerId: "CUST-001",
            customerName: "Alice Johnson",
            email: "alice.johnson@example.com",
            phone: "+1-555-0101"
        },
        items: [
            {productId: "PRD-501", productName: "Wireless Headphones", quantity: 1, unitPrice: 89.99d, totalPrice: 89.99d},
            {productId: "PRD-302", productName: "USB-C Charging Cable 2m", quantity: 2, unitPrice: 12.49d, totalPrice: 24.98d}
        ],
        subtotal: 114.97d,
        tax: 10.35d,
        shippingCost: 0.00d,
        totalAmount: 125.32d,
        paymentMethod: "CREDIT_CARD",
        paymentStatus: "PAID",
        shipping: {
            carrier: "FedEx",
            trackingNumber: "FX-7823901234",
            estimatedDelivery: "2026-09-05",
            shippingAddress: "123 Maple St, Boston, MA 02101, USA",
            shippingStatus: "DELIVERED"
        },
        notes: "Leave at door if no answer"
    },
    "ORD-10002": {
        orderId: "ORD-10002",
        orderDate: "2026-09-07T14:15:00Z",
        status: "SHIPPED",
        customer: {
            customerId: "CUST-002",
            customerName: "Bob Martinez",
            email: "bob.martinez@example.com",
            phone: "+1-555-0202"
        },
        items: [
            {productId: "PRD-110", productName: "Mechanical Keyboard", quantity: 1, unitPrice: 149.00d, totalPrice: 149.00d},
            {productId: "PRD-215", productName: "Mouse Pad XL", quantity: 1, unitPrice: 24.99d, totalPrice: 24.99d},
            {productId: "PRD-408", productName: "HDMI Cable 1.5m", quantity: 3, unitPrice: 8.99d, totalPrice: 26.97d}
        ],
        subtotal: 200.96d,
        tax: 18.09d,
        shippingCost: 5.99d,
        totalAmount: 225.04d,
        paymentMethod: "PAYPAL",
        paymentStatus: "PAID",
        shipping: {
            carrier: "UPS",
            trackingNumber: "UPS-1Z999AA10123456784",
            estimatedDelivery: "2026-09-11",
            shippingAddress: "456 Oak Ave, Chicago, IL 60601, USA",
            shippingStatus: "IN_TRANSIT"
        },
        notes: ()
    },
    "ORD-10003": {
        orderId: "ORD-10003",
        orderDate: "2026-09-09T09:00:00Z",
        status: "PROCESSING",
        customer: {
            customerId: "CUST-003",
            customerName: "Carol Lee",
            email: "carol.lee@example.com",
            phone: "+1-555-0303"
        },
        items: [
            {productId: "PRD-720", productName: "4K Monitor 27\"", quantity: 1, unitPrice: 399.00d, totalPrice: 399.00d}
        ],
        subtotal: 399.00d,
        tax: 35.91d,
        shippingCost: 0.00d,
        totalAmount: 434.91d,
        paymentMethod: "DEBIT_CARD",
        paymentStatus: "PAID",
        shipping: {
            carrier: "DHL",
            trackingNumber: "DHL-PENDING",
            estimatedDelivery: "2026-09-14",
            shippingAddress: "789 Pine Rd, Seattle, WA 98101, USA",
            shippingStatus: "PENDING"
        },
        notes: "Fragile - handle with care"
    },
    "ORD-10004": {
        orderId: "ORD-10004",
        orderDate: "2026-09-08T16:45:00Z",
        status: "CANCELLED",
        customer: {
            customerId: "CUST-004",
            customerName: "David Kim",
            email: "david.kim@example.com",
            phone: "+1-555-0404"
        },
        items: [
            {productId: "PRD-330", productName: "Laptop Stand Adjustable", quantity: 2, unitPrice: 45.00d, totalPrice: 90.00d}
        ],
        subtotal: 90.00d,
        tax: 8.10d,
        shippingCost: 7.99d,
        totalAmount: 106.09d,
        paymentMethod: "CREDIT_CARD",
        paymentStatus: "REFUNDED",
        shipping: {
            carrier: "USPS",
            trackingNumber: "N/A",
            estimatedDelivery: "N/A",
            shippingAddress: "321 Elm St, Austin, TX 78701, USA",
            shippingStatus: "CANCELLED"
        },
        notes: "Customer requested cancellation"
    },
    "ORD-10005": {
        orderId: "ORD-10005",
        orderDate: "2026-09-10T11:20:00Z",
        status: "PENDING",
        customer: {
            customerId: "CUST-005",
            customerName: "Eva Patel",
            email: "eva.patel@example.com",
            phone: "+1-555-0505"
        },
        items: [
            {productId: "PRD-601", productName: "Webcam 1080p", quantity: 1, unitPrice: 69.99d, totalPrice: 69.99d},
            {productId: "PRD-602", productName: "Ring Light 10\"", quantity: 1, unitPrice: 34.99d, totalPrice: 34.99d},
            {productId: "PRD-603", productName: "Microphone USB", quantity: 1, unitPrice: 59.99d, totalPrice: 59.99d}
        ],
        subtotal: 164.97d,
        tax: 14.85d,
        shippingCost: 0.00d,
        totalAmount: 179.82d,
        paymentMethod: "CREDIT_CARD",
        paymentStatus: "PENDING",
        shipping: {
            carrier: "TBD",
            trackingNumber: "TBD",
            estimatedDelivery: "2026-09-16",
            shippingAddress: "654 Birch Blvd, Miami, FL 33101, USA",
            shippingStatus: "NOT_SHIPPED"
        },
        notes: ()
    }
};

// Looks up an order by order ID and returns its details or an error message
isolated function lookupOrder(string orderId) returns OrderDetails|string {
    OrderDetails? orderDetails = orderCatalog[orderId];
    if orderDetails is OrderDetails {
        return orderDetails;
    }
    return string `Order '${orderId}' not found. Available orders: ORD-10001, ORD-10002, ORD-10003, ORD-10004, ORD-10005`;
}
