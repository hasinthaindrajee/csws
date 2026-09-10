// Response for a single string value (e.g. country name, capital, phone code)
type StringValueResponse record {|
    string value;
|};

// A code+name pair used in list responses
type CodeNamePair record {|
    string sISOCode;
    string sName;
|};

// Currency info returned by CountryCurrency
type CurrencyInfo record {|
    string sISOCode;
    string sName;
|};

// Full country info returned by FullCountryInfo
type FullCountryInfo record {|
    string sISOCode;
    string sName;
    string sCapitalCity;
    string sPhoneCode;
    string sContinentCode;
    string sCurrencyISOCode;
    string sCountryFlag;
    string sLanguageISOCode;
    string sLanguageName;
|};