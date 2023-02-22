({
	refreshConfig : function(cmp,event,helper) {
		
        let config = cmp.get('v.semaineType');
        
        let days = cmp.get('v.days');
        let types = ['dispo', 'abs'];
        for(let day of days){
            
         	let uiday = config[day];
            if(uiday){
                for(let type of types){
                    let dispos = uiday[type];
                    if(dispos){
                        let color = '#CFEBFE';
                        if(type == 'abs'){
                            color = '#8bcf6a';
                        }
                        
                        for(let dispo of dispos){
                            let from = dispo.from;
                            let to = dispo.to;
                            
                            let hrFrom = parseInt(from.split(':')[0]);
                            let minFrom = parseInt(from.split(':')[1]);
                            
                            let hrTo = parseInt(to.split(':')[0]);
                            let minTo = parseInt(to.split(':')[1]);
                            
                            for(let i = hrFrom; i <= hrTo; i++){
                                
                                let sHr = i < 10? '0' + i: '' + i;
                               
                                
                                let clsFull = day + '-' + sHr + ':00-full-' + type;
                                 let clsHalf = day + '-' + sHr + ':00-half-' + type;
                                document.getElementsByClassName(clsFull)[0].style.backgroundColor = color;
                                document.getElementsByClassName(clsHalf)[0].style.backgroundColor = color;
                                
                                
                                
                            }
                            
                            if(minFrom == 30){
                                let shrFrom = hrFrom < 10? '0'+hrFrom : '' + hrFrom;
                                let cls = day + '-' + shrFrom + ':00-full-' + type;
                                document.getElementsByClassName(cls)[0].style.backgroundColor = 'transparent';
                            }
                            
                            if(minTo == 0){
                                let cls = day + '-' + hrTo + ':00-half-' + type;
                                document.getElementsByClassName(cls)[0].style.backgroundColor = 'transparent';
                            }
                            
                        }
                    }
                }
            }
        }
	}, 
    adjustConfig: function(cmp,event,startTime, endTime, day, type){
        let config = cmp.get('v.semaineType');
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
        uitype.push({'from': startTime, 'to': endTime});
        cmp.set('v.semaineType', config);
        this.refreshConfig(cmp, event,this);
    }
})