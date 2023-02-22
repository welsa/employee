/*
----------------------------------------------------------------------
-- - Name          : VFC04_POManageOrderLines
-- - Author        : ABT
-- - Description   : Controller VFP04_POManageOrderLines_ABT
--
-- Maintenance History:
--
-- Date         Name  Version   Remarks
-- -----------  ----  -------   ---------------------------------------
-- 17-FEB-2017  ABT     1.0     Initial version
-- 18-AUG-2017  AMI     1.1     Commenting MaximumDeliveryDuration__c (
                                now a rollup summary field)
-- 28-NOV-2017  VSU     1.2     C-002008: Businesshours optimisation
-- 14-FEB-2018  DUN     1.3     C-002313: button to add new orderline on PO
-- 22-MAR-2018  RLA     1.4     C-002219: OrderLineWrapper : Attempt to de-reference a null object
-- 21-MAR-2018  VSU     1.5     C-002066: Remove extra AS % for Germany
-- 28-MAY-2018  ASE     1.6     changes in calculations /update stock
-- 09-JUL-2018  ASE     1.7     C-002659 : Prices & Part Type to be sent to Coler
-- 04-OCT-2018  AMI     1.8     C-002045 - color status red if advanced case management is enabled +
                                adding new statuses "managed,cancelled,returned
-- 08-OCT-2018  AMI     1.9     C-002045 - added condition to enable edit button when status = delivery confirmed but 
                                there are still errored lines (applicable to adv case mgt only)
-- 30-NOV-2018  ASE     2.0     C-002948: Avoid duplciate Order call to Coler   
-- 05 DEC 2018  RLa     2.1     C-002782 CJP A'                             
-- 17 JAN 2019  WCH     2.2     C-002620: Unable to see individual parts in PO
-- 05 DEC 2018  RLa     2.1     C-002782 CJP A'                  
-- 18 JAN 2018  RLA     2.2     C-002958: MultiSourcing Belgium - Large choice of distributors for Bodyshops
-- 17 APR 2019  RLA     2.3     C-003193 : Created from scratch R3 assessments not sent to Coler
-- 30 MAY 2019  WCH     2.4     C-003130 : Enhance 'Add a line' button
-- 06 AUG 2019  WCH     2.5     C-003247 : Pop up when Discount is less than 10 in Offer Process
-- 18 JUN 2020  RLA     2.6     C-003700: IG - orderConfirmation
-- 03 sep 2020  ARA     2.7     c-003914: Button 'Order Confirmation' on PO
-- 09 OCT 2020  WCH     2.8     C-003997: Regression IG on ES PO not displayed correctly when in delivered confirmed and viewed by distributor
-- 19 OCT 2021  WCH     2.9     C-004194 : Permission Set : Give AS visibility to Prefikar User
-- 13 MAY 2021  WCH     3.0     C-004160 : Create two new Family and Brand fields in Order Lines
-- 17 Mar 2022  NPE     3.1     C-003897: PO in agency mode does not change to CLOSEDKO after all delivered parts are set to returned
-- 04-May 2022  NPE     3.2     C-004705: Set PO in Agency Mode to CLOSEDKO when all spare parts are set to returned
-- 26-OCT-2022  RRJ     2.6     C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
----------------------------------------------------------------------
**********************************************************************
*/
public class VFC04_POManageOrderLines
{
    public PurchaseOrder__c currentPurchaseOrder {get; set;}
    public Map<Id, OrderLine__c> mapOrderLines {get; set;}

    //boolean to know if order confirmation is done automatically.
    public Boolean OrderAutomatically {get;set;}
    

    // Map Id of Original Order line and its wrapper
    public Map<Id, OrderLineWrapper> mapIdOrderLineWrapper {get; set;}

    public Boolean isEditable {get; set;}
    public Boolean canBeValidated {get; set;}
    public Boolean isPageReadOnly {get; set;}

    public Boolean canRefresh {get; set;}

    // boolean to know if discount management should be used
    public Boolean hasDiscountManagement {get; set;}

    // boolean to know if user can modify the discount when in delivery
    public Boolean hasPORectificationRights {get; set;}

    // boolean to know if the quotation version show be displayed
    //
    // RecordType.Name      |   Boolean
    // -------------------------------------------
    // DraftQuote           |   true
    // In Delivery          |   false
    // Ordered              |   false
    // Eliminated           |   false
    public Boolean isQuotation {get; set;}

    CountryCodeInformationsMapping__c currentCountryInfo;

    public String decimalSeparator {get; set;}

    public Map<String, List<SelectOption>> mapKeyDiscountOptions;
    public Map<Id, Discount__c> mapIdDiscount;

    // ABT - C-001459 - 08-NOV-2016
    //public Utils_BusinessDays currentBusinessDay;
    public BusinessHours currentBusinessDay;

    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}

    public Boolean hasPreselectedParts {get; set;}

    public String locale {get; set;}

    public Boolean hasStatusPredraftQuote {get;set;}

    //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
    public Boolean displayAddOLButton {get;set;}
   // public list<OrderLine__c> oLToInsert {get;set;}
    //public list<Offer__c> offToInsert {get;set;}
    //public list<PartList__c> plToInsert {get;set;}
    public list<OrderLineWrapper> listnewOrderline {get;set;}
    public boolean hasSaved{get;set;}

    //AMI 04/10/18 : C-002045 - Advanced Case Management
    //             : New boolean to determine if advanced case mgt is enabled
    public boolean isAdCaseMgt {get;set;}

    //AMI 04/10/18 : C-002045 - Advanced Case Management
    //             : new string variables retrieved from aspis constants
    public string statusIssue {get;set;}
    public string statusManaged {get;set;}
    public string statusCanceled {get;set;}
    public string statusReturned {get;set;}

    //AMI 04/10/18 : C-002045 - Advanced Case Management
    //             : New boolean to determine if there is at least one offer on error and case mgt is enabled
    //public boolean hasErroredOffer {get;set;}
    
    //WCH 17/01/2019 : C-002620 - PO Unable to see individual parts in PO
    private Datetime VFP04_LoadedTime {get;set;}

    //WCH 06/08/2019 : C-003247 - Pop up when Discount is less than 10 in Offer Process
    public boolean showPopUpForAsDiscount {get;private set;}
    public double minAsDiscountToShowPopUp {get;private set;}

    //RLA 21/10/2020 C-004025 - IG - Re launch Order Call for EFA/NORA
    public Boolean canRelaunchOrderCall {get;set;}

    //WCH 13/05/2021 : C-004160 : Create two new Family and Brand fields in Order Lines
    public Map<String,List<String>> familyBrandOptions {get;set;}
    public Boolean activateFamilyBrand {get;set;}

    //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
    public map<string,Manufacturer_reference__c> mapManufRef {get;set;}
    public VFC04_POManageOrderLines(ApexPages.StandardController sc)
    {
        // if (!Test.isRunningTest()){
        //     sc.addFields(new List<String>{'OrderConfirmationDate__c'});
        //     sc.addFields(new List<String>{'OrderConfirmationErrorMe__c'});
        // }
        

        // Getting the current purchase order
        currentPurchaseOrder = (PurchaseOrder__c) sc.getRecord();
		populateFields(currentPurchaseOrder.Id);//WCH 09/10/2020 C-003997

        // Initialising the variables
        mapOrderLines               = new Map<Id, OrderLine__c>();
        mapIdOrderLineWrapper       = new Map<Id, OrderLineWrapper> ();
        mapKeyDiscountOptions       = new Map<String, List<SelectOption>>();
        mapIdDiscount               = new Map<Id, Discount__c>();
        isEditable                  = false;
        canBeValidated              = false;
        isPageReadOnly              = false;
        canRefresh                  = false;
        hasDiscountManagement       = false;
        isQuotation                 = true;
        hasPORectificationRights    = false;
        hasPreselectedParts         = false;
        hasErrors                   = false;
        isToastError                = false;
        hasStatusPredraftQuote      = false;
        hasSaved                    = false;
        familyBrandOptions          = new Map<String,List<String>>();//WCH 13/05/2021 C-004160
        activateFamilyBrand         = false;//WCH 13/05/2021 C-004160

        //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
        displayAddOLButton          = false;
        //oLToInsert                  = new list<OrderLine__c>();
        //offToInsert                  = new list<Offer__c>();
        //plToInsert                  = new list<PartList__c>();
        listnewOrderline            = new list<OrderLineWrapper>();

        //AMI 04/10/18 : C-002045 - Advanced Case Management
        //             : New boolean to determine if advanced case mgt is enabled
        isAdCaseMgt                 = false;

        //AMI 04/10/18 : C-002045 - Advanced Case Management
        //             : New boolean to determine if there is at least one offer on error and case mgt is enables
        //hasErroredOffer             = false;

        //AMI 04/10/18 : C-002045 - Advanced Case Management
        //             : new string variables retrieved from aspis constants
        statusIssue = ASPISConstants.ORD_LINE_STATUS_ISSUE;
        statusManaged = ASPISConstants.ORD_LINE_STATUS_MANAGED;
        statusCanceled = ASPISConstants.ORD_LINE_STATUS_CANCELED;
        statusReturned = ASPISConstants.ORD_LINE_STATUS_RETURNED;

        //WCH 17/01/2019 : C-002620 - PO Unable to see individual parts in PO
        VFP04_LoadedTime = Datetime.now();
        
        //WCH 06/08/2019 : C-003247 - Pop up when Discount is less than 10 in Offer Process
        showPopUpForAsDiscount = false;
        minAsDiscountToShowPopUp=0;

        //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
        mapManufRef = new map<string,Manufacturer_reference__c>();
        //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
        if(currentPurchaseOrder.Distributor__r.AdditionalPartButton__c && currentPurchaseOrder.Status__c=='DRAFTQUOTE'){
            displayAddOLButton = true;
        }

        if(currentPurchaseOrder.Status__c=='PREDRAFTQUOTE'){
            hasStatusPredraftQuote=true;
        }
        else{
            locale                      = UserInfo.getLocale().left(2);

            Decimal value = 1.10;
            decimalSeparator = (value.format()).substring(1,2);

            // Checks if there is a purchase order
            if (currentPurchaseOrder.Id != null)
            {
                //AMI 08/11/2018 : C-002045 - added condition to enable edit button when status = delivery confirmed but 
                //                 there are still errored lines (applicable to adv case mgt only)
                //                 All below logic moved before check for readonly is performed
                //                 This is to get info from cs
                // Retrieving custom settings for france
                // in case not found display an error message
                currentCountryInfo = CountryCodeInformationsMapping__c.getInstance(currentPurchaseOrder.TECH_AssessmentCountryCode__c);
                if (currentCountryInfo == null)
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.NoCountryMappingFound));
                }
                else
                {
                    hasDiscountManagement = currentCountryInfo.UseAdvancedDiscountManagement__c;

                    // ABT - C-001459 - 28-NOV-2016
                    hasPORectificationRights = currentCountryInfo.EnableDistributorPORectifications__c;

                    // ABT - C-001459 - 08-NOV-2016
                    //Utils_BusinessDays.isInvokedFromFlow = true;
                    ASPISConstants.isInvokedFromFlow = true;
                    //currentBusinessDay = new Utils_BusinessDays(currentPurchaseOrder.TECH_AssessmentCountryCode__c);
                    currentBusinessDay = ASPISConstants.getBusinessHours(currentPurchaseOrder.TECH_AssessmentCountryCode__c);

                    //WCH 06/08/2019 : C-003247 - Pop up when Discount is less than 10 in Offer Process
                    showPopUpForAsDiscount=currentCountryInfo.MinDiscountASToShowWarning__c==null?false:true;
                    minAsDiscountToShowPopUp=currentCountryInfo.MinDiscountASToShowWarning__c==null?0:currentCountryInfo.MinDiscountASToShowWarning__c;
                }

                //AMI 04/10/18 : C-002045 - Advanced Case Management
                //             : checked isAdCaseMgt
                if(currentCountryInfo != null && currentCountryInfo.AdvancedCaseManagement__c){
                    isAdCaseMgt = true;
                }
                //WCH 14/05/2021 C-004160
                if(currentCountryInfo != null && currentCountryInfo.activateOLFamilyBrand__c){
                    system.debug('activateFamilyBrand');
                    activateFamilyBrand=true;
                    familyBrandOptions=getFamilyBrand('');
                }
                // Checking the recordtype name of the purchase order.
                if(currentPurchaseOrder.RecordTypeId == Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId())
                {
                    isQuotation         = true;

                    // NOTE: The condition below is only for draftquote recordtyoe
                    // Checking if the purchase order is not in status draftquote and PREDRAFTQUOTE
                    // Also checking if the user's profile Id is not present in the custom label PROFILEADMINIDS
                    isPageReadOnly = (currentPurchaseOrder.Status__c != 'DRAFTQUOTE' &&
                                      currentPurchaseOrder.Status__c != 'PREDRAFTQUOTE' &&
                                      !(Label.PROFILEADMINIDS.contains(UserInfo.getProfileId()))
                                     ) ? true : false;
                }
                else
                {
                    isQuotation         = false;

                    //AMI 08/11/2018 : C-002045 - added condition to enable edit button when status = delivery confirmed but 
                    //                 there are still errored lines (applicable to adv case mgt only)
                    // Checking if the purchase order is in status DELIVEREDCONFIRMED
                    // Also checking if the user's profile Id is not present in the custom label PROFILEADMINIDS
                    if(isAdCaseMgt){
                        isPageReadOnly = (currentPurchaseOrder.Status__c == 'DELIVEREDCONFIRMED' &&
                                          !(Label.PROFILEADMINIDS.contains(UserInfo.getProfileId())) &&
                                          currentPurchaseOrder.AcceptedLines__c > 0 &&
                                          currentPurchaseOrder.AcceptedLines__c == (currentPurchaseOrder.DeliveredLines__c  + currentPurchaseOrder.Canceled_Lines__c)
                                         ) ? true : false;
                    }else{
                        isPageReadOnly = (currentPurchaseOrder.Status__c == 'DELIVEREDCONFIRMED' &&
                                          !(Label.PROFILEADMINIDS.contains(UserInfo.getProfileId()))
                                         ) ? true : false;
                    }  
                }
            }

            // Getting the list of order line for that purchase order
            retrieveOrderLines();
        }
        //WCH 19/02/2021 C-004194
        if (currentPurchaseOrder.Id != null){
            isPageReadOnly = !(verifyPermission(currentPurchaseOrder.Id));
        }
    }
    //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
    public list<Manufacturer_reference__c> getBrandFamily(set<string> lstpartNumber){
        String query='SELECT Id, Name, RecordType.Name, Brand__c, Sub_family__c, Manufacturer_ID__c FROM Manufacturer_reference__c WHERE ';
        for(string item: lstpartNumber){
            query+='Manufacturer_ID__c = \'' + item+ '\' OR ';
        }
        system.debug('Querry = '+query);
        return database.query(query.removeEnd(' OR '));
    }
    //WCH 09/10/2020 C-003997 
    public void populateFields(Id CurrentPOId){
        PurchaseOrder__c currentPOWithNewFields = [SELECT Id,Name,OrderConfirmationDate__c,OrderConfirmationErrorMe__c,Status__c,Reason__c,TechInsuranceBroker__c,TECH_AssessmentCountryCode__c,
        Distributor__r.AdditionalPartButton__c,Brand__c,RecordTypeId,PrerequisiteOrder__c,SLADeliveryEntryDate__c,Rebate__c,Assessment__c,Comment__c,
        Distributor__r.DistributorConnected__c, Distributor__r.Type_of_Substitutes__c, Assessment__r.BodyShop__r.DistributorConnected__c, Assessment__r.OrderOrigin__c,
        wsDate__c, wsErrorMessage__c, Distributor__r.OrderRequest__c,Assessment__r.BodyShop__c
        FROM PurchaseOrder__c 
        where Id = :CurrentPOId];
        currentPurchaseOrder.OrderConfirmationDate__c=currentPOWithNewFields.OrderConfirmationDate__c;
        currentPurchaseOrder.OrderConfirmationErrorMe__c=currentPOWithNewFields.OrderConfirmationErrorMe__c;
        currentPurchaseOrder.Status__c=currentPOWithNewFields.Status__c;
        currentPurchaseOrder.Reason__c=currentPOWithNewFields.Reason__c;
        currentPurchaseOrder.Distributor__r.AdditionalPartButton__c=currentPOWithNewFields.Distributor__r.AdditionalPartButton__c;
        currentPurchaseOrder.Brand__c=currentPOWithNewFields.Brand__c;
        currentPurchaseOrder.RecordTypeId=currentPOWithNewFields.RecordTypeId;
        currentPurchaseOrder.PrerequisiteOrder__c=currentPOWithNewFields.PrerequisiteOrder__c;
        currentPurchaseOrder.SLADeliveryEntryDate__c=currentPOWithNewFields.SLADeliveryEntryDate__c;
        currentPurchaseOrder.Rebate__c=currentPOWithNewFields.Rebate__c;
        currentPurchaseOrder.Assessment__c=currentPOWithNewFields.Assessment__c;
        currentPurchaseOrder.Comment__c=currentPOWithNewFields.Comment__c;
        currentPurchaseOrder.Distributor__r.DistributorConnected__c=currentPOWithNewFields.Distributor__r.DistributorConnected__c;
        currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c=currentPOWithNewFields.Distributor__r.Type_of_Substitutes__c;
        // system.debug('1'+currentPOWithNewFields.Assessment__r.BodyShop__r.DistributorConnected__c);
        // system.debug('1'+currentPOWithNewFields.Assessment__r.BodyShop__c);
        // currentPurchaseOrder.Assessment__r.BodyShop__r.DistributorConnected__c=currentPOWithNewFields.Assessment__r.BodyShop__r.DistributorConnected__c;
        // currentPurchaseOrder.Assessment__r.OrderOrigin__c=currentPOWithNewFields.Assessment__r.OrderOrigin__c;
        currentPurchaseOrder.wsDate__c=currentPOWithNewFields.wsDate__c;
        currentPurchaseOrder.wsErrorMessage__c=currentPOWithNewFields.wsErrorMessage__c;
        currentPurchaseOrder.Distributor__r.OrderRequest__c=currentPOWithNewFields.Distributor__r.OrderRequest__c;

    }
    // function to get all the order lines and populate the map of wrapper
    public void retrieveOrderLines()
    {
        //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
        list<Manufacturer_reference__c> lstManuRef = new list<Manufacturer_reference__c> ();
	    set<String> setPartNumber  = new set<String> ();
        // checks if there is a purchase order
        if(currentPurchaseOrder.Id != null)
        {
            mapIdOrderLineWrapper           = new Map<Id, OrderLineWrapper>();
            mapKeyDiscountOptions           = new Map<String, List<SelectOption>>();
            Integer suppliableIsNull        = 0;

            String discountConditions       = '';
            Set<String> discountPartTypes   = new Set<String>();

            //AMI 04/10/18 : C-002045 - Advanced Case Management
            //             : map containing offer's ol and offer status
            //             : to be used to check whether corresponding offer is errored
            map <id,string> mapOLIdOfferStatus = new map <id,string>();

            //AMI 04/10/18 : C-002045 - Advanced Case Management
            //             : Retrieving associated Offers
            for (OrderLine__c ol : [SELECT   Id, Name, OrderType__c, PartNumber__c, Type__c, Description__c, Manufacturer__c, ExpectedDeliveryDuration__c, CataloguePrice__c, Quantity__c, TotalPrice__c,
                                             AXADiscount__c, BodyShopDiscount__c, AXATotalPrice__c, PartList__r.CompliantPart__c, Suppliable__c, OriginalItem__c, OriginalItem__r.OriginalItem__c,
                                             AdditionnalDiscount__c, PurchaseOrder__c, PartList__c, VAT__c, TECH_ExtraAS__c, PartList__r.Compliance__c, TECH_DistributorCode__c, Discount__c,
                                             Discount__r.DistributorCode__c, DeliveryStatus__c, AcceptedCheck__c, BodyshopTotalPrice__c, CancelReason__c, Rebate__c, AdditionalDiscountAmount__c, DistributorPrice__c,
                                             IsCanceledByDistributor__c, PreselectedForOrder__c, DeliveryStatusReason__c, 
                                             PurchaseOrder__r.TECH_AssessmentCountryCode__c, 
                                             TechExternalId__c,TechOLType__c,SubstituteType__c,FamilyOfSparePart__c,BrandOfSparePart__c,PurchaseOrder__r.Brand__c,//WCH 14/05/2021 C-004160
                                             PartList__r.DiscountRecord__c,PartList__r.DiscountRecord__r.Rebate__c, 
                                             PartList__r.DiscountRecord__r.BSdiscount__c,//RLA 27/11/2018 C-002782 CJP A'
                                        (select id,DeliveryStatus__c
                                            from Offers__r)
                                    FROM     OrderLine__c
                                   WHERE    PurchaseOrder__c =: currentPurchaseOrder.Id
                                    ORDER BY Name ASC])
            {
                //AMI 04/10/18 : C-002045 - Advanced Case Management
                //             : populating mapOLIdOfferStatus
                if(isAdCaseMgt && !ol.Offers__r.isEmpty() && ol.Offers__r[0].DeliveryStatus__c == ASPISConstants.OFFER_STATUS_ERROR){
                    mapOLIdOfferStatus.put(ol.Id,ASPISConstants.OFFER_STATUS_ERROR);
                    //hasErroredOffer = true;
                }

                // Adding the order line to the map
                // Map stores all the order lines
                // cloning so as to avoid that the data of the order line to be modified
                mapOrderLines.put(ol.Id, ol.clone());

                //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
                if(ol.PartNUmber__c != null){
                    setPartNumber.Add(string.valueof(ol.PartNUmber__c));
                }
                // Increment suppliableIsNull when the order line is not YES or NO
                if (ol.Suppliable__c == null)
                {
                    suppliableIsNull++;
                }

                if(!hasPreselectedParts)
                {
                    hasPreselectedParts = ol.PreselectedForOrder__c;
                }

                // populating the soql query to retrieve the distributor code(discount)
                // if one of the fields is blank exclude it from the select
                // that is if one of the fields on orderline is null, the only option for
                // the distributor code will be none.
                if (ol.Type__c != null &&
                    ol.Manufacturer__c != null)
                {

                    discountConditions += '(     PartType__c     = \'' + ol.Type__c + '\' ' +
                                            'AND Manufacturer__c = \'' + String.escapeSingleQuotes(ol.Manufacturer__c) + '\') OR ';
                }

                if (ol.Type__c != null)
                {
                    discountPartTypes.add(ol.Type__c);
                }

                // check if the order line is an original one
                if (ol.OrderType__c == 'ORIGINAL')
                {
                    if (!mapIdOrderLineWrapper.containsKey(ol.Id))
                    {
                        mapIdOrderLineWrapper.put(ol.Id, new OrderLineWrapper(ol));
                    }
                    else
                    {
                        mapIdOrderLineWrapper.get(ol.Id).setOriginalItem(ol);
                    }
                    //WCH 15/05/2021 C-004160
                    mapIdOrderLineWrapper.get(ol.Id).oLFamily.addAll(getFamilyOptionList(familyBrandOptions,'getFamily'));
                    if(!String.isBlank(ol.FamilyOfSparePart__c)) mapIdOrderLineWrapper.get(ol.Id).oLBrand=getFamilyOptionList(getFamilyBrand(ol.FamilyOfSparePart__c),'getBrand');
                }
                // check if the order line is a final one
                else if (ol.OrderType__c == 'FINAL')
                {
                    // there are two types for the final order line
                    // One can be the original one itself (that has been converted to final)
                    // --- Therefore OriginalItem__c should be null
                    // The second one is that the final order line is the alternative or final of a bundle
                    // --- Therefore OriginalItem__c should not be null

                    if (ol.OriginalItem__c == null)
                    {
                        // Original that has been converted to final
                        if (!mapIdOrderLineWrapper.containsKey(ol.Id))
                        {
                            mapIdOrderLineWrapper.put(ol.Id, new OrderLineWrapper(ol));
                        }
                        //WCH 15/05/2021 C-004160
                        mapIdOrderLineWrapper.get(ol.Id).oLFamily.addAll(getFamilyOptionList(familyBrandOptions,'getFamily'));
                        if(!String.isBlank(ol.FamilyOfSparePart__c)) mapIdOrderLineWrapper.get(ol.Id).oLBrand=getFamilyOptionList(getFamilyBrand(ol.FamilyOfSparePart__c),'getBrand');
                    }
                    else
                    {
                        // Final can be alternative or final for bundle
                        if (!mapIdOrderLineWrapper.containsKey(ol.OriginalItem__c))
                        {
                            mapIdOrderLineWrapper.put(ol.OriginalItem__c, new OrderLineWrapper(ol));
                        }
                        else
                        {
                            mapIdOrderLineWrapper.get(ol.OriginalItem__c).setFinalItem(ol);
                        }
                        //WCH 15/05/2021 C-004160
                        mapIdOrderLineWrapper.get(ol.OriginalItem__c).oLFamily.addAll(getFamilyOptionList(familyBrandOptions,'getFamily'));
                        if(!String.isBlank(ol.FamilyOfSparePart__c)) mapIdOrderLineWrapper.get(ol.OriginalItem__c).oLBrand=getFamilyOptionList(getFamilyBrand(ol.FamilyOfSparePart__c),'getBrand');
                    }
                }
                // check if it is a bundle item
                else if (ol.OrderType__c == 'BUNDLEITEM')
                {
                    if (!mapIdOrderLineWrapper.containsKey(ol.OriginalItem__r.OriginalItem__c))
                    {
                        mapIdOrderLineWrapper.put(ol.OriginalItem__r.OriginalItem__c, new OrderLineWrapper(ol));
                    }
                    else
                    {   //WCH 15/05/2021 C-004160
                        mapIdOrderLineWrapper.get(ol.OriginalItem__r.OriginalItem__c).addBundleItem(ol,getFamilyOptionList(familyBrandOptions,'getFamily'),(!String.isBlank(ol.FamilyOfSparePart__c)?(getFamilyOptionList(getFamilyBrand(ol.FamilyOfSparePart__c),'getBrand')):(new List<SelectOption>())));
                    }
                }
                //DUN 18/08/2017 Shipping cost should not be displayed 
                //else if (ol.OrderType__c == 'SHIPPING COST')
                //{
                //  mapIdOrderLineWrapper.put(ol.Id, new OrderLineWrapper(ol));
                //}

                // ABT - 17-FEB-2017 - Moved logic to the wrapper
                // workaround: not possible to see ol.DistributorPrice__c (Profile 'FR - Distributor' should have access to the DistributorPrice object)
                // if (mapIdOrderLineWrapper.get(ol.Id) != null) {
                //  mapIdOrderLineWrapper.get(ol.Id).isDistributorPrice = (String.isBlank(ol.DistributorPrice__c) ? false : true);
                // }
            }

            //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
            lstManuRef = getBrandFamily(setPartNumber);
            if(lstManuRef != null){
                for(Manufacturer_reference__c mr : lstManuRef){
                    //string s1 = mr.Name;
                    mapManufRef.put(mr.Manufacturer_ID__c,mr);
                    system.debug('VFII ='+mapManufRef);
                }
            }

            // check if there is no orderline
            if (suppliableIsNull == 0)
            {
                canBeValidated = true;
            }

            // Discount Part
            // checks if there is any conditions caught
            // Reason if there is no conditions caught therefore only None will be available as option
            // It is useless to execute the query and bring useless data

            // adding condition for global discount
            for(String partType : discountPartTypes)
            {
                discountConditions +=   ' (  PartType__c     = \'' + partType + '\' ' +
                                        'AND Manufacturer__c = null) OR ';
            }

            if (hasDiscountManagement &&
                discountConditions != '' &&
                currentPurchaseOrder.Brand__c != null)
            {
                // function to populate the map
                retrieveDistributorCode(discountConditions);

                // now map has been populated
                // we need to update the List of select options of each wrapper
                for (OrderLineWrapper wrapper : mapIdOrderLineWrapper.values())
                {
                    wrapper.setDistributorCodeForWholeWrapper(mapKeyDiscountOptions);
                }

                System.debug('## mapIdOrderLineWrapper ' + mapIdOrderLineWrapper);
            }

            //AMI 04/10/18 : C-002045 - Advanced Case Management
            //             : setting isOriginalOfferErrored and isFinalOfferErrored
            if(mapOLIdOfferStatus.size() > 0){
                //looping in final wrapper
                for(OrderLineWrapper olWraper : mapIdOrderLineWrapper.values()){
                    if(olWraper.originalOrderLine != null && mapOLIdOfferStatus.containsKey(olWraper.originalOrderLine.id)){
                        olWraper.isOriginalOfferErrored = true;
                    }

                    if(olWraper.finalOrderLine != null && mapOLIdOfferStatus.containsKey(olWraper.finalOrderLine.id)){
                        olWraper.isFinalOfferErrored = true; 
                    }
                }
            }//end if mapOLIdOfferStatus.size() > 0
        }
    }

    // function to populate and alse update the mapKeyDiscountOptions
    public void retrieveDistributorCode(String discountConditions)
    {
        // Building the SOQL query
        // ABT - 03-JAN-2017 - C-001855 - Added DistributorCode__c != null
        String discountSOQL = 'SELECT Id, Active__c, Brand__c, Distributor__c, DistributorCode__c, PartType__c, Manufacturer__c, ASHighLimit__c ' +
                              'FROM   Discount__c ' +
                              'WHERE  Active__c = true ' +
                              'AND    DistributorCode__c != null ' +
                              'AND    Brand__c includes ( \'' + String.escapeSingleQuotes(currentPurchaseOrder.Brand__c) + '\' ) ' +
                              'AND    Distributor__c = \'' + String.escapeSingleQuotes(currentPurchaseOrder.Distributor__c) + '\' ' +
                              'AND    (' + discountConditions.removeEnd('OR ') + ') ' +
                              'ORDER BY DistributorCode__c ASC';

        System.debug('## Discount SOQL: ' + discountSOQL);
        System.debug('## Discount SOQL: ' + Database.Query(discountSOQL));

        // Running the soql query and also looping in each result to populate the map
        for (Discount__c discount : Database.Query(discountSOQL))
        {
            // add the discount to a map
            mapIdDiscount.put(discount.Id, discount);

            // check if the same combination exists    
            if (!mapKeyDiscountOptions.containsKey(discount.PartType__c + ';' + discount.Manufacturer__c))
            {
                mapKeyDiscountOptions.put(  discount.PartType__c + ';' +  discount.Manufacturer__c,
                                            new List<SelectOption>
                                            {
                                                new SelectOption('', '--None--'),
                                                new SelectOption(discount.Id, discount.DistributorCode__c)
                                            });
            }
            else
            {
                mapKeyDiscountOptions.get(discount.PartType__c + ';' +  discount.Manufacturer__c).add(new SelectOption(discount.Id, discount.DistributorCode__c));
            }
        }
        //18 JAN 2018  RLA  C-002958: MultiSourcing Belgium - Large choice of distributors for Bodyshops 
        List<SelectOption> lst = new list<SelectOption>();
        for (String s: mapKeyDiscountOptions.keyset()){
            //System.debug('@@ s: '+s);
            //System.debug('@@ mapKeyDiscountOptions: '+mapKeyDiscountOptions.get(s));
            lst =mapKeyDiscountOptions.get(s);
            lst.sort();
            mapKeyDiscountOptions.put(s, lst);
        }
        System.debug('## mapKeyDiscountOptions: ' + mapKeyDiscountOptions);        
    }

    // function to go to the edit mode
    public void setEditMode()
    {
        isEditable = true;
        hasErrors = false;
        isToastError = false;
    }
    //WCH 17/01/2019 : C-002620 - PO Unable to see individual parts in PO
    private boolean isOLUpdatable(Set<OrderLine__c> orderlinesIdToBeUpdated){
        for(OrderLine__c theCurrentOL : [Select LastModifiedDate from OrderLine__c where Id in :orderlinesIdToBeUpdated]){
            if(VFP04_LoadedTime<=theCurrentOL.LastModifiedDate) return false;
        }
        return true;
    } 

    // function to save all the changes made on the page to the web page
    public void saveAllChanges()
    {   
    
        //isEditable = false;
        hasErrors = false;
        isToastError = false;

        //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
        // Creating a savepoint
        SavePoint beforeDML = Database.setSavepoint();
        list<Offer__c> offToInsert = new list<Offer__c>();
        list<PartList__c> plToInsert = new list<PartList__c>();
        map<String, String> PLExtIdMap = new map<String, String>();
        map<String, Id> PlIdMap = new map<String, Id>();

        // List that will store the orderlines that needs to upserted
        List<OrderLine__c> orderLineToUpsertList = new List<OrderLine__c>();
        // List that will store the orderlines that needs to delete
        List<OrderLine__c> orderLineToDeleteList = new List<OrderLine__c>();

        // Map that stores the bundle wrapper id and its final
        // So that the mappings can be made with the bundle item
        Map<Id, OrderLine__c> mapBundleWrapperIdFinalOrderLine = new Map<Id, OrderLine__c>();

        // Purchase Order Max Delivery
        // It will store the maximum delivery of the order lines of the purchase order
        // Exceptions: For alternative -> only the alternative
        //           : For bundle      -> only bundle items
        Integer purchaseOrderMaxDelivery = 0;

        // Boolean to check if there is at least 1 delayed order line for the purchase order (for non-quotation only)
        Boolean isDelayedOrderLinePresent = false;

        // Variable to store the order lines that is delayed
        List<OrderLine__c> delayedOrderLineList = new List<OrderLine__c>();

        // ABT - 29-NOV-2016 - C-001459
        String rectifiedOrderLines      = '';

        Datetime estimatedDeliveryDatetime;

        //NPE 04/05/2022 C-004705: Set PO in Agency Mode to CLOSEDKO when all spare parts are set to returned (COMMENT CODE HERE- Logic moved to AP39AgencyMode & PurchaseOrderTriggerHandler))
        // //NPE 17/03/2022 C-003897: PO in agency mode does not change to CLOSEDKO after all delivered parts are set to returned
        // Boolean OLNotReturned = false;
        // set<id> setPOId = new set<id>();

        //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
        list<OrderLineWrapper> listAllOLWrapper = new list<OrderLineWrapper>();
        listAllOLWrapper.addAll(mapIdOrderLineWrapper.values());
        listAllOLWrapper.addAll(listnewOrderline);
        system.debug('## listAllOLWrapper : ' + listAllOLWrapper);
        system.debug('## mapIdOrderLineWrapper : ' + mapIdOrderLineWrapper);
        system.debug('## listnewOrderline : ' + listnewOrderline);


        // Loop in all the wrappers
        for (OrderLineWrapper currentWrapper : listAllOLWrapper)
        {
            if(currentWrapper.isPreselectedForOrder == hasPreselectedParts || (!hasPreselectedParts && currentWrapper.finalOrderLine.Id == null))
            {
                //check the type of the wrapper (Original, Final Original, Alternative, Bundle
                if (currentWrapper.isBundle)
                {
                    // the current wrapper is a bundle

                    // Variable that will store the bundle description (will be placed in the final order line)
                    String bundleDescription        = '';
                    Double finalTotalPrice          = 0;
                    Double finalAXATotalPrice       = 0;
                    Double finalBodyShopTotalPrice  = 0;
                    Double finalQuantity            = 0;
                    String maximumDelivery          = null;


                    // loop in the bundle items
                    // add to list
                    // also add validation check
                    // also capture the data for the final
                    for (BundleItemWrapper bundleItemWrap : currentWrapper.bundleItemList)
                    {
                        // Gathering data of the bundle items
                        bundleDescription       +=  bundleItemWrap.bundleItem.Type__c + ';' +
                                                    bundleItemWrap.bundleItem.PartNumber__c + ';' +
                                                    bundleItemWrap.bundleItem.Description__c + ';' +
                                                    bundleItemWrap.bundleItem.Manufacturer__c + ';' +
                                                    bundleItemWrap.bundleItem.CataloguePrice__c + '|';

                        finalTotalPrice         +=  calculateTotalPrice(bundleItemWrap.bundleItem);
                        finalAXATotalPrice      +=  calculateAXATotalPrice(bundleItemWrap.bundleItem);
                        finalBodyShopTotalPrice +=  calculateBodyShopTotalPrice(bundleItemWrap.bundleItem);
                        finalQuantity           +=  (bundleItemWrap.bundleItem.Quantity__c == null) ? 0 : bundleItemWrap.bundleItem.Quantity__c;

                        if(bundleItemWrap.bundleItem.ExpectedDeliveryDuration__c != null &&
                        (
                            maximumDelivery == null ||
                            (Integer.valueOf(bundleItemWrap.bundleItem.ExpectedDeliveryDuration__c) > Integer.valueOf(maximumDelivery))
                            ))
                        {
                            maximumDelivery = bundleItemWrap.bundleItem.ExpectedDeliveryDuration__c;
                        }

                        if( maximumDelivery != null &&
                            Integer.valueOf(maximumDelivery) > purchaseOrderMaxDelivery)
                        {
                            purchaseOrderMaxDelivery = Integer.valueOf(maximumDelivery);
                        }

                        //-----------------------------------------------------------------------------------------
                        //System.debug('checkDiscount>bundleItemWrap.bundleItem=' + bundleItemWrap.bundleItem);
                        if(checkCataloguePrice(isQuotation, bundleItemWrap.bundleItem, currentCountryInfo))
                        {
                            return;
                        }

                        if (checkDiscount(isQuotation, bundleItemWrap.bundleItem, currentCountryInfo)) {
                            return;
                        }
                        if(activateFamilyBrand && checkFamilyBrandValues(bundleItemWrap.bundleItem) && currentPurchaseOrder.Status__c=='DRAFTQUOTE') return;//WCH 04/07/2021 C-004160
                        if(!isQuotation)
                        {
                            // therefore we are in a non-quotation page
                            // We update the status of all the bundles to the one of the original order line
                            bundleItemWrap.bundleItem.DeliveryStatus__c = currentWrapper.originalOrderLine.DeliveryStatus__c;

                            // ABT - C-001459 - 08-NOV-2016
                            if( currentBusinessDay != null &&
                                currentPurchaseOrder.SLADeliveryEntryDate__c != null &&
                                bundleItemWrap.bundleItem.ExpectedDeliveryDuration__c != null)
                            {
                                //bundleItemWrap.bundleItem.EstimatedDeliveryDate__c = currentBusinessDay.addBusinessDays(Date.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c), Integer.valueOf(bundleItemWrap.bundleItem.ExpectedDeliveryDuration__c));
                                estimatedDeliveryDatetime = BusinessHours.add(currentBusinessDay.id,Datetime.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c),Integer.valueOf(bundleItemWrap.bundleItem.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                                bundleItemWrap.bundleItem.EstimatedDeliveryDate__c = Date.newInstance(estimatedDeliveryDatetime.year(), estimatedDeliveryDatetime.month(), estimatedDeliveryDatetime.day());
                                system.debug('##bundleItemWrap.bundleItem.EstimatedDeliveryDate__c: '+bundleItemWrap.bundleItem.EstimatedDeliveryDate__c);
                            }

                            if(!isDelayedOrderLinePresent &&
                                currentWrapper.originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELAYED)
                            {
                                isDelayedOrderLinePresent = true;
                            }

                            if(hasOrderLineChanged(bundleItemWrap.bundleItem, mapOrderLines.get(bundleItemWrap.bundleItem.Id)))
                            {
                                // we are InDelivery and there has been a change in the order line
                                rectifiedOrderLines += bundleItemWrap.bundleItem.Name + ', ';
                            }
                        }

                        orderLineToUpsertList.add(bundleItemWrap.bundleItem);
                    }

                    Double finalAXADiscount         = (finalTotalPrice > 0) ? ((finalTotalPrice - finalAXATotalPrice) / finalTotalPrice) * 100 : 0;
                    Double finalBodyShopDiscount    = (finalTotalPrice > 0) ? ((finalTotalPrice - finalBodyShopTotalPrice) / finalTotalPrice) * 100 : 0;

                    // check if it has already a final order line
                    if (currentWrapper.finalOrderLine == null)
                    {
                        // should create a final order line
                        currentWrapper.finalOrderLine = new OrderLine__c(
                                                                            OrderType__c                = 'FINAL',
                                                                            TechOLType__c = 'replacement', //RLA 18/06/2020 C-003700: IG - orderConfirmation
                                                                            Type__c                     = currentWrapper.originalOrderLine.Type__c,
                                                                            PurchaseOrder__c            = currentWrapper.originalOrderLine.PurchaseOrder__c,
                                                                            PartNumber__c               = currentWrapper.originalOrderLine.PartNumber__c,
                                                                            Description__c              = currentWrapper.originalOrderLine.Description__c,
                                                                            Manufacturer__c             = currentWrapper.originalOrderLine.Manufacturer__c,
                                                                            PartList__c                 = currentWrapper.originalOrderLine.PartList__c,
                                                                            VAT__c                      = currentWrapper.originalOrderLine.VAT__c,
                                                                            OriginalItem__c             = currentWrapper.originalOrderLine.Id,
                                                                            TechGeneratedFinal__c       = true,
                                                                            TechFinalTotalPrice__c      = finalTotalPrice,
                                                                            TechFinalTotalAxaPrice__c   = finalAXATotalPrice,
                                                                            TechFinalBSTotalPrice__c    = finalBodyShopTotalPrice,
                                                                            Quantity__c                 = finalQuantity,
                                                                            ExpectedDeliveryDuration__c = maximumDelivery,
                                                                            AXADiscount__c              = finalAXADiscount,
                                                                            BodyShopDiscount__c         = finalBodyShopDiscount,
                                                                            BundleItemsDescription__c   = bundleDescription,
                                                                            Suppliable__c               = currentWrapper.originalOrderLine.Suppliable__c,
                                                                            // ABT 30-MAR-2017 - C-001823
                                                                            PreselectedForOrder__c      = currentWrapper.originalOrderLine.PreselectedForOrder__c,
                                                                            AcceptedCheck__c            = currentWrapper.originalOrderLine.AcceptedCheck__c
                                                                            // TechExternalId__c = (currentWrapper.originalOrderLine.PurchaseOrder__r.Name + '-' + currentWrapper.originalOrderLine.PartNumber__c + '-' + currentWrapper.originalOrderLine.Description__c + '-' + currentWrapper.originalOrderLine.ID) //RLA 18/06/2020 C-003700: IG - orderConfirmation

                                                                        );
                    }
                    else
                    {
                        // final order line already exists
                        // so we need to update it
                        currentWrapper.finalOrderLine.TechGeneratedFinal__c         = true;
                        currentWrapper.finalOrderLine.TechFinalTotalPrice__c        = finalTotalPrice;
                        currentWrapper.finalOrderLine.TechFinalTotalAxaPrice__c     = finalAXATotalPrice;
                        currentWrapper.finalOrderLine.TechFinalBSTotalPrice__c      = finalBodyShopTotalPrice;
                        currentWrapper.finalOrderLine.Quantity__c                   = finalQuantity;
                        currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c   = maximumDelivery;
                        currentWrapper.finalOrderLine.AXADiscount__c                = finalAXADiscount;
                        currentWrapper.finalOrderLine.BodyShopDiscount__c           = finalBodyShopDiscount;
                        currentWrapper.finalOrderLine.BundleItemsDescription__c     = bundleDescription;
                        currentWrapper.finalOrderLine.Suppliable__c                 = currentWrapper.originalOrderLine.Suppliable__c;
                        // ABT 30-MAR-2017 - C-001823
                        currentWrapper.finalOrderLine.PreselectedForOrder__c        = currentWrapper.originalOrderLine.PreselectedForOrder__c;
                        currentWrapper.finalOrderLine.AcceptedCheck__c              = currentWrapper.originalOrderLine.AcceptedCheck__c;
                    }

                    if (!isQuotation)
                    {
                        // now the currentWrapper.finalOrderLine should not be null
                        currentWrapper.finalOrderLine.DeliveryStatus__c = currentWrapper.originalOrderLine.DeliveryStatus__c;

                        // ABT - C-001459 - 08-NOV-2016
                        if( currentBusinessDay != null &&
                            currentPurchaseOrder.SLADeliveryEntryDate__c != null &&
                            currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c != null)
                        {
                            //currentWrapper.finalOrderLine.EstimatedDeliveryDate__c = currentBusinessDay.addBusinessDays(Date.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c), Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c));
                            estimatedDeliveryDatetime = BusinessHours.add(currentBusinessDay.id,currentPurchaseOrder.SLADeliveryEntryDate__c,Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                            currentWrapper.finalOrderLine.EstimatedDeliveryDate__c = date.newInstance(estimatedDeliveryDatetime.year(),estimatedDeliveryDatetime.month(),estimatedDeliveryDatetime.day());
                        }
                    }

                    orderLineToUpsertList.add(currentWrapper.originalOrderLine);
                    orderLineToUpsertList.add(currentWrapper.finalOrderLine);
                    mapBundleWrapperIdFinalOrderLine.put(currentWrapper.originalOrderLine.Id, currentWrapper.finalOrderLine);
                }
                else if (currentWrapper.isFinalAltenative)
                {
                    system.debug('## if else here 1');
                    //System.debug('checkDiscount>currentWrapper.finalOrderLine=' + currentWrapper.finalOrderLine);
                    if(checkCataloguePrice(isQuotation, currentWrapper.finalOrderLine, currentCountryInfo))
                    {
                        return;
                    }

                    if (checkDiscount(isQuotation, currentWrapper.finalOrderLine, currentCountryInfo)) {
                        return;
                    }
                    if(activateFamilyBrand && checkFamilyBrandValues(currentWrapper.finalOrderLine) && currentPurchaseOrder.Status__c=='DRAFTQUOTE') return;//WCH 04/07/2021 C-004160
                    // Getting the max delivery for the purchase order
                    if( currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c != null &&
                        Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c) > purchaseOrderMaxDelivery)
                    {
                        purchaseOrderMaxDelivery = Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c);
                    }

                    if (!isQuotation)
                    {
                        // Set the status of the original order line to the final order line
                        currentWrapper.finalOrderLine.DeliveryStatus__c = currentWrapper.originalOrderLine.DeliveryStatus__c;

                        // ABT - C-001459 - 08-NOV-2016
                        if( currentBusinessDay != null &&
                            currentPurchaseOrder.SLADeliveryEntryDate__c != null &&
                            currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c != null)
                        {
                            //currentWrapper.finalOrderLine.EstimatedDeliveryDate__c = currentBusinessDay.addBusinessDays(Date.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c), Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c));
                            estimatedDeliveryDatetime = BusinessHours.add(currentBusinessDay.id,Datetime.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c),Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                            currentWrapper.finalOrderLine.EstimatedDeliveryDate__c = Date.newInstance(estimatedDeliveryDatetime.year(),estimatedDeliveryDatetime.month(),estimatedDeliveryDatetime.day());
                        }

                        if(!isDelayedOrderLinePresent &&
                            currentWrapper.originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELAYED)
                        {
                            isDelayedOrderLinePresent = true;
                        }

                        if(hasOrderLineChanged(currentWrapper.finalOrderLine, mapOrderLines.get(currentWrapper.finalOrderLine.Id)))
                        {
                            // we are InDelivery and there has been a change in the order line
                            rectifiedOrderLines += currentWrapper.finalOrderLine.Name + ', ';
                        }
                    }

                    //RLA 18/06/2020 C-003700: IG - orderConfirmation
                    if (currentWrapper.finalOrderLine.Id == null
                        && currentWrapper.finalOrderLine.OrderType__c == 'FINAL'
                        && String.isblank(currentWrapper.finalOrderLine.TechOLType__c)){

                            currentWrapper.finalOrderLine.TechOLType__c = 'replacement';
                            //RLA 14/10/2020 Replacements
                            currentWrapper.finalOrderLine.UpdateOLinfo__c = true;

                    }


                    // link to original is already done
                    // add both order line to the list that will upsert them
                    orderLineToUpsertList.add(currentWrapper.originalOrderLine);
                    orderLineToUpsertList.add(currentWrapper.finalOrderLine);
                }
                else if(currentWrapper.isFinalOriginal)
                {
                    if(currentWrapper.finalOrderLine.PartNumber__c == system.label.AdditionalPartNumber 
                        && (currentCountryInfo != null &&
                        (currentCountryInfo.DiscountException__c == null || (currentCountryInfo.DiscountException__c != null && !currentCountryInfo.DiscountException__c.contains(currentWrapper.finalOrderLine.PartNumber__c))) &&
                        (currentWrapper.finalOrderLine.CataloguePrice__c == null || currentWrapper.finalOrderLine.CataloguePrice__c == 0))){
                            //currentWrapper.finalOrderLine.PreselectedForOrder__c = false;
                            currentWrapper.finalOrderLine.AcceptedCheck__c = false;
                            currentWrapper.finalOrderLine.Suppliable__c = 'NO';
                    }
                    
                    //an original order line with OrderType = FINAL
                    //System.debug('checkDiscount>currentWrapper.finalOrderLine=' + currentWrapper.finalOrderLine);
                    if(checkCataloguePrice(isQuotation, currentWrapper.finalOrderLine, currentCountryInfo))
                    {
                        return;
                    }

                    if (checkDiscount(isQuotation, currentWrapper.finalOrderLine, currentCountryInfo)) {
                        return;
                    }
                    if(activateFamilyBrand && checkFamilyBrandValues(currentWrapper.finalOrderLine) && currentPurchaseOrder.Status__c=='DRAFTQUOTE') return;//WCH 04/07/2021 C-004160
                    // Getting the max delivery for the purchase order
                    if( currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c != null &&
                        Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c) > purchaseOrderMaxDelivery)
                    {
                        purchaseOrderMaxDelivery = Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c);
                    }

                    // ABT - C-001459 - 08-NOV-2016
                    if( !isQuotation)
                    {
                        if(currentBusinessDay != null &&
                            currentPurchaseOrder.SLADeliveryEntryDate__c != null &&
                            currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c != null)
                        {
                            //currentWrapper.finalOrderLine.EstimatedDeliveryDate__c = Date.valueOf(currentBusinessDay.addBusinessDays(Date.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c), Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c)));
                            estimatedDeliveryDatetime = Businesshours.add(currentBusinessDay.id,Date.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c),Integer.valueOf(currentWrapper.finalOrderLine.ExpectedDeliveryDuration__c)*10*60*60*1000L);
                            currentWrapper.finalOrderLine.EstimatedDeliveryDate__c = Date.newInstance(estimatedDeliveryDatetime.year(), estimatedDeliveryDatetime.month(), estimatedDeliveryDatetime.day());
                        }

                        // will already contain the updated delivery status
                        if(!isDelayedOrderLinePresent &&
                            currentWrapper.finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELAYED)
                        {
                            isDelayedOrderLinePresent = true;
                        }

                        // ABT - 29-NOV-2016 - C-001459
                        if(hasOrderLineChanged(currentWrapper.finalOrderLine, mapOrderLines.get(currentWrapper.finalOrderLine.Id)))
                        {
                            // we are InDelivery and there has been a change in the order line
                            rectifiedOrderLines += currentWrapper.finalOrderLine.Name + ', ';
                        }
                    } 

                    //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO 
                    if(currentWrapper.finalOrderLine.Id == null){

                        // ASE: 09/07/2018   C-002659 : Prices & Part Type to be sent to Coler 
                        currentWrapper.finalOrderLine.Rebate__c = (currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE') ? 0 : currentPurchaseOrder.Rebate__c;
                                
                        plToInsert.add(new PartList__c(  PartNumber__c = currentWrapper.finalOrderLine.PartNumber__c
                                                        ,Name = currentWrapper.finalOrderLine.Description__c
                                                        ,Description__c = currentWrapper.finalOrderLine.Description__c
                                                        ,Currency__c = 'EUR'
                                                        ,Assessment__c = currentPurchaseOrder.Assessment__c
                                                        ,Quantity__c = currentWrapper.finalOrderLine.Quantity__c
                                                        ,Price__c = currentWrapper.finalOrderLine.CataloguePrice__c
                                                        ,SelectedByBS__c = true
                                                        ,ProducerName__c = currentWrapper.finalOrderLine.Manufacturer__c
                                                        ,Type__c = currentWrapper.finalOrderLine.Type__c
                                                        ,TECH_OriginalPart__c = currentPurchaseOrder.Assessment__c + currentWrapper.finalOrderLine.PartNumber__c
                                                        ,TechCheckForSubstitute__c = currentWrapper.finalOrderLine.TechOLType__c == 'add' ? true : false
                                                      ));

                        

                        currentWrapper.finalOrderLine.PartList__r = new PartList__c(TECH_OriginalPart__c = currentPurchaseOrder.Assessment__c + currentWrapper.finalOrderLine.PartNumber__c);
                        currentWrapper.finalOrderLine.TechExternalId__c  = currentPurchaseOrder.Name + '-' + currentWrapper.finalOrderLine.PartNumber__c;
                        
                        PLExtIdMap.put(currentPurchaseOrder.Assessment__c + currentWrapper.finalOrderLine.PartNumber__c, currentWrapper.finalOrderLine.TechExternalId__c); 

                        /*offToInsert.add(new Offer__c(  PrerequisiteOrder__c  = currentPurchaseOrder.PrerequisiteOrder__c
                                                          ,OrderLine__r = new OrderLine__c(TechExternalId__c = currentPurchaseOrder.Name + '-' + currentWrapper.finalOrderLine.PartNumber__c)
                                                          ,Suppliable__c = true
                                                          , Accepted__c = 'YES'
                                                          ));*/
                    }
                    orderLineToUpsertList.add(currentWrapper.finalOrderLine);

                }
                else
                {
                    // original order line with OrderType = ORGINAL
                    //System.debug('checkDiscount>currentWrapper.originalOrderLine=' + currentWrapper.originalOrderLine);
                    if(checkCataloguePrice(isQuotation, currentWrapper.originalOrderLine, currentCountryInfo))
                    {
                        return;
                    }

                    if (checkDiscount(isQuotation, currentWrapper.originalOrderLine, currentCountryInfo)) {
                        return;
                    }
                    if(activateFamilyBrand && checkFamilyBrandValues(currentWrapper.originalOrderLine) && currentPurchaseOrder.Status__c=='DRAFTQUOTE') return;//WCH 04/07/2021 C-004160
                    // Getting the max delivery for the purchase order
                    if( currentWrapper.originalOrderLine.ExpectedDeliveryDuration__c != null &&
                        Integer.valueOf(currentWrapper.originalOrderLine.ExpectedDeliveryDuration__c) > purchaseOrderMaxDelivery)
                    {
                        purchaseOrderMaxDelivery = Integer.valueOf(currentWrapper.originalOrderLine.ExpectedDeliveryDuration__c);
                    }

                    if(!isDelayedOrderLinePresent &&
                        currentWrapper.originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELAYED)
                    {
                        isDelayedOrderLinePresent = true;
                    }

                    //convert original order line to a final type
                    currentWrapper.originalOrderLine.OrderType__c = 'FINAL';
                    orderLineToUpsertList.add(currentWrapper.originalOrderLine);

                }

                // Capturing all the order lines that needs to be delete
                orderLineToDeleteList.addAll(currentWrapper.orderLineToBeRemovedList);
            }
        }

        //WCH 17/01/2019 : C-002620 - PO Unable to see individual parts in PO
        Set<OrderLine__c> allOLsToBeModified = new Set<OrderLine__c>(orderLineToDeleteList);
        allOLsToBeModified.addAll(orderLineToUpsertList);
        if(!isOLUpdatable(allOLsToBeModified)){
            hasErrors = true;isToastError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.StaleInformation));
            return;
        }


        //NPE 17/03/2022 C-003897: PO in agency mode does not change to CLOSEDKO after all delivered parts are set to returned
        // if(currentPurchaseOrder.status__c ==  ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK){
        //     //AP39AgencyMode.getOLofPO(currentPurchaseOrder.id);
        // }


        // deleting the order lines first
        try
        {
            system.debug('## deleting orderlines try');
            if (orderLineToDeleteList.size() > 0)
            {
                // upserting the order lines
                // if does not have an id it will create the order line
                delete orderLineToDeleteList;
            }
        }
        catch (Exception ex)
        {
            system.debug('## deleting orderlines catch');
            
            addErrorMessage(ex, 'OrderLine__c');
            // stops the execution
            return;
        }

        //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO 
        try
        {
            system.debug('## inserting partlist try'+plToInsert);
            
            if (plToInsert.size() > 0)
            {
                // upserting the order lines
                // if does not have an id it will create the order line
                insert plToInsert;
            }
            system.debug('## inserting partlist try done');
        }
        catch (Exception ex)
        {
            system.debug('## inserting partlist catch');          
            addErrorMessage(ex, 'PartList__c');
            // stops the execution
            return;
        }

        system.debug('## PLExtIdMap: '+PLExtIdMap);  
        //07/06/2018 ASE 1.3 C-002313: button to add new orderline on PO 
        if(PLExtIdMap.size() > 0){
            for(PartList__c pl : [Select id, TECH_OriginalPart__c, PartNumber__c from PartList__c where TECH_OriginalPart__c in: PLExtIdMap.keySet()]){
                PlIdMap.put(currentPurchaseOrder.Name + '-' + pl.PartNumber__c, pl.Id); 
            }  
            system.debug('## PlIdMap: '+PlIdMap);          
        }

        // upserting the list
        try
        {
            system.debug('## upserting orderlines try');
            
            if (orderLineToUpsertList.size() > 0)
            {
                //07/06/2018 ASE 1.3 C-002313: button to add new orderline on PO 
                if(PlIdMap.size() > 0){
                    for(OrderLine__c ol : orderLineToUpsertList){
                        Boolean toUpdate = (ol.getPopulatedFieldsAsMap()).containsKey('TechExternalId__c');
                        if(toUpdate){
                            string olextId = currentPurchaseOrder.Name + '-' + ol.PartNumber__c;
                            if(ol.TechExternalId__c == olextId && PlIdMap.containsKey(olextId)){
                                ol.TechExternalId__c = currentPurchaseOrder.Name + '-' + PlIdMap.get(olextId);
                                system.debug('## olextId:'+ol.TechExternalId__c);
                            }
                        }
                    }
                }
                // upserting the order lines
                // if does not have an id it will create the order line
                upsert orderLineToUpsertList;
            }
            hasSaved = true;
            system.debug('## upserting orderlines try done');
        }
        catch (Exception ex)
        {
            system.debug('## upserting orderlines catch');
            //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
            Database.rollback(beforeDML);
          
            addErrorMessage(ex, 'OrderLine__c');            
            // stops the execution
            return;
        }

        //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO 
        try
        {
            system.debug('## inserting offers try'+offToInsert);
            
            //if (offToInsert.size() > 0)
            if (PlIdMap.size() > 0 && currentPurchaseOrder.PrerequisiteOrder__c != null){
                // upserting the order lines
                // if does not have an id it will create the order line
                for(Id plId : PlIdMap.values()){
                    offToInsert.add(new Offer__c(  PrerequisiteOrder__c  = currentPurchaseOrder.PrerequisiteOrder__c
                                                  ,OrderLine__r = new OrderLine__c(TechExternalId__c = currentPurchaseOrder.Name + '-' + plId)
                                                  ,Suppliable__c = true
                                                  , Accepted__c = 'YES'
                                                  ));
                }
                insert offToInsert;
            }

            system.debug('## inserting offers try done: ');
        }
        catch (Exception ex)
        {
            system.debug('## inserting offers catch');          
            addErrorMessage(ex, 'OrderLine__c');
            // stops the execution
            return;
        }

        // After inserting/updating all the orderlines
        // there is the link between a final for bundle and the original item

        // List that will store the orderlines to update
        List<OrderLine__c> bundleItemsToUpdate = new List<OrderLine__c>();
        for (Id wrapperId : mapBundleWrapperIdFinalOrderLine.keySet())
        {
            // checking if the id exists (is always present)
            if (mapIdOrderLineWrapper.containsKey(wrapperId))
            {
                // loop in the bundles and set its parent
                for (BundleItemWrapper bundleItemWrap : mapIdOrderLineWrapper.get(wrapperId).bundleItemList)
                {
                    bundleItemWrap.bundleItem.OriginalItem__c = mapBundleWrapperIdFinalOrderLine.get(wrapperId).Id;
                    bundleItemsToUpdate.add(bundleItemWrap.bundleItem);
                }
            }
        }

        try
        {
            system.debug('## upsert bundleItemsToUpdate try');
            if (bundleItemsToUpdate.size() > 0)
            {
                // updating the bundle items
                upsert bundleItemsToUpdate;
            }

        }
        catch (Exception ex)
        {
            system.debug('## upsert bundleItemsToUpdate catch');
            addErrorMessage(ex, 'OrderLine__c');
            // stops the execution
            return;
        }

        // Updating the purchase order
        try
        {
            system.debug('## updating PO try');
            // To avoid any regression for the Purchase Order a new variable is created using the required fields to update
            // AMI 18/08/17 : commenting MaximumDeliveryDuration__c --> now a rollup summary field
            PurchaseOrder__c purchaseOrderToUpdate = new PurchaseOrder__c(  Id                          = currentPurchaseOrder.Id/*,
                                                                            MaximumDeliveryDuration__c  = purchaseOrderMaxDelivery*/);

            // ABT - C-001459 - 08-NOV-2016
            if( !isQuotation &&
                currentBusinessDay != null &&
                currentPurchaseOrder.SLADeliveryEntryDate__c != null)
            {
                //purchaseOrderToUpdate.EstimatedDeliveryDate__c = currentBusinessDay.addBusinessDays(Date.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c), purchaseOrderMaxDelivery);
                estimatedDeliveryDatetime = BusinessHours.add(currentBusinessDay.id,Datetime.valueOf(currentPurchaseOrder.SLADeliveryEntryDate__c),(purchaseOrderMaxDelivery)*10*60*60*1000L);
                purchaseOrderToUpdate.EstimatedDeliveryDate__c = Date.newInstance(estimatedDeliveryDatetime.year(), estimatedDeliveryDatetime.month(), estimatedDeliveryDatetime.day());
            }

            //currentPurchaseOrder.MaximumDeliveryDuration__c = purchaseOrderMaxDelivery;
            if (isDelayedOrderLinePresent)
            {
                purchaseOrderToUpdate.DelayedCaseCreated__c = true;
            }

            update purchaseOrderToUpdate;
            system.debug('## updating PO try done');
        }
        catch (Exception ex)
        {
            system.debug('## updating PO catch ');
            addErrorMessage(ex, 'PurchaseOrder__c');
            // stops the execution
            return;
        }

        // if it is not in quotation
        // and there is order lines in delayed status
        // we should update the offer also
        if (!isQuotation)
        {
            // looping in the recently upserted order lines
            // and gathering the order line that has been delayed
            for (OrderLine__c ol : orderLineToUpsertList)
            {
                if (ol.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELAYED)
                {
                    delayedOrderLineList.add(ol);
                }
            }

            if (delayedOrderLineList.size() > 0)
            {
                // List of offers that needs to be updated
                List<Offer__c> offersToUpdateList = new List<Offer__c>();

                // looping in the offers selected
                // set the delayed status to it
                for (Offer__c currentOffer : [  SELECT  Id
                                                FROM    Offer__c
                                                WHERE   OrderLine__c IN : delayedOrderLineList])
                {
                    currentOffer.DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELAYED;
                    offersToUpdateList.add(currentOffer);
                }

                try
                {
                    system.debug('## updating offers try ');
                    if (offersToUpdateList.size() > 0)
                    {
                        update offersToUpdateList;
                    }
                    system.debug('## updating offers try done');
                }
                catch (Exception ex)
                {
                    system.debug('## updating offers catch ');
                    addErrorMessage(ex, 'Offer__c');
                    // stops the execution
                    return;
                }
            }

            // ABT - 29-NOV-2016 - C-001459
            if(rectifiedOrderLines != '')
            {
                // therefore a case needs to be created
                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', currentPurchaseOrder.TECH_AssessmentCountryCode__c, currentPurchaseOrder.Distributor__c, currentPurchaseOrder.Assessment__c, currentPurchaseOrder.Id, currentPurchaseOrder.PrerequisiteOrder__c, currentPurchaseOrder.Comment__c, UserInfo.getUserId(), '-OrderLineRectification');

                if(newCase != null)
                {
                    // Making a select to retrieve the latest value of the total on PO
                    PurchaseOrder__c updatedPurchaseOrder = [SELECT Id, TotalPrice__c, CurrencyIsoCode, name
                                                             FROM   PurchaseOrder__c
                                                             WHERE  Id =: currentPurchaseOrder.Id];

                    newCase.Description__c = String.format(newCase.Description__c,  new List<String>
                                                                                    {
                                                                                        rectifiedOrderLines.removeEnd(', '),
                                                                                        updatedPurchaseOrder.CurrencyIsoCode + ' ' + updatedPurchaseOrder.TotalPrice__c.format(),
                                                                                        currentPurchaseOrder.Name
                                                                                    });

                    try
                    {
                        insert newCase;
                    }
                    catch (Exception ex)
                    {
                        system.debug('## inserting cases catch ');
                        addErrorMessage(ex, 'Case__c');
                        // stops the execution
                        return;
                    }
                }
            }
        }

        //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
        if(hasSaved){
            listnewOrderline = new list<OrderLineWrapper>();
        }
        isEditable = false;
        system.debug('## retrieveOrderLines start:');
        retrieveOrderLines();
        
        //WCH 17/01/2019 : C-002620 - PO Unable to see individual parts in PO
        VFP04_LoadedTime = Datetime.now();
    }

    private Boolean checkDiscount(Boolean isQuotation, OrderLine__c currentOrderLine, CountryCodeInformationsMapping__c currentCountryInfo)
    {
        Boolean hasError = false;

        if (isQuotation && currentOrderLine.Suppliable__c == 'YES')
        {
            if (currentCountryInfo != null &&
                //currentCountryInfo.MinDiscountAS__c != 0 &&
                (currentCountryInfo.MinDiscountAS__c != null &&
                    (currentOrderLine.AXADiscount__c <= currentCountryInfo.MinDiscountAS__c ||
                        currentOrderLine.AXADiscount__c == null)
                ) &&
                !(currentCountryInfo.DiscountException__c != null &&
                currentOrderLine.PartNumber__c != null &&
                currentCountryInfo.DiscountException__c.contains(currentOrderLine.PartNumber__c)) &&
                String.isBlank(currentOrderLine.DistributorPrice__c)
                )
            {
               
                // Gives the error message
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,
                                    String.format(Label.ASDiscountErrorMsg, new List<String>
                                                        {
                                                            String.valueOf(currentCountryInfo.MinDiscountAS__c)
                                                        }
                                            )
                                    )
                            );

                // stops execution
                hasError = true;

                hasErrors = true;
                isToastError = true;
            }
            else if (currentCountryInfo != null &&
                        (currentCountryInfo.MinDiscountBS__c != null &&
                        currentCountryInfo.DefaultBSDiscount__c == null &&
                        (currentOrderLine.BodyShopDiscount__c <= currentCountryInfo.MinDiscountBS__c ||
                            currentOrderLine.BodyShopDiscount__c == null)
                        ) &&
                        !(  currentCountryInfo.DiscountException__c != null &&
                        currentOrderLine.PartNumber__c != null &&
                        currentCountryInfo.DiscountException__c.contains(currentOrderLine.PartNumber__c)) &&
                        String.isBlank(currentOrderLine.DistributorPrice__c)
                )
            {
                // Gives the error message
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,
                                    String.format(Label.BSDiscountErrorMsg, new List<String>
                                                        {
                                                            String.valueOf(currentCountryInfo.MinDiscountBS__c)
                                                        }
                                            )
                                    )
                            );

                // stops execution
                hasError = true;

                hasErrors = true;
                isToastError = true;
            }
        }

        return hasError;
    }

    public Double calculateTotalPrice(OrderLine__c ol)
    {
        return (((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) *
                ((ol.Quantity__c == null) ? 0 : ol.Quantity__c));
    }

    // ABT - 13-JAN-2016 - C-001856 - Added Rebate
    public Double calculateAXATotalPrice(OrderLine__c ol)
    {
        if(ol.AdditionalDiscountAmount__c != null)
        {
            return  ((((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) *
                    (1 - ((((ol.AXADiscount__c == null) ? 0 : ol.AXADiscount__c) + ((ol.TECH_ExtraAS__c == null) ? 0 : ol.TECH_ExtraAS__c)) / 100.0)) *
                    (1 - ((ol.Rebate__c == null) ? 0 : ol.Rebate__c) / 100.0)) *
                    ((ol.Quantity__c == null) ? 0 : ol.Quantity__c)) -
                    ((ol.AdditionalDiscountAmount__c == null) ? 0 : ol.AdditionalDiscountAmount__c);
        }
        else
        {
            return  (((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) *
                    (1 - ((((ol.AXADiscount__c == null) ? 0 : ol.AXADiscount__c) + ((ol.TECH_ExtraAS__c == null) ? 0 : ol.TECH_ExtraAS__c)) / 100.0)) *
                    (1 - ((ol.AdditionnalDiscount__c == null) ? 0 : ol.AdditionnalDiscount__c) / 100.0) *
                    (1 - ((ol.Rebate__c == null) ? 0 : ol.Rebate__c) / 100.0)) *
                    ((ol.Quantity__c == null) ? 0 : ol.Quantity__c);
        }
    }

    public Double calculateBodyShopTotalPrice(OrderLine__c ol)
    {
        if(ol.AdditionalDiscountAmount__c != null)
        {
            return ((((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) *
                        (1 - ((ol.BodyShopDiscount__c == null) ? 0 : ol.BodyShopDiscount__c) / 100.0)) *
                    ((ol.Quantity__c == null) ? 0 : ol.Quantity__c)) -
                    ((ol.AdditionalDiscountAmount__c == null) ? 0 : ol.AdditionalDiscountAmount__c);
        }
        else
        {
            return (((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) *
                        (1 - ((ol.BodyShopDiscount__c == null) ? 0 : ol.BodyShopDiscount__c) / 100.0) *
                        (1 - ((ol.AdditionnalDiscount__c == null) ? 0 : ol.AdditionnalDiscount__c) / 100.0))*
                    ((ol.Quantity__c == null) ? 0 : ol.Quantity__c);
        }
    }

    public String wrapperId {get; set;}
    public String wrapperIdFamily {get; set;}//WCH 15/05/2021 C-004160

    public void setWrapperSuppliable()
    {
        hasErrors = false;
        isToastError = false;

        if (mapIdOrderLineWrapper.containsKey(wrapperId))
        {
            mapIdOrderLineWrapper.get(wrapperId).setSuppliable();
        }
    }

    public void setWrapperUnsuppliable()
    {
        hasErrors = false;
        isToastError = false;
        
        if (mapIdOrderLineWrapper.containsKey(wrapperId))
        {
            mapIdOrderLineWrapper.get(wrapperId).setUnsuppliable();
        }
    }
    //WCH 15/05/2021 C-004160
    public void setWrapperBrand()
    {
        hasErrors = false;
        isToastError = false;
        
        if (mapIdOrderLineWrapper.containsKey(wrapperId))
        {
            mapIdOrderLineWrapper.get(wrapperId).setBrandOptions(wrapperIdFamily);
        }
    }

    public Integer bundleItemIndexToRemove {get; set;}

    // removing an order line on the page
    public void removeCurrentLine()
    {
        hasErrors = false;
        isToastError = false;

        if (mapIdOrderLineWrapper.containsKey(wrapperId))
        {
            mapIdOrderLineWrapper.get(wrapperId).removeOrderLine(bundleItemIndexToRemove);
        }
    }

    public void addNewOrderLine()
    {
        hasErrors = false;
        isToastError = false;

        if (mapIdOrderLineWrapper.containsKey(wrapperId))
        {
            mapIdOrderLineWrapper.get(wrapperId).addOrderLine();
        }
    }

    public void setAllSuppliableAndDelivery()
    {
        hasErrors = false;
        isToastError = false;
        // we need to know what is the first editable line
        // 1st line is obtained by looping in the wrapper
        // ignoring the orderlines that was already unsuppliable before any changes
        // how do we get that ?
        // take the id and check in the map mapOrderLines if it is suppliable or not
        OrderLine__c referenceOrderLine;

        for (OrderLineWrapper currentWrapper : mapIdOrderLineWrapper.values())
        {
            // Check if the originalOrderLine or finalOrderLine is not unsuppliable
            if( currentWrapper.isPreselectedForOrder == hasPreselectedParts &&
                ((currentWrapper.originalOrderLine != null &&
                 currentWrapper.originalOrderLine.Suppliable__c != 'NO') ||
                (currentWrapper.finalOrderLine != null &&
                 currentWrapper.finalOrderLine.Suppliable__c != 'NO'))
              )
            {
                // the wrapper is suppliable

                // now we are going to retrieve the 1st editable line
                referenceOrderLine = currentWrapper.getFirstEditableLineOfCurrentWrapper();

                // stop the loop
                break;
            }
        }

        if (referenceOrderLine != null)
        {
            // Now we have our reference order line
            // we need to apply it on all the editable lines of the page (not those in the section Not Available)
            for (OrderLineWrapper olWrapper : mapIdOrderLineWrapper.values())
            {
                if( olWrapper.isPreselectedForOrder == hasPreselectedParts &&
                    (olWrapper.originalOrderLine != null &&
                     olWrapper.originalOrderLine.Suppliable__c != 'NO') ||
                    (olWrapper.finalOrderLine != null &&
                     olWrapper.finalOrderLine.Suppliable__c != 'NO')
                  )
                {
                    olWrapper.setAllEditableLines(referenceOrderLine, hasDiscountManagement);
                }
            }
        }
    }

    public void validatePurchaseOrder(){
        //GBH 02.10.2020 - Prevent 
        if (isEditable && currentPurchaseOrder.TECH_AssessmentCountryCode__c  == 'DE') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.NotSavedBeforeValidation));
        } else {
            
        
            // ASE : 08/04/18 : Coler WS
            PurchaseOrder__c purchaseOrderToUpdate = new PurchaseOrder__c(  Id = currentPurchaseOrder.Id);
            //ASE: 09/07/2018: C-002659 : Prices & Part Type to be sent to Coler  - add Assessment__r.TECH_EntityCountryCode__c in query
            list<PurchaseOrder__c> currentPOList = [Select Distributor__r.OrderRequest__c, Distributor__r.DistributorConnected__c, Distributor__r.Type_of_Substitutes__c, Assessment__r.BodyShop__r.DistributorConnected__c, Assessment__r.BodyShop__r.isEligibleSourcing__c, Assessment__r.OrderOrigin__c, Assessment__r.TECH_EntityCountryCode__c, Status__c, techColerCalled__c, name,Assessment__r.isShoppingList__c from PurchaseOrder__c where id = :currentPurchaseOrder.Id];
            
            PurchaseOrder__c currentPO = null;

            if(currentPOList.size() > 0 ){
                currentPO = currentPOList[0];
            }

            
            if(/*ASE: 30/11/18 - C-002948 */currentPO != null && currentPO.Status__c == 'DRAFTQUOTE' && currentPO.techColerCalled__c == false ){

                // check if the purchase order can be validated
                if (!hasErrors && canBeValidated){
                    // change the status to RESPONDED
                    // Taking only the id and the status to do the update
                    
                    system.debug('## currentPO :'+currentPO );
                    if(currentPO != null && currentPO.Distributor__r.OrderRequest__c == 'OrderPO' 
                        // && currentPO.Distributor__r.DistributorConnected__c
                        && RestDistributorUtility.isConnectedDist(currentPO.Distributor__r.Type_of_Substitutes__c)
                        && RestDistributorUtility.canMakeOrderCall(currentPO.Distributor__r.Type_of_Substitutes__c)
                        && currentPO.Assessment__r.BodyShop__r.DistributorConnected__c
                        // C-002655 : Order should be sent to Coler for R3 Manual PO when BS.Distributor Connected=true
                        // ASE 23/11/18 : Add manual creation in ordeOrigin.
                        && (currentPO.Assessment__r.OrderOrigin__c == 'Order' 
                            //RLA 17/04/19 C-003193                        
                            || ((currentPO.Assessment__r.OrderOrigin__c == 'Legacy' || currentPO.Assessment__r.OrderOrigin__c == 'ManualCreation') 
                                && ! currentPO.Assessment__r.BodyShop__r.isEligibleSourcing__c))
                        ){
                        PurchaseOrder__c PO = VFC_RESTUpdatePOOrderLines.retrieveAssessment(currentPurchaseOrder.Id);

                        map <Id, PartList__c> partMap = new map <Id, PartList__c>();
                        String wsRequest = VFC_RESTUpdatePOOrderLines.buildRequest(PO, 'Order', partMap);

                        system.debug('## wsRequest order:'+wsRequest);

                        //RLA 28/11/2018 Case: C-002940 ValidatePO sur un NewAssessment pour BSR4 KO
                        if(wsRequest == System.label.NoPartsAccepted){
                            purchaseOrderToUpdate.Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
                            //RLA 01/01/2019 Case
                            //Update placement changed
                            try
                            {                
                                update purchaseOrderToUpdate;
                                //canRefresh = true;
                            }
                            catch (Exception e)
                            {
                                addErrorMessage(e, 'PurchaseOrder__c');
                            }
                        }
                        else if(wsRequest != null){
                            //RLA 01/01/2019 Case
                            //Boolean set to true if callout has been initiated
                            PurchaseOrder__c poUpdate = new PurchaseOrder__c(Id = PO.Id, techColerCalled__c = true);
                            update poUpdate;
                            // @future : Exceptions: You have uncommitted work pending. Please commit or rollback before calling out                    
                            System.enqueueJob(new AP40CallDistributorQueueable(wsRequest+ '-OrderType : PO-', new set <id>{PO.Id}, null));
                        
                        }                    
                    }
                    else{
                        purchaseOrderToUpdate.Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
                        //RLA 10/01/2019 Case
                        //Update placement changed
                        try
                        {            
                            update purchaseOrderToUpdate;
                            //canRefresh = true;
                        }
                        catch (Exception e)
                        {
                            addErrorMessage(e, 'PurchaseOrder__c');
                        }
                    }           
                    //Commented by RLA 10/01/2019
                    //try
                    //{
                    //    system.debug('## update purchaseOrderToUpdate:'+purchaseOrderToUpdate);
            
                    //    update purchaseOrderToUpdate;
                    canRefresh = true;
                    system.debug('@@ canRefresh: ' +canRefresh);

                    //    system.debug('## update purchaseOrderToUpdate done:'+purchaseOrderToUpdate);
                    //}
                    //catch (Exception e)
                    //{
                    //    system.debug('## saveAllChanges:');
                    //    addErrorMessage(e, 'PurchaseOrder__c');
                    //}
                }
            }
            /*ASE: 30/11/18 - C-002948 */
            else{         
                canRefresh = true;
                system.debug('@@ canRefresh: ' +canRefresh);
            } 
        }   
    }

    // function to get the number formatting of the user for the percentage displayed on the screen
    // public String getPercentageFormatString()
    // {
    //  Decimal value = 1000.10;
    //  String formattedValue = value.format();
    //  String thousandSep = formattedValue.substring(1,2);
    //  String decimalSep = formattedValue.substring(5,6);
    //  return '{0,number,#0'+decimalSep+'00 %}';
    // }

    // On change of the order line distributor code
    // update the order line fields
    public Integer bundleItemIndexChanged {get; set;}

    public void onSelectDistributorCode()
    {
        hasErrors = false;
        isToastError = false;

        if (hasDiscountManagement &&
            mapIdOrderLineWrapper.containsKey(wrapperId))
        {
            // passing the map of discount so that it can be inserted in the order line discount__r
            mapIdOrderLineWrapper.get(wrapperId).changeDistributorCode(bundleItemIndexChanged, mapIdDiscount);
        }
    }
    //WCH 16/05/2021 C-004160
    public void updateSpecificOrderLineBundleFB()
    {
        hasErrors = false;
        isToastError = false;

        if (activateFamilyBrand && mapIdOrderLineWrapper.containsKey(wrapperId)){
            mapIdOrderLineWrapper.get(wrapperId).setSelectedBundleFamilyBrand(bundleItemIndexChanged, wrapperIdFamily);
        }
    }
    // The function is used to update the select options when an order line
    // type or manufacturer is changed
    public void updateSpecificOrderLine()
    {
        hasErrors = false;
        isToastError = false;
        if(mapIdOrderLineWrapper.containsKey(wrapperId) && !String.isBlank(mapIdOrderLineWrapper.get(wrapperId).getSelectedOrderLinePartType(bundleItemIndexChanged)) && mapIdOrderLineWrapper.get(wrapperId).getSelectedOrderLinePartType(bundleItemIndexChanged)=='A'){
            String currentPOBrand=currentPurchaseOrder.Brand__c;
            mapIdOrderLineWrapper.get(wrapperId).setSelectedOrderLineBrand(bundleItemIndexChanged,currentPOBrand);
        }
        if (hasDiscountManagement &&
            mapIdOrderLineWrapper.containsKey(wrapperId))
        {
            // Getting the data required for that wraper id
            String partType     = mapIdOrderLineWrapper.get(wrapperId).getSelectedOrderLinePartType(bundleItemIndexChanged);
            String manufacturer = mapIdOrderLineWrapper.get(wrapperId).getSelectedOrderLineManufacturer(bundleItemIndexChanged);

            // check if the string are not null and that combination does not already exists in the map
            if (partType     != null &&
                !(  mapKeyDiscountOptions.containsKey(partType + ';' + manufacturer) &&
                    mapKeyDiscountOptions.containsKey(partType + ';' + null) ) )
            {
                String discountConditions = '';

                if( manufacturer != null &&
                    !mapKeyDiscountOptions.containsKey(partType + ';' + manufacturer))
                {
                    discountConditions +=   '(   PartType__c     = \'' + partType + '\' ' +
                                            'AND Manufacturer__c = \'' + String.escapeSingleQuotes(manufacturer) + '\') OR ';
                }

                if(!mapKeyDiscountOptions.containsKey(partType + ';' + null))
                {
                    discountConditions += '(     PartType__c     = \'' + partType + '\' ' +
                                            'AND Manufacturer__c = null) OR ';
                }

                retrieveDistributorCode(discountConditions);
            }

            // now we call the function to set the select option for the altered order line
            mapIdOrderLineWrapper.get(wrapperId).setDistributorCodeForSpecificOrderLine(bundleItemIndexChanged, mapKeyDiscountOptions);
        }
    }

    public Boolean hasOrderLineChanged(OrderLine__c updatedOrderLine, OrderLine__c oldOrderLine)
    {
        if  (   updatedOrderLine != null &&
                oldOrderLine != null &&
                (
                    updatedOrderLine.ExpectedDeliveryDuration__c    != oldOrderLine.ExpectedDeliveryDuration__c ||
                    updatedOrderLine.CataloguePrice__c              != oldOrderLine.CataloguePrice__c ||
                    (
                        !hasDiscountManagement &&
                        (
                            updatedOrderLine.AXADiscount__c         != oldOrderLine.AXADiscount__c ||
                            updatedOrderLine.BodyShopDiscount__c    != oldOrderLine.BodyShopDiscount__c
                        )
                    ) ||
                    (
                        hasDiscountManagement &&
                        (
                            updatedOrderLine.Discount__c            != oldOrderLine.Discount__c ||
                            updatedOrderLine.TECH_ExtraAS__c        != oldOrderLine.TECH_ExtraAS__c
                        )
                    )
                )
            )
        {
            return true;
        }

        return false;
    }

    // ARA 02/09/2020 : Button 'Order Confirmation' on PO
    public void callsendOrderConfirmation()
    {
        System.debug('---------------------------------- START callsendOrderConfirmation- ----------------------------------');
        // System.debug('@@ id check :' + currentPurchaseOrder.Id);

        
        
        // System.debug('@@ check currentPurchaseOrder: ' + currentPurchaseOrder);
        
        //call the future method if certain conditions are meet
         if ( currentPurchaseOrder != null &&  (
                                (
                                    ( currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO && 
                                      currentPurchaseOrder.Reason__c  ==  ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE
                                    ) ||
                                  currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_INDELIVERY
                                )
                                && String.isNotBlank(currentPurchaseOrder.TechInsuranceBroker__c) 
                                && system.label.InsBrokerName.contains(currentPurchaseOrder.TechInsuranceBroker__c)
         
                             ) 
                         &&

                             ( 
                                    (   currentPurchaseOrder.OrderConfirmationDate__c != null && string.isnotBlank(currentPurchaseOrder.OrderConfirmationErrorMe__c ) && 
                                        currentPurchaseOrder.OrderConfirmationErrorMe__c.containsIgnoreCase('Error')
                                    ) || 
                                    
                                    ( currentPurchaseOrder.OrderConfirmationDate__c == null && 
                                    string.isblank(currentPurchaseOrder.OrderConfirmationErrorMe__c)    
                                    ) 
                             )
             )
         
         {
            system.debug('@@ check if it got in');

            REST_OrderConfirmation.sendConfirmation(currentPurchaseOrder.Id, currentPurchaseOrder.Name);

            // system.debug('@@ end ');
         }

         else
         {
            System.debug('@@ check if its done automatically');
         }

         System.debug('---------------------------------- END callsendOrderConfirmation ----------------------------------');

    }
    // ARA 02/09/2020 : on page load check if the order confirmation is already done.

    public void onLoad(){


        if( currentPurchaseOrder.OrderConfirmationDate__c != null && string.isnotBlank(currentPurchaseOrder.OrderConfirmationErrorMe__c ) && 
            currentPurchaseOrder.OrderConfirmationErrorMe__c.containsIgnoreCase('OK')){
            OrderAutomatically = true;

        }
        set<Id> setadminId = ASPISConstants.getProfileIdAdmin();
        boolean connectedUserSystemAdmin = setadminId.size() > 0 ? setadminId.contains(Userinfo.getProfileId()) : false;
        system.debug('@@ connectedUserSystemAdmin'+connectedUserSystemAdmin);

        if( currentPurchaseOrder.Status__c == 'DRAFTQUOTE'
            &&currentPurchaseOrder.Distributor__r.OrderRequest__c == 'OrderR4' 
            // && currentPurchaseOrder.Distributor__r.DistributorConnected__c
            && RestDistributorUtility.isConnectedDist(currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c)
            // && currentPurchaseOrder.Assessment__r.BodyShop__r.DistributorConnected__c
            // && currentPurchaseOrder.Assessment__r.OrderOrigin__c == 'Order' 
            && String.isNotBlank(currentPurchaseOrder.wsErrorMessage__c)
            && currentPurchaseOrder.wsErrorMessage__c.contains('Order error reported')
            && currentPurchaseOrder.wsDate__c != null
            && connectedUserSystemAdmin
            ){
            canRelaunchOrderCall = true;
        }

     

        
    }

    //RLA 21/10/2020 C-004025 - IG - Re launch Order Call for EFA/NORA 
    public void callSendToDistributor()
    {
        System.debug('---------------------------------- START callSendToDistributor- ----------------------------------');

        
        //call the future method if certain conditions are meet
        
        system.debug('@@ check if it got in');
        Map<String,Object> mapInput = new map<String, Object>();
        mapInput.put('currentPurchaseOrder',currentPurchaseOrder);
        

        Map<String,Object> mapResponse = RESTCreateOrder.validatePurchaseOrder(mapInput);

        system.debug('@@ end ');
        

        

         System.debug('---------------------------------- END callSendToDistributor ----------------------------------');

    }

    public void addErrorMessage(Exception e, String objectType)
    {

        hasErrors = true;
        system.debug('## Exception: '+ e);    
        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
        {
            // error is caused by validation error
            isToastError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
        }
        else
        {
            Utils_ManageLogs.createLogFromException('VFC04_POManageOrderLines', objectType, e); 
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        
        }
    }

    private Boolean checkCataloguePrice(Boolean isQuotation, OrderLine__c currentOrderLine, CountryCodeInformationsMapping__c currentCountryInfo)
    {
        Boolean isOLInError = false;

        if ((isQuotation && currentOrderLine.Suppliable__c == 'YES') || (!isQuotation && currentOrderLine.Suppliable__c == 'YES' && currentOrderLine.AcceptedCheck__c))
        {
            if (currentCountryInfo != null &&
                (currentCountryInfo.DiscountException__c == null || (currentCountryInfo.DiscountException__c != null && !currentCountryInfo.DiscountException__c.contains(currentOrderLine.PartNumber__c))) &&
                (currentOrderLine.CataloguePrice__c == null || currentOrderLine.CataloguePrice__c == 0))
            {
                // Gives the error message
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.PriceShouldNotBeNullOrZero));

                hasErrors = true;
                isToastError = true;
                
                isOLInError = true;
            }
        }

        return isOLInError;
    }
    //WCH 04/07/2021 C-004160
    private Boolean checkFamilyBrandValues(OrderLine__c currentOrderLine)
    {
        Boolean isOLInError = false;
        if (currentOrderLine.Suppliable__c == 'YES' && currentPurchaseOrder.Status__c=='DRAFTQUOTE'){
            if (currentOrderLine.Type__c=='A' && String.isBlank(currentOrderLine.FamilyOfSparePart__c)){
                isOLInError = true;
            }else if(currentOrderLine.Type__c!='A' && (String.isBlank(currentOrderLine.FamilyOfSparePart__c) || String.isBlank(currentOrderLine.BrandOfSparePart__c))){
                isOLInError = true;
            }
            if(isOLInError){
            // Gives the error message
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.FamilyBrandOfSparePartRequired));
            hasErrors = true;isToastError = true;
            }
        }

        return isOLInError;
    }

    //14/FEB/2018 DUN 1.3 C-002313: button to add new orderline on PO
    public void addNewPlOlOff(){
        hasErrors = false;
        isToastError = false;
        OrderLine__c newOrderLineItem = new OrderLine__c( OrderType__c = 'FINAL',
                                                          PurchaseOrder__c = currentPurchaseOrder.Id,
                                                          Quantity__c = 1,
                                                          Suppliable__c = 'YES',
                                                          AcceptedCheck__c = (currentPurchaseOrder.PrerequisiteOrder__c != null ? true : false), 
                                                          OriginalItem__c = null,
                                                          PreselectedForOrder__c = (currentPurchaseOrder.PrerequisiteOrder__c != null ? true : false)

                                                          //WCH 30/05/2019 C-003130
                                                          , Type__c='A'
                                                          , Manufacturer__c=currentPurchaseOrder.Brand__c
                                                          , ExpectedDeliveryDuration__c='0'
                                                          , CataloguePrice__c=1
                                                          , TechOLType__c = 'add' //RLA 18/06/2020 C-003700: IG - orderConfirmation
                                                          
                                                          );
        listnewOrderline.add(new OrderLineWrapper(newOrderLineItem));
        //mapIdOrderLineWrapper.put(newOrderLineItem.Id, new OrderLineWrapper(newOrderLineItem));
        system.debug('## newOrderLineItem' + newOrderLineItem);
        system.debug('## mapIdOrderLineWrapper' + mapIdOrderLineWrapper);
        //oLToInsert.add(newOrderLineItem);
    }
    //WCH 19/02/2021 C-004194
    private Boolean verifyPermission(Id currentPOId)
    {
        List<UserRecordAccess> userRecordAccessList = [ SELECT  RecordId
                                                        FROM    UserRecordAccess
                                                        WHERE   RecordId =: currentPOId
                                                        AND     UserId =: UserInfo.getUserId()
                                                        AND     HasEditAccess = true];

        return (userRecordAccessList != null && userRecordAccessList.size() > 0);
    }
    //WCH 13/05/2021 C-004160
    public Map<String,List<String>> getFamilyBrand(String specificFamily)
    {   Map<String,List<String>> mapFamilyBrand = new Map<String,List<String>>();
        String fambranQuery = 'SELECT Family__c,Brand__c FROM Orderline_Family_Brand__mdt WHERE Active__c = true' + (String.isBlank(specificFamily)?'':(' and Family__c=\''+specificFamily+'\'')) + (Test.isRunningTest()?' and isTest__c=true ':' and isTest__c=false')+(' order by Family__c asc, brand__c asc');
        for(Orderline_Family_Brand__mdt currentOFB : Database.Query(fambranQuery)){
            if(mapFamilyBrand.containsKey(currentOFB.Family__c)){
                mapFamilyBrand.get(currentOFB.Family__c).add(currentOFB.Brand__c);
            }else{
                mapFamilyBrand.put(currentOFB.Family__c, new List<String>{currentOFB.Brand__c});
            }
        }
        return mapFamilyBrand;
    }
    public List<SelectOption> getFamilyOptionList(Map<String,List<String>> famBrand,String getWhat)
    {   List<SelectOption> optns = new List<Selectoption>();
        List<String> correctFBList = new List<String>();
        if(getWhat=='getFamily'){ 
            correctFBList=new list<string>(famBrand.keySet());
        }else{ 
            correctFBList=(famBrand==null || famBrand.isEmpty())?(new List<String>()):(famBrand.get((new list<string>(famBrand.keySet()))[0]));
        }
        for(String currentOFB : correctFBList){
            optns.add(new selectOption(currentOFB, currentOFB));
        }
        return optns;
    }

    // Wrapper class for order lines
    public class OrderLineWrapper
    {
        // the original order line
        public OrderLine__c originalOrderLine {get; set;}

        // workaround: not possible to see ol.DistributorPrice__c (Profile 'FR - Distributor' should not have access to the DistributorPrice object)
        public Boolean isDistributorPrice {get;set;}

        // the final order line
        public OrderLine__c finalOrderLine {get; set;}

        // the list of bundle items
        public List<BundleItemWrapper> bundleItemList {get; set;}

        // Distributor Select Option for originalOrderLine
        public List<SelectOption> originalOrderLineDistributorCodeOptions {get; set;}

        // Distributor Select Option for finalOrderLine
        public List<SelectOption> finalOrderLineDistributorCodeOptions {get; set;}

        //AMI 04/10/18 : C-002045 - Advanced Case Management
        //             : Boolean to know if associated offer original has status error
        public boolean isOriginalOfferErrored {get;set;}

        //AMI 04/10/18 : C-002045 - Advanced Case Management
        //             : Boolean to know if associated offer final has status error
        public boolean isFinalOfferErrored {get;set;}

        //AMI 04/10/18 : C-002045 - Advanced Case Management
        //             : New boolean to determine if status is managed
        public boolean isManaged{
            get{
                return ((originalOrderLine != null &&
                        originalOrderLine.DeliveryStatus__c == 'MANAGED') || 
                        (finalOrderLine != null &&
                        finalOrderLine.DeliveryStatus__c == 'MANAGED'));
            }
        } 
        //WCH 14/05/2021 C-004160
        public List<SelectOption> oLFamily {get; set;}
        public List<SelectOption> oLBrand {get; set;}

        // variable to know if the wrapper contains an original order line with OrderType = FINAL
        public Boolean isFinalOriginal
        {
            get
            {
                return (finalOrderLine != null &&
                        (finalOrderLine.OrderType__c == 'FINAL' ||
                         finalOrderLine.OrderType__c == 'SHIPPING COST') &&
                        finalOrderLine.OriginalItem__c == null);
            }
        }

        // variable to know if there is an alternative for the original order line
        public Boolean isFinalAltenative
        {
            get
            {
                return (finalOrderLine != null &&
                        finalOrderLine.OrderType__c == 'FINAL' &&
                        finalOrderLine.OriginalItem__c != null &&
                        bundleItemList.size() == 0);
            }
        }

        //RLA 27/11/2018 C-002782 CJP A'
        // variable to know if partlist has a discount record for virtual A'
        public Boolean hasDiscountVirtual
        {
            get
            {
                return (finalOrderLine != null &&                        
                        finalOrderLine.PartList__c != null &&
                        finalOrderLine.PartList__r.DiscountRecord__c != null 
                        //finalOrderLine.PartList__r.DiscountRecord__r.Rebate__c != null 
                        );
            }
        }

        // variable to know if the wrapper is a bundle one
        public Boolean isBundle
        {
            get
            {
                return (bundleItemList.size() > 0);
            }
        }

        // variable to get the value of row span for the Suppliable Column
        public Integer rowSpan
        {
            get
            {
                if (isFinalAltenative)
                {
                    return 2;
                }
                else if (isBundle)
                {
                    return (bundleItemList.size() + 1);
                }
                else
                {
                    return 1;
                }
            }
        }

        public Boolean isFinalOriginalDelivered
        {
            get
            {
                return (isFinalOriginal &&
                        finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELIVERED);
            }
        }

        public Boolean isFinalAlternativeDelivered
        {
            get
            {
                return (isFinalAltenative &&
                        finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELIVERED);
            }
        }

        // Supplied By AS (Not Quotation)
        public Boolean isSuppliedByAS
        {
            get
            {
                if(isFinalOriginal)
                {
                    return (finalOrderLine.Suppliable__c == 'YES' &&
                            finalOrderLine.AcceptedCheck__c &&
                            !((finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED ||
                               finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_RETURNED) &&
                             !finalOrderLine.IsCanceledByDistributor__c));
                }
                else
                {
                    return (originalOrderLine.Suppliable__c == 'YES' &&
                            originalOrderLine.AcceptedCheck__c &&
                            !((originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED ||
                               originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_RETURNED) &&
                             !originalOrderLine.IsCanceledByDistributor__c));
                }
            }
        }

        // Supplied By AS (Not Quotation)
        public Boolean isNotSelectedByDistributor
        {
            // Also added the part where a PO is canceled using the button Cancel Purchase Order
            get
            {
                if(isFinalOriginal)
                {
                    return (finalOrderLine.Suppliable__c == 'NO' ||
                            (finalOrderLine.Suppliable__c == null &&
                            finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED &&
                             finalOrderLine.IsCanceledByDistributor__c));
                }
                else
                {
                    return (originalOrderLine.Suppliable__c == 'NO' ||
                            (originalOrderLine.Suppliable__c == null &&
                            originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED &&
                             originalOrderLine.IsCanceledByDistributor__c));
                }
            }
        }

        // Canceled By BS (Not Quotation .... these types should not be present in Quotation)
        public Boolean isCanceledByBodyshop
        {
            get
            {
                if(isFinalOriginal)
                {
                    return (finalOrderLine.Suppliable__c == 'YES' &&
                            finalOrderLine.AcceptedCheck__c &&
                            (finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED ||
                             finalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_RETURNED) &&
                            !finalOrderLine.IsCanceledByDistributor__c);
                }
                else
                {
                    return (originalOrderLine.Suppliable__c == 'YES' &&
                            originalOrderLine.AcceptedCheck__c &&
                            (originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED ||
                             originalOrderLine.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_RETURNED) &&
                            !originalOrderLine.IsCanceledByDistributor__c);
                }
            }
        }

        // Not Selected By BS (Not Quotation .... these types should not be present in Quotation)
        public Boolean isNotSelectedByBodyshop
        {
            get
            {
                if(isFinalOriginal)
                {
                    return (finalOrderLine.Suppliable__c == 'YES' && !finalOrderLine.AcceptedCheck__c);
                }
                else
                {
                    return (originalOrderLine.Suppliable__c == 'YES' && !originalOrderLine.AcceptedCheck__c);
                }
            }
        }

        public Boolean isPreselectedForOrder
        {
            get
            {
                if(isFinalOriginal)
                {
                    return finalOrderLine.PreselectedForOrder__c;
                }
                else
                {
                    return originalOrderLine.PreselectedForOrder__c;
                }
            }
        }

        public List<OrderLine__c> orderLineToBeRemovedList;

        public OrderLineWrapper(OrderLine__c currentOL)
        {
            // Initialising the list
            bundleItemList              = new List<BundleItemWrapper>();
            orderLineToBeRemovedList    = new List<OrderLine__c>();

            //AMI 04/10/18 : C-002045 - Advanced Case Management
            //             : Boolean to know if associated offer original has status error
            isOriginalOfferErrored = false;

            //AMI 04/10/18 : C-002045 - Advanced Case Management
            //             : Boolean to know if associated offer final has status error
            isFinalOfferErrored = false;

            originalOrderLineDistributorCodeOptions = new List<SelectOption>
            {
                new SelectOption('', '--None--')
            };

            finalOrderLineDistributorCodeOptions    = new List<SelectOption>
            {
                new SelectOption('', '--None--')
            };
            
            //WCH 14/05/2021 C-004160
            oLFamily = new List<SelectOption>{ new SelectOption('', '--None--') };
            oLBrand = new List<SelectOption>{ new SelectOption('', '--None--') };
            

            if (currentOL.OrderType__c == 'ORIGINAL')
            {
                originalOrderLine = currentOL;

                isDistributorPrice = (String.isBlank(currentOL.DistributorPrice__c) ? false : true);
            }
            else if (currentOL.OrderType__c == 'FINAL' ||
                     currentOL.OrderType__c == 'SHIPPING COST')
            {
                finalOrderLine = currentOL;
                isDistributorPrice = (String.isBlank(currentOL.DistributorPrice__c) ? false : true);
            }
            else if (currentOL.OrderType__c == 'BUNDLEITEM')
            {
                bundleItemList.add(new BundleItemWrapper(currentOL));
            }
        }
        //WCH 15/05/2021 C-004160
        public void setBrandOptions(String olFam)
        {
            List<SelectOption> currentBrands = new List<SelectOption>();
            String fambranQuery = 'SELECT Family__c,Brand__c FROM Orderline_Family_Brand__mdt WHERE Active__c = true' + (String.isBlank(olFam)?' and Id=null':(' and Family__c=\''+olFam+'\'')) + (Test.isRunningTest()?' and isTest__c=true ':' and isTest__c=false') + (' order by Family__c asc, brand__c asc');

            for(Orderline_Family_Brand__mdt currentOFB : Database.Query(fambranQuery)){
                currentBrands.add(new selectOption(currentOFB.Brand__c, currentOFB.Brand__c));
            }
            if(String.isBlank(olFam)) currentBrands.add(new selectOption('', '--None--'));
            this.oLBrand=currentBrands;
        }
        public List<SelectOption> getFamilyOptions()
        {   Set<SelectOption> currentBrands = new Set<SelectOption>();
            String fambranQuery = 'SELECT Family__c FROM Orderline_Family_Brand__mdt WHERE Active__c = true' + (Test.isRunningTest()?' and isTest__c=true ':' and isTest__c=false') + (' order by Family__c asc, brand__c asc');
            for(Orderline_Family_Brand__mdt currentOFB : Database.Query(fambranQuery)){
                currentBrands.add(new selectOption(currentOFB.Family__c, currentOFB.Family__c));
            }
            return (new List<SelectOption>(currentBrands));
        }
        public void setOriginalItem(OrderLine__c originalOL)
        {
            if(originalOrderLine == null)
            {
                originalOrderLine = originalOL;

                isDistributorPrice = (String.isBlank(originalOL.DistributorPrice__c) ? false : true);
            }
        }

        public void setFinalItem(OrderLine__c finalOL)
        {
            finalOrderLine = finalOL;
            isDistributorPrice = (String.isBlank(finalOL.DistributorPrice__c) ? false : true);
        }
        //WCH 16/05/2021 C-004160
        public void addBundleItem(OrderLine__c currentOL, List<SelectOption> bundleFams, List<SelectOption> bundleBrands)
        {   BundleItemWrapper currentBW=new BundleItemWrapper(currentOL);
            currentBW.setBundleItemWrapperFB(bundleFams,bundleBrands);
            bundleItemList.add(currentBW);
        }

        public void setSuppliable()
        {
            if (originalOrderLine != null)
            {
                originalOrderLine.Suppliable__c = 'YES';

                if(originalOrderLine.PreselectedForOrder__c)
                {
                    originalOrderLine.AcceptedCheck__c = true;
                }
            }

            if (finalOrderLine != null)
            {
                finalOrderLine.Suppliable__c    = 'YES';

                if(finalOrderLine.PreselectedForOrder__c)
                {
                    finalOrderLine.AcceptedCheck__c = true;
                }
            }

            for (BundleItemWrapper bundleItemWrap : bundleItemList)
            {
                bundleItemWrap.bundleItem.Suppliable__c     = 'YES';

                if(bundleItemWrap.bundleItem.PreselectedForOrder__c)
                {
                    bundleItemWrap.bundleItem.AcceptedCheck__c = true;
                }
            }
        }

        public void setUnsuppliable()
        {
            if (originalOrderLine != null)
            {
                originalOrderLine.Suppliable__c = 'NO';

                if(originalOrderLine.PreselectedForOrder__c)
                {
                    originalOrderLine.AcceptedCheck__c = false;
                }
            }

            if (finalOrderLine != null)
            {
                finalOrderLine.Suppliable__c    = 'NO';

                if(finalOrderLine.PreselectedForOrder__c)
                {
                    finalOrderLine.AcceptedCheck__c = false;
                }
            }

            for (BundleItemWrapper bundleItemWrap : bundleItemList)
            {
                bundleItemWrap.bundleItem.Suppliable__c     = 'NO';

                if(bundleItemWrap.bundleItem.PreselectedForOrder__c)
                {
                    bundleItemWrap.bundleItem.AcceptedCheck__c = false;
                }
            }
        }

        public void removeOrderLine(Integer indexToRemove)
        {
            if (isFinalAltenative)
            {
                // The current instance has an alternative

                // if the alternative is already in the database add it to the list of
                // orderlines to be removed
                if (finalOrderLine.Id != null)
                {
                    orderLineToBeRemovedList.add(finalOrderLine);
                }

                finalOrderLine = originalOrderLine;
                finalOrderLineDistributorCodeOptions = originalOrderLineDistributorCodeOptions;

                // set the original item to final
                finalOrderLine.OrderType__c = 'FINAL';

                originalOrderLine = null;
                originalOrderLineDistributorCodeOptions = null;
            }
            else if (isBundle)
            {
                // The current instance is a bundle

                // using the index passed as parameter to remove the bundle
                if (bundleItemList[indexToRemove].bundleItem.Id != null)
                {
                    // adding the order line to remove in the
                    orderLineToBeRemovedList.add(bundleItemList[indexToRemove].bundleItem);
                }

                bundleItemList.remove(indexToRemove);

                // when there is only one bundle left it becomes an altenative
                if (bundleItemList.size() == 1)
                {
                    // Should become an altenative
                    // there was already a final order line add it in the list to be deleted
                    if (finalOrderLine != null &&
                        finalOrderLine.Id != null)
                    {
                        orderLineToBeRemovedList.add(finalOrderLine);
                    }


                    // should not delete the orderline in the bundle list
                    finalOrderLine                       = bundleItemList[0].bundleItem;
                    finalOrderLine.OrderType__c          = 'FINAL';
                    finalOrderLine.OriginalItem__c       = originalOrderLine.Id;
                    finalOrderLineDistributorCodeOptions = bundleItemList[0].distributorCodeOptions;

                    bundleItemList = new List<BundleItemWrapper>();
                }
            }
        }

        public void addOrderLine()
        {
            if (isBundle)
            {
                // The current wrapper is already a bundle
                // Nothing to do apart from adding new order line item

                OrderLine__c newOrderLineItem = new OrderLine__c(
                                                                    OrderType__c                = 'BUNDLEITEM',
                                                                    Type__c                     = originalOrderLine.Type__c,
                                                                    PurchaseOrder__c            = originalOrderLine.PurchaseOrder__c,
                                                                    PartNumber__c               = originalOrderLine.PartNumber__c,
                                                                    Description__c              = originalOrderLine.Description__c,
                                                                    Manufacturer__c             = originalOrderLine.Manufacturer__c,
                                                                    ExpectedDeliveryDuration__c = originalOrderLine.ExpectedDeliveryDuration__c,
                                                                    Quantity__c                 = originalOrderLine.Quantity__c,
                                                                    AXADiscount__c              = originalOrderLine.AXADiscount__c,
                                                                    BodyShopDiscount__c         = originalOrderLine.BodyShopDiscount__c,
                                                                    PartList__c                 = originalOrderLine.PartList__c,
                                                                    CataloguePrice__c           = originalOrderLine.CataloguePrice__c,
                                                                    PartList__r                 = originalOrderLine.PartList__r,
                                                                    VAT__c                      = originalOrderLine.VAT__c,
                                                                    Suppliable__c               = originalOrderLine.Suppliable__c,
                                                                    Discount__c                 = originalOrderLine.Discount__c,
                                                                    TECH_ExtraAS__c             = originalOrderLine.TECH_ExtraAS__c,
                                                                    // ABT 13-JAN-2017 - C-001856 - Added Rebate
                                                                    Rebate__c                   = originalOrderLine.Rebate__c,
                                                                    // ABT 30-MAR-2017 - C-001823
                                                                    PreselectedForOrder__c      = originalOrderLine.PreselectedForOrder__c,
                                                                    AcceptedCheck__c            = originalOrderLine.AcceptedCheck__c,
                                                                    BrandOfSparePart__c         = (String.isBlank(originalOrderLine.Type__c)?'':originalOrderLine.PurchaseOrder__r.Brand__c)
                                                                );
                //WCH 16/05/2021 C-004160
                BundleItemWrapper currentBundle = new BundleItemWrapper(newOrderLineItem, originalOrderLineDistributorCodeOptions);
                currentBundle.setBundleItemWrapperFB(getFamilyOptions(),new List<SelectOption>());
                bundleItemList.add(currentBundle);

            }
            else if (isFinalAltenative)
            {
                // The current wrapper is an alternative
                // So we need to take the final to the list
                // and add a new item to the list

                OrderLine__c newOrderLineItem = new OrderLine__c(
                                                                    OrderType__c                = 'BUNDLEITEM',
                                                                    Type__c                     = originalOrderLine.Type__c,
                                                                    PurchaseOrder__c            = originalOrderLine.PurchaseOrder__c,
                                                                    PartNumber__c               = originalOrderLine.PartNumber__c,
                                                                    Description__c              = originalOrderLine.Description__c,
                                                                    Manufacturer__c             = originalOrderLine.Manufacturer__c,
                                                                    ExpectedDeliveryDuration__c = originalOrderLine.ExpectedDeliveryDuration__c,
                                                                    Quantity__c                 = originalOrderLine.Quantity__c,
                                                                    AXADiscount__c              = originalOrderLine.AXADiscount__c,
                                                                    BodyShopDiscount__c         = originalOrderLine.BodyShopDiscount__c,
                                                                    PartList__c                 = originalOrderLine.PartList__c,
                                                                    CataloguePrice__c           = originalOrderLine.CataloguePrice__c,
                                                                    PartList__r                 = originalOrderLine.PartList__r,
                                                                    VAT__c                      = originalOrderLine.VAT__c,
                                                                    Suppliable__c               = originalOrderLine.Suppliable__c,
                                                                    Discount__c                 = originalOrderLine.Discount__c,
                                                                    TECH_ExtraAS__c             = originalOrderLine.TECH_ExtraAS__c,
                                                                    // ABT 13-JAN-2017 - C-001856 - Added Rebate
                                                                    Rebate__c                   = originalOrderLine.Rebate__c,
                                                                    // ABT 30-MAR-2017 - C-001823
                                                                    PreselectedForOrder__c      = originalOrderLine.PreselectedForOrder__c,
                                                                    AcceptedCheck__c            = originalOrderLine.AcceptedCheck__c,
                                                                    BrandOfSparePart__c         = (String.isBlank(originalOrderLine.Type__c)?'':originalOrderLine.PurchaseOrder__r.Brand__c)
                                                                );

                // updating the final to a bundle item
                finalOrderLine.OrderType__c     = 'BUNDLEITEM';
                finalOrderLine.OriginalItem__c  = null;

                //WCH 16/05/2021 C-004160
                BundleItemWrapper currentBundleFinal = new BundleItemWrapper(finalOrderLine, finalOrderLineDistributorCodeOptions);
                currentBundleFinal.setBundleItemWrapperFB(this.oLFamily,this.oLBrand);
                BundleItemWrapper currentBundleNewOL = new BundleItemWrapper(newOrderLineItem, originalOrderLineDistributorCodeOptions);
                currentBundleNewOL.setBundleItemWrapperFB(getFamilyOptions(),new List<SelectOption>());
                bundleItemList.add(currentBundleFinal);
                bundleItemList.add(currentBundleNewOL);

                finalOrderLine = null;
            }
            else if (isFinalOriginal)
            {
                // it in a Final Order line
                // variable to use : finalOrderLine
                originalOrderLine                       = finalOrderLine;
                originalOrderLine.OrderType__c          = 'ORIGINAL';
                originalOrderLineDistributorCodeOptions = finalOrderLineDistributorCodeOptions;

                finalOrderLine = new OrderLine__c(
                                                    OrderType__c                = 'FINAL',
                                                    Type__c                     = originalOrderLine.Type__c,
                                                    PurchaseOrder__c            = originalOrderLine.PurchaseOrder__c,
                                                    PartNumber__c               = originalOrderLine.PartNumber__c,
                                                    Description__c              = originalOrderLine.Description__c,
                                                    Manufacturer__c             = originalOrderLine.Manufacturer__c,
                                                    ExpectedDeliveryDuration__c = originalOrderLine.ExpectedDeliveryDuration__c,
                                                    Quantity__c                 = originalOrderLine.Quantity__c,
                                                    AXADiscount__c              = originalOrderLine.AXADiscount__c,
                                                    BodyShopDiscount__c         = originalOrderLine.BodyShopDiscount__c,
                                                    PartList__c                 = originalOrderLine.PartList__c,
                                                    CataloguePrice__c           = originalOrderLine.CataloguePrice__c,
                                                    VAT__c                      = originalOrderLine.VAT__c,
                                                    PartList__r                 = originalOrderLine.PartList__r,
                                                    OriginalItem__c             = originalOrderLine.Id,
                                                    Suppliable__c               = originalOrderLine.Suppliable__c,
                                                    Discount__c                 = originalOrderLine.Discount__c,
                                                    TECH_ExtraAS__c             = originalOrderLine.TECH_ExtraAS__c,
                                                    // ABT 13-JAN-2017 - C-001856 - Added Rebate
                                                    Rebate__c                   = originalOrderLine.Rebate__c,
                                                    // ABT 30-MAR-2017 - C-001823
                                                    PreselectedForOrder__c      = originalOrderLine.PreselectedForOrder__c,
                                                    AcceptedCheck__c            = originalOrderLine.AcceptedCheck__c,
                                                    //RLA 18/06/2020 C-003700: IG - orderConfirmation
                                                    TechOLType__c = originalOrderLine.TechOLType__c,
                                                    BrandOfSparePart__c         = (String.isBlank(originalOrderLine.Type__c)?'':originalOrderLine.PurchaseOrder__r.Brand__c)
                                                );
            }
            else
            {
                // it is an original orderline
                // variable to use : originalOrderLine
                finalOrderLine = new OrderLine__c(
                                                    OrderType__c                = 'FINAL',
                                                    Type__c                     = originalOrderLine.Type__c,
                                                    PurchaseOrder__c            = originalOrderLine.PurchaseOrder__c,
                                                    PartNumber__c               = originalOrderLine.PartNumber__c,
                                                    Description__c              = originalOrderLine.Description__c,
                                                    Manufacturer__c             = originalOrderLine.Manufacturer__c,
                                                    ExpectedDeliveryDuration__c = originalOrderLine.ExpectedDeliveryDuration__c,
                                                    Quantity__c                 = originalOrderLine.Quantity__c,
                                                    AXADiscount__c              = originalOrderLine.AXADiscount__c,
                                                    BodyShopDiscount__c         = originalOrderLine.BodyShopDiscount__c,
                                                    PartList__c                 = originalOrderLine.PartList__c,
                                                    CataloguePrice__c           = originalOrderLine.CataloguePrice__c,
                                                    VAT__c                      = originalOrderLine.VAT__c,
                                                    PartList__r                 = originalOrderLine.PartList__r,
                                                    OriginalItem__c             = originalOrderLine.Id,
                                                    Suppliable__c               = originalOrderLine.Suppliable__c,
                                                    Discount__c                 = originalOrderLine.Discount__c,
                                                    TECH_ExtraAS__c             = originalOrderLine.TECH_ExtraAS__c,
                                                    // ABT 13-JAN-2017 - C-001856 - Added Rebate
                                                    Rebate__c                   = originalOrderLine.Rebate__c,
                                                    // ABT 30-MAR-2017 - C-001823
                                                    PreselectedForOrder__c      = originalOrderLine.PreselectedForOrder__c,
                                                    AcceptedCheck__c            = originalOrderLine.AcceptedCheck__c,
                                                    BrandOfSparePart__c         = (String.isBlank(originalOrderLine.Type__c)?'':originalOrderLine.PurchaseOrder__r.Brand__c)
                                                );

                finalOrderLineDistributorCodeOptions = originalOrderLineDistributorCodeOptions;
            }
        }

        public OrderLine__c getFirstEditableLineOfCurrentWrapper()
        {
            if (isBundle)
            {
                // get the 1st line
                return bundleItemList[0].bundleItem;
            }
            else if (isFinalAltenative || isFinalOriginal)
            {
                // alternative and final original is the same variable
                return finalOrderLine;
            }
            else
            {
                // it is the original item
                return originalOrderLine;
            }
        }

        public void setAllEditableLines(OrderLine__c referenceOrderLine, Boolean discountManagement)
        {
            // NOTE: when discount management is true, this means that only expected delivery duration and suppliable should be replicated
            if (isBundle)
            {
                // loop in the bundle and set it to the reference order line
                for (BundleItemWrapper bundleItemWrap : bundleItemList)
                {
                    bundleItemWrap.bundleItem.ExpectedDeliveryDuration__c   = referenceOrderLine.ExpectedDeliveryDuration__c;
                    bundleItemWrap.bundleItem.Suppliable__c                 = referenceOrderLine.Suppliable__c;

                    if(!discountManagement)
                    {
                        bundleItemWrap.bundleItem.AXADiscount__c            = referenceOrderLine.AXADiscount__c;

                        if(!isDistributorPrice)
                        {
                            bundleItemWrap.bundleItem.BodyShopDiscount__c       = referenceOrderLine.BodyShopDiscount__c;
                        }
                    }
                }

                // update the suppliable of the original
                originalOrderLine.Suppliable__c                             = referenceOrderLine.Suppliable__c;
            }
            else if (isFinalAltenative || isFinalOriginal)
            {
                // set the finalOrderLine to the reference order line

                finalOrderLine.ExpectedDeliveryDuration__c  = referenceOrderLine.ExpectedDeliveryDuration__c;
                finalOrderLine.Suppliable__c                = referenceOrderLine.Suppliable__c;

                if(!discountManagement)
                {
                    finalOrderLine.AXADiscount__c           = referenceOrderLine.AXADiscount__c;

                    if(!isDistributorPrice)
                    {
                        finalOrderLine.BodyShopDiscount__c      = referenceOrderLine.BodyShopDiscount__c;
                    }
                }

                if(isFinalAltenative)
                {
                    // update the suppliable of the original
                    originalOrderLine.Suppliable__c         = referenceOrderLine.Suppliable__c;
                }
            }
            else
            {
                // set the original order line to the reference order line

                originalOrderLine.ExpectedDeliveryDuration__c   = referenceOrderLine.ExpectedDeliveryDuration__c;
                originalOrderLine.Suppliable__c                 = referenceOrderLine.Suppliable__c;

                if(!discountManagement)
                {
                    originalOrderLine.AXADiscount__c            = referenceOrderLine.AXADiscount__c;

                    if(!isDistributorPrice)
                    {
                        originalOrderLine.BodyShopDiscount__c       = referenceOrderLine.BodyShopDiscount__c;
                    }
                }
            }
        }

        public void setDistributorCodeForWholeWrapper(Map<String, List<SelectOption>> mapKeyDistributorOptions)
        {
            // only final orginal does not have an order line in originalOrderLine
            if (isFinalOriginal)
            {
                finalOrderLineDistributorCodeOptions = null;
                List<SelectOption> globalDiscountsList;
                if(finalOrderLine != null && //RLA 22/03/18 Case-2219
                    finalOrderLine.Type__c != null &&
                    mapKeyDistributorOptions.containsKey(finalOrderLine.Type__c + ';' + null))
                {
                    globalDiscountsList = mapKeyDistributorOptions.get(finalOrderLine.Type__c + ';' + null).clone();
                }

                // Check the final variable
                if (finalOrderLine != null && //RLA 22/03/18 Case-2219
                    finalOrderLine.Type__c != null &&
                    finalOrderLine.Manufacturer__c != null &&
                    mapKeyDistributorOptions.containsKey(finalOrderLine.Type__c + ';' + finalOrderLine.Manufacturer__c))
                {
                    finalOrderLineDistributorCodeOptions = mapKeyDistributorOptions.get(finalOrderLine.Type__c + ';' + finalOrderLine.Manufacturer__c).clone();

                    if(globalDiscountsList != null)
                    {
                        globalDiscountsList.remove(0);
                    }
                }

                if(finalOrderLineDistributorCodeOptions != null && globalDiscountsList != null)
                {
                    finalOrderLineDistributorCodeOptions.addAll(globalDiscountsList);
                }
                else if(finalOrderLineDistributorCodeOptions == null && globalDiscountsList != null)
                {
                    finalOrderLineDistributorCodeOptions = globalDiscountsList;
                }
                else if(finalOrderLineDistributorCodeOptions == null && globalDiscountsList == null)
                {
                    finalOrderLineDistributorCodeOptions = new List<SelectOption>
                    {
                        new SelectOption('', '--None--')
                    };
                }

            }
            else
            {
                // it could be a bundle or final alternative or an original
                // if it is a bundle or alternative set the selectoptions in their repective variable
                if (isBundle)
                {
                    // therefore only the bundles will need to have the options
                    for (BundleItemWrapper bundleItemWrap : bundleItemList)
                    {
                        bundleItemWrap.distributorCodeOptions = null;
                        List<SelectOption> globalDiscountsList;
                        if(mapKeyDistributorOptions.containsKey(bundleItemWrap.bundleItem.Type__c + ';' + null))
                        {
                            globalDiscountsList = mapKeyDistributorOptions.get(bundleItemWrap.bundleItem.Type__c + ';' + null).clone();
                        }

                        if (bundleItemWrap.bundleItem.Type__c != null &&
                            bundleItemWrap.bundleItem.Manufacturer__c != null &&
                            mapKeyDistributorOptions.containsKey(bundleItemWrap.bundleItem.Type__c + ';' + bundleItemWrap.bundleItem.Manufacturer__c))
                        {
                            bundleItemWrap.distributorCodeOptions = mapKeyDistributorOptions.get(bundleItemWrap.bundleItem.Type__c + ';' + bundleItemWrap.bundleItem.Manufacturer__c).clone();

                            if(globalDiscountsList != null)
                            {
                                globalDiscountsList.remove(0);
                            }
                        }

                        if(bundleItemWrap.distributorCodeOptions != null && globalDiscountsList != null)
                        {
                            bundleItemWrap.distributorCodeOptions.addAll(globalDiscountsList);
                        }
                        else if(bundleItemWrap.distributorCodeOptions == null && globalDiscountsList != null)
                        {
                            bundleItemWrap.distributorCodeOptions = globalDiscountsList;
                        }
                        else if(bundleItemWrap.distributorCodeOptions == null && globalDiscountsList == null)
                        {
                            bundleItemWrap.distributorCodeOptions = new List<SelectOption>
                            {
                                new SelectOption('', '--None--')
                            };
                        }
                    }
                }
                else if (isFinalAltenative)
                {
                    finalOrderLineDistributorCodeOptions = null;
                    List<SelectOption> globalDiscountsList;
                    if(finalOrderLine != null && //RLA 22/03/18 Case-2219
                        finalOrderLine.Type__c != null &&
                        mapKeyDistributorOptions.containsKey(finalOrderLine.Type__c + ';' + null))
                    {
                        globalDiscountsList = mapKeyDistributorOptions.get(finalOrderLine.Type__c + ';' + null).clone();
                    }

                    // Check the final variable
                    if (finalOrderLine != null && //RLA 22/03/18 Case-2219
                        finalOrderLine.Type__c != null &&
                        finalOrderLine.Manufacturer__c != null &&
                        mapKeyDistributorOptions.containsKey(finalOrderLine.Type__c + ';' + finalOrderLine.Manufacturer__c))
                    {
                        finalOrderLineDistributorCodeOptions = mapKeyDistributorOptions.get(finalOrderLine.Type__c + ';' + finalOrderLine.Manufacturer__c).clone();

                        if(globalDiscountsList != null)
                        {
                            globalDiscountsList.remove(0);
                        }
                    }

                    if(finalOrderLineDistributorCodeOptions != null && globalDiscountsList != null)
                    {
                        finalOrderLineDistributorCodeOptions.addAll(globalDiscountsList);
                    }
                    else if(finalOrderLineDistributorCodeOptions == null && globalDiscountsList != null)
                    {
                        finalOrderLineDistributorCodeOptions = globalDiscountsList;
                    }
                    else if(finalOrderLineDistributorCodeOptions == null && globalDiscountsList == null)
                    {
                        finalOrderLineDistributorCodeOptions = new List<SelectOption>
                        {
                            new SelectOption('', '--None--')
                        };
                    }
                }

                originalOrderLineDistributorCodeOptions = null;
                List<SelectOption> globalDiscountsListForOriginal;
                
                if(originalOrderLine != null && //RLA 22/03/18 Case-2219
                    originalOrderLine.Type__c != null &&
                   mapKeyDistributorOptions.containsKey(originalOrderLine.Type__c + ';' + null))
                {
                    globalDiscountsListForOriginal = mapKeyDistributorOptions.get(originalOrderLine.Type__c + ';' + null).clone();
                }
                // But whatever it is except from finalOrginal
                // it should have an original order line
               
                if (originalOrderLine != null && //RLA 22/03/18 Case-2219
                    originalOrderLine.Type__c != null &&
                    originalOrderLine.Manufacturer__c != null &&
                    mapKeyDistributorOptions.containsKey(originalOrderLine.Type__c + ';' + originalOrderLine.Manufacturer__c))
                {
                    originalOrderLineDistributorCodeOptions = mapKeyDistributorOptions.get(originalOrderLine.Type__c + ';' + originalOrderLine.Manufacturer__c).clone();

                    if(globalDiscountsListForOriginal != null)
                    {
                        globalDiscountsListForOriginal.remove(0);
                    }
                }

                if(originalOrderLineDistributorCodeOptions != null && globalDiscountsListForOriginal != null)
                {
                    originalOrderLineDistributorCodeOptions.addAll(globalDiscountsListForOriginal);
                }
                else if(originalOrderLineDistributorCodeOptions == null && globalDiscountsListForOriginal != null)
                {
                    originalOrderLineDistributorCodeOptions = globalDiscountsListForOriginal;
                }
                else if(originalOrderLineDistributorCodeOptions == null && globalDiscountsListForOriginal == null)
                {
                    originalOrderLineDistributorCodeOptions = new List<SelectOption>
                    {
                        new SelectOption('', '--None--')
                    };
                }
            }
        }

        public void changeDistributorCode(Integer bundleIndex, Map<Id, Discount__c> mapDiscount)
        {
            if (isBundle)
            {
                // check if the discount is not null (Other value than None is selected
                if (bundleItemList[bundleIndex].bundleItem.Discount__c != null)
                {
                    Discount__c selectedDiscount                            = mapDiscount.get(bundleItemList[bundleIndex].bundleItem.Discount__c);
                    bundleItemList[bundleIndex].bundleItem.Discount__r      = selectedDiscount;
                    bundleItemList[bundleIndex].bundleItem.AXADiscount__c   = selectedDiscount.ASHighLimit__c;
                }
                else
                {
                    bundleItemList[bundleIndex].bundleItem.Discount__r      = null;
                    bundleItemList[bundleIndex].bundleItem.AXADiscount__c   = 0.00;
                }
            }
            else if (isFinalAltenative || isFinalOriginal)
            {
                // should update finalOrderLine
                if (finalOrderLine.Discount__c != null)
                {
                    Discount__c selectedDiscount    = mapDiscount.get(finalOrderLine.Discount__c);
                    finalOrderLine.Discount__r      = selectedDiscount;
                    finalOrderLine.AXADiscount__c   = selectedDiscount.ASHighLimit__c;
                }
                else
                {
                    finalOrderLine.Discount__r      = null;
                    finalOrderLine.AXADiscount__c   = 0.00;
                }
            }
            else
            {
                // should update originalOrderLine
                if (originalOrderLine.Discount__c != null)
                {
                    Discount__c selectedDiscount     = mapDiscount.get(originalOrderLine.Discount__c);
                    originalOrderLine.Discount__r    = selectedDiscount;
                    originalOrderLine.AXADiscount__c = selectedDiscount.ASHighLimit__c;
                }
                else
                {
                    originalOrderLine.Discount__r    = null;
                    originalOrderLine.AXADiscount__c = 0.00;
                }
            }
        }

        public void setDistributorCodeForSpecificOrderLine(Integer bundleIndex, Map<String, List<SelectOption>> mapKeyDistributorOptions)
        {
            // part type and manufacturer can be changed only for alternative and bundles

            // Check if it is a bundle
            if (isBundle)
            {
                // Setting to null to facilitate last part
                bundleItemList[bundleIndex].distributorCodeOptions = null;

                List<SelectOption> globalDiscountsList;
                if(mapKeyDistributorOptions.containsKey(bundleItemList[bundleIndex].bundleItem.Type__c + ';' + null))
                {
                    globalDiscountsList = mapKeyDistributorOptions.get(bundleItemList[bundleIndex].bundleItem.Type__c + ';' + null).clone();
                }

                // therefore only the bundles will need to have the options
                if (bundleItemList[bundleIndex].bundleItem.Type__c != null &&
                    bundleItemList[bundleIndex].bundleItem.Manufacturer__c != null &&
                    mapKeyDistributorOptions.containsKey(bundleItemList[bundleIndex].bundleItem.Type__c + ';' + bundleItemList[bundleIndex].bundleItem.Manufacturer__c))
                {
                    bundleItemList[bundleIndex].distributorCodeOptions = mapKeyDistributorOptions.get(bundleItemList[bundleIndex].bundleItem.Type__c + ';' + bundleItemList[bundleIndex].bundleItem.Manufacturer__c).clone();

                    if(globalDiscountsList != null)
                    {
                        globalDiscountsList.remove(0);
                    }
                }

                if(bundleItemList[bundleIndex].distributorCodeOptions != null && globalDiscountsList != null)
                {
                    bundleItemList[bundleIndex].distributorCodeOptions.addAll(globalDiscountsList);
                }
                else if(bundleItemList[bundleIndex].distributorCodeOptions == null && globalDiscountsList != null)
                {
                    bundleItemList[bundleIndex].distributorCodeOptions = globalDiscountsList;
                }
                else if(bundleItemList[bundleIndex].distributorCodeOptions == null && globalDiscountsList == null)
                {
                    bundleItemList[bundleIndex].distributorCodeOptions = new List<SelectOption>
                    {
                        new SelectOption('', '--None--')
                    };
                }

                bundleItemList[bundleIndex].bundleItem.AXADiscount__c   = 0.00;
                bundleItemList[bundleIndex].bundleItem.Discount__c      = null;
            }
            else if (isFinalAltenative)
            {
                finalOrderLineDistributorCodeOptions = null;

                List<SelectOption> globalDiscountsList;
                if(finalOrderLine != null && //RLA 22/03/18 Case-2219
                    finalOrderLine.Type__c != null &&
                    mapKeyDistributorOptions.containsKey(finalOrderLine.Type__c + ';' + null))
                {
                    globalDiscountsList = mapKeyDistributorOptions.get(finalOrderLine.Type__c + ';' + null).clone();
                }

                // Check the final variable
                if (finalOrderLine != null && //RLA 22/03/18 Case-2219
                    finalOrderLine.Type__c != null &&
                    finalOrderLine.Manufacturer__c != null &&
                    mapKeyDistributorOptions.containsKey(finalOrderLine.Type__c + ';' + finalOrderLine.Manufacturer__c))
                {
                    finalOrderLineDistributorCodeOptions = mapKeyDistributorOptions.get(finalOrderLine.Type__c + ';' + finalOrderLine.Manufacturer__c).clone();

                    if(globalDiscountsList != null)
                    {
                        globalDiscountsList.remove(0);
                    }
                }

                if(finalOrderLineDistributorCodeOptions != null && globalDiscountsList != null)
                {
                    finalOrderLineDistributorCodeOptions.addAll(globalDiscountsList);
                }
                else if(finalOrderLineDistributorCodeOptions == null && globalDiscountsList != null)
                {
                    finalOrderLineDistributorCodeOptions = globalDiscountsList;
                }
                else if(finalOrderLineDistributorCodeOptions == null && globalDiscountsList == null)
                {
                    finalOrderLineDistributorCodeOptions = new List<SelectOption>
                    {
                        new SelectOption('', '--None--')
                    };
                }

                finalOrderLine.AXADiscount__c   = 0.00;
                finalOrderLine.Discount__c      = null;
            }
        }

        public String getSelectedOrderLinePartType(Integer bundleIndex)
        {
            // Check if it is a bundle
            if (isBundle)
            {
                return bundleItemList[bundleIndex].bundleItem.Type__c;
            }
            else if (isFinalAltenative || isFinalOriginal)
            {
                return finalOrderLine.Type__c;
            }
            else
            {
                return originalOrderLine.Type__c;
            }
        }

        public String getSelectedOrderLineManufacturer(Integer bundleIndex)
        {
            // Check if it is a bundle
            if (isBundle)
            {
                // therefore only the bundles will need to have the options
                return bundleItemList[bundleIndex].bundleItem.Manufacturer__c;
            }
            else if (isFinalAltenative || isFinalOriginal)
            {
                return finalOrderLine.Manufacturer__c;
            }
            else
            {
                return originalOrderLine.Manufacturer__c;
            }
        }
        
        //WCH 16/05/2021 C-004160
        public void setSelectedOrderLineBrand(Integer bundleIndex,String theBrand)
        {
            if (isBundle){ system.debug('isbundle');bundleItemList[bundleIndex].bundleItem.BrandOfSparePart__c=theBrand;}
            else if (isFinalAltenative || isFinalOriginal){finalOrderLine.BrandOfSparePart__c=theBrand;}
            else{ system.debug('is else');originalOrderLine.BrandOfSparePart__c=theBrand;}
        }
        public void setSelectedBundleFamilyBrand(Integer bundleIndex,String theSelectedFamily)
        {   System.debug('the selected family>>'+theSelectedFamily);
            List<SelectOption> currentBrands = new List<SelectOption>();
            String fambranQuery = 'SELECT Family__c,Brand__c FROM Orderline_Family_Brand__mdt WHERE Active__c = true' + (String.isBlank(theSelectedFamily)?' and Id=null':(' and Family__c=\''+theSelectedFamily+'\''))+ (Test.isRunningTest()?' and isTest__c=true ':'  and isTest__c=false')+(' order by Family__c asc, brand__c asc');

            for(Orderline_Family_Brand__mdt currentOFB : Database.Query(fambranQuery)){
                currentBrands.add(new selectOption(currentOFB.Brand__c, currentOFB.Brand__c));
            }
            if(String.isBlank(theSelectedFamily)) currentBrands.add(new selectOption('', '--None--'));
            // Check if it is a bundle
            if (isBundle){
                bundleItemList[bundleIndex].oLBrand=currentBrands;
            }
        }
    }

    // Wrapper class for each bundle item and its options of distributors code
    public class BundleItemWrapper
    {
        public OrderLine__c bundleItem {get; set;}
        public List<SelectOption> distributorCodeOptions {get; set;}

        //WCH 14/05/2021 C-004160
        public List<SelectOption> oLFamily {get; set;}
        public List<SelectOption> oLBrand {get; set;}

        public Boolean isBundleDelivered
        {
            get
            {
                return (bundleItem != null &&
                        bundleItem.DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELIVERED);
            }
        }

        public BundleItemWrapper(OrderLine__c ol)
        {
            bundleItem = ol;
            distributorCodeOptions = new List<SelectOption>
            {
                new SelectOption('', '--None--')
            };
            oLFamily = new List<SelectOption>{ new SelectOption('', '--None--') };//WCH 14/05/2021 C-004160
            oLBrand = new List<SelectOption>{ new SelectOption('', '--None--') };//WCH 14/05/2021 C-004160
        }

        public BundleItemWrapper(OrderLine__c ol, List<SelectOption> options)
        {
            bundleItem = ol;
            distributorCodeOptions = options;
            if(oLFamily==null) oLFamily = new List<SelectOption>{ new SelectOption('', '--None--') };//WCH 14/05/2021 C-004160
            if(oLBrand==null) oLBrand = new List<SelectOption>{ new SelectOption('', '--None--') };//WCH 14/05/2021 C-004160
        }

        //WCH 14/05/2021 C-004160
        public void setBundleItemWrapperFB(List<SelectOption> optionsFami, List<SelectOption> optionsBrands)
        {
            if(optionsFami!=null && optionsFami.size()>0) this.oLFamily.addAll(optionsFami);
            if(optionsBrands!=null && optionsBrands.size()>0) this.oLBrand = optionsBrands;
        }
    }
}