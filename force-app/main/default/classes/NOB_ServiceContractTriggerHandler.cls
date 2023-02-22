/*************************************************************************************
Class Name - NOB_ServiceContractTriggerHandler
Version - 1.0
Created Date - 11/01/2021


Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* KPA           11/01/2021  Initial version
* Hansraj M     29-07-2021  RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur
* Hansraj M     02-09-2021  RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur - 10672 (adding bypass)
*************************************************************************************/
public with sharing class NOB_ServiceContractTriggerHandler {

    private boolean bIsExecuting = false;
	private integer iBatchSize = 0;

    //HMO -- 02-09-2021
    public NOB_ServiceContractTriggerHandler(Boolean executing, Integer size) {
        this.bIsExecuting = executing;
        this.iBatchSize = size;
    }

    public void NOBOnAfterUpdate(list<ServiceContract> lstNewServiceContract, map<Id,ServiceContract> mapOldServContract){

        System.debug('##### Start NOB_ServiceContractTriggerHandler.NOBOnAfterUpdate ####');
        set<Id> AccSetId = new set<Id>();

        List<ServiceContract> lstSC = new List<ServiceContract>();
        Set<Id> setAccsId = new Set<Id>();
        String recordTypeIdz = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
       .get('NOB_BodyshopContract').getRecordTypeId();

		//HMO -- 13/12/2021 - RSIW 5886
        set<Id> setReparateurUpdate = new set<Id>();

        
        //HMO - 24-12-2021 -- RSIW 5686
        List<ServiceContract> lstSCEndDate = new List<ServiceContract>();
        List<ServiceContract> lstClearEnd = new List<ServiceContract>();

        //HMO - 04/01/2022-RSIW 5686
        set<Id> setReparateurStartDate = new set<Id>();
        
        for (ServiceContract ServCon : lstNewServiceContract){
            
            //HMO -- 27-09-2021 RSIW 9655 check field to trigger class
            if(ServCon.NOB_NombreMissionAnnuel__c != mapOldServContract.get(ServCon.Id).NOB_NombreMissionAnnuel__c || (ServCon.NOB_techTriggerClass__c != mapOldServContract.get(ServCon.Id).NOB_techTriggerClass__c && ServCon.NOB_techTriggerClass__c) ){
              AccSetId.add(ServCon.AccountId);
            }
            System.debug('#### AccSetIdz ### ' + AccSetId);

            //RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur -- HMO -- 29-07-2021
            if (mapOldServContract != null && mapOldServContract.containsKey(ServCon.Id)){

                if (ServCon.Status == 'Active' && ServCon.recordTypeId == recordTypeIdz && ServCon.AccountId != null && ServCon.NOB_TECH_RankingRep__c && (ServCon.StartDate != mapOldServContract.get(ServCon.Id).StartDate) || (ServCon.EndDate != mapOldServContract.get(ServCon.Id).EndDate) && (ServCon.StartDate != null && ServCon.EndDate != null)){
                    setAccsId.add(ServCon.AccountId);
                }
            }    
            
            //HMO -- 24-12-2021 -- RSIW 5686
            if (ServCon.startDate != null && ((ServCon.startDate != mapOldServContract.get(ServCon.Id).startDate) || (ServCon.NOB_endDate__c != mapOldServContract.get(ServCon.Id).NOB_endDate__c)) ){
                if (!lstSCEndDate.contains(ServCon)){
                    lstSCEndDate.add(ServCon);
                }
            }

            if ((ServCon.NOB_endDate__c != mapOldServContract.get(ServCon.Id).NOB_endDate__c)  && ServCon.NOB_endDate__c == null){
                if (!lstClearEnd.contains(ServCon)){
                    lstClearEnd.add(ServCon);
                }
            }

            //HMO - 04/01/2022 -RSIW 5686
              if (ServCon.recordTypeId == recordTypeIdz && ServCon.AccountId != null && ServCon.StartDate != null && mapOldServContract.get(ServCon.Id).startDate == null){
                if(!setReparateurStartDate.contains(ServCon.AccountId)){
                    setReparateurStartDate.add(ServCon.AccountId);
                }
            }
        }
        
        System.debug('#### AccSetIdz ### ' + AccSetId);
        
         if(AccSetId.size()>0){
            NOB_AP60_DispoEntreesCal.updateDispo(AccSetId);
            NOB_AP59_TauxEngagementPourcentCal.updateMissionReserve(AccsetId);
      
        }
    
        //RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur -- HMO -- 29-07-2021
        if (setAccsId != null && setAccsId.size()> 0){
            System.debug('???? into class !!');
            NOB_AP61_UpdateRankingQuarter.getServiceContracts(setAccsId, null);
        }
        
        //HMO -- 24-12-2021
        if (!lstSCEndDate.isEmpty() && !lstSCEndDate.contains(null)){
            NOB_AP68_EvolutionServiceContract.updateEndDate(lstSCEndDate);
        }

        if (!lstClearEnd.isEmpty() && !lstClearEnd.contains(null)){
            NOB_AP68_EvolutionServiceContract.clearEndDate(lstClearEnd);
        }

        //HMO - 04-01-2022-RSIW 5686
        if (!setReparateurStartDate.isEmpty() && !setReparateurStartDate.contains(null)){
            NOB_AP68_EvolutionServiceContract.assignStartDate(setReparateurStartDate);
        }
        System.debug('##### END NOB_ServiceContractTriggerHandler.NOBOnAfterUpdate ####');
    }

    
    //RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur -- HMO -- 29-07-2021
    public void NOBOnAfterInsert(list<ServiceContract> lstNewServiceContract, map<Id,ServiceContract> mapOldServiceContract){
        string context = '';
        System.debug('##### Start NOB_ServiceContractTriggerHandler.NOBOnAfterInsert ####');

        Set<Id> setAccsId = new Set<Id>();
        String recordTypeIdz = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
        .get('NOB_BodyshopContract').getRecordTypeId();

        
        //HMO - 13/12/2021-RSIW 5686
        set<Id> setReparateurInsert = new set<Id>();

        //HMO - 24-12-2021
        List<ServiceContract> lstSCEndDate = new List<ServiceContract>();
        
        for (ServiceContract sc : lstNewServiceContract){     
            
            if (sc.Status == 'Active' && sc.recordTypeId == recordTypeIdz && sc.AccountId != null && sc.NOB_TECH_RankingRep__c){
                context = NOB_AP00_Constants.contextCR;
                setAccsId.add(sc.AccountId);
            }
            
            //HMO - 13/12/2021-RSIW 5686
            if (sc.recordTypeId == recordTypeIdz && sc.AccountId != null && sc.StartDate != null){
                if(!setReparateurInsert.contains(sc.AccountId)){
                    setReparateurInsert.add(sc.AccountId);
                }

                if (!lstSCEndDate.contains(sc)){
                    lstSCEndDate.add(sc);
                }
            }
        }

        if (setAccsId != null && setAccsId.size()> 0){
            NOB_AP61_UpdateRankingQuarter.getServiceContracts(setAccsId, context);
        }
        
         //HMO - 13/12/2021-RSIW 5686
        if (!setReparateurInsert.isEmpty() && !setReparateurInsert.contains(null)){
            NOB_AP68_EvolutionServiceContract.assignStartDate(setReparateurInsert);
        }

        //HMO -- 24-12-2021
        if (!lstSCEndDate.isEmpty() && !lstSCEndDate.contains(null)){
            NOB_AP68_EvolutionServiceContract.updateEndDate(lstSCEndDate);
        }

        System.debug('##### END NOB_ServiceContractTriggerHandler.NOBOnAfterInsert ####');
    }
    
    	//HMO -- RSIW 5686
    public void NOBOnBeforeUpdate(list<ServiceContract> lstNewServiceContract, map<Id,ServiceContract> mapOldServiceContract){

        List<ServiceContract> lstServiceCons = new List<ServiceContract>();
        for(ServiceContract ServCon : lstNewServiceContract){
            if (((ServCon.NOB_endDate__c != mapOldServiceContract.get(ServCon.Id).NOB_endDate__c) &&(ServCon.startDate != mapOldServiceContract.get(ServCon.Id).startDate)) && ServCon.NOB_endDate__c == null && ServCon.startDate == null){
                ServCon.endDate = null;
            }

            if ((ServCon.startDate != mapOldServiceContract.get(ServCon.Id).startDate) && ServCon.startDate == null){
                ServCon.endDate = null;
            }
        }
    }
}