/*************************************************************************************
Class Name - RESTCreateOrder
Version - 1.0
Created Date - 11 November 2016
Function - Controller extension for page OrderMakeSelection,
           which displays all offers available for an assessment 
Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* RlA          01/06/2020  C-003698: IG - createOrder
//RLA          20/08/2020  C-003882 IG - Order Quality Check outside ASPIS

**************************************************************************************/ 
@RestResource(urlMapping='/v1.0/createOrder/*') 
global without sharing class RESTCreateOrder {
//RLA 20/08/2020 C-003882 IG - Order Quality Check outside ASPIS



    static Map<String, String> mapErrorsCreation;  
    static String assessmentName;
    static String assessmentId;
    static SavePoint beforeDML;



    @HttpPost
    global static void createOrder()
    {
        System.debug('---------------------------------- START RESTCreateOrder - searchAssessment ----------------------------------');
        
        datetime qryStart = datetime.now();
        String body = RestContext.request.requestBody.toString();
        // variables
        String jsonResponse= ''; 
        
        if(body != null && body != ''){
        
            jsonResponse = deserialiseResponse(body);

            APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
            wrapperLog.className = 'RESTCreateOrder';
            wrapperLog.objectreference = assessmentName;
            wrapperLog.sobjectid = assessmentId;
            wrapperLog.jsonmessage = body != null && body.length() <= 30000 ? body : '';
            wrapperLog.sobjectName = 'Assessment__c';
            wrapperLog.jsonresponse = jsonResponse != null && jsonResponse.length() <= 30000 ? jsonResponse : '';
            // wrapperLog.wsdate = lastCallOut;
            // wrapperLog.wserrormessage = distErrorMsg;
            wrapperLog.inout = 'Inbound;Outbound';
            // wrapperLog.systemcalling = systemCallingAss;
            // wrapperLog.wsRequest = wsRequestCallout;
            // wrapperLog.wSResponse = wSResponseCallout;
            //wrapperLog.TraceVariablesNena = traceVariables;

            if(jsonResponse != null && (jsonResponse.contains('Exceptions') || (jsonResponse.contains('Error') && !jsonResponse.contains('"ErrorMessage":null')))){
                wrapperLog.status = Label.STATUSFAILED;
            }
            else{
                wrapperLog.status = Label.STATUSPASSED;
            }  

            if(body.length() > 30000){
                wrapperLog.attachmentRequestbody = body;
            }

            if(jsonResponse != null && jsonResponse.length() > 30000){
                wrapperLog.attachmentResponsebody = jsonResponse;
            }  
            datetime qryEnd = datetime.now();
            // Decimal heapsize2 = Limits.getHeapSize() ;
            // system.debug('@@@ heapsize End: '+heapsize2);

            decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
            tempExec = (tempExec.divide(1000, 5));


            wrapperLog.executionTime = tempExec;
            
            // system.debug('@@@ qryEnd: '+qryEnd);
            // system.debug('@@@ tempExec: '+tempExec);
            //system.debug('@@ total'+ (qryEnd.getTime() - qryStart.getTime()) );

            //RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
            APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');

        }

        RestContext.response.responseBody = Blob.valueOf(jsonResponse);
        
        System.debug('---------------------------------- START RESTCreateOrder - searchAssessment ----------------------------------');


    }
    
     public static String deserialiseResponse(String body)
    {
        System.debug('---------------------------------- START RESTCreateOrder - deserialiseResponse ----------------------------------');
        CreateOrderInfo CreateOrderInfoInstance;
        Boolean isValid = false;
        mapErrorsCreation = new Map<String, String>();
        String response;

        try {
            CreateOrderInfoInstance = (CreateOrderInfo) System.JSON.deserialize(body, CreateOrderInfo.class);
            system.debug('@@ CreateOrderInfoInstance'+CreateOrderInfoInstance); 
            if (CreateOrderInfoInstance != null
                ){
                // for (CreateOrderInfo CreateOrderInfoInstance: lstWrapperinstance){
                    for (Assessments AssessmentsInstance : CreateOrderInfoInstance.Assessments){
                        isValid = checkMandatoryFields(AssessmentsInstance);
                        if (isValid){
                            response = queryAssessment(AssessmentsInstance, CreateOrderInfoInstance.CallerSystem);
                        }
                        else{
                            if (mapErrorsCreation.containsKey('MandatoryFields')){
                                response = generateResponse(system.label.BsReferenceMissing, null) ;

                            }
                        }

                    }
                // }
                
            } 



        }
        catch (exception e){
            system.debug('@@ Error'); 
            if (beforeDML != null){
            system.debug('@@ am in rollback');

                Database.rollback(beforeDML); 
            }
            response = generateResponse( 'Exceptions: ' + e.getMessage() + '.  Stack Trace : ' + e.getStackTraceString(),null) ;


        }
         
        
        System.debug('---------------------------------- END RESTCreateOrder - deserialiseResponse ----------------------------------');
        
        return response;

        
    }

     public static string queryAssessment(Assessments assessmentInfo, string callerSystem){
        System.debug('---------------------------------- START RESTCreateOrder - queryAssessment ----------------------------------');

        AccountRef__c accRef = AccountRef__c.getValues(callerSystem + '-' + assessmentInfo.BSReferenceNumber);
        String response;
        String bsId = '';
        String queryCondition;
        Boolean canQuery = true;

        system.debug('@@ accRef: '+ accRef);          
        system.debug('@@ callerSystem: '+ callerSystem);          
        system.debug('@@ assessmentInfo.BSReferenceNumber: '+ assessmentInfo.BSReferenceNumber);          
        if (accRef != null){
            bsId = accRef.InternalReference__c;

            if (String.isBlank(bsId)){                
                return response = generateResponse( system.label.NoBSFound,null) ;
            }
        }
        else{
            // system.debug('@@ accRef: '+ accRef);          

            return response = generateResponse(system.label.NoBSFound,null) ;

        }

        if (String.IsNotBlank(assessmentInfo.AssessmentID)){
            queryCondition = ' AssessmentID__c = \'' + assessmentInfo.AssessmentID + '\''; 
            assessmentName =  assessmentInfo.AssessmentID;

        }
        else{
            canQuery = false;
            response = generateResponse(system.label.SpecifyAssessmentID,null); 
        }

        // system.debug(Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_ClaimOrder).getRecordTypeId());
        system.debug(bsId);
        system.debug(queryCondition);

        String query = 'SELECT Id,ParentAssessment__c, comment__c, BodyShop__c,CreatedDate' +
                        ' FROM Assessment__c ' +
                        ' Where  RecordTypeId =\''+Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_Name_ClaimOrder).getRecordTypeId() +'\'  AND Bodyshop__c = \'' + bsId + '\' AND ' +
                            queryCondition +
                        ' ORDER BY LastModifiedDate DESC';


        system.debug('@@ query'+query);

        if (canQuery){
            list<Assessment__c> listAssessment = Database.query(query);

            if (listAssessment.size() == 0){
                 return generateResponse(system.label.NoAssessFound,null);
            
            }
            if (listAssessment.size() == 1){
                Map<Id, Parts> mapOLIdParts = new map<Id, Parts>();
               
                for (Parts part: assessmentInfo.Parts){
                    mapOLIdParts.put(part.ID, Part);
                }
                system.debug('@@ listAssessment[0]'+listAssessment[0]);
                system.debug('@@ mapOLIdParts'+mapOLIdParts);

                if (mapOLIdParts.size() > 0){

                    if (checkTimeLimit(listAssessment[0].CreatedDate)){
                        Map<String, Object> mapResponse = order(listAssessment[0],assessmentInfo.Comment,assessmentInfo.BodyShopOrderReference, mapOLIdParts );
                        system.debug('@@ mapResponse'+mapResponse);
                        Map<Assessments, List<Parts>> mapAssessParts = new map<Assessments, list<Parts>>();

                        if(mapResponse.containsKey('Response')){
                            if (mapResponse.get('Response') == 'OK'){
                                Map<Id,Parts> mapOrderlineUpdatedParts = new map<Id,Parts>();
                                for (Offer__c off: [Select Id,  Quantity__c,PartNUmber__c, OrderLine__c, Accepted__c, PurchaseOrder__c , Prerequisiteorder__c ,Prerequisiteorder__r.Name, AgencyMode__c, Distributor__c,OrderLine__r.PurchaseOrder__c
                                                        From Offer__c
                                                        where OrderLine__c in :mapOLIdParts.keyset() 
                                                        and OrderLine__r.PurchaseOrder__r.Assessment__r.AssessmentID__c = :assessmentInfo.AssessmentID ]){

                                    Parts part =new Parts(off);
                                    part.Message = 'Success';
                                    
                                    mapOrderlineUpdatedParts.put(off.OrderLine__c,part);
                                    system.debug('@@ off: '+ off);
                                }
                                system.debug('@@ mapOrderlineUpdatedParts before'+mapOrderlineUpdatedParts);


                                for (Id idOl: mapOLIdParts.keyset()){
                                    if (!mapOrderlineUpdatedParts.containsKey(idOl)){
                                        Parts part = mapOLIdParts.get(idOl);
                                        part.Order = false;
                                        part.Message = 'PartList was not found';
                                        mapOrderlineUpdatedParts.put(idOl, part);

                                    }
                                }

                                system.debug('@@ mapOrderlineUpdatedParts'+mapOrderlineUpdatedParts);
                                mapAssessParts.put(assessmentInfo,mapOrderlineUpdatedParts.values() );


                            }
                            return  generateResponse( (String) mapResponse.get('Response'), mapAssessParts);


                        }
                    }
                    else{
                         return response = generateResponse( system.label.TimeLimitMessage,null) ;
                    }
                    
                }
                else{
                    return generateResponse(system.label.SpecifyAtleast1Part,null);
                }                

            }
            else{
                return generateResponse('You must send only one Assessment',null);
            }
        }                


        return response;


     }

    public static Boolean checkMandatoryFields(Assessments assessmentInfo){
        System.debug('---------------------------------- START RESTCreateOrder - checkMandatoryFields ----------------------------------');

        Boolean isValid = false;

        String missingFields  = checkFields(assessmentInfo);

        // check if missingFields is blank, asssessment is valid
        if(missingFields == ''){
            isValid = true;
        }
        else{
            isValid = false;
            mapErrorsCreation.put('MandatoryFields', 'Exceptions: Missing fields: '+ missingFields);
        }

        system.debug('@@@ isValid: '+isValid);
        System.debug('---------------------------------- END RESTCreateOrder - checkMandatoryFields ----------------------------------');


        return isValid;
     }

    public static String checkFields(Assessments assessmentInfo){
        System.debug('---------------------------------- START RESTCreateOrder - checkFields ----------------------------------');

        String missingFields = '';

        if (String.isBlank(assessmentInfo.BSReferenceNumber )){
            missingFields = 'BSReferenceNumber';
        }
        System.debug('---------------------------------- START RESTCreateOrder - checkFields ----------------------------------');

        return missingFields;
    }

    public static map<String,Object> order(Assessment__c currentClaimOrderAssessment, String comment, String bodyShopOrderNumber, Map<Id, Parts> mapOLIdParts){

        Map<String, OrderMakeSelection.PartWrapper> mapPartWrapper  = new Map<String, OrderMakeSelection.PartWrapper>();
        Map<String, OrderMakeSelection.PartWrapper> mapAlreadyOrderedPartWrapper= new Map<String, OrderMakeSelection.PartWrapper>();
        map<String,Object> mapReturn = new map<String,Object> ();
        map<Id, Offer__c> mapOffersResponse = new map<Id,Offer__c>();
        String response = '';



        // checking if the salesOrder has already been responded
        List<PrerequisiteOrder__c> respondedSalesOrderList =    [SELECT Id, Status__c, Assessment__r.Name
                                                                 FROM   PrerequisiteOrder__c
                                                                 WHERE  Assessment__c =: currentClaimOrderAssessment.Id
                                                                 AND    (Status__c !=: ASPISConstants.PRE_ORDER_STATUS_PREACCEPTANCE)];
        system.debug('@@ respondedSalesOrderList: '+respondedSalesOrderList);

        if(respondedSalesOrderList.size() > 0)
        {
            mapReturn.put('Response','SO does not have the right status for ordering');
            return mapReturn;
        }

        
       
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

            
            Id assessmentClaimId = currentClaimOrderAssessment.ParentAssessment__c;

            map <string,list <OrderMakeSelection.orderingPartWrapper>> mapDistNamePartList = new map <string,list <OrderMakeSelection.orderingPartWrapper>>();

            // String bodyShopOrderNumber; //Map to json

            String assessmentComment = comment;
                assessmentId = currentClaimOrderAssessment.Id;

            // //ASE 23/11/17  : phase pilote: pas d'appel si BodyShop__c.DistributorConnected__c = false
            // Assessment__c BS = [Select BodyShop__r.DistributorConnected__c from Assessment__c where id =:currentClaimOrderAssessment.Id];
            // Boolean connectedBS = BS.BodyShop__r.DistributorConnected__c;

            //Commented by RLA on 20/11/2020
            // Setting the comment if present
            // if(currentClaimOrderAssessment != null && currentClaimOrderAssessment.Comment__c != null)
            // {
                // assessmentComment = currentClaimOrderAssessment.Comment__c; 
            // }

            // Map<Id, Parts> mapOrderLineIdPartsSent = new map<Id, Parts>();

            for(Offer__c currentOffer : [SELECT Id, Type__c, BSTotalPrice__c, OrderLine__r.BodyShopDiscount__c, Quantity__c, OrderLine__r.CataloguePrice__c, OrderLine__r.PartList__c, PartNUmber__c, ParentOffer__c, 
                                                    OriginalPartNumber__c, OriginalDescription__c, FinalType__c, PreselectedForOrder__c, CancelReason__c,
                                                    OrderLine__r.PartList__r.Name, OrderLine__r.PartNumber__c, OrderLine__r.PartList__r.VAT__c, OrderLine__r.PartList__r.Quantity__c, OrderLine__r.TotalPrice__c , Description__c,
                                                    OrderLine__r.PartList__r.PartNumber__c, OrderLine__r.PartList__r.Price__c, OrderLine__r.PartList__r.Type__c, Discount__c, Distributor__c,
                                                    OrderLine__r.PartList__r.OriginalPart__c, OrderLine__r.PartList__r.Original__c,OrderLine__r.PartList__r.Description__c, Accepted__c,
                                                    OrderLine__r.PartList__r.ProducerName__c, OrderLine__r.PartList__r.SelectedByBS__c,
                                                    OrderLine__r.PartList__r.CrossReferenceId__c, OrderLine__r.PartList__r.IsSourced__c, OrderLine__r.PartList__r.Assessment__c, orderLine__r.PartList__r.DiscountRecord__c, //RLA 27/11/2018 C-002782 CJP A'
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
                                                    PrerequisiteOrder__r.Assessment__r.BodyShop__r.DistributorConnected__c, PrerequisiteOrder__r.Assessment__r.Compensated__c, PrerequisiteOrder__r.Assessment__r.Comment__c,PrerequisiteOrder__r.Assessment__r.BodyShop__c,
                                                    PrerequisiteOrder__r.Assessment__r.Manufacturer__c,PrerequisiteOrder__r.Assessment__r.ModelV2__c,PrerequisiteOrder__r.Assessment__r.FirstRegistrationDate__c ,
                                                    PrerequisiteOrder__r.Assessment__r.PlateNumber2__c,PrerequisiteOrder__r.Assessment__r.VINNumber__c,PrerequisiteOrder__r.Assessment__r.BuildDate__c,
                                                    PrerequisiteOrder__r.Assessment__r.ClaimReference__c,PrerequisiteOrder__r.Assessment__r.BodyShop__r.ParentId, PrerequisiteOrder__r.Assessment__r.ParentAssessment__r.BodyShop__r.ParentId,
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
                                                    OrderLine__r.PurchaseOrder__r.TechInsuranceBroker__c ////RLA 20/08/2020 C-003882
                                             FROM   Offer__c 
                                             WHERE  PrerequisiteOrder__r.Assessment__r.ParentAssessment__c =: assessmentClaimId
                                             order by OrderLine__r.PurchaseOrder__r.Distributor__r.Name]) //WCH 13/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
            {

                 if( currentOffer.PrerequisiteOrder__r.Assessment__c == currentClaimOrderAssessment.Id &&
                    currentOffer.PrerequisiteOrder__r.Assessment__r.ParentAssessment__c != null)
                {
                    system.debug('@@@ here 1: ');

                    if(!mapPartWrapper.containsKey(currentOffer.OrderLine__r.PartList__c))
                    {   
                        // OrderMakeSelection.isAccepted = true;
                        // OrderMakeSelection.OfferWrapper.isAccepted = true;
                        mapPartWrapper.put(currentOffer.OrderLine__r.PartList__c, new OrderMakeSelection.PartWrapper(currentOffer));
                    }
                    else
                    {   
                        mapPartWrapper.get(currentOffer.OrderLine__r.PartList__c).addNewOffer(currentOffer);
                    }
                }
                // else if(currentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c > 0 && 
                //     currentOffer.OrderLine__r.Suppliable__c == 'YES' && 
                //     (
                //             currentOffer.PrerequisiteOrder__r.Status__c != 'PREACCEPTANCE' && 
                //             currentOffer.PrerequisiteOrder__r.Status__c != 'INACCEPTANCE'
                //     ))
                // {

                // }

            }
            system.debug('@@@ mapPartWrapper: '+mapPartWrapper);

             for(OrderMakeSelection.PartWrapper currentPartWrapper : mapPartWrapper.values())
            {
                system.debug('@@@ currentPartWrapper: '+currentPartWrapper);

                for(OrderMakeSelection.DistributorWrapper currentDistributorWrapper : currentPartWrapper.mapDistributorWrapper.values())
                {
                    system.debug('@@@ currentDistributorWrapper: '+currentDistributorWrapper);

                    for(OrderMakeSelection.OfferWrapper currentOfferWrapper : currentDistributorWrapper.mapOfferWrapper.values())
                    {
                        system.debug('@@@ currentOfferWrapper: '+currentOfferWrapper);

                        Boolean isAccepted = false;
                        Decimal quantity; 

                        if (mapOLIdParts.containsKey(currentOfferWrapper.parentOffer.OrderLine__c)){
                            Parts part = mapOLIdParts.get(currentOfferWrapper.parentOffer.OrderLine__c);
                            if (part.Order == true && part.Quantity > 0){
                                isAccepted = true;

                            }
                            quantity = part.Quantity; 
                             
                        }
                        system.debug('@@@ isAccepted: '+isAccepted);
                        system.debug('@@@ quantity: '+quantity);


                        if(isAccepted)
                        {
                            system.debug('@@@ currentOfferWrapper.isAccepted: ');

                         
                            // OFFER
                            offerToUpdateList.add(new Offer__c( Id              = currentOfferWrapper.parentOffer.Id,
                                                                Accepted__c     = 'YES',
                                                                Suppliable__c   = true,
                                                                Type__c         = ''));

                            // Loop in child offers if present
                            if(currentOfferWrapper.childOfferList.size() > 0)
                            {
                                for(OrderMakeSelection.BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
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
                                                                                                                    Quantity__c             = quantity));
                            
                            if(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c != null)
                            {
                                mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                  = currentOfferWrapper.parentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                                        Suppliable__c       = 'YES',
                                                                                                                                        AcceptedCheck__c    = true,
                                                                                                                                        PreselectedForOrder__c  = true));
                            }

                            if(currentPartWrapper.currentPart.PartNumber__c != system.label.AdditionalPartNumber){
                                mapPartToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c, new PartList__c(Id                     = currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__c,
                                                                                                                                            //Ordered__c             = true,
                                                                                                                                            TECH_OrderedCounter__c = (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c != null ? (currentOfferWrapper.parentOffer.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c + 1) : 1),
                                                                                                                                            QuantityOrdered__c     = quantity));
                            }

                            if(!mapPurchaseOrderToUpdate.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c))
                            {
                                // if(careOrderSwitch == 'ON')
                                // {
                                    mapPurchaseOrderToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                    BodyShopOrderNumber__c = bodyShopOrderNumber,
                                                                                                                                                    Comment__c = comment,
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
                                    mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Comment__c = Comment;
                                }
                            }
                            system.debug('@@@ here'+mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c);
                            // PURCHASE ORDER //RLA 08-11-2019  C-003411 : Agency Mode V3
                            if( (mapPurchaseOrderToUpdate.get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c).Status__c == ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                                && !mapPurchaseOrderToUpdateAgencyV3.containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c)
                                && CountryCodeInformationsMapping__c.getall().containsKey(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c) 
                                && CountryCodeInformationsMapping__c.getall().get(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TECH_AssessmentCountryCode__c).AgencyModeAutomaticDelivery__c
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.AgencyMode__c 
                                && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.Agency_V3__c
                                )
                                )
                                
                            {
                                system.debug('@@@ here agency mode');
                                mapPurchaseOrderToUpdateAgencyV3.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                                                                                                                                                Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED));
                            }

                            // //RLA 20/08/2020 C-003882 IG - Order Quality Check outside ASPIS
                            // if( (String.isnotblank(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TechInsuranceBroker__c) && system.label.InsBrokerName.contains(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.TechInsuranceBroker__c))
                            //     && currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.Distributor__r.OrderRequest__c == 'OrderR4'
                            //     )
                                
                            // {
                            //     system.debug('@@@ here automatic delivery');
                            //     mapPurchaseOrderToUpdateAgencyV3.put(currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c, new PurchaseOrder__c(Id = currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__c,
                            //                                                                                                                     Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED));
                            // }

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

                        }//Offer accepted
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
                                for(OrderMakeSelection.BundleItemWrapper currentBundleWrapper : currentOfferWrapper.childOfferList)
                                {
                                    offerToUpdateList.add(new Offer__c( Id = currentBundleWrapper.bundleItem.Id,
                                                                        Accepted__c  = 'NO',
                                                                        Suppliable__c  = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? true :
                                                                                        ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                        currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? false : true,
                                                                        PreselectedForOrder__c  = false,
                                                                        Type__c = ''));
                                }
                            }
                            mapOrderLineToUpdate.put(currentOfferWrapper.parentOffer.OrderLine__c, new OrderLine__c(Id = currentOfferWrapper.parentOffer.OrderLine__c,
                                                                                                                    Suppliable__c  = ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMED' ||
                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c == 'CONFIRMEDWITHDELAY') &&
                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null) ? 'YES' :
                                                                                                                                    ((currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMED' &&
                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.SASStatus__c != 'CONFIRMEDWITHDELAY' &&
                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsDate__c != null &&
                                                                                                                                    currentOfferWrapper.parentOffer.OrderLine__r.PurchaseOrder__r.wsErrorMessage__c == null)) ? 'NO' : 'YES',
                                                                                                                    AcceptedCheck__c = false));

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

                        }//offer not accepted

                    }
                }
            }//end if mapPartWrapper.values()
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

            Boolean err = false;

            // if(mapPartToUpdate.size() > 0)
            // {
            //     update mapPartToUpdate.values();
            // }
            List <Database.Saveresult> listPartResults   = Database.update(mapPartToUpdate.values(), false);

            //error management
            for(Database.SaveResult res : listPartResults){
                if(!res.isSuccess()){
                    //raise error
                    err  = true;
                }
            }//end looping in result list

            // if(mapPurchaseOrderToUpdate.size() > 0)
            // {
            //     update mapPurchaseOrderToUpdate.values();
            // }

            List <Database.Saveresult> listPoResults   = Database.update(mapPurchaseOrderToUpdate.values(), false);

            

            // if(mapSalesOrderToUpdate.size() > 0)
            // {
            //     update mapSalesOrderToUpdate.values();
            // }
            List <Database.Saveresult> listSOResults   = Database.update(mapSalesOrderToUpdate.values(), false);

            //error management
            for(Database.SaveResult res : listSOResults){
                if(!res.isSuccess()){
                    //raise error
                    err  = true;
                }
            }//end looping in result list

            // if(mapAssessmentToUpdate.size() > 0)
            // {
            //     update mapAssessmentToUpdate.values();
            // }
            List <Database.Saveresult> listAssResults   = Database.update(mapAssessmentToUpdate.values(), false);

            //error management
            for(Database.SaveResult res : listAssResults){
                if(!res.isSuccess()){
                    //raise error
                    err  = true;
                }
            }//end looping in result list

            system.debug('@@@ mapPurchaseOrderToUpdateAgencyV3: '+mapPurchaseOrderToUpdateAgencyV3);
            if(mapPurchaseOrderToUpdateAgencyV3.size() > 0)
            {
                update mapPurchaseOrderToUpdateAgencyV3.values();
            }

            if (!err){
                map<String, Object> mapParams = new map<String,Object>();

                //error management
                for(Database.SaveResult res : listPoResults){
                    if(res.isSuccess()){
                        mapParams.put('currentPurchaseOrder', new PurchaseOrder__c(Id = res.getId()));
                        validatePurchaseOrder(mapParams);
                    }
                }//end looping in result list               

            }
        
       
         mapReturn.put('Response','OK');
        return mapReturn;
    }

    // public static string generateResponse(String ErrorMessage){

    //     JSONGenerator genResults = JSON.createGenerator(false);

    //     return ErrorMessage;

    // }

    public static string generateResponse(String ErrorMessage, Map<Assessments, List<Parts>> MapAssessParts){

        JSONGenerator genResults = JSON.createGenerator(false);

        if (ErrorMessage == 'OK' && MapAssessParts != null){
            //genResults.writeStartArray();
                genResults.writeStartObject();
                    genResults.writeFieldName('Assessments');
                        genResults.writeStartArray();
                        for (Assessments assess: MapAssessParts.keyset()){
                            genResults.writeStartObject();
                                genResults.writeStringField('AssessmentID', String.IsNotBlank(assess.AssessmentID) ? assess.AssessmentID : '');
                                genResults.writeStringField('InsBrokerNumber', String.IsNotBlank(assess.InsBrokerNumber) ? assess.InsBrokerNumber : '');
                                genResults.writeStringField('BSReferenceNumber', String.IsNotBlank(assess.BSReferenceNumber) ? assess.BSReferenceNumber : '');
                                genResults.writeStringField('BodyShopOrderReference', String.IsNotBlank(assess.BodyShopOrderReference) ? assess.BodyShopOrderReference : '');
                           
                                genResults.writeFieldName('Parts');
                                genResults.writeStartArray();
                            
                                    for (Parts part: MapAssessParts.get(assess) ){
                                        genResults.writeStartObject();
                                            genResults.writeNumberField('Quantity', part.Quantity != null ? part.Quantity : 0);
                                            genResults.writeStringField('PartNumber', String.IsNotBlank(part.PartNumber) ? part.PartNumber : '');
                                            genResults.writeStringField('ID', String.IsNotBlank(part.Id) ? part.Id : '');
                                            genResults.writeBooleanField('Order',part.Order != null ? part.Order : false);
                                            genResults.writeStringField('PO', String.IsNotBlank(part.PO) ? part.PO : '');
                                            genResults.writeStringField('POLink', String.IsNotBlank(part.POLink) ? part.POLink : '');
                                            genResults.writeStringField('SO',String.IsNotBlank(part.SO) ?  part.SO : '');
                                            genResults.writeBooleanField('AgencyMode', part.AgencyMode != null ?  part.AgencyMode  : false );
                                            genResults.writeStringField('Distributor', String.IsNotBlank(part.Distributor) ? part.Distributor : '');
                                            genResults.writeStringField('Message', String.IsNotBlank(part.Message) ? part.Message : '');
                                        genResults.writeEndObject();
                                    }
                                
                                genResults.writeEndArray();
                            genResults.writeEndObject();

                        }
                        genResults.writeEndArray();                            
                    genResults.writeStringField('Message', ErrorMessage);
                genResults.writeEndObject();                
            //genResults.writeEndArray();   

        }
        else{
           // genResults.writeStartArray();
                genResults.writeStartObject();
                    genResults.writeFieldName('Assessments');
                    genResults.writeStartArray();
                    genResults.writeEndArray();                            
                genResults.writeStringField('Message', ErrorMessage);
                genResults.writeEndObject();                
           // genResults.writeEndArray();   


        }      
          
        return  genResults.getAsString();

    }

    public static Boolean checkTimeLimit(Datetime createdDateAssess){
        if (system.label.limitForOrder == 'none'){
            return true;
        }
        else{
            integer limittime = integer.valueof(system.label.limitForOrder);
          
            system.debug('@@ createdDateAssess:'+createdDateAssess );

            DateTime datetimeNow =datetime.now();

            // integer Difference = datetimeNow.minute() - createdDateAssess.minute();
            // system.debug(Difference );
            Long Difference = datetimeNow.getTime() - createdDateAssess.getTime();
            Difference /= 60000;


            if (Difference <=limittime ){
                return true;
            }
            else{
                return false;
            }


            
        }
    }

    //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
    public static map<String,Object> validatePurchaseOrder(map<String, Object> mapParams){

        system.debug('## start validatePurchaseOrder');

        map<String, Object> mapOutputParams = new map<String,Object>();

        PurchaseOrder__c currentPurchaseOrder = mapParams.containsKey('currentPurchaseOrder') ? (PurchaseOrder__c)mapParams.get('currentPurchaseOrder') : null;
        Boolean hasErrors = false;

        system.debug('## currentPurchaseOrder'+currentPurchaseOrder);


        if (currentPurchaseOrder != null){       

            // ASE : 08/04/18 : Coler WS
            PurchaseOrder__c purchaseOrderToUpdate = new PurchaseOrder__c(  Id = currentPurchaseOrder.Id);
            //ASE: 09/07/2018: C-002659 : Prices & Part Type to be sent to Coler  - add Assessment__r.TECH_EntityCountryCode__c in query
            list<PurchaseOrder__c> currentPOList = [Select Distributor__r.OrderRequest__c, Distributor__r.DistributorConnected__c, Assessment__r.BodyShop__r.DistributorConnected__c, Assessment__r.BodyShop__r.isEligibleSourcing__c, Assessment__r.OrderOrigin__c, Assessment__r.TECH_EntityCountryCode__c, Status__c, techColerCalled__c, name
                                                     from PurchaseOrder__c where id = :currentPurchaseOrder.Id];
            
            PurchaseOrder__c currentPO = null;

            system.debug('## currentPOList'+currentPOList);


            if(currentPOList.size() > 0 ){
                currentPO = currentPOList[0];
            }

            
            if(/*ASE: 30/11/18 - C-002948 */currentPO != null && currentPO.Status__c == 'DRAFTQUOTE' && currentPO.techColerCalled__c == false ){

                // check if the purchase order can be validated
                if (!hasErrors ){
                    // change the status to RESPONDED
                    // Taking only the id and the status to do the update
                    
                    system.debug('## currentPO :'+currentPO );
                    if(currentPO != null && currentPO.Distributor__r.OrderRequest__c == 'OrderR4' 
                        && currentPO.Distributor__r.DistributorConnected__c
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
                                // addErrorMessage(e, 'PurchaseOrder__c');
                            }
                        }
                        else if(wsRequest != null){
                            //RLA 01/01/2019 Case
                            //Boolean set to true if callout has been initiated
                            PurchaseOrder__c poUpdate = new PurchaseOrder__c(Id = PO.Id);
                            update poUpdate;
                            // @future : Exceptions: You have uncommitted work pending. Please commit or rollback before calling out        
	                        map <string,object> mapinputParameters = new map<String,Object>();
                            mapinputParameters.put('finalOrderReq', wsRequest+ '-OrderType : R4-');
                            mapinputParameters.put('setPOToUpdate', new set <id>{PO.Id});
                            mapinputParameters.put('sentOlIdSet', null);            
                            mapinputParameters.put('doAutovalidate', true);            
                            System.enqueueJob(new AP40CallDistributorQueueable(mapinputParameters));
                        
                        }                    
                    }
                    // else{
                    //     purchaseOrderToUpdate.Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
                    //     //RLA 10/01/2019 Case
                    //     //Update placement changed
                    //     try
                    //     {            
                    //         update purchaseOrderToUpdate;
                    //         //canRefresh = true;
                    //     }
                    //     catch (Exception e)
                    //     {
                    //         // addErrorMessage(e, 'PurchaseOrder__c');
                    //     }
                    // }           
                    //Commented by RLA 10/01/2019
                    //try
                    //{
                    //    system.debug('## update purchaseOrderToUpdate:'+purchaseOrderToUpdate);
            
                    //    update purchaseOrderToUpdate;
                    // canRefresh = true;
                    // system.debug('@@ canRefresh: ' +canRefresh);

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
                // canRefresh = true;
                // system.debug('@@ canRefresh: ' +canRefresh);
            }  
        }
        system.debug('## end validatePurchaseOrder');


        return mapOutputParams;  
    }

    public class CreateOrderInfo{
        String CallerSystem;
        List<Assessments> Assessments;
    }
    public class Parts {
		public Decimal Quantity;
		public String PartNumber;
		public String ID;
		public Boolean Order;
        public String PO;
        public String POLink;
        public String SO;
        public Boolean AgencyMode;
        public String Distributor;
        public String Message;

        public Parts(Offer__c off){
            this.Quantity = off != null && off.Quantity__c != null ? off.Quantity__c : 0;
            this.PartNumber =  off != null && off.PartNUmber__c != null && String.IsNotBlank(off.PartNUmber__c) ? off.PartNUmber__c : '';
            this.ID = off != null && off.OrderLine__c != null  && String.IsNotBlank(off.OrderLine__c) ? off.OrderLine__c : '';
            this.Order = off != null && String.isnotblank(off.Accepted__c) ?  off.Accepted__c == 'YES' ? true : false : false;
            this.PO = off != null && off.PurchaseOrder__c != null  && String.IsNotBlank(off.PurchaseOrder__c) ?  off.PurchaseOrder__c : '';
            this.POLink = off != null && String.isnotblank(off.OrderLine__r.PurchaseOrder__c) ? URL.getSalesforceBaseUrl().toExternalForm() + '/' + off.OrderLine__r.PurchaseOrder__c : '';
            this.SO = off != null && off.Prerequisiteorder__c != null  && String.IsNotBlank(off.Prerequisiteorder__r.Name) ?  off.Prerequisiteorder__r.Name : '';
            this.AgencyMode = off != null && off.AgencyMode__c != null ?  off.AgencyMode__c : false;
            this.Distributor = off != null && off.Distributor__c != null  && String.IsNotBlank(off.Distributor__c) ? off.Distributor__c : '';
            this.Message = '';

        }
	}

	public class Assessments {
		public String InsBrokerNumber;
		public String AssessmentID;
		public String BSReferenceNumber;
		public String BodyShopOrderReference;
		public String Comment;
		public List<Parts> Parts;
	}

    // public class PartsResponse {
	// 	public Decimal Quantity;
	// 	public String PartNumber;
	// 	public String ID;
	// 	public Boolean Order;
    //     public String PO;
    //     public String SO;
    //     public Boolean AgencyMode;
    //     public String Distributor;
    //     public String Message;

    //     public PartsResponse(Offer__c off){
    //         this.Quantity = off != null && off.Quantity__c != null ? off.Quantity__c : 0;
    //         this.PartNumber =  off != null && off.PartNUmber__c != null && String.IsNotBlank(off.PartNUmber__c) ? off.PartNUmber__c : '';
    //         this.ID = off != null && off.OrderLine__c != null  && String.IsNotBlank(off.OrderLine__c) ? off.OrderLine__c : '';
    //         this.Order = off != null && String.isnotblank(off.Accepted__c) ?  off.Accepted__c == 'YES' ? true : false : false;
    //         this.PO = off != null && off.PurchaseOrder__c != null  && String.IsNotBlank(off.PurchaseOrder__c) ?  off.PurchaseOrder__c : '';
    //         this.SO = off != null && off.Prerequisiteorder__c != null  && String.IsNotBlank(off.Prerequisiteorder__r.Name) ?  off.Prerequisiteorder__r.Name : '';
    //         this.AgencyMode = off != null && off.AgencyMode__c != null ?  off.AgencyMode__c : false;
    //         this.Distributor = off != null && off.Distributor__c != null  && String.IsNotBlank(off.Distributor__c) ? off.Distributor__c : '';
    //         this.Message = '';

    //     }


    // }



   
}