({
    myAction : function(component, event, helper) {
        
    },
    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        debugger;
        var accountType = component.get('v.accountType');
        fields.ContactId = fields.NOB_Assure__c;
        fields.NOB_ContactPickup__c = fields.NOB_Assure__c;        
        if(accountType === 'readonly'){
            var apporteur = component.get('v.firstAccount.Id');
            fields.NOB_BusinessProvider__c = apporteur;
        }else if(accountType === 'select'){
            var apporteurSelected = component.find('selectedBusinessProvided').get('v.value');
            fields.NOB_BusinessProvider__c = apporteurSelected;
        }
        component.find('recordForm').submit(fields);
    },
    handleSuccess: function(component, event) {
        let caseId = event.getParams().response.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": caseId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleError	: function(component, event){
        //window.location.href = window.location.href.replace('testcreatecase', '');
    },
    
    handleLoad: function(component, event, helper){
        helper.onInit(component, event, helper);
    },
    
    showCreateContact: function(component, event, helper){
        component.set('v.popupContact', true);
    },
    
    closeCreateContact:  function(component, event, helper){
        component.set('v.popupContact', false);
    },
    
    handleSubmitContact: function(component, event, helper) {
        debugger;
        event.preventDefault();       // stop the form from submitting
        
      //  alert(JSON.stringify(event.getParams()));
        helper.insertContact(component, event, helper);
    },

    handleSuccessContact: function(component, event) {
        let contactId = event.getParams().response.id;
        component.set("v.assureField", contactId);
        component.set('v.popupContact', false);
        
    },

    handleErrorContact	: function(component, event){
        //window.location.href = window.location.href.replace('testcreatecase', '');
    },

    handleLoadContact: function(component, event, helper){
        helper.onInitContact(component, event, helper);
        //helper.getProvinceOptions(component, event, helper);
    }
      
})