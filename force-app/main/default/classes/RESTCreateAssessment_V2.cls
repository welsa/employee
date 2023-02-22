/*************************************************************************************
Class Name - RESTCreateAssessment_V2
Version - 1.0
Created Date - 25 MAY 2015
Function - Class REST for the creation of an Assessment version 2

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Brayan Nunhuck 25/05/2015     Original Version
* Shamina M      17/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S      27/09/2016  C-001724: if transaction is not sent, set it to blank instead of null
*                                       add userRolePrefix to referenceNumber to look for BS only if userRole is DE or IT]
* Ashwina S      14/10/2016  C-001645: Special aggreement : Adding new fields in Assessment and CreateAssessment
* Ashwina S      21/11/2016  search for existing assessments in salesforce using AssessmentNumber
                             no updates on assessment
                             if existing assessment and new delta parts, create child assessment (assessId + timestamp)
* Ashwina S      08/12/2016  C-001814: Patch all reference numbers on Bodyshops & Distributors, except for ES
* Ashwina S      XX/04/2017  C-001907: elimination of assessment arrived by CreateAssesslent and already exist with upsertAssessment
                             C-001903: ASPIS 2.0 : Change the Car Mapping to be insensitive
* Ashutosh B     25/07/2017  C-001976: 2 PO for the same assessment - Also reworked the whole class and optimisation
* Ashwina S      02/08/2017  add ES to Account reference
* Ashwina S      23/01/2018  C-001987: Assessment total amount must be calculated on selected parts only - add SelectedByBS__c = true
* Dourga U       23/04/2018  C-002482 : VAT on Invoice lines
* Dourga         13/06/2018  C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
* Welsa C        21/08/2018  C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
* Ruksaar        01/11/2018   C-002883 - The PO with Priority 1 is not created when ProService cancels a part or the whole PO  
* Welsa C        20/11/2018   C-002883 - PO.TECHRulesAppliedDescription__c not being filled properly
* Ruksaar L      20/12/2018  C-002964: Cancel DE-NewAssessment if a Claim Assessment has the same Claim Reference
* Ruksaar L      23/08/2018  C-002690 Spain audatex assessments in r4
* Ruksaar L      11/04/2019  C-003100: ManageOrdering for SPain R4 
* Welsa C        13/06/2019  C-003286 - For RESTCreateAssessment_V2, PO is created when Partlist sent with Quantity 0 
* Welsa C        25/10/2019  C-003444 - POs sourced with CJP for the brand Mercedes are not created in Agency Mode
* Welsa C        06/11/2019  C-003460 - RestCreate Assessment cancelled if wrong part type sent
* Ruksaar L      17/03/2020  C-003652: R4 SPain: do not create claim order on Expert Claims
* Ruksaar L      18/11/2020  C-004030: From createAssessment to upsertAssessment
* Ruksaar L      13/01/2021  C-004139: if no BS is found do not convert R3 to R4
* Ruksaar L      21/01/2021  C-004154: Do not CreateAssessment with RestCreateAssessment
* Rayhaan B      30/11/2022  C-004850: Store Audatex version from CreateAssessment Spain
*************************************************************************************/
@RestResource(urlMapping='/v2.0/createAssessment/*')
global with sharing class RESTCreateAssessment_V2 {
    private final Static String OBJECTCODE = '-ASS';
    private final Static String PROCESSDELIVERYPROBLEM = '-WS';
    private final Static String PROCESSDUPLICATEPARTLIST = '-DuplicateParts';
     //RLA 27/09/18 Case-2177: Corrections/evolutions sur les logs
    //             Variable to store ObjectReference for Log
    private static String assessmentName = '';
    private static String jrespFuture;

    //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
    private static map<String,CountryCodeInformationsMapping__c> mapConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

    //DUN 13/06/2018 C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
    private static map <String,ASPISDirectSourcing.DistributorsListWrapper> mapPartTypeDistributorsWrap = new map <String,ASPISDirectSourcing.DistributorsListWrapper>();
    private static set<String> setPartTypes = new set<string>();   
    
    @HttpPost
    global static void createNewAssessment() {

        Map<String,String> mapHeaders = new Map<String,String>();
        string results = '';

        //retrieve the headers that are received by the request. Synchronous / Asynchronous
        RestRequest req = RestContext.request;
        mapHeaders = req.headers;

        //convert the requestbody into a string
        String body = RestContext.request.requestBody.toString();

        Log__c log = new Log__c(DateLog__c  = System.now(),
                                Class__c    = 'RESTCreateAssessment_V2');

        if (body.length() <= 30000){
            log.JSONMessage__c = body;
        }          
        
        insert log;

        if (body.length() > 30000)
        {
            APCreateAttachments.createAttachment('Request', body, log);
        }

        if(mapHeaders.containsKey(Label.CALLTYPE))
        {
            String cType = mapHeaders.get(Label.CALLTYPE);

            if(cType == Label.ASYNCHRONOUS){
                log.CallType__c = Label.ASYNCHRONOUS;
                // call @future method
                createAssessmentASync(log.Id,body);
                results = '[{"Message" : "' + Label.MSGASYNCTREATMENT +' '+log.Id+ '"}]';
            }
            else if(cType == Label.SYNCHRONOUS)
            {
                log.CallType__c = Label.SYNCHRONOUS;
                //call synchronous method
                results = createAssessmentSync(log.Id,body);
            }
        }
        else
        {
            log.CallType__c = Label.SYNCHRONOUS;
            //if no callType in header, by default call synchronous method
            results = createAssessmentSync(log.Id,body);
        }

        if(!results.contains(Label.MSGASYNCTREATMENT)){
            if(results.contains('Exceptions')){
                log.Status__c = Label.STATUSFAILED;
            }else{
                log.Status__c = Label.STATUSPASSED;
            }
        }else{
            log.Status__c = Label.STATUSPASSED;
        }

        if (results != ''){
            List<Object> l = (List<Object>) JSON.deserializeUntyped(results);

            string msgWarning = '';
            string functionalId = '';

            for(Object o : l){
                Map<String, Object> a2 = (Map<String, Object>)o;
                msgWarning = (String)a2.get('Warning');
                functionalId = (String)a2.get('FunctionalId');
            }

            if(msgWarning != '' && msgWarning != null){
                log.ErrorCode__c = 'warning';
                log.ErrorDescription__c = msgWarning;
            }

            if(functionalId != '' && functionalId != null){
                log.AssessmentID__c = functionalId;
            }

            update log;

            RestContext.response.responseBody = Blob.valueOf(results);

        }
    }

    private static Map<String, String> validationPartList(List<PartList__c> listOfPartListToValidate)
    {
        Map<String,String> mapValidationErrors  = new Map<String,String>();
        Map<String, Schema.SObjectType> m       = Schema.getGlobalDescribe() ;
        Schema.SObjectType s                    = m.get(Label.SOBJECTPARTLIST) ;
        Schema.DescribeSObjectResult r          = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields  = r.fields.getMap() ;

        Set<String> lstRequiredFields = new Set<String>();

        for(String f : fields.keyset())
        {
            Schema.DescribeFieldResult describeResult = fields.get(f).getDescribe();
            if( describeResult.isCreateable() && !describeResult.isNillable() && !describeResult.isDefaultedOnCreate())
            {
                //This is mandatory / required field
                lstRequiredFields.add(f);
            }
        }

        for(PartList__c p : listOfPartListToValidate)
        {
            if(lstRequiredFields.size() > 0){
                for(String fieldNameCompulsory : lstRequiredFields){
                    //It provides to get the object fields data type.
                    Schema.DisplayType fielddataType = fields.get(fieldNameCompulsory).getDescribe().getType();
                    if(mapValidationErrors.containsKey(p.PartNumber__c)){
                        String existingField = mapValidationErrors.get(p.PartNumber__c);
                        String newFields = existingField +','+fieldNameCompulsory;
                        mapValidationErrors.put(p.PartNumber__c,newFields);
                    }else{
                        String newFields = fieldNameCompulsory;
                        mapValidationErrors.put(p.PartNumber__c,newFields);
                    }
                }
            }
        }

        return mapValidationErrors;
    }

    // call if calltype is async
    @future
    public static void createAssessmentAsync(Id logId, String body){
        List<Log__c> logToUpdate = new List<Log__c>();

        //call method that will process json that contains assessments
        string jResp = createRecordsAssessment(body);
        //get log id to update

        for(Log__c l : [SELECT  Id
                        FROM    Log__c
                        WHERE   Id =: logId])
        {
            if (jResp.length() > 30000)
            {
                APCreateAttachments.createAttachment('Response',jResp,l);
            }
            else
            {
                l.JSONResponse__c = jResp;
            }
            logToUpdate.add(l);
        }

        //update log
        if(logToUpdate.size()  > 0){
            update logToUpdate;
        }
    }

    // call if calltype is sync
    public static string createAssessmentSync(Id logId,String body){
        List<Log__c> logToUpdate = new List<Log__c>();

        //call method that will process json that contains assessments
        string jResp = createRecordsAssessment(body);

        //get log id to update
        for(Log__c l : [SELECT  Id
                        FROM    Log__c
                        WHERE   Id =:logId])
        {
            if (jResp.length() > 30000){
                APCreateAttachments.createAttachment('Response',jResp,l);
            }else{
                l.JSONResponse__c = jResp;
            }

            logToUpdate.add(l);
        }

        //update log
        if(logToUpdate.size()  > 0){
            update logToUpdate;
        }

        return jResp;
    }

    // Map containing all the error messages that need to be output at the end
    private static Map<String, String> mapErrorMessageAssessment;
    // Map of car metadatas
    private static Map<String, CarMappings__mdt> mapCarMapping;
    // Name of the user running the class....alias the callingSystem
    private static String callingSystem;

    //create objects in Salesforce
    public static string createRecordsAssessment(string body){
        List<Assessment__c> assessmentsToBeInserted = new List<Assessment__c>();
        List<PartList__c> partsToBeInserted = new List<PartList__c>();
        List<Assessment> assessmentList = new List<Assessment>();
        Map<String, Account> mapRefNumberAccount = new Map<String, Account>();
        mapErrorMessageAssessment = new Map<String, String>();
        Map<String, List<Assessment>> mapAssessmentNumber = new Map<String, List<Assessment>>();
        Map<String, Assessment> mapAssessmentIdAssessmentWrapper = new Map<String, Assessment>();

        Map<String, String> mapSuccessCreation = new Map<String, String>();
        Map<String, String> mapErrorsCreation = new Map<String, String>();
        Map<String, String> mapExtIdNSFDCID = new Map<String, String>();
        

        String results = '';
        JSONGenerator genResults;
        List<Case__c> l_casesToInsert = new List<Case__c>();
        Set<String> notValidForCreationSet = new Set<String>();
        Map<String, PartList__c> mapPartList = new Map<String, PartList__c>();
        String userRolePrefix;
        // C-001814:  Enlever la condition dans le RESTCreateAssessment sur le code pays
        String bodyShopCountryCodePrefix;

        //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
        Assessment deserializedAssess;

        try{

            //ASE : case 1724
            // 2016/09/19; get user Role
            User intUser = [SELECT UserRole.Name,CreateToUpsert__c,callersystem__c,noCreateAssessment__c  FROM User WHERE Id =: UserInfo.getUserId()];
            userRolePrefix =  (intUser.UserRole != null  && intUser.UserRole.Name != null) ? intUser.UserRole.Name.left(2) : '';
            callingSystem = UserInfo.getName();

            //RLA 21/01/2021  C-004154: Do not CreateAssessment with RestCreateAssessment
            if(intUser.noCreateAssessment__c == false){

            // C-001814: Replace bodyShopCountryCodePrefix by userRolePrefix
            // ASE : 2017/08/02
            //bodyShopCountryCodePrefix = (userRolePrefix != 'ES') ? userRolePrefix : '';
            bodyShopCountryCodePrefix = userRolePrefix;

            populateRecordTypeMap();

            //create json parser
            JSONParser parser = JSON.createParser(body);

            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            //parse block of Assessment into helper class Assessment
                            Assessment a = (Assessment)parser.readValueAs(Assessment.class);
                            parser.skipChildren();
                            assessmentList.add(a);
                        }
                    }
                }
            }

            // Checking if the assessment list is greater that 0
            if(assessmentList.size() > 0)
            {
                // Set storing all the bodyshop reference numbers to retrieve
                Set<String> bodyShopReferenceNumberSet = new Set<String>();

                // ABT - found that SOQL of CarMapping Metadata was in a loop
                Set<String> allBrandsToBeTreated = new Set<String>();

                for(Assessment a : assessmentList)
                {
                    deserializedAssess = a;

                    if(a.currentBodyShop != null)
                    {

                            //RLA 15/01/2020 C-004138: Convert BS Reference into 10 digit format
                            if (String.isnotblank(a.currentBodyShop.ReferenceNumber) && String.isnotblank(intUser.callersystem__c) && (intUser.callersystem__c).toUpperCase() == 'FR_NEVADA' ){
                                a.currentBodyShop.ReferenceNumber = convertBSRef(a.currentBodyShop.ReferenceNumber);
                            }

                            
                        if(a.currentBodyShop.ReferenceNumber != null && a.currentBodyShop.ReferenceNumber != ''){
                            bodyShopReferenceNumberSet.add(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber);
                        }
                    }

                    // ABT - Capturing all the brands that need to have their true values retrieved from the CarMapping Metadata
                    if(a.currentAsset != null && a.currentAsset.Manufacturer != null)
                    {
                        allBrandsToBeTreated.add((callingSystem + '-' + a.currentAsset.Manufacturer).toUpperCase());
                    }

                    // if contains no transactionId, set to blank
                    String transactionId = (a.TransactionID == null) ? '' : a.TransactionID;
                    mapAssessmentIdAssessmentWrapper.put(userRolePrefix + a.AssessmentNumber + transactionId, a);
                    // mapAssessmentIdAssessmentWrapper.put(userRolePrefix + a.AssessmentNumber,a);

                    if(a.AssessmentNumber != null && a.AssessmentNumber != ''){
                        if(mapAssessmentNumber.containsKey(a.AssessmentNumber)){
                            mapAssessmentNumber.get(a.AssessmentNumber).add(a);
                        }else{
                            mapAssessmentNumber.put(a.AssessmentNumber, new List<Assessment>{a});
                        }
                    }

                    // ABT - 24-JUL-2017 - C-001976
                    if(a.Parts != null && a.Parts.size() > 0)
                    {
                        for(Part currentPartWrapper : a.Parts)
                        {
                            if(String.isBlank(currentPartWrapper.PartNumber) && String.isNotBlank(currentPartWrapper.Name))
                            {
                                currentPartWrapper.PartNumber = removeSpaceHypen(currentPartWrapper.Name);
                            }
                            
                        }
                    }
                }

                // System.debug('bodyShopReferenceNumberSet=' + bodyShopReferenceNumberSet);

                // Calling the function retrieveAccountMap to get all the accounts using the captured reference number
                mapRefNumberAccount = retrieveAccountMap(bodyShopReferenceNumberSet);

                populateCarMappingMetadata(allBrandsToBeTreated);

                // System.debug('mapRefNumberAccount=' + mapRefNumberAccount);

                //get all parts that exist for the assessment number
                Map<String, Set<String>> mapAssessmentSobjNPartNum = new Map<String, Set<String>>();

                // Map of AssessmentNumber + PartNumber + Description -> No of quantity of parts
                Map<String, Decimal> mapPartQuantity = new Map<String, Decimal>();

                // Retrieving the parts according to its created date
                for(PartList__c pl : [  SELECT  Id, PartNumber__c, Assessment__r.AssessmentNumber__c, Assessment__r.AssessmentID__c, Quantity__c,
                                                Description__c, Assessment__c, RecordTypeId, Compliance__c, SelectedByBS__c
                                        FROM    PartList__c
                                        WHERE   Assessment__r.AssessmentNumber__c IN: mapAssessmentNumber.keySet()
                                        AND     Assessment__r.Recordtype.Name = :ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment
                                        ORDER BY CreatedDate ASC])
                {
                    String key = pl.Assessment__r.AssessmentNumber__c;
                    
                    if(mapAssessmentSobjNPartNum.containsKey(key)){
                        mapAssessmentSobjNPartNum.get(key).add(pl.PartNumber__c); 
                    }
                    else{
                        mapAssessmentSobjNPartNum.put(key, new Set<String>{pl.PartNumber__c});
                    }

                    mapPartList.put(pl.Assessment__r.AssessmentNumber__c + '' + pl.PartNumber__c + '' + pl.Description__c + '' + pl.Quantity__c, pl);

                    String keyWithoutQuantity = pl.Assessment__r.AssessmentNumber__c + pl.PartNumber__c + pl.Description__c;
                    if(mapPartQuantity.containsKey(keyWithoutQuantity))
                    {
                        Decimal totalQuantity = mapPartQuantity.get(keyWithoutQuantity) + pl.Quantity__c;
                        mapPartQuantity.put(keyWithoutQuantity, totalQuantity);
                    }
                    else
                    {
                        mapPartQuantity.put(keyWithoutQuantity, pl.Quantity__c);
                    }
                }

                // System.debug('## mapPartList:'+mapPartList);

                Map<String, Assessment__c> mapAssessmentNumberToBeTreated = new Map<String, Assessment__c>();

                //receiving assessment number and transaction id same
                //action : Update Assessment that already exist
                for(Assessment__c currentAssessment : [ SELECT  Id, AssessmentID__c, AssessmentNumber__c
                                                        FROM    Assessment__c
                                                        WHERE   AssessmentNumber__c IN: mapAssessmentNumber.keySet()
                                                        AND     Recordtype.Name = :ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment
                                                        ORDER BY CreatedDate ASC])
                {
                    if (!mapAssessmentNumberToBeTreated.containsKey(currentAssessment.AssessmentNumber__c)){
                        mapAssessmentNumberToBeTreated.put(currentAssessment.AssessmentNumber__c, currentAssessment);
                    }
                }

                System.debug('## mapAssessmentNumberToBeTreated: '+mapAssessmentNumberToBeTreated);

                for(Assessment a : assessmentList)
                {
                    String transactionId = (a.TransactionID == null) ? '' : a.TransactionID;
                    String alldirectOrderIds = '';

                    if(mapAssessmentNumberToBeTreated.containsKey(a.AssessmentNumber)){
                        //treatment of assessment that has an assessment number that exist but transaction number different
                        //action: create new assessment and tached to parent assessment that has same assessment number *
                        // Condition : must check part list before creating new assessment

                        Assessment__c toInsertAssessment = createAssessmentVariable(a, transactionId, userRolePrefix, true);

                        //associate the body shop provided in the json to the assessment
                        if(a.currentBodyShop != null)
                        {
                            if(mapRefNumberAccount.containsKey(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber)){
                                toInsertAssessment.BodyShop__c = mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).Id;
                                
                            }
                            else{
                                //populate a map of transaction id as key and the error message that should be displayed if the body shop is not found
                                mapErrorMessageAssessment.put(toInsertAssessment.AssessmentID__c, Label.ERRORACCOUNTNOTEXIST);
                                
                                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, null, null, null, null, null, null, UserInfo.getUserId(), PROCESSDELIVERYPROBLEM);
                                if(newCase != null){
                                    l_casesToInsert.add(newCase);
                                }
                            }
                        }

                        //change request on 29 may 2015 Jonathan
                        // associate parent asssessment to the new one
                        // done by BNU
                        Assessment__c amt = mapAssessmentNumberToBeTreated.get(a.AssessmentNumber);
                        toInsertAssessment.ParentAssessment__c = amt.Id;

                        // Change request from Jonathan on 15 july 2015
                        //If no delta don't create new asessment if Assessment number exist and transaction number does not exist
                        Boolean validForCreation = false;
                        if(mapAssessmentSobjNPartNum.containsKey(a.AssessmentNumber))
                        {
                            Set<String> existingPartNumberSet = mapAssessmentSobjNPartNum.get(a.AssessmentNumber);
                            if(a.Parts != null && a.Parts.size() > 0)
                            {
                                for(Part p : a.Parts)
                                {
                                    if(!existingPartNumberSet.contains(p.PartNumber))
                                    {
                                        //if the json block contains new part list that the existing Assessment does not have
                                        //Action: create the new part list
                                        validForCreation = true;

                                        PartList__c pl = createPartVariable(p, toInsertAssessment.AssessmentID__c, null);
                                        
                                        partsToBeInserted.add(pl);
                                    }
                                    else
                                    {
                                        //eles if part number exist alrealdy
                                        //Action check for unicity ( Partnumber concatenate with Description)
                                        String mapPartListKey = toInsertAssessment.AssessmentNumber__c.trim() + '' + p.PartNumber.trim() + '' + p.Description.trim() + '' + p.Quantity.trim();

                                        // Check if there is a diff in the number of parts by using the key
                                        if(!mapPartList.containsKey(mapPartListKey))
                                        {
                                            String mapPartListNumDescKey = a.AssessmentNumber.trim() + '' + p.PartNumber.trim() + '' + p.Description.trim();

                                            // Changed to number of quantity
                                            if (mapPartQuantity.containsKey(mapPartListNumDescKey))
                                            {
                                                // means that quantity differs
                                                // ABT - Changed != by > as to prevent creation of assessment with fewer quantity that existed in the database
                                                if (Integer.valueOf(p.Quantity) > mapPartQuantity.get(mapPartListNumDescKey) && Integer.valueOf(p.Quantity)>0/*WCH 13/06/2019 C-003286*/)
                                                {
                                                    System.debug('## quantity differs!');
                                                    validForCreation = true;

                                                    PartList__c pl = createPartVariable(p, toInsertAssessment.AssessmentID__c, mapPartQuantity.get(mapPartListNumDescKey));
                                                    
                                                    partsToBeInserted.add(pl);
                                                }
                                            }
                                            else
                                            {
                                                //if does not exist
                                                //Action: Create new partlist for the new assessment
                                                // start C-001288
                                                validForCreation = true;

                                                PartList__c pl = createPartVariable(p, toInsertAssessment.AssessmentID__c, null);

                                                partsToBeInserted.add(pl);
                                                // end C-001288
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else
                        {
                            // to be checked
                            // new part list found in json block
                            //Action : Create new partlist
                            if(a.Parts != null && a.Parts.size() > 0)
                            {
                                validForCreation = true;

                                for(Part p : a.Parts)
                                {
                                    PartList__c pl = createPartVariable(p, toInsertAssessment.AssessmentID__c, null);
                                    
                                    partsToBeInserted.add(pl);
                                }
                            }
                        }

                        //DUN 13/06/2018 C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                        if(setPartTypes.size() > 0 
                            && mapRefNumberAccount.containsKey(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber)
                            && mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).Feature__c != null
                            && mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).Feature__c.contains('PilotDirectSourcing')){
                            mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(bodyShopCountryCodePrefix,toInsertAssessment.BodyShop__c,toInsertAssessment.Manufacturer__c ,mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).ShippingPostalCodeLeft2__c, mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).CarBrandsSuppliedAgency__c, setPartTypes);
                                                                
                            toInsertAssessment.Feature__c = mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).Feature__c;
                            String allFirstDistributorsIds = '';
                            String allAgencyDistributorsIds = '';
                            String allDistributorsDirOrders = '';

                            if(!mapPartTypeDistributorsWrap.isEmpty()){
                                for(String ptype : mapPartTypeDistributorsWrap.keySet()){
                                    for(Id directOrderIds : mapPartTypeDistributorsWrap.get(ptype).DirectOrderIds){
                                        if(!alldirectOrderIds.contains(directOrderIds))
                                            alldirectOrderIds += directOrderIds + ';' ;
                                    }
                                    for(String disId : mapPartTypeDistributorsWrap.get(ptype).FirstDistributor.split(';')){
                                        if(disId.contains('-true')){
                                           disId = disId.remove('-true');
                                        }
                                        if(!allFirstDistributorsIds.contains(disId)){
                                            allFirstDistributorsIds += disId + ';';
                                        }
                                    } 
                                    if(mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors != null && mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors != '' ){
                                        for(String agencydisId : mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors.split(';')){
                                            if(!allAgencyDistributorsIds.contains(agencydisId)){
                                                allAgencyDistributorsIds += agencydisId + ';';
                                            }
                                        }
                                    }
                                    //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                                    if (String.isNotBlank(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders) ){
                                        //WCH 20/11/2018: C-002883 - PO.TECHRulesAppliedDescription__c not being filled properly
                                        if (!allDistributorsDirOrders.contains(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders)){
                                            allDistributorsDirOrders +=','+ mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders;
                                        }
                                    }

                                }   
                                if(allFirstDistributorsIds != ''){
                                    toInsertAssessment.MRSourcing__c = allFirstDistributorsIds.removeEnd(';');
                                    toInsertAssessment.AgencyDistributors__c = allAgencyDistributorsIds;
                                }
                                if(alldirectOrderIds != ''){
                                    alldirectOrderIds = alldirectOrderIds.removeEnd(';');
                                }   
                                //WCH 21/08/2018 : C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                                toInsertAssessment.Tech_DirectOrders__c=alldirectOrderIds;
                                //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                                toInsertAssessment.TechDistAndDirectOrder__c=allDistributorsDirOrders;
                            }
                            else{
                                toInsertAssessment.MRSourcing__c = 'false';
                            }
                        }

                        if(validForCreation)
                        {
                            assessmentsToBeInserted.add(toInsertAssessment);
                        }
                        else
                        {
                            notValidForCreationSet.add(userRolePrefix + toInsertAssessment.AssessmentNumber__c + toInsertAssessment.TransactionId__c);
                            // notValidForCreationSet.add(userRolePrefix+toInsertAssessment.AssessmentNumber__c);
                        }
                    }
                    else{
                        // Assessment Number not found
                        // Action : Create Assessment from scratch

                        // System.debug('## assessment does not exists in database');
                        Assessment__c newAssessmentToInsert = createAssessmentVariable(a, transactionId, userRolePrefix, false);

                        alldirectOrderIds = '';
                        //associate the body shop provided in the json to the assessment
                        if(a.currentBodyShop != null){
                            if(mapRefNumberAccount.containsKey(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber)){
                                newAssessmentToInsert.BodyShop__c = mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).Id;
                                
                            } 
                            else{
                                //populate a map of transaction id as key and the error message that should be displayed if the body shop is not found
                                mapErrorMessageAssessment.put(newAssessmentToInsert.AssessmentID__c,Label.ERRORACCOUNTNOTEXIST);
                                Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, null, null, null, null, null, null, UserInfo.getUserId(), PROCESSDELIVERYPROBLEM);
                                if(newCase != null){
                                    l_casesToInsert.add(newCase);
                                }
                            }
                        }

                        //initialise the partlists that are associated with the assessment
                        if(a.Parts != null && a.Parts.size() > 0)
                        {
                            for(Part p : a.Parts)
                            {
                                PartList__c pl = createPartVariable(p, newAssessmentToInsert.AssessmentID__c, null);

                                partsToBeInserted.add(pl);
                            }
                        }
                        //DUN 13/06/2018 C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                        if(setPartTypes.size() > 0 
                            && mapRefNumberAccount.containsKey(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber)
                            && mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).Feature__c != null
                            && mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).Feature__c.contains('PilotDirectSourcing')){
                            mapPartTypeDistributorsWrap = ASPISDirectSourcing.getmaptypeDistributors(bodyShopCountryCodePrefix,newAssessmentToInsert.BodyShop__c,newAssessmentToInsert.Manufacturer__c ,mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).ShippingPostalCodeLeft2__c, mapRefNumberAccount.get(bodyShopCountryCodePrefix + a.currentBodyShop.ReferenceNumber).CarBrandsSuppliedAgency__c, setPartTypes);
                            String allFirstDistributorsIds = '';
                            String allAgencyDistributorsIds = '';
                            String allDistributorsDirOrders = '';//RLA 08/11/2018 C-002868 
                            
                            if(!mapPartTypeDistributorsWrap.isEmpty()){
                                for(String ptype : mapPartTypeDistributorsWrap.keySet()){
                                    for(Id directOrderIds : mapPartTypeDistributorsWrap.get(ptype).DirectOrderIds){
                                        if(!alldirectOrderIds.contains(directOrderIds))
                                            alldirectOrderIds += directOrderIds + ';' ;
                                    }
                                    for(String disId : mapPartTypeDistributorsWrap.get(ptype).FirstDistributor.split(';')){
                                        if(disId.contains('-true')){
                                           disId = disId.remove('-true');
                                        }
                                        if(!allFirstDistributorsIds.contains(disId)){
                                            allFirstDistributorsIds += disId + ';';
                                        }
                                    } 
                                    if(mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors != null && mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors != '' ){
                                        for(String agencydisId : mapPartTypeDistributorsWrap.get(ptype).AgencyDistributors.split(';')){
                                            if(!allAgencyDistributorsIds.contains(agencydisId)){
                                                allAgencyDistributorsIds += agencydisId + ';';
                                            }
                                        }
                                    }
                                    //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                                    if (String.isNotBlank(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders) ){
                                        //WCH 20/11/2018: C-002883 - PO.TECHRulesAppliedDescription__c not being filled properly
                                        if (!allDistributorsDirOrders.contains(mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders)){
                                            allDistributorsDirOrders +=','+ mapPartTypeDistributorsWrap.get(ptype).DistributorsDirOrders;
                                        }
                                    }
                                }   
                                if(allFirstDistributorsIds != ''){
                                    newAssessmentToInsert.MRSourcing__c = allFirstDistributorsIds.removeEnd(';');
                                    newAssessmentToInsert.AgencyDistributors__c = allAgencyDistributorsIds;
                                }
                                if(alldirectOrderIds != ''){
                                    alldirectOrderIds = alldirectOrderIds.removeEnd(';');
                                }
                                //WCH 21/08/2018 : C-001837 - Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                                newAssessmentToInsert.Tech_DirectOrders__c=alldirectOrderIds;
                                //RLA 08/11/2018 C-002868 : In the PO, in the field "Rules Applied Description", the direct sourcing rule priority 1 is displayed in addition of the rule priority 0
                                newAssessmentToInsert.TechDistAndDirectOrder__c=allDistributorsDirOrders;
                            }
                            else{
                                newAssessmentToInsert.MRSourcing__c = 'false';
                            }
                        }

                        assessmentsToBeInserted.add(newAssessmentToInsert);
                    }
                }

                //create case if body shop not found
                if(l_casesToInsert.size()>0){
                    insert l_casesToInsert;
                }

                Set<Id> assessmentSuccessSet = new Set<Id>();
                Set<String> assessmentErrorSet = new Set<String>();
                Map<Id, Assessment__c> mapAssUpdateES = new map<Id, Assessment__c>();
                 //RLA 16/08/2018 C-002690 Spain audatex assessments in r4 
                Map<String, assessment__c> mapAssNumberInsertedES = new Map<String, assessment__c>();
                //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
                Map<String, assessment__c> mapAssToConvert = new Map<String, assessment__c>();
                Boolean allowConversion = false;

                // For(cs: [select id,ConversionR3toR4__c from CustomerInformationsMapping__mdt where MasterLabel =: userRolePrefix ]){

                //     if (cs.ConversionR3toR4__c){
                //         allowConversion = true;
                //     }

                // }
                // if ((system.label.R3toR4Callersystem).toUpperCase() != 'NONE' ){
                //     allowConversion = true;                    
                // }
                // system.debug('@@ allowConversion: '+allowConversion);

                //RLA 19/04/2019 C-003101: Manage Delta part List for SPain R4 
                String newAssessmentId, assExtId ='';
                Decimal versionToQuote = 0;

                // ABT - Map to be used to remove an extra update on assessment
                Map<Id, Assessment__c> mapAssessmentToUpdate = new Map<Id, Assessment__c>();
                if(assessmentsToBeInserted.size() > 0)
                {
                    setCrossReferencesFieldForAssessment(assessmentsToBeInserted, partsToBeInserted);

                    // System.debug('## assessmentsToBeInserted:' + assessmentsToBeInserted);
                    checkEligibilityOfAssess(assessmentsToBeInserted,bodyShopCountryCodePrefix);

                    //upsert assessments
                    Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;
                    List<Database.upsertResult> uResults = Database.upsert(assessmentsToBeInserted, assessExtId, false);
                    
                    for(Integer i = 0; i < uResults.size(); i++) {
                        if(uResults[i].isSuccess()) {
                            // if success populate the set of id that has been successful
                            assessmentSuccessSet.add(uResults[i].getId());
                            mapExtIdNSFDCID.put(assessmentsToBeInserted[i].AssessmentId__c, uResults[i].getId());
                        } 
                        else {
                            //generate the json that will be used for errors as reponse
                            for(Database.Error err : uResults[i].getErrors())
                            {
                                String errorRequiredFieldsAssess = null;
                                
                                mapErrorsCreation.put(assessmentsToBeInserted[i].AssessmentId__c, Label.Error + ':' + (errorRequiredFieldsAssess == null ? err.getMessage() : errorRequiredFieldsAssess));
                                assessmentErrorSet.add(assessmentsToBeInserted[i].AssessmentId__c);
                            }
                        }
                    }
                    
                    ///populate the json for success assessment that will be return as response
                    if(assessmentSuccessSet.size() > 0){
                        for(Assessment__c a : [SELECT   Id, Name, AssessmentId__c,AssessmentExternalId__c, AssessmentExtIdCallerSystem__c , TECH_EntityCountryCode__c, BodyShop__r.DirectOrderingProcess__c, BodyShop__c
                                               FROM     Assessment__c
                                               WHERE    Id IN: assessmentSuccessSet])
                        {
                            assessmentName += a.Name;
                            mapSuccessCreation.put(a.AssessmentId__c, 'Success');
                            //RLA 16/08/2018 C-002690 Spain audatex assessments in r4 
                            if (a.TECH_EntityCountryCode__c == 'ES' && String.isNotBlank(a.AssessmentExtIdCallerSystem__c)){
                                mapAssNumberInsertedES.put(a.AssessmentExtIdCallerSystem__c ,a);  
                            }

                            //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
                            if ( !(a.BodyShop__r.DirectOrderingProcess__c) && intUser.CreateToUpsert__c && string.isnotblank(intUser.callersystem__c)){
                                    //RLA 13/01/2020 C-004139: if no BS is found do not convert R3 to R4
                                    String bsRefNumber = searchR4bodyshop (bodyShopReferenceNumberSet,intUser.callersystem__c);
                                    if (String.isNotBlank(bsRefNumber)){
                                allowConversion = true;
                                mapAssToConvert.put(a.Id, a);
                                a.Status__c = ASPISConstants.ASSESS_STATUS_CANCELED;
                                mapAssessmentToUpdate.put(a.Id, a);
                            }
                        }
                            }
                        system.debug('@@ mapAssNumberInsertedES: '+ mapAssNumberInsertedES);               

                        if (mapAssNumberInsertedES.size() > 0){
                            for(Assessment__c a : [select Id,Status__c, AssessmentExtIdCallerSystem__c,AssessmentExternalId__c,AssessmentVersion__c 
                                                    FROM     Assessment__c
                                                    WHERE    AssessmentExtIdCallerSystem__c  IN: mapAssNumberInsertedES.keyset()
                                        AND Recordtype.Name = :ASPISConstants.ASSESS_RT_DeveloperName_Claim
                                        AND BodyShop__r.Type = 'Standard' //RLA 17/03/2020 C-003652: R4 SPain: do not create claim order on Expert Claims

                                        ])  {

                                //a.OrderAuthorised__c = true;
                                //mapAssUpdateES.put(a.Id,a);
                                if (mapAssNumberInsertedES.containsKey(a.AssessmentExtIdCallerSystem__c)){
                                    assessment__c tempAss = mapAssNumberInsertedES.get(a.AssessmentExtIdCallerSystem__c);
                                    tempAss.Status__c = ASPISConstants.ASSESS_STATUS_CANCELED;
                                    mapAssUpdateES.put(tempAss.Id, tempAss);
                                    mapAssessmentToUpdate.put(tempAss.Id, tempAss);
                                    newAssessmentId = tempAss.Id;
                                    assExtId = a.AssessmentExternalId__c;
                                    versionToQuote = a.AssessmentVersion__c;
                                    //setAssNumberFoundES.add(tempAss.AssessmentExternalId__c);
                                    //setAssNumberFoundES.add(tempAss.Id);
                                }                                
                            } 
                        }
                    }

                }

                genResults = JSON.createGenerator(false);
                genResults.writeStartArray();
                    if(mapSuccessCreation.size() > 0){
                        for(String suc : mapSuccessCreation.keySet()){
                            genResults.writeStartObject();
                                genResults.writeStringField('OperationType', 'Insert');
                                genResults.writeStringField('TechnicalId', mapExtIdNSFDCID.get(suc));
                                genResults.writeStringField('FunctionalId', suc);
                                genResults.writeBooleanField('Success', true);
                                if(mapErrorMessageAssessment.containsKey(suc)){
                                    genResults.writeStringField('Warning', 'Warning : ' + mapErrorMessageAssessment.get(suc));
                                }else{
                                    genResults.writeNullField('Warning');
                                }
                                genResults.writeNullField('ErrorMessage');
                            genResults.writeEndObject();
                        }
                    }

                    if(mapErrorsCreation.size() > 0){
                        for(String suc : mapErrorsCreation.keySet()){
                            genResults.writeStartObject();
                                genResults.writeStringField('OperationType', 'Insert');
                                genResults.writeNullField('TechnicalId');
                                genResults.writeStringField('FunctionalId', suc);
                                genResults.writeBooleanField('Success', false);
                                genResults.writeNullField('Warning');
                                genResults.writeStringField('ErrorMessage', 'Exceptions: ' + mapErrorsCreation.get(suc));
                            genResults.writeEndObject();
                        }
                    }

                    if(notValidForCreationSet.size() > 0){
                        for(String suc : notValidForCreationSet){
                            genResults.writeStartObject();
                                genResults.writeStringField('OperationType', 'Insert');
                                genResults.writeStringField('TechnicalId', '');
                                genResults.writeStringField('FunctionalId', suc);
                                genResults.writeBooleanField('Success', true);
                                genResults.writeStringField('Warning', 'WARNING: No assessment creation as no delta partlist.');
                                genResults.writeNullField('ErrorMessage');
                            genResults.writeEndObject();
                        }
                    }
                genResults.writeEndArray();

                results = genResults.getAsString();
                // System.debug('## results: '+results);                

                List<PartList__c> partsValidForInsertion = new List<PartList__c>();
                
                if(partsToBeInserted.size() > 0)
                {
                    for(PartList__c p : partsToBeInserted){
                        if(!assessmentErrorSet.contains(p.Assessment__r.AssessmentId__c)){
                            //DUN 13/06/2018 C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
                            if(!mapPartTypeDistributorsWrap.isEmpty()){
                                if(p.RecordTypeId != recordTypePartTypeMap.get('Labour')){
                                    p.Distributors__c = mapPartTypeDistributorsWrap.containsKey(p.Type__c) ? mapPartTypeDistributorsWrap.get(p.Type__c).FirstDistributor : null;
                                    p.NextDistributors__c = mapPartTypeDistributorsWrap.containsKey(p.Type__c) ? mapPartTypeDistributorsWrap.get(p.Type__c).NextDistributors : null;
                                }
                            }
                            partsValidForInsertion.add(p);
                        }
                    }

                    if(partsValidForInsertion.size() > 0){
                        //set of inserted parts
                        Set<Id> partIdsSet = new Set<Id>();
                        //validate partlist before inserting
                        Map<String,String> mapErrPartLists = validationPartList(partsValidForInsertion);
                        List<Database.saveResult> uResults = Database.insert(partsValidForInsertion, false);
                        //System.debug('## uResults: '+uResults);

                        for(Integer idx = 0; idx < uResults.size(); idx++) {
                            if(!uResults[idx].isSuccess()) {
                                JSONGenerator genErr = JSON.createGenerator(false);
                                genErr.writeStartArray();
                                for(Database.Error err : uResults[idx].getErrors()) {
                                    String errorRequiredFieldsPartList = null;
                                    
                                    if(mapErrPartLists.containsKey(partsValidForInsertion[idx].PartNumber__c)){
                                        errorRequiredFieldsPartList = mapErrPartLists.get(partsValidForInsertion[idx].PartNumber__c);
                                    }

                                    genErr.writeStartObject();
                                        genErr.writeStringField(partsValidForInsertion[idx].PartNumber__c, Label.Error + ':' + (errorRequiredFieldsPartList == null ? err.getMessage() : errorRequiredFieldsPartList));
                                    genErr.writeEndObject();
                                }
                                genErr.writeEndArray();
                            }
                            else{
                                // populate set of parts ids that have been successfully inserted
                                partIdsSet.add(uResults[idx].getId());
                            }
                        }

                        //assessment that should be modified
                        Set<Id> idAssessmentSet = new Set<Id>();
                        //part list thta have been inserted successfully
                        for(PartList__c pl : [SELECT Assessment__c, SelectedByBS__c FROM PartList__c WHERE Id IN: partIdsSet]){
                            //impacted assessment
                            idAssessmentSet.add(pl.Assessment__c);
                        }

                        Map<Id,List<PartList__c>> mapAssessmentIdNPartList = new Map<Id,List<PartList__c>>();
                        // select all partlist for the impacted assessment set
                        for(PartList__c pl : [SELECT Assessment__c, Type__c, SelectedByBS__c 
                                              FROM   PartList__c 
                                              WHERE  Assessment__c IN: idAssessmentSet
                                              AND    Type__c != null])
                        {
                            // ABT - WHY query those with no part type ? ... moved to query
                            // if(pl.Type__c  != null){
                                if(mapAssessmentIdNPartList.containsKey(pl.Assessment__c)){
                                    mapAssessmentIdNPartList.get(pl.Assessment__c).add(pl);
                                }else{
                                    mapAssessmentIdNPartList.put(pl.Assessment__c, new List<PartList__c>{pl});
                                }
                            // }
                        }

                        //list of assessment to be updated with the number of part a, part b, part c and part d
                        List<Assessment__c> assessmentToBeUpdated = new List<Assessment__c>();
                        for(Id assessmentId : mapAssessmentIdNPartList.keySet()){
                            Decimal partACount = 0;
                            Decimal partBCount = 0;
                            Decimal partCCount = 0;
                            Decimal partDCount = 0;

                            for(PartList__c pl : mapAssessmentIdNPartList.get(assessmentId)){
                                if(pl.Type__c == Label.VALUEPARTA){
                                    partACount += 1;
                                }else if(pl.Type__c == Label.VALUEPARTB){
                                    partBCount += 1;
                                }else if(pl.Type__c == Label.VALUEPARTC){
                                    partCCount += 1;
                                }else if(pl.Type__c == Label.VALUEPARTD){
                                    partDCount += 1;
                                }
                            }

                            if(mapAssessmentToUpdate.containsKey(assessmentId))
                            {
                                Assessment__c tempAss =  mapAssessmentToUpdate.get(assessmentId);
                                tempAss.PartA__c = partACount;
                                tempAss.PartB__c = partBCount;
                                tempAss.PartC__c = partCCount;
                                tempAss.PartD__c = partDCount;

                            }
                            else
                            {
                                // update assessmnet with the number of part a, part b, part c and part d
                                mapAssessmentToUpdate.put(assessmentId, new Assessment__c(  Id       = assessmentId,
                                                                                        PartA__c = partACount,
                                                                                        PartB__c = partBCount,
                                                                                        PartC__c = partCCount,
                                                                                        PartD__c = partDCount));
                            }

                        }
                    }
                }

                // launch eligibility
                List<Assessment__c> assessmentStatusToBeUpdated = new List<Assessment__c>();
                if(assessmentSuccessSet.size() > 0){
                    for(Id currentAssessmentId : assessmentSuccessSet)
                    {
                        //RLA 16/08/2018 C-002690 Spain audatex assessments in r4 
                        if (!mapAssUpdateES.containsKey(currentAssessmentId)
                            && !mapAssToConvert.containskey(currentAssessmentId)){//RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
                            if(mapAssessmentToUpdate.containsKey(currentAssessmentId))
                            {
                                mapAssessmentToUpdate.get(currentAssessmentId).Status__c = 'READY';
                            }
                            else
                            {
                                mapAssessmentToUpdate.put(currentAssessmentId, new Assessment__c(Id = currentAssessmentId, Status__c = 'READY'));
                            }
                        }
                    }
                }

                // launch eligibility
                // ABT Make all updates on assessment here
                if(mapAssessmentToUpdate.size() > 0)
                {
                    update mapAssessmentToUpdate.values();
                }
                //RLA 19/04/2019 C-003101: Manage Delta part List for SPain R4 
                if (String.isNotBlank(newAssessmentId)
                    && string.isNotBlank(assExtId)){
                    //RestProcessESAssessments.checkForClaim(setAssNumberFoundES);
                    RestProcessESAssessments.queryClaim(newAssessmentId, assExtId, versionToQuote);
                }

                //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
                if (mapAssToConvert.size() > 0){
                    //NPE 14/12/2021 C:004540
                    String newassId= '';
                    for (String assR3: mapAssToConvert.keySet()){
                        newassId = mapAssToConvert.get(assR3).Id;
                    }
                    string strReq = convertToR4(deserializedAssess, bodyShopReferenceNumberSet, intUser.callersystem__c, newassId); //NPE 14/12/2021 C:004540
                    sendToUpsert(strReq);
            }

            }
            }
            //RLA 21/01/2021  C-004154: Do not CreateAssessment with RestCreateAssessment
            else{
                genResults = JSON.createGenerator(false);
                genResults.writeStartArray();
                    genResults.writeStartObject();
                        genResults.writeStringField('OperationType', 'Insert');
                        genResults.writeNullField('TechnicalId');
                        genResults.writeNullField('FunctionalId');
                        genResults.writeBooleanField('Success', true);
                        genResults.writeStringField('Warning',system.label.SkipR3Assessment);
                        genResults.writeNullField('ErrorMessage');
                    genResults.writeEndObject();
                genResults.writeEndArray();

            results = genResults.getAsString();
            }

            return results;
        }
        catch(Exception ex)
        {
            genResults = JSON.createGenerator(false);
            genResults.writeStartArray();
                genResults.writeStartObject();
                    genResults.writeStringField('OperationType', 'Insert');
                    genResults.writeNullField('TechnicalId');
                    genResults.writeNullField('FunctionalId');
                    genResults.writeBooleanField('Success', false);
                    genResults.writeNullField('Warning');
                    genResults.writeStringField('ErrorMessage', 'Exceptions: ' + ex.getMessage());
                genResults.writeEndObject();
            genResults.writeEndArray();

            results = genResults.getAsString();

            return results;
        }
    }

    @TestVisible
    private static Boolean isPartSubstitute(String partNumber) {
        Boolean isSubstitute = false;
        if (String.isNotBlank(partNumber) && partNumber.startsWithIgnoreCase('ASCR-')) {
            isSubstitute = true;
        }
        return isSubstitute;
    }

    @TestVisible
    private static String getPartType(String partNumber, String partType) {
        String type;

        if (isPartSubstitute(partNumber)) {
            type = '';
        } else if (String.isBlank(partType)) {
            type = 'A';
        } else {
            type = partType;
        }
        return type;
    }

    // set Assessment__c.CrossReferences_c field
    @TestVisible
    private static void setCrossReferencesFieldForAssessment(List<Assessment__c> assessmentList, List<PartList__c> partList) {
        // Map < AssessmentID, Set<CrossRef number> >
        Map<Id, Set<String>> crossRefByAssessementMap = new Map<Id, Set<String>>();

        for (PartList__c part : partList) {
            if (isPartSubstitute(part.PartNumber__c)) {
                if (crossRefByAssessementMap.get(part.assessment__c) == null) {
                    crossRefByAssessementMap.put(part.assessment__c, new Set<String>());
                }
                crossRefByAssessementMap.get(part.assessment__c).add(part.PartNumber__c);
            }
        }

        for (Assessment__c assessment : assessmentList) {
            Set<String> crossRefSet = crossRefByAssessementMap.get(assessment.Id);
            if (crossRefSet != null) {
                assessment.CrossReferences__c = String.join(new List<String>(crossRefSet), ';');
            }
        }
    }

    //ASE: XX/04/2017: C-001907
    public static void checkEligibilityOfAssess(List<Assessment__c> createdAssessList, string bodyShopCountryCodePrefix){    
        System.debug('## start of checkEligibilityOfAssess');
        Assessment__c createdAssess= createdAssessList[0];

        List<Assessment__c> existingAssessList;
        System.debug('## bodyShopCountryCodePrefix'+bodyShopCountryCodePrefix);


        //RLA 20/12/2018 C-002964: Cancel DE-NewAssessment if a Claim Assessment has the same Claim Reference
        if (bodyShopCountryCodePrefix == 'DE'){
            system.debug('@@ got in');
            existingAssessList = [Select Id from Assessment__c where 
                                                    ClaimReference__c = :createdAssess.ClaimReference__c and
                                                    RecordTypeId = : Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId()
                                                ORDER BY CreatedDate DESC
                                                LIMIT 30];
        }
        else{
            existingAssessList = [Select Id from Assessment__c where BodyShop__c = :createdAssess.BodyShop__c and
                                                    ClaimReference__c = :createdAssess.ClaimReference__c and
                                                    RecordTypeId = : Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId() and
                                                    (VINNumber__c = :createdAssess.VINNumber__c or
                                                PlateNumber2__c = :createdAssess.PlateNumber2__c)
                                                ORDER BY CreatedDate DESC
                                                LIMIT 30];
        }
        system.debug('@@ existingAssessList'+existingAssessList);

        if(existingAssessList.size() > 0){
            createdAssess.AlreadyOrdered__c = true;
        }

        System.debug('## end of checkEligibilityOfAssess');
    }

    public static String removeSpaceHypen(String s)
    {
        s = s.replaceAll('\\s+', '');
        s = s.replaceAll('-', '');

        return s;
    }

    private static Map<String, Id> recordTypeAssessmentMap;
    private static Map<String, Id> recordTypePartTypeMap;
    
    /**
     * Function to populate the map of record types' developer name and its id
     */
    private static void populateRecordTypeMap()
    {
        //build map to store recordtype for sobject ASSESSMENT__c
        recordTypeAssessmentMap = new Map<String, Id>();

        //build map to store recordtype for sobject PartList__c
        recordTypePartTypeMap = new Map<String, Id>();

        Set<String> sObjectSet =  new Set<String>{Label.SOBJECTASSESSMENT, Label.SOBJECTPARTLIST};
        for(RecordType r : [SELECT  SobjectType, Id, DeveloperName 
                            FROM    RecordType 
                            WHERE   SobjectType IN: sObjectSet])
        {
            if(r.SobjectType == Label.SOBJECTASSESSMENT){
                recordTypeAssessmentMap.put(r.DeveloperName,r.Id);
            }
            if(r.SobjectType == Label.SOBJECTPARTLIST){
                recordTypePartTypeMap.put(r.DeveloperName,r.Id);
            }
        }
    }

    /**
     * Function to retrieve the Accounts using the References Number from the JSON
     * @param  bodyShopReferenceNumberSet The set of Reference Number obtained from the JSON
     * @return                            A map of reference number and Account
     */
    private static Map<String, Account> retrieveAccountMap(Set<String> bodyShopReferenceNumberSet)
    {
        Map<String, Account> mapRefNumberAccount = new Map<String, Account>();
        system.debug('@@@ bodyShopReferenceNumberSet: '+bodyShopReferenceNumberSet);
        //DUN 30/07/18 : C-001837 - Added CarBrandsSuppliedAgency__c
        for(Account currentAccount : [  SELECT Id, Name, ReferenceNumber__c , Feature__c, ShippingPostalCodeLeft2__c, CarBrandsSuppliedAgency__c
                                        FROM   Account 
                                        WHERE  ReferenceNumber__c IN: bodyShopReferenceNumberSet])
        {
            mapRefNumberAccount.put(currentAccount.ReferenceNumber__c, currentAccount);
        }

        return mapRefNumberAccount;
    }

    /**
     * Function to create Assessment instance
     * @param  assessmentWrapper The assessment wrapper
     * @param  transactionId     The transaction Id of the wrapper
     * @param  userRolePrefix    The prefix of role of the user
     * @param  addTimestamp      Whether to add timestamp in the AssessmentID__c
     * @return                   A populated assessment variable
     */
    private static Assessment__c createAssessmentVariable(Assessment assessmentWrapper, String transactionId, String userRolePrefix, Boolean addTimestamp)
    {
        Assessment__c currentAssessment = new Assessment__c(RecordTypeId              = recordTypeAssessmentMap.get(Label.RECTYPENEWASSESSMENT),
                                                            AssessmentNumber__c       = assessmentWrapper.AssessmentNumber,
                                                            TransactionId__c          = transactionId,
                                                            Entity__c                 = assessmentWrapper.Entity,
                                                            MissionNumber__c          = assessmentWrapper.MissionNumber,
                                                            Name                      = assessmentWrapper.Name,
                                                            PortfolioAgentCode__c     = assessmentWrapper.PortfolioAgentCode,
                                                            Status__c                 = 'NEW',
                                                            EntityCode__c             = assessmentWrapper.EntityCode,
                                                            ExpertValidationDate__c   = assessmentWrapper.ExpertValidationDate,
                                                            OrderOrigin__c            = 'Legacy');
        
        // currentAssessment.AssessmentID__c = userRolePrefix + assessmentWrapper.AssessmentNumber + datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        if(!addTimestamp)
        {
            currentAssessment.AssessmentID__c = userRolePrefix + assessmentWrapper.AssessmentNumber + transactionId;
        }
        else
        {
            currentAssessment.AssessmentID__c = userRolePrefix + assessmentWrapper.AssessmentNumber + transactionId + System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        }

        // claim
        if(assessmentWrapper.currentClaim != null)
        {
            Claim currentClaim                              = assessmentWrapper.currentClaim;
            currentAssessment.AbleToAuthoriseRepairs__c     = (currentClaim.AbleToAuthoriseRepairs == null ? false : currentClaim.AbleToAuthoriseRepairs);
            currentAssessment.AuthorisationStatus__c        = currentClaim.AuthorisationStatus;
            currentAssessment.CompanyName__c                = currentClaim.CompanyName;
            currentAssessment.ClaimReference__c             = currentClaim.ClaimReference;
            currentAssessment.DateOfIncident__c             = currentClaim.DateOfIncident;
            currentAssessment.EstimatedRepairTime__c        = currentClaim.EstimatedRepairTime;
            currentAssessment.IncidentReference__c          = currentClaim.IncidentReference;
            currentAssessment.OtherReference__c             = currentClaim.OtherReference;
            currentAssessment.PolicyNumber__c               = currentClaim.PolicyNumber;
            currentAssessment.RepairsAuthorised__c          = (currentClaim.RepairsAuthorised == null ? false : currentClaim.RepairsAuthorised);
            currentAssessment.VATPortionPayable__c          = currentClaim.VATPortionPayable;
            currentAssessment.WorkProvider__c               = currentClaim.WorkProvider;
            currentAssessment.SupposedOfFraud__c            = (currentClaim.Fraud == null ? false: currentClaim.Fraud);
            currentAssessment.TotalLoss__c                  = (currentClaim.TotalLoss == null ? false:currentClaim.TotalLoss);
            currentAssessment.Fleet__c                      = (currentClaim.Fleet == null ? false:currentClaim.Fleet);
            currentAssessment.SpecialRenting__c             = (currentClaim.Rental == null ? false:currentClaim.Rental);
            currentAssessment.SpecialAgreement__c           = (currentClaim.SpecialAgreement == null ? false:currentClaim.SpecialAgreement);
            currentAssessment.ExcessAmount__c               = currentClaim.ExcessAmount;
            // ASE: 14/10/2016: case 1645 added new fields
            currentAssessment.ProductCode__c                = currentClaim.ProductCode;
            currentAssessment.GroupAgentCode__c             = currentClaim.GroupAgentCode;
            currentAssessment.AgentCode__c                  = currentClaim.AgentCode;
            currentAssessment.SubAgentCode__c               = currentClaim.SubAgentCode;
            currentAssessment.Individual__c                 = (currentClaim.Individual == null) ? false : currentClaim.Individual;
            currentAssessment.CVM__c                        = currentClaim.CVM;
            currentAssessment.GuaranteeType__c              = currentClaim.GuaranteeType;
            currentAssessment.NetworkType__c                = currentClaim.NetworkType;
            currentAssessment.SubstitutionAccepted__c       = (currentClaim.SubstitutionAccepted == null) ? false : currentClaim.SubstitutionAccepted;
            currentAssessment.ExpertCode__c                 = currentClaim.ExpertCode;
            currentAssessment.TotalLabourAmtDiscount__c     = currentClaim.TotalLabourAmtDiscount;
            currentAssessment.TotalPaintingAmtDiscount__c   = currentClaim.TotalPaintingAmtDiscount;
            currentAssessment.TotalPartsAmtDiscount__c      = currentClaim.TotalPartsAmtDiscount;
            currentAssessment.ExpertType__c                 = currentClaim.ExpertType;
            currentAssessment.IDCIA__c                      = currentClaim.IDCIA;

            //RLA 16/08/2018 C-002690 Spain audatex assessments in r4
            if (String.isNotBlank(currentClaim.AssessmentExternalID)){
                string version = currentClaim.AssessmentExternalID.substringAfterLast('_');
                string extId = currentClaim.AssessmentExternalID.substringBeforeLast('_');
                currentAssessment.AssessmentExternalId__c       = extId;
                //RBE 30/11/2022 C-004850 
                if(String.isNotBlank(version))
                    currentAssessment.AssessmentVersion__c        = Decimal.valueOf(version);
                currentAssessment.AssessmentExtIdCallerSystem__c  = 'ES_AUDATEX' +  extId + '-' + version; 
                system.debug('@@ currentAssessment.AssessmentExtIdCallerSystem__c: '+currentAssessment.AssessmentExtIdCallerSystem__c);

            }

        }

        //Asset
        if(assessmentWrapper.currentAsset != null)
        {
            Asset currentAsset                              = assessmentWrapper.currentAsset;
            currentAssessment.BrakesPedalTravel__c          = currentAsset.BrakesPedalTravel;
            currentAssessment.BuildDate__c                  = currentAsset.BuildDate;
            currentAssessment.Colour__c                     = currentAsset.Colour;
            currentAssessment.DamageAreas__c                = currentAsset.DamageAreas;
            currentAssessment.DirectionImpact__c            = currentAsset.DirectionImpact;
            currentAssessment.Engine__c                     = currentAsset.Engine;
            currentAssessment.Manufacturer__c               = getBrand(currentAsset.Manufacturer);
            currentAssessment.ModelSheetNumber__c           = currentAsset.ModelSheetNumber;
            currentAssessment.ModelSpecs__c                 = currentAsset.ModelSpecs;
            currentAssessment.Odometer__c                   = currentAsset.Odometer;
            currentAssessment.PaintCode__c                  = currentAsset.PaintCode;
            currentAssessment.PlaceOfInspection__c          = currentAsset.PlaceOfInspection;
            currentAssessment.PlateNumber2__c               = removeSpaceHypen(currentAsset.PlateNumber);
            currentAssessment.PreAccidentCondition__c       = currentAsset.PreAccidentCondition;
            currentAssessment.PreAccidentDamage__c          = currentAsset.PreAccidentDamage;
            currentAssessment.RegistrationMonth__c          = currentAsset.RegistrationMonth;
            currentAssessment.RegistrationNumber__c         = currentAsset.RegistrationNumber;
            currentAssessment.RegistrationYear__c           = currentAsset.RegistrationYear;
            currentAssessment.SelectionType__c              = currentAsset.SelectionType;
            currentAssessment.SeverityOfImpact__c           = currentAsset.SeverityOfImpact;
            currentAssessment.SteeringRimPly__c             = currentAsset.SteeringRimPly;
            currentAssessment.TreadDepthLHF__c              = currentAsset.TreadDepthLHF;
            currentAssessment.TreadDepthLHR__c              = currentAsset.TreadDepthLHR;
            currentAssessment.TreadDepthRHF__c              = currentAsset.TreadDepthRHF;
            currentAssessment.TreadDepthRHR__c              = currentAsset.TreadDepthRHR;
            currentAssessment.VehicleStatusInspection__c    = currentAsset.VehicleStatusInspection;
            currentAssessment.VINNumber__c                  = currentAsset.VINNumber;
            currentAssessment.FirstRegistrationDate__c      = currentAsset.FirstRegistrationDate;
            currentAssessment.ModelV2__c                    = currentAsset.Model;
        }

        return currentAssessment;
    }

    /**
     * Function to create an instance of PartList__c using the parameters passed
     * @param  currentPartWrapper       The part wrapper
     * @param  assessmentExtId          The AssessmentID__c of the assessment to which the part will be attached
     * @param  quantityDecreasingFactor By how much the quantity should be decreased (for cases where there is a diff in number of quantity)
     * @return                          A populated part variable
     */
    private static PartList__c createPartVariable(Part currentPartWrapper, String assessmentExtId, Decimal quantityDecreasingFactor)
    {
        if(quantityDecreasingFactor == null)
        {
            quantityDecreasingFactor = 0;
        }

        PartList__c currentPart = new PartList__c(  Description__c          = currentPartWrapper.Description,
                                                    GuideNo__c              = currentPartWrapper.GuideNo,
                                                    HeldDate__c             = currentPartWrapper.HeldDate,
                                                    Name                    = currentPartWrapper.Name,
                                                    PartNumber__c           = currentPartWrapper.PartNumber,
                                                    PartNumberOptimized__c  = currentPartWrapper.PartNumberOptimized,
                                                    PriceOptimized__c       = currentPartWrapper.PriceOptimized,
                                                    Quantity__c             = Integer.valueOf(currentPartWrapper.Quantity) - quantityDecreasingFactor,
                                                    Status__c               = currentPartWrapper.Status,
                                                    Type__c                 = getPartType(currentPartWrapper.PartNumber, currentPartWrapper.Type),
                                                    //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
                                                    //VAT__c                  = ((currentPartWrapper.VAT == null) ? 0 : Integer.valueOf(currentPartWrapper.VAT)),
                                                    VAT__c                  = (mapConfigCountryCodeInfo.get(assessmentExtId.left(2)).CountryVAT__c != null) ? mapConfigCountryCodeInfo.get(assessmentExtId.left(2)).CountryVAT__c : null,
                                                    Compliance__c           = ((currentPartWrapper.Compliance == null) ? false : currentPartWrapper.Compliance),
                                                    Assessment__r           = new Assessment__c(AssessmentID__c = assessmentExtId),
                                                    SelectedByBS__c         = true,
                                                    RecordTypeId            = (currentPartWrapper.RecordType != null && recordTypePartTypeMap != null && recordTypePartTypeMap.containsKey(currentPartWrapper.RecordType)) ? recordTypePartTypeMap.get(currentPartWrapper.RecordType) : recordTypePartTypeMap.get('Material'));
        
        //DUN 13/06/2018 C-001837 : Give the possibility to create a Direct Sourcing Between Bodyshops and Distributors
        System.debug('## currentPartWrapper.RecordType' + currentPartWrapper.RecordType);
        if(/* currentPartWrapper.RecordType == 'Material' */ currentPartWrapper.RecordType != 'Labour' //WCH 29/10/2019 C-003444
            && Integer.valueOf(currentPartWrapper.Quantity)>0 /*WCH 13/06/2019 C-003286*/){
            setPartTypes.add(String.isBlank(currentPartWrapper.Type)?'A':currentPartWrapper.Type/*WCH 06/11/2019 C-003460*/);
        }
        System.debug('## setPartTypes' + setPartTypes);
        
        if(currentPartWrapper.Price != null){
            currentPart.Price__c = currentPartWrapper.Price;
        }
        else{
            if(!mapErrorMessageAssessment.containsKey(assessmentExtId)){
                mapErrorMessageAssessment.put(assessmentExtId, Label.ERRORACCOUNTNOTEXIST);
            }
            else{
                String existing = mapErrorMessageAssessment.get(assessmentExtId);
                String newError = existing + '- Price is null.';
                mapErrorMessageAssessment.put(assessmentExtId, newError);
            }
        }

        return currentPart;
    }

    private static void populateCarMappingMetadata(Set<String> callingSystemBrandSet) 
    {
        mapCarMapping = new Map<String, CarMappings__mdt>();

        for(CarMappings__mdt currentCarMapping : [  SELECT  MasterLabel, CarDestination__c 
                                                    FROM    CarMappings__mdt 
                                                    WHERE   MasterLabel IN: callingSystemBrandSet])
        {
            mapCarMapping.put(currentCarMapping.MasterLabel, currentCarMapping);
        }
    }

    private static String getBrand(String jsonBrand)
    {
        String brand    = jsonBrand;
        String key      = (callingSystem + '-' + jsonBrand).toUpperCase();

        if(mapCarMapping != null && mapCarMapping.containsKey(key))
        {
            brand = mapCarMapping.get(key).CarDestination__c;
        }

        return brand;
    }

    //RLA 15/01/2020 C-004138: Convert BS Reference into 10 digit format
    public static string convertBSRef(String bsRef){
        // string bsRef = '123456';

        if(String.isnotBlank(bsRef) && bsRef.length() < 10 ){
            integer lenRefNumber = bsRef.length();
            // system.debug(10-lenRefNumber );
            integer numZerosToAdd = 10-lenRefNumber ;
            for (integer i=0; i<numZerosToAdd ; i++){
                bsRef = '0' + bsRef;
            }
        }
        // system.debug(bsRef);
        // if(String.isnotBlank(bsRef) && (bsRef.left(2) != ('FR'))){
        //     bsRef = 'FR' + bsRef;
        // }
        system.debug(bsRef);

        return bsRef;


    }


    //RLA 13/01/2020 C-004139: if no BS is found do not convert R3 to R4
    public static string searchR4bodyshop(Set<String> bodyShopReferenceNumberSet, String callerSystem ){

        String refNumber = '';
        for (string bsId: bodyShopReferenceNumberSet){
            refNumber = bsid;
        }
        String bodyshopExtRef = '';
        
        system.debug('@@ refNumber: '+callerSystem + '-' + refNumber);
        if (String.isNotBlank(refNumber)){
            AccountRef__c accRef = AccountRef__c.getValues(callerSystem + '-' + refNumber);

            if (accRef != null){
                bodyshopExtRef = accref.ExternalReference__c;
            }

        }

        return bodyshopExtRef;
                
        }

    //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
    public static String convertToR4(Assessment deserializedAssess, Set<String> bodyShopReferenceNumberSet, String callerSystem , String assessmentR3){  //NPE 14/12/2021 C:004540

        //RLA 13/01/2020 C-004139: if no BS is found do not convert R3 to R4
        String bodyshopExtRef = searchR4bodyshop(bodyShopReferenceNumberSet, callerSystem);        

        RESTUpsertAssessmentV2.BodyShop BodyShop = new RESTUpsertAssessmentV2.BodyShop(bodyshopExtRef);

        RESTUpsertAssessmentV2.Claim Claim = new RESTUpsertAssessmentV2.Claim(
                                                deserializedAssess.currentClaim.TotalAmtLabour,
                                                deserializedAssess.currentClaim.TotalAmtLabourPainting,
                                                deserializedAssess.currentClaim.TotalAmtLabourExlPainting,
                                                deserializedAssess.currentClaim.TotalAmtPainting,
                                                deserializedAssess.currentClaim.TotalAmtPaintingInclLabour,
                                                deserializedAssess.currentClaim.AmtOthers,
                                                deserializedAssess.currentClaim.TotalAmtExlVAT,
                                                deserializedAssess.currentClaim.TotalVAT,
                                                deserializedAssess.currentClaim.TotalAmtInclVAT,
                                                deserializedAssess.currentClaim.QuotationAmountExlVAT,
                                                deserializedAssess.currentClaim.QuotationAmountInclVAT,
                                                deserializedAssess.currentClaim.NBHoursLabour,
                                                deserializedAssess.currentClaim.NBHoursLabourLevel1,
                                                deserializedAssess.currentClaim.NBHoursLabourLevel2,
                                                deserializedAssess.currentClaim.NBHoursLabourLevel3,
                                                deserializedAssess.currentClaim.NBHoursLabourPainting,
                                                deserializedAssess.currentClaim.ClaimReference,
                                                deserializedAssess.currentClaim.CompanyName,
                                                deserializedAssess.currentClaim.DateOfIncident    
                                                );

        RESTUpsertAssessmentV2.Asset Asset = new RESTUpsertAssessmentV2.Asset(
                                                deserializedAssess.currentAsset.Colour,
                                                deserializedAssess.currentAsset.FirstRegistrationDate,
                                                deserializedAssess.currentAsset.Manufacturer,
                                                deserializedAssess.currentAsset.Model,
                                                deserializedAssess.currentAsset.PlateNumber,
                                                deserializedAssess.currentAsset.VINNumber,
                                                // deserializedAssess.currentAsset.Manufacturer,
                                                deserializedAssess.currentAsset.KMS,
                                                deserializedAssess.currentAsset.PaintingType,
                                                deserializedAssess.currentAsset.Energy,
                                                deserializedAssess.currentAsset.VDSCode,
                                                deserializedAssess.currentAsset.BuildDate
                                                );

        List<RESTUpsertAssessmentV2.Part> lstParts = new list<RESTUpsertAssessmentV2.Part>();
        for (Part p: deserializedAssess.Parts){
             String partNumber = '\''+ p.PartNumber + '\'' ;
            if(!system.label.NonMaterialPartlist.contains(partNumber)){
                lstParts.add(new RESTUpsertAssessmentV2.Part(
                                                p.Name,
                                                p.PartNumber,
                                                p.Price,
                                                Decimal.ValueOf(p.Quantity),
                                                'Material',
                                                p.Status,
                                                'Automatic',
                                                p.Compliance 
                                                ));
            }
        }

        RESTUpsertAssessmentV2.Assesment Assesment = new RESTUpsertAssessmentV2.Assesment(
                                                     callerSystem,
                                                     deserializedAssess.Entity,
                                                     deserializedAssess.EntityCode,
                                                     1,
                                                     deserializedAssess.isShoppingList,
                                                     Claim,
                                                     Asset,
                                                     BodyShop,
                                                     lstParts,
                                                     true,
                                                     assessmentR3 //NPE 14/12/2021 C:004540
                                                    );
       
        String requestStr = '['+JSON.serialize(Assesment)+']';
        system.debug('@@@ restupsert string'+requestStr);


        // RESTUpsertAssessmentV2.Part Part = new RESTUpsertAssessmentV2.Part(deserializedAssess.currentBodyShop.ReferenceNumber);

        return requestStr;
    }

    @future
    public static void sendToUpsert(String requestStr){
        RestRequest request         = new RestRequest();
        request.httpMethod          = 'POST';
        request.requestURI          = '/v2.0/upsertAssessment/*';
        request.requestBody         = Blob.valueOf(requestStr);
        RestContext.request         = request;
        RestContext.response        = new RestResponse();
        
        request.requestBody         = Blob.valueOf(requestStr);

        RESTUpsertAssessmentV2.upsertAssessment();

    }

    class Assessment
    {
        public String TransactionID;
        public String AssessmentNumber;
        public Datetime BodyShopCreationDate;
        public String Entity;
        public Datetime ExpertValidationDate;
        public String MissionNumber;
        public String Name;
        public String PortfolioAgentCode;
        public String EntityCode;
        public Boolean isShoppingList;

        public Claim currentClaim;
        public Asset currentAsset;
        public BodyShop currentBodyShop;
        public List<Part> Parts;
    }

    class BodyShop
    {
        public String Name;
        public String ClientScoring;
        public String InvoicePeriod;
        public String OrderEmail;
        public String ReferenceNumber;
        public String BillingStreet;
        public String BillingZipCode;
        public String BillingCity;
        public String ShippingStreet;
        public String ShippingCity;
        public String ShippingZipCode;
    }

    class Claim
    {
        public Boolean AbleToAuthoriseRepairs;
        public String AuthorisationStatus;
        public String ClaimReference;
        public String CompanyName;
        public Date DateOfIncident;
        public Integer EstimatedRepairTime;
        public String IncidentReference;
        public String OtherReference;
        public String PolicyNumber;
        public Boolean RepairsAuthorised;
        public Decimal VATPortionPayable;
        public String WorkProvider;
        public Boolean Fraud;
        public Boolean TotalLoss;
        public Boolean Fleet;
        public Boolean Rental;
        public Boolean SpecialAgreement;
        public Decimal ExcessAmount;
        public Integer ProductCode;
        public Integer GroupAgentCode;
        public Integer AgentCode;
        public Integer SubAgentCode;
        public Boolean Individual;
        public String CVM;
        public String GuaranteeType;
        public String NetworkType;
        public Boolean SubstitutionAccepted;
        public String ExpertCode;
        public Decimal TotalLabourAmtDiscount;
        public Decimal TotalPaintingAmtDiscount;
        public Decimal TotalPartsAmtDiscount;
        public String ExpertType;
        public String IDCIA;
        public String AssessmentExternalID;  //RLA 17/09/2018 C-002690 Spain audatex assessments in r4
        //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
        public Decimal TotalAmtParts;
        public Decimal TotalAmtLabourPainting;
        public Decimal TotalAmtLabourExlPainting;
        public Decimal TotalAmtPainting;
        public Decimal TotalAmtPaintingInclLabour;
        public Decimal AmtOthers;
        public Decimal TotalAmtExlVAT;
        public Decimal TotalAmtInclVAT;
        public Decimal QuotationAmountExlVAT;
        public Decimal QuotationAmountInclVAT;
        public Decimal NBHoursLabour;
        public Decimal NBHoursLabourLevel1;
        public Decimal NBHoursLabourLevel2;
        public Decimal NBHoursLabourLevel3;
        public Decimal NBHoursLabourPainting;
        public Decimal TotalAmtLabour;
        public Decimal TotalVAT;
    
    }

    class Asset
    {
        public String BrakesPedalTravel;
        public Date BuildDate;
        public String Colour;
        public String DamageAreas;
        public String DirectionImpact;
        public String Engine;
        public String Manufacturer;
        public String Model;
        public String ModelSheetNumber;
        public String ModelSpecs;
        public String Odometer;
        public String PaintCode;
        public String PlaceOfInspection;
        public String PlateNumber;
        public String PreAccidentCondition;
        public String PreAccidentDamage;
        public String RegistrationMonth;
        public String RegistrationNumber;
        public Integer RegistrationYear;
        public String SelectionType;
        public String SeverityOfImpact;
        public String SteeringRimPly;
        public String TreadDepthLHF;
        public String TreadDepthLHR;
        public String TreadDepthRHF;
        public String TreadDepthRHR;
        public String VehicleStatusInspection;
        public String VINNumber;
        public Date FirstRegistrationDate;
        //RLA 18/11/2020 C-004030: From createAssessment to upsertAssessment
        public String KMS;
        public String PaintingType;
        public String Energy;
        public String VDSCode;

    }

    class Part
    {
        public String Description;
        public Integer GuideNo;
        public Date HeldDate;
        public String Name;
        public String PartNumber;
        public String PartNumberOptimized;
        public Decimal Price;
        public Decimal PriceOptimized;
        public String ProducerName;
        public String ProducerNameOptimized;
        public String Quantity;
        public String Recordtype;
        public String Status;
        public String Type;
        public String VAT;
        public Boolean Compliance;
    }
}