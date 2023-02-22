@isTest
private class TestASPISScheduledBodyShopCredit {
// ABT - 10-MAY-2016 - Commented as ASPISBatchBodyShopCredit_TEST does it
/*
	@isTest static void test_ScheduledBSCredit() {
		// Implement test code

		String jobId;
		Test.startTest();
			ASPISScheduledBodyShopCredit schBsCredit = new ASPISScheduledBodyShopCredit();
			// means 'every day at 1 p.m.'
			String dailyCronExpression = '0 0 13 * * ?';

			jobId = system.schedule('Process Trans 1', dailyCronExpression, schBsCredit);
		Test.stopTest();

		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		//system.debug('CronTriggerBSCredit:'+ct);

		System.assertEquals(dailyCronExpression, ct.CronExpression); 
		System.assertEquals(0, ct.TimesTriggered);
	}
*/
}