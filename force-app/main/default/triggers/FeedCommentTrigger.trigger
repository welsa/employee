/********************************************************************************************
Class Name - FeedItemTriggerHandler
Version - 1.0
Function - Class to Manage FeedComment Changes

Modification Log :
---------------------------------------------------------------------------------------------
* Developer     Date         Description
* ---------     ----------   -----------------------------------------------------------------
* Abdool        28/01/2019   Original Version (Trigger Notification To BS on Each New Comment)
*********************************************************************************************/
trigger FeedCommentTrigger on FeedComment (after insert) {
	FeedCommentTriggerHandler handler = new FeedCommentTriggerHandler();
    
    if(ASPISTools.cantrigger('FeedCommentTrigger')){
		if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.old,Trigger.new);
        }
    }
}