/*************************************************************************************
Trigger Name - DetailRuleTrigger
Version - 1.0
Created Date - 07 DEC 2015
Function - Trigger to manage processes on Discount object

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Cecile L   	07/12/2015 	Original Version(Check field validity relative to sObject)
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
*************************************************************************************/
trigger DiscountTrigger on Discount__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    DiscountTriggerHandler handler = new DiscountTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(ASPISTools.cantrigger('DiscountTrigger')){
        //Insert Handling
        if(Trigger.isInsert && Trigger.isBefore){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX DISCOUNT TRIGGER Trigger.isInsert && Trigger.isBefore');
            handler.OnBeforeInsert(Trigger.new);
        }
      /*  else if(Trigger.isInsert && Trigger.isAfter){
            system.debug('####### CLA AssessmentTrigger.OnAfterInsert ');
            handler.OnAfterInsert(Trigger.new); 
            //Handler.OnAfterInsertAsync(Trigger.newMap.keySet());
        } */
        //Update Handling   
        else if(Trigger.isUpdate && Trigger.isBefore){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INVOICE DISCOUNT Trigger.isUpdate && Trigger.isAfter');
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
        /*else if(Trigger.isUpdate && Trigger.isAfter){
            //Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
            //AccountTrigger//Handler.OnAfterUpdateAsync(Trigger.oldMap.keySet());
        }
        //Delete Handling   
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