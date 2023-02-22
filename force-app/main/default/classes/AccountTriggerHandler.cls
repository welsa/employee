/*************************************************************************************
Class Name - AccountTriggerHandler
Version - 1.0
Created Date - 28 APR 2015
Function - Class to Manage AccountTrigger

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Yudish R          28/04/2015  Original Version
* Shamina M         11/02/2016  Case C-001496 - Use the Reference Number in Public Group for sharing to BS and Dist
* Welsa C           10/09/2020  C-003913: NOB - Anticipation - Create Expert RT on Account
* Welsa C           24/08/2020  C-003838 - Nob - Migrate Billing information to new fields
* Welsa C           22/09/2020  C-003923: NOB - Sharing Rules Management
* Welsa C           14/10/2020  C-004007: when creating account with recordtype expert, fill the Type field to Expert
* Kureem R          15/10/2020  RSIW-1988: Gestion history tracking competences
* Kejilen P         11/01/2021  RSIW-7209 - A la modification du ranking ou du taux annuel si gold le taux d'engagement doit �tre recalcul� 
* Welsa C           24/03/2021  C-004288 : PREFIKAR - Remove The Account Sharing when the Reference number is empty
* Hansraj M         26-07-2021  RSIW - 9655 : Mise à jour des engagements Préfikar / Réparateur
*Hansraj M          23/11/2021  RSIW : 11198
*Hansraj M          03/12/2021  RSIW : 9311
*Hansraj M          15-02-2021  RSIW : 5654
*************************************************************************************/
public without sharing class AccountTriggerHandler {

    //Bypass__c userBypass = Bypass__c.getInstance(UserInfo.getUserId());

    public void OnBeforeInsert(Account[] newAccounts){
        //WCH 24/08/2020 C-003838
        Map<String,String> MapCountryNameToCountryCode = getCountryNameMapCountryCode();
        //WCH 22/09/2020 C-003923
        boolean isAlphaScaleUser = ASPISTools.isAlphaScaleUser();
        system.debug('isAlphaScaleUser>>'+isAlphaScaleUser);
        
        //ap22
        List<Account> l_Accounts = new List<Account>();
        Set<String> s_AccountReference = new Set<String>();
        for(integer i=0;i<newAccounts.size();i++){
            if (newAccounts[i].ReferenceNumber__c != null)
            {
                l_Accounts.add(newAccounts[i]);
                s_AccountReference.add(newAccounts[i].ReferenceNumber__c );
            }
            //WCH 24/08/2020 C-003838
            if(String.isNotBlank(newAccounts[i].BillingCountry__c) && MapCountryNameToCountryCode.containsKey(newAccounts[i].BillingCountry__c)){
                newAccounts[i].BillingCountryCode__c=MapCountryNameToCountryCode.get(newAccounts[i].BillingCountry__c);
            }
            //WCH 22/09/2020 C-003923
            if(isAlphaScaleUser){
                newAccounts[i].isAspis__c=true;
            }
            //WCH 14/10/2020 C-004007
            if(String.isNotBlank(newAccounts[i].RecordtypeId) && newAccounts[i].RecordtypeId.equals(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ASPISConstants.ACCOUNT_RT_DeveloperName_Expert).getRecordTypeId())){
                newAccounts[i].Type=ASPISConstants.ACCOUNT_Type_Expert;
            }
        }

        //ap22
        if (s_AccountReference.size() > 0)
        {
            AP22PopulateContactOnAccount.populateContact(l_Accounts,s_AccountReference);
        }
    
        
       // handleCompetences(null, newAccounts);
    }
    
    
    public void NOBOnBeforeInsert(Account[] newAccounts){
        handleCompetences(null, newAccounts);
    }
    
    public void NOBOnBeforeUpdate(Account[] newAccounts,Account[] oldAccounts){
        handleCompetences(oldAccounts, newAccounts);
    }
    
    public void handleCompetences(Account[] oldAccounts, Account[] newAccounts){
        Map<String,String> competences = getAllCompetences();
        Integer index = 0;
        for(Account acc : newAccounts){
            String newCompetences = acc.NOB_SkillSet__c;
            String oldCompetences = '';
            if(oldAccounts != null){
                oldCompetences = oldAccounts[index].NOB_SkillSet__c;
            }
            if(newCompetences == null){
                newCompetences = '';
            }
            
            if(oldCompetences == null){
                oldCompetences = '';
            }
            if(newCompetences != oldCompetences){
                String[] comps = newCompetences.split(';');
                String techComp = '';
                for(String comp : comps){
                    if(techComp != ''){
                        techComp = techComp + ';' + competences.get(comp);
                    }else{
                        techComp = competences.get(comp);
                    }
                }
                if(techComp != null && techComp.length() > 254){
                    techComp = techComp.substring(0, 254);
                }
                acc.NOB_TECH_SkillSets__c = techComp;
            }
                
            index++;
            
            //HMO -- RSIW 5654 - 15--02-2021
            if (Trigger.isBefore && Trigger.isInsert){
                System.debug('£ in before insert ');
                acc.NOB_isPrefikar__c = true;
            }
        }
    }
    
    public static Map<String,String> getAllCompetences(){
        Map<String,String> item =new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Account.NOB_SkillSet__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            item.put(pickListVal.getValue(), pickListVal.getLabel());
            
            //lstRet.add(item);
        } 
        return item;
    }
    
    public void onAfterInsert(Account[] newAccounts){
        system.debug('######### START onAfterInsert Account trigger handler');
        
        map <String,Id> accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
        
        //list<Group> groupsToBeInserted = new list <Group> ();
        //list<AccountShare> accountShareToBeInserted = new list<AccountShare>();
        
        // ABT 05-APR-2016 C-1496
        Map<String, Account> mapReferenceNumberAccount = new Map<String, Account>();

        for(integer i=0;i<newAccounts.size();i++){
            if((newAccounts[i].RecordTypeId==accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor) || 
                newAccounts[i].RecordTypeId==accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop) || 
                newAccounts[i].RecordTypeId==accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Expert))/*WCH 10/09/2020 C-003913 */
                && String.isNotBlank(newAccounts[i].ReferenceNumber__c)/*WCH 24/03/2021 C-004288 */)
            {
                // //Shamina M: case 1496 - using ReferenceNumber__c for uniqueness of group name and dev name
                // system.debug('##### newAccounts[i].RecordTypeId:'+newAccounts[i].RecordTypeId);
                // groupsToBeInserted.add(new Group(Name=newAccounts[i].ReferenceNumber__c));
                // //groupsToBeInserted.add(new Group(Name=newAccounts[i].Name));
                // 
                // accountShareToBeInserted.add(new AccountShare(AccountId = newAccounts[i].Id
                //          ,AccountAccessLevel='Edit',OpportunityAccessLevel='Edit'));

                // ABT 05-APR-2016 C-1496
                mapReferenceNumberAccount.put(newAccounts[i].ReferenceNumber__c, newAccounts[i]);
            }//end if 

        }//end loop

                
        //Shamina M- case 1496 - managed exception by creating logs
        try{
            // if(groupsToBeinserted.size() > 0)
            //  system.debug('########## groupsToBeInserted: '+groupsToBeInserted);
            //     insert groupsToBeInserted;
            //     system.debug('########## groupsToBeInserted: '+groupsToBeInserted);
            // 
            // for(integer i=0;i<groupsToBeInserted.size();i++){
            //  accountShareToBeInserted[i].UserOrGroupId = groupsToBeInserted[i].Id;
            // }
            // 
            // if(accountShareToBeInserted.size()>0){
            //  insert accountShareToBeInserted;
            // }//end if

            // ABT 05-APR-2016 C-1496
            if (mapReferenceNumberAccount.size() > 0)
            {
                AP28UserAccountGroupSharing.shareAccount(mapReferenceNumberAccount);
            }

        } catch(Exception ex){
            Utils_ManageLogs.createLogFromException('AccountTriggerHandler', 'Group', ex);
        }

   
        /*
        if(groupsToBeinserted.size()>0){
            insert groupsToBeInserted;
        }//end if
        
        
        for(integer i=0;i<groupsToBeInserted.size();i++){
            accountShareToBeInserted[i].UserOrGroupId = groupsToBeInserted[i].Id;
        }

        system.debug('////accountShareToBeInserted: '+accountShareToBeInserted);
        if(accountShareToBeInserted.size()>0){
            insert accountShareToBeInserted;
        }//end if
        */
        system.debug('######### END onAfterInsert Account trigger handler');
    }//end method
    
    public void onBeforeUpdate(Account[] newAccounts,Account[] oldAccounts){
        //WCH 24/08/2020 C-003838
        Map<String,String> MapCountryNameToCountryCode = getCountryNameMapCountryCode();
        
        for(integer i=0;i<newAccounts.size();i++){
            //WCH 24/08/2020 C-003838
            if(String.isNotBlank(newAccounts[i].BillingCountry__c) && MapCountryNameToCountryCode.containsKey(newAccounts[i].BillingCountry__c)){
                newAccounts[i].BillingCountryCode__c=MapCountryNameToCountryCode.get(newAccounts[i].BillingCountry__c);
            }
            //WCH 14/10/2020 C-004007
            if(String.isNotBlank(newAccounts[i].RecordtypeId) && newAccounts[i].RecordtypeId.equals(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ASPISConstants.ACCOUNT_RT_DeveloperName_Expert).getRecordTypeId())){
                newAccounts[i].Type=ASPISConstants.ACCOUNT_Type_Expert;
            }
        }//end loop
        
        //handleCompetences(oldAccounts, newAccounts);
    }
    
    
    public void onAfterUpdate(Account[] newAccounts,Account[] oldAccounts){
        //Shamina M: case 1496 - update on group is no longer applicable when account name is updated
        /*
        list<Group> groupsToBeUpdated = new list <Group> ();
        map<string,string> accountNamesMap = new map <string,string>();
        
        for(integer i=0;i<newAccounts.size();i++){
            if(newAccounts[i].Name != oldAccounts[i].Name){
                accountNamesMap.put(oldAccounts[i].Name,newAccounts[i].Name);
            }//end if
        }//end loop
        
        //build map groupName and groupId
        for(Group g:[select Id,Name,DeveloperName from Group where Name IN: accountNamesMap.Keyset()]){
            groupsToBeUpdated.add(new Group(Id=g.Id,Name=accountNamesMap.get(g.Name)));
        }//end loop
        
        system.debug('////groupsToBeUpdated: '+groupsToBeUpdated);
        if(groupsToBeUpdated.size()>0){
            update groupsToBeUpdated;
        }//end if
        */

    }//end method
    //WCH 24/08/2020 C-003838
    public Map<String,String> getCountryNameMapCountryCode(){
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,String> returnMap = new Map<String,String>();
        for( Schema.PicklistEntry f : ple){
            returnMap.put(f.getLabel(),f.getValue());
        }
        return returnMap;
   }
    public void NOBOnAfterUpdate(list<Account> lstNew, map<Id,Account> mapOldAcc){
        System.debug('##### Start AccountTriggerHandler.NOBOnAfterUpdate ####');
        set<Id> AccSetId = new set<Id>();
        Set<Id> setAccIds = new Set<Id>();
        //HMO -- 23-11-2021 -- RSIW 11198
        Set<Id> setAccs = new set<Id>();

        //HMO -- RSIW 9311 -- 03-12-2021
        Set<Id> setAccsToUpdate = new set<Id>();
        //RLA 17/12/2021 RSIW-5638: Contrôle sur la présence dans photos Prospect -> En attente (8 photos mini.)
        Map<Id,Account> mapAcc = new map<Id,Account>();

        String context = '';
        
        for (Account acc : lstNew){
            if (acc.NOB_Ranking__c != mapOldAcc.get(acc.Id).NOB_Ranking__c){
                AccSetId.add(acc.Id);
            }

            //RSIW - 9655 : Mise à jour des engagements Préfikar / Réparateur -- HMO -- 26/07/2021
            /*if (((acc.NOB_Ranking__c != mapOldAcc.get(acc.Id).NOB_Ranking__c) && acc.NOB_Ranking__c != null) || ((acc.NOB_TrainingDate__c != mapOldAcc.get(acc.Id).NOB_TrainingDate__c) && acc.NOB_TrainingDate__c != null)){
                setAccIds.add(acc.Id);
            }*/

            //HMO -- 05-09-2021
            if ((acc.NOB_Ranking__c != mapOldAcc.get(acc.Id).NOB_Ranking__c) && acc.NOB_Ranking__c != null){
                context = NOB_AP00_Constants.contextRK;
                setAccIds.add(acc.Id);
            }

            if ((acc.NOB_TrainingDate__c != mapOldAcc.get(acc.Id).NOB_TrainingDate__c) && acc.NOB_TrainingDate__c != null ) {
                context = NOB_AP00_Constants.contextDF;
                setAccIds.add(acc.Id);
            }
            
            //HMO -- 23-11-2021 -- RSIW 11198
            if (acc.NOB_TECHTriggerZoneIntervention__c != mapOldAcc.get(acc.Id).NOB_TECHTriggerZoneIntervention__c){
                setAccs.add(acc.id);
            }

            //HMO -- RSIW 9311 -- 03-12-2021
            if ((acc.NOB_DateFinPartenariat__c != mapOldAcc.get(acc.Id).NOB_DateFinPartenariat__c) && acc.NOB_DateFinPartenariat__c == null){
                setAccsToUpdate.add(acc.Id);
            }

            //RLA 17/12/2021 RSIW-5638: Contrôle sur la présence dans photos Prospect -> En attente (8 photos mini.)
            if (acc.NOB_Statut__c != mapOldAcc.get(acc.Id).NOB_Statut__c && String.isNotBlank(acc.NOB_Statut__c) && acc.NOB_Statut__c == 'En attente' && mapOldAcc.get(acc.Id).NOB_Statut__c == 'Prospect'){
                mapAcc.put(acc.Id,acc);
            }
        }
        
        system.debug('#### AccSetId ### ' + AccSetId);        
        if(AccSetId.size()>0){
            NOB_AP60_DispoEntreesCal.updateDispo(AccSetId);
            NOB_AP59_TauxEngagementPourcentCal.updateMissionReserve(AccsetId);
        }

        //RSIW - 9655 : Mise à jour des engagements Préfikar / Réparateur -- HMO -- 26/07/2021
        system.debug('#### setAccIds ### ' + setAccIds);   
        if (setAccIds.size() > 0){
            NOB_AP61_UpdateRankingQuarter.getServiceContracts(setAccIds, context);
        }
        
       //HMO -- 23-11-2021 -- RSIW 11198
       if (setAccs.size() > 0){
            NOB_AP66_ZoneInterventionUtility.queryZonesfromAcc(setAccs);
       }

       //HMO -- RSIW 9311 -- 03-12-2021
        if (setAccsToUpdate != null && !setAccsToUpdate.isEmpty()){
            NOB_AP67_EmailDateFinPartenariat.clearRaisonAccount(setAccsToUpdate);
        }

        if(mapAcc.size() > 0){
            NOB_AP58_ContentDocumentCheck.checkPhotos(mapAcc);
        }
        System.debug('##### Stop AccountTriggerHandler.NOBOnAfterUpdate ####');
    }
}