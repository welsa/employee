/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 19/03/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   02-18-2021   ARA   Initial Version
**/
@isTest
public with sharing class SVR_AP104_AuditReseauSharing_TEST {

    static List<User> listUsers;
    static List<User> listPortalUser;
    static List<Account> listAccount;
    static List<Contact> listContact;
    static List<SVR_AuditReseau__c> listAuditReseau;
    static UserRole userrole ;
    static List<User> listPrefitoolUser;
    static List<NOB_AccountRelationship__c> listAccountRelationship;
    static list<Account> lstAssureur;
    static list<NOB_TauxNeg__c> lstTauxNeg;

    static{
        //creating User
        listUsers = new List<User>{
            TestFactory.createPrefikarUser('Admin')
        };
        listAccountRelationship = new List<NOB_AccountRelationship__c>();

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'AlphaScale' Limit 1];

        listUsers[0].UserRoleId = userrole.id;
        listUsers[0].BypassWorkflows__c = true;
        system.debug('@@listUsers[0]'+listUsers[0]);

        System.runAs(listUsers[0]){

            
            //Create users
            listPrefitoolUser = new List<User>{
                TestFactory.createPrefitoolUser('ResponsableSector'),
                TestFactory.createPrefitoolUser('NomDeLauditeur'),
                TestFactory.createPrefitoolUser('NomDeLauditeur1'),
                TestFactory.createPrefitoolUser('ResponsableSector')
            };
            insert listPrefitoolUser;
            
            //Create Account
            listAccount = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Garage Prefitool Spoon', 'Réseau Platinium')
            };
            listAccount[0].SVR_AreaManager__c = listPrefitoolUser[0].Id;
            listAccount[0].OwnerID = listUsers[0].Id;
            insert listAccount;
            
            //create contact
            listContact = new List<Contact>{
                TestFactory.createBodyshopContact('Luffy', 'Monkey', listAccount[0].Id)
            };
            insert listContact;

            lstAssureur = new List<Account>{
                TestFactory.createInsurerAccount('AXA assurance','Nord'),
                TestFactory.createInsurerAccount('AXA assurance 2','Bourgogne')
            };
            lstAssureur[0].ReferenceNumber__c = 'FR0121237464';
            // lstAssureur[0].NOB_Type__c = 'Réparateur - Assureur';
            lstAssureur[1].ReferenceNumber__c = 'FR0121237424';
            lstAssureur[1].Name = 'AXA RM';
            insert lstAssureur;

            listAccountRelationship.add(TestFactory.createRelationCompte(listAccount[0].Id, lstAssureur[1].Id, 'Réparateur - Assureur'));
            listAccountRelationship[0].NOB_Type__c = 'Réparateur - Assureur';
            insert listAccountRelationship;

            lstTauxNeg = new List <NOB_TauxNeg__c>{
                TestFactory.createTauxNeg(listAccountRelationship[0].Id, Date.newInstance(System.today().year(), System.today().month()-2, System.today().day()), Date.newInstance(System.today().year(), System.today().month()+2, System.today().day()))
            };
            insert lstTauxNeg;


            //create Audit Reseau
            listAuditReseau = new List<SVR_AuditReseau__c>{
                TestFactory.createAuditRS(listPrefitoolUser[0],listAccount[0]),
                TestFactory.createAuditRS(listPrefitoolUser[0],listAccount[0])
            };
            listAuditReseau[1].SVR_NomAuditeur__c = listPrefitoolUser[1].id;
            listAuditReseau[1].SVR_ResponsableSecteur__c = listPrefitoolUser[0].Id;
            listAuditReseau[1].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId();

        }

    }

    @isTest
    public static void onAfterInsertTest(){
        System.runAs(listUsers[0]){
            Test.startTest();
                insert listAuditReseau;
            Test.stopTest();

        }
    }

    @isTest
    public static void onAfterUpdateTest(){
        System.runAs(listUsers[0]){
            insert listAuditReseau;
            listAuditReseau[1].SVR_NomAuditeur__c = listPrefitoolUser[2].id;
            listAuditReseau[1].SVR_ResponsableSecteur__c = listPrefitoolUser[3].Id;
            listAuditReseau[1].SVR_DateVisite__c = Date.newInstance(System.today().year(),
            System.today().month(), System.today().day()+7);
            Test.startTest();
                update listAuditReseau;
            Test.stopTest();
        }
    }

}