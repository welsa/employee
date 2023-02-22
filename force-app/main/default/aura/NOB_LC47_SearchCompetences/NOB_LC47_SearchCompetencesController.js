({
    init: function (cmp, event, helper) {
    	//cmp.set('v.competences', []);
    	//alert(JSON.stringify(cmp.get('v.competences')));
    },
	searchChanges : function(cmp, event, helper) {
		let value = event.getParam('value');
        console.log(value);
        if(value != null){
            let item ={'label': value.text, 'name': value.val};
            let currentItems = cmp.get('v.competences');
            if(!currentItems){
                currentItems = [item];
            }else{
                let toadd = true;
                for(let cur of currentItems){
                    if(cur.name === item.name){
                        toadd = false;
                        break;
                    }
                }
                if(toadd)
                	currentItems.push(item);
            }
            cmp.find('lookup').setCompetences(currentItems);
            cmp.set('v.competences', currentItems);
            var cmpEvent = cmp.getEvent("ChangeCompetences");
            cmpEvent.setParams({"competences" : currentItems});
        	cmpEvent.fire();

        }
        cmp.set('v.selItems', null);
        
        //alert(JSON.stringify(value));
        //alert(value);
	},
    handleItemRemove: function (cmp, event) {
        var name = event.getParam("item").name;
       // alert(name + ' pill was removed!');
        // Remove the pill from view
        var items = cmp.get('v.competences');
        var item = event.getParam("index");
        items.splice(item, 1);
        
        cmp.set('v.competences', items);
        cmp.find('lookup').setCompetences(items);
        var cmpEvent = cmp.getEvent("ChangeCompetences");
        cmpEvent.setParams({"competences" : items});
        cmpEvent.fire();
    },
    doSetComp: function(cmp, event, helper){
        var params = event.getParam('arguments');
        if (params) {
            var competences = params.competences;
            cmp.find('lookup').setCompetences(competences);
            
            //cmp.set('v.competences', competences);
            //alert(JSON.stringify(competences));
        }
    }
})