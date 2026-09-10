import ballerinax/hubspot.crm.obj.contacts;
import ballerina/log;
import ballerina/time;
import ballerina/sql;

// Searches for contacts updated within the last 60 seconds, with optional pagination cursor
function fetchRecentlyUpdatedContacts(string? afterCursor) returns contacts:CollectionResponseWithTotalSimplePublicObjectForwardPaging|error {
    // Compute timestamp for 60 seconds ago in milliseconds
    time:Utc nowUtc = time:utcNow();
    int nowMillis = nowUtc[0] * 1000;
    int oneMinuteAgoMillis = nowMillis - 60000;

    contacts:Filter lastModifiedFilter = {
        propertyName: "lastmodifieddate",
        operator: "GTE",
        value: oneMinuteAgoMillis.toString()
    };
    contacts:FilterGroup filterGroup = {
        filters: [lastModifiedFilter]
    };
    contacts:PublicObjectSearchRequest searchRequest = {
        filterGroups: [filterGroup],
        properties: ["firstname", "lastname", "email", "phone", "company", "jobtitle"],
        'limit: 100,
        after: afterCursor
    };
    return hubspotContactsClient->/search.post(payload = searchRequest);
}

// Maps a HubSpot contact object to a ContactProperties record
function mapToContactProperties(contacts:SimplePublicObject hubspotContact) returns ContactProperties {
    record {|string?...;|} props = hubspotContact.properties;
    return {
        contactId: hubspotContact.id,
        firstName: props["firstname"],
        lastName: props["lastname"],
        email: props["email"],
        phone: props["phone"],
        company: props["company"],
        jobTitle: props["jobtitle"],
        updatedAt: hubspotContact.updatedAt
    };
}

// Inserts a contact or updates the email if the contact_id already exists
function upsertContact(ContactProperties contactProps) returns error? {
    string contactId = contactProps.contactId;
    string emailValue = contactProps.email ?: "";
    sql:ParameterizedQuery upsertQuery = `INSERT INTO Contacts (contact_id, email)
        VALUES (${contactId}, ${emailValue})
        ON DUPLICATE KEY UPDATE email = ${emailValue}`;
    _ = check dbClient->execute(upsertQuery);
}

// Logs the contact properties to the console
function logContactProperties(ContactProperties contactProps) {
    log:printInfo(string `Contact Synced | ID: ${contactProps.contactId}`);
    log:printInfo(string `  Name      : ${contactProps.firstName ?: "-"} ${contactProps.lastName ?: "-"}`);
    log:printInfo(string `  Email     : ${contactProps.email ?: "-"}`);
    log:printInfo(string `  Phone     : ${contactProps.phone ?: "-"}`);
    log:printInfo(string `  Company   : ${contactProps.company ?: "-"}`);
    log:printInfo(string `  Job Title : ${contactProps.jobTitle ?: "-"}`);
    log:printInfo(string `  Updated At: ${contactProps.updatedAt}`);
}