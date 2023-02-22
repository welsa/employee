/*************************************************************************************
Trigger Name - OfferTrigger
Version - 1.0
Created Date - 21 MAY 2015
Function - Trigger to Manage Offer Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Cecile L.  	21/05/2015 	Original Version
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
*************************************************************************************/

trigger OfferTrigger on Offer__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	//OfferTriggerHandler handler = new OfferTriggerHandler(Trigger.isExecuting, Trigger.size);
	OfferTriggerHandler handler = new OfferTriggerHandler();
  
	if(ASPISTools.cantrigger('OfferTrigger'))
	{
		//Insert Handling
		if(Trigger.isInsert && Trigger.isBefore){
		//handler.OnBeforeInsert(Trigger.new);  
		}
		else if(Trigger.isInsert && Trigger.isAfter){
			Handler.OnAfterInsert(Trigger.new);
		}
		//Update Handling	
		else if(Trigger.isUpdate && Trigger.isBefore){
			Handler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
		}
		else if(Trigger.isUpdate && Trigger.isAfter){
	        system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isUpdate && Trigger.isAfter');
			Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
		//AccountTrigger//Handler.OnAfterUpdateAsync(Trigger.oldMap.keySet());
		}
	}
}//end trigger