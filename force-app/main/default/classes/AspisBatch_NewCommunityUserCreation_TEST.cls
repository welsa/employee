@isTest
private class AspisBatch_NewCommunityUserCreation_TEST
/*
----------------------------------------------------------------------
-- - Name          : AspisBatch_NewCommunityUserCreation_TEST
-- - Author        : AMI

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 13-SEP-2018  AMI   1.0      Initial version
-- 24-AUG-2020  WCH   1.1      C-003838 - Nob - Migrate Billing information to new fields
----------------------------------------------------------------------
*/
{
	static list <User> userList;
	static List <Account> lstAccount;
	static List <Contact> lstContact;

	static
	{
		//initialising user
		userList 										= new list <User>{TestFactory.createUser('adminUser')};
		userList[0].UserRoleId    = [select id from UserRole where name='Alpha Scale'].Id;
		insert userList;

		system.runAs(userList[0]){
			//creating BS account
			lstAccount 									= new List <Account>{TestFactory.createAccountBodyshop('BodyShopv1', 'FR'),
																				TestFactory.createAccountBodyshop('BodyShopv2', 'DE'),
																				TestFactory.createAccountBodyshop('BodyShopv3', 'ES'),
																				TestFactory.createAccountBodyshop('BodyShopv4', 'BE'),
																				TestFactory.createAccountBodyshop('BodyShopv5', 'BE')};

			lstAccount[0].CCUsername__c 				= 'NewCommunityUserCreationBodyShopv1@test.com';
			lstAccount[0].ContactEmail__c 				= 'NewCommunityUserCreationBodyShopv1@test.com';
			lstAccount[0].Locale__c 					= 'French';
			lstAccount[0].Communities_Target_Profile__c = system.label.CommunitiesTargetProfile;
			lstAccount[0].CommunitiesBatchNewBtoMigrate__c = true;
			lstAccount[0].Phone 						= '4543333';
			lstAccount[0].Fax 							= '122333';
			lstAccount[0].ReferenceNumber__c 			= 'FR0000033333';//WCH 23/12/2020 C-004120
			lstAccount[0].Permission_Sets__c			=  system.label.CommunitiesPermissionSet;

			lstAccount[1].CCUsername__c 				= 'NewCommunityUserCreationBodyShopv2@test.com';
			lstAccount[1].ContactEmail__c 				= 'NewCommunityUserCreationBodyShopv2@test.com';
			lstAccount[1].Locale__c 					= 'German';
			lstAccount[1].Communities_Target_Profile__c = system.label.CommunitiesTargetProfile;
			lstAccount[1].CommunitiesBatchNewBtoMigrate__c = true;
			lstAccount[1].BillingStreet__c 				= 'xxx';
			lstAccount[1].BillingCity__c 					= 'yyy';
			lstAccount[1].BillingPostalCode__c 			= '123';
			lstAccount[1].BillingCountry__c 				= 'Germany';
			lstAccount[1].Phone 						= '4543333';
			lstAccount[1].Fax 							= '122333';
			lstAccount[1].ReferenceNumber__c 			= 'DE00000v1';

			lstAccount[2].CCUsername__c 				= 'NewCommunityUserCreationBodyShopv3@test.com';
			lstAccount[2].ContactEmail__c 				= 'NewCommunityUserCreationBodyShopv3@test.com';
			lstAccount[2].Locale__c 					= 'Spanish';
			lstAccount[2].Communities_Target_Profile__c = system.label.CommunitiesTargetProfile;
			lstAccount[2].CommunitiesBatchNewBtoMigrate__c = true;
			lstAccount[2].ShippingStreet 				= 'aaa';
			lstAccount[2].ShippingCity 					= 'bbb';
			lstAccount[2].ShippingPostalCode 			= '456';
			lstAccount[2].ShippingCountry 				= 'Spain';
			lstAccount[2].Phone 						= '4543333';
			lstAccount[2].Fax 							= '122333';
			lstAccount[2].ReferenceNumber__c 			= 'ES00000v2';

			lstAccount[3].CCUsername__c 				= 'NewCommunityUserCreationBodyShopv4@test.com';
			lstAccount[3].ContactEmail__c 				= 'NewCommunityUserCreationBodyShopv4@test.com';
			lstAccount[3].Locale__c 					= 'FrenchBelgium';
			lstAccount[3].Communities_Target_Profile__c = system.label.CommunitiesTargetProfile;
			lstAccount[3].CommunitiesBatchNewBtoMigrate__c = true;

			lstAccount[4].CCUsername__c 				= 'NewCommunityUserCreationBodyShopv5@test.com';
			lstAccount[4].ContactEmail__c 				= 'NewCommunityUserCreationBodyShopv5@test.com';
			lstAccount[4].Locale__c 					= 'DutchBelgium';
			lstAccount[4].Communities_Target_Profile__c = system.label.CommunitiesTargetProfile;
			lstAccount[4].CommunitiesBatchNewBtoMigrate__c = true;

			insert lstAccount;

			//creating contact
			lstContact 									= new List <Contact>{new Contact(AccountId = lstAccount[0].Id,
																						 LastName = 'BodyShopv1'),
																				new Contact(AccountId = lstAccount[1].Id,
																						    LastName = 'BodyShopv2'),
																				new Contact(AccountId = lstAccount[2].Id,
																						    LastName = 'BodyShopv3'),
																				new Contact(AccountId = lstAccount[3].Id,
																						    LastName = 'BodyShopv4'),
																				new Contact(AccountId = lstAccount[4].Id,
																						    LastName = 'BodyShopv5')};

			insert lstContact;

			string BypassTrigger 						= 'AccountTrigger;AssessmentTrigger;CaseTriggerHandler;DetailRuleTrigger;' 
														+ 'DiscountTrigger;InvoiceTrigger;MasterRuleTrigger;OfferTrigger;'
														+ 'OrderLineTrigger;PrerequisiteOrderTrigger;PurchaseOrderTrigger;'
														+ 'UserTrigger';
			//inserting bypass
			Bypass__c customSetting 					= new Bypass__c(Name = 'testBypass',
															            SetupOwnerId = userList[0].Id,
															            BypassValidationRules__c = true,
															            BypassWorkflows__c = true,
															            BypassTrigger__c = BypassTrigger);

            Database.upsert(customSetting, Bypass__c.Name.getDescribe().getSObjectField(), false);
		}//end system.runAs
	}//end static

	@isTest static void NewCommunityUserCreationTest(){
		system.runAs(userList[0]){

			set <id> setContactId					= new set <id>();

			//build setContactId
			for(Contact con : [select Id
								from Contact
								where id IN : lstContact]){
				setContactId.add(con.Id);
			}

			//start test
			Test.startTest();
				AspisBatch_NewCommunityUserCreation batch = new AspisBatch_NewCommunityUserCreation(setContactId);
				Database.executeBatch(batch);
			Test.stopTest();

			//assert
			List<Contact> lstContact = [SELECT id FROM Contact WHERE AccountId IN :lstAccount];
			System.assertEquals(5,lstContact.size());
		}
	}
    
    
    
}