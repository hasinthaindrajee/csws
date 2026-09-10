import ballerinax/mysql;
import ballerinax/mysql.driver as _;

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