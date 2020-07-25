public with sharing class DataChecker {
    
    //Check if a server has been available in the past
    public static void check() {
        List<Log__c> logs = [SELECT Id FROM Log__c WHERE Status_Code__c != '200'];
        List<Id> logIds = new List<Id>();
        for (Log__c l : logs) {
            logIds.add(l.Id);
        }
        
        if (logs.size() > 0) {
            List<Exchange_Rate__c> rates = [SELECT Id, Date__c FROM Exchange_Rate__c WHERE Log__c IN :logIds];
            for (Exchange_Rate__c r : rates) {
                ExRatesLoader.loadHelper(String.valueOf(r.Date__c), null);
            }
        }
    }
}