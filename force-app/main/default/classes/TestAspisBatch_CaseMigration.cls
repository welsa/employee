/*************************************************************************************
Class Name - TestAspisBatch_CaseMigration
Version - 1.0
Created Date - 20 AUG 2018
Function - TestClass to AspisBatch_CaseMigration

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* LGO           20/08/2018  Original Version
*************************************************************************************/



@isTest
private class TestAspisBatch_CaseMigration {

    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static User userAdmin;

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
                        
        //insert userAdmin;
        insert userAdmin;

        system.runas(userAdmin){
            // insert accounts
            Account accounts = 
                new Account(Name='BodyShop_ScTest1', ContactEmail__c = 'test1@test.com',VATNumber__c = '0', ReferenceNumber__c ='FR2589741361'
                   ,VAT__c = 0 ,ASEntity__c = 'ASDE1' ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                   ,ArchivedContactUser__c = userAdmin.Id
                );//WCH 23/12/2020 C-004120
                
            insert accounts;

            //Cases
            Case__c Cases =  
                new Case__c(Account_Name__c = accounts.Id, Type__c = 'PROBLEM', Case_Reason__c = 'OTHER', Subject__c = 'Subject Test',SubmittedBy__c= userAdmin.Id ) ;
            
            
            insert Cases;
            update accounts;
            update Cases;



        }

    }
    
       static testmethod void test() {        
        Test.startTest();
        AspisBatch_CaseMigration uso = new AspisBatch_CaseMigration();
        Id batchId = Database.executeBatch(uso);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(1, [select count() from Case__c where lastmodifieddate >= TODAY ]);
    }

}