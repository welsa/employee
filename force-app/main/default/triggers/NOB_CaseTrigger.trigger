/*************************************************************************************
Trigger Name - NOB_CaseTrigger
Version - 1.0
Created Date - 12/10/2020

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Kureem		12/10/2020 	Original Version
*************************************************************************************/
trigger NOB_CaseTrigger on Case (after insert, before insert, before update, after update) {
    
    NOB_CaseTriggerHandler handler = new NOB_CaseTriggerHandler();
    if(Trigger.isInsert && Trigger.isAfter ){
        system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isAfter');
        handler.onAfterInsert(Trigger.new); 
    }
    //Before insert
    if(Trigger.isInsert && Trigger.isBefore ){
        handler.onBeforeInsert(Trigger.new); 
    }
    //Before update
    if(Trigger.isUpdate && Trigger.isBefore ){
        handler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.oldMap); 
    }
    //after update
    if(Trigger.isUpdate && Trigger.isAfter ){
        handler.onAfterUpdate(Trigger.new, Trigger.old, Trigger.oldMap); 
    }
}