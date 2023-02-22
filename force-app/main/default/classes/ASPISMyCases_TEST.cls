@isTest
private class ASPISMyCases_TEST{
/*
----------------------------------------------------------------------
-- - Name          : ASPISMyCases_TEST
-- - Author        : AMI
-- - Description   : TEST class for ASPISMyCases
--
-- Maintenance History:
--
-- Date         Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 07-FEB-2019  AMI   1.0        Initial version
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
		userList = new list <User>{TestFactory.createUser('adminUser')};

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
										Email = 'test@yahoo.com');

			insert customerCon;

			//create portal user
			portalUser = new User(profileId = system.label.CommunitiesTargetProfile.split(';')[1],
									username = 'test@1yahoo.com',
									CommunityNickname = 'test@2yahoo.com',
									email = 'test@yahoo.com',
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
			l_cases[1].Tech_BSAccount__c = customerAcc.Id;
			l_cases[2].Tech_BSAccount__c = customerAcc.Id;

			insert l_cases;
		}//end system.runAs
	}//end static

	@isTest
	static void testConstructorSuccess(){
		system.debug('## Start testConstructorSuccess');
		
		system.runAs(portalUser){
			Test.startTest();

			//encrypt bs id
			string bsid = ASPISMyCases.encryptBase64(string.valueOf(portalUser.id));

			//set current page
			PageReference myVfPage = Page.ASPISMyCases;
			Test.setCurrentPage(myVfPage);

			// Put Id into the current page Parameters
			ApexPages.currentPage().getParameters().put('id',bsid);

			ASPISMyCases constructor = new ASPISMyCases();

			Test.stopTest();
		}
		system.debug('## End testConstructorSuccess');
	}

	@isTest
	static void testConstructorError(){
		system.debug('## Start testConstructorError');
		
		system.runAs(portalUser){
			Test.startTest();

			//set current page
			PageReference myVfPage = Page.ASPISMyCases;
			Test.setCurrentPage(myVfPage);

			// Put Id into the current page Parameters
			ApexPages.currentPage().getParameters().put('id','xxxxxxxxx');

			ASPISMyCases constructor = new ASPISMyCases();

			Test.stopTest();
		}
		system.debug('## End testConstructorError');
	}

	@isTest
	static void testSearchCases(){
		system.debug('## Start testSearchCases');
		
		system.runAs(portalUser){
			Test.startTest();

			 string errMsg = ASPISMyCases.searchCases(
			 	string.valueOf(
			 		(date.newinstance(date.today().year(),date.today().month(),(date.today().addDays(-1)).day())).format()
			 		),
			 	string.valueOf(
			 		(date.newinstance(date.today().year(),date.today().month(),(date.today().addDays(7)).day())).format()
			 		),
			 	true,
			 	false).errorMsg;

			 	system.assertEquals('',errMsg);
			Test.stopTest();
		}
		system.debug('## End testSearchCases');
	}
}