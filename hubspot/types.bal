// Represents a synchronized contact with key properties
type ContactProperties record {|
    string contactId;
    string? firstName;
    string? lastName;
    string? email;
    string? phone;
    string? company;
    string? jobTitle;
    string updatedAt;
|};