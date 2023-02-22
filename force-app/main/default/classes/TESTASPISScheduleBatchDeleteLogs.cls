@isTest
private class TESTASPISScheduleBatchDeleteLogs {
// ABT - 10-MAY-2016 - Commented as ASPISBatchDeleteLogs_TEST does it
/*
	@isTest static void test_ScheduledBSCredit() {
		// Implement test code

		String jobId;
		Test.startTest();
			ASPISScheduleBatchDeleteLogs schBatchDelete = new ASPISScheduleBatchDeleteLogs();
			// means 'every day at 8 p.m.'
			String dailyCronExpression = '0 0 20 * * ?';

			jobId = system.schedule('Process Trans 002', dailyCronExpression, schBatchDelete );
		Test.stopTest();

		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		system.debug('Proces :'+ct);

		System.assertEquals(dailyCronExpression, ct.CronExpression); 
		System.assertEquals(0, ct.TimesTriggered);
	}	
*/
}