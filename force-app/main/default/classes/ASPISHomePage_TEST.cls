@isTest
private class ASPISHomePage_TEST{
/*
----------------------------------------------------------------------
-- - Name          : ASPISHomePage_TEST
-- - Author        : AMI
-- - Description   : TEST class for ASPISHomePage
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
			countryMap.DisplayFeedSize__c = 9.0;

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
									contactId = customerCon.id,
									CountryCode = 'ES');

			insert portalUser;
		}//end system.runAs
	}//end static

	@isTest
	static void testConstructorWithCountryCodeMapping(){
		system.debug('## Start testConstructorWithCountryCodeMapping');
		
		system.runAs(portalUser){
			Test.startTest();

			insert countryMap;

			ASPISHomePage constructor = new ASPISHomePage();

			Test.stopTest();
		}
		system.debug('## End testConstructorWithCountryCodeMapping');
	}

	@isTest
	static void testConstructorWOCountryCodeMapping(){
		system.debug('## Start testConstructorWOCountryCodeMapping');
		
		system.runAs(portalUser){
			Test.startTest();

			ASPISHomePage constructor = new ASPISHomePage();

			Test.stopTest();
		}
		system.debug('## End testConstructorWOCountryCodeMapping');
	}
}