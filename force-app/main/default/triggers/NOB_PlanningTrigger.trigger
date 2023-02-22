/**
 * @File Name          : NOB_PlanningTrigger.apxt
 * @Description        : NOB_Planning__c Trigger
 * @Author             : Spoon
 * @Group              : 
 * @Last Modified By   : ARA
 * @Last Modified On   : 12-15-2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      Modification
 *==============================================================================
 * 1.0    30-JUL-2020                   Spoon      Initial Version 
 * 
**/
trigger NOB_PlanningTrigger on NOB_Planning__c(after delete, after insert, after undelete,
                                                      after update, before delete, before insert, before update) {
    NOB_PlanningTriggerHandler handler = new NOB_PlanningTriggerHandler(Trigger.isExecuting, Trigger.size);   
    if(ASPISTools.cantrigger('DisponibilityTrigger')){
        //Insert Handling
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        //GBH 16.10.2020 - RSIW-1951
        else if(Trigger.isInsert && Trigger.isAfter){
            System.debug('##### End NOB_PlanningTrigger.onAfterInsert ####');
            handler.onAfterInsert(Trigger.new);
            System.debug('##### End NOB_PlanningTrigger.onAfterInsert ####');
        }
        //Update Handling   
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.new, Trigger.old);
        }   
        else if(Trigger.isUpdate && Trigger.isafter){
            System.debug('##### End NOB_PlanningTrigger.onAfterUpdate ####');
            handler.onAfterUpdate(Trigger.old,Trigger.new, Trigger.oldMap);
            System.debug('##### End NOB_PlanningTrigger.onAfterUpdate ####');
        }
        //ARA 14/12/2020 -RSIW-5859
        else if(Trigger.isDelete && Trigger.isAfter){
            handler.onAfterDelete(Trigger.old);
        }
    }                                                       
}