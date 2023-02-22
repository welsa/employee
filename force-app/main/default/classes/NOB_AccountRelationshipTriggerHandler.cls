public without sharing class NOB_AccountRelationshipTriggerHandler {
    
    public void onAfterDelete(List<NOB_AccountRelationship__c> lstOld){
        List<Id> lstDeletedId = new List<Id>();
        Set<Id> setReparateurId = new Set<Id>();
        //get list of deleted bodyshop id from deleted Relation compte
        for (NOB_AccountRelationship__c ar : lstOld) {
            lstDeletedId.add(ar.NOB_Bodyshop__c);
            if (ar.NOB_Type__c == NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR) {
                setReparateurId.add(ar.NOB_Bodyshop__c);
            }

        }
        
        NOB_AP55_AccountSharing.accountSharingDelete(lstOld, setReparateurId);


        List <NOB_AccountRelationship__c> lstAR = new List<NOB_AccountRelationship__c>([SELECT id, NOB_Compte__c,NOB_Bodyshop__c
                                                                                        FROM NOB_AccountRelationship__c
                                                                                        WHERE NOB_Type__c = :NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR
                                                                                            AND NOB_Bodyshop__c IN :lstDeletedId
                                                                                       ]);
        //get All accounts to be updated
        Map<id, Account> mapAccToUpdate = new Map<id, Account>([SELECT id, nob_tech_AssureurId__c FROM Account WHERE id in :lstDeletedId]);
        List<Account> lstAccToUpdate = new List<Account>();
        for (Id a : lstDeletedId) {
            String AssureurIds = '';
            for (NOB_AccountRelationship__c ar : lstAR) {
                if (a == ar.NOB_Bodyshop__c) {
                     AssureurIds = AssureurIds + ar.NOB_Compte__c + ';';
                }
            }

            mapAccToUpdate.get(a).nob_tech_AssureurId__c = AssureurIds;
            if(!lstAccToUpdate.contains(mapAccToUpdate.get(a)))
            	lstAccToUpdate.add(mapAccToUpdate.get(a));
        }
        if(lstAccToUpdate.size() > 0)
        	update lstAccToUpdate;
    }

    public void onAfterInsert(List<NOB_AccountRelationship__c> lstNew){
        List<NOB_AccountRelationship__c> lstFilteredAR = new List<NOB_AccountRelationship__c>();
        Set<Id> lstReparateurId = new Set<Id>();
        for (NOB_AccountRelationship__c accRel : lstNew) {
            if (accRel.NOB_Type__c == NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR) {
                lstFilteredAR.add(accRel);
                lstReparateurId.add(accRel.NOB_Bodyshop__c);
            }
        }
        if(lstFilteredAR.size() > 0) {
            NOB_AP55_AccountSharing.accountSharing(lstFilteredAR, lstReparateurId);
        }
    }

    public void onAfterUpdate(List<NOB_AccountRelationship__c> lstNew, Map<Id, NOB_AccountRelationship__c> mapOld){
        List<NOB_AccountRelationship__c> lstFilteredAR = new List<NOB_AccountRelationship__c>();
        Set<Id> setReparateurId = new Set<Id>();
        List<NOB_AccountRelationship__c> lstOldFilteredAR = new List<NOB_AccountRelationship__c>();
        Set<Id> setOldReparateurId = new Set<Id>();

        for (NOB_AccountRelationship__c accRel : lstNew) {
            //BBH 23/02/21 - check for type update
            if (accRel.NOB_Bodyshop__c != mapOld.get(accRel.id).NOB_Bodyshop__c || accRel.NOB_Compte__c != mapOld.get(accRel.id).NOB_Compte__c || accRel.NOB_Type__c != mapOld.get(accRel.Id).NOB_Type__c){
                if(mapOld.get(accRel.Id).NOB_Type__c == NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR) {
                    lstOldFilteredAR.add(mapOld.get(accRel.id));
                    setOldReparateurId.add(mapOld.get(accRel.id).NOB_Bodyshop__c);
                }
                if(accRel.NOB_Type__c == NOB_AP00_Constants.ACCOUNT_RELATIONSHIP_TYPE_REPARATEUR_ASSUREUR) {
                    lstFilteredAR.add(accRel);
                    setReparateurId.add(accRel.NOB_Bodyshop__c);
                }
            }
        }
        if(lstOldFilteredAR.size() > 0) {
            NOB_AP55_AccountSharing.accountSharingDelete(lstOldFilteredAR, setOldReparateurId);
        }
        if(lstFilteredAR.size() > 0) {
            NOB_AP55_AccountSharing.accountSharing(lstFilteredAR, setReparateurId);
        }
    }
}