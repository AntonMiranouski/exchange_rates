public with sharing class ExRatesController {
    
    @AuraEnabled
    public static List<Exchange_Rate__c> getRates(String startDate, String endDate, String baseCurrency){
       
        //If the dates is from the future then set it as today
        if (startDate != null && Date.valueOf(startDate) >= Date.today()) {
            startDate = String.valueOf(Date.today().addDays(-1));
        } else if (startDate != null && Date.valueOf(startDate) < Date.valueOf('1999-01-04')){
            throw new AuraHandledException('There is no data for dates older then 1999-01-04');
        }

        if (endDate != null && Date.valueOf(endDate) >= Date.today()) {
            endDate = String.valueOf(Date.today().addDays(-1));
        }

        List<Exchange_Rate__c> rates = new List<Exchange_Rate__c>();
        String query = ' ';
        for (String c : ExRatesUtils.getCurrencyNames()) {
            query += c + ', ';
        }

        //Get latest record
        if (endDate == null && startDate == null) {
            rates = Database.query(
                'SELECT' + query + 'Id, Date__c, BaseCurrency__c FROM Exchange_Rate__c ORDER BY Date__c DESC LIMIT 1'
            );
        }
        
        //Get record for one day
        else if(endDate == null && startDate != null){
            rates = Database.query(
                'SELECT' + query + 'Id, Date__c, BaseCurrency__c FROM Exchange_Rate__c ' +
                'WHERE Date__c = ' + startDate
            );
            if (rates.size() < 1) {
                ExRatesLoader.loadRates(startDate, endDate);
                rates = Database.query(
                    'SELECT' + query + 'Id, Date__c, BaseCurrency__c FROM Exchange_Rate__c ' +
                    'WHERE Date__c = ' + startDate
                );
            }
        }
        
        //Get records for period
        else {
            rates = Database.query(
                'SELECT' + query + 'Id, Date__c, BaseCurrency__c FROM Exchange_Rate__c ' +
                'WHERE Date__c >= ' + startDate +
                ' AND Date__c <= ' + endDate +
                ' ORDER BY Date__c DESC'
            );
            
            Integer daysBetween = (Date.valueOf(startDate).daysBetween(Date.valueOf(endDate)) + 1);
            Integer startDateDayNumber = ExRatesUtils.dayOfWeekNumber(Date.valueOf(startDate));
			
            //Check if all data is already loaded
            if (daysBetween > 730){
                throw new AuraHandledException('Sorry, the rates limit is two years for one request');
            } else if (rates.size() < daysBetween) {
                if(startDateDayNumber == 6 || startDateDayNumber == 0){
                    try {
                        ExRatesLoader.loadRates(String.valueOf(Date.valueOf(startDate).addDays(-2)), endDate);
                    } catch(DmlException e) {
                        throw new AuraHandledException(e.getMessage());
                    }
                } else {
                    try {
                        ExRatesLoader.loadRates(startDate, endDate);
                    } catch(DmlException e) {
                        throw new AuraHandledException(e.getMessage());
                    }
                }
                rates = Database.query(
                    'SELECT' + query + 'Id, Date__c, BaseCurrency__c FROM Exchange_Rate__c ' +
                    'WHERE Date__c >= ' + startDate +
                    ' AND Date__c <= ' + endDate +
                    ' ORDER BY Date__c DESC'
                );
            }
        }

        Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.BaseCurrency__c.getDescribe();
        String defaultBaseCurrency = (String)fieldResult.getDefaultValue();

        //Recalculate rates if necessary
        if (baseCurrency != defaultBaseCurrency && baseCurrency != null && baseCurrency != '') {
            return ExRatesUtils.calcRates(rates, baseCurrency);
        } else if (rates.size() < 1) {
            throw new AuraHandledException('Data for this day/period is not available');
        }
        else {
            return rates;
        }
    }

    @AuraEnabled        
    public static List<String> getCurrenciesPickList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }
}