trigger SVR_DossierPreficontrolTrigger on SVR_DossierPreficontrol__c (after insert, after update, after delete) {
/**
 * @description       : Trigger which will be fired when a dossier Preficontrol is inserted ,updated or deleted.
 * @author            : ASE
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   25/01/2021   ASE   Initial Version*/





    SVR_DossierPreficontrolHandler handler = new SVR_DossierPreficontrolHandler();

    if(Trigger.isAfter && Trigger.isInsert){
        handler.OnAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        handler.OnAfterUpdate(Trigger.old, Trigger.new);
    }

    if(Trigger.isDelete && Trigger.isAfter ){
        handler.onAfterDelete(Trigger.old);
    }
}