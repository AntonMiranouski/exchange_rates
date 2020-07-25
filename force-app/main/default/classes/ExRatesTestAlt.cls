@isTest
private class ExRatesTestAlt {

    @isTest
    static void testGetPerPeriod() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ExRatesPeriodAlt');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
		
        Test.StartTest();
        List<Exchange_Rate__c> rates = ExRatesController.getRates('2020-05-05', '2020-05-07', 'CAD');
        Test.StopTest();
        
        System.assertEquals(3, rates.size());
        System.assertEquals('CAD', rates[0].BaseCurrency__c);
        System.assertEquals(1, rates[0].CAD__c);
    }
}