/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchShortTermDeletion_TEST
  -- - Author        : ABT
  -- - Description   : Test class for ASPISBatchShortTermDeletion
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 04-MAY-2017	ABT		1.0    	Initial version
  -------------------------------------------------------------------------
  **********************************************************************
*/
@isTest
private class ASPISBatchShortTermDeletion_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<Invoice__c> invoiceList;
	static List<Case__c> caseList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('FR_BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('FR_Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('ES_BodyShop_1', 'ES'),
				TestFactory.createAccountDistributor('ES_Distributor_1', 'ES'),

				TestFactory.createAccountBodyshop('DE_BodyShop_1', 'DE'),
				TestFactory.createAccountDistributor('DE_Distributor_1', 'DE')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				// This claim will not be deleted as it is not a shopping list
				TestFactory.createAssessment('FR Unconfirmed Claim Assessment', accountList[0]),
				TestFactory.createAssessment('FR Unconfirmed Crash Assessment', accountList[0]),
				// only the claim order will be deleted
				TestFactory.createAssessment('FR Unconfirmed Claim Order Order Assessment', accountList[0]),

				TestFactory.createAssessment('FR Confirmed Claim Assessment', accountList[0]),
				TestFactory.createAssessment('FR Confirmed Crash Assessment', accountList[0]),
				TestFactory.createAssessment('FR Confirmed Claim Order Order Assessment', accountList[0]),

				TestFactory.createAssessment('FR Unconfirmed Claim Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Unconfirmed Crash Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Unconfirmed Shopping Claim Order Order Assessment', accountList[0]),

				TestFactory.createAssessment('FR Confirmed Claim Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Confirmed Crash Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Confirmed Shopping Claim Order Order Assessment', accountList[0])
			};

			Id claimOrderId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id claimId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id crashId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Crash').getRecordTypeId();

			assessmentList[0].RecordTypeId 				= claimId;
			assessmentList[0].TECH_EntityCountryCode__c = 'FR';

			assessmentList[1].RecordTypeId 				= crashId;
			assessmentList[1].TECH_EntityCountryCode__c = 'FR';

			assessmentList[2].RecordTypeId 				= claimOrderId;
			assessmentList[2].TECH_EntityCountryCode__c = 'FR';

			// --------------------------------------------------------------

			assessmentList[3].RecordTypeId 				= claimId;
			assessmentList[3].TECH_EntityCountryCode__c = 'FR';

			assessmentList[4].RecordTypeId 				= crashId;
			assessmentList[4].TECH_EntityCountryCode__c = 'FR';

			assessmentList[5].RecordTypeId 				= claimOrderId;
			assessmentList[5].TECH_EntityCountryCode__c = 'FR';

			// --------------------------------------------------------------

			assessmentList[6].RecordTypeId 				= claimId;
			assessmentList[6].TECH_EntityCountryCode__c = 'FR';
			assessmentList[6].isShoppingList__c			= true;

			assessmentList[7].RecordTypeId 				= crashId;
			assessmentList[7].TECH_EntityCountryCode__c = 'FR';
			assessmentList[7].isShoppingList__c			= true;

			assessmentList[8].RecordTypeId 				= claimOrderId;
			assessmentList[8].TECH_EntityCountryCode__c = 'FR';
			assessmentList[8].isShoppingList__c			= true;

			// --------------------------------------------------------------

			assessmentList[9].RecordTypeId 				 = claimId;
			assessmentList[9].TECH_EntityCountryCode__c  = 'FR';
			assessmentList[9].isShoppingList__c			 = true;

			assessmentList[10].RecordTypeId				 = crashId;
			assessmentList[10].TECH_EntityCountryCode__c = 'FR';
			assessmentList[10].isShoppingList__c		 = true;

			assessmentList[11].RecordTypeId				 = claimOrderId;
			assessmentList[11].TECH_EntityCountryCode__c = 'FR';
			assessmentList[11].isShoppingList__c		 = true;

			// --------------------------------------------------------------
			
			insert assessmentList;

			assessmentList[1].ParentAssessment__c = assessmentList[0].Id;
			assessmentList[2].ParentAssessment__c = assessmentList[0].Id;

			assessmentList[4].ParentAssessment__c = assessmentList[3].Id;
			assessmentList[5].ParentAssessment__c = assessmentList[3].Id;

			assessmentList[7].ParentAssessment__c = assessmentList[6].Id;
			assessmentList[8].ParentAssessment__c = assessmentList[6].Id;

			assessmentList[10].ParentAssessment__c = assessmentList[9].Id;
			assessmentList[11].ParentAssessment__c = assessmentList[9].Id;

			DateTime pastDate = System.now().addHours(-2);

			// forcing all the assessment to have a deletion date
			assessmentList[0].ShortTermDeletionDate__c = pastDate;
			assessmentList[1].ShortTermDeletionDate__c = pastDate;
			assessmentList[2].ShortTermDeletionDate__c = pastDate;
			assessmentList[3].ShortTermDeletionDate__c = pastDate;
			assessmentList[4].ShortTermDeletionDate__c = pastDate;
			assessmentList[5].ShortTermDeletionDate__c = pastDate;
			assessmentList[6].ShortTermDeletionDate__c = pastDate;
			assessmentList[7].ShortTermDeletionDate__c = pastDate;
			assessmentList[8].ShortTermDeletionDate__c = pastDate;
			assessmentList[9].ShortTermDeletionDate__c = pastDate;
			assessmentList[10].ShortTermDeletionDate__c = pastDate;
			assessmentList[11].ShortTermDeletionDate__c = pastDate;

			update assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[2], accountList[0], 'PREACCEPTANCE'),
				TestFactory.createSalesOrder(assessmentList[5], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[8], accountList[0], 'PREACCEPTANCE'),
				TestFactory.createSalesOrder(assessmentList[11], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[0], accountList[0], accountList[1], 'PREDRAFTQUOTE'),
				TestFactory.createPurchaseOrder(assessmentList[5], salesOrderList[1], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[8], salesOrderList[2], accountList[0], accountList[1], 'PREDRAFTQUOTE'),
				TestFactory.createPurchaseOrder(assessmentList[11], salesOrderList[3], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};
			
			insert purchaseOrderList;

			invoiceList = new List<Invoice__c>
			{
				TestFactory.createBodyshopInvoice('INV_0001', 1000, ASPISConstants.INV_STATUS_SENT, salesOrderList[1]),
				TestFactory.createBodyshopInvoice('INV_0002', 1000, ASPISConstants.INV_STATUS_SENT, salesOrderList[3]),
				TestFactory.createDistributorInvoice('INV_0003', 1000, ASPISConstants.INV_STATUS_SENT, purchaseOrderList[0]),
				TestFactory.createDistributorInvoice('INV_0004', 1000, ASPISConstants.INV_STATUS_SENT, purchaseOrderList[2])
			};
			
			insert invoiceList;

			caseList = new List<Case__c>
			{
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[0].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[1].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[2].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[3].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[4].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[5].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[6].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[7].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[8].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[9].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[10].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM'),
				new Case__c(Account_Name__c = accountList[0].Id,
							Assesment__c = assessmentList[11].Id,
							SubmittedBy__c = adminUser.ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM')
			};
			
			insert caseList;
		}
	}

	@isTest static void runBatch()
	{
		System.runAs(adminUser)
		{
			ASPISBatchShortTermDeletion batch = new ASPISBatchShortTermDeletion();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			Map<Id, Assessment__c> mapAssessment = new Map<Id, Assessment__c>([SELECT Id, Name FROM Assessment__c WHERE Id IN: assessmentList]);

			for(Assessment__c currentAssessment : mapAssessment.values())
			{
				System.debug('## TEST CLASS : ' + currentAssessment.Name);
			}
			System.assertEquals(8, mapAssessment.size());
			System.assertEquals(false, mapAssessment.containsKey(assessmentList[2].Id));
			System.assertEquals(false, mapAssessment.containsKey(assessmentList[6].Id));
			System.assertEquals(false, mapAssessment.containsKey(assessmentList[7].Id));
			System.assertEquals(false, mapAssessment.containsKey(assessmentList[8].Id));

			Map<Id, PrerequisiteOrder__c> mapSalesOrder = new Map<Id, PrerequisiteOrder__c>([SELECT Id FROM PrerequisiteOrder__c WHERE Id IN: salesOrderList]);

			System.assertEquals(2, mapSalesOrder.size());
			System.assertEquals(false, mapSalesOrder.containsKey(salesOrderList[0].Id));
			System.assertEquals(false, mapSalesOrder.containsKey(salesOrderList[2].Id));

			Map<Id, PurchaseOrder__c> mapPurchaseOrder = new Map<Id, PurchaseOrder__c>([SELECT Id FROM PurchaseOrder__c WHERE Id IN: purchaseOrderList]);

			System.assertEquals(2, mapPurchaseOrder.size());
			System.assertEquals(false, mapPurchaseOrder.containsKey(purchaseOrderList[0].Id));
			System.assertEquals(false, mapPurchaseOrder.containsKey(purchaseOrderList[2].Id));


			Map<Id, Invoice__c> mapInvoice = new Map<Id, Invoice__c>([SELECT Id FROM Invoice__c WHERE Id IN: invoiceList]);

			System.assertEquals(2, mapInvoice.size());
			System.assertEquals(false, mapInvoice.containsKey(invoiceList[2].Id));
			System.assertEquals(false, mapInvoice.containsKey(invoiceList[3].Id));

			Map<Id, Case__c> mapCase = new Map<Id, Case__c>([SELECT Id FROM Case__c WHERE Id IN: caseList]);

			System.assertEquals(8, mapCase.size());
			System.assertEquals(false, mapCase.containsKey(caseList[2].Id));
			System.assertEquals(false, mapCase.containsKey(caseList[6].Id));
			System.assertEquals(false, mapCase.containsKey(caseList[7].Id));
			System.assertEquals(false, mapCase.containsKey(caseList[8].Id));
		}
	}

	@isTest static void scheduleBatchShortTermDeletion()
	{
		System.runAs(adminUser)
		{
			ASPISBatchShortTermDeletion scheduler = new ASPISBatchShortTermDeletion();
			String sch = '0 0 0 * * ?';

			Test.startTest();
				Id processId = System.schedule('Test delete batch scheduler', sch, scheduler);
			Test.stopTest();

			CronTrigger ct = [SELECT Id, CronExpression
							  FROM	 CronTrigger
							  WHERE	 Id =: processId];

			System.assertEquals(sch, ct.CronExpression);
		}
	}
}