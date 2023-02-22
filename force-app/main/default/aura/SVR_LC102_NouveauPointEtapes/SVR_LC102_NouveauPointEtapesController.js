({
    doInit : function(component, event, helper) {
      console.log('####jpi open', component.get("v.isOpen"));
        helper.checkInitialisationPA(component);
    },
    createChild: function(component, event, helper) {
       helper.cloneAudit(component);
    },

    closeModal: function(component, event, helper) {
      component.set('v.isOpen', false);
      $A.get("e.force:closeQuickAction").fire()
    },

    closeInnerModal: function(component, event, helper) {
      component.set('v.isSuccess', false);
    },
  
 })