import ballerina/http;

final http:Client soapClient = check new http:Client(
    "http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso"
);