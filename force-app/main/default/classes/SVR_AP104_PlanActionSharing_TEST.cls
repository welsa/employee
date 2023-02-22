/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 19/03/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   03-19-2021   ARA   Initial Version
**/
@isTest
public with sharing class SVR_AP104_PlanActionSharing_TEST {
    static List<User> listUser;
    static List<User> listPortalUser;
    static List<Account> listAccount;
    static List<Contact> listContact;
    static List<SVR_AuditReseau__c> listAuditReseau;
    static List<Audit_Plan_Action__c> lstPlanAction;
    static List<SVR_AuditOperationnel__c> lstAuditop;
    static List<NOB_AccountRelationship__c> listAccountRelationship;
    static list<Account> lstAssureur;
    static list<NOB_TauxNeg__c> lstTauxNeg;


    static{
        //Create User 'System admin'
        listUser = new List<User>{
            TestFactory.createPrefikarUser('userAdmin'),
            TestFactory.createPrefitoolGestionnaireUser('Gestionnaire'),
            TestFactory.createPrefitoolUser('ResponsableSector')
        };
        insert listUser;
        listAccountRelationship = new List<NOB_AccountRelationship__c>();

       
        System.runAs(listUser[0]){
            // create Account
            listAccount = new List<Account>{
                TestFactory.createPrefikarBodyAccount('Garage Prefitool Spoon1', 'Réseau Platinium'),
                TestFactory.createPrefikarBodyAccount('Garage Prefitool Spoon2', 'Réseau Platinium')
            };
            listAccount[0].SVR_AreaManager__c = listUser[1].Id;
            listAccount[1].SVR_AreaManager__c = listUser[1].Id;
            insert listAccount;

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
                TestFactory.createAuditRS(listUser[2],listAccount[0]),
                TestFactory.createAuditRS(listUser[2],listAccount[1])
            };
            listAuditReseau[1].SVR_ResponsableSecteur__c = listUser[2].Id;
            listAuditReseau[1].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId();
            insert listAuditReseau;

            // create Audit Operationnel
            lstAuditop  = new List<SVR_AuditOperationnel__c>{
                TestFactory.createAuditOP(listUser[0], listAccount[0]),
                TestFactory.createAuditOP(listUser[0], listAccount[1])
            };
            lstAuditop[0].Nom_du_gestionnaire__c = listUser[1].Id;
            insert lstAuditop;

            //create Audit plan action share.
            lstPlanAction = new List<Audit_Plan_Action__c>{
                TestFactory.createPlanActionOP(lstAuditop[0],'Acquis','Acquis','Acquis'),
                TestFactory.createPlanActionRS(listAuditReseau[1],'Mise sous tutelle','Acquis','Animation de la qualité','Acquis','Connaissance du SD','Acquis','Mise sous tutelle','Acquis','Maitrise des procédures Préfikar','Acquis','Connaissance du SD','Acquis','Mise sous tutelle','Acquis')
            };
            lstPlanAction[0].SVR_NomGestionnaire__c = listUser[1].Id;
            lstPlanAction[1].SVR_ResponsableSecteur__c = listUser[2].Id;
        }

    }
    @isTest
    public static void afterInsertTest(){
        System.runAs(listUser[0]){
            Test.startTest();
            insert lstPlanAction;
            Test.stopTest();
        }
    }
    @isTest
    public static void afterUpdateTest(){
        System.runAs(listUser[0]){
            insert lstPlanAction;
            Test.startTest();
            lstPlanAction[1].SVR_ResponsableSecteur__c = listUser[1].Id;
            update lstPlanAction;
            Test.stopTest();
        }
    }
    @isTest
    public static void afterDeleteTest(){
        System.runAs(listUser[0]){
            insert lstPlanAction;
            Test.startTest();
            delete lstPlanAction;
            Test.stopTest();
        }
    }

}