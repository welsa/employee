/*************************************************************************************
Trigger Name - AccountTrigger
Version - 1.0
Created Date - 28 APR 2015
Function - Trigger to automaticaly create a respective User Group

Modification Log :
-----------------------------------------------------------------------------
* Developer Date Description
* ---------- ---------- -----------------------
* Yudish R 28/04/2015 Original Version
* Dourga U 08/03/2016 C-001553: Verify all triggers check the bypass before execution
* Welsa C 24/08/2020 C-003838 - Nob - Migrate Billing information to new fields added on before update
* Kureem R 15/10/2020 RSIW-1988: Gestion history tracking competences
* Hansraj M 02-09-2021  RSIW - 9655 : Mise ? jour des engagements Pr?fikar / R?parateur - 10672 (adding bypass)
*************************************************************************************/
trigger AccountTrigger on Account (after delete, after insert, after undelete,after update, before delete, before insert, before update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    if(ASPISTools.cantrigger('AccountTrigger')){
        if(Trigger.isInsert && Trigger.isBefore){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isBefore');
            handler.OnBeforeInsert(Trigger.new);
            
        }
        else if(Trigger.isInsert && Trigger.isAfter ){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isAfter');
            handler.onAfterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate && Trigger.isAfter ){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isUpdate && Trigger.isAfter');
            handler.onAfterUpdate(Trigger.new, Trigger.old);
        }else if(Trigger.isUpdate && Trigger.isBefore ){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isUpdate && Trigger.isBefore');
            handler.onBeforeUpdate(Trigger.new, Trigger.old);
        }
        else if(Trigger.isUpdate && Trigger.isAfter ){
            system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isUpdate && Trigger.isAfter');
            handler.onAfterUpdate(Trigger.new, Trigger.old);
        }
    }
    

    //HMO -- 02/09/2021
    //KRO 15.10.2020 RSIW-1988
    if(ASPISTools.cantrigger('AccountTrigger')){

        if(NOBTools.isPrefikarUser()){
            if(Trigger.isInsert && Trigger.isBefore){
                system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX INSERT Trigger.isInsert && Trigger.isBefore');
                handler.NOBOnBeforeInsert(Trigger.new);
            }
            else if(Trigger.isUpdate && Trigger.isBefore ){
                system.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX UPDATE Trigger.isUpdate && Trigger.isBefore');
                handler.NOBOnBeforeUpdate(Trigger.new, Trigger.old);
            }
            
            else if(Trigger.isUpdate && Trigger.isAfter ){
                System.debug('XXXXXXXXXXXX AccountTrigger.isUpdate && Trigger.isAfter');
                handler.NOBOnAfterUpdate(Trigger.new, Trigger.oldMap);
            }
            
        }
    }
}