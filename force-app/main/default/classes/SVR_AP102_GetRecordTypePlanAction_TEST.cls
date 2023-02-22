/**
 * @description       : This class will test the decision of Plan d'action recordtype based on a audit reseau/operationnel recordtype
 * @author            : JPI
 * @group             : 
 * @last modified on  : 26/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01/12/2020   JPI   Initial Version
**/
@isTest
public with sharing class SVR_AP102_GetRecordTypePlanAction_TEST {
    
    static List<User> listUsers;
    static List<Account> listAccount;
    static List<SVR_AuditReseau__c> listAuditRS;
    static List<SVR_AuditOperationnel__c> listAuditOP;
    static List<Audit_Plan_Action__c> listPlanAction;

    static {

        listUsers = new List<User>();
        listAccount = new List<Account>();
        listAuditRS = new List<SVR_AuditReseau__c>();
        listAuditOP = new List<SVR_AuditOperationnel__c>();
        listPlanAction = new List<Audit_Plan_Action__c>();

        listUsers.add(SVR_TestFactory.createUser('ScUserTest'));
        insert listUsers;


        System.runAs(listUsers[0]){

            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 1', 'Réseau Platinium'));
            listAccount.add(SVR_TestFactory.createPrefikarBodyAccount('Test 2', 'Réseau Platinium'));
            insert listAccount;

            listAuditRS.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[0]));
            listAuditRS.add(SVR_TestFactory.createAuditRS(listUsers[0], listAccount[1]));
            listAuditRS[0].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyenChild).getRecordTypeId();
            listAuditRS[1].recordTypeId = Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId();
            insert listAuditRS;

            
            listAuditOP.add(SVR_TestFactory.createAuditOP(listUsers[0], listAccount[0]));
            listAuditOP.add(SVR_TestFactory.createAuditOP(listUsers[0], listAccount[0]));
            listAuditOP.add(SVR_TestFactory.createAuditOP(listUsers[0], listAccount[1]));
            listAuditOP.add(SVR_TestFactory.createAuditOP(listUsers[0], listAccount[1]));
            listAuditOP.add(SVR_TestFactory.createAuditOP(listUsers[0], listAccount[1]));
            listAuditOP[0].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId();
            listAuditOP[1].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactu).getRecordTypeId();
            listAuditOP[2].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPGrosChoc).getRecordTypeId();
            listAuditOP[3].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPAppels).getRecordTypeId();
            listAuditOP[4].recordTypeId = Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPQualite).getRecordTypeId();
            insert listAuditOP;
            
        }

    }

    @isTest
    public static void getPlanActionRecordTypeRS_Test(){
        System.runAs(listUsers[0]){
            Test.startTest();
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeIdRS( (String) listAuditRS[0].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeNameRS( (String) listAuditRS[0].Id);

            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeIdRS( (String) listAuditRS[1].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeNameRS( (String) listAuditRS[1].Id);
            
            Id id = SVR_AP102_GetRecordTypePlanAction.retrieveResponsableSecteur(listAuditRS[0].Id);
            
            Test.stopTest();
        }
    }

    @isTest
    public static void getPlanActionRecordTypeOP_Test(){
        System.runAs(listUsers[0]){
            Test.startTest();
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeIdOP( (String) listAuditOP[0].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeIdOP( (String) listAuditOP[1].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeIdOP( (String) listAuditOP[2].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeIdOP( (String) listAuditOP[3].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeIdOP( (String) listAuditOP[4].Id);

            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeNameOP( (String) listAuditOP[0].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeNameOP( (String) listAuditOP[1].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeNameOP( (String) listAuditOP[2].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeNameOP( (String) listAuditOP[3].Id);
            SVR_AP102_GetRecordTypePlanAction.getPlanActionRecordTypeNameOP( (String) listAuditOP[4].Id);
            
            Id id = SVR_AP102_GetRecordTypePlanAction.retrieveNomDuGestionnaire(listAuditOP[0].Id);
            
            Test.stopTest();
        }
    }
}