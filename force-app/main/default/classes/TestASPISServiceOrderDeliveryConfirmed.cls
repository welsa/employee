/*************************************************************************************
Class Name - TestASPISServiceOrderDeliveryConfirmed 
Version - 1.0
Created Date - 21 MAY 2015
Function - Test Class for ASPISServiceOrderDeliveryConfirmed

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Kevan(SC)   21/05/2015   Original Version
* Shamina M   22/01/2016  case 1386 - commented unused business hr variable
*************************************************************************************/
@isTest
private class TestASPISServiceOrderDeliveryConfirmed {
	/*static list<OrderLine__c> orderLines; 
	static list<PurchaseOrder__c> purchaseOrders;
	static list<user> users;
    //static BusinessHours defaultHours;
   
	static {

		users = new list<User>{ new User(Username = 'kk@test.com',
				                         LastName = 'ko',
				                         FirstName = 'ka',
				                         Email = 'kk@test.com',
				                         Alias = 'kk',
				                         LanguageLocaleKey = 'en_US',
				                         TimeZoneSidKey = 'Europe/Dublin',
				                         LocaleSidKey = 'en_US',
				                         EmailEncodingKey = 'UTF-8',
				                         ProfileId = ASPISConstants.getProfileAdminId(),
				                         bypassworkflows__c = true)
	  	}; 
	  	//insert users;
	  	ASPISTestUtils.generateTestUsers(users);
	  	
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);

	  	system.runas(users[0]){
			ASPISTestUtils.generateBasicTestData();
			datetime myDateTime = datetime.newInstance(2015, 2, 17);
	      	date myDate = date.newInstance(2015, 2, 17);
			//defaultHours = [select Id from BusinessHours where IsDefault=true];
			//System.debug('##defaultHours'+defaultHours);

			purchaseOrders =  new list<PurchaseOrder__c>{
				new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
									  ValidityDate__c=date.today(),
									  Status__c = system.Label.PURCHASEORDERORDEREDSTATUS,
									  //QuotationTimestampStart__c = Datetime.now(),
									  SLAQuotationLevel1__c = myDateTime.addDays(2),
									  SLAQuotationLevel2__c = myDateTime,
									  SLAQuotationLevel3__c = myDateTime.addDays(5),
									  TECHSLAQuotationIsLevel1__c = false,
									  TECHSLAQuotationIsLevel2__c = false,
									  TECHSLAQuotationIsLevel3__c = false,
									  Assessment__c = ASPISTestUtils.assessments[0].id,
									  prerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].id),

		    	new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
		        					 ValidityDate__c=date.today(),
		        					 Status__c = 'DELIVEREDCONFIRMED',
		        					 //QuotationTimestampStart__c = Datetime.now(),
		        					 SLAQuotationLevel1__c = (datetime.now()).addDays(2),
		        					 SLAQuotationLevel2__c = (datetime.now()).addDays(3),
		        					 SLAQuotationLevel3__c = (datetime.now()).addDays(5),
		        					 TECHSLAQuotationIsLevel1__c = false,
		        					 TECHSLAQuotationIsLevel2__c = false,
	            					 TECHSLAQuotationIsLevel3__c = false,
									 Assessment__c = ASPISTestUtils.assessments[0].id,
	            					 prerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[1].id)
			};
			insert purchaseOrders;

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
	static testMethod void testAllConfirmed() {
		system.runas(users[0]){
			ASPISServiceOrderDeliveryConfirmed sodc = new ASPISServiceOrderDeliveryConfirmed();
			test.startTest();
				sodc.executeProcess(purchaseOrders[0]);
			test.stoptest();
		}
	}
	static testMethod void testAllDeliveredConfirmed() {
		system.runas(users[0]){
			ASPISServiceOrderDeliveryConfirmed sodc = new ASPISServiceOrderDeliveryConfirmed();
			test.startTest();
				sodc.executeProcess(purchaseOrders[1]);
			test.stoptest();
		}
	}*/
	
}