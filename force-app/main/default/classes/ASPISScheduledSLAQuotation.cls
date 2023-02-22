global class ASPISScheduledSLAQuotation implements Schedulable {
/*************************************************************************************
Class Name - ASPISScheduledSLAQuotation
Version - 1.0
Created Date - 11 MAY 2015
Function - schedule class for SLA Quotation

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Yudish R     			11/05/2015  Original Version
*************************************************************************************/

	global void execute(SchedulableContext SC) {
		ASPISBatchSLAQuotation b = new ASPISBatchSLAQuotation(); 

		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
   			database.executeBatch(b);
		}
		//database.executeBatch(b);
		
	}

	/*
	public static void scheduleThis(){
       	ASPISBatchSLAQuotation b = new ASPISBatchSLAQuotation(); 

		String sch = '0 05 * * * ?';
		String jobID = system.schedule('Merge Job', sch, (Schedulable)b);
    }*/

}