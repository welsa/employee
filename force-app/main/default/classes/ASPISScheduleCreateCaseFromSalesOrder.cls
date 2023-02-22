/*************************************************************************************
Class Name - ASPISScheduleCreateCaseFromSalesOrder
Version - 1.0
Created Date - 19 JUN 2015
Function - schedule class for SLA Quotation

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Cecile L     			19/05/2015  Original Version
*************************************************************************************/
global class ASPISScheduleCreateCaseFromSalesOrder {
// ABT 10-MAY-2016 - Commented due to duplicate scheduler
/*implements Schedulable {
	global void execute(SchedulableContext SC) {
		ASPISBatchCreateCaseFromSalesOrder b = new ASPISBatchCreateCaseFromSalesOrder(); 

		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
   			database.executeBatch(b);
		}
		//database.executeBatch(b);
	}
	*/
	/*
	public static void scheduleThis(){
       	ASPISBatchSLAQuotation b = new ASPISBatchSLAQuotation(); 

		String sch = '0 05 * * * ?';
		String jobID = system.schedule('Merge Job', sch, (Schedulable)b);
    }*/

}