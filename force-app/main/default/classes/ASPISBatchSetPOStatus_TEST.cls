/*************************************************************************************
Class Name - ASPISBatchSetPOStatus_TEST
Version - 1.0
Created Date - 01 Dec 2015
Function - Test Class sending invoices with status Payable and  record type Distributor to Exponens every night

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina S             17/02/2016  Original Version
* Shamina M             16/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S             18/01/2017  Case C-001860
*************************************************************************************/
@isTest
public with sharing class ASPISBatchSetPOStatus_TEST {
	static list<Account> l_Accounts;
	static List<Assessment__c> l_Assessments;
	static list<user> l_users;
	static list<PurchaseOrder__c> l_purchaseOrders;
	static list<PrerequisiteOrder__c> l_SalesOrders;
	static list<OrderLine__c> l_OrderLines;
	static list<Invoice__c> l_Invoices;
	//Shamina M:case 1386 - reverted back to std business hours
	static BusinessHours defaultHours;
	//static BusinessHoursSetting__mdt bhs;
	static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;
	static InvoiceMargin__c inv;
	static list<CaseDetailsProcessMapping__c> l_caseDetailsProcessMapping;
	static List<Group> groupList;
	static List<GroupMember> groupMemberList;


	static {
		// initialising variables
		l_Accounts = new list<Account>();
		l_Assessments = new list<Assessment__c>();
		l_users = new list<user>();
		l_purchaseOrders = new list<PurchaseOrder__c>();
		l_SalesOrders = new list<PrerequisiteOrder__c>();
		l_OrderLines =  new list<OrderLine__c>();
		l_Invoices = new list<Invoice__c>();
		l_cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>();

		// creating user
		User user1 = TestFactory.createUser('ScUserTest');
		l_users.add(user1);
		insert l_users;

		system.runas(l_users[0]){
			// initialising dates
			DateTime myDateTime = datetime.newInstance(2015, 2, 17);
			Date myDate = date.newInstance(2015, 2, 17);

			// Create several accounts
			Account bs1 = TestFactory.createAccountPayment('BodyShop_ScTest1', 'ES');
			bs1.ContactUser__c = l_users[0].Id;
			bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
			bs1.ShippingCountryCode = 'FR';
			//l_Accounts.add(bs1);

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
			PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
			po1_1.TechToBeProcessed__c = true;
			po1_1.TotalExpectedAmount__c = 40.00;
			l_purchaseOrders.add(po1_1);

			PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
			po1_2.TechToBeProcessed__c = true;
			l_purchaseOrders.add(po1_2);
			insert l_purchaseOrders;
			system.debug('######### inserted l_purchaseOrders:');

			// Create several orderlines.
			OrderLine__c ol1 = TestFactory.createOrderLineFinal(20,po1_1, 'DELIVERED');
			l_OrderLines.add(ol1);

			OrderLine__c ol2 = TestFactory.createOrderLineFinal(30,po1_1, 'DELIVERED');
			ol2.PartNumber__c = '1234';
			l_OrderLines.add(ol2);

			OrderLine__c ol3 = TestFactory.createOrderLineFinal(70,po1_2, 'DELIVERED');
			l_OrderLines.add(ol3);

			OrderLine__c ol4 = TestFactory.createOrderLineFinal(70,po1_2, 'DELIVERED');
			l_OrderLines.add(ol4);
			insert l_OrderLines;
			system.debug('######### inserted l_OrderLines:');


			// Create several invoices.
			Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 14.40, 'RECEIVED', po1_1);
			l_Invoices.add(inv1);

			Invoice__c inv2 = TestFactory.createDistributorCreditNote('INV-2812B', 4.40, 'RECEIVED', po1_2);
			l_Invoices.add(inv2);

			Invoice__c inv3 = TestFactory.createDistributorInvoice('INV-2812C', 54.40, 'RECEIVED', po1_1);
			l_Invoices.add(inv3);

			Invoice__c inv4 = TestFactory.createDistributorInvoice('INV-2812D', 14.40, 'RECEIVED', po1_2);
			l_Invoices.add(inv4);
			insert l_Invoices;

			// access Business Hours
			defaultHours = [select Id from BusinessHours where IsDefault=true];
			//bhs = [select Id from BusinessHoursSetting__mdt where DeveloperName='DEFAULT'];


			// create countryCode
			CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
			l_cs_CountryCodeIngformation.add(countryCode1);
			CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);
			countryCode2.URLInvoiceDistributor__c= 'xxxxx';
			countryCode2.LoginInvoiceDistributor__c = 'login';
			countryCode2.PasswordInvoiceDistributor__c = 'pwd';
			l_cs_CountryCodeIngformation.add(countryCode2);
			insert l_cs_CountryCodeIngformation;

			inv = new InvoiceMargin__c(Name='FR', CountryCode__c='FR', ValidationMargin__c=1);
			//insert inv;

			l_caseDetailsProcessMapping = TestFactory.createCaseDetailsProcessMapping();
			insert l_caseDetailsProcessMapping;

			groupList = new List<Group>{ new Group(Name = 'SystemAdmins', Type = 'Regular')};
			insert groupList;

			groupMemberList = new List<GroupMember>{new GroupMember(GroupId = groupList[0].Id, UserOrGroupId = l_users[0].Id)};			
			insert groupMemberList;
		}
	}

	static testMethod void TestASPISBatchSetPOStatus() {
		system.runas(l_users[0]){
			Test.startTest();
				Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
			Test.stopTest();

			PurchaseOrder__c po = [Select Status__c, TechToBeProcessed__c,InvoiceStatus__c,TotalInvoicesAmount__c, TotalExpectedAmount__c from PurchaseOrder__c where id =: l_purchaseOrders[0].id];
			system.debug('######### po:'+po.TotalExpectedAmount__c);
			System.assertEquals(po.Status__c, 'PAYABLE');
			// ABT - 20-OCT-2016 - C-001677 - Commented the assert as it is no more used
			//System.assertEquals(po.TechToBeProcessed__c, false);
			System.assertEquals(po.TotalInvoicesAmount__c, 40.00);
			System.assertEquals(po.TotalExpectedAmount__c, 40.00);
			System.assertEquals(po.InvoiceStatus__c, 'VALIDATED');
		}
	}

	static testMethod void TestASPISBatchSetPOStatusWithInvoiceMargin() {
		system.runas(l_users[0]){
			Test.startTest();
				insert inv;
				Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
			Test.stopTest();

			PurchaseOrder__c po = [Select Status__c, TechToBeProcessed__c,InvoiceStatus__c,TotalInvoicesAmount__c, TotalExpectedAmount__c from PurchaseOrder__c where id =: l_purchaseOrders[0].id];
			system.debug('######### po:'+po.TotalExpectedAmount__c);
			System.assertEquals(po.Status__c, 'PAYABLE');
			// ABT - 20-OCT-2016 - C-001677 - Commented the assert as it is no more used
			//System.assertEquals(po.TechToBeProcessed__c, false);
			System.assertEquals(po.TotalInvoicesAmount__c, 40.00);
			System.assertEquals(po.TotalExpectedAmount__c, 40.00);
			System.assertEquals(po.InvoiceStatus__c, 'VALIDATED');
		}
	}

	// ABT - 14 JUN 2017 Commented as this part is handled by ASPISBatchInvoice
	//  static testMethod void TestASPISBatchSetPOStatusPOPaid() {
	// 	Test.startTest();
	// 		l_Invoices[0].Status__c = 'PAID';
	// 		l_Invoices[2].Status__c = 'PAID';
	// 		l_purchaseOrders[0].TechToBeProcessed__c = true;
	// 		//ASE: 18/01/2017  Case C-001860: changed from payable to DELIVEREDCONFIRMED
	// 		l_purchaseOrders[0].Status__c='DELIVEREDCONFIRMED';

	// 		update l_Invoices;
	// 		update l_purchaseOrders;

	// 		Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
	// 	Test.stopTest();

	// 	// ABT - 20-OCT-2016 - C-001677 - Changed the assert as the purchase order will be in closedok when set paid as it was not canceled
	// 	// System.assertEquals([Select Status__c from PurchaseOrder__c where id =: l_purchaseOrders[0].id].Status__c, 'PAID');
	// 	System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, [Select Status__c from PurchaseOrder__c where id =: l_purchaseOrders[0].id].Status__c);
	// }
	//ASE: 18/01/2017  Case C-001860: case is no more created
	/*static testMethod void TestASPISBatchSetPOStatusCreateCase() {
		Test.startTest();
			l_purchaseOrders[0].Status__c = 'INDELIVERY';
			l_purchaseOrders[0].TechToBeProcessed__c = true;
			l_purchaseOrders[0].NotDeliveredCaseCreated__c = false;
			update l_purchaseOrders;

			Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
		Test.stopTest();

		System.assertEquals([Select Id, Purchase_order__c  from Case__c where Purchase_order__c =: l_purchaseOrders[0].id].size(), 1);
	}
*/
	static testMethod void TestASPISBatchSetPOStatusCreateCaseSCH() {
		system.runas(l_users[0]){
			test.startTest();
				for(CronTrigger c : [Select Id From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'testBatchSetPOStatus' and JobType = '7')]){
					System.abortJob(c.id);
				}

				ASPISBatchSetPOStatus  testBatchSetPOStatus = new ASPISBatchSetPOStatus();
				String sch = '0 0 0 * * ?';
				system.schedule('testBatchSetPOStatus', sch, testBatchSetPOStatus);

				CronTrigger ct =[Select Id,CronExpression, TimesTriggered, NextFireTime From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'testBatchSetPOStatus' and JobType = '7')];
				System.assertEquals('0 0 0 * * ?', ct.CronExpression);
				System.assertEquals(0, ct.TimesTriggered);
			test.stopTest();
		}
	}

	//static testMethod void TestASPISBatchSetPOStatusPOFailed() {
	//	system.runas(l_users[0]){
	//		update new user(Id = l_users[0].Id, BypassValidationRules__c = true);	
		
	//		l_Invoices[0].Status__c = 'PAID';
	//		l_Invoices[2].Status__c = 'PAID';			
	//		l_purchaseOrders[0].Status__c='DELIVEREDCONFIRMED';
	//		l_purchaseOrders[0].Distributor__c=l_Accounts[3].Id;
			
	//		update l_Invoices;
	//		update l_purchaseOrders;
	//		update l_Accounts;

	//		update new user(Id = l_users[0].Id, BypassValidationRules__c = false);	

	//		Test.startTest();
	//			Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
	//		Test.stopTest();

	//		System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED, [Select Status__c from PurchaseOrder__c where id =: l_purchaseOrders[0].id].Status__c);
	//	}
	//}


	@isTest static void setAllInvoicesOfCanceledInvoiceToPaid()
	{
		System.runAs(l_users[0])
		{
			l_purchaseOrders[0].Status__c = 'CANCELEDINVOICE';

			update l_purchaseOrders;

			List<Invoice__c> invToUpdateList = new List<Invoice__c>();
			for(Invoice__c currentInvoice : [SELECT Id
											 FROM 	Invoice__c
											 WHERE	PurchaseOrder__c =: l_purchaseOrders])
			{
				currentInvoice.Status__c = 'PAID';
				invToUpdateList.add(currentInvoice);
			}

			update invToUpdateList;

			Test.startTest();
				Database.executeBatch(new ASPISBatchSetPOStatus(), 200);
			Test.stopTest();

			// ABT - 14 JUN 2017 Commented as this part is handled by ASPISBatchInvoice but the status must not change
			// System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, [Select Status__c from PurchaseOrder__c where id =: l_purchaseOrders[0].id].Status__c);
			System.assertEquals('CANCELEDINVOICE', [Select Status__c from PurchaseOrder__c where id =: l_purchaseOrders[0].id].Status__c);
		}
	}

	@isTest static void sendEmail(){
		System.runAs(l_users[0]){ 
			Map<String, String> mapInvErrorsCreation = new Map<String, String>{l_Invoices[0].Id => 'Error: Invoice rejected: Inconcistency found with the Distributor of the PO', l_Invoices[2].Id => 'Error: Invoice rejected: Inconcistency found with the Distributor of the PO'};		
	    	Map<String, String> mapPOErrorsCreation = new Map<String, String>{l_purchaseOrders[1].id => 'Error'};	
	    	
	    	test.startTest();
				ASPISBatchSetPOStatus ASPISBatchSetPOStatusClass = new ASPISBatchSetPOStatus();
				ASPISBatchSetPOStatusClass.sendErrorEmail(mapInvErrorsCreation, mapPOErrorsCreation);
				Integer invocations = Limits.getEmailInvocations();
			test.stopTest();

			System.assertNotEquals(0, invocations);
		 

		}
	}
}