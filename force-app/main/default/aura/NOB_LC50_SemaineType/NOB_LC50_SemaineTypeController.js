({
    init : function(component, event, helper) {
        let times = [];
        let days =['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
        component.set('v.days', days);
        for(let i = 9; i <=21;i++){
            if(i == 9){
                times.push('09:00');
            }else{
                times.push( i + ':00');
            }
        }
        component.set('v.times', times);
        
        let config = {'Lundi':{
            					'dispo':[{'from':'10:30', 'to': '12:30'},{'from':'14:00', 'to': '15:00'}],
            					'abs':  [{'from':'16:30', 'to': '17:30'},{'from':'18:00', 'to': '19:00'}]
        					},
                      'Mardi':{
            					'dispo':[{'from':'09:30', 'to': '10:30'},{'from':'14:00', 'to': '15:00'}],
            					'abs':  [{'from':'14:30', 'to': '15:30'},{'from':'20:00', 'to': '21:00'}]
        					}
                     };
        
        component.set('v.semaineType', config);
        
        setTimeout(function(){helper.refreshConfig(component,event,helper)}, 1000);;
        
	},
    addItem : function(component, event, helper){
        debugger;
        let time = event.target.getAttribute('data-time');
        let day = event.target.getAttribute('data-day');
        let half = event.target.getAttribute('data-half');
        let id = day + '-' + time + '-' + half;
        
        component.set('v.selectedDay', day);
        
        let parts = time.split( ':');
        if(half === 'half'){
            parts[1] = '30';
        }
        time= parts[0] + ':' + parts[1];
        
        let endTime = (parseInt(parts[0]) + 1) + ':' + parts[1];
        component.set('v.selectedStartTime', time);
        component.set('v.selectedEndTime', endTime);
        component.set('v.selectedDay', day);
        
        component.set('v.showPopup', true);
        
       // let elem = document.getElementsByClassName(id);
       //	elem[0].style.backgroundColor = 'red';
    },
    handleClosePopup: function(component, event, helper){
        component.set('v.showPopup', false);
    },
    handleSave: function(cmp, event, helper){
        
        event.preventDefault();
        debugger;
        
        let start = cmp.get('v.selectedStartTime');
        let end = cmp.get('v.selectedEndTime');
        let day = cmp.get('v.selectedDay');
        let type = cmp.get('v.selectedType');
        
        helper.adjustConfig(cmp,event,start,end,day,type);
       
       // helper.refreshConfig(cmp,event,helper);
        cmp.set('v.showPopup', false);
        
    }
    
})