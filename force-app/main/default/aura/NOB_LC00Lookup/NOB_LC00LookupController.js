({
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    
    handleFocus: function(component,event,helper){
      component.set('v.hasFocus', true);  
      helper.serverCall(component, event, helper);
    },
    handleBlur: function(component, event, helper){
        var blurTimeout = window.setTimeout(() => {
                component.set('v.hasFocus', false);
                blurTimeout = null;
            },
            300
        );
    },
    clearSelection : function(component, event, helper){
        
        helper.clearSelection(component, event, helper);
    },
    doSetCompetences: function(cmp, event, helper){
        var params = event.getParam('arguments');
        if (params) {
            var competences = params.competences;
            cmp.set('v.competences', competences);
           // alert(JSON.stringify(competences));
        }
    }
})