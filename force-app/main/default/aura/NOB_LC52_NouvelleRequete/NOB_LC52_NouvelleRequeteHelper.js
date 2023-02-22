({
    onInit : function(component, event, helper) {
        //var recordId = component.get("v.recordId");
        var action = component.get('c.getApporteurAffaire');
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result != null){
                    
                }
                 
                if(result.accounts.length == 1){
                    component.set('v.accountType', 'readonly');
                    component.set('v.firstAccount',result.accounts[0]);
                }else if(result.accounts.length > 1){
                    component.set('v.accountType', 'select');
                }else{
                    component.set('v.accountType', 'readonly');
                }
                component.set('v.businessProvider', result.accounts);
            }
            else {  
                console.log(state);
            }
        });
    
        $A.enqueueAction(action);
    },
    
    insertContact : function(component, event, helper) {
        debugger;
        try{
        let sfields = JSON.stringify(event.getParams());
        let params = JSON.parse(sfields);
        let fields = params.fields;//event.getParam('fields');
        
        var address = component.get('v.contact');
        console.table(JSON.stringify(address));
        const mapCountries = component.get('v.countries');

        fields['MailingStreet'] = address.MailingStreet;
        fields['MailingCity'] = address.MailingCity;
        fields['MailingPostalCode'] = address.MailingPostalCode;
        //fields['MailingCountry'] = address.MailingCountry;
        if(address.MailingCountry in mapCountries){
            fields['MailingCountryCode'] = mapCountries[address.MailingCountry];
        }
        var recId = component.get('v.recordId');
        fields['RecordTypeId'] = recId;
        component.find('recordFormContact').submit(fields);
        }catch(err){
            console.log(err);
        }
    },
    
    onInitContact : function(component, event, helper) {
        var recordTypeLabel = "NOB_Fiche_Assure";
        var action = component.get('c.getUserandRecId');
        action.setParams({"recordTypeLabel": recordTypeLabel});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result'+ JSON.stringify(result));
                debugger;
                if(result.user){
                    //if(result.user.Account){
                        //if(!result.user.Account.length){
                            //component.set('v.recordOwner', result.user.Account.Name);
                        //}else{
                            //component.set('v.recordOwner', result.user.Account[0].Name);
                        //}
                    //}else{
                        component.set('v.recordOwner', result.user.Name); 
                    //}
                    //console.log('acc', result.user[0].Account.Name );
                    
                }
                if(result.recordType.length > 0){
                    component.set('v.recordId', result.recordType[0].Id);
                    component.set('v.recordTypeName', result.recordType[0].Name);
                }
                if(result.mapValues){
                    component.set('v.countries', result.mapValues);
                }
                else {
                    console.log(state);
                }
            }
        });
        $A.enqueueAction(action);
    }
})