/*************************************************************************************
Class Name - VFC29_ASPartners_TEST
Version - 1.0
Created Date - 25 October 2021
Function - TestClass to VFC29_ASPartners_TEST

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* RLA           25/10/2021  Original Version
*************************************************************************************/

@isTest
private class VFC29_ASPartners_TEST {
    
    static User userAdmin;
    static User CCBodyShopUser;
    static User userBS;
	static list<Account> accounts;
    static List<Attachment> lstAttachment;
    static Contact con;
    static list<AccountRef__c> listAccountRef;
	static Map <String,Id> profileNameMapId;

    
    static {
        accounts = new list<Account>();
        lstAttachment = new list<Attachment>();
        listAccountRef = new List<AccountRef__c>();
        // UserRole r1 = [SELECT Id FROM UserRole WHERE DeveloperName LIKE 'FR - AlphaScale%' limit 1];
        
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = 'FR2589741361';//WCH 23/12/2020 C-004120
        userAdmin.userroleId=[select Id from UserRole where name='FR - AlphaScale' limit 1].Id;
        insert userAdmin;

        

        system.runas(userAdmin){
            
            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist2.Partner_Available__c = true;
            dist2.Tech_Distributor__c = 'OPISTO';
            dist2.TypeOfService__c = 'PRE';
            dist2.E_Part_Backgound_Color__c = '#b0ca33';
            dist2.E_part_Order_Link__c = 'null';
            dist2.E_Part_Text_Color__c = '#FFFFFF';
            dist2.ReferenceOEM__c = true;
            accounts.add(dist2); 
            
            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist1.Partner_Available__c = true;
            dist1.TypeOfService__c = 'PRE';
            accounts.add(dist1); 
            
             Account dist3 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');
            dist3.Partner_Available__c = false;
            accounts.add(dist3);
            
            Account BS = TestFactory.createAccountBodyshop('BS', 'FR');
            BS.ReferenceNumber__c = 'FR1215727904';
            accounts.add(BS);
            
            insert accounts;
            
            con = TestFactory.createInsuredContact('firstName', 'lastName', BS.Id,  'Nord' );
            insert con;
            
            Attachment att1 =  new Attachment(ParentId = accounts[0].Id,ContentType = 'image/png', Name = 'LOGOASPARTNER', Body = Blob.valueOf('hi' ));
			lstAttachment.add(att1);      
            insert lstAttachment;
            
             
            AccountRef__c accRef1 = TestFactory.createAccountRef('FR1215727904', BS.Id, 'OPISTO');
            accRef1.ExternalReference__c='2722835';
            listAccountRef.add(accRef1);
            insert listAccountRef;

           
        }
    }
    
    static testmethod void testAssessmentAlreadyExist(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.ASPartners);

            Test.startTest();
                VFC29_ASPartners controller = new VFC29_ASPartners();
            Test.stopTest();

            //system.assertEquals(true,controller.hasSO);
        }
    }

    static testmethod void testAuthenticateRem(){
        Test.setMock(HttpCalloutMock.class, new DistributorMockCallout());
        system.runas(userAdmin){
            Test.setCurrentPage(Page.ASPartners);

            Test.startTest();
                VFC29_ASPartners controller = new VFC29_ASPartners();
                VFC29_ASPartners.authenticateRem('OPISTO;FBS');
            Test.stopTest();

            //system.assertEquals(true,controller.hasSO);
        }
    }

    static testmethod void testcalloutError(){
        Test.setMock(HttpCalloutMock.class, new DistributorMockCallout());
        system.runas(userAdmin){
            Test.setCurrentPage(Page.ASPartners);

            Test.startTest();
                VFC29_ASPartners controller = new VFC29_ASPartners();
                VFC29_ASPartners.callDistributor('OPISTO','12345');
            Test.stopTest();

            //system.assertEquals(true,controller.hasSO);
        }
    }

    // static testmethod void testcalloutGood(){
    //     Test.setMock(HttpCalloutMock.class, new DistributorMockCallout());    
           

    //     system.runas(userAdmin){
    //         // insert newDist;  
    //         Test.setCurrentPage(Page.ASPartners);

    //         Test.startTest();
    //             VFC29_ASPartners controller = new VFC29_ASPartners();
    //             VFC29_ASPartners.doAllow =  true;
    //             VFC29_ASPartners.callDistributor('OPISTO','12345');
    //         Test.stopTest();

    //         //system.assertEquals(true,controller.hasSO);
    //     }
    // }
}