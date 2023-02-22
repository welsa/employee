/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchDeleteLogs_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISBatchDeleteLogs_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- No History
 **********************************************************************
*/
@isTest
public class ASPISBatchDeleteLogs_TEST 
{
	static User adminUser;
	static List<DelayForDeletion__c> delayForDeletionList;
	static List<Log__c> logList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			delayForDeletionList = new List<DelayForDeletion__c>
			{
				new DelayForDeletion__c(Name					= 'DELETE-FROM',
										PurgePeriodLogsDays__c	= 1)
			};

			insert delayForDeletionList;

			logList = new List<Log__c>
			{
				new Log__c(Tech_CreatedDate__c = System.now().addMonths(-3)),
				new Log__c(Tech_CreatedDate__c = null)
			};

			insert logList;
		}
	}

	@isTest static void deleteLog()
	{
		System.runAs(adminUser)
		{
			ASPISBatchDeleteLogs batch = new ASPISBatchDeleteLogs();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Log__c> remainingLogList = [SELECT Id
											 FROM	Log__c
											 WHERE	Id IN: logList];

			System.assertEquals(1, remainingLogList.size());
		}
	}

	@isTest static void noLogDeleted()
	{
		System.runAs(adminUser)
		{
			// updating the DelayForDeletion__c
			delayForDeletionList[0].PurgePeriodLogsDays__c = null;

			update delayForDeletionList;
			
			ASPISBatchDeleteLogs batch = new ASPISBatchDeleteLogs();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Log__c> remainingLogList = [SELECT Id
											 FROM	Log__c
											 WHERE	Id IN: logList];

			System.assertEquals(2, remainingLogList.size());
		}
	}

	@isTest static void scheduleBatchDeleteLogs()
	{
		System.runAs(adminUser)
		{
			ASPISScheduleBatchDeleteLogs scheduler = new ASPISScheduleBatchDeleteLogs();
			String sch = '0 0 0 * * ?';

			Test.startTest();
				Id processId = System.schedule('Test delete logs scheduler', sch, scheduler);
			Test.stopTest();

			CronTrigger ct = [SELECT Id, CronExpression
							  FROM	 CronTrigger
							  WHERE	 Id =: processId];

			System.assertEquals(sch, ct.CronExpression);
		}
	}
}