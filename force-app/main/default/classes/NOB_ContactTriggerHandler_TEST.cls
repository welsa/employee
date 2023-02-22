/*
 @File Name          : NOB_ContactTriggerHandler_TEST
 @Description        : 
 @Author             : HMO
 @Group              : 
 @Last Modified By   : ARA
 @Last Modified On   : 01-26-2021
 @Modification Log   : 
 ==============================================================================
  Ver         Date            Author      Modification
 ==============================================================================
  1.0    16/11/2020, 16.30     HMO          1.0
  1.1    14/01/2021            KPA          1.1
*/

@isTest
public with sharing class NOB_ContactTriggerHandler_TEST {
   static List<Account> lstAccReparateur;
   static List<Account> lstAccAsssureur;
   static List<Contact> lstContactAssure;
   static List<Contact> lstContactReparateur;
   static List<Contact> lstContactConvoyeur;
   static Account accReparateur;
   static Contact contactReparateur;
   static Account accAssure;
   static Contact contactAssure;
   static User userAdmin;
   static User newUser;
   static User userAssureur;

   static{
    userAdmin = TestFactory.createPrefikarUser('adminUser');
    userAdmin.BypassValidationRules__c = true;
    userAdmin.BypassWorkflows__c = true;
    UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Prefikar' LIMIT 1];
    userAdmin.UserRoleId = userRole.Id;
    insert userAdmin;

    lstAccReparateur = new List<Account>();
    lstAccAsssureur = new List<Account>();
    lstContactAssure = new List<Contact>();
    newUser = new User();
    userAssureur = new User();


    System.runAs(userAdmin){
        accReparateur = TestFactory.createPrefikarBodyAccount('accReparateur', 'Réseau Premium','siret123','Actif');
        insert accReparateur;

        String recordTypeRep = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
        contactReparateur = new Contact(LastName = 'userContact', AccountId = accReparateur.Id, NOB_Status__c = 'Actif', recordTypeId = recordTypeRep);
        insert contactReparateur;

        accAssure = TestFactory.createInsurerAccount('accAssuree','FR');
        accAssure.NOB_SiretHeadquarters__c='Siret123456';
        insert accAssure;

        contactAssure = TestFactory.createInsuredContact('contact', 'Assuree', accAssure.Id,'Alsace Lorraine');
        
        insert contactAssure;

        newUser = TestFactory.createUser('newUser');
        Profile p = [select id from profile where name='CCP bodyshop'];
        newUser.profileId = p.Id;
        newUser.LastName = 'nob0';
        newUser.ContactId = contactReparateur.Id;
        newUser.isActive = true;
        newUser.PortalRole = '';
        insert newUser;

        userAssureur = TestFactory.createUser('userAssureur');
        Profile pAssureur = [select id from profile where name='PRE_CCP Assureur'];
        userAssureur.profileId = pAssureur.Id;
        userAssureur.LastName = 'nob0Assureur';
        userAssureur.ContactId = contactAssure.Id;
        userAssureur.isActive = true;
        userAssureur.PortalRole = '';
        insert userAssureur;

    }
   }

   @isTest
   public static void onAfterInsertReparateur(){
       System.runAs(newUser){
           Test.startTest();
          
                lstAccReparateur.add(TestFactory.createPrefikarBodyAccount('testAccBodyshop', 'Réseau Premium','siret12345','Actif'));
                lstAccReparateur[0].ContactEmail__c = 'test@test.com';
                lstAccReparateur[0].VATNumber__c = 'vat245686';
                lstAccReparateur[0].ReferenceNumber__c = 'FR0123456789';
                lstAccReparateur[0].ASEntity__c = 'ASFR1';
                lstAccReparateur[0].ExpertSubstitutionMethod__c = 'Forced';
                insert lstAccReparateur;
                String recordTypeRep = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
                lstContactReparateur = new List<Contact>{
                    new Contact (LastName = 'contactReparateur1', NOB_Status__c = 'Actif', AccountId = lstAccReparateur[0].Id, recordTypeId = recordTypeRep),
                    new Contact (LastName = 'contactReparateur2', NOB_Status__c = 'Actif', recordTypeId = recordTypeRep),
                    new Contact (LastName = 'contactReparateur3', NOB_Status__c = 'Actif', AccountId = lstAccReparateur[0].Id, recordTypeId = recordTypeRep)
                };
                insert lstContactReparateur;

               
           Test.stopTest();

           List<Contact> lstContacts = new List<Contact>([SELECT Id, createdById, Name FROM Contact WHERE Id IN :lstContactReparateur]);
           //System.assertEquals(3, lstContacts.size()); 
       }
   }

   @isTest
   public static void onAfterInsertAssureur(){
       System.runAs(userAssureur){
           Test.startTest();
            lstAccAsssureur.add(TestFactory.createInsurerAccount('testAccAssure','FR'));
            lstAccAsssureur[0].NOB_SiretHeadquarters__c='Siret123';
            lstAccAsssureur[0].ContactEmail__c = 'test@test.com';
           lstAccAsssureur[0].ReferenceNumber__c = 'v245686';
            lstContactAssure.add(TestFactory.createInsuredContact('test', 'contactAssure', lstAccAsssureur[0].Id,'Alsace Lorraine'));
            insert lstAccAsssureur;
            insert lstContactAssure;
           
            Contact cc = lstContactAssure[0];
           cc.MailingLatitude = 44;
           cc.MailingLongitude = 44;
           update cc;
           Test.stopTest();

           List<Contact> lstContactsAssure = new List<Contact>([SELECT Id, createdById, Name FROM Contact WHERE Id IN :lstContactAssure]);
           //System.assertEquals(1, lstContactsAssure.size()); 
       }
   }
}