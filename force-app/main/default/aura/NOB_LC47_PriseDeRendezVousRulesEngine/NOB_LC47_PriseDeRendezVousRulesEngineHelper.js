({
    filterRecords: function(cmp, tester){
        let num = 0;
        let numres = 0;
        let value = cmp.get('v.selectedRanking');
        let calendars = cmp.get('v.calendar');
        
        for(let cal of calendars){
            
            if(!cal.account.NOB_Ranking__c){
                cal.account.NOB_Ranking__c = 'Bronze';
            }
            if(tester(cal.account,value)){
                
                cal.show = true;
                num = num+1;
                numres = numres +1;
            }else{
                cal.show = false;
            }
            
        }
        let horsreseaux = cmp.get('v.horsreseaux');
        let selectReseaux = cmp.get('v.selectReseaux');
        if(selectReseaux !== '1'){
            for(let acc of horsreseaux){
                
                if(!acc.NOB_Ranking__c){
                    acc.NOB_Ranking__c = 'Bronze';
                }
                if(tester(acc,value)){
                    acc.show = true;
                    num = num+1;
                }else{
                    acc.show = false;
                }
                
            }
            cmp.set('v.horsreseaux', horsreseaux);
        }
        cmp.set('v.calendar', calendars);
        
        if(selectReseaux === '2'){
            num = num - numres;
        }
        
        this.calculateNumResults(cmp);
        //cmp.set('v.numResults', num);
    },
    doCreateHorsRess: function(cmp, params){
        var action = cmp.get("c.createWorkOrderHorsRes");
        action.setParams(params);
	
        cmp.set("v.loading", true);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

               // alert(JSON.stringify(response.getReturnValue()));
                $A.get('e.force:refreshView').fire();
				//this.processData(cmp,response.getReturnValue());
               
                cmp.set("v.loading", false);
                var result1 = response.getReturnValue();

                if(result1.haserror){
                    this.showToastMessage('Error','Error',result1.error);
                }
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
    logError: function(cmp, errors){
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + 
                            errors[0].message);
            }
        } else {
            console.log("Unknown error");
        }
    },

    showToastMessage : function(messageTitle, messageType, messageText) {
        debugger;
        console.log('£££ mo dans toast !');
        var resultsToast = $A.get("e.force:showToast");
        if(!messageText){
            messageText = 'Une erreur est survenue. Veuillez réessayer ultérieurement';
        }
        resultsToast.setParams({
            "title": messageTitle,
            "type": messageType,
            "message": messageText,
            "duration": 5000
        });
        resultsToast.fire();
   },
   
    doCreateOtherDispossq: function(cmp, params){
        var action = cmp.get("c.createOtherDispossss");
        action.setParams(params);

		cmp.set("v.loadingOther", true);
        cmp.set("v.loading", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               cmp.set("v.loading", false);
                cmp.set("v.loadingOther", false);
                $A.get('e.force:refreshView').fire();
                var result1 = response.getReturnValue();

                if(result1.haserror){
                    this.showToastMessage('Error','Error',result1.error);
                }
                console.log('## error obj1 : ',result1);
            }
            
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                cmp.set("v.loading", false);
                cmp.set("v.loadingOther", false);
                var errors = response.getError();
               this.logError(cmp,errors);
               this.showToastMessage('Error','Error',errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },
    doCreateWO: function(cmp, params){
        var action = cmp.get("c.createWorkOrder");
        action.setParams(params);
	
        cmp.set("v.loadingOther", true);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

              	cmp.set("v.loadingOther", false);
                $A.get('e.force:refreshView').fire();
				var result1 = response.getReturnValue();

                if(result1.haserror){
                    this.showToastMessage('Error','Error',result1.error);
                }
               
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                cmp.set("v.loadingOther", false);
                this.logError(cmp,errors);
                
                this.showToastMessage('Error','Error',errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },
    
    doCreateRep: function(cmp, params){
        var action = cmp.get("c.createReparateur");
        action.setParams(params);

        cmp.set("v.loading", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                cmp.set('v.showPopup', false);
              	let horsreseaux = cmp.get('v.horsreseaux');
                let res = response.getReturnValue();
                res.show = true;
                horsreseaux.push(res);
                cmp.set('v.horsreseaux', horsreseaux);
                cmp.set('v.showPopupRaison', true);
                cmp.set('v.numResults', 1);
                cmp.set('v.selectedRep', res.Id);
               	cmp.set("v.loading", false);
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                cmp.set("v.loading", false);
                this.logError(cmp,errors);
                this.showToastMessage('Error','Error',errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },
    
	"loadData" : function(cmp) {
        console.log("### loadData ###");
        var action = cmp.get("c.getRuleEngineCompetences");
        action.setParams({ caseId : cmp.get("v.recordId"), filrer:{} });
		cmp.set("v.loading", true);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.offset', response.getReturnValue().offset);
                //HMO -- 20/08/2021
                cmp.set('v.userAssureur', response.getReturnValue().userAssureur);
                cmp.set('v.showReseau', response.getReturnValue().showReseau);
                
                
				this.processDataRE(cmp,response.getReturnValue(),true);
                cmp.set("v.loading", false);
                
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                cmp.set("v.loading", false);
                this.logError(cmp,errors);
                this.showToastMessage('Error','Error',errors[0].message);
            }
        });

        $A.enqueueAction(action);
    },
    addDispo: function(cmp, dispo){
		let startDate = new Date(cmp.get('v.startDate'));
        
        
        let calendars = cmp.get('v.calendar');
        let accId = dispo.NOB_BodyShop__c;
        for(let cal of calendars){
            if(cal.account.Id === accId){
             	cal.account.dispos.push(dispo);
                let week = this.processDates(cal.account.dispos, startDate, cmp);
                cal.week = week;
            }
        }
        
        
        
        cmp.set('v.calendar', calendars);
    },
    filterCompetences: function(cmp, competences){
        let calendars = cmp.get('v.calendar');
        for(let calendar of calendars){
            let skills = calendar.account.NOB_SkillSet__c;
            if(skills && skills !== ''){
                let askills = skills.split(';');
                let inclu = this.hasAll(askills, competences);
                calendar.skills = inclu;
            }else{
                calendar.skills = false;
            }
        }
        
        cmp.set('v.calendar', calendars);
        
        let horsreseaux = cmp.get('v.horsreseaux');
        for(let rep of horsreseaux){
            let skills = rep.NOB_SkillSet__c;
            if(skills && skills !== ''){
                let askills = skills.split(';');
                let inclu = this.hasAll(askills, competences);
                rep.skills = inclu;
            }else{
                rep.skills = false;
            }
        }
        cmp.set('v.horsreseaux', horsreseaux);
        this.calculateNumResults(cmp);
    },
    hasAll: function(askills, competences){
        if(!competences || competences.length <= 0){
            return true;
        }
        
        
        for(let comp of competences){
            let present = false;
            for(let skill of askills){
                if(skill === comp.name){
                    present = true;
                }
            }
            if(!present){
                return false;
            }
        }
        return true;
	},
    doBuildRequest: function(cmp,letit){
        cmp.set('v.selectedDispo', null);
        let startDate = new Date(cmp.get('v.startDate'));
        if(startDate.getTime() < new Date().getTime()){
            startDate = new Date();
        }
        
        let selectReseaux = cmp.get('v.selectReseaux');
        let competences = cmp.get('v.competences');
        
        let params = [];
        let paramdispo = [];
        let startDateParam = this.to2dp( startDate.getDate()) + '/' + this.to2dp (startDate.getMonth()+1) + '/' + startDate.getFullYear() ;
       	startDateParam = startDateParam +  ' ' + this.to2dp(startDate.getHours()) + ':' +  this.to2dp(startDate.getMinutes());
        params.push('NOB_StartDate__c-EQUALS-' +  startDateParam);
      	paramdispo.push('NOB_StartDate__c-EQUALS-' + startDateParam);
        
        if(selectReseaux === '0'){
            params.push('NOB_NetworkType__c-NOT_EQUALS-NULL');
            
        }else if(selectReseaux === '1'){
            params.push('NOB_NetworkType__c-NOT_EQUALS-Hors réseau');
            
        }else{
            params.push('NOB_NetworkType__c-EQUALS-Hors réseau');
            
        }
 												//et pas hors reseau       
        if(competences && competences.length >0 && selectReseaux !== '2' ){
            let comps = '';
            for(let comp of competences){
                //comps.push(comp.name)
                if(comps !== ''){
                    comps = comps+ ',';
                }
                comps = comps + comp.name;
                //comps = comps + comps !== ''? ,'
            }
            params.push('NOB_SkillSet__c-INCLUDES-' + comps);
        }else{
            params.push('NOB_SkillSet__c-NOT_EQUALS-Null');
        }
        
        let request = {'Account': params, 'Disponibilite__r': paramdispo};
        
        console.log(JSON.stringify(request));
        cmp.set("v.loading", true);
         var action = cmp.get("c.getRuleEngineCompetences");
        action.setParams({ caseId : cmp.get("v.recordId"), filter: request });

        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				
                if(letit){
                    this.processDataRE(cmp,response.getReturnValue(), true);
                }else{
					this.processDataRE(cmp,response.getReturnValue());
                }
               cmp.set("v.loading", false);
            }
            else if (state === "INCOMPLETE") {
               
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                cmp.set("v.loading", false);
                this.logError(cmp,errors);
                this.showToastMessage('Error','Error',errors[0].message);
            }
        });

        $A.enqueueAction(action);
        
    },
    processDataRE: function(cmp, datas, withcomp){
        let res =[];
        let data = datas.dispos;
        let competences = cmp.get('v.competences');
        let thecase = datas.case;
        let canCustom = datas.canCustom;
        // cmp.set('v.offset', datas.offset);
        cmp.set('v.canCustom', canCustom);
        cmp.set('v.case', thecase);
        if(withcomp){
        	competences = datas.competences;
        	cmp.set('v.competences', competences);
            if(cmp.find('uicomp'))
        		cmp.find('uicomp').setComp(competences);
        }
        let re = false;
        
        let startDate = new Date(cmp.get('v.startDate'));
        startDate.setHours(0);
        startDate.setMinutes(0);
        startDate.setSeconds(0);
        startDate.setMilliseconds(0);
        let calendars = [];
        cmp.set('v.currentStartDate', startDate.getTime());
        
        let horsres = [];
        var mapDispoId = new Map();
        for(let acc of datas.ruleengine){
            if(!acc.NOB_NetworkType__c){
                acc.NOB_NetworkType__c = 'Type réseau';
            }
            if(!acc.NOB_NetworkType__c){
                continue;
            }
            
            if(acc.NOB_Ranking__c === 'Gold'){
                acc.rank = $A.get('$Resource.gold');
            }else if(acc.NOB_Ranking__c === 'Silver'){
                acc.rank = $A.get('$Resource.silver');
            }else {
                acc.rank = $A.get('$Resource.bronze');
            }
            
            if(acc.NOB_Statut__c === 'Inactif'  || acc.NOB_Statut__c === 'Suspendu'){
                acc.show = false;
            }else{
            	acc.show = true;
            }
            acc.distance = (acc.Distance/1).toFixed(2);
            if(acc.NOB_NetworkType__c === 'Hors réseau'){
                horsres.push(acc);
            }else{
                //en reseaux
                let week = [];
                if(acc.Disponibilite__r && acc.Disponibilite__r.length > 0){
                    //set map dispo id
                    var dispoIds = this.setMapDispoId(acc.Disponibilite__r);
                    mapDispoId[acc.Id] = dispoIds;

              
                    
                    //merge disponibilite
                    var accDispo = this.mergeDispo(acc.Disponibilite__r, cmp);
                    console.log("##accDispo" +  JSON.stringify(accDispo));
                    console.log("##acc.Disponibilite__r" +  JSON.stringify(acc.Disponibilite__r));
                    // week = this.processDates(acc.Disponibilite__r, startDate, cmp);
                    week = this.processDates(accDispo, startDate, cmp);
                } else {
                    week = this.processDates([], startDate, cmp); //GBH RSIW-10100  28/06/2021
                }
                
                let show = false;
                if(acc.show){
                    show = true;
                }
                let calendar = {'account': acc, 'week': week, 'show': show};
                calendars.push(calendar);

                cmp.set('v.mapDispoId', mapDispoId);
                console.log('### mapDispoId ###'+ JSON.stringify(mapDispoId));
            }
        }
        
        cmp.set('v.horsreseaux', horsres);
        
        
        cmp.set('v.calendar', calendars);
        
        
        console.log("##calendar "+JSON.stringify(calendars));
        this.processMarkers(calendars, horsres, cmp);
        this.buildDateHeader(startDate, cmp);
        this.filterCompetences(cmp,competences);
        this.calculateNumResults(cmp);
    },
    
    setMapDispoId : function (accDispo){
        var mapDispo = new Map();
        for ( var i = 0; i< accDispo.length; i++){
            var dispokey = accDispo[i].NOB_BodyShop__c + '_' + i;
            mapDispo[dispokey] = accDispo[i].Id;
        }
        return mapDispo;
    },
    
    calculateNumResults: function(cmp){
        let calendars = cmp.get('v.calendar');
        let selectReseaux = cmp.get('v.selectReseaux');
        let numResults = 0;
        //!item.show &amp;&amp; item.skills &amp;&amp; (v.selectReseaux == '0' || v.selectReseaux == '1') 
        for(let item of calendars){
            if(item.show &&  (selectReseaux === '0' || selectReseaux === '1')){
                numResults = numResults + 1;
            }
        }
        
        let horsreseaux = cmp.get('v.horsreseaux');
        //rep.show &amp;&amp; rep.skills &amp;&amp; (v.selectReseaux == '0' || v.selectReseaux == '2')
        for(let rep of horsreseaux){
            if(rep.show &&  (selectReseaux === '0' || selectReseaux === '2')){
                numResults = numResults + 1;
            }
        }
        
        cmp.set('v.numResults', numResults);
    }, 
    dateToStr: function(startDate){
        let start = startDate.getFullYear() + '/' + this.to2dp(startDate.getMonth() + 1) +'/'+ this.to2dp(startDate.getDate());
        return start;
    },
    refreshMarkers: function(cmp){
    	let calendars = cmp.get('v.calendars'); 
      	let horsreseaux = cmp.get('v.horsreseaux');
        this.processMarkers(calendars, horsreseaux, cmp);
    },
    processMarkers: function(calendars, horsreseaux, cmp){
        let selectReseaux = cmp.get('v.selectReseaux');
        let markers = [];
        
        let cas = cmp.get('v.case');
        if(cas.Contact){
            let marker = {
                location:{
                    'City': cas.Contact.MailingCity,
                    'Country':cas.Contact.MailingCountry,
                    'Street': cas.Contact.MailingStreet,
                    'PostalCode':cas.Contact.MailingPostalCode
                 },
                
                value: cas.Contact.Id,
                icon: 'custom:custom26',
                title: cas.Contact.Name,
                description:'Adresse Conducteur'
            };
            
            markers.push(marker);
            cmp.set('v.center', marker);
         	 
        }
        
        
        
        for(let cal of calendars){
            //if(cal.show && (selectReseaux === '0' || selectReseaux ==='1'))
            {
                let acc = cal.account;
                let marker = {
                    location:{
                        'City': acc.BillingCity,
                        'Country':acc.BillingCountry,
                        'Street': acc.BillingStreet,
                        'PostalCode':acc.BillingPostalCode
                    },
                    
                    value: acc.Id,
                    icon: 'custom:custom26',
                    title: acc.Name,
                    description: acc.distance? acc.distance + ' KM': 'Non renseigné'
                };
                markers.push(marker);
            }
        } 
        
        for(let acc of horsreseaux){
            //if(acc.show && (selectReseaux === '0' || selectReseaux ==='2'))
            {
                let marker = {
                    location:{
                        'City': acc.BillingCity,
                        'Country':acc.BillingCountry,
                        'Street': acc.BillingStreet,
                        'PostalCode':acc.BillingPostalCode
                    },
                    
                    value: acc.Id,
                    icon: 'custom:custom26',
                    title: acc.Name,
                    description:acc.distance? acc.distance + ' KM': 'Non renseigné'
                };
                markers.push(marker);
            }
        }
        
         
        
        cmp.set('v.mapMarkers', markers);
    },
    formatDate: function(dat){
        let month = ['jan', 'fev', 'mar', 'avr', 'mai', 'juin', 'Juil', 'aout', 'sep', 'oct', 'nov', 'dec']
      	let imont = dat.getMonth();
        console.log('WCH imont'+imont);
        console.log('WCH dat.getDate'+dat.getDate());
        return dat.getDate() + '-' + month[imont] + '-' + dat.getFullYear();
    },
    buildDateHeader: function(startDate, cmp){
      
        let dates = [];
        var currentDate = startDate;
        currentDate.setDate(startDate.getDate());
        for(let i = 0; i < 7; i++){
            console.log('WCH 2startDate:'+startDate);
            //let dt = startDate.getTime();
            //let ndt = dt + (1000*60*60*24*i);
            //let formatedDate = this.formatDate(new Date(ndt));
            let formatedDate = this.formatDate(currentDate);
            currentDate.setDate(currentDate.getDate()+1);
            console.log('WCH formatedDate:'+formatedDate);
            dates.push(formatedDate);
        }
        console.log('WCH dates'+dates);
        
        cmp.set('v.dates', dates);
    },
    
    processDates: function(dispos, startDate, cmp){
        let calendar = [];
//        let dates = [];

        for(let i = 0; i < 7; i++){
            let dt = startDate.getTime();
            let ndt = dt + (1000*60*60*24*i);
            let tomorrow = (ndt + 1000*60*60*24) -1;
            let formatedDate = this.formatDate(new Date(ndt));//.toLocaleString('fr-FR',{'dateStyle':'medium'});
            
            let calendarItem = {'date': ndt, 'dates':[], 'formattedData': formatedDate};
//            dates.push(formatedDate);
            calendar.push(calendarItem);
            let opts = [];
            calendarItem.options = opts;
            let current = [];
            for(let dispo of dispos){
                if(dispo.NOB_Status__c === 'Disponible'){
                    let dispoStartDate = new Date(dispo.NOB_StartDate__c);
                    let dispoEndDate = new Date(dispo.NOB_EndDate__c);
                    let ids = dispo.arrIds;
                   // if(ndt %2 ==0)
                    if(dispoStartDate.getTime() >= ndt && dispoStartDate < tomorrow)
                    {
                        let label = this.formatLabel(dispoStartDate, dispoEndDate, cmp);
                        if(current.indexOf(label) < 0){
                            let opt = {'label': label, 'value': dispo.Id, 'startTime':dispoStartDate, 'endTime':dispoEndDate, 'arrIds': dispo.arrIds};
                            calendarItem.options.push(opt);
                            calendarItem.dates.push({'from': dispoStartDate, 'to': dispoEndDate});
                            current.push(label);
                        }
                        
                    }
                }
                
            }
            
        }
//        cmp.set('v.dates', dates);
        return calendar;
    },
    
    formatLabel: function(start, end, cmp){
        var timezone = $A.get("$Locale.timezone");
        var startDate = new Date(start).toLocaleString("fr-FR", {timeZone: timezone})
        var endDate = new Date(end).toLocaleString("fr-FR", {timeZone: timezone})
        

        let res = startDate.substring(12,17) + ' - ' + endDate.substring(12,17); 
        return res;
    },
    
    recalcOffset:function(thedate, offset){
        let dt = new Date();
        dt.setMonth(2);
        dt.setDate(28);
        let offsta = offset;
       
        /*if(dt.getTime() < thedate.getTime()){
            offsta = offset +1;
        }*/
        return offsta;
    },
    
    to2dp: function(l){
        if(l < 10){
            return '0' + l;
        }
        return l + ''
    },
    
    findBodyShop: function(cmp, accId, res){
        for(let acc of res){
            if(acc.Id === accId){
                return acc;
            }
        }
        return null;
    },
    //GBH 12/01/2021 RSIW-7164
    mergeDispo: function(accDispo, cmp){
        var sd = accDispo[0].NOB_StartDate__c;
        var ed = accDispo[0].NOB_EndDate__c;
        var date = accDispo[0].NOB_StartDate__c.substring(0, 9);
        var id = accDispo[0].Id;
        var allDispo = [];
        var dispo={};
        var planningDuration = cmp.get('v.defaultPlanningDuration'); 
        var arrIds = [];
        // arrIds.push(accDispo[0]);

        for (var i = 0; i < Object.keys(accDispo).length; i++){
            var delta = (new Date(accDispo[i].NOB_EndDate__c).getTime()-new Date(accDispo[i].NOB_StartDate__c).getTime())/60000;
            
            dispo = {
                	"NOB_BodyShop__c":accDispo[i].NOB_BodyShop__c,
                    "NOB_tech_DiffHeure__c":accDispo[i].NOB_tech_DiffHeure__c,
                    "NOB_StartDate__c": sd,
                    "NOB_EndDate__c": ed,
                    "Id": id,
                    "arrIds":arrIds,
                    "NOB_Status__c": accDispo[i].NOB_Status__c
            };
        
            if(accDispo[i].NOB_Status__c === 'Disponible' 
                && accDispo[i].NOB_StartDate__c <= ed 
                && accDispo[i].NOB_StartDate__c.substring(0, 9) === date){

                ed = accDispo[i].NOB_EndDate__c;
                arrIds.push(accDispo[i]);
                
                if (sd > accDispo[i].NOB_StartDate__c) {
                    sd = accDispo[i].NOB_StartDate__c;
                }
                // let arrIds = [];
                // if (delta > planningDuration) {
                //     let slots = (delta/planningDuration) ;
                //     let ids = '';
                //     for(let j = 0; j < slots; j++){
                       
                //         ids = ids + accDispo[i].Id + ';'; 
                //         arrIds.push(accDispo[i]);
                //     }
                //     id = id + ';' + ids;
                // } else {
                //     id = id + ';' + accDispo[i].Id;
                //     arrIds.push(accDispo[i]);
                // }
                
                console.log(i);    
                if (i == Object.keys(accDispo).length-1){
                    dispo = {"NOB_BodyShop__c":accDispo[i].NOB_BodyShop__c,
                             "NOB_tech_DiffHeure__c":accDispo[i].NOB_tech_DiffHeure__c,
                             "NOB_StartDate__c": sd,
                             "NOB_EndDate__c": ed,
                             "Id":id,
                             "arrIds":arrIds,
                             "NOB_Status__c": accDispo[i].NOB_Status__c
                            };
                    allDispo.push(dispo);
                    console.log('###');
                    console.log(i);
                }
                    

            } else {
                allDispo.push(dispo);

                id = accDispo[i].Id;
                arrIds = [];
                arrIds.push(accDispo[i]);
                ed = new Date(ed);
                ed.setHours(0);
                ed.setMinutes(0);
                ed.setSeconds(0);
                ed.setMilliseconds(0);
                
                sd = accDispo[i].NOB_StartDate__c;
                ed = accDispo[i].NOB_EndDate__c;
                date = accDispo[i].NOB_StartDate__c.substring(0, 9);

                if (i != Object.keys(accDispo).length-1)
                    dispo={};
                else {
                    //  let arrIds = [];
                    // if (delta > planningDuration) {
                    //     let slots = (delta/planningDuration) ;
                    //     let ids = '';
                    //     for(let j = 0; j < slots; j++){
                    //         ids = ids + accDispo[i].Id + ';'; 
                    //         arrIds.push(accDispo[i]);
                    //     }
                    //     id = id + ';' + ids;
                    // } else {
                    //     id = id + ';' + accDispo[i].Id;
                    // }
                    dispo = {"NOB_BodyShop__c":accDispo[i].NOB_BodyShop__c,
                            "NOB_tech_DiffHeure__c":accDispo[i].NOB_tech_DiffHeure__c,
                            "NOB_StartDate__c": sd,
                            "NOB_EndDate__c": ed,
                            "Id":id,
                            "arrIds":arrIds,
                            "NOB_Status__c": accDispo[i].NOB_Status__c};
                            allDispo.push(dispo);
                }
            }
        }
        return allDispo;
    }
})