/**
 * @description       : Trigger which will be fired when an Audit Operationnel is inserted or updated.
 * @author            : JPI
 * @group             : 
 * @last modified on  : 18/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   17/12/2020   JPI   Initial Version
**/
trigger SVR_AuditOperationnelTrigger on SVR_AuditOperationnel__c (after insert, after update) {

    SVR_AuditOperationTriggerHandler handler = new SVR_AuditOperationTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert){
        handler.OnAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}