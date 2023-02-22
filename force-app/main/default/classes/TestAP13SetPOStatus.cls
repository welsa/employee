/*************************************************************************************
Class Name - TestAP13SetPOStatus
Version - 1.0
Created Date - 09 Dec 2015
Function - Test class of AP13SetPOStatus

Modification Log :
-----------------------------------------------------------------------------
* Developer          Date         Description
* ----------       ----------  -----------------------
* Ashwina Seetaram    09/12/2015    C-001405: Nouveau statut "payé"
*************************************************************************************/
@isTest
private class TestAP13SetPOStatus {
/*
	static list<Account> accounts;
	static list<user> users;
	public static list<PurchaseOrder__c> purchaseOrders1 = new list<PurchaseOrder__c>();
	public static list<PurchaseOrder__c> purchaseOrders2 = new list<PurchaseOrder__c>();
	public static list<PurchaseOrder__c> purchaseOrdersAll = new list<PurchaseOrder__c>();
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
                                         ProfileId = ASPISConstants.getProfileAdminId())}; 
        //insert users;
        ASPISTestUtils.generateTestUsers(users);
        
        // @CLA  To avoid the error with the class AP09
        InvoiceMargin__c newCSInvoiceMagin = new InvoiceMargin__c(Name ='FR', CountryCode__c = 'FR', ValidationMargin__c = 1);
        insert newCSInvoiceMagin;

       	system.runas(users[0]){    
			accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);

	        accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
                                                     RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                                                     ReferenceNumber__c = '123',
                                                     ContactEmail__c = 'bt1@gmail.com',
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
		                                             ShippingCountryCode = 'FR')};
	        ASPISTestUtils.generateAccount(accounts);

			assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001',
		                                                     AssessmentNumber__c = 'ASSESS_TEST-0001',
		                                                     BodyShop__c = accounts[0].Id,
		                                                     Entity__c = 'AXA Direct',
		                                                     EntityRules__c = 'AXA Direct',
		                                                     MissionNumber__c = '01',
		                                                     PortfolioAgentCode__c = '355',
		                                                     AssessmentID__c = '0912',
		                                                     TechExternalId__c = '233')};
			//insert assessments ;
			ASPISTestUtils.generateAssessment(assessments);

	        //for(integer i = 0; i<=5; i++){
			//	purchaseOrders1.add(new PurchaseOrder__c(Distributor__c =accounts[0].Id, ValidityDate__c=date.today(),Status__c ='DELIVEREDCONFIRMED',Assessment__c=assessments[0].id);
			//}
			//for(integer i = 0; i<=5; i++){
			//	purchaseOrders1.add(new PurchaseOrder__c(Distributor__c =accounts[1].Id, ValidityDate__c=date.today(),Status__c ='DELIVEREDCONFIRMED',Assessment__c=assessments[0].id);
			//}
			//purchaseOrdersAll.addAll(purchaseOrders1);
			//purchaseOrdersAll.addAll(purchaseOrders2);
			purchaseOrdersAll= new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c =accounts[1].Id, ValidityDate__c=date.today(),Status__c ='DELIVEREDCONFIRMED',Assessment__c=assessments[0].id),
						          new PurchaseOrder__c(Distributor__c =accounts[2].Id, ValidityDate__c=date.today(),Status__c ='DELIVEREDCONFIRMED',Assessment__c=assessments[0].id)};
			ASPISTestUtils.generatePurchaseOrder(purchaseOrdersAll);
		}
 	}
  

	@isTest static void testUpdateInvoicesUpdatePO() {
	    // All invoices inserted are PAID
	    system.runas(users[0]){
			test.startTest();
				list<Invoice__c> invoicesList = new list<Invoice__c>();
				list<Invoice__c> invoicesList1 = new list<Invoice__c>();
				list<Invoice__c> invoicesList2 = new list<Invoice__c>();
				list<Invoice__c> invoicesList3 = new list<Invoice__c>();
				list<Invoice__c> invoicesList4 = new list<Invoice__c>();
				list<Invoice__c> invoicesList5 = new list<Invoice__c>();
				list<Invoice__c> invoicesListAll = new list<Invoice__c>();
				for(integer i = 0; i<200; i++){
					invoicesList.add(new Invoice__c(PurchaseOrder__c = purchaseOrdersAll[0].id, RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(), status__c = 'PAID'));
					invoicesList2.add(new Invoice__c(PurchaseOrder__c = purchaseOrdersAll[1].id, RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(), status__c = 'PAID'));
				}
				for(integer i = 0; i<55; i++){
					invoicesList3.add(new Invoice__c(PurchaseOrder__c = purchaseOrdersAll[1].id, RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId(), status__c = 'RECEIVED'));
				}
				invoicesListAll.addAll(invoicesList);
				invoicesListAll.addAll(invoicesList2);	
				invoicesListAll.addAll(invoicesList3);	
				insert invoicesListAll;
				system.assertEquals([Select TechToBeProcessed__c from PurchaseOrder__c where id=: purchaseOrdersAll[0].id].TechToBeProcessed__c, true);
						
			test.stopTest();				
	    }
	}
	*/
}