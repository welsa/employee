({
    
    
    init: function (cmp, event, helper) {
        let start = new Date().getFullYear() + '/' + helper.to2dp(new Date().getMonth() + 1)+'/' + helper.to2dp(new Date().getDate());
        cmp.set('v.startDate', start);
        helper.loadData(cmp,true);
        
        cmp.set('v.mapMarkers', [
            {
                location: {
                    City: 'Cap-d\'Ail',
                    Country: 'France'
                },

                value: 'France1',
                icon: 'custom:custom26',
                title: 'Cap-d\'Ail',
                description: 'this is a description\n\rnewline'
            },
            {
                location: {
                    City: 'Beaulieu-sur-Mer',
                    Country: 'France'
                },

                value: 'France2',
                icon: 'custom:custom96',
                title: 'Beaulieu-sur-Mer'
            },
            {
                location: {
                    City: 'Saint-Jean-Cap-Ferrat',
                    Country: 'France'
                },

                value: 'France3',
                title: 'Saint-Jean-Cap-Ferrat'
            },
            {
                location: {
                    City: 'Villefranche-sur-Mer',
                    Country: 'France'
                },

                value: 'France4',
                icon: 'custom:custom92',
                title: 'Villefranche-sur-Mer'
            },
            {
                location: {
                    City: 'Antibes',
                    Country: 'France'
                },

                value: 'France5',
                icon: 'custom:custom61',
                title: 'Antibes'
            },
            {
                location: {
                    City: 'Juan-les-Pins',
                    Country: 'France'
                },

                value: 'France6',
                icon: 'custom:custom74',
                title: 'Juan-les-Pins'
            },
            {
                location: {
                    City: 'Cannes',
                    Country: 'France'
                },

                value: 'France7',
                icon: 'custom:custom3',
                title: 'Cannes'
            },
            {
                location: {
                    City: 'Saint-Raphaël',
                    Country: 'France'
                },

                value: 'France8',
                icon: 'custom:custom54',
                title: 'Saint-Raphaël'
            },
            {
                location: {
                    City: 'Fréjus',
                    Country: 'France'
                },

                value: 'France9',
                icon: 'custom:custom88',
                title: 'Fréjus'
            },
            {
                location: {
                    City: 'Sainte-Maxime',
                    Country: 'France'
                },

                value: 'France10',
                icon: 'custom:custom92',
                title: 'Sainte-Maxime'
            }
        ]);
        cmp.set('v.markersTitle', 'Côte d\'Azur');
        
    },
    forceRefreshViewHandler: function(cmp,event,helper){
        //alert('refresh');
        helper.loadData(cmp,true);
        
        
        
        
        cmp.set('v.showPopupRaison', false);
        cmp.set('v.showPopupSplit', false);
        cmp.set('v.otherDispo', false);
        cmp.set('v.showPopup', false);
        
        
    },
    searchCompetences: function(cmp, event, helper){
        helper.doBuildRequest(cmp);
        let value = event.getParam('competences');
        helper.filterCompetences(cmp, value);
        //alert(JSON.stringify(value));
    },
    adjustEndTime: function(cmp, event, helper){
        let defaultPlanningDuration = cmp.get('v.defaultPlanningDuration');
      let start = cmp.get('v.startDateTime');
      let parts = start.split('T');
      let times = parts[1].split(':');
      let hours = parseInt(times[0]);
      let mins = parseInt(times[1]);
      
        /*if(mins < defaultPlanningDuration){
            mins = mins + defaultPlanningDuration;
        }else{
           	mins = mins - 30;
            hours = hours+1;
        }*/
        hours = hours +1;
        
        let shrs = hours >=10? hours + '':'0' + hours + '';
        let smins = mins>=10? mins + '': '0' + mins + '';
        let end = parts[0] + 'T' + shrs + ':' + smins + ':00.000Z';
       // alert(end);
      cmp.set('v.endDateTime', end);
     // alert(start);
    },
    handleMarkerSelect: function (cmp, event, helper) {
        var marker = event.getParam("selectedMarkerValue");
        var map = cmp.find('mpp');
        //alert(marker);
    },
    selectLocationUU: function (cmp, event, helper) {
        var marker = event.currentTarget.getAttribute('name');
        var map = cmp.find('mpp');
        map.set('v.selectedMarkerValue', marker);
        //var marker = event.target.get('v.value');
        //alert(marker);
        //cmp.set('v.selectedMarkerValue', marker);
        //alert(marker);
    },
    selectLocation: function(component, event, helper ) {
        var workspaceAPI = component.find("workspace");
        var marker = event.currentTarget.getAttribute('name');
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId":marker,
                    "actionName":"view"
                },
                "state": {}
            },
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
        }).then(function(tabInfo) {
            console.log("The recordId for this tab is: " + tabInfo.recordId);
        });
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    handleSearch : function(cmp, event, helper){
    	let val = cmp.get('v.newRepName');
        cmp.set('v.selectedDispo', null);
        
        
        
        var action = cmp.get("c.getDisponibilyForReparateur");
        action.setParams({ caseId : cmp.get("v.recordId"), reparateur: val });

        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				let resp = response.getReturnValue();
                if(resp.ruleengine && resp.ruleengine.length > 0){
                    helper.processDataRE(cmp,response.getReturnValue(),true);
                }else{
                    let createNew = confirm('Votre recherche n\'a retourné aucun resultat, souhaitez vous créer un nouveau réparateur?');
    				cmp.set('v.showPopup', createNew);
                }
				
               
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                helper.showToastMessage('Error','Error',errors[0].message);
            }
        });

        $A.enqueueAction(action);
        
        
        
        //alert(val);
        
        
        
        if(cmp.get('v.numResults') == 0){
    		
        }
	},
    
    handleClosePopup: function(cmp, event, helper){
      	cmp.set('v.showPopup', false);
    },
    handleClosePopupRaison : function(cmp,event,helper){
        cmp.set('v.showPopupRaison', false);
    },
    handleCloseOtherDispo : function(cmp,event,helper){
        cmp.set('v.otherDispo', false);
    },
    handleOpenOtherDispo : function(cmp,event,helper){
        
        var marker = event.getSource().get('v.name');
        //alert(marker);
        cmp.set('v.selectedRep', marker);
        cmp.set('v.lessOneHrError', false);
        cmp.set('v.otherDispo', true);
    },
    
    handleSaveHorsRes : function(cmp, event, helper){
        var reparateurId = cmp.get('v.selectedRep');
        var caseId = cmp.get('v.recordId');
        var params = {
            'reparateurId': reparateurId,
            'caseId': caseId
            
        }
        helper.doCreateHorsRess(cmp,params);
    },
    
    handleSaveOtherDispo: function(cmp, event, helper){
        
        var startDateTime = cmp.get('v.startDateTime');
        var endDateTime = cmp.get('v.endDateTime');
        debugger;
        let defaultPlanningDuration = cmp.get('v.defaultPlanningDuration');
        cmp.set('v.lessOneHrError', false);
        if(startDateTime && endDateTime){
            let st = new Date(startDateTime).getTime();
            let en = new Date(endDateTime).getTime();
            let diff = en - st
            if((diff/60000)<defaultPlanningDuration){
                cmp.set('v.lessOneHrError', true);
            }else{
                var reparateurId = cmp.get('v.selectedRep');
                var caseId = cmp.get('v.recordId');
                var params = {
                    'reparateurId': reparateurId,
                    'caseId': caseId,
                    'startDateTime': startDateTime,
                    'endDateTime': endDateTime
                }
                helper.doCreateOtherDispossq(cmp,params);
            }
        }
        
    },
    handleSelectHors: function(cmp,event,helper){
        
         var marker = event.getSource().get('v.name');
        //alert(marker);
        cmp.set('v.selectedRep', marker);
        cmp.set('v.showPopupRaison', true);
    },
    handlePreviousDate: function(cmp,event,helper){
        let dtLst = new Date(cmp.get('v.startDate'));
        let mtn = new Date();
        let isoLst = dtLst.getFullYear() + '-' + helper.to2dp(dtLst.getMonth() + 1) + '-' + helper.to2dp(dtLst.getDate());
        let isoNow = mtn.getFullYear() + '-' + helper.to2dp(mtn.getMonth() + 1) + '-' + helper.to2dp(mtn.getDate());
        
        if(isoLst !== isoNow){
        
            let lst = dtLst.getTime();
            lst = lst - (1000*60*60*24*7);
            let startDate = new Date(lst);
            if(startDate.getTime() < new Date().getTime()){
                startDate = new Date();
            }
            
            
            
            let start = startDate.getFullYear() + '/' + helper.to2dp(startDate.getMonth() + 1) +'/'+ helper.to2dp(startDate.getDate());
            cmp.set('v.startDate', start);
            helper.buildDateHeader(startDate,cmp);
            helper.doBuildRequest(cmp);
        }
        
       
    },
    handleNextDate: function(cmp,event,helper){
       
        let lst = new Date(cmp.get('v.startDate')).getTime();
        lst = lst + (1000*60*60*24*7);
        let startDate = new Date(lst);
        let start = startDate.getFullYear() + '/' + helper.to2dp(startDate.getMonth() + 1) +'/'+ helper.to2dp(startDate.getDate());
        cmp.set('v.startDate', start);
        helper.buildDateHeader(startDate,cmp);
        helper.doBuildRequest(cmp);
    },
    
    
    positionDate: function(cmp,event,helper){
        helper.doBuildRequest(cmp);
        let startDate = new Date(cmp.get('v.startDate'));
        if(startDate.getTime() < new Date().getTime()){
            startDate = new Date();
             let start = startDate.getFullYear() + '/' + helper.to2dp(startDate.getMonth() + 1) +'/'+ helper.to2dp(startDate.getDate());
        	cmp.set('v.startDate', start);
        }
        
        helper.buildDateHeader(startDate,cmp);
        helper.calculateNumResults(cmp);
    },
   
    handleFilter: function(cmp,event,helper){
        helper.doBuildRequest(cmp);
        
    },
    handleSelect: function(cmp,event,helper){
        let offset = cmp.get('v.offset');
        let dispoId = cmp.get('v.selectedDispo');
        let caseId = cmp.get('v.recordId');
        let startTime = cmp.get('v.selectedStartTime');
        let endTime = cmp.get('v.selectedEndTime');
        let selectedMerge = cmp.get('v.selectedMerge');
        let delta = (endTime.getTime() - startTime.getTime())/60000;
        let splitSlots = [];
        let planningDuration = cmp.get('v.defaultPlanningDuration');
        // console.log('### selectedMerge ###' + JSON.stringify(selectedMerge));
        
        if(delta >= planningDuration){
            let slots = (delta/30) ;
            
            let start = new Date(startTime.getTime());

            if(dispoId.length>18)
                var  dispoIds_arr = dispoId.split(";");
            let previous = '';
            for(let i = 0; i < slots; i++){
                var earliest;
                var selectedDispos =[];
                // console.log('## earliest ##' + JSON.stringify(earliest));
                // console.log('## selectedDispo ##' + JSON.stringify(selectedDispos));
                if(start.getTime() <= endTime.getTime()){
                    let labelstart = helper.to2dp(start.getUTCHours() + parseInt(helper.recalcOffset(start, offset))) + ':' + helper.to2dp(start.getMinutes());
                    let end = new Date(start.getTime());
                    console.log('## start ##' + end);
                    end.setTime(end.getTime() + (planningDuration*60*1000));
                    let labelend = helper.to2dp(end.getUTCHours() + parseInt(helper.recalcOffset(start, offset))) + ':' + helper.to2dp(end.getMinutes());
                    //GBH	RSIW-9295
                    let label = helper.formatLabel(start, end, cmp);
                    

                    // for ()
                    // var opt;

                    for (var j = 0; j < selectedMerge.length; j++){
                        if (start >= new Date(selectedMerge[j].NOB_StartDate__c)
                        && end <= new Date(selectedMerge[j].NOB_EndDate__c)) {
                            selectedDispos.push(selectedMerge[j]);
                            break;
                            //earliest = selectedMerge[j];
                        }
                    }
                    earliest = selectedDispos[0];
                    for (var j = 0; j < selectedDispos.length; j++){
                        if (earliest.NOB_StartDate__c >= selectedDispos[j].NOB_StartDate__c){
                            earliest = selectedDispos[j];
                        }
                        
                    }
                    if(earliest){
                    	var opt = {'value':start.getTime() + '', 'label':label, 'id': earliest.Id};
                    	console.log('## opt ## ' + JSON.stringify(opt));
                        splitSlots.push(opt);
                    }

                	
                	
                }
                start.setTime(start.getTime() + (planningDuration*30*1000));
                //alrrt
                //alert('sdf');
                
                
            }
            
        }
        cmp.set('v.splitSlot',splitSlots);
        console.log('### splitSlots ### '+ JSON.stringify(splitSlots));
      //  alert(delta);
        debugger;
        if(splitSlots.length > 0){
            cmp.set('v.showPopupSplit',true);
        }else{
        	helper.doCreateWO(cmp,{'dispoId':dispoId, 'caseId': caseId});
        }
        //alert(selectedDispo);
    },
    handleClosePopupSplit: function(cmp, event, helper){
            cmp.set('v.showPopupSplit',false);
            cmp.set('v.selectedTime', null);
        
    },
    handleSaveSplit: function(cmp, event, helper){
        let dispoId = cmp.get('v.selectedDispo');
        let caseId = cmp.get('v.recordId');
        let selectedTime = cmp.get('v.selectedTime');
        console.log('## selectedtime ##' + selectedTime);
        console.log('## dispoId ##' + dispoId);
        console.log('## caseId ##' + caseId);
        var splitSlots = cmp.get('v.splitSlot');
        console.log('## splitSlots ##' + JSON.stringify(splitSlots));
       // if(splitSlots.length>0){
            for (var i = 0; i<splitSlots.length; i++){
                if (splitSlots[i].value == selectedTime) {
                    dispoId = splitSlots[i].id
                    break;
                }
            }
        //}
        console.log('## selectedtime ##' + selectedTime);
        console.log('## dispoId ##' + dispoId);
        console.log('## caseId ##' + caseId);
        
        debugger;
        helper.doCreateWO(cmp,{'dispoId':dispoId, 'caseId': caseId, 'selectedTime':selectedTime});
        
    },
    handleCreateReparateur: function(cmp,event,helper){
        let name = cmp.get('v.newRepName');
        let phone = cmp.get('v.newRepTelephone');
        
        let street = cmp.get('v.newRepStreet');
        let postalCode = cmp.get('v.newRepPostalCode');
        let city = cmp.get('v.newRepCity');
        let province = cmp.get('v.newRepProvince');
        let country = cmp.get('v.newRepCountry');
        
        let data = {'name': name, 'phone': phone, 'street':street,'postalCode':postalCode, 'city':city, 'province':province, 'country':country};
       // alert(JSON.stringify(data));
        helper.doCreateRep(cmp,data);
    },
    
    searchChange: function(cmp,event,helper){
        console.log("numItems has changed");
        //console.log("old value: " + event.getParam("oldValue"));
        //console.log("current value: " + JSON.stringify( event.getParam("value")));
        
        let value = event.getParam('value');
        if(value && value.text)
        	cmp.set('v.newRepName', event.getParam('value').text);
        else
            cmp.set('v.newRepName', null);
    }
});