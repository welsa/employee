({
	manageDisplay : function(component, event, helper) {

		console.log('manageDisplay');
        var isShow = component.get("v.showTable");
        if(isShow){
            component.set("v.showTable", false);
        }else{
            component.set("v.showTable", true);
        }
	},
})