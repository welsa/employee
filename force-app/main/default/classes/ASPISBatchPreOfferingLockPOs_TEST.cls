/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchPreOfferingLockPOs_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISBatchPreOfferingLockPOs_TEST
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
  -- Kevan (sc)	    22/05/2015  Original Version
  -- Bhavish (sc)	27/05/2015	Added Assert
 **********************************************************************
*/
@isTest
public class ASPISBatchPreOfferingLockPOs_TEST 
{
	// ABT - 02-NOV-2016 - C-001625 - Commented
	/*
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<Invoice__c> invoiceList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountBodyshop('BodyShop_2', 'FR')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment1', accountList[0]),
				TestFactory.createAssessment('Assessment2', accountList[1])
			};

			assessmentList[0].QuotationEndTime__c = System.now().addDays(-100);
			assessmentList[1].QuotationEndTime__c = System.now().addDays(-100);

			assessmentList[0].Status__c = ASPISConstants.ASSESS_STATUS_SOURCED;
			assessmentList[1].Status__c = ASPISConstants.ASSESS_STATUS_SOURCED;

			insert assessmentList;
		}
	}

	@isTest static void batchPreOfferingLockPOsWithoutParameter()
	{
		System.runAs(adminUser)
		{
			ASPISBatchPreOfferingLockPOs batch = new ASPISBatchPreOfferingLockPOs();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Assessment__c> updatedAssessmentList = [SELECT Id, Status__c
														 FROM	Assessment__c
														 WHERE	Id IN: assessmentList];

			System.assertEquals(2, updatedAssessmentList.size());
			System.assertEquals('PREOFFERING', updatedAssessmentList[0].Status__c);
			System.assertEquals('PREOFFERING', updatedAssessmentList[1].Status__c);
		}
	}

	@isTest static void batchPreOfferingLockPOsWithParameter()
	{
		System.runAs(adminUser)
		{
			String soql = 'SELECT Id, Name, BodyShop__c, Entity__c ' +
						  'FROM Assessment__c ' + 
						  'WHERE QuotationExpired__c = true ' + 
						  'AND Status__c = \'SOURCED\' ';

			ASPISBatchPreOfferingLockPOs batch = new ASPISBatchPreOfferingLockPOs(soql);

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Assessment__c> updatedAssessmentList = [SELECT Id, Status__c
														 FROM	Assessment__c
														 WHERE	Id IN: assessmentList];

			System.assertEquals(2, updatedAssessmentList.size());
			System.assertEquals('PREOFFERING', updatedAssessmentList[0].Status__c);
			System.assertEquals('PREOFFERING', updatedAssessmentList[1].Status__c);
		}
	}*/
}