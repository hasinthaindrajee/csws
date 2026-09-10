import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

// REST mediator for the CountryInfoService SOAP backend
service /country on httpDefaultListener {

    // GET /country/continents - List all continents ordered by name
    resource function get continents() returns CodeNamePair[]|error {
        xml envelope = check buildNoParamEnvelope("ListOfContinentsByName");
        xml responseXml = check callSoap(envelope, "ListOfContinentsByName");
        return parseCodeNameList(responseXml);
    }

    // GET /country/currencies - List all currencies ordered by name
    resource function get currencies() returns CodeNamePair[]|error {
        xml envelope = check buildNoParamEnvelope("ListOfCurrenciesByName");
        xml responseXml = check callSoap(envelope, "ListOfCurrenciesByName");
        return parseCodeNameList(responseXml);
    }

    // GET /country/languages - List all languages ordered by name
    resource function get languages() returns CodeNamePair[]|error {
        xml envelope = check buildNoParamEnvelope("ListOfLanguagesByName");
        xml responseXml = check callSoap(envelope, "ListOfLanguagesByName");
        return parseCodeNameList(responseXml);
    }

    // GET /country/countries - List all countries ordered by name
    resource function get countries() returns CodeNamePair[]|error {
        xml envelope = check buildNoParamEnvelope("ListOfCountryNamesByName");
        xml responseXml = check callSoap(envelope, "ListOfCountryNamesByName");
        return parseCodeNameList(responseXml);
    }

    // GET /country/{isoCode} - Get full country info by ISO code (e.g. US, GB, DE)
    resource function get [string isoCode]() returns FullCountryInfo|error {
        xml envelope = check buildCountryCodeEnvelope("FullCountryInfo", isoCode);
        xml responseXml = check callSoap(envelope, "FullCountryInfo");
        return parseFullCountryInfo(responseXml);
    }

    // GET /country/{isoCode}/capital - Get capital city for a country
    resource function get [string isoCode]/capital() returns StringValueResponse|error {
        xml envelope = check buildCountryCodeEnvelope("CapitalCity", isoCode);
        xml responseXml = check callSoap(envelope, "CapitalCity");
        return {value: check extractSingleValue(responseXml, "CapitalCityResult")};
    }

    // GET /country/{isoCode}/currency - Get currency for a country
    resource function get [string isoCode]/currency() returns CurrencyInfo|error {
        xml envelope = check buildCountryCodeEnvelope("CountryCurrency", isoCode);
        xml responseXml = check callSoap(envelope, "CountryCurrency");
        string xmlStr = responseXml.toString();
        return {
            sISOCode: check extractByTagName(xmlStr, "sISOCode"),
            sName: check extractByTagName(xmlStr, "sName")
        };
    }

    // GET /country/{isoCode}/phoneCode - Get international phone code for a country
    resource function get [string isoCode]/phoneCode() returns StringValueResponse|error {
        xml envelope = check buildCountryCodeEnvelope("CountryIntPhoneCode", isoCode);
        xml responseXml = check callSoap(envelope, "CountryIntPhoneCode");
        return {value: check extractSingleValue(responseXml, "CountryIntPhoneCodeResult")};
    }

    // GET /country/{isoCode}/flag - Get flag image URL for a country
    resource function get [string isoCode]/flag() returns StringValueResponse|error {
        xml envelope = check buildCountryCodeEnvelope("CountryFlag", isoCode);
        xml responseXml = check callSoap(envelope, "CountryFlag");
        return {value: check extractSingleValue(responseXml, "CountryFlagResult")};
    }

    // GET /country/currency/{isoCurrencyCode}/name - Get currency name by ISO currency code
    resource function get currency/[string isoCurrencyCode]/name() returns StringValueResponse|error {
        xml envelope = check buildCurrencyCodeEnvelope(isoCurrencyCode);
        xml responseXml = check callSoap(envelope, "CurrencyName");
        return {value: check extractSingleValue(responseXml, "CurrencyNameResult")};
    }

    // GET /country/language/{isoLangCode}/name - Get language name by ISO language code
    resource function get language/[string isoLangCode]/name() returns StringValueResponse|error {
        xml envelope = check buildLanguageCodeEnvelope(isoLangCode);
        xml responseXml = check callSoap(envelope, "LanguageName");
        return {value: check extractSingleValue(responseXml, "LanguageNameResult")};
    }
}
