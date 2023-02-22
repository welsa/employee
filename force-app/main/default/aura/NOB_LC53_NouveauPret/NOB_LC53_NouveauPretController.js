({
    closeScreen : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    refresh : function(component, event, helper) {
        var refreshCmp = $A.get('e.force:refreshView');
        refreshCmp.fire();
    }
})