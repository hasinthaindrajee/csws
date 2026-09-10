import ballerinax/hubspot.crm.obj.contacts;
import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final contacts:Client hubspotContactsClient = check new contacts:Client(
    config = {
        auth: <http:BearerTokenConfig>{
            token: hubspotAccessToken
        }
    }
);

final mysql:Client dbClient = check new mysql:Client(
    host = dbHost,
    port = dbPort,
    user = dbUser,
    password = dbPassword,
    database = dbName,
    options = {
        ssl: {
            mode: "REQUIRED"
        }
    }
);