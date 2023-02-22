/*
----------------------------------------------------------------------
-- - Name          : ASPISJoinUsConfirmation_TEST
-- - Author        : ABT
-- - Description   : Test class for ASPISJoinUsConfirmation
--
-- Maintenance History:
--
-- Date			Name  Version  Remarks
-- -----------	----  -------  ---------------------------------------
-- 25-JAN-2017	ABT		1.0    Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class ASPISJoinUsConfirmation_TEST
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

	@isTest static void constructorWithoutParameters_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsConfirmation);

			Test.startTest();
				ASPISJoinUsConfirmation controller = new ASPISJoinUsConfirmation();
			Test.stopTest();

			System.assertEquals(false, controller.isValidLink);
		}
	}

	@isTest static void constructorWithInValidLink_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsConfirmation);
			
			ApexPages.currentPage().getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(accountList[0].Id)));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			Test.startTest();
				ASPISJoinUsConfirmation controller = new ASPISJoinUsConfirmation();
			Test.stopTest();

			System.assertEquals(false, controller.isValidLink);
		}
	}

	@isTest static void constructorWithInValidParameter_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsConfirmation);
			
			ApexPages.currentPage().getParameters().put('AccountId', 'abcd');
			ApexPages.currentPage().getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(contactList[0].Id)));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			Test.startTest();
				ASPISJoinUsConfirmation controller = new ASPISJoinUsConfirmation();
			Test.stopTest();

			System.assertEquals(false, controller.isValidLink);
		}
	}

	@isTest static void constructorWithValidLink_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsConfirmation);
			
			ApexPages.currentPage().getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(accountList[0].Id)));
			ApexPages.currentPage().getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(contactList[0].Id)));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			Test.startTest();
				ASPISJoinUsConfirmation controller = new ASPISJoinUsConfirmation();
			Test.stopTest();

			System.assertEquals(true, controller.isValidLink);
		}
	}

	@isTest static void download_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISJoinUsConfirmation);
			
			ApexPages.currentPage().getParameters().put('AccountId', EncodingUtil.base64Encode(Blob.valueOf(accountList[0].Id)));
			ApexPages.currentPage().getParameters().put('ContactId', EncodingUtil.base64Encode(Blob.valueOf(contactList[0].Id)));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISJoinUsConfirmation controller = new ASPISJoinUsConfirmation();
			
			Test.startTest();
				PageReference currentPageRef = controller.downloadPDF();
			Test.stopTest();

			PageReference expectedPageRef = Page.ASPISJoinUsPDF;
			expectedPageRef.getParameters().put('AccountId', accountList[0].Id);
			expectedPageRef.getParameters().put('ContactId', contactList[0].Id);
			expectedPageRef.getParameters().put('lang', 'fr');
			expectedPageRef.getParameters().put('country', 'FR');

			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}
}