/*
----------------------------------------------------------------------
-- - Name          : VFC18_PrivacyNotice
-- - Author        : ABT
-- - Description   : Controller for VFP18_PrivacyNotice
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 10-JUL-2017	ABT		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class VFC18_PrivacyNotice_TEST
{
	static User adminUser;
	static List<User> userList;
	static List<Document> documentList;
	static List<CS_Agreement__c> csAgreementList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			userList = new List<User>
			{
				TestFactory.createUserBodyshop('FR_BodyShop'),
				TestFactory.createUserBodyshop('ES_BodyShop'),
				TestFactory.createUserBodyshop('IT_BodyShop'),
				TestFactory.createUserBodyshop('DE_BodyShop')
			};

			userList[0].CountryCode 		= 'FR';
			userList[0].LanguageLocaleKey 	= 'fr';
			userList[1].CountryCode 		= 'ES';
			userList[1].LanguageLocaleKey 	= 'es';
			userList[2].CountryCode 		= 'IT';
			userList[2].LanguageLocaleKey 	= 'it';
			userList[3].CountryCode 		= 'DE';
			userList[3].LanguageLocaleKey 	= 'de';

			insert userList;

			documentList = new List<Document>
			{
				new Document(Name			= 'AgreementEnglish',
							DeveloperName	= 'AgreementEnglish',
							Description		= 'Hello test class',
							Body			= Blob.valueOf('Hello test class'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= UserInfo.getUserId(),
							FolderId		= UserInfo.getUserId()),
				new Document(Name			= 'AgreementFrench',
							DeveloperName	= 'AgreementFrench',
							Description		= 'J\'aime le Français',
							Body			= Blob.valueOf('J\'aime le Français'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[0].id,
							FolderId		= userList[0].id),
				new Document(Name			= 'AgreementSpanish',
							DeveloperName	= 'AgreementSpanish',
							Description		= 'Hola clase de prueba',
							Body			= Blob.valueOf('Hola clase de prueba'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[1].id,
							FolderId		= userList[1].id),
				new Document(Name			= 'AgreementItalian',
							DeveloperName	= 'AgreementItalian',
							Description		= 'Ciao la classe di prova',
							Body			= Blob.valueOf('Ciao la classe di prova'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[2].id,
							FolderId		= userList[2].id),
				new Document(Name			= 'AgreementGerman',
							DeveloperName	= 'AgreementGerman',
							Description		= 'Hallo Testklasse',
							Body			= Blob.valueOf('Hallo Testklasse'),
							ContentType		= 'text/plain; charset=UTF-8',
							AuthorId		= userList[3].id,
							FolderId		= userList[3].id)
				
			};

			insert documentList;

			csAgreementList = new List<CS_Agreement__c>
			{
				new CS_Agreement__c(Name					= 'EN',
									Agreement_Document__c	= 'AgreementEnglish',
									User_Field__c			= 'General_Agreement__c',
									Url_Context__c			= '/home/home.jsp',
									Active__c				= true,
									General__c				= true),               
				new CS_Agreement__c(Name					= 'FR',
									Agreement_Document__c	= 'AgreementFrench',
									User_Field__c			= 'General_Agreement__c',
									Url_Context__c			= '/home/home.jsp',
									Active__c				= true,
									General__c				= false),
				new CS_Agreement__c(Name					= 'ES',
									Agreement_Document__c	= 'AgreementSpanish',
									User_Field__c			= 'General_Agreement__c',
									Url_Context__c			= '/home/home.jsp',
									Active__c				= true,
									General__c				= false),
				new CS_Agreement__c(Name					= 'IT',
									Agreement_Document__c	= 'AgreementItalian',
									User_Field__c			= 'General_Agreement__c',
									Url_Context__c			= '/home/home.jsp',
									Active__c				= true,
									General__c				= false),
				new CS_Agreement__c(Name					= 'DE',
									Agreement_Document__c	= 'AgreementGerman',
									User_Field__c			= 'General_Agreement__c',
									Url_Context__c			= '/home/home.jsp',
									Active__c				= true,
									General__c				= false)
			};

			insert csAgreementList;
		}
	}

	@isTest static void englishUser_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP18_PrivacyNotice);

			Test.startTest();
				VFC18_PrivacyNotice controller = new VFC18_PrivacyNotice();
			Test.stopTest();

			System.assertEquals(documentList[0].body.toString(), controller.agreementBody);
		}
	}

	@isTest static void frenchUser_TEST()
	{
		System.runAs(userList[0])
		{
			Test.setCurrentPage(Page.VFP18_PrivacyNotice);

			Test.startTest();
				VFC18_PrivacyNotice controller = new VFC18_PrivacyNotice();
			Test.stopTest();

			/*system.debug('##documentList[0].body.toString() '+documentList[0].body.toString());
			system.debug('##controller.agreementBody '+controller.agreementBody);

			List<Document> retDocumentList = [	SELECT	Id, Body,DeveloperName
										FROM Document where id IN: documentList
										 ];
			system.debug('##retrieveAgreementDocument'+retDocumentList);*/

			System.assertEquals(documentList[1].body.toString(), controller.agreementBody);
		}
	}

	@isTest static void spanishUser_TEST()
	{
		System.runAs(userList[1])
		{
			Test.setCurrentPage(Page.VFP18_PrivacyNotice);

			Test.startTest();
				VFC18_PrivacyNotice controller = new VFC18_PrivacyNotice();
			Test.stopTest();

			System.assertEquals(documentList[2].body.toString(), controller.agreementBody);
		}
	}

	@isTest static void italianUser_TEST()
	{
		System.runAs(userList[2])
		{
			Test.setCurrentPage(Page.VFP18_PrivacyNotice);

			Test.startTest();
				VFC18_PrivacyNotice controller = new VFC18_PrivacyNotice();
			Test.stopTest();

			System.assertEquals(documentList[3].body.toString(), controller.agreementBody);
		}
	}

	@isTest static void germanUser_TEST()
	{
		System.runAs(userList[3])
		{
			Test.setCurrentPage(Page.VFP18_PrivacyNotice);

			Test.startTest();
				VFC18_PrivacyNotice controller = new VFC18_PrivacyNotice();
			Test.stopTest();

			System.assertEquals(documentList[4].body.toString(), controller.agreementBody);
		}
	}

	@isTest static void frenchUserWithoutCS_TEST()
	{
		System.runAs(userList[0])
		{
			delete csAgreementList[1];

			Test.setCurrentPage(Page.VFP18_PrivacyNotice);

			Test.startTest();
				VFC18_PrivacyNotice controller = new VFC18_PrivacyNotice();
			Test.stopTest();

			System.assertEquals(controller.agreementBody,null);
		}
	}

	@isTest static void noEntryInCS_TEST()
	{
		System.runAs(adminUser)
		{
			delete csAgreementList;

			Test.setCurrentPage(Page.VFP18_PrivacyNotice);

			Test.startTest();
				VFC18_PrivacyNotice controller = new VFC18_PrivacyNotice();
			Test.stopTest();

			System.assertEquals(null, controller.agreementBody);
		}
	}
}