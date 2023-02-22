/*
----------------------------------------------------------------------
-- - Name          : ASPISWelcomeDetect_TEST
-- - Author        : ABT
-- - Description   : Test class for ASPISWelcomeDetect
--
-- Maintenance History:
--
-- Date			Name  Version  Remarks
-- -----------	----  -------  ---------------------------------------
-- 24-JAN-2017	ABT		1.0    Initial version
-- 15-MAR-2018  DUN     1.1    C-002339 - Updated test class   
-- 10-APR-2018  DUN     1.4    C-002417 - Enlever la redirection sur la page d'inscription en français  
-- 23-JAN-2019	WCH		1.5	   C-002989 - Error is displayed when Bodyshop Beron attempts to log in
-- 22-MAR-2019	WCH		1.6	   C-002781 - Spain R4
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class ASPISWelcomeDetect_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;

	static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES')
			};

			accountList[0].isEligible__c 	= true;
			accountList[1].isEligible__c 	= false;
			accountList[1].Type 			= 'Expert';

			insert accountList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2]),
				TestFactory.createAssessment('Assessment_FR_NoBodyShop', new Account())
			};

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[1], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[2], accountList[1], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;
		}
	}

	@isTest static void salesOrderNotConnected_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = false;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = Page.ASPISConnect;
			expectedPageRef.getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}
    //WCH 23/01/2019 C-002989 Error is displayed when Bodyshop Beron attempts to log in
	@isTest static void salesOrderInvalidUser_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(encryptedId)+'jL');
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = false;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = Page.ASPISConnect;
			expectedPageRef.getParameters().put('Id', EncodingUtil.base64Encode(encryptedId)+'jL');
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}
	@isTest static void salesOrderConnectedWithoutDomain_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference('https://' + controller.currentInstance + '.salesforce.com/apex/ASPISSalesOrder');
			expectedPageRef.getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void salesOrderConnectedWithDomain_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			controller.isUsingDomain	  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef =  new PageReference(Label.AlphaScaleDomain + '/apex/ASPISSalesOrder');
			expectedPageRef.getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void orderMakeSelectionNotConnected_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = false;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = Page.ASPISConnect;
			expectedPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('ChildId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void orderMakeSelectionConnectedWithoutDomain_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference('https://' + controller.currentInstance + '.salesforce.com/apex/OrderMakeSelection');
			expectedPageRef.getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('ChildId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void orderMakeSelectionConnectedWithDomain_TEST()
	{
		System.runAs(adminUser)
		{

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('ChildId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			controller.isUsingDomain	  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef =  new PageReference(Label.AlphaScaleDomain + '/apex/OrderMakeSelection');
			expectedPageRef.getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('ChildId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void invalidLink_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Test.startTest();
				ApexPages.currentPage().getParameters().put('AssessmentId', 'ABCDEFGHIJ');
				ASPISWelcomeDetect controllerWithInvalidAssessmentId = new ASPISWelcomeDetect();
			Test.stopTest();

			System.assertEquals(false, controllerWithInvalidAssessmentId.isValidLink);
		}
	}

	@isTest static void validLink_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(assessmentList[0].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			Test.startTest();
				ASPISWelcomeDetect controller = new ASPISWelcomeDetect();

				ApexPages.currentPage().getParameters().put('AssessmentId', '');
				ASPISWelcomeDetect controllerWithAssessmentIdBlank = new ASPISWelcomeDetect();

				ApexPages.currentPage().getParameters().put('AssessmentId', '');
				ASPISWelcomeDetect controllerWithoutAssessmentIdParameter = new ASPISWelcomeDetect();
			Test.stopTest();

			System.assertEquals(true, controller.isValidLink);
			System.assertEquals(true, controllerWithAssessmentIdBlank.isValidLink);
			System.assertEquals(true, controllerWithoutAssessmentIdParameter.isValidLink);
			System.assertEquals('fr', controller.language);
			System.assertNotEquals(null, controller.currentAssessment);
			System.assertEquals(null, controllerWithAssessmentIdBlank.currentAssessment);
			System.assertEquals(null, controllerWithoutAssessmentIdParameter.currentAssessment);
		}
	}

	@isTest static void assessmentBodyshopNull_TEST()
	{
		System.runAs(adminUser)
		{
			assessmentList[0].BodyShop__c = null;

			update assessmentList;

			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(assessmentList[0].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			//10-APR-2018  DUN     1.4    C-002417 - Enlever la redirection sur la page d'inscription en français  
			PageReference expectedPageRef = Page.ASPISJoinUs;
			expectedPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());     
		}
	}

	// if there is a bodyshop in the assessment the user will not be redirectd to ASPISJoinUs

	@isTest static void assessmentWithoutBodyShop_TEST()
	{
		// there is a bodyshop in the assessement that is not eligible
		System.runAs(adminUser)
		{	
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(assessmentList[2].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();

			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			//10-APR-2018  DUN     1.4    C-002417 - Enlever la redirection sur la page d'inscription en français  
			PageReference expectedPageRef = Page.ASPISJoinUs;
			expectedPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	

	@isTest static void assessmentWithBodyshopButNotConnected_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(assessmentList[0].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'fr');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = false;

			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = Page.ASPISConnect;
			expectedPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'fr');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void assessmentWithBodyshopAndConnectedWithoutDomain_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(assessmentList[1].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('Order', '1');
			ApexPages.currentPage().getParameters().put('lang', 'es');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference('https://' + controller.currentInstance + '.salesforce.com/apex/OrderChooseAssessment');
			expectedPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('Order', '1');
			expectedPageRef.getParameters().put('lang', 'es');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void assessmentWithBodyshopAndConnectedWithDomain_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			Blob encryptedId = Blob.valueOf(assessmentList[1].Id);
			ApexPages.currentPage().getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			ApexPages.currentPage().getParameters().put('lang', 'es');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			controller.isUsingDomain	  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/apex/OrderChooseAssessment');
			expectedPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedId));
			expectedPageRef.getParameters().put('lang', 'es');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void noAssessmentAndNotConnected_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = false;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = Page.ASPISConnect;
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void noAssessmentButConnectedWithoutDomain_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isConnected 		  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference('https://' + controller.currentInstance + '.salesforce.com/apex/Search');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void noAssessmentButConnectedWithDomain_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isUsingDomain	  = true;
			controller.isConnected 		  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/apex/Search');
			
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}

	@isTest static void assessmentIdBlank_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISWelcomeDetect);
			ApexPages.currentPage().getParameters().put('AssessmentId', '');

			ASPISWelcomeDetect controller = new ASPISWelcomeDetect();
			controller.isUsingDomain	  = true;
			controller.isConnected 		  = true;
			
			Test.startTest();
				PageReference currentPageRef = controller.redirectPage();
			Test.stopTest();

			PageReference expectedPageRef = new PageReference(Label.AlphaScaleDomain + '/apex/Search');
			
			System.assertEquals(true, controller.isValidLink);
			System.assertEquals(expectedPageRef.getUrl(), currentPageRef.getUrl());
		}
	}
}