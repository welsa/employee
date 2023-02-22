/*************************************************************************************
Trigger Name - NOB_CDocumentLinkTrigger
Version - 1.0
Created Date - 18-04-22


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hansraj M     18-04-22    RSIW 12130
*************************************************************************************/
trigger NOB_CDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete) {
    NOB_CDocumentTriggerHandler handler = new NOB_CDocumentTriggerHandler();
    if (ASPISTools.cantrigger('NOB_CDocumentLinkTrigger')){
        if (Trigger.isBefore && Trigger.isInsert){
            system.debug('XXXXXXXXXXX NOB_CDocumentLinkTrigger XXX Trigger.isInsert && Trigger.isBefore');
            handler.onBeforeInsert(Trigger.new);
        }

        if (Trigger.isBefore && Trigger.isUpdate){
            system.debug('XXXXXXXXXXX NOB_CDocumentLinkTrigger XXX Trigger.isUpdate && Trigger.isBefore');
            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }

        if (Trigger.isBefore && Trigger.isDelete){
            system.debug('XXXXXXXXXXX NOB_CDocumentLinkTrigger XXX Trigger.isDelete && Trigger.isBefore');
            handler.onBeforeDelete(Trigger.old);
        }

    }

}