/**
 * @description       : This class will test the creation of 'Nouveau Point d'etape'
 * @author            : JPI
 * @group             : 
 * @last modified on  : 08/02/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01/12/2020   JPI   Initial Version
**/
@isTest
public with sharing class SVR_AP102_NouveauPointEtapes_TEST {
    
    static List<User> listUsers;
    static List<Account> listAccount;
    static List<SVR_AuditReseau__c> listAuditRS;
    static List<Audit_Plan_Action__c> listPlanAction;
    static List<NOB_AccountRelationship__c> listAccountRelationship;
    static list<Account> lstAssureur;
    static list<NOB_TauxNeg__c> lstTauxNeg;

    
    static {

        listUsers = new List<User>();
        listAccount = new List<Account>();
        listAuditRS = new List<SVR_AuditReseau__c>();
        listPlanAction = new List<Audit_Plan_Action__c>();
        listAccountRelationship = new List<NOB_AccountRelationship__c>();


        listUsers.add(SVR_TestFactory.createUser('ScUserTest'));
        insert listUsers;


        System.runAs(listUsers[0]){

            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Platinium'));
            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Platinium'));
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
            

            listAuditRS.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            listAuditRS.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            listAuditRS.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            listAuditRS.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[1]));
            listAuditRS[0].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId();
            listAuditRS[1].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId();
            listAuditRS[2].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId();
            listAuditRS[3].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId();
            
            listAuditRS[0].SVR_RepairerUser__c= listUsers[0].id;
            listAuditRS[1].SVR_RepairerUser__c=listUsers[0].id;
            listAuditRS[2].SVR_RepairerUser__c=listUsers[0].id;
            listAuditRS[3].SVR_RepairerUser__c= listUsers[0].id;
            
        }
    }


    @isTest
    public static void getCloneAuditParentTest(){
        System.runAs(listUsers[0]){
            Test.startTest();
            insert listAuditRS; 
            SVR_AP102_NouveauPointEtapes.AuditListWrapper test1 = SVR_AP102_NouveauPointEtapes.cloneAuditParent( (String) listAuditRS[0].Id, 'NOTTEST');
            SVR_AP102_NouveauPointEtapes.AuditListWrapper test2 = SVR_AP102_NouveauPointEtapes.cloneAuditParent( (String) listAuditRS[3].Id, 'NOTTEST');
            System.assertEquals('NoPA', test1.errorType);
            System.assertEquals('NoPA', test2.errorType);
            Test.stopTest();
        }
    }

    @isTest
    public static void getCloneAuditParentWithPATest(){
        System.runAs(listUsers[0]){
            Test.startTest();
            insert listAuditRS;

            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[0], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire')); 
            listPlanAction[0].SVR_DateDuProchainPoint__c = System.today()+1;
            
            System.debug('Shane listPlanAction ' + listPlanAction);

            insert listPlanAction;

            SVR_AP102_NouveauPointEtapes.AuditListWrapper test1 = SVR_AP102_NouveauPointEtapes.cloneAuditParent( (String) listAuditRS[0].Id, 'NOTTEST');
            System.assertEquals('NONE', test1.errorType);
            Test.stopTest();
        }
    }

    @isTest
    public static void getCloneAuditParentWithPENoPATest(){
        System.runAs(listUsers[0]){
            Test.startTest();
            
            insert listAuditRS; 
            listAuditRS[1].SVR_StatutReseau__c='Point d\'étape en cours';
            listAuditRS[2].SVR_AuditReseauParent__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_StatutReseau__c='Audit Cloturé';
            listAuditRS[3].SVR_AuditReseauParent__c = listAuditRS[2].Id;
            listAuditRS[3].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            update listAuditRS; 

            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[1], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[0].SVR_DateDuProchainPoint__c = System.today()+1;
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[2], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[1].SVR_DateDuProchainPoint__c = System.today()+1;
            insert listPlanAction;

            SVR_AP102_NouveauPointEtapes.AuditListWrapper test1 = SVR_AP102_NouveauPointEtapes.cloneAuditParent( (String) listAuditRS[3].Id, 'NOTTEST');
            System.assertEquals('NoPA', test1.errorType);
            Test.stopTest();
        }
    }

    @isTest
    public static void getCloneAuditParentWithPETest(){
        System.runAs(listUsers[0]){
            Test.startTest();
            
            insert listAuditRS; 
            listAuditRS[1].SVR_StatutReseau__c='Point d\'étape en cours';
            listAuditRS[1].SVR_TECH_ContientPointEtape__c = true;
            listAuditRS[2].SVR_AuditReseauParent__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_StatutReseau__c='Audit Cloturé';
            listAuditRS[2].SVR_TECH_ContientPointEtape__c = true;
            listAuditRS[3].SVR_AuditReseauParent__c = listAuditRS[2].Id;
            listAuditRS[3].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            update listAuditRS; 

            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[1], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[0].SVR_DateDuProchainPoint__c = System.today()+1;
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[2], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[1].SVR_DateDuProchainPoint__c = System.today()+1;
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[3], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[2].SVR_DateDuProchainPoint__c = System.today()+1;
            insert listPlanAction;

            SVR_AP102_NouveauPointEtapes.AuditListWrapper test1 = SVR_AP102_NouveauPointEtapes.cloneAuditParent( (String) listAuditRS[3].Id, 'NOTTEST');
            System.assertEquals('NONE', test1.errorType);
            Test.stopTest();
        }
    }

    @isTest
    public static void getCloneAuditParentWithPEClotureTest(){
        System.runAs(listUsers[0]){
            Test.startTest();
            
            insert listAuditRS;

            listAuditRS[1].SVR_StatutReseau__c='Point d\'étape en cours';
            listAuditRS[1].SVR_TECH_ContientPointEtape__c = true;
            listAuditRS[2].SVR_AuditReseauParent__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_StatutReseau__c='Audit Cloturé';
            listAuditRS[2].SVR_TECH_ContientPointEtape__c = true;
            listAuditRS[3].SVR_AuditReseauParent__c = listAuditRS[2].Id;
            listAuditRS[3].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            listAuditRS[3].SVR_StatutReseau__c='Audit Cloturé';
            listAuditRS[3].SVR_TECH_ContientPointEtape__c = true;
            update listAuditRS; 

            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[1], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[0].SVR_DateDuProchainPoint__c = System.today()+1;
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[2], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[1].SVR_DateDuProchainPoint__c = System.today()+1;
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[3], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction[2].SVR_DateDuProchainPoint__c = System.today()+1;
            insert listPlanAction;

            SVR_AP102_NouveauPointEtapes.AuditListWrapper test1 = SVR_AP102_NouveauPointEtapes.cloneAuditParent( (String) listAuditRS[3].Id, 'NOTTEST');
            System.assertEquals('Closed', test1.errorType);
            Test.stopTest();
        }
    }
}