declare module "@salesforce/apex/ExRatesLoader.loadRates" {
  export default function loadRates(param: {startDate: any, endDate: any}): Promise<any>;
}
