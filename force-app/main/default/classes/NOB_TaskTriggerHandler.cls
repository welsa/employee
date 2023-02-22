/**
 * @description       : Trigger Handler for task trigger
 * @author            : GBH
 * @group             : 
 * @last modified on  : 24-01-2022
 * @last modified by  : SRA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-24-2020   GBH   Initial Version
 * 1.1   24-01-2022   SRA   RSIW-11190 when task fail update case status to closed
 * 1.2   21-02-2022   HMO   RSIW 11528
**/
public with sharing class NOB_TaskTriggerHandler {
    public static DateTime testDate;

    //HMO -- 02-03-2022 - RSW 11528
    static string userProfile = NOBTools.ProfileName();

    private void adjustPreferredCallTime(List<Task> lstNew){
        List<Task> lstTasks = new List<Task> ();

        String[] ArrMS =  System.Label.NOB_morningStart.Split(':');
        String[] ArrME =  System.Label.NOB_morningEnd.Split(':');
        String[] ArrEE =  System.Label.NOB_eveningEnd.Split(':');
        Time morningStart = Time.newInstance(integer.valueof(ArrMS[0]), integer.valueof(ArrMS[1]), integer.valueof(ArrMS[2]), integer.valueof(ArrMS[3]));
        Time morningEnd = Time.newInstance(integer.valueof(ArrME[0]), integer.valueof(ArrME[1]), integer.valueof(ArrME[2]), integer.valueof(ArrME[3]));
        Time eveningEnd = Time.newInstance(integer.valueof(ArrEE[0]), integer.valueof(ArrEE[1]), integer.valueof(ArrEE[2]), integer.valueof(ArrEE[3]));
        
        for (Task t : lstNew) {
            if (t.Subject == NOB_AP00_Constants.TASK_SUBJECT_Appel_Planifie) {
                
                t.NOB_Case__c = t.WhatId;
                t.PFR_CallStatus__c = 'À appeler';
                t.Type = 'Call';
                lstTasks.add(t);
            }
        }

        for (Task t : lstTasks){

            //use start and end from values entered by user
            DateTime enteredStart = t.PFR_CallPreferedStartTime__c;
            Datetime enteredEnd = t.PFR_CallPreferedEndTime__c;

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
            t.PFR_CallPreferedStartTime__c = prefStart;
            t.PFR_CallPreferedEndTime__c = prefEnd;


            
        }
    }


    
    private void checkBeforeCreatingTask(List<Task> lstNew){
        List<id> lstId = new list <id>();
        for(Task t : lstNew ){   
            lstid.add(t.WhatId);      
        }  
        Map <id,case> mapcase = new Map <id,case>([Select Id,NOB_BodyShop__c, NOB_BusinessProvider__r.Nob_CTICampaignNumber__c, IsClosed FROM Case where Id IN:lstid]);
        for(Task t : lstNew){
            // if(mapcase.get(t.WhatId) != null && (mapcase.get(t.WhatId).NOB_BusinessProvider__r.Nob_CTICampaignNumber__c == null  || mapcase.get(t.WhatId).NOB_BodyShop__c !=null)){
            if(mapcase.get(t.WhatId) != null && (mapcase.get(t.WhatId).NOB_BusinessProvider__r.Nob_CTICampaignNumber__c == null  || (mapcase.get(t.WhatId).NOB_BodyShop__c !=null && mapcase.get(t.WhatId).IsClosed != false))){
            // if(mapcase.get(t.WhatId) != null && (mapcase.get(t.WhatId).IsClosed != false  && mapcase.get(t.WhatId).NOB_BodyShop__c !=null)){
                t.adderror(System.Label.NOB_TaskError);
            }
        }
    }

    // SRA 1.1
    private void checkIfTaskFailed(List<Task> lstnewTask){
        List<Case> lstCaseToUpdate = new List<Case>();
        Set<Id> setCaseId = new Set<Id>();
        for(Task tk: lstnewTask){
            if(tk.WhatId != null && tk.status == NOB_AP00_Constants.TASK_STATUS_COMPLETED && ((tk.PFR_CallStatus__c == NOB_AP00_Constants.TASK_CALL_STATUS_ECHECS_NBR_TENTATIVE) || tk.NOB_TECH_Close_case__c == true)) {
                setCaseId.add(tk.WhatId);
            }
        }
        if(setCaseId.size() > 0){
            for(Case cas: [SELECT Status FROM Case WHERE Status != :NOB_AP00_Constants.CASE_STATUS_CLOSED AND Status != :NOB_AP00_Constants.CASE_STATUS_CANCELED AND Id IN :setCaseId]){
                cas.status = NOB_AP00_Constants.CASE_STATUS_CANCELED;
                cas.NOB_CancelationReason__c = NOB_AP00_Constants.CASE_RAISON_INJOIGNABLE;
                lstCaseToUpdate.add(cas);
            }
            if(lstCaseToUpdate.size() > 0){
                update lstCaseToUpdate;
            }
        }
    }
    
    public void onBeforeInsert(List<Task> lstNew){
        adjustPreferredCallTime(lstNew);
        checkBeforeCreatingTask(lstNew);
    }

    // SRA 1.1
    public void onAfterUpdate(Map<Id, task> mapOldTask, List<Task> lstnewTask){
        checkIfTaskFailed(lstnewTask);
    }

    //HMO - RSIW 11528
    public void onAfterInsert(List<Task> lstnewTask){
        
        assignReparateurOwner(lstnewTask);
    }

    //HMO - 02-02-2022 RSIW 11528
    public void onBeforeUpdate(List<Task> lstNewTask, Map<Id, Task> mapOldTask){
        Set<String> setFieldsExist = Schema.SObjectType.Task.fields.getMap().keySet();
        List<string> lstFields = (System.label.NOB_TaskFieldsTrigger != null) ? System.label.NOB_TaskFieldsTrigger.split(',') : new List<String>();
        
        for (Task tache : lstNewTask){
            if (checkAttestation(mapOldTask.get(tache.Id)) && userProfile == System.Label.NOB_CCP_Bodyshop){
               
                preventUpdate(tache, mapOldTask.get(tache.Id), setFieldsExist, lstFields);
            }
        }
    }

    public void onBeforeDelete(List<Task> lstTasks, Map<Id, Task> mapOldTask){
        for (Task tache : mapOldTask.values()){
            if(checkAttestation(tache) && userProfile == System.Label.NOB_CCP_Bodyshop){
                tache.addError(System.Label.NOB_ErrorDeleteAttestation);
            }
        }
    }

    private void preventUpdate(Task tache, Task old, set<String> setFields, List<String> lstFields){
        for (Integer i = 0; i < lstFields.size(); i ++){
          
            if (setFields.contains(lstFields[i].toLowerCase())){

                if (tache.get(lstFields[i]) != old.get(lstFields[i])){
                    tache.addError(System.label.NOB_ErrorModifAttestation);
                }

            }
        }
    }

    private Boolean checkAttestation(Task tache){
        
        if ((tache.TaskSubtype == 'Email') && !String.isBlank(tache.OwnerId) && !String.isBlank(tache.WhoId) && String.valueof(tache.WhoId).startsWith('003') && !String.isBlank(tache.WhatId) && (tache.WhatId).getSObjectType().getDescribe().getName() == 'Nob_MesDocuments__c'){
            return true;
        }
        return false;
    }

    private void assignReparateurOwner(List<Task> lstnewTask){
        
        Map<Id, Task> mapTaskUpdate = new Map<Id, Task>();
        Map<Id, Id> mapIds = new Map<Id, Id>();
        Map<Id, Task> mapWhatIds = new Map<Id,Task>();
        Map<Id, User> mapUser = new Map<Id, User>();

        for (Task tache : lstnewTask){
        
            if (checkAttestation(tache) && !mapIds.containsKey(tache.Id)){
                mapIds.put(tache.Id, tache.WhoId);
                if (!mapWhatIds.containsKey(tache.WhatId)){
                    mapWhatIds.put(tache.WhatId, tache);
                }
            }
        }

        

        if (!mapIds.isEmpty()){
  
            for (User user : [SELECT Id, ContactId from User where contactId IN: mapIds.values()]){
                mapUser.put(user.contactId, user);
            }

          

            if (mapUser != null && !mapUser.isEmpty()){

                for (Id ids : mapIds.keySet()){

                    if (mapUser.containsKey(mapIds.get(ids))){
                        Task tsk = new Task(Id = ids, OwnerId = mapUser.get(mapIds.get(ids)).Id, status = 'Open', Type = NOB_AP00_Constants.TASK_TYPE_DOCUMENTCONTRACUEL);
                        mapTaskUpdate.put(tsk.Id, tsk);
                    }
                }

                Map<Id, Date> mapDates;
                if(!mapWhatIds.isEmpty()){
                    mapDates = new Map<Id, Date>();
                    for(Nob_MesDocuments__c attestation : [Select Id, NOB_DateFin__c from Nob_MesDocuments__c where Id IN: mapWhatIds.Keyset()]){
                        mapDates.put(attestation.Id, attestation.NOB_DateFin__c);
                    }
                }
               

                if (mapDates != null && !mapDates.isEmpty()){
                    for (Id id : mapWhatIds.keySet()){
                        if (mapDates.containsKey(id) && mapTaskUpdate.containsKey(mapWhatIds.get(Id).Id)){
                           
                           
                            Id taskId = mapWhatIds.get(id).id;
                           
                            mapTaskUpdate.get(taskId).ActivityDate = mapDates.get(id);
                        }
                    }
                }
            }

           
        }

        if (!mapTaskUpdate.isEmpty() && !mapTaskUpdate.containsKey(null)){
            try{
                update mapTaskUpdate.values();
            }catch(DmlException dmle){
                system.debug(LoggingLevel.ERROR, 'Error : '+ dmle.getMessage() + 'at' + dmle.getStackTraceString());
            }
        }
    }

}