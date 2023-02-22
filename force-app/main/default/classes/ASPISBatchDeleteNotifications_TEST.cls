/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchDeleteNotifications_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISBatchDeleteNotifications_TEST
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
  -- Brayan Nunhuck 05/08/2015 	Original Version
 **********************************************************************
*/
@isTest
public class ASPISBatchDeleteNotifications_TEST 
{
	static User adminUser;
	static List<DelayForDeletion__c> delayForDeletionList;
	static List<Notification__c> notificationList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			delayForDeletionList = new List<DelayForDeletion__c>
			{
				new DelayForDeletion__c(Name							= 'DELETE-FROM',
										PurgePeriodNotificationsDays__c	= 1)
			};

			insert delayForDeletionList;

			notificationList = new List<Notification__c>
			{
				new Notification__c(Tech_CreatedDate__c = System.now().addMonths(-3)),
				new Notification__c(Tech_CreatedDate__c = null)
			};

			insert notificationList;
		}
	}

	@isTest static void deleteNotification()
	{
		System.runAs(adminUser)
		{
			ASPISBatchDeleteNotifications batch = new ASPISBatchDeleteNotifications();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Notification__c> remainingNotificationList = [SELECT Id
											 FROM	Notification__c
											 WHERE	Id IN: notificationList];

			System.assertEquals(1, remainingNotificationList.size());
		}
	}

	@isTest static void noNotificationDeleted()
	{
		System.runAs(adminUser)
		{
			// updating the DelayForDeletion__c
			delayForDeletionList[0].PurgePeriodNotificationsDays__c = null;

			update delayForDeletionList;
			
			ASPISBatchDeleteNotifications batch = new ASPISBatchDeleteNotifications();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Notification__c> remainingNotificationList = [SELECT Id
											 FROM	Notification__c
											 WHERE	Id IN: notificationList];

			System.assertEquals(2, remainingNotificationList.size());
		}
	}

	@isTest static void scheduleBatchDeleteLogs()
	{
		System.runAs(adminUser)
		{
			ASPISScheduleBatchDeleteNotifications scheduler = new ASPISScheduleBatchDeleteNotifications();
			String sch = '0 0 0 * * ?';

			Test.startTest();
				Id processId = System.schedule('Test delete notifications scheduler', sch, scheduler);
			Test.stopTest();

			CronTrigger ct = [SELECT Id, CronExpression
							  FROM	 CronTrigger
							  WHERE	 Id =: processId];

			System.assertEquals(sch, ct.CronExpression);
		}
	}
}