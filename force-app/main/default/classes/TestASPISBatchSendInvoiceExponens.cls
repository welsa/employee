/*************************************************************************************
Class Name - TestASPISBatchSendInvoiceExponens
Version - 1.0
Created Date - 01 Dec 2015
Function - Test Class sending invoices with status Payable and  record type Distributor to Exponens every night

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------  
* Ashwina S             01/12/2015  Original Version
*************************************************************************************/
@isTest
private class TestASPISBatchSendInvoiceExponens {
	/*// create test data
	static list<Account> accounts;
	static list<user> users;
	static list<Group> groups;
	public static list<PrerequisiteOrder__c> prerequisiteOrders;
	public static list<PurchaseOrder__c> purchaseOrders;
	public static list<Assessment__c> assessments;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	public static map <String,Id> proRecordTypeMap = new map <String,Id>();
	public static List<Invoice__c> invoicesList; 
	public static list<OrderLine__c> orderLines;
	public static list<CountryCodeInformationsMapping__c> cs_CountryCodeIngformation;
	public static BusinessHours defaultHours;

	static{
		// create users
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
        ASPISTestUtils.generateTestUsers(users);
        
        //create InvoiceMargin__c custom settings
        InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
        insert newCSInvoiceMagin;

       system.runas(users[0]){
	  		DateTime myDateTime = datetime.newInstance(2015, 2, 17);
      		Date myDate = date.newInstance(2015, 2, 17);
			
		   	// create accounts
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

	       			
			// create assessment
	        assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001',
	                                                               AssessmentNumber__c = 'ASSESS_TEST-0001',
	                                                               BodyShop__c = accounts[0].Id,
	                                                               Entity__c = 'AXA Direct',
	                                                               EntityRules__c = 'AXA Direct',
	                                                               MissionNumber__c = '01',
	                                                               PortfolioAgentCode__c = '355',
	                                                               AssessmentID__c = '0912',
	                                                               TechExternalId__c = '233')
			};
	       	ASPISTestUtils.generateAssessment(assessments);
			
			// create PO
	        purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[2].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c ='PAYABLE',
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
	                                                                         Assessment__c=assessments[0].id,
																			 TechToBeProcessed__c = true
	                                                                        ),
                                                        new PurchaseOrder__c(Distributor__c = accounts[3].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c ='PAYABLE',
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
	                                                                         Assessment__c=assessments[0].id,
																			 TechToBeProcessed__c = true
                                                        					),
														new PurchaseOrder__c(Distributor__c = accounts[3].Id,
                                                                             ValidityDate__c=date.today(),
                                                                             Status__c ='PAYABLE',
                                                                             SLAQuotationLevel1__c = myDateTime.addDays(2),
                                                                             SLAQuotationLevel2__c = myDateTime,
                                                                             SLAQuotationLevel3__c = myDateTime.addDays(5),
                                                                             TECHSLAQuotationIsLevel1__c = false,
                                                                             TECHSLAQuotationIsLevel2__c = false,
                                                                             TECHSLAQuotationIsLevel3__c = false,
	                                                                         Assessment__c=assessments[0].id,
																			 TechToBeProcessed__c = true
                                                        					)
	        };
	        ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
			
			orderLines = new list<OrderLine__c>{new OrderLine__c(AcceptedCheck__c = true, 
										        				PurchaseOrder__c = purchaseOrders[0].id, 
										        				CataloguePrice__c = 10, 
										        				AXADiscount__c = 11, 
										        				BodyShopDiscount__c = 10, 
										        				Quantity__c = 2,
																DeliveryStatus__c = 'DELIVERED'),
									        	new OrderLine__c(AcceptedCheck__c = true, 
									        					 PurchaseOrder__c =purchaseOrders[0].id, 
									        					 CataloguePrice__c = 10, 
									        					 AXADiscount__c = 11, 
									        					 BodyShopDiscount__c = 10, 
									        					 Quantity__c = 2,
																 DeliveryStatus__c = 'DELIVERED'),
												new OrderLine__c(AcceptedCheck__c = true, 
										        				PurchaseOrder__c = purchaseOrders[1].id, 
										        				CataloguePrice__c = 10, 
										        				AXADiscount__c = 11, 
										        				BodyShopDiscount__c = 10, 
										        				Quantity__c = 2,
																DeliveryStatus__c = 'DELIVERED'),
									        	new OrderLine__c(AcceptedCheck__c = true, 
									        					 PurchaseOrder__c =purchaseOrders[1].id, 
									        					 CataloguePrice__c = 10, 
									        					 AXADiscount__c = 11, 
									        					 BodyShopDiscount__c = 10, 
									        					 Quantity__c = 2,
																 DeliveryStatus__c = 'DELIVERED')
	        };
	        ASPISTestUtils.generateOrderLine(orderLines);

	       			
			// creating invoice data
			invoicesList = new List<Invoice__c>{new Invoice__c(	Assessment__c = assessments[0].Id,
																Number__c = '12345',
											                	Distributor__c =  accounts[2].id,
												                TotalNet__c  =40,
												                Status__c = 'PAYABLE',
												                PurchaseOrder__c = purchaseOrders[0].id,
												                PaymentTo__c = accounts[2].id,
																TECH_InvoiceSentToExponens__c = true,
												                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId()
												            ),
												new Invoice__c(	Assessment__c = assessments[0].Id,
																Number__c = '12346',
											                	Distributor__c =  accounts[2].id,
												                TotalNet__c  = 4.40,
												                Status__c = 'PAYABLE',
																TECH_InvoiceSentToExponens__c = true,
												                PurchaseOrder__c = purchaseOrders[0].id,
												                PaymentTo__c = accounts[2].id,
												                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
												                IsBodyShop__c = false
								            				),
												new Invoice__c(	Assessment__c = assessments[0].Id,
											                	Distributor__c =  accounts[3].id,
																Number__c = '12347',
												                TotalNet__c  =50,
												                Status__c = 'PAYABLE',
												                PurchaseOrder__c = purchaseOrders[1].id,
																TECH_InvoiceSentToExponens__c = true,
												                PaymentTo__c = accounts[2].id,
												                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId()
												            ),
												new Invoice__c(	Assessment__c = assessments[0].Id,
											                	Distributor__c =  accounts[3].id,
																Number__c = '12348',
												                TotalNet__c  = 14.40,
																TECH_InvoiceSentToExponens__c = true,
												                Status__c = 'PAYABLE',
												                PurchaseOrder__c = purchaseOrders[1].id,
												                PaymentTo__c = accounts[2].id,
												                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId(),
												                IsBodyShop__c = false
								            				)
			};	        
			insert invoicesList;
			
			defaultHours = [select Id from BusinessHours where IsDefault=true];
			
			cs_CountryCodeIngformation = new list<CountryCodeInformationsMapping__c>{
                                            new CountryCodeInformationsMapping__c(
                                                name = 'DEFAULT',
                                                BusinessHoursID__c = defaultHours.id 
                                            ),
                                            new CountryCodeInformationsMapping__c(
                                                name = 'FR',
                                                BusinessHoursID__c = defaultHours.id,
												URLInvoiceDistributor__c = 'xxxxx',
												LoginInvoiceDistributor__c = 'login',
												PasswordInvoiceDistributor__c = 'pwd'
                                            )
                                        };
            insert  cs_CountryCodeIngformation;  
	  	}

	}
	
	public class WS_DiagnosisAndQuestionList implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String responseHttp;
			//responseHttp = '[Endpoint=http://labo.vitemescomptes.fr:5000/applications/exponens/v1.0/updateDistributorInvoiceStatus, Method=POST]';
			responseHttp = '[{"User":"aspis","Password":"aspisVMC2423","Number":"51122","PO":"PO-63452","Status":"PAYABLE"},{"User":"aspis","Password":"aspisVMC2423","Number":"51122","PO":"PO-63452","Status":"PAYABLE"},{"User":"aspis","Password":"aspisVMC2423","Number":"51242","PO":"PO-63452","Status":"PAYABLE"}]';
            //responseHttp = '[{"diagnosis":{"id":1,"diagnosisDescKey":"diag.prospecting.mobility","subCategoryDescKey":"sub_category_full","version":"0.0.1"},"questionList":[{"id":961,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.repartition","relevanceLevel":0,"answerTypeId":1,"minValue":0,"maxValue":10000000},{"id":962,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice1","relevanceLevel":2,"answerTypeId":113}, {"id":1210,"descKey":"diag.study.salaryRepartition.sedentaryOnSite.principalJob.choice4","relevanceLevel":2,"answerTypeId":117}]}]';

            HttpResponse res = new HttpResponse();
			res.setBody(responseHttp);
			res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

	
	static testMethod void ASPISBatchSendInvoiceExponensTest() {	
		Test.setMock(HttpCalloutMock.class, new WS_DiagnosisAndQuestionList());
		try{ 
        	Test.startTest();
			Database.executeBatch(new ASPISBatchSendInvoiceExponens(), 200);		 
        	Test.stopTest(); 
        }
		catch (System.UnexpectedException theException){ // this exeption will not be catch because it is probably thown in a separate transaction
            System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
                'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage()); 
        }	
	}*/
}