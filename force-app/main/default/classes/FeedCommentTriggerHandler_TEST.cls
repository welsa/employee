@isTest
private class FeedCommentTriggerHandler_TEST{
/*
----------------------------------------------------------------------
-- - Name          : FeedCommentTriggerHandler_TEST
-- - Author        : AMI
-- - Description   : TEST class for FeedCommentTriggerHandler
--
-- Maintenance History:
--
-- Date         Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 11-FEB-2019  AMI   1.0        Initial version
----------------------------------------------------------------------
**********************************************************************
*/
	static list <user> userList;
	static user portalUser;
	static account customerAcc;
	static contact customerCon;
	static List<Assessment__c> l_Assessments;
	static List<PrerequisiteOrder__c> salesOrderList;
	static list<Case__c> l_cases;
	static CountryCodeInformationsMapping__c countryMap;
	static BusinessHours defaultHours;

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

			insert countryMap;

			//create new portal user account
			customerAcc = TestFactory.createAccountBodyshop('testuseraccount', 'ES');

			insert customerAcc;

			//create new portal user contact
			customerCon = new Contact(AccountId = customerAcc.Id,
										LastName = 'test',
										Email = 'CaseDetail@yahoo.com');

			insert customerCon;

			//create portal user
			portalUser = new User(profileId = system.label.CommunitiesTargetProfile.split(';')[1],
									username = 'CaseDetail@1yahoo.com',
									CommunityNickname = 'CaseDetail@2yahoo.com',
									email = 'CaseDetail@yahoo.com',
									emailencodingkey = 'UTF-8',
									localesidkey = 'en_US',
									languagelocalekey = 'en_US',
									timezonesidkey = 'America/Los_Angeles',
									alias='nuser',
									lastname='test',
									contactId = customerCon.id);

			insert portalUser;

			//create assessment
			l_Assessments = new list <Assessment__c>{TestFactory.createAssessment('ASSESS_TEST-0001', customerAcc)};

			insert l_Assessments;

			//create salesorder
			salesOrderList = new List<PrerequisiteOrder__c>{TestFactory.createSalesOrder(l_Assessments[0],customerAcc, ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)};

            insert salesOrderList;

			//create cases
			l_cases = new list <Case__c>{TestFactory.createCase('testcase1',3, userList[0]),
										 TestFactory.createCase('testcase2',3, userList[0]),
										 TestFactory.createCase('testcase3',3, userList[0])};

			l_cases[0].Tech_BSAccount__c = customerAcc.Id;
			l_cases[0].CountryCode__c = 'ES';
			l_cases[0].Assesment__c = l_Assessments[0].Id;

			l_cases[1].Tech_BSAccount__c = customerAcc.Id;
			l_cases[1].CountryCode__c = 'ES';
			l_cases[2].Tech_BSAccount__c = customerAcc.Id;
			l_cases[2].CountryCode__c = 'ES';

			insert l_cases;

			//updating account contact user
			customerAcc.ContactUser__c = portalUser.id;
			update customerAcc;
		}//end system.runAs
	}//end static

	@isTest
	static void testnotifyBSOnAss(){
		system.debug('## Start testnotifyBSOnAss');
		
		system.runAs(userList[0]){
			Test.startTest();
				FeedItem fdItem = new FeedItem(ParentId = l_Assessments[0].Id,
												Type = 'TextPost',
												Body = 'test msg one');

				insert fdItem;

				list <FeedComment> fcList = new list <FeedComment>{new FeedComment(FeedItemId  = fdItem.Id,
																					CommentBody = 'test comment one')};
				insert fcList;

				system.assertEquals(2,Limits.getEmailInvocations());
			Test.stopTest();
		}

		system.debug('## End testnotifyBSOnAss');
	}

	@isTest
	static void testnotifyBSOnSO(){
		system.debug('## Start testnotifyBSOnSO');
		
		system.runAs(userList[0]){
			Test.startTest();
				FeedItem fdItem = new FeedItem(ParentId = salesOrderList[0].Id,
												Type = 'TextPost',
												Body = 'test msg two');

				insert fdItem;

				list <FeedComment> fcList = new list <FeedComment>{new FeedComment(FeedItemId  = fdItem.Id,
																					CommentBody = 'test comment two')};
				insert fcList;

				system.assertEquals(2,Limits.getEmailInvocations());
			Test.stopTest();
		}

		system.debug('## End testnotifyBSOnSO');
	}

	@isTest
	static void testnotifyBSOnCase(){
		system.debug('## Start testnotifyBSOnCase');
		
		system.runAs(userList[0]){
			Test.startTest();
				FeedItem fdItem = new FeedItem(ParentId = l_cases[0].Id,
												Type = 'TextPost',
												Body = 'test msg three');

				insert fdItem;

				list <FeedComment> fcList = new list <FeedComment>{new FeedComment(FeedItemId  = fdItem.Id,
																					CommentBody = 'test comment three')};
				insert fcList;

				system.assertEquals(2,Limits.getEmailInvocations());
			Test.stopTest();
		}

		system.debug('## End testnotifyBSOnCase');
	}
}