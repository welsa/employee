/*************************************************************************************
Class Name - ASPISScheduleBatchDeleteNotifications
Version - 1.0
Created Date - 04 AUG 2015
Function - Scheduler for Batch to delete Notifications

Modification Log :
-----------------------------------------------------------------------------
* Developer  	 Date       	Description
* ---------- 	 ----------  -----------------------
* Brayan Nunhuck 05/08/2015 	Original Version
*************************************************************************************/
global class ASPISScheduleBatchDeleteNotifications implements Schedulable {
	global void execute(SchedulableContext sc) {
		ASPISBatchDeleteNotifications b = new ASPISBatchDeleteNotifications(); 

		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
   			database.executeBatch(b);
		}
	}
}