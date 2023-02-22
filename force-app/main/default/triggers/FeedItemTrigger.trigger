/*************************************************************************************
Trigger Name - FeedItemTrigger
Version - 1.0
Created Date - 21 MAY 2015
Function - Trigger to Manage FeedItem Changes

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga        27/08/2018  Original Version
* Abdool        22/01/2019  Trigger Notification To BS on Each New Post
*************************************************************************************/
trigger FeedItemTrigger on FeedItem ( before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	FeedItemTriggerHandler handler = new FeedItemTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(ASPISTools.cantrigger('FeedItemTrigger')){
		//Insert Handling
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.old,Trigger.new);
        }/*
        //Update Handling   
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
        }
        else if(Trigger.isUpdate && Trigger.isAfter){
            Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
            //AccountTrigger//Handler.OnAfterUpdateAsync(Trigger.oldMap.keySet());
        }
        //Delete Handling   
        else if(Trigger.isDelete && Trigger.isBefore){
            //Handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isDelete && Trigger.isAfter){
            //Handler.OnAfterInsert(Trigger.new);
            //AccountTrigger//Handler.OnAfterInsertAsync(Trigger.newMap.keySet());
        }
        //Undelete Handling
        else if(Trigger.isUndelete && Trigger.isBefore){
            //Handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        }
        else if(Trigger.isUndelete && Trigger.isAfter){
            //Handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
            //AccountTrigger//Handler.OnAfterUpdateAsync(Trigger.newMap.keySet());
        }*/
    }
}//end trigger