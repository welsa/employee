({
    doInit : function(component, event, helper) {
        helper.assignRecordTypeId(component);
        helper.checkRecordTypeName(component);
        helper.getNomDuGestionnaire(component);
    },
  
    handleSuccess: function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(JSON.stringify(payload));
  
        $A.get("e.force:closeQuickAction").fire();
        helper.messageSuccess(component, payload.id);
    },
  
    closeModal: function(component, event, helper) {
        component.set('v.isOpen', false);
        $A.get("e.force:closeQuickAction").fire()
      },
  
  })