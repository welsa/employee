/*
----------------------------------------------------------------------
-- - Name          : VFC17_PrintPartListForAssessment
-- - Author        : VSU
-- - Description   : Controller of VFP17_PrintPartListForAssessment
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 06-JUN-2017  VSU     1.0         Initial version
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class VFC17_PrintPartListForAssessment {
    public Assessment__c currentAssessment;
    public Assessment currentAssessmentWrapper {get; set;}
    public String renderAs {get; set;}
    public String language {get; set;}
    public Map <Id, PartListWrapper> mapPartListsWrapper {get; set;}
    public String currentDate {get; set;}

    public VFC17_PrintPartListForAssessment() {
        String assessmentId = ApexPages.currentPage().getParameters().get('Id');
        language = String.isNotBlank(ApexPages.currentPage().getParameters().get('lang')) ? ApexPages.currentPage().getParameters().get('lang') : UserInfo.getLanguage();

        currentAssessment = [SELECT Id, Name, OrderOrigin__c, CurrencyIsoCode, Manufacturer__c, PlateNumber2__c, ModelV2__c,
                                    BodyShop__r.Name, BodyShop__r.ShippingStreet, BodyShop__r.ShippingPostalCode, BodyShop__r.ShippingCity,
                                    BodyShop__r.ShippingCountry, BodyShop__r.ShippingCountryCode, BodyShop__r.VATNumber__c, ASReference__c,ClaimReference__c
                            FROM Assessment__c
                            WHERE Id =: assessmentId];

        currentAssessmentWrapper = new Assessment(currentAssessment);

        renderAs = 'pdf';
        mapPartListsWrapper = new Map <Id, PartListWrapper>();
        currentDate = System.today().format();

        String fileName = 'PDF_' + currentAssessment.Name + '_' + System.now().format('dd-MM-yy') + '.pdf';

        if (ApexPages.currentPage().getParameters().get('force_download') == 'true') {
            ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + fileName);
        } else {
            ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
        }

        for (PartList__c currentPartList: [ SELECT Id, PartNumber__c, Quantity__c, Type__c, Description__c
                                            FROM PartList__c
                                            WHERE Assessment__c =: currentAssessment.Id
                                            ORDER BY Name ASC]){
            mapPartListsWrapper.put(currentPartList.Id, new PartListWrapper(currentPartList));
        }
    }

    public class Assessment {
        public String id {get; set;}
        public String currencyISOCode {get; set;}
        public String billingAddress {get; set;}
        public String vatNumber {get; set;}
        public String asReference {get; set;}
        public String manufacturer {get; set;}
        public String model {get; set;}
        public String plateNumber {get; set;}
        public String claimreference {get; set;}

        public Assessment(Assessment__c currentAssessment) {
            id = currentAssessment.Id;
            currencyISOCode = currentAssessment.currencyISOCode;
            billingAddress =    '<p class="text-bold">' + currentAssessment.BodyShop__r.Name + '</p>' +
                                '<p>' + currentAssessment.BodyShop__r.ShippingStreet + '</p>' +
                                '<p>' + currentAssessment.BodyShop__r.ShippingPostalCode + ' ' + currentAssessment.BodyShop__r.ShippingCity + '</p>' +
                                '<p>' + currentAssessment.BodyShop__r.ShippingCountry.toUpperCase() + ' (' + currentAssessment.BodyShop__r.ShippingCountryCode + ')</p>';
            vatNumber = currentAssessment.BodyShop__r.VATNumber__c;
            asReference = currentAssessment.ASReference__c;
            manufacturer = currentAssessment.Manufacturer__c;
            model = currentAssessment.ModelV2__c;
            plateNumber = currentAssessment.PlateNumber2__c;
            claimreference = currentAssessment.ClaimReference__c;
        }

    }

    public class PartListWrapper {
        public String id {get; set;}
        public String partNumber {get; set;}
        public String type {get; set;}
        public String description {get; set;}
        public Decimal quantity {get; set;}

        public PartListWrapper(PartList__c pl) {
            id          = pl.Id;
            partNumber  = pl.PartNumber__c;
            description = pl.Description__c;
            type        = pl.Type__c;
            quantity    = pl.Quantity__c;
        }
    }
}