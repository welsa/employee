/*
 @File Name          : NOB_VFC49_EtatDeLieux.cls
 @Description        : visualforce pdf EtatDesLieux_merged controller
 @Author             : HMO
 @Group              : 
 @Last Modified By   : DUN
 @Last Modified On   : 05-24-2021
 @Modification Log   : 
 ==============================================================================
  Ver         Date                     Author      Modification
 ==============================================================================
  1.0    25/08/2020, 11:00      HMO      1.0
  1.1    05/11/2020, 16:42      HMO      1.1       All fields from Case replaced by formula fields from WorkOrder
*/


public without sharing class NOB_VFC49_EtatDeLieux {
    public WorkOrder wo { get; set; }
    public String dateRetour {get;set;}
    public String timeRetour {get;set;}
    public NOB_Rent__c rent {get;set;}
    public String dateRentalVR{get;set;}
    public String timeRentalVR{get;set;}
    public String dateReturnVR{get;set;}
    public String timeReturnVR{get;set;}
    public String strlocaldt{get;set;}
    public String dateRendezVous{get;set;}
    public String timeRendezVous{get;set;}

    public NOB_VFC49_EtatDeLieux(ApexPages.StandardController controller) {
        Id workOrderId = controller.getId();
        wo = [
                SELECT Id,
                        WorkOrderNumber,
                        NOB_VehiculeReturnDate__c,
                        NOB_TECH_VehicleRegistrationNumber__c,
                        NOB_VehicleBrand__c,
                        NOB_TECH_VehicleBrand__c,
                        NOB_TECH_VehicleModel__c,
                        CreatedDate,
                        NOB_TECH_ReparateurName__c,
                        NOB_TECH_ReparateurPhone__c,
                        NOB_TECH_ReparateurFax__c,
                        NOB_TECH_ReparateurBillingCity__c,
                        NOB_TECH_ReparateurBillingStreet__c,
                        NOB_TECH_ReparateurBillingPostalCode__c,
                        NOB_TECH_ReparateurEmailAddress__c,
                        NOB_TECH_ReparateurRate1__c,
                        NOB_TECH_ReparateurRate2__c,
                        NOB_TECH_ReparateurRate3__c,
                        NOB_TECH_ReparateurPaintRate__c,            
                        NOB_TECH_AddressType__c,              
                        NOB_VehicleModel__c,
                        NOB_TECH_BusinessProviderName__c,
                        NOB_TECH_ContactPickupSalutation__c,
                        NOB_TECH_ContactPickupFirstName__c,
                        NOB_TECH_ContactPickupLastName__c,
                        NOB_TECH_ContactPickupPhone__c,
                        NOB_TECH_ContactPickupMobilePhone__c,
                        NOB_TECH_ContactPickup_OtherPhone__c,
                        NOB_TECH_ContactPickup_Fax__c,
                        NOB_TECH_ContactPickupEmail__c,
                        NOB_InsuredStreet__c,
                        NOB_InsuredCity__c,
                        NOB_InsuredZipCode__c,
                        NOB_TECH_ContactPickup_MailingCountry__c,
                        NOB_TECH_ContactPickup_OtherStreet__c,
                        NOB_TECH_ContactPickup_OtherPostalCode__c,
                        NOB_TECH_ContactPickup_OtherCity__c,
                        NOB_TECH_ContactPickup_OtherCountry__c,
                        NOB_DamageType__c,
                        NOB_TECH_DamageDetails__c, 
                        NOB_Mileage__c,
                        NOB_Carburant__c,                 
                        toLabel(NOB_Color__c),             
                        toLabel(NOB_Energy__c)             
                FROM WorkOrder
                WHERE Id = :workOrderId
        ];

        if(wo.NOB_VehiculeReturnDate__c != null) {
            Datetime retour = wo.NOB_VehiculeReturnDate__c;
            dateRetour = retour.format('dd/MM/yyyy');
            timeRetour = retour.format('HH:mm');
        }

        rent = new NOB_Rent__c();
        List<NOB_Rent__c> lstRent = new List<NOB_Rent__c>([
                Select Id,
                        Name,  //
                        toLabel(NOB_ReplacementVehicule__r.NOB_Make__c),
                        NOB_ReplacementVehicule__r.NOB_Model__c,
                        NOB_ReplacementVehicule__r.NOB_PlateNumber__c,
                        NOB_VehiculeRentalDate__c,
                        NOB_VehiculeReturnDate__c
                from NOB_Rent__c
                where NOB_OrdreExecution__c = :wo.Id
                order by NOB_VehiculeRentalDate__c DESC
                Limit 1
        ]);
        if (lstRent.size() > 0) {
            rent = lstRent[0];
            if(rent.NOB_VehiculeRentalDate__c != null) {
                Datetime rentalVR = rent.NOB_VehiculeRentalDate__c;
                dateRentalVR = rentalVR.format('dd/MM/yyyy');
                timeRentalVR = rentalVR.format('HH:mm');
            }


            if(rent.NOB_VehiculeReturnDate__c != null) {
                Datetime returnVR = rent.NOB_VehiculeReturnDate__c;
                dateReturnVR = returnVR.format('dd/MM/yyyy');
                timeReturnVR = returnVR.format('HH:mm');
            }
        }

        Datetime now = Datetime.now();
       // Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime localdt = now;//.addSeconds(offset/1000);
        strlocaldt = localdt.format('dd/MM/yyy HH:mm');

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

//     public static workOrder getDetails(){
//         // Id workOrderId = ApexPages.currentPage().getParameters().get('Id');
//         return [SELECT Id, Account.Name, Account.Phone, Account.Fax, Account.ShippingCity, Account.ShippingStreet, Account.ShippingPostalCode, 
//         Contact.Name, Contact.MailingStreet, Contact.MailingPostalCode, Contact.MailingCity, Contact.MailingCountry, Contact.Email, Contact.Salutation,
//         Contact.OtherStreet, Contact.OtherPostalCode, Contact.OtherCity, Contact.OtherCountry, Contact.OtherPhone,
//         Contact.Fax,Contact.MobilePhone, Contact.Phone, Case.NOB_VehicleBrand__c, Case.NOB_AddressType__c,
//         Case.NOB_VehicleRegistrationNumber__c, Case.NOB_VehicleModel__c, Case.NOB_BusinessProvider__r.name,
//         WorkOrder.WorkOrderNumber, WorkOrder.NOB_VehiculeReturnDate__c, asset.NOB_ContractStartDate__c, asset.NOB_Make__c, asset.NOB_Model__c, account.NOB_Rate1__c,
//         account.NOB_Rate2__c, account.NOB_Rate3__c, account.NOB_PaintRate__c
//         FROM workOrder WHERE Id = '0WO1l000000Gk5KGAS'];       
//     }
}