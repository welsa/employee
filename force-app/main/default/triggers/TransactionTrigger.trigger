/*************************************************************************************
Trigger Name - TransactionTrigger
Version - 1.0
Created Date - 10 DEC 2021
Function - Trigger to Manage Transaction Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Welsa         10/12/2021  Original Version
*************************************************************************************/

trigger TransactionTrigger on PFR_Transaction__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    NOB_TransactionTriggerHandler handler = new NOB_TransactionTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(ASPISTools.cantrigger('TransactionTrigger')){
        //Insert Handling
        if(Trigger.isInsert && Trigger.isBefore){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isBefore');
            //handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isAfter');
            //handler.OnAfterInsert(Trigger.new); 
        }
        //Update Handling   
        else if(Trigger.isUpdate && Trigger.isBefore){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isUpdate && Trigger.isBefore');
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isUpdate && Trigger.isAfter');
            //handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
        /*//Delete Handling   
        else if(Trigger.isDelete && Trigger.isBefore){
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