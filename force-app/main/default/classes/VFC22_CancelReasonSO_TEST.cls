@isTest
private class VFC22_CancelReasonSO_TEST
{
/*************************************************************************************
Class Name - VFC22_CancelReasonSO_TEST
Version - 1.0
Created Date - 08 AUG 2018
Function - TestClass for VFC22_CancelReasonSO

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Ruksaar       08/08/2018  Original Version
*************************************************************************************/

	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;

	static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES')
			};

			insert accountList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2])
			};

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};
			
			insert salesOrderList;

			
		}
	}

	static testMethod void  constructorWithoutSO_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP22_CancelReasonSO);

			Test.startTest();
				VFC22_CancelReasonSO controller = new VFC22_CancelReasonSO();
			Test.stopTest();

			System.assertEquals(null, controller.so);
			System.assertEquals(null, controller.soId);
			
		}
	}

	static testMethod void constructorWithSO_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP22_CancelReasonSO);
			ApexPages.currentPage().getParameters().put('Id', salesOrderList[0].Id);

			Test.startTest();
				VFC22_CancelReasonSO controller = new VFC22_CancelReasonSO();
				 			
			Test.stopTest();

			//System.assertEquals(salesOrderList[0], controller.so);
			System.assertEquals(salesOrderList[0].Id, controller.soId);
		}
	}

	static testMethod void constructorWithSOSave_TEST()
	{
		System.runAs(adminUser)
		{
			salesOrderList[0].cancelationReason__c = '6. OTHER';
			update salesOrderList;

			System.debug('@@ start:');

			Test.setCurrentPage(Page.VFP22_CancelReasonSO);
			ApexPages.currentPage().getParameters().put('Id', salesOrderList[0].Id);

			Test.startTest();
				VFC22_CancelReasonSO controller = new VFC22_CancelReasonSO();
				controller.savePicklist();
				 			
			Test.stopTest();

			PrerequisiteOrder__c so = [select Status__c, Comment__c from PrerequisiteOrder__c
																	where Id = :salesOrderList[0].Id ];

			System.debug('@@ so:'+so);
			System.assertEquals(so.Comment__c, '6. OTHER');
			//System.assertEquals(so.Status__c, 'CANCELED');
			//System.assertEquals(salesOrderList[0], controller.so);
			System.assertEquals(salesOrderList[0].Id, controller.soId);
		}
	}

	static testMethod void constructorWithSOSaveError_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.VFP22_CancelReasonSO);
			ApexPages.currentPage().getParameters().put('Id', salesOrderList[0].Id);

			Test.startTest();
				VFC22_CancelReasonSO controller = new VFC22_CancelReasonSO();

				controller.savePicklist();
				 			
			Test.stopTest();

			PrerequisiteOrder__c so = [select Status__c, Comment__c from PrerequisiteOrder__c
																	where Id = :salesOrderList[0].Id ];
			System.assertEquals(so.Comment__c, null);
			System.assertEquals(so.Status__c, ASPISConstants.PRE_ORDER_STATUS_INDELIVERY);
			//System.assertEquals(salesOrderList[0], controller.so);
			System.assertEquals(salesOrderList[0].Id, controller.soId);
		}
	}
}