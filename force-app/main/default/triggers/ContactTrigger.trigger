/*************************************************************************************
Trigger Name - ContactTrigger
Version - 1.0
Created Date - 12/10/2020

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Kureem		12/10/2020 	Original Version
*************************************************************************************/
trigger ContactTrigger on Contact ( after insert) {
    NOB_ContactTriggerHandler handler = new NOB_ContactTriggerHandler();
    if(Trigger.isInsert && Trigger.isAfter ){
        system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isAfter');
        handler.onAfterInsert(Trigger.new); 
    }    

}