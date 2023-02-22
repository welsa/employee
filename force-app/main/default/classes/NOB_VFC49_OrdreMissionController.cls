/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 05-24-2021
 * @last modified by  : DUN
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   08-24-2020   ARA   Initial Version
 * 1.1   05-11-2020   HMO   Removing fields from Case and replace with fields in workOrder
**/
public without sharing class NOB_VFC49_OrdreMissionController {

    public ApexPages.StandardController controller {get;set;}
    public WorkOrder wo { get; set; }
    public NOB_Rent__c rent {get;set;}
    public String dateRendezVous{get;set;}
    public String timeRendezVous{get;set;}

    public NOB_VFC49_OrdreMissionController(ApexPages.StandardController controller) {

        Id workOrderId = controller.getId();
        wo = [SELECT Id,
            CaseId,
            NOB_AssistanceGuarantee__c,
            NOB_TECH_BusinessProvider__c,
            NOB_TECH_InsuredMobile__c,
            NOB_TECH_ContactOtherPhone__c,
            NOB_TECH_InsuredPhone__c,
            NOB_TECH_ContactFax__c,
            NOB_InsuredStreet__c,
            NOB_InsuredCity__c,
            NOB_InsuredZipCode__c,
            NOB_TECH_ContactPickUpMailingState__c,
            NOB_TECH_ContactPickup_MailingCountry__c,
            //Case.NOB_Pricebook__r.NOB_PriceBook__r.NOB_Offer__c,
            NOB_TECH_PriceBook_PriceBookOffre__c,
            NOB_ModelReleasedYear__c,
            NOB_Franchise__c,
            NOB_Variable__c,
            NOB_VariableMax__c,
            NOB_VariableMin__c,
            NOB_Mileage__c,
            NOB_NatureOfTheEvent__c,
            toLabel(NOB_Color__c),
            NOB_TECH_InsurerClaimNumber__c,
            NOB_IncidentDateandTime__c ,
            NOB_TECH_InsuredName__c,
            toLabel(NOB_VehicleBrand__c),
            NOB_VehicleModel__c,
            NOB_TECH_VehicleRegistrationNumber__c,
            NOB_TECH_DamageDetails__c,
            NOB_DamageType__c,
            NOB_ContexteDeLexpertise__c,
            NOB_TECH_ReparateurName__c,
            NOB_TECH_RunningVehicle__c,
            NOB_TECH_Expert__c,
            NOB_TECH_ExpertTelephone__c,
            NOB_TECH_ReparateurSiret__c,
            NOB_TECH_ReparateurBillingStreet__c,
            NOB_TECH_ReparateurBillingPostalCode__c,
            NOB_TECH_ReparateurBillingCity__c,
            NOB_TECH_ReparateurBillingState__c ,
            NOB_TECH_ReparateurBillingCountry__c,
            NOB_TECH_ReparateurPhone__c,
            NOB_TECH_ReparateurFax__c
        from WorkOrder
        where Id = :workOrderId];

        NOB_Planning__c planning = new NOB_Planning__c();
        List<NOB_Planning__c> lstPlanning = new List<NOB_Planning__c>([Select Id,
                NOB_StartDate__c
        from NOB_Planning__c
        where NOB_WorkOrder__c = :wo.Id
        order by CreatedDate DESC
        Limit 1]);
        if(lstPlanning.size() > 0){
            planning = lstPlanning[0];
            if(lstPlanning[0].NOB_StartDate__c != null){
                Datetime rendezVous = lstPlanning[0].NOB_StartDate__c;
                dateRendezVous = rendezVous.format('dd/MM/yyyy');
                timeRendezVous = rendezVous.format('HH:mm');
            }
        }

        rent = new NOB_Rent__c();
        List<NOB_Rent__c> lstRent = new List<NOB_Rent__c>([
                Select Id,
                        Name
                from NOB_Rent__c
                where NOB_OrdreExecution__c = :wo.Id
                order by NOB_VehiculeRentalDate__c DESC
                Limit 1
        ]);
        if (lstRent.size() > 0) {
            rent = lstRent[0];
        }
    }
}