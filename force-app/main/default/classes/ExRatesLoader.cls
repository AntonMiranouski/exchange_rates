public with sharing class ExRatesLoader implements Schedulable{
    
    public void execute(SchedulableContext sc){
        DataChecker.check();
        loadHelper(null, null);
    }

    @AuraEnabled
    public static void loadRates(String startDate, String endDate){
        ExRatesAPI__mdt mdt = [SELECT URL__c FROM ExRatesAPI__mdt WHERE MasterLabel = 'Default'];
        String endpoint = mdt.URL__c;
        Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.BaseCurrency__c.getDescribe();
        String baseCurrency = (String)fieldResult.getDefaultValue();
        
        //Load latest rates
        if (startDate == null ) {
            endpoint += 'latest?base=' + baseCurrency;
            
            HttpResponse response = callout(endpoint);
            ExRatesWrapper erw = ExRatesWrapper.parse(response.getBody());
            Id logId = RecordsCreator.createLogs(response);
            RecordsCreator.createOne(erw, logId);
        }

        //Load rates for period
        else if (startDate != null && endDate != null) {
            endpoint += 'history?start_at=' + startDate + '&end_at=' + endDate + '&base=' + baseCurrency;
            
            HttpResponse response = callout(endpoint);
            ExRatesPeriodWrapper erpw = ExRatesPeriodWrapper.parse(response.getBody());
            Id logId = RecordsCreator.createLogs(response);
            RecordsCreator.createMany(erpw, logId);
        }
         
        //Load rates for one day
        else if (startDate != null && endDate == null) {
            endpoint += startDate + '?base=' + baseCurrency;
            
            HttpResponse response = callout(endpoint);
            ExRatesWrapper erw = ExRatesWrapper.parse(response.getBody());
            Id logId = RecordsCreator.createLogs(response);
            RecordsCreator.createOne(erw, logId);
        }
    }

    public static HttpResponse callout(String endpoint){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        return http.send(request);
    }

    @future(callout = true)
    public static void loadHelper(String startDate, String endDate){
        loadRates(startDate, endDate);
    }
}