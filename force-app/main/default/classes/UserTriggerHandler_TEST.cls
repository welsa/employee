/*
  ----------------------------------------------------------------------
  -- - Name          : UserTriggerHandler_TEST
  -- - Author        : ABT
  -- - Description   : Test class for UserTriggerHandler
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-SEP-2016  ABT    1.0     Initial Version
  -- 09-FEB-2021  WCH    1.1     Increase code coverage
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class UserTriggerHandler_TEST
{
	static User adminUser;
	static User aspisLocalAdminUser;
	static List<User> userList;
	static User CCBodyShopUser;
	static User CCBodyShopOrderUser;
	static Map <String,Id> profileNameMapId;
	static list<Contact> contacts;
	static list<Account> accounts;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		adminUser.UserRoleId    = [select id from UserRole where name='Alpha Scale'].Id;
		insert adminUser;
		System.runAs(adminUser)
		{
			aspisLocalAdminUser=TestFactory.createUserASPISLocal('cardoso');

			UserRole ur =[SELECT Id FROM UserRole WHERE DeveloperName = 'AlphaScale'];
			String paintingPermissionSetCC='';
			for(Schema.PicklistEntry thePM : Account.Permission_Sets__c.getDescribe().getPicklistValues()){
				if(thePM.getLabel().equals('CC Painting')){
					paintingPermissionSetCC=thePM.getValue();
				}
			}

			accounts = new list<Account>();
			Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');        
			bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
			bs1.BillingCity__c = 'Paris';
			bs1.ContactEmail__c = 'test@example.com';
			bs1.BillingStreet__c = '123 rose';
			bs1.BillingPostalCode__c = '12345';
			bs1.BillingCountryCode__c = 'FR';
			bs1.BillingCountry__c = 'France';
			bs1.isEligibleSubstitution__c = true;
			bs1.ExpertSubstitutionMethod__c='FORCED';
			bs1.Permission_Sets__c=paintingPermissionSetCC;
			bs1.ownerId=adminUser.Id;
			accounts.add(bs1);

			insert accounts;

			//create contact
			contacts = new list<Contact>();
			Contact con1 = new Contact (AccountId = accounts[0].Id, LastName = 'testcontact1');
			Contact con2 = new Contact (AccountId = accounts[0].Id, LastName = 'testcontact2');
			contacts.add(con1);
			contacts.add(con2);
			insert contacts;

			profileNameMapId=new Map<String,Id>();
			for(Profile theProfile : [select Id,Name from Profile where Name =: label.R3BSProfileNameCommunity or Name = : label.R4BSProfileNameCommunity]){
				profileNameMapId.put(theProfile.Name,theProfile.Id);
			}

			// Disactivating any 4 user having Force.com Subscription
			List<UserLicense> userLiscenseList = [	SELECT 	Id, LicenseDefinitionKey 
													FROM 	UserLicense
													WHERE 	LicenseDefinitionKey = 'FDC_SUB'];

			if(userLiscenseList.size() > 0)
			{
				List<User> userToDisactivate = new List<User>();

				for(User currentUser : [SELECT 	Id, UserType, Profile.UserLicenseId, ProfileId 
										FROM 	User
										WHERE	IsActive = true
										AND		Profile.UserLicenseId =: userLiscenseList[0].Id
										AND		UserType = 'Standard'
										LIMIT 	4])
				{
					currentUser.IsActive = false;
					userToDisactivate.add(currentUser);
				}

				if(userToDisactivate.size() > 0)
				{
					update userToDisactivate;
				}
			}

			userList = new List<User>
			{
				TestFactory.createUserBodyshop('BodyShopUser_1'),
				TestFactory.createUserBodyshop('BodyShopUser_2'),

				TestFactory.createUserDistributor('DistributorUser_1'),
				TestFactory.createUserDistributor('DistributorUser_2')
			};

			userList[0].BodyShopID__c		= '111111';
			userList[1].BodyShopID__c		= '111111';
			
			userList[2].DistributorID__c	= '222222';
			userList[3].DistributorID__c	= '222222';

			userList[0].IsActive			= false;
			userList[1].IsActive			= false;
			userList[2].IsActive			= false;
			userList[3].IsActive			= false;

			insert userList;

			CCBodyShopUser = TestFactory.createUser('BS1');
			CCBodyShopUser.Username  = 'aspisforgetpwdCCBD@test.com';
			CCBodyShopUser.EmailEncodingKey = 'ISO-8859-1';
			CCBodyShopUser.CommunityNickname = 'testUser1232';
			CCBodyShopUser.IsActive = true;
			CCBodyShopUser.LanguageLocaleKey = 'fr';
			CCBodyShopUser.LocaleSidKey= 'fr_FR';

			CCBodyShopOrderUser = TestFactory.createUser('BS2');
			CCBodyShopOrderUser.Username  = 'aspisforgetpwdCCBDORD@test.com';
			CCBodyShopOrderUser.EmailEncodingKey = 'ISO-8859-1';
			CCBodyShopOrderUser.CommunityNickname = 'testUser1231';
			CCBodyShopOrderUser.IsActive = true;
			CCBodyShopOrderUser.LanguageLocaleKey = 'fr';
			CCBodyShopOrderUser.LocaleSidKey= 'fr_FR';
		}
	}

	@isTest static void insertUsers_TEST()
	{
		System.runAs(adminUser)
		{	
			CCBodyShopUser.ContactId=contacts[0].Id;
			CCBodyShopUser.ProfileId=profileNameMapId.get(label.R3BSProfileNameCommunity);

			List<User> usersToInsertList = new List<User>
			{
				TestFactory.createUserBodyshop('BodyShopUser_1'),
				TestFactory.createUserBodyshop('BodyShopUser_2'),

				TestFactory.createUserDistributor('DistributorUser_1'),
				TestFactory.createUserDistributor('DistributorUser_2'),
				CCBodyShopOrderUser,
				CCBodyShopUser
			};

			usersToInsertList[0].BodyShopID__c		= '000001';
			usersToInsertList[1].BodyShopID__c		= '000001';

			usersToInsertList[2].DistributorID__c	= '000002';
			usersToInsertList[3].DistributorID__c	= '000002';

			Test.startTest();
				insert usersToInsertList;
			Test.stopTest();

			// If the users were successfully inserted then they should be in a group.
			List<GroupMember> groupMemberList = [SELECT Id, UserOrGroupId, GroupId
												 FROM	GroupMember
												 WHERE	UserOrGroupId IN: usersToInsertList
												 AND	Group.Name IN ('000001', '000002')];

			System.assertEquals(4, groupMemberList.size());
		}
	}

	@isTest static void updateUsers_TEST()
	{
		System.runAs(adminUser)
		{
			userList[0].IsActive = true;
			userList[1].IsActive = true;
			userList[2].IsActive = true;
			userList[3].IsActive = true;

			Test.startTest();
				update userList;
			Test.stopTest();

			// Because there is a job that would be enqueued. The goup members would not be updated yet
			List<GroupMember> groupMemberList = [SELECT Id, UserOrGroupId, GroupId
												 FROM	GroupMember
												 WHERE	UserOrGroupId IN: userList
												 AND	Group.Name IN ('111111', '222222')];

			System.assertEquals(0, groupMemberList.size());
		}
	}

	// @isTest static void updateUsersBodyShop_TEST()
	// {
	// 	System.runAs(adminUser)
	// 	{
	// 		userList[0].IsActive = true;
	// 		userList[1].IsActive = true;

	// 		Test.startTest();
	// 			update userList;
	// 		Test.stopTest();

	// 		// Because there is a job that would be enqueued. The goup members would not be updated yet
	// 		List<GroupMember> groupMemberList = [SELECT Id, UserOrGroupId, GroupId
	// 											 FROM	GroupMember
	// 											 WHERE	UserOrGroupId IN: userList
	// 											 AND	Group.Name IN ('111111')];

	// 		System.assertEquals(0, groupMemberList.size());
	// 	}
	// }

	// @isTest static void updateUsersDistributor_TEST()
	// {
	// 	System.runAs(adminUser)
	// 	{
	// 		userList[2].IsActive = true;
	// 		userList[3].IsActive = true;

	// 		Test.startTest();
	// 			update userList;
	// 		Test.stopTest();

	// 		// Because there is a job that would be enqueued. The goup members would not be updated yet
	// 		List<GroupMember> groupMemberList = [SELECT Id, UserOrGroupId, GroupId
	// 											 FROM	GroupMember
	// 											 WHERE	UserOrGroupId IN: userList
	// 											 AND	Group.Name IN ('222222')];

	// 		System.assertEquals(0, groupMemberList.size());
	// 	}
	// }
}