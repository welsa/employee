({
	init : function(component, event, helper) {
		let options = [];
        for(let i = 6; i<=21;i++){
            let hr = i + '';
            if(i < 10){
                hr = '0' + i;
            }
            
            let fullhr = {'label': hr + ':00', 'value': hr + ':00'};
            let halfhr = {'label': hr + ':30', 'value': hr + ':30'};
            options.push(fullhr);
            if(i < 21)
            	options.push(halfhr);
            
        }
        component.set('v.options', options);
	}
})