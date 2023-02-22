/**
 * @description       : 
 * @author            : GBH
 * @group             : 
 * @last modified on  : 12-10-2020
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   12-10-2020   GBH   Initial Version
**/
public without sharing class NOB_AP55_AccountSharing {
    
    public static void accountSharing(List<NOB_AccountRelationship__c> lstFilteredAR, Set<Id> lstReparateurId){
        List<user> lstUsers = new List<user>([SELECT id, AccountId 
                                                FROM User 
                                                WHERE AccountId IN :lstReparateurId]);

        List<AccountShare> lstAccShare = new List<AccountShare> ();
        
        Map <String, List<User>> mapUsers = new Map <String, List<User>> ();

        for (user u : [SELECT id, accountid 
                        FROM User 
                        WHERE AccountId IN :lstReparateurId AND Profile.name = 'CCP Bodyshop' AND NOB_isPrefikar__c =:NOBTools.isPrefikarUser() AND IsActive = TRUE]) {
            if (mapUsers.containsKey(u.accountid)) {
                List <User> lstUsersMap = mapUsers.get(u.accountid);
                lstUsersMap.add(u);
                mapUsers.put(u.accountid, lstUsersMap);
            } else {
                mapUsers.put(u.accountid, new List<User>{u});
            }
        }

        
        for (NOB_AccountRelationship__c accRel : lstFilteredAR) {
            if (mapUsers.containsKey(accRel.NOB_Bodyshop__c)) {
                List<User> lstCurrentUsers = mapUsers.get(accRel.NOB_Bodyshop__c);

                for (User u : lstCurrentUsers) {
                    AccountShare accShare = new AccountShare();
                    accShare.AccountId = accRel.NOB_Compte__c;
                    accShare.UserOrGroupId = u.Id;
                    accShare.AccountAccessLevel = 'Read';
                    accShare.OpportunityAccessLevel = 'edit';
                    lstAccShare.add(accShare);
                }
            }
        }

        if (lstAccShare.size()>0) {
            insert lstAccShare;
        }

    }
    
    public static void accountSharingDelete(List<NOB_AccountRelationship__c> lstDeletedAR, Set<Id> setReparateurId){
        List<Id> lstAssureur = new List<Id>();

        for (NOB_AccountRelationship__c a : lstDeletedAR) {
            lstAssureur.add(a.NOB_Compte__c);
        }
        Map <String, List<User>> mapUsers = new Map <String, List<User>> ();
        //BBH : Code review 22/02/21, add user to list
        List<User> lstUsers = new List<User>();
        for (user u : [SELECT id, AccountId FROM User WHERE AccountId IN :setReparateurId AND IsActive = TRUE ]) {
            lstUsers.add(u);
            if (mapUsers.containsKey(u.accountid)) {
                List <User> lstUsersMap = mapUsers.get(u.accountid);
                lstUsersMap.add(u);
                mapUsers.put(u.accountid, lstUsersMap);
            } else {
                mapUsers.put(u.accountid, new List<User>{u});
            }
        }

        //BBH : Code review 22/02/21, add user to list in previous select
        //List<User> lstUsers = new List<User>([SELECT id FROM User WHERE AccountId IN :setReparateurId]);

        List<AccountShare> lstAccShare = new List<AccountShare>([SELECT id, AccountId, UserOrGroupId FROM AccountShare WHERE UserOrGroupId IN :lstUsers AND AccountId IN :lstAssureur]);

        //create acc share map
        Map <String, AccountShare> mapAccountShare = new Map <String, AccountShare> ();
        for (AccountShare accShare : lstAccShare) {
            String accShareKey = (String)accShare.AccountId + (String)accShare.UserOrGroupId;
        
            mapAccountShare.put(accShareKey, accShare);
        }
        //Get account share to be deleted
        List<AccountShare> lstAccShareToDelete = new List<AccountShare>();
        for (NOB_AccountRelationship__c ar : lstDeletedAR) {
            if(mapUsers.containsKey(ar.NOB_Bodyshop__c)){
                List<User> lstCurrentUsers = mapUsers.get(ar.NOB_Bodyshop__c);
                
                for (User u : lstCurrentUsers) {
                    String currentKey = (String)ar.NOB_Compte__c + (String)u.id;
                    
                    if (mapAccountShare.containsKey(currentKey)) {
                        lstAccShareToDelete.add(mapAccountShare.get(currentKey));
                    }
                }
            }
        }

        if (lstAccShareToDelete.size()>0) {
            delete lstAccShareToDelete;
        }

    }

    /**
     * @Description Creates Account Share by querying users' Account's AccountRelationships RSIW-8386
     * @param lstUser List to user for which to create Account Share
     * @return void
     * @author BBH
     * @date 22/02/2021
    */
    public static void userAccountSharing(Set<Id> setUserIds){
        Map<Id, List<User>> mapBodyshopUsers = new Map<Id, List<User>>();
        for(User u : [Select Id, AccountId from User where Id IN:setUserIds]){
            if(mapBodyshopUsers.containsKey(u.AccountId)){
                mapBodyshopUsers.get(u.AccountId).add(u);
            }
            else{
                mapBodyshopUsers.put(u.AccountId, new List<User>{u});
            }
        }

        List<AccountShare> lstAccountShares = new List<AccountShare>();
		
        List<NOB_AccountRelationship__c> accRels =[Select Id, NOB_Compte__c, NOB_Bodyshop__c from NOB_AccountRelationship__c where NOB_Bodyshop__c IN:mapBodyshopUsers.keySet() and NOB_Type__c=:NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR]; 
       
        for(NOB_AccountRelationship__c accRel : accRels){
            for(User u : mapBodyshopUsers.get(accRel.NOB_Bodyshop__c)){
                AccountShare accShare = new AccountShare();
                accShare.AccountId = accRel.NOB_Compte__c;
                accShare.UserOrGroupId = u.Id;
                accShare.AccountAccessLevel = 'Read';
                accShare.OpportunityAccessLevel = 'edit';
                lstAccountShares.add(accShare);
            }
        }

        if(lstAccountShares.size() > 0){
            System.enqueueJob(new AsyncInsertAccountShare(lstAccountShares));
        }
    }

    public  class AsyncInsertAccountShare implements Queueable{
        List<AccountShare> lstAccountShareToInsert = new List<AccountShare>();

        public AsyncInsertAccountShare(List<AccountShare> lstAccountShareToInsert) {
            this.lstAccountShareToInsert = lstAccountShareToInsert;
        }
        public void execute(QueueableContext context) {
            try {
                List<AccountShare> lstAccountShareToIns = new List<AccountShare>();
                List<AccountShare> lstAccountShareRemaining = new List<AccountShare>();
                for (Integer i = 0; i < lstAccountShareToInsert.size(); i++) {
                    if (i < 10000) {
                        lstAccountShareToIns.add(lstAccountShareToInsert[i]);
                    }
                    else{
                        lstAccountShareRemaining.add(lstAccountShareToInsert[i]);
                    }
                }
                insert lstAccountShareToIns;

                if (lstAccountShareRemaining.size() > 0) {
                    System.enqueueJob(new AsyncInsertAccountShare(lstAccountShareRemaining));
                }
            }
            catch (Exception e) {
                System.debug('Exception: '+e.getMessage());
            }
        }
    }
}