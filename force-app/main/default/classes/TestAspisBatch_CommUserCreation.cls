@isTest private class TestAspisBatch_CommUserCreation {
/*
----------------------------------------------------------------------
-- - Name          : TestAspisBatch_CommUserCreation
-- - Author        : SPOON

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 22-AUG-2018  LGO    1.0      Initial version
----------------------------------------------------------------------
*/

	static User adminUser;
	static User user1;
	static User user2;
	static PermissionSetAssignment psa;
	static List<Account> lstAccount;
	static List<Contact> lstContact;
	static map <String, String> mapUserIdToContactId = new map<String, String>();

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)

		{
			        user1 = new User(Username = 'jean.paul@test.com'
                    ,LastName = 'pauline'
                    ,LanguageLocaleKey = 'en_US'
                    ,FirstName = 'jean'
                    ,Email = 'jean@test.com'
                    ,Alias = 'jpa'
                    ,TimeZoneSidKey = 'Europe/Dublin'
                    ,LocaleSidKey = 'en_US'
                    ,EmailEncodingKey = 'UTF-8'
                    ,ProfileId = ASPISConstants.getProfileAdminId()); 

            insert user1;

			lstAccount = new List<Account>();
			lstContact = new List<Contact>();
			
			Account tmp = TestFactory.createAccountBodyshop('BodyShop_1', 'FR');
			tmp.ArchivedContactUser__c = user1.Id;
			tmp.Communities_Batch_1_BS_to_Migrate__c = true;
			tmp.Communities_Target_Profile__c = 'CC Bodyshop;00e0D000000LqfK';
			lstAccount.add(tmp);

			insert lstAccount;



			lstContact = new List<Contact>{new Contact(firstName = lstAccount[0].Name,
                                                lastName = lstAccount[0].Name,
                                                //Email = lstAccount[0].Email,
                                                AccountID = lstAccount[0].id)

		                                   };

			insert lstContact;


			//psa = new PermissionSetAssignment(AssigneeId = user2.id, PermissionSetId = system.label.PaintingPermissionSetId.split('-')[0]);


			//insert psa;
		}
	}

	@isTest static void userCreation_TEST(){
		System.runAs(adminUser)
		{
			
			mapUserIdToContactId.put(user1.Id,lstContact[0].Id);
			

			AspisBatch_CommUserCreation batch = new AspisBatch_CommUserCreation(mapUserIdToContactId);


			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<User> lstUser = [SELECT id FROM User WHERE Id IN :mapUserIdToContactId.keySet()];
			System.assertEquals(1,lstUser.size());
		}
	}
}