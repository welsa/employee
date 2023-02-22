/**
 * @description       : Trigger handler for Darva Message log
 * @author            : USA
 * @group             :
 * @last modified on  : 11-26-2020
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-26-2020   USA      Initial Version
 * 1.1   21-12-2020   HMO      Uncommented NOB_AP53_GenesysWS usage
**/
public with sharing class NOB_DarvaMessageLogTriggerHandler {
    
    /*public static void onBeforeInsert(List<NOB_DarvaMessageLog__c> logs){
        List<Case> cases = loadCases(logs);
        
        for(NOB_DarvaMessageLog__c log : logs){
            if(log.NOB_MessageType__c == 'SD40' && (log.NOB_MessageSubType__c == 'Type 2' || log.NOB_MessageSubType__c == 'Type 4' || log.NOB_MessageSubType__c == 'Type 5' || log.NOB_MessageSubType__c == 'Type 6' || log.NOB_MessageSubType__c == 'Type 7')){
                for(Case c : cases){
                    if(c.Id == log.NOB_Case__c){
                        if((c.NOB_ScenarioCode__c == '36' || c.NOB_ScenarioCode__c == '38') && c.PFR_TECH_EngineerClaimNR__c != NULL ){
                            //if(log.NOB_Status__c == 'En')
                        }else{
                            log.NOB_Status__c = 'En attente AS';
                        }
                    }
                }
            }
        }
    }
    
    private static List<Case> loadCases(List<NOB_DarvaMessageLog__c> logs){
        
        List<Id> ids = new List<Id>();
        
        for(NOB_DarvaMessageLog__c log : logs){
            if(log.NOB_Case__c != null)
            	ids.add(log.NOB_Case__c);
        }
        
        return [SELECT Id, PFR_TECH_EngineerClaimNR__c, NOB_TECH_IsAXAorDA__c, NOB_ScenarioCode__c, NOB_BodyShop__c,NOB_BodyShop__r.NOB_NetworkCategory__c FROM Case WHERE Id IN: ids];
        
        
    }*/
    
    public static void onAfterInsert(List<NOB_DarvaMessageLog__c> logs){
        for(NOB_DarvaMessageLog__c log : logs){
            if(log.NOB_Status__c == 'New'){
                if(log.NOB_MessageType__c == NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS){
                    NOB_AP53_GenesysWS.doSendMessage(log.Id);
                }
                else{
                    system.debug('NOB_DarvaMessageLogTriggerHandler : onAfterInsert : ');
                    if(!(System.isBatch() || System.isFuture()))
                    NOB_AP51_DarvaWS.doSendMessage(log.Id, log.Nob_WorkOrder__c, log.NOB_Case__c);
                }
            }
        }
    }

    public static void onAfterUpdate(List<NOB_DarvaMessageLog__c> logsnew, List<NOB_DarvaMessageLog__c> logsold, Map<Id,NOB_DarvaMessageLog__c> mapLog) {
        List<PRE_DarvaLog_Events__e> lstDarvaLogsToUpdate = new List<PRE_DarvaLog_Events__e>();
        for (NOB_DarvaMessageLog__c log : logsnew) {
            if (log.NOB_Status__c == 'New') {
                 if(log.NOB_MessageType__c == NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_GENESYS){
                    NOB_AP53_GenesysWS.doSendMessage(log.Id);
                    
                 } else {
                    if(!(System.isBatch() || System.isFuture())){
                        NOB_AP51_DarvaWS.doSendMessage(log.Id, log.Nob_WorkOrder__c, log.NOB_Case__c);
                    }
                 }
            }else if(log.SD32_Log__c!=null
                    && log.NOB_Status__c!=mapLog.get(log.Id).NOB_Status__c
                    && log.NOB_Status__c=='Sent'
                    && log.NOB_MessageType__c=='SD40'){
                        lstDarvaLogsToUpdate.add(new PRE_DarvaLog_Events__e(PRE_DarvaLogId__c=log.SD32_Log__c,PRE_DarvaLogStatus__c='New'));
            }
            
        }
        if (lstDarvaLogsToUpdate.size()>0) {
            system.debug('### Publish event');

            List<Database.SaveResult> results = EventBus.publish(lstDarvaLogsToUpdate);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }       
            }
        }
    }
}