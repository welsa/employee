/*************************************************************************************
Class Name - TestASPISScheCreateCaseFromSalesOrder
Version - 1.0
Created Date - 16 JUL 2015
Function - TestClass to ASPISScheduleCreateCaseFromSalesOrder

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Hirikesh (SC)	16/07/2015 	Original Version
*************************************************************************************/
@isTest
private class TestASPISScheCreateCaseFromSalesOrder {
// ABT - 10-MAY-2016 - Commented
/*
	@isTest static void test_ScheduledSLA() {
		
		String jobId;
		Test.startTest();
	        ASPISScheduleCreateCaseFromSalesOrder s8 = new ASPISScheduleCreateCaseFromSalesOrder();
	        string sch = '0 10 * * * ?';
	        jobId = system.schedule('Process Trans 1', sch, s8);
        Test.stopTest();

		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		system.debug('CronTrigger:'+ct);
		
		System.assertEquals(sch, ct.CronExpression); 
		System.assertEquals(0, ct.TimesTriggered);
		
	}
*/
}