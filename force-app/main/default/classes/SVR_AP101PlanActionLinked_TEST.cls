/**
 * @description       : This class will test the insertion and deletion of plan d'action to count the number of plan d'action for each audit reseau
 * @author            : JPI
 * @group             : 
 * @last modified on  : 21/04/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01/12/2020   JPI   Initial Version
**/
@isTest
public with sharing class SVR_AP101PlanActionLinked_TEST {

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
            listAuditRS[0].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId();
            insert listAuditRS;

            //SVR_PlanActionOperationel
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[0],'Action expert', 'A faire', 'Mise sous tutelle', 'Non-réalisé', 'Utilisation de l\'outil de chiffrage', 'Non-réalisé'));
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[0], 'Mise sous tutelle', 'A faire', 'Action expert', 'Non-réalisé', 'Utilisation d’ASF', 'Non-réalisé'));
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[0],'Action expert', 'A faire', 'Utilisation de l\'outil de chiffrage', 'Non-réalisé', 'Formation des équipes', 'Non-réalisé'));																					
            listPlanAction.add(SVR_TestFactory.createPlanActionRSQuality(listAuditRS[0],'Connaissance du SD', 'Non-réalisé', 'Connaissance du SD', 'Non-réalisé', 'Connaissance du SD', 'Non-réalisé'));																					
            
        }
    }

    @isTest
    public static void insertNewPlanActionForCountTest(){

        System.runAs(listUsers[0]){
            Test.startTest();
            insert listPlanAction;

            List<SVR_AuditReseau__c> auditReseau  = [SELECT Id, Nb_de_plan_d_action__c FROM SVR_AuditReseau__c WHERE Id =:listAuditRS[0].Id];
            System.assertEquals(4, auditReseau[0].Nb_de_plan_d_action__c);
            Test.stopTest();
        }
    }
}