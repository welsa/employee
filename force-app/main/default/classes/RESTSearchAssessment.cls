@RestResource(urlMapping='/v1.0/searchAssessment/*') 
global without sharing class RESTSearchAssessment {
/*************************************************************************************
Class Name - RESTSearchAssessment
Version - 1.0
Created Date - 15 JUN 2020
Function - Class to order

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Ruksaar L   		15/06/2020  Original Version
*************************************************************************************/

    // map<error string, error string>
    static Map<String, String> mapErrorsCreation;        
    static Map<String, Account> mapDistIdDistAcc = new map <String, Account>();
    static Map<Id, Account> mapBodyshopIdName = new map <Id, Account>();
    public static boolean isFromSearchAssessment = false;
    private static List<Offer__c> offers = new List<Offer__c>();
    static Map<String, PartList__c> mapSubsIdOEM = new Map<string, PartList__c>();
    static SavePoint beforeDML;
    static String assessmentName;
    static String assessmentId;
    static Map<String, OrderLine__c> mapOrderLines = new map<String,OrderLine__c>();
    static Assessment__c claimAssDates;
    static string insuranceBroker;

    @HttpPost
    global static void searchAssessment()
    {
        System.debug('---------------------------------- START RESTSearchAssessment - searchAssessment ----------------------------------');
        system.debug('@@ Limits.getHeapSize() : '+Limits.getHeapSize() );
        datetime qryStart = datetime.now();
        // variables
        String jsonResponse= ''; 
        
        String body = RestContext.request.requestBody.toString();

        if(body != null && body != ''){
        
            jsonResponse = deserialiseResponse(body);

            APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
            wrapperLog.className = 'RESTSearchAssessment';
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

            if(jsonResponse.contains('Exceptions') || (jsonResponse.contains('Error') && !jsonResponse.contains('"ErrorMessage":null'))){
                wrapperLog.status = Label.STATUSFAILED;
            }
            else{
                wrapperLog.status = Label.STATUSPASSED;
            }  

            if(body.length() > 30000){
                wrapperLog.attachmentRequestbody = body;
            }

            if(jsonResponse.length() > 30000){
                wrapperLog.attachmentResponsebody = jsonResponse;
            }  
            datetime qryEnd = datetime.now();
            Decimal heapsize2 = Limits.getHeapSize() ;
            system.debug('@@@ heapsize End: '+heapsize2);

            decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
            tempExec = (tempExec.divide(1000, 5));


            wrapperLog.executionTime = tempExec;
            
            system.debug('@@@ qryEnd: '+qryEnd);
            system.debug('@@@ tempExec: '+tempExec);
            system.debug('@@ total'+ (qryEnd.getTime() - qryStart.getTime()) );

            //RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
            APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');

        }

        RestContext.response.responseBody = Blob.valueOf(jsonResponse);
        
        System.debug('---------------------------------- START RESTSearchAssessment - searchAssessment ----------------------------------');


    }
    
     public static String deserialiseResponse(String body)
    {
        System.debug('---------------------------------- START RESTSearchAssessment - deserialiseResponse ----------------------------------');

        SearchInfo wrapperinstance;
        Boolean isValid = false;
        mapErrorsCreation = new Map<String, String>();
        String response;

        try{

            wrapperinstance = (SearchInfo) JSON.deserialize(body, SearchInfo.class);
            system.debug('@@ wrapperinstance'+wrapperinstance); 

            if (wrapperinstance != null){
                isValid = checkMandatoryFields(wrapperinstance);
            } 

            if (isValid){
                response = queryAssessment(wrapperinstance);
            }
            else{
                if (mapErrorsCreation.containsKey('MandatoryFields')){
                    response = generateResponse(null, null, null, system.label.BsReferenceMissing) ;

                }
            }
        }
        catch(Exception e){
            
            system.debug('@@ am in catch'+beforeDML);
            if (beforeDML != null){
            system.debug('@@ am in rollback');

                Database.rollback(beforeDML); 
            }
            
            response = generateResponse(null, null, null, 'Exceptions: ' + e.getMessage() + '.  Stack Trace : ' + e.getStackTraceString()) ;


        }

            
        System.debug('---------------------------------- END RESTSearchAssessment - deserialiseResponse ----------------------------------');
        
         Decimal d = Limits.getLimitHeapSize();
        Decimal heapsize = Limits.getHeapSize() ;
        Decimal remaining = d-heapsize;


        return response;

        
    }

     public static Boolean checkMandatoryFields(SearchInfo SearchInfoInstance){
        System.debug('---------------------------------- START RESTSearchAssessment - checkMandatoryFields ----------------------------------');

        Boolean isValid = false;

        String missingFields  = checkFields(SearchInfoInstance);

        // check if missingFields is blank, asssessment is valid
        if(missingFields == ''){
            isValid = true;
        }
        else{
            isValid = false;
            mapErrorsCreation.put('MandatoryFields', 'Exceptions: Missing fields: '+ missingFields);
        }

        system.debug('@@@ isValid: '+isValid);
        System.debug('---------------------------------- END RESTSearchAssessment - checkMandatoryFields ----------------------------------');


        return isValid;
     }

    public static String checkFields(SearchInfo SearchInfoInstance){
        System.debug('---------------------------------- START RESTSearchAssessment - checkFields ----------------------------------');

        String missingFields = '';

        if (String.isBlank(SearchInfoInstance.BSReferenceNumber )){
            missingFields = 'BSReferenceNumber';
        }
        System.debug('---------------------------------- START RESTSearchAssessment - checkFields ----------------------------------');

        return missingFields;
    }

    public static string queryAssessment(SearchInfo searchInfoInstance){
        System.debug('---------------------------------- START RESTSearchAssessment - queryAssessment ----------------------------------');

        String queryCondition;
        Boolean canQuery = true;
        String response;
        
        Set<String> setDist = new set<String>();
        Set<String> setBodyshop = new set<String>();
        Map<String, String> mapDistIdName = new map <String, String>();
        Map<String, String> mapDistPrioConnected = new map <String, String>();
        String bsId = '';
     
        AccountRef__c accRef = AccountRef__c.getValues(searchInfoInstance.CallerSystem + '-' + SearchInfoInstance.BSReferenceNumber);

        system.debug('@@ accRef: '+ accRef);          
        if (accRef != null){
            bsId = accRef.InternalReference__c;

            if (String.isBlank(bsId)){                
                return response = generateResponse(null, null, null, system.label.NoBSFound) ;
            }
        }
        else{
            // system.debug('@@ accRef: '+ accRef);          

            return response = generateResponse(null, null, null, system.label.NoBSFound) ;

        }


        // query = 'Select Id,ClaimReference__c,InsBrokerNumber__c,AssessmentVersion__c,AssessmentID__c,LastUpdateDate__c,CreatedDate, '+
        // ' PlateNumber2__c,AssessmentExternalId__c,VINNumber__c,ModelV2__c,Manufacturer__c,FirstRegistrationDate__c, '+
        // ' CapturedDistributors__c, '+
        // ' (select Id, Name,Type__c,Quantity__c,PartNumber__c,ProducerName__c,Description__c,Status__c,Price__c,Discount__c,TECH_OrderedCounter__c, ' +
        // '  Distributors__c from PartsLists__r where SelectedByBS__c = true) from Assessment__c where ';

        if (String.isNotBlank(searchInfoInstance.InsBrokerNumber)){
            queryCondition = ' InsBrokerNumber__c = \'' + searchInfoInstance.InsBrokerNumber + '\'';    
        }
        else if (String.isNotBlank(searchInfoInstance.AssessmentID)){
            queryCondition = ' AssessmentID__c = \'' + searchInfoInstance.AssessmentID + '\'';    
        }
        else if (String.isNotBlank(searchInfoInstance.Plate)
                && String.isBlank(searchInfoInstance.VIN)){
            queryCondition = ' PlateNumber2__c = \'' + searchInfoInstance.Plate + '\'';    
        }
        else if (String.isBlank(searchInfoInstance.Plate)
                && String.isNotBlank(searchInfoInstance.VIN)){
            queryCondition = ' VINNumber__c = \'' + searchInfoInstance.VIN + '\'';    
        }
        else if (String.isNotBlank(searchInfoInstance.Plate)
                && String.isNotBlank(searchInfoInstance.VIN)){
            queryCondition = ' PlateNumber2__c = \'' + searchInfoInstance.Plate + '\' AND VINNumber__c =\'' + searchInfoInstance.VIN + '\' ';     
        }
        else{
            canQuery = false;
            response = generateResponse(null,null,null, 'No Assessment Found'); 
        }

        String query = 'SELECT Id,AlreadyQuoted__c,Status__c,isShoppingList__c, ParentAssessment__c, Name, BodyShop__c, Entity__c, AssessmentNumber__c, CreatedDate, LastModifiedDate,AssessmentExternalId__c,CapturedDistributors__c,InsBrokerNumber__c, ' +
        'SpecialAgreement__c, SpecialRenting__c, VINCheck__c, Fleet__c, TotalLoss__c, BuildDate__c, CrossReferences__c, AgencyDistributors__c, InsuranceBroker__c,' +
        ' AssessmentVersion__c,LastUpdateDate__c, substitutiontype__c, ' +
        'SupposedOfFraud__c, DateOfIncident__c, FirstRegistrationDate__c, EntityCode__c, ReasonFailure__c, Compensated__c, Feature__c, TechDistAndDirectOrder__c,' +
        'ModelV2__c, MissionNumber__c, ClaimReference__c, Manufacturer__c, EntityRules__c, ASReference__c, Bodyshop_is_Eligible_Non_AXA__c, ' +
        'PlateNumber2__c, TECH_EntityCountryCode__c, VINNumber__c, AssessmentID__c, BodyShop__r.Type, BodyShop__r.SepaValid__c, MREligibility__c, MRSourcing__c,OwnerId,Tech_DirectOrders__c, '+' OrderAuthorised__c,BodyShop__r.OrderFromAT__c , ' +  //RLA 16/08/2018 C-002690 Spain audatex assessments in r4 
        'BodyShop__r.AXA_Partner__c, '+//WCH 17/12/2019 C-003512
            '(SELECT Id, Name, VAT__c, Quantity__c, PartNumber__c, Price__c, Type__c, OriginalPart__c, Original__c, Description__c, NextDistributors__c,Status__c,Discount__c, ' +
            'SelectedByBS__c, CrossReferenceId__c, IsSourced__c, Assessment__c, TECH_OriginalPart__c,ProducerName__c,  '+
            'QuantityOrdered__c, CrossReferenceId__r.Name, TECH_OrderedCounter__c, Alpha_Scale_MRID__c, DistributorPriceId__c, Distributor__c, TECHDistList__c, ASNetPrice__c, StandardMargin__c, StandardDiscount__c, '+
                    ' DiscountRecord__c,DiscountRecord__r.Rebate__c, RecordTypeId,InputType__c '+//RLA 20/11/2018 C-002782 CJP A'
            'FROM PartsLists__r ' +
            'WHERE SelectedByBS__c = true ' +
            'AND isDeleted__c = false), ' +
        '(SELECT Id, Name , AssessmentNumber__c,Tech_DirectOrders__c '+
            'FROM Assessments__r ' +
            'WHERE RecordType.DeveloperName = \'ClaimOrder\' ' +
            'ORDER BY CreatedDate DESC) ' +
    'FROM Assessment__c ' +
    ' Where  RecordTypeId =\''+Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() +'\'  AND Bodyshop__c = \'' + bsId + '\' AND ' +
        queryCondition +
    ' ORDER BY LastModifiedDate DESC';

        
        system.debug('@@ query'+query);

        if (canQuery){
            list<Assessment__c> listAssessment = Database.query(query);
            Map<String, List<Assessment__c>> mapExtIdListAss = new map<String, List<Assessment__c>>();
            Map<String, Assessment__c> mapExtIdAss = new map<String, Assessment__c>();
            // Assessment assWrapper = new Assessment(listAssessment[0]);
            // response = JSON.serialize(assWrapper);
            for (Assessment__c ass: listAssessment){
                if (mapExtIdListAss.containsKey(ass.AssessmentExternalId__c)){
                    mapExtIdListAss.get(ass.AssessmentExternalId__c).add(ass);
                }
                else{
                    mapExtIdListAss.put(ass.AssessmentExternalId__c, new list<Assessment__c> {ass});
                }

                if (String.isNotBlank(ass.CapturedDistributors__c)){
                   map<String, String> tempMapDist = ASPISDirectSourcing.buildmapDistPrio(ass.CapturedDistributors__c);
                   setDist = new Set<String>(tempMapDist.values());
                   system.debug('@@ setdist'+ tempMapDist);

                }

                if (ass.BodyShop__c != null){
                    setBodyshop.add(ass.BodyShop__c);
                }
                system.debug('@@ ass.CapturedDistributors__c: '+ass.CapturedDistributors__c);
            }
            system.debug('@@ mapExtIdListAss: '+mapExtIdListAss);
            system.debug('@@ mapExtIdListAss: '+mapExtIdListAss);
           

            for (String extId: mapExtIdListAss.keyset()){
                for (Assessment__c ass: mapExtIdListAss.get(extId)){
                    if (mapExtIdAss.containsKey(extId)){
                        if (ass.AssessmentVersion__c > mapExtIdAss.get(extId).AssessmentVersion__c){
                            mapExtIdAss.put(extId, ass);
                        }

                    }
                    else{
                        mapExtIdAss.put(extId, ass);
                    }
                }
            }
            system.debug('@@ mapExtIdAss: '+mapExtIdAss);
            if (!mapExtIdAss.isEmpty()){

                    if (String.isBlank((mapExtIdAss.values()[0]).CapturedDistributors__c)){
                        return response = generateResponse(null,null,null ,'This caller system is not allowed to order');


                    }
                    else{
                        map <String, String> mapDistPrio = ASPISDirectSourcing.buildmapDistPrio((mapExtIdAss.values()[0]).CapturedDistributors__c);
                    
                        for (String priority: mapDistPrio.keyset()){
                            mapDistPrioConnected.put(mapDistPrio.get(priority), priority);
                        }  
                    }
            }

            For(Account acc: [select id, type,Name, Categories__c, PartTypeRegionDelayMatrix__c,DistributorConnected__c, Type_of_Substitutes__c,
                                  DistributorCarBrandSupplied__c,ConnectedEndtoEnd__c,ReferenceNumber__c,VATNumber__c,
                                  Tech_Distributor__c,Rebate__c, Tech_ATConfirmed__c, Tech_ATConfirmedWithDelay__c,
                                  Tech_ATPartial__c, Tech_ATNotFound__c, Tech_ATOther__c, IdforExpert__c, /*C-2602*/CarBrandsSuppliedAgency__c, EligibleVirtualA__c, /*C-003492*/AllowedBPartsStatusForDistConnected__c
                            
                             From Account Where id in :setDist or id in :setBodyshop]){
                if (setDist.contains(acc.Id) ){
                    mapDistIdName.put(acc.Id,acc.Name);
                //    if ( acc.DistributorConnected__c == true
                   if ( RestDistributorUtility.isConnectedDist(acc.Type_of_Substitutes__c)
                        && acc.ConnectedEndtoEnd__c == true){
                        mapDistIdDistAcc.put(acc.Id, acc);
                    }
                }

                if (setBodyshop.contains(acc.Id)){
                    mapBodyshopIdName.put(acc.Id, acc);
                }

                // if (mapDistPrioConnected.containsKey(acc.Id)){
                //     mapPrioTechDist.put(mapDistPrioConnected.get(acc.Id), acc.Tech_Distributor__c);    
                // }
            }
            system.debug('@@ mapDistIdName: '+mapDistIdName);

            set<String> setAllowedCallerSystems =  new Set<String>((system.label.AllowedIGCallerSystemOrder).split(';'));

            if (mapExtIdAss.isEmpty()){
                response = generateResponse(null,null, null,system.label.NoAssessFound);
            }
           else if (mapExtIdAss.size() == 1 && String.isNotBlank(searchInfoInstance.CallerSystem) && setAllowedCallerSystems.contains(searchInfoInstance.CallerSystem)){
                system.debug('We create ORder');
                List<Assessment__c> lstAssReturned = createClaimOrderAssessment(mapExtIdAss.values());

                if (lstAssReturned.size() > 0){
                    Map<String,List<Parts>> mapAssIdlstPartWrapper = new  Map<String,List<Parts>>();
                   


                    if (offers != null & offers.size() > 0){
                         List<Offer__c> lstOffers = [select Id, OrderLine__c, Type__c, Quantity__c, PartNUmber__c, Manufacturer__c,OrderLine__r.ExpectedDeliveryDuration__c,
                                                Description__c, OrderLine__r.SASStatus__c, BSTotalPrice__c, Discount__c,CataloguePrice__c ,
                                                ExpectedDeliveryDuration__c, Distributor__c,FinalType__c,OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c from Offer__c where Id in:offers ];

                        List<Parts> lstPartWrapper = new List<Parts>();
                        for (Offer__c off: lstOffers){
                            // system.debug('@@ off: '+off);
                            // system.debug('@@ off: '+off.OrderLine__c);
                            lstPartWrapper.add(new Parts(null,off));
                        }

                        mapAssIdlstPartWrapper.put(lstAssReturned[0].AssessmentExternalId__c,lstPartWrapper );
                    }
                    
                    system.debug('@@ mapAssIdlstPartWrapper'+mapAssIdlstPartWrapper);
                    claimAssDates = (mapExtIdAss.values())[0];

                    response = generateResponse(new map<String, Assessment__c> {lstAssReturned[0].AssessmentExternalId__c => lstAssReturned[0]},mapAssIdlstPartWrapper, mapDistIdName,'OK');
                }
                else{
                    response = generateResponse(null,null,null ,'Error in creating Order');

                }
                    

            }
            else{
                Map<String,List<Parts>> mapAssIdlstPartWrapper = new  Map<String,List<Parts>>();
                For (String extID: mapExtIdAss.keyset()){
                    system.debug('@@ extID'+extID);

                    Assessment__c assess = mapExtIdAss.get(extID);
                    system.debug('@@ assess'+assess);

                    string materialRt = Schema.SObjectType.PartList__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();

                    Boolean sendMaterialOnly = (String.isNotBlank(searchInfoInstance.CallerSystem) && setAllowedCallerSystems.contains(searchInfoInstance.CallerSystem)) ? true : false;

                    if (assess.partslists__r != null & assess.partslists__r.size() > 0){

                        List<Parts> lstPartWrapper = new List<Parts>();
                        for (partlist__c part: assess.partslists__r){

                            if (sendMaterialOnly){

                                if(part.RecordTypeId == materialRt){
                                    lstPartWrapper.add(new Parts(part,null));
                                }
                            }
                            else {
                                lstPartWrapper.add(new Parts(part,null));
                            }
                            
                        }

                        mapAssIdlstPartWrapper.put(extID,lstPartWrapper );
                    }
                }
                system.debug('@@ mapAssIdlstPartWrapper'+mapAssIdlstPartWrapper);
                
                response = generateResponse(mapExtIdAss,mapAssIdlstPartWrapper, mapDistIdName,'OK');
            }
            // system.debug('@@ assWrapper: '+assWrapper);
            // system.debug('@@ listAssessment[0]: '+listAssessment[0]);

            system.debug('@@ listAssessment'+listAssessment);
        }
        
        System.debug('---------------------------------- END RESTSearchAssessment - queryAssessment ----------------------------------');

        return response;
    }

    private static List<Assessment__c> createClaimOrderAssessment(List<Assessment__c> lstAsses){

        Assessment__c newClaimOrderAssessment = new Assessment__c();
        List<Assessment__Share> assShareExistList;
        Map<String,String> mapTypeDelay = new Map<String,String>();
        String partType, delayValue;
        List<String> matrixValues = new List<String>();
        list<Account> listDistributors = new list<Account>();
        List<PurchaseOrder__c> purchaseOrders = new List<PurchaseOrder__c>();
        //List of Orderlines to insert
        List<OrderLine__c> orderLines = new List<OrderLine__c>();
        //list of offers to insert
        // List<Offer__c> offers = new List<Offer__c>();

        set<String> DistributorIdSet = new set<String>();

        Map<Id, Partlist__c> mapPartlistToSend = new map <Id, Partlist__c> ();

        // Map<Id, Partlist__c> mapPartlistOEMToupdate = new map <Id, Partlist__c> ();





        // SavePoint beforeDML = Database.setSavepoint();

        
        
        // cloned IGP = claim IGP id
        // map original IGP ==> OEM

        // map<original igp extid, OEM partlist__c> map1
        // // map<original igp  salesforce id, original igp extid> map2
        

        // when cloning igps 
        // cloned IGP so original IGP exid, salesforce Id

        





        Assessment__c lockParentAssessment;
        List<PartList__c> lstPartlistToSend = new list<PartList__c>();
        Map<Assessment__c, List<PartList__c>> mapAssessmentPartlist = new map<Assessment__c, List<PartList__c>>();

        
        for (PartList__c part : [  SELECT  Assessment__r.TECH_EntityCountryCode__c,Assessment__r.InsuranceBroker__c,
                                            Assessment__r.CapturedDistributors__c, Assessment__r.TechDistAndDirectOrder__c,Assessment__r.Id, 
                                            id,CrossReferenceId__c,CrossReferenceId__r.Name,Name, VAT__c, Quantity__c, InputType__c,RecordTypeId,
                                            PartNumber__c, Price__c, Type__c, OriginalPart__c, Original__c, 
                                            Description__c,SelectedByBS__c,IsSourced__c, Assessment__c, 
                                            TECH_OriginalPart__c,ProducerName__c, QuantityOrdered__c, TECH_OrderedCounter__c, Alpha_Scale_MRID__c, 
                                            DistributorPriceId__c, Distributor__c, TECHDistList__c, StandardMargin__c, StandardDiscount__c,
                                            DiscountRecord__c,DiscountRecord__r.Rebate__c,
                                            OriginalPart__r.Id, OriginalPart__r.Quantity__c,OriginalPart__r.InputType__c,OriginalPart__r.RecordTypeId,OriginalPart__r.PartNumber__c,
                                            OriginalPart__r.Price__c,OriginalPart__r.Type__c,OriginalPart__r.Description__c,OriginalPart__r.Assessment__c,OriginalPart__r.ProducerName__c,
                                            OriginalPart__r.Alpha_Scale_MRID__c,OriginalPart__r.QuantityOrdered__c,OriginalPart__r.DistributorPriceId__c,OriginalPart__r.Distributor__c, 
                                            OriginalPart__r.TECH_OriginalPart__c, OriginalPart__r.CrossReferenceId__c, OriginalPart__r.Name, OriginalPart__r.VAT__c, OriginalPart__r.Original__c, 
                                            OriginalPart__r.SelectedByBS__c,  OriginalPart__r.IsSourced__c, OriginalPart__r.StandardMargin__c,techTypeOfSubsPartNumber__c,
                                            OriginalPart__r.StandardDiscount__c,OriginalPart__r.DiscountRecord__c
                                        from PartList__c
                                        WHERE isDeleted__c = false and SelectedByBS__c = true
                                              AND Assessment__c IN: lstAsses FOR UPDATE]){

            if (mapAssessmentPartlist.containskey(part.Assessment__r)){
                mapAssessmentPartlist.get(part.Assessment__r).add(part);

            }
            else{
                mapAssessmentPartlist.put(part.Assessment__r, new list<PartList__c> {part});
            }

            
            // lockParentAssessment = ass;
            // insuranceBroker = ass.InsuranceBroker__c;
            
            // if (lockParentAssessment.PartsLists__r.size() > 0){
            //     for (partlist__c part: lockParentAssessment.PartsLists__r){
                  
            //         lstPartlistToSend.add(part);
                    
            //         if (String.isnotBlank(part.Alpha_Scale_MRID__c)){
            //             mapSubsIdOEM.put(part.Id, new partlist__c(Id = part.OriginalPart__c,
            //                                                         Quantity__c = part.OriginalPart__r.Quantity__c,
            //                                                         //InputType__c = part.OriginalPart__r.InputType__c,
            //                                                         RecordTypeId = part.OriginalPart__r.RecordTypeId,
            //                                                         PartNumber__c = part.OriginalPart__r.PartNumber__c,
            //                                                         Price__c = part.OriginalPart__r.Price__c,
            //                                                         Type__c = part.OriginalPart__r.Type__c,
            //                                                         Description__c = part.OriginalPart__r.Description__c,
            //                                                         Assessment__c = part.OriginalPart__r.Assessment__c,
            //                                                         ProducerName__c = part.OriginalPart__r.ProducerName__c,
            //                                                         Alpha_Scale_MRID__c = part.OriginalPart__r.Alpha_Scale_MRID__c,
            //                                                         QuantityOrdered__c = part.OriginalPart__r.QuantityOrdered__c,
            //                                                         DistributorPriceId__c = part.OriginalPart__r.DistributorPriceId__c,
            //                                                         Distributor__c = part.OriginalPart__r.Distributor__c,
            //                                                         TECH_OriginalPart__c = part.OriginalPart__r.TECH_OriginalPart__c,
            //                                                         CrossReferenceId__c = part.OriginalPart__r.CrossReferenceId__c,
            //                                                         Name = part.OriginalPart__r.Name,
            //                                                         VAT__c = part.OriginalPart__r.VAT__c,
            //                                                         Original__c = part.OriginalPart__r.Original__c,
            //                                                         StandardDiscount__c = part.OriginalPart__r.StandardDiscount__c,
            //                                                         StandardMargin__c = part.OriginalPart__r.StandardMargin__c,
            //                                                         NextDistributors__c = null,
            //                                                         DiscountRecord__c = part.OriginalPart__r.DiscountRecord__c));
                        
            //         }
            //     }
            // }

        } 

        for (Assessment__c ass: mapAssessmentPartlist.keySet()){

             lockParentAssessment = ass;
            insuranceBroker = ass.InsuranceBroker__c;

            for (PartList__c part: mapAssessmentPartlist.get(ass)){

                lstPartlistToSend.add(part);
                    
                if (String.isnotBlank(part.Alpha_Scale_MRID__c)){
                        mapSubsIdOEM.put(part.Id, new partlist__c(Id = part.OriginalPart__c,
                                                                    Quantity__c = part.OriginalPart__r.Quantity__c,
                                                                    //InputType__c = part.OriginalPart__r.InputType__c,
                                                                    RecordTypeId = part.OriginalPart__r.RecordTypeId,
                                                                    PartNumber__c = part.OriginalPart__r.PartNumber__c,
                                                                    Price__c = part.OriginalPart__r.Price__c,
                                                                    Type__c = part.OriginalPart__r.Type__c,
                                                                    Description__c = part.OriginalPart__r.Description__c,
                                                                    Assessment__c = part.OriginalPart__r.Assessment__c,
                                                                    ProducerName__c = part.OriginalPart__r.ProducerName__c,
                                                                    Alpha_Scale_MRID__c = part.OriginalPart__r.Alpha_Scale_MRID__c,
                                                                    QuantityOrdered__c = part.OriginalPart__r.QuantityOrdered__c,
                                                                    DistributorPriceId__c = part.OriginalPart__r.DistributorPriceId__c,
                                                                    Distributor__c = part.OriginalPart__r.Distributor__c,
                                                                    TECH_OriginalPart__c = part.OriginalPart__r.TECH_OriginalPart__c,
                                                                    CrossReferenceId__c = part.OriginalPart__r.CrossReferenceId__c,
                                                                    Name = part.OriginalPart__r.Name,
                                                                    VAT__c = part.OriginalPart__r.VAT__c,
                                                                    Original__c = part.OriginalPart__r.Original__c,
                                                                    StandardDiscount__c = part.OriginalPart__r.StandardDiscount__c,
                                                                    StandardMargin__c = part.OriginalPart__r.StandardMargin__c,
                                                                    NextDistributors__c = null,
                                                                    DiscountRecord__c = part.OriginalPart__r.DiscountRecord__c));
                        
                }

            }

        }

        Assessment__c claimAssessment = lstAsses[0];
        system.debug('@@ lstPartlistToSend: '+lstPartlistToSend);   
        system.debug('@@ mapAssessmentPartlist: '+mapAssessmentPartlist);   
        system.debug('@@ mapSubsIdOEM: '+mapSubsIdOEM);   


        newClaimOrderAssessment = populateNewClaimOrderAssessment(claimAssessment,lstPartlistToSend, true); 

        List<PartList__c> partsToInsertList = copyPartsToClaimOrder(claimAssessment,lstPartlistToSend,newClaimOrderAssessment);
                
        system.debug('@@ partsToInsertList: '+partsToInsertList);   
      

        if (newClaimOrderAssessment != null){
            if(partsToInsertList.size() > 0)
            {
                // List<Database.upsertResult> uResultsparts = Database.upsert(partsToInsertList,partExtId ,false);

                // if (uResultsparts.isSuccess()){

                for (Partlist__c part: partsToInsertList){
                    mapPartlistToSend.put(part.OriginalPart__c,part);

                }

                // if ()
                
                string s = callConnectedDist (mapPartlistToSend,newClaimOrderAssessment);

                for (partlist__c part: [select id, Distributor__c, TECHDistList__c,TECH_OriginalPart__c from partlist__c where Id in :partsToInsertList ]){
                    // system.debug('@@@ part: '+part);
                    DistributorIdSet.add(part.TECHDistList__c);
                    if (mapOrderLines.containsKey(part.TECH_OriginalPart__c)){
                        // system.debug('@@ i contain');
                        OrderLine__c ol = mapOrderLines.get(part.TECH_OriginalPart__c);
                        mapOrderLines.put(part.Id, ol);
                        mapOrderLines.remove(part.TECH_OriginalPart__c);
                    }
                    
                    // System.debug('### newClaimOrderAssessment.MRSourcing__:'+newClaimOrderAssessment.MRSourcing__c);
                    // System.debug('### mapOrderLines:'+mapOrderLines);
                   
                }
                if (DistributorIdSet.size() > 0){
                    newClaimOrderAssessment.MRSourcing__c = DistributorIdSet.size() > 0 ? String.join(new List<String>(DistributorIdSet), ';') : newClaimOrderAssessment.MRSourcing__c;

                }

                // for (partlist__c partOem: lstPartlistToSend){
                //     if(partOem.TECH_OrderedCounter__c!=null){      
                //         Decimal counter = partOem.TECH_OrderedCounter__c +1 ;            
                //         mapPartlistOEMToupdate.put(partOem.Id, new partlist__c(Id = partOem.Id, TECH_OrderedCounter__c = counter,ordered__c = true ));
                //     }

                // }
                


                // }

                // ASPISWithoutSharingExceptions.insertPartLists(partsToInsertList);
            } 
            else{
                System.debug('### no delta partlist');
                // Rollback to prevent inconsistency of data
                // Database.rollback(beforeDML);  
                // return 'error';
            }
        }
        else{
            System.debug('### no delta partlist');
            // Rollback to prevent inconsistency of data
            // Database.rollback(beforeDML);  
            // return 'error';
        }

       

            // if (mapPartlistOEMToupdate.size() > 0){
            //     update mapPartlistOEMToupdate.values();
            // }
        // }
        // else
        // {
        //     Assessment__c assFailure = [SELECT  Id, toLabel(ReasonFailure__c)
        //                                 FROM    Assessment__c
        //                                 WHERE   Id =: newClaimOrderAssessment.Id];
        //     // Database.rollback(beforeDML);
        //     return null;
        // }        

        return new list<Assessment__c> {newClaimOrderAssessment};
    }

    private static string callConnectedDist(map<Id,Partlist__c> mapPartlists, Assessment__c claimOrderAssessment){

        System.debug('---------------------------------- START RESTSearchAssessment - callConnectedDist ----------------------------------');


        List<PartList__c> lstPartListforCallout = new List<PartList__c>();
       
        String request = '';

        

        // String request = RestDistributorUtility.buildDistributorRequestV3(claimOrderAssessment,mapDistIdDistAcc.values(),lstPartListforCallout,paramsCallout);
        
        if (mapDistIdDistAcc.size() > 0){
            isFromSearchAssessment = true;
            
            request = RestDistributorUtility.initialiseWSCallOut(claimOrderAssessment, mapDistIdDistAcc.values(),mapPartlists, false, true, new map <string,PurchaseOrder__c>(),'RESTSearchAssessment');

            isFromSearchAssessment = false;

        }
        else{
            request = processResponseParts(claimOrderAssessment,mapPartlists, '' );
        }
        System.debug('---------------------------------- END RESTSearchAssessment - callConnectedDist ----------------------------------');


        return request;

    }

    private static Assessment__c populateNewClaimOrderAssessment(Assessment__c claimAssessment,list <PartList__c> associatedPL, Boolean isOrder)
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

        
        currentClaimOrder.BodyShop__c = claimAssessment.BodyShop__c;
        

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
        String assessmentNumberSuffix           = OrderChooseAssessment.getAssessmentNumberSuffix(claimAssessment);
        currentClaimOrder.AssessmentNumber__c   = claimAssessment.AssessmentNumber__c.left(78) + '-' + assessmentNumberSuffix;
        currentClaimOrder.AssessmentID__c       = claimAssessment.AssessmentID__c.left(78) + '-' + assessmentNumberSuffix;
        //RLA 03/07/2019 C-003171: Flag Orders generated from Assessment Tool
        currentClaimOrder.CreatedByAssessmentTool__c = false;
        /*******************
        **************/
        //AMI 26/06/18 : Community Rollout 
        //             : Updating owner if connected user have a community license        
        // if(string.isNotBlank(formattedLicenseName) && formattedLicenseName.contains(connectedUserLicenseName)){
        //      currentClaimOrder.OwnerId = claimAssessment.OwnerId;
        // }else{
        //     currentClaimOrder.OwnerId = connectedUsrId;
        // }
        
        return currentClaimOrder;
    }

    private static List<PartList__c> copyPartsToClaimOrder(Assessment__c claimAssessment,list <PartList__c> associatedPL, Assessment__c claimOrderAssessment)
    {
        List<PartList__c> newPartList = new List<PartList__c>();
        List<PartList__c> lstPartListforCallout = new List<PartList__c>();
        map <string,object> paramsCallout = new map<String,object>();
        set<String> setCrossReferenceId = new set<String>();
        map <string, PartList__c> mapTechOriginalPartKeyCorrespondingPart = new map <string, PartList__c>();
        map <string, string> mapTechOriginalPartKeyCorrespondingAssId = new map <string, string>();


        // Loop in the parts of the claim Assessment
        //AMI 17/12/2018 : Invalid Query Locator
        //               : Loop in param instead of initial query
        for(PartList__c currentPart : associatedPL)
        {
            //system.debug('## current part ' + currentPart);
            PartList__c clonedPart = currentPart.clone(false, true);
            clonedPart.Assessment__c = claimOrderAssessment.Id;
            clonedPart.OriginalPart__c = currentPart.Id;
            clonedPart.TECH_OrderedCounter__c = 0;
            clonedPart.TECH_OriginalPart__c = currentPart.TECH_OriginalPart__c + '-' + claimOrderAssessment.Id + '-' + claimOrderAssessment.AssessmentID__c.substringAfterLast('-');

            newPartList.add(clonedPart);

            // if(clonedPart.CrossReferenceId__c != null){
            //     setCrossReferenceId.add(clonedPart.CrossReferenceId__c);
            // }
            // mapTechOriginalPartKeyCorrespondingPart.put(clonedPart.TECH_OriginalPart__c,clonedPart);

            // if (currentPart.OriginalPart__c == null){
            //     mapTechOriginalPartKeyCorrespondingAssId.put(currentPart.TECH_OriginalPart__c,claimAssessment.AssessmentID__c);
            // }

            // if (String.isnotBlank(currentPart.Alpha_Scale_MRID__c) && currentPart.Alpha_Scale_MRID__c.startsWith(system.label.desubstitureprefix)){
            //     lstPartListforCallout.add(new partlist__c(id=currentPart.OriginalPart__r.Id,
            //                                               Quantity__c = currentPart.OriginalPart__r.Quantity__c,
            //                                               InputType__c = currentPart.OriginalPart__r.InputType__c,
            //                                               RecordTypeId = currentPart.OriginalPart__r.RecordTypeId,
            //                                               PartNumber__c = currentPart.OriginalPart__r.PartNumber__c,
            //                                               Price__c = currentPart.OriginalPart__r.Price__c,
            //                                               Type__c = currentPart.OriginalPart__r.Type__c,
            //                                               Description__c = currentPart.OriginalPart__r.Description__c,
            //                                               Assessment__c = currentPart.OriginalPart__r.Assessment__c,
            //                                               ProducerName__c = currentPart.OriginalPart__r.ProducerName__c,
            //                                               TECH_OriginalPart__c = currentPart.OriginalPart__r.TECH_OriginalPart__c
                                                          
            //                                               ));    
            // }
            // else{
            //     lstPartListforCallout.add(currentPart);
            // }
        }

        

        // Boolean isExpert = false;
        // if (mapBodyshopIdName.containsKey(claimOrderAssessment.BodyShop__c)){
        //     if (mapBodyshopIdName.get(claimOrderAssessment.BodyShop__c).type == 'Expert'){
        //         isExpert = true;   
        //     }

        // }  

        // paramsCallout.put('setCrossReferenceId',setCrossReferenceId);
        // paramsCallout.put('isExpert',isExpert);
        // paramsCallout.put('bsRefAccountMap',mapBodyshopIdName);
        // paramsCallout.put('isIG',system.label.InsBrokerName.contains(claimOrderAssessment.InsuranceBroker__c) ? true: false);
        // paramsCallout.put('isORder',true);
        // // paramsCallout.put('mapTechOriginalPartKeyCorrespondingPart',mapTechOriginalPartKeyCorrespondingPart);
        

        // String request = RestDistributorUtility.buildDistributorRequestV3(claimOrderAssessment,mapDistIdDistAcc.values(),lstPartListforCallout,paramsCallout);

        // system.debug('@@ request: '+ request);
        // RESTUpsertAssessmentV2.updatedPartsFromDistCallOut returnWrap;


        // if(string.isNotBlank(request)){
        //     paramsCallout = new map<String, object>();
        //     map <string,Account> mapEligiblePONameELigiblePO = new map<String,Account>();
        //     for (Account acc: mapDistIdDistAcc.values()){
        //         if(string.isNotBlank(acc.Tech_Distributor__c)){
        //             mapEligiblePONameELigiblePO.put(acc.Tech_Distributor__c,acc);
        //         }

        //     }
        //     paramsCallout.put('mapEligiblePONameELigiblePO',mapEligiblePONameELigiblePO);
                
        //         returnWrap = RestDistributorUtility.launchCallOut(request,mapTechOriginalPartKeyCorrespondingPart,mapTechOriginalPartKeyCorrespondingAssId, mapPrioTechDist,paramsCallout);
        //     }
 
        return newPartList;
    }

   public static string processResponseParts(Assessment__c assRecord, map<Id, PartList__c> partMap, string receivedResponse){

        system.debug('@@ Not to deploy on Prod - receivedResponse - ***: '+receivedResponse);
        String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);
        // String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);


        //build map distributor name distributor wrapper
        map <string,RestDistributorUtility.dist> deserialiseDist;
        map <string,list<RestDistributorUtility.Lines>> mapAllowedLinesPerDist = new map <string,list<RestDistributorUtility.Lines>>();

        //map of priority and their TechDist 
        map <String, String> mapPrioTechDist = new map<String, String>();
        map <String, String> mapPrioTechDistNotConnected = new map<String, String>();

        //map of distID and its priority
        map<String, String> mapDistPrioConnected = new map <String, String>();

        //set of all connected distributors
        Set<String> setDist;

        //map of dist and lines which are allowed per priority
        map <string,list<RestDistributorUtility.Lines>> mapAllowedLinesPerPrio = new map <string,list<RestDistributorUtility.Lines>>();

        map <string,Account> mapEligiblePONameELigiblePO = new map<String,Account>();

        map<String, PartList__c> partMapToUpdate = new map<String, PartList__c> ();

        //if this is true take ID from callout response
        Boolean isSimulation = false;

        //partmap for simulation
        map<string, PartList__c> partMapSimulation = new map<string, PartList__c> ();

        //the distributor with the least priority
        string distNameLeastPrio = null;

        map<string, PartList__c> mapTechOriPart = new map<string,partlist__c>();


        //set of all connected distributors
        Set<String> setDistMrSourcing = new set<String>();

        beforeDML = Database.setSavepoint();

        Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;

        Schema.SObjectField partExtId = partlist__c.Fields.TECH_OriginalPart__c;

        List<String> lstPrios = new List<String>();

        map<String, String> tempMapDist = new map<String, String> ();

        Map<String, Map<String,String>> mapDistPartTypeDelay = new map<String, Map<String,String>>();

         list<Account> listDistributors = new list<Account>();
        List<PurchaseOrder__c> purchaseOrders = new List<PurchaseOrder__c>();
        //List of Orderlines to insert
        Map<String, OrderLine__c> MapOrderLines = new Map<String,OrderLine__c>();

        map <Id, PartList__c> partMapPo   = new map <Id, PartList__c>();
        map <string,PurchaseOrder__c> mapPOExtIDPO  = new map <string,PurchaseOrder__c>();
        map <string,Account> mapDistributorNameDistributor = new map <string,Account>();  

        //map of old key partlist and new key
        map<string,String> mapOldKeyNewKeyPart = new map<String,String>();
        //map of old key partlist and partlist Id
        map<string,String> mapOldKeyIdPart = new map<String,String>();

        if (partMap != null){
            for (partlist__c part: partMap.values()){
                mapTechOriPart.put(part.TECH_OriginalPart__c, part);
            }
        }

        if (system.label.responseCalloutDistOrder != 'none' && system.label.responseCalloutDistOrder.StartsWith('a0D')){
            Log__c logResponse = [Select id,WSResponse__c from Log__c Where Id = :system.label.responseCalloutDistOrder];
            receivedResponse = logResponse.WSResponse__c;
            isSimulation = true;
        }
        system.debug('@@ Not to be deployed on Prod -receivedResponse: ****'+receivedResponse);
        system.debug('@@ assRecord: '+assRecord);
        // system.debug('@@ assRecord.CapturedDistributors__c: '+assRecord.CapturedDistributors__c);

        
       
        if (assRecord != null && String.isNotBlank(assRecord.CapturedDistributors__c)){
            string distToSend = String.isNotBlank(assRecord.CapturedDistributors__c) ? assRecord.CapturedDistributors__c : '';
            tempMapDist = ASPISDirectSourcing.buildmapDistPrio(distToSend);
                system.debug('@@@ tempMapDist'+tempMapDist);
            

            setDist = new Set<String>(tempMapDist.values());

            for (String distDo: tempMapDist.keyset()){
                system.debug('@@@ distDo'+distDo);

                // String prio = (distDo.split('-'))[0];
                // system.debug('@@@ dist'+dist);
                String dist = tempMapDist.get(distDo);
                // system.debug('@@@ priority'+priority);

                // map containing the distributor Id and its priority
                mapDistPrioConnected.put(dist, distDo);
                // system.debug('@@@ priority: '+priority);
            
            }
        }
            system.debug('@@ mapDistPrioConnected: '+mapDistPrioConnected);
            system.debug('@@ setDist: '+setDist);

        if (partMap != null){
            for (String partId: partMap.keyset()){
                
                string partNumber = partMap.get(partId).PartNumber__c;

                // string key = (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: (partNumber.startsWith(system.label.DEsubstiturePrefix)) ? partNumber.split(system.label.DEsubstiturePrefix)[1] : partNumber;

                //RLA 09/07/2020 C-003857: IG - Creation IGO 
                string key = RestDistributorUtility.getOemPartNumber (partNumber , InsuranceBroker,prefixPartNumberIGO);


                //// string key =  partMap.get(partId).PartNumber__c;

                partMapSimulation.put(key,partmap.get(partId));

            }
        }

            system.debug('@@ partMapSimulation: '+partMapSimulation);

        For(Account acc: [select id, type,Name, Categories__c, PartTypeRegionDelayMatrix__c,DistributorConnected__c, Type_of_Substitutes__c,
                            DistributorCarBrandSupplied__c,ConnectedEndtoEnd__c,ReferenceNumber__c,VATNumber__c,
                            Tech_Distributor__c,Rebate__c, Tech_ATConfirmed__c, Tech_ATConfirmedWithDelay__c,OrderRequest__c,
                            Tech_ATPartial__c, Tech_ATNotFound__c, Tech_ATOther__c, IdforExpert__c, /*C-2602*/CarBrandsSuppliedAgency__c, EligibleVirtualA__c, /*C-003492*/AllowedBPartsStatusForDistConnected__c
                    
                            From Account Where id in :setDist]){

            if (mapDistPrioConnected.containsKey(acc.Id)){
                system.debug('@@ here : '+acc);
                // if(acc.DistributorConnected__c == true
                if ( RestDistributorUtility.isConnectedDist(acc.Type_of_Substitutes__c)
                && acc.ConnectedEndtoEnd__c == true){
                    mapPrioTechDist.put(mapDistPrioConnected.get(acc.Id), acc.Tech_Distributor__c);    
                }
                
                mapPrioTechDistNotConnected.put(mapDistPrioConnected.get(acc.Id), acc.Tech_Distributor__c); 
                
            }

            if(string.isNotBlank(acc.Tech_Distributor__c)){
                mapEligiblePONameELigiblePO.put(acc.Tech_Distributor__c,acc);
            }

            if (acc.PartTypeRegionDelayMatrix__c != null){
                Map<String,String> mapTypeDelay = ASPISCreatePOOrderLines.getTypeDelayMap(acc.PartTypeRegionDelayMatrix__c);  
                mapDistPartTypeDelay.put(acc.Tech_Distributor__c,mapTypeDelay); 

            }
            
            
        }
            system.debug('@@ mapDistPartTypeDelay: '+mapDistPartTypeDelay);
            system.debug('@@ mapPrioTechDist: '+mapPrioTechDist);
            system.debug('@@ mapPrioTechDistNotConnected: '+mapPrioTechDistNotConnected);
            system.debug('@@ mapDistPrioConnected: '+mapDistPrioConnected);
        
        if (!mapPrioTechDistNotConnected.isEmpty()){
             if (!tempMapDist.isEmpty()){
                lstPrios.addAll(tempMapDist.Keyset());
                lstPrios.sort();
            }

            for (String priority : lstPrios){
                system.debug('@@ priority: '+priority);
                string dist = mapPrioTechDistNotConnected.get(priority);
                system.debug('@@ priority: '+dist);
                
                if (String.isBlank(distNameLeastPrio)){
                    distNameLeastPrio = dist;
                }
            }
            system.debug('@@ lstPrios: '+lstPrios);
            system.debug('@@ distNameLeastPrio: '+distNameLeastPrio);

        }

        // if (!mapPrioTechDist.isEmpty()){
        //     lstPrios.addAll(mapPrioTechDist.Keyset());
        //     lstPrios.sort();

        // }
        // system.debug('@@ lstPrios: '+lstPrios);

         if(string.isNotBlank(receivedResponse)){
            //  distNameLeastPrio = '';
        
            //deserialise to get lines info
            deserialiseDist  = RestDistributorUtility.deserialiseRespIntoDistributors(receivedResponse);
            system.debug('@@ deserialiseDist: '+deserialiseDist);

            if (deserialiseDist != null){


                for (string distName: deserialiseDist.keyset()){

                    // system.debug('@@ distName: '+ distName);
                    // system.debug('@@ deserialiseDist: '+ deserialiseDist.get(distName));
                    String isSuccess = deserialiseDist.get(distName).Success;
                    if(isSuccess != 'true'){
                        
                    }
                    else{
                        if(deserialiseDist.get(distName).Lines != null){

                            for (RestDistributorUtility.Lines ln: deserialiseDist.get(distName).Lines){
                                
                                if((ln.StatusMessage == null || string.isBlank(ln.StatusMessage)) && string.isNotBlank(ln.PartNumber)){
                                    if((ln.Status == 'CONFIRMED' || 
                                        ln.Status == 'CONFIRMEDWITHDELAY')){
                                        if (mapAllowedLinesPerDist.containsKey(distname)){
                                            mapAllowedLinesPerDist.get(distname).add(ln);

                                        }
                                        else{
                                            mapAllowedLinesPerDist.put(distName, new list<RestDistributorUtility.Lines> {ln});
                                        }
                                    }
                                }
                            }
                        }
                    }
                }//end for Loop in all lines
                system.debug('@@ mapAllowedLinesPerDist: '+mapAllowedLinesPerDist);
                system.debug('@@ mapPrioTechDist: '+mapPrioTechDist);

                set<String> setLinesProcess = new set<String>();
                // if (!mapPrioTechDist.isEmpty()){
                //     lstPrios.addAll(mapPrioTechDist.Keyset());
                //     lstPrios.sort();

                // }
                // system.debug('@@ lstPrios: '+lstPrios);
                

                for (String priority : lstPrios){
                    string dist = mapPrioTechDist.get(priority);                    
                    if (String.isBlank(distNameLeastPrio)){
                        distNameLeastPrio = dist;
                    }

                    if (mapAllowedLinesPerDist.containsKey(dist)){

                        for (RestDistributorUtility.Lines tempLine: mapAllowedLinesPerDist.get(dist)){

                            // system.debug('@@ dist: '+dist);
                            // system.debug('@@ priority: '+priority);
                            // if (mapTechOriginalKeyOriginalPartNoDist.containskey(tempLine.ID)){
                            //     system.debug('@@ removing this line'+tempLine.ID);
                            //     mapTechOriginalKeyOriginalPartNoDist.remove(tempLine.ID);

                            // }

                            if (mapAllowedLinesPerPrio.containsKey(dist)){
                                if (!setLinesProcess.contains(tempLine.Id)){
                                    mapAllowedLinesPerPrio.get(dist).add(tempLine);
                                    setLinesProcess.add(tempLine.Id);
                                    system.debug('got in another time');
                                }

                            }
                            else{
                                if (!setLinesProcess.contains(tempLine.Id)){
                                    mapAllowedLinesPerPrio.put(dist, new list<RestDistributorUtility.Lines> {tempLine});
                                    setLinesProcess.add(tempLine.Id);
                                    system.debug('got in first time');
                                }
                            }

                        }
                    }

                }//endfor list priorities

                system.debug('@@ mapAllowedLinesPerPrio: '+mapAllowedLinesPerPrio);
                system.debug('@@ partMap: '+partMap);
                //RLA 09/07/2020 C-003857: IG - Creation IGO 
                // String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);
               

                for(string distName : mapAllowedLinesPerPrio.keySet()){
                    system.debug('@@ distName: '+distName);
                    Map<string, String> mapTypeDelay = new map<String,String>();
                    if (mapDistPartTypeDelay.containsKey(distname)){
                        mapTypeDelay = mapDistPartTypeDelay.get(distName);

                    }
                    Decimal Rebate = 0.0;
                    if (mapEligiblePONameELigiblePO.containsKey(distName)){
                        Rebate = mapEligiblePONameELigiblePO.get(distName).Rebate__C != null ? ( mapEligiblePONameELigiblePO.get(distName).Rebate__C / 100) : 0.0;

                    } 
                    system.debug('@@ mapTypeDelay: '+mapTypeDelay);

                    for(RestDistributorUtility.Lines ln : mapAllowedLinesPerPrio.get(distName)){
                        //string receivedStatus = (ln.Status == 'CONFIRMED') ? 'Available' : ((ln.Status == 'CONFIRMEDWITHDELAY ') ? 'In order' : 'Unavailable');
                        string receivedStatus = '';
                        System.debug('@@ ln'+ln.ID);
                        System.debug('@@ ln'+ln);
                        //RLA 23/03/19 Case-2408 upsertAssessment - Stock availability manageable at Account level
                        if (mapEligiblePONameELigiblePO.containsKey(distName)){

                            if (ln.Status == 'CONFIRMED'
                                && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmed__c))
                            {
                                receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmed__c;
                            } 
                            else if (ln.Status == 'CONFIRMEDWITHDELAY'
                                    && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmedWithDelay__c))
                            {
                                receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATConfirmedWithDelay__c;
                            } 
                            else if (ln.Status == 'PARTIAL'
                                    && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATPartial__c))
                            {
                                receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATPartial__c;
                            } 
                            else if (ln.Status == 'NOTFOUND'
                                    && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATNotFound__c))
                            {
                                receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATNotFound__c;
                            } 
                            else if (ln.Status == 'OTHER'
                                    && String.isNotBlank(mapEligiblePONameELigiblePO.get(distName).Tech_ATOther__c))
                            {
                                receivedStatus = mapEligiblePONameELigiblePO.get(distName).Tech_ATOther__c;
                            } 
                        }

                        decimal discountToUse = (mapEligiblePONameELigiblePO.containsKey(distName) && mapEligiblePONameELigiblePO.get(distName).Rebate__c != null) ? 
                                    (mapEligiblePONameELigiblePO.get(distName).Rebate__c) /100 : 0.0;

                        decimal asPublicPrice = 0.0,ASNETPRICE = 0.0;
                        decimal OEMPrice = 0.0,OEMASNETPRICE = 0.0;

                        //AMI 12/02/2018 - C-002041 - Distributor V2 - Update std discount and margin during A' Creation
                        decimal oemStdDiscount = 0.0, oemStdMargin = 0.0;

                        //ASE: 28/05/2018-C-002041 changes in calculations
                        decimal aspStdDiscount = 0.0, aspStdMargin = 0.0;

                        //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
                        //                        - calculate discount to apply (either as additional discount or rebate)
                        //                        
                        decimal discount = ln.AlphaScaleDiscountAdditional > 0 ? (ln.AlphaScaleDiscountAdditional/100) : (discountToUse > 0 ? discountToUse : 0.0);

                        //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                        //                                         - this map will be used to pass param to calculate price values
                        map <string,object> inputParamForPriceCalc = new map <string,object>();

                        //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                        //                                         - this map will be used get updated price values
                        map <string,object> updatedPricing = new map <string,object>();

                        //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                        //                                         - populate inputParamForPriceCalc
                        inputParamForPriceCalc.put('entity','fr');                                         
                        // ASE: 07/05/18 : C-002528
                        //inputParamForPriceCalc.put('discount',discount);
                        inputParamForPriceCalc.put('discount', discountToUse);
                        
                        inputParamForPriceCalc.put('CatalogPrice',ln.CatalogPrice);
                        inputParamForPriceCalc.put('AlphaScaleDiscount',ln.AlphaScaleDiscount);

                        //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
                        inputParamForPriceCalc.put('isIG', true);


                       

                        if (mapTechOriPart.containsKey(ln.ID)){
                            partlist__c tempPartList = mapTechOriPart.get(ln.ID);
                            system.debug('@@@ tempPartList: '+tempPartList);

                            if(ln.CatalogPrice > 0){ 
                                //AMI 25/01/18 : C-002041 - Distributor V2 - Do not update price on original during A' Creation
                                /*
                                OEMPrice = ln.CatalogPrice - (ln.CatalogPrice * (ln.BodyShopDiscount/100));
                                OEMASNETPRICE = (ln.CatalogPrice * (ln.BodyShopDiscount/100));*/
                                
                                //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                                //                                         - get updated values
                                if(String.isnotBlank(tempPartList.Alpha_Scale_MRID__c) && tempPartList.Alpha_Scale_MRID__c.startswith(prefixPartNumberIGO) ){
                                    updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPricesOEMConnected(inputParamForPriceCalc);

                                }
                                else {
                                    updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPrices(inputParamForPriceCalc);
                                }
                                

                                ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;
                                asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;
                                oemStdDiscount = updatedPricing.containsKey('oemStdDiscount') ? (decimal)updatedPricing.get('oemStdDiscount') : 0.0;
                                oemStdMargin = updatedPricing.containsKey('oemStdMargin') ? (decimal)updatedPricing.get('oemStdMargin') : 0.0;
                                aspStdDiscount = updatedPricing.containsKey('aspStdDiscount') ? (decimal)updatedPricing.get('aspStdDiscount') : 0.0;
                                aspStdMargin = updatedPricing.containsKey('aspStdMargin') ? (decimal)updatedPricing.get('aspStdMargin') : 0.0;

                                
                            }
                            
                            // tempPartList.PartNumber__c = ln.PartNumber;


                            if (tempPartList.Alpha_Scale_MRID__c != null){

                                

                                // tempPartList.ASNetPrice__c = ASNETPRICE.setScale(2);
                                tempPartList.ASNetPrice__c = ASNETPRICE;
                                tempPartList.Price__c = asPublicPrice;
                                tempPartList.StandardDiscount__c = aspStdDiscount;
                                tempPartList.StandardMargin__c = aspStdMargin;
                                
                                tempPartList.Distributor__c= mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null;    
                           
                            }
                            else{
                                tempPartList.Price__c = ln.CatalogPrice;
                                tempPartList.StandardDiscount__c = oemStdDiscount;
					            tempPartList.StandardMargin__c = oemStdMargin;
                                //RLA 13/10/2020 New IG changes
                                tempPartList.PartNumber__c = ln.PartNumber;
                                tempPartList.Description__c = ln.Description;
                            }
                            tempPartList.Distributors__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null; 

                            tempPartList.TECHDistList__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null;
                             tempPartList.Stock__c = receivedStatus;
                            partMapToUpdate.put(ln.ID, tempPartList);
                            setDistMrSourcing.add(tempPartList.TECHDistList__c);

                        } 
                    }
                }//endofr looping in allowed lines for each dist
            }
        }//endfor response not null
        
        

            system.debug('@@ setDistMrSourcing: '+setDistMrSourcing);
            system.debug('@@ partMapToUpdate: '+partMapToUpdate);
            system.debug('@@ mapTechOriPart: '+mapTechOriPart);
            system.debug('@@ distNameLeastPrio: '+distNameLeastPrio);
            system.debug('@@ mapEligiblePONameELigiblePO: '+mapEligiblePONameELigiblePO);
            system.debug('@@ mapSubsIdOEM: '+mapSubsIdOEM);
            system.debug('@@ mapOrderLines: '+mapOrderLines);

            for (String partId: mapTechOriPart.keySet()){
                if (!partMapToUpdate.containsKey(partId)){
                     partlist__c tempPartList; 
                    //  system.debug('@@ got in: '+mapTechOriPart.get(partId).Alpha_Scale_MRID__c);
                    //  system.debug('@@ got in: '+mapTechOriPart.get(partId).OriginalPart__c); 

                    

                    if (mapTechOriPart.get(partId).OriginalPart__c != null
                        && mapTechOriPart.get(partId).Alpha_Scale_MRID__c != null
                        && mapSubsIdOEM.containsKey(mapTechOriPart.get(partId).OriginalPart__c) ){
                        // system.debug('@@ we are cloning oem: ');
                        partlist__c oem = mapSubsIdOEM.get(mapTechOriPart.get(partId).OriginalPart__c) ;

                        tempPartList = oem.clone(false, true);
                        tempPartList.Assessment__c = assRecord.Id;
                        tempPartList.OriginalPart__c = oem.Id;
                        tempPartList.SelectedByBS__c = true;
                        tempPartList.TECH_OrderedCounter__c = 0;
                        tempPartList.TECH_OriginalPart__c = oem.TECH_OriginalPart__c + '-' + assRecord.Id + '-' + assRecord.AssessmentID__c.substringAfterLast('-');

                    }
                    else{
                        // system.debug('@@ we are using same part: ');

                        tempPartList = mapTechOriPart.get(partId);
                    }

                    
                    if (tempPartList.RecordTypeId != Schema.SObjectType.partlist__c.getRecordTypeInfosByName().get('Labour').getRecordTypeId()){

                        tempPartList.Distributor__c= mapEligiblePONameELigiblePO.containsKey(distNameLeastPrio) ? mapEligiblePONameELigiblePO.get(distNameLeastPrio).Id : null;
                        tempPartList.TECHDistList__c = mapEligiblePONameELigiblePO.containsKey(distNameLeastPrio) ? mapEligiblePONameELigiblePO.get(distNameLeastPrio).Id : null;
                        tempPartList.Distributors__c = mapEligiblePONameELigiblePO.containsKey(distNameLeastPrio) ? mapEligiblePONameELigiblePO.get(distNameLeastPrio).Id : null; 
                        setDistMrSourcing.add(tempPartList.TECHDistList__c);

                    }
                    partMapToUpdate.put(partId, tempPartList);
                    
                    // system.debug('@@ Partnumber: '+tempPartList.PartNUmber__c + '- ' + tempPartList.Distributor__c);


                }
            }

            system.debug('@@ partMapToUpdate: '+partMapToUpdate);

            if (partMapToUpdate.size() > 0){

                if (setDistMrSourcing.size() > 0){
                    assRecord.MRSourcing__c = string.join(new List<String>(setDistMrSourcing),';');

                }

                
                // insert assRecord;

                Database.upsertResult uResultsAss = Database.upsert(assRecord,assessExtId ,false);
                assessmentName = assRecord.AssessmentID__c;
                assessmentId = assRecord.Id;
                Boolean isAllSuccess = true;
                set<String> DistributorIdSet = new set<String>();

                if (uResultsAss.isSuccess()){

                    for (String partId : partMapToUpdate.keyset()){

                        string key = (partMapToUpdate.get(partId).TECH_OriginalPart__c).substringbeforeLast('-null') + '-' + assRecord.Id + '-' + assRecord.AssessmentID__c.substringAfterLast('-');

                        // system.debug('@@ key: '+key);
                       
                        mapOldKeyNewKeyPart.put(key,partMapToUpdate.get(partId).TECH_OriginalPart__c);

                        
                        partMapToUpdate.get(partId).TECH_OriginalPart__c = key;
                        partMapToUpdate.get(partId).Assessment__c = assRecord.Id;
                        DistributorIdSet.add(partMapToUpdate.get(partId).TECHDistList__c);
                        // partMapToUpdate.get(partId).Id = 'a0I5E000003OKHd';


                    }
                    system.debug('@@ mapOrderLines after: '+mapOrderLines);
                    system.debug('@@ mapOldKeyNewKeyPart: '+mapOldKeyNewKeyPart);
                    // insert partMapToUpdate.values();
                    List<Database.upsertResult> uResultsparts = Database.upsert(partMapToUpdate.values(),partExtId ,false);
                    String msg = checkforErrors(uResultsparts);
                    for (PartList__c part: partMapToUpdate.values()){
                        partMapPo.put(part.Id, part);

                        if (mapOldKeyNewKeyPart.containsKey(part.TECH_OriginalPart__c)){
                            mapOldKeyIdPart.put(mapOldKeyNewKeyPart.get(part.TECH_OriginalPart__c),part.Id);

                        }
                        

                    }
                    system.debug('@@ mapOldKeyIdPart: '+mapOldKeyIdPart);


                    if (String.isnotBlank(msg)){
                        system.debug('@@ here rollback 2: '+msg);

                        Database.rollback(beforeDML); 
                        return msg;
                    }

                }
                else{
                    isAllSuccess = false;
                    Database.rollback(beforeDML); 
                    String msg = '';
                    for (Database.Error er : uResultsAss.getErrors()) {
                        msg += 'Error (' + er.getStatusCode() + '):' + er.getMessage();
                        msg += '\r\n'; 
                    }
                    system.debug('@@ msg: '+msg);

                    return msg;
                }

                if (isAllSuccess){
                    //setting Mrsourcing of claim order
                    if (DistributorIdSet.size() > 0){
                        assRecord.MRSourcing__c = DistributorIdSet.size() > 0 ? String.join(new List<String>(DistributorIdSet), ';') : assRecord.MRSourcing__c;                       

                    }

                    if(assRecord.MREligibility__c && assRecord.MRSourcing__c != null){
                        system.debug('## if');
                        for(String dis : assRecord.MRSourcing__c.split(';')){
                            if (string.isnotBlank(dis)){
                            listDistributors.add(new Account(Id=dis));
                        }
                        }
                        system.debug('## listDistributors: '+listDistributors);

                        if(listDistributors.size() > 0){
                            //DUN 08/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                            set <Id> agencydistributorsId = new set <Id>();
                            if(assRecord.AgencyDistributors__c != null && assRecord.AgencyDistributors__c != ''){
                                for(String adisId : assRecord.AgencyDistributors__c.split(';')){
                                    agencydistributorsId.add(adisId);
                                }
                            }
                            Set<Id> directOrdersSet = new Set<Id>();
                            if(!String.isBlank(assRecord.Tech_DirectOrders__c))
                                for(String dOId : assRecord.Tech_DirectOrders__c.split(';')){
                                    directOrdersSet.add(dOId);
                                }
                            ASPISDirectSourcing.createPurchaseOrders(assRecord, listDistributors, null, null, null, null,'P0', agencydistributorsId,directOrdersSet);

                            update new Assessment__c(Id         = assRecord.Id,
                                                    Status__c  = ASPISConstants.ASSESS_STATUS_SOURCED,
                                                    MRSourcing__c = assRecord.MRSourcing__c)
                                                    ;
                        }
                    }  
                    else{
                        system.debug('## else'); 
                        // Passing the assessment to Ready to generate the PO and OLs
                        update new Assessment__c(Id = assRecord.Id,
                                                Status__c  = ASPISConstants.ASSESS_STATUS_READY);
                    }  

                    //select PO and its OL to update suppliable orderlines
                    List<PurchaseOrder__c> listPO = ASPISWithoutSharingExceptions.getPOList(assRecord.Id);
                    system.debug('## listPO' + listPO);
                     if(listPO.size() > 0)
                    {
                        //Create newSalesOrder
                        PrerequisiteOrder__c newSalesOrder = new PrerequisiteOrder__c(Assessment__c = assRecord.Id,
                                                                                        BodyShop__c   = assRecord.BodyShop__c,
                                                                                        Status__c     = 'PREACCEPTANCE',
                                                                                        RecordTypeId  = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId());

                        insert newSalesOrder;
                        System.debug('## newSalesOrder' + newSalesOrder);

                    
                        Map<Id,List<Id>> partTypeMapDistributors = new Map<Id,List<Id>>();
                        boolean hasMultiSourcing=false;

                        for(PurchaseOrder__c po : listPO){
                            /*canCreateAddPart = false;
                            if(po.Distributor__r.Categories__c != null && po.Distributor__r.Categories__c.contains('A') && po.Distributor__r.Name == system.label.AdditionalPartDistributor){
                                canCreateAddPart = true;
                            }*/
                            // mapTypeDelay = new Map<String,String>();
                            // if(po.Distributor__r.PartTypeRegionDelayMatrix__c != null)
                            // {
                            //     for(String matrixline : po.Distributor__r.PartTypeRegionDelayMatrix__c.split(';'))
                            //     {
                            //         matrixValues = matrixline.split(':');
                            //         partType = matrixValues[0].right(1);
                            //         delayValue = matrixValues[2].left(2);
                            //         if(!mapTypeDelay.containsKey(partType)){
                            //             mapTypeDelay.put(partType, delayValue);
                            //         }
                            //     }
                            // }
                            po.Status__c            = 'PREDRAFTQUOTE';
                            po.PrerequisiteOrder__c = newSalesOrder.Id;
                            po.RecordTypeId         = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId();

                            //AMI 04/09/17 - Distributor Integration
                            po.Tech_ExternalId__c   = string.valueOf(assRecord.Id) + string.valueOf(po.Distributor__c);

                            purchaseOrders.add(po); 

                            // if(partTypeMapDistributors.containsKey(ol.PartList__c)){
                            //     partTypeMapDistributors.get(ol.PartList__c).add(po.Distributor__c);
                            //     hasMultiSourcing=true;
                            // }else{
                            //     partTypeMapDistributors.put(ol.PartList__c,new List<Id>{po.Distributor__c});
                            // }
                            // system.debug('@@ PO: '+ po.Name + '- ' +po.OrderLines__r );
                            // system.debug('@@ PO: '+ po.Distributor__r.Tech_Distributor__c  );
                            for(OrderLine__c ol : po.OrderLines__r)
                            {
                                // system.debug('@@ ol '+ol.partlist__r.TECH_OriginalPart__c);
                                // system.debug('@@ ol '+ol.PartList__c);
                                ol.OrderType__c = 'FINAL';
                                // if (mapOrderLines.containsKey(ol.PartList__c)){
                                //     ol.ExpectedDeliveryDuration__c =  mapOrderLines.get(ol.PartList__c).ExpectedDeliveryDuration__c;
                                //     ol.SASStatus__c =  mapOrderLines.get(ol.PartList__c).SASStatus__c;
                                //     ol.CataloguePrice__c =  mapOrderLines.get(ol.PartList__c).CataloguePrice__c;
                                //     ol.Rebate__c =  mapOrderLines.get(ol.PartList__c).Rebate__c;
                                //     ol.BodyShopDiscount__c =  mapOrderLines.get(ol.PartList__c).BodyShopDiscount__c;
                                //     ol.AXADiscount__c =  mapOrderLines.get(ol.PartList__c).AXADiscount__c;
                                //     ol.Suppliable__c = 'YES';
                                //     // ol.ASBodyshopNetPrice__c =  mapOrderLines.get(ol.PartList__c).ASBodyshopNetPrice__c;
                                //     // ol.ASBodyshopPrice__c =  mapOrderLines.get(ol.PartList__c).ASBodyshopPrice__c;

                                // }
                                
                                // orderLines.add(ol);
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
                                system.debug('@@@ offer: '+offer);
                                offers.add(offer);                            
                            }  

                            for(string distName : mapAllowedLinesPerPrio.keySet()){
                                if (po.Distributor__r.Tech_Distributor__c == distName){
                                     Decimal Rebate = 0.0;
                                    if (mapEligiblePONameELigiblePO.containsKey(distName)){
                                        Rebate = mapEligiblePONameELigiblePO.get(distName).Rebate__C != null ? ( mapEligiblePONameELigiblePO.get(distName).Rebate__C / 100) : 0.0;

                                    } 
                                    Map<string, String> mapTypeDelayforOL = new map<String,String>();
                                    if (mapDistPartTypeDelay.containsKey(distname)){
                                        mapTypeDelayforOL = mapDistPartTypeDelay.get(distName);

                                    }
                                    Integer allPartExceptAddPartSize = 0;
                                    system.debug('## allPartExceptAddPartSize:'+allPartExceptAddPartSize);
                                    Integer notSuppliablePartSize = 0;
                                    Boolean containAddPart = false;
                                    Boolean setAddPartToNotSuppliable = false; 
                                    String OrderRequest = mapEligiblePONameELigiblePO.get(distName).OrderRequest__c != null ? ( mapEligiblePONameELigiblePO.get(distName).OrderRequest__c ) : '';
                                    for(RestDistributorUtility.Lines line :mapAllowedLinesPerPrio.get(distName)){  
                                        if(line.PartNumber != system.label.AdditionalPartNumber){
                                            allPartExceptAddPartSize ++;
                                            if(line.Status != 'CONFIRMED' && line.Status != 'CONFIRMEDWITHDELAY' ){
                                                notSuppliablePartSize++;
                                            }
                                        }  
                                        else{
                                            if(OrderRequest != 'OrderPO'){
                                                containAddPart = true;
                                            }
                                        } 



                                    }
                                    for(RestDistributorUtility.Lines line :mapAllowedLinesPerPrio.get(distName)){ 
                                        system.debug('## line.StatusMessage:'+line.StatusMessage);
                                        if((line.StatusMessage == null || string.isBlank(line.StatusMessage)) && string.isNotBlank(line.PartNumber)){

                                            if (mapOldKeyIdPart.containsKey(line.ID)){
                                                line.ID = mapOldKeyIdPart.get(line.ID) ;
                                            }
                                            
                                            system.debug('## line.PartNumber:'+line.PartNumber);
                                            system.debug('## line.ID:'+line.ID);
                                            //Commented by RLA Case 2778 : Call Distributor Stock does not update Status 13/09/2018
                                            //if(!(line.PartNumber.toUpperCase()).startsWith('ASCR-')){
                                                
                                            //AMI 18/10/17 : SAS: Remplacement de pièce
                                            Boolean isReplacament = false;
                                            String originalPN = '';
                                            String fluxPN = RESTUpsertAssessmentV2.cleanseReference(line.PartNumber);
                                            string OLStatus = string.isNotBlank(line.Status) ? line.Status.toUpperCase() : '';
                                            String olCanSupply = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO';
                                            // system.debug('## partMapToUpdate: '+partMapToUpdate);
                                            system.debug('## line: '+line.ID);
                                            //build originalPN
                                            if(partMapPo.containsKey(line.ID)){ 
                                                PartList__c tempPart = partMapPo.get(line.ID);
                                                system.debug('## line: '+line.ID);
                                                    originalPN =tempPart.PartNumber__c;
                                                /*Ashwina S    18/04/2018  C-002477: ASP- Prefix*/
                                                // originalPN = (originalPN.startsWith(system.label.desubstitureprefix)) ? originalPN.split(system.label.desubstitureprefix)[1]: originalPN;
                                                //RLA 09/07/2020 C-003857: IG - Creation IGO 
                                                originalPN = RestDistributorUtility.getOemPartNumber (originalPN , InsuranceBroker, prefixPartNumberIGO);
                                                originalPN =  RESTUpsertAssessmentV2.cleanseReference(originalPN);
                                            }

                                            if(originalPN != fluxPN){
                                                isReplacament = true;
                                            }

                                            system.debug('## isReplacament ' + isReplacament + ' originalPN: ' + originalPN + 'fluxPN: '+fluxPN);

                                            OrderLine__c originalOL;

                                            

                                            if(!isReplacament){
                                                originalOL = ASPISCreatePOOrderLines.createOrderline(line, PO.Name, PO.Id, mapTypeDelayforOL, partMapPo, false, PO.Status__c, new map <ID, OrderLine__c>(),false,'', setAddPartToNotSuppliable, null, OrderRequest,Rebate);
                                                system.debug('@@ originalOL: '+originalOL);
                                                MapOrderLines.put(originalOL.TechExternalId__c, originalOL);
                                            

                                            
                                            }else{
                                                if(line.Bundle == false && ((line.Parts != null && line.Parts.size() == 0) || line.Parts == null)){
                                                    //initialise original in order to update ordertype
                                                    originalOL = ASPISCreatePOOrderLines.createOrderline(line, PO.Name, PO.Id, mapTypeDelayforOL, partMapPo, false, PO.Status__c, new map <ID, OrderLine__c>(),false,'', setAddPartToNotSuppliable, null, OrderRequest,Rebate);
                                                    originalOL.OrderType__c = 'ORIGINAL';
                                                    system.debug('## originalOL ' + originalOL);

                                                    // //create alternaltive
                                                    OrderLine__c alterna = ASPISCreatePOOrderLines.createOrderline(line, PO.Name, PO.Id, mapTypeDelayforOL, partMapPo, false, PO.Status__c, new map <ID, OrderLine__c>(),true,(PO.Name + '-' + line.ID), setAddPartToNotSuppliable, null, OrderRequest,Rebate);
                                                    //RLA 18/06/2020 C-003700: IG - orderConfirmation
                                                    
                                                    alterna.TechOLType__c = 'replacement';
                                                    
                                                    MapOrderLines.put(originalOL.TechExternalId__c, originalOL);
                                                    MapOrderLines.put(alterna.TechExternalId__c, alterna);

                                                    // system.debug('## alterna ' + alterna);

                                                    // //add to upsert map
                                                    // if(alternativeOLMap.containsKey(PO.Id)){
                                                    //     alternativeOLMap.get(PO.Id).add(alterna);
                                                    // }else{
                                                    //     alternativeOLMap.put(PO.Id,new list <OrderLine__c>{alterna});
                                                    // }  
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        system.debug('## offers:'+offers);

                        system.debug('## MapOrderLines: '+MapOrderLines); 
                        if(MapOrderLines.size() > 0) 
                        {
                            // class is already in without sharing
                            upsert MapOrderLines.values() TechExternalId__c;
                            // ASPISWithoutSharingExceptions.updateOrderLineList(orderLines);
                        }
                        system.debug('## offers:'+offers);

                        if(purchaseOrders.size() > 0)
                        {
                            // class is already in without sharing
                            update purchaseOrders;
                            // ASPISWithoutSharingExceptions.updatePurchaseOrderList(purchaseOrders);
                        }
                        system.debug('## offers:'+offers);

                        if(offers.size() > 0)
                        {
                            insert offers;
                            
                        }     

                        

                    }//endif PO


                    

                }//endif allSuccess
                
                
            }


            


    // }//end if response not null


        return 'OK';
    }

    public static string generateResponse (Map<String, Assessment__c> mapExtIdAss, Map<String,List<Parts>> mapAssIdlstPartWrapper, Map<String, String> mapBSNameId, String ErrMsg){

        System.debug('---------------------------------- START RESTSearchAssessment - generateResponse ----------------------------------'); 


        JSONGenerator genResults = JSON.createGenerator(false);

        if (mapExtIdAss != null && mapExtIdAss.size() > 0){
        
           // genResults.writeStartArray();
                genResults.writeStartObject();
                genResults.writeFieldName('Assessments');
                genResults.writeStartArray();
                
                for (String extId: mapExtIdAss.keyset()){
                    Assessment__c assess = mapExtIdAss.get(extId);
                    genResults.writeStartObject();
                        genResults.writeStringField('ClaimReference', String.IsNotBlank(assess.ClaimReference__c) ? assess.ClaimReference__c : '');
                        genResults.writeStringField('InsBrokerNumber', String.IsNotBlank(assess.InsBrokerNumber__c) ? assess.InsBrokerNumber__c : '');
                        genResults.writeStringField('AssessmentVersion', assess.AssessmentVersion__c != null ? String.valueOf(assess.AssessmentVersion__c) : '');
                        genResults.writeStringField('AssessmentID', String.isNotBlank(assess.AssessmentID__c) ? assess.AssessmentID__c: '');
                        genResults.writeStringField('CreationDate', claimAssDates != null && claimAssDates.CreatedDate != null ? String.valueof(claimAssDates.CreatedDate) : assess != null && assess.CreatedDate != null ? String.valueof(assess.CreatedDate) : '');
                        genResults.writeStringField('LastUpdateDatefromAT', claimAssDates != null && claimAssDates.LastUpdateDate__c  != null ? String.valueof(claimAssDates.LastUpdateDate__c) : assess != null && assess.LastUpdateDate__c != null ? String.valueof(assess.LastUpdateDate__c) : '');
                        // genResults.writeStartObject();
                        genResults.writeFieldName('Vehicle');
                            genResults.writeStartObject();
                                genResults.writeStringField('VinNumber', String.isNotBlank(assess.VINNumber__c) ? assess.VINNumber__c: '');
                                genResults.writeStringField('PlateNumber', String.isNotBlank(assess.PlateNumber2__c) ? assess.PlateNumber2__c: '');
                                genResults.writeStringField('Model', String.isNotBlank(assess.ModelV2__c) ? assess.ModelV2__c: '');
                                String firstReg = '';
                                if (assess.FirstRegistrationDate__c != null){
                                    Date firstRegDAte = assess.FirstRegistrationDate__c;
                                    DateTime DT = DateTime.newInstance(firstRegDAte.year(), firstRegDAte.month(), firstRegDAte.day(), 0, 0, 0);
                                    firstReg = String.valueOf(DT);
                                }
                                genResults.writeStringField('FirstRegistrationDate', firstReg);
                                genResults.writeStringField('Brand', String.isNotBlank(assess.Manufacturer__c) ? assess.Manufacturer__c: '');

                            genResults.writeEndObject();
                        
                        genResults.writeFieldName('Parts');
                        genResults.writeStartArray();
                        if (mapAssIdlstPartWrapper.containsKey(extId) && mapAssIdlstPartWrapper.get(extId) != null && mapAssIdlstPartWrapper.get(extId).size() > 0){
                            for (Parts part: mapAssIdlstPartWrapper.get(extId) ){
                                genResults.writeStartObject();
                                genResults.writeStringField('Type', part.Type);
                                genResults.writeNumberField('Quantity', part.Quantity);
                                genResults.writeStringField('PartNumber', part.PartNumber);
                                genResults.writeStringField('Manufacturer', part.Manufacturer);
                                genResults.writeStringField('ID', part.Id);
                                genResults.writeStringField('Description', part.Description);
                                genResults.writeStringField('Status', part.Status);
                                genResults.writeNumberField('Price', part.Price);
                                genResults.writeNumberField('Discount', part.Discount);
                                genResults.writeStringField('Delay', part.Delay);
                                genResults.writeStringField('Distributor',part.Distributor);
                                genResults.writeBooleanField('AlreadyOrdered',part.AlreadyOrdered);
                                genResults.writeEndObject();
                            }
                        }
                        genResults.writeEndArray();
                    genResults.writeEndObject();
                }
                genResults.writeEndArray();
                genResults.writeStringField('Message', ErrMsg);
                genResults.writeEndObject();
            //genResults.writeEndArray();        

        }
        else{
            //  genResults.writeStartObject();
            //genResults.writeStartArray();
                genResults.writeStartObject();
                    genResults.writeFieldName('Assessments');
                    genResults.writeStartArray();
                    genResults.writeEndArray();                            
                genResults.writeStringField('Message', ErrMsg);
                genResults.writeEndObject();                
           // genResults.writeEndArray();   

        }

        System.debug('---------------------------------- END RESTSearchAssessment - generateResponse ----------------------------------');


         return  genResults.getAsString();

       
    }

    public class SearchInfo {
        
        Public string Plate;
        Public string VIN;
        Public string InsBrokerNumber;
        Public string AssessmentID;
        Public string BSReferenceNumber;
        Public string CallerSystem;

    }

    public class Assessment{
 
        public  string ClaimReference;
        public  string InsBrokerNumber;
        public  Decimal AssessmentVersion;
        public  string AssessmentID;
        public  Datetime CreationDate;
		public  Datetime LastUpdateDatefromAT;
        public List<parts> ListParts;


        public Assessment(Assessment__c assess ){
            this.ClaimReference = assess.ClaimReference__c;
            this.InsBrokerNumber = assess.InsBrokerNumber__c;
            this.AssessmentVersion = assess.AssessmentVersion__c;
            this.AssessmentID = assess.AssessmentID__c;
            this.CreationDate = assess.CreatedDate;
		    this.LastUpdateDatefromAT = assess.LastUpdateDate__c;
                
        }

        
    }

    class Parts {
        public String Type;
        public Decimal Quantity;
        public String PartNumber;
        public String Manufacturer;
        public String Description;
        public String Status;
        public Decimal Price;
        public String Delay;
        public Decimal Discount;
        public String Distributor;
        public Boolean AlreadyOrdered;
        public String ID;
        // public Datetime createdDate;


        public Parts (PartList__c part, Offer__c off){
            this.Type = part != null && String.isNotBlank(part.Type__c) ? part.Type__c : off != null && String.isNotBlank(off.FinalType__c) ? off.FinalType__c : '';
            this.Quantity = part != null && part.Quantity__c != null ? part.Quantity__c : off != null && off.Quantity__c != null? off.Quantity__c : 0;
            this.PartNumber = part != null && String.isNotBlank(part.PartNumber__c) ? part.PartNumber__c : off != null && String.isNotBlank(off.PartNUmber__c) ? off.PartNUmber__c : '';
            this.Manufacturer = part != null && String.isNotBlank(part.ProducerName__c) ? part.ProducerName__c : off != null && String.isNotBlank(off.Manufacturer__c) ? off.Manufacturer__c : '';
            this.Description = part != null && String.isNotBlank(part.Description__c) ? part.Description__c : off != null && String.isNotBlank(off.Description__c) ? off.Description__c : '';
            this.Status = part != null ? '' : off != null && off.OrderLine__r != null && String.isNotBlank(off.OrderLine__r.SASStatus__c) ? off.OrderLine__r.SASStatus__c  : '';
            this.Price = part != null && part.Price__c != null ? part.Price__c : off != null && off.CataloguePrice__c != null ? off.CataloguePrice__c : 0;
            this.Discount  = part != null && part.Discount__c != null ? part.Discount__c : off != null && off.Discount__c != null ? off.Discount__c : 0;
            this.Delay = part != null ? '' : off != null && off.OrderLine__r != null && off.OrderLine__r.ExpectedDeliveryDuration__c != null ? off.OrderLine__r.ExpectedDeliveryDuration__c : '';
            this.Distributor = part != null ? '' : off != null && String.isNotBlank(off.Distributor__c) ? off.Distributor__c : '';
            this.AlreadyOrdered = part != null && part.TECH_OrderedCounter__c != null && part.TECH_OrderedCounter__c > 0 ? true : off != null && off.OrderLine__c != null && off.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c != null && off.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c > 0 ? true  : false;
            this.ID = part != null && part.Id != null ? part.Id : off != null && off.OrderLine__c != null && off.OrderLine__c != null ? off.OrderLine__c  : '';
            // this.createdDate = part != null && part.createdDate != null ? part.createdDate
        }
    }

    public static string checkforErrors( List<Database.upsertResult> uResults){
        string msgerr = '';
        for(Integer i=0;i<uResults.size();i++){
            if (!uResults.get(i).isSuccess()){                           
                
                Database.Error err = uResults.get(i).getErrors().get(0);
                    msgerr += 'Error (' + err.getStatusCode() + '):' + err.getMessage();
                    msgerr += '\r\n';    
            }
        }

        return msgerr;
    }

    


   
}