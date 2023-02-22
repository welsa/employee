trigger MasterRuleTrigger on MasterRules__c (before insert, before update,after update, after insert) {
/*************************************************************************************
Trigger Name - MasterRuleTrigger
Version - 1.0
Created Date - 16 APR 2015
Function - Trigger to manage processes on Master Rule object

Modification Log :
-----------------------------------------------------------------------------
* Developer       	Date        Description
* ----------      	----------  -----------------------
* Dourga Unmole   	16/04/2015  Original Version(Check validity of conditions)
* Hirikesh Dussoye	20/04/2015	Desactivate previous rule version when cloning   
* Dourga Unmole     08/03/2016  C-001553: Verify all triggers check the bypass before execution                         
*************************************************************************************/

	MasterRuleTriggerHandler handler = new MasterRuleTriggerHandler();
	
	if(ASPISTools.cantrigger('MasterRuleTrigger')){
		if(Trigger.isInsert && Trigger.isBefore){
			handler.onBeforeInsert(trigger.new);
		}
		else if(Trigger.isUpdate && Trigger.isBefore){
			handler.onBeforeUpdate(trigger.new, trigger.old);
		}
		else if(Trigger.isUpdate && Trigger.isAfter ){
			handler.onAfterUpdate(Trigger.new, Trigger.old); 
		}
		else if(Trigger.isInsert && Trigger.isAfter ){
			handler.onAfterInsert(Trigger.new); 
		}
	}
}