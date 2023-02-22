/*************************************************************************************
Class Name - VFC11_OrderMakeSelection
Version - 1.0
Created Date - 11 November 2016
Function - Controller extension for page OrderMakeSelection,
           which displays all offers available for an assessment 
Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       14/12/2016  Original Version (case 1823 : ASPIS 2.0 : Order Process - OrderMakeSelection)
* Abdool M     04/09/2017  Distribor WS Integration
* Abdool M     12/10/2017  SAS : Envoyer l'IAMManufacturer des pièces issues de la substitution que pour les pièces de type autre que A
* Abdool M     18/10/2017  SAS: Remplacement de pièce  
* Dourga       15/11/2017  case C-002071 : Add the functionality to select additional address for a BS
* Ashwina S    14/11/2017  C-002072
* Abdool M     05/12/2017  Distributor name should be fetch from Tech_Distributor__c instead of 
*                          referencing name directly
* Abdool M     12/12/2017  Creating LOG for distributor callout (EIP Request and Response)
* Dourga U     10/01/2018  C-002135 : Agency Mode V2
* Ashwina S    10/01/2018  C-002178 -The IAM part number is not the same on DRAFT and ORDER request
* Ashwina S    19/01/2018  C-002152 - Add part created even if all the parts are refused
* Abdool M     16/02/2018  C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c and Rebate__c to query 
*                                                    - Saving MRID in OL generated  but using Rebate to calculate new pricing for ASP Parts 
* Ashwina S    19/02/2018  C-002236 : C-002236
* Dourga       13/03/2018  C-002384 : Bug BE : Pièces déjà commandés n'apparaissent pas dans la R4
* Dourga       29/03/2018  C-002240 : Manage R4 Stock information at Account Level
* Vaynee       04/04/2018  C-002315 : Cross Scripting
* Ruksaar L    28/03/2018  C-002177: Corrections/evolutions sur les logs
* Dourga       22/06/2018  Bug on logs when partlist size on assessment is greater than 200  
* Dourga       04/07/2018  C-002652 : Parts NOTFOUND Price in DistributorV2
* Ashwina S    10/07/2018  C-002659 : Prices & Part Type to be sent to Coler  
* Abdool M     22/10/2018  C-002781 : Migrate Spain to R4
                                    : Adding possibility to add cancel reason when offer is not accepted
* Abdool M     06/11/2018  C-002781 : Migrate Spain to R4
                                    : Display Recap of Parts Ordered For Spain Only
                                    : adding ap constant variable for ES
* Ruksaar L     10/12/2018 C-002782 : CJP A'
* Welsa C       13/12/2018  C-002958 : MultiSourcing Belgium - Large choice of distributors for Bodyshops                                    
* Welsa C       07/01/2019  C-002958 : MultiSourcing Belgium - Large choice of distributors for Bodyshops          
* Ruksaar L     11/01/2019 Case: C-003007: Duplicate order for Coler (bis)                                 
* Welsa C      28/01/2019  C-002963 : Select/Unselect ALL on R4 Order page                                                             
* Welsa C       08/02/2018  C-002958 : MultiSourcing Belgium - Large choice of distributors for Bodyshops                                    
* Ashwina S     08/02/2018  C-003077 : Manufacturer sur Appel Order SAS       
* Welsa C       03/04/2019  C-003153 : Select All / Unselect All Issue                                    
* Welsa C       15/05/2019  C-002781 : Migrate Spain to R4
* Ruksaar L     11/11/2019  C-003411 : Agency Mode V3 
* Welsa C       07/01/2020  C-003528 : Status on OrderMakeSelection class log set to Passed when it fails
* Welsa C       07/04/2020  C-003677 : SO CANCELATION BUTTON BS 
* Ruksaar L     12/06/2020  C-003754: IG - Update Query Call for Coler
* Welsa C       18/08/2020  C-003864 : 2020 Connectivity changes for EIP
* Ruksaar L     20/08/2020  C-003882 IG - Order Quality Check outside ASPIS
* Welsa C       02/04/2021  C-004067 : Pentest : Forced Browsing
* Welsa C       22/09/2021  C-004066 : Pentest : Improper Error Handling with code disclosure
* Hootesh R     22/10/2021  C-004215 : Plafond Commande
* Neha  P       08/02/2022  C-004587: Send default value on PO's First Registration Date field for OrderMakeSelection calls to SAS if value is NULL                                                                                                                
* Welsa C      15/04/2022   C-004691 : Order SAS: Send null- in the BSexternal Reference field
* Welsa C      22/06/2022   C-004697 : Sixt - Shipping & email addresses
* Welsa C      19/07/2022   C-004762 : Catalogue OEM
* Rayhaan B    13/01/2023   PREv2 Connected - C-004897: Lot 3.3, C-004898: Lot 3.4, C-004899: Lot 3.5,C-004900: Lot 3.6, C-004901: Lot 3.7

**************************************************************************************/ 
global without sharing class OrderMakeSelection
{
    public Map<String, PartWrapper> mapPartWrapper {get; set;}
    public Map<String, PartWrapper> mapAlreadyOrderedPartWrapper {get; set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}

    private String encryptedAssessmentId;
    private String encryptedChildAssessmentId;
    private String encryptedSourceAssessmentId{get;set;}

    public Assessment__c currentClaimAssessment {get; set;}
    public Assessment__c currentClaimOrderAssessment {get; set;}
    public String assessmentTitle {get; set;}
    // public String careOrderSwitch {get; set;}
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

    //AMI 04/09/17 - Distributor Integration
    //boolean to prevent recursive page loads due to remote action
    public boolean hasAlreadyRun {get;set;}

    //AMI 12/09/17 - Distributor Integration
    //set po id used to build error received during order call out
    public set <id> setPOToUpdate = new set <id>();

    //DUN 15/11/2017 case 2071
    public List<SelectOption> accountSelectOptionList {get; set;}
    public Map<Id, Account> mapIdAccount {get; set;}

    //ASE: 21/11/17:  // C-002072: adding check on DistributorConnected__c for BS for pilot phase   
    public boolean isBSConnected {get;set;}
    //Dourga 05/02/2018  C-002135 : When at least one part is in agency mode. flag agency mode in the order section
    public boolean isAgencyMode {get;set;}

    //DUN 22/02/2018 boolean to display cfsla instead of green rectangle 
    public boolean displayCFSLA{get;set;}
    private static String objReference = '';

    //AMI 06/11/2018  C-002781 : Migrate Spain to R4
    //                         : Display Recap of Parts Ordered For Spain Only
    //                         : adding ap constant variable for ES
    public string countryCode {get;set;}
    //WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
    public String countryCodeBE{get;set;}
    //WCH 28/01/2019 C-002963 - Select/Unselect ALL on R4 Order page
    public Boolean toggleValue{get;set;}
    public Boolean toggleButtonVisible{get;set;}
    //WCH 27/03/2019 C-003153 : Select All / Unselect All Issue  
    public Integer numberOfPartList{get;set;}
    //WCH 01/04/2020 C-003677 
    public boolean showBSCancelSOButton {get;set;}
    public String socb{get;set;}
    public PrerequisiteOrder__c shadowSO{get;set;}
    //WCH 22/06/2022 C-004697
    public List<SelectOption> lstMultiaddressRepairCenter{get;set;}
    public List<multiAddressWrapper> lstAllBSAddresses{get;set;}
    public boolean isMultiAddress {get;set;}
    public String repairCenterCodeChosen {get;set;}
    public String contactIdChosen {get;set;}
    public String contactChosen {get;set;}
    //RBE 12/01/2023 
    public Map<Id,OccurenceWrapper> mapOcc {get;set;}  //Stores the occurences for an xref
    public OccurenceWrapper detailOcc { get;set; } //Stores the occurence to be used in the additional details popup
    public Id xrefId {get;set;} //Id of the xref for which to view the occurences
    public Integer occLimit {get;set;} //Number of occurences to display on one page    
    public Integer occOffset {get;set;} //Used in the query to fetch occurences to determine from which row to start
    public Id detailOccId {get;set;}    //Id of the occurence to view in additional details
    public Id selectedOccId {get;set;} //Id of the occurence currently selected 
    public String xrefDesc {get;set;}
    public String occPartId {get;set;}
    public String occDistId {get;set;}
    public String occOfferId {get;set;}
    public String occOperation {get;set;}
    public Integer noOccurences {set;get;} //Ttotal no of occurences for an xref
    public List<Occurence__c> lstAllAvailableOcc;
    public PIEC_Config__mdt preConfig;    
    public String occErrorMessage {get;set;}

    //WCH 19/07/2022 C-004762
    public static Map<Id, OrderLine__c> mapOriginalOlRecoveredOL1 = new map<Id,OrderLine__c>();
    public static Map<Id, OrderLine__c> mapOlIdOL = new map<Id,OrderLine__c>();
    public OrderMakeSelection()
    {
        system.debug('Start OrderMakeSelection');
        
        //DUN 15/11/2017 case 2071
        accountSelectOptionList = new List<SelectOption>();
        mapIdAccount = new Map<Id, Account>();

        //WCH 01/04/2020 C-003677 
        showBSCancelSOButton    = false;
        socb='';
        shadowSO=new PrerequisiteOrder__c();

        //AMI 04/09/17 - Distributor Integration
        hasAlreadyRun = false;

        isAgencyMode = false;

        //AMI 06/11/2018  C-002781 : Migrate Spain to R4
        //                         : Display Recap of Parts Ordered For Spain Only
        //                         : adding ap constant variable for ES
        countryCode = ASPISConstants.TECH_EntityCountryCodeES;
        //WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
        countryCodeBE = (CountryCodeInformationsMapping__c.getall().containsKey(ASPISConstants.TECH_EntityCountryCodeBE) && CountryCodeInformationsMapping__c.getall().get(ASPISConstants.TECH_EntityCountryCodeBE).ActivateMultisourcing__c)?ASPISConstants.TECH_EntityCountryCodeBE:'MultiSourcingBEInactive';
        // // ASE: 21/11/17:
        // C-002072: adding check on DistributorConnected__c for BS for pilot phase        
        //isBSConnected = [Select BodyShop__r.DistributorConnected__c from Assessment__c where id = :ApexPages.currentPage().getParameters().get('ChildId')].BodyShop__r.DistributorConnected__c;
        //system.debug('## isBSConnected:'+isBSConnected);
        
        //WCH 28/01/2019 C-002963 - Select/Unselect ALL on R4 Order page
        toggleValue=false;
        toggleButtonVisible=false;
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

        
        //RBE 11/01/2023
        preConfig = [SELECT OccurencePaginationLimit__c, OccurencePaginationOffset__c, OccurenceMaxLimit__c, CreateLog__c FROM PIEC_Config__mdt WHERE DeveloperName = 'OccurencePagination' LIMIT 1];
        occLimit  = (Integer) preConfig.OccurencePaginationLimit__c;//(Integer) PIEC_Config__mdt.getInstance('OccurencePagination').OccurencePaginationLimit__c;
        occOffset = (Integer) preConfig.OccurencePaginationOffset__c;
        system.debug('occOffset '+ occOffset);
        noOccurences = occLimit;
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

    /**
     * Function to redirect the page to the search page in case of wrong link opened
     * @return   The page to which it must be redirected
     */
    public PageReference redirectPage()
    {
        if(currentClaimAssessment == null)
        {
            PageReference pageRef = Page.Search;
            pageRef.setRedirect(true);
            return pageRef;
        }

        return null;
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

        public PartWrapper(Offer__c currentOffer)
        {
            currentPart             = currentOffer.OrderLine__r.PartList__r;
            isAlreadyOrdered        = false;
            preferredDistId         = null;

            isPartAvailable         = (currentOffer.OrderLine__c != null && currentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null && currentOffer.OrderLine__r.Suppliable__c == 'YES');

            // isPartManual            = (currentPart.InputType__c == 'Manual' && currentPart.SelectedByBS__c) ? true : false;
            mapDistributorWrapper   = new Map<Id, DistributorWrapper>();
            mapDistributorWrapper.put(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c, new DistributorWrapper(currentOffer));
            orderedDistIds=new List<Id>();
            //WCH 17/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            if(currentOffer.PreferredDistributor__c){
                this.preferredDistId=currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c;
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

        public OfferWrapper(Offer__c off, Map<String, String> mapPartTypeDelayMatrix)
        {
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
                return (parentOffer != null &&
                        parentOffer.OriginalPartNumber__c != null &&
                        childOfferList.size() == 0);
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
            
            deliveryValue                   = (parentOffer.OrderLine__c != null && parentOffer.OrderLine__r.ExpectedDeliveryDuration__c != null) ? (Integer.valueOf(parentOffer.OrderLine__r.ExpectedDeliveryDuration__c) * 24) : 0;
            quantity                        = parentOffer.Quantity__c;

            if(mapPartTypeDelayMatrix != null && mapPartTypeDelayMatrix.containsKey(parentOffer.FinalType__c))
            {
                delayValue = Integer.valueOf(mapPartTypeDelayMatrix.get(parentOffer.FinalType__c));
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

             //RBE 19/01/2023 PREv2 Connected - Lot 3.7 - Order - PRE SELECTED and Update IHM + PO SO
             cancelPOWithNoOL(assessmentClaimOrderId);
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
                            // ASE: 14/11/17 C-002072 populateSet to check if OL has alernative or not                            
                            OLIdSet.add(currentOfferWrapper.parentOffer.OrderLine__c);
                            system.debug('## currentDistributorWrapper.currentDistributor:'+ currentDistributorWrapper.currentDistributor);
                            system.debug('## currentDistributorWrapper.currentDistributor.OrderRequest__c:'+currentDistributorWrapper.currentDistributor.OrderRequest__c);
                            system.debug('## currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c:'+currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c);
                            system.debug('## currentOfferWrapper.parentOffer.OrderLine__r.id:'+currentOfferWrapper.parentOffer.OrderLine__r.Id);
                            system.debug('## currentDistributorWrapper.currentDistributor.Type_of_Substitutes__c:'+currentDistributorWrapper.currentDistributor.Type_of_Substitutes__c);
                            //kem
                            mapOlIdOL.put(currentOfferWrapper.parentOffer.OrderLine__r.Id,currentOfferWrapper.parentOffer.OrderLine__r);
                            system.debug('## mapOlIdOL'+mapOlIdOL);
                            //AMI 05/09/17 - Distributor Integration
                            // if(currentDistributorWrapper.currentDistributor.DistributorConnected__c == true &&
                            //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
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

                             // PURCHASE ORDER //RLA 08-11-2019  C-003411 : Agency Mode V3
                            if( mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                                && !mapPurchaseOrderToUpdateAgencyV3.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c)
                                && CountryCodeInformationsMapping__c.getall().containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c) 
                                && CountryCodeInformationsMapping__c.getall().get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c).AgencyModeAutomaticDelivery__c
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.AgencyMode__c 
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Agency_V3__c
                                )
                            {
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

            // ASE: 14/11/17 C-002072
            if(OLIdSet.size() > 0){
                for(OrderLine__c ol : [Select Id, OriginalItem__c, PartNumber__c, Quantity__c, Type__c, Description__c, DistributorReference__c from OrderLine__c where OriginalItem__c in :OLIdSet and TechGeneratedFinal__c = false]){
                    oriAltOLMap.put(ol.OriginalItem__c, ol);
                }
            }
            system.debug('## mapDistNamePartList ' + mapDistNamePartList);


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
                mainRequest mainRequest;

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
                    list <RestDistributorUtility.PartsConnectedE> tempSuppliedPartsE = new list <RestDistributorUtility.PartsConnectedE>(); 
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

                        system.debug('## orWrap:'+orWrap);
                        system.debug('## orWrap.OLId:'+orWrap.OLId);
                        system.debug('## mapPartIdCrossRef.get(orWrap.part.Id):'+mapPartIdCrossRef.get(orWrap.part.Id));
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
                        }//kem check if part is connected E and populate tempSuppliedPartsE
                         else if(mapPartIdCrossRef.get(orWrap.part.Id) != null && mapPartIdCrossRef.get(orWrap.part.Id).IAMManufacturer__c == 'Connected E'){
                            Orderline__c altOl2  = oriAltOLMap.get(orWrap.OLId);
                            system.debug('good to be consious');
                            system.debug('mapOlIdOL.get(orWrap.OLId)'+mapOlIdOL.get(orWrap.OLId));
                            system.debug('(orWrap.OLId)'+ orWrap.OLId );
                            tempSuppliedPartsE.add(new RestDistributorUtility.PartsConnectedE
                            ( string.valueOf(orWrap.OLId)
                               // ASE : 10/01/18 : C-002178
                               , mapOlIdOL.get(orWrap.OLId).DistributorReference__c
                            ));
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

                    //WCH 15/04/2022 C-004691
                     //RLA 31/10/2020 C-004018: IG - Efa requirements
                    String bsExtId = /* techDist + '-' + */ mapBodyshop.get(currentClaimOrderAssessment.BodyShop__c).ReferenceNumber__c;
                    //build distributorObj
                    if(tempSuppliedParts != null && tempSuppliedParts.size() > 0){
                        distributorObj.put(distName,new distributor(mapDistNamePartList.get(distName)[0].POName,bodyShopOrderNumber,assessmentComment,true,tempSuppliedParts,bsExtId));//RLA 11/06/2020 C-003754: IG - Update Query Call for Coler
                    }
                    if(tempSuppliedPartsE != null && tempSuppliedPartsE.size() > 0){
                    distributorObj.put(distName,new distributor(mapDistNamePartList.get(distName)[0].POName,bodyShopOrderNumber,assessmentComment,true,tempSuppliedPartsE,bsExtId));//KEM 10/02/2023  Update Call for ORDER for connected E 
                    }
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
                mainRequest = new mainRequest(
                    string.isNotBlank(currentClaimOrderAssessment.ClaimReference__c) ? currentClaimOrderAssessment.ClaimReference__c : '',
                    false,
                    'ORDER',
                    null,
                    (object)distributorObj,
                    BodyShop,
                    Vehicle);

                //kem
                system.debug('## mainRequest ' + mainRequest); 

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
                list<OrderLine__c> updatedOLList = getbundles(mapOrderLineToUpdate);  
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
            //HRM 22/11/21 : C-004215 - Plafond Commande
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

    public PageReference respond()
    {
        hasErrors       = false;
        isToastError    = false;

        // checking if the salesOrder has already been responded
        List<PrerequisiteOrder__c> respondedSalesOrderList =    [SELECT Id, Status__c
                                                                 FROM   PrerequisiteOrder__c
                                                                 WHERE  Assessment__c =: currentClaimOrderAssessment.Id
                                                                 AND    (Status__c =: ASPISConstants.PRE_ORDER_STATUS_INDELIVERY
                                                                        OR  Status__c =: ASPISConstants.PRE_ORDER_STATUS_RESPONDED)];

        //AMI 22/10/2018  C-002781 : Migrate Spain to R4
        //                         : Adding possibility to add cancel reason when offer is not accepted
        //                         : Removing hard coded warning
        if(respondedSalesOrderList.size() > 0)
        {
            hasErrors       = true;
            isToastError    = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, system.label.PartsAlreadyOrdered));
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
                            // OFFER
                            offerToUpdateList.add(new Offer__c( Id          = currentOfferWrapper.parentOffer.Id,
                                                                Accepted__c = 'YES'));
                            
                            // Loop in child offers if present
                            if(currentOfferWrapper.childOfferList.size() > 0)
                            {
                                for(BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
                                {
                                    offerToUpdateList.add(new Offer__c( Id          = currentBundleWrapper.bundleItem.Id,
                                                                        Accepted__c = 'YES'));
                                }
                            }

                            // ORDER LINE
                            // mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__c, new OrderLine__c(Id                   = currentOfferWrapper.parentOffer.OrderLine__c,
                            //                                                                                         Quantity__c         = currentOfferWrapper.quantity));
                            
                            // if(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                            // {
                            //     mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                   = currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c);
                            // }

                            // PART LIST
                            mapPartToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c, new PartList__c(Id                     = currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c,
                                                                                                                                          //Ordered__c             = true,
                                                                                                                                          TECH_OrderedCounter__c = (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c != null ? (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c + 1) : 1),
                                                                                                                                          QuantityOrdered__c     = currentOfferWrapper.quantity));

                            // PURCHASE ORDER
                            if(!mapPurchaseOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c))
                            {
                                mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id                     = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                 BodyShopOrderNumber__c = bodyShopOrderNumber));
                            }

                             // PURCHASE ORDER //RLA 08-11-2019  C-003411 : Agency Mode V3
                            if(!mapPurchaseOrderToUpdateAgencyV3.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c)
                                && CountryCodeInformationsMapping__c.getall().containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c) 
                                && CountryCodeInformationsMapping__c.getall().get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c).AgencyModeAutomaticDelivery__c
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.AgencyMode__c 
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Agency_V3__c
                                )
                            {
                                system.debug('@@@ here');
                                mapPurchaseOrderToUpdateAgencyV3.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED));
                            }
                            


                            // SALES ORDER
                            if(!mapSalesOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.PrerequisiteOrder__c))
                            {
                                mapSalesOrderToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__c, new PrerequisiteOrder__c(Id             = currentOfferWrapper.parentOffer.PrerequisiteOrder__c,
                                                                                                                                         Status__c      = ASPISConstants.PRE_ORDER_STATUS_RESPONDED,
                                                                                                                                         OfferType__c   = currentOfferWrapper.parentOffer.Type__c,
                                                                                                                                         BodyShop__c    = currentClaimOrderAssessment.BodyShop__c));
                            }


                            // ASSESSMENT
                            if(!mapAssessmentToUpdate.containsKey(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c))
                            {
                                
                                mapAssessmentToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c, new Assessment__c(Id             = currentOfferWrapper.parentOffer.PrerequisiteOrder__r.Assessment__c,
                                                                                                                                                Comment__c     = assessmentComment,
                                                                                                                                                OrderOrigin__c = 'Order',
                                                                                                                                                BodyShop__c    = currentClaimOrderAssessment.BodyShop__c));
                            }
                        }
                        else
                        {
                            //AMI 22/10/2018  C-002781 : Migrate Spain to R4
                            //                         : Adding possibility to add cancel reason when offer is not accepted
                            //                         : adding cancel reason
                            offerToUpdateList.add(new Offer__c( Id              = currentOfferWrapper.parentOffer.Id,
                                                                Accepted__c     = 'NO',
                                                                CancelReason__c = currentOfferWrapper.parentOffer.CancelReason__c));
                            
                            // Loop in child offers if present
                            if(currentOfferWrapper.childOfferList.size() > 0)
                            {
                                for(BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
                                {
                                    offerToUpdateList.add(new Offer__c( Id          = currentBundleWrapper.bundleItem.Id,
                                                                        Accepted__c = 'NO'));
                                }
                            }
                            //WCH 15/05/2019  C-002781 : Migrate Spain to R4
                            // SALES ORDER
                            if(!mapSalesOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.PrerequisiteOrder__c))
                            {
                                mapSalesOrderToUpdate.put(currentOfferWrapper.parentOffer.PrerequisiteOrder__c, new PrerequisiteOrder__c(Id             = currentOfferWrapper.parentOffer.PrerequisiteOrder__c,
                                                                                                                                         Status__c      = ASPISConstants.PRE_ORDER_STATUS_RESPONDED,
                                                                                                                                         OfferType__c   = currentOfferWrapper.parentOffer.Type__c,
                                                                                                                                         BodyShop__c    = currentClaimOrderAssessment.BodyShop__c));
                            }
                        }
                    }
                }
            }

            if(offerToUpdateList.size() > 0)
            {
                update offerToUpdateList;
            }

            if(mapOrderLineToUpdate.size() > 0)
            {
                update mapOrderLineToUpdate.values();
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

    @RemoteAction
    public static String getTermsAndCondtions(String distributorId)
    {
        String base64Pdf = '';

        if(String.isNotBlank(distributorId))
        {
            List<Attachment> attachmentList = [SELECT   Id, Body
                                                FROM    Attachment 
                                                WHERE   ParentId =: distributorId 
                                                AND     Name LIKE '%TermsAndCondition%' 
                                                ORDER BY LastModifiedDate DESC];

            // Taking the 1st one
            if(attachmentList.size() > 0)
            {
                base64Pdf = EncodingUtil.base64Encode(attachmentList[0].Body);
                system.debug('##base64Pdf '+base64Pdf);
            }  
        }

        return base64Pdf;
    }

    /**
     * Function to verify the permission of the user to the assessment
     * @param  currentClaimAssessment The assessment on which the permissions needs to be checked
     * @return                        Whether the user has access to the assessment
     */
    private Boolean verifyPermission(Assessment__c currentClaimAssessment)
    {
        List<UserRecordAccess> userRecordAccessList = [ SELECT  RecordId
                                                        FROM    UserRecordAccess
                                                        WHERE   RecordId =: currentClaimAssessment.Id
                                                        AND     UserId =: UserInfo.getUserId()
                                                        AND     HasReadAccess = true];

        return (userRecordAccessList != null && userRecordAccessList.size() > 0);
    }

    //AMI 04/09/17 - Distributor Integration
    //this method allows to requery records for display after ws call out
   public PageReference queryRecords(){
        system.debug('## Start queryRecords');

        hasAlreadyRun = true;

        mapPartWrapper              = new Map<String, PartWrapper>();
        mapAlreadyOrderedPartWrapper= new Map<String, PartWrapper>();
        Boolean isExpert =false;//WCH 17/08/2021 C-004067

        //VSU 28/03/2018 C-002315             


        encryptedAssessmentId       = String.isBlank(ApexPages.currentPage().getParameters().get('Id'))?null:ApexPages.currentPage().getParameters().get('Id').replaceAll('[^a-zA-Z0-9\\s+]', ''); //WCH 22/09/2021 C-004066
        encryptedChildAssessmentId  =String.isBlank(ApexPages.currentPage().getParameters().get('ChildId'))?null:ApexPages.currentPage().getParameters().get('ChildId').replaceAll('[^a-zA-Z0-9\\s+]', ''); //WCH 22/09/2021 C-004066
        //WCH 01/04/2020 C-003677 
        socb  = String.isBlank(ApexPages.currentPage().getParameters().get('socb'))?null:ApexPages.currentPage().getParameters().get('socb').replaceAll('[^a-zA-Z0-9\\s+]', ''); //WCH 22/09/2021 C-004066
        //WCH 01/04/2020 C-003677 
        
            
        try{
            //VSU 02/04/18 C-002315

      
            encryptedSourceAssessmentId = String.isBlank(ApexPages.currentPage().getParameters().get('SourceAssessmentId'))?null:ApexPages.currentPage().getParameters().get('SourceAssessmentId').replaceAll('[^a-zA-Z0-9\\s+]', ''); //WCH 22/09/2021 C-004066
            Id idSrc = encryptedSourceAssessmentId != null? decryptBase64(encryptedSourceAssessmentId): null;

            doesAssessmentHaveOffers    = false;

            isSalesOrderInAcceptance    = false;

            redirectionInErrorModal     = false;

            displayCFSLA                = false;

            assessmentClaimId        = decryptBase64(encryptedAssessmentId);
            assessmentClaimOrderId   = decryptBase64(encryptedChildAssessmentId);

            Id idAssClaimid = assessmentClaimId;
            Id idAssClaimOrderId = assessmentClaimOrderId;

            system.debug('## assessmentClaimId'+assessmentClaimId);
            system.debug('## assessmentClaimOrderId'+assessmentClaimOrderId);

            Set<String> alreadyOrderedPartsSet = new Set<String>();
            Set<String> alreadySelectedPartsSet = new Set<String>();//WCH 07/01/2017 : C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            Set<String> distributorIdSet       = new Set<String>();
            //WCH 01/04/2020 C-003677 
            String countryCode='';
            List<PrerequisiteOrder__c> SalesOrderListToCancel = [SELECT Id, cancelationReason__c FROM   PrerequisiteOrder__c WHERE  Assessment__c =: assessmentClaimOrderId AND Status__c =: ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE limit 1];
            if(SalesOrderListToCancel.size() > 0){
                shadowSO=SalesOrderListToCancel[0];
            }

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
                                                    OrderLine__r.PartList__r.CrossReferenceId__r.Connected__c, OrderLine__r.PartList__r.CrossReferenceId__r.OEMStandardDiscount__c, OrderLine__r.PartList__r.CrossReferenceId__r.PRE_Price__c, OrderLine__r.DistributorPrice__c, //RBE 10/01/2023 PREv2 Connected - Lot 3.3
                                                    OrderLine__r.PartList__r.OriginalPart__r.OriginalPart__r.Price__c, //RBE 20/01/2023 PREv2 Connected - Lot 3.7
                                                    OrderLine__r.PartList__r.TECH_OriginalPart__c, OrderLine__r.PurchaseOrder__c,OrderLine__r.PurchaseOrder__r.Name,OrderLine__r.PurchaseOrder__r.Distributor__c,
                                                    OrderLine__r.PartList__r.InputType__c, OrderLine__r.Suppliable__c, OrderLine__r.OriginalItem__c,OrderLine__r.SASStatus__c,
                                                    OrderLine__r.PartList__r.OriginalPart__r.QuantityOrdered__c, OrderLine__r.PartList__r.OriginalPart__r.Quantity__c, CataloguePrice__c,
                                                    OrderLine__r.PurchaseOrder__r.DistributorConnected__c, /* ASE : 19/02/18: case C-002236*/ OrderLine__r.PurchaseOrder__r.Distributor__r.OrderRequest__c,OrderLine__r.ExpectedDeliveryDuration__c, OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.ReferenceNumber__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Name,OrderLine__r.PurchaseOrder__r.BodyShopOrderNumber__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,OrderLine__r.PurchaseOrder__r.Distributor__r.DistributorRegionsCovered__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.DistributorConnected__c,  
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c, /*RLA 23/03/2021 C-004102*/ 
                                                    OrderLine__r.PurchaseOrder__r.wsErrorMessage__c,OrderLine__r.PurchaseOrder__r.wsDate__c,
                                                    OrderLine__r.PurchaseOrder__r.TECH_OrderLines__c, //RBE 20/01/2023 PREv2 Connected - Lot 3.7
                                                    OrderLine__r.PurchaseOrder__r.Status__c,OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_Distributor__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Confirmed__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4ConfirmedWithDelay__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4NotFound__c,
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Other__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_R4Partial__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c, AgencyMode__c, OrderLine__r.PurchaseOrder__r.AgencyMode__c,
                                                    PrerequisiteOrder__c,PrerequisiteOrder__r.TECH_BodyshopCountryCode__c, PrerequisiteOrder__r.Assessment__c, PrerequisiteOrder__r.Assessment__r.ParentAssessment__c,PrerequisiteOrder__r.Status__c,
                                                    PrerequisiteOrder__r.Assessment__r.BodyShop__r.DistributorConnected__c, PrerequisiteOrder__r.Assessment__r.Compensated__c, PrerequisiteOrder__r.Assessment__r.Comment__c,PrerequisiteOrder__r.Assessment__r.BodyShop__c,
                                                    PrerequisiteOrder__r.Assessment__r.Manufacturer__c,PrerequisiteOrder__r.Assessment__r.ModelV2__c,PrerequisiteOrder__r.Assessment__r.FirstRegistrationDate__c ,
                                                    PrerequisiteOrder__r.Assessment__r.PlateNumber2__c,PrerequisiteOrder__r.Assessment__r.VINNumber__c,PrerequisiteOrder__r.Assessment__r.BuildDate__c,
                                                    PrerequisiteOrder__r.Assessment__r.ClaimReference__c,PrerequisiteOrder__r.Assessment__r.BodyShop__r.ParentId, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.ParentId,PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.MultiAddress__c,/* WCH 22/06/22 C-004697 */
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
                                                    OrderLine__r.PurchaseOrder__r.Distributor__r.Agency_V3__c, OrderLine__r.DistributorReference__c, 
                                                    OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c
                                             FROM   Offer__c 
                                             WHERE  PrerequisiteOrder__r.Assessment__r.ParentAssessment__c =: assessmentClaimId AND DeliveryStatus__c != 'CANCELED'  //RBE 17/01/2023
                                             order by OrderLine__r.PurchaseOrder__r.Distributor__r.Name]) //WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                {
                    //system.debug('## currentOffer'+currentOffer);
                    //system.debug('## OrderLine__r.PartList__r.CrossReferenceId__c ' + currentOffer.OrderLine__r.PartList__r.CrossReferenceId__c);
                    // extracting the assessment
                    System.debug('<<<currentOffer.OrderLine__r>>>' + currentOffer.OrderLine__r);
                    if( currentOffer.PrerequisiteOrder__r.Assessment__c == assessmentClaimOrderId &&
                        currentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__c != null)
                    {
                        currentClaimAssessment      = currentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__r;
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

                        if(!isSalesOrderInAcceptance && currentOffer.PrerequisiteOrder__r.Status__c == ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
                        {
                            isSalesOrderInAcceptance = true;
                        }

                        // Constructing the wrapper
                        if(!mapPartWrapper.containsKey(currentOffer.OrderLine__r.PartList__c))
                        {   

                            mapPartWrapper.put(currentOffer.OrderLine__r.PartList__c, new PartWrapper(currentOffer));
                        }
                        else
                        {   
                            mapPartWrapper.get(currentOffer.OrderLine__r.PartList__c).addNewOffer(currentOffer);
                        }

                        if(currentOffer.OrderLine__c != null &&
                            currentOffer.OrderLine__r.PurchaseOrder__c != null &&
                            currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c != null)
                        {
                            distributorIdSet.add(currentOffer.OrderLine__r.PurchaseOrder__r.Distributor__c);
                        }
                    }
                    else if(currentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c > 0 && 
                            currentOffer.OrderLine__r.Suppliable__c == 'YES' && 
                            (
                                    currentOffer.PrerequisiteOrder__r.Status__c != 'PREACCEPTANCE' && 
                                    currentOffer.PrerequisiteOrder__r.Status__c != 'INACCEPTANCE'
                            ))
                    {
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
                    //WCH 07/01/2018 : C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    if(currentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c > 0 && 
                            (currentOffer.PrerequisiteOrder__r.Status__c == 'PREACCEPTANCE' || currentOffer.PrerequisiteOrder__r.Status__c == 'INACCEPTANCE'))
                    {
                        alreadySelectedPartsSet.add(currentOffer.OrderLine__r.PartList__r.OriginalPart__c);
                    }
                    //WCH 29/01/2019 C-002963 - Select/Unselect ALL on R4 Order page
                    toggleButtonVisible = CountryCodeInformationsMapping__c.getValues(currentOffer.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c).ActivateMultisourcing__c ? false: CountryCodeInformationsMapping__c.getValues(currentOffer.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c).ActivateSelectUnselectAll__c;
                    //WCH 01/04/2020 C-003677 
                    if(String.isBlank(countryCode)){
                        countryCode=currentOffer.PrerequisiteOrder__r.TECH_BodyshopCountryCode__c;
                    }
                }
                system.debug('## currentBodyShop ' + currentBodyShop);
                system.debug('## alreadySelectedPartsSet ' + alreadySelectedPartsSet);

                //WCH 01/04/2020 C-003677 
                if(countryCode != null && CountryCodeInformationsMapping__c.getall().containsKey(countryCode) && String.isNotBlank(socb) && socb.equals('true')){
                    showBSCancelSOButton = CountryCodeInformationsMapping__c.getall().get(countryCode).SOCancellationButton__c;
                }
                system.debug('## showBSCancelSOButton ' + showBSCancelSOButton);
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

                //System.debug('@@ distributorHavingTCIdSet:'+distributorHavingTCIdSet);

                // Loop in the map of PartWrapper to set the already ordered parts
                // Why do this as the id of the map is not the original part
                for(PartWrapper currentPartWrapper : mapPartWrapper.values())
                {   
                    currentPartWrapper.orderTheDistributors();//WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    if(alreadyOrderedPartsSet.contains(currentPartWrapper.currentPart.OriginalPart__c))
                    {
                        currentPartWrapper.setAlreadyOrdered();
                        //WCH 07/01/2019 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                        for(Id distOfOrderedPart:currentPartWrapper.mapDistributorWrapper.keyset()){
                            for(Id offerOfOrderedPart : currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.keyset()){
                                currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;
                            }
                        }
                    }

                    //WCH 27/03/2019 C-003153: Select All / Unselect All Issue. reformat code here
                    //WCH 07/01/2019 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    for(Id distOfOrderedPart:currentPartWrapper.mapDistributorWrapper.keyset()){
                        for(Id offerOfOrderedPart : currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.keyset()){
                            if(alreadySelectedPartsSet.contains(currentPartWrapper.currentPart.OriginalPart__c)){
                                currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=false;
                            }
                            //WCH 27/03/2019 C-003153: Select All / Unselect All Issue

                            // if((!currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.DistributorConnected__c) 
                            //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
                            if((!RestDistributorUtility.isConnectedDist(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c)) 
                            || !String.isBlank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c) && (currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c.contains(String.isBlank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c)?'':currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c)) && currentClaimOrderAssessment.OrderOrigin__c.equals('Order') ){
                                    numberOfEligibleParts++;
                            }
                        }
                    }

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
           
           //WCH 22/06/2022 C-004697
        //    for(String currentRP : picklist_values('Contact','RepairCenterCode__c')){
        //      lstMultiaddressRepairCenter.add(new SelectOption(currentRP, currentRP));
        //    }

            
            //RRJ 12/10/2022
            for(String currentRP : picklist_values(currentBodyShop.Id)){
                lstMultiaddressRepairCenter.add(new SelectOption(currentRP, currentRP));
            }

            //DUN 15/11/2017 case 2071
            retrieveParentAndChildrenAccounts();
            //WCH 02/04/2021 C-004067 
            if(!(verifyPermission(currentClaimAssessment) || isExpert)){
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
        }
        return null;
    }
    //WCH 28/01/2019 C-002963 - Select/Unselect ALL on R4 Order page
    public void toggleIsAcceptedForAllParts(){
        system.debug('toggleValue>>'+toggleValue);
        Boolean passOnAllOffer=true;
        Integer numberOfEligibleParts=0;
        for(PartWrapper currentPartWrapper : mapPartWrapper.values()){ 
            for(Id distOfOrderedPart:currentPartWrapper.mapDistributorWrapper.keyset()){
                for(Id offerOfOrderedPart : currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.keyset()){
                    //WCH 26/03/2019 C-003153 : Select All / Unselect All Issue
                    // if(((!currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.DistributorConnected__c) 
                    if(((!RestDistributorUtility.isConnectedDist(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c)) 
                    || !String.isBlank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c) && (currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_OrderNF__c.contains(String.isBlank(currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c)?'':currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).parentOffer.OrderLine__r.SASStatus__c)) && currentClaimOrderAssessment.OrderOrigin__c.equals('Order')) || !toggleValue){
                        currentPartWrapper.mapDistributorWrapper.get(distOfOrderedPart).mapOfferWrapper.get(offerOfOrderedPart).isAccepted=toggleValue;
                        numberOfEligibleParts++;
                    }
                }
            }
        }
        toggleValue=(!passOnAllOffer ? !toggleValue : toggleValue);
        numberOfPartList=numberOfEligibleParts;
    }
    //WCH 22/06/22 C-004697
    public void getAddressDeLivraison(){
        system.debug('## Start getAddressDeLivraison>>'+repairCenterCodeChosen);
        //lstAllBSAddresses = [select Id from Contact where recordtype.developername=:ASPISConstants.CONTACT_RT_DeveloperName_MULTIADDRESS and RepairCenterCode__c=:repairCenterCodeChosen and AccountId=:currentBodyShop.Id];
        lstAllBSAddresses=new List<multiAddressWrapper>();
        for(Contact con1: [select Id,RepairCenterCode__c,Account.Name,MailingStreet,Name, MailingCity, MailingState, MailingPostalcode ,MailingCountry from Contact where recordtype.developername=:'Multiaddress' and isActive__c=true and RepairCenterCode__c=:repairCenterCodeChosen and AccountId=:currentBodyShop.Id order by Name ASC]){
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
                contactChosen=currentMAW.theContact.RepairCenterCode__c+' '+currentMAW.theContact.Name+' '+currentMAW.theContact.MailingStreet;
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
               
        if(string.isNotBlank(assId)){
            decryptedAssId                                                                  = decryptBase64(assId);

            //AMI 16/02/18 : C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c and Rebate to query 
            //                                         - Saving MRID in OL generated  but using Rebate to calculate new pricing for ASP Parts 
            //query current assesssment,po,distributor and parts associated
            //AMI 05/12/17 : Adding Tech_Distributor__c in query
            //DUN 22/06/2018 Bug on logs when partlist size on assessment is greater than 200  
            //for(Assessment__c ass : [select id,BodyShop__c, BodyShop__r.DistributorConnected__c , 
            //                        BodyShop__r.Name,BodyShop__r.VATNumber__c, BodyShop__r.ReferenceNumber__c, 
            //                        BodyShop__r.RecordTypeId, BodyShop__r.CurrencyIsoCode,
            //                        Manufacturer__c, ModelV2__c,  FirstRegistrationDate__c,PlateNumber2__c, VINNumber__c,
            //                        ClaimReference__c,BuildDate__c,Name,
            //                            (select id,Type__c,Quantity__c,PartNumber__c,ProducerName__c,Description__c,Price__c,
            //                                    RecordTypeId, CrossReferenceId__c,Alpha_Scale_MRID__c, CrossReferenceId__r.IAMPartNumber__c, 
            //                                    CrossReferenceId__r.IAMManufacturer__c, DistributorPriceId__c, DistributorPriceId__r.DistributorPartNumber__c,
            //                                    CrossReferenceId__r.OEMPartNumber__c, Assessment__r.Feature__c, Distributor__c, distributor__r.Feature__c
            //                            from PartsLists__r),
            //                            (select id,Name,Assessment__c,Distributor__c,Distributor__r.Name,Distributor__r.DistributorConnected__c,  
            //                                    Tech_ExternalId__c,Status__c,wsDate__c,wsErrorMessage__c,Manual_Creation__c,
            //                                    Rebate__c,Distributor__r.Categories__c, Distributor__r.PartTypeRegionDelayMatrix__c,
            //                                    Distributor__r.Tech_Distributor__c,Distributor__r.Rebate__c,Distributor__r.DistributorCarBrandSupplied__c,
            //                                    Distributor__r.RecordTypeId, Distributor__r.CurrencyIsoCode, Distributor__r.OrderRequest__c
            //                            from Purchaseorders__r
            //                            where Distributor__r.DistributorConnected__c = true and TECH_OrderLines__c != 0)
            //                        from Assessment__c
            //                        where id = :decryptedAssId]){ 
            //    //get assessment associated with current PO
            //    assRecord  = ass;
            //    objReference = ass.Name;

            //    //get all parts associated with assessment
            //    if(!ass.PartsLists__r.isEmpty()){
            //        partMap  = new map <Id, PartList__c>();
            //        for (PartList__c part: ass.PartsLists__r){
            //            partMap.put( part.Id, part);

            //        }
            //    }
            //    system.debug('## partMap:'+partMap);

            //    for(PurchaseOrder__c po : ass.purchaseorders__r){
            //        //get distributor info
            //        distributorLst.add(new Account(id = po.Distributor__c,
            //                    Name = po.Distributor__r.Name, 
            //                    Tech_Distributor__c = po.Distributor__r.Tech_Distributor__c, 
            //                    Categories__c = po.Distributor__r.Categories__c, 
            //                    PartTypeRegionDelayMatrix__c = po.Distributor__r.PartTypeRegionDelayMatrix__c, 
            //                    DistributorConnected__c = po.Distributor__r.DistributorConnected__c, 
            //                    DistributorCarBrandSupplied__c = po.Distributor__r.DistributorCarBrandSupplied__c, 
            //                    Rebate__c =po.Distributor__r.Rebate__c,
            //                    RecordTypeId = po.Distributor__r.RecordTypeId, 
            //                    CurrencyIsoCode = po.Distributor__r.CurrencyIsoCode,
            //                    OrderRequest__c = po.Distributor__r.OrderRequest__c
            //                    ));

            //        //AMI 05/12/17 : add Tech_Distributor__c as key instead of distributor name
            //        mapDistributorNameDistributor.put(po.Distributor__r.Tech_Distributor__c,new Account(id = po.Distributor__c,
            //                                                                                            Name = po.Distributor__r.Name,
            //                                                                                            Categories__c = po.Distributor__r.Categories__c,
            //                                                                                            PartTypeRegionDelayMatrix__c = po.Distributor__r.PartTypeRegionDelayMatrix__c,
            //                                                                                            DistributorConnected__c = po.Distributor__r.DistributorConnected__c,
            //                                                                                            Rebate__c = po.Distributor__r.Rebate__c,
            //                                                                                            Tech_Distributor__c = po.Distributor__r.Tech_Distributor__c));

            //        //get PO Info
            //        mapPOExtIDPO.put(po.Tech_ExternalId__c,po);
            //    }   
            //}//end looping in assessment
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
                                            PurchaseOrder__r.Assessment__r.InsuranceBroker__c,PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c,PurchaseOrder__r.Assessment__r.TECH_EntityCountryCode__c,DistributorReference__c
                                  from OrderLine__c
                                  where PurchaseOrder__r.Assessment__c = :decryptedAssId
                                //   and PurchaseOrder__r.Distributor__r.DistributorConnected__c = true 
                                  //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration

                                  //and PurchaseOrder__r.Distributor__r.Type_of_Substitutes__c includes ('Distributor Connected;Draft Call') WCH 21/07/2022 C-004762
                                  and PurchaseOrder__r.TECH_OrderLines__c != 0
                                  and PurchaseOrder__r.Assessment__r.DisableUpdateStockInfo__c = false]){//RLA 16/05/2019 Case 003145 Spare part Recovery SAS France

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

                wsResponse = makeDraftCall(wsRequest, mapDistributorNameDistributor, assRecord.Id, mapPOExtIDPO, partMap, false, 'OrderR4', 'OrderMakeSelection',''); 

               //wsResponse = callConnectedDistributor(system.label.EIPEndPoint, wsRequest);

               // system.debug('## wsResponse stock:'+wsResponse);
                
               // if(wsResponse != '' && wsResponse != null){
               //     if(!wsResponse.contains('Exceptions')){
               //         //error reported during call out
               //         //update each connected PO with error message
               //         if(wsResponse.contains(' statusCode = ')){
               //             String statusCode = wsResponse.substringAfter(' statusCode = ');
               //             if(statusCode == '200'){
               //                 //Object responseObj = (Object) JSON.deserializeUntyped(WSresponse);
               //                 Map<String, Object> responseObjMap = (Map<String, Object>) JSON.deserializeUntyped(WSresponse);
               //                 message = responseObjMap.containsKey('Message') ? (String.ValueOf(responseObjMap.get('Message')) != null ?  String.ValueOf(responseObjMap.get('Message')) : null ): null; 

               //                 if(message == '' || message == null){ 
               //                     //process response 
               //                     processResponse(wsResponse,
               //                                     mapDistributorNameDistributor,
               //                                     assRecord.Id,
               //                                     mapPOExtIDPO,
               //                                     partMap);
               //                 }
               //                 else{
               //                     updateErroredPO(erroredPO, mapPOExtIDPO, message);
               //                 }
               //             }
               //             else{
               //                 //error reported during call out
               //                 //update each connected PO with error message
               //                 updateErroredPO(erroredPO, mapPOExtIDPO, string.isNotBlank(wsResponse) ? ((wsResponse.length() < 1000) ? wsResponse: system.label.DistributorWSNoInfo) : system.label.DistributorWSNoInfo);                         
               //                 wsResponse = string.isNotBlank(wsResponse) ? ((wsResponse.length() < 1000) ? wsResponse : system.label.DistributorWSNoInfo) : system.label.DistributorWSNoInfo;
               //             }
               //         }
               //     }
               //     else{
               //         system.debug('## System.CalloutException ' + wsResponse);
               //         updateErroredPO(erroredPO, mapPOExtIDPO, (wsResponse.length() < 1000) ? wsResponse : system.label.DistributorWSNoInfo);     
               //     }
               // }
               // system.debug('## erroredPO ' + erroredPO);
               // if(!erroredPO.isEmpty()){
               //     update erroredPO;
               // }

               // //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
               // // Initialise Log Object
               // Log__c newLog = generateLog(wsRequest, WSresponse, 'Draft', message);
               // system.debug('## newLog ' + newLog);
               // if(newLog != null){
               //     insert newLog;
               // }
            }
        }//end if string.isNotBlank(assId)
        //WCH 19/07 C-004762
        system.debug('## mapOriginalOlRecoveredOL1'+mapOriginalOlRecoveredOL1);
        ProcessNonConnectedParts(mapOriginalOlRecoveredOL1,assRecord,partMapNonConnected,olMapPartNonConnected,olMapNonConnected);

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

    global static void updateErroredPO(list <PurchaseOrder__c> erroredPO, map <string,PurchaseOrder__c> mapPOExtIDPO, string errorMsg){
        system.debug('## Start updateErroredPO');

        //update each connected PO with error message
        for(PurchaseOrder__c PO : mapPOExtIDPO.values()){
            erroredPO.add(new PurchaseOrder__c(id = PO.Id,
                                                wsDate__c = system.now(),
                                                wsErrorMessage__c = errorMsg));
        }   

        system.debug('## End updateErroredPO');
    }

    //RLA 09/08/2021 C-004102: FR - Aniel Distributor Integration
    global static void updateErroredPO(list <PurchaseOrder__c> erroredPO, Id poId, string errorMsg){
        system.debug('## Start updateErroredPO');

        //update each connected PO with error message
        // for(PurchaseOrder__c PO : mapPOExtIDPO.values()){
            erroredPO.add(new PurchaseOrder__c(id = poId,
                                                wsDate__c = system.now(),
                                                wsErrorMessage__c = errorMsg));
        // }   

        system.debug('## End updateErroredPO');
    }

    //AMI 04/09/17 - Distributor Integration
    //method to process received response from distributor callout
    global static String processResponse(string wsResponse,
                                        map <string,Account> mapDistributorNameDistributor,
                                        Id assessmentId,
                                        map <string,PurchaseOrder__c> mapPOExtIDPO,
                                        map <Id, PartList__c> partMap,
                                        Boolean isDraft,
                                        String fromUpdateStockInfo){
        system.debug('## Start processResponse');
        String results = '';

        system.debug('## isDraft:'+isDraft);

        //build map distributor name distributor wrapper
        map <string,RestDistributorUtility.dist> deserialiseDist;

        list<ASPISCreatePOOrderLines.responseToGenerate> respToGenerateList                 = new list<ASPISCreatePOOrderLines.responseToGenerate>();
        map<Id, list<OrderLine__c>> originalOLMap                                           = new map<Id, list<OrderLine__c>>();
        map<Id, list<OrderLine__c>> alternativeOLMap                                        = new map<Id, list<OrderLine__c>>();
        map<Id, list<OrderLine__c>> bundleItemOLMap                                         = new map<Id, list<OrderLine__c>>();
        map<Id, list<OrderLine__c>> originalOLMapToUpd                                      = new map<Id, list<OrderLine__c>>();
        map<Id, list<OrderLine__c>> bundleItemOLMapToUpd                                    = new map<Id, list<OrderLine__c>>();
        map<Id, list<OrderLine__c>> alternativeOLMapToUpd                                   = new map<Id, list<OrderLine__c>>();
        map<Id, PurchaseOrder__c> updatedPOMap                                              = new map<Id, PurchaseOrder__c>(); 

        if(string.isNotBlank(wsResponse)){
            deserialiseDist                                                                 = RestDistributorUtility.deserialiseRespIntoDistributors(wsResponse);  
        }
        system.debug('## deserialiseDist ' + deserialiseDist);


        //AMI 18/10/17 : SAS: Remplacement de pièce
        map <Id, PartList__c> updatedPartMap = new map <Id, PartList__c>();

        //RLA 16/05/2019 Case 003145 Spare part Recovery SAS France
        String country = '';
        String featureAssessment = '';
        Account distAcc;
        //map<String,CountryCodeInformationsMapping__c> mapCountryCodeInformationMapping = CountryCodeInformationsMapping__c.getall();
        map <Id, PartList__c> allPartsMap = new map <Id, PartList__c>();

        //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
        Boolean updatePartlist = false;



        //AMI 16/02/18 : C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c and Rebate to query 
        //                                         - Saving MRID in OL generated but using Rebate to calculate new pricing for ASP Parts 
        //AMI 18/10/17 : SAS: Remplacement de pièce
        //reconstruct partMap so that iam part number can be queried
        for(PartList__c pt : [select id,CrossReferenceId__c,CrossReferenceId__r.IAMPartNumber__c,ForTechSubsNumber__c,InputType__c,Currency__c,Assessment__r.InsuranceBroker__c,TechCheckForSubstitute__c,
                                    PartNumber__c,Price__c,Type__c,ProducerName__c,Description__c,Quantity__c,Alpha_Scale_MRID__c, Assessment__r.TECH_EntityCountryCode__c,
                                    Assessment__r.Feature__c, NextDistributors__c,OriginalPart__c,OriginalPart__r.NextDistributors__c,VAT__c/*RLA 3145*/
                                    ,TECH_OriginalPart__c,TechCatalog_Price_Dist_Connected__c//RLA 14/10/2020 C-004005
                                from PartList__c
                                where Assessment__c =:assessmentId ]){//RLA 16/05/2019 Case 003145 Spare part Recovery SAS France

            if (partMap.containsKey(pt.Id)){
                updatedPartMap.put(pt.Id,pt);
            }
            allPartsMap.put(pt.Id,pt);

            // system.debug('## pt:'+pt);
            //RLA 16/05/2019 Case 003145 Spare part Recovery SAS France
            if (String.isNotBlank(pt.Assessment__r.TECH_EntityCountryCode__c )){
                country = pt.Assessment__r.TECH_EntityCountryCode__c;
                featureAssessment = pt.Assessment__r.Feature__c;
                // system.debug('## got in:'+country);

            }
            //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
            if (String.isnotBlank(pt.Assessment__r.InsuranceBroker__c) && system.label.InsBrokerName.contains(pt.Assessment__r.InsuranceBroker__c) && !updatePartlist){
                CustomerInformationsMapping__mdt customerInfo = RestDistributorUtility.getcustomerMapping(pt.Assessment__r.InsuranceBroker__c);
                if (customerInfo != null
                    && customerInfo.Optimize_DQC__c){
                        updatePartlist = true;
                        system.debug('@@ i am IG true here');

                    }
                
            }
        }

        if (deserialiseDist != null){
        for(String distributor : deserialiseDist.keyset()){ 
            //ASE: 07/05/2018: Rework response EIP
            RestDistributorUtility.dist distIns  = deserialiseDist.get(distributor);
            if(mapDistributorNameDistributor.containsKey(distributor)){
                distAcc = mapDistributorNameDistributor.get(distributor);       
                
                String POKey = String.valueOf(assessmentId)+ String.valueOf(distAcc.Id);

                if(mapPOExtIDPO.containsKey(POKey) 
                    //&& deserialiseDist.get(distributor).Lines != null
                    ){
                    PurchaseOrder__c PO = mapPOExtIDPO.get(POKey); 
                    //processing of PO and OL
                    //AMI 18/10/17 : SAS: Remplacement de pièce
                    system.debug('## distIns.Success:'+distIns.Success);
                    if(distIns.Success == 'true'){
                        ASPISCreatePOOrderLines.processPOOL(deserialiseDist.get(distributor).Lines, 
                                                            PO, 
                                                            distAcc, 
                                                            updatedPartMap, 
                                                            'DRAFT', 
                                                            respToGenerateList, 
                                                            originalOLMap, 
                                                            alternativeOLMap, 
                                                            bundleItemOLMap, 
                                                            originalOLMapToUpd,
                                                            alternativeOLMapToUpd,
                                                            bundleItemOLMapToUpd,
                                                            updatedPOMap, 
                                                            isDraft,
                                                            null,
                                                            null,
                                                            null,
                                                            null);
                    }
                    else{
                        updatedPOMap.put(PO.Id, new PurchaseOrder__c(Id = PO.Id, wsErrorMessage__c = distIns.Message, wsDate__c = system.now()));
                        respToGenerateList.add(new ASPISCreatePOOrderLines.responseToGenerate('Update', PO.Id, null, false, null, distIns.Message));
                    }
                }
            }
        }
        }
        
        system.debug('## respToGenerateList ' + respToGenerateList); 
        system.debug('## originalOLMap ' + originalOLMap);
        system.debug('## alternativeOLMap ' + alternativeOLMap);
        system.debug('## bundleItemOLMap ' + bundleItemOLMap);
        system.debug('## updatedPOMap ' + updatedPOMap); 

        //upsert all results
        ASPISCreatePOOrderLines.upsertAll(originalOLMap, 
                                            alternativeOLMap, 
                                            bundleItemOLMap, 
                                            originalOLMapToUpd,
                                            alternativeOLMapToUpd,
                                            bundleItemOLMapToUpd,
                                            assessmentId, 
                                            updatedPOMap, 
                                            mapPOExtIDPO,
                                            true,
                                            respToGenerateList,
                                            false,
                                            null,         
                                            updatePartlist ? updatedPartMap : null,//RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check                                 
                                            fromUpdateStockInfo);//RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO Added parameter

        //AP34BundleGeneration.generateBundlesOffers(updatedPOMap.KeySet());
        if(!respToGenerateList.isEmpty()){
            results = Json.serialize(respToGenerateList);  
        }
        system.debug('## originalOLMap '+ originalOLMap);
        system.debug('## distAcc '+ distAcc);
        //system.debug('## distAcc '+ distAcc.DistributorConnected__c);
        //system.debug('## distAcc '+ distAcc.Tech_Distributor__c);
        system.debug('## countryu '+ country);
        system.debug('## featureAssessment '+ featureAssessment);
        system.debug('## updatedPartMap '+ updatedPartMap);
        //system.debug('## countryu'+ mapCountryCodeInformationMapping.get(country).UseSparePartsRecovery__c);

        if (String.isNotBlank(system.Label.DistributorsForRecovery)
            && distAcc != null
            // && distAcc.DistributorConnected__c
            //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
            && RestDistributorUtility.isConnectedDist (distAcc.Type_of_Substitutes__c)
            && system.Label.DistributorsForRecovery.contains(distAcc.Tech_Distributor__c)
            && String.isnotblank(featureAssessment)    
            && featureAssessment.contains('PilotDirectSourcing')){
            system.debug('## got in '+assessmentId);
            recoverySAS(assessmentId,allPartsMap);

        }


        system.debug('## End processResponse');
        return results;
    }
    public static void recoverySAS(string assessmentId,map <Id, PartList__c> allPartsMap){
        system.debug('## start recoverySAS');

        Set<String> setStatusSAS = new set <String>(system.Label.SparePartRecoveryStatus.split(';'));
        system.debug('## setStatusSAS '+setStatusSAS);
        //list<OrderLine__c> olList = new list<OrderLine__c>();
        Map<Id,Purchaseorder__c> mapPosDirectSourcing = new map<Id,Purchaseorder__c>();
        //Map of distributor and its PO
        Map<Id,Purchaseorder__c> mapAllPOsDist = new map<Id,Purchaseorder__c>();
        Map<Id,list<OrderLine__c>> mapPOOrderlines = new map<Id,list<OrderLine__c>>();
        Map<Id,list<OrderLine__c>> mapAllOrderlines = new map<Id,list<OrderLine__c>>();
        Map<Id,Offer__c> mapAllOffers = new map<Id,Offer__c>();
        //String containing next priority that the PO should be created
        String nextPriority = '';
        //map of assessment id and a set of agency distributors
        map<Id,set<Id>> mapAssIdSetAgencyDist = new map<Id,set<Id>>();
        //map <Assessment Id,map<Distributor Id, Priority of distributor>>
        map<Id,map<Id,String>> mapAssIdDistIdPriority = new map<Id,map<Id,String>>();
        //map <Assessment,map<distributorId,list<PartList>>>
        map<Assessment__c,map<Id,set<PartList__c>>> mapAssIdmapDistIdListPartList = new map<Assessment__c,map<Id,set<PartList__c>>>();        
        //map of country code and its correcsponding business hours
        map<String,BusinessHours> mapCountryCodeBusinessHours = new map<String,BusinessHours>();
        //Set of country codes 
        Set<String> setCountryCode = new set<String>();
        //map of country code and CountryCodeInformationsMapping__c
        map<String,CountryCodeInformationsMapping__c> mapCountryCodeInfo = CountryCodeInformationsMapping__c.getall();
        //List of purchase orders to insert
        list<PurchaseOrder__c> listPurchaseOrderToInsert = new list<PurchaseOrder__c>();
        //List of Orderlines to insert            
        list<OrderLine__c> listOrderlinesToInsert = new list<OrderLine__c>();
        //Set of direct Orders        
        Set<Id> setDirectOrders = new Set<Id>();
        //map <distributor id+'-'+directOrderId, and its corresponding direct order>
        map<String,DirectOrder__c> mapDistIdDirectOrder = new Map<String,DirectOrder__c>();
        Map<String, String> mapDistributorsPriority = new map<String,String>();
        //map of OL id and its current distributor
        Map<Id,String> mapOLCurrentDist = new map<Id,String>();
        Map<Id,PartList__c> mapPartListToUpdate = new map<Id,PartList__c>();
        //SO to attach to PO
        String salesOrderforPO = '';
        //Map distributor and PartTypeRegionDelayMatrix__c
        Map<Id,String> mapdistDistributionDelay = new map<Id,String>();
        //Map distributor and PartTypeRegionDelayMatrix__c        
        Map<Id,Map<string,String>> mapDistTypeDelay = new Map<Id,Map<String,String>>();


        for (Offer__c off: [select Id,
                                OrderLine__r.SASStatus__c,OrderLine__r.partlist__c,OrderLine__r.OriginalItem__c,
                                OrderLine__r.PartList__r.ForTechSubsNumber__c,/*RLA IG 08/06/2020 */
                                OrderLine__r.PartList__r.NextDistributors__c,
                                OrderLine__r.PartList__r.OriginalPart__r.NextDistributors__c,
                                OrderLine__r.PartList__r.PartNumber__c,OrderLine__r.PartList__r.DiscountRecord__c,
                                OrderLine__r.PartList__r.OriginalPart__c,OrderLine__r.PartList__r.OriginalPart__r.OriginalPart__c,
                                OrderLine__r.PartList__r.OriginalPart__r.OriginalPart__r.Price__c,
                                OrderLine__r.PartList__r.Price__c,
                                OrderLine__r.PartList__r.Description__c,OrderLine__r.PartList__r.Quantity__c,
                                OrderLine__r.PartList__r.VAT__c,OrderLine__r.PartList__r.ProducerName__c,
                                OrderLine__r.PartList__r.Alpha_Scale_MRID__c,OrderLine__r.PartList__r.DiscountRecord__r.BSdiscount__c,
                                OrderLine__r.PartList__r.Type__c,
                                OrderLine__r.PurchaseOrder__c,OrderLine__r.purchaseOrder__r.Distributor__r.Tech_Distributor__c,
                                OrderLine__r.purchaseOrder__r.Current_Priority__c,OrderLine__r.purchaseOrder__r.Assessment__c, 
                                OrderLine__r.purchaseOrder__r.Assessment__r.TECH_EntityCountryCode__c, 
                                OrderLine__r.purchaseOrder__r.Assessment__r.Tech_DirectOrders__c,
                                OrderLine__r.purchaseOrder__r.Assessment__r.TechDistAndDirectOrder__c,
                                OrderLine__r.purchaseOrder__r.TECH_AssessmentCountryCode__c,
                                OrderLine__r.purchaseOrder__r.Rebate__c,
                                OrderLine__r.purchaseOrder__r.Name,
                                OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,
                                Prerequisiteorder__c,
                                OrderLine__r.PartList__r.ASNetPrice__c
                            From Offer__c
                            Where OrderLine__r.PurchaseOrder__r.Assessment__c =: assessmentId]){
            system.debug('## off '+off);
            //olList.add(off.OrderLine__r);
            if (off.Prerequisiteorder__c != null){
                salesOrderforPO =off.Prerequisiteorder__c;
            } 
            if (off.OrderLine__r.OriginalItem__c != null){
                if (mapAllOrderlines.containsKey(off.OrderLine__r.OriginalItem__c)){
                    mapAllOrderlines.get(off.OrderLine__r.OriginalItem__c).add(off.OrderLine__r);  
                }
                else{
                    mapAllOrderlines.put(off.OrderLine__r.OriginalItem__c,new list<OrderLine__c>{off.OrderLine__r});      
                }  
            }

            if (off.OrderLine__r.PurchaseOrder__c != null
                && String.isNotBlank(off.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_Distributor__c)
                && system.Label.DistributorsForRecovery.contains(off.OrderLine__r.PurchaseOrder__r.Distributor__r.Tech_Distributor__c)){
                mapPosDirectSourcing.put(off.OrderLine__r.PurchaseOrder__c, off.OrderLine__r.PurchaseOrder__r);
                
                if (mapPOOrderlines.containsKey(off.OrderLine__r.PurchaseOrder__c)){
                    mapPOOrderlines.get(off.OrderLine__r.PurchaseOrder__c).add(off.OrderLine__r);  
                }
                else{
                    mapPOOrderlines.put(off.OrderLine__r.PurchaseOrder__c,new list<OrderLine__c>{off.OrderLine__r});      
                }    
                

            }
            if (off.OrderLine__r.PurchaseOrder__c != null){
                mapAllPOsDist.put(off.OrderLine__r.PurchaseOrder__r.Distributor__c, off.OrderLine__r.PurchaseOrder__r);
            }

            if (off.OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c != null){
                mapdistDistributionDelay.put(off.OrderLine__r.PurchaseOrder__r.Distributor__c,off.OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c);
            }
            mapAllOffers.put(off.Id,off);

        }

        system.debug('## mapPosDirectSourcing '+mapPosDirectSourcing);
        system.debug('## mapPOOrderlines '+mapPOOrderlines);
        system.debug('## mapAllPOsDist '+mapAllPOsDist);

        if(!mapPOOrderlines.isEmpty()
            && !mapPosDirectSourcing.isEmpty()){
            map<Id,OrderLine__c> mapOlsForRecovery = new map<Id,OrderLine__c>();
            map<Id,PartList__c> mapOlPartlist = new map<Id,PartList__c>();
            map<Id,list<OrderLine__c>> mapOlsChildrenRecovery = new map<Id,list<OrderLine__c>>();
            set<String> setDistributors = new set<String>();

            for (Purchaseorder__c po: mapPosDirectSourcing.values()){
                nextPriority = '';
                //Getting the next priority to search for distributors
                Integer nextPriorityNumber = po.Current_Priority__c != null ? (Integer.valueOf((po.Current_Priority__c.split('P')[1])) + 1) : 0;                   
                
                nextPriority = 'P'+ nextPriorityNumber;
                
                system.debug('@@ nextPriority '+nextPriority);
                //system.debug('@@ olList '+olList);
                if (mapPOOrderlines.containsKey(po.Id)){
                    system.debug('## got in : ' );

                    //system.debug('## po.OrderLines__r : ' + po.OrderLines__r);
                    //Looping through orderlines of its correcsponding purchase order
                    for(OrderLine__c ol : mapPOOrderlines.get(po.Id)){
                        system.debug('@@ ol '+ol);

                        system.debug('@@ setStatusSAS.contains(ol.SASStatus__c) '+!setStatusSAS.contains(ol.SASStatus__c));
                        system.debug('@@ ol.partlist__c != null '+ol.partlist__c != null);
                        system.debug('@@ allPartsMap.containskey(ol.partlist__c) '+allPartsMap.containskey(ol.partlist__c));

                        //RLA 05/11/2020 C-004028 Add parts NOTFOUND in SAS recovery
                        String partNumber = '\''+ ol.partlist__r.PartNumber__c + '\'' ;
                        if (!setStatusSAS.contains(ol.SASStatus__c)
                            && ol.partlist__c != null
                            && ol.OriginalItem__c == null
                            && allPartsMap.containskey(ol.partlist__c)
                            && !RestDistributorUtility.isFakeRef(partNumber)//RLA 05/11/2020 C-004028 Add parts NOTFOUND in SAS recovery
                            ){
                            
                            system.debug('@@ oallPartsMap.get(ol.partlist__c) '+allPartsMap.get(ol.partlist__c));
                            
                            if(string.isnotblank(ol.PartList__r.NextDistributors__c)
                                && string.isblank(ol.PartList__r.Alpha_Scale_MRID__c)){
                                mapOlsForRecovery.put(ol.id,ol);
                                //setDistributors.add(ol.PartList__r.NextDistributors__c);
                                String distId = '';
                                system.debug('## nextPriority : ' + nextPriority);
                                list<String> listDistPriorityArray = ol.PartList__r.NextDistributors__c.split(nextPriority+':');
                                system.debug('## listDistPriorityArray : ' + listDistPriorityArray);
                                list<String> listPriority = listDistPriorityArray[1].split('}');
                                system.debug('## listPriority : ' + listPriority);
                                list<String> listdist = listPriority[0].split(';');
                                setDistributors = new set <String>();
                                for (String dis:listdist ){
                                    if (dis.contains('-true')){
                                        setDistributors.add(dis.split('-true')[0]);
                                    } 
                                    else{
                                        setDistributors.add(dis);
                                    }
                                }
                                // setDistributors = new set <String>(listPriority[0].split(';'));
                                mapOlPartlist.put(ol.Id, ol.partlist__r);
                                string plCurrentDistList = listDistPriorityArray[0] + nextPriority + ':' + listPriority[0] + '}';
                                system.debug('## plCurrentDistList : ' + plCurrentDistList);
                                string plNextDistList = listPriority.size() > 1 ? listPriority[(listPriority.size() - 1)].removeStart(',') + '}' : '';
                                system.debug('## plNextDistList : ' + plNextDistList);
                                mapPartListToUpdate.put(ol.PartList__c, new PartList__c(Id = ol.PartList__c, NextDistributors__c = plNextDistList));
                        
                                for (String dist:setDistributors ){

                                    if (mapAllPOsDist.containsKey(dist)){
                                        setDistributors.remove(dist);    
                                    }


                                }

                                for(String distLine : listdist){
                                system.debug('## here 1 : ' );
                                    distId = distLine.contains('-true') ? distId = distLine.split('-true')[0] : distLine;

                                    mapOLCurrentDist.put(ol.id, distId);
                                system.debug('## here 1 : ' );

                                    if (setDistributors.contains(distId)){
                                system.debug('## here 1 : ' );

                                        //Checking if distributor contains "-true" value which is agencyMode = true
                                        
                                        if(distId != null){
                                            //Adding assessment country code to setCountryCode 
                                            setCountryCode.add(po.Assessment__r.TECH_EntityCountryCode__c);
                                            //building map<Assessment, set<Agency distributor ids>>
                                            if(distLine.contains('-true')){
                                                if(!mapAssIdSetAgencyDist.containsKey(po.Assessment__c)){
                                                    mapAssIdSetAgencyDist.put(po.Assessment__c,new set <Id>{distId});
                                                }
                                                else{
                                                    mapAssIdSetAgencyDist.get(po.Assessment__c).add(distId);
                                                }
                                            }
                                            //building map<Assessment Id, map<Distributor id, Next Priority
                                            if(!mapAssIdDistIdPriority.containsKey(po.Assessment__c)){
                                                mapAssIdDistIdPriority.put(po.Assessment__c, new map<Id,String>{(Id)distId => nextPriority});
                                            }
                                            else if(!mapAssIdDistIdPriority.get(po.Assessment__c).containsKey(distId)){
                                                mapAssIdDistIdPriority.get(po.Assessment__c).put((Id)distId,nextPriority);
                                            }
                                            //building set of direct order ids in setDirectOrders
                                            if(po.Assessment__r.Tech_DirectOrders__c != null){
                                                for(String dirtOrd : po.Assessment__r.Tech_DirectOrders__c.split(';')){
                                                    setDirectOrders.add(dirtOrd);
                                                }
                                            }
                                            if(po.Assessment__r.TechDistAndDirectOrder__c != null){

                                                mapDistributorsPriority = ASPISDirectSourcing.buildMapDisPrio(po.Assessment__r.TechDistAndDirectOrder__c);
                                            }

                                            if (setDistributors.contains(distId)){
                                                //building map <Assessment,map<Distributor id, list <partlist>>>
                                                if(!mapAssIdmapDistIdListPartList.containsKey(po.Assessment__r)){
                                                    mapAssIdmapDistIdListPartList.put(po.Assessment__r, new map<Id,set<PartList__c>>{(Id)distId => new set<PartList__c>{ol.PartList__r}});
                                                }
                                                else{
                                                    if(!mapAssIdmapDistIdListPartList.get(po.Assessment__r).containsKey((Id)distId)){
                                                        mapAssIdmapDistIdListPartList.get(po.Assessment__r).put((Id)distId, new set<PartList__c>{ol.PartList__r});
                                                    }
                                                    else{
                                                        mapAssIdmapDistIdListPartList.get(po.Assessment__r).get((Id)distId).add(ol.PartList__r);
                                                    }
                                                }
                                            }
                                        }
                                    }

                                }
                                system.debug('## setDistributors : ' + setDistributors);

                                //String plCurrentDistList = listDistPriorityArray[0] + nextPriority + ':' + listPriority[0] + '}';
                                //system.debug('## plCurrentDistList : ' + plCurrentDistList);
                                //plNextDistList = listPriority.size() > 1 ? listPriority[(listPriority.size() - 1)].removeStart(',') + '}' : '';
                                //system.debug('## plNextDistList : ' + plNextDistList);

                            }
                            else if(string.isnotblank(ol.PartList__r.Alpha_Scale_MRID__c)
                                && string.isnotblank(ol.PartList__r.OriginalPart__r.NextDistributors__c)){
                                if (mapOlsChildrenRecovery.containsKey(ol.OriginalItem__c)){
                                    mapOlsChildrenRecovery.get(ol.OriginalItem__c).add(ol);
                                }
                                else{
                                    mapOlsChildrenRecovery.put(ol.OriginalItem__c,new list<OrderLine__c >{ol});
                                }
                            }

                        }
                        
                    }//end for allOLs
                }
            }
            system.debug('@@ mapAssIdmapDistIdListPartList '+mapAssIdmapDistIdListPartList);
            system.debug('@@ setDistributors '+setDistributors);
            system.debug('@@ mapOlsForRecovery '+mapOlsForRecovery);
            system.debug('@@ mapOlsChildrenRecovery '+mapOlsChildrenRecovery);
            if(mapAssIdmapDistIdListPartList.size() > 0){
                //Looping through list of selected direct orders to build map<Distributor Id, Direct Order>
                for(DirectOrder__c DOs :[select Id,name,Type__c,Priority__c,Distributor__c from DirectOrder__c where Id in : setDirectOrders]){
                    system.debug('## DOs : '+ DOs);
                    mapDistIdDirectOrder.put(DOs.Distributor__c+'-'+DOs.Id,DOs);
                }
                system.debug('## mapDistIdDirectOrder : '+ mapDistIdDirectOrder);
                //looping through set of country codes to build map <country code,business hours>
                for(String couCode : setCountryCode){
                    mapCountryCodeBusinessHours.put(couCode,ASPISConstants.getBusinessHours(couCode));
                }
                for(Assessment__c ass : mapAssIdmapDistIdListPartList.keySet()){
                    //looping through mapAssIdmapDistIdListPartList.get(assessment).values to create a purchase order for each distributor
                    for(Id disId : mapAssIdmapDistIdListPartList.get(ass).keySet()){
                        String rulesAppliedDescription = '';
                        PurchaseOrder__c newPO = new PurchaseOrder__c ( assessment__c = ass.Id,
                                                                        SparePartsRecovery__c = true,
                                                                        validityDate__c = Date.valueOf(Businesshours.add(mapCountryCodeBusinessHours.get(ass.TECH_EntityCountryCode__c).id,datetime.now(),mapCountryCodeInfo.get(ass.TECH_EntityCountryCode__c).Validity_Duration_Purchase_Order__c!=null?Integer.valueOf(mapCountryCodeInfo.get(ass.TECH_EntityCountryCode__c).Validity_Duration_Purchase_Order__c)*60*60*1000L:0)),               
                                                                        status__c = 'PREDRAFTQUOTE',
                                                                        distributor__c = disId,
                                                                        recordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId(),
                                                                        SLAQuotationEntryDate__c = datetime.now(),
                                                                        Tech_ExternalId__c = String.valueOf(ass.Id) + String.valueOf(disId),
                                                                        Current_Priority__c = mapAssIdDistIdPriority.get(ass.Id).get(disId),
                                                                        AgencyMode__c = (mapAssIdSetAgencyDist.containsKey(ass.Id) && mapAssIdSetAgencyDist.get(ass.Id).contains(disId)));
                        system.debug('@@ newPO '+newPO);
                        for(String distIdDOId : mapDistIdDirectOrder.keySet()){
                            system.debug('## distIdDOId '+ distIdDOId);      
                            if(distIdDOId.contains(disId) && ass.Tech_DirectOrders__c.contains(distIdDOId.split('-')[1])){
                                system.debug('## disId '+ disId);    
                                //WCH 20181121 : C-002868 : additional check on PO to be created priority value
                                if (mapDistributorsPriority.containskey(distIdDOId) &&
                                    mapDistributorsPriority.get(distIdDOId) == mapDistIdDirectOrder.get(distIdDOId).Priority__c && mapDistributorsPriority.get(distIdDOId)==mapAssIdDistIdPriority.get(ass.Id).get(disId)){ //RLA  C-002868 :
                                    rulesAppliedDescription += 'Name of record:' + mapDistIdDirectOrder.get(distIdDOId).Name +
                                                            '\nType de sourcing:' + mapDistIdDirectOrder.get(distIdDOId).Type__c +
                                                            '\nPriority:' + mapDistIdDirectOrder.get(distIdDOId).Priority__c + '\n';
                                }                        }
                        }
                        newPO.TECHRulesAppliedDescription__c = rulesAppliedDescription;
                        newPO.PrerequisiteOrder__c = salesOrderforPO;
                        listPurchaseOrderToInsert.add(newPO);
                        system.debug('@@ newPO '+newPO);
                        
                        
                    }
                }//endfor Assessment
            }//end for mapAssessment
            //Checking if size of list of purchase orders to insert is greater than zero
            if(listPurchaseOrderToInsert.size() > 0){

                //inserting new purchase orders
                insert listPurchaseOrderToInsert;
                for (PurchaseOrder__c po:listPurchaseOrderToInsert ){
                    mapAllPOsDist.put(po.distributor__c, po);
                }
            }
            system.debug('@@ mapAllPOsDist '+mapAllPOsDist);
            system.debug('@@ mapOLCurrentDist '+mapOLCurrentDist);
            system.debug('@@ mapOlPartlist '+mapOlPartlist);
            
            //for (String dist: mapAllPOsDist.keyset()){
            //    Purchaseorder__c current PO = mapAllPOsDist.get(dist);


            //}
            Map<Id, OrderLine__c> mapOriginalOlRecoveredOL = new map<Id,OrderLine__c>();
            Map<Id, OrderLine__c> mapOriginalOlToDelete = new map<Id,OrderLine__c>();
            Map<Id, Offer__c> mapOffersToUpdate = new map<Id,Offer__c>();
            Map<Id, Purchaseorder__c> mapPurchaseOrderToDelete = new map<Id,Purchaseorder__c>();

            For (Account dist: [select Id, PartTypeRegionDelayMatrix__c 
                                From account
                                Where Id IN: mapAllPOsDist.keyset()]){
                if( dist.PartTypeRegionDelayMatrix__c != null){
                    Map<String,String> mapTypeDelay = new map<String,String>();        
                    for(String matrixline :  dist.PartTypeRegionDelayMatrix__c.split(';'))
                    {
                        List<String> matrixValues = matrixline.split(':');
                        String partType = matrixValues[0].right(1);
                        String delayValue = matrixValues[2].left(2);
                        
                        if(!mapTypeDelay.containsKey(partType)){
                            mapTypeDelay.put(partType, delayValue);
                        }
                        mapDistTypeDelay.put(dist.id,mapTypeDelay);
                    }
                            
                }

            }
            system.debug('@@ mapDistTypeDelay '+mapDistTypeDelay);

            for ( OrderLine__c ol:  mapOlsForRecovery.values()){
                system.debug('@@ ol '+ol);

                if (mapOLCurrentDist.containsKey(ol.id)){
                    String distributor = mapOLCurrentDist.get(ol.id);
                    system.debug('@@ distributor '+distributor);

                    if(mapOlPartlist.containsKey(ol.id)
                        && mapAllPOsDist.containsKey(distributor)){
                        system.debug('@@ part '+mapOlPartlist.get(ol.id));
                        system.debug('@@ PO '+mapAllPOsDist.get(distributor));
                        Map<String,String> mapTypeDelay;
                        if (mapDistTypeDelay.containskey(distributor)){
                          mapTypeDelay = mapDistTypeDelay.get(distributor);
                        }
                        system.debug('@@ mapTypeDelay '+mapTypeDelay);

                        OrderLine__c newRecoveredOL = PurchaseOrderTriggerHandler.createOL(mapOlPartlist.get(ol.id),null,mapAllPOsDist.get(distributor),'');
                        newRecoveredOL.Ordertype__c = 'FINAL';
                        //listOrderlinesToInsert.add(newRecoveredOL);
                        ol.TechRecoveredOL__c = newRecoveredOL.TechExternalId__c;
                        newRecoveredOL.ExpectedDeliveryDuration__c = mapTypeDelay != null ? (mapTypeDelay.containsKey(newRecoveredOL.Type__c) ? String.valueOf((Integer.valueOf(mapTypeDelay.get(newRecoveredOL.Type__c)))/24) : null ) : null;
                        system.debug('@@ newRecoveredOL.ExpectedDeliveryDuration__c '+newRecoveredOL.ExpectedDeliveryDuration__c);

                        mapOriginalOlRecoveredOL.put(ol.id,newRecoveredOL);
                    }
                }

            }
            system.debug('@@ mapOriginalOlRecoveredOL '+mapOriginalOlRecoveredOL );
            system.debug('@@ mapOlsForRecovery '+mapOlsForRecovery);
            system.debug('@@ mapAllOrderlines '+mapAllOrderlines);

            //WCH 19/07 C-004762
            mapOriginalOlRecoveredOL1=mapOriginalOlRecoveredOL;

            if(mapOriginalOlRecoveredOL.size() > 0){

                //inserting new purchase orders
                upsert mapOriginalOlRecoveredOL.values() TechExternalId__c;
                system.debug('@@ mapOriginalOlRecoveredOL '+mapOriginalOlRecoveredOL);


                for (OrderLine__c ol: mapOlsForRecovery.values()){
                    if (mapOriginalOlRecoveredOL.containsKey(ol.id)
                       && ol.TechRecoveredOL__c  == mapOriginalOlRecoveredOL.get(ol.id).TechExternalId__c){
                        ol.TechRecoveredOL__c = mapOriginalOlRecoveredOL.get(ol.id).Id;
                        mapOriginalOlToDelete.put(ol.id,ol); 
                    }
                    if (mapAllOrderlines.containsKey(ol.id)){
                        for (OrderLine__c childOl:mapAllOrderlines.get(ol.id) ){
                            mapOriginalOlToDelete.put(childOl.id,childOl);   
                        }

                    }
                } 
            }
            system.debug('@@ mapOlsForRecovery '+mapOlsForRecovery);
            system.debug('@@ mapOriginalOlToDelete '+mapOriginalOlToDelete);
            for (Offer__c off: mapAllOffers.values()){
                if (mapOriginalOlToDelete.containsKey(off.Orderline__c)
                    &&  mapOriginalOlRecoveredOL.containsKey(off.Orderline__c)){
                    off.Orderline__c = mapOriginalOlRecoveredOL.get(off.Orderline__c).Id;
                    mapOffersToUpdate.put(off.Id,off);
                }
            }
            system.debug('@@ mapOriginalOlToDelete '+mapOriginalOlToDelete);
            system.debug('@@ mapOffersToUpdate '+mapOffersToUpdate);
            system.debug('@@ mapPartListToUpdate '+mapPartListToUpdate);
            if (mapOffersToUpdate.size() > 0){
                update mapOffersToUpdate.values();
            }

            if (mapOriginalOlToDelete.size() > 0){
                delete mapOriginalOlToDelete.values();
            }

            if (mapPartListToUpdate.size() > 0){
                update mapPartListToUpdate.values();
            }
            Set<String> setAllDist = new set<String>();
            for (PurchaseOrder__c po: [select id,Distributor__c,
                                        (Select id
                                        From OrderLines__r)
                                        From PurchaseOrder__c
                                        Where Id IN:mapAllPOsDist.values()]){
                if (po.OrderLines__r.size() == 0){
                    mapPurchaseOrderToDelete.put(po.Id,po);
                }
                setAllDist.add(po.Distributor__c);
            }
            if (setAllDist.size() > 0){
                Assessment__c assToUpdate = new Assessment__c(Id=assessmentId ,
                                                               MRSourcing__c =  string.join(new List<String>(setAllDist),';'),
                                                               DisableUpdateStockInfo__c = true);
                system.debug('## assToUpdate'+assToUpdate);
                update assToUpdate;

            }
            if (mapPurchaseOrderToDelete.size() > 0){
                delete mapPurchaseOrderToDelete.values();
            }

           


        }//endfor if orderlines to create
        system.debug('## End recoverySAS');

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

    
    public static void callDistributor(string finalOrderReq, set <id> setPOToUpdate, set <id> sentOlIdSet){ 
        map <string,object> mapinputParam = new map<String,Object>();
        mapinputParam.put('finalOrderReq',finalOrderReq);
        mapinputParam.put('setPOToUpdate',setPOToUpdate);
        mapinputParam.put('sentOlIdSet',sentOlIdSet);
        callDistributor(mapinputParam);
    }


    public static void callDistributor(map <string,object> mapinputParam){ 
        system.debug('## Start callDistributor');

        string finalOrderReq = mapinputParam.containsKey('finalOrderReq') ? (string)mapinputParam.get('finalOrderReq') : '';
        Boolean doAutovalidate = mapinputParam.containsKey('doAutovalidate') ? (Boolean)mapinputParam.get('doAutovalidate') : false;
        set <id>  setPOToUpdate = mapinputParam.containsKey('setPOToUpdate') ? (set <id>)mapinputParam.get('setPOToUpdate') : null;
        set <id>  sentOlIdSet = mapinputParam.containsKey('sentOlIdSet') ? (set <id> )mapinputParam.get('sentOlIdSet') : null;

        // doAutovalidate


        String message;
        string errorReported = '';   
        // ASE: 10/07/2018: C-002659 : Prices & Part Type to be sent to Coler  
        String DistributorOrderReference;     
        //WCH 18/08/2020 C-003864
        Map<String, Object> requestEIPEndpoint = new Map<String, Object>{'EIP_EndPoint' => 'authenticate'};
        Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(requestEIPEndpoint);

        if(string.isNotBlank((String)responseEIPEndpoint.get('EIP_EndPoint'))){//WCH 18/08/2020 C-003864
            /* ASE 19/02/18  C-002236*/
            list<String> reqlst = finalOrderReq.split('-OrderType : ');
            system.debug('## reqlst: '+reqlst);
            String statusPO =  'DRAFTQUOTE' ;
            String WSresponse;
            String purchaseOrderReference;
            Log__c Jsnresponse;

            //kem
            /* String WSresponse = callConnectedDistributor((String)responseEIPEndpoint.get('EIP_EndPoint'), reqlst[0]); */
            //WCH 18/08/2020 C-003864
            system.debug('## WSresponse: KEM1  ' +WSresponse);

            //kem use fake to populate JSON response with custom label responseCalloutValidate
            if (system.label.responseCalloutValidate != 'none' && system.label.responseCalloutValidate.StartsWith('a0D')){
                try{
                    Jsnresponse = [Select id,WSResponse__c,JSONResponse__c from Log__c Where Id = :system.label.responseCalloutValidate LIMIT 1];
                    WSresponse = Jsnresponse.JSONResponse__c;
                }catch(QueryException e){
                    System.debug( e.getMessage());
                    //return null;
                }
            }

            system.debug('## WSresponse: KEM2  ' +WSresponse);

            list <PurchaseOrder__c> lstPOToUpdate = new list <PurchaseOrder__c>();
            //RLA 11/01/2019 Case: C-003007: Duplicate order for Coler (bis)
            Boolean techColerSent = false;
            //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
            Boolean autoValidate = false;

            if(wsResponse != '' && wsResponse != null){
                if(!wsResponse.contains('Exceptions')){
                    system.debug('## Exceptions: KEM2  ' +WSresponse);
                    //error reported during call out
                    //update each connected PO with error message
                    if(wsResponse.contains(' statusCode = ')){
                        system.debug('## statusCode =' +WSresponse);
                        String statusCode = wsResponse.substringAfter(' statusCode = ');
                        system.debug('## statusCode:'+statusCode);
                        if(statusCode == '200'){
                            //Object responseObj = (Object) JSON.deserializeUntyped(WSresponse);
                            Map<String, Object> responseObjMap = (Map<String, Object>) JSON.deserializeUntyped(WSresponse);
                            system.debug('## responseObjMap:'+responseObjMap);
                            //system.debug('## reqlst[1]:'+reqlst[1]);
                            
                            message = responseObjMap.containsKey('Message') ? (String.ValueOf(responseObjMap.get('Message')) != null ?  String.ValueOf(responseObjMap.get('Message')) : null ): null; 
                            map <string,RestDistributorUtility.dist> deserialiseDist = RestDistributorUtility.deserialiseRespIntoDistributors(wsResponse);  
                            RestDistributorUtility.dist distIns;
                            //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                            system.debug('## deserialiseDist:'+deserialiseDist);
                            if (deserialiseDist != null){
                                for(String distributor : deserialiseDist.keyset()){ 
                                    distIns  = deserialiseDist.get(distributor);
                                    purchaseOrderReference = distIns.PurchaseOrderReference;
                                    system.debug('## purchaseOrderReference:'+purchaseOrderReference);
                                }
                            }
                           

                            if(message == null){  
                                if(distIns != null && distIns.Success == 'true'){  
                                    // ASE: 10/07/2018: C-002659 : Prices & Part Type to be sent to Coler   
                                    DistributorOrderReference = distIns.DistributorOrderReference; 
                                                                                      
                                    errorReported = 'Order successfully sent';
                                    statusPO = (reqlst[1] == 'PO-') ? ASPISConstants.PUR_ORDER_STATUS_RESPONDED : 'DRAFTQUOTE'; 
                                    if (reqlst.size() > 0
                                        && reqlst[1] == 'PO-'){
                                        //RLA 11/01/2019 Case: C-003007: Duplicate order for Coler (bis)
                                        techColerSent = true;
                                    }
                                    //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                                    if( statusPO == 'DRAFTQUOTE'
                                        && doAutovalidate
                                        )
                                    {
                                        statusPO = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
                                        autoValidate = true;
                                    }
                                } 
                                else{
                                        // system.debug('@@ distIns: '+distIns);
                                        // system.debug('@@ distIns.Message: '+distIns.Message);
                                    //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                                    errorReported = 'Order error reported : ' + (distIns != null ? distIns.Message : '');
                                }                          
                            }
                            else{
                                errorReported = 'Order error reported : ' + message;
                            }
                        }
                        else{
                            errorReported = 'Order error reported : ' + wsResponse;
                        }
                    }
                    else{
                        errorReported = 'Order error reported : ' + wsResponse;
                    }
                }
                else{
                    errorReported = wsResponse; 
                }

                if(!setPOToUpdate.isEmpty()){
                    for(id poid : setPOToUpdate){
                        lstPOToUpdate.add(new PurchaseOrder__c(Id = poid,
                                                                wsDate__c = system.now(),
                                                                wsErrorMessage__c = errorReported,
                                                                Status__c = statusPO,
                                                                DistributorPOReference__c = DistributorOrderReference,
                                                                AutoValidate_PO__c = autoValidate,
                                                                DistributorOrderReference__c = purchaseOrderReference,
                                                                techColerCalled__c = techColerSent));//RLA 11/01/2019 Case: C-003007: Duplicate order for Coler (bis)
                    }
                }//end if !setPOToUpdate.isEmpty()
                system.debug('## sentOlIdSet:'+sentOlIdSet);
                system.debug('## lstPOToUpdate:'+lstPOToUpdate);
                list<OrderLine__c> sentOlIdLines = new list<OrderLine__c>();

                if(sentOlIdSet != null && sentOlIdSet.size() > 0){    
                                  
                    for(Id olId : sentOlIdSet){
                        sentOlIdLines.add(new OrderLine__c(Id = olId,  Suppliable__c = null));
                    } 
                }
                system.debug('## lstPOToUpdate33:'+lstPOToUpdate);
                if(!lstPOToUpdate.isEmpty() && lstPOToUpdate != null){   
                    system.debug('## lstPOToUpdate22:'+lstPOToUpdate);
                    update lstPOToUpdate;
                }    
                
                if(!sentOlIdLines.isEmpty()){
                    system.debug('## sentOlIdLines:'+sentOlIdLines);
                    update sentOlIdLines;
                }              
            }      
                
            //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
            //                insert log
            //RLA 14/06/2018 Case 2177
            generateLog(reqlst[0], WSresponse, 'Order', errorReported, 'OrderMakeSelection');
            //system.debug('## newLog ' + newLog);
            //if(newLog != null){
            //    insert newLog;
            //}
            system.debug('## End callDistributor');
        }
    }

    //new wrapper class in order to send BodyShopOrderReference during ordering process in distributor object
    public class mainRequest{
        public string ClaimReference;
        public boolean AutomaticValidation;
        public string Request;
        public string AlphaScalePO;
        public Object Distributors;
        public RestDistributorUtility.BodyShop BodyShop;
        public RestDistributorUtility.Vehicle Vehicle;

        public mainRequest(string ClaimReference, boolean AutomaticValidation, string Request, string AlphaScalePO, Object Distributors, RestDistributorUtility.BodyShop BodyShop, RestDistributorUtility.Vehicle Vehicle){
            this.ClaimReference = ClaimReference;
            this.AutomaticValidation = AutomaticValidation;
            this.Request = Request;
            this.AlphaScalePO = AlphaScalePO;
            this.Distributors = Distributors;
            this.BodyShop = BodyShop;
            this.Vehicle = Vehicle;
        }
    }

    public class distributor{
        public string ExternalOrderReference;
        public string BodyShopOrderReference;
        public string Comment ;
        public Boolean Option1; //RLA 11/06/2020 C-003754: IG - Update Query Call for Coler
        public list <RestDistributorUtility.Parts> Parts;
        public list <RestDistributorUtility.PartsConnectedE> PartsE;
        public string BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements


        public distributor(string ExternalOrderReference,string BodyShopOrderReference,string Comment,Boolean Option1, list <RestDistributorUtility.Parts> Parts, string BSExternalReference){
            this.ExternalOrderReference = ExternalOrderReference;
            this.BodyShopOrderReference = BodyShopOrderReference;
            this.Comment = Comment;
            this.Option1 = Option1;
            this.Parts = Parts;
            this.BSExternalReference  = BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements
            system.debug('SHANE11');
        } 
        //kem
        public distributor(string ExternalOrderReference,string BodyShopOrderReference,string Comment,Boolean Option1, list <RestDistributorUtility.PartsConnectedE> PartsE, string BSExternalReference){
            this.ExternalOrderReference = ExternalOrderReference;
            this.BodyShopOrderReference = BodyShopOrderReference;
            this.Comment = Comment;
            this.Option1 = Option1;
            this.PartsE = PartsE;
            this.BSExternalReference  = BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements
            system.debug('SHANE22');
        } 
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

     global static String callConnectedDistributor(String endpoint, String wsRequest){
        system.debug('## start callConnectedDistributor');
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new http();
        String wsResponse = null;

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(integer.valueOf(system.label.EIPTimeout));
        request.setHeader('Content-Type','application/json; charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        request.setbody(wsRequest);
        system.debug('## wsRequest ' + wsRequest);

        try{
            response = http.send(request);
            system.debug('## response ' + response);
            if(response != null){
                String statusCode = String.valueOf(response.getStatusCode());
                system.debug('## statusCode ' + statusCode);
                if(statusCode == '200'){
                    
                    wsResponse = response.getBody() + ' statusCode = '+statusCode;
                    //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                    if (system.label.responseCalloutValidate != 'none' && system.label.responseCalloutValidate.StartsWith('a0D')){
                        Log__c logResponse = [Select id,WSResponse__c from Log__c Where Id = :system.label.responseCalloutValidate];
                        wsResponse = logResponse.WSResponse__c + ' statusCode = '+statusCode;
                        // isSimulation = true;
                    }
          
                }
                else{
                    wsResponse ='Error: ' + response.toString() + ' statusCode = '+statusCode;  
                }                              
            } 
        }
        catch(Exception e){
            wsResponse = (e.getMessage().length() < 1000) ? e.getMessage() : system.label.DistributorWSNoInfo;    
            wsResponse = 'Exceptions: ' + wsResponse;                    
        } 

        system.debug('## wsResponse: '+wsResponse); 
        return wsResponse;
     }

    public static void generateLog(String finalOrderReq, String WSResponse, String callType, String errorReported, string className){
        system.debug('## start generateLog');
        system.debug('## errorReported: '+errorReported);

        //Log__c newLog = new Log__c(DateLog__c  = System.now()                                                                                                                 
        //                           ,SystemCalling__c = callType
        //                           ,Class__c = ClassName
        //                           ,JSONMessage__c = finalOrderReq
        //                           );

        //if(wsResponse.contains(' statusCode = ')){
        //    newLog.JSONResponse__c = wsResponse.substringBefore(' statusCode = ');
        //}
        //else{
        //    newLog.JSONResponse__c = wsResponse;
        //}

        //if(callType == 'Order'){
        //    if(errorReported.contains('Order successfully sent')){
        //        newLog.Status__c = 'Passed';
        //    }
        //    else{
        //        newLog.Status__c = 'Failed';
        //    }
        //}
        //else{
        //    if(WSResponse.contains('Exceptions') || WSResponse.contains(system.label.DistributorWSNoInfo) || (errorReported != null && errorReported != '')){
        //        newLog.Status__c = 'Failed';
        //    }
        //    else{
        //        newLog.Status__c = 'Passed';
        //    }
        //}

        //system.debug('## end generateLog');

        //return newLog;

        //RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
        APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
        wrapperLog.className = className;
        //wrapperLog.objectreference = assessmentName;
        wrapperLog.jsonmessage = finalOrderReq;

        if (callType == 'Order'){
            wrapperLog.sobjectName = 'Assessment__c';            
        }
        else if (callType == 'Draft'){
            wrapperLog.sobjectName = 'Purchaseorder__c';            
        }
        wrapperLog.inout = 'Outbound';
        wrapperLog.calltype = callType;
              
        

        if(wsResponse.contains(' statusCode = ')){
            wrapperLog.jsonresponse = wsResponse.substringBefore(' statusCode = ');
        }
        else{
            wrapperLog.jsonresponse = wsResponse;
        }

        if(callType == 'Order'){
            if(errorReported.contains('Order successfully sent')){
                wrapperLog.status = 'Passed';
            }
            else{
                wrapperLog.status = 'Failed';
            }
        }
        else{
            if(WSResponse.contains('Exceptions') || WSResponse.contains(system.label.DistributorWSNoInfo) || (errorReported != null && errorReported != '')){
                wrapperLog.status = 'Failed';
            }
            else{
                wrapperLog.status = 'Passed';
            }
        }
        wrapperLog.objectreference = objReference;


        system.debug('## end generateLog');

        //Log__c log = APManageLogs.createWsLog(wrapperLog, 'insert');
        //RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
        APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');
    }

    public static map<String, OrderLine__c> addAdditionalParts(map <string,list <orderingPartWrapper>> mapDistNamePartList){
        system.debug('## start addAdditionalParts');
        list <PartList__c> addPartList = new list <PartList__c>();
        list <OrderLine__c> additionalPartOrderList = new list <OrderLine__c>();
        list <Offer__c> additionalPartOfferList = new list <Offer__c>();
        Map <String,String> mapTypeDelay = new Map <String,String>();              
        map<String, Id> assessPLIdMap = new map<String, Id>();
        map<String, OrderLine__c> distOLMap = new map<String, OrderLine__c>();
        set<String> setDistNameLineDiscount =  new Set<String>((system.label.AdditionalPartDistributor).split(';'));

        for(String key : mapDistNamePartList.keyset()){
            orderingPartWrapper opw = mapDistNamePartList.get(key)[0];            

            if( setDistNameLineDiscount.contains(key)){
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
            if(setDistNameLineDiscount.contains(key)){
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

    public static String makeDraftCall(String wsRequest, map <string,Account> mapDistributorNameDistributor, Id assRecordId, map <string,PurchaseOrder__c> mapPOExtIDPO, map <Id, PartList__c> partMap, Boolean isDraft, String orderRequest, String className,String fromUpdateStockInfo){
        system.debug('##------------------ start makeDraftCall--------------------------------');
        system.debug('## start mapPOExtIDPO'+mapPOExtIDPO);

        HttpResponse response = new HttpResponse();
        Http http = new http();
        HttpRequest request = new HttpRequest();
        String message = '';
        Boolean isDraft2 = (orderRequest == 'OrderPO') ? true : false;
        system.debug('## isDraft:'+isDraft);
        system.debug('## isDraft2:'+isDraft2);
        list <PurchaseOrder__c> erroredPO = new list <PurchaseOrder__c>();

        //WCH 18/08/2020 C-003864
        Map<String, Object> requestEIPEndpoint = new Map<String, Object>{'EIP_EndPoint' => 'authenticate'};
        Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(requestEIPEndpoint);

        String wsResponse = callConnectedDistributor((String)responseEIPEndpoint.get('EIP_EndPoint'), wsRequest);//WCH 18/08/2020 
        
        String draftWsResponse = '';

        //String wsResponse3 = (orderRequest == 'OrderPO') ? wsResponse2 : wsResponse;      

        system.debug('## wsResponse stock:'+wsResponse);
        
        if(wsResponse != '' && wsResponse != null){
            if(!wsResponse.contains('Exceptions')){
                //error reported during call out
                //update each connected PO with error message
                if(wsResponse.contains(' statusCode = ')){
                    String statusCode = wsResponse.substringAfter(' statusCode = ');
                    system.debug('## statusCode: '+statusCode);
                    if(statusCode == '200'){
                        map<Id, Id> mapDistPOID = new map<Id,Id>();
                        for (PurchaseOrder__c PO: mapPOExtIDPO.values() ){
                            mapDistPOID.put(PO.Distributor__c, PO.Id);
                        }
                        //Object responseObj = (Object) JSON.deserializeUntyped(WSresponse);
                        Map<String, Object> responseObjMap = (Map<String, Object>) JSON.deserializeUntyped(WSresponse);
                        system.debug('## responseObjMap: '+responseObjMap);
                        system.debug('## mapDistPOID: '+mapDistPOID);

                        map <string,RestDistributorUtility.dist> deserialiseDist;
                        if(string.isNotBlank(WSresponse)){
                            deserialiseDist  = RestDistributorUtility.deserialiseRespIntoDistributors(WSresponse);  
                        }
                        system.debug('## deserialiseDist: '+deserialiseDist);

                        Boolean isSuccessfulPRocess = false;
                        if (deserialiseDist != null){
                            for(String distributor : deserialiseDist.keyset()){ 
                                system.debug('## distributor: '+distributor);


                                RestDistributorUtility.dist distIns  = deserialiseDist.get(distributor);

                                system.debug('## distIns: '+distIns);

                                if(distIns.Success == 'true' && !isSuccessfulPRocess){
                                    //process response 
                                    draftWsResponse = processResponse(wsResponse,
                                                                mapDistributorNameDistributor,
                                                                assRecordId,
                                                                mapPOExtIDPO,
                                                                partMap,
                                                                false,
                                                                fromUpdateStockInfo);
                                    isSuccessfulPRocess = true;
                                    system.debug('## isSuccessfulPRocess: '+isSuccessfulPRocess);
                                    system.debug('## draftWsResponse: '+draftWsResponse);


                                }
                                else{
                                    system.debug('## msg not null: '+distIns.Message);
                                    if (mapDistributorNameDistributor.containskey(distributor)){
                                        Id idDist = mapDistributorNameDistributor.get(distributor).Id;
                                        system.debug('## idDist: '+idDist);

                                        if (mapDistPOID.containskey(idDist)){
                                            system.debug('## mapDistPOID.get(idDist): '+mapDistPOID.get(idDist));

                                            updateErroredPO(erroredPO,mapDistPOID.get(idDist) , distIns.Message);
                                        }
                                        
                                    }
                                    
                                    
                                }


                            }

                        }


                        //WCH 07/01/2019 C-003528 
                        //message = responseObjMap.containsKey('Message') ? (String.ValueOf(responseObjMap.get('Message')) != null ?  String.ValueOf(responseObjMap.get('Message')) : null ): null; 
                        // message = wsResponse.substringBetween('"Message" : "','"');

                        // if(message == '' || message == null){ 
                        //     //process response 
                        //     draftWsResponse = processResponse(wsResponse,
                        //                                  mapDistributorNameDistributor,
                        //                                  assRecordId,
                        //                                  mapPOExtIDPO,
                        //                                  partMap,
                        //                                  false,
                        //                                  fromUpdateStockInfo);
                        //     system.debug('## draftWsResponse: '+draftWsResponse);
                        // }
                        // else{
                        //     system.debug('## msg not null: '+statusCode);
                        //     updateErroredPO(erroredPO, mapPOExtIDPO, message);
                        // }
                    }
                    else{
                        //error reported during call out
                        //update each connected PO with error message
                        system.debug('## Error status code:'+draftWsResponse);
                        updateErroredPO(erroredPO, mapPOExtIDPO, string.isNotBlank(wsResponse) ? ((wsResponse.length() < 1000) ? wsResponse: system.label.DistributorWSNoInfo) : system.label.DistributorWSNoInfo);                         
                        wsResponse = string.isNotBlank(wsResponse) ? ((wsResponse.length() < 1000) ? wsResponse.substringBefore(' statusCode = ') : system.label.DistributorWSNoInfo) : system.label.DistributorWSNoInfo;
                        draftWsResponse = wsResponse;
                    }
                }
            }
            else{
                system.debug('## System.CalloutException ' + wsResponse);
                draftWsResponse = wsResponse;
                updateErroredPO(erroredPO, mapPOExtIDPO, (wsResponse.length() < 1000) ? wsResponse : system.label.DistributorWSNoInfo);     
            }
        }
        system.debug('## erroredPO ' + erroredPO);
        if(!erroredPO.isEmpty()){
            update erroredPO;
        }

        for (String s: mapPOExtIDPO.keyset()){
            objReference += mapPOExtIDPO.get(s).Name;
        }

        //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
        // Initialise Log Object
        //RLA 14/06/2018 Case 2177
        generateLog(wsRequest, WSresponse, 'Draft', message,className);
        //Log__c newLog = generateLog(wsRequest, WSresponse, 'Draft', message, className);
        //system.debug('## newLog ' + newLog);
        //if(newLog != null){
        //    insert newLog;
        //}
        system.debug('## end makeDraftCall');
        if(isDraft){
            return draftWsResponse;
        }
        else{
            return wsResponse;
        }
    }
    /* WCH 01/04/2020 C-003677 */
    public void getTargetedSO(){
        hasErrors = false;
    }
    public PageReference cancelCurrentSO(){

        PageReference redirectToAfterCancelSO = new PageReference('/apex/OrderChooseAssessment?AssessmentId=' + (((encryptedSourceAssessmentId != null) && (encryptedAssessmentId != encryptedSourceAssessmentId)) ? encryptedSourceAssessmentId : encryptedAssessmentId));
        if(shadowSO!=null && shadowSO.cancelationReason__c != '' && shadowSO.cancelationReason__c != null){
            shadowSO.Comment__c = shadowSO.cancelationReason__c;
            shadowSO.Status__c = 'CANCELED';
        }else{ 
            hasErrors = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, system.label.CancellationReasonIsRequired));
            return null;
        }
        try{
            update shadowSO;  
            return redirectToAfterCancelSO;
        }catch (Exception e){
            hasErrors = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,  e.getMessage() + ' : ' + e.getStackTraceString()));
        }
        return null;
    }
    //RRJ 12/10/2022
    public static list<String> picklist_values(Id BS) {
        system.debug('###### picklist value start');
        list<String> values = new list<String>();
		list<MultiaddressRepairCenter__mdt> RP_mdt = new list<MultiaddressRepairCenter__mdt>();
        //RRJ 14/10/2022
        String MulAdressQuerry = 'SELECT Active__c, BS__c, isTest__c, RepairCenterCode__c FROM MultiaddressRepairCenter__mdt WHERE Active__c=true AND BS__c=:BS' + (Test.isRunningTest()?' and isTest__c=true AND BS__c=:"XXX"':' and isTest__c=false');
		//RP_mdt = [SELECT Active__c, BS__c, isTest__c, RepairCenterCode__c FROM MultiaddressRepairCenter__mdt WHERE Active__c=true AND isTest__c=false AND BS__c=:BS];
        for(MultiaddressRepairCenter__mdt mt : Database.Query(MulAdressQuerry)){
           values.add(mt.RepairCenterCode__c);
        }
			
        system.debug('###### picklist value stop');
        return values;
    }

    //RBE 06/01/2023
    //Wrapper class to store an Occurence, its images and main image, and its additional information
    public class OccurenceWrapper {
        public Occurence__c occ { get; set; }
        public List<String> lstImages {get;set;}
        public String mainImage {get; set;}
        public Map<String,String> mapAdditionalInfo {get;set;} //Stores additional information in the form of: label = value
        public List<String> lstInfoKeys {get;set;}  //Used to access the map in the same order as inserted, because VF sorts the keys when iterating over a collection
        public Boolean isSelected {get;set;}
    
        public OccurenceWrapper(Occurence__c occ) {
            this.occ = occ;
            this.isSelected = false;
            builImageList();
        }

        public void builImageList(){
            if(String.isNotBlank(occ.PhotoURL__c)){
                this.lstImages = occ.PhotoURL__c.split(';');

                if(lstImages.size() > 0){
                    //Remove the first image from list to display it only in list and not detail modal  
                    this.mainImage = lstImages.remove(0);
                }
            }else{
                this.mainImage = 'No image';
            }
        }

        public void buildMapAdditionalInfo(){
            String info = occ.AdditionalInformation__c;
            if(String.isNotBlank(info)){
                mapAdditionalInfo       = new Map<String,String>();
                lstInfoKeys             = new List<String>();
                List<String> lstInfo    = info.split('[|]');            
                for(String s : lstInfo){
                    List<String> pair = s.split('_');
                    mapAdditionalInfo.put(pair[0],pair[1]);
                    lstInfoKeys.add(pair[0]);
                }
            } 
            system.debug(mapAdditionalInfo);
        }  
    }
    
    //RBE 02/02/2023 C-004898: PREv2 Connected - Lot 3.4 - Order - Stock Call For Occurence
    public List<Occurence__c> ConnectedEDraftCall(Map<String,Occurence__c> mapAllOcc){        
        system.debug('## Start ConnectedEDraftCall');
        String wsRequest                    = '';
        String wsResponse                   = '';        
        String fakeLog                      = System.label.Response_DraftCallOccurences;
        Assessment__c assRecord             = mapPartWrapper.get(occPartId).mapDistributorWrapper.get(occDistId).mapOfferWrapper.get(occOfferId).parentOffer.PrerequisiteOrder__r.Assessment__r;
        Partlist__c    prt                  = mapPartWrapper.get(occPartId).currentPart;
              

        if (assRecord != null && assRecord.BodyShop__r.DistributorConnected__c)
            wsRequest = RestDistributorUtility.buildConnectedEDistributorRequest(assRecord, mapAllOcc.values()); //Construct JSON request to send to distributors
        else
            return null;
       
        
        if (fakeLog != 'none' && fakeLog.StartsWith('a0D')){    //Use response from fake log
            Log__c logResponse;
            try{
                logResponse = [SELECT id,JSONResponse__c FROM Log__c WHERE Id = :fakeLog LIMIT 1];
                if (logResponse != null && logResponse.JSONResponse__c != null)
                wsResponse = logResponse.JSONResponse__c;
            }catch(QueryException e){
                System.debug( e.getMessage());
                return null;
            }
        }        
        else{ //Make real webservice call
            Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(new Map<String, Object> {'EIP_EndPoint' => 'authenticate'} );
            wsResponse                              = callConnectedDistributor((String)responseEIPEndpoint.get('EIP_EndPoint'), wsRequest);
        }
            
        //wsRequest = wsRequest.replaceAll('lines','parts');
        system.debug('## E wsRequest ' + wsRequest);
        system.debug('## E wsResponse ' + wsResponse);
        //Create log containing request and response 
        if(preConfig.CreateLog__c)    
            generateLog(wsRequest, WSresponse, 'Draft', '', 'OrderMakeSelection E connected');

        if(wsResponse.contains('Exceptions') || wsResponse.contains('Error')){ //Request could not be sent or Response contains errors
            // system.debug('could not call distributors');
            occErrorMessage = 'Impossible de contacter les distributeurs';
            return null;
        }
        else{ // Webservice call was successful
            Map <String,RestDistributorUtility.dist> deserialiseDist = new  Map <String,RestDistributorUtility.dist>();   
            try{
                deserialiseDist = RestDistributorUtility.deserialiseRespIntoDistributors(wsResponse);
            }
            catch(Exception e){
                occErrorMessage = e.getMessage();
            }
            
            List<Occurence__c> lstAvailableOcc   = new List<Occurence__c>();
            // Loop over all distributors and store confirmed occurences
            for(String dist : deserialiseDist.keyset()){
                if(deserialiseDist.get(dist).Success == 'true'){
                    for(RestDistributorUtility.Lines line : deserialiseDist.get(dist).Lines){ //Loop over occurences of a distributor
                        if(mapAllOcc.containsKey(line.ID)){
                            if(line.Status == 'CONFIRMED')
                                lstAvailableOcc.add(mapAllOcc.get(line.ID)); //Line.Id == Occurence__c.Name
                        }
                    }
                }
            }
            noOccurences = lstAvailableOcc.size();
            system.debug('##lstAvailable occ:'+lstAvailableOcc);
            if(lstAvailableOcc.isEmpty())
                return null;
            
                system.debug('## End ConnectedEDraftCall');
            return lstAvailableOcc;
        }       
        return null;
    }
    
    //RBE 06/01/2023
    //Fetches a number of occurences related to an xref and makes a stock call to distributors to check if they are available
    public void getOccurences(){       
       Map<String, Occurence__c> mapAllOcc  = new Map<String, Occurence__c>();  
       Integer occMax                       = (Integer) preConfig.OccurenceMaxLimit__c;
       //Get the price of the original part
       Decimal priceA                       = mapPartWrapper.get(occPartId).mapDistributorWrapper.get(occDistId).mapOfferWrapper.get(occOfferId).parentOffer.Orderline__r.PartList__r.OriginalPart__r.OriginalPart__r.price__c;
    //    system.debug('##Heap size before query: ' + Limits.getHeapSize() + '/' + limits.getLimitHeapSize());
       for(Occurence__c occ : [SELECT Name, Color__c, Distributor__c, Distributor__r.Tech_Distributor__c, Distributor__r.Name , Quality__c, ASSellingNetPrice__c,
                                      AdditionalMargin__c, Brand__c, Delay__c, CutOff__c, PhotoURL__c,AdditionalInformation__c,DistributorReference__c 
                               FROM Occurence__c 
                               WHERE CrossReference__c =: xrefId AND Status__c = 'Active' 
                               AND  Distributor__r.Type_of_Substitutes__c INCLUDES ('XREF Connected')
                               AND ASSellingNetPrice__c < :priceA // Get only occurences cheaper than the original part
                               Limit :occMax]){
           mapAllOcc.put(occ.Name, occ);
        }      
        // system.debug('##Heap size after query: ' + Limits.getHeapSize() + '/' + limits.getLimitHeapSize());

       lstAllAvailableOcc = ConnectedEDraftCall(mapAllOcc);       
       if(lstAllAvailableOcc != null){
          occOffset = 0;
          populateMapOcc(occOffset, occLimit);
       }else{
        mapOcc = new Map<Id, OccurenceWrapper>();
       }            
    //    system.debug('##Heap size after Stock call: '+Limits.getHeapSize()+'/'+limits.getLimitHeapSize());
    }

    //Stores occurences within the range startOcc-endOcc in the map mapOcc
    public void populateMapOcc(Integer startOcc, Integer endOcc){
        mapOcc = new Map<Id, OccurenceWrapper>();   
        if (endOcc > lstAllAvailableOcc.size()) endOcc = lstAllAvailableOcc.size();
        if (endOcc < startOcc) endOcc = startOcc + 1;

        for(Integer i = startOcc; i < endOcc; i++){
            Occurence__c occ = lstAllAvailableOcc.get(i);
            mapOcc.put(occ.Id, new OccurenceWrapper(lstAllAvailableOcc.get(i)));
        }
        // System.debug('occurences found: '+mapOcc);
    }

    public Boolean getMapOccEmpty(){
        return mapOcc == null || mapOcc.isEmpty();
    }
    
    //Assigns the occurence to display in the additional details modal
    public void setDetailOcc(){
        // system.debug('occ Id: '+detailOccId);

        detailOcc = mapOcc.get(detailOccId); 
        detailOcc.buildMapAdditionalInfo();

        // system.debug('detail occ: '+ detailOcc);
    } 
    
    public void selectOcc(){
        // for(OccurenceWrapper occWrap : mapOcc.values()){
        //     occWrap.isSelected = false;
        // }
        // mapOcc.get(selectedOccId).isSelected = true;

        Offer__c offer      = mapPartWrapper.get(occPartId).mapDistributorWrapper.get(occDistId).mapOfferWrapper.get(occOfferId).parentOffer;
        Occurence__c occ    = mapOcc.get(selectedOccId).occ;

        // system.debug('####Offer: ' + offer);
        // system.debug('####orderline: ' + offer.orderLine__r);
        // system.debug('####salesorder: ' + offer.PrerequisiteOrder__r);
        // system.debug('###offer distId'+ occDistId);
        // system.debug('###occ distId'+ occ.Distributor__c);

        PartList__c part = changePartListPrice(offer.Orderline__r.PartList__r, occ);
        update part;

        if(occOperation == 'create')
           createOrderlineAndOffer(offer, occ);
        else if(occOperation == 'change'){
           changeOrderline(offer, occ);
        }
        // Re query offers
        PageReference pr = queryRecords();
    }

   
    public void createOrderlineAndOffer(Offer__c offer, Occurence__c occ){
        PurchaseOrder__c    newPO;
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
        // system.debug('OL: '+ newOl);

        newOff = cloneOccOffer(offer, newOl);
        // system.debug('Offer: '+ newOff);

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
        ol.ASBodyshopNetPrice__c         = occ.ASSellingNetPrice__c;
        ol.Description__c                = ol.PartList__r.Description__c;
        ol.ExpectedDeliveryDuration__c   = String.valueOf(occ.Delay__c / 24);
        ol.CataloguePrice__c             = ol.PartList__r.Price__c; //RBE 17/02/2023
    }

    public PartList__c changePartListPrice(PartList__c prt, Occurence__c occ){
        Decimal priceA              = prt.OriginalPart__r.OriginalPart__r.price__c;
        Decimal PREPrice            = occ.ASSellingNetPrice__c + priceA * prt.CrossReferenceId__r.OEMStandardDiscount__c / 100 + occ.AdditionalMargin__c;
        prt.price__c                = PREPrice;
        prt.StandardMargin__c       = PREPrice - occ.ASSellingNetPrice__c;
        prt.StandardDiscount__c     = (1 - (occ.ASSellingNetPrice__c / PREPrice)) * 100;
        prt.UnitGain__c             = priceA - PREPrice;
        prt.ASNetPrice__c           = occ.ASSellingNetPrice__c;
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
        //kem to be removed         
        newOl.SASStatus__c                  = 'CONFIRMED';        
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
        //system.debug('##Heap size before next: '+Limits.getHeapSize()+'/'+limits.getLimitHeapSize());
        occOffset+=occLimit;
        populateMapOcc(occOffset, occOffset+occLimit);
        //system.debug('##Heap size after next: '+Limits.getHeapSize()+'/'+limits.getLimitHeapSize());
    }

    public void prevOcc(){
        occOffset-=occLimit;
        populateMapOcc(occOffset, occOffset+occLimit);
    }

    public void lastOcc(){
        occOffset = noOccurences - math.mod(noOccurences, occLimit);
        populateMapOcc(occOffset, occOffset+occLimit);

    }

    public void firstOcc(){
        occOffset = (Integer) preConfig.OccurencePaginationOffset__c;
        populateMapOcc(occOffset, occOffset+occLimit);
    }
    //End of pagination functions   
}