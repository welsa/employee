/*************************************************************************************
Trigger Name - NOB_ExpeditionTrigger
Version - 1.0
Created Date - 18-04-22


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hansraj M     18-04-22    RSIW 12130
* Ruksaar L     06-05-22    RSIW 12130
*************************************************************************************/
trigger NOB_ExpeditionTrigger on NOB_Expedition__c (before update, after update, before insert, before delete) {
    NOB_ExpeditionTriggerHandler handler = new NOB_ExpeditionTriggerHandler();

    if (ASPISTools.cantrigger('NOB_ExpeditionTrigger')){
        if (Trigger.isBefore && Trigger.isUpdate){
            system.debug('XXXXXXXXXXX NOB_Expedition__c XXX Trigger.isUpdate && Trigger.isBefore');
            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }

        if (Trigger.isBefore && Trigger.isInsert){
            system.debug('XXXXXXXXXXX NOB_Expedition__c XXX Trigger.isInsert && Trigger.isBefore');
            handler.onBeforeInsert(Trigger.new);
        }

        if (Trigger.isAfter && Trigger.isUpdate){
            system.debug('XXXXXXXXXXX NOB_Expedition__c XXX Trigger.isUpdate && Trigger.isAfter');
            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isBefore && Trigger.isDelete){
        system.debug('XXXXXXXXXXX NOB_Expedition__c XXX Trigger.isDelete && Trigger.isBefore');
        handler.onBeforeDelete(Trigger.old);
    }
}