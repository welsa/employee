/*
----------------------------------------------------------------------
-- - Name          : ASPISSalesOrder_TEST
-- - Author        : ABT
-- - Description   : Test class for ASPISSalesOrder
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 23-MAR-2017	ABT		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class ASPISSalesOrder_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static list<Invoice__c> l_Invoices;
	static List<Case__c> caseList;

	static
	{	l_Invoices = new list<Invoice__c>();
        caseList = new list<Case__c>();
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES'),

				TestFactory.createAccountBodyshop('BodyShop_3', 'IT'),
				TestFactory.createAccountDistributor('Distributor_3', 'IT')
			};

			insert accountList;

			Id claimRecordTypeId 			= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id claimOrderRecordTypeId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id newAssessmentRecordTypeId 	= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_FR_Child', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2]),
				TestFactory.createAssessment('Assessment_ES_Child', accountList[2]),
				TestFactory.createAssessment('Assessment_IT', accountList[4])
			};

			assessmentList[2].TECH_EntityCountryCode__c = 'ES';
			assessmentList[3].TECH_EntityCountryCode__c = 'ES';
			assessmentList[4].TECH_EntityCountryCode__c = 'IT';

			assessmentList[0].PlateNumber2__c 			= '123MR17';
			assessmentList[1].PlateNumber2__c 			= '123MR17';
			assessmentList[2].PlateNumber2__c 			= '798MR17';
			assessmentList[3].PlateNumber2__c 			= '798MR17';
			assessmentList[4].PlateNumber2__c 			= '123JU17';

			assessmentList[0].RecordTypeId 				= claimRecordTypeId;
			assessmentList[1].RecordTypeId 				= claimOrderRecordTypeId;
			assessmentList[2].RecordTypeId 				= claimRecordTypeId;
			assessmentList[3].RecordTypeId 				= claimOrderRecordTypeId;
			assessmentList[4].RecordTypeId 				= newAssessmentRecordTypeId;

			insert assessmentList;

			assessmentList[1].ParentAssessment__c 		= assessmentList[0].Id;
			assessmentList[3].ParentAssessment__c 		= assessmentList[2].Id;

			update assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[1], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[3], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[4], accountList[4], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;
			Case__c c = new Case__c(Account_Name__c = accountList[0].Id,
                            Assesment__c = assessmentList[1].Id,
                            SubmittedBy__c = adminUser.ID,
                            Description__c = 'TEST',
                            CountryCode__c = 'FR',
                            Origin__c = 'APPLICATION',
                            Priority__c = 'LOW',                                                                                        
                            Status__c = 'New',
                            Subject__c = 'TEST',
                            Type__c = 'PROBLEM',
							Sales_order__c=salesOrderList[0].Id);
            caseList.add(c);
			insert caseList;

			Invoice__c inv1 = TestFactory.createBodyshopInvoice('INV-2812A', 14.40, 'RECEIVED', salesOrderList[0]);
			inv1.Number__c='ferfrgtybjiuolpolp';
            l_Invoices.add(inv1);
			insert l_Invoices;
		}
	}

	@isTest static void constructorWithoutId_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISSalesOrder);

			Test.startTest();
				ASPISSalesOrder controller 	= new ASPISSalesOrder();
			Test.stopTest();

			PageReference currentPageRef 	= Page.Search;

			System.assertEquals(false, controller.hasSalesOrderId);
			System.assertEquals(true, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
			System.assertEquals(currentPageRef.getUrl(), controller.backURL);
		}
	}

	@isTest static void constructorWithIdBlank_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISSalesOrder);

			ApexPages.currentPage().getParameters().put('Id', '');

			Test.startTest();
				ASPISSalesOrder controller 	= new ASPISSalesOrder();
				controller.redirectPage();
			Test.stopTest();

			PageReference currentPageRef 	= Page.Search;

			System.assertEquals(false, controller.hasSalesOrderId);
			System.assertEquals(true, controller.hasErrors);
			System.assertEquals(true, controller.isToastError);
			System.assertEquals(currentPageRef.getUrl(), controller.backURL);
		}
	}

	@isTest static void constructorWithId_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISSalesOrder);

			Blob encryptedId 				= Blob.valueOf(salesOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));

			Test.startTest();
				ASPISSalesOrder controller 	= new ASPISSalesOrder();
			Test.stopTest();

			PageReference currentPageRef 	= Page.OrderChooseAssessment;
			Blob encryptedClaimId			= Blob.valueOf(assessmentList[0].Id);
			currentPageRef.getParameters().put('AssessmentId', EncodingUtil.base64Encode(encryptedClaimId));

			System.assertEquals(true, controller.hasSalesOrderId);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
			System.assertEquals(currentPageRef.getUrl(), controller.backURL);
		}
	}

	@isTest static void constructorWithItalianSOId_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISSalesOrder);

			Blob encryptedId 				= Blob.valueOf(salesOrderList[2].Id);
			ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));

			Test.startTest();
				ASPISSalesOrder controller 	= new ASPISSalesOrder();
			Test.stopTest();

			PageReference currentPageRef 	= Page.Search;

			System.assertEquals(true, controller.hasSalesOrderId);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
			System.assertEquals(currentPageRef.getUrl(), controller.backURL);
		}
	}
	@isTest static void DownloadPDFSOId_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISSalesOrder);

			Blob encryptedId 				= Blob.valueOf(salesOrderList[2].Id);
			ApexPages.currentPage().getParameters().put('Id', EncodingUtil.base64Encode(encryptedId));

			Test.startTest();
				ASPISSalesOrder controller 	= new ASPISSalesOrder();
				controller.downloadPDFSO();
			Test.stopTest();

			PageReference currentPageRef 	= Page.Search;

			System.assertEquals(true, controller.hasSalesOrderId);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
			System.assertEquals(currentPageRef.getUrl(), controller.backURL);
		}
	}
}