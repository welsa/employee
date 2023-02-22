/*
  ----------------------------------------------------------------------
  -- - Name          : NOB_VFC49_Contrat 
  -- - Author        : BBH
  -- - Description   : Controller NOB_VFP49_Contrat 
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 14-AUG-2020    BBH     1.0     Initial version
  -- 24-JUN-2021    HMO     1.1     RSIW - 2321
  **********************************************************************
*/
public without sharing class NOB_VFC49_Contrat {

    public ApexPages.StandardController controller {get;set;}
    public WorkOrder wo { get; set; }
    public NOB_Rent__c rent {get;set;}
    public String dateRendezVous{get;set;}
    public String timeRendezVous{get;set;}
    public String dateRentalVR{get;set;}
    public String timeRentalVR{get;set;}
    

    public NOB_VFC49_Contrat(ApexPages.StandardController controller) {
        Id workOrderId = controller.getId();
        wo = [Select Id,
                NOB_Franchise__c,
                NOB_Variable__c,
                NOB_VariableMax__c,
                NOB_VariableMin__c,


                //HMO -- rsiw 2321
                NOB_TECH_BusinessProviderFrancDommage__c,
                NOB_TECH_BusinessProviderFranchiseBriseG__c,
                NOB_TECH_BusinessProviderFranchiseCasVol__c,
                NOB_TECH_BusinessProviderMontantCaution__c,

                //HMO -- rsiw 9765
                NOB_TECH_ReparateurEmailAddress__c,

                //HMO -- rsiw 8853
                NOB_RefContratVR__c,
                NOB_RefcontratSAD__c,
                NOB_TECH_ReparateurBillingCity__c,
                NOB_TECH_ReparateurBillingPostalCode__c,
                NOB_TECH_ReparateurBillingStreet__c,
                NOB_TECH_ReparateurFax__c,
                NOB_TECH_ReparateurName__c,
                NOB_TECH_ReparateurPhone__c,
                NOB_TECH_InsurerClaimNumber__c,
                NOB_TECH_ContractRefVR__c,
                NOB_TECH_ContractRefSAD__c,
                NOB_TECH_ContactPickupFirstName__c,
                NOB_TECH_ContactPickupLastName__c,
                NOB_TECH_ContactPickupPhone__c,
                NOB_TECH_ContactPickupEmail__c,
                NOB_InsuredStreet__c,
                NOB_InsuredCity__c,
                NOB_InsuredZipCode__c,
                NOB_TECH_ContactPickupMobilePhone__c,
                NOB_TECH_ContactPickup_OtherPhone__c,
                NOB_EuropeanPassport__c,
                NOB_InsurerClaimNumber__c,
                NOB_VehicleRegistrationNumber__c,
                toLabel(NOB_VehicleBrand__c),
                NOB_VehicleModel__c,
                NOB_VehiculeReturnDate__c,
                NOB_TECH_VehicleRegistrationNumber__c,
                toLabel(NOB_Color__c),
                NOB_TECH_AssureMailingAddress__c,
                toLabel(NOB_Energy__c)
        from WorkOrder
        where Id = :workOrderId];

        rent = new NOB_Rent__c();
        List<NOB_Rent__c> lstRent = new List<NOB_Rent__c>([Select Id,
                toLabel(NOB_ReplacementVehicule__r.NOB_Make__c),
                NOB_ReplacementVehicule__r.NOB_Model__c,
                NOB_ReplacementVehicule__r.NOB_PlateNumber__c,
                NOB_ReplacementVehicule__r.NOB_CirculationDate__c,
                toLabel(NOB_ReplacementVehicule__r.NOB_Carburant__c),
                //HMO -- rsiw 4131 -- 09-02-2021
                NOB_VehiculeRentalDate__c
        from NOB_Rent__c
        where NOB_OrdreExecution__c = :wo.Id
        order by NOB_VehiculeRentalDate__c DESC
        Limit 1]);
        if(lstRent.size() > 0){
            rent = lstRent[0];
            //HMO -- 4131
           if(rent.NOB_VehiculeRentalDate__c != null) {
                Datetime rentalVR = rent.NOB_VehiculeRentalDate__c;
                dateRentalVR = rentalVR.format('dd/MM/yyyy');
                timeRentalVR = rentalVR.format('HH:mm');         
            }
        }

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
    }
}