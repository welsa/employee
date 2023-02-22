/*
  ----------------------------------------------------------------------
  -- - Name          : Utils_ManageLogs_TEST
  -- - Author        : ABT
  -- - Description   : Test class for Utils_ManageLogs
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 20-SEP-2016  ABT    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class Utils_ManageLogs_TEST 
{
	static User adminUser;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;
	}

	@isTest static void createLogFromException_TEST() 
	{
		System.runAs(adminUser)
		{
			// Testing the function createLogFromException
			// Creating an instance of a null pointer exeception and casting it to Exception
			Test.startTest();
				Utils_ManageLogs.createLogFromException('Utils_ManageLogs_TEST', 'Log__c', (Exception) NullPointerException.class.newInstance());
			Test.stopTest();
		
			List<Log__c> logList = [SELECT	Id
									FROM	Log__c
									WHERE	RecordTypeId =: Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Development').getRecordTypeId()
									AND		Status__c = 'Failed'];

			System.assertEquals(1, logList.size());
		}
	}

	@isTest static void createLogManually_TEST() 
	{
		System.runAs(adminUser)
		{
			// Testing the function createLogManually
			// Log is created using the inputs we feed to the function.
			Test.startTest();
				Utils_ManageLogs.createLogManually('Utils_ManageLogs_TEST', 'Log__c', 'TESTERROR', 'Testing log creation manually', 'Utils_ManageLogs_TEST.createLogManually_TEST');
			Test.stopTest();
		
			List<Log__c> logList = [SELECT	Id
									FROM	Log__c
									WHERE	RecordTypeId =: Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Development').getRecordTypeId()
									AND		Status__c = 'Failed'];

			System.assertEquals(1, logList.size());
		}
	}
    //GBH	
    @isTest static void NOBcreateLogFromException_TEST() 
	{
		System.runAs(adminUser)
		{
			// Testing the function createLogFromException
			// Creating an instance of a null pointer exeception and casting it to Exception
			Test.startTest();
				Utils_ManageLogs.NOBcreateLogFromException('Utils_ManageLogs_TEST', 'Log__c', (Exception) NullPointerException.class.newInstance(), '0WO250000074GQaGAM');
			Test.stopTest();
		
			List<Log__c> logList = [SELECT	Id
									FROM	Log__c
									WHERE	RecordTypeId =: Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Development').getRecordTypeId()
									AND		Status__c = 'Failed'];

			System.assertEquals(1, logList.size());
		}
	}
}