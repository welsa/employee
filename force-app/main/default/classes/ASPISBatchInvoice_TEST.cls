/*
----------------------------------------------------------------------
-- - Name          : ASPISBatchInvoice_TEST
-- - Author        : ABT
-- - Description   : Test class for the batch of ASPISBatchInvoice
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 15-JUN-2017	ABT		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class ASPISBatchInvoice_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PartList__c> partList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static List<Offer__c> offerList;
	static List<Invoice__c> invoiceList;

	static
	{
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
				TestFactory.createAccountDistributor('Distributor_2', 'ES')
			};
			accountList[0].BillingCity='Nimes';
			accountList[0].BillingCountry='France';
			accountList[0].BillingStreet='st martin de chez yvone';
			accountList[0].BillingPostalCode='12345';
			accountList[2].BillingCity='Nimes';
			accountList[2].BillingCountry='France';
			accountList[2].BillingStreet='st martin de chez yvone';
			accountList[2].BillingPostalCode='12345';
			insert accountList;	

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2])
			};

			assessmentList[0].TECH_EntityCountryCode__c = 'FR';
			assessmentList[1].TECH_EntityCountryCode__c = 'ES';

			assessmentList[0].PlateNumber2__c 			= '1234MR17';
			assessmentList[1].PlateNumber2__c 			= '4567MR17';

			assessmentList[0].Manufacturer__c 			= 'NISSAN';
			assessmentList[1].Manufacturer__c 			= 'BMW';

			insert assessmentList;

			partList = new List<PartList__c>
            {
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),

                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1])
            };

            insert partList;

			salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED),
                TestFactory.createSalesOrder(assessmentList[1], accountList[2], ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
            };

            insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
			};

			purchaseOrderList[0].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();
			purchaseOrderList[1].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();

			purchaseOrderList[0].InvoiceStatus__c = ASPISConstants.PUR_ORDER_INVOICESTATUS_VALIDATED;
			purchaseOrderList[1].InvoiceStatus__c = ASPISConstants.PUR_ORDER_INVOICESTATUS_VALIDATED;

			purchaseOrderList[0].TotalExpectedAmount__c = 1000;
			purchaseOrderList[1].TotalExpectedAmount__c = 1000;

			insert purchaseOrderList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
			};

			insert orderLineList;

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),

				TestFactory.createOfferLine(orderLineList[2], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[3], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED)
			};

			insert offerList;

			invoiceList = new List<Invoice__c>
			{
				TestFactory.createBodyshopInvoice('INV-0001', 1000, ASPISConstants.INV_STATUS_PAID, salesOrderList[0]),

				TestFactory.createBodyshopInvoice('INV-0002', 1000, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),
				TestFactory.createBodyshopInvoice('INV-0002-A', 1000, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),

				TestFactory.createBodyshopCreditNote('INV-0003', 1000, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),
				TestFactory.createBodyshopCreditNote('INV-0003-A', 1000, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),

				TestFactory.createBodyshopInvoice('INV-0004', 1000, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),
				TestFactory.createBodyshopInvoice('INV-0004-A', 1000, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),
				
				TestFactory.createDistributorInvoice('INV-0005', 1000, ASPISConstants.INV_STATUS_PAID, purchaseOrderList[0]),

				TestFactory.createDistributorInvoice('INV-0006', 1000, ASPISConstants.INV_STATUS_PAID, purchaseOrderList[1]),
				TestFactory.createDistributorInvoice('INV-0007', 1000, ASPISConstants.INV_STATUS_PAID, purchaseOrderList[1]),
				TestFactory.createDistributorCreditNote('INV-0008', 1000, ASPISConstants.INV_STATUS_PAID, purchaseOrderList[1])
			};

			invoiceList[2].PurchaseOrder__c = purchaseOrderList[1].Id;
			invoiceList[4].PurchaseOrder__c = purchaseOrderList[1].Id;
			invoiceList[6].PurchaseOrder__c = purchaseOrderList[1].Id;

			insert invoiceList;

			invoiceList[2].ParentInvoice__c = invoiceList[1].Id;
			invoiceList[4].ParentInvoice__c = invoiceList[3].Id;
			invoiceList[6].ParentInvoice__c = invoiceList[4].Id;

			update invoiceList;
		}
	}

	@isTest static void allInvoicesPaid_TEST()
	{
		System.runAs(adminUser)
		{
			ASPISBatchInvoice batch = new ASPISBatchInvoice();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Invoice__c> updatedInvoiceList = [SELECT 	Id, Status__c
												   FROM		Invoice__c
												   WHERE	Id IN: invoiceList];

			System.assertEquals('CLOSED', updatedInvoiceList[0].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[1].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[2].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[3].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[4].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[5].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[6].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[7].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[8].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[9].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[10].Status__c);


			List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT 	Id, Status__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList];

			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[0].Status__c);
			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[1].Status__c);

			List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
																FROM	PrerequisiteOrder__c
																WHERE	Id IN: salesOrderList];

			System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[0].Status__c);
			System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[1].Status__c);
		}
	}

	@isTest static void unPaidInvoices_TEST()
	{
		System.runAs(adminUser)
		{
			invoiceList[1].Status__c = ASPISConstants.INV_STATUS_PAYABLE;
			invoiceList[2].Status__c = ASPISConstants.INV_STATUS_PAYABLE;
			invoiceList[10].Status__c = ASPISConstants.INV_STATUS_PAYABLE;

			update invoiceList;

			ASPISBatchInvoice batch = new ASPISBatchInvoice();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Invoice__c> updatedInvoiceList = [SELECT 	Id, Status__c
												   FROM		Invoice__c
												   WHERE	Id IN: invoiceList];

			System.assertEquals('CLOSED', updatedInvoiceList[0].Status__c);
			System.assertEquals(invoiceList[1].Status__c, updatedInvoiceList[1].Status__c);
			System.assertEquals(invoiceList[2].Status__c, updatedInvoiceList[2].Status__c);
			System.assertEquals(invoiceList[3].Status__c, updatedInvoiceList[3].Status__c);
			System.assertEquals(invoiceList[4].Status__c, updatedInvoiceList[4].Status__c);
			System.assertEquals(invoiceList[5].Status__c, updatedInvoiceList[5].Status__c);
			System.assertEquals(invoiceList[6].Status__c, updatedInvoiceList[6].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[7].Status__c);
			System.assertEquals(invoiceList[8].Status__c, updatedInvoiceList[8].Status__c);
			System.assertEquals(invoiceList[9].Status__c, updatedInvoiceList[9].Status__c);
			System.assertEquals(invoiceList[10].Status__c, updatedInvoiceList[10].Status__c);


			List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT 	Id, Status__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList];

			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[0].Status__c);
			System.assertEquals(purchaseOrderList[1].Status__c, updatedPurchaseOrderList[1].Status__c);

			List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
																FROM	PrerequisiteOrder__c
																WHERE	Id IN: salesOrderList];

			System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[0].Status__c);
			System.assertEquals(salesOrderList[1].Status__c, updatedSalesOrderList[1].Status__c);
		}
	}

	@isTest static void paidAndClosedInvoices_TEST()
	{
		System.runAs(adminUser)
		{
			invoiceList[1].Status__c = 'CLOSED';
			invoiceList[2].Status__c = 'CLOSED';
			invoiceList[10].Status__c = 'CLOSED';

			ASPISBatchInvoice batch = new ASPISBatchInvoice();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Invoice__c> updatedInvoiceList = [SELECT 	Id, Status__c
												   FROM		Invoice__c
												   WHERE	Id IN: invoiceList];

			System.assertEquals('CLOSED', updatedInvoiceList[0].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[1].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[2].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[3].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[4].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[5].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[6].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[7].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[8].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[9].Status__c);
			System.assertEquals('CLOSED', updatedInvoiceList[10].Status__c);

			List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT 	Id, Status__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList];

			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[0].Status__c);
			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[1].Status__c);

			List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
																FROM	PrerequisiteOrder__c
																WHERE	Id IN: salesOrderList];

			System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[0].Status__c);
			System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[1].Status__c);
		}
	}

	@isTest static void sendEmail_TEST()
	{
		System.runAs(adminUser)
		{
			ASPISBatchInvoice batch = new ASPISBatchInvoice();
			batch.mapInvoiceError.put(invoiceList[0].Id, 'Test Error Message');

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();
		}
	}

	@isTest static void scheduleBatchInvoice()
	{
		System.runAs(adminUser)
		{
			ASPISBatchInvoice scheduler = new ASPISBatchInvoice();
			String sch = '0 0 0 * * ?';

			Test.startTest();
				Id processId = System.schedule('Test invoice batch scheduler', sch, scheduler);
			Test.stopTest();

			CronTrigger ct = [SELECT Id, CronExpression
							  FROM	 CronTrigger
							  WHERE	 Id =: processId];

			System.assertEquals(sch, ct.CronExpression);
		}
	}
}