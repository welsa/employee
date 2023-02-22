/*************************************************************************************
Trigger Name - DetailRuleTrigger
Version - 1.0
Created Date - 16 APR 2015
Function - Trigger to manage processes on Detail Rule object

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* SC(NJO)   	16/04/2015 	Original Version(Check field validity relative to sObject)
* Dourga U      08/03/2016  C-001553: Verify all triggers check the bypass before execution
*************************************************************************************/
trigger DetailRuleTrigger on DetailRule__c (before insert,before update,before delete) {

	DetailRuleTriggerHandler handler = new DetailRuleTriggerHandler();
	
	if(ASPISTools.cantrigger('DetailRuleTrigger')){
		if(Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		}
		else if(Trigger.isUpdate && Trigger.isBefore){
			handler.OnBeforeUpdate(Trigger.old,Trigger.new);
		}
		else if(Trigger.isDelete && Trigger.isBefore){
			handler.OnBeforeDelete(Trigger.old);
		}
	}
}