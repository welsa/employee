/*************************************************************************************
Class Name - NOB_CaseTriggerHandler
Version - 1.0
Created Date - 12/10/2020
Function - Class to Manage Case Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Kureem        12/10/2020  Original Version
  HMO           23-12-2020  Internal user from custom label
  HMO           08-07-2021  RSIW - 10319
  GBH           20/07/2021  RSIW-9967
  HMO           19-10-2021  RSIW-10330
  HMO           10-11-2021  RSIW-10330 : commenting if case scenario code is changed LINE 221 (onAfterUpdate)
*************************************************************************************/
public class NOB_CaseTriggerHandler {

    public static DateTime testDate = System.now();

    //HMO -- 11-10-2021
    private static Boolean userMigration = NOBTools.isMigrationUser();
    private static Boolean userInterface = NOBTools.isInterfaceUser();

    public void onAfterInsert(Case[] cases){

        //HMO -- 11-10-2021
        String profileName = NOBTools.ProfileName();

        //HMO -- 08-07-2021 -- RSIW 10319
        //RecordType rc = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'NOB_Cas_nominal'];
        Id rc = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NOB_Cas_nominal').getRecordTypeId();
        

        QueueSObject que = [Select Queue.Id From QueueSObject where Queue.Name = 'Nouvelle Demande' limit 1];

        //HMO --11-10-2021
        //List<Id> ids =new List<Id>();
        //for(Case ca : cases){
            //ids.add(ca.Id);
        //}

         //List<Case> caseList = [SELECT Id, RecordTypeId, Origin, NOB_Assure__c,  ContactId, OwnerId FROM Case WHERE Id IN: ids];
        //User u = [SELECT Id, Contact.AccountId, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];

        //HMO -- 11-10-2021
        List<Case> caseList = new List<Case>();
        
        for(Case ca : cases){
            Case cas = new Case(Id = ca.Id, RecordTypeId = ca.RecordTypeId, Origin = ca.Origin,NOB_Assure__c = ca.NOB_Assure__c, ContactId = ca.ContactId, OwnerId = ca.OwnerId );
            caseList.add(cas);
        }

     

        for(Case c : caseList){
            
   
            if(c.RecordTypeId.equals(rc)){
                System.debug('Entered Here:::');

                //HMO -- 11-10-2021
                //if(u.Profile.Name == 'PRE_CCP Assureur'){

                if (profileName == 'PRE_CCP Assureur'){
                    if(c.Origin != null && (c.Origin == 'Darva' || c.Origin == 'Web' || c.Origin == 'Web service' )){
                        
                        c.OwnerId = que.Queue.Id;
                    }else{
                        c.OwnerId =  System.Label.NOB_InternalUser;
                    }
                    if (c.NOB_Assure__c != null){ 
                            c.ContactId = c.NOB_Assure__c;
                    }
                    System.debug('Cassee::' + c);
                 }
            }
        }
      
        update caseList;
    }
    
    //HMO --23-12-2020
    // private Id getInternalUser(){
    //     String username = System.Label.NOB_InternalUser;
    //     List<User> users = [SELECT Id, username FROM User where username =: username];
    //     if(users.size() > 0){
    //     	return users.get(0).Id;
    //     }
    //     return null;
    // }

    public void onBeforeInsert(List<Case> lstNew){
        system.debug('## handleBeforeInsert start');


        //HMO --11-10-2021
        //if (!NOBTools.isMigrationUser) { 
          if (!userMigration){         
            Set<String> setInsurerClaimNumber = new Set<String>();
            for (Case c : lstNew) {
                setInsurerClaimNumber.add(c.NOB_InsurerClaimNumber__c);
            }
            
            checkInsurerClaimNumber(lstNew, setInsurerClaimNumber);
    
            //GBH 30/11/2020 RSIW-3907
            adjustPreferredCallTime(lstNew);
            handleCompensations(null, lstNew);
      	}
    }

    public void onBeforeUpdate(List<Case> lstNew, List<Case> lstOld, Map<Id, Case> mapOld){
		system.debug('## handleBeforeUpdate start');


        //HMO -- 11-10-2021
        //if (!NOBTools.isMigrationUser) {   
          if (!userMigration){       
            Set<String> setInsurerClaimNumber = new Set<String>();
    
            //get cases with updated NOB_InsurerClaimNumber__c
            List<Case> lstUpdatedClaimNumber = new List<Case>();
            for (Case c : lstNew) {
                
                if (c.NOB_InsurerClaimNumber__c != mapOld.get(c.id).NOB_InsurerClaimNumber__c) {
                    lstUpdatedClaimNumber.add(c);
                    setInsurerClaimNumber.add(c.NOB_InsurerClaimNumber__c);
                }
            }
    
            checkInsurerClaimNumber(lstUpdatedClaimNumber, setInsurerClaimNumber);
            
            handleCompensations(lstOld, lstNew);
        }
        //GBH  20/07/2021   RSIW-9967
        checkUnexpectedSC37(lstNew, lstOld, mapOld);
    }

    //GBH  20/07/2021   RSIW-9967
    private void checkUnexpectedSC37(List<Case> lstNew, List<Case> lstOld, Map<Id, Case> mapOld){
        //HMO -- 11-10-2021
        //if (NOBTools.isInterface) {
        if(userInterface){               
            for (Case c : lstNew) {
                
                if (c.Origin == 'Darva' &&
                    mapOld.get(c.id).Origin == 'Web service' &&
                    c.PFR_TECH_EngineerClaimNR__c != null && 
                    mapOld.get(c.id).PFR_TECH_EngineerClaimNR__c == null &&
                    c.NOB_ScenarioCode__c == '37' && 
                    mapOld.get(c.id).NOB_ScenarioCode__c == null &&
                    NOBTools.ProfileName == 'PRE_Integration' 
                    ) {
                        c.addError(System.Label.NOB_unexpectedSC37_ErrorMsg);
                }
            }
        }
    }

    private void checkInsurerClaimNumber(List<Case> lstUpdatedClaimNumber, Set<String> setInsurerClaimNumber){
        
        List<Case> lstCases = new List<Case>([SELECT Id, CaseNumber,PFR_TECH_STDClaimNr__c 
                                            FROM Case 
                                            WHERE 
                                                PFR_TECH_STDClaimNr__c IN :setInsurerClaimNumber]);

        Map<String, Case> mapDuplicate = new Map<String, Case>();

        for (Case c : lstCases) {
            String key =  c.PFR_TECH_STDClaimNr__c;
            mapDuplicate.put(key, c);
        }

        //look for cases with new NOB_InsurerClaimNumber__c value
        for (Case c : lstUpdatedClaimNumber) {
            String key = c.NOB_InsurerClaimNumber__c;
            Case duplicate = mapDuplicate.get(key);

            if (duplicate == null) {
                c.PFR_TECH_STDClaimNr__c = c.NOB_InsurerClaimNumber__c;
            } else {
                c.addError('Une requête avec le même numéro de sinistre existe déjà (N° de la requête ' + duplicate.CaseNumber + ')');
            }
        }
    }
    
    //HMO -- 08-07-2021 - rsiw 10319

    //RSIW - 10330 -- RLA
     private static List<Case> reloadCases(set<Id> setCaseIds){
        // List<Id> ids = new List<Id>();
        // for(Case ca : css){
        //     ids.add(ca.Id);
        // }
        
        return [SELECT Id, PFR_TECH_EngineerClaimNR__c, NOB_TECH_IsAXAorDA__c, NOB_ScenarioCode__c, NOB_BodyShop__c,NOB_BodyShop__r.NOB_NetworkCategory__c FROM Case WHERE Id IN: setCaseIds];
    }

    public void onAfterUpdate(List<Case> lstNew, List<Case> lstOld, Map<Id, Case> mapOld){
        system.debug('## handleAfterupdate start');
        
        //HMO -- 11-10-2021
        //if (!NOBTools.isMigrationUser) { 

          if(!userMigration){


            //List<Case> lstUpdatedCase = new List<Case>();
            set<Id> setCaseIds = new set<Id>();
            for (Case c: lstNew){

            //HMO -- 19-01-2021 -- RSIW - 10330
            //HMO -- 10-11-2021 -- RSIW - 10330
                if((c.NOB_ScenarioCode__c != null) || c.NOB_ScenarioCode__c != mapOld.get(c.Id).NOB_ScenarioCode__c && (c.NOB_ScenarioCode__c == '30' || c.NOB_ScenarioCode__c == '36' || c.NOB_ScenarioCode__c == '38') && c.PFR_TECH_EngineerClaimNR__c != null){
                    setCaseIds.add(c.Id);
                }
            }
			  //RLA 09/11/2021 optimisations 
              if (!(system.isFuture() || system.isBatch())){//WCH 26/01/2021 RSIW-11969 regression optimisation
                  updateDarvaFuture(setCaseIds);
              }
              else{
              	  updateDarva(setCaseIds);    
              }
            
            system.debug('## handleAfterupdate end');
            
        }

    }

    private void adjustPreferredCallTime(List<Case> lstNew){

        String[] ArrMS =  System.Label.NOB_morningStart.Split(':');
        String[] ArrME =  System.Label.NOB_morningEnd.Split(':');
        String[] ArrEE =  System.Label.NOB_eveningEnd.Split(':');
        Time morningStart = Time.newInstance(integer.valueof(ArrMS[0]), integer.valueof(ArrMS[1]), integer.valueof(ArrMS[2]), integer.valueof(ArrMS[3]));
        Time morningEnd = Time.newInstance(integer.valueof(ArrME[0]), integer.valueof(ArrME[1]), integer.valueof(ArrME[2]), integer.valueof(ArrME[3]));
        Time eveningEnd = Time.newInstance(integer.valueof(ArrEE[0]), integer.valueof(ArrEE[1]), integer.valueof(ArrEE[2]), integer.valueof(ArrEE[3]));

        for (Case c : lstNew) {

                //use start and end from values entered by user
                DateTime enteredStart = c.PFR_CallPreferedStartTime__c;
                Datetime enteredEnd = c.PFR_CallPreferedEndTime__c;

                if(enteredStart == null || enteredEnd == null){
                    //if user did not enter either start of end, we suggest a possible start and end
                    Datetime[] tmp = NOBTools.suggestPossibleStartEndDates(morningStart,morningEnd,eveningEnd);
                    enteredStart = tmp[0];
                    enteredEnd = tmp[1];
                }

                //calculate preferred based on suggested
                Datetime[] results = NOBTools.calculatePrefDates( enteredStart,  enteredEnd, morningStart,  morningEnd,  eveningEnd);
                DateTime prefStart = results[0];
                DateTime prefEnd = results[1];
                c.PFR_CalculatedCallPreferedStartTime__c = prefStart;
                c.PFR_CalculatedCallPreferedEndTime__c = prefEnd;

        }
        // }
    }

    
    
    public void handleCompensations(Case[] oldCases, Case[] newCases){
        Map<String,String> mapComp = getAllCompensations();
        Integer index = 0;
        for(Case acc : newCases){
            String newComp = acc.PFR_ASCompDecisionFinal__c;
            String oldComp = '';
            if(oldCases != null){
                oldComp = oldCases[index].PFR_ASCompDecisionFinal__c;
            }
            if(newComp == null){
                newComp = '';
            }
            
            if(oldComp == null){
                oldComp = '';
            }
            if(newComp != oldComp){
                String[] comps = newComp.split(';');
                String techComp = '';
                for(String comp : comps){
                    if(techComp != ''){
                    	techComp = techComp + ';' + mapComp.get(comp);
                    }else{
                        techComp = mapComp.get(comp);
                    }
                }
                if(techComp != null && techComp.length() > 254){
                    techComp = techComp.substring(0, 254);
                }
                acc.NOB_HistoriqueCompensationDecisionFinale__c = techComp;
            }
                
            index++;
        }
    }
    
    public static Map<String,String> getAllCompensations(){
        Map<String,String> item =new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Case.PFR_ASCompDecisionFinal__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            item.put(pickListVal.getValue(), pickListVal.getLabel());
            
            //lstRet.add(item);
        } 
        return item;
    }
    
    
	//RLA 09/11/2021 Optimisations
    @future (callout=true)
    public static void updateDarvaFuture(set<Id> setCaseIds){
		updateDarva(setCaseIds);        
    }
        
    
    public static void updateDarva(set<Id> setCaseIds){


        List<Case> reloaded = reloadCases(setCaseIds);


        /*for (Case c : lstNew) {
            if (mapOld.get(c.Id).PFR_TECH_EngineerClaimNR__c == null && c.PFR_TECH_EngineerClaimNR__c != null) {
                lstUpdatedCase.add(c);
            }
        }*/
        List<NOB_DarvaMessageLog__c> lstDarvaMsg = new List<NOB_DarvaMessageLog__c>([SELECT Id, NOB_MessageType__c, NOB_MessageSubType__c, NOB_Status__c, NOB_Case__c 
                                                                                    FROM NOB_DarvaMessageLog__c 
                                                                                    WHERE 
                                                                                        NOB_MessageType__c LIKE 'SD%' 
                                                                                        AND NOB_Status__c = 'En attente AS'
                                                                                        AND NOB_Case__c IN :reloaded]);
        
        List<NOB_DarvaMessageLog__c> toUpdate = new List<NOB_DarvaMessageLog__c>();

        if (lstDarvaMsg.size()>0) {
            for (Case c : reloaded) {
                for (NOB_DarvaMessageLog__c DMsg : lstDarvaMsg) {
                    if (DMsg.NOB_Case__c == c.Id) {
                        
                        String scena = c.NOB_ScenarioCode__c;
                        Id repa = c.NOB_BodyShop__c;
                        String claim = c.PFR_TECH_EngineerClaimNR__c;
                        //String status32 = 'En attente AS';
                        String networkCat = '';
                        if(c.NOB_BodyShop__r != null){
                            networkCat = c.NOB_BodyShop__r.NOB_NetworkCategory__c;
                        }
                        if(networkCat == null){
                            networkCat = '';
                        }
                         system.debug('status after if' + 'NOB_TECH_Nom_de_la_carrosserie__c :'+c.NOB_BodyShop__c  + 'claim' + claim + 'repa '+ repa +'scena '+scena );
         
                        
                        if(DMsg.NOB_MessageType__c == 'SD32'){
                            if(claim != null && repa != null && (scena == '30' || ((scena == '36' || scena == '38') && networkCat.contains('NNB')))){//WCH 16/02/2022 RSIW-11375
                                //DMsg.NOB_Status__c = 'New';
                                DMsg.NOB_Status__c = 'To be sent';
                                toUpdate.add(DMsg);
                                
                            }
                        }else if(DMsg.NOB_MessageType__c == 'SD40'){
                            
                            if(DMsg.NOB_MessageSubType__c == 'Type 2' || DMsg.NOB_MessageSubType__c == 'Type 4' || DMsg.NOB_MessageSubType__c == 'Type 5' || DMsg.NOB_MessageSubType__c == 'Type 6' || DMsg.NOB_MessageSubType__c == 'Type 7' ){
                                if(claim != null  && ( scena == '36' || scena == '38') ){
                                    //DMsg.NOB_Status__c = 'New';
                                    DMsg.NOB_Status__c = 'To be sent';
                                    toUpdate.add(DMsg);
                                }
                            }else{
                                if(claim != null && repa != null && ( scena == '36' || scena == '38') && !networkCat.contains('NNB') ){
                                    //DMsg.NOB_Status__c = 'New';
                                    DMsg.NOB_Status__c = 'To be sent';
                                    toUpdate.add(DMsg);
                                }
                            }
                            
                            
                        }
                        //DMsg.NOB_Status__c = 'New';
                    }
                }
            }
            if(toUpdate.size() > 0){
                system.debug('@@ i am updating a darva log');

                update toUpdate; 
            }
            
        }
    }
}