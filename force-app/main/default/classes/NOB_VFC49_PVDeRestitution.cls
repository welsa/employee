/**
 * @description       : 
 * @author            : KPA
 * @group             : 
 * @last modified on  : 08-20-2020
 * @last modified by  : KPA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   08-18-2020   KPA   Initial Version
 * 1.1   10-28-2020   HMO   Replacing static values from NOB_AP00_Constants 
**/
public without sharing class NOB_VFC49_PVDeRestitution {
    public ApexPages.StandardController controller {get;set;}
    public WorkOrder wo {get;set;}
    public String dateRetour {get;set;}
    public String timeRetour {get;set;}
    public NOB_VFC49_PVDeRestitution(ApexPages.StandardController controller) {
        Id workOrderId = controller.getId();
        wo = [SELECT Id,
                NOB_TECH_InsuredName__c,
                NOB_TECH_InsuredPhone__c,
                Account.Name,
                NOB_TECH_ContactPickupFirstName__c,
                NOB_TECH_ContactPickupLastName__c,
                NOB_TECH_ContactPickupPhone__c,
                NOB_TECH_ContactPickupEmail__c,
                NOB_TECH_VehicleRegistrationNumber__c,
                toLabel(NOB_VehicleBrand__c),
                NOB_VehicleModel__c,
                NOB_VehiculeReturnDate__c,
                NOB_TECH_ReparateurPhone__c,
                NOB_TECH_ReparateurEmailAddress__c
        FROM workOrder WHERE Id = :workOrderId];

        if(wo.NOB_VehiculeReturnDate__c != null){
            Datetime retour = wo.NOB_VehiculeReturnDate__c;
            dateRetour = retour.format(NOB_AP00_Constants.WORKORDER_VEHICULERETURNDATE_FORMAT_DATE);
            timeRetour = retour.format(NOB_AP00_Constants.WORKORDER_VEHICULERETURNDATE_FORMAT_TIME);
        }
    }
}