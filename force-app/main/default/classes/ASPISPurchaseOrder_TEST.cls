/*
  ---------------------------------------------------------------------- 
  -- - Name          : ASPISPurchaseOrder_TEST
  -- - Author        : ABT
  -- - Description   : Test class for ASPISPurchaseOrder
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 27-SEP-2016  ABT    1.0     Initial Version
  -- 07-SEP-2017  AMI    2.0     Added new methods param to createOrders 
  -- 							(due to distributor intgegration)
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class ASPISPurchaseOrder_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShopFR_1', 'FR'),
				TestFactory.createAccountBodyshop('BodyShopES_1', 'ES'),

				TestFactory.createAccountDistributor('DistributorFR_1', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_2', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_3', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_4', 'FR'),

				TestFactory.createAccountDistributor('DistributorES_1', 'ES'),
				TestFactory.createAccountDistributor('DistributorES_2', 'ES'),
				TestFactory.createAccountDistributor('DistributorES_3', 'ES'),
				TestFactory.createAccountDistributor('DistributorES_4', 'ES')
			};

			accountList[2].ReferenceNumber__c = '222222';
			accountList[3].ReferenceNumber__c = '333333';
			accountList[4].ReferenceNumber__c = '444444';
			accountList[5].ReferenceNumber__c = '555555';

			accountList[6].ReferenceNumber__c = '666666';
			accountList[7].ReferenceNumber__c = '777777';
			accountList[8].ReferenceNumber__c = '888888';
			accountList[9].ReferenceNumber__c = '999999';

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('AssessmentFR_1', accountList[0]),
				TestFactory.createAssessment('AssessmentES_1', accountList[1])
			};

			// Setting the TECH_EntityCountryCode__c as ES in the second assessment
			assessmentList[0].TECH_EntityCountryCode__c = 'ES';

			insert assessmentList;

			// access Business Hours 
            defaultHours = [SELECT	Id 
							FROM	BusinessHours 
							WHERE	IsDefault = true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id)
			};
			
			insert countryMappingList;
		}
	}

	@isTest static void createOrdersFR_TEST()
	{
		System.runAs(adminUser)
		{
			// The function createOrders is used to create purchase orders for 1 assessment only.
			// In this test method we will test the function directly not passing by the triggers.

			List<Account> distributorList = new List<Account>
			{
				accountList[2],
				accountList[4],
				accountList[5]
			};

			Test.startTest();
				//AMI 07/09/17 - Added new methods param (due to distributor intgegration)
				ASPISPurchaseOrder.createOrders(assessmentList[0], distributorList,'',null,new set <id>(),new map <id,Account>());
			Test.stopTest();

			// The function above will create the purchase orders and also share the bodyshop to the distributors of the purchase order

			List<PurchaseOrder__c> purchaseOrderList = [SELECT	Id
														FROM	PurchaseOrder__c
														WHERE	Assessment__c =: assessmentList[0].Id];

			System.assertEquals(3, purchaseOrderList.size());

			List<String> groupNameList = new List<String>
			{
				distributorList[0].ReferenceNumber__c, 
				distributorList[1].ReferenceNumber__c, 
				distributorList[2].ReferenceNumber__c
			};

			List<AccountShare> accountShareList = [	SELECT	Id
													FROM	AccountShare
													WHERE	UserOrGroup.Name IN: groupNameList
													AND		AccountId =: assessmentList[0].BodyShop__c];

			System.assertEquals(0, accountShareList.size());
		}
	}

	@isTest static void createOrdersDefault_TEST()
	{
		System.runAs(adminUser)
		{
			// The function createOrders is used to create purchase orders for 1 assessment only.
			// In this test method we will test the function directly not passing by the triggers.
			// We will use the ES assessment but there is no ES in the country code mapping.

			List<Account> distributorList = new List<Account>
			{
				accountList[6],
				accountList[9]
			};

			Test.startTest();
				//AMI 07/09/17 - Added new methods param (due to distributor intgegration)
				ASPISPurchaseOrder.createOrders(assessmentList[1], distributorList,'',null,new set <id>(),new map <id,Account>());
			Test.stopTest();

			// The function above will create the purchase orders and also share the bodyshop to the distributors of the purchase order

			List<PurchaseOrder__c> purchaseOrderList = [SELECT	Id
														FROM	PurchaseOrder__c
														WHERE	Assessment__c =: assessmentList[1].Id];

			//System.assertEquals(2, purchaseOrderList.size());

			List<String> groupNameList = new List<String>
			{
				distributorList[0].ReferenceNumber__c,
				distributorList[1].ReferenceNumber__c
			};

			List<AccountShare> accountShareList = [	SELECT	Id
													FROM	AccountShare
													WHERE	UserOrGroup.Name IN: groupNameList
													AND		AccountId =: assessmentList[1].BodyShop__c];

			//System.assertEquals(2, accountShareList.size());
		}
	}
}