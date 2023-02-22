/*************************************************************************************
Class Name - NOB_ContactTriggerHandler
Version - 1.0
Created Date - 12/10/2020
Function - Class to Manage Case Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Kureem      	12/10/2020  Original Version
  HMO           23-12-2020  Internal user from custom label
  USA           29/12/2020  RSIW-7131
*************************************************************************************/
public without sharing class NOB_ContactTriggerHandler {
    
    public void OnAfterInsert(Contact[] contacts){
        System.debug('On after insert');
        List<Id> userIds = new List<Id>();
        Map<Id, Contact> mapUserIdCont = new Map<Id,Contact>();
        List<Id> recordTypeIds = new List<Id>();
        Map<Id, String> mapRecordTypes = new Map<Id,String>();
        List<Id> contactIds = new List<Id>();
        for(Contact c : contacts){
            contactIds.add(c.Id);
            if(!userIds.contains(c.CreatedById)){
                userIds.add(c.createdById);
            }
            mapUserIdCont.put(c.CreatedById, c);
            if(!recordTypeIds.contains(c.RecordTypeId)){
                recordTypeIds.add(c.RecordTypeId);
            }
        }
        
        List<Contact> conts = [SELECT Id, Name,RecordTypeId,NOB_FunctionServices__c, OwnerId,AccountId FROM Contact WHERE Id IN: contactIds];
        
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE Id IN: recordTypeIds];
        for(RecordType rc : recordTypes){
            mapRecordTypes.put(rc.Id, rc.DeveloperName);
        }
       User u = [SELECT Id, Contact.AccountId,NOB_isPrefikar__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        List<Contact> contactToUpdate = new List<Contact>();
        if(isUserCommunity(u)){
            Id internalUser = System.Label.NOB_InternalUser;
            for(Contact c : conts){
                // if(c.AccountId == null){
                //     if(isReparateur(c, mapRecordTypes)){
                //         if(isConvoyeur(c)){
                //             c.OwnerId = internalUser;
                //             c.AccountId = u.Contact.AccountId;
                //             contactToUpdate.add(c);
                //         }
                //     }else if(isAssure(c, mapRecordTypes)){
                //         c.AccountId = u.Contact.AccountId;
                //         c.OwnerId = internalUser;
                //         contactToUpdate.add(c);
                //     }
                // }

                //HMO -- 23-12-2020
                if(isReparateur(c, mapRecordTypes) || isConvoyeur(c) || isAssure(c, mapRecordTypes)){
                    c.OwnerId = internalUser;
                    //RSIW 7131
                    if (isAssure(c, mapRecordTypes) && u.Profile.Name == 'CCP Bodyshop'){
                       //account automatically assigned to 'CONTACT SANS COMPTE'
                    }
                    else{
                        c.AccountId = u.Contact.AccountId;
                    }
                    contactToUpdate.add(c);
                }
            }
        }
        
        if(contactToUpdate.size() > 0){
            update contactToUpdate;
        }
    }
    
    private boolean isConvoyeur(Contact c){
        if(c.NOB_FunctionServices__c != null && c.NOB_FunctionServices__c.indexOf('Convoyeur') >=0){
            return true;
        }else{
            return false;
        }
    }
    
    private boolean isReparateur(Contact c, Map<Id,String> mapRecordTypes){
        Id rc = c.RecordTypeId;
        String rcName = mapRecordTypes.get(rc);
        return (rcName == 'NOB_Contact_Reparateur');
    }
    
    private boolean isAssure(Contact c, Map<Id,String> mapRecordTypes ){
        Id rc = c.RecordTypeId;
        String rcName = mapRecordTypes.get(rc);
        return (rcName == 'NOB_Fiche_Assure');
    }
    
    private boolean isUserCommunity(User u){
        return u.Profile.Name == 'PRE_CCP Assureur' || u.Profile.Name == 'CCP Bodyshop';
    }
    

    //HMO -- 23-12-2020
    // private Id getInternalUser(){
    //     String username = System.Label.NOB_InternalUser;
    //     List<User> users = [SELECT Id, username FROM User where username =: username];
    //     if(users.size() > 0){
    //     	return users.get(0).Id;
    //     }
    //     return null;
    // }
}