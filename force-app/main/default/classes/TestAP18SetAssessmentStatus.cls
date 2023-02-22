/*************************************************************************************
Class Name - TestAP18SetAssessmentStatus
Version - 1.0
Created Date - 16 OCT 2015
Function - Test class of AP18SetAssessmentStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer      		Date         Description
* ----------     	----------  -----------------------
* Ashwina Seetaram    16/10/2015    C-001275: Original Version
*************************************************************************************/
@isTest
private class TestAP18SetAssessmentStatus {
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
        
        // @CLA	To avoid the error with the class AP09
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
                                                                             Status__c ='DRAFTQUOTE',
                                                                              //QuotationTimestampStart__c = Datetime.now(),
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
	                                                                         Assessment__c=assessments[0].id
	                                                                        ),

                                                        new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c ='REJECTED',
																			 Reason__c ='REJECTEDQUOTE',
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
		}
	}
	
	@isTest static void testInsertPONotUpdatePO() {
		// Not all PO inserted have status cancelled/rejected
		system.runas(users[0]){
			test.startTest();
	        	ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
				system.assertNotEquals([Select Status__c from Assessment__c where id=:assessments[0].id].Status__c, 'REJECTED');
			
				// update PO
				purchaseOrders[1].Status__c = 'CANCELED';
				system.assertNotEquals([Select Status__c from Assessment__c where id=:assessments[0].id].Status__c, 'REJECTED');
			
				purchaseOrders[0].Status__c = 'REJECTED';
				Assessment__c updatedAssess = [Select Status__c, ReasonFailure__c from Assessment__c where id=:assessments[0].id];
				system.assertNotEquals(updatedAssess.Status__c, 'REJECTED');
				system.assertNotEquals(updatedAssess.ReasonFailure__c, 'NoPurchaseOrderAvailable');				
	        test.stopTest();			
		}
	}
	
	@isTest static void testInsertPOUpdatePO() {
		// Not all PO inserted have status cancelled/rejected
		system.runas(users[0]){
			test.startTest();
				purchaseOrders[0].Status__c = 'CANCELED';
	        	ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
			test.stopTest();
			Assessment__c updatedAssess = [Select Status__c, ReasonFailure__c from Assessment__c where id=:assessments[0].id];
			system.assertEquals(updatedAssess.Status__c, 'CANCELED');
			system.assertEquals(updatedAssess.ReasonFailure__c, 'NoPurchaseOrderAvailable');
		}
	}*/
}