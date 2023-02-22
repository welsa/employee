/*
  ----------------------------------------------------------------------
  -- - Name          : VFC06_SOManageOffers
  -- - Author        : ABT
  -- - Description   : Controller VFP06_SOManageOffers
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 13-JUN-2016    ABT     1.0     Initial version
  -- 08-SEP-2016    ABT     1.1     Added refresh on saving when the Page is InDelivery
  -- 08-NOV-2016    ABT     1.2     C-001768 - Added Accept All button on the page
  -- 10-NOV-2016    ABT     1.3     C-001790 - Added Delivery_Status_Reason__c for offer
  -- 14-NoV-2017    DUN     1.4     C-002001 : exclude Invoicing cost so as to avoid resynchronisation 
  -- 10-JAN-2018    DUN     1.5     C-002135 : Agency Mode V2 
  -- 04-MAY-2018    DUN     1.6     C-002488 : Added OrderOrigin = ASPIS in condition
  -- 03-OCT-2018    AMI     1.7     C-002045 - Advance case management
  -- 20-NOV-2018    WCH     1.8     C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
  -- 08-JAN-2019    WCH     1.9     C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops > custom setting
  -- 14-AUG-2019    WCH     2.0     C-003348 - Include spare part cancellation reason in SO Delivery Slip
  -- 29-NOV-2019    WCH     2.1     C-003491 - Cancelation reason in the SO should be displayed in native langue for users in each country  
  -- 29-SEP-2020    WCH     2.2     C-003938 - NOB - Creation of Alpha-Scale Bodyshop Permission Set  
  -- 19-FEB-2021    WCH     2.3     C-004194 : Permission Set : Give AS visibility to Prefikar User  
  -- 10-JUN-2021    WCH     2.4     C-004160 : Create two new Family and Brand fields in Order Lines  
  -- 16-DEC-2021    NPE     2.5     C-004548: Not allow BS to change the "RETURNED" spare parts to "DELIVERED" when they use the "Conjunto Entregado" button
  -- 25-OCT-2022    RRJ     2.6     C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
  ----------------------------------------------------------------------
  -- NOTE 14-JUN-2016:
  -- Selected By Alpha Scale -> Suppliable__c = true & Accepted = YES/NULL
  -- Not Selected            -> Suppliable__c = true & Accepted = NO
  -- Not Available           -> Suppliable__c = false
  **********************************************************************
*/
public class VFC06_SOManageOffers
{
    public PrerequisiteOrder__c currentSalesOrder { get; set; }
    public Map<Id, Offer__c> mapOffers { get; set; }

    public Boolean canBeResponded { get; set; }
    public Boolean canBeSavedAndValidated {get; set;}
    public Boolean isPageReadOnly { get; set; }

    public Boolean canRefresh { get; set; }
    public Boolean isOrderPage { get; set; }

    // Boolean to know if the page to be displayed is the one for in delivery 
    // or in acceptance/eliminated
    public Boolean isInDelivery { get; set; }

    public Map<Id, OfferWrapper> mapOfferWrapper {get; set;}

    public List<SelectOption> offerTypeOptionsList {get; set;}

    public String previousOfferType;

    public String locale {get; set;}
    public String locale2 {get; set;}

    public Map<Id, Account> mapIdAccount {get; set;}
    public List<SelectOption> accountSelectOptionList {get; set;}

    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}

    //AMI 05/07/18 : Community Rollout
    //             : New boolean to detect if we are in community 
    //               to enable correct redirection
    public boolean isCommunityUser {get;set;}
    public string userType {get;set;}

    //AMI 03/10/18 : C-002045 - Advance case management
    //             : boolean used to check whether we are in advance case management
    public boolean isAdvancedCaseMgt {get;set;}

    //             : get cs info
    public map<string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = new map<string,CountryCodeInformationsMapping__c>();

    //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
    public static Set<Id> setParentOfferIds {get; set;}
    public static Set<String> partNumberSelectedByBS {get; set;}
    public boolean isMultiSourcing {get;set;}

    //WCH 13/05/2021 : C-004160 : Create two new Family and Brand fields in Order Lines
    public Boolean activateFamilyBrand {get;set;}
    
    //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
	public static Boolean isNONAXA {get;set;}

    //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
    public map<string,Manufacturer_reference__c> mapManufRef {get;set;}

    public VFC06_SOManageOffers(ApexPages.StandardController sc)
    {
        // Getting the current purchase order
        currentSalesOrder       = (PrerequisiteOrder__c) sc.getRecord();
        
        // Initialising the variables
        mapOffers               = new Map<Id, Offer__c>();
        mapOfferWrapper         = new Map<Id, OfferWrapper> ();
        offerTypeOptionsList    = new List<SelectOption>(); 
        canBeResponded          = false;
        canBeSavedAndValidated  = false;
        isPageReadOnly          = false;
        canRefresh              = false;
        isOrderPage             = String.isBlank(ApexPages.currentPage().getParameters().get('isOrderPage')) ? false : Boolean.valueOf(ApexPages.currentPage().getParameters().get('isOrderPage'));
        isInDelivery            = false;
        previousOfferType       = '';

        locale                  = UserInfo.getLocale()=='nl_BE'?'fr_BE':UserInfo.getLocale();//vsu Use locale fr (Belgium) for date format 
        locale2                 = UserInfo.getLocale()=='nl_BE'?'nl-BE':UserInfo.getLocale();//vsu Added for locale Dutch (Belgium)
        system.debug('##UserInfo.getLocale(): '+UserInfo.getLocale());
        hasErrors               = false;
        isToastError            = false;

        isCommunityUser         = false;
        userType                = '';

        //WCH 09/01/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        partNumberSelectedByBS  = new Set<String>();
        setParentOfferIds       = new Set<Id>();
        isMultiSourcing         = false;

        //AMI 03/10/18 : C-002045 - Advance case management
        //             : boolean used to check whether we are in advance case management
        isAdvancedCaseMgt       = false;

        //             : get cs info
        allConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

        activateFamilyBrand         = false;//WCH 13/05/2021 C-004160
        //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
        mapManufRef = new map<string,Manufacturer_reference__c>();
        
        if(currentSalesOrder.Id != null)
        {
            //AMI 05/07/18 : Community Rollout
            string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
            string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

            //             : get connected user info
            for(User us : [Select id,Profile.UserLicense.Name,Profile.Name 
                            from User 
                            where Id=: UserInfo.getUserId()]){
                if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains((us.Profile.UserLicense.Name).toLowerCase())){
                    isCommunityUser = true;
                }

                if((us.Profile.Name.toLowerCase()).contains('order') || system.label.R4BSProfileNameCommunityPrefikar.equals(us.Profile.Name)/*  WCH 29/09/2020 C-3938 */){
                    userType = 'R4';
                }else {
                    userType = 'R3';
                }
            }

            //AMI 03/10/18 : C-002045 - Advance case management
            //             : boolean used to check whether we are in advance case management
            if(currentSalesOrder.TECH_BodyshopCountryCode__c != null &&
                allConfigCountryCodeInfo.containsKey(currentSalesOrder.TECH_BodyshopCountryCode__c) && 
                allConfigCountryCodeInfo.get(currentSalesOrder.TECH_BodyshopCountryCode__c).AdvancedCaseManagement__c){

                    isAdvancedCaseMgt = true;
            }
            //WCH 14/05/2021 C-004160
            if(currentSalesOrder.TECH_BodyshopCountryCode__c != null && allConfigCountryCodeInfo.containsKey(currentSalesOrder.TECH_BodyshopCountryCode__c) && allConfigCountryCodeInfo.get(currentSalesOrder.TECH_BodyshopCountryCode__c).activateOLFamilyBrand__c){
                activateFamilyBrand=true;
            }

            // check id the record type of the currentSalesOrder is InDelivery
            if( currentSalesOrder.RecordTypeId == Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId() ||
                currentSalesOrder.RecordTypeId == Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('Eliminated').getRecordTypeId())
            {
                isInDelivery = true;

                // Checks if the page should be in read only mode
                isPageReadOnly = (currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED &&
                                  !(Label.PROFILEADMINIDS.contains(UserInfo.getProfileId()))
                                 ) ? true : false;
            }

            // Getting the list of offers fot that sales order
            if (!isInDelivery)
            {
                retrieveOffers();
            }
            else
            {
                retrieveOffersInDelivery();
            }

            retrieveParentAndChildrenAccounts();

            //WCH 19/02/2021 C-004194
            if (currentSalesOrder.Id != null){
                isPageReadOnly = !(verifyPermission(currentSalesOrder.Id));
            }
        }
    }
    //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
    public list<Manufacturer_reference__c> getBrandFamily(set<string> lstpartNumber){
        String query='SELECT Id, Name, RecordType.Name, Brand__c, Sub_family__c, Manufacturer_ID__c FROM Manufacturer_reference__c WHERE ';
        if(lstpartNumber.size()>0){
            for(string item: lstpartNumber){
                query+='Manufacturer_ID__c = \'' + item+ '\' OR ';
            }
            system.debug('Querry = '+query);
            return database.query(query.removeEnd(' OR '));
        }
        else{
            return null;
        }
    }

    // function to get all the offers of the sales order and populate the map of wrapper
    public void retrieveOffers()
    {

        //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
        list<Manufacturer_reference__c> lstManuRef = new list<Manufacturer_reference__c> ();
	    set<String> setPartNumber  = new set<String> ();

        // Map containing the values of the picklist and its translated values
        Map<String, String> mapTypeValues = new Map<String, String>();

        for (Schema.PicklistEntry pe: Offer__c.Type__c.getDescribe().getPicklistValues()) 
        {
            mapTypeValues.put(pe.getValue(), pe.getLabel());
        }

        mapOfferWrapper      = new Map<Id, OfferWrapper>();
        offerTypeOptionsList = new List<SelectOption>();

        //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        Map <String,Id> PartNumberNotSelectedMapOfferId = new Map <String,Id> ();
        Set <String> PartNumberNotSelected = new Set <String> ();
        isMultiSourcing=currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) ? ((CountryCodeInformationsMapping__c.getall().containsKey(ASPISConstants.TECH_EntityCountryCodeBE) && CountryCodeInformationsMapping__c.getall().get(ASPISConstants.TECH_EntityCountryCodeBE).ActivateMultisourcing__c)?true:false) : false;

        // checks if there is a sales order
        if (currentSalesOrder.Id != null)
        {
            Set<String> finalOfferTypeSet = new Set<String>();

            //DUN 14/12/2017 case C-002001 : added Type__c != 'Invoicing' 
            //DUN 10/01/2018  C-002135 agency Mode V2 adding field AgencyMode__c from PurchaseOrder
            for (Offer__c offer :[SELECT    Id, Name, Suppliable__c, Accepted__c, Type__c, ParentOffer__c, Distributor__c, Description__c,
                                            Manufacturer__c, ExpectedDeliveryDuration__c, CataloguePrice__c, Quantity__c, Total__c, 
                                            Discount__c, Price__c, BSTotalPrice__c, OrderLine__r.PartList__r.Compliance__c, OrderType__c,
                                            DeliveryStatus__c, FinalType__c, OriginalPartNumber__c, OriginalType__c, OriginalDescription__c,
                                            OriginalManufacturer__c, OriginalCatalogPrice__c, TargetedDistributor__c,
                                            PartNUmber__c, CancelReason__c, ExpectedDeliveryDate__c,
                                            Prerequisiteorder__c, OrderLine__c, IsCanceledByBodyshop__c,RealDeliveryDate__c,
                                            Prerequisiteorder__r.Assessment__r.TECH_EntityCountryCode__c,
                                            Prerequisiteorder__r.Assessment__r.EntityCode__c,
                                            AgencyMode__c,tolabel(OrderLine__r.CancelReason__c),Orderline__r.FamilyOfSparePart__c,Orderline__r.BrandOfSparePart__c/* WCH 14/08/2019 C-003348, WCH 29/11/2019 C-003491, WCH 10/06/2021 C-004160*/
                                  FROM      Offer__c
                                  WHERE     Prerequisiteorder__c = :currentSalesOrder.Id   
                                  AND       Type__c != 'Invoicing'
                                  ORDER BY  Name ASC])
            {
                // Get the types of the final offers in the set
                // the set will be used to build the select option afterwards
                if (offer.OrderType__c == 'FINAL' &&
                    offer.Type__c      != null)
                {
                    finalOfferTypeSet.add(offer.Type__c);
                }

                //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
                if(offer.PartNUmber__c != null){
                    setPartNumber.Add(string.valueof(offer.PartNUmber__c));
                }

                // To add wrapper depending on its type
                if (offer.ParentOffer__c != null)
                {
                    // is a child offer

                    // Checks if a wrapper of that id already exists
                    if (mapOfferWrapper.containsKey(offer.ParentOffer__c))
                    {
                        // add the child offer to the existing wrapper
                        mapOfferWrapper.get(offer.ParentOffer__c).addChildOffer(offer);
                    }
                    else
                    {
                        // put a new wrapper in the map
                        mapOfferWrapper.put(offer.ParentOffer__c, new OfferWrapper(offer));
                    }
                }
                else
                {
                    // is the parent offer

                    // Checks if a wrapper of that id already exists
                    if (mapOfferWrapper.containsKey(offer.Id))
                    {
                        // add the parent offer to the existing wrapper
                        mapOfferWrapper.get(offer.Id).setParentOffer(offer);
                    }
                    else
                    {
                        // put a new wrapper in the map
                        mapOfferWrapper.put(offer.Id, new OfferWrapper(offer));

                        //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                        if(mapOfferWrapper.get(offer.Id).isSelectedByBodyShop){
                            partNumberSelectedByBS.add(offer.PartNUmber__c);
                        }else{
                            PartNumberNotSelectedMapOfferId.put(offer.PartNUmber__c,offer.Id);
                            PartNumberNotSelected.add(offer.PartNUmber__c);
                        }
                    }
                    
                    //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    if(!(currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) && isMultiSourcing)){
                        setParentOfferIds.add(offer.Id);
                    }
                }
                //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
                isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => offer.Prerequisiteorder__r.Assessment__r.TECH_EntityCountryCode__c, 'entity' => offer.Prerequisiteorder__r.Assessment__r.EntityCode__c, 'fromProcess' => 'Order'});
            }
            //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
            lstManuRef = getBrandFamily(setPartNumber);
            if(lstManuRef != null){
                for(Manufacturer_reference__c mr : lstManuRef){
                    //string s1 = mr.Name;
                    mapManufRef.put(mr.Manufacturer_ID__c,mr);
                }
            }

            //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            if(currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) && isMultiSourcing){
                PartNumberNotSelectedMapOfferId.keyset().removeAll(new List<String>(partNumberSelectedByBS));
                setParentOfferIds.addAll(PartNumberNotSelectedMapOfferId.values());
            }
            for(Id currentOfferId:setParentOfferIds){
                mapOfferWrapper.get(currentOfferId).showInNotSelectedSection=true;
            }

            // Convert the set of offer types and then sort it
            List<String> sortedOfferTypeList = new List<String>(finalOfferTypeSet);
            sortedOfferTypeList.sort();

            // if the offertype is null set the 1st type in the list as a default value
            if(currentSalesOrder.OfferType__c == null &&
               sortedOfferTypeList.size() > 0)
            {
                currentSalesOrder.OfferType__c = sortedOfferTypeList[0];
            }

            // Capture the previous offer type
            previousOfferType = currentSalesOrder.OfferType__c;

            // Loop in the finalOfferTypeSet to create the SelectOptions of the Offer Type View
            for (String typeOption : sortedOfferTypeList)
            {
                offerTypeOptionsList.add(new SelectOption(typeOption, (mapTypeValues.containsKey(typeOption)) ? mapTypeValues.get(typeOption) : typeOption));
            }
            System.debug('## finalOfferTypeSet : ' + finalOfferTypeSet);

            canSalesOrderBeResponded();
        }

        
        System.debug('## mapOfferWrapper : ' + mapOfferWrapper);
        System.debug('## offerTypeOptionsList : ' + offerTypeOptionsList);
    }

    // function to get only the accepted offers of the sales order
    public void retrieveOffersInDelivery()
    {

        //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
        list<Manufacturer_reference__c> lstManuRef = new list<Manufacturer_reference__c> ();
	    set<String> setPartNumber  = new set<String> ();

        // Map containing the values of the picklist and its translated values
        Map<String, String> mapTypeValues = new Map<String, String>();

        for (Schema.PicklistEntry pe: Offer__c.Type__c.getDescribe().getPicklistValues()) 
        {
            mapTypeValues.put(pe.getValue(), pe.getLabel());
        }

        mapOfferWrapper      = new Map<Id, OfferWrapper>();
        offerTypeOptionsList = new List<SelectOption>();

        //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        Map <String,Id> PartNumberNotSelectedMapOfferId = new Map <String,Id> ();
        Set <String> PartNumberNotSelected = new Set <String> ();
        isMultiSourcing=currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) ? ((CountryCodeInformationsMapping__c.getall().containsKey(ASPISConstants.TECH_EntityCountryCodeBE) && CountryCodeInformationsMapping__c.getall().get(ASPISConstants.TECH_EntityCountryCodeBE).ActivateMultisourcing__c)?true:false) : false;

        // checks if there is a sales order
        if (currentSalesOrder.Id != null)
        {
            Set<String> finalOfferTypeSet = new Set<String>();
            //DUN 14/12/2017 case C-002001 : added Type__c != 'Invoicing'
            //DUN 10/01/2018  C-002135 agency Mode V2 adding field AgencyMode__c from PurchaseOrder
            for (Offer__c offer :[SELECT    Id, Name, Suppliable__c, Accepted__c, Type__c, ParentOffer__c, Distributor__c, Description__c,
                                            Manufacturer__c, ExpectedDeliveryDuration__c, CataloguePrice__c, Quantity__c, Total__c, 
                                            Discount__c, Price__c, BSTotalPrice__c, OrderLine__r.PartList__r.Compliance__c, OrderType__c,
                                            DeliveryStatus__c, FinalType__c, OriginalPartNumber__c, OriginalType__c, OriginalDescription__c,
                                            OriginalManufacturer__c, OriginalCatalogPrice__c, TargetedDistributor__c,
                                            PartNUmber__c, CancelReason__c, RealDeliveryDate__c, ExpectedDeliveryDate__c,
                                            OrderLine__c, OrderLine__r.OriginalItem__c, DeliveryStatusReason__c, IsCanceledByBodyshop__c,
                                            AgencyMode__c,Prerequisiteorder__r.status__c,tolabel(OrderLine__r.CancelReason__c),OrderLine__r.FamilyOfSparePart__c,OrderLine__r.BrandOfSparePart__c/* WCH 14/08/2019 C-003348, WCH 29/11/2019 C-003491, WCH 10/06/2021 C-004160 */
                                  FROM      Offer__c
                                  WHERE     Prerequisiteorder__c =: currentSalesOrder.Id
                                  //AND     Suppliable__c        =  true
                                  //AND     Accepted__c          =  'YES'
                                  AND       Type__c != 'Invoicing'
                                  ORDER BY  Name ASC])
            {
                // Check if the real delivery date is null and sets it to today
                // if(  offer.Suppliable__c &&
                //  offer.Accepted__c == 'YES' &&
                //  offer.RealDeliveryDate__c == null)
                // {
                //  offer.RealDeliveryDate__c = System.today();
                // }

                //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
                if(offer.PartNUmber__c != null){
                    setPartNumber.Add(string.valueof(offer.PartNUmber__c));
                }

                // To add wrapper depending on its type
                if (offer.ParentOffer__c != null)
                {
                    // is a child offer

                    // Checks if a wrapper of that id already exists
                    if (mapOfferWrapper.containsKey(offer.ParentOffer__c))
                    {
                        // add the child offer to the existing wrapper
                        mapOfferWrapper.get(offer.ParentOffer__c).addChildOffer(offer);
                    }
                    else
                    {
                        // put a new wrapper in the map
                        mapOfferWrapper.put(offer.ParentOffer__c, new OfferWrapper(offer));
                    }
                }
                else
                {
                    // is the parent offer
                    // Checks if a wrapper of that id already exists
                    if (mapOfferWrapper.containsKey(offer.Id))
                    {
                        // add the parent offer to the existing wrapper
                        mapOfferWrapper.get(offer.Id).setParentOffer(offer);
                    }
                    else
                    {
                        // put a new wrapper in the map
                        mapOfferWrapper.put(offer.Id, new OfferWrapper(offer));

                        //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                        if(mapOfferWrapper.get(offer.Id).isSelectedByBodyShop){
                            partNumberSelectedByBS.add(offer.PartNUmber__c);
                        }else{
                            PartNumberNotSelectedMapOfferId.put(offer.PartNUmber__c,offer.Id);
                            PartNumberNotSelected.add(offer.PartNUmber__c);
                        }
                    }
                    
                    //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    if(!(currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) && isMultiSourcing)){
                        setParentOfferIds.add(offer.Id);
                    }
                }
            }
            //RRJ 25/10/2022 C-004824 : Manufacturer ("Marca") should be introduced for each line of paint/annexes products
            lstManuRef = getBrandFamily(setPartNumber);
            if(lstManuRef != null){
                for(Manufacturer_reference__c mr : lstManuRef){
                    //string s1 = mr.Name;
                    mapManufRef.put(mr.Manufacturer_ID__c,mr);
                }
            }
        }
        //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        if(currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) && isMultiSourcing){
            PartNumberNotSelectedMapOfferId.keyset().removeAll(new List<String>(partNumberSelectedByBS));
            setParentOfferIds.addAll(PartNumberNotSelectedMapOfferId.values());
        }    
        for(Id currentOfferId:setParentOfferIds){
            mapOfferWrapper.get(currentOfferId).showInNotSelectedSection=true;
        }
        System.debug('## mapOfferWrapper : ' + mapOfferWrapper);
        System.debug('## offerTypeOptionsList : ' + offerTypeOptionsList);
    }

    //WCH 19/02/2021 C-004194
    private Boolean verifyPermission(Id currentSOId)
    {
        List<UserRecordAccess> userRecordAccessList = [ SELECT  RecordId
                                                        FROM    UserRecordAccess
                                                        WHERE   RecordId =: currentSOId
                                                        AND     UserId =: UserInfo.getUserId()
                                                        AND     HasEditAccess = true];

        return (userRecordAccessList != null && userRecordAccessList.size() > 0);
    }

    public String wrapperId {get; set;}

    public void setWrapperAccepted()
    {
        hasErrors = false;
        isToastError = false;

        if (mapOfferWrapper.containsKey(wrapperId))
        {
            mapOfferWrapper.get(wrapperId).setAccepted();
        }
    }

    public void setWrapperNotAccepted()
    {
        hasErrors = false;
        isToastError = false;
        
        if (mapOfferWrapper.containsKey(wrapperId))
        {
            mapOfferWrapper.get(wrapperId).setNotAccepted();
        }
    }

    public void saveAllChanges()
    {
        system.debug('##saveAllChanges');
        hasErrors = false;
        isToastError = false;
        
        List<Offer__c> offersToUpdateList           = new List<Offer__c>();
        Map<Id, OrderLine__c> mapOrderLineToUpdate  = new Map<Id, OrderLine__c>();

        //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        Map <String,Id> PartNumberNotSelectedMapOfferId = new Map <String,Id> ();
        Set <String> PartNumberNotSelected = new Set <String> ();
        partNumberSelectedByBS  = new Set<String>();
        setParentOfferIds       = new Set<Id>();
        isMultiSourcing=currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) ? ((CountryCodeInformationsMapping__c.getall().containsKey(ASPISConstants.TECH_EntityCountryCodeBE) && CountryCodeInformationsMapping__c.getall().get(ASPISConstants.TECH_EntityCountryCodeBE).ActivateMultisourcing__c)?true:false) : false;


        Boolean isThereDeliveryIssue                = false;

        // loop in all the wrappers
        for (OfferWrapper wrapper : mapOfferWrapper.values())
        {

            system.debug('## wrapper.parentOffer.RealDeliveryDate__c: '+ wrapper.parentOffer.RealDeliveryDate__c);
            // check if it is in delivery or not (record type)
            if(!isInDelivery)
            {
                // is not in delivery

                // if the wrapper is not selected
                // we should replicate the cancel reason to all the child offers
                if(Schema.sObjectType.Offer__c.fields.CancelReason__c.isAccessible() &&
                   wrapper.isNotSelectedByBodyShop)
                {
                    // Before assigning the cancel reason to the child offers
                    // we check if the parent cancel reason has been filled in
                    if(wrapper.parentOffer != null &&
                       wrapper.parentOffer.Type__c == currentSalesOrder.OfferType__c &&
                       wrapper.parentOffer.CancelReason__c == null)
                    {
                        hasErrors = true;
                        isToastError = true;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,System.label.CancelReason));

                        // stop execution
                        return;
                    }


                    // loop in the child offers and set the cancel reason of the parent to it
                    for (Offer__c childOffer : wrapper.childOfferList)
                    {
                        childOffer.CancelReason__c = wrapper.parentOffer.CancelReason__c;
                    }
                }
            }
            else
            {
                // is in delivery
                
                // Variable to know if parent offer has delivery issues and needs to update the child offers order line also
                Boolean isParentOfferDeliveryProblem = false;
                // Variable to know if parent offer has no delivery and needs to update the child offers order line also
                Boolean isParentOfferDeliverySuccess = false;

                // take the parent delivery status and set it to its child
                // also the real delivery date
                if(wrapper.parentOffer != null)
                {
                    // checks if the parent offer is in status MISSING, DAMAGED, ERROR
                    // ASE 28/11/2016 : C-001674
                    if (/*wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_MISSING ||
                        wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DAMAGED ||*/
                        wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_ERROR)
                    {
                        // change the boolen isParentOfferDeliveryProblem ONLY to true
                        isParentOfferDeliveryProblem    = true;

                        // add the offer's order line to be updated
                        mapOrderLineToUpdate.put(wrapper.parentOffer.OrderLine__c, new OrderLine__c(Id                      = wrapper.parentOffer.OrderLine__c,
                                                                                                    DeliveryStatus__c       = ASPISConstants.ORD_LINE_STATUS_ISSUE,
                                                                                                    DeliveryStatusReason__c = wrapper.parentOffer.DeliveryStatusReason__c));

                        if(wrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                        {
                            mapOrderLineToUpdate.put(wrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                      = wrapper.parentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                        DeliveryStatus__c       = ASPISConstants.ORD_LINE_STATUS_ISSUE,
                                                                                                                        DeliveryStatusReason__c = wrapper.parentOffer.DeliveryStatusReason__c));
                        }
                        
                        // set the boolean to create case on SO about delivery issue to true
                        isThereDeliveryIssue            = true;
                    }
                    // else check if the status is INDELIVERY, DELIVERED, DELAYED, CANCELED, RETURNED
                    //DUN 07/02/2017 case1669 : exclude shipping cost so as to avoid resynchronisation when FDP changes to Delivered
                    else if ((wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_INDELIVERY ||
                             wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED ||
                             wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELAYED ||
                             wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
                             wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)&&
                             wrapper.parentOffer.OrderType__c != 'SHIPPING COST')
                    {
                        // change the boolen isParentOfferDeliverySuccess ONLY to true
                        isParentOfferDeliverySuccess    = true;

                        // add the offer's order line to be updated
                        mapOrderLineToUpdate.put(wrapper.parentOffer.OrderLine__c, new OrderLine__c(Id                      = wrapper.parentOffer.OrderLine__c,
                                                                                                    DeliveryStatus__c       = wrapper.parentOffer.DeliveryStatus__c,
                                                                                                    RealDeliveryDate__c     = wrapper.parentOffer.RealDeliveryDate__c,
                                                                                                    DeliveryStatusReason__c = ((wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED) ? wrapper.parentOffer.DeliveryStatusReason__c : null)));

                        if(wrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                        {
                            mapOrderLineToUpdate.put(wrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                      = wrapper.parentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                        DeliveryStatus__c       = wrapper.parentOffer.DeliveryStatus__c,
                                                                                                                        RealDeliveryDate__c     = wrapper.parentOffer.RealDeliveryDate__c,
                                                                                                                        DeliveryStatusReason__c = ((wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED) ? wrapper.parentOffer.DeliveryStatusReason__c : null)));
                        }
                    }

                    // loop in the child offers and set the delivery status to the child
                    for (Offer__c childOffer : wrapper.childOfferList)
                    {
                        childOffer.DeliveryStatus__c        = wrapper.parentOffer.DeliveryStatus__c;
                        childOffer.RealDeliveryDate__c      = wrapper.parentOffer.RealDeliveryDate__c;
                        // ABT 10-NOV-2016 - C-001790
                        childOffer.DeliveryStatusReason__c  = wrapper.parentOffer.DeliveryStatusReason__c;

                        if(isParentOfferDeliveryProblem)
                        {
                            // add the offer's order line to be updated
                            mapOrderLineToUpdate.put(childOffer.OrderLine__c, new OrderLine__c( Id                  = childOffer.OrderLine__c,
                                                                                                DeliveryStatus__c   = ASPISConstants.ORD_LINE_STATUS_ISSUE));
                        }
                        else if(isParentOfferDeliverySuccess)
                        {
                            // add the offer's order line to be updated
                            mapOrderLineToUpdate.put(childOffer.OrderLine__c, new OrderLine__c( Id                  = childOffer.OrderLine__c,
                                                                                                DeliveryStatus__c   = childOffer.DeliveryStatus__c,
                                                                                                RealDeliveryDate__c = childOffer.RealDeliveryDate__c));
                        }
                    }
                }
            }

            // add the parent offer and child offers to the list to 
            // update the offers
            offersToUpdateList.add(wrapper.parentOffer);
            offersToUpdateList.addAll(wrapper.childOfferList);

            //WCH 21/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            if (wrapper.ParentOffer.ParentOffer__c == null){
                if(mapOfferWrapper.get(wrapper.ParentOffer.Id).isSelectedByBodyShop){
                    partNumberSelectedByBS.add(wrapper.ParentOffer.PartNUmber__c);
                }else{
                    PartNumberNotSelectedMapOfferId.put(wrapper.ParentOffer.PartNUmber__c,wrapper.ParentOffer.Id);
                    PartNumberNotSelected.add(wrapper.ParentOffer.PartNUmber__c);
                }
            }
        }
        
        //WCH 19/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        if(currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE) && isMultiSourcing){
            PartNumberNotSelectedMapOfferId.keyset().removeAll(new List<String>(partNumberSelectedByBS));
            setParentOfferIds.addAll(PartNumberNotSelectedMapOfferId.values());
        }   
        for(Id currentOfferId:setParentOfferIds){
            mapOfferWrapper.get(currentOfferId).showInNotSelectedSection=true;
        }

        try 
        {
            if (offersToUpdateList.size() > 0)
            {
                update offersToUpdateList;
            }
        }
        catch (Exception e)
        {
            hasErrors = true;
            
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                // error is caused by validation error
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }
            else
            {
                Utils_ManageLogs.createLogFromException('VFC06_SOManageOffers', 'Offer__c', e); 
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }

            // stops the execution
            return;
        }

        try 
        {
            if (mapOrderLineToUpdate.size() > 0)
            {
                update mapOrderLineToUpdate.values();
            }
        }
        catch (Exception e)
        {
            hasErrors = true;
            
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                // error is caused by validation error
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }
            else
            {
                Utils_ManageLogs.createLogFromException('VFC06_SOManageOffers', 'OrderLine__c', e); 
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }

            // stops the execution
            return;
        }

        try 
        {
            PrerequisiteOrder__c salesOrderToUpdate = new PrerequisiteOrder__c( Id              = currentSalesOrder.Id,
                                                                                OfferType__c    = currentSalesOrder.OfferType__c);

            // check if there is a delivery issue
            if(isInDelivery && 
               isThereDeliveryIssue)
            {
                salesOrderToUpdate.HasSomeDeliveryIssuedCaseCreated__c = true;
                //currentSalesOrder.HasSomeDeliveryIssuedCaseCreated__c = true;
            }

            update salesOrderToUpdate;
        }
        catch (Exception e)
        {
            hasErrors = true;
            
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                // error is caused by validation error
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }
            else
            {
                Utils_ManageLogs.createLogFromException('VFC06_SOManageOffers', 'PrerequisiteOrder__c', e); 
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }

            // stops the execution
            return;
        }

        // re-selecting the offers
        if (!isInDelivery)
        {
            retrieveOffers();
        }
        else
        {
            retrieveOffersInDelivery();
            canRefresh = true;
        }
        
    }

    public void changeDisplayingOffer()
    {
        hasErrors = false;
        isToastError = false;

        for(OfferWrapper wrapper : mapOfferWrapper.values())
        {
            wrapper.setAcceptedNull(previousOfferType);
        }

        previousOfferType = currentSalesOrder.OfferType__c;

        // update the boolean canBeResponded
        canSalesOrderBeResponded();
    }

    // function to know if the button Responded should be enabled or disabled
    public void canSalesOrderBeResponded()
    {
        // check first if the status of the sales order is responded
        if(currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_RESPONDED)
        {
            canBeResponded = true;
            canBeSavedAndValidated = true;
        }
        else if((currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE && 
            // DUN 04/05/2018 case 2488 : Added OrderOrigin = ASPIS in condition
                (currentSalesOrder.Assessment__r.OrderOrigin__c == 'Order' ||  currentSalesOrder.Assessment__r.OrderOrigin__c == 'ASPIS')) || 
                currentSalesOrder.Status__c == 'PREACCEPTANCE')
        {
            canBeResponded = false;
            canBeSavedAndValidated = false;
        }
        else
        {
            // Variable to count the number of offers having the accepted__c null
            Integer numberOfOfferAcceptedNull = 0;

            // loop in the wrappers and check if the offers of the same type as the sales order
            // has Accepted__c null
            for(OfferWrapper wrapper : mapOfferWrapper.values())
            {
                // check if the parent offer has accepted == null
                if( wrapper.parentOffer != null &&
                    wrapper.parentOffer.Type__c == currentSalesOrder.OfferType__c &&
                    wrapper.parentOffer.Suppliable__c == true &&
                    wrapper.parentOffer.Accepted__c == null)
                {
                    numberOfOfferAcceptedNull++;
                }

                for(Offer__c offer : wrapper.childOfferList)
                {
                    if( offer.Type__c == currentSalesOrder.OfferType__c &&
                        offer.Suppliable__c == true &&
                        offer.Accepted__c == null)
                    {
                        numberOfOfferAcceptedNull++;
                    }
                }
            }

            // checks if the number of offers having accepted null = 0
            if(numberOfOfferAcceptedNull == 0)
            {
                canBeResponded = true;
                canBeSavedAndValidated = true;
            }
            else
            {
                canBeResponded = false;
                canBeSavedAndValidated = true;
            }
        }
    }

    public void respondSalesOrder()
    {
        hasErrors = false;
        isToastError = false;
        
        // check if the sales order can be responded
        if (canBeResponded)
        {
            // change the status to RESPONDED
            currentSalesOrder.Status__c = ASPISConstants.PRE_ORDER_STATUS_RESPONDED;

            Assessment__c assessmentToUpdate = new Assessment__c(Id          = currentSalesOrder.Assessment__c,
                                                                 BodyShop__c = currentSalesOrder.BodyShop__c);

            try
            {
                update assessmentToUpdate;
                update currentSalesOrder;
                canRefresh = true;
            }
            catch (Exception e)
            {
                hasErrors = true;
            
                if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                {
                    // error is caused by validation error
                    isToastError = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                }
                else
                {
                    Utils_ManageLogs.createLogFromException('VFC06_SOManageOffers', 'PrerequisiteOrder__c', e); 
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
                }
            }
        }
    }

    // function to set all the offers to delivered and the real delivery date to today
    // this function is used when isInDelivery is true
    public void setAllOfferDeliverable()
    {
        hasErrors = false;
        isToastError = false;

        // Loop in all the offers in the map
        for (OfferWrapper wrapper : mapOfferWrapper.values())
        {
            if(wrapper.isSelectedByBodyShop && currentSalesOrder.TECH_BodyshopCountryCode__c !=ASPISConstants.TECH_EntityCountryCodeES) //NPE 16/12/2021 C-004548
            {
                if (wrapper.parentOffer != null)
                {
                    wrapper.parentOffer.DeliveryStatus__c   = ASPISConstants.OFFER_STATUS_DELIVERED;
                    //wrapper.parentOffer.RealDeliveryDate__c = system.today();
                }

                // loop in the child offers also
                for(Offer__c offer : wrapper.childOfferList)
                {
                    offer.DeliveryStatus__c                 = ASPISConstants.OFFER_STATUS_DELIVERED;
                    //offer.RealDeliveryDate__c               = system.today();
                }
            }

            //NPE 16/12/2021 C-004548: Not allow BS to change the "RETURNED" spare parts to "DELIVERED" when they use the "Conjunto Entregado" button

            if(wrapper.isSelectedByBodyShop && currentSalesOrder.TECH_BodyshopCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeES)){

                if (wrapper.parentOffer != null && (wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_INDELIVERY ||wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_MANAGED) ) {
                    wrapper.parentOffer.DeliveryStatus__c   = ASPISConstants.OFFER_STATUS_DELIVERED;
                }

                // loop in the child offers also
                for(Offer__c offer : wrapper.childOfferList) {
                    if (offer != null && (offer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_INDELIVERY ||wrapper.parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_MANAGED)) {
                        offer.DeliveryStatus__c   = ASPISConstants.OFFER_STATUS_DELIVERED;
                    }
                }
            }
        }
    }

    // ABT - C-001768 - 08-NOV-2016
    public void setAllOfferAccepted()
    {
        hasErrors = false;
        isToastError = false;

        for(OfferWrapper currentWrapper : mapOfferWrapper.values())
        {
            currentWrapper.setAccepted(currentSalesOrder.OfferType__c);
        }
    }

    // ABT - C-001804 - 18-NOV-2016
    public void retrieveParentAndChildrenAccounts()
    {
        accountSelectOptionList = new List<SelectOption>();
        mapIdAccount = new Map<Id, Account>();
        Account parentAcc;
        // check if the BodyShop attached to the Sales Order does not have a parent -> It is the parent
        if(currentSalesOrder.BodyShop__r.ParentId == null)
        {
            // The current bodyshop is the parent
            // Why do select here ? -> to get the children account in a single query
            parentAcc = [SELECT Id, Name, ShippingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                         FROM   Account
                         WHERE  Id =: currentSalesOrder.BodyShop__c];
        }
        else
        {
            // have to make a select to retrieve the parent Account
            parentAcc = [SELECT Id, Name, ShippingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                         FROM   Account
                         WHERE  Id =: currentSalesOrder.BodyShop__r.ParentId];
        }

        mapIdAccount.put(parentAcc.Id, parentAcc);
        accountSelectOptionList.add(new SelectOption(parentAcc.Id, parentAcc.Name));

        List<Id> parentIdList = new List<Id>
        {
            parentAcc.Id
        };

        // Temporary map to build the select option in the correct way
        Map<Id, SelectOption> mapAccountIdSelectOption = new Map<Id, SelectOption>();
        Map<Id, List<Account>> mapParentIdAccounts = new Map<Id, List<Account>>();
        // Level of the Account compared to the parent
        Integer depth = 1;
        
        // check if the parent account has children
        while(parentIdList.size() > 0 && Limits.getQueries() < 100)
        {
            // the parent account has children
            List<Account> chidrenAccountList = [SELECT  Id, Name, ShippingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ParentId
                                                FROM    Account
                                                WHERE   ParentId IN: parentIdList];

            // Clearing the parentIdList
            parentIdList.clear();

            String prefix = calulateNoOfSpaces(++depth);

            for(Account childAccount : chidrenAccountList)
            {
                parentIdList.add(childAccount.Id);
                mapIdAccount.put(childAccount.Id, childAccount);

                SelectOption currentOption = new SelectOption(childAccount.Id, prefix + childAccount.Name);
                currentOption.setEscapeItem(false);

                mapAccountIdSelectOption.put(childAccount.Id, currentOption);

                if(!mapParentIdAccounts.containsKey(childAccount.ParentId))
                {
                    mapParentIdAccounts.put(childAccount.ParentId, new List<Account>{childAccount});
                }
                else
                {
                    mapParentIdAccounts.get(childAccount.ParentId).add(childAccount);
                }
            }
        }

        accountSelectOptionList.addAll(sortSelectOptionsByParent(parentAcc.Id, mapParentIdAccounts, mapAccountIdSelectOption));
    }

    public List<SelectOption> sortSelectOptionsByParent(Id parentId, Map<Id, List<Account>> mapParentIdAccounts, Map<Id, SelectOption> mapAccountIdSelectOption)
    {
        List<SelectOption> groupedOptions = new List<SelectOption>();

        if(mapParentIdAccounts.containsKey(parentId))
        {
            for(Account childAccount : mapParentIdAccounts.get(parentId))
            {
                groupedOptions.add(mapAccountIdSelectOption.get(childAccount.Id));
                groupedOptions.addAll(sortSelectOptionsByParent(childAccount.Id, mapParentIdAccounts, mapAccountIdSelectOption));
            }
        }

        return groupedOptions;
    }

    public String calulateNoOfSpaces(Integer depth)
    {
        String spaces = '';

        for(Integer i = 0; i < depth; i++)
        {
            spaces += '&nbsp;&nbsp;&nbsp;&nbsp;';
        }

        return spaces;
    }

    // ABT - C-001804 - 28-NOV-2016
    public void changeBodyShop()
    {
        Assessment__c assessmentToUpdate        = new Assessment__c(Id          = currentSalesOrder.Assessment__c,
                                                                    BodyShop__c = currentSalesOrder.BodyShop__c);
                                                    
        PrerequisiteOrder__c salesOrderToUpdate = new PrerequisiteOrder__c( Id          = currentSalesOrder.Id,
                                                                            BodyShop__c = currentSalesOrder.BodyShop__c);

        try
        {
            update assessmentToUpdate;
            update salesOrderToUpdate;
            canRefresh = true;
        }
        catch (Exception e)
        {
            hasErrors = true;
            
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                // error is caused by validation error
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }
            else
            {
                Utils_ManageLogs.createLogFromException('VFC06_SOManageOffers', 'Assessment__c', e); 
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }
        }
    }

    public class OfferWrapper
    {
        // The parent offer of the wrapper
        public Offer__c parentOffer { get; set; }
        
        //WCH 24/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        public Boolean showInNotSelectedSection { get; set; }

        // List of child offers of the wrapper
        // It is empty if there is no child offers
        public List<Offer__c> childOfferList { get; set; }

        // SELECTED BY BODYSHOP
        public Boolean isSelectedByBodyShop
        {
            get
            {
                return (parentOffer != null && 
                        parentOffer.Suppliable__c == true && 
                        parentOffer.Accepted__c != 'NO' &&
                        !(parentOffer.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED &&
                          !parentOffer.IsCanceledByBodyshop__c));
            }
        }

        // NOT SELECTED BY BODYSHOP
        public Boolean isNotSelectedByBodyShop
        {
            get
            {
                return (parentOffer != null && 
                        parentOffer.Suppliable__c == true && 
                        parentOffer.Accepted__c == 'NO' &&
                        this.showInNotSelectedSection);//WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
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
                        !parentOffer.IsCanceledByBodyshop__c);
            }
        }

        // NOT SELECTED BY DISTRIBUTOR
        public Boolean isNotSelectedByDistributor
        {
            get
            {
                return (parentOffer != null && 
                        parentOffer.Suppliable__c == false);
            }
        }


        // variable to get the value of row span for the Accepted Column
        public Integer rowSpan
        {
            get
            {
                if (isOfferAlternative)
                {   
                    return 2;
                }
                else
                {
                    return childOfferList.size() + 1;
                }
            }
        }

        // Variable to know if the offer's order line has a parent
        public Boolean isOfferOriginal
        {
            get
            {
                return (parentOffer != null &&
                        parentOffer.OriginalPartNumber__c != null);
            }
        }

        // variable to know if the offer is for an alternative order line
        public Boolean isOfferAlternative
        {
            get
            {
                return (parentOffer != null &&
                        parentOffer.OriginalPartNumber__c != null &&
                        childOfferList.size() == 0);
            }
        }

        public OfferWrapper(Offer__c off)
        {
            //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            showInNotSelectedSection=false;

            childOfferList = new List<Offer__c> ();

            if (off.ParentOffer__c != null)
            {
                // the offer is a child offer
                childOfferList.add(off);
            }
            else
            {
                // the offer is a parent offer
                parentOffer = off;
            }
        }

        public void setParentOffer(Offer__c offer)
        {
            if (parentOffer == null)
            {
                parentOffer = offer;
                //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                showInNotSelectedSection=false;
            }
        }

        public void addChildOffer(Offer__c offer)
        {
            childOfferList.add(offer);
        }

        public void setAccepted()
        {
            if(isSelectedByBodyShop || isNotSelectedByBodyShop)
            {
                if(parentOffer != null)
                {
                    parentOffer.Accepted__c     = 'YES';

                    // also clear the cancel reason (if present)
                    parentOffer.CancelReason__c = null;
                }

                for (Offer__c offer : childOfferList)
                {
                    offer.Accepted__c           = 'YES';

                    // also clear the cancel reason (if present)
                    offer.CancelReason__c = null;

                }
                //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                showInNotSelectedSection=false;
            }
        }
        
        public void setNotAccepted()
        {
            if(isSelectedByBodyShop || isNotSelectedByBodyShop)
            {
                if(parentOffer != null)
                {
                    parentOffer.Accepted__c = 'NO';
                }

                for (Offer__c offer : childOfferList)
                {
                    offer.Accepted__c       = 'NO';
                }
                //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                showInNotSelectedSection=true;
            }
        }

        public void setAcceptedNull(String previousStatus)
        {
            if(isSelectedByBodyShop || isNotSelectedByBodyShop)
            {
                if( parentOffer                 != null && 
                    parentOffer.Suppliable__c   == true &&
                    parentOffer.Type__c         == previousStatus)
                {
                    parentOffer.Accepted__c = null;

                    // also clear the cancel reason (if present)
                    parentOffer.CancelReason__c = null;
                }

                for (Offer__c offer : childOfferList)
                {
                    if(offer.Suppliable__c  == true &&
                        offer.Type__c       == previousStatus) 
                    {
                        offer.Accepted__c   = null;

                        // also clear the cancel reason (if present)
                        offer.CancelReason__c = null;
                    }
                }
            }
        }

        public void setAccepted(String currentStatus) 
        {
            if(isSelectedByBodyShop || isNotSelectedByBodyShop)
            {
                if( parentOffer                 != null && 
                    parentOffer.Suppliable__c   == true &&
                    parentOffer.Type__c         == currentStatus)
                {
                    parentOffer.Accepted__c = 'YES';

                    // also clear the cancel reason (if present)
                    parentOffer.CancelReason__c = null;
                }

                for (Offer__c offer : childOfferList)
                {
                    if(offer.Suppliable__c  == true &&
                        offer.Type__c       == currentStatus)
                    {
                        offer.Accepted__c   = 'YES';

                        // also clear the cancel reason (if present)
                        offer.CancelReason__c = null;
                    }
                }
            }
        }
    }
}