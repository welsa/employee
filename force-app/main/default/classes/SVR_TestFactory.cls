/**
 * @description       : Class which has all the method to create objects in test classes
 * @author            : JPI
 * @group             : 
 * @last modified on  : 05/02/2021
 * @last modified by  : JPI
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01/12/2020   JPI   Initial Version
**/
public class SVR_TestFactory {
    

    // Create user
    public static User createUser(String name){
        return new User(
            Username = TestFactory.randomizeString(Name) +'@test.com',
            LastName = 'Ballack',
            FirstName = 'Jean',
            Email = 'jean@test.com',
            Alias = 'JBAL',
            CountryCode = 'FR',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = ASPISConstants.getProfileAdminId()
        );
    }

    // Create account bodyshop
    public static Account createPrefikarBodyAccount(String name, String typeReseau){
        return new Account(
                Name = name,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BODYSHOP').getRecordTypeId(),
                ShippingCountry = 'France',
                ShippingCity = 'Paris',
                ShippingStreet = '5 RUE EMILE LEPEU',
                ShippingPostalCode = '75011',
                NOB_NetworkType__c = typeReseau,
                BillingCountryCode = 'FR',
                NOB_isPrefikar__c = true,
                NOB_Statut__c = 'Actif'
        );
    }

    // Create audit reseau
    public static SVR_AuditReseau__c createAuditRS(User u1, Account acc){
        return new SVR_AuditReseau__c(
            SVR_Collaborator__c = u1.Id,
            SVR_Bodyshop__c = acc.Id,
            SVR_ResponsableSecteur__c = u1.id,
            SVR_RepairerUser__c=u1.Id
        );
    }

    // Create audit operationnel
    public static SVR_AuditOperationnel__c createAuditOP(User u1, Account acc){
        return new SVR_AuditOperationnel__c(
            SVR_Collaborator__c = u1.Id,
            SVR_Bodyshop__c = acc.Id
        );
    }

    public static Audit_Plan_Action__c createPlanActionOP(SVR_AuditOperationnel__c auditOP, String amel1, String amel2, String amel3){
        return new Audit_Plan_Action__c(
            SVR_AuditOperationnel__c =  auditOP.Id,
            SVR_StatutAmelioration1__c = amel1,
            SVR_StatutAmelioration2__c = amel2,
            SVR_StatutAmelioration3__c = amel3,
            RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAOperationnelBOFactu).getRecordTypeId()
        );
    }

    public static Audit_Plan_Action__c createPlanActionRSCM(SVR_AuditReseau__c auditRS, String ai1, String statut1, String ai2, String statut2, String ai3, String statut3){
        return new Audit_Plan_Action__c(
            SVR_AuditReseau__c =  auditRS.Id,
            SVR_ActionIdentifie1__c = ai1,
            SVR_CMStatut1__c = statut1,
            SVR_ActionIdentifie2__c = ai2,
            SVR_CMStatut2__c = statut2,
            SVR_ActionIdentifie3__c = ai3,
            SVR_CMStatut3__c = statut3,
            SVR_DateDuProchainPoint__c = System.today().addDays(7),
            RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAReseauCM).getRecordTypeId()
        );
    }

    public static Audit_Plan_Action__c createPlanActionRSQuality(SVR_AuditReseau__c auditRS, String ai1, String statut1, String ai2, String statut2, String ai3, String statut3){
        return new Audit_Plan_Action__c(
            SVR_AuditReseau__c =  auditRS.Id,
            SVR_ActionIdentifie1__c = ai1,
            SVR_CMStatut1__c = statut1,
            SVR_ActionIdentifie2__c = ai2,
            SVR_CMStatut2__c = statut2,
            SVR_ActionIdentifie3__c = ai3,
            SVR_CMStatut3__c = statut3,
            SVR_DateDuProchainPoint__c = System.today().addDays(7),
            RecordTypeId = Schema.SObjectType.Audit_Plan_Action__c.getRecordTypeInfosByDeveloperName().get(SVR_AP100_Constant.recordTypePAReseauQualite).getRecordTypeId()
        );
    }

    public static SVR_Dossier__c createDossier(String name){
        return new SVR_Dossier__c(
                Name = name
        );
    }

    public static Contact createContact(String name){
        return new Contact(
                LastName = name
        );
    }
}