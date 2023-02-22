/*************************************************************************************
Class Name - InvoiceTriggerHandler_TEST
Version - 1.0
Created Date - 28 APR 2016
Function - Test Class for InvoiceTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date         Description
* ----------            ----------   -----------------------
* Ashwina S             28/04/2016   Original Version
*************************************************************************************/
@isTest
private class InvoiceTriggerHandler_TEST{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<Invoice__c> invoiceList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderlineList;
	static list<Offer__c> offerList;
    static list<Case> caseList;

	static{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser){
			accountList = new List<Account>{
				TestFactory.createAccountBodyshop('BodyShop_1', 'ES'),
				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor1', 'FR'),
				TestFactory.createAccountDistributor('Distributor2', 'ES')
			};
			accountList[0].AXAPartner__c=true;
            accountList[0].IceInvTransmit__c=true;
			insert accountList;

			assessmentList = new List<Assessment__c>{
				TestFactory.createAssessment('Assessment1', accountList[0]),
				TestFactory.createAssessment('Assessment2', accountList[1])
			};

			assessmentList[1].TECH_EntityCountryCode__c = 'ES';
            assessmentList[1].NewCompensatedProcess__c = true;
            assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            assessmentList[0].recordtypeId=Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            assessmentList[0].EntityCode__c = '299';
            assessmentList[0].isShoppingList__c = false;
			assessmentList[0].ClaimReference__c = '0000009557973773';
            
			insert assessmentList;
            
            assessmentList[0].parentassessment__c=assessmentList[1].Id;
            update assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
				TestFactory.createSalesOrder(assessmentList[1], accountList[1], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[2], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[2], ASPISConstants.PUR_ORDER_STATUS_ISSUED),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[1], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[1], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[1], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};
			insert purchaseOrderList;

			invoiceList = new List<Invoice__c>{
				TestFactory.createBodyshopInvoice('INV-2811A', 98, ASPISConstants.INV_STATUS_SENT, salesOrderList[0]),
				TestFactory.createBodyshopInvoice('INV-2811B', 71, ASPISConstants.INV_STATUS_PAID, salesOrderList[0]),
				TestFactory.createBodyshopCreditNote('INV-2811C', 50, ASPISConstants.INV_STATUS_SENT, salesOrderList[1]),
				TestFactory.createBodyshopCreditNote('INV-2811D', 50, ASPISConstants.INV_STATUS_PAID, salesOrderList[1]),
				TestFactory.createDistributorCreditNote('INV-2812A', 14.40, ASPISConstants.INV_STATUS_SENT, purchaseOrderList[0]),
				TestFactory.createDistributorCreditNote('INV-2812B', 4.40, ASPISConstants.INV_STATUS_PAID, purchaseOrderList[0]),
				TestFactory.createDistributorInvoice('INV-2812C', 54.40, ASPISConstants.INV_STATUS_SENT, purchaseOrderList[1]),
				TestFactory.createDistributorInvoice('INV-2812D', 14.40, ASPISConstants.INV_STATUS_PAID, purchaseOrderList[1]),
				TestFactory.createBodyshopInvoice('INV-2812E', 71, 'RECEIVED', salesOrderList[0]),
				TestFactory.createBodyshopCreditNote('INV-2811Parent', 50, ASPISConstants.INV_STATUS_SENT, salesOrderList[1]),
                TestFactory.createBodyshopInvoice('INV-2911A', 98, ASPISConstants.INV_STATUS_SENT, salesOrderList[0])
			};

			invoiceList[1].Type__c= '';
			invoiceList[1].Assessment__c= null;
			invoiceList[3].Type__c= '';
			invoiceList[5].Type__c= '';
			invoiceList[5].Assessment__c= null;
			invoiceList[7].Type__c= '';
			invoiceList[0].PurchaseOrder__c = purchaseOrderList[0].Id;
            invoiceList[10].Assessment__c=assessmentList[0].Id;

			//Create several orderlines.
			orderlineList = new list<OrderLine__c>{
				TestFactory.createOrderLineFinal(50,purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[1], 'INDELIVERY')
			};
			insert orderlineList;

			//create offers
			offerList = new list<Offer__c>{
				TestFactory.createOfferLine(orderlineList[0], salesOrderList[0], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[1], salesOrderList[0], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[2], salesOrderList[0], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[3], salesOrderList[1], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[4], salesOrderList[1], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[5], salesOrderList[1], 'DELIVERED')
			};
			insert offerList;
            
            caseList = new List<Case>{
                new Case(PFR_TECH_STDClaimNr__c='0000009557973773',PFR_ASCompDecisionFinal__c='O',Origin='Email',CurrencyIsoCode='EUR',Status='Facturation')
            };
            insert caseList;
		}
	}

	@isTest static void invoiceTriggerHandlerInsertTest(){
		System.runAs(adminUser){
			Double totalBSPrice = 0;
            List<Case> test1=[select Id,PFR_TECH_STDClaimNr__c from case];
			system.debug('test1>>'+test1);
            test1[0].PFR_TECH_STDClaimNr__c='0000009557973773';
            update test1;
            List<Case> test2=[select Id,PFR_TECH_STDClaimNr__c from case];
            system.debug('test2>>'+test2);
			test.startTest();
				insert invoiceList;
			test.stopTest();

			List<Invoice__c> insertedInvoiceList = [Select Name, Assessment__c, Distributor__c, IsBodyShop__c, Type__c from Invoice__c where id IN :invoiceList];
			system.assertEquals(insertedInvoiceList[1].Type__c, 'INVOICE');
			system.assertEquals(insertedInvoiceList[1].IsBodyShop__c, true);

			for(Offer__c offer: [Select BSTotalPrice__c from Offer__c where Prerequisiteorder__c =:salesOrderList[0].Id]){
				totalBSPrice += offer.BSTotalPrice__c;
			}

			PrerequisiteOrder__c SO = [Select Assessment__c, Assessment__r.Status__c, TotalExpectedAmount__c from PrerequisiteOrder__c where id= :salesOrderList[0].Id];

			system.assertEquals(insertedInvoiceList[1].Assessment__c, SO.Assessment__c);
			system.assertNotEquals('PAID', SO.Assessment__r.Status__c);
			system.assertEquals(totalBSPrice, SO.TotalExpectedAmount__c);

			system.assertEquals(insertedInvoiceList[5].Type__c, 'CREDITNOTE');
			system.assertEquals(insertedInvoiceList[5].IsBodyShop__c, false);

			PurchaseOrder__c PO = [Select Assessment__c, Distributor__c, Assessment__r.Status__c from PurchaseOrder__c where id= :purchaseOrderList[0].Id];
			system.assertEquals(insertedInvoiceList[5].Assessment__c, PO.Assessment__c);
			system.assertEquals(insertedInvoiceList[5].Distributor__c, PO.Distributor__c);
			system.assertEquals('INVOICED', PO.Assessment__r.Status__c);
			// ABT 20-OCT-2016 - C-001677 - Commented the assert as TechToBeProcessed__c is no more used
			// system.assertEquals(true, PO.TechToBeProcessed__c);
		}
	}
	@isTest static void invoiceTriggerHandlerInsertCDFNonTest(){
		System.runAs(adminUser){
			Double totalBSPrice = 0;
            List<Case> test1=[select Id,PFR_TECH_STDClaimNr__c from case];
			system.debug('test1>>'+test1);
            test1[0].PFR_TECH_STDClaimNr__c='0000009557973773';
            test1[0].PFR_ASCompDecisionFinal__c=null;
            update test1;
            List<Case> test2=[select Id,PFR_TECH_STDClaimNr__c,PFR_ASCompDecisionFinal__c from case];
            system.debug('test2>>'+test2);
			test.startTest();
				insert invoiceList;
			test.stopTest();

			List<Invoice__c> insertedInvoiceList = [Select Name, Assessment__c, Distributor__c, IsBodyShop__c, Type__c from Invoice__c where id IN :invoiceList];
			system.assertEquals(insertedInvoiceList[1].Type__c, 'INVOICE');
			system.assertEquals(insertedInvoiceList[1].IsBodyShop__c, true);

			for(Offer__c offer: [Select BSTotalPrice__c from Offer__c where Prerequisiteorder__c =:salesOrderList[0].Id]){
				totalBSPrice += offer.BSTotalPrice__c;
			}

			PrerequisiteOrder__c SO = [Select Assessment__c, Assessment__r.Status__c, TotalExpectedAmount__c from PrerequisiteOrder__c where id= :salesOrderList[0].Id];

			system.assertEquals(insertedInvoiceList[1].Assessment__c, SO.Assessment__c);
			system.assertNotEquals('PAID', SO.Assessment__r.Status__c);
			system.assertEquals(totalBSPrice, SO.TotalExpectedAmount__c);

			system.assertEquals(insertedInvoiceList[5].Type__c, 'CREDITNOTE');
			system.assertEquals(insertedInvoiceList[5].IsBodyShop__c, false);

			PurchaseOrder__c PO = [Select Assessment__c, Distributor__c, Assessment__r.Status__c from PurchaseOrder__c where id= :purchaseOrderList[0].Id];
			system.assertEquals(insertedInvoiceList[5].Assessment__c, PO.Assessment__c);
			system.assertEquals(insertedInvoiceList[5].Distributor__c, PO.Distributor__c);
			system.assertEquals('INVOICED', PO.Assessment__r.Status__c);
		}
	}

	@isTest static void invoiceTriggerHandlerUpdateTest(){
		System.runAs(adminUser){
			insert invoiceList;

			test.startTest();
				invoiceList[0].Assessment__c= null;
				invoiceList[2].Status__c= 'PAID';
				//VR:updates not allowed for distributor invoice
				//invoiceList[6].Status__c= 'PAID';
				//invoiceList[6].Number__c = '21221';
				//invoiceList[7].Status__c= 'SENT';
				update invoiceList[0];
				update invoiceList[2];
			test.stopTest();

			// ABT 20-OCT-2016 - C-001677 - Commented the assert as TechToBeProcessed__c is no more used
			// system.assertEquals(true,  [Select TechToBeProcessed__c from PurchaseOrder__c where id= :purchaseOrderList[0].Id].TechToBeProcessed__c);

			List<Invoice__c> invoiceToQueryList = new List<Invoice__c>
			{
				invoiceList[0],
				invoiceList[2]
			};

			List<Invoice__c> updateInvoiceList = [	SELECT Id, Assessment__c, Status__c
													FROM	Invoice__c
													WHERE	Id IN: invoiceToQueryList];

			System.assertNotEquals(null, updateInvoiceList[0].Assessment__c);
			System.assertEquals(assessmentList[0].Id, updateInvoiceList[0].Assessment__c);
			System.assertEquals(ASPISConstants.INV_STATUS_PAID, updateInvoiceList[1].Status__c);
		}
	}

	// ABT 19-OCT-2016 - C-001677 - no more used
	// @isTest static void invoiceTriggerHandlerDeleteTest(){
	//     System.runAs(adminUser){
	//          Double totalBSPrice = 0;
	//         insert invoiceList;
	//
	//         test.startTest();
	//             delete [Select id from Invoice__c where id =:invoiceList[0].Id];
	//         test.stopTest();
	//
	//         for(Offer__c offer: [Select BSTotalPrice__c from Offer__c where Prerequisiteorder__c =:salesOrderList[0].Id]){
	//             totalBSPrice += offer.BSTotalPrice__c;
	//         }
	//
	//         system.assertEquals(totalBSPrice, [Select TotalExpectedAmount__c from PrerequisiteOrder__c where id= :salesOrderList[0].Id].TotalExpectedAmount__c);
	//     }
	// }

	// ABT 27-SEP-2016 - C-001480
	@isTest static void changeBodyShopInvoiceToSent_TEST()
	{
		System.runAs(adminUser)
		{
			// In this test nethod we will test if the sales order of an invoice becomes INVOICED when an invoice is set to SENT
			insert invoiceList;

			List<Invoice__c> bodyshopInvoices = new List<Invoice__c>
			{
				invoiceList[1],
				invoiceList[3]
			};

			bodyshopInvoices[0].Status__c = ASPISConstants.INV_STATUS_SENT;
			bodyshopInvoices[1].Status__c = ASPISConstants.INV_STATUS_SENT;

			Test.startTest();
				update bodyshopInvoices;
			Test.stopTest();

			List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT	Id, Status__c
																FROM	PrerequisiteOrder__c
																WHERE	Id IN: salesOrderList];

			System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INVOICED, updatedSalesOrderList[0].Status__c);
			System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INVOICED, updatedSalesOrderList[1].Status__c);
		}
	}

	// ABT 19-OCT-2016 - C-001677 - no more used
	// @isTest static void changeDistributorInvoiceToSent_TEST()
	// {
	// 	System.runAs(adminUser)
	// 	{
	// 		// In this test nethod we will test if the purchase order TechToBeProcessed__c is set to true when an invoice is set to PAID
	// 		insert invoiceList;
	//
	// 		List<Invoice__c> distributorInvoices = new List<Invoice__c>
	// 		{
	// 			invoiceList[4],
	// 			invoiceList[6]
	// 		};
	//
	// 		distributorInvoices[0].Status__c = ASPISConstants.INV_STATUS_PAID;
	// 		distributorInvoices[1].Status__c = ASPISConstants.INV_STATUS_PAID;
	//
	// 		Test.startTest();
	// 			update distributorInvoices;
	// 		Test.stopTest();
	//
	// 		Set<Id> purchaseOrderIdSet = new Set<Id>
	// 		{
	// 			distributorInvoices[0].PurchaseOrder__c,
	// 			distributorInvoices[1].PurchaseOrder__c
	// 		};
	//
	// 		List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT	Id, TechToBeProcessed__c
	// 															FROM	PurchaseOrder__c
	// 															WHERE	Id IN: purchaseOrderIdSet];
	//
	// 		System.assertEquals(true, updatedPurchaseOrderList[0].TechToBeProcessed__c);
	// 		System.assertEquals(true, updatedPurchaseOrderList[1].TechToBeProcessed__c);
	// 	}
	// }

	// ABT 13-JUN-2017 - Commented on Jonathan request
	// @isTest static void updateSpanishSalesOrder_TEST()
	// {
	// 	System.runAs(adminUser)
	// 	{
	// 		// insering the invoices first
	// 		insert invoiceList;

	// 		invoiceList[2].ParentInvoice__c = invoiceList[9].Id;
	// 		invoiceList[3].ParentInvoice__c = invoiceList[9].Id;
	// 		invoiceList[2].InvoiceSent__c = true;
	// 		invoiceList[3].InvoiceSent__c = true;

	// 		List<Invoice__c> invoiceToUpdateList = new List<Invoice__c>
	// 		{
	// 			invoiceList[2],
	// 			invoiceList[3]
	// 		};

	// 		//for(Invoice__c currentInvoice : [SELECT Id
	// 		//								 FROM	Invoice__c
	// 		//								 WHERE	PrerequisiteOrder__c =: salesOrderList[1].Id
	// 		//								 AND	ParentInvoice__c != null])
	// 		//{
	// 		//	currentInvoice.InvoiceSent__c = true;
	// 		//	invoiceToUpdateList.add(currentInvoice);
	// 		//}

	// 		// update the invoices
	// 		Test.startTest();
	// 			update invoiceToUpdateList;
	// 		Test.stopTest();

	// 		List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
	// 															FROM	PrerequisiteOrder__c
	// 															WHERE	Id IN: salesOrderList];

	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[1].Status__c);
	// 	}
	// }
}