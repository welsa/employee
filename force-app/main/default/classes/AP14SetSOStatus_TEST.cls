/*************************************************************************************
Class Name - 9
Version - 1.0
Created Date - 03 March 2016
Function - Test Class AP14SetSOStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina S             03/03/2016  Original Version
*************************************************************************************/
@isTest
private class AP14SetSOStatus_TEST {
	// ABT - 05-JUL-2017 - C-001938 - Commented as there are no more active methods in AP14
	/*
	static list<Account> l_Accounts;
	static List<Assessment__c> l_Assessments;
	static list<user> l_users;
	static list<PurchaseOrder__c> l_purchaseOrders;
	static list<PrerequisiteOrder__c> l_SalesOrders;
	static list<Invoice__c> l_Invoices;
	static BusinessHours defaultHours;

	static {
		// initialising variables
		l_Accounts = new list<Account>();
		l_Assessments = new list<Assessment__c>();
		l_users = new list<user>();
		l_purchaseOrders = new list<PurchaseOrder__c>();
		l_SalesOrders = new list<PrerequisiteOrder__c>();
		l_Invoices = new list<Invoice__c>();

		// creating user
		User user1 = TestFactory.createUser('ScUserTest');
		l_users.add(user1);
		insert l_users;

		System.runas(l_users[0]){
			// initialising dates
			DateTime myDateTime = datetime.newInstance(2015, 2, 17);
			Date myDate = date.newInstance(2015, 2, 17);

			// Create several accounts
			Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
			bs1.ContactUser__c = l_users[0].Id;
			bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
			bs1.ShippingCountryCode = 'FR';
			l_Accounts.add(bs1);

			Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
			bs2.ContactUser__c = l_users[0].Id;
			l_Accounts.add(bs2);

			Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ES', 'ES');
			bs3.ContactUser__c = l_users[0].Id;
			l_Accounts.add(bs3);

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

			// ABT - 06-DEC-2016 - C-001677
			Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs3);
			ass4.TECH_EntityCountryCode__c = 'ES';
			l_Assessments.add(ass4);

			Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs3);
			ass5.TECH_EntityCountryCode__c = 'ES';
			l_Assessments.add(ass5);

			insert l_Assessments;


			// Create severals Sales Orders
			PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED);
			//so1.RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();
			l_SalesOrders.add(so1);

			PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, ASPISConstants.PRE_ORDER_STATUS_INVOICED);
			//so2.RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();
			l_SalesOrders.add(so2);

			// ABT 19-OCT-2016 - C-001677
			PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO);
			l_SalesOrders.add(so3);

			// ABT 06-DEC-2016 - C-001677
			PrerequisiteOrder__c so4 = TestFactory.createSalesOrder(ass4, bs3, ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED);
			l_SalesOrders.add(so4);

			PrerequisiteOrder__c so5 = TestFactory.createSalesOrder(ass5, bs3, ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE);
			l_SalesOrders.add(so5);

			insert l_SalesOrders;

			// Create several invoices.
			Invoice__c inv1= TestFactory.createBodyshopInvoice('INV-2812D', 14.40, 'PAID', so1);
			l_Invoices.add(inv1);

			Invoice__c inv2= TestFactory.createBodyshopInvoice('INV-2812E', 14.40, 'SENT', so1);
			l_Invoices.add(inv2);

			Invoice__c inv3= TestFactory.createBodyshopCreditNote('INV-2812E', 14.40, 'PAID', so2);
			l_Invoices.add(inv3);
			
			// ABT 19-OCT-2016 - C-001677
			Invoice__c inv4 = TestFactory.createBodyshopInvoice('INV-2812AA', 50.00, ASPISConstants.INV_STATUS_SENT, so3);
			l_Invoices.add(inv4);

			// ABT 06-DEC-2016 - C-001677
			Invoice__c inv5 = TestFactory.createBodyshopInvoice('INV-2812AB', 50.00, ASPISConstants.INV_STATUS_SENT, so4);
			l_Invoices.add(inv5);

			Invoice__c inv6 = TestFactory.createBodyshopInvoice('INV-2812ABChild', 50.00, ASPISConstants.INV_STATUS_SENT, so4);
			l_Invoices.add(inv6);

			Invoice__c inv7 = TestFactory.createBodyshopInvoice('INV-2812AC', 50.00, ASPISConstants.INV_STATUS_SENT, so5);
			l_Invoices.add(inv7);

			Invoice__c inv8 = TestFactory.createBodyshopInvoice('INV-2812ACChild', 50.00, ASPISConstants.INV_STATUS_SENT, so5);
			l_Invoices.add(inv8);
		}
	}*/

	// commented as the new test method covers the same thing
	// static testMethod void testInsertInvoicesUpdatePOInvoiced() {
	// 	System.runas(l_users[0]){
	// 		Test.startTest();
	// 			insert l_Invoices;
	// 		Test.stopTest();
	// 		System.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: l_SalesOrders[0].id].Status__c, 'INVOICED');
	// 	}
	// }

	// Commented as these are not test method....missing @isTest or testMethod in Function definition
	// static void testInsertInvoicesUpdatePOPaid() {
	//   // All invoices inserted have status Payable
	// 	System.runas(l_users[0]){
	// 		test.startTest();
	// 			l_Invoices[0].Status__c = 'PAID';
	// 			insert l_Invoices;
	// 		test.stopTest();
	// 		System.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: l_SalesOrders[0].id].Status__c, 'PAID');
	// 	}
	// }

	// static void testUpdateInvoicesUpdatePOInvoiced() {
	//   // Not all invoices updated have status Payable
	// 	System.runas(l_users[0]){
	// 		test.startTest();
	// 	  	insert l_Invoices;
	// 		l_Invoices[1].Status__c ='SENT';
	// 		update l_Invoices;
	// 		test.stopTest();
	// 		System.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: l_SalesOrders[0].id].Status__c, 'INVOICED');
	//   	}
	// }

	// static void testUpdateInvoicesUpdatePOPaid() {
	// // All invoices updated have status Payable
	// 	System.runas(l_users[0]){
	// 		test.startTest();
	// 			insert l_Invoices;
	// 			l_Invoices[0].Status__c = 'PAID';
	// 			update l_Invoices;
	// 		test.stopTest();
	// 		System.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: l_SalesOrders[0].id].Status__c, 'PAID');
	// 	}
	// }

	// ABT - 05-JUL-2017 - C-001938 - Commented as it is no more called in trigger
	// @isTest static void updateSalesOrderInvoicedV2OnInsert_TEST()
	// {
	// 	System.runAs(l_users[0])
	// 	{
	// 		// testing the insert of invoices
	// 		Test.startTest();
	// 			insert l_Invoices;
	// 		Test.stopTest();

	// 		// Retrieving the Sales order having at least 1 invoice with status SENT
	// 		List<PrerequisiteOrder__c> salesOrderWithSentInvoiceList = new List<PrerequisiteOrder__c>
	// 		{
	// 			l_SalesOrders[0],
	// 			l_SalesOrders[2]
	// 		};

	// 		List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
	// 															FROM	PrerequisiteOrder__c
	// 															WHERE	Id IN: salesOrderWithSentInvoiceList];
			
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INVOICED, updatedSalesOrderList[0].Status__c);
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE, updatedSalesOrderList[1].Status__c);
	// 	}
	// }

	// ABT 13-JUN-2017 - Commented on Jonathan request
	// @isTest static void updateSalesOrderPaidOnInsert_TEST()
	// {
	// 	System.runAs(l_users[0])
	// 	{
	// 		// testing the insertion of invoices
	// 		Test.startTest();
	// 			insert l_Invoices;
	// 		Test.stopTest();

	// 		// Retrieving sales order with all invoices to PAID...there's only 1
	// 		PrerequisiteOrder__c updatedSalesOrder = [	SELECT 	Id, Status__c
	// 													FROM	PrerequisiteOrder__c
	// 													WHERE	Id =: l_SalesOrders[1].Id];
			
	// 		// Sales order is updated to PAID and then the trigger of sales order will set it to CLOSEDOK 
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrder.Status__c);
	// 	}
	// }

	// ABT - 05-JUL-2017 - C-001938 - Commented as it is no more called in trigger
	// @isTest static void updateSalesOrderInvoicedV2OnUpdate_TEST()
	// {
	// 	System.runAs(l_users[0])
	// 	{
	// 		l_Invoices[1].Status__c = ASPISConstants.INV_STATUS_PAID;
	// 		l_Invoices[3].Status__c = ASPISConstants.INV_STATUS_PAID;

	// 		// insering the invoices first
	// 		insert l_Invoices;

	// 		// Setting at least 1 invoice per sales order to sent
	// 		l_Invoices[0].Status__c = ASPISConstants.INV_STATUS_SENT;
	// 		l_Invoices[2].Status__c = ASPISConstants.INV_STATUS_SENT;
	// 		l_Invoices[3].Status__c = ASPISConstants.INV_STATUS_SENT;

	// 		// update the invoices
	// 		Test.startTest();
	// 			update l_Invoices;
	// 		Test.stopTest();

	// 		List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
	// 															FROM	PrerequisiteOrder__c
	// 															WHERE	Id IN: l_SalesOrders];

	// 		// Sales orders are reopened
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INVOICED, updatedSalesOrderList[0].Status__c);
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INVOICED, updatedSalesOrderList[1].Status__c);
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE, updatedSalesOrderList[2].Status__c);
	// 	}
	// }

	// ABT 13-JUN-2017 - Commented on Jonathan request
	// @isTest static void updateSalesOrderPaidOnUpdate_TEST()
	// {
	// 	System.runAs(l_users[0])
	// 	{
	// 		l_Invoices[0].Status__c = ASPISConstants.INV_STATUS_SENT;
	// 		l_Invoices[2].Status__c = ASPISConstants.INV_STATUS_SENT;

	// 		// insering the invoices first
	// 		insert l_Invoices;

	// 		// Setting all invoice per sales order to sent except for 1st salesorder
	// 		l_Invoices[0].Status__c = ASPISConstants.INV_STATUS_PAID;
	// 		l_Invoices[2].Status__c = ASPISConstants.INV_STATUS_PAID;
	// 		l_Invoices[3].Status__c = ASPISConstants.INV_STATUS_PAID;

	// 		// update the invoices
	// 		Test.startTest();
	// 			update l_Invoices;
	// 		Test.stopTest();

	// 		List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
	// 															FROM	PrerequisiteOrder__c
	// 															WHERE	Id IN: l_SalesOrders];

	// 		// Sales orders are closed except the 1st sales order which does not have all invoices to paid
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INVOICED, updatedSalesOrderList[0].Status__c);
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[1].Status__c);
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO, updatedSalesOrderList[2].Status__c);
	// 	}
	// }

	// ABT 13-JUN-2017 - Commented on Jonathan request
	// @isTest static void updateSpanishSalesOrder_TEST()
	// {
	// 	System.runAs(l_users[0])
	// 	{
	// 		// insering the invoices first
	// 		insert l_Invoices;

	// 		l_Invoices[5].ParentInvoice__c = l_Invoices[4].Id;
	// 		l_Invoices[7].ParentInvoice__c = l_Invoices[6].Id;
	// 		l_Invoices[5].InvoiceSent__c = true;
	// 		l_Invoices[7].InvoiceSent__c = true;

	// 		// update the invoices
	// 		Test.startTest();
	// 			update l_Invoices;
	// 		Test.stopTest();

	// 		List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT 	Id, Status__c
	// 															FROM	PrerequisiteOrder__c
	// 															WHERE	Id IN: l_SalesOrders];

	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[3].Status__c);
	// 		System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO, updatedSalesOrderList[4].Status__c);
	// 	}
	// }
}