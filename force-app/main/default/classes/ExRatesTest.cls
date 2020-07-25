@isTest
private class ExRatesTest {
	
    @isTest
    static void testSchedule() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExchangeRatesDay');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Log__c log = new Log__c(
            Status_Code__c = '500',
            Response_Body__c = ''
        );
        Id logId = Database.insert(log).getId();
        
        Exchange_Rate__c newRecord = new Exchange_Rate__c(
            Date__c = Date.valueOf('2020-04-24'),
            Log__c = logId
        );
        insert newRecord;
        
        String CRON_EXP = '0 0 0 30 12 ? 2020';
        
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new ExRatesLoader());
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE id = :jobId
        ];
        Test.stopTest();
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2020-12-30 00:00:00', String.valueOf(ct.NextFireTime));
    }
    
    @isTest 
    static void testGetPerDay() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExchangeRatesDay');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.StartTest();
        List<Exchange_Rate__c> rates = ExRatesController.getRates('2020-04-24', null, null);
        Test.StopTest();
        
        System.assertEquals('2020-04-24', String.valueOf(rates[0].Date__c));
        System.assertEquals('GBP', rates[0].BaseCurrency__c);
        System.assertEquals(1.7340967794, rates[0].CAD__c);
    }
    
    @isTest
    static void testGetPerPeriod() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExchangeRatesPeriod');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
		
        Test.StartTest();
        List<Exchange_Rate__c> rates = ExRatesController.getRates('2020-04-26', '2020-04-30', 'CAD');
        Test.StopTest();
        
        System.assertEquals(5, rates.size());
        System.assertEquals('2020-04-30', String.valueOf(rates[0].Date__c));
        System.assertEquals('CAD', rates[0].BaseCurrency__c);
        System.assertEquals(1, rates[0].CAD__c);
    }
    
    @isTest 
    static void testGetLast() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExchangeRatesPeriod');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.StartTest();
        ExRatesLoader.loadRates('2020-04-28', '2020-04-30');
        List<Exchange_Rate__c> rates = ExRatesController.getRates(null, null, null);
        Test.StopTest();
        
        System.assertEquals('2020-04-30', String.valueOf(rates[0].Date__c));
        System.assertEquals('GBP', rates[0].BaseCurrency__c);
        System.assertEquals(1.7348829181, rates[0].CAD__c);
    }
    
    @isTest
    static void testCurrenciesPickList() {
        List<String> actCurrencies = ExRatesController.getCurrenciesPickList('Exchange_Rate__c', 'BaseCurrency__c');
    	List<String> expCurrencies = new List<String>{'GBP', 'EUR', 'CAD', 'USD'};
    	System.assertEquals(expCurrencies, actCurrencies);
    }
}