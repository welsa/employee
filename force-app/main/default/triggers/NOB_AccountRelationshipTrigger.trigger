trigger NOB_AccountRelationshipTrigger on NOB_AccountRelationship__c (after delete, after insert, after update) {
    
    NOB_AccountRelationshipTriggerHandler triggerHandler = new NOB_AccountRelationshipTriggerHandler();
    //After Delete
    if(Trigger.isAfter && Trigger.isDelete ){
        triggerHandler.onAfterDelete(Trigger.old); 
    }

    //After insert
    if(Trigger.isAfter && Trigger.isInsert ){
        triggerHandler.onAfterInsert(Trigger.new); 
    }
    //After update
    if(Trigger.isAfter && Trigger.isUpdate ){
        triggerHandler.onAfterUpdate(Trigger.new, trigger.oldMap); 
    }
}