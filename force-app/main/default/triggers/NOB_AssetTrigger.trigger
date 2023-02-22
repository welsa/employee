/*************************************************************************************
Trigger Name - NOB_AssetTrigger
Version - 1.0
Created Date - 07-10-2021


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hansraj M     07-10-2021  RSIW - 9164 : BESOIN DE LA VUE DE LISTE DU DETAIL DES VR SAISIS DANS LE PORTAIL REP DANS LE PORTAIL MY PREFIKAR
* Hansraj M     15/12/2021  RSIW - 11173 : Gestion du parc VR hors prefikar/ Prefikar
*************************************************************************************/


/**
 * THIS DEV NOT USED ANYMORE - HMO - 15-12-2021 - 11173
 */

trigger NOB_AssetTrigger on Asset (after insert, after update) {
	// NOB_AssetTriggerHandler handler = new NOB_AssetTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    // if (ASPISTools.cantrigger('NOB_AssetTrigger')){
    //     if (NOBTools.isPrefikarUser()){
    //         if (trigger.isAfter && trigger.isInsert){
    //             system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX NOB_Asset UPDATE Trigger.isInsert && Trigger.isAfter');
    //             handler.NOBonAfterInsert(trigger.new, trigger.oldMap);
    //         }
            
    //         if (trigger.isAfter && trigger.isUpdate){
    //             system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX NOB_Asset UPDATE Trigger.isUpdate && Trigger.isAfter');
    //             handler.NOBonAfterUpdate(trigger.new, trigger.oldMap);
    //         }
    //     }
    // }
}