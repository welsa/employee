/*************************************************************************************
Class Name - 9
Version - 1.0
Created Date - 03 March 2016
Function - Test Class AP13SetPOStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina S             03/03/2016  Original Version
* Ashwina S 			18/01/2017 : case C-001860
* Welsa C   			23/12/2020 : C-004120 - Format du Reference Number
*************************************************************************************/
@isTest
private class AP13SetPOStatus_TEST {
	static List<Account> l_Accounts;
	static List<Assessment__c> l_Assessments;
	static List<User> l_users;
	static List<PurchaseOrder__c> l_purchaseOrders;
	static List<PrerequisiteOrder__c> l_SalesOrders;
	static List<Invoice__c> l_Invoices;
	static BusinessHours defaultHours;
	static List<OrderLine__c> orderLineList;

	static {
		// initialising variables
		l_Accounts = new List<Account>();
		l_Assessments = new List<Assessment__c>();
		l_users = new List<user>();
		l_purchaseOrders = new List<PurchaseOrder__c>();
		l_SalesOrders = new List<PrerequisiteOrder__c>();
		l_Invoices = new List<Invoice__c>();

		// creating user
		User user1 = TestFactory.createUser('ScUserTest');
		l_users.add(user1);
		insert l_users;

		system.runas(l_users[0]){
			// initialising dates
			DateTime myDateTime = datetime.newInstance(2015, 2, 17);
			Date myDate = date.newInstance(2015, 2, 17);

			// Create several accounts
			Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');//WCH 23/12/2020 C-004120
			bs1.ContactUser__c = l_users[0].Id;
			//bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
			bs1.ShippingCountryCode = 'FR';
			l_Accounts.add(bs1);

			Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
			bs2.ContactUser__c = l_users[0].Id;
			l_Accounts.add(bs2);

			Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
			l_Accounts.add(dist1);

			Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
			l_Accounts.add(dist2);
			insert l_Accounts;


			// Create several Assessments
			Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);
			ass1.AssessmentID__c = '0912';
			l_Assessments.add(ass1);

			Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
			l_Assessments.add(ass2);

			Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
			l_Assessments.add(ass3);
			insert l_Assessments;


			// Create severals Sales Orders
			PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'DELIVEREDCONFIRMED');
			l_SalesOrders.add(so1);

			PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'DELIVEREDCONFIRMED');
			l_SalesOrders.add(so2);

			PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, 'DELIVEREDCONFIRMED');
			l_SalesOrders.add(so3);
			insert l_SalesOrders;


			// Create several Purchase Orders.
			PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DRAFTQUOTE');
			l_purchaseOrders.add(po1_1);

			PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
			l_purchaseOrders.add(po1_2);

			// ABT 19-OCT-2016 - C-001677
			PurchaseOrder__c po1_3 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO);
			l_purchaseOrders.add(po1_3);

			PurchaseOrder__c po1_4 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK);
			l_purchaseOrders.add(po1_4);

			insert l_purchaseOrders;

			orderLineList = new List<OrderLine__c>{
				TestFactory.createOrderLineFinal(1000, l_purchaseOrders[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, l_purchaseOrders[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, l_purchaseOrders[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
			};
			

			// Create several invoices.
			Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 14.40, 'PAID', po1_1);
			l_Invoices.add(inv1);

			Invoice__c inv2 = TestFactory.createDistributorCreditNote('INV-2812B', 4.40, 'PAID', po1_2);
			l_Invoices.add(inv2);

			Invoice__c inv3 = TestFactory.createDistributorInvoice('INV-2812C', 54.40, 'PAID', po1_1);
			l_Invoices.add(inv3);

			Invoice__c inv4 = TestFactory.createDistributorInvoice('INV-2812D', 14.40, 'PAID', po1_2);
			l_Invoices.add(inv4);

			Invoice__c inv5= TestFactory.createBodyshopInvoice('INV-2812E', 14.40, 'PAID', so1);
			l_Invoices.add(inv5);

			Invoice__c inv6= TestFactory.createBodyshopInvoice('INV-2812E', 14.40, 'PAID', so2);
			l_Invoices.add(inv6);

			// ABT 19-OCT-2016 - C-001677
			Invoice__c inv7 = TestFactory.createDistributorCreditNote('INV-2812G', 14.40, ASPISConstants.INV_STATUS_SENT, po1_3);
			l_Invoices.add(inv7);

			Invoice__c inv8 = TestFactory.createDistributorCreditNote('INV-2812H', 4.40, ASPISConstants.INV_STATUS_SENT, po1_4);
			l_Invoices.add(inv8);

			Invoice__c inv9 = TestFactory.createDistributorInvoice('INV-2812I', 54.40, ASPISConstants.INV_STATUS_SENT, po1_3);
			l_Invoices.add(inv9);

			Invoice__c inv10 = TestFactory.createDistributorInvoice('INV-2812K', 14.40, ASPISConstants.INV_STATUS_SENT, po1_4);
			l_Invoices.add(inv10);
		}
	}

	// No more used
	// static testMethod void TestInsertInvoicesDistributor() {
	// 	Test.startTest();
	// 	system.debug('#### PO:'+[Select TechToBeProcessed__c from PurchaseOrder__c where id =:l_purchaseOrders[0].id].TechToBeProcessed__c);

	// 		insert l_Invoices;
	// 	Test.stopTest();
	// 	system.assertEquals([Select TechToBeProcessed__c from PurchaseOrder__c where id =:l_purchaseOrders[0].id].TechToBeProcessed__c, true);
	// }

	// ABT 19-OCT-2016 - C-001677
	@isTest static void reopenPurchaseOrder_TEST()
	{
		System.runAs(l_users[0])
		{
			// insering the invoices to test if the closed purchase orders are reopened and the already opened purchase orders does not change status
			Test.startTest();
				insert l_Invoices;
			Test.stopTest();

			// Selecting all the purchase orders again
			List<PurchaseOrder__c> updatedPurchaseOrdersList = [SELECT 	Id, Status__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: l_purchaseOrders];

			System.assertEquals(l_purchaseOrders[0].Status__c, updatedPurchaseOrdersList[0].Status__c);
			System.assertEquals(l_purchaseOrders[1].Status__c, updatedPurchaseOrdersList[1].Status__c);
			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE, updatedPurchaseOrdersList[2].Status__c);
			// ABT - 29-JUN-2017 - C-001938 Changed Payable to DELIVEREDCONFIRMED
			// System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_PAYABLE, updatedPurchaseOrdersList[3].Status__c);
			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED, updatedPurchaseOrdersList[3].Status__c);
		}
	}

	// ASE 18/01/2017 : case C-001860
	@isTest static void reopenPurchaseOrderWithCanceledOrderLine_TEST()
	{
		System.runAs(l_users[0])
		{
			// insering the invoices to test if the closed purchase orders are reopened and the already opened purchase orders does not change status
			Test.startTest();
				insert orderLineList;
				l_purchaseOrders[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_PAYABLE;
				update l_purchaseOrders[0];
				orderLineList[0].DeliveryStatus__c =ASPISConstants.ORD_LINE_STATUS_RETURNED;
				update orderLineList[0];
			Test.stopTest();

			// Selecting all the purchase orders again
			List<PurchaseOrder__c> updatedPurchaseOrdersList = [SELECT 	Id, Status__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: l_purchaseOrders];
			system.debug('## updatedPurchaseOrdersList:' +updatedPurchaseOrdersList);													
			System.assertEquals('DELIVEREDCONFIRMED', updatedPurchaseOrdersList[1].Status__c);
			
		}
	}
}