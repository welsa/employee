trigger DarvaMessageLogTrigger on NOB_DarvaMessageLog__c (after insert, after update) {
	if(Trigger.isInsert && Trigger.isAfter ){
        system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isAfter');
        //NOB_AP51_DarvaWS.handleAfterCreate(Trigger.new);
        NOB_DarvaMessageLogTriggerHandler.onAfterInsert(Trigger.new);
    }      
 
    if(Trigger.isUpdate && Trigger.isAfter ){
        //NOB_AP51_DarvaWS.handleAfterUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
        NOB_DarvaMessageLogTriggerHandler.onAfterUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
    }
}