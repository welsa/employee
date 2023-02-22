/*************************************************************************************
Class Name - TestAccountTriggerHandler
Version - 1.0
Created Date - 29 APR 2015
Function - TestClass to AccountTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Yudish R  	29/10/2015 	Original Version
* Shamina M     11/02/2016  Case C-001496 - Use the Reference Number in Public Group for sharing to BS and Dist
*************************************************************************************/
@isTest
private class TestAccountTriggerHandler { 
/*
	static User userAdmin;
	static list<Account> accounts;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	
	static{
		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
		
		userAdmin = new User(Username = 'jean.paul@test.com'
                    ,LastName = 'paul'
                    ,LanguageLocaleKey = 'en_US'
                    ,FirstName = 'jean'
                    ,Email = 'jean@test.com'
                    ,Alias = 'jpa'
                    ,TimeZoneSidKey = 'Europe/Dublin'
                    ,LocaleSidKey = 'en_US'
                    ,EmailEncodingKey = 'UTF-8'
                    ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
         ASPISTestUtils.generateTestUser(userAdmin);
        
        system.runas(userAdmin){
        	// insert accounts
        	accounts = new list<Account>{
        		new Account(Name='BodyShop_ScTest1'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
        			,ReferenceNumber__c = '123'
        			,ContactEmail__c = 'bt1@gmail.com'
                    ,VAT__c = 10
        		),
        		new Account(Name='BodyShop_ScTest2'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
        			,ReferenceNumber__c = '1234'
        			,ContactEmail__c = 'bt2@gmail.com'
                    ,VAT__c = 10
        		),
        		new Account(Name='Distributor_ScTest1'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
        			,ReferenceNumber__c = '12345'
        			,ContactEmail__c = 'dt1@gmail.com'
                    ,VAT__c = 10
        		),
        		new Account(Name='Distributor_ScTest2'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
        			,ReferenceNumber__c = '123456'
        			,ContactEmail__c = 'dt1@gmail.com'
                    ,VAT__c = 10
        		)
        	};
        	
        }//end runAs
	}//end method
	
	
    static testMethod void publicGroupOnInsertTest() {
        system.debug('#### Start of method publicGroupOnInsertTest');
        
        system.runAs(userAdmin){	
        	test.starttest();	
        		insert accounts;
        	test.stoptest();
        	
        	set<string> accountRef = new set<string>();
        	for(Account a: accounts){
        		accountRef.add(a.ReferenceNumber__c);
        	}
        	
        	list<Group> groupAssertList = [select Id, Name 
        									from Group 
        									where Name IN:accountRef order by Name];
        	//system.debug('////groupAssertList: '+groupAssertList);
        	
        	system.assertEquals(4,groupAssertList.size());
        	
        	system.assertEquals(accounts[0].ReferenceNumber__c,groupAssertList[0].Name);
        	system.assertEquals(accounts[1].ReferenceNumber__c,groupAssertList[1].Name);
        	system.assertEquals(accounts[2].ReferenceNumber__c,groupAssertList[2].Name);
        	system.assertEquals(accounts[3].ReferenceNumber__c,groupAssertList[3].Name);
        }//end runAs
    }//end method
   */
    //Shamina M: case 1496 - update on group is no longer applicable when account name is updated
    /*
    static testMethod void publicGroupOnUpdateTest() {
        system.debug('#### Start of method publicGroupOnUpdateTest');
        
        system.runAs(userAdmin){	
        	insert accounts;
        	test.starttest();
        		accounts[0].Name = 'BodyShop_ScTest1.1';
        		accounts[1].Name ='BodyShop_ScTest2.1';
        		accounts[2].Name ='Distributor_ScTest1.1';
        		update accounts;
        	test.stoptest();
        	
        	set<string> accountRef = new set<string>();
        	for(Account a: accounts){
        		accountRef.add(a.ReferenceNumber__c);
        	}
        	
        	list<Group> groupAssertList = [select Id, Name 
        									from Group 
        									where Name IN:accountRef order by Name];
        	system.debug('////groupAssertList: '+groupAssertList);
        	
        	system.assertEquals(4,groupAssertList.size());
        	
        	system.assertEquals(accounts[0].ReferenceNumber__c,groupAssertList[0].Name);
        	system.assertEquals(accounts[1].ReferenceNumber__c,groupAssertList[1].Name);
        	system.assertEquals(accounts[2].ReferenceNumber__c,groupAssertList[2].Name);
        	system.assertEquals(accounts[3].ReferenceNumber__c,groupAssertList[3].Name);
        }//end runAs
    }//end method
    */
}