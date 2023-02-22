/*
----------------------------------------------------------------------
-- - Name          : ASPISJoinUsPDF_TEST
-- - Author        : ABT
-- - Description   : Test class for ASPISJoinUsPDF
--
-- Maintenance History:
--
-- Date			Name  Version  Remarks
-- -----------	----  -------  ---------------------------------------
-- 26-JAN-2017	ABT		1.0    Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class ASPISJoinUsPDF_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Contact> contactList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR')
			};

			Id leadAccId 				= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Lead').getRecordTypeId();

			accountList[0].RecordTypeId = leadAccId;

			insert accountList;

			contactList = new List<Contact>
			{
				new Contact(Salutation = 'Mr',
							FirstName = 'Alpha',
							LastName = 'Scale')
			};

			insert contactList;
		}
	}

	@isTest static void constructorWithoutAnyParameters_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsPDF);

			Test.startTest();
				ASPISJoinUsPDF controller = new ASPISJoinUsPDF();
			Test.stopTest();

			System.assertEquals(null, controller.currentAccount.Id);
			System.assertEquals(null, controller.currentContact.Id);
			System.assertEquals('en_US', controller.language);
		}
	}

	@isTest static void constructorWithLanguageOnly_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsPDF);

			ApexPages.currentPage().getParameters().put('lang', 'fr');

			Test.startTest();
				ASPISJoinUsPDF controller = new ASPISJoinUsPDF();
			Test.stopTest();

			System.assertEquals(null, controller.currentAccount.Id);
			System.assertEquals(null, controller.currentContact.Id);
			System.assertEquals('fr', controller.language);
		}
	}

	@isTest static void constructorWithAccountAndContact_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsPDF);

			ApexPages.currentPage().getParameters().put('AccountId', accountList[0].Id);
			ApexPages.currentPage().getParameters().put('ContactId', contactList[0].Id);
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			Test.startTest();
				ASPISJoinUsPDF controller = new ASPISJoinUsPDF();
			Test.stopTest();

			System.assertEquals(accountList[0].Id, controller.currentAccount.Id);
			System.assertEquals(contactList[0].Id, controller.currentContact.Id);
			System.assertEquals('fr', controller.language);
		}
	}
}