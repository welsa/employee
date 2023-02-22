@isTest
private class ASPISChatterPage_TEST{
/*
----------------------------------------------------------------------
-- - Name          : ASPISChatterPage_TEST
-- - Author        : AMI
-- - Description   : TEST class for ASPISChatterPage
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
	static list<Case__c> l_cases;

	static{
		//initialising user
		userList = new list <User>{TestFactory.createUser('adminUserCaseDetail')};

		//query userrole
		id userRole = [Select Id From UserRole Where Name = :system.label.AlphaScaleRole Limit 1].Id;

		userList[0].UserRoleId  = userRole;
		insert userList;

		system.runAs(userList[0]){
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

			//create cases
			l_cases = new list <Case__c>{TestFactory.createCase('testcase1',3, userList[0]),
										 TestFactory.createCase('testcase2',3, userList[0]),
										 TestFactory.createCase('testcase3',3, userList[0])};

			l_cases[0].Tech_BSAccount__c = customerAcc.Id;
			l_cases[0].CountryCode__c = 'ES';
			l_cases[1].Tech_BSAccount__c = customerAcc.Id;
			l_cases[1].CountryCode__c = 'ES';
			l_cases[2].Tech_BSAccount__c = customerAcc.Id;
			l_cases[2].CountryCode__c = 'ES';

			insert l_cases;
		}//end system.runAs
	}//end static

	@isTest
	static void testConstructorNotHomePage(){
		system.debug('## Start testConstructorNotHomePage');
		
		system.runAs(portalUser){
			Test.startTest();

			//encrypt bs id
			string csid = ASPISMyCaseDetail.encryptBase64(string.valueOf(l_cases[0].Id));

			//set current page
			PageReference myVfPage = Page.ASPISChatterPage;
			Test.setCurrentPage(myVfPage);

			// Put Id into the current page Parameters
			ApexPages.currentPage().getParameters().put('id',csid);

			ASPISChatterPage constructor = new ASPISChatterPage();

			Test.stopTest();
		}
		system.debug('## End testConstructorNotHomePage');
	}

	@isTest
	static void testConstructorHomePage(){
		system.debug('## Start testConstructorHomePage');
		
		system.runAs(portalUser){
			Test.startTest();

			//encrypt bs id
			string csid = ASPISMyCaseDetail.encryptBase64(string.valueOf(l_cases[0].Id));

			//set current page
			PageReference myVfPage = Page.ASPISChatterPage;
			Test.setCurrentPage(myVfPage);

			// Put Id into the current page Parameters
			ApexPages.currentPage().getParameters().put('id',csid);
			ApexPages.currentPage().getParameters().put('homepage','1');

			ASPISChatterPage constructor = new ASPISChatterPage();

			Test.stopTest();
		}
		system.debug('## End testConstructorHomePage');
	}
}