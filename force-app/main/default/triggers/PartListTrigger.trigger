/*
  ----------------------------------------------------------------------
  -- - Name          : PartListTrigger
  -- - Author        : VSU
  -- - Description   : Trigger on partlist 
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 08-JUN-2017  VSU    1.0     Initial version
  -- 15-FEB-2018  DUN    1.1     case 2297 : Added After Insert part
  ----------------------------------------------------------------------
 **********************************************************************/
 trigger PartListTrigger on PartList__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    PartListTriggerHandler handler = new PartListTriggerHandler();
    
    if(ASPISTools.cantrigger('PartListTrigger')){    
        if(Trigger.isInsert && Trigger.isAfter){
            handler.onAfterInsert(Trigger.new);
        }
        else if(Trigger.isUpdate && Trigger.isAfter){
            handler.onAfterUpdate(Trigger.new,Trigger.old);
        }
    }
}