/*************************************************************************************
Class Name - ASPISScheduledBodyShopCredit
Version - 1.0
Created Date - 06 JUL 2015
Function - schedule class for SLA Quotation

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Yudish R     			06/07/2015  Original Version
*************************************************************************************/

global class ASPISScheduledBodyShopCredit implements Schedulable {
	global void execute(SchedulableContext sc) {
		ASPISBatchBodyShopCredit b = new ASPISBatchBodyShopCredit();
		database.executebatch(b);
	}
}