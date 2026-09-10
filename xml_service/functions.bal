import ballerina/http;
import ballerina/lang.regexp;

const string SOAP_ACTION_BASE = "http://www.oorsprong.org/websamples.countryinfo/CountryInfoService.wso/";
const string CONTENT_TYPE_XML = "text/xml; charset=utf-8";

const string SOAP_NS = "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"";
const string WEB_NS = "xmlns:web=\"http://www.oorsprong.org/websamples.countryinfo\"";

// Builds the SOAP envelope for operations that take no parameters
function buildNoParamEnvelope(string operation) returns xml|error {
    string envStr = string `<soap:Envelope ${SOAP_NS} ${WEB_NS}><soap:Body><web:${operation}/></soap:Body></soap:Envelope>`;
    return check xml:fromString(envStr);
}

// Builds the SOAP envelope for operations that take a single ISO country code
function buildCountryCodeEnvelope(string operation, string isoCode) returns xml|error {
    string envStr = string `<soap:Envelope ${SOAP_NS} ${WEB_NS}><soap:Body><web:${operation}><web:sCountryISOCode>${isoCode}</web:sCountryISOCode></web:${operation}></soap:Body></soap:Envelope>`;
    return check xml:fromString(envStr);
}

// Builds the SOAP envelope for CurrencyName (takes ISO currency code)
function buildCurrencyCodeEnvelope(string isoCurrencyCode) returns xml|error {
    string envStr = string `<soap:Envelope ${SOAP_NS} ${WEB_NS}><soap:Body><web:CurrencyName><web:sCurrencyISOCode>${isoCurrencyCode}</web:sCurrencyISOCode></web:CurrencyName></soap:Body></soap:Envelope>`;
    return check xml:fromString(envStr);
}

// Builds the SOAP envelope for LanguageName (takes ISO language code)
function buildLanguageCodeEnvelope(string isoLangCode) returns xml|error {
    string envStr = string `<soap:Envelope ${SOAP_NS} ${WEB_NS}><soap:Body><web:LanguageName><web:sISOCode>${isoLangCode}</web:sISOCode></web:LanguageName></soap:Body></soap:Envelope>`;
    return check xml:fromString(envStr);
}

// Sends a SOAP request and returns the raw response XML
function callSoap(xml envelope, string operation) returns xml|error {
    http:Response soapResponse = check soapClient->post(
        "/",
        envelope,
        headers = {
            "SOAPAction": SOAP_ACTION_BASE + operation,
            "Content-Type": CONTENT_TYPE_XML
        }
    );
    return check soapResponse.getXmlPayload();
}

// Extracts the text value of a named element from an XML string (namespace-agnostic)
// Matches both <ns:tagName>value</ns:tagName> and <tagName>value</tagName>
function extractByTagName(string xmlStr, string tagName) returns string|error {
    string:RegExp pattern = check regexp:fromString(string `<[^:>]+:${tagName}[^>]*>([^<]*)<`);
    regexp:Groups? groups = pattern.findGroups(xmlStr);
    if groups is regexp:Groups && groups.length() > 1 {
        regexp:Span? span = groups[1];
        if span is regexp:Span {
            return span.substring().trim();
        }
    }
    // Fallback: try without namespace prefix
    string:RegExp plainPattern = check regexp:fromString(string `<${tagName}[^>]*>([^<]*)<`);
    regexp:Groups? plainGroups = plainPattern.findGroups(xmlStr);
    if plainGroups is regexp:Groups && plainGroups.length() > 1 {
        regexp:Span? span = plainGroups[1];
        if span is regexp:Span {
            return span.substring().trim();
        }
    }
    return "";
}

// Extracts all repeated blocks matching a tag name and returns their raw XML strings
function extractRepeatedBlocks(string xmlStr, string tagName) returns string[]|error {
    string[] blocks = [];
    string:RegExp pattern = check regexp:fromString(string `<[^:>]+:${tagName}[^>]*>[\s\S]*?</[^:>]+:${tagName}>`);
    regexp:Span[] matches = pattern.findAll(xmlStr);
    foreach regexp:Span matchSpan in matches {
        blocks.push(matchSpan.substring());
    }
    return blocks;
}

// Parses a list response into CodeNamePair[] by extracting the first and second child text
// from each item element. Works for continents (sCode/sName), countries (sISOCode/sName),
// currencies (sISOCode/sName), and languages (sISOCode/sName).
function parseCodeNameList(xml responseXml) returns CodeNamePair[]|error {
    CodeNamePair[] resultList = [];
    string xmlStr = responseXml.toString();
    // Match each item element: any element with exactly two child elements
    // Pattern: <ns:tag ...> whitespace <ns:child1>value1</ns:child1> whitespace <ns:child2>value2</ns:child2> whitespace </ns:tag>
    string:RegExp itemPattern = check regexp:fromString(
        "<[^:>]+:[^>]+>\\s*<[^:>]+:[^>]+>([^<]*)</[^:>]+:[^>]+>\\s*<[^:>]+:[^>]+>([^<]*)</[^:>]+:[^>]+>\\s*</[^:>]+:[^>]+>"
    );
    regexp:Groups[] allGroups = itemPattern.findAllGroups(xmlStr);
    foreach regexp:Groups groups in allGroups {
        if groups.length() > 2 {
            regexp:Span? codeSpan = groups[1];
            regexp:Span? nameSpan = groups[2];
            string isoCode = codeSpan is regexp:Span ? codeSpan.substring().trim() : "";
            string name = nameSpan is regexp:Span ? nameSpan.substring().trim() : "";
            if isoCode != "" || name != "" {
                resultList.push({sISOCode: isoCode, sName: name});
            }
        }
    }
    return resultList;
}

// Parses FullCountryInfo response into a FullCountryInfo record
function parseFullCountryInfo(xml responseXml) returns FullCountryInfo|error {
    string xmlStr = responseXml.toString();
    return {
        sISOCode: check extractByTagName(xmlStr, "sISOCode"),
        sName: check extractByTagName(xmlStr, "sName"),
        sCapitalCity: check extractByTagName(xmlStr, "sCapitalCity"),
        sPhoneCode: check extractByTagName(xmlStr, "sPhoneCode"),
        sContinentCode: check extractByTagName(xmlStr, "sContinentCode"),
        sCurrencyISOCode: check extractByTagName(xmlStr, "sCurrencyISOCode"),
        sCountryFlag: check extractByTagName(xmlStr, "sCountryFlag"),
        sLanguageISOCode: check extractByTagName(xmlStr, "sLanguageISOCode"),
        sLanguageName: check extractByTagName(xmlStr, "sLanguageName")
    };
}

// Extracts a single named value from the SOAP response XML string
function extractSingleValue(xml responseXml, string tagName) returns string|error {
    string xmlStr = responseXml.toString();
    return check extractByTagName(xmlStr, tagName);
}