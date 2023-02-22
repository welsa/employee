@isTest private class AspisBatch_ContactCreation_TEST {
/*
----------------------------------------------------------------------
-- - Name          : AspisBatch_ContactCreation_TEST
-- - Author        : SPOON

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 21-AUG-2018  CLA    1.0      Initial version
----------------------------------------------------------------------
*/

	static User adminUser;
	static User user1;
	static User user2;
	static List<Account> lstAccount;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		user1 = TestFactory.createUser('user1');
		insert user1;

		user2 = TestFactory.createUser('user2');
		insert user2;

		System.runAs(adminUser)
		{
			lstAccount = new List<Account>();
			
			Account tmp = TestFactory.createAccountBodyshop('BodyShop_1', 'FR');
			tmp.ContactUser__c = user1.Id;
			tmp.Communities_Batch_1_BS_to_Migrate__c = true;
			lstAccount.add(tmp);

			tmp = TestFactory.createAccountBodyshop('BodyShop_2', 'FR');
			tmp.ContactUser__c = user2.Id;
			tmp.Communities_Batch_1_BS_to_Migrate__c = true;
			lstAccount.add(tmp);

			insert lstAccount;
		}
	}

	@isTest static void contactCreation_TEST(){
		System.runAs(adminUser)
		{
			Set<String> setAccId = new Set<String>();
			setAccId.add(lstAccount[0].Id);
			setAccId.add(lstAccount[1].Id);

			AspisBatch_ContactCreation batch = new AspisBatch_ContactCreation(setAccId);


			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Contact> lstContact = [SELECT id FROM Contact WHERE AccountId IN :setAccId];
			System.assertEquals(2,lstContact.size());
		}
	}
}