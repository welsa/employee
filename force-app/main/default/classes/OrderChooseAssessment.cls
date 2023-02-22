/*************************************************************************************
Class Name - VFC11_OrderChooseAssessment
Version - 1.0
Created Date - 11 November 2016
Function - Controller extension for page OrderChooseAssessment

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       14/12/2016  Original Version (case 1821 : ASPIS 2.0 : Order Process - OrderChooseAssessment)
* Abdool M     04/09/2017  Distributor Integration
* Ashwina S    08/11/2017  C-002072 -  SAS UAT 03/11/2017
* Ashwina S    19/01/2018  C-002152 - Add part created even if all the parts are refused
* Dourga       29/01/2018  C-002174 - Avoid running again Eligibility and sourcing  
* Abdool M     16/02/2018  C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c to query so that latter can be cloned    
* Dourga U     23/02/2018  C-002186 - Bypass the orderchooseAssessment screen         
* Dourga       16/03/2018  C-002391 : Impossible to order in Belgium    
* Vaynee       30/04/2018  C-002315 : Cross Scripting 
* Ashwina S    07/05/2018  C-002528 - ASP for Coler Distributor 
* Ashwina S    28/05/2018  C-002041 changes in calculations 
* Dourga       08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
* Ruksaar L    23/08/2018  C-002690 Spain audatex assessments in r4     
* Ashwina S    17/12/2018  C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
* Welsa C      18/12/2018  C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
* Welsa C      08/02/2019  C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops > custom setting
* Ruksaar L    27/11/2018  C-002782   CJP A'
* Ruksaar L    20/11/2018  C-002879  : UAT Erreur commande BS sur chiffrage Expert
* Abdool M     14/12/2018  C-002781 : Migrate Spain to R4
--                                  : Display Chatter Feed 
* Abdool M     29/01/2019  C-002781 : Getting Connected User Country Code to Remove SEPA validation for ES
* Ruksaar L    04/07/2019  C-003171: Flag Orders generated from Assessment Tool
* Welsa C      06/12/2019  C-003512: Prevent Bodyshop to order
* Welsa C      02/04/2020  C-003685: When Quoting if assessment has list of ongoing quotes orderchooseassessment not rendered correctly
* Welsa C      26/11/2020  C-003980: NOB - Compensated Invoices
* Welsa C      09/11/2020  C-004311 - NOB -New Compensated process should not be activated for Claims in old compensation process
* Welsa C      22/09/2021  C-004066 : Pentest : Improper Error Handling with code disclosure
* Hootesh R    13/10/2021  C-004405 : No Ordering on Fake References
* Hootesh R    18/10/2021  C-004215 - Plafond de Commande
* Welsa C      19/11/2021  C-004511 : Force direct debit payment (SEPA) if there is no compensation
**************************************************************************************/
public without sharing class OrderChooseAssessment{

    //String BodyShop Type
    public String bsType{get;set;}
    //String encripted assessment id
    public String encryptedText {get; set;}
    //Map<BodyShop Type,assessment>
    public Map<String, Assessment__c> mapBSTypeAssessment{get;set;}
    //Boolean whether there are ongoing sales orders
    public boolean hasOngoingAssessment{get;set;}
    //Boolean whether there are any assessment
    public boolean hasAssessment{get;set;}
    //public List<Assessment__c> listOngoingAssessments{get;set;}
    public List<OnGoingAssessment> onGoingAssessmentList {get; set;}
    //Boolean whether there are errors
    public Boolean hasErrors {get; set;}
    //Boolean whether there are errors to be displayed in a toast
    public Boolean isToastError {get; set;}
    //The bodyshop account related to the user connected
    public Account bodyShopConnected{get;set;}
    //Boolean whether select to order button should be available
    public Boolean isEligibleOrder {get; set;}
    //Boolean whether quote button should be available
    public Boolean isEligibleQuotation {get; set;}
    //Group of user connected
    public Group userConnectedGroup;

    public MainAssessment receivedAssessmentWrapper {get; set;}
    public Map<String, AssessmentWrapper> mapTypeAssessment {get; set;}
    public Boolean redirectionInErrorModal {get; set;}

    //DUN 23/02/2018  C-002186 - Bypass the orderchooseAssessment screen
    public Boolean automaticSelecToOrder {get;set;}

    /*********************************/
    //AMI 26/06/18 : Community Rollout 
    //             : string to hold license name if user is a community user
    //             : check will be done later on this string together with connectedUserLicenseName to ensure no apex sharing is created if user 
    //             : has a community license
    string licenseName = '';
    string formattedLicenseName = '';

    //             : this string will be used to hold connected user license name
    string connectedUserLicenseName = '';

    //             : this string will be used to hold connected user id
    string connectedUsrId = '';

    //AMI 14/12/18  C-002781 : Migrate Spain to R4
    //                       : Display Chatter Feed
    //                       : boolean to determine whether to display chatter feed
    public boolean showFeed {get;set;}

    //AMI 29/01/19  C-002781 : Getting Connected User Country Code to Remove SEPA validation for ES
    public boolean isES {get;set;}

    //RLA 04/07/2019 C-003171: Flag Orders generated from Assessment Tool
    String flag;
    String decryptedAssessmentId;

 //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
    private Boolean isNonAxa = false;
public boolean bsIsCompensated {get;set;}
    public Boolean renderEparts {get;set;}//RLA C-004115: FR - E parts orderin
    public Boolean onlyEparts {get;set;}//RLA C-004115: FR - E parts orderin
    public Boolean buttonEParts {get;set;}//RLA C-004115: FR - E parts orderin

    public OrderChooseAssessment() 
    {
        hasErrors = false;
        isToastError = false;
        redirectionInErrorModal = false;

        isEligibleOrder = false;
        isEligibleQuotation = false;
        hasOngoingAssessment = false;
        //DUN 23/02/2018  C-002186 - Bypass the orderchooseAssessment screen
        automaticSelecToOrder = false;
        onGoingAssessmentList = new List<OnGoingAssessment>();

        //AMI 14/12/18  C-002781 : Migrate Spain to R4
        //                       : Display Chatter Feed
        //                       : boolean to determine whether to display chatter feed
        showFeed = false;

        bsIsCompensated=false;//WCH 02/05/2021 C-004327

        renderEparts = false;//RLA C-004115: FR - E parts orderin
        onlyEparts = false;//RLA C-004115: FR - E parts orderin
        buttonEParts = false;//RLA C-004115: FR - E parts orderin
        try
        {
            if(ApexPages.currentPage().getParameters().get('flag') != null){
                 system.debug('@@@ : '+ApexPages.currentPage().getParameters().get('flag'));  
                 flag = ApexPages.currentPage().getParameters().get('flag').replaceAll('[^a-zA-Z0-9\\s+]', ''); //WCH 22/09/2021 C-004066
            }
            if(ApexPages.currentPage().getParameters().get('AssessmentId') != null){
                encryptedText = ApexPages.currentPage().getParameters().get('AssessmentId').replaceAll('[^a-zA-Z0-9\\s+]', '');//WCH 22/09/2021 C-004066
                decryptedAssessmentId = decryptBase64(encryptedText);

                Id anId = decryptedAssessmentId;//VSU 02/04/18 C-002315

                /*********************************/
                //AMI 26/06/18 : Community Rollout 
                //             : QUerying connected user license name
                /*for(User us : [Select id,Profile.UserLicense.Name 
                                from User 
                                where Id=: UserInfo.getUserId()]){
                    connectedUsrId = us.id;
                    connectedUserLicenseName = us.Profile.UserLicense.Name.toLowerCase();
                }*/

                connectedUsrId = UserInfo.getUserId();
                connectedUserLicenseName = UserInfo.getUserType().toLowerCase();
                
                licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
                formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';

                //AMI 26/06/18 : Querying claim assessment owner
                Assessment__c capturedAssessment = [SELECT  Id, VINNumber__c ,PlateNumber2__c, Manufacturer__c, BodyShop__r.Type, isShoppingList__c, TechDistAndDirectOrder__c,SelectedByBSPartTypes__c,bodyshop__r.Feature__c,ReasonFailure__c,status__c,
                                                            EntityRules__c, Bodyshop_is_Eligible_Non_AXA__c,AlreadyQuoted__c, TECH_EntityCountryCode__c, /*ASE: 08/05/2018 : C-002278*/Feature__c,OwnerId,BodyShop__r.Payment_Type__c,/*WCH 02/05/2021 C-004327*/Compensated__c,/*WCH 19/11/2021 C-004511*/
                                                            EntityCode__c,/*RLA: 14/10/2021 C-C-004494 */                                                            BodyShop__r.Name,AssessmentNumber__c /*HRM: C-04215*/,
                                                            ParentAssessment__c,/**RLA 18/11/2021 */
                                                            (SELECT Id
                                                            FROM PartsLists__r 
                                                            WHERE SelectedByBS__c = true 
                                                            AND isDeleted__c = false)
                                                    FROM    Assessment__c
                                                    WHERE   Id =: decryptedAssessmentId
                                                    AND     RecordType.DeveloperName = 'Claim'
                                                    FOR VIEW];
                //AMI 29/01/19  C-002781 : Getting Connected User Country Code to Remove SEPA validation for ES
                isES  = (capturedAssessment.TECH_EntityCountryCode__c == ASPISConstants.userCountryCodeES) ? true : false;
                isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => capturedAssessment.TECH_EntityCountryCode__c, 'entity' => capturedAssessment.EntityCode__c, 'fromProcess' => 'Order'});

                if (!isNonAxa && String.isnotblank(capturedAssessment.SelectedByBSPartTypes__c) && capturedAssessment.SelectedByBSPartTypes__c.contains(system.label.commandePieceE) && capturedAssessment.partslists__r.size() > 0 && String.isnotblank(capturedAssessment.bodyshop__r.Feature__c) && capturedAssessment.bodyshop__r.Feature__c.contains('Order Part E')){
                        renderEparts = true;
                        if (capturedAssessment.ReasonFailure__c != null && capturedAssessment.status__c == 'Rejected' && capturedAssessment.SelectedByBSPartTypes__c == (system.label.commandePieceE)){
                            onlyEparts = true;
                        }
                    }
                    system.debug('@@@ renderEparts:'+renderEparts);
                    system.debug('@@@ onlyEparts:'+onlyEparts);

                receivedAssessmentWrapper = new MainAssessment(capturedAssessment);

                String queryCondition = receivedAssessmentWrapper.getQueryConditions();

                if(queryCondition == null)
                {
                    hasErrors = true;
                    isToastError = false;
                    redirectionInErrorModal = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.NoVinOrPlateNumber));
                    return;
                }

                if(!receivedAssessmentWrapper.isValidBodyShopType) 
                {
                    hasErrors = true;
                    isToastError = false;
                    redirectionInErrorModal = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.AccountIncorrectType));
                    return;
                }

                retrieveUserAccountAndGroup();
                
                /*********************************/
                //AMI 26/06/18 : Community Rollout 
                //             : Querying claim assessment owner
                //AMI 16/02/18 - C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c to query so that latter can be cloned
                //ASE: 08/05/18: C-002278 : added DistributorPriceId__c, Distributor__c in query            
                //DUN 08/06/2018 C-001837 : Added AgencyDistributors__c , Description__c, NextDistributors__c,               
                String query = 'SELECT Id,AlreadyQuoted__c,Status__c,isShoppingList__c, ParentAssessment__c, Name, BodyShop__c, Entity__c, AssessmentNumber__c, CreatedDate, LastModifiedDate, ' +
                                            'SpecialAgreement__c, SpecialRenting__c, VINCheck__c, Fleet__c, TotalLoss__c, BuildDate__c, CrossReferences__c, AgencyDistributors__c, ' +
                                            'SupposedOfFraud__c, DateOfIncident__c, FirstRegistrationDate__c, EntityCode__c, ReasonFailure__c, Compensated__c, Feature__c, TechDistAndDirectOrder__c,' +
                                            'ModelV2__c, MissionNumber__c, ClaimReference__c, Manufacturer__c, EntityRules__c, ASReference__c, Bodyshop_is_Eligible_Non_AXA__c,NewCompensatedProcess__c,BodyShop__r.IceInvTransmit__c,BodyShop__r.AXAPartner__c, ' +//WCH 26/11/2020 C-003980 add new compensation field on ass
                                            'PlateNumber2__c, TECH_EntityCountryCode__c, VINNumber__c, AssessmentID__c, BodyShop__r.Type, BodyShop__r.SepaValid__c, MREligibility__c, MRSourcing__c,OwnerId,Tech_DirectOrders__c, '+' OrderAuthorised__c,BodyShop__r.OrderFromAT__c , ' +  //RLA 16/08/2018 C-002690 Spain audatex assessments in r4 
                                            'BodyShop__r.AXA_Partner__c,InsuranceBroker__c, '+//WCH 17/12/2019 C-003512 RLA 10/06/2020 C-003753
                                            'BodyShop__r.ShippingPostalCodeLeft2__c,SelectedByBSPartTypes__c, '+//RLA 4029
                                            'Bodyshop__r.Feature__c, Bodyshop__r.Non_AXA_Authorised__c,'+/*C-004277*/
                                            '(SELECT Id, Name, VAT__c, Quantity__c, PartNumber__c, Price__c, Type__c, OriginalPart__c, Original__c, Description__c, NextDistributors__c, ' +
                                                    'SelectedByBS__c, CrossReferenceId__c, IsSourced__c, Assessment__c, TECH_OriginalPart__c,ProducerName__c, Distributors__c, '+
                                                    'QuantityOrdered__c, CrossReferenceId__r.Name, TECH_OrderedCounter__c, Alpha_Scale_MRID__c, DistributorPriceId__c, Distributor__c, TECHDistList__c, ASNetPrice__c, StandardMargin__c, StandardDiscount__c, '+
                                                     ' DiscountRecord__c,DiscountRecord__r.Rebate__c '+//RLA 20/11/2018 C-002782 CJP A'
                                            'FROM PartsLists__r ' +
                                            'WHERE SelectedByBS__c = true ' +
                                            'AND isDeleted__c = false), ' +
                                        '(SELECT Id, Name , AssessmentNumber__c,Tech_DirectOrders__c '+
                                            'FROM Assessments__r ' +
                                            'WHERE RecordType.DeveloperName = \'ClaimOrder\' ' +
                                            'ORDER BY CreatedDate DESC) ' +
                                'FROM Assessment__c ' +
                                'WHERE RecordType.DeveloperName = \'Claim\' AND ' + 
                                    queryCondition +
                                'ORDER BY LastModifiedDate DESC';

                Set<Id> recordsToVerifyPermission = new Set<Id>();
                Set<Id> claimAssessmentIdSet = new Set<Id>();
                mapTypeAssessment = new Map<String, AssessmentWrapper>();

                Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();

                //AMI 14/12/18  C-002781 : Migrate Spain to R4
                //                       : Display Chatter Feed
                //                       : boolean to determine whether to display chatter feed
                if(string.isNotBlank(capturedAssessment.TECH_EntityCountryCode__c) && mapCountryCodeMapping.containsKey((capturedAssessment.TECH_EntityCountryCode__c).toUpperCase())){
                    showFeed = mapCountryCodeMapping.get((capturedAssessment.TECH_EntityCountryCode__c).toUpperCase()).EnableChatterFeed__c;
                }

                // Loop in the assessment
                List<Assessment__c> claimAssessmentList = Database.query(query);
                //RLA 10/11/2020 C-004029:Do not display Expert Assessment for ordering in some cases
                Boolean checkExpertAssess = false;
                map<String, object> mapInputParamsExp = new map<String, Object>();

                for(Assessment__c currentAssessment : claimAssessmentList)
                {
                    recordsToVerifyPermission.add(currentAssessment.Id);

                    if(receivedAssessmentWrapper.isExpertAssessment)
                    {
                        // Normally the query should have returned only the assessment passed as parameter
                        mapTypeAssessment.put(currentAssessment.BodyShop__r.Type, new AssessmentWrapper(currentAssessment, mapCountryCodeMapping));

                        claimAssessmentIdSet.add(currentAssessment.Id);
                        
                        if (String.isNotBlank(currentAssessment.SelectedByBSPartTypes__c) && currentAssessment.SelectedByBSPartTypes__c.contains('A')){
                            system.debug('Check if to display expert');
                            checkExpertAssess = true;
                            mapInputParamsExp.put('Country',currentAssessment.TECH_EntityCountryCode__c);
                            mapInputParamsExp.put('Brand',currentAssessment.Manufacturer__c);
                            mapInputParamsExp.put('State',currentAssessment.BodyShop__r.ShippingPostalCodeLeft2__c);
                            mapInputParamsExp.put('IdExpert',currentAssessment.Id);
                        }   
                        
                        // to improve performance by stopping the loop
                        break;
                    }
                    else
                    {
                        if(currentAssessment.BodyShop__r.Type == 'Standard' && currentAssessment.Id == receivedAssessmentWrapper.currentAssessment.Id)
                        {
                            mapTypeAssessment.put(currentAssessment.BodyShop__r.Type, new AssessmentWrapper(currentAssessment, mapCountryCodeMapping));
                            claimAssessmentIdSet.add(currentAssessment.Id);
                        }
                        else if (currentAssessment.BodyShop__r.Type == 'Expert' && !mapTypeAssessment.containsKey(currentAssessment.BodyShop__r.Type))
                        {
                            
                            if (String.isNotBlank(currentAssessment.SelectedByBSPartTypes__c) && currentAssessment.SelectedByBSPartTypes__c.contains('A')){
                                system.debug('Check if to display expert');
                                checkExpertAssess = true;
                                mapInputParamsExp.put('Country',currentAssessment.TECH_EntityCountryCode__c);
                                mapInputParamsExp.put('Brand',currentAssessment.Manufacturer__c);
                                mapInputParamsExp.put('State',currentAssessment.BodyShop__r.ShippingPostalCodeLeft2__c);
                                mapInputParamsExp.put('IdExpert',currentAssessment.Id);
                            }   
                            mapTypeAssessment.put(currentAssessment.BodyShop__r.Type, new AssessmentWrapper(currentAssessment, mapCountryCodeMapping));
                            claimAssessmentIdSet.add(currentAssessment.Id);
                        }   
                    }
                }
                system.debug('claimAssessmentIdSet>>'+claimAssessmentIdSet);
                //RLA 10/11/2020 C-004029:Do not display Expert Assessment for ordering in some cases
                if (claimAssessmentIdSet.size() > 0
                    && checkExpertAssess){

                    Id IdExpert = mapInputParamsExp.containskey('IdExpert') ? (Id)mapInputParamsExp.get('IdExpert') : null;
                    
                    Boolean displayExp = isDisplayExpert(mapInputParamsExp);
                    system.debug('displayExp>>'+displayExp);
                    if (!displayExp && IdExpert != null){
                       claimAssessmentIdSet.remove(IdExpert) ;
                       mapTypeAssessment.remove('Expert');
                    }


                }
                system.debug('claimAssessmentIdSet after>>'+claimAssessmentIdSet);

                if(claimAssessmentIdSet.size() > 0)
                {
                    // Setting the boolean to true as there are assessments to display
                    hasAssessment = true;

                    // For performance reason select was not done in the for loop -> saved 100ms for 30 claim orders
                    List<Assessment__c> claimOrderAssessmentList = [SELECT   Id, CreatedDate, Status__c, ParentAssessment__c, ParentAssessment__r.ReasonFailure__c,
                                                                            OrderOrigin__c, IsCareOrder__c, OrderStatus__c, AssessmentNumber__c, BodyShop__r.SepaValid__c,
                                                                            BodyShop__r.Type,TECH_EntityCountryCode__c,Tech_DirectOrders__c,
                                                                            BodyShop__r.AXA_Partner__c,//WCH 02/04/2020 C-003685
Compensated__c,/*WCH 19/11/2021 C-004511*/
                                                                            TechDistAndDirectOrder__c,
                                                                            (SELECT Id, BodyShopOrderNumber__c, Name, Status__c
                                                                            FROM PrerequisiteOrders__r
                                                                            WHERE Status__c != 'PREACCEPTANCE')
                                                                    FROM    Assessment__c
                                                                    WHERE   ParentAssessment__c IN: claimAssessmentIdSet
                                                                    AND     RecordType.DeveloperName = 'ClaimOrder'
                                                                    AND     OrderStatus__c != null
                                                                    ORDER BY CreatedDate DESC];

                    for(Assessment__c claimOrderAssessment : claimOrderAssessmentList)
                    {
                        onGoingAssessmentList.add(new OnGoingAssessment(claimOrderAssessment));
                        hasOngoingAssessment = true;

                        recordsToVerifyPermission.add(claimOrderAssessment.Id);
                    }
                }

                // Checking the permission of the assessment
                Set<Id> recordWithReadPermission = verifyPermission(recordsToVerifyPermission);

                if(recordWithReadPermission.contains(receivedAssessmentWrapper.currentAssessment.Id))
                {
                    receivedAssessmentWrapper.hasReadPermission = true;
                }

                // Setting the read permission on the assessment to display
                for(AssessmentWrapper currentWrapper : mapTypeAssessment.values())
                {
                    if(recordWithReadPermission.contains(currentWrapper.currentAssessment.Id))
                    {
                        currentWrapper.hasReadPermission = true;
                    }
                }

                // Setting the read permission on the on going assessment
                for(OnGoingAssessment currentOnGoingAssessment : onGoingAssessmentList)
                {
                    if(recordWithReadPermission.contains(currentOnGoingAssessment.currentAssessment.Id))
                    {
                        currentOnGoingAssessment.hasReadPermission = true;
                    }
                }

                if(!receivedAssessmentWrapper.hasReadPermission)
                {
                    hasErrors = true;
                    isToastError = false;
                    redirectionInErrorModal = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.InsufficientPrivileges));
                }

                //DUN 23/02/2018  C-002186 - Bypass the orderchooseAssessment screen 
                if(ApexPages.currentPage().getParameters().get('Order') != null && 
                   ApexPages.currentPage().getParameters().get('Order').replaceAll('[^a-zA-Z0-9\\s+]', '') == '1' && 
                   mapTypeAssessment.containsKey('Standard')&&//RLA 20/11/2018  C-002879  : UAT Erreur commande BS sur chiffrage Expert
                   mapTypeAssessment.get('Standard').currentAssessment.BodyShop__r.SepaValid__c && 
                   mapTypeAssessment.get('Standard').currentAssessment.ReasonFailure__c == null &&
                   receivedAssessmentWrapper.hasReadPermission){//RLA 09/08/2018  C-002723  Bypass prevents coherent check errors from being thrown
                    system.debug('## Order : ' + ApexPages.currentPage().getParameters().get('Order'));
                    automaticSelecToOrder = true;
                }
            }
        }
        catch(Exception e)
        {
            //VSU 28/03/2018 C-002315             
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){ 
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }else{
                hasAssessment = false;
                hasErrors = true;
                isToastError = false;
                redirectionInErrorModal = true;
                System.debug('@@ message: '+e.getMessage());
                //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.NoAssessmentFound));
            }
        }
    }

    public String decryptBase64(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();
        System.debug('Decrypted Text ' + decryptedText);

        return decryptedText;
    }

    public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);
        System.debug('Encrypted Text ' + encryptedData);

        return encryptedData;
    }

    //DUN 23/02/2018  C-002186 - Bypass the orderchooseAssessment screen
    public PageReference selectToOrder(){
        system.debug('## start selectToOrder : ');
        if(automaticSelecToOrder){
            bsType = 'Standard';
            return createClaimOrderAssessment();
        }else{
            return null;
        }
    }

    public PageReference orderPartsE(){

        String encryptedAssesId = encryptBase64(mapTypeAssessment.get(bsType).currentAssessment.Id);
        system.debug('## encryptedAssesId : '+encryptedAssesId);

        return new PageReference('/apex/OrderConfirmation?AssessmentId='+encryptedAssesId);


    }

    //Method used to create claim Order assessment, Pre-Draft Quote Purchase Order and Pre-Acceptance Sales Order
    public PageReference createClaimOrderAssessment(){
        system.debug('## start createClaimOrderAssessment : ');
        //List of pre-Draft Quote Purchase Order to insert
        List<PurchaseOrder__c> purchaseOrders = new List<PurchaseOrder__c>();
        //List of Orderlines to insert
        List<OrderLine__c> orderLines = new List<OrderLine__c>();
        //list of offers to insert
        List<Offer__c> offers = new List<Offer__c>();
        //Assessemnt claim order which is selected if already exist , else is created
        Assessment__c newClaimOrderAssessment = new Assessment__c();
        List<Assessment__Share> assShareExistList;
        Map<String,String> mapTypeDelay = new Map<String,String>();
        String partType, delayValue;
        List<String> matrixValues = new List<String>();
        list<Account> listDistributors = new list<Account>();

        hasErrors = false;
        isToastError = false;
        //HRM 18/10/21 : C-004215 - Plafond Commande
    	Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();
        if(mapCountryCodeMapping.containsKey(receivedAssessmentWrapper.currentAssessment.TECH_EntityCountryCode__c) && mapCountryCodeMapping.get(receivedAssessmentWrapper.currentAssessment.TECH_EntityCountryCode__c).AllowPlafondCommande__c){
            Id bsId= getBsId();
            if(bsId != null){
                Decimal maxAmountForOrders = VFC28_PlafondCommande.getMaxOrderAmount(bsId);
                Decimal sumTotalPriceOrdered = VFC28_PlafondCommande.getSumTotalPriceOrdered(bsId);
                sumTotalPriceOrdered = sumTotalPriceOrdered != null ? sumTotalPriceOrdered : 0;
                maxAmountForOrders = maxAmountForOrders != null ? maxAmountForOrders : 0;
                if(maxAmountForOrders != null){
                    if(maxAmountForOrders <= sumTotalPriceOrdered){
                        hasErrors = true;
                        isToastError = true;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.ErrorPlafondReached));
                        String reportToEmailAddress = mapCountryCodeMapping.get(receivedAssessmentWrapper.currentAssessment.TECH_EntityCountryCode__c).FinanceAndSupportEmail__c;
                        VFC28_PlafondCommande.ReportError(receivedAssessmentWrapper.currentAssessment,reportToEmailAddress,false);
                        return null; 
                    }
                }
            }
        }
        

        //Dourga 16/03/2018  C-002391 : Impossible to order in Belgium added && receivedAssessmentWrapper.currentAssessment.TECH_EntityCountryCode__c != 'BE'
        if((receivedAssessmentWrapper.hasvinNumber || receivedAssessmentWrapper.hasplateNumber) && receivedAssessmentWrapper.currentAssessment.TECH_EntityCountryCode__c != 'BE'){
            if(String.IsBlank(receivedAssessmentWrapper.vinNumber) || 
               String.IsBlank(receivedAssessmentWrapper.plateNumber)){
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.ErrorPlateVinNumber));
                return null;
            }

            if(receivedAssessmentWrapper.hasvinNumber &&
               String.IsNotBlank(receivedAssessmentWrapper.vinNumber) &&
               receivedAssessmentWrapper.vinNumber.length() > 35){
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.VinNumberError));
                return null;
            }


            if(receivedAssessmentWrapper.hasplateNumber &&
               String.IsNotBlank(receivedAssessmentWrapper.plateNumber) &&
               receivedAssessmentWrapper.plateNumber.length() > 15){
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.PlateNumberError));
                return null;
            }

            receivedAssessmentWrapper.currentAssessment.VINNumber__c =  receivedAssessmentWrapper.vinNumber;
            receivedAssessmentWrapper.currentAssessment.PlateNumber2__c =  receivedAssessmentWrapper.plateNumber;
            update receivedAssessmentWrapper.currentAssessment;
        }

        // Creating a savepoint
        SavePoint beforeDML = Database.setSavepoint();

        //RLA C-004115: FR - E parts orderin
        if (onlyEparts && mapTypeAssessment.containsKey(bsType)){
            String encryptedAssesId = encryptBase64(mapTypeAssessment.get(bsType).currentAssessment.Id);
            system.debug('## encryptedAssesId : '+encryptedAssesId);

            return new PageReference('/apex/OrderConfirmation?AssessmentId='+encryptedAssesId);
        }
        else
        if(mapTypeAssessment.containsKey(bsType))
        {
            //AMI 17/12/2018 : Invalid Query Locator
            //               : Querying partlist info here to avoid invalid query locator
            // Locking the parent
            Assessment__c lockParentAssessment = [  SELECT  Id,TECH_EntityCountryCode__c,/*C-004277*/EntityCode__c,Bodyshop__r.Feature__c,Bodyshop__r.Non_AXA_Authorised__c,Compensated__c,//WCH 18/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                                                        (Select id,CrossReferenceId__c,CrossReferenceId__r.Name,Name, VAT__c, Quantity__c, 
                                                                PartNumber__c, Price__c, Type__c, OriginalPart__c, Original__c, 
                                                                Description__c, NextDistributors__c,SelectedByBS__c,IsSourced__c, Assessment__c, 
                                                                TECH_OriginalPart__c,ProducerName__c, Distributors__c,QuantityOrdered__c, TECH_OrderedCounter__c, Alpha_Scale_MRID__c, 
                                                                DistributorPriceId__c, Distributor__c, TECHDistList__c, ASNetPrice__c, StandardMargin__c, StandardDiscount__c,
                                                                DiscountRecord__c,DiscountRecord__r.Rebate__c,OriginalPart__r.TECH_OriginalPart__c,TechCatalog_Price_Dist_Connected__c
                                                            from PartsLists__r
                                                            // WHERE SelectedByBS__c = true//Conditions added by RLA and commented for 4277
                                                            WHERE isDeleted__c = false
                                                            // HRM 12/10/2021 C-004405 : No Ordering on Fake References
                                                            AND NotForOrder__c = false)
                                                    FROM    Assessment__c
                                                    WHERE   Id =: mapTypeAssessment.get(bsType).currentAssessment.Id FOR UPDATE];

            try
            {
                Assessment__c claimAssessment = mapTypeAssessment.get(bsType).currentAssessment;

                //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => claimAssessment.TECH_EntityCountryCode__c, 'entity' => claimAssessment.EntityCode__c, 'fromProcess' => 'Order'});
                // counting on the locking to prevent the same prefix in the claim order assessment
                //AMI 17/12/2018 : Invalid Query Locator
                //               : Adding newly queried partlist as param
                List<PartList__c> lstPartlistToSend = new list<PartList__c>();
                system.debug('@@@isNonAxa: '+isNonAxa);
                //RLA 19/12/2018 send only selected and already quoted parts
                if (!isNonAxa){
                   for (PartList__c part: lockParentAssessment.PartsLists__r){
                       if (part.SelectedByBS__c == true){
                           lstPartlistToSend.add(part);    
                       }
                   }   
                }
                else{
                    lstPartlistToSend =   lockParentAssessment.PartsLists__r; 
                }
                
                newClaimOrderAssessment = populateNewClaimOrderAssessment(claimAssessment,lstPartlistToSend, true);

                //add new vin number and plate number to new assessment
                if(receivedAssessmentWrapper.hasvinNumber || receivedAssessmentWrapper.hasplateNumber){
                    newClaimOrderAssessment.VINNumber__c    = receivedAssessmentWrapper.vinNumber;
                    newClaimOrderAssessment.PlateNumber2__c = receivedAssessmentWrapper.plateNumber;
                }

                insert newClaimOrderAssessment;

                /*********************************/
                //AMI 26/06/18 : Community Rollout 
                //             : Bypassing programatic sharing
                if((string.isBlank(formattedLicenseName) || 
                   (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains(connectedUserLicenseName)))){
                    if(userConnectedGroup != null){
                        assShareExistList = [SELECT UserOrGroupId, ParentId
                                             FROM Assessment__Share
                                             WHERE UserOrGroupId =: userConnectedGroup.Id
                                             AND ParentId =: claimAssessment.Id];
                    }

                    if(userConnectedGroup != null && bsType == 'Expert' && assShareExistList.IsEmpty()){
                        insert new Assessment__Share(   UserOrGroupId   = userConnectedGroup.Id,
                                                        ParentId        = claimAssessment.Id,
                                                        AccessLevel     = 'Read');
                    }
                }
                System.debug('## newClaimOrderAssessment' + newClaimOrderAssessment);

                //AMI 17/12/2018 : Invalid Query Locator
                //               : Adding newly queried partlist as param
                List<PartList__c> partsToInsertList = copyPartsToClaimOrder(claimAssessment,lstPartlistToSend,newClaimOrderAssessment);

                if(partsToInsertList.size() > 0)
                {
                    insert partsToInsertList;
                    // ASPISWithoutSharingExceptions.insertPartLists(partsToInsertList);
                }
                 //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                Set<String> setDisId = new set<String>();
                if (isnonAxa){
                    Map<String,String> mapOEMswithASPsInsert = new map<String,String>();
                    Map<String,String> mapOEMswithASCRInsert = new map<String,String>();
                     List<PartList__c> partsToUpdateList = new List<PartList__c>();
                    for (PartList__c currentPart: [select id, TECHDistList__c, Alpha_Scale_MRID__c, TECH_OriginalPart__c, OriginalPart__r.TECH_OriginalPart__c, OriginalPart__r.OriginalPart__r.TECH_OriginalPart__c from PartList__c where Id IN :partsToInsertList] ){
                        if (String.isNotBlank(currentPart.Alpha_Scale_MRID__c) && currentPart.Alpha_Scale_MRID__c.StartsWith('ASP-')){
                            System.debug('## i am ASP:' + currentPart.Alpha_Scale_MRID__c + '-' + currentPart.Id);

                            mapOEMswithASPsInsert.put(currentPart.OriginalPart__r.OriginalPart__r.TECH_OriginalPart__c, currentPart.Id);
                        }
                        if (String.isBlank(currentPart.Alpha_Scale_MRID__c)){
                            System.debug('## i am OEM:' + currentPart.Alpha_Scale_MRID__c + '-' + currentPart.Id);
                            // System.debug('## i am ASCR:' + currentPart.Alpha_Scale_MRID__c);

                            mapOEMswithASCRInsert.put(currentPart.OriginalPart__r.TECH_OriginalPart__c, currentPart.Id);
                        }
                        if(!String.isBlank(currentPart.TECHDistList__c)){
                            setDisId.addAll(new List<String>(currentPart.TECHDistList__c.split(';')));
                        }
                    }
                    System.debug('## mapOEMswithASPsInsert:' + mapOEMswithASPsInsert);
                    System.debug('## mapOEMswithASCRInsert:' + mapOEMswithASCRInsert);


                    for (PartList__c currentPart: partsToInsertList ){
                        if(String.isnotblank(currentPart.Alpha_Scale_MRID__c) && currentPart.Alpha_Scale_MRID__c.StartsWith('ASCR-')) {
                            if( mapOEMswithASPsInsert.containsKey(currentPart.OriginalPart__r.TECH_OriginalPart__c) &&  mapOEMswithASPsInsert.get(currentPart.OriginalPart__r.TECH_OriginalPart__c) != null){
                                System.debug('## i am ASCR having ASP OEM:' + currentPart.Alpha_Scale_MRID__c);

                                currentPart.NonAxa_Original_Part__c = mapOEMswithASPsInsert.get(currentPart.OriginalPart__r.TECH_OriginalPart__c);//change to ASP in list
                                
                            }
                            else if( mapOEMswithASCRInsert.containsKey(currentPart.OriginalPart__r.TECH_OriginalPart__c) &&  mapOEMswithASCRInsert.get(currentPart.OriginalPart__r.TECH_OriginalPart__c) != null){
                                System.debug('## i am ASCR having OEM:' + currentPart.Alpha_Scale_MRID__c);
                                System.debug('## i am ASCR having OEM:' + mapOEMswithASCRInsert.get(currentPart.OriginalPart__r.TECH_OriginalPart__c));

                                currentPart.NonAxa_Original_Part__c = mapOEMswithASCRInsert.get(currentPart.OriginalPart__r.TECH_OriginalPart__c);//change to ASP in list
                            }
                            partsToUpdateList.add(currentPart);
                        }
                    }
                    System.debug('## partsToUpdateList:' + partsToUpdateList);


                    if (partsToUpdateList.size() > 0){
                        update partsToUpdateList;
                    }

                }
                System.debug('## setDisId' + setDisId);
                system.debug('>>1 newClaimOrderAssessment.MRSourcing__c before>>'+newClaimOrderAssessment.MRSourcing__c);

                if(!setDisId.isEmpty() && isnonAxa){
                    newClaimOrderAssessment.MRSourcing__c=string.join(new List<String>(setDisId),';');
                } 
                
                system.debug('>>1 newClaimOrderAssessment.MRSourcing__c after>>'+newClaimOrderAssessment.MRSourcing__c);
                


                //DUN 29/01/2018 C-002174 - if MREligibility__c and MRSourcing__c, use list of distributor Id to create PO instead of triggering eligiblity and sourcing
                if(newClaimOrderAssessment.MREligibility__c && newClaimOrderAssessment.MRSourcing__c != null){
                    system.debug('## if');
                    for(String dis : newClaimOrderAssessment.MRSourcing__c.split(';')){
                        listDistributors.add(new Account(Id=dis));
                    }
                    if(listDistributors.size() > 0){
                        //DUN 08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                        set <Id> agencydistributorsId = new set <Id>();
                        if(claimAssessment.AgencyDistributors__c != null && claimAssessment.AgencyDistributors__c != ''){
                            for(String adisId : claimAssessment.AgencyDistributors__c.split(';')){
                                agencydistributorsId.add(adisId);
                            }
                        }
                        Set<Id> directOrdersSet = new Set<Id>();
                        if(!String.isBlank(claimAssessment.Tech_DirectOrders__c))
                            for(String dOId : newClaimOrderAssessment.Tech_DirectOrders__c.split(';')){
                                directOrdersSet.add(dOId);
                            }
                        ASPISDirectSourcing.createPurchaseOrders(newClaimOrderAssessment, listDistributors, null, null, null, null,'P0', agencydistributorsId,directOrdersSet);
                        update new Assessment__c(Id         = newClaimOrderAssessment.Id,
                                                 Status__c  = ASPISConstants.ASSESS_STATUS_SOURCED
                                                 ,MRSourcing__c = newClaimOrderAssessment.MRSourcing__c //RLA 31/03/2021 C-004277
                                                 );
                    }
                }  
                else{
                    system.debug('## else');
                    // Passing the assessment to Ready to generate the PO and OLs
                    update new Assessment__c(Id         = newClaimOrderAssessment.Id,
                                             Status__c  = ASPISConstants.ASSESS_STATUS_READY);
                }  

                //select PO and its OL to update suppliable orderlines
                List<PurchaseOrder__c> listPO = ASPISWithoutSharingExceptions.getPOList(newClaimOrderAssessment.Id);
                system.debug('## listPO' + listPO);

                if(listPO.size() > 0)
                {
                    //Create newSalesOrder
                    PrerequisiteOrder__c newSalesOrder = new PrerequisiteOrder__c(Assessment__c = newClaimOrderAssessment.Id,
                                                                                  BodyShop__c   = newClaimOrderAssessment.BodyShop__c,
                                                                                  Status__c     = 'PREACCEPTANCE',
                                                                                  RecordTypeId  = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId());

                    insert newSalesOrder;
                    System.debug('## newSalesOrder' + newSalesOrder);

                    //Updating all POs with new status PREDRAFTQUOTE
                    //// ASE : 19/01/2018: C-002152: commenting creation of ADD-P /////
                    /*Boolean canCreateAddPart = false;
                    map<String, PartList__c> additionalPartMap = new map<String, PartList__c>();

                    for(PurchaseOrder__c po : listPO){
                        if(po.Distributor__r.Categories__c != null && po.Distributor__r.Categories__c.contains('A') && po.Distributor__r.Name == system.label.AdditionalPartDistributor){
                            // ASE 08/11/17 : C-002072
                            if(!additionalPartMap.containsKey(po.Assessment__c + system.label.AdditionalPartNumber)){

                                additionalPartMap.put( po.Assessment__c + system.label.AdditionalPartNumber, new PartList__c(PartNumber__c = system.label.AdditionalPartNumber
                                                                                                                                            ,Name = system.label.AdditionalPart
                                                                                                                                            ,Description__c = system.label.AdditionalPart
                                                                                                                                            ,Currency__c = 'EUR'
                                                                                                                                            ,Assessment__c = po.Assessment__c
                                                                                                                                            ,Quantity__c = 1
                                                                                                                                            ,Price__c = 0
                                                                                                                                            ,SelectedByBS__c = true
                                                                                                                                            ,Type__c = 'A'
                                                                                                                                            ,TECH_OriginalPart__c = po.Assessment__c + system.label.AdditionalPartNumber
                                                                                                                                            ));      
                            }
                        }
                    }
                    system.debug('## additionalPartMap:'+additionalPartMap);
                    if(additionalPartMap.size() > 0){
                        // map should normally contain only 1 additional part
                        insert additionalPartMap.values()[0];
                    }*//////

                    //WCH 18/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                    Map<Id,List<Id>> partTypeMapDistributors = new Map<Id,List<Id>>();
                    boolean hasMultiSourcing=false;

                    for(PurchaseOrder__c po : listPO){
                        /*canCreateAddPart = false;
                        if(po.Distributor__r.Categories__c != null && po.Distributor__r.Categories__c.contains('A') && po.Distributor__r.Name == system.label.AdditionalPartDistributor){
                            canCreateAddPart = true;
                        }*/
                        mapTypeDelay = new Map<String,String>();
                        if(po.Distributor__r.PartTypeRegionDelayMatrix__c != null)
                        {
                            for(String matrixline : po.Distributor__r.PartTypeRegionDelayMatrix__c.split(';'))
                            {
                                matrixValues = matrixline.split(':');
                                partType = matrixValues[0].right(1);
                                delayValue = matrixValues[2].left(2);
                                if(!mapTypeDelay.containsKey(partType)){
                                    mapTypeDelay.put(partType, delayValue);
                                }
                            }
                        }
                        po.Status__c            = 'PREDRAFTQUOTE';
                        po.PrerequisiteOrder__c = newSalesOrder.Id;
                        po.RecordTypeId         = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId();

                        //AMI 04/09/17 - Distributor Integration
                        po.Tech_ExternalId__c   = string.valueOf(newClaimOrderAssessment.Id) + string.valueOf(po.Distributor__c);

                        purchaseOrders.add(po);                       

                        for(OrderLine__c ol : po.OrderLines__r)
                        {
                            ol.OrderType__c = 'FINAL';
                            ol.ExpectedDeliveryDuration__c = mapTypeDelay != null ? (mapTypeDelay.containsKey(ol.Type__c) ? String.valueOf((Integer.valueOf(mapTypeDelay.get(ol.Type__c)))/24) : null ) : null;
                            orderLines.add(ol);
                            //WCH 20/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
                            if(partTypeMapDistributors.containsKey(ol.PartList__c)){
                                partTypeMapDistributors.get(ol.PartList__c).add(po.Distributor__c);
                                hasMultiSourcing=true;
                            }else{
                                partTypeMapDistributors.put(ol.PartList__c,new List<Id>{po.Distributor__c});
                            }
                            Offer__c offer = new Offer__c(  PrerequisiteOrder__c    = newSalesOrder.Id,
                                                            OrderLine__c            = ol.Id,
                                                            Type__c                 = po.Distributor__r.ReferenceNumber__c);
                            offers.add(offer);                            
                        }
                        
                        //// ASE : 19/01/2018: C-002152: commenting creation of ADD-P /////
                        /*if(canCreateAddPart){
                            OrderLine__c additionalPartOrder = new OrderLine__c(PartNumber__c       = system.label.AdditionalPartNumber
                                                                                ,Description__c     = system.label.AdditionalPart
                                                                                ,Type__c            = 'A'
                                                                                ,Quantity__c        = 1
                                                                                ,CataloguePrice__c  = 0
                                                                                ,PartList__c        = additionalPartMap.values()[0].Id
                                                                                ,PurchaseOrder__c   = po.Id
                                                                                ,TechExternalId__c  = po.Name + '-' + additionalPartMap.values()[0].Id
                                                                                ,OrderType__c       = 'FINAL'
                                                                                ,ExpectedDeliveryDuration__c = mapTypeDelay != null ? (mapTypeDelay.containsKey('A') ? String.valueOf((Integer.valueOf(mapTypeDelay.get('A')))/24) : null ) : null);

                            system.debug('## additionalPartOrder:'+additionalPartOrder);
                            orderLines.add(additionalPartOrder);

                            offers.add(new Offer__c(  PrerequisiteOrder__c  = newSalesOrder.Id
                                                      ,OrderLine__r         = new OrderLine__c(TechExternalId__c = additionalPartOrder.TechExternalId__c)
                                                      ,Type__c              = po.Distributor__r.ReferenceNumber__c));
                        }*//////

                    }

                    system.debug('## orderLines: '+orderLines);
                    if(orderLines.size() > 0)
                    {
                        // class is already in without sharing
                        upsert orderLines TechExternalId__c;
                        // ASPISWithoutSharingExceptions.updateOrderLineList(orderLines);
                    }
                    if(purchaseOrders.size() > 0)
                    {
                        // class is already in without sharing
                        update purchaseOrders;
                        // ASPISWithoutSharingExceptions.updatePurchaseOrderList(purchaseOrders);
                    }
                    system.debug('## offers:'+offers);
                    if(offers.size() > 0)
                    {
                        // class is already in without sharing
                        insert offers;
                        // ASPISWithoutSharingExceptions.insertOffers(offers);
                        
                        system.debug('partTypeMapDistributors>>'+partTypeMapDistributors);
                        //WCH 18/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops : if BE and has multiple distributors for a single partnumber 
                        if(hasMultiSourcing && (CountryCodeInformationsMapping__c.getall().containsKey(lockParentAssessment.TECH_EntityCountryCode__c) && CountryCodeInformationsMapping__c.getall().get(lockParentAssessment.TECH_EntityCountryCode__c).ActivateMultisourcing__c) && lockParentAssessment.TECH_EntityCountryCode__c.equals(ASPISConstants.TECH_EntityCountryCodeBE/*remove this part if to enable preselection for all countries*/)){
                            ASPISPreOffering.executePreOffering(offers, claimAssessment.EntityRules__c, 'PRESELECTION');//ASE 17/12/2018 C-002958, preselection
                        }else{
                            ASPISPreOffering.executePreOffering(offers, claimAssessment.EntityRules__c, 'PREOFFERING');
                        }
                    }
                }
                else
                {
                    Assessment__c assFailure = [SELECT  Id, toLabel(ReasonFailure__c)
                                                FROM    Assessment__c
                                                WHERE   Id =: newClaimOrderAssessment.Id];
                    hasErrors = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, assFailure.ReasonFailure__c));
                    Database.rollback(beforeDML);
                    return null;
                }

                String assId = encryptBase64(claimAssessment.Id);
                String assChildId = encryptBase64(newClaimOrderAssessment.Id);
                //RLA C-004115: FR - E parts orderin
                if (onlyEparts){
                    return new PageReference('/apex/OrderConfirmation?id='+assId+'&ChildId='+assChildId+'&SourceAssessmentId='+encryptedText);
                }
                //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
                if (isNonAxa){
                    return new PageReference('/apex/NONPartenaireOrdering?id='+assId+'&ChildId='+assChildId+'&SourceAssessmentId='+encryptedText);
                }
                else{
                return new PageReference('/apex/OrderMakeSelection?id='+assId+'&ChildId='+assChildId+'&SourceAssessmentId='+encryptedText);
            }


            }
            catch (DMLException e)
            {
                hasErrors = true;
                System.debug( '@@ message 3: '+e.getMessage());


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

                // Rollback to prevent inconsistency of data
                Database.rollback(beforeDML);
            }
            catch(Exception e)
            {
                hasErrors = true;

                System.debug( '@@ message 2: '+e.getMessage());

                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + ' : ' + e.getStackTraceString()));

                // Rollback to prevent inconsistency of data
                Database.rollback(beforeDML);
            }
        }

        return null;
    }

    public PageReference assessmentCanQuote()
    {
        hasErrors = false;
        isToastError = false;

        Assessment__c newClaimOrderAssessment = new Assessment__c();
        List<Assessment__Share> assShareExistList;
        list<Account> listDistributors = new list<Account>();
        
        //Dourga 16/03/2018  C-002391 : Impossible to order in Belgium added && receivedAssessmentWrapper.currentAssessment.TECH_EntityCountryCode__c != 'BE'
        if((receivedAssessmentWrapper.hasvinNumber || receivedAssessmentWrapper.hasplateNumber) && receivedAssessmentWrapper.currentAssessment.TECH_EntityCountryCode__c != 'BE'){
            if(String.IsBlank(receivedAssessmentWrapper.vinNumber) || 
               String.IsBlank(receivedAssessmentWrapper.plateNumber)){
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.ErrorPlateVinNumber));
                return null;
            }

            if(receivedAssessmentWrapper.hasvinNumber &&
               String.IsNotBlank(receivedAssessmentWrapper.vinNumber) &&
               receivedAssessmentWrapper.vinNumber.length() > 35){
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.VinNumberError));
                return null;
            }


            if(receivedAssessmentWrapper.hasplateNumber &&
               String.IsNotBlank(receivedAssessmentWrapper.plateNumber) && 
               receivedAssessmentWrapper.plateNumber.length() > 15){
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.PlateNumberError));
                return null;
            }

            receivedAssessmentWrapper.currentAssessment.VINNumber__c =  receivedAssessmentWrapper.vinNumber;
            receivedAssessmentWrapper.currentAssessment.PlateNumber2__c =  receivedAssessmentWrapper.plateNumber;
            update receivedAssessmentWrapper.currentAssessment;
        }

        // Creating a savepoint
        SavePoint beforeDML = Database.setSavepoint();

        if(mapTypeAssessment.containsKey(bsType))
        {
            //AMI 17/12/2018 : Invalid Query Locator
            //               : Querying partlist info here to avoid invalid query locator
            // Locking the parent
            Assessment__c lockParentAssessment = [  SELECT  Id,TECH_EntityCountryCode__c,Compensated__c,
                                                        (Select id,CrossReferenceId__c,CrossReferenceId__r.Name,Name, VAT__c, Quantity__c, 
                                                                PartNumber__c, Price__c, Type__c, OriginalPart__c, Original__c, 
                                                                Description__c, NextDistributors__c,SelectedByBS__c,IsSourced__c, Assessment__c, 
                                                                TECH_OriginalPart__c,ProducerName__c, Distributors__c,QuantityOrdered__c, TECH_OrderedCounter__c, Alpha_Scale_MRID__c, 
                                                                DistributorPriceId__c, Distributor__c, TECHDistList__c, ASNetPrice__c, StandardMargin__c, StandardDiscount__c,
                                                                DiscountRecord__c,DiscountRecord__r.Rebate__c,OriginalPart__r.TECH_OriginalPart__c
                                                            from PartsLists__r
                                                            WHERE SelectedByBS__c = true//Conditions added by RLA
                                                            AND isDeleted__c = false)
                                                    FROM    Assessment__c
                                                    WHERE   Id =: mapTypeAssessment.get(bsType).currentAssessment.Id FOR UPDATE];

            try
            {
                Assessment__c claimAssessment = mapTypeAssessment.get(bsType).currentAssessment;

                List<PartList__c> lstPartlistToSend = new list<PartList__c>();
                //RLA 19/12/2018 send only selected and already quoted parts
                //if (lockParentAssessment.TECH_EntityCountryCode__c == 'ES'){
                //    for (PartList__c part: lockParentAssessment.PartsLists__r){
                //        if (part.AlreadyQuoted__c == false){
                //            lstPartlistToSend.add(part);    
                //        }
                //    }   
                //}
                //else{
                    lstPartlistToSend =   lockParentAssessment.PartsLists__r; 
                //}
                

                // counting on the locking to prevent the same prefix in the claim order assessment
                //AMI 17/12/2018 : Invalid Query Locator
                //               : Adding newly queried partlist as param
                newClaimOrderAssessment = populateNewClaimOrderAssessment(claimAssessment,lstPartlistToSend, true);

                //add new vin number and plate number to new assessment
                if(receivedAssessmentWrapper.hasvinNumber || receivedAssessmentWrapper.hasplateNumber){
                    newClaimOrderAssessment.VINNumber__c    = receivedAssessmentWrapper.vinNumber;
                    newClaimOrderAssessment.PlateNumber2__c = receivedAssessmentWrapper.plateNumber;
                }

                insert newClaimOrderAssessment;

                /*********************************/
                //AMI 26/06/18 : Community Rollout 
                //             : Bypassing programatic sharing
                if((string.isBlank(formattedLicenseName) || 
                   (string.isNotBlank(formattedLicenseName) && !formattedLicenseName.contains(connectedUserLicenseName)))){
                    if(userConnectedGroup != null){
                        assShareExistList = [SELECT UserOrGroupId, ParentId
                                             FROM Assessment__Share
                                             WHERE UserOrGroupId =: userConnectedGroup.Id
                                             AND ParentId =: claimAssessment.Id];
                    }

                    if(userConnectedGroup != null && bsType == 'Expert' && assShareExistList.IsEmpty()){
                        insert new Assessment__Share(   UserOrGroupId   = userConnectedGroup.Id,
                                                        ParentId        = claimAssessment.Id,
                                                        AccessLevel     = 'Read');
                    }
                }
                System.debug('## newClaimOrderAssessment' + newClaimOrderAssessment);

                //AMI 17/12/2018 : Invalid Query Locator
                //               : Adding newly queried partlist as param
                List<PartList__c> partsToInsertList = copyPartsToClaimOrder(claimAssessment,lstPartlistToSend,newClaimOrderAssessment);

                if(partsToInsertList.size() > 0)
                {
                    insert partsToInsertList;
                    // ASPISWithoutSharingExceptions.insertPartLists(partsToInsertList);
                }

                //DUN 29/01/2018 C-002174 - if MREligibility__c and MRSourcing__c, use list of distributor Id to create PO instead of triggering eligiblity and sourcing
                if(claimAssessment.MREligibility__c && claimAssessment.MRSourcing__c != null){
                    //DUN 08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                    set <Id> agencydistributorsId = new set <Id>();
                    for(String dis : claimAssessment.MRSourcing__c.split(';')){
                        listDistributors.add(new Account(Id=dis));
                    }
                    if(claimAssessment.AgencyDistributors__c != null && claimAssessment.AgencyDistributors__c != ''){
                        for(String adisId : claimAssessment.AgencyDistributors__c.split(';')){
                            agencydistributorsId.add(adisId);
                        }
                    }
                    Set<Id> directOrdersSet = new Set<Id>();
                    if(!String.isBlank(claimAssessment.Tech_DirectOrders__c))
                        for(String dOId : claimAssessment.Tech_DirectOrders__c.split(';')){
                            directOrdersSet.add(dOId);
                        }
                    ASPISDirectSourcing.createPurchaseOrders(newClaimOrderAssessment, listDistributors, null, null, null, null,'P0', agencydistributorsId,directOrdersSet);
                }  
                else{
                    // Passing the assessment to Ready to generate the PO and OLs
                    update new Assessment__c(Id         = newClaimOrderAssessment.Id,
                                             Status__c  = ASPISConstants.ASSESS_STATUS_READY);
                } 


                Assessment__c assFailure = [SELECT  Id, toLabel(ReasonFailure__c) 
                                            FROM    Assessment__c 
                                            WHERE   Id =: newClaimOrderAssessment.Id];

                if(assFailure.ReasonFailure__c != null)
                {
                    hasErrors = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, assFailure.ReasonFailure__c));
                    Database.rollback(beforeDML);
                    return null;
                }
                else
                {
                    Database.rollback(beforeDML);
                    String assId = encryptBase64(claimAssessment.Id);
                    return new PageReference('/apex/OrderRunSourcing?AssessmentId='+assId+'&SourceAssessmentId='+encryptedText);
                }
            }
            catch(Exception e)
            {
                hasErrors = true;

                System.debug('@@ message 3: '+e.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'An exception occurred<br/><i>' + e.getMessage() + ' : ' + e.getStackTraceString() + '</i>'));

                // Rollback to prevent inconsistency of data
                Database.rollback(beforeDML);
            }
        }

        return null;
    }

    /**
     * The suffix number in string format
     * @param  claimAssessment The parent assessment (Claim)
     * @return                 The suffix number in string format
     */
    public static String getAssessmentNumberSuffix(Assessment__c claimAssessment)
    {
        Integer assessmentNumberSuffix = 1;
        // Looping the claim orders as in test class the correct value is not being taken due to the same time on created date
        for(Assessment__c existingClaimOrder : [SELECT  Id, AssessmentNumber__c
                                                FROM    Assessment__c
                                                WHERE   ParentAssessment__c =: claimAssessment.Id
                                                AND     RecordType.DeveloperName = 'ClaimOrder'])
        {
            if(assessmentNumberSuffix <= Integer.valueOf(existingClaimOrder.AssessmentNumber__c.substringAfterLast('-')))
            {
                assessmentNumberSuffix = Integer.valueOf(existingClaimOrder.AssessmentNumber__c.substringAfterLast('-')) + 1;
            }
        }
    

        return String.valueOf(assessmentNumberSuffix);
    }

    /**
     * Function to clone the claim assessment and build the claim order assessment
     * @param  claimAssessment The claim assessment to clone
     * @return                 Claim Order Assessment with the claim assessment as its parent
     */
    //AMI 17/12/2018 : Invalid Query Locator
    //               : Adding partlist as param so that we no longer based on initial query
    private Assessment__c populateNewClaimOrderAssessment(Assessment__c claimAssessment,list <PartList__c> associatedPL, Boolean isOrder)
    {
        // Cloning the parent assessement
        Assessment__c currentClaimOrder         = claimAssessment.clone(false, true);
        currentClaimOrder.ParentAssessment__c   = claimAssessment.Id;
        if(isOrder)
        {
            currentClaimOrder.OrderOrigin__c        = 'Order';
        }
        else
        {
            currentClaimOrder.OrderOrigin__c        = 'Quotation';
            currentClaimOrder.OrderStatus__c        = 'QUOTATION SENT';
        }
        currentClaimOrder.RecordTypeId          = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();

        if(bodyShopConnected != null && bsType == 'Expert')
        {
            currentClaimOrder.BodyShop__c = bodyShopConnected.Id;
        }

        if( claimAssessment.CrossReferences__c != null &&
            claimAssessment.CrossReferences__c != 'NONE')
        {
            // Loop in the parts and populate the cross ref name
            String crossRefNames = '';

            //AMI 17/12/2018 : Invalid Query Locator
            //               : Loop in param instead of initial query
            for(PartList__c currentPart : associatedPL)
            {
                if(currentPart.CrossReferenceId__c != null)
                {
                    crossRefNames += currentPart.CrossReferenceId__r.Name + ';';
                }
            }

            currentClaimOrder.CrossReferences__c = (crossRefNames != '') ? crossRefNames.removeEnd(';') : 'NONE';
        }

        // Calling the query to set the suffix of the AssessmentNumber__c and AssessmentID__c
        String assessmentNumberSuffix           = getAssessmentNumberSuffix(claimAssessment);
        currentClaimOrder.AssessmentNumber__c   = claimAssessment.AssessmentNumber__c.left(78) + '-' + assessmentNumberSuffix;
        currentClaimOrder.AssessmentID__c       = claimAssessment.AssessmentID__c.left(78) + '-' + assessmentNumberSuffix;
        //RLA 03/07/2019 C-003171: Flag Orders generated from Assessment Tool
        currentClaimOrder.CreatedByAssessmentTool__c = decryptedAssessmentId == currentClaimOrder.ParentAssessment__c && flag == 'true' ? true : false;
        /****************
        *****************/
        //AMI 26/06/18 : Community Rollout 
        //             : Updating owner if connected user have a community license        
        if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains(connectedUserLicenseName)){
             currentClaimOrder.OwnerId = claimAssessment.OwnerId;
        }else{
            currentClaimOrder.OwnerId = connectedUsrId;
        }
        //WCH 30/11/2020 C-003980,08/04/2021 C-004311
        currentClaimOrder.Compensated__c=false;
        if(String.isNotBlank(currentClaimOrder.ClaimReference__c) && String.isNotBlank(currentClaimOrder.TECH_EntityCountryCode__c) && CountryCodeInformationsMapping__c.getall().containsKey(currentClaimOrder.TECH_EntityCountryCode__c) && CountryCodeInformationsMapping__c.getall().get(currentClaimOrder.TECH_EntityCountryCode__c).New_Compensation_Activate__c && String.isNotBlank(currentClaimOrder.EntityCode__c) && system.label.ASFRPrefikarEntity.contains(currentClaimOrder.EntityCode__c) && !currentClaimOrder.isShoppingList__c && currentClaimOrder.BodyShop__c!=null && currentClaimOrder.BodyShop__r.IceInvTransmit__c && currentClaimOrder.BodyShop__r.AXAPartner__c && currentClaimOrder.NewCompensatedProcess__c){
            system.debug('got in compensation');
            for(Case currentCase : [Select Id,PFR_TECH_STDClaimNr__c,PFR_ASCompDecisionFinal__c,PFR_ASCompDecisionEstim__c from Case where PFR_TECH_STDClaimNr__c =: currentClaimOrder.ClaimReference__c limit 1]){
                if(!String.isBlank(currentCase.PFR_ASCompDecisionFinal__c) && currentCase.PFR_ASCompDecisionFinal__c.equals(ASPISConstants.PFR_ASCompDecisionFinalOui)){
                    system.debug('got in compensation set to true');
                    currentClaimOrder.Compensated__c=true;
                }else if(String.isBlank(currentCase.PFR_ASCompDecisionFinal__c)){
                    system.debug('got in compensation set to currentCase.PFR_ASCompDecisionEstim__c');
                    currentClaimOrder.Compensated__c=currentCase.PFR_ASCompDecisionEstim__c;
                }
            }
            
        }
        return currentClaimOrder;
    }

    /**
     * Function to clone the parts of the claim assessment to the claim order assessment
     * @param  claimAssessment      The parent assessment from which the parts must be retrieved to be cloned
     * @param  claimOrderAssessment The child assessment to which the parts needs to be attached
     * @return                      List of parts that need to be created for the claimOrderAssessment
     */
    //AMI 17/12/2018 : Invalid Query Locator
    //               : Adding partlist as param so that we no longer based on initial query
    private List<PartList__c> copyPartsToClaimOrder(Assessment__c claimAssessment,list <PartList__c> associatedPL, Assessment__c claimOrderAssessment)
    {
 
        List <PartList__c> newPartList = new list<PartList__c>();
        


        if (isNonAxa){
            //RLA 31/03/2021 C-004277: FR - Commande sur des chiffrages NON AXA
            List<PartList__c> newPartListToSend = new List<PartList__c>();
            Map<String,String> mapOEMswithASPs = new map<String,String>();
            // Map<String,PartList__c> mapTechOriAllPartlist = new map<String,PartList__c>();
            Map<String,List<PartList__c>> mapOEMswithAllSubs = new map<String,List<PartList__c>>();
            List<PartList__c> listOEMsOnly = new List<PartList__c>();
            //  Map<String,List<PartList__c>> mapPartOkWithSubs = new Map<String,List<PartList__c>>();
            for(PartList__c currentPart : associatedPL)
            {
                if (String.isNotBlank(currentPart.Alpha_Scale_MRID__c) && currentPart.Alpha_Scale_MRID__c.StartsWith('ASP-')){
                    mapOEMswithASPs.put(currentPart.OriginalPart__r.TECH_OriginalPart__c, currentPart.Id);
                }

                // if (String.isNotBlank(currentPart.Alpha_Scale_MRID__c)){
                //     if (mapOEMswithAllSubs.containsKey(currentPart.OriginalPart__r.TECH_OriginalPart__c)){
                //         mapOEMswithAllSubs.get(currentPart.OriginalPart__r.TECH_OriginalPart__c).add(currentPart);
                //     }
                //     else{
                //         mapOEMswithAllSubs.put(currentPart.OriginalPart__r.TECH_OriginalPart__c, new list<PartList__c>{currentPart});
                //     }
                // } 
                // else{
                //     listOEMsOnly.add(currentPart);
                // }

                // mapTechOriAllPartlist.put(currentPart.TECH_OriginalPart__c,currentPart);               
            }

            // for (PartList__c currentPart : listOEMsOnly){

            //     if (mapOEMswithASPs.containsKey(currentPart.TECH_OriginalPart__c)){
            //         mapPartOkWithSubs.put(mapOEMswithASPs.get(currentPart.TECH_OriginalPart__c), new list<PartList__c>());
            //     }
            //     else{
            //         mapPartOkWithSubs.put(currentPart.TECH_OriginalPart__c, new list<PartList__c>());
            //     }

            // }

            for (PartList__c currentPart : associatedPL){

                Boolean toSend = true;
                system.debug('@@ currentPart.TECH_OriginalPart__c' + currentPart.TECH_OriginalPart__c);
                system.debug('@@ currentPart.Alpha_Scale_MRID__c' + currentPart.Alpha_Scale_MRID__c);

                //if it is an OEM having an ASP we do not send
                if(String.isblank(currentPart.Alpha_Scale_MRID__c)){
                    system.debug('@@ OEM here' + currentPart.Name);
                    
                    if (mapOEMswithASPs.containsKey(currentPart.TECH_OriginalPart__c) ){
                        toSend = false;
                        system.debug('@@ not sending currentPart.Name' + currentPart.Name);
                    }
                }
                
                if (toSend){
                    newPartListToSend.add(currentPart);   
                }

            }
            associatedPL.clear();
            associatedPL = new list<PartList__c>(newPartListToSend);

        }


        
        

        // Loop in the parts of the claim Assessment
        //AMI 17/12/2018 : Invalid Query Locator
        //               : Loop in param instead of initial query
        for(PartList__c currentPart : associatedPL)
        {
            //system.debug('## current part ' + currentPart);
            PartList__c clonedPart = currentPart.clone(false, true);
            clonedPart.Assessment__c = claimOrderAssessment.Id;
            clonedPart.OriginalPart__c = currentPart.Id;
            clonedPart.TECH_OriginalPart__c = currentPart.TECH_OriginalPart__c + '-' + claimOrderAssessment.Id + '-' + claimOrderAssessment.AssessmentID__c.substringAfterLast('-');

            newPartList.add(clonedPart);
        }

        // ASE 08/11/17 : C-002072
        /*newPartList.add(new PartList__c(PartNumber__c = system.label.AdditionalPartNumber
                                        ,Name = system.label.AdditionalPart
                                        ,Description__c = system.label.AdditionalPart
                                        ,Currency__c = 'EUR'
                                        ,Assessment__c = claimOrderAssessment.Id
                                        ,Quantity__c = 1
                                        ,Price__c = 0
                                        //SelectedByBS__c = true
                                        ,Type__c = 'A'
                                        ));    */  
        return newPartList;
    }

    /**
     * Function to verify the permission of the user to the assessment
     * @param  currentClaimAssessment The assessment on which the permissions needs to be checked
     * @return                        Whether the user has access to the assessment
     */
    private Set<Id> verifyPermission(Set<Id> recordIdSet)
    {
        Set<Id> userRecordAccessSet = new Set<Id>();
        for(UserRecordAccess currentRecordAccess : [SELECT  RecordId
                                                    FROM    UserRecordAccess
                                                    WHERE   RecordId IN: recordIdSet
                                                    AND     UserId =: UserInfo.getUserId()
                                                    AND     HasReadAccess = true])
        {
            userRecordAccessSet.add(currentRecordAccess.RecordId);
        }

        return userRecordAccessSet;
    }

    public PageReference redirectPage()
    {
        if(receivedAssessmentWrapper == null || !receivedAssessmentWrapper.hasReadPermission)
        {
            PageReference pageRef = Page.Search;
            pageRef.setRedirect(true);
            return pageRef;
        }

        return null;
    }

    private void retrieveUserAccountAndGroup()
    {
        User connectedUser = [SELECT BodyShopID__c
                              FROM  User
                              WHERE Id =: UserInfo.getUserId()];

        if(connectedUser != null && connectedUser.BodyShopID__c != null)
        {
            List<Account> accountList = [SELECT ReferenceNumber__c, SepaValid__c, AXA_Partner__c /* WCH 06/12/2019 C-003512 */
                                        FROM    Account
                                        WHERE   ReferenceNumber__c =: connectedUser.BodyShopID__c];

            if(accountList.size() > 0)
            {
                bodyShopConnected = accountList[0];
            }

            List<Group> currentUserGroupList = [SELECT Id
                                                FROM    Group
                                                WHERE   Name =: connectedUser.BodyShopID__c];

            if(currentUserGroupList.size() > 0)
            {
                userConnectedGroup = currentUserGroupList[0];
            }
        }
    }
    //HRM 19/01/22 : C-004215 - Plafond Commande
    public Id getBsId(){
        System.debug('###HRM Connected User: '+bodyShopConnected);
        System.debug('###HRM received Assesment: '+receivedAssessmentWrapper.currentAssessment);
        if(receivedAssessmentWrapper.currentAssessment.BodyShop__r.Type == 'Expert'){
            return bodyShopConnected.Id;
        }
        else{
            return receivedAssessmentWrapper.currentAssessment.BodyShop__c;
        }
    }
    public class OnGoingAssessment
    {
        public Assessment__c currentAssessment {get; set;}
        public PrerequisiteOrder__c currentSalesOrder {get; set;}
        public String salesOrderEncodedId {get; set;}
        public String bodyShopOrderNumber {get; set;}
        public Boolean hasReadPermission {get; set;}

        public OnGoingAssessment(Assessment__c currentOnGoingAssessment)
        {
            currentAssessment   = currentOnGoingAssessment;
            bodyShopOrderNumber = '';
            salesOrderEncodedId = '';
            hasReadPermission   = false;

            if(currentOnGoingAssessment.PrerequisiteOrders__r.size() > 0)
            {
                // As there is only one take the first one
                currentSalesOrder = currentOnGoingAssessment.PrerequisiteOrders__r[0];

                if(currentSalesOrder != null)
                {
                    Blob encryptedBlob = Blob.valueOf(currentSalesOrder.Id);
                    salesOrderEncodedId = EncodingUtil.base64Encode(encryptedBlob);

                    if(currentSalesOrder.BodyShopOrderNumber__c != null)
                    {
                        Set<String> setBodyShopOrderNumber = new Set<String>(currentSalesOrder.BodyShopOrderNumber__c.split(';'));

                        for(String currentBodyShopOrderNumber : setBodyShopOrderNumber)
                        {
                            bodyShopOrderNumber += currentBodyShopOrderNumber + ';';
                        }

                        bodyShopOrderNumber = bodyShopOrderNumber.removeEnd(';');
                    }
                }
            }
        }
    }

    public class MainAssessment
    {
        public Assessment__c currentAssessment {get; set;}
        public String brand {get; set;}
        public String plateNumber {get; set;}
        public String vinNumber {get; set;}
        public Boolean isExpertAssessment {get; set;}
        public Boolean isValidBodyShopType;
        public Boolean hasReadPermission {get; set;}
        //public Boolean needUpdateNonAxa {get; set;}
        public Boolean hasplateNumber {get; set;}
        public Boolean hasvinNumber {get; set;}

        public MainAssessment(Assessment__c claimAssessment)
        {
            currentAssessment   = claimAssessment;
            brand               = currentAssessment.Manufacturer__c;
            plateNumber         = currentAssessment.PlateNumber2__c;
            vinNumber           = currentAssessment.VINNumber__c;
            isExpertAssessment  = (currentAssessment.BodyShop__c != null && currentAssessment.BodyShop__r.Type == 'Expert');
            isValidBodyShopType = ((currentAssessment.BodyShop__c != null && (currentAssessment.BodyShop__r.Type == 'Expert' || currentAssessment.BodyShop__r.Type == 'Standard')));
            hasReadPermission   = (isExpertAssessment) ? true : false;
            //needUpdateNonAxa    = (currentAssessment.PlateNumber2__c == null || currentAssessment.VINNumber__c == null);
            hasplateNumber = (currentAssessment.PlateNumber2__c == null);
            hasvinNumber = (currentAssessment.VINNumber__c == null);
        }

        /**
         * Function to get the query condition of the assessment
         * @return   The query condition if either VIN or PlateNumber is not null else returns null
         */
        public String getQueryConditions()
        {
            String queryCondition;

            //if(String.isNotBlank(vinNumber) || String.isNotBlank(plateNumber))
            //{
                // if(isExpertAssessment || !(currentAssessment.BodyShop__r.Type == 'Standard' && !currentAssessment.isShoppingList__c && currentAssessment.TECH_EntityCountryCode__c == 'FR') || (String.isBlank(vinNumber) && String.isBlank(plateNumber)))
                if(isExpertAssessment || !(currentAssessment.BodyShop__r.Type == 'Standard' && !currentAssessment.isShoppingList__c && currentAssessment.TECH_EntityCountryCode__c == 'FR'))
                {
                    system.debug('## here if');
                    queryCondition = 'Id = \'' + currentAssessment.Id + '\'';
                }
                // else if(String.isNotBlank(vinNumber) || String.isNotBlank(plateNumber))
                else
                {
                    // system.debug('## here else if');
                    // if(String.isNotBlank(vinNumber))
                    // {
                    //     queryCondition = 'VINNumber__c = \'' + String.escapeSingleQuotes(vinNumber) + '\' ';
                    // }
                    // else if(String.isNotBlank(plateNumber))
                    // {
                    //     queryCondition = 'PlateNumber2__c = \'' + String.escapeSingleQuotes(plateNumber) + '\' ';
                    // }
                    //RLA 14/10/2021 C:004494: 	Un garage ne doit pas pouvoir commander un chiffrage expert d'un Assureur pour un sinistre d'un assureur diff?rent
                    // queryCondition += 'AND (BodyShop__r.Type = \'Expert\' OR BodyShop__r.Type = \'Standard\') AND TECH_EntityCountryCode__c = \'' + currentAssessment.TECH_EntityCountryCode__c + '\' ' + ' AND EntityCode__c = \'' + currentAssessment.EntityCode__c + '\'';
                   
                    if (String.IsnotBlank(currentAssessment.ParentAssessment__c)){
                        queryCondition = '((BodyShop__r.Type = \'Standard\' AND Id = \'' +  currentAssessment.Id + '\' ) OR (BodyShop__r.Type = \'Expert\' AND Id = \'' + currentAssessment.ParentAssessment__c + '\')) AND TECH_EntityCountryCode__c = \'' + currentAssessment.TECH_EntityCountryCode__c + '\' ' ;
                    }
                    else{
                        queryCondition = '(BodyShop__r.Type = \'Standard\' AND Id =\'' +  currentAssessment.Id + '\' ) AND TECH_EntityCountryCode__c = \'' + currentAssessment.TECH_EntityCountryCode__c + '\' ' ;
                    }

                    // + ' AND EntityCode__c = \'' + currentAssessment.EntityCode__c + '\' ';
                }
            //}
            //NON AXA is not used by experts
            //else if(currentAssessment.Bodyshop_is_Eligible_Non_AXA__c){
            //  queryCondition = 'Id = \'' + currentAssessment.Id + '\'';

            //}

            return queryCondition;
        }
    }
    //RLA 10/11/2020 C-004029:Do not display Expert Assessment for ordering in some cases
    public static boolean isDisplayExpert(map<String,Object> mapInputParamsExp){

        String assBrand = mapInputParamsExp.containskey('Brand') ? (string)mapInputParamsExp.get('Brand') : '';
        String assCountryCode = mapInputParamsExp.containskey('Country') ? (string)mapInputParamsExp.get('Country') : '';
        String assState = mapInputParamsExp.containskey('State') ? (string)mapInputParamsExp.get('State') : '';
                              

        String query = ' SELECT Name,Distributor__c, Part_Type__c, Priority__c, BodyShop__c, Agency_mode__c, Type__c  ' +
                        ' FROM DirectOrder__c  ' +
                        ' WHERE RecordType.DeveloperName = \'Direct_Sourcing\' ' +
                        ' AND Part_Type__c INCLUDES ( \'A\' ) '  +
                        ' AND Active__c = true ' +
                        ' AND Distributor__r.ShippingCountryCode = \''+ assCountryCode + '\' '+                        
                        ' AND Brands__c INCLUDES (\'' + assBrand + '\') ' +
                        ' AND State__c INCLUDES (\'' + assState + '\') ' +
                        ' AND Distributor__c!=null ' ;


        system.debug('## query' + query);

        list<DirectOrder__c> listDistributors = Database.query(query);
        system.debug('## listDistributors' + listDistributors);


        if (listDistributors.size() > 0){
            return false;
        }
        else{
            return true;
        }

    }

    public class AssessmentWrapper
    {
        public Assessment__c currentAssessment {get; set;}
        public Boolean hasReadPermission {get; set;}
        public Boolean isEligibleOrder {get; set;}
        public Boolean isEligibleQuotation {get; set;}
        public Boolean isNotAuthorisedOrder {get;set;}

        public AssessmentWrapper(Assessment__c assment, Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping)
        {
            currentAssessment = assment;
            isEligibleOrder = false;
            isEligibleQuotation = false;
            isNotAuthorisedOrder = false;
            // permission of expert assessment is set to true by default as the user won't have access to it
            hasReadPermission = (currentAssessment.BodyShop__c != null && currentAssessment.BodyShop__r.Type == 'Expert') ? true : false;

            CountryCodeInformationsMapping__c currentCountryInfo = (mapCountryCodeMapping.containsKey(currentAssessment.TECH_EntityCountryCode__c) ? mapCountryCodeMapping.get(currentAssessment.TECH_EntityCountryCode__c) : mapCountryCodeMapping.get('DEFAULT'));

            if (currentAssessment.TECH_EntityCountryCode__c == 'ES'
                && currentAssessment.OrderAuthorised__c == false) {
                system.debug('got in non eligible order');
                isNotAuthorisedOrder = true;
            }
            else
            if(currentCountryInfo != null)
            {
                isEligibleOrder = currentCountryInfo.EligibleOrder__c;
                isEligibleQuotation = currentCountryInfo.EligibleQuotation__c;
            }
        }
    }
}