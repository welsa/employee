/*************************************************************************************
Trigger Name - NOB_ExpeditionTrigger
Version - 1.0
Created Date - 20-04-22


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hansraj M     20-04-22    RSIW 12130
*************************************************************************************/
trigger NOB_CommunicationTrigger on NOB_Communication__c (before delete){
    NOB_CommunicationTriggerHandler handler = new NOB_CommunicationTriggerHandler();
    if (ASPISTools.cantrigger('NOB_CommunicationTrigger')){
        if (Trigger.isBefore && Trigger.isDelete){
            system.debug('XXXXXXXXXXX NOB_CommunicationTrigger XXX Trigger.isDelete && Trigger.isBefore');
            handler.onBeforeDelete(Trigger.oldMap);
        }
    }

}