/*
----------------------------------------------------------------------
-- - Name          : ASPISForgotPassword_TEST
-- - Author        : ABT
-- - Description   : Test class for ASPISForgotPassword
--
-- Maintenance History:
--
-- Date			Name  Version  Remarks
-- -----------	----  -------  ---------------------------------------
-- 24-JAN-2017	ABT		1.0    Initial version
-- 22-JAN-2019  WCH     1.1	   C-003021 : Users in R4 can not reset their password (Issue with community ?)
-- 24-AUG-2020  WCH     1.7    C-003838 - Nob - Migrate Billing information to new fields
-- 08-FEB-2021  WCH     1.8    C-004183 - 7 apex test classes failing when run all is done by prefikar user
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class ASPISForgotPassword_TEST 
{
	static User adminUser;
	static User CCBodyShopUser;
	static User CCBodyShopOrderUser;
	static Map <String,Id> profileNameMapId;
	static list<Contact> contacts;
	static list<Account> accounts;

	static
	{
		adminUser			= TestFactory.createUser('adminUser');
		adminUser.Username  = 'aspisforgetpwd@test.com';
		adminUser.UserRoleId    = [select id from UserRole where name='Alpha Scale'].Id;
		insert adminUser;

		UserRole ur =[SELECT Id FROM UserRole WHERE DeveloperName = 'AlphaScale'];
		String paintingPermissionSetCC='';
        for(Schema.PicklistEntry thePM : Account.Permission_Sets__c.getDescribe().getPicklistValues()){
            if(thePM.getLabel().equals('CC Painting')){
                paintingPermissionSetCC=thePM.getValue();
            }
        }
		System.runAs(adminUser)
		{
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
			
			CCBodyShopUser			 = TestFactory.createUser('BS1');
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

	@isTest static void constructor_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'fr');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'fr');

			Test.startTest();
				ASPISForgotPassword controller = new ASPISForgotPassword();
			Test.stopTest();

			System.assertEquals('fr', controller.language);
		}
	}
	//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
	@isTest static void constructorNoUser_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'fr');
			ASPISForgotPassword controller 	= new ASPISForgotPassword();
			controller.username 			= 'aspisforgetpwd111@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();
			PageReference expectedPageRef = new PageReference(system.label.CommunityDomain + '/secur/forgotpassword.jsp');
			expectedPageRef.getParameters().put('un', 'aspisforgetpwd111@test.com');
			expectedPageRef.getParameters().put('lang', 'fr');
            expectedPageRef.getParameters().put('locale', 'fr');
			System.assertEquals('https://'+expectedPageRef.getUrl(), currentPageRef.getUrl());

		}
	}
	//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
	@isTest static void constructorLangInexistant_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'europ');
			ASPISForgotPassword controller 	= new ASPISForgotPassword();
			controller.username 			= 'aspisforgetpwd111@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();
			
			System.assertEquals('fr', controller.language);
		}
	}
	//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
	@isTest static void constructorUserR3_TEST()
	{	
		System.runAs(adminUser)
		{	CCBodyShopUser.ContactId=contacts[0].Id;
			CCBodyShopUser.ProfileId=profileNameMapId.get(label.R3BSProfileNameCommunity);
			insert CCBodyShopUser;
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'fr');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'fr');
			ASPISForgotPassword controller 	= new ASPISForgotPassword();
			controller.username 			= 'aspisforgetpwdCCBD@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();
			
			System.assertEquals('fr', controller.language);
		}
	}
	//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
	@isTest static void constructorUserR4_TEST()
	{
		System.runAs(adminUser)
		{	CCBodyShopUser.ContactId=contacts[1].Id;
			CCBodyShopUser.ProfileId=profileNameMapId.get(label.R4BSProfileNameCommunity);
			insert CCBodyShopOrderUser;
			Test.setCurrentPage(Page.ASPISForgotPassword);
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'fr');
			ASPISForgotPassword controller 	= new ASPISForgotPassword();
			controller.username 			= 'aspisforgetpwdCCBDORD@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();
			
			System.assertEquals('fr', controller.language);
		}
	}
	@isTest static void resetPassword_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'fr');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'fr');
			
			ASPISForgotPassword controller 	= new ASPISForgotPassword();

			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			controller.username 			= 'aspisforgetpwd@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/secur/forgotpassword.jsp');
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			expectedPageRef.getParameters().put('un', 'aspisforgetpwd@test.com');
			expectedPageRef.getParameters().put('lang', 'fr');

			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void constructor_TESTDE()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'de');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'de');

			Test.startTest();
				ASPISForgotPassword controller = new ASPISForgotPassword();
			Test.stopTest();

			System.assertEquals('de', controller.language);
		}
	}

	@isTest static void resetPassword_TESTDE()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'de');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'de');
			
			ASPISForgotPassword controller 	= new ASPISForgotPassword();

			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			controller.username 			= 'aspisforgetpwd@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/secur/forgotpassword.jsp');
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			expectedPageRef.getParameters().put('un', 'aspisforgetpwd@test.com');
			expectedPageRef.getParameters().put('lang', 'de');

			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void constructor_TESTIT()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'it');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'it');
			

			Test.startTest();
				ASPISForgotPassword controller = new ASPISForgotPassword();
			Test.stopTest();

			System.assertEquals('it', controller.language);
		}
	}

	@isTest static void resetPassword_TESTIT()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'it');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'it');
			
			ASPISForgotPassword controller 	= new ASPISForgotPassword();
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			controller.username 			= 'aspisforgetpwd@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/secur/forgotpassword.jsp');
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			expectedPageRef.getParameters().put('un', 'aspisforgetpwd@test.com');
			expectedPageRef.getParameters().put('lang', 'it');

			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void constructor_TESTNL_BE()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'nl');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'nl');
			

			Test.startTest();
				ASPISForgotPassword controller = new ASPISForgotPassword();
			Test.stopTest();

			System.assertEquals('nl_be', controller.language);
		}
	}

	@isTest static void resetPassword_TESTNL_BE()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'nl');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'nl');
			
			ASPISForgotPassword controller 	= new ASPISForgotPassword();
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			controller.username 			= 'aspisforgetpwd@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/secur/forgotpassword.jsp');
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			expectedPageRef.getParameters().put('un', 'aspisforgetpwd@test.com');
			expectedPageRef.getParameters().put('lang', 'nl_be');

			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void constructor_TESTfrOnly()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'fr_');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'fr_');
			

			Test.startTest();
				ASPISForgotPassword controller = new ASPISForgotPassword();
			Test.stopTest();

			System.assertEquals('fr', controller.language);
		}
	}

	@isTest static void resetPassword_TESTfrOnly()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISForgotPassword);

			//WCH 22/01/2019: C-003021 : Users in R4 can not reset their password (Issue with community ?)
			//ApexPages.currentPage().getParameters().put('lang', 'fr_');
			ApexPages.currentPage().getHeaders().put('Accept-Language', 'fr_');
			
			ASPISForgotPassword controller 	= new ASPISForgotPassword();
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			controller.username 			= 'aspisforgetpwd@test.com';

			Test.startTest();
				PageReference currentPageRef = controller.resetPassword();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/secur/forgotpassword.jsp');
			//AMI 12/07/2018 : Community ROllout
			//      		 : hardcoding username to prevent attempt to dereference null object
			expectedPageRef.getParameters().put('un', 'aspisforgetpwd@test.com');
			expectedPageRef.getParameters().put('lang', 'fr');

			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}
}