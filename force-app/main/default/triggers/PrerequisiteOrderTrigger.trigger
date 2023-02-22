/*************************************************************************************
Trigger Name - PrerequisiteOrderTrigger
Version - 1.0
Created Date - 02 APR 2015
Function - Trigger to Manage PrerequisiteOrder Status Changes on PrerequisiteOrder LifeCycle

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Joao Dias  	02/04/2015 	Original Version
* Yudish R  	28/04/2015 	OnAfterInsert:
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
*************************************************************************************/
trigger PrerequisiteOrderTrigger on PrerequisiteOrder__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
	//PrerequisiteOrderTriggerHandler handler = new PrerequisiteOrderTriggerHandler(Trigger.isExecuting, Trigger.size);
	PrerequisiteOrderTriggerHandler handler = new PrerequisiteOrderTriggerHandler();
	
	if(ASPISTools.cantrigger('PrerequisiteOrderTrigger')){
		//Insert Handling
		if(Trigger.isInsert && Trigger.isBefore){  
			//handler.OnBeforeInsert(Trigger.new);
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