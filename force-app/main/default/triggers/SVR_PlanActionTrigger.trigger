/**
 * @description       :  Trigger which will be fired when a plan d'action is inserted or updated.
 * @author            : JPI
 * @group             : 
 * @last modified on  : 18/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   18/01/2021   JPI   Initial Version
**/
trigger SVR_PlanActionTrigger on Audit_Plan_Action__c (after insert, after update, after delete) {

    SVR_PlanActionTriggerHandler handler = new SVR_PlanActionTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert){
        handler.OnAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }

    if(Trigger.isDelete && Trigger.isAfter ){
        handler.onAfterDelete(Trigger.old);
    }
}