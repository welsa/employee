/*************************************************************************************
Class Name - ASPISSCHBatchCreateCaseFromSalesOrder
Version - 1.0
Created Date - 15 June 2015
Function - Schedulable for the batch ASPISSCHBatchCreateCaseFromSalesOrder

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Brayan Nunhuck    	15/06/2015  Original Version
*************************************************************************************/
global class ASPISSCHBatchCreateCaseFromSalesOrder implements Schedulable {
	global void execute(SchedulableContext sc) {
		//MyBatchClass b = new MyBatchClass();
		//database.executebatch(b);
		ASPISBatchCreateCaseFromSalesOrder insertCase = new ASPISBatchCreateCaseFromSalesOrder();
		database.executebatch(insertCase); 
	}
}