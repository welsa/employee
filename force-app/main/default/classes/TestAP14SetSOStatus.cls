/*************************************************************************************
Class Name - TestAP14SetSOStatus
Version - 1.0
Created Date - 06 OCT 2015
Function - Test class of AP14SetSOStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer          Date         Description
* ----------       ----------  -----------------------
* Ashwina Seetaram    05/10/2015    C-001255: Original Version
*************************************************************************************/
@isTest
private class TestAP14SetSOStatus {
/*
	static list<Account> accounts;
	static list<user> users;
	static list<Group> groups;
	public static list<PrerequisiteOrder__c> prerequisiteOrders;
	public static list<PurchaseOrder__c> purchaseOrders;
	public static list<Assessment__c> assessments;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	public static map <String,Id> proRecordTypeMap = new map <String,Id>();
	public static List<Invoice__c> invoicesList; 

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
        
        // @CLA  To avoid the error with the class AP09
        InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
        insert newCSInvoiceMagin;

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

	        assessments = new list<Assessment__c>{new Assessment__c( Name='ASSESS_TEST-0001',
	                                                                 AssessmentNumber__c = 'ASSESS_TEST-0001',
	                                                                 BodyShop__c = accounts[0].Id,
	                                                                 Entity__c = 'AXA Direct',
	                                                                 EntityRules__c = 'AXA Direct',
	                                                                 MissionNumber__c = '01',
	                                                                 PortfolioAgentCode__c = '355',
	                                                                 AssessmentID__c = '0912',
	                                                                 TechExternalId__c = '233'),	                                                  
	                                                new Assessment__c( Name='ASSESS_TEST-0002',
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

			proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);
			
			prerequisiteOrders= new list<PrerequisiteOrder__c>{	new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id,
																						Assessment__c = assessments[0].Id,
																						RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)),
																new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id,
																						Assessment__c = assessments[0].Id,
																						OfferType__c = 'BASIC',
																						RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance))
																						};
			//insert prerequisiteOrders;
			ASPISTestUtils.generatePrerequisiteOrder(prerequisiteOrders);
	      
			// creating invoice data
			invoicesList =  new list<Invoice__c>{new Invoice__c(BodyShop__c=accounts[0].Id
											            		,Status__c = ASPISConstants.INV_STATUS_SENT
																,Number__c = '12345'
											            		,Assessment__c =  assessments[0].Id
											            		,PrerequisiteOrder__c = prerequisiteOrders[0].id
												                ,RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId()),
												new Invoice__c(	BodyShop__c=accounts[0].Id
																,Number__c = '123456'
											            		,Status__c = ASPISConstants.INV_STATUS_PAID
											            		,Assessment__c =  assessments[0].Id
											            		,PrerequisiteOrder__c = prerequisiteOrders[1].id
												                ,RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId())
			};
		}
	}
  
  	@isTest static void testInsertInvoicesUpdatePOInvoiced() {
    // Not all invoices inserted have status Payable
    system.runas(users[0]){
	    test.startTest();
	    insert invoicesList;
	    test.stopTest();
	    System.debug('############# Check 1:'+[Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id]);
	    system.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id].Status__c, 'INVOICED');
	    }
	}
  
    @isTest static void testInsertInvoicesUpdatePOPaid() {
	    // All invoices inserted have status Payable
	    system.runas(users[0]){
	        test.startTest();
	        	invoicesList[0].Status__c = ASPISConstants.INV_STATUS_PAID;
	            insert invoicesList;
	        test.stopTest();
	        System.debug('############# Check 2:'+[Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id]);
	        //30/11/2015 commented because of batch
        //system.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id].Status__c, 'PAID');
	    }
  	}
  
  	@isTest static void testUpdateInvoicesUpdatePOInvoiced() {
	    // Not all invoices updated have status Payable
	    system.runas(users[0]){
		    test.startTest();
			    insert invoicesList;	        
		        invoicesList[1].Status__c =ASPISConstants.INV_STATUS_SENT;
		        update invoicesList;
		    test.stopTest();
	      	System.debug('############# Check 3:'+[Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id]);
	    	system.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id].Status__c, 'INVOICED');
    	}
 	}  
  
  	@isTest static void testUpdateInvoicesUpdatePOPaid() {
    // All invoices updated have status Payable
    	system.runas(users[0]){
            test.startTest();
	        	insert invoicesList;	        
	        	invoicesList[0].Status__c = 'PAID';
	        	update invoicesList;
          	test.stopTest();
      		System.debug('############# Check 4: '+[Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id]);
          	system.assertEquals([Select Status__c from PrerequisiteOrder__c where id=: prerequisiteOrders[0].id].Status__c, 'PAID');
    	}
  	}  */
}