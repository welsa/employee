/**
 * @description       : Test class for NOB_AP55_AccountSharing
 * @author            : GBH
 * @group             : 
 * @last modified on  : 02-15-2021
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   02-15-2021   GBH   Initial Version
**/
@isTest
public without sharing class NOB_AP55_AccountSharingTEST {
    static User userAdmin;
    static list<Account> lstReparateur;
    static list<Account> lstAssureur;
    static list<NOB_AccountRelationship__c> lstRelationCompte;
    static list<NOB_AccountRelationship__c> lstRelationCompteBis;
    static list<Contact> lstContact;
    static list<User> lstUsers;

    static {

        UserRole portalRole1 = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        userAdmin.UserRoleId = portalRole1.Id;
        insert userAdmin;

        system.runas(userAdmin){
            lstReparateur = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Garage PFK', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarBodyAccount('Garage PFK2', 'Réseau Premium', '44057565200035','Actif')
            };

            lstReparateur[0].NOB_Ranking__c = 'Gold';
            lstReparateur[0].ContactEmail__c = 'test@test.com';
            lstReparateur[0].VATNumber__c = 'vat245686';
            lstReparateur[0].ReferenceNumber__c = 'FR0123456789';
            lstReparateur[0].ASEntity__c = 'ASFR1';
            lstReparateur[0].ExpertSubstitutionMethod__c = 'Forced';

            lstReparateur[1].NOB_Ranking__c = 'Gold';
            lstReparateur[1].ContactEmail__c = 'tsest@test.com';
            lstReparateur[1].VATNumber__c = 'vat245486';
            lstReparateur[1].ReferenceNumber__c = 'FR0123656787';
            lstReparateur[1].ASEntity__c = 'ASFR1';
            lstReparateur[1].ExpertSubstitutionMethod__c = 'Forced';

            insert lstReparateur;

            lstAssureur = new List<Account>{
                TestFactory.createInsurerAccount('AXA assurance','Nord'),
                TestFactory.createInsurerAccount('AXA assurance 2','Bourgogne')
            };

            lstAssureur[0].ReferenceNumber__c = 'FR0121237464';

            lstAssureur[1].ReferenceNumber__c = 'FR0121237424';
            insert lstAssureur;

            
            

            lstContact = new List<Contact>{
                new Contact(),
                new Contact(),
                new Contact()
            };

            lstContact[0].FirstName = 'contact 1';
            lstContact[0].Lastname = 'McTesty 1';
            lstContact[0].Email = 'contact.test1@nobilastest.com';
            lstContact[0].AccountId = lstReparateur[0].id;
            lstContact[0].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
            
            lstContact[1].FirstName = 'contact 2';
            lstContact[1].Lastname = 'McTesty 2';
            lstContact[1].Email = 'contact.test1@nobilastest.com';
            lstContact[1].AccountId = lstReparateur[1].id;
            lstContact[1].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
            
            lstContact[2].FirstName = 'contact 3';
            lstContact[2].Lastname = 'McTesty 3';
            lstContact[2].Email = 'contact.test3@nobilastest.com';
            lstContact[2].AccountId = lstReparateur[1].id;
            lstContact[2].RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('NOB_Contact_Reparateur').getRecordTypeId();
            insert lstContact;

            Profile profileBS = [Select Id from Profile where name = 'CCP Bodyshop'];

            lstRelationCompte = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[1].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[1].Id, 'Réparateur - Assureur')
            };
                
             lstRelationCompteBis = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReparateur[0].Id, lstAssureur[1].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[0].Id, 'Réparateur - Assureur'),
                TestFactory.createRelationCompte(lstReparateur[1].Id, lstAssureur[1].Id, 'Réparateur - Assureur')
            };
                
                insert lstRelationCompteBis;
            
            
            lstUsers = new List<User>{
                TestFactory.createUser('testUser1'),
                TestFactory.createUser('testUser2'),
                TestFactory.createUser('testUser2')
            };
            lstUsers[0].ContactId = lstContact[0].id;
            lstUsers[0].NOB_isPrefikar__c = true;
            lstUsers[0].ProfileId = profileBS.id;

            lstUsers[1].ContactId = lstContact[1].id;
            lstUsers[1].NOB_isPrefikar__c = true;
            lstUsers[1].ProfileId = profileBS.id;
            
            lstUsers[2].ContactId = lstContact[2].id;
            lstUsers[2].NOB_isPrefikar__c = true;
            lstUsers[2].ProfileId = profileBS.id;

            insert lstUsers;
            
            
            
        }
    }

    @isTest
    public static void insertAndDeleteAccRel(){
        System.runAs(userAdmin){
            
            Test.startTest();
            
            insert lstRelationCompte;
            

            delete lstRelationCompte;
            
            Test.stopTest();

            Set<AccountShare> setAccountShare = new Set<AccountShare>([SELECT Id FROM AccountShare where UserOrGroupId IN :lstUsers]);
            System.assertEquals(6, setAccountShare.size());
        }
    }
}