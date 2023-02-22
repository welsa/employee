/*************************************************************************************
Class Name - VFC16_CreateNewUser_TEST
Version - 1.0
Created Date - 12 JUNE 2017
Function - TestClass to VFC16_CreateNewUser

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      12/06/2017  Original Version
*************************************************************************************/
@isTest
private class VFC16_CreateNewUser_TEST {
	static User userAdmin;
    static list<Account> accounts;

	static {
        // initialising variables
        accounts = new list<Account>();
        
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        userAdmin.BodyShopID__c = '258974136';
        insert userAdmin;

        system.runas(userAdmin){

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');        
            bs1.ReferenceNumber__c = 'FR2589741361';//WCH 23/12/2020 C-004120
            bs1.BillingCity = 'Paris';
            bs1.ContactEmail__c = 'test@example.com';
			bs1.BillingStreet = '123 rose';
			bs1.BillingPostalCode = '12345';
			bs1.BillingCountryCode = 'FR';
			bs1.BillingCountry = 'France';
			bs1.isEligibleSubstitution__c = true;
            accounts.add(bs1);

            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'FR');    
            dist2.ReferenceNumber__c = 'FR5897413464';//WCH 23/12/2020 C-004120
            dist2.BillingCity = 'Paris';
            dist2.ContactEmail__c = 'test@example.com';
			dist2.BillingStreet = '123 rose';
			dist2.BillingPostalCode = '12345';
			dist2.BillingCountryCode = 'FR';
			dist2.BillingCountry = 'France';
			dist2.isEligibleSubstitution__c = true;
            accounts.add(dist2); 

            insert accounts;
        }
    }

	static testmethod void testUserCreationBS(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.VFP16_CreateNewUser);

            ApexPages.currentPage().getParameters().put('Id', accounts[0].Id);

            Test.startTest();
                VFC16_CreateNewUser controller = new VFC16_CreateNewUser();
                Id userId = VFC16_CreateNewUser.createNewUserRelated(controller.accJSON, 'Balack@gmail.com.fr', 'test@example.com', 'Balack', 'Jean', true, controller.newUserPassword);
                VFC16_CreateNewUser.createAccRefUpdateAcc('FR_DIVA', 'test' , accounts[0].Id,true, userId);
                controller.newExternalReference = '464f6ff';
                controller.newSystemCalling = 'FR_DIVA';
                controller.redirectPage();
            Test.stopTest();

            system.assertEquals(1,[select Id, LastName from User where LastName = 'Jean'].size());
        }
    }

	static testmethod void testUserCreationDist(){
        system.runas(userAdmin){
            Test.setCurrentPage(Page.VFP16_CreateNewUser);

            ApexPages.currentPage().getParameters().put('Id', accounts[1].Id);

            Test.startTest();
                VFC16_CreateNewUser controller = new VFC16_CreateNewUser();
                Id userId = VFC16_CreateNewUser.createNewUserRelated(controller.accJSON, 'Balack@gmail.com.fr', 'test@example.com', 'Balack', 'Jean', true, controller.newUserPassword);
                VFC16_CreateNewUser.createAccRefUpdateAcc('SIDEXA', 'test' , accounts[1].Id,true, userId);
            Test.stopTest();

            system.assertEquals(1,[select Id, LastName from User where LastName = 'Jean'].size());
        }
    }
}