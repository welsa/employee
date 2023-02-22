/*************************************************************************************
Trigger Name - UserTrigger
Version - 1.0
Created Date - 28 APR 2015
Function - Trigger to automaticaly make user a member of the respective User Group

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Yudish R		28/04/2015 	Original Version
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
* Welsa C       22/09/2020  C-003923: NOB - Sharing Rules Management
* Hansraj M     19/02/2021  RSIW 8386 : add after insert trigger for Prefikar users
*************************************************************************************/
trigger UserTrigger on User (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	UserTriggerHandler handler = new UserTriggerHandler();
	
	if(ASPISTools.cantrigger('UserTrigger')){
        if(Trigger.isInsert && Trigger.isBefore ){
			handler.onBeforeInsert(Trigger.new); 
		}
		else if(Trigger.isInsert && Trigger.isAfter ){
			handler.onAfterInsert(Trigger.new); 
		}
		else if(Trigger.isUpdate && Trigger.isAfter ){
			handler.onAfterUpdate(Trigger.new, Trigger.old); 
		}
	}
	
	//HMO -- 19-02-2021 -- RSIW 8386
	if(NOBTools.isPrefikarUser()){
		if(Trigger.isInsert && Trigger.isAfter){
			handler.NOBOnAfterInsert(Trigger.new);
		}
		if(Trigger.isUpdate && Trigger.isAfter){
			handler.NOBOnAfterUpdate(Trigger.new, Trigger.old);
		}
	}
}