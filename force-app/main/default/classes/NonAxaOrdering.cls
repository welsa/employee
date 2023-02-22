/*************************************************************************************
Class Name - NonAxaOrdering
Version - 1.0
Created Date - 05 April 2021

Modification Log :
-----------------------------------------------------------------------------  
* Developer      Date           Description
* -------------- ----------     -----------------------
* RLA           05/04/2021      Original Version
* HRM 			29/11/2021 		C-004215 - Plafond Commande
* Neha  P       08/02/2022      C-004587: Send default value on PO's First Registration Date field for OrderMakeSelection calls to SAS if value is NULL                                                                                                                
* Welsa C      19/07/2022   C-004762 : Catalogue OEM
*************************************************************************************/
global without sharing class NonAxaOrdering {

    //displays assessment name
    public String assessmentTitle {get; set;}
    //boolean to prevent recursive page loads due to remote action
    public boolean hasAlreadyRun {get;set;}
    //C-002135 : When at least one part is in agency mode. flag agency mode in the order section
    public boolean isAgencyMode {get;set;}
    //DUN 15/11/2017 case 2071
    public List<SelectOption> accountSelectOptionList {get; set;}
    public Map<Id, Account> mapIdAccount {get; set;}
    //DUN 22/02/2018 boolean to display cfsla instead of green rectangle 
    public boolean displayCFSLA{get;set;}
     //WCH 28/01/2019 C-002963 - Select/Unselect ALL on R4 Order page
    // public Boolean toggleValue{get;set;}
    public String countryCodeBE{get;set;}

    public Boolean toggleButtonSelectOEMVisible{get;set;}
    
    public Boolean toggleButtonSelectCheapestVisible{get;set;}
    public Boolean toggleValueCheapest{get;set;}
    public Boolean toggleValueOEM{get;set;}
    public Boolean doSortingCheapest {get;set;}
    public Boolean doSortingOEM {get;set;}


    //WCH 27/03/2019 C-003153 : Select All / Unselect All Issue  
    public Integer numberOfPartList{get;set;}
    public string countryCode {get;set;}
    private static String objReference = '';

    public Map<String, PartWrapper> mapPartWrapper {get; set;}
    public Map<String, List<PartWrapper>> mapListPartWrapper {get; set;}
    public Map<String, PartWrapper> mapAlreadyOrderedPartWrapper {get; set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}

    private String encryptedAssessmentId;
    private String encryptedChildAssessmentId;
    private String encryptedSourceAssessmentId{get;set;}

    public Assessment__c currentClaimAssessment {get; set;}
    public Assessment__c currentClaimOrderAssessment {get; set;}
    public String assessmentComment {get;set;}
    // public Boolean isCareOrderSwitchReadOnly {get; set;}
    public Boolean doesAssessmentHaveOffers {get; set;}

    public Account currentBodyShop {get; set;}

    public String bodyShopOrderNumber {get; set;}
    public boolean displayBodyshopOrderNumber{get;set;}
    public Boolean isSalesOrderInAcceptance {get; set;}
    public Boolean hasAlreadyOrderedOffers {get; set;}
    public Boolean redirectionInErrorModal {get; set;}
    public Boolean isShippingEligible {get;set;}
    public String shippingLabel {get;set;}

    public String assessmentClaimId;
    public String assessmentClaimOrderId; 

    //AMI 05/09/17 - Distributor Integration
    public map <string,list <orderingPartWrapper>> mapDistNamePartList = new map <string,list <orderingPartWrapper>>();
    public set <id> setPOToUpdate = new set <id>();

    private map<String, NonAxaOrdering__mdt> mapNonAxaParams = new map<String, NonAxaOrdering__mdt>();
    public static set<String> setStatusNotAllowed = new Set<String>();

    //WCH 22/06/2022 C-004697
    public List<SelectOption> lstMultiaddressRepairCenter{get;set;}
    public List<multiAddressWrapper> lstAllBSAddresses{get;set;}
    public boolean isMultiAddress {get;set;}
    public String repairCenterCodeChosen {get;set;}
    public String contactIdChosen {get;set;}
    public String contactChosen {get;set;}

    //RBE 25/01/2023 
    public Map<Id,OccurenceWrapper> mapOcc {get;set;}  //Stores the occurences for an xref
    public OccurenceWrapper detailOcc { get;set; } //Stores the occurence to be used in the additional details popup
    public Id xrefId {get;set;} //Id of the xref for which to view the occurences
    public Integer occLimit {get;set;} //Number of occurences to display on one page    
    public Integer occOffset {get;set;} //Used in the query to fetch occurences to determine from which row to start
    public Id detailOccId {get;set;}    //Id of the occurence to view in additional details
    public Id selectedOccId {get;set;} 
    public String xrefDesc {get;set;}
    public String occPartId {get;set;}
    public String occDistId {get;set;}
    public String occOfferId {get;set;}
    public String occOperation {get;set;}

    public NonAxaOrdering()
    {
        system.debug('Start NonAxaOrdering');
              
        //DUN 15/11/2017 case 2071
        accountSelectOptionList = new List<SelectOption>();
        mapIdAccount = new Map<Id, Account>();
        
        setStatusNotAllowed =new Set<String>(system.label.StatusNotAllowedNonAXAOrder.split(';'));
       

        //AMI 04/09/17 - Distributor Integration
        hasAlreadyRun = false;

        isAgencyMode = false;

        //AMI 06/11/2018  C-002781 : Migrate Spain to R4
        //                         : Display Recap of Parts Ordered For Spain Only
        //                         : adding ap constant variable for ES
        countryCode = ASPISConstants.TECH_EntityCountryCodeES;
        
        //WCH 28/01/2019 C-002963 - Select/Unselect ALL on R4 Order page
        // toggleValue=false;
        toggleButtonSelectOEMVisible=false;
        toggleButtonSelectCheapestVisible=false;
        toggleValueOEM=false;
        toggleValueCheapest = false;
        //WCH 27/03/2019 C-003153 : Select All / Unselect All Issue  
        numberOfPartList=0;

        //WCH 22/06/2022 C-004697
        lstMultiaddressRepairCenter=new List<SelectOption>();
        lstAllBSAddresses=new List<multiAddressWrapper>();

        //lstAllBSAddresses= new List<Contact>();
        isMultiAddress=false;
        repairCenterCodeChosen='';
        contactIdChosen='';
        contactChosen='';

        //RBE 25/01/2023
        occLimit = 10;
        occOffset = 0; 
        
    }

    //this method allows to requery records for display after ws call out
    public PageReference queryRecords(){
        system.debug('## Start queryRecords');

        hasAlreadyRun = true;

        mapPartWrapper              = new Map<String, PartWrapper>();
        mapListPartWrapper              = new Map<String, List<PartWrapper>>();
        mapAlreadyOrderedPartWrapper= new Map<String, PartWrapper>();
        Boolean isExpert =false;

        //VSU 28/03/2018 C-002315             


        encryptedAssessmentId       = ApexPages.currentPage().getParameters().get('Id');
        encryptedChildAssessmentId  = ApexPages.currentPage().getParameters().get('ChildId');        
            
        try{
            //VSU 02/04/18 C-002315

      
            encryptedSourceAssessmentId = ApexPages.currentPage().getParameters().get('SourceAssessmentId');
            Id idSrc = encryptedSourceAssessmentId != null? decryptBase64(encryptedSourceAssessmentId): null;

            doesAssessmentHaveOffers    = false;

            isSalesOrderInAcceptance    = false;

            redirectionInErrorModal     = false;

            displayCFSLA                = false;


            doSortingOEM = false;
                    
            
            doSortingCheapest = false;

            assessmentClaimId        = decryptBase64(encryptedAssessmentId);
            assessmentClaimOrderId   = decryptBase64(encryptedChildAssessmentId);

            Id idAssClaimid = assessmentClaimId;
            Id idAssClaimOrderId = assessmentClaimOrderId;

            system.debug('## assessmentClaimId'+assessmentClaimId);
            system.debug('## assessmentClaimOrderId'+assessmentClaimOrderId);

            Set<String> alreadyOrderedPartsSet = new Set<String>();
            Set<String> distributorIdSet       = new Set<String>();
        
            Boolean applyCheapestAlgo = false;
            Boolean applyOEMAlgo = false;

           

            List<Offer__c> lstOffersSubs = new list<Offer__c>();

                //AMI 22/10/2018  C-002781 : Migrate Spain to R4
                //                         : Adding possibility to add cancel reason when offer is not accepted
                //                         : query TECH_BodyshopCountryCode__c,CancelReason__c
            
                //AMI 05/12/17 : Adding Tech_Distributor__c in query
                //DUN 10/01/2018  C-002135 agency Mode V2 removed field AgencyMode__c from Assessment and adding field AgencyMode__c from PurchaseOrder 
                //DUN 29/03/2018  C-002240 Tech_R4 fields
                for(Offer__c currentOffer : [SELECT Id, Type__c, BSTotalPrice__c, OrderLine__r.BodyShopDiscount__c, Quantity__c, OrderLine__r.CataloguePrice__c, OrderLine__r.PartList__c, PartNUmber__c, ParentOffer__c, 
                                                    OriginalPartNumber__c, OriginalDescription__c, FinalType__c, PreselectedForOrder__c, CancelReason__c,
                                                    OrderLine__r.PartList__r.Name, OrderLine__r.PartNumber__c, OrderLine__r.PartList__r.VAT__c, OrderLine__r.PartList__r.Quantity__c, OrderLine__r.TotalPrice__c , Description__c,
                                                    OrderLine__r.PartList__r.PartNumber__c, OrderLine__r.PartList__r.Price__c, OrderLine__r.PartList__r.Type__c, Discount__c, Distributor__c,
                                                    OrderLine__r.PartList__r.OriginalPart__c, OrderLine__r.PartList__r.Original__c,OrderLine__r.PartList__r.Description__c, Accepted__c,
                                                    OrderLine__r.PartList__r.ProducerName__c, OrderLine__r.PartList__r.SelectedByBS__c,
                                                    OrderLine__r.PartList__r.CrossReferenceId__c, OrderLine__r.PartList__r.IsSourced__c, OrderLine__r.PartList__r.Assessment__c, orderLine__r.PartList__r.DiscountRecord__c, //RLA 27/11/2018 C-002782 CJP A'
                                                    OrderLine__r.PartList__r.CrossReferenceId__r.Connected__c, OrderLine__r.PartList__r.CrossReferenceId__r.OEMStandardDiscount__c, OrderLine__r.PartList__r.CrossReferenceId__r.NONPARTNER_PRE_Price__c, OrderLine__r.DistributorPrice__c, //RBE 10/01/2023 PREv2 Connected - Lot 3.3
                                                    OrderLine__r.PartList__r.OriginalPart__r.OriginalPart__r.Price__c, //RBE 20/01/2023 PREv2 Connected - Lot 3.7
                                                    OrderLine__r.PartList__r.TECH_OriginalPart__c, OrderLine__r.PurchaseOrder__c,OrderLine__r.PurchaseOrder__r.Name,OrderLine__r.PurchaseOrder__r.Distributor__c,
                                                    OrderLine__r.PartList__r.InputType__c, OrderLine__r.Suppliable__c, OrderLine__r.OriginalItem__c,OrderLine__r.SASStatus__c,
                                                    OrderLine__r.PartList__r.OriginalPart__r.QuantityOrdered__c, OrderLine__r.PartList__r.OriginalPart__r.Quantity__c, CataloguePrice__c,
                                                    OrderLine__r.PurchaseOrder__r.DistributorConnected__c, /* ASE : 19/02/18: case C-002236*/ OrderLine__r.PurchaseOrder__r.Distributor__r.OrderRequest__c,OrderLine__r.ExpectedDeliveryDuration__c, OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.ReferenceNumber__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Name,OrderLine__r.PurchaseOrder__r.BodyShopOrderNumber__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,OrderLine__r.PurchaseOrder__r.Distributor__r.DistributorRegionsCovered__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.DistributorConnected__c,  
                                                    OrderLine__r.PurchaseOrder__r.wsErrorMessage__c,OrderLine__r.PurchaseOrder__r.wsDate__c,
                                                    OrderLine__r.PurchaseOrder__r.Status__c,OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_Distributor__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Confirmed__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4ConfirmedWithDelay__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4NotFound__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Other__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Partial__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c, AgencyMode__c, OrderLine__r.PurchaseOrder__r.AgencyMode__c,
                                                    PrerequisiteOrder__c,PrerequisiteOrder__r.TECH_BodyshopCountryCode__c, PrerequisiteOrder__r.Assessment__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__c,PrerequisiteOrder__r.Status__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c, /*RLA 23/03/2021 C-004102*/ 
                                                    PrerequisiteOrder__r.Assessment__r.BodyShop__r.DistributorConnected__c, PrerequisiteOrder__r.Assessment__r.Compensated__c, PrerequisiteOrder__r.Assessment__r.Comment__c,PrerequisiteOrder__r.Assessment__r.BodyShop__c,
                                                    PrerequisiteOrder__r.Assessment__r.Manufacturer__c,PrerequisiteOrder__r.Assessment__r.ModelV2__c,PrerequisiteOrder__r.Assessment__r.FirstRegistrationDate__c ,
                                                    PrerequisiteOrder__r.Assessment__r.PlateNumber2__c,PrerequisiteOrder__r.Assessment__r.VINNumber__c,PrerequisiteOrder__r.Assessment__r.BuildDate__c,
                                                    PrerequisiteOrder__r.Assessment__r.ClaimReference__c,PrerequisiteOrder__r.Assessment__r.BodyShop__r.ParentId, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.ParentId,PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.MultiAddress__c,/* WCH 22/06/22 C-004697 */
                                                    //PrerequisiteOrder__r.Assessment__r.ClaimReference__c,PrerequisiteOrder__r.Assessment__r.BodyShop__r.ParentId, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.ParentId,
                                                    PrerequisiteOrder__r.Assessment__r.OrderOrigin__c, PrerequisiteOrder__r.Assessment__r.IsCareOrder__c,PrerequisiteOrder__r.Assessment__r.ASReference__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Status__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.ParentAssessment__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Name, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Entity__c,PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.SpecialAgreement__c, 
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.SpecialRenting__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.VINCheck__c, 
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Fleet__c,PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.TotalLoss__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.SupposedOfFraud__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.DateOfIncident__c, 
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.FirstRegistrationDate__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.EntityCode__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.ModelV2__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.MissionNumber__c, 
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.ClaimReference__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Manufacturer__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.EntityRules__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.PlateNumber2__c, 
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.TECH_EntityCountryCode__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.VINNumber__c, 
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.AssessmentID__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.Type,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.AssessmentNumber__c,PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.ShippingPostalCodeLeft2__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.Payment_Type__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.ASReference__c,PrerequisiteOrder__r.Assessment__r.Name,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Bodyshop__r.isEligibleShippingCost__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Bodyshop__r.ShippingCountryCode,PreferredDistributor__c ,                        
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Agency_V3__c,  
                                                    OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c,
                                                    OrderLine__r.AlphaScaleMRID__c,
                                                    OrderLine__r.PartList__r.NonAxa_Original_Part__c,
                                                    PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.Bodyshop__r.Non_Axa_Sorting_for_Order__c
                                             FROM   Offer__c 
                                             WHERE  PrerequisiteOrder__r.Assessment__r.ParentAssessment__c =: assessmentClaimId AND DeliveryStatus__c != 'CANCELED'  //RBE 17/01/2023
                                             order by OrderLine__r.PurchaseOrder__r.Distributor__r.Name]) //WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                {

                    for (NonAxaOrdering__mdt params: [SELECT MasterLabel,Active__c,isCheapestSortingVisible__c,selectOemsOnlyVisible__c
                                                                    FROM NonAxaOrdering__mdt
                                                                    where MasterLabel = :currentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c
                                                                            and  Active__c = true]){
                        mapNonAxaParams.put(params.MasterLabel, params);

                    }
                    system.debug('## currentOffer'+currentOffer);

                    //system.debug('## OrderLine__r.PartList__r.CrossReferenceId__c ' + currentOffer.OrderLine__r.PartList__r.CrossReferenceId__c);
                    // extracting the assessment
                    if( currentOffer.PrerequisiteOrder__r.Assessment__c == assessmentClaimOrderId &&
                        currentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__c != null)
                    {
                        currentClaimAssessment      = currentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__r;
                        system.debug('£ currentClaimAssessment' + currentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__r);
                        currentClaimOrderAssessment = currentOffer.PrerequisiteOrder__r.Assessment__r;
                        doesAssessmentHaveOffers    = true;

                        currentBodyShop = currentClaimAssessment.BodyShop__r;

                        //WCH 22/06/22 C-004697
                        isMultiAddress=currentClaimAssessment.BodyShop__r.MultiAddress__c;

                        //Dourga 05/02/2018  C-002135 : When at least one part is in agency mode. flag agency mode in the order section
                        if(currentOffer.AgencyMode__c){
                           isAgencyMode = true;
                        }

                        if(currentBodyShop.Type == 'Expert')
                        {
                            assessmentTitle = Label.AssessmentInProgress;
                            isExpert=true;
                        }
                        else
                        {
                            assessmentTitle = Label.MyAssessment;
                        }

                        System.debug('££££ non axa ordering '+currentBodyShop.Non_Axa_Sorting_for_Order__c);

                        if (String.isNotBlank(currentBodyShop.Non_Axa_Sorting_for_Order__c) && currentBodyShop.Non_Axa_Sorting_for_Order__c.contains('Cheapest') ){
                            applyCheapestAlgo = true;
                            toggleValueCheapest = true; 

                        }
                        else if (String.isNotBlank(currentBodyShop.Non_Axa_Sorting_for_Order__c) && currentBodyShop.Non_Axa_Sorting_for_Order__c.contains('OEM Only') ){
                            applyOEMAlgo = true;
                            toggleValueOEM = true;
                        }
                        
                        if(!isSalesOrderInAcceptance && currentOffer.PrerequisiteOrder__r.Status__c == ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
                        {
                            isSalesOrderInAcceptance = true;
                        }

                        if ( String.isnotblank(currentOffer.PartNUmber__c) && (String.isnotblank(currentOffer.OrderLine__r.AlphaScaleMRID__c) && currentOffer.OrderLine__r.AlphaScaleMRID__c.StartsWith('ASP-')) || (String.isblank(currentOffer.OrderLine__r.AlphaScaleMRID__c))){

                            System.debug('£££ mapPartWrapper 1 : '+ mapPartWrapper);
                            // Constructing the wrapper
                            if(!mapPartWrapper.containsKey(currentOffer.OrderLine__r.PartList__c))
                            {   
                                system.debug('£££ not contains in map');

                                mapPartWrapper.put(currentOffer.OrderLine__r.PartList__c, new PartWrapper(currentOffer));
                            }
                            else
                            {   
                                system.debug('£££ contains in map');
                                mapPartWrapper.get(currentOffer.OrderLine__r.PartList__c).addNewOffer(currentOffer);
                            }
                            System.debug('£££ mapPartWrapper 2 : '+ mapPartWrapper);
                            system.debug('@@ I am an OEM '+currentOffer.PartNumber__c);
                        }
                        // else if(String.isBlank(currentOffer.OrderLine__r.SASStatus__c) || (String.isnotBlank(currentOffer.OrderLine__r.SASStatus__c) && !setStatusNotAllowed.contains(currentOffer.OrderLine__r.SASStatus__c))){
                        else {
                            system.debug('@@ you are an ASCR'+currentOffer.PartNumber__c + currentOffer.OrderLine__r.SASStatus__c);
                            lstOffersSubs.add(currentOffer);
                            // Constructing the wrapper

                        }

            


                        if(currentOffer.OrderLine__c != null &&
                            currentOffer.OrderLine__r.PurchaseOrder__c != null &&
                            currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c != null)
                        {
                            distributorIdSet.add(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c);
                        }
                        system.debug('@@@ i came here');

                    }
                

                    else if(currentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c > 0 && 
                            currentOffer.OrderLine__r.Suppliable__c == 'YES' && 
                            (
                                    currentOffer.PrerequisiteOrder__r.Status__c != 'PREACCEPTANCE' && 
                                    currentOffer.PrerequisiteOrder__r.Status__c != 'INACCEPTANCE'
                            ))
                    {
                        system.debug('@@@ but did you come to alread ordered?');
            

                        hasAlreadyOrderedOffers = true;

                        // check if the offer is an alternative or bundle by checking the orderline's 
                        if(currentOffer.OrderLine__r.OriginalItem__c == null)
                        {
                            // it is an original
                            // should merge the quantity

                            if(!mapAlreadyOrderedPartWrapper.containsKey(currentOffer.OrderLine__r.PartList__r.OriginalPart__c))
                            {
                                mapAlreadyOrderedPartWrapper.put(currentOffer.OrderLine__r.PartList__r.OriginalPart__c, new PartWrapper(currentOffer));
                            }
                            else
                            {
                                mapAlreadyOrderedPartWrapper.get(currentOffer.OrderLine__r.PartList__r.OriginalPart__c).addNewOffer(currentOffer);
                            }
                        }
                        else
                        {
                            if(!mapAlreadyOrderedPartWrapper.containsKey(currentOffer.PrerequisiteOrder__r.Assessment__c + '-' + currentOffer.OrderLine__r.PartList__r.OriginalPart__c))
                            {
                                mapAlreadyOrderedPartWrapper.put(currentOffer.PrerequisiteOrder__r.Assessment__c + '-' + currentOffer.OrderLine__r.PartList__r.OriginalPart__c, new PartWrapper(currentOffer));
                            }
                            else
                            {
                                mapAlreadyOrderedPartWrapper.get(currentOffer.PrerequisiteOrder__r.Assessment__c + '-' + currentOffer.OrderLine__r.PartList__r.OriginalPart__c).addNewOffer(currentOffer);
                            }
                        }
                        

                        // capture the id of the already order parts
                        alreadyOrderedPartsSet.add(currentOffer.OrderLine__r.PartList__r.OriginalPart__c);
                    }
                    
                    //WCH 29/01/2019 C-002963 - Select/Unselect ALL on R4 Order page
                    toggleButtonSelectCheapestVisible = mapNonAxaParams.get(currentOffer.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c).isCheapestSortingVisible__c; 
                    toggleButtonSelectOEMVisible = mapNonAxaParams.get(currentOffer.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c).selectOemsOnlyVisible__c; 
                   
                }
                system.debug('## currentBodyShop ' + currentBodyShop);
                system.debug('## toggleButtonSelectCheapestVisible ' + toggleButtonSelectCheapestVisible);
                system.debug('## mapPartWrapper ' + mapPartWrapper);
                system.debug('## lstOffersSubs ' + lstOffersSubs);

                for (Offer__c currentOffer: lstOffersSubs){
                    system.debug('@@ currentOffer.OrderLine__r.PartList__r.NonAxa_Original_Part__c:'+currentOffer.OrderLine__r.PartList__r.NonAxa_Original_Part__c);
                    system.debug('@@ currentOffer.OrderLine__r.PartList__r.NonAxa_Original_Part__c:'+currentOffer.OrderLine__r.PartList__r.Name);

        
                    
                    System.debug('FinalType__c '+ mapPartWrapper.get(currentOffer.OrderLine__r.PartList__r.NonAxa_Original_Part__c));

                    if(!mapPartWrapper.containsKey(currentOffer.OrderLine__r.PartList__r.NonAxa_Original_Part__c))
                    {   
                        mapPartWrapper.put(currentOffer.OrderLine__r.PartList__r.NonAxa_Original_Part__c, new PartWrapper(currentOffer));
                        system.debug('@@ am in new');
                    }
                    else
                    {   
                        system.debug('%% current offer : '+ currentOffer);
                        mapPartWrapper.get(currentOffer.OrderLine__r.PartList__r.NonAxa_Original_Part__c).partSubstitutes.add(new PartWrapper(currentOffer));
                        system.debug('@@ am in else');

                    }

                }

                system.debug('## mapListPartWrapper after subs ' + mapPartWrapper);

                    

                
                if(currentBodyShop.isEligibleShippingCost__c &&
                   CountryCodeInformationsMapping__c.getall().containsKey(currentBodyShop.ShippingCountryCode) && 
                   CountryCodeInformationsMapping__c.getall().get(currentBodyShop.ShippingCountryCode).AlphaScaleEntity__c != null){
                    Account shippingAccount = [select id, ShippingCostStepClassic__c, ShippingCostValueClassic__c, ShippingCostRegionClassic__c,
                                                      ShippingCostRegionOther__c, ShippingCostStepOther__c, ShippingCostValueOther__c 
                                               from Account
                                               where id =: CountryCodeInformationsMapping__c.getall().get(currentBodyShop.ShippingCountryCode).AlphaScaleEntity__c];
    
                    if(shippingAccount != null){
                        
                        isShippingEligible = true;//vsu added null check on shippingCostRegionClassic 26/10/17
                        if(shippingAccount.ShippingCostRegionClassic__c!= null && shippingAccount.ShippingCostRegionClassic__c.contains(currentBodyShop.ShippingPostalCodeLeft2__c)){
                            shippingLabel = String.format(Label.EligibleShippingCost, new List<String>{String.valueOf(shippingAccount.ShippingCostValueClassic__c), String.valueOf(shippingAccount.ShippingCostStepClassic__c)});
                        }
                        else if(shippingAccount.ShippingCostRegionOther__c!=null && shippingAccount.ShippingCostRegionOther__c.contains(currentBodyShop.ShippingPostalCodeLeft2__c)){
                            shippingLabel = String.format(Label.EligibleShippingCost, new List<String>{String.valueOf(shippingAccount.ShippingCostValueOther__c), String.valueOf(shippingAccount.ShippingCostStepOther__c)});
                        }
                        
                    }
                }

                // Setting the comment if present
                if(currentClaimOrderAssessment != null && currentClaimOrderAssessment.Comment__c != null)
                {
                    assessmentComment = currentClaimOrderAssessment.Comment__c; 
                }

                // Retrieving the terms and condition of the distributors
                Set<Id> distributorHavingTCIdSet = new Set<Id>();
                if(distributorIdSet.size() > 0)
                {
                    for(Attachment currentAttachment : [SELECT  Id, ParentId 
                                                        FROM    Attachment 
                                                        WHERE   ParentId IN: distributorIdSet 
                                                        AND     Name LIKE '%TermsAndCondition%' 
                                                        ORDER BY LastModifiedDate DESC])
                    {
                        distributorHavingTCIdSet.add(currentAttachment.ParentId);
                    }
                }
                
                //WCH 27/03/2019 C-003153: Select All / Unselect All Issue
                Integer numberOfEligibleParts=0;
                system.debug('@@@ alreadyOrderedPartsSet: '+alreadyOrderedPartsSet);
                system.debug('@@ applyCheapestAlgo: '+applyCheapestAlgo);
                system.debug('@@ applyOEMAlgo: '+applyOEMAlgo);

                //System.debug('@@ distributorHavingTCIdSet:'+distributorHavingTCIdSet);

                // Loop in the map of PartWrapper to set the already ordered parts
                // Why do this as the id of the map is not the original part > i wonder too.
                //system.debug('mapPartWrapper.values().size()>>>'+mapPartWrapper.values().size());
                for(PartWrapper currentPartWrapper : mapPartWrapper.values())

                {   
                     Double tempPrice;
                     OfferWrapper offerCheapest;
                    currentPartWrapper.orderTheDistributors();//WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops

                    system.debug('@@@ current part: '+ currentPartWrapper.currentPart.OriginalPart__c);
                    if(!alreadyOrderedPartsSet.contains(currentPartWrapper.currentPart.OriginalPart__c))
                    {

                        System.debug('£££ in here !!'+currentPartWrapper.currentPart.OriginalPart__c);
                    //     currentPartWrapper.setAlreadyOrdered();
                    //     //WCH 07/01/2019 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                            System.debug('£££ in here 2 !!'+ currentPartWrapper.mapDistributorWrapper);

                            for(Id distOfOrderedPart:currentPartWrapper.mapDistributorWrapper.keyset()){
                                for(Id offerOfOrderedPart : currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.keyset()){

                                    // if ((currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c).contains(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c)){

                                    if (((String.isnotblank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c) && String.isnotblank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c).contains(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&
																
                                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                    
                                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                                    
                                    (currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c == null &&
                                    
                                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                                    
                                    (currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                    
                                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c != null)) ){

                                        if (applyOEMAlgo){
                                            currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=true;
                                        }
                                        else if (applyCheapestAlgo){
                                            tempPrice = currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.CataloguePrice__c;
                                            offerCheapest = currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart);
                                            system.debug('Chepest is me: '+offerCheapest.parentOffer.PartNUmber__c);
                                            system.debug('Chepest is me: '+offerCheapest.parentOffer.CataloguePrice__c);
                                        }
    }  
   

                                
                                }
                            }
                    }
                    // RLA added now order distributors for substitutes
                    for (PartWrapper currentPartWrapperSubs: currentPartWrapper.partSubstitutes){


                        currentPartWrapperSubs.orderTheDistributors();//WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of 
                        if(!alreadyOrderedPartsSet.contains(currentPartWrapperSubs.currentPart.OriginalPart__c))
                        {
                            currentPartWrapperSubs.setAlreadyOrdered();
                            //WCH 07/01/2019 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                            for(Id distOfOrderedPart:currentPartWrapperSubs.mapDistributorWrapper.keyset()){
                                for(Id offerOfOrderedPart : currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.keyset()){

                                    if (((String.isnotblank(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c) && String.isnotblank(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c).contains(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&
																
                                    currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                    
                                    currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                                    
                                    (currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c == null &&
                                    
                                    currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                                    
                                    (currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                    
                                    currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c != null)) ){

                                        if (applyOEMAlgo){
                                            currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;
                                        }
                                        else if (applyCheapestAlgo){
                                            if (currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.CataloguePrice__c <  tempPrice){
                                                tempPrice = currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.CataloguePrice__c;
                                                offerCheapest = currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart);
                                                system.debug('Chepest is me: '+offerCheapest.parentOffer.PartNUmber__c);
                                                system.debug('Chepest is me: '+offerCheapest.parentOffer.CataloguePrice__c);

                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                    // if (applyCheapestAlgo && offerCheapest != null){
                        
                    //         // tempPrice = currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.CataloguePrice__c;
                    //         offerCheapest.isAccepted = true;
                    //         system.debug('Chepest final is me: '+offerCheapest.parentOffer.PartNUmber__c);

                        

                    // }
                    if (applyOEMAlgo){
                        doSortingOEM = true;
                    }
                    else if(applyCheapestAlgo){
                        doSortingCheapest = true;
                    }
                    dosorting();

                    
                    // Loop in the distributors and set the boolean hasTermsAndCondition to true
                    for(Id distributorId : currentPartWrapper.mapDistributorWrapper.keySet())
                    {
                        if(distributorHavingTCIdSet.contains(distributorId))
                        {
                            //System.debug('@@ distributorId:'+distributorId);

                            currentPartWrapper.mapDistributorWrapper.get(distributorId).hasTermsAndCondition = true;
                        }
                    }
                }
           
           //WCH 27/03/2019 C-003153: Select All / Unselect All Issue
           numberOfPartList=numberOfEligibleParts;
           System.debug('## numberOfPartList : ' + numberOfPartList);

        // 
            //RRJ 12/10/2022
            for(String currentRP : picklist_values(currentBodyShop.Id)){
                lstMultiaddressRepairCenter.add(new SelectOption(currentRP, currentRP));
            }

            //DUN 15/11/2017 case 2071
            retrieveParentAndChildrenAccounts();
            System.debug('## verifypermission : ' + verifyPermission(currentClaimAssessment));
            System.debug('## isExpert : ' + isExpert);
            //WCH 02/04/2021 C-004067 
            system.debug('currentClaimAssessment' + currentClaimAssessment);


            if(!(verifyPermission(currentClaimAssessment) || isExpert)){
                System.debug('## got in verif perm ' );
                hasErrors = true;
                isToastError = false;
                redirectionInErrorModal = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }

            if(currentClaimAssessment == null)
            {
                hasErrors = true;
                isToastError = false;
                redirectionInErrorModal = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.AssessmentRejected));
            }   
            
            //VSU
            if(CountryCodeInformationsMapping__c.getall().get(currentBodyShop.ShippingCountryCode).BodyShopOrderNumber__c){
                displayBodyshopOrderNumber = true;
            }     

            //DUN 22/02/2018
            if(CountryCodeInformationsMapping__c.getall().get(currentBodyShop.ShippingCountryCode).DelayLine__c){
                displayCFSLA = true;
            }
            
            System.debug('## mapPartWrapper : ' + mapPartWrapper);
            System.debug('## mapAlreadyOrderedPartWrapper : ' + mapAlreadyOrderedPartWrapper);

        }//VSU 02/04/18 C-002315
        catch(Exception e){
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){ 
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
            else{
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            system.debug('@@@ err'+ e.getMessage() + e.getStackTraceString());
        }
        return null;
    }
    /**
     * Function to redirect the page to the search page in case of wrong link opened
     * @return   The page to which it must be redirected
     */
    public PageReference redirectPage()
    {
        PageReference pageRef = Page.Search;
        pageRef.setRedirect(true);
        return pageRef;
    }

    //WCH 22/06/22 C-004697
    public class multiAddressWrapper {
        public Contact theContact { get; set; }
        public Boolean selected { get; set; }
    
        public multiAddressWrapper(Contact contct) {
            this.theContact = contct;
            this.selected = false;
        }
    }
    public static list<Orderline__c> getbundles(Map<Id, OrderLine__c> olMap){
        system.debug('## getbundles START: '+olMap);
        list<Orderline__c> olList = olMap.values();
        //list<Orderline__c> olList = new list<Orderline__c>();
        set<Id> oriSet = new set<Id>();
        for(Id OLId : olMap.keyset()){
            Orderline__c acceptedOL = olMap.get(OLId);
            if(acceptedOL.AcceptedCheck__c){
                oriSet.add(acceptedOL.Id);
            }
        }

        system.debug('## oriSet:'+oriSet);
        if(oriSet.size() > 0){
            for(Orderline__c ol : [Select Id, Suppliable__c, AcceptedCheck__c, Quantity__c, PreselectedForOrder__c, OriginalItem__c, OriginalItem__r.OriginalItem__c, OrderType__c 
                                    from Orderline__c 
                                    //where OriginalItem__c in :oriSet or OriginalItem__r.OriginalItem__c in: oriSet]){
                                    where OriginalItem__c in :olMap.keyset() or OriginalItem__r.OriginalItem__c in: olMap.keyset()]){
                system.debug('## ol: '+ol);
                if(ol.OrderType__c == 'BUNDLEITEM'){
                    Orderline__c originalOL = olMap.get(ol.OriginalItem__r.OriginalItem__c);
                    if(originalOL != null){
                        Orderline__c OL1 = new Orderline__c(Id = Ol.Id, Suppliable__c = originalOL.Suppliable__c , AcceptedCheck__c = originalOL.AcceptedCheck__c, PreselectedForOrder__c = originalOL.PreselectedForOrder__c);
                        if(OL1.AcceptedCheck__c){
                            OL1.Quantity__c =  originalOL.Quantity__c;
                        }
                        olList.add(OL1);
                    }
                }
                else if(ol.OrderType__c == 'FINAL' && ol.OriginalItem__c != null){
                    Orderline__c originalOL = olMap.get(ol.OriginalItem__c);
                    if(originalOL != null){
                        Orderline__c OL2 = new Orderline__c(Id = Ol.Id, Suppliable__c = originalOL.Suppliable__c , AcceptedCheck__c = originalOL.AcceptedCheck__c, PreselectedForOrder__c = originalOL.PreselectedForOrder__c);
                        if(OL2.AcceptedCheck__c){
                            OL2.Quantity__c =  originalOL.Quantity__c;
                        }
                        olList.add(OL2);
                    }
                }            
            }
        }
        system.debug('## olList:'+olList);
        system.debug('## olList:'+olList.size());
        system.debug('## getbundles END');

        return olList;
    }


    //DUN 15/11/2017 case 2071
    public void retrieveParentAndChildrenAccounts()
    {
        
        Account parentAcc;
        system.debug('## currentClaimOrderAssessment' + currentClaimOrderAssessment);
        system.debug('## currentClaimOrderAssessment.BodyShop__c ' + currentClaimOrderAssessment.BodyShop__c);
        system.debug('## currentClaimOrderAssessment.BodyShop__r.ParentId ' + currentClaimOrderAssessment.BodyShop__r.ParentId);
        // check if the BodyShop attached to the Sales Order does not have a parent -> It is the parent
        if(currentClaimOrderAssessment.BodyShop__r.ParentId == null)
        {
            // The current bodyshop is the parent
            // Why do select here ? -> to get the children account in a single query
            parentAcc = [SELECT Id, Name, ShippingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                         FROM   Account
                         WHERE  Id =: currentClaimOrderAssessment.BodyShop__c];
        }
        else
        {
            // have to make a select to retrieve the parent Account
            parentAcc = [SELECT Id, Name, ShippingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                         FROM   Account
                         WHERE  Id =: currentClaimOrderAssessment.BodyShop__r.ParentId];
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

    public String calulateNoOfSpaces(Integer depth)
    {
        String spaces = '';

        for(Integer i = 0; i < depth; i++)
        {
            spaces += '&nbsp;&nbsp;&nbsp;&nbsp;';
        }

        return spaces;
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

    // public void doSorting(Boolean applyCheapestAlgo, Boolean applyOEMAlgo){
    public void doSorting(){

        system.debug('@@@ doSortingOEM:'+doSortingOEM);
        system.debug('@@@ doSortingCheapest:'+doSortingCheapest);
        if (doSortingOEM != null && doSortingOEM){
            toggleValueCheapest = false;
        }
        if (doSortingCheapest != null && doSortingCheapest){
           toggleValueOEM = false; 
        }
        // Loop in the map of PartWrapper to set the already ordered parts
        // Why do this as the id of the map is not the original part > i wonder too.
        //system.debug('mapPartWrapper.values().size()>>>'+mapPartWrapper.values().size());
        for(PartWrapper currentPartWrapper : mapPartWrapper.values())
        {   
            Double tempPrice;
            OfferWrapper offerCheapest;
            // currentPartWrapper.orderTheDistributors();//WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            // if(alreadyOrderedPartsSet.contains(currentPartWrapper.currentPart.OriginalPart__c))
            // {
            //     currentPartWrapper.setAlreadyOrdered();
            //     //WCH 07/01/2019 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            for(Id distOfOrderedPart:currentPartWrapper.mapDistributorWrapper.keyset()){
                for(Id offerOfOrderedPart : currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.keyset()){

                    if (((String.isnotblank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c) && String.isnotblank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c).contains(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&
																
                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                    
                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                    
                    (currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c == null &&
                    
                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                    
                    (currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                    
                    currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c != null)) ){

                        if (doSortingOEM != null && doSortingOEM){
                                currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=true;
                        }
                        else if (doSortingCheapest != null && doSortingCheapest){
                            currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;
                            tempPrice = currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.BSTotalPrice__c;
                            offerCheapest = currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart);
                            system.debug('Chepest is me: '+offerCheapest.parentOffer.PartNUmber__c);
                            system.debug('Chepest is me: '+offerCheapest.parentOffer.BSTotalPrice__c);
                        }
                        else{
                            currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;
                        }
                    }
                    
                }
            }
            // }
            // RLA added now order distributors for substitutes
            for (PartWrapper currentPartWrapperSubs: currentPartWrapper.partSubstitutes){
         
                // currentPartWrapperSubs.orderTheDistributors();//WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of 
                // if(alreadyOrderedPartsSet.contains(currentPartWrapperSubs.currentPart.OriginalPart__c))
                // {
                    // currentPartWrapperSubs.setAlreadyOrdered();
                    //WCH 07/01/2019 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    for(Id distOfOrderedPart:currentPartWrapperSubs.mapDistributorWrapper.keyset()){
                        for(Id offerOfOrderedPart : currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.keyset()){

                            if (((String.isnotblank(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c) && String.isnotblank(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c).contains(currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c) &&
																
                            currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                            
                            currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                            
                            (currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c == null &&
                            
                            currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ||
                            
                            (currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                            
                            currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c != null)) ){
                                if (doSortingOEM != null && doSortingOEM){
                                    currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;
                                }
                                else if (doSortingCheapest != null && doSortingCheapest){
                                    currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;
                                    if (currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.BSTotalPrice__c <  tempPrice){
                                        tempPrice = currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.BSTotalPrice__c;
                                        offerCheapest = currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart);
                                        system.debug('Chepest is me: '+offerCheapest.parentOffer.PartNUmber__c);
                                        system.debug('Chepest is me: '+offerCheapest.parentOffer.BSTotalPrice__c);

                                    }

                                }
                                else{
                                    currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;  
                                }
                            }
                        }
                    }
                // }
            }
            if (doSortingCheapest != null && doSortingCheapest && offerCheapest != null){
                    // tempPrice = currentPartWrapperSubs.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.CataloguePrice__c;
                    offerCheapest.isAccepted = true;
                    system.debug('Chepest final is me: '+offerCheapest.parentOffer.PartNUmber__c); 
            }

        }
    }

    //WCH 22/06/22 C-004697
    public void getAddressDeLivraison(){
        system.debug('## Start getAddressDeLivraison>>'+repairCenterCodeChosen);
        //lstAllBSAddresses = [select Id from Contact where recordtype.developername=:ASPISConstants.CONTACT_RT_DeveloperName_MULTIADDRESS and RepairCenterCode__c=:repairCenterCodeChosen and AccountId=:currentBodyShop.Id];
        lstAllBSAddresses=new List<multiAddressWrapper>();
        for(Contact con1: [select Id,RepairCenterCode__c,Account.Name,MailingStreet, MailingCity, MailingState, MailingPostalcode ,MailingCountry from Contact where recordtype.developername=:'Multiaddress' and RepairCenterCode__c=:repairCenterCodeChosen and AccountId=:currentBodyShop.Id]){
            lstAllBSAddresses.add(new multiAddressWrapper(con1));
         }
        system.debug('## end getAddressDeLivraison>>'+lstAllBSAddresses);
    }
    public void setAddressDeLivraison(){
        system.debug('## Start setAddressDeLivraison>>'+lstAllBSAddresses);
        //update PO and SO 
        for(multiAddressWrapper currentMAW : lstAllBSAddresses){
            if(currentMAW.selected){
                contactIdChosen=currentMAW.theContact.Id;
                contactChosen=currentMAW.theContact.RepairCenterCode__c+' '+currentMAW.theContact.Account.Name+' '+currentMAW.theContact.MailingStreet;
            }
        }
        List<PurchaseOrder__c> purchaseOrderToUpdateList = [SELECT  Id 
                                                                    FROM    PurchaseOrder__c 
                                                                    WHERE   Assessment__c =: currentClaimOrderAssessment.Id];
        for(PurchaseOrder__c cpo : purchaseOrderToUpdateList){
            cpo.Addresse_De_Livraison__c=contactIdChosen;
        }

        List<PrerequisiteOrder__c> salesOrderToUpdateList = [SELECT  Id 
                                                                FROM    PrerequisiteOrder__c 
                                                                WHERE   Assessment__c =: currentClaimOrderAssessment.Id];
        for(PrerequisiteOrder__c cso : salesOrderToUpdateList){
            cso.Addresse_De_Livraison__c=contactIdChosen;
        }
        update purchaseOrderToUpdateList;
        update salesOrderToUpdateList;
        system.debug('## end setAddressDeLivraison>>');
    }
    public void checkAddressDeLivraison(){
        system.debug('## Start checkAddressDeLivraison>>'+contactIdChosen);
        for(multiAddressWrapper currentMAW : lstAllBSAddresses){
            if(currentMAW.theContact.Id==contactIdChosen){
                currentMAW.selected=true;
            }else{currentMAW.selected=false;}
        }
        system.debug('## end checkAddressDeLivraison>>'+lstAllBSAddresses);
    }

    //AMI 04/09/17 - Distributor Integration
    @RemoteAction
    global static string updateStockInfo(string assId){
        system.debug('## Start updateStockInfo');

        string decryptedAssId                                                               = '';
        string wsRequest                                                                    = '';
        string wsResponse = '';
        
        
        Assessment__c assRecord                                                             = null;

        map <Id, PartList__c> partMap                                                       = new map <Id, PartList__c>();
        map <Id, PartList__c> partMapNonConnected                                                       = new map <Id, PartList__c>();//WCH 21/07/2022 C-004762
        map <Id, OrderLine__c> olMapNonConnected                                                       = new map <Id, OrderLine__c>();//WCH 21/07/2022 C-004762
        map <Id, Id> olMapPartNonConnected                                                       = new map <Id, Id>();//WCH 21/07/2022 C-004762
        map <string,PurchaseOrder__c> mapPOExtIDPO                                          = new map <string,PurchaseOrder__c>();
        map <string,Account> mapDistributorNameDistributor                                  = new map <string,Account>();  

        //deserailse response to get Message
        map <string,object> deserialisedResponseMap                                         = new map <string,object>();

        list <Account> distributorLst                                                       = new list <Account>();
        //list <PurchaseOrder__c> erroredPO                                                   = new list <PurchaseOrder__c>();

        // toggleValueCheapest = true;
               
        if(string.isNotBlank(assId)){
            decryptedAssId                                                                  = decryptBase64(assId);

            
            for(OrderLine__c ol : [Select Id, PartList__c, PartList__r.Type__c, PartList__r.Quantity__c, PartList__r.PartNumber__c, PartList__r.ProducerName__c, PartList__r.Description__c, PartList__r.Price__c, 
                                          PartList__r.RecordTypeId, PartList__r.CrossReferenceId__c, PartList__r.Alpha_Scale_MRID__c, PartList__r.CrossReferenceId__r.IAMPartNumber__c,
                                          PartList__r.CrossReferenceId__r.IAMManufacturer__c, PartList__r.DistributorPriceId__c, PartList__r.DistributorPriceId__r.DistributorPartNumber__c, 
                                          PartList__r.CrossReferenceId__r.OEMPartNumber__c, PartList__r.Assessment__r.Feature__c, PartList__r.Distributor__c, PartList__r.distributor__r.Feature__c,
                                          PurchaseOrder__c, PurchaseOrder__r.Name, PurchaseOrder__r.Assessment__c, PurchaseOrder__r.Distributor__c, PurchaseOrder__r.Distributor__r.Name, 
                                          PurchaseOrder__r.Distributor__r.DistributorConnected__c, PurchaseOrder__r.Tech_ExternalId__c, PurchaseOrder__r.Status__c, PurchaseOrder__r.wsDate__c, 
                                          PurchaseOrder__r.wsErrorMessage__c, PurchaseOrder__r.Manual_Creation__c, PurchaseOrder__r.Rebate__c, PurchaseOrder__r.Distributor__r.Categories__c, 
                                          PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c, PurchaseOrder__r.Distributor__r.Tech_Distributor__c, PurchaseOrder__r.Distributor__r.Rebate__c, 
                                          PurchaseOrder__r.Distributor__r.DistributorCarBrandSupplied__c, PurchaseOrder__r.Distributor__r.RecordTypeId, PurchaseOrder__r.Distributor__r.CurrencyIsoCode, 
                                          PurchaseOrder__r.Distributor__r.OrderRequest__c, PurchaseOrder__r.Assessment__r.BodyShop__c, PurchaseOrder__r.Assessment__r.BodyShop__r.DistributorConnected__c,
                                          PurchaseOrder__r.Assessment__r.BodyShop__r.Name,PurchaseOrder__r.Assessment__r.BodyShop__r.VATNumber__c, PurchaseOrder__r.Assessment__r.BodyShop__r.ReferenceNumber__c, 
                                          PurchaseOrder__r.Assessment__r.BodyShop__r.RecordTypeId, PurchaseOrder__r.Assessment__r.BodyShop__r.CurrencyIsoCode, 
                                          PurchaseOrder__r.Assessment__r.Manufacturer__c, PurchaseOrder__r.Assessment__r.ModelV2__c,  PurchaseOrder__r.Assessment__r.FirstRegistrationDate__c,
                                          PurchaseOrder__r.Assessment__r.PlateNumber2__c, PurchaseOrder__r.Assessment__r.VINNumber__c, PurchaseOrder__r.Assessment__r.ClaimReference__c, 
                                          PurchaseOrder__r.Assessment__r.BuildDate__c, PurchaseOrder__r.Assessment__r.Name,/*Case 2659*/ PartList__r.Assessment__r.TECH_EntityCountryCode__c,
                                            PurchaseOrder__r.Assessment__r.InsuranceBroker__c,PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c
                                            ,PurchaseOrder__r.Assessment__r.TECH_EntityCountryCode__c

                                  from OrderLine__c
                                  where PurchaseOrder__r.Assessment__c = :decryptedAssId
                                  //and PurchaseOrder__r.Distributor__r.DistributorConnected__c= true WCH 21/07/2022 C-004762
                                  and PurchaseOrder__r.TECH_OrderLines__c != 0
                                  and PurchaseOrder__r.Assessment__r.DisableUpdateStockInfo__c = false]){//RLA 16/05/2019 Case 003145 Spare part Recovery SAS France

                
                
                //NPE 08/02/2022 C-004587: Send default value on PO's First Registration Date field for OrderMakeSelection calls to SAS if value is NULL 
                
                if(ol.PurchaseOrder__r.Assessment__r.FirstRegistrationDate__c ==null){
                    ol.PurchaseOrder__r.Assessment__r.FirstRegistrationDate__c=  date.parse('01/01/1900');
                }


                assRecord  = ol.PurchaseOrder__r.Assessment__r;
                objReference = assRecord.Name;

                //WCH 21/07/2022 C-004762
                if(ol.PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c.contains('Distributor Connected') && ol.PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c.contains('Draft Call')){
                    if(ol.PartList__c != null && !partMap.containsKey(ol.PartList__c)){
                        partMap.put(ol.PartList__c, ol.PartList__r);
                    }

                    if(ol.PurchaseOrder__c != null && !mapDistributorNameDistributor.containsKey(ol.PurchaseOrder__r.Distributor__r.Tech_Distributor__c)){
                        mapDistributorNameDistributor.put(ol.PurchaseOrder__r.Distributor__r.Tech_Distributor__c,ol.PurchaseOrder__r.Distributor__r);
                    }

                    if(ol.PurchaseOrder__c != null && !mapPOExtIDPO.containsKey(ol.PurchaseOrder__r.Tech_ExternalId__c)){
                        mapPOExtIDPO.put(ol.PurchaseOrder__r.Tech_ExternalId__c,ol.PurchaseOrder__r);
                    }
                }else{
                    if(ol.PartList__c != null && !partMap.containsKey(ol.PartList__c)){
                        partMapNonConnected.put(ol.PartList__c, ol.PartList__r);
                        olMapPartNonConnected.put(ol.Id,ol.PartList__c);
                        olMapNonConnected.put(ol.Id,ol);
                    }
                }

            }


            system.debug('## assRecord ' + assRecord);
            system.debug('## partMap ' + partMap);
            system.debug('## distributorLst ' + distributorLst);
            system.debug('## mapDistributorNameDistributor ' + mapDistributorNameDistributor);
            system.debug('## mapPOExtIDPO ' + mapPOExtIDPO);

            //build ws request
            //ASE: 23/11/17 : phase pilote 
            // no call made if DistributorConnected__c on BS is false
            if(assRecord != null && assRecord.BodyShop__r.DistributorConnected__c && !mapDistributorNameDistributor.isEmpty()){
                //DUN 22/06/2018 Bug on logs when partlist size on assessment is greater than 200  
                //wsRequest =  RestDistributorUtility.buildDistributorRequest(assRecord, distributorLst, partMap);
                wsRequest =  RestDistributorUtility.buildDistributorRequest(assRecord, mapDistributorNameDistributor.values(), partMap);
                // return ''; //RLA to remove
            }
            else{
                //no connected distributors,therefore no call out must be made
                return '';
            }
            system.debug('## wsRequest ' + wsRequest);

            //make call out
            HttpResponse response                                                           = new HttpResponse();
            Http http                                                                       = new http();
            HttpRequest request                                                             = new HttpRequest();
            String message = '';
            
            //WCH 18/08/2020 C-003864
            Map<String, Object> requestEIPEndpoint = new Map<String, Object>{'EIP_EndPoint' => 'authenticate'};
            Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(requestEIPEndpoint);

            if(string.isNotBlank((String)responseEIPEndpoint.get('EIP_EndPoint')) && string.isNotBlank(wsRequest)){ //WCH 18/08/2020 C-003864

                wsResponse = OrderMakeSelection.makeDraftCall(wsRequest, mapDistributorNameDistributor, assRecord.Id, mapPOExtIDPO, partMap, false, 'OrderR4', 'NonAxaOrdering',''); 

               
            }
        }//end if string.isNotBlank(assId)

        //WCH 19/07 C-004762
        ProcessNonConnectedParts(new Map<Id, OrderLine__c>(),assRecord,partMapNonConnected,olMapPartNonConnected,olMapNonConnected);

        system.debug('## End updateStockInfo');
        return wsResponse;
    }
    //WCH 19/07 C-004762
    Public static void ProcessNonConnectedParts(Map<Id, OrderLine__c> mapOriginalOlRecoveredOL1,Assessment__c currentAssessment,map <Id, PartList__c> allNonConnectedPartsMap,map <Id, Id> olPartNonConnectedMap,map <Id, OrderLine__c> allNonConnectedOLsMap){
        system.debug('## Start ProcessNonConnectedParts');
        Map<String,OrderLine__c> allOLUniqueKey = new Map<String,OrderLine__c>();
        Map<String,String> uniqueMapFamilyKey = new Map<String,String>();
        Map<String,Discount__c> familyMapDiscountObj = new Map<String,Discount__c>();
        String currentBrand=currentAssessment.Manufacturer__c;
        Map<Id,OrderLine__c> mapOLToUpdate = new Map<Id,OrderLine__c>();

        for(OrderLine__c currentOL : [select Id,PartList__r.PartNumber__c from Orderline__c where Id in:mapOriginalOlRecoveredOL1.keySet() and PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c excludes ('Distributor Connected;Draft Call')]){
            allNonConnectedOLsMap.put(currentOL.Id,currentOL);
        }

        //loop in allPartsMap put in map all OL with non connected distributor + put in list uniquekey
        for(Id currentOLId : allNonConnectedOLsMap.KeySet()){
            allOLUniqueKey.put(currentBrand+ASPISServiceSubstitution.cleanseReference(allNonConnectedOLsMap.get(currentOLId).PartList__r.PartNumber__c),allNonConnectedOLsMap.get(currentOLId));
        }
        
        //query table Referentiel OEM get family key
        for(OEMReferentiel__c refOEMLst : [select FamilyKey__c,UniqueKey__c from OEMReferentiel__c where UniqueKey__c in:allOLUniqueKey.keySet() and isActive__c=true]){
            uniqueMapFamilyKey.put(refOEMLst.UniqueKey__c,refOEMLst.FamilyKey__c);
        }

        //query table discount, get as discount and BS discount for each OL and update OL
        for(Discount__c discountOEMLst : [select AS_Discount__c,BSdiscount__c,FamilyKey__c from Discount__c where recordtype.developername='DiscountOEM' and FamilyKey__c in:uniqueMapFamilyKey.values()]){
            familyMapDiscountObj.put(discountOEMLst.FamilyKey__c,discountOEMLst);
        }
        //set OL details
        for(Id currentOLId : allNonConnectedOLsMap.keySet()){
            String currentUniqueKey = currentBrand+ASPISServiceSubstitution.cleanseReference(allNonConnectedOLsMap.get(currentOLId).PartList__r.PartNumber__c);
            if(uniqueMapFamilyKey.containsKey(currentUniqueKey) && familyMapDiscountObj.containsKey(uniqueMapFamilyKey.get(currentUniqueKey))){
                Orderline__c OLToModify = new Orderline__c(
                    Id = currentOLId,
                    AXADiscount__c=familyMapDiscountObj.get(uniqueMapFamilyKey.get(currentUniqueKey)).AS_Discount__c,
                    BodyShopDiscount__c=familyMapDiscountObj.get(uniqueMapFamilyKey.get(currentUniqueKey)).BSdiscount__c

                );
                mapOLToUpdate.put(currentOLId,OLToModify);
            }
        }
        system.debug('mapOLToUpdate>>'+mapOLToUpdate);
        //update all non connected OL 
        if(!mapOLToUpdate.isEmpty()){
            update mapOLToUpdate.values();
        }
    }
    public PageReference back()
    {
        hasErrors = false;
        isToastError = false;

        try
        {
            list<PrerequisiteOrder__c> listPreAcceptanceSO = [SELECT  Id 
                                                             FROM    PrerequisiteOrder__c 
                                                             WHERE   Assessment__c =: currentClaimOrderAssessment.Id
                                                             AND     Status__c = 'PREACCEPTANCE'];
            if(listPreAcceptanceSO.size() > 0)
            {
                List<PurchaseOrder__c> purchaseOrderToDeleteList = [SELECT  Id 
                                                                    FROM    PurchaseOrder__c 
                                                                    WHERE   Assessment__c =: currentClaimOrderAssessment.Id];
                delete purchaseOrderToDeleteList;

                List<PrerequisiteOrder__c> salesOrderToDeleteList = [SELECT  Id 
                                                                     FROM    PrerequisiteOrder__c 
                                                                     WHERE   Assessment__c =: currentClaimOrderAssessment.Id];
                delete salesOrderToDeleteList;

                Assessment__c currentAssessmentToDelete = [ SELECT  Id
                                                            FROM    Assessment__c 
                                                            WHERE   Id =: currentClaimOrderAssessment.Id];
                delete currentAssessmentToDelete;
            }

            return new PageReference('/apex/OrderChooseAssessment?AssessmentId=' + (((encryptedSourceAssessmentId != null) && (encryptedAssessmentId != encryptedSourceAssessmentId)) ? encryptedSourceAssessmentId : encryptedAssessmentId));
        }
        catch(DmlException e)
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
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }
        }
        catch (Exception e)
        {
            hasErrors = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,  e.getMessage() + ' : ' + e.getStackTraceString()));
        }

        return null;
    }



    public static Boolean isNonAxaAllowed (Map<String, Object> mapParams){


        Boolean isAllowed = false;

        String country = (mapParams.get('country') != null && mapParams.get('country') != '') ? (String.valueOf(mapParams.get('country'))).toUpperCase() : null;

        Boolean nonAxaAuthorised = (mapParams.get('nonAxaAuthorised') != null && mapParams.get('nonAxaAuthorised') != '') ? (Boolean.valueOf(mapParams.get('nonAxaAuthorised'))) : false;
        system.debug('@@@@  isNonAxaAllowed start'+nonAxaAuthorised);


        String feature = (mapParams.get('feature') != null && mapParams.get('feature') != '') ? (String.valueOf(mapParams.get('feature'))).toUpperCase() : null;

        String entity = (mapParams.get('entity') != null && mapParams.get('entity') != '') ? (String.valueOf(mapParams.get('entity'))).toUpperCase() : null;

        String fromProcess = (mapParams.get('fromProcess') != null && mapParams.get('fromProcess') != '') ? (String.valueOf(mapParams.get('fromProcess'))).toUpperCase() : null;

        list<NonAxaOrdering__mdt> listNonAxaOrdering = new list<NonAxaOrdering__mdt>();

        if ( String.isnotblank(fromProcess)){
           if (string.isnotBlank(entity) && fromProcess.contains('ORDER')){
                isAllowed = entity.contains('NONAXA')  ? true : false;
           }    
        }
        system.debug('@@@ fromProcess: '+fromProcess);
        system.debug('@@@ entity: '+entity);
        system.debug('@@@ isAllowed: '+isAllowed);
        system.debug('@@@ feature: '+feature);
       
        if (isAllowed){
             For (NonAxaOrdering__mdt nonAxa: [SELECT DeveloperName,Active__c,Create_Subs_on_Upsert__c,Label
                                                                    FROM NonAxaOrdering__mdt
                                                                    where MasterLabel = :country
                                                                            and  Active__c = true ] ){
                listNonAxaOrdering.add(nonAxa);
            }

            if (listNonAxaOrdering.size() > 0){
                if (listNonAxaOrdering[0].Active__c){
             return true;
        }
        else{
            return false;
        }
    }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    }

     public static String decryptBase64(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();

        return decryptedText;
    }

    public static String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }

    public void toggleIsAcceptedForCheapest(){
        system.debug('@@@ here toggleIsAcceptedForCheapest');
        toggleValueCheapest = false;
        toggleValueOEM = false;
    }

    // public void toggleButtonSelectOEM(){
    //     system.debug('@@@ here');

    // }

    public PageReference order()
    {
        hasErrors       = false;
        isToastError    = false;

        // checking if the salesOrder has already been responded
        List<PrerequisiteOrder__c> respondedSalesOrderList =    [SELECT Id, Status__c, Assessment__r.Name
                                                                 FROM   PrerequisiteOrder__c
                                                                 WHERE  Assessment__c =: currentClaimOrderAssessment.Id
                                                                 AND    (Status__c =: ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE
                                                                        OR  Status__c =: ASPISConstants.PRE_ORDER_STATUS_RESPONDED)];

        objReference = currentClaimOrderAssessment.Name;
        if(respondedSalesOrderList.size() > 0)
        {
            hasErrors       = true;
            isToastError    = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'The parts has already been ordered.'));
            return null;
        }

        SavePoint beforeDML;
        try
        {
            beforeDML                                           = Database.setSavepoint();

            List<Offer__c> offerToUpdateList                    = new List<Offer__c>();
            Map<Id, OrderLine__c> mapOrderLineToUpdate          = new Map<Id, OrderLine__c>();
            Map<Id, PartList__c> mapPartToUpdate                = new Map<Id, PartList__c>();
            Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdate  = new Map<Id, PurchaseOrder__c>();
            Map<Id, PrerequisiteOrder__c> mapSalesOrderToUpdate = new Map<Id, PrerequisiteOrder__c>();
            Map<Id, Assessment__c> mapAssessmentToUpdate        = new Map<Id, Assessment__c>();
            //RLA 08-11-2019  C-003411 : Agency Mode V3
            Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdateAgencyV3  = new Map<Id, PurchaseOrder__c>();


            //AMI 14/09/17 - get cross reference info in order to send IAM Manufacturer for ascr only
            set <id> setPartsToQuery                            = new set <id>();
            map <id,CrossReference__c> mapPartIdCrossRef        = new map <id,CrossReference__c>();

            //get cross reference info in order to send IAM PartNumber for ascr only
            map <id,CrossReference__c> mapPartIdCrossRefForPN   = new map <id,CrossReference__c>();

            // ASE: 14/11/17 C-002072
            set<Id> OLIdSet = new set<Id>();
            map<Id, Orderline__c> oriAltOLMap = new map<Id, Orderline__c>();

            //ASE 23/11/17  : phase pilote: pas d'appel si BodyShop__c.DistributorConnected__c = false
            Assessment__c BS = [Select BodyShop__r.DistributorConnected__c from Assessment__c where id =:currentClaimOrderAssessment.Id];
            Boolean connectedBS = BS.BodyShop__r.DistributorConnected__c;

            //AMI 22/10/2018  C-002781 : Migrate Spain to R4
            //                         : Adding possibility to add cancel reason when offer is not accepted
            //                         : save cancel reason
            for(PartWrapper currentPartWrapper : mapPartWrapper.values())
            {
                for(DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values())
                {
                    for(OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values())
                    {
                        if(currentOfferWrapper.isAccepted)
                        {
          
                            system.debug('@@currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c accepted: '+currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c);
                            system.debug('## currentOfferWrapper.isAccepted:'+currentOfferWrapper.isAccepted);

                            // ASE: 14/11/17 C-002072 populateSet to check if OL has alernative or not                            
                            OLIdSet.add(currentOfferWrapper.parentOffer.OrderLine__c);
                            
                            //AMI 05/09/17 - Distributor Integration
                            if(RestDistributorUtility.isConnectedDist(currentDistributorWrapper.currentDistributor.Type_of_Substitutes__c) &&
                                RestDistributorUtility.canMakeOrderCall(currentDistributorWrapper.currentDistributor.Type_of_Substitutes__c) &&
                                /* ASE : 19/02/18: case C-002236*/
                                currentDistributorWrapper.currentDistributor.OrderRequest__c == 'OrderR4' &&   
                                 (currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                  currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY')){

                                    //AMI 11/09/17 
                                    //SAS Status            | Envoi lors de l'order à SAS
                                    //Confirmed             | OUI  
                                    //Confirmed with Delay  | OUI
                                    //Not Found             | NON
                                    //Other                 | NON
                                    //Partial               | NON
                                    //Refused               | NON 
                                    
                                    setPartsToQuery.add(currentPartWrapper.currentPart.Id);

                                    //AMI 05/12/17 : add Tech_Distributor__c as key instead of distributor name

                                    system.debug('£ mapDistNamePartList : ' + mapDistNamePartList);
                                    system.debug('£ currentDistributorWrapper.currentDistributor' + currentDistributorWrapper.currentDistributor);

                                    if(mapDistNamePartList.containsKey(currentDistributorWrapper.currentDistributor.Tech_Distributor__c)){
                                        mapDistNamePartList.get(currentDistributorWrapper.currentDistributor.Tech_Distributor__c).add(new orderingPartWrapper(currentPartWrapper.currentPart,
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Name,
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                currentOfferWrapper.quantity,
                                                                                                                                                // ASE : 10/01/18 : C-002178
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c,
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.Assessment__c,
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,
                                                                                                                                                currentOfferWrapper.parentOffer.PrerequisiteOrder__c)); 
                                    }else{
                                        mapDistNamePartList.put(currentDistributorWrapper.currentDistributor.Tech_Distributor__c,new list <orderingPartWrapper>{new orderingPartWrapper(currentPartWrapper.currentPart,
                                                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Name,
                                                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                                             currentOfferWrapper.quantity,
                                                                                                                                                                            // ASE : 10/01/18 : C-002178
                                                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c,
                                                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.Assessment__c,
                                                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,
                                                                                                                                                                            currentOfferWrapper.parentOffer.PrerequisiteOrder__c)});
                                    }
                            }

                            // OFFER
                            offerToUpdateList.add(new Offer__c( Id              = currentOfferWrapper.parentOffer.Id,
                                                                Accepted__c     = 'YES',
                                                                Suppliable__c   = true,
                                                                Type__c         = '')); 
                            
                            // Loop in child offers if present
                            if(currentOfferWrapper.childOfferList.size() > 0)
                            {
                                for(BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
                                {
                                    offerToUpdateList.add(new Offer__c( Id              = currentBundleWrapper.bundleItem.Id,
                                                                        Accepted__c     = 'YES',
                                                                        Suppliable__c   = true,
                                                                        Type__c         = ''));
                                }
                            }

                            // ORDER LINE
                            mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__c, new OrderLine__c(Id                      = currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                    Suppliable__c           = 'YES',
                                                                                                                    AcceptedCheck__c        = true,
                                                                                                                    PreselectedForOrder__c  = true,
                                                                                                                    Quantity__c             = currentOfferWrapper.quantity));
                            
                            if(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                            {
                                mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                  = currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                                        Suppliable__c       = 'YES',
                                                                                                                                        AcceptedCheck__c    = true,
                                                                                                                                        PreselectedForOrder__c  = true));
                            }

                            //// ASE : 19/01/2018: C-002152: commenting creation of ADD-P /////
                            
                            // PART LIST
                            // ASE: 14/11/17 C-002072 : No need to update the quantity Ordered for additional part on claim
                            // DUN 13/03/2018 C-002384 : Bug BE : Pièces déjà commandés n'apparaissent pas dans la R4
                            if(currentPartWrapper.currentPart.PartNumber__c != system.label.AdditionalPartNumber){
                                mapPartToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c, new PartList__c(Id                     = currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c,
                                                                                                                                          //Ordered__c             = true,
                                                                                                                                          TECH_OrderedCounter__c = (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c != null ? (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c + 1) : 1),
                                                                                                                                          QuantityOrdered__c     = currentOfferWrapper.quantity));
                            }
                            /////////
                            // PURCHASE ORDER
                            if(!mapPurchaseOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c))
                            {
                                // if(careOrderSwitch == 'ON')
                                // {
                                    mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                    BodyShopOrderNumber__c = bodyShopOrderNumber,
                                                                                                                                                    Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE));
                                // }
                                // else
                                // {
                                //     mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                //                                                                                                                     BodyShopOrderNumber__c = bodyShopOrderNumber,
                                //                                                                                                                     Status__c = ASPISConstants.PUR_ORDER_STATUS_ISSUED));
                                // }
                            }
                            else
                            {
                                if(mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED)
                                {
                                    // if(careOrderSwitch == 'ON')
                                    // {
                                        mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
                                    // }
                                    // else
                                    // {
                                    //     mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c = ASPISConstants.PUR_ORDER_STATUS_ISSUED;
                                    // }

                                    mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Reason__c = '';
                                    mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).BodyShopOrderNumber__c = bodyShopOrderNumber;
                                }
                            }
                            system.debug('@@@ here'+mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c);

                             // PURCHASE ORDER //RLA 08-11-2019  C-003411 : Agency Mode V3
                            if( mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                                && !mapPurchaseOrderToUpdateAgencyV3.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c)
                                && CountryCodeInformationsMapping__c.getall().containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c) 
                                && CountryCodeInformationsMapping__c.getall().get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c).AgencyModeAutomaticDelivery__c
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.AgencyMode__c 
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Agency_V3__c
                                )
                            {
                                system.debug('@@@ here agency mode');
                                mapPurchaseOrderToUpdateAgencyV3.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED));
                            }


                            // SALES ORDER
                            if(!mapSalesOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.PrerequisiteOrder__c))
                            {
                                // if(careOrderSwitch == 'ON')
                                // {
                                    mapSalesOrderToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__c, new PrerequisiteOrder__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__c,
                                                                                                                                            Status__c = ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE,
                                                                                                                                            BodyShop__c   = currentClaimOrderAssessment.BodyShop__c));
                                // }
                                // else
                                // {
                                //     mapSalesOrderToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__c, new PrerequisiteOrder__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__c,
                                //                                                                                                             Status__c = ASPISConstants.PRE_ORDER_STATUS_RESPONDED));
                                // }
                            }


                            // ASSESSMENT
                            if(!mapAssessmentToUpdate.containsKey(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c))
                            {
                                
                                mapAssessmentToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c, new Assessment__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c,
                                                                                                                                                Comment__c = assessmentComment,
                                                                                                                                                /*DUN Commented: force care order switch to "on" and hide it  as long as distributors are not connected in real time with ASPIS(100)
                                                                                                                                                IsCareOrder__c = (careOrderSwitch == 'ON') ? true : false,
                                                                                                                                                OrderStatus__c = (careOrderSwitch == 'ON') ? 'PENDING DISTRIBUTOR (CARE)' : 'PENDING DISTRIBUTOR'*/
                                                                                                                                                IsCareOrder__c = true,
                                                                                                                                                OrderStatus__c = 'PENDING DISTRIBUTOR (CARE)',
                                                                                                                                                // ABT - 24-APR-2017 - C-001660 - Clearing the deletion date
                                                                                                                                                ShortTermDeletionDate__c = null,
                                                                                                                                                BodyShop__c    = currentClaimOrderAssessment.BodyShop__c));
                                // Clearing the claim assessment....also to be coherent with OrderRunSourcing                                                                                                                                                
                                mapAssessmentToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__c, new Assessment__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__c,
                                                                                                                                                                    ShortTermDeletionDate__c = null
                                                                                                                                                                    //,LongTermDeletionDate__c = null //RLA C-2002 Commented by RLA to remove later 
                                                                                                                                                                    ));
                            }
                        }
                        else
                        {
                            system.debug('@@currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c accepted: '+currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c);

                            //AMI 22/10/2018  C-002781 : Migrate Spain to R4
                            //                         : Adding possibility to add cancel reason when offer is not accepted
                            //                         : save cancel reason
                            offerToUpdateList.add(new Offer__c( Id                      = currentOfferWrapper.parentOffer.Id,
                                                                Accepted__c             = 'NO',
                                                                Suppliable__c           = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? true :
                                                                                            ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? false : true,
                                                                PreselectedForOrder__c  = false,
                                                                Type__c                 = '',
                                                                CancelReason__c         = currentOfferWrapper.parentOffer.CancelReason__c));

                            // Loop in child offers if present
                            if(currentOfferWrapper.childOfferList.size() > 0)
                            {
                                for(BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
                                {
                                    offerToUpdateList.add(new Offer__c( Id                      = currentBundleWrapper.bundleItem.Id,
                                                                        Accepted__c             = 'NO',
                                                                        Suppliable__c           = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? true :
                                                                                                    ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? false : true,
                                                                        PreselectedForOrder__c  = false,
                                                                        Type__c                 = ''));
                                }
                            }

                            mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__c, new OrderLine__c(Id                  = currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                    Suppliable__c       = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? 'YES' :
                                                                                                                                            ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                            currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? 'NO' : 'YES',
                                                                                                                    AcceptedCheck__c    = false));
                            
                            if(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                            {
                                mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                  = currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                                        Suppliable__c       = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? 'YES' :
                                                                                                                                                                ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? 'NO' : 'YES',
                                                                                                                                        AcceptedCheck__c    = false));
                            }

                            // PURCHASE ORDER
                            if(!mapPurchaseOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c))
                            {
                                mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id         = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                 Status__c  = ASPISConstants.PUR_ORDER_STATUS_CANCELED,
                                                                                                                                                 Reason__c  = 'NOTSELECTED'));
                            }
                        }
                    }
                }

                for ( PartWrapper currentSubsWrapper: currentPartWrapper.partSubstitutes){
                    system.debug('% current currentSubsWrapper :'+  currentSubsWrapper);
                    for(DistributorWrapper currentDistributorWrapper : currentSubsWrapper.mapDistributorWrapper.values())
                    {
                        system.debug('% current currentDistributorWrapper :'+  currentDistributorWrapper);
                        for(OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values())
                        {
                            system.debug('% current offer wrapper :'+  currentOfferWrapper);
                            if(currentOfferWrapper.isAccepted)
                            {
                                // ASE: 14/11/17 C-002072 populateSet to check if OL has alernative or not                            
                                OLIdSet.add(currentOfferWrapper.parentOffer.OrderLine__c);
                                system.debug('## currentDistributorWrapper.currentDistributor.OrderRequest__c:'+currentDistributorWrapper.currentDistributor.OrderRequest__c);
                                
                                //AMI 05/09/17 - Distributor Integration
                                if(RestDistributorUtility.isConnectedDist(currentDistributorWrapper.currentDistributor.Type_of_Substitutes__c) &&
                                    RestDistributorUtility.canMakeOrderCall(currentDistributorWrapper.currentDistributor.Type_of_Substitutes__c) &&
                                    /* ASE : 19/02/18: case C-002236*/
                                    currentDistributorWrapper.currentDistributor.OrderRequest__c == 'OrderR4' &&   
                                    (currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                    currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY')){

                                        //AMI 11/09/17 
                                        //SAS Status            | Envoi lors de l'order à SAS
                                        //Confirmed             | OUI  
                                        //Confirmed with Delay  | OUI
                                        //Not Found             | NON
                                        //Other                 | NON
                                        //Partial               | NON
                                        //Refused               | NON 
                                        
                                        setPartsToQuery.add(currentSubsWrapper.currentPart.Id);

                                        //AMI 05/12/17 : add Tech_Distributor__c as key instead of distributor name
                                        if(mapDistNamePartList.containsKey(currentDistributorWrapper.currentDistributor.Tech_Distributor__c)){
                                            mapDistNamePartList.get(currentDistributorWrapper.currentDistributor.Tech_Distributor__c).add(new orderingPartWrapper(currentSubsWrapper.currentPart,
                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Name,
                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                    currentOfferWrapper.quantity,
                                                                                                                                                    // ASE : 10/01/18 : C-002178
                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c,
                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.Assessment__c,
                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,
                                                                                                                                                    currentOfferWrapper.parentOffer.PrerequisiteOrder__c)); 
                                        }else{
                                            mapDistNamePartList.put(currentDistributorWrapper.currentDistributor.Tech_Distributor__c,new list <orderingPartWrapper>{new orderingPartWrapper(currentSubsWrapper.currentPart,
                                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Name,
                                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                                                currentOfferWrapper.quantity,
                                                                                                                                                                                // ASE : 10/01/18 : C-002178
                                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PartNumber__c,
                                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.Assessment__c,
                                                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,
                                                                                                                                                                                currentOfferWrapper.parentOffer.PrerequisiteOrder__c)});
                                        }
                                }

                                // OFFER
                                offerToUpdateList.add(new Offer__c( Id              = currentOfferWrapper.parentOffer.Id,
                                                                    Accepted__c     = 'YES',
                                                                    Suppliable__c   = true,
                                                                    Type__c         = ''));
                                
                                // Loop in child offers if present
                                if(currentOfferWrapper.childOfferList.size() > 0)
                                {
                                    for(BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
                                    {
                                        offerToUpdateList.add(new Offer__c( Id              = currentBundleWrapper.bundleItem.Id,
                                                                            Accepted__c     = 'YES',
                                                                            Suppliable__c   = true,
                                                                            Type__c         = ''));
                                    }
                                }

                                // ORDER LINE
                                mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__c, new OrderLine__c(Id                      = currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                        Suppliable__c           = 'YES',
                                                                                                                        AcceptedCheck__c        = true,
                                                                                                                        PreselectedForOrder__c  = true,
                                                                                                                        Quantity__c             = currentOfferWrapper.quantity));
                                
                                if(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                                {
                                    mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                  = currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                                            Suppliable__c       = 'YES',
                                                                                                                                            AcceptedCheck__c    = true,
                                                                                                                                            PreselectedForOrder__c  = true));
                                }

                                //// ASE : 19/01/2018: C-002152: commenting creation of ADD-P /////
                                
                                // PART LIST
                                // ASE: 14/11/17 C-002072 : No need to update the quantity Ordered for additional part on claim
                                // DUN 13/03/2018 C-002384 : Bug BE : Pièces déjà commandés n'apparaissent pas dans la R4
                                if(currentSubsWrapper.currentPart.PartNumber__c != system.label.AdditionalPartNumber){
                                    mapPartToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c, new PartList__c(Id                     = currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c,
                                                                                                                                            //Ordered__c             = true,
                                                                                                                                            TECH_OrderedCounter__c = (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c != null ? (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c + 1) : 1),
                                                                                                                                            QuantityOrdered__c     = currentOfferWrapper.quantity));
                                }
                                /////////
                                // PURCHASE ORDER
                                if(!mapPurchaseOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c))
                                {
                                    // if(careOrderSwitch == 'ON')
                                    // {
                                        mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                        BodyShopOrderNumber__c = bodyShopOrderNumber,
                                                                                                                                                        Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE));
                                    // }
                                    // else
                                    // {
                                    //     mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                    //                                                                                                                     BodyShopOrderNumber__c = bodyShopOrderNumber,
                                    //                                                                                                                     Status__c = ASPISConstants.PUR_ORDER_STATUS_ISSUED));
                                    // }
                                }
                                else
                                {
                                    if(mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_CANCELED)
                                    {
                                        // if(careOrderSwitch == 'ON')
                                        // {
                                            mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
                                        // }
                                        // else
                                        // {
                                        //     mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c = ASPISConstants.PUR_ORDER_STATUS_ISSUED;
                                        // }

                                        mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Reason__c = '';
                                        mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).BodyShopOrderNumber__c = bodyShopOrderNumber;
                                    }
                                }
                                system.debug('@@@ here'+mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c);

                                // PURCHASE ORDER //RLA 08-11-2019  C-003411 : Agency Mode V3
                                if( mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                                    && !mapPurchaseOrderToUpdateAgencyV3.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c)
                                    && CountryCodeInformationsMapping__c.getall().containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c) 
                                    && CountryCodeInformationsMapping__c.getall().get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c).AgencyModeAutomaticDelivery__c
                                    && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.AgencyMode__c 
                                    && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Agency_V3__c
                                    )
                                {
                                    system.debug('@@@ here agency mode');
                                    mapPurchaseOrderToUpdateAgencyV3.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                    Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED));
                                }


                                // SALES ORDER
                                if(!mapSalesOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.PrerequisiteOrder__c))
                                {
                                    // if(careOrderSwitch == 'ON')
                                    // {
                                        mapSalesOrderToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__c, new PrerequisiteOrder__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__c,
                                                                                                                                                Status__c = ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE,
                                                                                                                                                BodyShop__c   = currentClaimOrderAssessment.BodyShop__c));
                                    // }
                                    // else
                                    // {
                                    //     mapSalesOrderToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__c, new PrerequisiteOrder__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__c,
                                    //                                                                                                             Status__c = ASPISConstants.PRE_ORDER_STATUS_RESPONDED));
                                    // }
                                }


                                // ASSESSMENT
                                if(!mapAssessmentToUpdate.containsKey(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c))
                                {
                                    
                                    mapAssessmentToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c, new Assessment__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c,
                                                                                                                                                    Comment__c = assessmentComment,
                                                                                                                                                    /*DUN Commented: force care order switch to "on" and hide it  as long as distributors are not connected in real time with ASPIS(100)
                                                                                                                                                    IsCareOrder__c = (careOrderSwitch == 'ON') ? true : false,
                                                                                                                                                    OrderStatus__c = (careOrderSwitch == 'ON') ? 'PENDING DISTRIBUTOR (CARE)' : 'PENDING DISTRIBUTOR'*/
                                                                                                                                                    IsCareOrder__c = true,
                                                                                                                                                    OrderStatus__c = 'PENDING DISTRIBUTOR (CARE)',
                                                                                                                                                    // ABT - 24-APR-2017 - C-001660 - Clearing the deletion date
                                                                                                                                                    ShortTermDeletionDate__c = null,
                                                                                                                                                    BodyShop__c    = currentClaimOrderAssessment.BodyShop__c));
                                    // Clearing the claim assessment....also to be coherent with OrderRunSourcing                                                                                                                                                
                                    mapAssessmentToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__c, new Assessment__c(Id = currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__c,
                                                                                                                                                                        ShortTermDeletionDate__c = null
                                                                                                                                                                        //,LongTermDeletionDate__c = null //RLA C-2002 Commented by RLA to remove later 
                                                                                                                                                                        ));
                                }
                            }
                            else
                            {
                                system.debug('£ currentOfferWrapper.parentOffer' + currentOfferWrapper.parentOffer);
                                //AMI 22/10/2018  C-002781 : Migrate Spain to R4
                                //                         : Adding possibility to add cancel reason when offer is not accepted
                                //                         : save cancel reason
                                offerToUpdateList.add(new Offer__c( Id                      = currentOfferWrapper.parentOffer.Id,
                                                                    Accepted__c             = 'NO',
                                                                    Suppliable__c           = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? true :
                                                                                                ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? false : true,
                                                                    PreselectedForOrder__c  = false,
                                                                    Type__c                 = '',
                                                                    CancelReason__c         = currentOfferWrapper.parentOffer.CancelReason__c));

                                // Loop in child offers if present
                                if(currentOfferWrapper.childOfferList.size() > 0)
                                {
                                    for(BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
                                    {
                                        offerToUpdateList.add(new Offer__c( Id                      = currentBundleWrapper.bundleItem.Id,
                                                                            Accepted__c             = 'NO',
                                                                            Suppliable__c           = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? true :
                                                                                                        ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? false : true,
                                                                            PreselectedForOrder__c  = false,
                                                                            Type__c                 = ''));
                                    }
                                }

                                mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__c, new OrderLine__c(Id                  = currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                        Suppliable__c       = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? 'YES' :
                                                                                                                                                ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                                currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? 'NO' : 'YES',
                                                                                                                        AcceptedCheck__c    = false));
                                
                                if(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                                {
                                    mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                  = currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                                            Suppliable__c       = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? 'YES' :
                                                                                                                                                                    ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? 'NO' : 'YES',
                                                                                                                                            AcceptedCheck__c    = false));
                                }

                                // PURCHASE ORDER
                                if(!mapPurchaseOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c))
                                {
                                    mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id         = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                    Status__c  = ASPISConstants.PUR_ORDER_STATUS_CANCELED,
                                                                                                                                                    Reason__c  = 'NOTSELECTED'));
                                }
                            }
                        }
                    }

                }
            }

            // ASE: 14/11/17 C-002072
            if(OLIdSet.size() > 0){
                for(OrderLine__c ol : [Select Id, OriginalItem__c, PartNumber__c, Quantity__c, Type__c, Description__c from OrderLine__c where OriginalItem__c in :OLIdSet and TechGeneratedFinal__c = false]){
                    oriAltOLMap.put(ol.OriginalItem__c, ol);
                }
            }

            //AMI 05/09/17 - Distributor Integration
            //build order request to send to distributor
            system.debug('## mapDistNamePartList ' + mapDistNamePartList);
            system.debug('## connectedBS ' + connectedBS);

            if(connectedBS && !mapDistNamePartList.isEmpty()){
                map <string,object> distributorObj = new map <string,object>();
                map <id,Account> mapBodyshop = new map <id,Account>();
                // ase 28/02/17: C-002337
                set <id> sentOlIdSet = new set <id>();

                RestDistributorUtility.BodyShop BodyShop;
                RestDistributorUtility.Vehicle Vehicle;
                OrderMakeSelection.mainRequest mainRequest;

                // add additionalParts
                map<String, OrderLine__c> distOLMap = addAdditionalParts(mapDistNamePartList);                

                string finalOrderReq = '';  

                //build mapPartIdCrossRef
                //AMI 12/10/17 : SAS : Envoyer l'IAMManufacturer des pièces issues de la substitution que pour les pièces de type autre que A
                for(PartList__c pt : [select id,CrossReferenceId__c,CrossReferenceId__r.IAMPartNumber__c,CrossReferenceId__r.IAMManufacturer__c,Type__c
                                        from PartList__c
                                        where id IN :setPartsToQuery
                                        and CrossReferenceId__c != null]){
                    if(pt.Type__c != 'A'){
                        mapPartIdCrossRef.put(pt.id,new CrossReference__c(id = pt.CrossReferenceId__c,
                                                                           IAMManufacturer__c = pt.CrossReferenceId__r.IAMManufacturer__c));
                    }
                    
                    mapPartIdCrossRefForPN.put(pt.id,new CrossReference__c(id = pt.CrossReferenceId__c,
                                                                            IAMPartNumber__c = pt.CrossReferenceId__r.IAMPartNumber__c));
                }
                system.debug('## mapPartIdCrossRef: '+ mapPartIdCrossRef);
                system.debug('## mapPartIdCrossRefForPN: '+ mapPartIdCrossRefForPN);


                if(currentClaimOrderAssessment.BodyShop__c != null){
                    mapBodyshop = new map <id,Account>([select id,Name,VATNumber__c,ReferenceNumber__c,Tech_Distributor__c
                                                        from Account
                                                        where id = :currentClaimOrderAssessment.BodyShop__c]);
                }

                //RLA 31/10/2020 C-004018: IG - Efa requirements
                Integer i = 0;

                for(string distName : mapDistNamePartList.keySet()){
                    //build parts to be asscoiated with each distributor
                    list <RestDistributorUtility.Parts> tempSuppliedParts = new list <RestDistributorUtility.Parts>(); 
                    //RLA 31/10/2020 C-004018: IG - Efa requirements
                    i++;
                    String sequenceID = String.valueOf(i);


                    //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor  
                    String techDist =  mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).Tech_Distributor__c;
                    String distBrand = techDist +'-'+ (currentClaimOrderAssessment.Manufacturer__c).toUpperCase();
                    String brandName = RestDistributorUtility.getCarMappingsMatrix(distBrand);
                    system.debug('## brandName:'+brandName);
                    
                    if ( String.isBlank(brandName)){
                        brandName =  string.isNotBlank(currentClaimOrderAssessment.Manufacturer__c) ? currentClaimOrderAssessment.Manufacturer__c : '';  
                    }
                    system.debug('## brandName:'+brandName);
                    for(orderingPartWrapper orWrap : mapDistNamePartList.get(distName)){
                        //build setPOToUpdate to update in case of errors
                        setPOToUpdate.add(orWrap.POId);

                        system.debug('## orWrap.OLId:'+orWrap.OLId);
                        //build tempSuppliedParts
                        // ASE: 14/11/17 C-002072
                        if(oriAltOLMap.containsKey(orWrap.OLId)){
                            Orderline__c altOl  = oriAltOLMap.get(orWrap.OLId);
                            system.debug('## altOl.PartNumber__c:'+altOl.PartNumber__c);
                            tempSuppliedParts.add(new RestDistributorUtility.Parts
                            (  integer.valueOf(altOl.quantity__c)
                               ,'false'
                               , string.valueOf(altOl.Id)
                               , altOl.PartNumber__c
                               , altOl.Type__c
                               , brandName
                               , altOl.Description__c
                               ,sequenceID //RLA 31/10/2020 C-004018: IG - Efa requirements
                            ));

                            sentOlIdSet.add(altOl.Id);
                        }
                        else{
                            system.debug('## orWrap.part.Id:'+orWrap.part.Id);
                            system.debug('## mapPartIdCrossRef.get(orWrap.part.Id):'+mapPartIdCrossRef.get(orWrap.part.Id));
                            //system.debug('## mapPartIdCrossRef.get(orWrap.part.Id).IAMManufacturer__c:'+mapPartIdCrossRef.get(orWrap.part.Id).IAMManufacturer__c);
                            String iamManu;
                            if(mapPartIdCrossRef.get(orWrap.part.Id) != null && mapPartIdCrossRef.get(orWrap.part.Id).IAMManufacturer__c != null){
                                iamManu = RestDistributorUtility.getCarMappingsMatrix((techDist +'-'+ mapPartIdCrossRef.get(orWrap.part.Id).IAMManufacturer__c).toUpperCase());
                                // ASE 15/02/19 C-003077 Manufacturer sur Appel Order SAS
                                iamManu = (!String.isblank(iamManu)) ? iamManu : (mapPartIdCrossRef.get(orWrap.part.Id).IAMManufacturer__c).toUpperCase();
                            }
                            else{
                                iamManu = null;
                            }
                            string iamManuMapping = (iamManu != null) ? iamManu : brandName;
                            //system.debug('## iamManuMapping:'+iamManuMapping);
                            //system.debug('## orWrap.OlPartNumber:'+orWrap.OlPartNumber);
                            tempSuppliedParts.add(new RestDistributorUtility.Parts
                            (  integer.valueOf(orWrap.quantity)
                               ,'false'
                               , string.valueOf(orWrap.OLId)
                               // ASE : 10/01/18 : C-002178
                               //, mapPartIdCrossRefForPN.containsKey(orWrap.part.Id) ? (mapPartIdCrossRefForPN.get(orWrap.part.Id).IAMPartNumber__c != null ? mapPartIdCrossRefForPN.get(orWrap.part.Id).IAMPartNumber__c : '') : orWrap.part.PartNumber__c
                               , orWrap.OlPartNumber
                               , orWrap.part.Type__c
                               ,iamManuMapping
                               , orWrap.part.Description__c
                               ,sequenceID //RLA 31/10/2020 C-004018: IG - Efa requirements
                            ));
                            sentOlIdSet.add(orWrap.OLId);
                        }
                    }
                    if(distOLMap.containsKey(distName)){
                        OrderLine__c additionalPartOrder = distOLMap.get(distName);
                        tempSuppliedParts.add(new RestDistributorUtility.Parts(1 
                                                                               ,'false'
                                                                               ,additionalPartOrder.ID
                                                                               ,additionalPartOrder.PartNumber__c
                                                                               ,additionalPartOrder.Type__c
                                                                               ,null // manufacturer
                                                                               ,additionalPartOrder.Description__c
                                                                               ,sequenceID //RLA 31/10/2020 C-004018: IG - Efa requirements
                                                                               )
                                                                               );
                            
                    }
                    system.debug('@@@ techDist: '+techDist);
                    system.debug('@@@ mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c: '+mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c);
                     //RLA 31/10/2020 C-004018: IG - Efa requirements,
                    String bsExtId = /* techDist + '-' + */ mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c;
                    //build distributorObj
                    distributorObj.put(distName,new OrderMakeSelection.distributor(mapDistNamePartList.get(distName)[0].POName,bodyShopOrderNumber,assessmentComment,true,tempSuppliedParts,bsExtId));//RLA 11/06/2020 C-003754: IG - Update Query Call for Coler
                }

                
                //build bodyshop
                if(mapBodyshop.size() > 0){
                    BodyShop = new RestDistributorUtility.BodyShop(
                        mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).Name,
                        // ASE: this line should be commented in Prod
                        //RLA 15/09/2020 C-003940: Check on Bodyshop Reference number to send to Distributor
                        RestDistributorUtility.isColer(mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c) ? system.label.FakeBodyshopReference :string.isNotBlank(mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c) ? mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c : '', //DUN 14/06/2018 replaced manufacturer__c by bodyshop__c
                        //string.isNotBlank(mapBodyshop.get(currentClaimOrderAssessment.Manufacturer__c).Tech_Distributor__c) && RestDistributorUtility.isColer(mapBodyshop.get(currentClaimOrderAssessment.Manufacturer__c).Tech_Distributor__c) ? '123456789' :string.isNotBlank(mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c) ? mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c : '', //RLA Case 2603
                        //string.isNotBlank(mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c) ? mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c : '', $$$
                        string.isNotBlank(mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).VATNumber__c) ? mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).VATNumber__c : '');
                }//end if mapBodyshop.size() > 0
                else{
                    BodyShop = new RestDistributorUtility.BodyShop('','','');
                }
                system.debug('@@ BodyShop:'+BodyShop);  


                //build vehicle
                Vehicle = new RestDistributorUtility.Vehicle(
                    string.isNotBlank(currentClaimOrderAssessment.Manufacturer__c) ? currentClaimOrderAssessment.Manufacturer__c : '',
                    string.isNotBlank(currentClaimOrderAssessment.ModelV2__c) ? currentClaimOrderAssessment.ModelV2__c : '',
                    currentClaimOrderAssessment.FirstRegistrationDate__c != null ? string.valueOf(currentClaimOrderAssessment.FirstRegistrationDate__c) : '01/01/1900', //NPE C-004587 08/02/2022
                    string.isNotBlank(currentClaimOrderAssessment.PlateNumber2__c) ? currentClaimOrderAssessment.PlateNumber2__c : '',
                    string.isNotBlank(currentClaimOrderAssessment.VINNumber__c) ? currentClaimOrderAssessment.VINNumber__c : '',
                    null);

                //build main request
                //AlphaScalePO set to null so that it can be removed during serialisation (no need to transmit those values during ordering process)
                mainRequest = new OrderMakeSelection.mainRequest(
                    string.isNotBlank(currentClaimOrderAssessment.ClaimReference__c) ? currentClaimOrderAssessment.ClaimReference__c : '',
                    false,
                    'ORDER',
                    null,
                    (object)distributorObj,
                    BodyShop,
                    Vehicle);

                //serialise request while eliminating null param
                finalOrderReq = Json.serialize(mainRequest,true);
                system.debug('## finalOrderReq ' + finalOrderReq); 

                //initialise rest callout
                if(mapDistNamePartList.size() > 0){
                    /* ASE 19/02/18  C-002236*/
                    System.enqueueJob(new AP40CallDistributorQueueable(finalOrderReq + '-OrderType : R4-', setPOToUpdate, sentOlIdSet));
                }
            }//end if !mapDistNamePartList.isEmpty() 

            system.debug('## offerToUpdateList:'+offerToUpdateList);
            if(offerToUpdateList.size() > 0)
            {
                update offerToUpdateList;
            }

            if(mapOrderLineToUpdate.size() > 0)
            {
                //update mapOrderLineToUpdate.values();
                //retrieve bundles/alternatives if acceptedCheck = true
                list<OrderLine__c> updatedOLList = OrderMakeSelection.getbundles(mapOrderLineToUpdate);  
                system.debug('## updatedOLList:'+updatedOLList); 
                update updatedOLList;
            }



            if(mapPartToUpdate.size() > 0)
            {
                update mapPartToUpdate.values();
            }

            if(mapPurchaseOrderToUpdate.size() > 0)
            {
                update mapPurchaseOrderToUpdate.values();
            }

            if(mapSalesOrderToUpdate.size() > 0)
            {
                update mapSalesOrderToUpdate.values();
            }

            if(mapAssessmentToUpdate.size() > 0)
            {
                update mapAssessmentToUpdate.values();
            }

            system.debug('@@@ mapPurchaseOrderToUpdateAgencyV3: '+mapPurchaseOrderToUpdateAgencyV3);
            if(mapPurchaseOrderToUpdateAgencyV3.size() > 0)
            {
                update mapPurchaseOrderToUpdateAgencyV3.values();
            }
            //HRM 29/11/21 : C-004215 - Plafond Commande
            VFC28_PlafondCommande.isPlafondReached(currentClaimOrderAssessment.Id);
            return new PageReference('/apex/OrderConfirmation?AssessmentId=' + (((encryptedSourceAssessmentId != null) && (encryptedAssessmentId != encryptedSourceAssessmentId)) ? (encryptedChildAssessmentId + '&SourceAssessmentId=' + encryptedSourceAssessmentId) : encryptedChildAssessmentId));
        }
        catch(DmlException e)
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
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
            }

            Database.rollback(beforeDML);
        }
        catch(Exception e)
        {
            hasErrors = true;

            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));
        }

        return null;
    }
     public static map<String, OrderLine__c> addAdditionalParts(map <string,list <orderingPartWrapper>> mapDistNamePartList){
        system.debug('## start addAdditionalParts');
        list <PartList__c> addPartList = new list <PartList__c>();
        list <OrderLine__c> additionalPartOrderList = new list <OrderLine__c>();
        list <Offer__c> additionalPartOfferList = new list <Offer__c>();
        Map <String,String> mapTypeDelay = new Map <String,String>();              
        map<String, Id> assessPLIdMap = new map<String, Id>();
        map<String, OrderLine__c> distOLMap = new map<String, OrderLine__c>();

        for(String key : mapDistNamePartList.keyset()){

            orderingPartWrapper opw = mapDistNamePartList.get(key)[0];  
              

            if(key == system.label.AdditionalPartDistributor){
                // ASE 08/11/17 : C-002072
                PartList__c addPart = new PartList__c(  PartNumber__c = system.label.AdditionalPartNumber
                                                        ,Name = system.label.AdditionalPart
                                                        ,Description__c = system.label.AdditionalPart
                                                        ,Currency__c = 'EUR'
                                                        ,Assessment__c = opw.assessId
                                                        ,Quantity__c = 1
                                                        ,Price__c = 0
                                                        ,SelectedByBS__c = true
                                                        ,Type__c = 'A'
                                                        ,TECH_OriginalPart__c = opw.assessId + system.label.AdditionalPartNumber
                                                      ); 
                addPartList.add(addPart); 
            }
        }
            
        //upsert partList
        system.debug('## addPartList:'+addPartList);
        List<Database.upsertResult> uResults = Database.upsert(addPartList, PartList__c.Fields.TECH_OriginalPart__c, false);
        for(Integer idx = 0; idx < uResults.size(); idx++) {
            if(uResults[idx].isSuccess()) {
            // if success populate the Set of id that has been successful
            assessPLIdMap.put(addPartList[idx].TECH_OriginalPart__c, uResults[idx].getId());
            //system.debug('## uResults[idx]:'+uResults[idx]);  
            }          
        }

        for(String key : mapDistNamePartList.keyset()){

            orderingPartWrapper opw = mapDistNamePartList.get(key)[0];
     

            if(key == system.label.AdditionalPartDistributor){
                mapTypeDelay = new Map<String,String>();
                if(opw.PartTypeRegionDelayMatrix != null){
                    for(String matrixline : opw.PartTypeRegionDelayMatrix.split(';'))
                    {
                        List<String> matrixValues = matrixline.split(':');
                        String partType = matrixValues[0].right(1);
                        String delayValue = matrixValues[2].left(2);
                        if(!mapTypeDelay.containsKey(partType)){
                            mapTypeDelay.put(partType, delayValue);
                        }
                    }
                }   
                system.debug('## mapTypeDelay:'+mapTypeDelay);
                OrderLine__c additionalPartOrder = new OrderLine__c(PartNumber__c       = system.label.AdditionalPartNumber
                                                                    ,Description__c     = system.label.AdditionalPart
                                                                    ,Type__c            = 'A'
                                                                    ,Quantity__c        = 1
                                                                    ,CataloguePrice__c  = 0
                                                                    ,PartList__c        = assessPLIdMap.get(opw.assessId + system.label.AdditionalPartNumber)
                                                                    ,PurchaseOrder__c   = opw.POId
                                                                    ,TechExternalId__c  = opw.POName + '-' + assessPLIdMap.get(opw.assessId + system.label.AdditionalPartNumber)
                                                                    ,OrderType__c       = 'FINAL'
                                                                    ,Suppliable__c      = null
                                                                    ,AcceptedCheck__c   = true
                                                                    ,PreselectedForOrder__c  = true
                                                                    ,ExpectedDeliveryDuration__c = mapTypeDelay != null ? (mapTypeDelay.containsKey('A') ? String.valueOf((Integer.valueOf(mapTypeDelay.get('A')))/24) : null ) : null);

                system.debug('## additionalPartOrder:'+additionalPartOrder);
                additionalPartOrderList.add(additionalPartOrder);
                distOLMap.put(key, additionalPartOrder);

                additionalPartOfferList.add(new Offer__c(  PrerequisiteOrder__c  = opw.SOId
                                                          ,OrderLine__r = new OrderLine__c(TechExternalId__c = additionalPartOrder.TechExternalId__c)
                                                          //,Type__c = po.Distributor__r.ReferenceNumber__c
                                                          ,Suppliable__c = true
                                                          , Accepted__c = 'YES'
                                                          ));
                
            }
        }                 
                
        system.debug('## additionalPartOrderList:'+additionalPartOrderList);
        if(additionalPartOrderList.size() > 0){
            // map should normally contain only 1 additional part
            insert additionalPartOrderList;
        }

        system.debug('## additionalPartOfferList:'+additionalPartOfferList);
        if(additionalPartOfferList.size() > 0){
            insert additionalPartOfferList;
        }
        system.debug('## end addAdditionalParts');

        return distOLMap;
    }


    //AMI 05/09/17 - Distributor Integration
    //wrapper class to build order request to send to distributor during ordering process
    //
    public without sharing class orderingPartWrapper{
        public PartList__c part;
        public string OLId;
        public string POName; 
        public string POId;
        public decimal quantity;
        public String OlPartNumber;
        public Id assessId;
        public String PartTypeRegionDelayMatrix;
        public Id SOId;
        

        public orderingPartWrapper(PartList__c part,string OLId,string POName,string POId,decimal quantity, String OlPartNumber, Id assessId, String PartTypeRegionDelayMatrix, Id SOId){ 
            this.part = part;
            this.OLId = OLId;
            this.POName = POName;
            this.POId = POId; 
            this.quantity = quantity;
            this.OlPartNumber = OlPartNumber;
            this.assessId = assessId;
            this.PartTypeRegionDelayMatrix = PartTypeRegionDelayMatrix;
            this.SOId = SOId;            
        }
    }

    //
    public without sharing class PartWrapper
    {
        public PartList__c currentPart {get; set;}
        public Map<Id, DistributorWrapper> mapDistributorWrapper {get; set;}
        // public Boolean isPartManual {get; set;}
        public Boolean isAlreadyOrdered {get; set;}
        public Boolean isPartAvailable {get; set;}
        public List<Id> orderedDistIds {get; set;}
        public Id preferredDistId {get; set;}//WCH 19/12/2019 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        public Boolean isOEM {get;set;}
        public Boolean doNotDisplaySubs {get;set;}
        public Id OEMId {get;set;}
        public List<PartWrapper> partSubstitutes {get; set;}

        public PartWrapper(Offer__c currentOffer)
        {
            currentPart             = currentOffer.OrderLine__r.PartList__r;
            //system.debug('@@@ currentPart: '+currentPart.Name);
            isAlreadyOrdered        = false;
            preferredDistId         = null;
            isOEM = false;
            partSubstitutes = new List<PartWrapper>();

            isPartAvailable         = (currentOffer.OrderLine__c != null && currentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null && currentOffer.OrderLine__r.Suppliable__c == 'YES');

            // isPartManual            = (currentPart.InputType__c == 'Manual' && currentPart.SelectedByBS__c) ? true : false;
            mapDistributorWrapper   = new Map<Id, DistributorWrapper>();
            mapDistributorWrapper.put(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c, new DistributorWrapper(currentOffer));
            orderedDistIds=new List<Id>();
            //WCH 17/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            if(currentOffer.PreferredDistributor__c){
                this.preferredDistId=currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c;
            }
   
            if ( String.isnotblank(currentOffer.PartNUmber__c) && (String.isnotblank(currentOffer.OrderLine__r.AlphaScaleMRID__c) && currentOffer.OrderLine__r.AlphaScaleMRID__c.StartsWith('ASP-')) || (String.isblank(currentOffer.OrderLine__r.AlphaScaleMRID__c))){
                system.debug('@@ say yes i am an OEM: '+currentOffer.PartNUmber__c);
                isOEM = true;
            }
            else if (string.isnotblank(currentOffer.OrderLine__r.SASStatus__c) && setStatusNotAllowed.contains(currentOffer.OrderLine__r.SASStatus__c)){
                doNotDisplaySubs = true;
            }
        }

        public void addNewOffer(Offer__c currentOffer)
        {
            if(!isPartAvailable)
            {
                isPartAvailable = (currentOffer.OrderLine__c != null && currentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null && currentOffer.OrderLine__r.Suppliable__c == 'YES');
            }

            if(mapDistributorWrapper.containsKey(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c))
            {
                // add offer to the map in DistributorWrapper
                mapDistributorWrapper.get(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c).addNewOffer(currentOffer);
            }
            else
            {
                // add a new entry in the map of the DistributorWrapper
                mapDistributorWrapper.put(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c, new DistributorWrapper(currentOffer));
            }
            //WCH 17/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            if(currentOffer.PreferredDistributor__c){
                this.preferredDistId=currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c;
            }
        }

        public void setAlreadyOrdered()
        {
            isAlreadyOrdered = true;
        }
        //WCH 13/12/2018 : C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        public void orderTheDistributors(){   
            List<String> theDistNames = new List<String>();
            Map<String, Id> distNameMapId = new Map<String, Id>();
            if(!String.isBlank(preferredDistId)){
                this.orderedDistIds.add(preferredDistId);
            }
            for(Id theDistId : mapDistributorWrapper.keySet()){
                theDistNames.add(mapDistributorWrapper.get(theDistId).currentDistributor.Name.toUpperCase());
                distNameMapId.put(mapDistributorWrapper.get(theDistId).currentDistributor.Name.toUpperCase(),theDistId);
            }
            theDistNames.sort();
            for(String currentDistName : theDistNames){
                if(preferredDistId!=distNameMapId.get(currentDistName))
                    orderedDistIds.add(distNameMapId.get(currentDistName));
            }
        }
    }

    //
    public without sharing class DistributorWrapper
    {
        public Account currentDistributor {get; set;}
        public Map<Id, OfferWrapper> mapOfferWrapper {get; set;}
        public Map<String, String> mapPartTypeDelayMatrix {get; set;}
        public Boolean hasTermsAndCondition {get; set;}
        // variable for only already ordered section
        private Id parentOfferId;

        public DistributorWrapper(Offer__c currentOffer)
        {
            currentDistributor      = currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r;
            mapOfferWrapper         = new Map<Id, OfferWrapper>();
            mapPartTypeDelayMatrix  = new Map<String, String>();
            hasTermsAndCondition    = false;

            //system.debug('## currentDistributor:'+currentDistributor);

            if(currentDistributor != null && currentDistributor.PartTypeRegionDelayMatrix__c != null)
            {
                populateMapPartTypeDelayMatrix(currentDistributor.PartTypeRegionDelayMatrix__c);
            }

            if (currentOffer.ParentOffer__c != null)
            {
                parentOfferId = currentOffer.ParentOffer__c;
                mapOfferWrapper.put(currentOffer.ParentOffer__c, new OfferWrapper(currentOffer, mapPartTypeDelayMatrix));
            }
            else
            {
                // is the parent offer
                parentOfferId = currentOffer.Id;
                mapOfferWrapper.put(currentOffer.Id, new OfferWrapper(currentOffer, mapPartTypeDelayMatrix));
            }

        }

        public void addNewOffer(Offer__c currentOffer)
        {
            if (currentOffer.ParentOffer__c != null)
            {
                // is a child offer

                // Checks if a wrapper of that id already exists
                if (mapOfferWrapper.containsKey(currentOffer.ParentOffer__c))
                {
                    // add the child offer to the existing wrapper
                    mapOfferWrapper.get(currentOffer.ParentOffer__c).addChildOffer(currentOffer);
                }
                // Cannot occur
                // else
                // {
                //     // put a new wrapper in the map
                //     mapOfferWrapper.put(currentOffer.ParentOffer__c, new OfferWrapper(currentOffer));
                // }
            }
            else
            {
                // is the parent offer

                // Checks if a wrapper of that id already exists
                if (mapOfferWrapper.containsKey(currentOffer.Id))
                {
                    // add the parent offer to the existing wrapper
                    mapOfferWrapper.get(currentOffer.Id).setParentOffer(currentOffer, mapPartTypeDelayMatrix);
                }
                else
                {
                    incrementQuantity(currentOffer);
                }
                // Cannot occur
                // else
                // {
                //     // put a new wrapper in the map
                //     mapOfferWrapper.put(currentOffer.Id, new OfferWrapper(currentOffer));
                // }
            }
        }

        public void incrementQuantity(Offer__c currentOffer)
        {
            // Quantity is only incremented for parent offer that does not have childs
            if (mapOfferWrapper.containsKey(parentOfferId))
            {
                mapOfferWrapper.get(parentOfferId).incrementQuantity(currentOffer);
            }
        }

        private void populateMapPartTypeDelayMatrix(String partTypeDelayMatrix)
        {
            for(String currentMatrixLine : partTypeDelayMatrix.split(';'))
            {
                try
                {
                    List<String> values = currentMatrixLine.substringAfter('{').substringBeforeLast('}').split(':');
                    String partType     = values[0].trim();
                    String delayValue   = values[2].trim();
                    if(delayValue.contains('_')){
                        delayValue = delayValue.split('_')[0];
                    }
                    if(!mapPartTypeDelayMatrix.containsKey(partType))
                    {
                        mapPartTypeDelayMatrix.put(partType, delayValue);
                    }
                }
                catch(Exception e){}
            }
            //system.debug('## mapPartTypeDelayMatrix:'+ mapPartTypeDelayMatrix);
        }
    }
    private Boolean verifyPermission(Assessment__c currentClaimAssessment)
    {
        List<UserRecordAccess> userRecordAccessList = [ SELECT  RecordId
                                                        FROM    UserRecordAccess
                                                        WHERE   RecordId =: currentClaimAssessment.Id
                                                        AND     UserId =: UserInfo.getUserId()
                                                        AND     HasReadAccess = true];

        return (userRecordAccessList != null && userRecordAccessList.size() > 0);
    }
    //
    public without sharing  class OfferWrapper
    {
        // The parent offer of the wrapper
        public Offer__c parentOffer { get; set; }

        public Boolean isAccepted {get; set;}
        public Boolean hasDeliveryDateAndSuppliable {get; set;}
        public Integer deliveryValue {get; set;}
        public Decimal quantity {get; set;}
        public Integer delayValue {get; set;}
        public Boolean isSubs {get; set;}
        public String   typeOfSubs {get;set;}

        public OfferWrapper(Offer__c off, Map<String, String> mapPartTypeDelayMatrix)
        {
            isSubs = true;
            childOfferList = new List<BundleItemWrapper> ();

            if (off.ParentOffer__c != null)
            {
                // the offer is a child offer
                childOfferList.add(new BundleItemWrapper(off));
            }
            else
            {
                // the offer is a parent offer
                populateParentOffer(off, mapPartTypeDelayMatrix);   
            }
            
        }

        //DUN 29/03/2018  C-002240 Added String color code
        public String deliveryColor
        {
            get{
                if(parentOffer != null && parentOffer.OrderLine__r.SASStatus__c != null){
                    if(parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED'){
                        return parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Confirmed__c;
                    }
                    else if(parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY'){
                        return parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4ConfirmedWithDelay__c;
                    }
                    else if(parentOffer.OrderLine__r.SASStatus__c == 'PARTIAL'){
                        return parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Partial__c;
                    }
                    else if(parentOffer.OrderLine__r.SASStatus__c == 'NOTFOUND'){
                        return parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4NotFound__c;
                    }
                    else if(parentOffer.OrderLine__r.SASStatus__c == 'OTHER'){
                        return parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Other__c;
                    }
                    return '';
                }
                else{
                    return '';
                }
            }  
        }

        //AMI 22/10/2018  C-002781 : Migrate Spain to R4
        //                         : Adding possibility to add cancel reason when offer is not accepted
        //                         : getter to determine if cancel reason should be set or not
        public boolean isEligleES{
            get{
                if(parentOffer != null && 
                    parentOffer.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c == ASPISConstants.TECH_EntityCountryCodeES){
                        return true;
                }else{
                        return false;
                }
            }
        }

        // List of child offers of the wrapper
        // It is empty if there is no child offers
        public List<BundleItemWrapper> childOfferList { get; set; }

        //AMI 29/11/17 : bypassing security for cross ref (bs has no access)
        public string crossRefId {get;set;}

        public string discount {get;set;}

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
                if (isSubs){
                    return false;
                }
                else{
                    return (parentOffer != null &&
                        parentOffer.OriginalPartNumber__c != null &&
                        childOfferList.size() == 0);
                }
            }
        }

        // variable to know if the wrapper is for a bundle
        public Boolean isBundle
        {
            get
            {
                return (childOfferList.size() > 0);
            }
        }

        // the Catalogue Price returns 0 when catalogue price is null on orderline
        public Boolean isPriceZero
        {
            get
            {
                return parentOffer.CataloguePrice__c == 0;
            }
        }

        // public OfferWrapper(Offer__c off)
        // {
        //  childOfferList = new List<BundleItemWrapper> ();

        //  if (off.ParentOffer__c != null)
        //  {
        //      // the offer is a child offer
        //      childOfferList.add(new BundleItemWrapper(off));
        //  }
        //  else
        //  {
        //      // the offer is a parent offer
        //      populateParentOffer(off);
        //  }
        // }

        

        // public void setParentOffer(Offer__c offer)
        // {
        //  if (parentOffer == null)
        //  {
        //      populateParentOffer(offer);
        //  }
        // }

        public void setParentOffer(Offer__c offer, Map<String, String> mapPartTypeDelayMatrix)
        {
            if (parentOffer == null)
            {
                populateParentOffer(offer, mapPartTypeDelayMatrix);
            }
        }

        // private void populateParentOffer(Offer__c offer)
        // {
        //  parentOffer = offer;

        //     isAccepted                      = (parentOffer.PrerequisiteOrder__r.Status__c != 'PREACCEPTANCE') ? (parentOffer.Accepted__c == 'YES') : (parentOffer.PreselectedForOrder__c);
        //     hasDeliveryDateAndSuppliable    = (parentOffer.OrderLine__c != null && parentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null && parentOffer.OrderLine__r.Suppliable__c == 'YES');
        //     deliveryValue                   = (parentOffer.OrderLine__c != null && parentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null) ? (Integer.valueOf(parentOffer.OrderLine__r.ExpectedDeliveryDuration__c) * 24) : 0;
        //     quantity                        = parentOffer.Quantity__c;
        // }

        private void populateParentOffer(Offer__c offer, Map<String, String> mapPartTypeDelayMatrix)
        {

            parentOffer = offer;

            //AMI 29/11/17 : populating crossRefId
            crossRefId = offer.OrderLine__r.PartList__r.CrossReferenceId__c;

            //RLA 12/10/2018 C-002782 CJP A'
            discount =  offer.OrderLine__r.PartList__r.DiscountRecord__c;
            //system.debug('## crossRefId ' + crossRefId);

            //AMI 19/09/17 : isAccepted
            //initialise
            isAccepted                      = false;
            hasDeliveryDateAndSuppliable    = (parentOffer.OrderLine__c != null && parentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null && parentOffer.OrderLine__r.Suppliable__c == 'YES');
            if(parentOffer.PrerequisiteOrder__r.Status__c != 'PREACCEPTANCE'){
                isAccepted = parentOffer.Accepted__c == 'YES';
            }
            // DUN 04/07/2018  C-002652 replaced parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' && parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' by line below
            else if(((parentOffer.OrderLine__r.SASStatus__c != null && 
                     parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c != null && 
                     !parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c.contains(parentOffer.OrderLine__r.SASStatus__c)) || 
                    parentOffer.OrderLine__r.SASStatus__c == null ) &&
            /*parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' && parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' && parentOffer.OrderLine__r.SASStatus__c != 'NOTFOUND' &&*/ 
                        parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                        string.isBlank(parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c)){
                //system.debug('## here2');
                isAccepted                  = false;
            }
            //ASE : 19/01/2018: C-002152
            ////DUN 16/11/2017 2072
            //else if(parentOffer.PrerequisiteOrder__r.Status__c == 'PREACCEPTANCE' 
            //        && parentOffer.PartNUmber__c == system.label.AdditionalPartNumber                    
            //        && parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null 
            //        && string.isBlank(parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c)){
            //    system.debug('## here3');
            //    if(parentOffer.OrderLine__r.Suppliable__c == 'YES'){
            //        system.debug('## here3.1');
            //        isAccepted = true;
            //    }
            //    /*else{
            //        system.debug('## here3.2');
            //        isAccepted = false;
            //    }    */            
            //}
            else{
                system.debug('## here4');
                isAccepted                  = parentOffer.PreselectedForOrder__c;
            }
            system.debug('## isAccepted:'+isAccepted);
            // isAccepted = true;it all dpends on this to do preselection
            
            deliveryValue                   = (parentOffer.OrderLine__c != null && parentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null) ? (Integer.valueOf(parentOffer.OrderLine__r.ExpectedDeliveryDuration__c) * 24) : 0;
            quantity                        = parentOffer.Quantity__c;

            if(mapPartTypeDelayMatrix != null && mapPartTypeDelayMatrix.containsKey(parentOffer.FinalType__c))
            {
                delayValue = Integer.valueOf(mapPartTypeDelayMatrix.get(parentOffer.FinalType__c));
            }

            if (parentOffer.FinalType__c == 'A'){
                typeOfSubs = 'Origine';
            }
            else if (parentOffer.FinalType__c == 'B'){
                typeOfSubs = 'Equipementier';
            }
            else if (parentOffer.FinalType__c == 'C'){
                typeOfSubs = 'Certifiée';
            }
            else if (parentOffer.FinalType__c == 'E'){
                typeOfSubs = 'Ré-emploi';
            }
            else{
                typeOfSubs = 'NA';
            }

           
        }

        public void addChildOffer(Offer__c offer)
        {
            childOfferList.add(new BundleItemWrapper(offer));
        }

        public void incrementQuantity(Offer__c offer)
        {
            if (offer.Accepted__c == 'YES')
            {
                quantity += offer.Quantity__c;
            }
        }
    }

    //
    public without sharing  class BundleItemWrapper
    {
        public Offer__c bundleItem {get; set;}
        public Decimal quantity {get; set;}

        public Boolean isPriceZero
        {
            get
            {
                return bundleItem.CataloguePrice__c == 0;
            }
        }

        public BundleItemWrapper(Offer__c currentOffer)
        {
            bundleItem  = currentOffer;
            quantity    = currentOffer.Quantity__c;
        }
    }
    //RRJ 12/10/2022
    public static list<String> picklist_values(Id BS) {
        system.debug('###### picklist value start');
        list<String> values = new list<String>();
		list<MultiaddressRepairCenter__mdt> RP_mdt = new list<MultiaddressRepairCenter__mdt>();
        //RRJ 14/10/2022
        String MulAdressQuerry = 'SELECT Active__c, BS__c, isTest__c, RepairCenterCode__c FROM MultiaddressRepairCenter__mdt WHERE Active__c=true AND BS__c=:BS' + (Test.isRunningTest()?' and isTest__c=true AND BS__c=\"XXX\"':' and isTest__c=false');
		//RP_mdt = [SELECT Active__c, BS__c, isTest__c, RepairCenterCode__c FROM MultiaddressRepairCenter__mdt WHERE Active__c=true AND isTest__c=false AND BS__c=:BS];
        for(MultiaddressRepairCenter__mdt mt : Database.Query(MulAdressQuerry)){
           values.add(mt.RepairCenterCode__c);
        }
			
        system.debug('###### picklist value stop');
        return values;
    }


    //RBE 25/01/2023
    //Wrapper class to store an Occurence, its images and main image, and its additional information
    public class OccurenceWrapper {
        public Occurence__c         occ { get; set; }
        public List<String>         lstImages {get;set;}
        public String               mainImage {get; set;}
        public Map<String,String>   mapAdditionalInfo {get;set;} //Stores additional information in the form of: label = value
        public List<String>         lstInfoKeys {get;set;}  //Used to access the map in the same order as inserted, because VF sorts the keys when iterating over a collection
        public Boolean              isSelected {get;set;}
    
        public OccurenceWrapper(Occurence__c occ) {
            this.occ = occ;
            this.isSelected = false;
            builImageList();
        }

        public void builImageList(){
            if(!String.isBlank(occ.PhotoURL__c)){
                this.lstImages = occ.PhotoURL__c.split(';');

                if(lstImages.size() > 0){
                    this.mainImage = lstImages[0];
                }
            }else{
                this.mainImage = 'No image';
            }
        }

        public void buildMapAdditionalInfo(){
            String info = occ.AdditionalInformation__c;
            if(!String.isBlank(info)){
                mapAdditionalInfo = new Map<String,String>();
                lstInfoKeys = new List<String>();
                List<String> lstInfo = info.split('[|]');            
                for(String s : lstInfo){
                    List<String> pair = s.split('_');
                    mapAdditionalInfo.put(pair[0],pair[1]);
                    lstInfoKeys.add(pair[0]);
                }
            } 
            // system.debug(mapAdditionalInfo);
        }  
    }

    //Get the total no of occurences for an xref
    public Integer noOccurences {
        get { return [ SELECT COUNT() FROM Occurence__c WHERE CrossReference__c =: xrefId AND Status__c = 'Active']; }        
    }

    //RBE 25/01/2023
    //Fetch a number of occurences related to an xref, defined by occLimit, starting from occOffset
    public void getOccurences(){
        mapOcc = new Map<Id, OccurenceWrapper>();
        for(Occurence__c occ : [SELECT Color__c, Distributor__c, Distributor__r.Name , Quality__c, NonPartner_ASSellingNetPrice__c, AdditionalMargin__c, Brand__c, Delay__c, CutOff__c, PhotoURL__c,AdditionalInformation__c,DistributorReference__c 
                                FROM Occurence__c 
                                WHERE CrossReference__c =: xrefId AND Status__c = 'Active'
                                Limit :occLimit
                                OFFSET :occOffset]){
            mapOcc.put(occ.Id, new OccurenceWrapper(occ));
        }      
        System.debug('occurences found: '+mapOcc);
    }
    //Assigns the occurence to display in the additional details modal
    public void setDetailOcc(){
        detailOcc = mapOcc.get(detailOccId); 
        detailOcc.buildMapAdditionalInfo();
    } 

    public Integer occPartSubCount {get;set;}
    public PartWrapper subPart {get;set;}

    public void selectOcc(){
        // system.debug('sub: '+ mapPartWrapper.get(occPartId).partSubstitutes.get(occPartSubCount).mapDistributorWrapper.get(occDistId).mapOfferWrapper.get(occOfferId).parentOffer);
        Offer__c offer      = mapPartWrapper.get(occPartId).partSubstitutes.get(occPartSubCount).mapDistributorWrapper.get(occDistId).mapOfferWrapper.get(occOfferId).parentOffer;
        Occurence__c occ    = mapOcc.get(selectedOccId).occ;

        PartList__c part    = updatePartList(offer.Orderline__r.PartList__r, occ);
        update part;

        if(occOperation == 'create')
            createOrderlineAndOffer(offer, occ);
        else if(occOperation == 'change')
            changeOrderline(offer, occ);
        
        PageReference pr = queryRecords();
    }

    public void createOrderlineAndOffer(Offer__c offer, Occurence__c occ){
        PurchaseOrder__c    newPO;
        PurchaseOrder__c    existingPO; 
        OrderLine__c        newOl;
        Offer__c            newOff;

        newPO = POAlreadyExists(assessmentClaimOrderId, occ.Distributor__c);
        if(newPO == null){
            newPO = createPO(assessmentClaimOrderId, occ.Distributor__c, offer);      
            insert  newPO;
        }

        newOl = cloneOccOrderline (offer.orderLine__r, offer, newPO.Id, occ);
        changePriceAndDelivery(newOl, occ);
        insert newOl;

        newOff = cloneOccOffer(offer, newOl);

        offer.DeliveryStatus__c  = 'CANCELED';
        upsert new List<Offer__c> {newOff, offer};
    }

    public void changeOrderline(Offer__c offer, Occurence__c occ){
        PurchaseOrder__c    currentPO;        
        PurchaseOrder__c    existingPO;
        Offer__c            newOff;

        existingPO = POAlreadyExists(assessmentClaimOrderId, mapOcc.get(selectedOccId).occ.Distributor__c);
        if(existingPO != null){
            //reparent Ol to PO
             offer.Orderline__r.PurchaseOrder__c = existingPO.Id;
             //update offer.Orderline__r;
        }
        else{            
            currentPO                   = offer.orderLine__r.PurchaseOrder__r;            
            //Get number of orderlines in the purchase order
            Integer numOL = [SELECT COUNT() FROM OrderLine__c WHERE PurchaseOrder__c =:currentPO.Id];
            if(numOL > 1){
                //create new PO and move OL to it
                currentPO = createPO(assessmentClaimOrderId, occ.Distributor__c, offer);
                insert currentPO;
                offer.orderLine__r.purchaseOrder__c = currentPO.Id;
            }else{
                //change dist on PO
                currentPO.Distributor__c    = occ.Distributor__c; 
                update currentPO;
            }
        }
        changePriceAndDelivery(offer.OrderLine__r, occ);
        update offer.OrderLine__r;      
    }

    public void  changePriceAndDelivery(OrderLine__c ol, Occurence__c occ){
        ol.ASBodyshopPrice__c            = ol.PartList__r.Price__c;
        ol.ASBodyshopNetPrice__c         = occ.NonPartner_ASSellingNetPrice__c;
        ol.Description__c                = ol.PartList__r.Description__c;
        ol.ExpectedDeliveryDuration__c   = String.valueOf(occ.Delay__c / 24);
    }

    public PartList__c updatePartList(PartList__c prt, Occurence__c occ){
        Decimal priceA              = prt.OriginalPart__r.OriginalPart__r.price__c;
        Decimal PREPrice            = priceA;
        prt.price__c                = PREPrice;
        prt.StandardMargin__c       = PREPrice - occ.NonPartner_ASSellingNetPrice__c;
        prt.StandardDiscount__c     = (1 - (occ.NonPartner_ASSellingNetPrice__c / PREPrice)) * 100;
        prt.UnitGain__c             = priceA - PREPrice;
        prt.ASNetPrice__c           = occ.NonPartner_ASSellingNetPrice__c;
        prt.Distributor__c          = occ.Distributor__c;
        prt.OccurenceId__c          = occ.Id;
        return prt;
    }

    //Clones the orderline passed as parameter and sets the PurchaseOrder to the Id passed as parameter
    public OrderLine__c cloneOccOrderline (OrderLine__c ol, Offer__c off, Id purchaseOrderId, Occurence__c occ){

        OrderLine__c newOl                  = ol.clone();
        newOl.PurchaseOrder__c              = purchaseOrderId;
        newOl.OrderType__c                  = 'FINAL';
        newOl.Type__c                       = 'E';
        newOl.Quantity__c                   = 1;       
        newOl.DistributorReference__c       = occ.DistributorReference__c;
        newOl.AcceptedCheck__c              = false;
        newOl.IsCanceledByDistributor__c    = false;        
        return newOl;
    }

    //Clones the offer passed as parameter and links it to the orderline passed as parameter
    public Offer__c cloneOccOffer (Offer__c off, OrderLine__c orderLine){
        Offer__c newOff             = off.clone();
        newOff.PrerequisiteOrder__c = off.PrerequisiteOrder__c;
        newOff.OrderLine__c         = orderLine.Id;
        newOff.Type__c              = orderLine.PurchaseOrder__r.Distributor__r.ReferenceNumber__c;
        return newOff;
    }

    public PurchaseOrder__c createPO(Id assId, Id distId,Offer__c offer){
        String countryCode                                      = offer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.TECH_EntityCountryCode__c;        
        Map<String,Schema.RecordTypeInfo> purchaseOrderRTByName = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName();
        CountryCodeInformationsMapping__c configCountryCodeInfo = CountryCodeInformationsMapping__c.getall().get(countryCode);
        BusinessHours businessDays                              = ASPISConstants.getBusinessHours(countryCode);

        PurchaseOrder__c newOrder           = new PurchaseOrder__c(
                assessment__c               = assId,
                validityDate__c             = Date.valueOf(Businesshours.add(businessDays.id,datetime.now(),configCountryCodeInfo.Validity_Duration_Purchase_Order__c!=null?Integer.valueOf(configCountryCodeInfo.Validity_Duration_Purchase_Order__c)*60*60*1000L:0)),               
                status__c                   = 'PREDRAFTQUOTE',
                distributor__c              = distId,
                prerequisiteOrder__c        = offer.PrerequisiteOrder__c,
                recordTypeId                = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId(),
                SLAQuotationEntryDate__c    = datetime.now(),
                Tech_ExternalId__c          = String.valueOf(assId) + String.valueOf(distId),
                AgencyMode__c               = false
            );
        return newOrder;
    }
    //Returns the PurchaseOrder for the distributor on the assessment, if one exists
    public PurchaseOrder__c POAlreadyExists(Id assessmentClaimOrderId, Id distributorId){
        List<PurchaseOrder__c> lstPO = [SELECT Id FROM PurchaseOrder__c where Assessment__c =:assessmentClaimOrderId  AND Distributor__c =: distributorId];
        if(!lstPO.isEmpty())
            return lstPO[0];        
        else
            return null;        
    }

    //Updates POs with no OLs or only canceled OLs to Canceled
    public void cancelPOWithNoOL(Id assessmentClaimOrderId){
        List<PurchaseOrder__c> lstPOToUpdate = new List<PurchaseOrder__c>();
        for(PurchaseOrder__c po : [SELECT Id, (select DeliveryStatus__c from orderlines__r where deliverystatus__c <> 'canceled') FROM PurchaseOrder__c where Assessment__c =: assessmentClaimOrderId]){
            if(po.orderlines__r.isEmpty()){
                po.Status__c = 'CANCELED';
                lstPOToUpdate.add(po);
            }
        }
        update lstPOToUpdate;
    }

    //Pagination functions
    public void nextOcc(){
        occOffset+=occLimit;
        getOccurences();
    }

    public void prevOcc(){
        occOffset-=occLimit;
        getOccurences();
    }

    public void lastOcc(){
        occOffset = noOccurences - math.mod(noOccurences, occLimit);
        getOccurences();

    }

    public void firstOcc(){
        occOffset = 0;
        getOccurences();
    }
    //End of pagination functions   
}