/*************************************************************************************
Class Name - VFC24_CreateNewCommunityUser_TEST
Version - 1.0
Created Date - 12 NOV 2018
Function - TestClass to VFC24_CreateNewCommunityUser

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Welsa C       12/11/2018  Original Version
* Welsa C       24/08/2020  C-003838 - Nob - Migrate Billing information to new fields
*************************************************************************************/
@isTest
private class VFC24_CreateNewCommunityUser_TEST {
    static User userAdmin;
    static User prefikarUser;
    static list<Account> accounts;
    static list<Contact> contacts;

    static {
        // initialising variables
        accounts = new list<Account>();
        contacts = new list<Contact>();
        UserRole ur =[SELECT Id FROM UserRole WHERE DeveloperName = 'AlphaScale'];
        String paintingPermissionSetCC='';
        for(Schema.PicklistEntry thePM : Account.Permission_Sets__c.getDescribe().getPicklistValues()){
            if(thePM.getLabel().equals('CC Painting')){
                paintingPermissionSetCC=thePM.getValue();
            }
        }



        userAdmin = TestFactory.createUser('iamtheadminUser');
        userAdmin.EmailEncodingKey = 'ISO-8859-1';
        userAdmin.CommunityNickname = 'testUser123';
        userAdmin.IsActive = true;
        userAdmin.UserRoleId =ur.Id;
        userAdmin.LanguageLocaleKey = 'fr';
        userAdmin.LocaleSidKey= 'fr_FR';

        insert userAdmin;

        system.runas(userAdmin){

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');        
            bs1.ReferenceNumber__c = 'FR2589741363';
            bs1.BillingCity__c = 'Paris';
            bs1.ContactEmail__c = 'test@example.com';
            bs1.BillingStreet__c = '123 rose';
            bs1.BillingPostalCode__c = '12345';
            bs1.BillingCountryCode__c = 'FR';
            bs1.BillingCountry__c = 'France';
            bs1.isEligibleSubstitution__c = true;
            bs1.ExpertSubstitutionMethod__c='FORCED';
            bs1.Permission_Sets__c=paintingPermissionSetCC;
            accounts.add(bs1);
			
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');        
            bs2.ReferenceNumber__c = 'FR2589741362';
            bs2.BillingCity__c = 'Paris';
            bs2.ContactEmail__c = 'test2@example.com';
            bs2.BillingStreet__c = '122 rose';
            bs2.BillingPostalCode__c = '123451';
            bs2.BillingCountryCode__c = 'FR';
            bs2.BillingCountry__c = 'France';
            bs2.isEligibleSubstitution__c = true;
            bs2.ExpertSubstitutionMethod__c='FORCED';
            bs2.Permission_Sets__c=paintingPermissionSetCC;
            accounts.add(bs2);
            
            insert accounts;

            //create contact
            Contact con1 = new Contact (AccountId = accounts[0].Id, LastName = 'testcontact');
            contacts.add(con1);
            Contact con2 = new Contact (AccountId = accounts[1].Id, LastName = 'testcontact2');
            contacts.add(con2);
            insert contacts;
        }
        prefikarUser=TestFactory.createUserBodyshop('prefikar');
        prefikarUser.IsActive =true;
        prefikarUser.ProfileId=[select Id from Profile where name='CC Bodyshop Order'].Id;//could not put CCP Bodyshop coz process builder NOB_CreateCalendarView fails
        prefikarUser.ContactId=contacts[1].Id;
        insert prefikarUser;
    }
    static testmethod void testUserActivationBS_FR(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.VFP24_CreateNewCommunityUser);

            ApexPages.currentPage().getParameters().put('Id', contacts[1].Id);
            ApexPages.currentPage().getParameters().put('isP', 'true');

            Test.startTest();
                VFC24_CreateNewCommunityUser controller = new VFC24_CreateNewCommunityUser();
                Id userId = VFC24_CreateNewCommunityUser.updateUserRelated(controller.accJSON,prefikarUser.Id,false);
                VFC24_CreateNewCommunityUser.createAccRefUpdateAcc('FR_DIVA', 'test' , accounts[0].Id,true,true, userId);
                controller.newExternalReference = '464f6ff12';
                controller.newSystemCalling = 'FR_DIVA';
                controller.redirectPage();
            Test.stopTest();

            system.assertEquals(1,[select Id, Username from User where Username like 'prefikar%@test.com'].size());
        }
    }

    static testmethod void testUserCreationBS_FR(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.VFP24_CreateNewCommunityUser);

            ApexPages.currentPage().getParameters().put('Id', contacts[0].Id);

            Test.startTest();
                VFC24_CreateNewCommunityUser controller = new VFC24_CreateNewCommunityUser();
                Id userId = VFC24_CreateNewCommunityUser.createNewUserRelated(controller.accJSON,controller.conJSON, 'Balack@gmail.com.fr', 'test@example.com', 'Balack', 'Jean', true, controller.newUserPassword,'fr',true,false);
                VFC24_CreateNewCommunityUser.createAccRefUpdateAcc('FR_DIVA', 'test' , accounts[0].Id,true,true, userId);
                controller.newExternalReference = '464f6ff';
                controller.newSystemCalling = 'FR_DIVA';
                controller.redirectPage();
            Test.stopTest();

            system.assertEquals(1,[select Id, LastName from User where LastName = 'Jean'].size());
        }
    }

    static testmethod void testUserCreationBS_BE(){
        system.runas(userAdmin){
            userAdmin.CountryCode = 'BE';
            userAdmin.LanguageLocaleKey = 'nl_BE';
            userAdmin.TimeZoneSidKey = 'Europe/Brussels';
            userAdmin.LocaleSidKey = 'nl_BE';
            update userAdmin;

            Test.setCurrentPage(Page.VFP24_CreateNewCommunityUser);

            ApexPages.currentPage().getParameters().put('Id', contacts[0].Id);

            Test.startTest();
                VFC24_CreateNewCommunityUser controller = new VFC24_CreateNewCommunityUser();
                Id userId = VFC24_CreateNewCommunityUser.createNewUserRelated(controller.accJSON,controller.conJSON, 'Balack@gmail.com.fr', 'test@example.com', 'Balack', 'Jean', true, controller.newUserPassword,'fr',true,false);
                VFC24_CreateNewCommunityUser.createAccRefUpdateAcc('FR_DIVA', 'test' , accounts[0].Id,true,true, userId);
                controller.newExternalReference = '464f6ff';
                controller.newSystemCalling = 'FR_DIVA';
                controller.redirectPage();
            Test.stopTest();

            system.assertEquals(1,[select Id, LastName from User where LastName = 'Jean'].size());

        }
    }
}