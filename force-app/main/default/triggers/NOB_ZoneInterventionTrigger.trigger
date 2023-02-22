/*************************************************************************************
Class Name - NOB_ZoneInterventionTrigger
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 22-11-2021
Function - trigger zone intervention
#Ticket  - RSIW : 11198

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           22-11-2021   Initial version
*/
trigger NOB_ZoneInterventionTrigger on NOB_InterventionZone__c (after insert, after update, after delete, after undelete) {
    NOB_ZoneInterventionTriggerHandler handler = new NOB_ZoneInterventionTriggerHandler(Trigger.isExecuting, Trigger.size);

    if (ASPISTools.cantrigger('NOB_ZoneInterventionTrigger')){
        if (NOBTools.isPrefikarUser()){
            
            if (trigger.isAfter){
                if (trigger.isInsert){
                    handler.NOBonAfterInsert(trigger.new, trigger.oldMap);
                }

                if (trigger.isUpdate){
                    handler.NOBonAfterUpdate(trigger.new, trigger.oldMap);
                }

                if (trigger.isDelete){
                    handler.NOBonAfterDelete(trigger.new, trigger.oldMap);
                }

                // if (trigger.isUndelete){
                //     handler.NOBonAfterUnDelete(trigger.new, trigger.oldMap);
                // }
            }

        }
    }
}