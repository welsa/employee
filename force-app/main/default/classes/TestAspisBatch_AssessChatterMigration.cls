@isTest
private class TestAspisBatch_AssessChatterMigration
{
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
                   ,ArchivedContactUser__c = userAdmin.Id,ContactUser__c = userAdmin.Id, Communities_Batch_1_Chatter_to_Migrate__c =true
                );//WCH 23/12/2020 C-004120
                
            insert accounts;

            //Cases
            Assessment__c assess =  
                new Assessment__c(Name ='TestAssessment' ,BodyShop__c = accounts.Id, AssessmentNumber__c = '12345') ;
            
            
            insert assess;
            update accounts;
            update assess;

            //Feed Item
            FeedItem FItem =  
                new FeedItem(Body = 'Test', ParentId = assess.id, Visibility = 'InternalUsers') ;

            Insert FItem;
            update assess;
            update FItem;


        }

    }
    
       static testmethod void test() {        
        Test.startTest();
        AspisBatch_AssessChatterMigration acm = new AspisBatch_AssessChatterMigration();
        Id batchId = Database.executeBatch(acm);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(1, [select count() from FeedItem where lastmodifieddate >= TODAY ]);
    }
}