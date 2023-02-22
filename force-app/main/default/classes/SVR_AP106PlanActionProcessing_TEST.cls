@isTest
public class SVR_AP106PlanActionProcessing_TEST {
    /*************************************************************************************
Class Name - SVR_AP106PlanActionProcessing
Version - 1.0
Created Date - 10 June 2021
Function - class to initalise Plan actin

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Ruksaar L        15/10/2020  RSIW-9913: Original Version

*************************************************************************************/

    static List<User> listUsers;
    static List<Account> listAccount;
    static List<SVR_AuditReseau__c> listAuditRS;
    static List<Audit_Plan_Action__c> listPlanAction;
    static List<SVR_Performance__c> listPerformance;
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
        listUsers[0].NOB_isPrefikar__c = true;
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
            listAuditRS[0].SVR_ResponsableSecteur__c = listUsers[0].Id;
            listAuditRS[0].SVR_NomAuditeur__c = listUsers[0].Id;
            listAuditRS[0].SVR_RepairerUser__c = listUsers[0].Id;
            
            
            insert listAuditRS;

            listPerformance = new List<SVR_Performance__c>{
                TestFactory.createPerformance(listAccount[0],listUsers[0]),
                TestFactory.createPerformance(listAccount[1],listUsers[0])
            };
            listPerformance[0].recordTypeId = Schema.SObjectType.SVR_Performance__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePerfReseauCM).getRecordTypeId() ;
            listPerformance[0].SVR_Periode__c = '3MG';
            listPerformance[1].recordTypeId = Schema.SObjectType.SVR_Performance__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePerfReseauCM).getRecordTypeId() ;
            listPerformance[1].SVR_Periode__c = '3MG';
            insert listPerformance;


            //SVR_PlanActionOperationel
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[0],'Action expert', 'A faire', 'Mise sous tutelle', 'Non-réalisé', 'Utilisation de l\'outil de chiffrage', 'Non-réalisé'));
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[0], 'Mise sous tutelle', 'A faire', 'Action expert', 'Non-réalisé', 'Utilisation d’ASF', 'Non-réalisé'));
            listPlanAction.add(SVR_TestFactory.createPlanActionRSCM(listAuditRS[0],'Action expert', 'A faire', 'Utilisation de l\'outil de chiffrage', 'Non-réalisé', 'Formation des équipes', 'Non-réalisé'));
            listPlanAction[0].SVR_DateDuProchainPoint__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day() + 2);
            listPlanAction[0].SVR_NomGestionnaire__c = listUsers[0].Id;
            listPlanAction[0].SVR_ResponsableSecteur__c = listUsers[0].Id;
            
            listPlanAction[1].SVR_DateDuProchainPoint__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day() + 2);
            listPlanAction[1].SVR_NomGestionnaire__c = listUsers[0].Id;
            listPlanAction[1].SVR_ResponsableSecteur__c = listUsers[0].Id;
            
            listPlanAction[2].SVR_DateDuProchainPoint__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day() + 2);
            listPlanAction[2].SVR_NomGestionnaire__c = listUsers[0].Id;
            listPlanAction[2].SVR_ResponsableSecteur__c = listUsers[0].Id;
             
                
            
        }
    }

    @isTest
    public static void onAfterInsertTest(){
        System.runAs(listUsers[0]){
            Test.startTest();
            insert listPlanAction;
            Test.stopTest();
            
        }
    }

    @isTest
    public static void onAfterUpdateTest(){

        System.runAs(listUsers[0]){
            
            Test.startTest();
            insert listPlanAction;

            listPlanAction[1].SVR_NomGestionnaire__c = listUsers[0].Id;
            update listPlanAction;
            Test.stopTest();
            
        }
    }


}