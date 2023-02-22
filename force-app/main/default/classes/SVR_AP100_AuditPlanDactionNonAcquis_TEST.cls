/**
 * @description       : This class will test the insertion of audit operationnel to build a history of plan d'action, if other audit openrationnel of the same RT has plan d'action with status 'Non Acquis'
 * @author            : JPI
 * @group             : 
 * @last modified on  : 19/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01/12/2020   JPI   Initial Version
**/
@isTest
public with sharing class SVR_AP100_AuditPlanDactionNonAcquis_TEST {
    
    static List<User> listUsers;
    static List<Account> listAccount;
    static List<SVR_AuditOperationnel__c> listAuditOP;
    static List<Audit_Plan_Action__c> listPlanAction;

    static {

        listUsers = new List<User>();
        listAccount = new List<Account>();
        listAuditOP = new List<SVR_AuditOperationnel__c>();
        listPlanAction = new List<Audit_Plan_Action__c>();

        listUsers.add(SVR_TestFactory.createUser('ScUserTest'));
        insert listUsers;


        System.runAs(listUsers[0]){

            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Platinium'));
            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Platinium'));
            insert listAccount;

            listAuditOP.add(SVR_TestFactory.createAuditOP(listUsers[0], listAccount[0]));
            listAuditOP.add(SVR_TestFactory.createAuditOP(listUsers[0], listAccount[0]));
            listAuditOP[0].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId();
            listAuditOP[0].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId();
            insert listAuditOP;

            //SVR_PlanActionOperationel
            listPlanAction.add(SVR_TestFactory.createPlanActionOP(listAuditOP[0], 'Non acquis', 'Non acquis', 'Non acquis'));
            listPlanAction.add(SVR_TestFactory.createPlanActionOP(listAuditOP[0], 'Non acquis', 'Acquis', 'Non acquis'));
            listPlanAction.add(SVR_TestFactory.createPlanActionOP(listAuditOP[1], 'Non acquis', 'Non acquis', 'Non acquis'));
            listPlanAction[0].SVR_AxesAmeliorationAdditionnels__c ='Test Rich text';																						
            insert listPlanAction;
        }
    }

    @isTest
    public static void insertPlanActionTest(){

        System.runAs(listUsers[0]){
            Test.startTest();
            SVR_AuditOperationnel__c newAudit = SVR_TestFactory.createAuditOP(listUsers[0], listAccount[1]);
            newAudit.recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId();
            insert newAudit;
            Test.stopTest();
        }
    }
}