@isTest
public with sharing class mcr_UnitTestDataDefaults {

    public static Map<Schema.SObjectField, Object> getDefaultValues(Schema.SObjectType sobjType) {
        return objectDefaultsMap.get(sobjType);
    }

    private static Map<Schema.SObjectField, Object> accountDefaults = new Map<Schema.SObjectField, Object>{
        Account.RecordTypeId => Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('MCR_Customer').getRecordTypeId()
    };

    private static Map<Schema.SObjectField, Object> contactDefaults = new Map<Schema.SObjectField, Object>{
        Contact.RecordTypeId => Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MCR_Contact').getRecordTypeId()
    };

    private static Map<Schema.SObjectField, Object> powerBiDefaults = new Map<Schema.SObjectField, Object> {
        MCR_PowerBiItem__c.MCR_TECH_ExternalId__c => 'ItemExternalId',
        MCR_PowerBiItem__c.MCR_TECH_ExternalWorkspaceId__c => 'ExternalWorkspaceId',
        MCR_PowerBiItem__c.MCR_TECH_ExternalType__c => 'Report',
        MCR_PowerBiItem__c.Name => 'Dashboard 1'
    };

    private static Map<Schema.SObjectField, Object> powerBiAccessDefaults = new Map<Schema.SObjectField, Object> {
        MCR_PowerBiAccess__c.MCR_IsDefault__c => true,
       // MCR_PowerBiAccess__c.MCR_DefaultReportPage__c => 'DefaultPage',
        MCR_PowerBiAccess__c.MCR_IsFilterPaneExpanded__c => true,
        MCR_PowerBiAccess__c.MCR_IsFilterPaneVisible__c => true,
        MCR_PowerBiAccess__c.MCR_IsPageNavigationVisible__c => true
    };

    private static Map<Schema.SObjectField, Object> userDefaults = new Map<Schema.SObjectField, Object> {
        User.EmailEncodingKey => 'ISO-8859-1',
        User.LanguageLocaleKey => 'en_US',
        User.LocaleSidKey => 'fr_FR_EURO',
        User.TimeZoneSidKey => 'Europe/Paris'
    };

    private static Map<Schema.SObjectType, Map<Schema.SObjectField, Object>> objectDefaultsMap = new Map<Schema.SObjectType, Map<Schema.SObjectField, Object>>{       
        Account.SObjectType => accountDefaults,
        Contact.SObjectType => contactDefaults,  
        MCR_PowerBiItem__c.SObjectType => powerBiDefaults,
        MCR_PowerBiAccess__c.SObjectType => powerBiAccessDefaults,
        User.SObjectType => userDefaults
    };

}