/*************************************************************************************
Class Name - ASPISBatchCreateInvoiceAddDisSCH
Version - 1.0
Created Date - 15 FEB 2016
Function - Schedulable for the batch ASPISBatchCreateInvoiceAddDis

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      15/02/2016  Original Version
* Ruksaar L 	26/07/2018	C-002694 - Issue with Batch "ASPISBatchCreateInvoiceAddDis
*************************************************************************************/
global class ASPISBatchCreateInvoiceAddDisSCH implements Schedulable {
  global void execute(SchedulableContext sc) {
    //MyBatchClass b = new MyBatchClass();
    //database.executebatch(b);
    database.executebatch(new ASPISBatchCreateInvoiceAddDis(), 200); 
  }

  	//RLA 16/07/2018 C-002694 - Issue with Batch "ASPISBatchCreateInvoiceAddDis
	public static void scheduleThis(){

		String sch = '0 20 18 ? * * *';
		String jobID = system.schedule('ASPISBatchCreateInvoiceAddDisSCH', sch, new ASPISBatchCreateInvoiceAddDisSCH());
    }
}