// A single line item in an order
type OrderItem record {|
    string productId;
    string productName;
    int quantity;
    decimal unitPrice;
    decimal totalPrice;
|};

// Shipping information for an order
type ShippingInfo record {|
    string carrier;
    string trackingNumber;
    string estimatedDelivery;
    string shippingAddress;
    string shippingStatus;
|};

// Customer information
type CustomerInfo record {|
    string customerId;
    string customerName;
    string email;
    string phone;
|};

// Full order details
type OrderDetails record {|
    string orderId;
    string orderDate;
    string status;
    CustomerInfo customer;
    OrderItem[] items;
    decimal subtotal;
    decimal tax;
    decimal shippingCost;
    decimal totalAmount;
    string paymentMethod;
    string paymentStatus;
    ShippingInfo shipping;
    string? notes;
|};
