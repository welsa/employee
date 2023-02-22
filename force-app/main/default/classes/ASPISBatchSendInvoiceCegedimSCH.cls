/*************************************************************************************
Class Name - ASPISBatchSendInvoiceCegedimSCH
Version - 1.0
Created Date - 24 FEB 2015
Function - Schedulable for the batch ASPISBatchSendInvoiceCegedim

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Cecile L      24/02/2016  Original Version
* Dourga U 	    27/05/2016  Commented class, moved logic in class ASPISBatchSendInvoice
*************************************************************************************/
global class ASPISBatchSendInvoiceCegedimSCH {/*implements Schedulable {
  global void execute(SchedulableContext sc) {
    //MyBatchClass b = new MyBatchClass();
    //database.executebatch(b);
    database.executebatch(new ASPISBatchSendInvoiceCegedim()); 
  }*/
}