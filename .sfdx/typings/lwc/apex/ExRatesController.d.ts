declare module "@salesforce/apex/ExRatesController.getRates" {
  export default function getRates(param: {startDate: any, endDate: any, baseCurrency: any}): Promise<any>;
}
declare module "@salesforce/apex/ExRatesController.getCurrenciesPickList" {
  export default function getCurrenciesPickList(param: {objectType: any, selectedField: any}): Promise<any>;
}
