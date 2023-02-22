/*************************************************************************************
Trigger Name - NOB_ContentDocumentTrigger
Version - 1.0
Created Date - 29/12/2020

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Bhavish		29/12/2020 	Original Version
* Hansraj       25/04/2022  RSIW 12130
*************************************************************************************/
trigger NOB_ContentDocumentTrigger on ContentDocument (before update,after insert, before delete) {
    NOB_ContentDocumentTriggerHandler handler = new NOB_ContentDocumentTriggerHandler();
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.onBeforeUpdate(Trigger.new, Trigger.old);
    }

	//HMO -- RSIW 12130
    if (Trigger.isBefore && Trigger.isDelete){
        handler.onBeforeDelete(Trigger.old);
    }

}