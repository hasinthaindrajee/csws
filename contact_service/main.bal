import ballerina/http;
import ballerina/sql;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /contacts on httpDefaultListener {

    // Returns all contacts from the local database
    resource function get .() returns Contact[]|http:InternalServerError {
        Contact[] contactList = [];
        stream<Contact, sql:Error?> resultStream = dbClient->query(`SELECT contact_id, email FROM Contacts`);
        error? iterateError = from Contact contactRecord in resultStream
            do {
                contactList.push(contactRecord);
            };
        if iterateError is error {
            return <http:InternalServerError>{
                body: {message: "Failed to retrieve contacts: " + iterateError.message()}
            };
        }
        return contactList;
    }

    // Returns a single contact by contact_id
    resource function get [string contactId]() returns Contact|http:NotFound|http:InternalServerError {
        Contact|sql:Error result = dbClient->queryRow(`SELECT contact_id, email FROM Contacts WHERE contact_id = ${contactId}`);
        if result is sql:NoRowsError {
            return <http:NotFound>{
                body: {message: string `Contact '${contactId}' not found`}
            };
        }
        if result is sql:Error {
            return <http:InternalServerError>{
                body: {message: "Database error: " + result.message()}
            };
        }
        return result;
    }
}
