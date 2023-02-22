/**
 * @description       : This class will check the recordtype of a audit if the audit is 'Audit Reseau Cout Moyen' the id of the recordtype 'Plan d'action Cout Moyen' will be returned
 * @author            : JPI
 * @group             : 
 * @last modified on  : 22/01/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   12/01/2021   JPI   Initial Version
**/
public with sharing class SVR_AP102_GetRecordTypePlanAction {
    public static List<SVR_AuditReseau__c> listAuditRS = new List<SVR_AuditReseau__c>();
    public static List<SVR_AuditOperationnel__c> listAuditOP = new List<SVR_AuditOperationnel__c>();

    @AuraEnabled
    public static String getPlanActionRecordTypeIdRS(String Id) {

        listAuditRS = [SELECT id, recordTypeId
                    FROM SVR_AuditReseau__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId() 
        || listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyenChild).getRecordTypeId()){
            return Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAReseauCM).getRecordTypeId();
        }else  if(listAuditRS[0].recordTypeId== Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId()
        || listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId()){
            return Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAReseauQualite).getRecordTypeId();
        }

        return null;
    }

    @AuraEnabled
    public static String getPlanActionRecordTypeNameRS(String Id) {

        listAuditRS = [SELECT id, recordTypeId
                    FROM SVR_AuditReseau__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyen).getRecordTypeId() 
        || listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauCoutMoyenChild).getRecordTypeId()){
            return 'CM';
        }else  if(listAuditRS[0].recordTypeId== Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualite).getRecordTypeId()
        || listAuditRS[0].recordTypeId == Schema.SObjectType.SVR_AuditReseau__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditReseauQualiteChild).getRecordTypeId()){
            return 'Qualite';
        }

        return null;
    }

    @AuraEnabled
    public static String getPlanActionRecordTypeIdOP(String Id) {

        listAuditOP = [SELECT id, recordTypeId
                    FROM SVR_AuditOperationnel__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditOP[0].recordTypeId == Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId() ){
            return Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAOperationnelBOAdmin).getRecordTypeId();
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactu).getRecordTypeId()){
            return Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAOperationnelBOFactu).getRecordTypeId();
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPGrosChoc).getRecordTypeId()){
            return Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAOperationnelBOGrosChoc).getRecordTypeId();
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPAppels).getRecordTypeId()){
            return Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAOperationnelBOAppel).getRecordTypeId();
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPQualite).getRecordTypeId()){
            return Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAOperationnelBOQualite).getRecordTypeId();
        }

        return null;
    }

    @AuraEnabled
    public static String getPlanActionRecordTypeNameOP(String Id) {

        listAuditOP = [SELECT id, recordTypeId
                    FROM SVR_AuditOperationnel__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditOP[0].recordTypeId == Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactuAdmin).getRecordTypeId() ){
            return 'Admin';
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPBOFactu).getRecordTypeId()){
            return 'Factu';
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPGrosChoc).getRecordTypeId()){
            return 'GrosChoc';
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPAppels).getRecordTypeId()){
            return 'Appel';
        }else  if(listAuditOP[0].recordTypeId== Schema.SObjectType.SVR_AuditOperationnel__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypeAuditOPQualite).getRecordTypeId()){
            return 'Qualite';
        }

        return null;
    }

    @AuraEnabled
    public static String retrieveNomDuGestionnaire(String Id) {

        listAuditOP = [SELECT id, recordTypeId, Nom_du_gestionnaire__c 
                    FROM SVR_AuditOperationnel__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditOP.size()==1)
            return listAuditOP[0].Nom_du_gestionnaire__c;

        return null;
    }

    @AuraEnabled
    public static String retrieveResponsableSecteur(String Id) {

        listAuditRS = [SELECT id, recordTypeId, SVR_ResponsableSecteur__c 
                    FROM SVR_AuditReseau__c 
                    WHERE id=:Id LIMIT 1];

        if(listAuditRS.size()==1)
            return listAuditRS[0].SVR_ResponsableSecteur__c;

        return null;
    }
}