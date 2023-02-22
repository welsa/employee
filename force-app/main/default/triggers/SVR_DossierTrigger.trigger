/*************************************************************************************
Class Name - SVR_DossierTrigger
Version - 1.0
Created Date - 12/08/2021
Function - 

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Hansraj       12/08/2021  Original Version
*************************************************************************************/

trigger SVR_DossierTrigger on SVR_Dossier__c (after insert, after update) {
    SVR_DossierTriggerHandler handler = new SVR_DossierTriggerHandler();
	 if(NOBTools.isPrefikarUser()){
          if(Trigger.isInsert && Trigger.isAfter){
              system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX SVR DOSSIER Trigger.isInsert && Trigger.isAfter');
              handler.NOBOnAfterInsert(Trigger.New);
          }
         
           if(Trigger.isUpdate && Trigger.isAfter ){
              system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX SVR DOSSIER Trigger.isUpdate && Trigger.isAfter');
               handler.NOBOnAfterUpdate(Trigger.New, Trigger.oldMap);
          }
     }
}