/********************************************************************************
Apex Class Name - TestAgreementCtrl 
Version - 1.0
Created Date - July 08, 2015
Function - Contains unit test methods for the Class AgreementCtrl

Modification Log : 
--------------------------------------------------------------------------------

* Developer             Date                Description
* -----------------    ------------         -----------------------
* Immo Salo            08/07/2015           Original Version

********************************************************************************/
@isTest()
private class TestAgreementCtrl { 
/*
    private static testMethod void testAgreement() {
        
        // Create test users userAdmin and userAdmin2
        User userAdmin = new User(Username = 'jk678236712637216@test.com',
                         LastName = 'Jack',
                         FirstName = 'Kurry',
                         Email = 'KurryJack@test.com',
                         Alias = 'KJac213',
                         LanguageLocaleKey = 'fr',
                         TimeZoneSidKey = 'Europe/Dublin',
                         LocaleSidKey = 'en_US',
                         EmailEncodingKey = 'UTF-8',
                         General_Agreement__c = false,
                         ProfileId = ASPISConstants.getProfileAdminId()
        );
        ASPISTestUtils.generateTestUser(userAdmin);        

        User userAdmin2 = new User(Username = 'jk26634333444@test.com',
                         LastName = 'Jack',
                         FirstName = 'Kurry',
                         Email = 'KurryJack3443122222@test.com',
                         Alias = 'KJac2',
                         LanguageLocaleKey = 'fi',
                         TimeZoneSidKey = 'Europe/Dublin',
                         LocaleSidKey = 'en_US',
                         EmailEncodingKey = 'UTF-8',
                         General_Agreement__c = false,
                         ProfileId = ASPISConstants.getProfileAdminId()
        );
        ASPISTestUtils.generateTestUser(userAdmin2);
        // insert document that works as agreement template
        Document doc = new Document(
            Name = 'General Agreement',
            DeveloperName = 'General_Agreement',
            Description = 'Love it',
            Body = Blob.valueOf('Hi Friends'),
            ContentType = 'text/plain; charset=UTF-8',
            AuthorId = UserInfo.getUserId(),
            FolderId = UserInfo.getUserId()
        );
        insert doc;

        // insert Custom setting that is used by AgreementCtrl class
        CS_Agreement__c setting = new CS_Agreement__c();
        setting.Name = 'AgreementConfiguration';
        setting.Agreement_Document__c = 'General_Agreement';
        setting.User_Field__c = 'General_Agreement__c';
        setting.Url_Context__c = '/home/home.jsp';
        setting.Active__c = True;
        setting.General__c = True;
        insert setting;
        
        //start test    
        Test.startTest();
        
        // test user with language fr
        System.runAs(userAdmin){   
            ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
            AgreementCtrl ac = new AgreementCtrl();
            ac.Init();
            ApexPages.currentPage().getParameters().put('name', 'AgreementConfiguration');
            ac.Init();
            ac.Agree();
            
            // check that General_Agreement__c field was checked True
            User testUser1 =  [SELECT Id, General_Agreement__c FROM User where LastName = 'Jack' limit 1];           
            System.assertEquals(testUser1.General_Agreement__c,True);
        }

        // test user with language other than fr        
        System.runAs(userAdmin2){   
            ApexPages.currentPage().getHeaders().put('referer', '/home/home.jsp');
            AgreementCtrl ac = new AgreementCtrl();
            ac.Init();
            ApexPages.currentPage().getParameters().put('name', 'AgreementConfiguration');
            ac.Init();
            ac.Agree();

             // check that General_Agreement__c field was checked True
            User testUser2 =  [SELECT Id, General_Agreement__c FROM User where LastName = 'Jack' limit 1];           
            System.assertEquals(testUser2.General_Agreement__c,True);
        }
        
        //end test
        Test.stopTest();
    }    */
}