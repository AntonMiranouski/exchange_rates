public class ExRatesUtils {

    public static List<String> getCurrencyNames(){
        Schema.DescribeSObjectResult r = Exchange_Rate__c.sObjectType.getDescribe();
        List <String> curNames = new list <String>();
        for (String curName: r.fields.getMap().keySet()) {
            Schema.DisplayType fielddataType = r.fields.getMap().get(curName).getDescribe().getType();
            if(fielddataType == Schema.DisplayType.CURRENCY){
                curNames.add(curName);
            }
        }
        return curNames;
    }
    
    //Calculate rates with new base currency
    public static List<Exchange_Rate__c> calcRates(List<Exchange_Rate__c> rates, String newBaseCurrency){
        Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.BaseCurrency__c.getDescribe();
        String oldBaseCurrency = (String)fieldResult.getDefaultValue();
        oldBaseCurrency += '__c';
        newBaseCurrency += '__c';

        List<String> curNames = getCurrencyNames();
        
        for (Exchange_Rate__c r : rates) {
            Double valueNBC = (Double)r.get(newBaseCurrency);
            r.put(oldBaseCurrency, 1 / valueNBC);
            r.put(newBaseCurrency, 1);
            r.put('BaseCurrency__c', newBaseCurrency.remove('__c'));
            for(String c : curNames){
                if (c != oldBaseCurrency && c != newBaseCurrency && (Double)r.get(c) != null) {
                    r.put(c, 1 / valueNBC * (Double)r.get(c));
                }
            }
        }
    
        return rates; 
    }

    public static Integer dayOfWeekNumber(Date aDate) {
        return Math.mod(Date.newInstance(1900, 1, 7).daysBetween(aDate),7);
    }
}