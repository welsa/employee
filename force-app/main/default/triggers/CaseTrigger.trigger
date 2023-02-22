/*************************************************************************************
Trigger Name - CaseTrigger
Version - 1.0
Created Date - 21 MAY 2015
Function - Trigger to Manage Case Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L.     08/06/2015  Original Version
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
*************************************************************************************/

trigger CaseTrigger on Case__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    CaseTriggerHandler handler = new CaseTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(ASPISTools.cantrigger('CaseTrigger')){
        //Insert Handling
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new);
            //AccountTrigger//Handler.OnAfterInsertAsync(Trigger.newMap.keySet());
        }
        //Update Handling   
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter){
            Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
            //AccountTrigger//Handler.OnAfterUpdateAsync(Trigger.oldMap.keySet());
        }
        //Delete Handling   
        /*else if(Trigger.isDelete && Trigger.isBefore){
            //Handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isDelete && Trigger.isAfter){
            //Handler.OnAfterInsert(Trigger.new);
            //AccountTrigger//Handler.OnAfterInsertAsync(Trigger.newMap.keySet());
        }
        //Undelete Handling
        else if(Trigger.isUndelete && Trigger.isBefore){
            //Handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        }
        else if(Trigger.isUndelete && Trigger.isAfter){
            //Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
            //AccountTrigger//Handler.OnAfterUpdateAsync(Trigger.newMap.keySet());
        }*/
    }
}//end trigger