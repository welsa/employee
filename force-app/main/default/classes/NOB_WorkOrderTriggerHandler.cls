/**
* @description       : 
* @author            : GBH
* @group             : 
* @last modified on  : 02-16-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author   Modification
* 1.1   11-23-2020   GBH      RSIW-4580
* 1.2   11-25-2020   ARA      RSIW-3907
* 1.3   11-25-2020   KPA      RSIW-4182
* 1.4   01-15-2021   KPA       RSIW-7602
* 1.5   10-JUN-2021  GBH       RSIW-9793
* 1.6   08-JUL-2021  HMO       RSIW-10319
**/
public class NOB_WorkOrderTriggerHandler {
    
    private static String profileName = NOBTools.ProfileName();

    public  NOB_WorkOrderTriggerHandler(){
        
    }
    
    public void handleBeforeInsert(List<WorkOrder> workorders){ 
        system.debug('## handleBeforeInsert start :' +workorders);
        //handleTaux(workorders);   
        
    }
    
    public void handleBeforeUpdate(List<WorkOrder> workorders){   
        system.debug('## handleBeforeUpdate start :' +workorders);
        //handleTaux(workorders);
    }
    
    //KPA 15/01/2021 RSIW-7602 
    private static void handleTaux(List<WorkOrder> workorders){
        
        Map<Id,Id> mapWoIdBsId = new Map<Id,Id>();
        List<Id> repIds = new List<Id>();
        
        Map<Id,Id> mapWoIdAsurId = new Map<Id,Id>();
        List<Id> AssureurIds = new List<Id>();
        
        for(WorkOrder wo : workorders){
            system.debug('## handleTaux - WO :' + wo);
            system.debug('## handleTaux - case :' + wo.case);
            mapWoIdBsId.put(wo.Id, wo.NOB_Reparateur__c);
            
            if(!repIds.contains(wo.NOB_Reparateur__c)){
                repIds.add(wo.NOB_Reparateur__c);
            }   
            
            mapWoIdAsurId.put(wo.Id, wo.case.NOB_BusinessProvider__c);
            
            if(!AssureurIds.contains(wo.case.NOB_BusinessProvider__c)){
                System.debug('## handleTaux - AssureurIds.add:' +wo.case.NOB_BusinessProvider__c);
                AssureurIds.add(wo.case.NOB_BusinessProvider__c);
            }             
        }
        
        
        
        
        List<NOB_TauxNeg__c> taux = [SELECT Id, Name, NOB_RelationCompte__r.NOB_Bodyshop__c, NOB_RelationCompte__r.NOB_Compte__c, NOB_Active__c FROM NOB_TauxNeg__c WHERE (NOB_RelationCompte__r.NOB_Bodyshop__c IN:repIds OR NOB_RelationCompte__r.NOB_Compte__c IN:AssureurIds)  AND NOB_Active__c = TRUE];
        System.debug('taux:' +taux);
        for(NOB_TauxNeg__c tau : taux){
            for(WorkOrder wo : workorders){
                //System.debug('## handleTaux - taux:' + wo.NOB_Reparateur__c +'=='+ tau.NOB_RelationCompte__r.NOB_Bodyshop__c+ ' && '+ wo.case.NOB_BusinessProvider__c +' == '+ tau.NOB_RelationCompte__r.NOB_Compte__c);
                if(wo.NOB_Reparateur__c == tau.NOB_RelationCompte__r.NOB_Bodyshop__c  && wo.case.NOB_BusinessProvider__c == tau.NOB_RelationCompte__r.NOB_Compte__c ){
                    System.debug('## handleTaux - tauxfoud:::' + tau);
                    
                    wo.NOB_NegoRate__c = tau.Id;
                }
            }
        }
        if(workorders.size() > 0){
            update workorders;
        }
        system.debug('## handleTaux - End');
        
    }
    
    
    //HMO -- 08-07-2021 -- RSIW-10319
    private static List<WorkOrder> reloadWorkorders(List<WorkOrder> wos){
        List<Id> ids = new List<Id>();
        for(WorkOrder wo : wos){
            ids.add(wo.Id);
        }
        
        return [SELECT Id, CaseId, Case.PFR_TECH_EngineerClaimNR__c, Case.NOB_TECH_IsAXAorDA__c, Case.NOB_ScenarioCode__c, Case.NOB_BodyShop__c, Case.NOB_BodyShop__r.NOB_NetworkCategory__c,Case.NOB_BusinessProvider__c,NOB_Reparateur__c,NOB_NegoRate__c FROM WorkOrder WHERE Id IN: ids];
        
    }
    
    public void onAfterInsert(List<WorkOrder> workorders){
        system.debug('## handleAfterCreate start :' +workorders);
        system.debug('## handleAfterCreate start :' +NOBTools.isMigrationUser);
        List<NOB_DarvaMessageLog__c> messageLogs = new List<NOB_DarvaMessageLog__c>();
        List<NOB_SMSLog__c> smsLogs = new List<NOB_SMSLog__c>();
        Map<Id,Boolean> mapIsAxaDa = new Map<Id,Boolean>();
        
        if (!NOBTools.isMigrationUser) {
            list <WorkOrder> lstWO =  reloadWorkorders(workorders);
            //WCH 16/02/2022 RSIW-12213
            List<NOB_DarvaMessageLog__c> caseSD40InError = new List<NOB_DarvaMessageLog__c>();
            Set<Id> woCases = new Set<Id>();
            boolean caseHasSD40InError =false;

            //[SELECT Id, case.PFR_TECH_EngineerClaimNR__c, Case.NOB_TECH_IsAXAorDA__c FROM WorkOrder WHERE Id IN : workorders];
        
            handleTaux(lstWO);
        
            Map<Id, string> WOCaseMap = new Map<Id, string>();
            Map<Id,WorkOrder> mpWo = new Map<Id,WorkOrder>();
            
            for(WorkOrder wo: lstWO){
                if(!WOCaseMap.containsKey(wo.Id)){
                    WOCaseMap.put(wo.Id, wo.case.PFR_TECH_EngineerClaimNR__c );
                }  
                if(!mapIsAxaDa.containsKey(wo.Id)){
                    mapIsAxaDa.put(wo.Id,wo.Case.NOB_TECH_IsAXAorDA__c);
                }
                mpWo.put(wo.Id, wo);
                woCases.add(wo.caseId);//WCH 16/02/2022 RSIW-12213
            }
            //WCH 16/02/2022 RSIW-12213
            caseSD40InError =[select Id from NOB_DarvaMessageLog__c where NOB_Case__c in :woCases and NOB_Status__c='Error' and NOB_MessageType__c = 'SD40'];
            if(caseSD40InError.size()>0) caseHasSD40InError=true;
            
            
            List<Id> caseIds  = new List<Id>();
            for(WorkOrder wo : workorders){
                if(!caseIds.contains(wo.CaseId))
                    caseIds.add(wo.CaseId);
            }
            
            //HMO -- 09-07-2021 -- RSIW 10319
            /*Map<Id,Id> mpCsCnt = new Map<Id,Id>();
            List<Case> cases = [SELECT Id, ContactId FROM Case WHERE Id IN: caseIds];
            for(Case ca : cases){
                mpCsCnt.put(ca.Id,ca.ContactId);
            }*/
            
            // ARA RSIW-3907 :update PFR_CallStatus__c on Task
            updateTask(workorders);
            
            // User user = [Select NOB_isMigrationUser__c from User where Id =:UserInfo.getUserId() limit 1];
            
            for(WorkOrder wo : workorders){
                System.debug('##workorders :' +wo);
                
                System.debug('retrieve info' +  wo.CaseId + ' '+ case.PFR_TECH_EngineerClaimNR__c);
                NOB_DarvaMessageLog__c log = new NOB_DarvaMessageLog__c();
                log.NOB_Case__c = wo.CaseId;
                log.NOB_ActionType__c = 'New';
                
                WorkOrder reloaded = mpWo.get(wo.Id);
                
                String scena = reloaded.Case.NOB_ScenarioCode__c;
                Id repa = reloaded.Case.NOB_BodyShop__c;
                String claim = reloaded.Case.PFR_TECH_EngineerClaimNR__c;
                String status = 'En attente AS';
                String networkCat = '';
                if(reloaded.Case.NOB_BodyShop__r != null){
                    networkCat = reloaded.Case.NOB_BodyShop__r.NOB_NetworkCategory__c;
                }
                if(networkCat == null){
                    networkCat = '';
                }
                
                if(claim != null && repa != null && (scena == '30' || ((scena == '36' || scena == '38') && networkCat.contains('NNB')))){
                    //status = 'New';
                    status = 'To be sent';
                }
                log.NOB_Status__c = caseHasSD40InError ? 'Error' : status;//WCH 16/02/2022 RSIW-12213
                log.NOB_MessageType__c = 'SD32';
                log.Nob_WorkOrder__c = wo.id; //GBH RSIW-9793
                
                if(scena == NULL || scena == ''|| scena == '30' || scena == '36' || scena == '38')  
                    messageLogs.add(log);
                
                System.debug('Inserting log:' + log);
                
                String status40 = 'En attente AS';
                if(claim != null && repa != null && ( scena == '36' || scena == '38') && !networkCat.contains('NNB') ){
                    //status40 = 'New';
                    status40 = 'To be sent';
                }
                
                
                
                NOB_DarvaMessageLog__c log40 = new NOB_DarvaMessageLog__c();
                log40.NOB_Case__c = wo.CaseId;
                log40.NOB_ActionType__c = 'New';
                log40.NOB_Status__c =  caseHasSD40InError ? 'Error' : status40;//WCH 16/02/2022 RSIW-12213
                log40.NOB_MessageType__c = 'SD40';
                log40.NOB_MessageSubType__c = 'Type 1';
                log40.Nob_WorkOrder__c = wo.id; //GBH   RSIW-9793
                
                if((scena == NULL || scena == '' || scena == '36' || scena == '38') && (repa == null || (repa != null && !networkCat.contains('NNB')) ) )
                    messageLogs.add(log40);
                
                System.debug('Inserting log:' + log40);
                 
                
                /*if(mapIsAxaDa.get(wo.Id)){ /* && wo.NOB_TECHDateRendezVousPrisEnCharge__c != null remove because of RSIW-08384 
                    NOB_SMSLog__c sms = new NOB_SMSLog__c();
                    sms.NOB_Case__c = wo.CaseId;
                    sms.NOB_Contact__c =  mpCsCnt.get(wo.CaseId);//cc.ContactId;
                    sms.NOB_Statut__c = 'To be send';
                    sms.NOB_Subject__c = 'Etape_3';
                    smsLogs.add(sms);
                }*/
            }
        }
        system.debug('## messageLogs: '+messageLogs);
        
        //WCH 16/02/2022 RSIW-11375
        List <Database.Saveresult> lstResultsMessageLogs= new List <Database.Saveresult>();
        if(messageLogs.size()>0){
            lstResultsMessageLogs = Database.insert(messageLogs, false);
        }
        Map<String,Id> mapCaseWOLogSD40 = new Map<String,Id>();
        Map<String,Id> mapCaseWOLogSD32 = new Map<String,Id>();
        List<NOB_DarvaMessageLog__c> logsSD40ToUpdate = new List<NOB_DarvaMessageLog__c>();
        for(Integer i=0; i<lstResultsMessageLogs.size(); i++){
            Database.SaveResult sr = lstResultsMessageLogs[i]; 
            if(sr.isSuccess()){
                if(messageLogs[i].NOB_MessageType__c=='SD40'){
                    mapCaseWOLogSD40.put((messageLogs[i].NOB_Case__c+'_'+messageLogs[i].Nob_WorkOrder__c),messageLogs[i].Id);
                }else if(messageLogs[i].NOB_MessageType__c=='SD32'){
                    mapCaseWOLogSD32.put((messageLogs[i].NOB_Case__c+'_'+messageLogs[i].Nob_WorkOrder__c),messageLogs[i].Id);
                }
            }
        }
        for(String currentSD40 : mapCaseWOLogSD40.keyset()){
            if(mapCaseWOLogSD32.containsKey(currentSD40)){
                NOB_DarvaMessageLog__c log40 = new NOB_DarvaMessageLog__c(Id=mapCaseWOLogSD40.get(currentSD40),SD32_Log__c=mapCaseWOLogSD32.get(currentSD40));
                logsSD40ToUpdate.add(log40);
            }
        }
        system.debug('## logsSD40ToUpdate: '+logsSD40ToUpdate);
        if(logsSD40ToUpdate.size()>0) {
            update logsSD40ToUpdate;
        }
        /*system.debug('## smsLogs: '+smsLogs);
        if(messageLogs.size()>0) {
            insert smsLogs;
        }*/
        system.debug('## handleAfterCreate end');
    }
    
    
    
    public void onAfterUpdate(List<WorkOrder> lstWoNew,List<WorkOrder> lstWoOld){
        System.debug('~~~~~~~ START METHOD NOB_WorkOrderTriggerHandler - onAfterUpdate ~~~~~~~~~~~~');
        System.debug('## handleAfterUpdate start :' +NOBTools.isMigrationUser);
        List<NOB_DarvaMessageLog__c> messageLogs = new List<NOB_DarvaMessageLog__c>();
        List<WorkOrder> lstWOEmailAffectation = new List<WorkOrder>();
        
        //RLA 17/12/2021 RSIW-5831 Possibilité de revenir automatiquement au statut affectation (requête) après annulation de la mission sans annulation de la requête
        set<Id> setCases = new set<Id>();


        //list <WorkOrder> lstWO =  reloadWorkorders(lstWoNew);//[SELECT Id, case.PFR_TECH_EngineerClaimNR__c, Case.NOB_TECH_IsAXAorDA__c FROM WorkOrder WHERE Id IN : workorders];
        
        //handleTaux(lstWO);
        //handleTaux(lstWoNew);
        
        if (!NOBTools.isMigrationUser) {
            List<Id> caseIds  = new List<Id>();
            for(WorkOrder wo :lstWoOld){
                if(!caseIds.contains(wo.CaseId))
                    caseIds.add(wo.CaseId);
            }
            
            //HMO -- 09-07-2021 -- RSIW 10319
            /*Map<Id,Id> mpCsCnt = new Map<Id,Id>();
            List<Case> cases = [SELECT Id, ContactId FROM Case WHERE Id IN: caseIds];
            for(Case ca : cases){
                mpCsCnt.put(ca.Id,ca.ContactId);
            }*/
            
            for(Integer i = 0; i < lstWoNew.size(); i++){
                
                if(lstWoNew[i].Status != lstWoOld[i].Status){
                    
                    system.debug('~~~~ WO old status:'+lstWoOld[i].Status);
                    system.debug('~~~~ WO new status:'+lstWoNew[i].Status);
                    
                    if(lstWoOld[i].Status!='Canceled' && lstWoNew[i].Status=='Canceled'){
                        //RLA 17/12/2021 RSIW-5831 Possibilité de revenir automatiquement au statut affectation (requête) après annulation de la mission sans annulation de la requête
                        setCases.add(lstWoNew[i].CaseId);
                    }
                    
                    
                }
                //GBH   17.11.2021  RSIW-10850: Mail automatique d'information suite à la création d'une disponibilité depuis MyPrefikar,WCH 16/12/2021 RSIW-11619 correction
                if (profileName == 'PRE_Front Office' || profileName == 'PRE_System Administrator') {
                    if (!lstWoOld[i].PRE_TECH_CreationDispoDepuisMyPrefikar__c && lstWoNew[i].PRE_TECH_CreationDispoDepuisMyPrefikar__c) {
                        lstWOEmailAffectation.add(lstWoNew[i]);
                    }
                }
            }

        }
        if ( lstWOEmailAffectation.size()>0 ) NOB_AP65_WorkOrderUtils.buildAffectationEmail(lstWOEmailAffectation);

        //RLA 17/12/2021 RSIW-5831 Possibilité de revenir automatiquement au statut affectation (requête) après annulation de la mission sans annulation de la requête
        if (setCases.size() > 0){
            updateCase(setCases);
        }
        
        
    }

    //RLA 17/12/2021 RSIW-5831 Possibilité de revenir automatiquement au statut affectation (requête) après annulation de la mission sans annulation de la requête
    public static void updateCase(set<Id> setCase){

        Map<Id, Integer> mapCaseNumWOCanceled = new map<Id, Integer>();
        Map<Id, Integer> mapCaseNumWOAll = new map<Id, Integer>();
        Map<Id,Case> mapCasesToUpdate = new map<Id,Case>();
        for (WorkOrder wo: [select id,Status,CaseId from WorkOrder where CaseId in :setCase ]){

            if (wo.Status == 'Canceled'){
                if (mapCaseNumWOCanceled.containsKey(wo.CaseId)){
                    mapCaseNumWOCanceled.put(wo.CaseId, ((mapCaseNumWOCanceled.get(wo.CaseId))+1));
                }
                else{
                    mapCaseNumWOCanceled.put(wo.CaseId,1);
                }
            }

            if (mapCaseNumWOAll.containsKey(wo.CaseId)){
                mapCaseNumWOAll.put(wo.CaseId, ((mapCaseNumWOAll.get(wo.CaseId))+1));
            }
            else{
                mapCaseNumWOAll.put(wo.CaseId,1);
            }
        }

        for (Id id : mapCaseNumWOAll.keyset()){

            if (mapCaseNumWOAll.get(id) == mapCaseNumWOCanceled.get(id)){
                mapCasesToUpdate.put(id, new case(Id = id, Status = 'Affectation',NOB_BodyShop__c = null ));
            }
        }
        system.debug('## mapCasesToUpdate'+mapCasesToUpdate);

        if (mapCasesToUpdate.size() > 0){
            update mapCasesToUpdate.values();
        }

        
    }
    
    public static void updateTask(List<WorkOrder> workorders){
        system.debug('## updateTask start');
        List<Id> caseIds  = new List<Id>();
        for(WorkOrder wo : workorders){
            if(!caseIds.contains(wo.CaseId))
                caseIds.add(wo.CaseId);
        }
        
        List<Task> listTask = [SELECT Id FROM Task WHERE WhatId IN: caseIds];
        List<Task> listTaskToUpdate = new List<Task>();
        
        if(listTask.size()>0) {
            for(Task tsk : listTask){
                listTaskToUpdate.add(new Task(Id = tsk.Id, PFR_CallStatus__c = 'Rendez-vous pris'));
            }
        }
        if(listTaskToUpdate.size() > 0){
            update listTaskToUpdate;
        }
        system.debug('## updateTask end');
    }
}