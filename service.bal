import ballerinax/exchangerates;
import ramith/countryprofile;
import ballerina/log;
import ballerina/http;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get convert(decimal amount = 1.0, string target = "AUD", string base = "USD") returns PricingInfo|error {

        log:printInfo("new request:", base = base, target = target, amount = amount);
        countryprofile:Client countryprofileEp = check new (config = {
            auth: {
                clientId: clientId,
                clientSecret: clientSecret
            }
        });
        exchangerates:Client exchangeratesEp = check new ();
        countryprofile:Currency getCurrencyCodeResponse = check countryprofileEp->getCurrencyCode(code = target);
        exchangerates:CurrencyExchangeInfomation getExchangeRateForResponse = check exchangeratesEp->getExchangeRateFor(apikey = apikey, baseCurrency = base);

        decimal exchangeRate = <decimal>getExchangeRateForResponse.conversion_rates[target];

        decimal convertedAmount = amount * exchangeRate;

        PricingInfo pricingInfo = {
            currencyCode: target,
            displayName: getCurrencyCodeResponse.displayName,
            amount: convertedAmount
        };


        return pricingInfo;
    }
}

type PricingInfo record {
    string currencyCode;
    string displayName;
    decimal amount;
};


configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string apikey = ?;