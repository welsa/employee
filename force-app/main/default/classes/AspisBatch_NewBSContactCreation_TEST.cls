@isTest
private class AspisBatch_NewBSContactCreation_TEST
/*
----------------------------------------------------------------------
-- - Name          : AspisBatch_NewBSContactCreation_TEST
-- - Author        : AMI

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 13-SEP-2018  AMI   1.0      Initial version
----------------------------------------------------------------------
*/
{
	static list <User> userList;
	static List <Account> lstAccount;
	static Contact con1;

	static
	{
		//initialising user
		userList 										= new list <User>{TestFactory.createUser('adminUser')};
		insert userList;

		system.runAs(userList[0]){
			//creating BS account
			lstAccount 									= new List <Account>{TestFactory.createAccountBodyshop('BodyShopv1', 'FR'),
																				TestFactory.createAccountBodyshop('BodyShopv2', 'FR'),
																				TestFactory.createAccountBodyshop('BodyShopv3', 'FR'),
																				TestFactory.createAccountBodyshop('BodyShopv4', 'FR')};

			lstAccount[0].CCUsername__c 				= 'NewBSContactCreationBodyShopv1@test.com';
			lstAccount[0].ContactEmail__c 				= 'NewBSContactCreationBodyShopv1@test.com';
			lstAccount[0].Locale__c 					= 'French';
			lstAccount[0].Communities_Target_Profile__c = system.label.CommunitiesTargetProfile;
			lstAccount[0].CommunitiesBatchNewBtoMigrate__c = true;

			lstAccount[1].CCUsername__c 				= 'NewBSContactCreationBodyShopv2@test.com';
			lstAccount[1].ContactEmail__c 				= 'NewBSContactCreationBodyShopv2@test.com';
			lstAccount[1].Locale__c 					= 'French';
			lstAccount[1].Communities_Target_Profile__c = system.label.CommunitiesTargetProfile;
			lstAccount[1].CommunitiesBatchNewBtoMigrate__c = true;

			lstAccount[2].CommunitiesBatchNewBtoMigrate__c = true;

			lstAccount[3].CommunitiesBatchNewBtoMigrate__c = true;

			insert lstAccount;

			con1										= new Contact (AccountId = lstAccount[3].Id,
																		LastName = 'testcontact');

			insert con1;
		}//end system.runAs
	}//end static

	@isTest static void NewBSContactCreationTest(){
		system.runAs(userList[0]){
			//start test
			Test.startTest();
				AspisBatch_NewBSContactCreation batch = new AspisBatch_NewBSContactCreation();
				Database.executeBatch(batch);
			Test.stopTest();

			//assert
			List<Contact> lstContact = [SELECT id FROM Contact WHERE AccountId IN :lstAccount];
			System.assertEquals(3,lstContact.size());
		}
	}
}