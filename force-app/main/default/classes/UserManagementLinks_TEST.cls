/*************************************************************************************
Class Name - UserManagementLinks_TEST 
Version - 1.0
Created Date - 31 MAR 2021
Function - TestClass to UserManagementLinks

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* WCH           31/03/2021  Original Version
* 
*************************************************************************************/
@isTest
public class UserManagementLinks_TEST {
    
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
    
    @isTest
    static void resetUserPwd_Test(){
        system.runas(userAdmin){
            
            Test.startTest();
            UserManagementLinks.resetUserPassword(prefikarUser.id);
            Test.stopTest();

        }
    }
    @isTest
    static void ActivateDeactivateUser_Test(){
        system.runas(userAdmin){
            
            Test.startTest();
            UserManagementLinks.ActivateDeactivateUser(prefikarUser.id);
            Test.stopTest();

        }
    }
    @isTest
    static void UnlockUser_Test(){
        system.runas(userAdmin){
            
            Test.startTest();
            UserManagementLinks.UnlockUser(prefikarUser.id);
            Test.stopTest();

        }
    }
    
    
}