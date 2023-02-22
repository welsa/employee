({
    formatDate:function(dt){
      	let res = dt.getFullYear() + '-' + this.to2num( dt.getMonth() + 1) + '-' + this.to2num(dt.getDate());
        return res;
    },
    to2num: function(num){
        if(num < 10){
            return '0' + num;
        } else{
            return num + '';
        }
    },
    
    loadData: function(cmp, event,helper){
      
        var action = cmp.get("c.getSemaineType");
        cmp.set("v.loading", true);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

               let js = response.getReturnValue();
                if(js && js !== ''){
                    let semaineType = JSON.parse(js);
                    let config = semaineType.config;
                    if(!config){
                        let dt = new Date();
                    	dt.setTime(dt.getTime() + (5*7*24*60*60*1000));
                        semaineType = {'config': semaineType, 'until':dt};
                    }
                    cmp.set('v.applyUntil', this.formatDate(new Date(semaineType.until)));
                    cmp.set('v.semaineType', semaineType);
                   // setTimeout(function(){helper.refreshConfig(cmp,event,helper)}, 1000);;
                     window.myapp.setSemaineType(semaineType);
                    window.myapp.render(document.getElementsByClassName('semainetype')[0]);
                }else{
                    let config = {
                        'Lundi':{'dispo':[],'abs':[]},
                      	'Mardi':{'dispo':[],'abs':[]},
                        'Mercredi':{'dispo':[],'abs':[]}, 
                        'Jeudi':{'dispo':[],'abs':[]},
                        'Vendredi':{'dispo':[],'abs':[]},
                        'Samedi':{'dispo':[],'abs':[]}
                     };
                    let dt = new Date();
                    dt.setTime(dt.getTime() + (5*7*24*60*60*1000));
                    let semaineType = {'config':config, 'until':dt};
                    
                    cmp.set('v.semaineType', semaineType);
                    cmp.set('v.applyUntil', this.formatDate(new Date(semaineType.until)));
                    //setTimeout(function(){helper.refreshConfig(cmp,event,helper)}, 1000);;
                    window.myapp.setSemaineType(semaineType);
                    window.myapp.render(document.getElementsByClassName('semainetype')[0]);
                   
                }
                
                cmp.set("v.loading", false);
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                cmp.set("v.loading", false);
      	       	var errors = response.getError();
                this.logError(cmp,errors);
            }
        });

        $A.enqueueAction(action);
        
    },
    openPopup: function(cmp, event, helper){
       cmp.set('v.showPopup', true); 
    } ,   
    saveData: function(cmp, event, helper){
        let semaineType = cmp.get('v.semaineType');
        if(semaineType){
            var action = cmp.get("c.saveSemaineType");
            action.setParams({'semaineType': JSON.stringify(semaineType)});
            cmp.set("v.loading", true);
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                     cmp.set("v.loading", false);
                }
                else if (state === "INCOMPLETE") {
                    
                }
                    else if (state === "ERROR") {
                        cmp.set("v.loading", false);
                        var errors = response.getError();
                        this.logError(cmp,errors);
                    }
            });
            
            $A.enqueueAction(action);
        }
    },
    refreshConfig_: function(cmp){
        let semaineType = cmp.get('v.semaineType');
      window.myapp.setSemaineType(semaineType);
                    window.myapp.render(document.getElementsByClassName('semainetype')[0]);
        
    },
	refreshConfig : function(cmp,event,helper) {
		
        let semaineType = cmp.get('v.semaineType');
      window.myapp.setSemaineType(semaineType);
      window.myapp.render(document.getElementsByClassName('semainetype')[0]);
        
        
       
	}, 
    resetAll: function(cmp,event,helper){
        let days = cmp.get('v.days');
        let types = ['dispo', 'abs'];
        for(let day of days){
        	for(let type of types){
             
                for(let i = 9; i <=21;i++){
                    //Mardi-17:00-half-dispo
                    let hr = i==9? ('0' + i): (i + '')
                    let cls = day + '-'+hr + ':00-half-' + type;
                    let clsFull = day + '-'+hr + ':00-full-' + type;
                    
                    let elHalf =document.getElementsByClassName(cls)[0];
                    let elFull = document.getElementsByClassName(clsFull)[0];
                    
                    elHalf.style.backgroundColor = '';
                    elFull.style.backgroundColor = '';
                    elHalf.style.borderTopLeftRadius = '0px';
                    elFull.style.borderTopLeftRadius = '0px';
                    elHalf.style.borderTopRightRadius = '0px';
                    elFull.style.borderTopRightRadius = '0px';
                    
                    elHalf.style.borderBottomLeftRadius = '0px';
                    elFull.style.borderBottomLeftRadius = '0px';
                    elHalf.style.borderBottomRightRadius = '0px';
                    elFull.style.borderBottomRightRadius = '0px';
                    elHalf.setAttribute('title', '');
                    elFull.setAttribute('title', '');
                    
                }
                
            }
        }
    },
    adjustConfig: function(cmp,event,startTime, endTime, day, type, quantity){
        let semaineType = cmp.get('v.semaineType');
        let config = semaineType.config;
        let uiday = config[day];
        if(!uiday){
            uiday = {};
            config[day] = uiday;
        }
        let uitype = uiday[type];
        if(!uitype){
            uitype = [];
            uiday[type] = uitype;
            
        }
        uitype.push({'from': startTime, 'to': endTime, 'quantity': quantity});
        semaineType.config = config;
        cmp.set('v.semaineType', semaineType);
        this.refreshConfig(cmp, event,this);
    },
    handleEdit: function(params){
        let cmp = params[0];
        let type = params[1].type;
        cmp.set('v.selectedType', type);
        cmp.set('v.editMode', true);
        cmp.set('v.popupTitle', 'Modifier / supprimer ce créneau')
        cmp.set('v.showPopup', true);
        cmp.set('v.hasErrorQuant',false);
        
        let cr = params[1];
        if(!cr.quantity){
            cr.quantity = 1;
        }
       // let index = 0;
        cmp.set('v.selectedStartTime', cr.from);
        cmp.set('v.selectedEndTime', cr.to);
        cmp.set('v.selectedQuantity', cr.quantity);
        cmp.set('v.selectedDay', cr.day);
        
        
        
        let semaineType = cmp.get('v.semaineType');
        let st = semaineType.config;
        let tday = st[cr.day];
        let dispos = tday[cr.type];
        let ctime = cr.from;
        let theTime = new Date('01/01/2000 ' + ctime + ':00').getTime();
        let index = 0;
        for(let cr of dispos){
            let from = new Date('01/01/2000 ' + cr.from + ':00').getTime();
            let to = new Date('01/01/2000 ' + cr.to + ':00').getTime();
            let quantity = cr.quantity? cr.quantity:1;
            if(theTime >= from && theTime <= to){
                
                //component.set('v.selectedStartTime', cr.from);
                //component.set('v.selectedEndTime', cr.to);
                //component.set('v.selectedQuantity', quantity);
                //component.set('v.editingValue', {'day':day, 'type':type, 'from':cr.from, 'to':cr.to, 'quantity':quantity, 'index': index});
                break;
            }
            index++;
        }
        
        cmp.set('v.editingValue', {'day':cr.day, 'type':cr.type, 'from':cr.from, 'to':cr.to, 'quantity':cr.quantity, 'index': index});
        
       // alert(JSON.stringify(params[1]));
    },
    handleCreate: function(params){
        let cmp = params[0];
        let time = params[1].time;
        let day = params[1].day;
        
        cmp.set('v.popupTitle', 'Ajouter un créneau');
        cmp.set('v.editMode', false);
        cmp.set('v.editingValue', null);
        cmp.set('v.hasErrorQuant',false);
        let parts = time.split(':');
       // time= parts[0] + ':' + parts[1];
        let hr = parseInt(parts[0])+1;
        let shr = hr < 10? '0' + hr: hr + '';
        let endTime = shr + ':' + parts[1];
        cmp.set('v.selectedStartTime', time);
        cmp.set('v.selectedEndTime', endTime);
        cmp.set('v.selectedQuantity', 1);
        cmp.set('v.selectedDay', day);
		cmp.set('v.showPopup', true);  
    }
})