/**
 * @description       : Task Trigger
 * @author            : GBH
 * @group             : 
 * @last modified on  : 11-24-2020
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   11-24-2020   GBH   Initial Version
 * 1.1   21-02-2022   HMO   RSIW 11528
**/
trigger NOB_TaskTrigger on Task (before insert, after update, after insert, before update, before delete) {
    //Not used anymore
    
    NOB_TaskTriggerHandler handler = new NOB_TaskTriggerHandler();

    //Before insert
    if(Trigger.isInsert && Trigger.isBefore ){
        handler.onBeforeInsert(Trigger.new);
    }

    //Before update -- RSIW 11528
    if(Trigger.isUpdate && Trigger.isBefore ){
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    //HMO RSIW 11528  : 03-03-2022
    if(Trigger.isDelete && Trigger.isBefore){
        handler.onBeforeDelete(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            handler.onAfterUpdate(Trigger.oldMap, Trigger.new);
        }

        if (Trigger.isInsert){//HMO -- 21-02-22 - RSIW 11528
            system.debug('? onAfterInsert');
            handler.onAfterInsert(Trigger.new);
        }
    }
}