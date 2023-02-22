/*
----------------------------------------------------------------------
-- - Name          : Search
-- - Author        : ABT
-- - Description   : Controller for Search
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 20-MAR-2017	ABT		1.0			Initial version
-- 12-FEb-2019  AMI     2.0         C-002781 : Migrate Spain to R4
--                                           : Update Test Coverage
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class Search_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
    static list<Invoice__c> invoiceList;

    //AMI 12/02/19 : C-002781 : Migrate Spain to R4
    //             : Update Test Coverage
    static user portalUser;
	static account customerAcc;
	static contact customerCon;
	static CountryCodeInformationsMapping__c countryMap;
	static BusinessHours defaultHours;
	static list<Case__c> l_cases;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		//AMI 12/02/19 : C-002781 : Migrate Spain to R4
    	//             : Update Test Coverage
		//			   : query userrole
		id userRole = [Select Id From UserRole Where Name = :system.label.AlphaScaleRole Limit 1].Id;
		adminUser.UserRoleId  = userRole;

		insert adminUser;

		System.runAs(adminUser)
		{
			//AMI 12/02/19 : C-002781 : Migrate Spain to R4
    	    //             : Update Test Coverage
			//             : query bs hours
			defaultHours = [select Id from BusinessHours where IsDefault=true];

			//               insert cs
			countryMap = TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id);
			countryMap.EnableChatterFeed__c = true;

			insert countryMap;

			//               create new portal user account
			customerAcc = TestFactory.createAccountBodyshop('testuseraccount', 'ES');

			insert customerAcc;

			//               create new portal user contact
			customerCon = new Contact(AccountId = customerAcc.Id,
										LastName = 'test',
										Email = 'CaseDetail@yahoo.com');

			insert customerCon;

			//               create portal user
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

			//                create cases
			l_cases = new list <Case__c>{TestFactory.createCase('testcase1',3, adminUser),
										 TestFactory.createCase('testcase2',3, adminUser),
										 TestFactory.createCase('testcase3',3, adminUser)};

			l_cases[0].Tech_BSAccount__c = customerAcc.Id;
			l_cases[0].CountryCode__c = 'ES';
			l_cases[1].Tech_BSAccount__c = customerAcc.Id;
			l_cases[1].CountryCode__c = 'ES';
			l_cases[2].Tech_BSAccount__c = customerAcc.Id;
			l_cases[2].CountryCode__c = 'ES';

			insert l_cases;

			//                updating account contact user
			customerAcc.ContactUser__c = portalUser.id;
			update customerAcc;

			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES'),

				TestFactory.createAccountBodyshop('BodyShop_3', 'ES'),
				TestFactory.createAccountDistributor('Distributor_3', 'ES'),

				TestFactory.createAccountBodyshop('BodyShop_4', 'IT'),
				TestFactory.createAccountDistributor('Distributor_4', 'IT')
			};

			insert accountList;

			Id claimRecordTypeId 			= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id claimOrderRecordTypeId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id newAssessmentRecordTypeId	= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();			

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2]),
				TestFactory.createAssessment('Assessment_ES_Child', accountList[4]),
				TestFactory.createAssessment('Assessment_FR_ShoppingList', accountList[0]),
				TestFactory.createAssessment('Assessment_FR_ShoppingList_Expired', accountList[0]),
				TestFactory.createAssessment('Assessment_IT', accountList[6])
			};

			assessmentList[1].TECH_EntityCountryCode__c = 'ES';
			assessmentList[2].TECH_EntityCountryCode__c = 'ES';
			assessmentList[5].TECH_EntityCountryCode__c = 'IT';

			assessmentList[0].PlateNumber2__c 	= '1234MR17';
			assessmentList[1].PlateNumber2__c 	= '4567MR17';
			assessmentList[2].PlateNumber2__c 	= '4567MR17';
			assessmentList[3].PlateNumber2__c 	= '9876MY17';
			assessmentList[4].PlateNumber2__c 	= '9876MY17';
			assessmentList[5].PlateNumber2__c 	= '1234JU17';

			assessmentList[0].RecordTypeId 		= claimRecordTypeId;
			assessmentList[1].RecordTypeId 		= claimRecordTypeId;
			assessmentList[2].RecordTypeId 		= claimOrderRecordTypeId;
			assessmentList[3].RecordTypeId 		= claimRecordTypeId;
			assessmentList[4].RecordTypeId 		= claimRecordTypeId;
			assessmentList[5].RecordTypeId 		= newAssessmentRecordTypeId;

			assessmentList[3].isShoppingList__c = true;
			assessmentList[4].isShoppingList__c = true;

			insert assessmentList;

			assessmentList[2].ParentAssessment__c 		= assessmentList[1].Id;

			assessmentList[4].ShortTermDeletionDate__c 	= System.now().addHours(-2);
			
			update assessmentList;

			//AMI 12/02/19 : C-002781 : Migrate Spain to R4
    	    //             : Update Test Coverage
			//             : assign cases to assessment
			l_cases[0].Assesment__c = assessmentList[0].Id;
			l_cases[1].Assesment__c = assessmentList[0].Id;
			l_cases[2].Assesment__c = assessmentList[0].Id;
			update l_cases;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[2], accountList[4], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[5], accountList[6], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;

            invoiceList = new list<Invoice__c>{
                TestFactory.createBodyshopInvoice('4567MR17',10.50,'SENT',salesOrderList[0]),
                TestFactory.createBodyshopCreditNote('4567MR17',10.50,'SENT',salesOrderList[0])
            };      

            invoiceList[0].date__c = date.newInstance(2001, 3, 17);
            invoiceList[1].date__c = date.newInstance(2001, 3, 21);
            invoiceList[0].Number__c = '4567MR17';
            invoiceList[1].Number__c = '4567MR17';

            insert invoiceList;
		}
	}

	@isTest static void constructor_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.Search);

			Test.startTest();
				Search controller = new Search();
			Test.stopTest();

			System.assertEquals('', controller.inputTerm);
			// System.assertEquals(false, controller.isAssessmentWrapperListEmpty);
			// System.assertEquals(2, controller.assessmentWrapperList.size());
			System.assertNotEquals(null, controller.profilePicture);
			System.assertEquals(false, controller.isShowingSearchResult);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
		}
	}

	@isTest static void searchData_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.Search);

			Test.setFixedSearchResults(new List<Id>{assessmentList[0].Id, assessmentList[2].Id});

			Search controller = new Search();

			controller.inputTerm = '1234MR17';

			Test.startTest();
				controller.searchData();
			Test.stopTest();

			System.assertEquals('1234MR17', controller.inputTerm);
			System.assertEquals(false, controller.isAssessmentWrapperListEmpty);
			System.assertEquals(1, controller.assessmentWrapperList.size());
			System.assertEquals(true, controller.isShowingSearchResult);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
		}
	}

	@isTest static void searchData2_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.Search);

			Test.setFixedSearchResults(new List<Id>{assessmentList[0].Id, assessmentList[2].Id});

			Search controller = new Search();

			controller.inputTerm = '4567MR17';

			Test.startTest();
				controller.searchData();
			Test.stopTest();

			System.assertEquals('4567MR17', controller.inputTerm);
			System.assertEquals(false, controller.isAssessmentWrapperListEmpty);
			System.assertEquals(1, controller.assessmentWrapperList.size());
			System.assertEquals(true, controller.isShowingSearchResult);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
		}
	}

	@isTest static void searchDataViaSalesOrder_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.Search);

			Test.setFixedSearchResults(new List<Id>{salesOrderList[0].Id});

			Search controller = new Search();

			controller.inputTerm = '7777MR17';

			Test.startTest();
				controller.searchData();
			Test.stopTest();

			System.assertEquals('7777MR17', controller.inputTerm);
			System.assertEquals(false, controller.isAssessmentWrapperListEmpty);
			System.assertEquals(1, controller.assessmentWrapperList.size());
			System.assertEquals(assessmentList[1].Id, controller.assessmentWrapperList[0].currentAssessment.Id);
			System.assertEquals(true, controller.isShowingSearchResult);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
		}
	}

	@isTest static void siteWelcomePopup()
	{
		System.runAs(adminUser)
		{
			List<UserRole> frBodyShopRoleList = [SELECT Id
												 FROM	UserRole
												 WHERE 	Name = 'FR - BodyShop'];

			System.assertNotEquals(0, frBodyShopRoleList.size());

			adminUser.UserRoleId = frBodyShopRoleList[0].Id;

			update adminUser;

			Test.setCurrentPage(Page.Search);

			Search controller = new Search();

			System.assertEquals(true, controller.showWelcomeModal);

			controller.currentUser.HideSiteWelcomePopup__c = true;

			Test.startTest();
				controller.checkHideSiteWelcomePopup();
			Test.stopTest();

			User updatedAdminUser = [SELECT Id, HideSiteWelcomePopup__c
									 FROM 	User
									 WHERE	Id =: adminUser.Id];

			System.assertEquals(true, updatedAdminUser.HideSiteWelcomePopup__c);
		}
	}

	@isTest static void searchSubstitutionAssessment_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.Search);

			assessmentList[0].Status__c = ASPISConstants.ASSESS_STATUS_SUBSTITUTION;
			update assessmentList;

			Test.setFixedSearchResults(new List<Id>{assessmentList[0].Id, assessmentList[2].Id});

			Search controller = new Search();

			controller.inputTerm = '1234MR17';

			Test.startTest();
				controller.searchData();
			Test.stopTest();

			System.assertEquals('1234MR17', controller.inputTerm);
			System.assertEquals(true, controller.isAssessmentWrapperListEmpty);
			System.assertEquals(0, controller.assessmentWrapperList.size());
			System.assertEquals(true, controller.isShowingSearchResult);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
		}
	}

	@isTest static void searchShoppingList_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.Search);

			Test.setFixedSearchResults(new List<Id>{assessmentList[3].Id, assessmentList[4].Id});

			Search controller = new Search();

			controller.inputTerm = '9876MY17';

			Test.startTest();
				controller.searchData();
			Test.stopTest();

			System.assertEquals('9876MY17', controller.inputTerm);
			System.assertEquals(false, controller.isAssessmentWrapperListEmpty);
			// 1 has been expired therefore should not appear in the search results
			System.assertEquals(1, controller.assessmentWrapperList.size());
			System.assertEquals(true, controller.isShowingSearchResult);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
		}
	}

	@isTest static void searchItalianSO_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.Search);

			Test.setFixedSearchResults(new List<Id>{salesOrderList[1].Id});

			Search controller = new Search();

			controller.inputTerm = '1234JU17';

			Test.startTest();
				controller.searchData();
			Test.stopTest();

			System.assertEquals('1234JU17', controller.inputTerm);
			System.assertEquals(false, controller.isAssessmentWrapperListEmpty);
			// 1 has been expired therefore should not appear in the search results
			System.assertEquals(1, controller.assessmentWrapperList.size());
			System.assertEquals(true, controller.isShowingSearchResult);
			System.assertEquals(false, controller.hasErrors);
			System.assertEquals(false, controller.isToastError);
		}
	}

	//AMI 12/02/19 : C-002781 : Migrate Spain to R4
    //             : Update Test Coverage
    @isTest
	static void testSearchCaseES(){
		system.debug('## Start testSearchCaseES');
		portalUser.CountryCode = 'ES';
		update portalUser;

		system.runAs(portalUser){
			Test.startTest();
				Test.setCurrentPage(Page.Search);
				Search controller = new Search();
				controller.inputTerm = 'testcase';
				controller.searchData();
			Test.stopTest();
		}

		system.debug('## End testSearchCaseES');
	}

	//AMI 12/02/19 : C-002781 : Migrate Spain to R4
    //             : Update Test Coverage
    @isTest
	static void testSearchCaseNonES(){
		system.debug('## Start testSearchCaseNonES');
		
		system.runAs(portalUser){
			Test.startTest();
				Test.setCurrentPage(Page.Search);
				Search controller = new Search();
				controller.inputTerm = 'testcase';
				controller.searchData();
			Test.stopTest();
		}

		system.debug('## End testSearchCaseNonES');
	}

	//AMI 12/02/19 : C-002781 : Migrate Spain to R4
    //             : Update Test Coverage
    @isTest
	static void testRetrieveCaseData(){
		system.debug('## Start testRetrieveCaseData');

		system.runAs(portalUser){
			Test.startTest();
				Test.setCurrentPage(Page.Search);
				Search controller = new Search();
				controller.retrieveCaseData(new list <Assessment__c>{assessmentList[0]});
			Test.stopTest();
		}

		system.debug('## End testRetrieveCaseData');
	}
}