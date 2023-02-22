/*************************************************************************************
Class Name - TestAspisBatch_SOMigration
Version - 1.0
Created Date - 20 AUG 2018
Function - TestClass to AspisBatch_SOMigration

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* LGO           20/08/2018  Original Version
*************************************************************************************/



@isTest
private class TestAspisBatch_SOMigration {

    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static map <String,Id> proRecordTypeMap = new map <String,Id>();
    static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PrerequisiteOrder__c> prerequisiteOrders;
 

    
    static{

        accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
        proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);

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
            accounts = new list<Account>{//WCH 23/12/2020 C-004120
                new Account(Name='BodyShop_ScTest1', ContactEmail__c = 'test@test.com',VATNumber__c = '0', ReferenceNumber__c ='FR2589741361'
                   ,VAT__c = 0 ,ASEntity__c = 'ASDE1' ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                   ,ArchivedContactUser__c = userAdmin.Id
                ),
                new Account(Name='Distributor_ScTest1', ContactEmail__c = 'test@test.com',VATNumber__c = '0', ReferenceNumber__c ='TEST002'
                   ,VAT__c=0 ,ASEntity__c = 'ASDE1',RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                   ,ArchivedContactUser__c = userAdmin.Id
                )
            };
            insert accounts;
            system.debug('<<accounts >>'+accounts);

            //assessments
            assessments = new list<Assessment__c>{
                new Assessment__c(BodyShop__c = accounts[0].Id) 
            };
            
            insert assessments;

            //PrerequisiteOrder
            prerequisiteOrders= new list<PrerequisiteOrder__c>{
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                    ,BodyShopContact__c=accounts[0].ArchivedContactUser__c
                ),
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                    ,BodyShopContact__c=accounts[0].ArchivedContactUser__c
                ),
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                    ,BodyShopContact__c=accounts[0].ArchivedContactUser__c
                )
            };
            insert prerequisiteOrders;
            
            update accounts;
            update prerequisiteOrders;

            PrerequisiteOrder__c test = [SELECT ID, BodyShopContact__c, CommunitiesSOToMigrate__c FROM PrerequisiteOrder__c WHERE Id =: prerequisiteOrders[0].Id ];

            list<Account >testacc = [SELECT ID, ArchivedContactUser__c FROM Account WHERE Id =: accounts[0].Id ];
            system.debug('<<prerequisiteOrders TEST >>'+test);
            system.debug('<<account TEST >>'+testacc);
            system.debug('<<prerequisiteOrders >>'+prerequisiteOrders);

        }

    }
    
       static testmethod void test() {        
        Test.startTest();
        AspisBatch_SOMigration uso = new AspisBatch_SOMigration();
        Id batchId = Database.executeBatch(uso);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(3, [select count() from PrerequisiteOrder__c where lastmodifieddate >= TODAY ]);
    }

}