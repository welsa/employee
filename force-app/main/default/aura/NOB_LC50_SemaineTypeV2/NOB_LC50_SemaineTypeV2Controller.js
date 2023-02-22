({
    scriptsLoaded : function(component, event, helper) {
		//alert('loaded');
        debugger;
        let b = new window.fr.components.SemaineType();
        b.cmp =component;
        b.evt = event;
        b.helper = helper;
        b.setUserData(helper);
        //b.setHtml('hello world contaiernenenrenrnen');
        b.render(document.getElementsByClassName('semainetype')[0]);
        window.myapp = b;
        helper.loadData(component,event,helper);
	},
    init : function(component, event, helper) {
        let times = [];
        let days =['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
        component.set('v.days', days);
        for(let i = 6; i <=21;i++){
            if(i < 10){
                times.push('0'+i+':00');
            }else{
                times.push( i + ':00');
            }
        }
        component.set('v.times', times);
        
        
	},
    addItem : function(component, event, helper){
        debugger;
        let time = event.target.getAttribute('data-time');
        let day = event.target.getAttribute('data-day');
        let half = event.target.getAttribute('data-half');
        let id = day + '-' + time + '-' + half;
        let color = event.target.style.backgroundColor;
              
        if(color !== ''){
            let type = 'abs';
            if(color === 'rgb(207, 235, 254)'){
                type = 'dispo';
            }
            component.set('v.selectedType', type);
            component.set('v.editMode', true);
            component.set('v.popupTitle', 'Modifier / supprimer ce créneau')
            let ctime = time;
            if(half === 'half'){
                ctime = time.split(':')[0] + ':30';
            }
            let semaineType = component.get('v.semaineType');
            let st = semaineType.config;
            let tday = st[day];
            let dispos = tday[type];
            let theTime = new Date('01/01/2000 ' + ctime + ':00').getTime();
            let index = 0;
            for(let cr of dispos){
                let from = new Date('01/01/2000 ' + cr.from + ':00').getTime();
                let to = new Date('01/01/2000 ' + cr.to + ':00').getTime();
                let quantity = cr.quantity? cr.quantity:1;
                if(theTime >= from && theTime <= to){
                    
                    component.set('v.selectedStartTime', cr.from);
            		component.set('v.selectedEndTime', cr.to);
                    component.set('v.selectedQuantity', quantity);
                    component.set('v.editingValue', {'day':day, 'type':type, 'from':cr.from, 'to':cr.to, 'quantity':quantity, 'index': index});
                    break;
                }
                index++;
            }
            //dispo selected
            //selected
        }else{
            component.set('v.popupTitle', 'Ajouter un créneau');
            component.set('v.editMode', false);
            component.set('v.editingValue', null);
            let parts = time.split( ':');
            if(half === 'half'){
                parts[1] = '30';
            }
            time= parts[0] + ':' + parts[1];
            
            let endTime = (parseInt(parts[0]) + 1) + ':' + parts[1];
            component.set('v.selectedStartTime', time);
            component.set('v.selectedEndTime', endTime);
            component.set('v.selectedQuantity', 1);
        }
        component.set('v.selectedDay', day);
		component.set('v.showPopup', true);  
        
    },
    handleClosePopup: function(component, event, helper){
        component.set('v.showPopup', false);
    },
    handleSave: function(cmp, event, helper){
        
        event.preventDefault();
        debugger;
        
        let start = cmp.get('v.selectedStartTime').replace(':00.000', '');
        let end = cmp.get('v.selectedEndTime').replace(':00.000', '');
        let day = cmp.get('v.selectedDay');
        let type = cmp.get('v.selectedType');
        let quantity = cmp.get('v.selectedQuantity');
        
        let startTime = new Date('1970-01-01T' + start + ':00Z');
        let endTime = new Date('1970-01-01T' + end + ':00Z');
        
        if(endTime <= startTime){
            //error
            cmp.set('v.hasError',true);
            return;
        }
        if(quantity < 1){
            cmp.set('v.hasErrorQuant',true);
            return;
        }
        

        //time difference in minutes
        let timeDiff = (endTime - startTime)/60000;
        if(timeDiff < 60){
            cmp.set('v.hasError',true);
            return;
            //error
        }
        
        
        cmp.set('v.hasError',false);
        cmp.set('v.hasErrorQuant',false);
        
        let editMode = cmp.get('v.editMode');
        if(editMode){
            let edval = cmp.get('v.editingValue');
            let semaineType = cmp.get('v.semaineType');
            let config = semaineType.config;
            let day = edval.day;
            let type = edval.type;
            let index = edval.index;
            let eday = config[day];
            if(!eday){
                eday = {};
                config[day] = eday;
            }
            let times = eday[type];
            if(!times){
                times = [];
                eday[type] = times;
            }
            let i = 0;
            let newArr = [];
            for(let dt of times){
                if(i != index){
                    newArr.push(dt);
                }else{
                    newArr.push({'from':start, 'to': end, 'quantity': quantity})
                }
                
                i++;
            }
            config[day][type] = newArr;
            semaineType.config = config;
            cmp.set('v.semaineType', semaineType);
            helper.resetAll(cmp,event,helper);
            helper.refreshConfig(cmp, event,helper);
        }else{
        
        	helper.adjustConfig(cmp,event,start,end,day,type, quantity);
        }
       helper.saveData(cmp,event,helper);
        cmp.set('v.showPopup', false);
        
    },
    handleDelete: function(cmp, event,helper){
        debugger;
        
        let prom = window.confirm('Des RDV sont déjà positionnés sur ces disponibilités, la suppression de ces disponibilités n’entrainera pas d’annulation de ces RDV. Merci');
        
        if(prom){
        
        
     	let edval = cmp.get('v.editingValue');
        let semaineType = cmp.get('v.semaineType');
        let config = semaineType.config;
        let day = edval.day;
        let type = edval.type;
        let index = edval.index;
        let eday = config[day];
        if(!eday){
            eday = {};
            config[day] = eday;
        }
        let times = eday[type];
        if(!times){
            times = [];
            eday[type] = times;
        }
        let i = 0;
        let newArr = [];
        for(let dt of times){
            if(i != index){
                newArr.push(dt);
            }
            
            i++;
        }
        config[day][type] = newArr;
        semaineType.config = config;
        cmp.set('v.semaineType', semaineType);
        helper.resetAll(cmp,event,helper);
        helper.refreshConfig(cmp, event,helper);
        cmp.set('v.showPopup', false);
         helper.saveData(cmp,event,helper);
        }
    },
    handleApplyUntil: function(cmp, event, helper){
        debugger;
        let until = cmp.get('v.applyUntil');
        let semaineType = cmp.get('v.semaineType');
        semaineType.until = new Date(until);
        let config = semaineType.config;
        cmp.set('v.semaineType', semaineType);
        helper.saveData(cmp,event,helper);
        if(config){
            let params = {'semaineType':semaineType, 'until':until}
            var action = cmp.get("c.applySemaineType");
            action.setParams(params);
            cmp.set("v.loading", true);
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.loading", false);
                    let href = window.location.href.split('semainetype');
                    window.location.href = href[0];
                }
                else if (state === "INCOMPLETE") {
                    
                }
                    else if (state === "ERROR") {
                        cmp.set("v.loading", false);
                        var errors = response.getError();
                       // this.logError(cmp,errors);
                    }
            });
            
            $A.enqueueAction(action);
        }
    }
    
})