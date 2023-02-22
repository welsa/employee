@isTest
private class TestAP11ShareInvoices {
/*
	static list<Account> accounts;
	static list<user> users;
	static list<Group> groups;
	public static list<PrerequisiteOrder__c> prerequisiteOrders;
	public static list<PurchaseOrder__c> purchaseOrders;
	public static list<Assessment__c> assessments;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	public static map <String,Id> proRecordTypeMap = new map <String,Id>();

	static{

		users = new list<User>{ new User(Username = 'jb@test.com',
                                         LastName = 'Ballack',
                                         FirstName = 'Jean',
                                         Email = 'Jean@test.com',
                                         Alias = 'JBAL',
                                         LanguageLocaleKey = 'en_US',
                                         TimeZoneSidKey = 'Europe/Dublin',
                                         LocaleSidKey = 'en_US',
                                         EmailEncodingKey = 'UTF-8',
                                         ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        //insert users;
        ASPISTestUtils.generateTestUsers(users);
        
        // @CLA	To avoid the error with the class AP09
        InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
        insert newCSInvoiceMagin;

        //ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestAP11ShareInvoices',users[0].Id);

        //system.debug('////// bypass: ' + [Select Id,Name,SetupOwnerId,BypassValidationRules__c,BypassWorkflows__c,BypassTrigger__c from Bypass__c]);
	  	
	  	system.runas(users[0]){
	  		DateTime myDateTime = datetime.newInstance(2015, 2, 17);
      		Date myDate = date.newInstance(2015, 2, 17);

	  		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);

	  		accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                     ReferenceNumber__c = '123',
                                                     ContactEmail__c = 'bt1@gmail.com',
                                               		 ShippingCountryCode = 'FR'),

                                         new Account(Name='BodyShop_ScTest2',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                     ReferenceNumber__c = '1234',
                                                     ContactEmail__c = 'bt2@gmail.com',
                                              		 ShippingCountryCode = 'FR'),

                                         new Account(Name='Distributor_ScTest1',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                     ReferenceNumber__c = '12345',
                                                     ContactEmail__c = 'dt1@gmail.com', 
                                              		 DistributorNextInvoiceDate__c = date.today(),
                                              		 DistributorInvoicePeriod__c = '15',
                                              		 Categories__c='A',
                                              		 ShippingCountryCode = 'FR'),

                                         new Account(Name='Distributor_ScTest2',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                     ReferenceNumber__c = '123456',
                                                     ContactEmail__c = 'dt1@gmail.com', 
                                              		 DistributorNextInvoiceDate__c = date.today(),
                                              		 DistributorInvoicePeriod__c = '15',
                                              		 Categories__c='A',
                                              		 ShippingCountryCode = 'FR')
	        };
	        ASPISTestUtils.generateAccount(accounts);

	        List<Account> insertedAccounts = [Select Name from Account where Id in:accounts order by RecordTypeId];

	        if(insertedAccounts.size() > 2){
	        	groups = new list<Group>{
	            	new Group(Name=insertedAccounts[0].Name, Type='Regular'),
	            	new Group(Name=insertedAccounts[2].Name, Type='Regular')
	            };
	            insert groups;
	        }

	        assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001',
	                                                               AssessmentNumber__c = 'ASSESS_TEST-0001',
	                                                               BodyShop__c = accounts[0].Id,
	                                                               Entity__c = 'AXA Direct',
	                                                               EntityRules__c = 'AXA Direct',
	                                                               MissionNumber__c = '01',
	                                                               PortfolioAgentCode__c = '355',
	                                                               AssessmentID__c = '0912',
	                                                               TechExternalId__c = '233'),
	                                                
	                                               new Assessment__c(Name='ASSESS_TEST-0002',
	                                                                 AssessmentNumber__c = 'ASSESS_TEST-0002',
	                                                                 BodyShop__c = accounts[0].Id,
	                                                                 Entity__c = 'AXA Direct1',
	                                                                 EntityRules__c = 'AXA Direct1',
	                                                                 MissionNumber__c = '02',
	                                                                 PortfolioAgentCode__c = '3545',
	                                                                 AssessmentID__c = '5912')
	                
	        };
	        //insert assessments ;
	        ASPISTestUtils.generateAssessment(assessments);

	        purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                                                                              //QuotationTimestampStart__c = Datetime.now(),
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
	                                                                         Assessment__c=assessments[0].id
	                                                                      //  , BodyShop__c=accounts[0].id
	                                                                        ),

                                                        new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c =ASPISConstants.PUR_ORDER_STATUS_RESPONDED,
                                                                             //QuotationTimestampStart__c = Datetime.now(),
                                                                             SLAQuotationLevel1__c = (datetime.now()).addDays(2),
                                                                             SLAQuotationLevel2__c = (datetime.now()).addDays(3),
                                                                             SLAQuotationLevel3__c = (datetime.now()).addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
                                                    						 Assessment__c=assessments[0].id
                                                        )
	        };
	        //insert purchaseOrders;
	        ASPISTestUtils.generatePurchaseOrder(purchaseOrders);

	        proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);
	        prerequisiteOrders= new list<PrerequisiteOrder__c>{new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id,
                                                                                                                        Assessment__c = assessments[0].Id,
                                                                                                                        RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)),
	                                                    
	                                                                               new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id,
	                                                                                                                    Assessment__c = assessments[0].Id,
	                                                                                    OfferType__c = 'BASIC',
	                                                                                                                    RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance))
	        };
	        //insert prerequisiteOrders;
	        ASPISTestUtils.generatePrerequisiteOrder(prerequisiteOrders);
	        
	  	}

	}
	
	@isTest static void testInsertInvoices() {
		system.runas(users[0]){
            List<PurchaseOrder__c> l_PurchaseOrders = [SELECT Id FROM PurchaseOrder__c];
			List<Invoice__c> invoicesList = new List<Invoice__c>{
	        	new Invoice__c(
	                BodyShop__c = accounts[0].id,
	                TotalNet__c  = 500,
	                Status__c = 'SENT',
	                Prerequisiteorder__c = prerequisiteOrders[0].id,
	                PaymentTo__c = accounts[0].id,
	                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId(),
	                Assessment__c = assessments[0].Id,
	                PaymentFrom__c =accounts[0].id,
					Number__c = string.valueOf(math.random()),
					CustomerNotes__c = 'testNotes',
					TotalPieces__c = 3,
	                IsBodyShop__c = true
            	),
            	new Invoice__c(
            		Assessment__c = assessments[0].Id,
	                Distributor__c =  accounts[2].id,
	                TotalNet__c  = 600,
	                Status__c = 'SENT',
	                PurchaseOrder__c = l_PurchaseOrders[0].id,
	                PaymentTo__c = accounts[2].id,
	                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
	                IsBodyShop__c = false
            	)
	        };

	        test.startTest();
	        	insert invoicesList;
	        test.stopTest();

	        system.assert([Select Id from Invoice__Share].size() > 0);
		}
	}
	*/
	
}