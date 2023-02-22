/*
  ----------------------------------------------------------------------
  -- - Name          : RESTrunSubstitution
  -- - Author        : ASE 
  -- - Description   : new web service runSubstitution, same as upsertAssessment with less field and only creation no updates at all.
  --                   WE call the web service create the assessment provide the list of alternative part and we finish the process.
  --
  -- Flow:
  --    1.  Deserialise request
  --    2.  Build Assessment Id
  --    3.  Retrieve the Assessment with same Assessment Ids
  --    4.  if (similar assessmentId exist in database){
  --            add a random index to the external id to the new Assessment
  --        }
  --    5.  create Assessment
  --    6.  loop in parts
  --    7.  Look for substitutes
  --    8. Insert Assessment
  --    9. Insert Parts
  --    10. Insert substitutes
  --    11. Generate Response
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 14-JUL-2016  ASE    1.0     Initial Version
  -- 14-SEP-2016  ABT    2.0     Re-write the flow of the class
  -- 22-SEP-2016  ABT    2.1     C-001728: Added the new function of create attachment
  -- 27-OCT-2016  ASE    2.2     retrieve carOrigin by splitting Name.
  -- 31-OCT-2017  AMI    3.0     updateField method param update due to 
  --                             ASPISServiceSubstitution getDescribeOptimisation
  -- 07-FEB-2019 RLA     4.0     C-002901: RunSubstitution: GT Motive doit envoyer le Transaction ID
  -- 04-JUN-2019 RLA     5.0     C-003143 : Preseletion de la pièce E pour la France 
  -- 08-Jan-2020 RLA     6.0     C-003513: B parts without distributor should not be proposed

  ----------------------------------------------------------------------
 **********************************************************************
*/
@RestResource(urlMapping='/v1.0/runSubstitution/*') 
global class RESTrunSubstitution 
{
    // static variables
    static Map<String, Id> recordTypePartTypeMap        = new Map<String, Id>();

    static Map<Id, String> recordIdNameMap;

    // STATIC VARIABLES
    // Map Assessment, Error Message
    static Map<String, String> mapErrorsCreation;
    // Map Account Ref
    static Map<String, AccountRef__c> mapAccountRef;
    // Map Car Mapping
    static Map<String, CarMapping__c> mapCarMapping;
    // Map Bodyshop (Id, Account)
    static Map<Id, Account> mapBodyshop;
    // Role Prefix which will determine country code
    static String rolePrefix;
    static Map<String, String> assessCarMap = new Map<String, String>();
    static map<String, set<String>> assessBSCategoriesMap = new map<String, set<String>>();


    //RLA 04/03/2020 C-003608: Do not substitute partlist if description contains echange standard and if FR DIVA
    static  String callerSystemGlo;

    @HttpPost
    global static void runSubstitution()
    {
       System.debug('---------------------------------- START RESTrunSubstitution - runSubstitution ----------------------------------');
        // variables
        String jsonResponse = '';
        recordIdNameMap     = new Map<Id, String>();

        //build map to store recordtype for sobject PartList__c
        for(RecordType r : [SELECT  SobjectType, Id, DeveloperName, Name
                            FROM    RecordType
                            WHERE   SobjectType =: Label.SOBJECTPARTLIST])
        {
            recordTypePartTypeMap.put(r.DeveloperName, r.Id);
            recordIdNameMap.put(r.Id, r.Name);
        }

        // Getting the countryCode from the role the user is executing this class
        User currentUser = [SELECT Id, UserRole.Name
                            FROM    User
                            WHERE   Id =: UserInfo.getUserId()];

        rolePrefix = (currentUser.UserRole != null && currentUser.UserRole.Name != null) ? currentUser.UserRole.Name.left(2) : '';

        // deserialise response
        // convert the requestbody into a String
        String body = RestContext.request.requestBody.toString();

        // create log
        Log__c log      = new Log__c();
        log.DateLog__c  = System.now();
        log.Class__c    = 'RESTrunSubstitution';

        insert log;

        if (body.length() <= 30000)
        {
            log.JSONMessage__c = body;
        }
        else 
        {
            // ABT - C-001728 - 22-SEP-2016
            //APCreateAttachments.createAttachment(body, log);
            APCreateAttachments.createAttachment('Request', body, log);
        }


        System.debug('## body: ' + body);

        if(body != null && body != '')
        {
            // call deserialiseResponse method
            jsonResponse = deserialiseResponse(body);

            //if(jsonResponse != null)
            //{
                if(jsonResponse.contains('Exceptions') || jsonResponse.contains('Error'))
                {
                    log.Status__c = Label.STATUSFAILED;
                }
                else
                {
                    log.Status__c = Label.STATUSPASSED;
                }

                log.sObject__c = 'Assessment__c';

                if(jsonResponse.length() <= 30000){
                    log.JSONResponse__c = jsonResponse;
                }
                else
                {
                    // ABT - C-001728 - 22-SEP-2016
                    //APCreateAttachments.createAttachment(body, log);
                    APCreateAttachments.createAttachment('Response', jsonResponse, log);
                }
            //}
            //else
            //{
            //  log.Status__c = Label.STATUSFAILED;
            //}

            update log;
        }

        System.debug('## jsonResponse: ' + jsonResponse);

        RestContext.response.responseBody = Blob.valueOf(jsonResponse);

        System.debug('---------------------------------- END RESTrunSubstitution - runSubstitution ----------------------------------');
    }

    public static String deserialiseResponse(String body)
    {
        System.debug('---------------------------------- START RESTrunSubstitution - deserialiseResponse ----------------------------------');

        // Initialisation of static variables
        mapErrorsCreation   = new Map<String, String>();
        mapAccountRef       = new Map<String, AccountRef__c>();
        mapCarMapping       = new Map<String, CarMapping__c>();
        mapBodyshop         = new Map<Id, Account>();

        // Method variables
        // Response of processing
        String response;
        // Set containing Ids retrieved from account ref
        Set<Id> bodyshopInternalReferenceSet                                                    = new Set<Id>();
        // List of the JSON for each valid assessment
        List<Map<String, Object>> validAssessmentList                                           = new List<Map<String, Object>>();
        // Map Assessment Id -> JSON Received (Assessment)
        Map<String, Map<String, Object>> mapAssessmentIdJSONReceived                            = new Map<String, Map<String, Object>>();
        // Map Assessment Id -> AccountRef
        Map<String, AccountRef__c> mapAssessmentIdAccountRef                                    = new Map<String, AccountRef__c>();
        // Map Assessment Id -> Car Mapping
        Map<String, CarMapping__c> mapAssessmentIdCarMapping                                    = new Map<String, CarMapping__c>();
        // Map Assessment Id -> Entity Code
        Map<String, String> mapAssessmentIdEntityCode                                           = new Map<String, String>();
        // Map Assessment Id -> CountryCode
        //Map<String, String> mapAssessmentIdCountryCode                                            = new Map<String, String>();
        // Map Entity Rule -> Map AssessmentId - Brand - Country Code -> Part List
        Map<String, Map<String, List<Object>>> mapEntityRuleAssessmentPart                      = new Map<String, Map<String, List<Object>>>();
        // Map AssessmentId -> List of Cross Reference
        Map<String, List<CrossReference__c>> mapPartNumberManufacturerListCrossRef              = new Map<String, List<CrossReference__c>>();
        // Map AssessmentId -> Cross Reference (Best Cross Ref found by master rule)
        Map<String, CrossReference__c> mapPartNumberManufacturerBestCrossRef                    = new Map<String, CrossReference__c>();
        // Map Entity Rule -> Substitute Wrapper
        Map<String, ASPISServiceSubstitution.SubstituteWrapper> mapEntityRuleSubstituteWrapper  = new Map<String, ASPISServiceSubstitution.SubstituteWrapper>();
        // Map Assessment Id -> assessment
        Map<String, Assessment__c> mapAssessmentIdAssessment                                    = new Map<String, Assessment__c>();
        // Map Assessment Id -> original Parts
        Map<String, List<PartList__c>> mapAssessmentIdOriginalParts                             = new Map<String, List<PartList__c>>();
        // Map Assessment Id -> substitute Parts
        Map<String, List<PartList__c>> mapAssessmentIdSubstituteParts                           = new Map<String, List<PartList__c>>();

        //ASE: 02/03/2017: C-001885
        Set<String> carMapBrandSet = new Set<String>();
        Map<String, String> carMapBrandMap = new Map<String, String>();
        Map<String, String> carMapCrossRefMap  = new Map<String, String>();
        Set<String> carMapCrossRefSet = new Set<String>();

        try{
            // deserialize body
            List<Object> objList = (List<Object>) JSON.deserializeUntyped(body);

            if(!objList.isEmpty())
            {
                // Variable to know which index of the list of objects is being processed
                Integer position = 0;

                //ASE: 02/03/2017: C-001885
                //get carMapping from carMapping metadata to alphaScale manufacturer equivalent
                for(Object receivedAssess : objList){
                    Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;
                    String callerSystem = (receivedAssessMap.get('callerSystem') != null && receivedAssessMap.get('callerSystem') != '') ? (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase() : null;
                    String brand; 
                    if(receivedAssessMap.get('currentAsset') != null){
                        Map<String, Object> currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');    
                        brand = (currentAssetMap.get('Brand') != null && currentAssetMap.get('Brand') != '') ? String.valueOf(currentAssetMap.get('Brand')) : null;
                    }

                    if(callerSystem != null && brand !=null){
                        //carMapBrandSet.add((callerSystem + '_' +brand).toUpperCase()); 
                        carMapBrandSet.add((callerSystem + '-' +brand).toUpperCase()); 
                    }                      
                }
                system.debug('## carMapBrandSet:'+carMapBrandSet);

                //get carMapping from carMapping metadata to alphaScale manufacturer equivalent
                for(CarMappings__mdt carMapMdt : [Select MasterLabel, CarDestination__c from CarMappings__mdt where MasterLabel in: carMapBrandSet]){
                    if(!carMapBrandMap.containsKey(carMapMdt.MasterLabel)){
                        carMapBrandMap.put(carMapMdt.MasterLabel, carMapMdt.CarDestination__c);
                    }
                    //carMapCrossRefSet.add(('CATALOG_' + carMapMdt.CarDestination__c).toUpperCase()); 
                    carMapCrossRefSet.add(('CATALOG-' + carMapMdt.CarDestination__c));
                }
                system.debug('## carMapCrossRefSet:'+carMapCrossRefSet);
                system.debug('## carMapBrandMap:'+carMapBrandMap);

                //get carMapping from carMapping metadata to alphaScale manufacturer equivalent
                for(CarMappings__mdt carMapMdt : [Select MasterLabel, CarDestination__c from CarMappings__mdt where MasterLabel in: carMapCrossRefSet]){
                    if(!carMapCrossRefMap.containsKey(carMapMdt.MasterLabel)){
                        carMapCrossRefMap.put(carMapMdt.MasterLabel, carMapMdt.CarDestination__c);
                    }
                }
                system.debug('## carMapCrossRefMap:'+carMapCrossRefMap);


                // loop in received JSON and to determine if ReferenceNumber or callerSystem exists and get Account Ref
                for(Object receivedAssess: objList){
                    Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;

                    // Run check for mandatory fields on the current object
                    Boolean isValid = checkMandatoryFields(receivedAssessMap, position);
                    system.debug('## isValid:'+isValid);

                    // check if it is valid to process it
                    if(isValid)
                    {
                        // build criteria to select from AccountRef__c with matches ReferenceNumber and callerSystem
                        if(receivedAssessMap.get('currentBodyShop') != null)
                        {

                            String refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber'));
                            String callerSystem = (receivedAssessMap.get('callerSystem') == null) ? 'GTMOTIVE' : String.valueOf(receivedAssessMap.get('callerSystem')).toUpperCase();
                            String brand        = (receivedAssessMap.get('currentAsset') == null) ? null : String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('Brand'));

                            // check if mapping exists in Account reference
                            AccountRef__c accRef = AccountRef__c.getValues(callerSystem + '-' + refNumber);

                            //CarMapping__c carMap = CarMapping__c.getValues(callerSystem + '-' + brand);

                            if(accRef == null)
                            {
                                mapErrorsCreation.put('Assessment at position[' + position +']', 'Error: No Account Reference Mapping found');

                                // Increment the index before going to the next assessment
                                position++;

                                // will stop processing and will go to the next assessment
                                continue;
                            }
                            // C-001885
                            //else if(carMap == null)
                            /*else if(!carMapBrandMap.containsKey(callerSystem + '-' +brand)){
                                String manufacturerBrand  =carMapBrandMap.get(callerSystem + '-' +brand);
                                if(!carMapCrossRefMap.containsKey('CATALOG-' + manufacturerBrand)){         
                                    mapErrorsCreation.put('Assessment at position[' + position +']', 'Error: No Car Mapping found');

                                    // Increment the index before going to the next assessment
                                    position++;

                                    // will stop processing and will go to the next assessment
                                    continue;
                                }
                            }*/

                            // both accRef and carMap are not null when this part is being executed

                            String assessNum = String.valueOf(receivedAssessMap.get('AssessmentNumber'));
                            System.debug('## assessNum: ' + assessNum);


                            // Account Reference
                            mapAccountRef.put(accRef.Name, accRef);
                            bodyshopInternalReferenceSet.add(accRef.InternalReference__c);

                            // Car Mapping
                            //mapCarMapping.put(carMap.Name, carMap);

                            // list that contains all the assessment that is valid to be processed
                            validAssessmentList.add(receivedAssessMap);
                        }

                        // Increment the index for each loop
                        position++;                        
                    }
                }
            }

            // query the internal reference from account
            if(bodyshopInternalReferenceSet.size() > 0){
                for(Account acc: [  SELECT  Id, ShippingCountryCode, Categories__c   
                                    FROM    Account
                                    WHERE   Id IN: bodyshopInternalReferenceSet]){
                    mapBodyshop.put(acc.Id, acc);
                }
            }

            // Building the assessment external Id
            if(validAssessmentList.size() > 0)
            {
                List<String> assessmentIdToQueryList = new List<String>();

                for(Map<String, Object> receivedAssessMap : validAssessmentList)
                {
                    String callerSystem     = (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase();
                    callerSystemGlo = callerSystem;
                    String refNumber        = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber'));
                    String brand            = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('Brand'));

                    String accountRefKey    = callerSystem + '-' + refNumber;
                    //String carMappingKey    = callerSystem + '-' + brand;
                    String carMappingKey    = (callerSystem + '-' + brand).toUpperCase();

                    String entityCode       = String.valueOf(receivedAssessMap.get('EntityCode'));

                    //String shipCountryCode    =   (   mapAccountRef.get(accountRefKey).InternalReference__c != null &&
                    //                              mapBodyshop.containsKey(mapAccountRef.get(accountRefKey).InternalReference__c)
                    //                          )
                    //                          ?
                    //                              mapBodyshop.get(mapAccountRef.get(accountRefKey).InternalReference__c).ShippingCountryCode
                    //                          :
                    //                              null;
                    //
                    //String countryCode        = shipCountryCode != null ? shipCountryCode : 'ES';

                    String assessNumber     = String.valueOf(receivedAssessMap.get('AssessmentNumber'));

                    // case C-001885
                    String callerCarDest = carMapBrandMap.get(carMappingKey);
                    String catalogCarDest = carMapCrossRefMap.get('CATALOG-'+callerCarDest);
                    system.debug('## callerCarDest: '+callerCarDest);
                    system.debug('## catalogCarDest: '+catalogCarDest);
                    

                    String assessmentId     = 'SUBSTIT' +
                                              rolePrefix +
                                              refNumber +
                                              //mapCarMapping.get(carMappingKey).CarCrossRef__c +
                                              callerCarDest +
                                              assessNumber;

                    // Now we build our query condition to retrieve existing assessment
                    assessmentIdToQueryList.add(assessmentId + '%');

                    assessCarMap.put(assessmentID, brand + ';' + callerCarDest + ';' + catalogCarDest);

                    String BScategories    =  (mapAccountRef.get(accountRefKey).InternalReference__c != null && mapBodyshop.containsKey(mapAccountRef.get(accountRefKey).InternalReference__c)) ?
                                                  mapBodyshop.get(mapAccountRef.get(accountRefKey).InternalReference__c).Categories__c : null;

                    Set<String> BScategoriesSet;                              
                    if(BScategories != null){
                        BScategoriesSet = new Set<String>(BScategories.split(';'));
                    }
                    assessBSCategoriesMap.put(assessmentID, BScategoriesSet);
                    system.debug('## assessBSCategoriesMap in class:'+assessBSCategoriesMap);

                    system.debug('## assessCarMap: '+assessCarMap);
                }

                System.debug('## assessmentIdToQueryList: ' + assessmentIdToQueryList);

                // Map AssessmentId -> Max Index (-1 -2 -3)
                Map<String, Integer> mapOriginalAssessmentIdCounter = new Map<String, Integer>();

                // Retrieve the existing assessment
                for(Assessment__c existingAssessment : [SELECT  Id, AssessmentId__c
                                                        FROM    Assessment__c
                                                        WHERE   AssessmentId__c LIKE: assessmentIdToQueryList])
                {
                    String originalAssessmentId = existingAssessment.AssessmentId__c.substringBeforeLast('-');

                    Integer index               = (existingAssessment.AssessmentId__c.substringAfterLast('-') != '') ? Integer.valueOf(existingAssessment.AssessmentId__c.substringAfterLast('-')) : 0;

                    if(mapOriginalAssessmentIdCounter.containsKey(originalAssessmentId))
                    {
                        if(index > mapOriginalAssessmentIdCounter.get(originalAssessmentId))
                        {
                            mapOriginalAssessmentIdCounter.put(originalAssessmentId, index);
                        }
                    }
                    else
                    {
                        mapOriginalAssessmentIdCounter.put(originalAssessmentId, index);
                    }
                }


                // We have our existing assessment with the max index if the current assessment
                for(Map<String, Object> receivedAssessMap : validAssessmentList)
                {
                    String callerSystem     = (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase();
                    String refNumber        = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber'));
                    String brand            = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('Brand'));

                    String accountRefKey    = callerSystem + '-' + refNumber;
                    String carMappingKey    = (callerSystem + '-' + brand).toUpperCase();

                    String entityCode       = String.valueOf(receivedAssessMap.get('EntityCode'));

                    //String shipCountryCode    =   (   mapAccountRef.get(accountRefKey).InternalReference__c != null &&
                    //                              mapBodyshop.containsKey(mapAccountRef.get(accountRefKey).InternalReference__c)
                    //                          )
                    //                          ?
                    //                              mapBodyshop.get(mapAccountRef.get(accountRefKey).InternalReference__c).ShippingCountryCode
                    //                          :
                    //                              null;
                    //
                    //String countryCode        = shipCountryCode != null ? shipCountryCode : 'ES';

                    String assessNumber     = String.valueOf(receivedAssessMap.get('AssessmentNumber'));

                    String callerCarDest = carMapBrandMap.containsKey(carMappingKey) ? carMapBrandMap.get(carMappingKey) : null;
                    String catalogCarDest = callerCarDest != null ? carMapCrossRefMap.get('CATALOG-'+callerCarDest): null;

                    String assessmentId     = 'SUBSTIT' +
                                              rolePrefix +
                                              refNumber +
                                              //mapCarMapping.get(carMappingKey).CarCrossRef__c +
                                              carMapBrandMap.get(carMappingKey) +
                                              assessNumber;



                    // Check in the map of AssessmentId__c -> Max Index to know if there are assessment with the same assessmentId exists
                    if(mapOriginalAssessmentIdCounter.containsKey(assessmentId))
                    {
                        Integer additiveIndex = mapOriginalAssessmentIdCounter.get(assessmentId);
                        assessmentId  += '-' + ++additiveIndex;
                    }

                    assessCarMap.put(assessmentID, brand + ';' + callerCarDest + ';' + catalogCarDest);
                    system.debug('## assessCarMap: '+assessCarMap);


                    //mapAssessmentIdCountryCode.put(assessmentId, rolePrefix);

                    // popoulate this map with valid assessments <assessmentId, assessment>
                    mapAssessmentIdJSONReceived.put(assessmentId, receivedAssessMap);

                    // build map <AssessmentId, accountReference__c>
                    mapAssessmentIdAccountRef.put(assessmentId, mapAccountRef.get(accountRefkey));

                    // build map <AssessmentId, carRef>
                    //mapAssessmentIdCarMapping.put(assessmentId, mapCarMapping.get(carMappingKey));

                    // build map <AssessmentId, entityCode>
                    mapAssessmentIdEntityCode.put(assessmentId, entityCode);





                    String entityRule = rolePrefix + entityCode;
                    //String crossRefBrand = mapCarMapping.get(carMappingKey).CarCrossRef__c;
                    String crossRefBrand =assessCarMap.get(assessmentId).split(';')[2];
                    // ASE: C-002692 : 27/09/2018 
                    String assessmentIdBrandCountryCode = assessmentId + '-' + crossRefBrand + '-' + rolePrefix + '-' + rolePrefix;

                    // Building the Map Entity Rule -> Map AssessmentId - Brand - Country Code -> Part List
                    if(mapEntityRuleAssessmentPart.containsKey(entityRule))
                    {
                        // check if the key AssessmentId - Brand - Country Code already exists
                        //if(mapEntityRuleAssessmentPart.get(entityRule).containsKey(assessmentIdBrandCountryCode))
                        //{
                        //  mapEntityRuleAssessmentPart.get(entityRule).get(assessmentIdBrandCountryCode).addAll((List<Object>) receivedAssessMap.get('Parts'));
                        //}
                        //else
                        //{
                            mapEntityRuleAssessmentPart.get(entityRule).put(assessmentIdBrandCountryCode, (List<Object>) receivedAssessMap.get('Parts'));
                        //}
                    }
                    else
                    {
                        mapEntityRuleAssessmentPart.put(entityRule,
                                                        new Map<String, List<Object>>
                                                        {
                                                            assessmentIdBrandCountryCode => (List<Object>) receivedAssessMap.get('Parts')
                                                        });
                    }
                }

                // Loop in the mapEntityRuleAssessmentPart to run the class ASPISServiceSubstitution
                for(String entityRule : mapEntityRuleAssessmentPart.keySet())
                {
                    //RLA 14/08/2019 C-003355 : Add 'A' Prefix on Mercedes parts to query subsitutes
                    //RLA 08/01/2020 C-003513: B parts without distributor should not be proposed
                    ASPISServiceSubstitution.SubstituteWrapper substitutionWrapper = ASPISServiceSubstitution.runSubstitution(mapEntityRuleAssessmentPart.get(entityRule), entityRule, assessBSCategoriesMap, false,false,callerSystemGlo, '', '', false,false,false);

                    mapEntityRuleSubstituteWrapper.put(entityRule, substitutionWrapper);

                    for(String assessmentId : substitutionWrapper.mapAssMapOEMKeyListIAM.keySet())
                    {
                        mapPartNumberManufacturerListCrossRef.putAll(substitutionWrapper.mapAssMapOEMKeyListIAM.get(assessmentId));
                        mapPartNumberManufacturerBestCrossRef.putAll(substitutionWrapper.mapAssessmentIAMFinal.get(assessmentId));
                    }
                }
                System.debug('## mapEntityRuleSubstituteWrapper: ' + mapEntityRuleSubstituteWrapper);

                // Generating the assessment, parts, substitutes
                for(String assessmentId : mapAssessmentIdJSONReceived.keySet())
                {
                    Map<String, Object> receivedAssessMap   = mapAssessmentIdJSONReceived.get(assessmentId);

                    // Extracting the county code from the assessmentId
                    //String countryCode                        = mapAssessmentIdCountryCode.get(assessmentId);

                    // Retrieving the entity code from the map
                    String entityCode                       = mapAssessmentIdEntityCode.get(assessmentId);

                    //String crossRefBrand                    = mapAssessmentIdCarMapping.get(assessmentId).CarCrossRef__c;
                    list<String> assessCarMapList=  assessCarMap.get(assessmentId).split(';');
                    String manufacturer = assessCarMapList[1] != 'null' ? assessCarMapList[1]: assessCarMapList[0];
                    String crossRefBrand = assessCarMapList[2];
                    //String crossRefBrand                    = assessCarMap.get(assessmentId).split(';')[2];
                    Id bodyshopId                           = mapAssessmentIdAccountRef.get(assessmentId).InternalReference__c;

                    Assessment__c assessment                = createAssessment(assessmentId, receivedAssessMap, manufacturer, bodyshopId);

                    List<PartList__c> partList              = createPartList(assessmentId, (List<Object>) receivedAssessMap.get('Parts'));

                    List<PartList__c> substituteList        = createSubstitute(assessmentId,
                                                                                partList,
                                                                                crossRefBrand,
                                                                                mapEntityRuleSubstituteWrapper.get(rolePrefix + entityCode).mapAssMapOEMKeyListIAM.get(assessmentId),
                                                                                mapEntityRuleSubstituteWrapper.get(rolePrefix + entityCode).mapAssessmentIAMFinal.get(assessmentId),
                                                                                mapEntityRuleSubstituteWrapper.get(rolePrefix + entityCode).listUpdateFieldsCriteria);

                    mapAssessmentIdAssessment.put(assessmentId, assessment);
                    mapAssessmentIdOriginalParts.put(assessmentId, partList);
                    mapAssessmentIdSubstituteParts.put(assessmentId, substituteList);

                }

                insertAll(  mapAssessmentIdAssessment,
                            mapAssessmentIdOriginalParts,
                            mapAssessmentIdSubstituteParts);
            }

            response = generateResponse(mapAssessmentIdAssessment,
                                        mapAssessmentIdOriginalParts,
                                        mapPartNumberManufacturerListCrossRef,
                                        mapPartNumberManufacturerBestCrossRef,
                                        mapAssessmentIdAccountRef,
                                        mapAssessmentIdCarMapping);

            //System.debug('## mapAssessmentIdJSONReceived: ' + mapAssessmentIdJSONReceived);
            //System.debug('## mapAssessmentIdAccountRef: ' + mapAssessmentIdAccountRef);
            //System.debug('## mapAssessmentIdCarMapping: ' + mapAssessmentIdCarMapping);
            //System.debug('## mapAssessmentIdEntityCode: ' + mapAssessmentIdEntityCode);
        }
        catch(Exception ex){
            System.debug('## exception: ' + ex.getStackTraceString());
            JSONGenerator genResults  = JSON.createGenerator(false);
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

            response = genResults.getAsString();
        }

        System.debug('---------------------------------- END RESTrunSubstitution - deserialiseResponse ----------------------------------');
        return response;
    }

    public static Assessment__c createAssessment(String assessmentId, Map<String, Object> receivedAssessMap, String manufacturer, Id bodyshopId)
    {
        System.debug('---------------------------------- START RESTrunSubstitution - createAssessment ----------------------------------');

        // build currentAssetMap
        Map<String, Object> currentAssetMap;
        if(receivedAssessMap.get('currentAsset') != null)
        {
            currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');
        }

        Assessment__c newAssess = new Assessment__c (
                                                        Name                        = String.valueOf(receivedAssessMap.get('Name')),
                                                        EntityCode__c               = String.valueOf(receivedAssessMap.get('EntityCode')),
                                                        VINCheck__c                 = Integer.valueOf(receivedAssessMap.get('VINCheck')),
                                                        Status__c                   = 'SUBSTITUTION',
                                                        TECH_EntityCountryCode__c   = rolePrefix,
                                                        EntityRules__c              = rolePrefix + String.valueOf(receivedAssessMap.get('EntityCode')),
                                                        AssessmentID__c             = assessmentId,
                                                        AssessmentNumber__c         = String.valueOf(receivedAssessMap.get('AssessmentNumber')),
                                                        BodyShop__c                 = bodyshopId,
                                                        Manufacturer__c             = manufacturer,
                                                        RecordTypeId                = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId(),
                                                        CallerSystem__c             = String.valueOf(receivedAssessMap.get('callerSystem')),
                                                        TransactionId__c            =  String.valueOf(receivedAssessMap.get('TransactionID')) //RLA 07/02/2019 C-002901: RunSubstitution: GT Motive doit envoyer le Transaction ID
                                                    );

        if(currentAssetMap != null)
        {
            if(currentAssetMap.get('FirstRegistrationDate') != null && !String.isBlank(String.valueOf(currentAssetMap.get('FirstRegistrationDate'))))
            {
                newAssess.FirstRegistrationDate__c = (Date) JSON.deserialize('"' + currentAssetMap.get('FirstRegistrationDate') + '"', Date.class);
            }
        }

        System.debug('---------------------------------- END RESTrunSubstitution - createAssessment ----------------------------------');
        return newAssess;
    }

    public static List<PartList__c> createPartList(String assessmentId, List<Object> objPartList)
    {
        System.debug('---------------------------------- START RESTrunSubstitution - createPartList ----------------------------------');

        List<PartList__c> newPartList = new List<PartList__c>();

        // Loop in the parts received and create an instance for it
        for(Object part : objPartList)
        {
            // Casting the object to a map string -> object
            Map<String, Object> partMap = (Map<String, Object>) part;

            String partName     = String.valueOf(partMap.get('Name'));
            String partNumber   = String.valueOf(partMap.get('PartNumber'));
            String manufacturer = String.valueOf(partMap.get('Manufacturer'));

            newPartList.add(new PartList__c (
                                                Name                    = partName,
                                                Description__c          = String.valueOf(partMap.get('Description')),
                                                PartNumber__c           = partNumber,
                                                ProducerName__c         = manufacturer,
                                                Type__c                 = String.valueOf(partMap.get('Type')),
                                                InputType__c            = String.valueOf(partMap.get('InputType')),
                                                Currency__c             = String.valueOf(partMap.get('Currency')),
                                                Price__c                = Double.valueOf(partMap.get('Price')),
                                                Quantity__c             = Integer.valueOf(partMap.get('Quantity')),
                                                Compliance__c           = partMap.get('Compliance') != null ? Boolean.valueOf(partMap.get('Compliance')) : false,
                                                Assessment__r           = new Assessment__c(AssessmentID__c = assessmentId),
                                                RecordTypeId            = recordTypePartTypeMap.get(String.valueOf(partMap.get('RecordType'))),
                                                TECH_OriginalPart__c    = null + '-'
                                                                        + partNumber + '-'
                                                                        + partName.replaceAll('\\s+', '') + '-'
                                                                        + manufacturer + '-'
                                                                        + assessmentId + '-'
                                                                        + null
                                            ));
        }

        System.debug('---------------------------------- END RESTrunSubstitution - createPartList ----------------------------------');

        return newPartList;
    }

    public static List<PartList__c> createSubstitute(String assessmentId,
                                                     List<PartList__c> originalPartList,
                                                     String crossRefBrand,
                                                     Map<String, List<CrossReference__c>> OEMIAMMap,
                                                     Map<String, CrossReference__c> OEMIAMPriceMap,
                                                     List<DetailRule__c> listFieldUpdatesDetailRules
                                                     )
    {
        System.debug('---------------------------------- START RESTrunSubstitution - createSubstitute ----------------------------------');

        List<PartList__c> substituteList = new List<PartList__c>();
        List<PartList__c> substituteToUpdateList = new List<PartList__c>();
                           
        //AMI 31/10/17 - updateField method param update due to ASPISServiceSubstitution getDescribeOptimisation
        //A map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects.
        Map<String, Schema.SObjectType> gloDescribe = Schema.getGlobalDescribe();  
        
        //objectType is the object type
        Schema.SObjectType objectTypeUpdateF = gloDescribe.get('PartList__c');
        
        //get map of fields for the object above
        Map<String, Schema.SobjectField> fieldMapUpdateF = objectTypeUpdateF.getDescribe().fields.getMap();

        //this set is used to know if field was already described
        set <string> setDescribedUpdateF = new set <string>();

        //map used so that getDescribe is run only one time for fieldtype for best match method
        map <string,Schema.DisplayType> mapUpdateFFieldType = new map <string,Schema.DisplayType>();

        for(PartList__c originalPart : originalPartList)
        {
            String cleanseKey           = cleanseReference(originalPart.PartNumber__c) + '-' + crossRefBrand;
            String nonCleanseKey        = originalPart.PartNumber__c + '-' + crossRefBrand;
            String nonCleansePartNumber = originalPart.PartNumber__c;

            if(OEMIAMMap != null &&
               OEMIAMMap.containsKey(cleanseKey))
            {
                // Getting the best CrossRef returned by the master rule
                CrossReference__c bestCrossRef = OEMIAMPriceMap.containsKey(cleanseKey) ? OEMIAMPriceMap.get(cleanseKey) : null;

                // Loop in the Cross Reference using the cleanse key
                for(CrossReference__c crossRef : OEMIAMMap.get(cleanseKey))
                {
                    //String substitutePartName = (crossRef.IAMPartDescription__c != null) ? crossRef.IAMPartDescription__c.left(80) : crossRef.IAMPartNumber__c;
                    String IAMDescription = (crossRef.IAMPartDescription__c != null) ? crossRef.IAMPartDescription__c : crossRef.OEMPartDescription__c;    
                    String substitutePartName = (IAMDescription != null) ? IAMDescription.left(80) : crossRef.IAMPartNumber__c;

                    PartList__c substitutePart = new PartList__c(
                                                                    Name                        = substitutePartName,
                                                                    Description__c              = IAMDescription,
                                                                    PartNumber__c               = crossRef.IAMPartNumber__c,
                                                                    ProducerName__c             = crossRef.IAMManufacturer__c,
                                                                    Type__c                     = crossRef.IAMPartClass__c,
                                                                    Price__c                    = ((crossRef.ASPublicPrice__c != null) ? crossRef.ASPublicPrice__c : (crossRef.IAMPublicPrice__c != null) ? crossRef.IAMPublicPrice__c : 0),
                                                                    Alpha_Scale_MRID__c         = crossRef.Name,
                                                                    CrossReferenceId__c         = crossRef.Id,
                                                                    CertifyingOrganization__c   = crossRef.IAMCertifyingOrganization__c,
                                                                    Assessment__r               = new Assessment__c(AssessmentID__c = assessmentId),
                                                                    InputType__c                = originalPart.InputType__c,
                                                                    Currency__c                 = originalPart.Currency__c,
                                                                    Quantity__c                 = originalPart.Quantity__c,
                                                                    RecordTypeId                = originalPart.RecordTypeId,
                                                                    OriginalPart__r             = new PartList__c(TECH_OriginalPart__c = originalPart.TECH_OriginalPart__c),
                                                                    TECH_OriginalPart__c        = nonCleansePartNumber + '-'
                                                                                                + crossRef.IAMPartNumber__c + '-'
                                                                                                + substitutePartName.replaceAll('\\s+', '') + '-'
                                                                                                + crossRef.IAMManufacturer__c + '-'
                                                                                                + assessmentId + '-'
                                                                                                + crossRef.Name
                                                                );

                    // check if the current cross ref is the best cross ref
                    if(bestCrossRef != null && bestCrossRef.Id == crossRef.Id)
                    {
                        // if yes, add to list to perform a field update on it
                        substituteToUpdateList.add(substitutePart);
                    }
                    else
                    {
                        // if not, we create the substitute as it is
                        substituteList.add(substitutePart);
                    }
                }
            }
        }

        //AMI 31/10/17 - updateField method param update due to ASPISServiceSubstitution getDescribeOptimisation
        // if the list is not empty perform the field update
        if(substituteToUpdateList.size() > 0){
            substituteList.addAll((List<PartList__c>) (ASPISServiceSubstitution.updateField(substituteToUpdateList, 
                                                                                            'PartList__c', 
                                                                                            listFieldUpdatesDetailRules,
                                                                                            fieldMapUpdateF,
                                                                                            setDescribedUpdateF,
                                                                                            mapUpdateFFieldType)));
        }

        System.debug('---------------------------------- END RESTrunSubstitution - createSubstitute ----------------------------------');
        return substituteList;
    }

    public static void insertAll(Map<String, Assessment__c> mapAssessmentIdAssessment,
                                Map<String, List<PartList__c>> mapAssessmentIdOriginalParts,
                                Map<String, List<PartList__c>> mapAssessmentIdSubstituteParts)
    {
        System.debug('---------------------------------- START RESTrunSubstitution - insertAll ----------------------------------');

        if(mapAssessmentIdAssessment.size() > 0)
        {
            List<Assessment__c> assessmentList = mapAssessmentIdAssessment.values();
            List<Database.SaveResult> insertResultList = Database.insert(assessmentList, false);

            for(Integer i = 0; i < insertResultList.size(); i++)
            {
                if(!insertResultList[i].isSuccess())
                {
                    // Getting the errirs
                    for(Database.Error err : insertResultList[i].getErrors())
                    {
                        mapErrorsCreation.put(assessmentList[i].AssessmentID__c, Label.Error + ': ' + err.getMessage());
                    }

                    // removing the failed assessment parts
                    mapAssessmentIdAssessment.remove(assessmentList[i].AssessmentID__c);
                    mapAssessmentIdOriginalParts.remove(assessmentList[i].AssessmentID__c);
                    mapAssessmentIdSubstituteParts.remove(assessmentList[i].AssessmentID__c);
                }
            }

            List<PartList__c> originalPartsToInsertList = new List<PartList__c>();

            for(List<PartList__c> partsList : mapAssessmentIdOriginalParts.values())
            {
                originalPartsToInsertList.addAll(partsList);
            }

            insert originalPartsToInsertList;

            List<PartList__c> substitutePartsToInsertList = new List<PartList__c>();

            for(List<PartList__c> substituteList : mapAssessmentIdSubstituteParts.values())
            {
                substitutePartsToInsertList.addAll(substituteList);
            }

            insert substitutePartsToInsertList;
        }

        System.debug('---------------------------------- END RESTrunSubstitution - insertAll ----------------------------------');
    }

    public static String generateResponse(  Map<String, Assessment__c> mapAssessmentIdAssessment,
                                            Map<String, List<PartList__c>> mapAssessmentIdOriginalParts,
                                            Map<String, List<CrossReference__c>> OEMIAMMap,
                                            Map<String, CrossReference__c> OEMIAMPriceMap,
                                            Map<String, AccountRef__c> mapAssessmentIdAccountRef,
                                            Map<String, CarMapping__c> mapAssessmentIdCarMapping)
    {
        System.debug('---------------------------------- START RESTrunSubstitution - generateResponse ----------------------------------');

        String response = '';

        System.debug('## mapAssessmentIdAssessment: ' + mapAssessmentIdAssessment);
        System.debug('## OEMIAMMap: ' + OEMIAMMap);
        System.debug('## mapAssessmentIdAssessment: ' + mapAssessmentIdAssessment);

        // JSONGenerator;
        JSONGenerator genResults = JSON.createGenerator(false);
        // start array of Assessment
        genResults.writeStartArray();

            for(String assessmentId : mapAssessmentIdAssessment.keySet())
            {
                // start Object Assessment
                Assessment__c currentAssessment = mapAssessmentIdAssessment.get(assessmentId);
                CarMapping__c currentCarMapping = mapAssessmentIdCarMapping.get(assessmentId);

                genResults.writeStartObject();
                    genResults.writeStringField('AssessmentNumber', currentAssessment.AssessmentNumber__c);
                    genResults.writeStringField('EntityCode', currentAssessment.EntityCode__c);
                    genResults.writeStringField('Name', currentAssessment.Name);

                    if(currentAssessment.VINCheck__c != null){
                        genResults.writeNumberField('VINCheck', currentAssessment.VINCheck__c);
                    }

                    // start write Parts
                    genResults.writeFieldName('Parts');

                        // start array of Parts
                        genResults.writeStartArray();

                            for(PartList__c originalPart : mapAssessmentIdOriginalParts.get(assessmentId))
                            {
                                // start Object Part
                                genResults.writeStartObject();
                                    if(originalPart.Description__c != null)
                                    {
                                        genResults.writeStringField('Description', originalPart.Description__c);
                                    }

                                    genResults.writeStringField('Name', originalPart.Name);
                                    genResults.writeStringField('PartNumber', originalPart.PartNumber__c);
                                    genResults.writeNumberField('Price', originalPart.Price__c);

                                    if(originalPart.ProducerName__c != null)
                                    {
                                        genResults.writeStringField('Manufacturer', originalPart.ProducerName__c);
                                    }

                                    genResults.writeNumberField('Quantity', originalPart.Quantity__c);
                                    genResults.writeStringField('RecordType', recordIdNameMap.get(originalPart.RecordTypeId));
                                    genResults.writeStringField('Type', originalPart.Type__c);
                                    genResults.writeBooleanField('Compliance', originalPart.Compliance__c);
                                    genResults.writeStringField('InputType', originalPart.InputType__c);
                                    genResults.writeStringField('Currency', originalPart.Currency__c);
                                    genResults.writeBooleanField('IsSelected', originalPart.SelectedByBS__c);

                                        // start write Substitutions
                                    genResults.writeFieldName('Substitutions');
                                        // start array of Substitution
                                        genResults.writeStartArray();
                                            //String cleanseOEMKey =  cleanseReference(originalPart.PartNumber__c) + '-' + currentCarMapping.CarCrossRef__c;
                                            String cleanseOEMKey =  cleanseReference(originalPart.PartNumber__c) + '-' + assessCarMap.get(assessmentId).split(';')[2];
                                            System.debug('## cleanseOEMKey:' + cleanseOEMKey);

                                            if(OEMIAMMap.containskey(cleanseOEMKey)){
                                                System.debug('## cleanseOEMKeyMap:' + OEMIAMMap.get(cleanseOEMKey));
                                                for(CrossReference__c cr: OEMIAMMap.get(cleanseOEMKey)){
                                                    // start Object Substitution
                                                    genResults.writeStartObject();

                                                        String IAMDescription = (cr.IAMPartDescription__c != null) ? cr.IAMPartDescription__c : cr.OEMPartDescription__c;
                                                        String IAMName = (IAMDescription != null) ? IAMDescription.left(80) : cr.IAMPartNumber__c;
                                                        
                                                        genResults.writeStringField('Description', IAMDescription);
                                                        genResults.writeStringField('Name', IAMName);

                                                        genResults.writeStringField('PartNumber', cr.IAMPartNumber__c);

                                                        if(cr.ASPublicPrice__c != null)
                                                        {
                                                            genResults.writeNumberField('Price', cr.ASPublicPrice__c);
                                                        }
                                                        else if (cr.IAMPublicPrice__c != null)
                                                        {
                                                            genResults.writeNumberField('Price', cr.IAMPublicPrice__c);
                                                        }
                                                        else
                                                        {
                                                            genResults.writeNumberField('Price', 0);
                                                        }

                                                        if(cr.IAMManufacturer__c != null)
                                                        {
                                                                genResults.writeStringField('Manufacturer', cr.IAMManufacturer__c);
                                                            }

                                                        genResults.writeNumberField('Quantity', originalPart.Quantity__c);
                                                        genResults.writeStringField('RecordType', recordIdNameMap.get(originalPart.RecordTypeId));

                                                        // ABT - Removed Type - C-001765 - 19-OCT-2016
                                                        // ABT - Rollback - C-001765 - 24-OCT-2016
                                                        if(cr.IAMPartClass__c != null)
                                                        {
                                                            genResults.writeStringField('Type', cr.IAMPartClass__c);
                                                        }

                                                        genResults.writeStringField('Currency', originalPart.Currency__c);
                                                        genResults.writeStringField('AlphaScaleMRID', cr.Name);

                                                        if( OEMIAMPriceMap.containskey(cleanseOEMKey) &&
                                                            OEMIAMPriceMap.get(cleanseOEMKey).Id == cr.Id)
                                                        {
                                                            genResults.writeBooleanField('IsSelected', true);
                                                        }
                                                        else
                                                        {
                                                            genResults.writeBooleanField('IsSelected', false);
                                                        }

                                                    // End Object Substitution`
                                                    genResults.writeEndObject();
                                                }
                                            }
                                        // End Array Substitution
                                        genResults.writeEndArray();
                                // End Object Part
                                genResults.writeEndObject();
                            }
                        // End Array Part
                        genResults.writeEndArray();


                    // write Object currentAsset
                    genResults.writeFieldName('currentAsset');
                        // Start Object currentAsset
                        genResults.writeStartObject();
                            if(currentAssessment.FirstRegistrationDate__c != null){
                                genResults.writeDateField('FirstRegistrationDate', currentAssessment.FirstRegistrationDate__c);
                            }

                            // ASE: 27/10/16: retrieve carOrigin by splitting Name.
                            //genResults.writeStringField('Brand', currentCarMapping.CarOrigin__c);
                            //genResults.writeStringField('Brand', currentCarMapping.Name.substringAfter('-'));
                            genResults.writeStringField('Brand', assessCarMap.get(assessmentId).split(';')[0]);
                            
                        // End Object currentAsset
                        genResults.writeEndObject();

                    // write Object currentBodyshop
                    genResults.writeFieldName('currentBodyshop');

                        // Start Object currentBodyshop
                        genResults.writeStartObject();

                            // ASE: 27/10/16: retrieve ReferenceNumber by splitting Name.
                            //genResults.writeStringField('ReferenceNumber', mapAssessmentIdAccountRef.get(assessmentId).ExternalReference__c);
                            genResults.writeStringField('ReferenceNumber', mapAssessmentIdAccountRef.get(assessmentId).Name.substringAfter('-'));


                        // End Object currentBodyshop
                        genResults.writeEndObject();

                // End Object Assessment
                genResults.writeEndObject();
            }


            for(String suc : mapErrorsCreation.keySet())
            {
                genResults.writeStartObject();
                    genResults.writeStringField('OperationType', 'Insert');
                    genResults.writeNullField('TechnicalId');
                    genResults.writeStringField('FunctionalId', suc);
                    genResults.writeBooleanField('Success', false);
                    genResults.writeNullField('Warning');
                    genResults.writeStringField('ErrorMessage', 'Exceptions: ' + mapErrorsCreation.get(suc));
                genResults.writeEndObject();
            }
        // End array of Assessment
        genResults.writeEndArray();

        response = genResults.getAsString();

        System.debug('---------------------------------- END RESTrunSubstitution - generateResponse ----------------------------------');
        return response;
    }

    // check if assessment has missing mandatory fields
    public static Boolean checkMandatoryFields(Map<String,Object> receivedAssessMap, Integer position){
        System.debug('---------------------------------- START RESTrunSubstitution - checkMandatoryFields ----------------------------------');

        Boolean isValid = false;

        Set<String> assessfieldSet  = new Set<String>{'callerSystem', 'AssessmentNumber', 'EntityCode', 'Name', 'VINCheck', 'Parts', 'currentAsset', 'currentBodyShop'};
        Set<String> partFieldSet    = new Set<String>{'Name', 'PartNumber', 'Price', 'Quantity' , 'RecordType', 'Type', 'InputType'};
        Set<String> assetFieldSet   = new Set<String>{'Brand'};
        Set<String> bsFieldSet      = new Set<String>{'ReferenceNumber'};

        // Running the function to check the mandatory fields and give out a String containing the missing fields if present
        String missingFields  = checkFields(assessfieldSet, partFieldSet, assetFieldSet, bsFieldSet, receivedAssessMap);
        System.debug('##  missingFields: ' + missingFields);

        // check if missingFields is blank, asssessment is valid
        if(missingFields == ''){
            isValid = true;
        }
        else{
            isValid = false;
            mapErrorsCreation.put('Assessment in position[' + position + '] ', 'Exceptions: Missing fields: ' + missingFields);
        }

        System.debug('## isValid:' + isValid);

        System.debug('---------------------------------- END RESTrunSubstitution - checkMandatoryFields ----------------------------------');

        return isValid;
    }

    public static String checkFields(Set<String> assessfieldSet, Set<String> partFieldSet, Set<String> assetFieldSet, Set<String> bsFieldSet, Map<String, Object> receivedAssessMap){
        System.debug('---------------------------------- START RESTrunSubstitution - checkFields ----------------------------------');

        Boolean isValid         = true;
        String missingFields    = '';

        // check if field exists in assessment
        // checking the most outer fields of the JSON
        for(String assessField: assessFieldSet){
            if(!receivedAssessMap.containsKey(assessField)){
                isValid = false;
                missingFields += assessField + '; ';
            }
        }

        // loop in inner Json Objects
        if(isValid){

            // checking fields for Parts
            if(receivedAssessMap.get('Parts') != null){
                for(Object receivedPart: (List<Object>)receivedAssessMap.get('Parts')){
                    Map<String, Object> receivedPartMap = (Map<String, Object>) receivedPart;

                    //check if partNumber exists in partList
                    if(!receivedPartMap.containsKey('PartNumber')){
                        missingFields += 'PartNumber missing in one of the partList';
                    }
                    else{

                        // loop in part's other mandatory fields
                        String missingPartFieldSet = 'Part: '+ String.ValueOf(receivedPartMap.get('PartNumber')) +'\'s missing fields: ';

                        Boolean foundMissingFields = false;
                        // loop in partFieldSet
                        for(String partField: partFieldSet){
                            if(!receivedPartMap.containsKey(partField)){
                                missingPartFieldSet += partField +'; ';
                                foundMissingFields  = true;
                            }
                        }

                        if(foundMissingFields){
                            missingFields += missingPartFieldSet;
                        }
                    }
                }
            }

            // checking fields for currentAsset
            if(receivedAssessMap.get('currentAsset') != null){
                Map<String, Object> currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');

                for(String assetField: assetFieldSet){
                    if(!currentAssetMap.containsKey(assetField)){
                        //isValid = false;
                        missingFields += 'currentAsset.' + assetField + '; ';
                    }
                }
            }

             // checking fields for currentBodyShop
            if(receivedAssessMap.get('currentBodyShop') != null){
                Map<String, Object> currentBodyShopMap = (Map<String, Object>) receivedAssessMap.get('currentBodyShop');

                // loop in bsFieldSet
                for(String bsField: bsFieldSet){
                    if(!currentBodyShopMap.containsKey(bsField)){
                        //isValid = false;
                        missingFields += 'currentBodyShop.'+ bsField +'; ';
                    }
                }
            }
        }

        System.debug('---------------------------------- END RESTrunSubstitution - checkFields ----------------------------------');

        return missingFields;
    }

    // ABT - 26-AUG-2016 - C-001710
    public static String cleanseReference(String referenceToCleanse)
    {
        return referenceToCleanse.replaceAll('[^A-Za-z0-9]', '').replaceFirst('^0+(?!$)', '').toUpperCase();
    }
}