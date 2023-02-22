/*************************************************************************************
Trigger Name - OrderLineTrigger
Version - 1.0
Created Date - 02 APR 2015
Function - Trigger to Manage OrderLine Status Changes on OrderLIne LifeCycle

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Joao Dias  	02/04/2015 	Original Version
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
*************************************************************************************/

trigger OrderLineTrigger on OrderLine__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	//OrderLIneTriggerHandler handler = new OrderLIneTriggerHandler(Trigger.isExecuting, Trigger.size);
	OrderLIneTriggerHandler handler = new OrderLIneTriggerHandler();
	
	if(ASPISTools.cantrigger('OrderLineTrigger')){
		//Insert Handling
		if(Trigger.isInsert && Trigger.isBefore){
			handler.onBeforeInsert(Trigger.new);       
		}
		else if(Trigger.isInsert && Trigger.isAfter){
			//Handler.OnAfterInsert(Trigger.new);
			handler.onAfterInsert(Trigger.new);  
		}
		//Update Handling	
		else if(Trigger.isUpdate && Trigger.isBefore){
	        //handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
			handler.onBeforeUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
		}
		else if(Trigger.isUpdate && Trigger.isAfter){
			//Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
			handler.onAfterUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
		}
		// //Delete Handling	
		// else if(Trigger.isDelete && Trigger.isBefore){
		// }
		// else if(Trigger.isDelete && Trigger.isAfter){
		// }
		// //Undelete Handling
		// else if(Trigger.isUndelete && Trigger.isAfter){
		// }
	}
}//end trigger