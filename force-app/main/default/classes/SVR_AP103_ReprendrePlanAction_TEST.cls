/**
 * @description       : This class will test the cloning of a plan d'action from the most recent audit
 * @author            : JPI
 * @group             : 
 * @last modified on  : 19/03/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01/12/2020   JPI   Initial Version
**/
@isTest
public with sharing class SVR_AP103_ReprendrePlanAction_TEST {
    
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

        //RLA 19/07/2021
        listAccountRelationship = new List<NOB_AccountRelationship__c>();

        listUsers.add(TestFactory.createPrefikarUser('ScUserTest'));
        insert listUsers;


        System.runAs(listUsers[0]){

            listAccount.add(TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Platinium'));
            listAccount.add(TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Platinium'));
            listAccount.add(TestFactory.createPrefikarBodyAccount('AXA RM', 'Réseau Platinium'));
            // listAccount[0].Name = 'AXA RM';
            // listAccount[1].Name = 'AXA RM';
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

            listAuditRS.add(TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            listAuditRS.add(TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            listAuditRS.add(TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            listAuditRS.add(TestFactory.createAuditRS(listUsers[0], listAccount[1]));
            listAuditRS[0].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId();
            listAuditRS[1].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId();
            listAuditRS[2].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyenChild).getRecordTypeId();
            listAuditRS[3].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId(); 

            listPlanAction.add(TestFactory.createPlanActionRSCM(listAuditRS[0], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire')); 
            listPlanAction.add(TestFactory.createPlanActionRSQuality(listAuditRS[1], 'Mise sous tutelle', 'A faire', 'Connaissance du SD', 'A faire', 'Formation utilisation de la substitution', 'A faire'));
            listPlanAction.add(TestFactory.createPlanActionRSCM(listAuditRS[2], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            listPlanAction.add(TestFactory.createPlanActionRSQuality(listAuditRS[3], 'Mise sous tutelle', 'A faire', 'Connaissance du SD', 'A faire', 'Formation utilisation de la substitution', 'A faire'));
            
        }
    }

    @isTest
    public static void reprendrePlanActionNoPATest(){
        System.runAs(listUsers[0]){
            Test.startTest();

            insert listAuditRS; 
            listAuditRS[0].SVR_StatutReseau__c='Point d\'étape en cours';
            listAuditRS[1].SVR_StatutReseau__c='Point d\'étape en cours';
            listAuditRS[2].SVR_AuditReseauParent__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            listAuditRS[2].SVR_StatutReseau__c='Audit Cloturé';
            listAuditRS[3].SVR_AuditReseauParent__c = listAuditRS[0].Id;
            listAuditRS[3].SVR_AuditReseauUltimate__c = listAuditRS[0].Id;
            update listAuditRS; 

            insert listPlanAction;
            SVR_AP103_ReprendrePlanActionPrecedent.PlanActionListWrapper test1 = SVR_AP103_ReprendrePlanActionPrecedent.reprendrePlanAction( (String) listAuditRS[2].Id);
            SVR_AP103_ReprendrePlanActionPrecedent.PlanActionListWrapper test2 = SVR_AP103_ReprendrePlanActionPrecedent.reprendrePlanAction( (String) listAuditRS[3].Id);
            System.assertEquals('NoPA', test1.errorType);
            System.assertEquals('NoPA', test2.errorType);
            Test.stopTest();
        }
    }

    @isTest
    public static void reprendrePlanActionTest(){
        System.runAs(listUsers[0]){
            Test.startTest();

            List<SVR_AuditReseau__c> lstSVR_AuditReseau = new list<SVR_AuditReseau__c>();
            lstSVR_AuditReseau.addAll(listAuditRS);


            SVR_AuditReseau__c auditTest0 = TestFactory.createAuditRS(listUsers[0], listAccount[0]);
            auditTest0.SVR_AuditReseauParent__c = listAuditRS[2].Id;
            auditTest0.SVR_AuditReseauUltimate__c = listAuditRS[0].Id;
            auditTest0.recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyenChild).getRecordTypeId();
            lstSVR_AuditReseau.add(auditTest0);

            
            SVR_AuditReseau__c auditTest1 = TestFactory.createAuditRS(listUsers[0], listAccount[0]);
            auditTest1.SVR_AuditReseauParent__c = listAuditRS[3].Id;
            auditTest1.SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            auditTest1.recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId();
            lstSVR_AuditReseau.add(auditTest1);


           insert lstSVR_AuditReseau; 
            
            // CM
            listAuditRS[0].SVR_StatutReseau__c='Point d\'étape en cours';
            listAuditRS[2].SVR_AuditReseauParent__c = listAuditRS[0].Id;
            listAuditRS[2].SVR_AuditReseauUltimate__c = listAuditRS[0].Id;
            listAuditRS[2].SVR_StatutReseau__c='Audit Cloturé';

            // Quality
            listAuditRS[1].SVR_StatutReseau__c='Point d\'étape en cours';
            listAuditRS[3].SVR_AuditReseauParent__c = listAuditRS[1].Id;
            listAuditRS[3].SVR_AuditReseauUltimate__c = listAuditRS[1].Id;
            listAuditRS[3].SVR_StatutReseau__c='Audit Cloturé';
            update listAuditRS; 


            listPlanAction.add(TestFactory.createPlanActionRS(listAuditRS[0], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire'));
            listPlanAction.add(TestFactory.createPlanActionRS(listAuditRS[1], 'Mise sous tutelle', 'Non acquis', 'Connaissance du SD', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis'));
            listPlanAction.add(TestFactory.createPlanActionRS(listAuditRS[2], 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire', 'Action expert', 'A faire'));
            listPlanAction.add(TestFactory.createPlanActionRS(listAuditRS[3], 'Mise sous tutelle', 'Non acquis', 'Connaissance du SD', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis', 'Formation utilisation de la substitution', 'Non acquis'));
            // listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(auditTest1, 'Mise sous tutelle', 'A faire', 'Utilisation de l\'outil de chiffrage', 'A faire', 'Action expert', 'A faire'));
            // listPlanAction.add(SVR_TestFactory.createPlanActionRSQuality(auditTest0, 'Mise sous tutelle', 'A faire', 'Connaissance du SD', 'A faire', 'Formation utilisation de la substitution', 'A faire'));
            insert listPlanAction;

            SVR_AP103_ReprendrePlanActionPrecedent.PlanActionListWrapper test1 = SVR_AP103_ReprendrePlanActionPrecedent.reprendrePlanAction( (String) auditTest0.Id);
            SVR_AP103_ReprendrePlanActionPrecedent.PlanActionListWrapper test2 = SVR_AP103_ReprendrePlanActionPrecedent.reprendrePlanAction( (String) auditTest1.Id);
            System.assertEquals('NONE', test1.errorType);
            System.assertEquals('NONE', test2.errorType);
            Test.stopTest();
        }
    }
}