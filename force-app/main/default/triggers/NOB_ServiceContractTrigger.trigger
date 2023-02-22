/*************************************************************************************
Trigger Name - NOB_ServiceContractTrigger
Version - 1.0
Created Date - 11 JAN 2021


Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Kejilen P  	11/01/2021 	Original Version
* Hansraj M   29-07-2021  RSIW - 9655 : Mise à jour des engagements Préfikar / Réparateur
* Hansraj M     02-09-2021  RSIW - 9655 : Mise à jour des engagements Préfikar / Réparateur - 10672 (adding bypass)
*************************************************************************************/
trigger NOB_ServiceContractTrigger on ServiceContract  (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    NOB_ServiceContractTriggerHandler handler = new NOB_ServiceContractTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if (ASPISTools.cantrigger('NOB_ServiceContractTrigger')){

      if(NOBTools.isPrefikarUser()){
        //RSIW - 9655 : Mise à jour des engagements Préfikar / Réparateur -- HMO -- 29-07-2021
        if(Trigger.isUpdate && Trigger.isAfter ){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX NOB Serv Cont xxxxx UPDATE Trigger.isUpdate && Trigger.isAfter');
            handler.NOBOnAfterUpdate(Trigger.new, Trigger.oldMap); 
        }
      
  
        //RSIW - 9655 : Mise à jour des engagements Préfikar / Réparateur -- HMO -- 29-07-2021
        if (Trigger.isInsert && Trigger.isAfter){
          system.debug('## NOB_ServiceContractTrigger Trigger.isUpdate && Trigger.isAfter');
          handler.NOBOnAfterInsert(Trigger.new, Trigger.oldMap);
        }
  
        //RSIW - 5686 : HMO -- 24-12-2021
        if (Trigger.isBefore && Trigger.isUpdate){
          system.debug('## NOB_ServiceContractTrigger Trigger.isUpdate && Trigger.isBefore');
          handler.NOBOnBeforeUpdate(Trigger.new, Trigger.oldMap);
        }

      }

    }
}