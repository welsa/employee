/*************************************************************************************
Class Name - CaseTriggerHandler_TEST
Version - 1.0
Created Date - 09 MARCH 2015
Function - TestClass to CaseTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      09/03/2016  Reworked Version
*************************************************************************************/
@isTest
private class CaseTriggerHandler_TEST {
	static list<Account> l_Accounts;
    static List<Assessment__c> l_Assessments;
    static list<user> l_users;
    static list<PurchaseOrder__c> l_purchaseOrders;
    static list<PrerequisiteOrder__c> l_SalesOrders;
	static list<Case__c> l_cases;
	static list<Case__c> caseListCreatedByUser1;
	static list<Case__c> caseListCreatedByUser2;
    static list<CountryCodeInformationsMapping__c> l_cs_CountryCodeIngformation;
    static BusinessHours defaultHours;

	// ABT 21-APR-2015
	static List<Group> queueList;
	static List<QueueSobject> queueMappingList;
	static List<CountryQueueMapping__c> countryQueueMappingList;
	static List<CaseDetailsProcessMapping__c> caseMappingList;

	static {
        // initialising variables
        l_Accounts = new list<Account>();
        l_Assessments = new list<Assessment__c>();
        l_users = new list<user>();
        l_purchaseOrders = new list<PurchaseOrder__c>();
        l_SalesOrders = new list<PrerequisiteOrder__c>();
        l_cases = new list<Case__c>();
        l_cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>();

        User user1 = TestFactory.createUser('ScUserTest');
		user1.BodyShopID__c = '000007';
        l_users.add(user1);

		User user2 = TestFactory.createUser('ScUserTest');
		user2.DistributorID__c = '000001';
        l_users.add(user2);

		User user3 = TestFactory.createUser('ScUserTest');
        l_users.add(user3);

        insert l_users;
        
        system.runas(l_users[0]){
            // initialising dates
            DateTime myDateTime = datetime.newInstance(2015, 2, 17);
            Date myDate = date.newInstance(2015, 2, 17);
        
             // Create several accounts
            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'ES');
            l_Accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            l_Accounts.add(bs2);   

            Account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', '');
            l_Accounts.add(bs3);    
        
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            l_Accounts.add(dist1);  
        
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            l_Accounts.add(dist2);
            insert l_Accounts;        
            
            // Create several Assessments
            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.TECH_EntityCountryCode__c= 'ES';
            ass1.AssessmentID__c = '0912';
            l_Assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);
            l_Assessments.add(ass2);
        
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
            l_Assessments.add(ass3);        
            insert l_Assessments;
        
            
            // Create severals Sales Orders
            PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(ass1, bs1, 'INDELIVERY');
            so1.SLAInDeliveryLevel3__c = System.today();
            l_SalesOrders.add(so1);
        
            PrerequisiteOrder__c so2 = TestFactory.createSalesOrder(ass2, bs2, 'INDELIVERY');
            so2.SLAInDeliveryLevel3__c = System.today();
            l_SalesOrders.add(so2);
            
            PrerequisiteOrder__c so3 = TestFactory.createSalesOrder(ass1, bs1, 'DELIVERED');
            so3.SLAInDeliveryLevel3__c = System.today();
            l_SalesOrders.add(so3);

            PrerequisiteOrder__c so4 = TestFactory.createSalesOrder(ass1, bs3, 'DELIVERED');
            so4.SLAInDeliveryLevel3__c = System.today();
            l_SalesOrders.add(so4);
       
            insert l_SalesOrders;
        

            // Create several Purchase Orders.
            PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'ISSUED');
            po1_1.BodyShopOrderNumber__c = '2812';
            l_purchaseOrders.add(po1_1);
        
            PurchaseOrder__c po1_2 = TestFactory.createPurchaseOrder(ass1, so1, bs1, dist1, 'ISSUED');
            po1_2.BodyShopOrderNumber__c = '2813';           
            l_purchaseOrders.add(po1_2); 

            PurchaseOrder__c po1_3 = TestFactory.createPurchaseOrder(ass2, so2, bs2, dist2, 'INDELIVERY');
            po1_3.BodyShopOrderNumber__c = '2814';
            l_purchaseOrders.add(po1_3);
        
            PurchaseOrder__c po1_4 = TestFactory.createPurchaseOrder(ass2, so2, bs3, dist2, 'INDELIVERY');
            po1_4.BodyShopOrderNumber__c = '2815';             
            l_purchaseOrders.add(po1_4);  
            
            PurchaseOrder__c po1_5 = TestFactory.createPurchaseOrder(ass2, so3, bs2, dist2, 'INDELIVERY');
            po1_5.BodyShopOrderNumber__c = '2816';             
            l_purchaseOrders.add(po1_5);  

            PurchaseOrder__c po1_6 = TestFactory.createPurchaseOrder(ass2, so4, bs2, dist2, 'INDELIVERY');
            po1_6.BodyShopOrderNumber__c = '2817';             
            l_purchaseOrders.add(po1_6);                  
            insert l_purchaseOrders;

			Case__c ca1 = TestFactory.createCase('testcase',3, l_users[0]);
			ca1.Assesment__c = ass1.Id;
			l_cases.add(ca1);
			
			Case__c ca2 = TestFactory.createCase('testcase2',4, l_users[0]);
            ca2.Purchase_order__c = po1_1.Id;
			l_cases.add(ca2);

			Case__c ca3 = TestFactory.createCase('testcase3',3, l_users[0]);
			ca3.Sales_order__c = so1.Id;
			l_cases.add(ca3);
			
			Case__c ca4 = TestFactory.createCase('testcase4',4, l_users[0]);
            ca4.CountryCode__c = 'FR';
            ca4.Case_Reason__c = 'DEFAULT';
            ca4.SubmittedBy__c = l_users[0].Id;
			l_cases.add(ca4);

			Case__c ca5 = TestFactory.createCase('testcase5',3, l_users[0]);
            ca5.Status__c = 'NEW';
            ca5.OwnerId = l_users[0].Id;
			ca5.Assesment__c = ass1.Id;
			l_cases.add(ca5);
			
			Case__c ca6 = TestFactory.createCase('testcase6',4, l_users[0]);
            ca6.Purchase_order__c = po1_2.Id;
			l_cases.add(ca6);

			Case__c ca7 = TestFactory.createCase('testcase7',3, l_users[0]);
            ca7.SLAAssignationDate__c = system.now().addDays(-2);
            ca7.SLAResolutionDate__c = system.now();
			l_cases.add(ca7);

			Case__c ca8 = TestFactory.createCase('testcase8',3, l_users[0]);
            ca8.Purchase_order__c = po1_3.Id;
			l_cases.add(ca8);

			Case__c ca9 = TestFactory.createCase('testcase9',3, l_users[0]);
            ca9.CountryCode__c = 'FR';
            ca9.Case_Reason__c = 'DEFAULT';
			ca9.Type__c = 'PROBLEM';
			l_cases.add(ca9);

			Case__c ca10 = TestFactory.createCase('testcase10',3, l_users[0]);
            ca10.Sales_order__c = so2.Id;
			ca10.TECH_AutomaticCreationFromProcess__c = '-SO-OfferReturned';
			l_cases.add(ca10);

			Case__c ca11 = TestFactory.createCase('testcase10',3, l_users[0]);
            ca11.Purchase_order__c = po1_4.Id;
			ca11.TECH_AutomaticCreationFromProcess__c = '-PO-AdditionalDiscount';
			l_cases.add(ca11);

			Case__c ca12 = TestFactory.createCase('testcase12',3, l_users[0]);
            ca12.Purchase_order__c = po1_4.Id;
            ca12.Sales_order__c = so2.Id;
			ca12.TECH_AutomaticCreationFromProcess__c = '-SO-DeliveryProblem';
            ca12.SubmittedBy__c = l_users[0].Id;
            ca12.OwnerId = l_users[0].Id;
            ca12.Account_Name__c = bs2.Id;
			l_cases.add(ca12);

			defaultHours = [select Id from BusinessHours where IsDefault=true];

	        // create countryCode
	        CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
	        countryCode1.AdvancedCaseManagement__c = true;
	        l_cs_CountryCodeIngformation.add(countryCode1);
	        CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);   
	        countryCode2.AdvancedCaseManagement__c = true;         
	        countryCode2.URLInvoiceDistributor__c= 'xxxxx';
	        countryCode2.LoginInvoiceDistributor__c = 'login';
	        countryCode2.PasswordInvoiceDistributor__c = 'pwd';
	        l_cs_CountryCodeIngformation.add(countryCode2);
	        CountryCodeInformationsMapping__c countryCode3 = TestFactory.createCountryCodeInformationsMapping('ES',defaultHours.id);
	        countryCode3.AdvancedCaseManagement__c = true;
	        l_cs_CountryCodeIngformation.add(countryCode3);
	        insert l_cs_CountryCodeIngformation; 


			queueList = new List<Group>
			{
				new Group(Name = 'AllDefaultQueue',
						  Type = 'Queue'),
				new Group(Name = 'FRTestQueue',
						  Type = 'Queue')
			};

			insert queueList;

			queueMappingList = new List<QueueSobject>
			{
				new QueueSobject(QueueId = queueList[0].Id,
								 SobjectType = 'Case__c'),
				new QueueSobject(QueueId = queueList[1].Id,
								 SobjectType = 'Case__c')
			};

			insert queueMappingList;

			countryQueueMappingList = new List<CountryQueueMapping__c>
			{
				new CountryQueueMapping__c(Name = 'ALL-DEFAULT',
										   Queue_ID__c = queueList[0].Id,
										   Support_Type__c = 'DEFAULT'),
				new CountryQueueMapping__c(Name = 'FR-DEFAULT',
										   Queue_ID__c = queueList[1].Id,
										   Support_Type__c = 'DEFAULT'),
				new CountryQueueMapping__c(Name = 'FR-APPLICATION',
										   Queue_ID__c = queueList[1].Id,
										   Support_Type__c = 'APPLICATION'),
				new CountryQueueMapping__c(Name = 'FR-DELIVERY',
										   Queue_ID__c = queueList[1].Id,
										   Support_Type__c = 'DELIVERY'),
				new CountryQueueMapping__c(Name = 'FR-INVOICING',
										   Queue_ID__c = queueList[1].Id,
										   Support_Type__c = 'INVOICING')
			};

			insert countryQueueMappingList;

			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			
			insert caseMappingList;

		}

		System.runAs(l_users[1])
		{
			caseListCreatedByUser1 = new List<Case__c>
			{
				TestFactory.createCase('testcaseByDistributor',3, l_users[1]),
				TestFactory.createCase('testcaseByDistributor1',3, l_users[1])
			};

			insert caseListCreatedByUser1;
		}

		System.runAs(l_users[2])
		{
			caseListCreatedByUser2 = new List<Case__c>
			{
				TestFactory.createCase('testcaseByDistributor',3, l_users[1]),
				TestFactory.createCase('testcaseByDistributor1',3, l_users[1])
			};

			insert caseListCreatedByUser2;
		}
	}//end method
  
	static testMethod void test_insert() {
        
		system.runAs(l_users[0]){  
			test.starttest();
				insert l_cases;
			test.stoptest();

			List< Case__c > CasesResult = new List<Case__c >([SELECT Id,CountryCode__c FROM Case__c where ID IN :l_cases ]);
			List< Account > AccountsResult = new List<Account >([SELECT Id,ShippingCountryCode FROM Account where ID IN :l_Accounts ]);
			system.assertEquals( CasesResult[0].CountryCode__c , AccountsResult[0].ShippingCountryCode );
		}//end runAs
	}//end method

	static testMethod void test_update() {
          
		system.runAs(l_users[0]){ 
		l_purchaseOrders[0].InvoiceStatusNotValidated__c = true;
		l_purchaseOrders[1].DistributorPriceHigger__c = true;
		update l_purchaseOrders;
		insert l_cases;
		l_cases[1].Status__c = 'CLOSED';
		l_cases[1].TECH_AutomaticCreationFromProcess__c = '-PO-NotValidated';
		l_cases[5].Status__c = 'CLOSED';
		l_cases[5].TECH_AutomaticCreationFromProcess__c = '-PO-DistributorPriceHigh';
		test.starttest();                
			update l_cases;                
		test.stoptest();
              
		List<PurchaseOrder__c> POResults = [SELECT Id,DistributorPriceHigger__c,InvoiceStatusNotValidated__c, Name FROM PurchaseOrder__c WHERE Id IN :l_purchaseOrders ];
		for(PurchaseOrder__c po: POResults){
			system.assertEquals(FALSE, po.InvoiceStatusNotValidated__c);
			system.assertEquals(FALSE, po.DistributorPriceHigger__c);
		}

		}//end runAs
	}//end method

	static testMethod void test_update2() {
          
		system.runAs(l_users[0]){ 
		insert l_cases;
		List< Case__c > CasesResultbefore = new List<Case__c >([SELECT Id,Status__c,SLAAssignationDate__c,SLAResolutionDate__c FROM Case__c where ID IN :l_cases ]);  
		l_cases[3].CountryCode__c = 'Fi';
		l_cases[3].Status__c = 'CLOSED';
		l_cases[1].Status__c = 'CLOSED';
		l_cases[1].TECH_AutomaticCreationFromProcess__c = '-PO-Delayed';
		//l_cases[2].Status__c = 'CLOSED';
		//l_cases[2].TECH_AutomaticCreationFromProcess__c = '-SO-DeliveryProblem';
		l_cases[0].Status__c = 'ASSIGNED';
		l_cases[4].Subject__c = 'Test2.1';
		l_cases[5].Status__c = 'CLOSED';
		l_cases[5].TECH_AutomaticCreationFromProcess__c = '-PO-ASMarginTooLow';
  		l_cases[6].Status__c = 'CLOSED'; 
  		l_cases[6].CountryCode__c = 'FR';
		l_cases[7].Status__c = 'CLOSED';
		l_cases[7].TECH_AutomaticCreationFromProcess__c = '-PO-NotDelivered';

		l_cases[9].Status__c = 'CLOSED';

		l_cases[10].Status__c = 'CLOSED';

		test.starttest();                
			update l_cases;                
		test.stoptest();
		List< Case__c > CasesResult = new List<Case__c >([SELECT Id,Status__c,SLAAssignationDate__c,SLAResolutionDate__c FROM Case__c where ID IN :l_cases ]);
		system.assertEquals(CasesResult[1].Status__c, 'Closed');
		system.assertEquals(CasesResult[6].SLAResolutionDate__c, CasesResult[6].SLAResolutionDate__c);
              
			List<PrerequisiteOrder__c> SOResults = [SELECT Id,HasSomeDeliveryIssuedCaseCreated__c, Name FROM PrerequisiteOrder__c WHERE Id IN :l_SalesOrders ];
			for(PrerequisiteOrder__c so: SOResults)
				system.assertEquals(FALSE, so.HasSomeDeliveryIssuedCaseCreated__c);
              
			List<PurchaseOrder__c> POResults = [SELECT Id,DelayedCaseCreated__c,ASMarginTooLowCaseCreated__c, Name FROM PurchaseOrder__c WHERE Id IN :l_purchaseOrders ];
			for(PurchaseOrder__c po: POResults){
				system.assertEquals(FALSE, po.DelayedCaseCreated__c);
				//system.assertEquals(FALSE, po.ASMarginTooLowCaseCreated__c);
			}

		}//end runAs
	}

	// ABT 21-APR-2016
	@isTest static void testInsertForDifferentCountryQueueMapping()
	{
		System.runAs(l_users[0])
		{
			// deleting ALL-DEFAULT
			delete countryQueueMappingList[0];

			Test.startTest();
				insert l_cases;
			Test.stopTest();

			Case__c updatedCase9 = [SELECT Id, Due_Date__c
									FROM	Case__c
									WHERE	Id =: l_cases[8].Id];

			System.assertNotEquals(null, updatedCase9.Due_Date__c);
		}
	}
	
	@isTest static void testSharingOfCaseCreatedByDifferentUsers()
	{
		System.runAs(l_users[0])
		{
			List<Case__c> allCases = new List<Case__c>();
			allCases.addAll(caseListCreatedByUser1);
			allCases.addAll(caseListCreatedByUser2);

			Test.startTest();
				update allCases;
			Test.stopTest();

			List<Case__Share> caseShares = [SELECT Id
											FROM Case__Share
											WHERE ParentId IN: caseListCreatedByUser1];

			System.assertEquals(2, caseShares.size());

		}
	}
}