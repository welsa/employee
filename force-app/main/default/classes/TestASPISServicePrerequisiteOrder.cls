/*************************************************************************************
Class Name - TestASPISServicePrerequisiteOrder 
Version - 1.0
Created Date - 21 MAY 2015
Function - Test Class for ASPISServicePrerequisiteOrder

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Kevan(SC)   	21/05/2015   Original Version
* Bhavish (sc)	29/05/2015	 Added Assert
* Dourga U      04/07/2016   Commented class not longer in use(case 1653)
*************************************************************************************/
@isTest
private class TestASPISServicePrerequisiteOrder {
	/*static list<PurchaseOrder__c> purchaseOrders;
	static list<OrderLine__c> orderLines;
	static list<user> users;
	static {
		users = new list<User>{ new User(Username = 'testclass@test.com',
			                            LastName = 'testuser',
			                            LanguageLocaleKey = 'en_US',
			                            FirstName = 'test',
			                            Email = 'test@test.com',
			                            Alias = 'test',
			                            TimeZoneSidKey = 'Europe/Dublin',
			                            LocaleSidKey = 'en_US',
			                            EmailEncodingKey = 'UTF-8',
			                            ProfileId = ASPISConstants.getProfileAdminId())
	  	}; 
	  	ASPISTestUtils.generateTestUsers(users);
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
	  	system.runas(users[0]){
			ASPISTestUtils.generateBasicTestData();
			datetime myDateTime = datetime.newInstance(2015, 2, 17);
	      	date myDate = date.newInstance(2015, 2, 17);
			purchaseOrders =  new list<PurchaseOrder__c>{
				new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
									  ValidityDate__c=date.today(),
									  Status__c = system.Label.PURCHASEORDERORDEREDSTATUS,
                                      Assessment__c= ASPISTestUtils.assessments[0].id,
									  SLAQuotationLevel1__c = myDateTime.addDays(2),
									  SLAQuotationLevel2__c = myDateTime,
									  SLAQuotationLevel3__c = myDateTime.addDays(5),
									  TECHSLAQuotationIsLevel1__c = false,
									  TECHSLAQuotationIsLevel2__c = false,
									  TECHSLAQuotationIsLevel3__c = false,
									  prerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id),

		    	new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
		        					 ValidityDate__c=date.today(),
		        					 Status__c = 'REJECTED',
                                     Assessment__c= ASPISTestUtils.assessments[0].id,
		        					 SLAQuotationLevel1__c = (datetime.now()).addDays(2),
		        					 SLAQuotationLevel2__c = (datetime.now()).addDays(3),
		        					 SLAQuotationLevel3__c = (datetime.now()).addDays(5),
		        					 TECHSLAQuotationIsLevel1__c = false,
		        					 TECHSLAQuotationIsLevel2__c = false,
	            					 TECHSLAQuotationIsLevel3__c = false,
	            					 prerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id)
			};
			ASPISTestUtils.generatePurchaseOrder(purchaseOrders);

			orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
																 ExpectedDeliveryDuration__c = '1',
																 CataloguePrice__c  = 12,
																 Suppliable__c =  'Yes',
																 OrderType__c = 'FINAL',
																 AcceptedCheck__c=true),
												new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
																 ExpectedDeliveryDuration__c = '1',
																 CataloguePrice__c  = 12,
																 Suppliable__c =  'No',
																 AcceptedCheck__c=true)
			};
			ASPISTestUtils.generateOrderLine(orderLines);
		}

	}
	static testMethod void testServicePrerequisiteOrder_ORDERED(){
		system.runas(users[0]){
			ASPISServicePrerequisiteOrder spo = new ASPISServicePrerequisiteOrder();
			test.startTest();
				spo.executeProcess(ASPISTestUtils.prerequisiteOrders[0]);
			test.stopTest();
			List<prerequisiteOrder__c> prerequisiteOrders = new List<prerequisiteOrder__c>([select recordTypeId
																							from prerequisiteOrder__c
																							where id=:ASPISTestUtils.prerequisiteOrders[0].id]);
			List<PurchaseOrder__c> listPurchaseOrders = new List<PurchaseOrder__c>([select status__c
																							,recordTypeId
																					from PurchaseOrder__c
																					where prerequisiteOrder__c=:ASPISTestUtils.prerequisiteOrders[0].id]);
			System.assertEquals(1, listPurchaseOrders.size());
			System.assertEquals('INDELIVERY', listPurchaseOrders[0].status__c);
			List<OrderLine__c> listOrderLines = new List<OrderLine__c>([select
																				DeliveryStatus__c
																				,PurchaseOrder__c
																		from OrderLine__c
																		where PurchaseOrder__c=:purchaseOrders[0].Id]);
			System.assertEquals(3, listOrderLines.size());
		}
	}
	static testMethod void testServicePrerequisiteOrder_REJECTED(){	
		system.runas(users[0]){
			ASPISServicePrerequisiteOrder spo = new ASPISServicePrerequisiteOrder();
			test.startTest();
				spo.executeProcess(ASPISTestUtils.prerequisiteOrders[1]);
			test.stopTest();
			List<prerequisiteOrder__c> prerequisiteOrders = new List<prerequisiteOrder__c>([select recordTypeId
																							from prerequisiteOrder__c
																							where id=:ASPISTestUtils.prerequisiteOrders[1].id]);
			List<PurchaseOrder__c> listPurchaseOrders = new List<PurchaseOrder__c>([select status__c
																							,recordTypeId
																					from PurchaseOrder__c
																					where prerequisiteOrder__c=:ASPISTestUtils.prerequisiteOrders[1].id]);
			System.assertEquals(1, listPurchaseOrders.size());
			System.assertEquals('REJECTED', listPurchaseOrders[0].status__c);
			List<OrderLine__c> listOrderLines = new List<OrderLine__c>([select DeliveryStatus__c
																		from OrderLine__c
																		where PurchaseOrder__c=:purchaseOrders[1].Id]);
			System.assertEquals(1, listOrderLines.size());
		}
	}*/
}