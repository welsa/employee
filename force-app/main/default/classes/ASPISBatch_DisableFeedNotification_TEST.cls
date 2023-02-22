@isTest
private class ASPISBatch_DisableFeedNotification_TEST{
/* 
--------------------------------------------------------------------------------------
-- - Name          : ASPISBatch_DisableFeedNotification_TEST
-- - Author        : AMI 
-- - Description   : Test Class for ASPISBatch_DisableFeedNotification
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 12-FEB-2019  AMI   1.0      Initial version
--------------------------------------------------------------------------------------
*/
	static list <user> userList;
	static list <user> portalUserList;
	static list <account> accList;
	static list <contact> conList;
	static CountryCodeInformationsMapping__c countryMap;
	static BusinessHours defaultHours;
	static list <PermissionSetAssignment> permissionSetAssigment;

	static{
		//initialising user
		userList = new list <User>{TestFactory.createUser('adminUserCaseDetail')};

		//query userrole
		id userRole = [Select Id From UserRole Where Name = :system.label.AlphaScaleRole Limit 1].Id;

		userList[0].UserRoleId  = userRole;
		insert userList;

		system.runAs(userList[0]){
			//query bs hours
			defaultHours = [select Id from BusinessHours where IsDefault=true];

			//insert cs
			countryMap = TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id);
			countryMap.EnableChatterFeed__c = true;

			//creating account list
			accList = new list <account>{TestFactory.createAccountBodyshop('testuseraccv1', 'ES'),
										 TestFactory.createAccountBodyshop('testuseraccv2', 'ES'),
										 TestFactory.createAccountBodyshop('testuseraccv3', 'ES')};

			insert accList;

			//creating contact list
            conList = new list <contact>{new Contact(AccountId = accList[0].Id,
													LastName = 'test1',
													Email = 'disableFeed1@yahoo.com'),
									        new Contact(AccountId = accList[1].Id,
														LastName = 'test2',
														Email = 'disableFeed2@yahoo.com'),
										    new Contact(AccountId = accList[2].Id,
														LastName = 'test2',
														Email = 'disableFeed2@yahoo.com')};

			insert conList;

			//creating portal user
			portalUserList = new list <user>{new User(profileId = system.label.CommunitiesTargetProfile.split(';')[1],
														username = 'disableFeed1@1yahoo.com',
														CommunityNickname = 'disableFeed1@2yahoo.com',
														email = 'disableFeed1@yahoo.com',
														emailencodingkey = 'UTF-8',
														localesidkey = 'en_US',
														languagelocalekey = 'en_US',
														timezonesidkey = 'America/Los_Angeles',
														alias='nuser',
														lastname='test1',
														contactId = conList[0].id,
														CountryCode = 'ES'),
												new User(profileId = system.label.CommunitiesTargetProfile.split(';')[1],
														username = 'disableFeed2@1yahoo.com',
														CommunityNickname = 'disableFeed2@2yahoo.com',
														email = 'disableFeed2@yahoo.com',
														emailencodingkey = 'UTF-8',
														localesidkey = 'en_US',
														languagelocalekey = 'en_US',
														timezonesidkey = 'America/Los_Angeles',
														alias='nuser',
														lastname='test2',
														contactId = conList[1].id,
														CountryCode = 'ES'),
												new User(profileId = system.label.CommunitiesTargetProfile.split(';')[1],
															username = 'disableFeed3@1yahoo.com',
															CommunityNickname = 'disableFeed3@2yahoo.com',
															email = 'disableFeed3@yahoo.com',
															emailencodingkey = 'UTF-8',
															localesidkey = 'en_US',
															languagelocalekey = 'en_US',
															timezonesidkey = 'America/Los_Angeles',
															alias='nuser',
															lastname='test3',
															contactId = conList[2].id,
															CountryCode = 'ES')};

			insert portalUserList;

			//querying permission set
			PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = :system.label.R4PermissionSetName];
			

			//assigning permission set
			permissionSetAssigment = new list <PermissionSetAssignment>{new PermissionSetAssignment(AssigneeId = portalUserList[0].id, 
																									PermissionSetId = ps.Id),
																		new PermissionSetAssignment(AssigneeId = portalUserList[1].id, 
																									PermissionSetId = ps.Id ),
																		new PermissionSetAssignment(AssigneeId = portalUserList[2].id, 
																									PermissionSetId = ps.Id )};

			insert permissionSetAssigment;
		}//end system.runAs
	}//end static

	@isTest
	static void testExecuteWithCountryCodeInfo(){
		system.debug('## Start testExecuteWithCountryCodeInfo');
		
		system.runAs(userList[0]){
			Test.startTest();
				insert countryMap;

				database.executeBatch(new ASPISBatch_DisableFeedNotification());
			Test.stopTest();
		}

		list <NetworkMember>  assertObj = [SELECT Id,MemberId,Member.Profile.Name,Member.CountryCode,NetworkId,Member.Name
											FROM NetworkMember
											WHERE MemberId IN :portalUserList
											and PreferencesDisableAllFeedsEmail = true];

		system.assertEquals(3,assertObj.size());

		system.debug('## End testExecuteWithCountryCodeInfo');
	}

	@isTest
	static void testExecuteWOCountryCodeInfo(){
		system.debug('## Start testExecuteWOCountryCodeInfo');
		
		system.runAs(userList[0]){
			Test.startTest();
				database.executeBatch(new ASPISBatch_DisableFeedNotification());
			Test.stopTest();

			list <NetworkMember>  assertObj = [SELECT Id,MemberId,Member.Profile.Name,Member.CountryCode,NetworkId,Member.Name
												FROM NetworkMember
												WHERE MemberId IN :portalUserList
												and PreferencesDisableAllFeedsEmail = true];

			system.assertEquals(0,assertObj.size());
		}

		system.debug('## End testExecuteWOCountryCodeInfo');
	}
}