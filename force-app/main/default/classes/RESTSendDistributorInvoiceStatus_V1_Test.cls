@isTest
private class RESTSendDistributorInvoiceStatus_V1_Test {/*
	static list<Account> accountsList;
	static list<user> users;
	static list<OrderLine__c> orderLines;
	static list<Offer__c> offers;
	static list<PurchaseOrder__c> purchaseOrders;
	static list<Invoice__c> invoicesList;
	static Prerequisiteorder__c pr;

	static CountryCodeInformationsMapping__c ccim;
	static BusinessHours defaultHours;

	static{
		defaultHours = [select Id,TimeZoneSidKey from BusinessHours where IsDefault=true];

		ccim = new CountryCodeInformationsMapping__c(Name = 'FR',LoginInvoiceDistributor__c = 'Test',
													 PasswordInvoiceDistributor__c = 'Test',URLInvoiceDistributor__c = 'Test',
													 BusinessHoursID__c = defaultHours.Id);
		insert ccim;
	}
	
	@isTest static void test_method_two() {
		users = new list<User>{ new User(Username = 'test8class@test.com',
			                            LastName = 'test8user',
			                            LanguageLocaleKey = 'en_US',
			                            FirstName = 'te8st',
			                            Email = 'test8@test.com',
			                            Alias = 'test8',
			                            TimeZoneSidKey = 'Europe/Dublin',
			                            LocaleSidKey = 'en_US',
			                            EmailEncodingKey = 'UTF-8',
			                            ProfileId = ASPISConstants.getProfileAdminId())
	  	}; 
	  	ASPISTestUtils.generateTestUsers(users);
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
	  	//ASPISTestUtils.setupBypassCustomSetting(true,true,'','RESTUpdateBDInvoice_V1_Test',users[0].Id);
	  	
	  	system.runas(users[0]){
	  		
			ASPISTestUtils.generateBasicTestData();
            
			accountsList = new List<Account>{  
				new Account(Name='Payment_ScTest1',
		        			 ReferenceNumber__c = '1234567',
		        			 ContactEmail__c = 'bt3@gmail.com',
		        			 RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment').getRecordTypeId(),
		        			 ShippingCountryCode = 'FR')
			};
			//insert accountsList;
			ASPISTestUtils.generateAccount(accountsList); 

			ASPISTestUtils.accounts[0].ShippingCountryCode = 'FR';
			update ASPISTestUtils.accounts;
			
			purchaseOrders = new list<PurchaseOrder__c>{
	        	ASPISTestUtils.purchaseOrders[0]
	        	,ASPISTestUtils.purchaseOrders[1]
	        };
	        purchaseOrders[0].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id;
	        purchaseOrders[1].PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id;
	        update purchaseOrders;

	        orderLines = new list<OrderLine__c>{
	        	new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[0].id, CataloguePrice__c = 10, AXADiscount__c = 11, BodyShopDiscount__c = 10, Quantity__c = 2, AdditionnalDiscount__c = 5)
	        	,new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[0].id, CataloguePrice__c = 10, AXADiscount__c = 11, BodyShopDiscount__c = 10, Quantity__c = 2)
	        	,new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[1].id, CataloguePrice__c = 10, AXADiscount__c = 11, BodyShopDiscount__c = 10, Quantity__c = 2)
	        	,new OrderLine__c(AcceptedCheck__c = true, PurchaseOrder__c = purchaseOrders[1].id, CataloguePrice__c = 10, AXADiscount__c = 11, BodyShopDiscount__c = 10, Quantity__c = 2)
	        };
	        ASPISTestUtils.generateOrderLine(orderLines);

	        pr = [Select Id, Assessment__c, BodyShop__c, Name, PaymentTerms__c from Prerequisiteorder__c where Id =:ASPISTestUtils.prerequisiteOrders[1].id limit 1];
	        
			invoicesList = new List<Invoice__c>{
	        	new Invoice__c(
	                Assessment__c = pr.Assessment__c,
	                BodyShop__c = pr.BodyShop__c,
	                IsBodyShop__c = true,
	                Status__c = 'SENT',
	                Number__c = '123',
	                Prerequisiteorder__c = pr.id,
	                PaymentTo__c = accountsList[0].id,
	                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
	                Paymentterms__c = pr.PaymentTerms__c
            	),
            	new Invoice__c(
	                Assessment__c = pr.Assessment__c,
	                BodyShop__c = pr.BodyShop__c,
	                IsBodyShop__c = true,
	                Status__c = 'SENT',
	                Number__c = '125',
	                Prerequisiteorder__c = pr.id,
	                PaymentTo__c = accountsList[0].id,
	                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
	                Paymentterms__c = pr.PaymentTerms__c
            	)
	        };
		    insert invoicesList;
			
	    	set<Id> invoiceId = new Set<Id>();
			for(Invoice__c i : [Select Id from Invoice__c where Id in:invoicesList]){
				invoiceId.add(i.Id);
			}
		
			
			test.startTest();
				Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
				RESTSendDistributorInvoiceStatus_V1.buildWebServiceRequest(invoiceId);
			test.stopTest(); 
			
		}//end runas*/  
	//}
}