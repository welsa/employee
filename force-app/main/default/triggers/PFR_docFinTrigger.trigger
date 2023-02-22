/*************************************************************************************
Trigger Name - PFR_docFinTrigger
Version - 1.0
Created Date - 11/17/2020

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Telesio    11/17/2020   Original Version
*************************************************************************************/
trigger PFR_docFinTrigger on PFR_FinancialDocument__c (before insert,before update, after insert, after update) {
    PFR_docFinTriggerHandler handler = new PFR_docFinTriggerHandler();
    Set<String> setUid = new Set<String>();   
    if(Trigger.isInsert && Trigger.isBefore ){
       handler.onBeforeInsert(Trigger.new); 
    }

    if ( Trigger.isUpdate&&Trigger.isBefore ){
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }

   // if(Trigger.isUpdate && Trigger.isAfter){
       // handler.onAfterUpdate(Trigger.new);
    //}

    //After insert
    if(Trigger.isAfter && Trigger.isInsert ){
        handler.onAfterInsert(Trigger.new); 
    }
    //After update
    if(Trigger.isAfter && Trigger.isUpdate ){
        handler.onAfterUpdate(Trigger.new, trigger.oldMap); 
    }
}