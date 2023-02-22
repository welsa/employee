/*
----------------------------------------------------------------------
-- - Name          : VFC14_PrintPartListForBodyshop
-- - Author        : ABT
-- - Description   : Controller of VFP14_PrintPartListForBodyshop_ABT
--                   Class is without sharing and workarounds has been done to display data due to FLS
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 02-MAR-2017  ABT     1.0         Initial version
-- 26-MAY-2017  ABT     1.1         Reworked version
-- 06-MAR-2018  VSU     1.2         C-002044 Add canceled/returned section and invoice section for print the order button
-- 19-APR-2018  VSU     1.3         C-002345 Change Request Delivery Note Distributor details
-- 10-MAY-2018  DUN     1.4         C-001982 Impression champs commentaire dans récapitulatif
-- 07-AUG-2018  WCH     1.5         C-002718 Issue with delivery note (No distributor for each part)
-- 02-OCT-2018  WCH     1.6         C-002714 Delivery Note on Agency Mode(add AgencyMode__c field in offer)
-- 19-DEC-2018  WCH     1.7         C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
-- 08-JAN-2018  WCH     1.8         C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops>Custom setting
-- 29-MAR-2018  WCH     1.9         C-002981 - Mettre la référence client dans les 3 documents pdf
-- 14-AUG-2019  WCH     2.0         C-003348 - Include spare part cancellation reason in SO Delivery Slip
-- 29-NOV-2019  WCH     2.1         C-003491 - Cancelation reason in the SO should be displayed in native langue for users in each country 
-- 23-DEC-2019  WCH     2.2         C-003531 - Modify all email and delivery note templates sent to BS and Distributor
-- 09-Nov-2020  KPA     2.3         C-004026 : Pentest - Insecure Direct Object Reference
-- 19-May-2021  RLA     2.3         C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class VFC14_PrintPartListForBodyshop
{
    public PrerequisiteOrder__c currentSalesOrder{get;set;}
    public SalesOrder currentSalesOrderWrapper {get; set;}
    public String renderAs {get; set;}
    public String language {get; set;}
    public Map<Id, OfferWrapper> mapOfferWrapper {get; set;}
    public Map<Id, DistributorWrapper> mapDistributorWrapper {get; set;}
    public String currentDate {get; set;}
    public Boolean isDeliveryNote {get; set;}
    public Boolean printDeliveryNote {get;set;}
    public static Map<String, String> mapDeliveryStatusTranslatedValue =  new Map<String, String>();
    public Decimal vat {get; set;}
    public static Set<String> partNumberSelectedByBS {get; set;}
    public static Set<Id> setDistributorIdsBSSelectedFrom {get; set;}
    public static String currentCountryCode {get; set;}
    public static Set<Id> setParentOfferIds {get; set;}
    public Boolean isCDC {get;set;}//WCH 23/12/2019 C-003531 isConfirmationDeCommande
    public Boolean isBDL_FR {get;set;}//WCH 23/12/2019 C-003531 isBon de livraison FR
    public Boolean canSeeSO {get;set;} // KPA 09/11/2020  C-004026
    public String callPrintDevNote {get;set;}

    //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
    public static Boolean isNONAXA {get;set;}


    public VFC14_PrintPartListForBodyshop()
    {
        
        //KPA 09/11/2020  C-004026 
        canSeeSo = true;

        Blob decryptedData = EncodingUtil.base64Decode(ApexPages.currentPage().getParameters().get('Id'));
        String decryptedId = decryptedData.toString();
        String salesOrderId = decryptedId;
        
        callPrintDevNote = ApexPages.currentPage().getParameters().get('callFrom');
        System.debug('~~~~  callPrintDevNote '+ callPrintDevNote);
        
      if(!verifyPermission((Id)salesOrderId) && callPrintDevNote!= null && callPrintDevNote=='true'){
          canSeeSO=false;
         }
	
        System.debug('~~~verifyPermission((Id)SalesOrderId) '+verifyPermission((Id)SalesOrderId));
        System.debug('~~~~~ canSeeSO'+ canSeeSO);
      
        language            = String.isNotBlank(ApexPages.currentPage().getParameters().get('lang')) ? ApexPages.currentPage().getParameters().get('lang') : UserInfo.getLanguage();
        isDeliveryNote      = String.isNotBlank(ApexPages.currentPage().getParameters().get('isDeliveryNote')) && ApexPages.currentPage().getParameters().get('isDeliveryNote') == 'true' ? true : false;
        printDeliveryNote   = String.isNotBlank(ApexPages.currentPage().getParameters().get('printDeliveryNote')) && ApexPages.currentPage().getParameters().get('printDeliveryNote') == 'true' ? true : false;
        isCDC   = String.isNotBlank(ApexPages.currentPage().getParameters().get('isCDC')) && ApexPages.currentPage().getParameters().get('isCDC') == 'true' ? true : false;//WCH 23/12/2019 C-003531 isConfirmationDeCommande
        isBDL_FR   = String.isNotBlank(ApexPages.currentPage().getParameters().get('isBDL_FR')) && ApexPages.currentPage().getParameters().get('isBDL_FR') == 'true' ? true : false;//WCH 23/12/2019 C-003531 isConfirmationDeCommande 

        //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        partNumberSelectedByBS=new Set<String>();
        setDistributorIdsBSSelectedFrom=new Set<Id>();
        setParentOfferIds=new Set<Id>();
        currentCountryCode='NO_COUNTRY';

        currentSalesOrder           = [ SELECT  Id, Name, ClaimReference__c, ReferenceNumber__c, PlateNumber__c, Status__c, CurrencyIsoCode, TECH_BodyshopCountryCode__c,
                                                Manufacturer__c, Model__c, ExpectedDeliveryDateMaximum__c,Assessment__r.MissionNumber__c,
                                                BodyShop__r.Name, BodyShop__r.ShippingStreet, BodyShop__r.ShippingPostalCode, BodyShop__r.ShippingCity, BodyShop__r.ShippingCountry, BodyShop__r.ShippingCountryCode, BodyShop__r.VATNumber__c,
                                                Assessment__r.AssessmentNumber__c, Assessment__r.ASReference__c , BodyshopOrderNumber__c  , Assessment__r.Comment__c
                                                ,Assessment__r.TECH_EntityCountryCode__c, Assessment__r.EntityCode__c //RLA 19/05/2021 C-004337:
                                        FROM    PrerequisiteOrder__c
                                        WHERE   Id =: salesOrderId];

        currentSalesOrderWrapper    = new SalesOrder(currentSalesOrder);

        //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
        isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => currentSalesOrder.Assessment__r.TECH_EntityCountryCode__c, 'entity' => currentSalesOrder.Assessment__r.EntityCode__c, 'fromProcess' => 'Order'});


        //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        currentCountryCode=(currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE)?((CountryCodeInformationsMapping__c.getall().containsKey(ASPISConstants.TECH_EntityCountryCodeBE) && CountryCodeInformationsMapping__c.getall().get(ASPISConstants.TECH_EntityCountryCodeBE).ActivateMultisourcing__c)?ASPISConstants.TECH_EntityCountryCodeBE:'MultiSourcingBEInactive'):currentSalesOrder.TECH_BodyshopCountryCode__c);

        CountryCodeInformationsMapping__c currentCountryInfo    = CountryCodeInformationsMapping__c.getInstance(currentSalesOrder.TECH_BodyshopCountryCode__c);
        currentCountryInfo                                      = (currentCountryInfo != null) ? currentCountryInfo : CountryCodeInformationsMapping__c.getInstance('DEFAULT');
        vat                                                     = ((currentCountryInfo != null && currentCountryInfo.CountryVAT__c != null) ? currentCountryInfo.CountryVAT__c.setScale(2, System.RoundingMode.HALF_UP) : 0);

        renderAs                    = 'pdf';
        mapOfferWrapper             = new Map<Id, OfferWrapper>();
        mapDistributorWrapper       = new Map <Id, DistributorWrapper>();
        currentDate                 = System.today().format();

        String fileName             = ((isDeliveryNote) ? 'PDF' : Label.Delivery_note) + '_' + currentSalesOrder.Name + '_' + System.now().format('dd-MM-yy') + '.pdf';

        if(ApexPages.currentPage().getParameters().get('force_download') == 'true')
        {
            ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + fileName);
        }
        else
        {
            ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
        }

        populateMapDeliveryStatusStatusTranslatedValues();

        set <Id> setDistributorIds = new set <Id> ();
        Map <String,Id> PartNumberNotSelectedMapOfferId = new Map <String,Id> ();

        for (Offer__c currentOffer :[SELECT     Id, PartNUmber__c, Description__c, Quantity__c, FinalType__c, CataloguePrice__c,
                                                Discount__c, Price__c, BSTotalPrice__c, CreatedDate, DeliveryStatus__c, ParentOffer__c,
                                                Suppliable__c, Accepted__c, OriginalPartNumber__c, Type__c, VAT__c, IsCanceledByBodyshop__c,
                                                ExpectedDeliveryDate__c,CreditNote__c,Invoice__c,AdjustmentDescription__c,AdjustmentAmount__c,
                                                OrderLine__r.PurchaseOrder__r.Distributor__r.Name,OrderLine__r.PurchaseOrder__r.Distributor__r.ContactEmail__c,
                                                OrderLine__r.PurchaseOrder__r.Distributor__r.Phone,AgencyMode__c,OrderLine__r.PurchaseOrder__r.Distributor__c
                                                ,tolabel(OrderLine__r.CancelReason__c) //WCH 14/08/2019 C-003348, WCH 29/11/2019 C-003491
                                     FROM       Offer__c
                                     WHERE      Prerequisiteorder__c = :currentSalesOrder.Id /*and Type__c != 'Invoicing'*/
                                     AND        OrderLine__r.PurchaseOrder__r.Status__c != 'CLOSEDKO'//RBE 16/02/2023: To prevent PO of PRE By Alphascale from being selected
                                     ORDER BY   Name ASC])
        {
            // To add wrapper depending on its type
            if (currentOffer.ParentOffer__c != null)
            {
                // is a child offer

                // Checks if a wrapper of that id already exists
                if (mapOfferWrapper.containsKey(currentOffer.ParentOffer__c))
                {
                    // add the child offer to the existing wrapper
                    mapOfferWrapper.get(currentOffer.ParentOffer__c).addChildOffer(currentOffer);
                }
                else
                {
                    // put a new wrapper in the map
                    mapOfferWrapper.put(currentOffer.ParentOffer__c, new OfferWrapper(currentOffer));
                }
            }
            else
            {
                // is the parent offer
                
                //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                if(!currentCountryCode.equals(ASPISConstants.TECH_EntityCountryCodeBE)){
                    setParentOfferIds.add(currentOffer.Id);
                }

                // Checks if a wrapper of that id already exists
                if (mapOfferWrapper.containsKey(currentOffer.Id))
                {
                    // add the parent offer to the existing wrapper
                    mapOfferWrapper.get(currentOffer.Id).setParentOffer(currentOffer);
                }
                else
                {
                    // put a new wrapper in the map
                    mapOfferWrapper.put(currentOffer.Id, new OfferWrapper(currentOffer));

                    //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    if(mapOfferWrapper.get(currentOffer.Id).isSelectedByBodyShop){
                        partNumberSelectedByBS.add(currentOffer.PartNUmber__c);
                        setDistributorIdsBSSelectedFrom.add(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c);
                    }else{
                        PartNumberNotSelectedMapOfferId.put(currentOffer.PartNUmber__c,currentOffer.Id);
                    }
                }
                
            }
            //VSU 18/04/18
            if(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c != null){
                setDistributorIds.add(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c);
            }

        }      
        
        System.debug('## mapOfferWrapper: ' + mapOfferWrapper);

        for(Account dist : [select id,contactUser__r.Email,Name,Phone from Account where id IN: setDistributorIds]){
            //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            if(currentCountryCode.equals(ASPISConstants.TECH_EntityCountryCodeBE)){
                if(setDistributorIdsBSSelectedFrom.contains(dist.Id))
                    mapDistributorWrapper.put(dist.id,new DistributorWrapper(dist));
            }else{
                mapDistributorWrapper.put(dist.id,new DistributorWrapper(dist));
            }
        }
        //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        if(currentCountryCode.equals(ASPISConstants.TECH_EntityCountryCodeBE)){
            setParentOfferIds.addAll(PartNumberNotSelectedMapOfferId.values());
        }

        System.debug('## mapDistributorWrapper: ' + mapDistributorWrapper);
    }

    public void populateMapDeliveryStatusStatusTranslatedValues()
    {
        // Get the label of each status from the Schema.DescribeFieldResult
        Schema.DescribeFieldResult offerDeliveryStatusSchema = Offer__c.DeliveryStatus__c.getDescribe();

        for(Schema.PicklistEntry currentPicklistEntry : offerDeliveryStatusSchema.getPicklistValues())
        {
            VFC14_PrintPartListForBodyshop.mapDeliveryStatusTranslatedValue.put(currentPicklistEntry.getValue(), currentPicklistEntry.getLabel());
        }

        System.debug(VFC14_PrintPartListForBodyshop.mapDeliveryStatusTranslatedValue);
    }

    public class SalesOrder
    {
        public String id {get; set;}
        public String name {get; set;}
        public String claimReference {get; set;}
        // public String referenceNumber {get; set;}
        public String plateNumber {get; set;}
        public String status {get; set;}
        public String currencyIsoCode {get; set;}
        public String manufacturer {get; set;}
        public String model {get; set;}
        public String billingAddress {get; set;}
        public String assessmentNumber {get; set;}
        public String asReference {get; set;}
        public String deliveryDate {get; set;}
        public String vatNumber {get; set;}
        public String bodyshopOrderNumber {get; set;}
        public String TECH_BodyshopCountryCode {get; set;}
        
        public SalesOrder(PrerequisiteOrder__c currentSalesOrder)
        {
            id                      = currentSalesOrder.Id;
            name                    = currentSalesOrder.Name;
            claimReference          = currentSalesOrder.ClaimReference__c;
            // referenceNumber          = currentSalesOrder.ReferenceNumber__c;
            plateNumber             = currentSalesOrder.PlateNumber__c;
            status                  = currentSalesOrder.Status__c;
            currencyIsoCode         = currentSalesOrder.CurrencyIsoCode;
            manufacturer            = currentSalesOrder.Manufacturer__c;
            model                   = currentSalesOrder.Model__c;
            assessmentNumber        = currentSalesOrder.Assessment__r.AssessmentNumber__c;
            asReference             = currentSalesOrder.Assessment__r.ASReference__c;
            
            deliveryDate            = (currentSalesOrder.ExpectedDeliveryDateMaximum__c != null) ? currentSalesOrder.ExpectedDeliveryDateMaximum__c.format() : null;

            billingAddress =    '<p class="text-bold">' + currentSalesOrder.BodyShop__r.Name + '</p>' +
                                '<p>' + currentSalesOrder.BodyShop__r.ShippingStreet + '</p>' +
                                '<p>' + currentSalesOrder.BodyShop__r.ShippingPostalCode + ' ' + currentSalesOrder.BodyShop__r.ShippingCity +'</p>' +
                                '<p>' + currentSalesOrder.BodyShop__r.ShippingCountry.toUpperCase() + ' (' + currentSalesOrder.BodyShop__r.ShippingCountryCode + ')</p>';/* +
                                '<p>' + Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('VATNumber__c').getDescribe().getLabel() + ' : ' + currentSalesOrder.BodyShop__r.VATNumber__c + '</p>'; */

            vatNumber               = currentSalesOrder.BodyShop__r.VATNumber__c;
            //WCH 29/03/2019 C-002981 - Mettre la référence client dans les 3 documents pdf
            bodyshopOrderNumber     = currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) ? (currentSalesOrder.Name + (String.isBlank(currentSalesOrder.BodyshopOrderNumber__c)? '' : ' - '+currentSalesOrder.BodyshopOrderNumber__c)) : currentSalesOrder.BodyshopOrderNumber__c;
            TECH_BodyshopCountryCode     = currentSalesOrder.TECH_BodyshopCountryCode__c;
            
        }

    }

    //VSU 19/04/18
    public class DistributorWrapper
    {
        public String id {get;set;}
        public String distName {get;set;}
        public String distEmail {get;set;}
        public String distPhone {get;set;} 

        public DistributorWrapper(Account dist){
            populateDistributorOffer(dist);
        }

        private void populateDistributorOffer(Account dist)
        {
            id                          = dist.Id;
            distName                    = dist.Name;
            distEmail                   = dist.ContactUser__r.email;
            distPhone                   = dist.Phone;
        }

    }

    public class OfferWrapper
    {
        // The parent offer of the wrapper
        public Offer__c parentOffer { get; set; }
        
        public String id {get; set;}
        public String partNumber {get; set;}
        public String description {get; set;}
        public Decimal quantity {get; set;}
        public String finalType {get; set;}
        public Decimal cataloguePrice {get; set;}
        public Decimal discount {get; set;}
        public Decimal vat {get; set;}
        public Decimal price {get; set;}
        public Decimal bsTotalPrice {get; set;}
        public String translatedDeliveryStatus {get; set;}
        public String deliveryStatus {get; set;}
        public Date expectedDeliveryDate {get; set;}
        public String offerType {get;set;}
        public Id creditedInv {get;set;}
        public Id chargedInv {get;set;}
        public String adjustmentDesc {get;set;}
        public String distributorName {get;set;}
        public Decimal adjustmentAmount {get;set;}
        public Boolean AgencyMode {get; set;}
        public String olCancelReason {get; set;}//WCH 14/08/2019 C-003348

        // List of child offers of the wrapper
        // It is empty if there is no child offers
        public List<BundleItemOffer> childOfferList { get; set; }

        public Boolean hasInvoicesCredited{
            get{
                return (offerType == 'Invoicing' && creditedInv != null);
            }
        }

        public Boolean hasInvoicesCharged{
            get{
                return (offerType == 'Invoicing' && chargedInv != null);
            }
        }


        // SELECTED BY BODYSHOP
        public Boolean isSelectedByBodyShop
        {
            get
            {
                return (parentOffer != null && 
                        parentOffer.Suppliable__c == true && 
                        parentOffer.Accepted__c != 'NO' &&
                        !(parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED &&
                          !parentOffer.IsCanceledByBodyshop__c) && parentOffer.Type__c != 'Invoicing'
                        );
            }
        }
        // WCH 09/01/2020 C-003531
        public Boolean isAgencyMode
        {
            get
            {
                return (parentOffer != null && parentOffer.AgencyMode__c);
            }
        }

        // NOT SELECTED BY BODYSHOP
        public Boolean isNotSelectedByBodyShop
        {
            get
            {  //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                return((parentOffer != null && 
                                parentOffer.Suppliable__c == true && 
                                parentOffer.Accepted__c == 'NO'
                                && parentOffer.Type__c != 'Invoicing') ? (currentCountryCode.equals(ASPISConstants.TECH_EntityCountryCodeBE) ? (!partNumberSelectedByBS.contains(parentOffer.PartNUmber__c) && (setParentOfferIds.contains(parentOffer.Id))) : true) : false);
            }
        }
        
        // CANCELED BY DISTRIBUTOR
        public Boolean isCanceledByDistributor
        {
            get
            {
                return (parentOffer != null && 
                        parentOffer.Suppliable__c == true && 
                        parentOffer.Accepted__c != 'NO' &&
                        parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED &&
                        !parentOffer.IsCanceledByBodyshop__c
                        && parentOffer.Type__c != 'Invoicing');
            }
        }

        // CANCELED/RETURNED SECTION
        public Boolean isCanceledOrReturned//vsu Case 002044: 05/03/18
        {
            get
            {
                return (parentOffer != null && 
                        parentOffer.Suppliable__c == true && 
                        parentOffer.Accepted__c != 'NO' &&
                        !(parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED &&
                          !parentOffer.IsCanceledByBodyshop__c) &&                   
                        (parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED
                        || parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
                        && parentOffer.Type__c != 'Invoicing');
            }
        }

        // NOT SELECTED BY DISTRIBUTOR
        public Boolean isNotSelectedByDistributor
        {
            get
            {
                return (parentOffer != null && 
                        parentOffer.Suppliable__c == false
                        && parentOffer.Type__c != 'Invoicing');
            }
        }

        // variable to know if the offer is for an alternative order line
        public Boolean isOfferAlternative
        {
            get
            {
                return (parentOffer != null &&
                        parentOffer.OriginalPartNumber__c != null &&
                        childOfferList.size() != 0
                        && parentOffer.Type__c != 'Invoicing');
            }
        }

        public OfferWrapper(Offer__c off)
        {
            childOfferList = new List<BundleItemOffer>();

            if (off.ParentOffer__c != null)
            {
                // the offer is a child offer
                childOfferList.add(new BundleItemOffer(off));
            }
            else
            {
                // the offer is a parent offer
                populateParentOffer(off);
            }
        }

        public void setParentOffer(Offer__c offer)
        {
            if (parentOffer == null)
            {
                populateParentOffer(offer);
            }
        }

        private void populateParentOffer(Offer__c offer)
        {
            parentOffer = offer;

            id                          = offer.Id;
            partNumber                  = offer.PartNUmber__c;
            description                 = offer.Description__c;
            quantity                    = offer.Quantity__c;
            finalType                   = offer.FinalType__c;
            cataloguePrice              = offer.CataloguePrice__c;
            discount                    = offer.Discount__c;
            vat                         = ((offer.VAT__c != null) ? offer.VAT__c : 0).setScale(2);
            price                       = offer.Price__c;
            bsTotalPrice                = offer.BSTotalPrice__c;
            deliveryStatus              = offer.DeliveryStatus__c;
            expectedDeliveryDate        = offer.ExpectedDeliveryDate__c;
            translatedDeliveryStatus    = (VFC14_PrintPartListForBodyshop.mapDeliveryStatusTranslatedValue.containsKey(offer.DeliveryStatus__c)) ? VFC14_PrintPartListForBodyshop.mapDeliveryStatusTranslatedValue.get(offer.DeliveryStatus__c) : offer.DeliveryStatus__c;
            offerType                   = offer.Type__c;//vsu
            creditedInv                 = offer.CreditNote__c;
            chargedInv                  = offer.Invoice__c;
            adjustmentDesc              = offer.AdjustmentDescription__c;
            adjustmentAmount            = offer.AdjustmentAmount__c;
            distributorName             = offer.orderline__r.purchaseorder__r.Distributor__r.Name;
            AgencyMode                  = offer.AgencyMode__c;
            olCancelReason              = offer.OrderLine__r.CancelReason__c;//WCH 14/08/2019 C-003348
        } 

        public void addChildOffer(Offer__c offer)
        {
            childOfferList.add(new BundleItemOffer(offer));
        }
    }

    public class BundleItemOffer
    {
        public Offer__c bundleItem {get; set;}

        public String id {get; set;}
        public String partNumber {get; set;}
        public String description {get; set;}
        public Decimal discount {get; set;}
        public Decimal quantity {get; set;}
        public Decimal cataloguePrice {get; set;}
        public Decimal vat {get; set;}
        public Decimal price {get; set;}
        public Decimal bsTotalPrice {get; set;}
        public String finalType {get; set;}
        public String translatedDeliveryStatus {get; set;}
        public String deliveryStatus {get; set;}
        public Date expectedDeliveryDate {get;set;}
        public Boolean AgencyMode {get; set;}
        public String olCancelReason {get; set;}//WCH 14/08/2019 C-003348

        public BundleItemOffer(Offer__c currentOffer)
        {
            bundleItem = currentOffer;

            id              = currentOffer.Id;
            partNumber      = currentOffer.PartNUmber__c;
            description     = currentOffer.Description__c;
            quantity        = currentOffer.Quantity__c;
            finalType       = currentOffer.FinalType__c;
            cataloguePrice  = currentOffer.CataloguePrice__c;
            discount        = currentOffer.Discount__c;
            vat             = ((currentOffer.VAT__c != null) ? currentOffer.VAT__c : 0).setScale(2);
            price           = currentOffer.Price__c;
            bsTotalPrice    = currentOffer.BSTotalPrice__c;
            deliveryStatus  = currentOffer.DeliveryStatus__c;
            expectedDeliveryDate = currentOffer.ExpectedDeliveryDate__c;
            translatedDeliveryStatus    = (VFC14_PrintPartListForBodyshop.mapDeliveryStatusTranslatedValue.containsKey(currentOffer.DeliveryStatus__c)) ? VFC14_PrintPartListForBodyshop.mapDeliveryStatusTranslatedValue.get(currentOffer.DeliveryStatus__c) : currentOffer.DeliveryStatus__c;
            AgencyMode      = currentOffer.AgencyMode__c;
            olCancelReason  = currentOffer.OrderLine__r.CancelReason__c;//WCH 14/08/2019 C-003348
        }
    }
    
    public boolean verifyPermission(Id recordId){
        return ([SELECT  RecordId
                FROM    UserRecordAccess
                WHERE   RecordId =: recordId
                AND     UserId =: UserInfo.getUserId()
                AND     HasReadAccess = true].size() > 0);
    }

    // public String getAddress()
    // {
    //     if(currentSalesOrder.BodyShop__r.ShippingCountry == 'Spain')
    //     {
    //       return    '\n'+
    //                 '<div style="float:left;width:45%;text-align:right;">\n'+
    //                 '<p style="font-weight:bold;">Alpha Scale S.A., Sucursal en España<br/>\n'+
    //                 'W0010418B<br/>\n'+
    //                 'C/ Camino Fuente de la Mora, no 1<br/>\n'+
    //                 '28050 Madrid</p>\n'+
    //                 '</div>\n';
    //     }
    //     else if(currentSalesOrder.BodyShop__r.ShippingCountry == 'France')
    //     {
    //       return    '\n'+
    //                 '<div style="float:left;width:45%;text-align:right;">\n'+
    //                 '<p style="font-weight:bold;">Alpha Scale France<br/>\n'+
    //                 '21 Avenue Matignon<br/>\n'+
    //                 '75008 Paris</p>\n'+
    //                 '</div>\n';
    //     }
    //     else
    //     {
    //       return    '\n'+
    //                 '<div style="float:left;width:45%;text-align:right;">\n'+
    //                 '<p style="font-weight:bold;">Alpha Scale S.A., Sucursal en España<br/>\n'+
    //                 'W0010418B<br/>\n'+
    //                 'C/ Camino Fuente de la Mora, no 1<br/>\n'+
    //                 '28050 Madrid</p>\n'+
    //                 '</div>\n';
    //     }
    // }
}