/*************************************************************************************
Class Name - NOB_AP56_DocumentFinancierSharing
Version - 1.0
Created Date - 13 JUL 2021
Function - Class to Manage UserTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Sedera            13/07/2021  RSIW 9849 - Visibilité des Documents financiers
* Hansraj(Spoon)    03-05-2022  RSIW 11049 
*************************************************************************************/

public without sharing class NOB_AP56_DocumentFinancierSharing {
    
    public static void documentFinancierSharing(List<PFR_FinancialDocument__c> lstDocFin, Set<Id> setdocIdBilledPartyAccount){
     System.debug('@@@lstDocFin@@@' + lstDocFin);
     System.debug('@@@setdocIdBilledPartyAccount@@@' + setdocIdBilledPartyAccount);
    List<PFR_FinancialDocument__Share> lstDocFinShare = new List<PFR_FinancialDocument__Share> ();
    Map <String, List<User>> mapUsers = new Map <String, List<User>> ();
    for (user u : [SELECT id, AccountId FROM User WHERE AccountId IN :setdocIdBilledPartyAccount  AND Profile.name = 'CCP Bodyshop' AND NOB_isPrefikar__c =:NOBTools.isPrefikarUser() AND IsActive = TRUE  and Account.RecordType.DeveloperName =: NOB_AP00_Constants.ACCOUNT_RECORDTYPE_BODYSHOP]) {
        if (mapUsers.containsKey(u.AccountId)) {
            List <User> lstUsersMap = mapUsers.get(u.AccountId);
                lstUsersMap.add(u);
                mapUsers.put(u.AccountId, lstUsersMap);
        } else {
                mapUsers.put(u.AccountId, new List<User>{u});
            }
    }

    for (PFR_FinancialDocument__c finDoc : lstDocFin) {
        if (mapUsers.containsKey(finDoc.PFR_BilledPartyAccount__c)) {
            List<User> lstCurrentUsers = mapUsers.get(finDoc.PFR_BilledPartyAccount__c);

            for (User u : lstCurrentUsers) {
                PFR_FinancialDocument__Share docFinShare = new PFR_FinancialDocument__Share();
                docFinShare.ParentId = finDoc.Id;
                docFinShare.UserOrGroupId = u.Id;
                docFinShare.AccessLevel = 'Read';
                //docFinShare.RowCause  = Schema.PFR_FinancialDocument__Share.RowCause.Manual;
                lstdocFinShare.add(docFinShare);
            }
        }
    }

    if (lstdocFinShare.size()>0) {
        insert lstdocFinShare;
        System.debug('@@@Insert OKOK@@@');
    }
}



    @future // to avoid issue  first error: MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): PFR_FinancialDocument__Share, original object: User: []
    public static void userShareDocFinSharing(Set<Id> setUserIdsDocFin, Set<Id> setdocIdBilledPartyAccount){
        system.debug('setUserIdsDocFin==' + setUserIdsDocFin);
        system.debug('setdocIdBilledPartyAccount==' + setdocIdBilledPartyAccount);
        List<User> lstUser = new List<User>();
        //List<PFR_Transaction__c> lstransaction;
        List<PFR_FinancialDocument__Share> lstdocFinShare = new List<PFR_FinancialDocument__Share> ();
        //Set<Id> SetDocFin = new Set<Id> ();
        if (setdocIdBilledPartyAccount.size() > 0){
           /* lstransaction = [SELECT Name, PFR_DebtOrCreditThirdPartyAccount__c, PFR_ReferenceFinDoc__c FROM PFR_Transaction__c WHERE PFR_DebtOrCreditThirdPartyAccount__c =: setDebtOrCreditThirdPartyAccountId];
            for (PFR_Transaction__c trans : lstransaction){
                SetDocFin.add(trans.PFR_ReferenceFinDoc__c);
            }*/
           /* for(User u : [Select Id, AccountId from User where Id IN:SetDocFin2 AND IsActive = TRUE]){
                lstUser.add(u);
            }*/
            //lstdocFinShare = new List<PFR_FinancialDocument__Share>([SELECT id, UserOrGroupId, ParentId, AccessLevel FROM PFR_FinancialDocument__Share WHERE UserOrGroupId IN :setUserDocFinIds]);
            //for (PFR_FinancialDocument__Share dFShare : lstdocFinShare) {
            for (PFR_FinancialDocument__c docF : [SELECT Id, PFR_BilledPartyAccount__c FROM PFR_FinancialDocument__c WHERE PFR_BilledPartyAccount__c IN: setdocIdBilledPartyAccount]){
                for (Id u : setUserIdsDocFin) {
                        PFR_FinancialDocument__Share dcShare = new PFR_FinancialDocument__Share();
                        dcShare.ParentId = docF.Id;
                        dcShare.UserOrGroupId = u;
                        dcShare.AccessLevel = 'Read';
                        lstdocFinShare.add(dcShare); 
                }
            }
             system.debug('lstdocFinShare==' + lstdocFinShare);
    
             if (lstdocFinShare.size()>0) {
                insert lstdocFinShare;
            }
        }
    }

    //HMO -- RSIW 11049
    public static void checkValidationFR(List<PFR_FinancialDocument__c> lstNew, Map<Id,List<PFR_FinancialDocument__c>> mapFS){
        
        Set<Id> setDocFinId = (new Map<Id,PFR_FinancialDocument__c>(lstNew)).keySet().clone();
        Map<Id, List<PFR_FinancialDocument__c>> mapDocFinCase = new Map<Id,List<PFR_FinancialDocument__c>>(); 
        List<PFR_FinancialDocument__c> lstDocFin = new List<PFR_FinancialDocument__c>();
       

        for (Case ca : [select Id, (select Id from Financial_Documents__r
        where PFR_RecordTypeTech__c = 'FR' and (PFR_DocumentStatus__c != 'MA' AND PFR_DocumentStatus__c != 'RJ' AND PFR_DocumentStatus__c != 'AN') AND Id NOT IN: setDocFinId) from case where Id IN: mapFS.keySet()]){

            mapDocFinCase.put(ca.Id, ca.Financial_Documents__r);
        }

      
        if (!mapFS.isEmpty()){
          
            for (Id caId : mapFS.keySet()){
            
                if (!mapDocFinCase.isEmpty() && mapDocFinCase.containsKey(caId) && mapDocFinCase.get(caId) != null && mapDocFinCase.get(caId).size() > 0){
                   
                    continue;
                }else{
                  
                    lstDocFin.addAll(mapFS.get(caId));
                }
            }
        }
    
        Map<Id, Boolean> mapDocValidate;
        if (!lstDocFin.isEmpty()){
            mapDocValidate = new Map<Id, Boolean>();
            Set<Id> setDocument = (new Map<Id,PFR_FinancialDocument__c>(lstDocFin)).keySet().clone();
            Map<Id, PFR_FinancialDocument__c> mapDocsClamentures = new Map<Id,PFR_FinancialDocument__c>(); 
          

            for (PFR_FinancialDocument__c document : [select PFR_CaseBusinessProvider__r.NOB_ClamentureSinistreFacturation__c ,PFR_InsurerCaseNumber__c from PFR_FinancialDocument__c where Id IN:setDocument]){
             
                mapDocsClamentures.put(document.Id, document);
            }

          
            if (!mapDocsClamentures.isEmpty()){
                Map<Id, Boolean> mapBoolean;
                for (Id Id : mapDocsClamentures.keySet()){
                    String numeroSinistre;
                    String regex;
                    if (mapDocsClamentures.containsKey(id)){
                        numeroSinistre = mapDocsClamentures.get(id).PFR_InsurerCaseNumber__c;
                        regex = mapDocsClamentures.get(id).PFR_CaseBusinessProvider__r.NOB_ClamentureSinistreFacturation__c;
                    }
                    
                    if(regex != null && numeroSinistre != null){
                        mapBoolean = getNonClamentures(regex,numeroSinistre,Id);
                    }

           
                    if (mapBoolean != null){
                       
                        mapDocValidate.putAll(mapBoolean);
                    }
                }
            }
        }

        List<PFR_FinancialDocument__c> lstDocFinToAfterInsert;
        Set<Id> setDocFinBeforeUpdate;
        if (mapDocValidate != null && !mapDocValidate.isEmpty()){
          
            lstDocFinToAfterInsert = new List<PFR_FinancialDocument__c>();
            setDocFinBeforeUpdate= new set<Id>();
            for (Id docFin : mapDocValidate.keySet()){
              

                if (Trigger.isExecuting && Trigger.isAfter){
                    PFR_FinancialDocument__c newDoc = new PFR_FinancialDocument__c();
                    newDoc.Id = docFin;
                    newDoc.PFR_DocumentStatus__c = 'VL';
                    
                    lstDocFinToAfterInsert.add(newDoc);
                }

                if (Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate){
                    setDocFinBeforeUpdate.add(docFin);
                }
            }
        }

        if (setDocFinBeforeUpdate != null && setDocFinBeforeUpdate.size() > 0){
            for (PFR_FinancialDocument__c docUpdate : lstNew){
                if(setDocFinBeforeUpdate.contains(docUpdate.Id)){
                    docUpdate.PFR_DocumentStatus__c = 'VL';
                }
            }
        }

        if (lstDocFinToAfterInsert != null && lstDocFinToAfterInsert.size() > 0){
          
            update lstDocFinToAfterInsert;
        }
    }

    public static Map<Id,Boolean> getNonClamentures(String regex, String numSinistre, Id facture){
    

        Map<Id,Boolean> mapValid = new Map<Id,Boolean>();
        Pattern MyPattern = Pattern.compile(regex);
    
        Matcher MyMatcher = MyPattern.matcher(numSinistre);
     

        if (MyMatcher.matches()){
            mapValid.put(facture,true);
        }
        
        return mapValid;

    }
    //HMO -- RSIW 11049

}