/*
----------------------------------------------------------------------
-- - Name          : AP32PopulatePurchaseOrderFromAccountTEST
-- - Author        : ABT
-- - Description   : Test class for AP32PopulatePurchaseOrderFromAccount.
--					 Could not create AP32PopulatePurchaseOrderFromAccount_TEST as it exceeds 40 characters
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		----------------------------------
-- 13-JAN-2016	ABT		1.0			Initial version - C-001856
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class AP32PopulatePurchaseOrderFromAccountTEST 
{
	static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
				TestFactory.createAccountDistributor('Distributor_FR', 'FR')
			};

			accountList[1].ContactUser__c 	= adminUser.Id;
			accountList[1].Rebate__c 		= 10;

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR_1', accountList[0])
			};

			insert assessmentList;
		}
	}

	@isTest static void populatePurchaseOrder_TEST()
	{
		System.runAs(adminUser)
		{
			List<PurchaseOrder__c> purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			Test.startTest();
				insert purchaseOrderList;
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT 	Id, DistributorContact__c, Rebate__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList];

			System.assertEquals(adminUser.Id, updatedPurchaseOrderList[0].DistributorContact__c);
			System.assertEquals(adminUser.Id, updatedPurchaseOrderList[1].DistributorContact__c);
			System.assertEquals(10, updatedPurchaseOrderList[1].Rebate__c);
			System.assertEquals(10, updatedPurchaseOrderList[1].Rebate__c);
		}
	}
}