public with sharing class RecordsCreator {

    //Creating a record for a single day
    public static void createOne(ExRatesWrapper wrapper, Id logId) {
        ExRatesWrapper.Rates rates = wrapper.rates;
        
        Exchange_Rate__c newRecord = new Exchange_Rate__c(
            Date__c = Date.valueOf(wrapper.day),
            Name = wrapper.day,
            BaseCurrency__c = wrapper.base,
            Log__c = logId
        );

        for (String c : ExRatesUtils.getCurrencyNames()){
            newRecord.put(c, (Double)rates.get(c.remove('__c').toUpperCase()));
        }

        upsert newRecord Name;
        
        //Duplicating friday values for the weekend
        if (ExRatesUtils.dayOfWeekNumber(newRecord.Date__c) == 5) {
            Exchange_Rate__c satRate = newRecord.clone(false, true, false, false);
            satRate.Date__c = Date.valueOf(wrapper.day).addDays(1);
            satRate.Name = String.valueOf(Date.valueOf(wrapper.day).addDays(1));
            upsert satRate Name;

            Exchange_Rate__c sunRate = newRecord.clone(false, true, false, false);
            sunRate.Date__c = Date.valueOf(wrapper.day).addDays(2);
            sunRate.Name = String.valueOf(Date.valueOf(wrapper.day).addDays(2));
            upsert sunRate Name;
        }
    }

    //Creating a record for a period
    public static void createMany(ExRatesPeriodWrapper wrapper, Id logId){
        Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.BaseCurrency__c.getDescribe();
        String baseCurrency = (String)fieldResult.getDefaultValue();
        
        List<ExRatesPeriodWrapper.Rates> rates = wrapper.rates;
        List<Exchange_Rate__c> newRecords = new List<Exchange_Rate__c>();
        for (ExRatesPeriodWrapper.Rates r : rates) {
            Exchange_Rate__c newRecord = new Exchange_Rate__c(
                Date__c = Date.valueOf(r.day),
                Name = r.day,
                BaseCurrency__c = baseCurrency,
                Log__c = logId
            );
            
            for (String c : ExRatesUtils.getCurrencyNames()){
                newRecord.put(c, (Double)r.get(c.remove('__c').toUpperCase()));
            }

            newRecords.add(newRecord);

            //Duplicate friday values for the weekend
            if (ExRatesUtils.dayOfWeekNumber(newRecord.Date__c) == 5) {
                Exchange_Rate__c satRate = newRecord.clone(false, true, false, false);
                satRate.Date__c = Date.valueOf(r.day).addDays(1);
                satRate.Name = String.valueOf(Date.valueOf(r.day).addDays(1));
                newRecords.add(satRate);
    
                Exchange_Rate__c sunRate = newRecord.clone(false, true, false, false);
                sunRate.Date__c = Date.valueOf(r.day).addDays(2);
                sunRate.Name = String.valueOf(Date.valueOf(r.day).addDays(2));
                newRecords.add(sunRate);
            }
        }
        upsert newRecords Name;
    }

    public static Id createLogs(HttpResponse response) {
        Log__c log = new Log__c(
            Status_Code__c = String.valueOf(response.getStatusCode()),
            Response_Body__c = response.getBody()
        );
        
        Id logId;
        try {
            logId = Database.insert(log).getId();
        } catch (DmlException e) {
            log.Response_Body__c = e.getMessage();
            logId = Database.insert(log).getId();
        }
        return logId;
    }
}