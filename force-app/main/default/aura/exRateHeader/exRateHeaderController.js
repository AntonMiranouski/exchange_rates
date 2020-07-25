({
  doInit: function (component, event, helper) {
    var action = component.get("c.getRates");
    action.setParams({
      startDate: component.find("startDate").get("v.value"),
      endDate: component.find("endDate").get("v.value"),
      baseCurrency: component.find("sc").get("v.value")
    });
    action.setCallback(this, function (response) {
      var responseValue = response.getReturnValue();

      if (response.getState() === "SUCCESS") {
        component.set("v.exRates", responseValue);
        helper.setColumns(component, responseValue[0]);
      } else if (response.getState() === "ERROR") {
        var errors = action.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            alert(errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action, false);
  },

  handleSubmit: function (component, event, helper) {
    var action = component.get("c.getRates");
    action.setParams({
      startDate: component.find("singleDay").get("v.value"),
      endDate: null,
      baseCurrency: component.find("sc").get("v.value")
    });
    action.setCallback(this, function (response) {
      var responseValue = response.getReturnValue();

      if (response.getState() === "SUCCESS") {
        component.set("v.exRates", responseValue);
        helper.setColumns(component, responseValue[0]);
      } else if (response.getState() === "ERROR") {
        var errors = action.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            alert(errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action, true);
  }
});