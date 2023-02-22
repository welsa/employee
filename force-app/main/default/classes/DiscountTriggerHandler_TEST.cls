/*
  ----------------------------------------------------------------------
  -- - Name          : DiscountTriggerHandler_TEST
  -- - Author        : DUN
  -- - Description   : Test class for DiscountTriggerHandler
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 27-SEP-2016  ABT    1.0     Reworked the class as it was referencing ASPISTestUtils
  ----------------------------------------------------------------------
   -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Dourga U		27/04/2016  Reworked Version
 **********************************************************************
*/
@isTest
private class DiscountTriggerHandler_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Discount__c> discountList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShopFR_1', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_1', 'FR')
			};

			insert accountList;

			// NOTE: The brand__c will be sorted in the database. Make sure you input a sorted brand to facilitate asserts afterwards.
			discountList = new List<Discount__c>
			{
				TestFactory.createBodyshopDiscount(accountList[0], 10.0, 'A', 'MERCEDES;NISSAN'),
				TestFactory.createDistributorDiscount(accountList[1], 20.0, 'A', 'FERRARI;MAZDA')
			};

			insert discountList;
		}
	}

	@isTest static void onBeforeInsert_TEST()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test the insert of a discount so we need new discounts
			// In the trigger the value of Brand__c will be copied to TECH_BrandsText__c

			List<Discount__c> discountToBeInsertedList = new List<Discount__c>
			{
				TestFactory.createBodyshopDiscount(accountList[0], 50.0, 'B', 'RENAULT;REDBULL'),
				TestFactory.createDistributorDiscount(accountList[1], 40.0, 'B', 'DACIA;PEUGEOT')
			};

			Test.startTest();
				insert discountToBeInsertedList;
			Test.stopTest();

			List<Discount__c> insertedDiscountList = [	SELECT	Id, Brand__c, TECH_BrandsText__c
														FROM	Discount__c
														WHERE	Id IN: discountToBeInsertedList];

			System.assertEquals(discountToBeInsertedList[0].Brand__c, insertedDiscountList[0].TECH_BrandsText__c);
			System.assertEquals(discountToBeInsertedList[1].Brand__c, insertedDiscountList[1].TECH_BrandsText__c);
		}
	}

	@isTest static void onBeforeUpdate_TEST()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test the upadte of discounts
			// In the trigger the value of Brand__c will be copied to TECH_BrandsText__c on if there has been a changed
			
			discountList[1].Brand__c = 'TOYOTA';
			
			Test.startTest();
				update discountList;
			Test.stopTest();

			List<Discount__c> updatedDiscountList = [	SELECT	Id, Brand__c, TECH_BrandsText__c
														FROM	Discount__c
														WHERE	Id IN: discountList];

			System.assertEquals(discountList[0].Brand__c, updatedDiscountList[0].TECH_BrandsText__c);
			System.assertEquals(discountList[1].Brand__c, updatedDiscountList[1].TECH_BrandsText__c);
		}
	}
}