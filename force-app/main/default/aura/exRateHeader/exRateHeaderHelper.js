({
    setColumns: function (component, ExRateItem) {
		delete ExRateItem.Id;
		delete ExRateItem.BaseCurrency__c;
		let columns = [];
		for (const fieldName in ExRateItem) {
			let type = fieldName == 'Date__c' ? 'date' : 'number';
			columns.push({
				label: fieldName.replace('__c', ''),
				fieldName: fieldName,
				type: type,
				typeAttributes: {
					minimumFractionDigits: "4",
					year: "numeric",
					month: "long",
					day: "2-digit"
				}
			});
		}
		component.set("v.columns", columns)
	}
})