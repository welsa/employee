/*************************************************************************************
Trigger Name - NOB_TauxNegTrigger
Version - 1.0
Created Date - 01 Dec 2020
Function - Trigger to automaticaly prevent duplicate dates on NOB_TauxNeg__c

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* KPA           01/12/2020  Original Version
* USA           23/12/2020  RSIW-6861
*************************************************************************************/
trigger NOB_TauxNegTrigger on NOB_TauxNeg__c (before insert ,before update) {
    if (Trigger.isInsert && Trigger.isBefore){
        NOB_TauxNegTriggerHandler.onBeforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore){
        NOB_TauxNegTriggerHandler.onBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }
}