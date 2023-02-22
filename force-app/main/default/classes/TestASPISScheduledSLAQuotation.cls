/*************************************************************************************
Class Name - TestASPISScheduledSLAQuotation
Version - 1.0
Created Date - 11 MAY 2015
Function - TestClass to ASPISScheduledSLAQuotation

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Yudish R  	11/05/2015 	Original Version
*************************************************************************************/
@isTest
private class TestASPISScheduledSLAQuotation {
// ABT - 10-MAY-2016 - Commented as ASPISBatchBodyShopCredit_TEST does it
/*
	@isTest static void test_ScheduledSLA() {
		
		String jobId;
		Test.startTest();
	        ASPISScheduledSLAQuotation s8 = new ASPISScheduledSLAQuotation();
	        string sch = '0 10 * * * ?';
	        jobId = system.schedule('Process Trans 1', sch, s8);
        Test.stopTest();

		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		//system.debug('CronTrigger:'+ct);
		
		System.assertEquals(sch, ct.CronExpression); 
		System.assertEquals(0, ct.TimesTriggered);
		
	}
*/
}