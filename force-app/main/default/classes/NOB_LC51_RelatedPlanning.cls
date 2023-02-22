/**
 * @description       : RSIW-1670
 * @author            : GBH
 * @group             : 
 * @last modified on  : 10-29-2020
 * @last modified by  : GBH
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   10-29-2020   GBH   Initial Version
 * 1.1   21-12-2020   USA   RSIW-6769
**/
public without sharing class NOB_LC51_RelatedPlanning {
    @AuraEnabled
    public static List <NOB_Planning__c> getPlannings(String AccountId, String Status, String recordType) {
        //Get all disponibilité
        List<NOB_Planning__c> lstPlannings = [SELECT Id, 
                                                Name, 
                                                NOB_StartDate__c, 
                                                NOB_EndDate__c, 
                                                NOB_Status__c,
                                                NOB_WorkOrder__c,
                                                NOB_WorkOrder__r.WorkOrderNumber,
                                                OwnerId,
                                                Owner.Name,
                                                recordTypeId
                                            FROM NOB_Planning__c
                                            WHERE RecordType.Name = :recordType AND NOB_Status__c = :Status AND NOB_BodyShop__c = :AccountId
                                            AND IsDelete__c = FALSE];
        //return list of plannings
        System.debug('### lstPlannings ###'+lstPlannings);
        return lstPlannings;
    }

    @AuraEnabled
    public static Id getRecordTypeId(String recordType) {
        return Schema.SObjectType.Nob_Planning__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
    }
    
    @AuraEnabled
    public static Boolean checkProfileRights() {
        Boolean showButton = false;

        String profiles = Label.NOB_PlanningCreationProfiles;
        
        Id profileId= userinfo.getProfileId();
        String profileName= [Select Id,Name from Profile where Id=:profileId].Name;
        
        if (profiles.contains(profileName)) { showButton = true; }
        return showButton;
    }
}