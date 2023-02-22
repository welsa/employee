/**
 * Created by Hansraj Mohiputlall.
 */
/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_ExpeditionTriggerHandler
  -- - Author        : HMO
  -- - Description   : 
  -- - #Ticket       : RSIW : 12130
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 18-04-22        HMO     1.0     Initial version
  **********************************************************************
*/
public with sharing class NOB_ExpeditionTriggerHandler {
    String profileName;
    public NOB_ExpeditionTriggerHandler() {
        profileName = NOBTools.ProfileName();

    }

    public void onBeforeUpdate(List<NOB_Expedition__c> lstNewExpeditions, Map<Id, NOB_Expedition__c> mapOldExpeditions){
        Map<Id, NOB_Expedition__c> mapToPreventPublish = new Map<Id, NOB_Expedition__c>();
        List<NOB_Expedition__c> lstExpeditionPublished = new List<NOB_Expedition__c>();
        for (NOB_Expedition__c exp : lstNewExpeditions ){
            if (exp.NOB_StatutDeploiement__c != mapOldExpeditions.get(exp.Id).NOB_StatutDeploiement__c && exp.NOB_StatutDeploiement__c == NOB_AP00_Constants.EXPEDITION_PUBLISH){
                if (!mapToPreventPublish.containsKey(exp.Id)){
                    mapToPreventPublish.put(exp.Id,exp );
                }
            }

            if (mapOldExpeditions.get(exp.Id).NOB_StatutDeploiement__c == NOB_AP00_Constants.EXPEDITION_PUBLISH){
                lstExpeditionPublished.add(exp);
            }
        }

        if (!mapToPreventPublish.isEmpty()){
            NOB_LC54_ConteurComm.preventPublish(mapToPreventPublish);
        }

        if (lstExpeditionPublished.size() > 0){
            NOB_LC54_ConteurComm.preventUpdateExpedition(lstExpeditionPublished);
        }
    }


    public void onAfterUpdate(List<NOB_Expedition__c> lstNewExpeditions, Map<Id, NOB_Expedition__c> mapOldExpeditions){
        Set<Id> setExps = new Set<Id>();
        for (NOB_Expedition__c exp : lstNewExpeditions ){
            if (exp.NOB_StatutDeploiement__c != mapOldExpeditions.get(exp.Id).NOB_StatutDeploiement__c && exp.NOB_StatutDeploiement__c == NOB_AP00_Constants.EXPEDITION_PUBLISH){
                setExps.add(exp.Id);
            }
        }

        if (!setExps.isEmpty()){
            NOB_LC54_ConteurComm.createComunication(setExps);
        }


    }

    public void onBeforeInsert(List<NOB_Expedition__c> lstNewExpeditions){
        for (NOB_Expedition__c exp : lstNewExpeditions){
            if (exp.NOB_StatutDeploiement__c == NOB_AP00_Constants.EXPEDITION_PUBLISH){
                exp.addError(String.format(System.Label.NOB_ErrorNewsletter, 
                new List<Object>{ 'L\'insertion'}));
            }
        }
    }

    public void onBeforeDelete(List<NOB_Expedition__c> lstOldExpeditions){

        set<Id> setExpeditionsToDelete = new set<Id>();
        set<String> setProfilesAllowed = new Set<String>(Label.ProfilesForDeleteExpeditions.split(';'));


        if (ASPISTools.cantrigger('NOB_ExpeditionTrigger')){
            for (NOB_Expedition__c exp : lstOldExpeditions){

                if (String.IsNotBlank(profileName) && setProfilesAllowed.contains(profileName)){
           

                    setExpeditionsToDelete.add(exp.Id);

                }
                else if (exp.NOB_StatutDeploiement__c == NOB_AP00_Constants.EXPEDITION_PUBLISH){
                    exp.addError(String.format(System.Label.NOB_ErrorNewsletter, 
                    new List<Object>{ 'La suppression'}));
                }
            }
        }

        if (setExpeditionsToDelete.size() > 0){
            NOB_LC54_ConteurComm.deleteRecipient(setExpeditionsToDelete);
        }
    }

    
}