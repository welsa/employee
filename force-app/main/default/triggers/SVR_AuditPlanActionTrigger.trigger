/*************************************************************************************
Trigger Name - SVR_AuditPlanActionTrigger
Version - 1.0
Created Date - 21 DEC 2020
Function - Trigger to determine whether or not an action plan is linked to an audit reseau

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Shagoofah G	21/12/2020 	Initial Version
*************************************************************************************/

trigger SVR_AuditPlanActionTrigger on Audit_Plan_Action__c (after insert, after delete) {/*
	SVR_AuditPlanActionTriggerHandler handler = new SVR_AuditPlanActionTriggerHandler();
	
	// Bypass Trigger 
	// if(.cantrigger('SVR_AuditPlanActionTrigger')){
		if(Trigger.isInsert && Trigger.isAfter ){
			handler.onAfterInsert(Trigger.new); 
		}
		else if(Trigger.isDelete && Trigger.isAfter ){
			handler.onAfterDelete(Trigger.old); 
		}*/
	// }
}