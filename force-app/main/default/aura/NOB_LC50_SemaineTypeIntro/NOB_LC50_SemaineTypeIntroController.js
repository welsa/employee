({
	init : function(cmp, event, helper) {
		 var action = cmp.get("c.getSemaineType");
        //cmp.set("v.loading", true);
        let days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

               let redi = true;
               let js = response.getReturnValue();
                if(js && js !== ''){
                    let config = JSON.parse(js);
                    if(config.config){
                        config = config.config;
                    }
                    for(let day of days){
                        let dday = config[day];
                        if(dday){
                            if(dday.dispo && dday.dispo.length > 0){
                                redi = false;
                                break;
                            }
                            if(dday.abs && dday.abs.length > 0){
                                redi = false;
                                break;
                            }
                        }
                    }
                }
                
                if(redi)
                    	window.location.href = window.location.href.split('/s')[0] + '/s/semainetype';
            
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                cmp.set("v.loading", false);
      	       	var errors = response.getError();
               
            }
        });

        $A.enqueueAction(action);
	}
})