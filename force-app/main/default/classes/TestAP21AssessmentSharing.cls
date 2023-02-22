/***********************************************************************************************************
Trigger Name - TestAP20GenerateBodyshopInvoicesInCSV
Version - 1.0
Created Date - 18 NOV 2015
Function - Test Class for AP20GenerateBodyshopInvoicesWithPOinCSV

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Brayan  		30/11/2015 	Original Version
************************************************************************************************************/
@isTest
private class TestAP21AssessmentSharing { 
/*
	public static list <User> users;
    public static list <Account> accounts;
    public static date myDate;
    public static datetime myDateTime;
	static list<Group> groups;

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

	        List<Account> insertedAccounts = [Select Name from Account where Id in:accounts order by RecordTypeId];

	        if(insertedAccounts.size() > 2){
	            groups = new list<Group>{
	                new Group(Name=insertedAccounts[0].Name, Type='Regular'),
	                new Group(Name=insertedAccounts[2].Name, Type='Regular')
	              };
	              insert groups;
	        }

		}
	}

	static testMethod void myUnitTest() {
		system.runas(users[0]){
			list<Assessment__c> assessments = new list<Assessment__c>{new Assessment__c( Name='ASSESS_TEST-0001',
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
			Test.startTest();
				ASPISTestUtils.generateAssessment(assessments); 

				List<Assessment__Share> aShareList = [Select Id from Assessment__Share where ParentId in :assessments];
				System.assertEquals(true, aShareList.size() > 0);
			Test.stopTest();
		}
	}
	*/
}