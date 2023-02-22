/**
 * @description       : Trigger which will be fired when a performance is inserted or updated.
 * @author            : JPI
 * @group             : 
 * @last modified on  : 25/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   25/01/2021   JPI   Initial Version
**/
trigger SVR_PerformanceTrigger on SVR_Performance__c (after insert, after update) {

    SVR_PerformanceTriggerHandler handler = new SVR_PerformanceTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert){
        handler.OnAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}