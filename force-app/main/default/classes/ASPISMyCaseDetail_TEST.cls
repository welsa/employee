@isTest
private class ASPISMyCaseDetail_TEST{
/*
----------------------------------------------------------------------
-- - Name          : ASPISMyCaseDetail_TEST
-- - Author        : AMI
-- - Description   : TEST class for ASPISMyCaseDetail
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
	static CountryCodeInformationsMapping__c countryMap;
	static BusinessHours defaultHours;
	static list <Attachment> attList;

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

			//create attachement
			attList = new list <Attachment>{new Attachment(Name = 'test att one',
															 Description = 'test desc 1',
															 ParentId = l_cases[1].Id,
															 Body = Blob.valueOf('Unit Test Attachment Body 1')),
											new Attachment(Name = 'test att two',
															 Description = 'test desc 2',
															 ParentId = l_cases[2].Id,
															 Body = Blob.valueOf('Unit Test Attachment Body 2'))};

			insert attList;
		}//end system.runAs
	}//end static

	@isTest
	static void testConstructorSuccess(){
		system.debug('## Start testConstructorSuccess');
		
		system.runAs(portalUser){
			Test.startTest();

			//encrypt bs id
			string csid = ASPISMyCaseDetail.encryptBase64(string.valueOf(l_cases[0].Id));

			//set current page
			PageReference myVfPage = Page.ASPISMyCaseDetail;
			Test.setCurrentPage(myVfPage);

			// Put Id into the current page Parameters
			ApexPages.currentPage().getParameters().put('id',csid);

			ASPISMyCaseDetail constructor = new ASPISMyCaseDetail();

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
			PageReference myVfPage = Page.ASPISMyCaseDetail;
			Test.setCurrentPage(myVfPage);

			// Put Id into the current page Parameters
			ApexPages.currentPage().getParameters().put('id','xxxxxxxxx');

			ASPISMyCaseDetail constructor = new ASPISMyCaseDetail();

			Test.stopTest();
		}
		system.debug('## End testConstructorError');
	}

	@isTest
	static void testUpdateCase(){
		system.debug('## Start testUpdateCase');
		
		system.runAs(portalUser){
			Test.startTest();
				l_cases[1].Comment__c = 'test one 1';

				string err = ASPISMyCaseDetail.updateCase(new list <Case__c>{l_cases[1]});

				system.assertEquals('',err);
			Test.stopTest();
		}
		system.debug('## End testUpdateCase');
	}

	@isTest
	static void testRetrieveAtt(){
		system.debug('## Start testRetrieveAtt');
		
		system.runAs(portalUser){
			Test.startTest();
				list <Attachment> attList = ASPISMyCaseDetail.retrieveAtt(l_cases[1].Id);

				system.assertEquals(1,attList.size());
			Test.stopTest();
		}
		system.debug('## End testRetrieveAtt');
	}

	@isTest
	static void testDeleteAtt(){
		system.debug('## Start testDeleteAtt');
		
		system.runAs(portalUser){
			Test.startTest();

				/*id attId = [select id from Attachment where parentId = :l_cases[1].Id].Id;*/
				list <Attachment> attList = ASPISMyCaseDetail.retrieveAtt(l_cases[2].Id);
				ASPISMyCaseDetail.deleteAtt(string.valueOf(attList[0].Id));

				system.assertEquals(0,[select id from Attachment where parentId = :l_cases[2].Id].size());
			Test.stopTest();
		}
		system.debug('## End testDeleteAtt');
	}
}