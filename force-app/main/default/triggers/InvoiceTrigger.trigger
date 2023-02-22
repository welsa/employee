/*************************************************************************************
Trigger Name - InvoiceTrigger
Version - 1.0
Created Date - 17 JUN 2015
Function - Trigger to Manage Invoice Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L.     17/06/2015  Original Version
* Dourga U.     11/02/2016  case 1525
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
*************************************************************************************/
trigger InvoiceTrigger on Invoice__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
    
    if(/*(!(System.isBatch() || System.isFuture())) &&*/ ASPISTools.cantrigger('InvoiceTrigger'))
    {   
        //InvoiceTriggerHandler handler = new InvoiceTriggerHandler(Trigger.isExecuting, Trigger.size);
        InvoiceTriggerHandler handler = new InvoiceTriggerHandler();
        
        //Insert Handling
        if(Trigger.isInsert && Trigger.isBefore)
        {
            //handler.OnBeforeInsert(Trigger.new);
            handler.onBeforeInsert(Trigger.new);
        }
        else if(Trigger.isInsert && Trigger.isAfter)
        {
            //Handler.OnAfterInsert(Trigger.new);
            handler.onAfterInsert(Trigger.new, Trigger.newMap);
        }
        //Update Handling   
        else if(Trigger.isUpdate && Trigger.isBefore)
        {
            //case 1525
            //handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
            handler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter)
        {
            //Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
            handler.onAfterUpdate(Trigger.new, Trigger.old, Trigger.oldMap, Trigger.newMap);
        }
        // //Delete Handling    
        // else if(Trigger.isDelete && Trigger.isBefore)
        // {
        //  //Handler.OnBeforeInsert(Trigger.new);
        // }
        // else if(Trigger.isDelete && Trigger.isAfter)
        // {
        //  //Handler.OnAfterDelete(Trigger.old);
        // }
        // //Undelete Handling
        // else if(Trigger.isUndelete && Trigger.isBefore)
        // {
        // }
        // else if(Trigger.isUndelete && Trigger.isAfter)
        // {
        // }
    }
}//end trigger