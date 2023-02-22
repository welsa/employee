({
  init : function (cmp) {
    var flow = cmp.find("flowData");
    flow.startFlow("NOB_MesDocumentsNew");
  },
  statusChange : function (cmp, event) {
      if (event.getParam('status') === "FINISHED") {
       var outputVariables = event.getParam("outputVariables");
        var outputVar;
        for(var i = 0; i < outputVariables.length; i++) {
          outputVar = outputVariables[i];
          if(outputVar.name === "redirect") {
              console.log(outputVar.value);
              var urlEvent = $A.get("e.force:navigateToSObject");
              urlEvent.setParams({
                "recordId": outputVar.value,
                "isredirect": "true"
              });
              urlEvent.fire();
          }
        }
      }
  }
})