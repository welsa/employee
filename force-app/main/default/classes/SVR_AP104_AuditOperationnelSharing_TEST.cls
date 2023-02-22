/**
 * @description       : 
 * @author            : JPI
 * @group             : 
 * @last modified on  : 18/02/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   18/02/2021   JPI   Initial Version
**/
@isTest
public with sharing class SVR_AP104_AuditOperationnelSharing_TEST {

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
        listUsers.add(SVR_TestFactory.createUser('NomGestionnaire1'));
        listUsers.add(SVR_TestFactory.createUser('NomGestionnaire2'));
        insert listUsers;


        System.runAs(listUsers[0]){

            listAccount.add(TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Platinium'));
            listAccount.add(TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Platinium'));
            insert listAccount;

            listAuditOP.add(TestFactory.createAuditOP(listUsers[1], listAccount[0]));
            listAuditOP.add(TestFactory.createAuditOP(listUsers[1], listAccount[0]));
            listAuditOP.add(TestFactory.createAuditOP(listUsers[1], listAccount[0]));
            listAuditOP.add(TestFactory.createAuditOP(listUsers[1], listAccount[1]));
            listAuditOP[0].Nom_du_gestionnaire__c = listUsers[1].Id;
            listAuditOP[1].Nom_du_gestionnaire__c = listUsers[1].Id;
            listAuditOP[2].Nom_du_gestionnaire__c = listUsers[1].Id;
            listAuditOP[3].Nom_du_gestionnaire__c = listUsers[1].Id;
            listAuditOP[0].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId();
            listAuditOP[1].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactu).getRecordTypeId();
            listAuditOP[2].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPGrosChoc).getRecordTypeId();
            listAuditOP[3].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPAppels).getRecordTypeId(); 

            
        }
    }

    @isTest
    public static void insertAuditOperationnelTest(){
        System.runAs(listUsers[0]){
            Test.startTest();

            insert listAuditOP; 

            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[0],null, null, null)); 
            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[1],null, null, null));
            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[2],null, null, null));
            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[3],null, null, null));
            insert listPlanAction;
            
            Test.stopTest();
        }
    }

    @isTest
    public static void updateAuditOperationnelTest(){
        System.runAs(listUsers[0]){
            Test.startTest();

            insert listAuditOP; 

            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[0],null, null, null)); 
            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[1],null, null, null));
            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[2],null, null, null));
            listPlanAction.add(TestFactory.createPlanActionOP(listAuditOP[3],null, null, null));
            insert listPlanAction;
            
            listAuditOP[0].Nom_du_gestionnaire__c = listUsers[2].Id;
            listAuditOP[1].Nom_du_gestionnaire__c = listUsers[2].Id;
            listAuditOP[2].Nom_du_gestionnaire__c = listUsers[2].Id;
            listAuditOP[3].Nom_du_gestionnaire__c = listUsers[2].Id;
            update listAuditOP;
            Test.stopTest();
        }
    }
}