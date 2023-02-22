/***********************************************************************************************************
Trigger Name - TestAP12SetInvoiceStatus
Version - 1.0
Created Date - 18 NOV 2015
Function - Test Class for AP12SetInvoiceStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Brayan  		18/11/2015 	Original Version
************************************************************************************************************/
@isTest
private class TestAP12SetInvoiceStatus {/*
	static list<Account> accounts;
	static List<Assessment__c> assessments;
    static list<user> users;
    static list<PurchaseOrder__c> purchaseOrders;
    static list<Invoice__c> invoicesList;
	static date myDate;
    static datetime myDateTime;
	
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

		system.runas(users[0]){
			myDateTime = datetime.newInstance(2015, 2, 17);
			myDate = date.newInstance(2015, 2, 17);

			accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
													 RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId(),
													 ReferenceNumber__c = '123',
													 ContactEmail__c = 'bt1@gmail.com',
													 ShippingCountryCode = 'FR',
													 ReferentialASforAParts__c = 20,
													 ReferentialASforBCParts__c = 25,
													 LowKeepDiscountforAParts__c = 10),

										new Account(Name='BodyShop_ScTest2',
													RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId(),
													ReferenceNumber__c = '1234',
													ContactEmail__c = 'bt2@gmail.com',
													ShippingCountryCode = 'FR',
													LowKeepDiscountforAParts__c = 10),

										new Account(Name='Distributor_ScTest1',
													RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId(),
													ReferenceNumber__c = '12345',
													ContactEmail__c = 'dt1@gmail.com', 
													DistributorNextInvoiceDate__c = date.today(),
													DistributorInvoicePeriod__c = '15',
													Categories__c='A',
													ReferentialASforAParts__c = 20,
													ShippingCountryCode = 'FR'),

										new Account(Name='Distributor_ScTest2',
													RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId(),
													ReferenceNumber__c = '123456',
													ContactEmail__c = 'dt1@gmail.com', 
													DistributorNextInvoiceDate__c = date.today(),
													DistributorInvoicePeriod__c = '15',
													Categories__c='A',
													ReferentialASforAParts__c = 20,
													ShippingCountryCode = 'FR')
			};
			//insert accounts;
			ASPISTestUtils.generateAccount(accounts);

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
																			//, BodyShop__c=accounts[0].id
																			)
			};
			//insert purchaseOrders;
			ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
		}
	}
	static testMethod void myUnitTest() {
		system.runas(users[0]){
			invoicesList = new List<Invoice__c>{
                new Invoice__c(
                    Assessment__c = assessments[0].id,
                    TotalNet__c  = 100,
                    Status__c = 'SENT',
                    PurchaseOrder__c = purchaseOrders[0].id,
                    PaymentTo__c = accounts[0].id,
                    Distributor__c = purchaseOrders[0].Distributor__c,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
                    Paymentterms__c = 'Test'
                ),
                new Invoice__c(
                    Assessment__c = assessments[0].id,
                    TotalNet__c  = 600,
                    Status__c = 'SENT',
                    PurchaseOrder__c = purchaseOrders[0].id,
                    Distributor__c = purchaseOrders[0].Distributor__c,
                    PaymentTo__c = accounts[0].id,
                    RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(),
                    Paymentterms__c = 'Test'
                )
            };

			Test.startTest();
				insert invoicesList;
			Test.stopTest();

			List<PurchaseOrder__c> pList = [Select Id,InvoiceStatus__c from PurchaseOrder__c where id in :purchaseOrders];
			System.assertEquals(true, pList[0].InvoiceStatus__c != null);
		}
	}*/
}