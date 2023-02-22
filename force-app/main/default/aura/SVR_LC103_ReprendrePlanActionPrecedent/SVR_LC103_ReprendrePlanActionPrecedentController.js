({
    doInit : function (component, event, helper){
      console.log('####### recordId: ' + component.get("v.recordId"));
    },

    retakeChild: function(component, event, helper) {
       helper.clonePlanAction(component);
    },

    closeModal: function(component, event, helper) {
      component.set('v.isOpen', false);
      $A.get("e.force:closeQuickAction").fire();
    },

    closeInnerModal: function(component, event, helper) {
      component.set('v.isSuccess', false);
    },
  
 })