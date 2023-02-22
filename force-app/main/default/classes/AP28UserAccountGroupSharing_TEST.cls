/*
  ----------------------------------------------------------------------
  -- - Name          : AP28UserAccountGroupSharing_TEST 
  -- - Author        : ABT 
  -- - Description   : Test class for the class AP28UserAccountGroupSharing
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 11-APR-2016  ABT    1.0     Initial Version
  -- 08-FEB-2021  WCH    1.1     impact nobilas
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class AP28UserAccountGroupSharing_TEST 
{
	static List<User> users;
	static List<Account> accList;
	static List<Group> groupList;
	static User thisUser;

	static{
		thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	System.runAs ( thisUser ) {
			users = new List<User>();
			users.add( TestFactory.createUser('adminUser'));

			insert users;
		}

		System.runAs(users[0])
		{
			// Generating the account
			accList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR')
			};

			insert accList;

			groupList = new List<Group>
			{
				new Group( Name = 'FR1234567890')
			};

			insert groupList;
		}
	}

	@isTest static void testInsertionOfUser()
	{
		// test method to test sharing when a new user is inserted
		// the bodyshop id or distributor id does not have a corresponding account
		// that is the reference number is not present in any account

		System.runAs(users[0])
		{
			// creation of new user
			List<User> newUsers = new List<User>
			{
				TestFactory.createUser('adminUserWithBodyShopId'),
				TestFactory.createUserASPISLocal('aspisLocalWithDistributorId'),
				TestFactory.createUserBodyshop('bodyShopUserWithBodyShopId'),
				TestFactory.createUser('adminUserWithSameBodyShopIdAsAnotherUser')
			};

			newUsers[0].BodyShopID__c	 = '0000001';
			newUsers[1].DistributorID__c = '0000002';
			newUsers[2].BodyShopID__c	 = '0000003';
			newUsers[3].BodyShopID__c	 = '0000001';

			// Adding to the list the ref numbers as if select is made 
			// without any condition it will also take the group of the user 
			// if the user running the test class has a ref number.
			List<String> refNumbers = new List<String>();
			for(User u : newUsers)
			{
				if(u.BodyShopID__c != null)
				{
					refNumbers.add(u.BodyShopID__c);
				}

				if(u.DistributorID__c != null)
				{
					refNumbers.add(u.DistributorID__c);
				}
			}

			Test.startTest();
				insert newUsers;
			Test.stopTest();

			List<Group> newlyInsertedGroups = [SELECT Id, Name, DeveloperName
											   FROM	  Group
											   WHERE  Name IN: refNumbers ];
			for (Group g : newlyInsertedGroups)
			{
				System.debug('## Dev Name: ' + g.DeveloperName);
			}

			System.assertEquals(3, newlyInsertedGroups.size());
		}
	}

	@isTest static void testInsertionOfUserWithExistingGroup()
	{
		// test method to test sharing when a new user is inserted
		// the bodyshop id or distributor id does not have a corresponding account
		// that is the reference number is not present in any account

		System.runAs(users[0])
		{
			// creation of new user
			List<User> newUsers = new List<User>
			{
				TestFactory.createUser('adminUserWithBodyShopId'),
				TestFactory.createUserASPISLocal('aspisLocalWithDistributorId'),
				TestFactory.createUserBodyshop('bodyShopUserWithBodyShopId'),
				TestFactory.createUser('adminUserWithSameBodyShopIdAsAnotherUser')
			};

			newUsers[0].BodyShopID__c	 = 'FR1234567890';
			newUsers[1].DistributorID__c = '123456789';
			newUsers[2].BodyShopID__c	 = 'FR1234567890';
			newUsers[3].BodyShopID__c	 = 'FR1234567890';

			// Adding to the list the ref numbers as if select is made 
			// without any condition it will also take the group of the user 
			// if the user running the test class has a ref number.
			List<String> refNumbers = new List<String>();
			for(User u : newUsers)
			{
				if(u.BodyShopID__c != null)
				{
					refNumbers.add(u.BodyShopID__c);
				}

				if(u.DistributorID__c != null)
				{
					refNumbers.add(u.DistributorID__c);
				}
			}

			Test.startTest();
				insert newUsers;
			Test.stopTest();

			List<Group> newlyInsertedGroups = [SELECT Id, Name
											   FROM	  Group
											   WHERE  Name = 'FR1234567890' ];

			System.assertEquals(1, newlyInsertedGroups.size());

			List<GroupMember> groupMemberList = [SELECT Id
												 FROM	GroupMember
												 WHERE  UserOrGroupId IN: newUsers];

			System.assertEquals(4, groupMemberList.size());
		}
	}

	@isTest static void testInsertionOfAccount()
	{
		// test method to test sharing when a new account is inserted
		// the reference number  does not have a corresponding user

		System.runAs(users[0])
		{
			// creation of new user
			List<Account> newAccounts = new List<Account>
			{
				TestFactory.createAccountBodyshop('bodyShopWithRefNumber', 'FR'),
				TestFactory.createAccountDistributor('distributorWithRefNumber', 'FR'),
				TestFactory.createAccountBodyshop('bodyShopWithRefNumber1', 'FR'),
				TestFactory.createAccountDistributor('distributorWithRefNumber2', 'FR')
			};



			List<String> refNumbers = new List<String>();
			for(Account a : newAccounts)
			{
				refNumbers.add(a.ReferenceNumber__c);
			}

			Test.startTest();
				insert newAccounts;
			Test.stopTest();

			List<Group> newlyInsertedGroups = [SELECT Id, Name
											   FROM	  Group
											   WHERE  Name IN: refNumbers ];

			System.assertEquals(4, newlyInsertedGroups.size());

			List<AccountShare> accountShareList = [SELECT Id
												   FROM	AccountShare
												   WHERE AccountId IN: newAccounts
												   AND  UserOrGroupId IN: newlyInsertedGroups];

			System.assertEquals(4, accountShareList.size());
		}
	}

	@isTest static void testInsertionOfAccountWithExistingGroup()
	{
		// test method to test sharing when a new account is inserted
		// the reference number does not have a corresponding user

		// Cannot have duplicate reference number

		System.runAs(users[0])
		{
			// creation of new account
			List<Account> newAccounts = new List<Account>
			{
				TestFactory.createAccountBodyshop('bodyShopWithRefNumber', 'FR')
			};

			newAccounts[0].ReferenceNumber__c = 'FR1234567890';

			Set<String> refNumbers = new Set<String>();
			for(Account a : newAccounts)
			{
				refNumbers.add(a.ReferenceNumber__c);
			}

			Test.startTest();
				insert newAccounts;
			Test.stopTest();

			List<Group> newlyInsertedGroups = [SELECT Id, Name
											   FROM	  Group
											   WHERE  Name IN: refNumbers ];

			System.assertEquals(1, newlyInsertedGroups.size());

			List<AccountShare> accountShareList = [SELECT Id
												   FROM	AccountShare
												   WHERE AccountId IN: newAccounts
												   AND  UserOrGroupId IN: newlyInsertedGroups];

			System.assertEquals(1, accountShareList.size());
		}
	}

	@isTest static void testInsertionOfAccountAfterUser()
	{
		// test method to test sharing when a new account is inserted
		// but a user having the reference number already exists

		// Cannot have duplicate reference number
		System.runAs(users[0])
		{
			// Insertion of user first
			List<User> newUsers = new List<User>
			{
				TestFactory.createUser('adminUserWithBodyShopId'),
				TestFactory.createUserASPISLocal('aspisLocalWithDistributorId'),
				TestFactory.createUserBodyshop('bodyShopUserWithBodyShopId'),
				TestFactory.createUser('adminUserWithSameBodyShopIdAsAnotherUser')
			};

			newUsers[0].BodyShopID__c	 = 'FR0000000001';//WCH 23/12/2020 C-004120
			newUsers[1].DistributorID__c = 'FR0000000002';//WCH 23/12/2020 C-004120
			newUsers[2].BodyShopID__c	 = '0000003';
			newUsers[3].BodyShopID__c	 = 'FR0000000001';//WCH 23/12/2020 C-004120

			insert newUsers;


			// creation of new account
			List<Account> newAccounts = new List<Account>
			{
				TestFactory.createAccountBodyshop('bodyShopWithRefNumber', 'FR'),
				TestFactory.createAccountDistributor('distributorWithRefNumber', 'FR')
			};

			newAccounts[0].ReferenceNumber__c = 'FR0000000001';//WCH 23/12/2020 C-004120
			newAccounts[1].ReferenceNumber__c = 'FR0000000002';//WCH 23/12/2020 C-004120

			Set<String> refNumbers = new Set<String>();
			for(Account a : newAccounts)
			{
				refNumbers.add(a.ReferenceNumber__c);
			}

			Test.startTest();
				insert newAccounts;
			Test.stopTest();

			List<Group> newlyInsertedGroups = [SELECT Id, Name
											   FROM	  Group
											   WHERE  Name IN: refNumbers ];

			System.assertEquals(2, newlyInsertedGroups.size());

			List<AccountShare> accountShareList = [SELECT Id
												   FROM	AccountShare
												   WHERE AccountId IN: newAccounts
												   AND  UserOrGroupId IN: newlyInsertedGroups];

			System.assertEquals(2, accountShareList.size());

			List<GroupMember> groupMemberList = [SELECT Id
												 FROM   GroupMember
												 WHERE  UserOrGroupId IN: newUsers];

			System.assertEquals(4, groupMemberList.size());
		}
	}

	@isTest static void testInsertionOfUserAfterAccount()
	{
		// test method to test sharing when a new account is inserted
		// but a user having the reference number already exists

		// Cannot have duplicate reference number

		System.runAs(users[0])
		{
			// Account already exists

			// Insertion of user first
			List<User> newUsers = new List<User>
			{
				TestFactory.createUser('adminUserWithBodyShopId'),
				TestFactory.createUserASPISLocal('aspisLocalWithDistributorId'),
				TestFactory.createUserBodyshop('bodyShopUserWithBodyShopId'),
				TestFactory.createUser('adminUserWithSameBodyShopIdAsAnotherUser')
			};

			newUsers[0].BodyShopID__c	 = accList[0].ReferenceNumber__c;
			newUsers[1].DistributorID__c = accList[1].ReferenceNumber__c;
			newUsers[2].BodyShopID__c	 = accList[0].ReferenceNumber__c;
			newUsers[3].BodyShopID__c	 = accList[0].ReferenceNumber__c;

			List<String> refNumbers = new List<String>();
			for(User u : newUsers)
			{
				if(u.BodyShopID__c != null)
				{
					refNumbers.add(u.BodyShopID__c);
				}

				if(u.DistributorID__c != null)
				{
					refNumbers.add(u.DistributorID__c);
				}
			}
			Test.startTest();
				insert newUsers;
			Test.stopTest();

			List<Group> newlyInsertedGroups = [SELECT Id, Name
											   FROM	  Group
											   WHERE  Name IN: refNumbers ];

			System.assertEquals(2, newlyInsertedGroups.size());

			List<AccountShare> accountShareList = [SELECT Id
												   FROM	AccountShare
												   WHERE AccountId IN: accList
												   AND  UserOrGroupId IN: newlyInsertedGroups];

			System.assertEquals(2, accountShareList.size());

			List<GroupMember> groupMemberList = [SELECT Id
												 FROM   GroupMember
												 WHERE  UserOrGroupId IN: newUsers];

			System.assertEquals(4, groupMemberList.size());
		}
	}

	@isTest static void testUpdateUser()
	{
		System.runAs(users[0])
		{
			// Insertion of user first
			List<User> newUsers = new List<User>
			{
				TestFactory.createUser('adminUserWithBodyShopId'),
				TestFactory.createUserASPISLocal('aspisLocalWithDistributorId'),
				TestFactory.createUserBodyshop('bodyShopUserWithBodyShopId'),
				TestFactory.createUser('adminUserWithSameBodyShopIdAsAnotherUser'),
				TestFactory.createUserASPISLocal('aspisLocalWithSameDistributorIdAsAnotherUser')
			};

			newUsers[0].BodyShopID__c	 = accList[0].ReferenceNumber__c;
			newUsers[1].DistributorID__c = accList[1].ReferenceNumber__c;
			newUsers[2].BodyShopID__c	 = accList[0].ReferenceNumber__c;
			newUsers[3].BodyShopID__c	 = accList[0].ReferenceNumber__c;
			newUsers[4].DistributorID__c = accList[1].ReferenceNumber__c;

			// Start test and stop test on insert instead on update as @future method does not run
			// when the start test and stop test is on the update
			Test.startTest();
				insert newUsers;
			Test.stopTest();

			List<GroupMember> groupMemberList = [SELECT Id
												 FROM   GroupMember
												 WHERE  UserOrGroupId IN: newUsers];

			System.assertEquals(5, groupMemberList.size());

			// Inverting the reference number
			newUsers[0].BodyShopID__c	 = accList[1].ReferenceNumber__c;
			newUsers[1].DistributorID__c = accList[0].ReferenceNumber__c;
			newUsers[2].BodyShopID__c	 = accList[1].ReferenceNumber__c;
			newUsers[3].IsActive		 = false;
			newUsers[4].DistributorID__c = accList[0].ReferenceNumber__c;

			update newUsers;
			
			List<GroupMember> updatedGroupMemberList = [SELECT Id
														FROM   GroupMember
														WHERE  UserOrGroupId IN: newUsers];

			// the enqueued job will not run
			// so AP28 will delete the old group members and enqueue the job to call the function
			// shareUsers
			System.assertEquals(0, updatedGroupMemberList.size());
		}
	}

	@isTest static void testInsertionOfUserWithRole()
	{
		// test method to test sharing when a new user is inserted
		// the bodyshop id or distributor id does not have a corresponding account
		// that is the reference number is not present in any account

		System.runAs(users[0])
		{
			// Getting the roles
			Id spainRoleId = [SELECT Id 
							  FROM UserRole 
							  WHERE Name LIKE 'ES%'
							  LIMIT 1].Id;

			Id franceRoleId = [SELECT Id 
							   FROM UserRole 
							   WHERE Name LIKE 'FR%'
							   LIMIT 1].Id;
			// creation of new user
			List<User> newUsers = new List<User>
			{
				TestFactory.createUser('adminUserWithBodyShopId'),
				TestFactory.createUserASPISLocal('aspisLocalWithDistributorId'),
				TestFactory.createUserBodyshop('bodyShopUserWithBodyShopId'),
				TestFactory.createUser('adminUserWithSameBodyShopIdAsAnotherUser')
			};

			newUsers[0].BodyShopID__c	 = '0000001';
			newUsers[1].DistributorID__c = '0000002';
			newUsers[2].BodyShopID__c	 = '0000003';
			newUsers[3].BodyShopID__c	 = '0000001';

			newUsers[0].UserRoleId		 = spainRoleId;
			newUsers[1].UserRoleId		 = spainRoleId;
			newUsers[2].UserRoleId		 = franceRoleId;
			newUsers[3].UserRoleId		 = franceRoleId;

			// Adding to the list the ref numbers as if select is made 
			// without any condition it will also take the group of the user 
			// if the user running the test class has a ref number.
			List<String> refNumbers = new List<String>();
			for(User u : newUsers)
			{
				if(u.BodyShopID__c != null)
				{
					refNumbers.add(u.BodyShopID__c);
				}

				if(u.DistributorID__c != null)
				{
					refNumbers.add(u.DistributorID__c);
				}
			}

			Test.startTest();
				insert newUsers;
			Test.stopTest();

			List<Group> spainGroup = new List<Group>(); 
			List<Group> franceGroup = new List<Group>(); 

			for (Group g : [SELECT Id, Name, DeveloperName
							FROM   Group
							WHERE  Name IN: refNumbers ])
			{
				if (g.DeveloperName.startsWith('ES'))
				{
					spainGroup.add(g);
				}

				if (g.DeveloperName.startsWith('FR'))
				{
					franceGroup.add(g);
				}
			}

			System.assertEquals(1, spainGroup.size());
			System.assertEquals(2, franceGroup.size());
		}
	}
}