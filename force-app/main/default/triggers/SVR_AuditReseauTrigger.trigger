/**
 * @description       : Trigger which will be fired when an Audit reseau is inserted.
 * @author            : JPI
 * @group             : 
 * @last modified on  : 20/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   05/01/2021   JPI   Initial Version
**/
trigger SVR_AuditReseauTrigger on SVR_AuditReseau__c (after insert,after update) {

    System.debug('############# start SVR_AuditReseauTrigger ##########');
    SVR_AuditReseauTriggerHandler handler = new SVR_AuditReseauTriggerHandler();

    if(Trigger.isAfter && Trigger.isInsert){
        handler.OnAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    System.debug('############# end SVR_AuditReseauTrigger ##########');
}