@isTest
private class TESTASPISScheduleBatchDeleteNotification {
// ABT - 10-MAY-2016 - Commented as ASPISBatchDeleteNotifications_TEST does it
/*
    @isTest static void test_ASPISScheduleBatchDeleteNotification() {
		// Implement test code

		String jobId;
		Test.startTest();
			ASPISScheduleBatchDeleteNotifications schBatchDeleteNotification = new ASPISScheduleBatchDeleteNotifications();
			// means 'every day at 9 p.m.'
			String dailyCronExpression = '0 0 21 * * ?';

			jobId = system.schedule('Process Trans 1', dailyCronExpression, schBatchDeleteNotification);
		Test.stopTest();

		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		system.debug('CronTriggerBSCredit:'+ct);

		System.assertEquals(dailyCronExpression, ct.CronExpression); 
		System.assertEquals(0, ct.TimesTriggered);
	}*/
}