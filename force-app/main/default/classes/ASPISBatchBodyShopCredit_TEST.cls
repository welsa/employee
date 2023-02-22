/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchBodyShopCredit_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISBatchBodyShopCredit_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-APR-2016  ABT    1.0     Reworked version
  -- 10-MAY-2016  ABT	 1.1	 Added test for scheduler
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Yudish R  		08/07/2015 	Original Version
 **********************************************************************
*/
@isTest
public class ASPISBatchBodyShopCredit_TEST 
{
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

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
				TestFactory.createSalesOrder(assessmentList[1], accountList[1], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			invoiceList = new List<Invoice__c>
			{
				TestFactory.createBodyshopInvoice('0000001', 98, ASPISConstants.INV_STATUS_SENT, salesOrderList[0]),
				TestFactory.createBodyshopInvoice('0000002', 71, ASPISConstants.INV_STATUS_SENT, salesOrderList[0]),
				TestFactory.createBodyshopInvoice('0000003', 98, ASPISConstants.INV_STATUS_PAID, salesOrderList[0]),
				TestFactory.createBodyshopInvoice('0000004', 200, ASPISConstants.INV_STATUS_PAID, salesOrderList[0]),
				TestFactory.createBodyshopCreditNote('0000005', 50, ASPISConstants.INV_STATUS_SENT, salesOrderList[0]),

				TestFactory.createBodyshopInvoice('0000006', 213, ASPISConstants.INV_STATUS_SENT, salesOrderList[1]),
				TestFactory.createBodyshopInvoice('0000007', 89, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),
				TestFactory.createBodyshopInvoice('0000008', 250, ASPISConstants.INV_STATUS_SENT, salesOrderList[1]),
				TestFactory.createBodyshopCreditNote('0000009', 150, ASPISConstants.INV_STATUS_SENT, salesOrderList[1])
			};

			insert invoiceList;
		}
	}

	@isTest static void batchBodyShopCredit_TEST()
	{
		System.runAs(adminUser)
		{
			ASPISBatchBodyShopCredit batch = new ASPISBatchBodyShopCredit();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Account> updatedAccountList = [SELECT	Id, Credit__c
												FROM	Account
												WHERE	Id IN: accountList];

			System.assertEquals(119, updatedAccountList[0].Credit__c);
			System.assertEquals(313, updatedAccountList[1].Credit__c);
		}
	}

	// ABT 10-MAY-2016 
	@isTest static void scheduleBatchBodyShopCredit()
	{
		System.runAs(adminUser)
		{
			ASPISScheduledBodyShopCredit scheduler = new ASPISScheduledBodyShopCredit();
			String sch = '0 0 0 * * ?';

			Test.startTest();
				Id processId = System.schedule('Test bodyshop credit scheduler', sch, scheduler);
			Test.stopTest();

			CronTrigger ct = [SELECT Id, CronExpression
							  FROM	 CronTrigger
							  WHERE	 Id =: processId];

			System.assertEquals(sch, ct.CronExpression);
		}
	}
}