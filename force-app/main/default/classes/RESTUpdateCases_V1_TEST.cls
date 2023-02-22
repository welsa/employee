/*************************************************************************************
Class Name - RESTUpdateCases_V1_Test
Version - 1.0
Created Date - 21 JULY 2015
Function - Test class for the web service RESTUpdateCases_V1

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga        21/07/2015  Original Version 
* Shamina M     20/01/2016  code review/updates to increase coverage 
*************************************************************************************/
@isTest
private class RESTUpdateCases_V1_TEST {
	static list<Account> l_Accounts;
	static List<Assessment__c> l_Assessments;
	static list<user> l_users;
	static list<PurchaseOrder__c> l_purchaseOrders;
	static list<PrerequisiteOrder__c> l_SalesOrders;
	static list<OrderLine__c> l_OrderLines;
	static list<Offer__c> l_Offers;
	static list<Invoice__c> l_Invoices;
	static list<Case__c> l_cases;
	static list<Case__c> casesSelected;
	static list<PrerequisiteOrder__c> selectedPrerequisiteOrdersList;
	
	static {

		l_Accounts = new list<Account>();
		l_Assessments = new list<Assessment__c>();
		l_users = new list<user>();
		l_purchaseOrders = new list<PurchaseOrder__c>();
		l_SalesOrders = new list<PrerequisiteOrder__c>();
		l_OrderLines =  new list<OrderLine__c>();
		l_Offers = new list<Offer__c>();
		l_Invoices = new list<Invoice__c>();
		l_cases = new list<Case__c>();
		casesSelected = new list<Case__c>();
		selectedPrerequisiteOrdersList = new list<PrerequisiteOrder__c>();

		 
		User user1 = TestFactory.createUser('ScUserTest');
		l_users.add(user1);
		insert l_users;    

		system.runas(l_users[0]){

			Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');//WCH 23/12/2020 C-004120
			bs1.ContactUser__c = l_users[0].Id;
			//bs1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId();
			bs1.ShippingCountryCode = 'FR';
			l_Accounts.add(bs1);
			Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'ES');
			bs2.ContactUser__c = l_users[0].Id;
			bs2.ReferenceNumber__c = '963258';
			l_Accounts.add(bs2);
			Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
			l_Accounts.add(dist1);
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
			PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs2, 'PREORDERCONFIRMED');
			so1.ReferenceNumber__c = '6893';
			l_SalesOrders.add(so1);
			PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'INDELIVERY');
			l_SalesOrders.add(so2);
			PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass3, bs2, 'PREORDERCONFIRMED');
			l_SalesOrders.add(so3);            
			insert l_SalesOrders;

			selectedPrerequisiteOrdersList = [Select Id,Name from PrerequisiteOrder__c where Id in:l_SalesOrders];

			// Create several Purchase Orders.
			PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
			l_purchaseOrders.add(po1_1);
			PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs2, dist1, 'DELIVEREDCONFIRMED');
			l_purchaseOrders.add(po1_2);
			PurchaseOrder__c po2_1 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
			l_purchaseOrders.add(po2_1);
			PurchaseOrder__c po2_2 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist1, 'DELIVEREDCONFIRMED');
			l_purchaseOrders.add(po2_2);
			PurchaseOrder__c po3 = TestFactory.createPurchaseOrder(ass2, so3, bs2, dist1, 'DELIVEREDCONFIRMED');
			l_purchaseOrders.add(po3);          
			insert l_purchaseOrders;

			//create invoices
			Invoice__c inv1 = TestFactory.createBodyshopInvoice('INV1212', 222, 'SENT', so1);
			inv1.Number__c = 'INV1212';
			l_Invoices.add(inv1);
			insert l_Invoices;

			Case__c c1 = TestFactory.createCase('testAssess',1,l_users[0]);
			c1.Assesment__c = ass1.Id;
			l_cases.add(c1);
			Case__c c2 = TestFactory.createCase('testPO',1,l_users[0]);
			c2.Purchase_order__c = po1_1.Id;
			l_cases.add(c2);
			Case__c c3 = TestFactory.createCase('testSO',1,l_users[0]);
			c3.Sales_order__c = so1.Id;
			l_cases.add(c3);
			insert l_cases;
			

			casesSelected = [select Name, Id from Case__c where Id in: l_cases];

		}
	}

	static testMethod void Test_TreatCase() {
		system.runAs(l_users[0]){   
			Restrequest req = new Restrequest();
			Restresponse res = new Restresponse();
			
			test.starttest();
				String jsonStr = '[{"CaseID":"'+casesSelected[0].Id+'","CaseName":"'+casesSelected[0].Name+'","BodyShopID":"963258","AssessmentId":"0912","CaseReason":"other","Comment":"Comments","Description":"Desc","DueDate":"2015-04-13T14:10:33.278Z","InternalComments":"Comments","InvoiceNumber":"INV1212","Origin":"Email","Priority":"Low","SalesOrderId":"6893","Status":"Assigned","Subject":"Subject","SubmittedBy":"Jonathan SABA","Type":"Problem"}]';
				req.httpMethod = 'POST';
				req.requestURI = '/v1.0/updateCases/*';
				req.requestBody = blob.valueOf(jsonStr); 
				RestContext.request = req;
				RestContext.response = res;
				RESTUpdateCases_V1.treatCase();
				Blob Json = RestContext.response.responseBody;
				//system.debug('>>> Json<<< : '+  Json.toString());
				system.assertEquals(true, Json != null); 
			test.stopTest();
		}
	}

	static testMethod void Test_TreatCaseNoName() {
		system.runAs(l_users[0]){   
			Restrequest req = new Restrequest();
			Restresponse res = new Restresponse();
			
			test.starttest();
				String jsonStr = '[{"CaseID":"a0I250000001iev","CaseName":"NomBanale","BodyShopID":"REF 001-003","AssessmentId":"JSA TEST 002ID01","CaseReason":"other","Comment":"Comments","Description":"Desc","DueDate":"2015-04-13T14:10:33.278Z","InternalComments":"Comments","InvoiceNumber":"INV-001","Origin":"Email","Priority":"Low","SalesOrderId":"SO-12513","Status":"Assigned","Subject":"Subject","SubmittedBy":"Jonathan SABA","Type":"Problem"}]';
				req.httpMethod = 'POST';
				req.requestURI = '/v1.0/updateCases/*';
				req.requestBody = blob.valueOf(jsonStr); 
				RestContext.request = req;
				RestContext.response = res;
				RESTUpdateCases_V1.treatCase();
				Blob Json = RestContext.response.responseBody;
				//system.debug('>>> Json<<< : '+  Json.toString());
				system.assertEquals(true, Json != null); 
			test.stopTest();
		}
	}   

	static testMethod void Test_TreatCaseAsync() {
	  system.runAs(l_users[0]){  
		Restrequest req = new Restrequest();
		  Restresponse res = new Restresponse();
		  
		  test.starttest();
			String jsonStr = '[{"CaseID":"a0I250000001iev","CaseName":"'+casesSelected[0].Name+'","BodyShopID":"REF 001-003","AssessmentId":"JSA TEST 002ID01","CaseReason":"other","Comment":"Comments","Description":"Desc","DueDate":"2015-04-13T14:10:33.278Z","InternalComments":"Comments","InvoiceNumber":"INV-001","Origin":"Email","Priority":"Low","SalesOrderId":"SO-12513","Status":"Assigned","Subject":"Subject","SubmittedBy":"Jonathan SABA","Type":"Problem"}]';
			  req.httpMethod = 'POST';
			  req.requestURI = '/v1.0/updateCases/*';
			  req.addHeader(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
			  req.requestBody = blob.valueOf(jsonStr); 
			  RestContext.request = req;
			  RestContext.response = res;
			  RESTUpdateCases_V1.treatCase();
			  Blob Json = RestContext.response.responseBody;
		  //system.debug('>>> Json<<< : '+  Json.toString());
		  system.assertEquals(true, Json != null); 
	  test.stopTest();
	  }
	}

	static testMethod void Test_TreatCaseSync() {
	  system.runAs(l_users[0]){  
		Restrequest req = new Restrequest();
		  Restresponse res = new Restresponse();
		  
		  test.starttest();
			String jsonStr = '[{"CaseID":"a0I250000001iev","CaseName":"'+casesSelected[0].Name+'","BodyShopID":"REF 001-003","AssessmentId":"JSA TEST 002ID01","CaseReason":"other","Comment":"Comments","Description":"Desc","DueDate":"2015-04-13T14:10:33.278Z","InternalComments":"Comments","InvoiceNumber":"INV-001","Origin":"Email","Priority":"Low","SalesOrderId":"SO-12513","Status":"Assigned","Subject":"Subject","SubmittedBy":"Jonathan SABA","Type":"Problem"}]';
			  req.httpMethod = 'POST';
			  req.requestURI = '/v1.0/updateCases/*';
			  req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
			  req.requestBody = blob.valueOf(jsonStr); 
			  RestContext.request = req;
			  RestContext.response = res;
			  RESTUpdateCases_V1.treatCase();
			  Blob Json = RestContext.response.responseBody;
		  //system.debug('>>> Json<<< : '+  Json.toString());
		  system.assertEquals(true, Json != null); 
	  test.stopTest();
	  }
	}

	static testMethod void Test_TreatCaseFail() {
	  system.runAs(l_users[0]){  
		Restrequest req = new Restrequest();
		  Restresponse res = new Restresponse();
		  
		  test.starttest();
			String jsonStr = '[{"CaseID":"a0I250000001iev","CaseName":"'+casesSelected[0].Name+'","BodyShopID":"REF 001-003","AssessmentId":"JSA TEST 002ID01","CaseReason":6,"Comment":"Comments","Description":"Desc","DueDate":"2015/04/13T14:10:33.278Z","InternalComments":"Comments","InvoiceNumber":"INV-001","Origin":"Email","Priority":"Low","SalesOrderId":"SO-12513","Status":"Assigned","Subject":"Subject","SubmittedBy":"Jonathan SABA","Type":"Problem"},{"CaseID":"a0I250000001iev","CaseName":"'+casesSelected[0].Name+'","BodyShopID":"REF 001-003","AssessmentId":"JSA TEST 002ID01","CaseReason":6,"Comment":"Comments","Description":"Desc","DueDate":"2015/04/13T14:10:33.278Z","InternalComments":"Comments","InvoiceNumber":"INV-001","Origin":"Email","Priority":"Low","SalesOrderId":"SO-12513","Status":"Assigned","Subject":"Subject","SubmittedBy":"Jonathan SABA","Type":"Problem"}]';
			  req.httpMethod = 'POST';
			  req.requestURI = '/v1.0/updateCases/*';
			  req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
			  req.requestBody = blob.valueOf(jsonStr); 
			  RestContext.request = req;
			  RestContext.response = res;
			  RESTUpdateCases_V1.treatCase();
			  Blob Json = RestContext.response.responseBody;
		  //system.debug('>>> Json<<< : '+  Json.toString());
		  system.assertEquals(true, Json != null); 
	  test.stopTest();
	  }
	}

	static testMethod void Test_CatchException() {
	  system.runAs(l_users[0]){  
		Restrequest req = new Restrequest();
		  Restresponse res = new Restresponse();
		  
		  test.starttest();
		  //Shamina M: 20160120 - dummy json string to test for catch exception section
			String jsonStr;
			for(integer i=0; i<3000; i++){
			  jsonStr += '******INVALID_JSON';
			} 
			req.httpMethod = 'POST';
			req.requestURI = '/v1.0/updateCases/*';
			req.addHeader(system.label.CALLTYPE,system.label.SYNCHRONOUS);
			req.requestBody = blob.valueOf(jsonStr); 
			RestContext.request = req;
			RestContext.response = res;
			RESTUpdateCases_V1.treatCase();
			Blob Json = RestContext.response.responseBody;
			jsonStr = Json.toString();
			//system.debug('>>> Json<<< : '+  jsonStr);
		  system.assertEquals(true, jsonStr.contains('Exceptions')); 
	  test.stopTest();
	  }
	}
}