/***********************************************************************************************************
Trigger Name - TestAP22PopulateContactOnAccount
Version - 1.0
Created Date - 15 DEC 2015
Function - Test Class for TestAP22PopulateContactOnAccount

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Brayan  		15/12/2015 	Original Version
************************************************************************************************************/
@isTest
private class TestAP22PopulateContactOnAccount { 
/*	public static list <User> users;
	public static list <Account> accounts;
	static{
		users = new list<User>{new User(Username = 'jb@test.com',
                                         LastName = 'Ballack',
                                         FirstName = 'Jean',
                                         Email = 'Jean@test.com',
                                         Alias = 'JBAL',
                                         LanguageLocaleKey = 'en_US',
                                         TimeZoneSidKey = 'Europe/Dublin',
                                         LocaleSidKey = 'en_US',
                                         EmailEncodingKey = 'UTF-8',
										 DistributorID__c = '123456',
                                         ProfileId = ASPISConstants.getProfileAdminId()),
								new User(Username = 'jb@test.com',
                                         LastName = 'Ballock',
                                         FirstName = 'Jean',
                                         Email = 'Ballock@test.com',
                                         Alias = 'JBAL',
                                         LanguageLocaleKey = 'en_US',
                                         TimeZoneSidKey = 'Europe/Dublin',
                                         LocaleSidKey = 'en_US',
                                         EmailEncodingKey = 'UTF-8',
										 BodyShopID__c = '123',
                                         ProfileId = ASPISConstants.getProfileAdminId())
        }; 
        ASPISTestUtils.generateTestUsers(users);
	}

	static testMethod void myUnitTest() {
		accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
													 RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId(),
													 ReferenceNumber__c = '123',
													 ContactEmail__c = 'bt1@gmail.com',
													 ShippingCountryCode = 'FR',
													 ReferentialASforAParts__c = 20,
													 ReferentialASforBCParts__c = 25,
													 LowKeepDiscountforAParts__c = 10),
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
		Test.startTest();
		insert accounts;

		for (Account a : [Select Id,ContactUser__c from Account where id in :accounts])
		{
			system.assertEquals(true, a.ContactUser__c != null);
		}
		Test.stopTest();
	}
*/
}