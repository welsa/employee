/*************************************************************************************
Class Name - RESTUpsertAssessmentV1
Version - 1.0
Created Date - 09 MAY 2016
Function - Class REST to use inbound message to create/update an assessment with the related parts
in ASPIS application.


if assessmentNumber is null
    create all parts and perform substitution with best match (recommended by AS = true)

else
    get all parts and substitutes using assessmentId 
    loop on parts received in Json
    if part contains no alphascaleMRID ==> original part
        if parts exists
            send original part (SelectedbyBS = true) and related substitutes (SelectedbyBS = false)
        else
            create new part and perform substitution with best match (recommended by AS = true)
        end if
    else ==> substitute part
        if substitute part exists
            send original part (SelectedbyBS = false), substitute part (SelectedbyBS = true) and other substitutes (SelectedbyBS = false)
        else
            send error message 'this susbtitute does not exist'
        end if
end if

Modification Log :
-----------------------------------------------------------------------------  
* Developer      Date           Description
* -------------- ----------     -----------------------
* Ashwina S      09/05/2016     Original Version
* Dourga U       11/08/2016     MasterRule substitution 
* Ashutosh B     22/09/2016     C-001728: Added the new function of create attachment
* Ashwina S      27/09/2016     replace countryCode by userRolePrefix
* Ashwina S      28/09/2016     retrieve carOrigin by splitting Name.
* Ashwina S      17/11/2016     C-001803 : Assessment Public Identifier
* Ashwina S      09/12/2016     bug when having similar substitutes
* Ashwina S      30/01/2017     If shoppingList = true && AssessmentNumber ==null, 
                                - create Assessment with Name, Assessment Number, AssessmentId = BodyShop Ref + Timestamp
                                - Type  = claim, check IsShoppingList, No Substitution, Do not check SendingAccepted__c
                                Else If shoppingList = true && AssessmentNumber !=null, ignore assessment but generate response OK
* Ashwina S      01/03/2017     split description of substitute : take original description to search in Salesforce
* Ashwina S      XX/03/2017     - when part has no substitutes, set SelectedByBS__c to true.
                                - if no substitutes are recieved for assessment, HasBeenSubstituted__c on assessment= false
                                - isEligibleSubstitution on BS is false, do not perform substitution
* Ashwina S      13/03/2017     No substitution if brand is found in CarBrandExcluded__c
* Ashwina S      05/04/17       C-001825 : call restPostAssessment
* Ashwina S      15/06/2017     C-001937 :  
* Abdool M       06/07/2017     Adding warning message exception handling (C-001969)
* Abdool M       12/07/2017     Duplicate handling (C-001969)
* Abdool M       13/07/2017     Crash code handling (C-001969)
* Abdool M       17/07/2017     Commenting crash genereation record code (C-001969)
* Abdool M       19/07/2017     New External Id being sent in ass request
* Abdool M       20/07/2017     C-001934 : Upsert Evolution to add margins on original parts
* Abdool M       25/07/2017     C-001927 - upsertAssessent add External ID
* Ashwina S      24/08/2017     C-002016 - RunSubstitution & UpsertAssessment substitution : verify IAM part description
* Abdool M       04/10/2017     C-001969 - Evolutions of upsertAssessment - crash management
* Ashwina S      07/11/2017     C-002070 - UpsertAssessment - OEM Discount / Margin missing when doing an update
* Dourga U       07/11/2017     C-001994 - add parameters in runValidation Method
* Ashwina S      13/11/2017     C-001988 - Expert assessments part list are not selected
* Ashwina S      17/11/2017     C-002078 - ICE - Compensation new filed in upsertAssessment
* Abdool M       18/12/2017     C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
* Ashwina S      24/01/2018     C-002185 - AssessmentNumber must not be updated if Claim number change
*************************************************************************************/
@RestResource(urlMapping='/v2.0/upsertAssessmentOld/*')
global with sharing class RESTUpsertAssessmentV1 {    
    // static variables
    
    static Map<String, Id> recordTypePartTypeMap        = new Map<String, Id>();
    static Map<String, Id> recordTypeAssessTypeMap      = new Map<String, Id>();

    // map<error string, error string>
    static Map<String, String> mapErrorsCreation;

    //AMI 06/07/2017 - Adding warning message exception handling
    static Map<String, String> mapWarningCreation;
    
    //map<assessId, AccountRef__c> to get AccountRef__c custom setting values 
    static Map<String, AccountRef__c> assessAccountRefMap;
    //map<assessId, CarMapping__c> to get CarMapping__c custom setting values 
    //static Map<String, CarMapping__c> assessCarMap;
    //map<assessId, brand sent in response; car destination for callerId; car destination for CATALOG>
    static Map<String, String> assessCarMap;
    //map<AssessmentId, list<Parts from Json requiring substitution>>
    static Map<String, list<Object>> newOriginalMap;
    //build map <AssessmentId, entityCode>
    static Map<String, String> assessIDEntityCodeMap;
    // map<AssessmentId, valid assessments from json>
    static Map<String, Map<String, Object>> allValidAssessMap; 
    //map <BSId, BS>
    static Map<Id, Account> bsRefAccountMap ; 
    // ase: 05/12/17 : lien BS evol 
    static set<id> expertAccSet; 
    //map <AssessmentId, map<pl.TECH_OriginalPart__c, pl>> 
    static map<String, Partlist__c> originalPartsMap ;
    //map <AssessmentId, map<pl.TECH_OriginalPart__c, map<Substitute.TECH_OriginalPart__c, Substitute >>> 
    static map<String,list<Partlist__c>> originalSubstitutesMap = new map<String,list<Partlist__c>>(); 
    //map<assessId-substitute.alphascaleMRID, original.TechOriginalPart>
     static map<String, list<String>> assessSubOriginalMap = new map<String, list<String>>();
    //map<assessId-substitute, partList>
    static map<String, Object> assessSubstituteMap = new map<String, Object>();  
    //map<assessId-substitute, partList>
    //static map<String, Object> assessSubstituteMapWithDesc = new map<String, Object>(); 
    static String urlLink = URL.getSalesforceBaseUrl().toExternalForm();
    //map<AssessId-originalPart.TECH_OriginalPart__c, list<substitute>>
    static Map<String, List<PartList__c>> asessPartSubMap;
    //DUN 12/09/2016 MasterRule Update
    static Map<String, Set<String>> mapEntitysetPartListTechId = new Map<String, Set<String>>();
    // role prefix of connectedUser
    static String userRolePrefix;
    // set<assessmentClaimID> used to create parent (claim) assessment when crashCode is sent
    static set<String> assessmentClaimIDSet = new set<String>();
    // ASE 12/01/2017: case C-001828
    //map<AssessmentId, original and substitutes>
    //static map<String, map<String, Partlist__c>> claimOriginalSubstitutesMap =  new map<String, map<String, Partlist__c>>();
    static map<String, Partlist__c> claimOriginalSubstitutesMap =  new map<String, Partlist__c>();
    //map<crashSubstitute.TECH_OriginalPart__c, claimSubstitute.TECH_OriginalPart__c>
    static Map<String, String> cloneSubstituteMap = new Map<String, String>();
    //map<AssessmentId, isEligibleSubstitution>
    static Map<String, String> isEligibleMap = new Map<String, String>();
    static set<String> assessTimestampSet = new set<String>(); 
    static Map<String, String> shoppingListAssessIDMap = new Map<String, String>();
    static Map<String, String> crashClaimIdMap = new Map<String, String>();
    static Map<String, Id> assessSFDCIDMap = new Map<String, Id>();
    //map<AlphaScaleMrid -IAM partNUmber>
    static Map<String, String> ASCRPartNumbMap = new Map<String, String>();
    static set<String> shoppingListExistAssessFound = new set<String>(); 
    static set<String> partsToDelSet = new set<String>();
    static map<String, Partlist__c> allSubPartsMap ;
    static map<String, Set<String>> allAssessSubOriginalMap = new map<String, Set<String>>();
    static set<String> allOriSubPartsSet = new set<String>();    
    static map<String, Partlist__c> claimcrashOriginalSubstitutesMap =  new map<String, Partlist__c>();
    static map<String, set<String>> assessBSCategoriesMap = new map<String, set<String>>();
    static Set<String> igEntitySet = String.isBlank(Label.ASFRIGEntity) ? new Set<String>() : new Set<String>(Label.ASFRIGEntity.split(';'));
    static map<String, String> crashSubCrashOriginalMap = new map<String, String>();
    static map<String, String> crashOriClaimOriMap = new map<String, String>();

    //AMI 12/07/17 - duplicate handling
    static map <string,duplicateSizeCrashCodeWrapper> mapOriginalKeyListPL = new map <string,duplicateSizeCrashCodeWrapper>();
    static map <string,duplicateSizeCrashCodeWrapper> mapSubstituteKeyListPL = new map <string,duplicateSizeCrashCodeWrapper>();   

    //AMI 20/07/17 - C-001934 : Upsert Evolution to add margins on original parts
    static map <string,CrossReference__c> mapPartNumCrossRef = new map <string,CrossReference__c>();
    static map<String, set<String>> expertOriginalPartsMap= new map<String, set<String>>();
    static map<Id, set<String>> crossRefMap = new map<Id, set<String>>(); 
     // ase: 05/12/17 : lien BS evol 
    static set<String> setClaim = new set<String>();
    static set<String> setPlate = new set<String>();
    static map<String, Id> claimPlateBSRefMap = new map<String, Id>(); 
    static map<Id, String> claimPlateCarBrandExcludedMap = new map<Id, String>(); 

      /**
    * @description upsertAssessment
    * @return [description]
    */
    @HttpPost
    global static void upsertAssessment() {
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - upsertAssessment ----------------------------------');
        
        // variables
        String jsonResponse= ''; 

        User intUser = [select UserRole.NAme from User where id =: UserInfo.getUserId()];
        userRolePrefix =  (intUser.UserRole != null  && intUser.UserRole.Name != null) ? intUser.UserRole.Name.left(2) : '';

        //build Mapto store recordtype for sobject PartList__c
        for(RecordType r : [SELECT  SobjectType, Id, DeveloperName 
                            FROM    RecordType 
                            WHERE   SobjectType =: Label.SOBJECTPARTLIST or SobjectType =: Label.SOBJECTASSESSMENT]){
            if(r.SobjectType == Label.SOBJECTPARTLIST){
                recordTypePartTypeMap.put(r.DeveloperName, r.Id);
            }
            else if(r.SobjectType == Label.SOBJECTASSESSMENT){
                recordTypeAssessTypeMap.put(r.DeveloperName, r.Id);
            }
        }

        // deserialise response
        //convert the requestbodyv into a String
        String body = RestContext.request.requestBody.toString();
        system.debug('## body:'+body);
        
        // create log
        Log__c log      = new Log__c();
        log.DateLog__c  = System.now();

        // ABT - C-001728 - 22-SEP-2016
        log.Class__c   = 'RESTUpsertAssessmentV1';

        insert log;

        if (body.length() <= 30000){
            log.JSONMessage__c = body;
        }
        else {
            APCreateAttachments.createAttachment('Request', body, log);
        }

        
        if(body != null && body != ''){
            // call deserialiseResponse method
            jsonResponse = deserialiseResponse(body, log.Id);

            if(jsonResponse.contains('Exceptions') || (jsonResponse.contains('Error') && !jsonResponse.contains('"ErrorMessage":null'))){
                log.Status__c = Label.STATUSFAILED;
            }
            else{
                log.Status__c = Label.STATUSPASSED;
            }

            log.sObject__c = 'Assessment__c';

            if(jsonResponse.length() <= 30000){
                log.JSONResponse__c = jsonResponse;
            }
            else {
                APCreateAttachments.createAttachment('Response', jsonResponse, log);
            }
        }

        update log;

        //System.debug('## jsonResponse: ' + jsonResponse);

        RestContext.response.responseBody = Blob.valueOf(jsonResponse);

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - upsertAssessment ----------------------------------');
    }

    public static String deserialiseResponse(String body, Id logId){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - deserialiseResponse ----------------------------------');

        // variable
        //set<AccountId> used to get BS
        Set<String> bsIdRefSet                              = new Set<String>();    
        bsRefAccountMap                                     = new Map<Id, Account>();
        // ase: 05/12/17 : lien BS evol
        expertAccSet                                        = new set<id>();                                    
        // map<AccountRef__c.Name, AccountRef__c>
        Map<String, AccountRef__c> accRefMap                = new Map<String, AccountRef__c>();
        // map<CarMapping__c.Name, CarMapping__c>
        //Map<String, CarMapping__c> carRefMap                = new Map<String, CarMapping__c>();
        assessAccountRefMap                                 = new Map<String, AccountRef__c>();     
        assessCarMap                                        = new Map<String, String>(); 
        //map<AssessmentId, receivedJson>
        Map<String, List<Object>> existingAssessMap         = new Map<String, List<Object>>();
        newOriginalMap                                      = new Map<String, list<Object>> ();
        allValidAssessMap                                   = new Map<String, Map<String, Object>>();
        originalPartsMap                                    = new map<String, Partlist__c>();
        originalSubstitutesMap                              = new map<String,list<Partlist__c>>(); 
        assessSubOriginalMap                                = new map<String, list<String>>();
        allSubPartsMap                                      = new map<String, Partlist__c>();
        allAssessSubOriginalMap                             = new map<String, set<String>>();
        List<Assessment__c> newAssessmentList               = new List<Assessment__c>();       
        //map<assessNumber, Assessment__c>
        map<String, Assessment__c> claimAssessmentMap      = new map<String, Assessment__c>();
        
        
        //list<partList> to be inserted
        List<PartList__c> newPartList                           = new List<PartList__c>();
        //list<Substitues> to be inserted
        List<PartList__c> newSubstituteList                     = new List<PartList__c>();
        //map<AssessementId, list<PartList>>
        Map<String, List<PartList__c>> assessIdPartsMap         = new Map<String, List<PartList__c>>();
        Map<String, List<PartList__c>> shopAssessIdPartsMap     = new Map<String, List<PartList__c>>();
        //map<AssessementId, list<Substitutes>>
        Map<String, List<PartList__c>> assessSubstituteListMap  = new Map<String, List<PartList__c>>();   
        // Map<OEM PartNumber, all existing IAM>
        Map<String, List<CrossReference__c>> OEMIAMMap          = new Map<String, List<CrossReference__c>>();
        // Map<AssessId, Assessment__c>
        Map<String, Assessment__c> assessMap                    = new Map<String, Assessment__c>();
        //Map<String, Assessment__c> assessExternalIdMap          = new Map<String, Assessment__c>();
        
        String response;
        String nevadaResponse;
        Boolean isNevada = false;

        // Map<OEM PartNumber, IAM with least price>
        Map<String, CrossReference__c> OEMIAMPriceMap           = new Map<String, CrossReference__c>();
        
        // map<Assessement__c.AssessmentId, Assessement__c.Id>
        //Map<String, Id> assessSFDCIDMap;
        mapErrorsCreation                                       = new Map<String, String>();

        //AMI 06/07/2017 - Adding warning message exception handling
        mapWarningCreation                                      = new Map<String, String>();

        //DUN 11/08/2016 Mapof entity and Mapof AssNo-AssBrand-CountryCode as Key and a List of parts used to call method runSubstitution
        //map<entity, map<AssId-AssBrand-CountryCode, list<partList>>>
        Map<String, Map<String, List<Object>>> mapEntitymapAsslistParts;
        Map<String, ASPISServiceSubstitution.SubstituteWrapper> mapEntitySubstituteWrapper = new Map<String, ASPISServiceSubstitution.SubstituteWrapper>();

        // list of all assessments that are considered valid after checking for mandatory fields        
        List<Map<String, Object>> allValidAssessList                        = new List<Map<String, Object>>();
  
     
        asessPartSubMap                         = new Map<String, List<PartList__c>>();
        //map of AccountRef__c whose SubstitutionAccepted__c is not true
        Map<Id, AccountRef__c> accountRefToUpdate = new Map<Id, AccountRef__c>();
        Map<String, List<Object>> shoppingListExistAssessMap = new Map<String, List<Object>>();    
        Map<String, Id> claimAssessSFDCMap = new  Map<String, Id>();

        //ASE: 02/03/2017: C-001885
        Set<String> carMapBrandSet = new Set<String>();
        Map<String, String> carMapBrandMap = new Map<String, String>();
        Map<String, String> carMapCrossRefMap  = new Map<String, String>();
        Set<String> carMapCrossRefSet = new Set<String>();

        //AMI 25/07/17 - C-001927 - upsertAssessent add External ID
        //this list is used to get all received assessment map having external id
        List<Map<String, Object>> lstProcessedAssObj = new List<Map<String, Object>>();
        //  ASE: 17/11/17 C-002078
        map<String, Assessment__c> ICEAssessmentMap = new  map<String, Assessment__c>();
        list<Object> nonICEAssessList = new list<Object>();
        map<String, String> ICEAssessErrorMap = new map<String, String>();

        //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
        //             : this map will be used to hold correct order (position) of assessment
        map <string,integer> mapAssIdPositionNumber = new map <string,integer>();

        try{ 
            // deserialize body
            List<Object> objList = (List<Object>) JSON.deserializeUntyped(body);
            if(!objList.isEmpty()){
                // The index of the assessment in the objList
                Integer position = 0;

                for(Object receivedAssess : objList){
                    Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;
                    String callerSystem = (receivedAssessMap.get('callerSystem') != null && receivedAssessMap.get('callerSystem') != '') ? (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase() : null;
                    String AssessmentNumber = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;
                    system.debug('## callerSystem:'+callerSystem);
                    system.debug('## AssessmentNumber:'+AssessmentNumber);
                    //  ASE: 17/11/17 C-002078
                    Boolean compensated = (receivedAssessMap.get('Compensated') != null) ? Boolean.valueOf(receivedAssessMap.get('Compensated')) : null;
                    system.debug('## compensated:'+compensated);
                    
                    if(callerSystem == 'FR_ICE'){

                        if(compensated !=null && AssessmentNumber !=null){
                            if(!ICEAssessmentMap.containsKey(AssessmentNumber)){
                                ICEAssessmentMap.put(AssessmentNumber, new Assessment__c(AssessmentID__c = AssessmentNumber,  Compensated__c = compensated));
                                mapAssIdPositionNumber.put(AssessmentNumber,position);
                            }
                        }
                        else{
                            ICEAssessErrorMap.put('Assessment ['+ position + ']', 'Assessment ['+ position + '] not processed.  No AssessmentNumber or Compensated found.' );
                        }
                    }
                    else{
                        nonICEAssessList.add(receivedAssess);
                        String brand;    
                        if ( (receivedAssessMap.get('EntityCode') == '299'  || receivedAssessMap.get('EntityCode') == '392') && receivedAssessMap.get('isShoppingList')== false) {
                            isNevada = true;
                        }                     
                        if(receivedAssessMap.get('currentAsset') != null){
                            Map<String, Object> currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');    
                            brand = (currentAssetMap.get('Brand') != null && currentAssetMap.get('Brand') != '') ? String.valueOf(currentAssetMap.get('Brand')) : null;
                        }
                        String brandCallerSystem = (callerSystem != null) ? ((callerSystem.substring(2, 3) == '_') ? callerSystem.right(callerSystem.length()-3) : callerSystem) : null;            
                        if(brandCallerSystem != null && brand !=null){
                            //carMapBrandSet.add((callerSystem + '_' +brand).toUpperCase()); 
                            carMapBrandSet.add((brandCallerSystem + '-' +brand).toUpperCase()); 
                        }   
                    }                
                }
                system.debug('## carMapBrandSet:'+carMapBrandSet);

                system.debug('## ICEAssessmentMap:'+ICEAssessmentMap);
                //  ASE: 17/11/17 C-002078
                if(ICEAssessmentMap.size() > 0 || ICEAssessErrorMap.size() > 0){

                    //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
                    //             : pass new param to method
                    response = processICEAssessment(ICEAssessmentMap, ICEAssessErrorMap,mapAssIdPositionNumber);
                } 

                if(nonICEAssessList.size() > 0){
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
                    
                    for(Object receivedAssess : nonICEAssessList){
                        // Casting the received assessment to a map of string, object
                        Map<String, Object> receivedAssessMap = (Map<String, Object>) receivedAssess;

                        // check if assessment contains all mandatory fields
                        Boolean isValid = checkMandatoryFields(receivedAssessMap, position);

                        // if assessment is Valid, check if request contains an assessment number
                        if(isValid){
                            string assessmentNumber = String.valueOf(receivedAssessMap.get('AssessmentNumber'));
                            if(string.isNotBlank(assessmentNumber)){
                                lstProcessedAssObj.add(receivedAssessMap);
                            }

                            String callerSystem = (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase();
                            String refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber')).replaceAll('[^A-Za-z0-9]', '');
                            String brand        = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('Brand'));
                            Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;

                            // ase: 05/12/17 : lien BS evol
                            String claimRef = String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentClaim')).get('ClaimReference'));
                            String plateNum = String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('PlateNumber'));
                            plateNum = (plateNum != null) ? removeSpaceHypen(plateNum) : plateNum;

                            // check if mapping exists in Account reference
                            AccountRef__c accRef = AccountRef__c.getValues(callerSystem + '-' + refNumber);

                            // both accRef and carMap are not null when this part is being executed             

                            // Account Reference
                            if (accRef != null){
                                accRefMap.put(accRef.Name, accRef);
                                bsIdRefSet.add(accRef.InternalReference__c);

                                if(!accRef.SendingAccepted__c && !isShoppingList){
                                   accountRefToUpdate.put(accRef.Id, new AccountRef__c(Id = accRef.Id, SendingAccepted__c = true));
                                }
                            }                   
                            
                            // list that contains all the assessment that is valid to be processed
                            allValidAssessList.add(receivedAssessMap);  

                            // ase: 05/12/17 : lien BS evol
                            if (claimRef != null){
                                   setClaim.add(claimRef);
                            }
                            if (plateNum != null){
                                   setPlate.add(plateNum);
                            }
                            
                            if (accRef != null){
                                if(accRef.InternalReference__c != null){
                                    claimPlateBSRefMap.put(claimRef + '-'+ plateNum, accRef.InternalReference__c);    
                                }   
                            }
                                           
                        }

                        // Increment the index for each loop
                        position++;
                    }

                    system.debug('## setClaim: '+setClaim);
                    system.debug('## setPlate: '+setPlate);

                    //AMI 25/07/17 - C-001927 - upsertAssessent add External ID
                    //perform parts list external key levelling first - to allow old system 
                    //without ext id to work with new system having ext id
                    system.debug('## lstProcessedAssObj.size() ' + lstProcessedAssObj.size());
                    if(!lstProcessedAssObj.isEmpty()){
                        updatePartsKey(lstProcessedAssObj);
                    }
                
                    if(!bsIdRefSet.isEmpty()){
                        for(Account acc: [  SELECT  Id, ShippingCountryCode, ContactUser__r.Email, ContactUser__c, ContactEmail__c, ReferenceNumber__c, isEligibleSubstitution__c, CarBrandExcluded__c, Categories__c, Type, AXAPartner__c  
                                            FROM    Account 
                                            WHERE   Id IN: bsIdRefSet]){
                            bsRefAccountMap.put(acc.Id, acc);
                            // ase: 05/12/17 : lien BS evol
                            if(acc.type == 'Expert'){
                                expertAccSet.add(acc.Id);
                                isNevada = false;
                            }
                            if (acc.AXAPartner__c == false){
                                    isNevada = false;
                            }
                        }
                    }
                    system.debug('## bsRefAccountMap:'+bsRefAccountMap);
                    system.debug('## expertAccSet:'+expertAccSet);
                    if(expertAccSet.size() > 0){
                        for(Assessment__c assess: [Select AssessmentId__c, ClaimReference__c, PlateNumber2__c, BodyShop__r.CarBrandExcluded__c 
                                                    from Assessment__c
                                                    where (ClaimReference__c in: setClaim or PlateNumber2__c in : setPlate) and BodyShop__r.Type = 'Standard']){
                            if(assess.BodyShop__r.CarBrandExcluded__c != null && claimPlateBSRefMap.containskey(assess.ClaimReference__c + '-' + assess.PlateNumber2__c)){
                                claimPlateCarBrandExcludedMap.put(claimPlateBSRefMap.get(assess.ClaimReference__c + '-' + assess.PlateNumber2__c), assess.BodyShop__r.CarBrandExcluded__c);
                            }
                        }
                    }

                    // loop in allValidAssessList to filter assessmentNumber
                    if(!allValidAssessList.isEmpty()){
                        existingAssessMap = filterAssessment(allValidAssessList, accRefMap, carMapBrandMap, carMapCrossRefMap, shoppingListExistAssessMap);
                    }

                    if(!existingAssessMap.isEmpty() || !shoppingListExistAssessMap.isEmpty()){
                        // this method determines which parts and respective substitutes are contained in an assessment         
                        retrievePartHierachy(existingAssessMap.keySet() , shoppingListExistAssessMap.keySet(), assessMap);

                        // filter partList from response to determine which partList really exists for request having an assessmentNumber
                        filterExistingPartList(existingAssessMap);
                        
                    }       

                    // build mapEntitymapAsslistParts to proceed with substitution
                    if(newOriginalMap !=null){
                        mapEntitymapAsslistParts = buildSubstitutionMap(newOriginalMap);
                    }
                    system.debug('## mapEntitymapAsslistParts:'+mapEntitymapAsslistParts);
                    
                    if(!mapEntitymapAsslistParts.isEmpty()){
                        //DUN 11/08/2016 apply Susbtitution
                        for(String entity : mapEntitymapAsslistParts.keySet()){
                            
                            ASPISServiceSubstitution.SubstituteWrapper substituteWrapper = ASPISServiceSubstitution.runSubstitution(mapEntitymapAsslistParts.get(entity), entity, assessBSCategoriesMap);
                            
                            for(String assNum : substituteWrapper.mapAssmapOEMKeylistIAM.keyset()){
                                OEMIAMMap.putAll(substituteWrapper.mapAssmapOEMKeylistIAM.get(assNum));
                                OEMIAMPriceMap.putAll(substituteWrapper.mapAssessmentIAMfinal.get(assNum));
                            }
                            mapEntitySubstituteWrapper.put(entity, substituteWrapper);
                        }
                    }        
                                
                    // process allValidAssessMap to upsert assessment, parts and substitutues
                    
                    if(!allValidAssessMap.isEmpty()){
                        processValidAssess(allValidAssessMap, mapEntitySubstituteWrapper, newAssessmentList, claimAssessmentMap, newPartList, assessIdPartsMap, assessSubstituteListMap, assessMap, OEMIAMMap, OEMIAMPriceMap, existingAssessMap.keyset(), shoppingListExistAssessMap, shopAssessIdPartsMap); 
                    }           

                    // call method to insert assessment, partlist and substitute
                    assessSFDCIDMap = insertAll(claimAssessmentMap, newAssessmentList, accountRefToUpdate, assessIdPartsMap, assessMap, assessSubstituteListMap, claimAssessSFDCMap);
                    
                    //DUN 12/09/2016 MasterRule Pricing
                    //list of partlist to update
                    list<PartList__c> listPartListToUpdate = new list<PartList__c>();
                    //set of partlist tech id
                    set<String> setTechId = new set<String>();
                    for(String enCode : mapEntitysetPartListTechId.keySet()){
                        if(mapEntitySubstituteWrapper.get(enCode) != null){
                            //DUN 07/11/2017 case 1994 add parameters in runValidation Method
                            //Testing original without entity
                            //mapEntitysetPartListTechId.get(enCode).addAll(expertOriginalPartsSet);
                            //for(String enCode : expertOriginalPartsMap.Keyset()){
                            if(expertOriginalPartsMap.containsKey(enCode)){
                                mapEntitysetPartListTechId.get(enCode).addAll(expertOriginalPartsMap.get(enCode));
                            }
                            map<String,PartList__c> mapTechIdPartListtoUpdate = ASPISServiceSubstitution.runValidation(mapEntitySubstituteWrapper.get(enCode).listValidationCriteria, mapEntitySubstituteWrapper.get(enCode).listUpdateFieldsCriteria ,mapEntitysetPartListTechId.get(enCode), enCode, mapEntitySubstituteWrapper.get(enCode).validationLogicValue);
                            if(mapTechIdPartListtoUpdate != null && mapTechIdPartListtoUpdate.size() > 0){
                                listPartListToUpdate.addAll(mapTechIdPartListtoUpdate.values());
                                setTechId.addAll(mapTechIdPartListtoUpdate.keySet()); 
                            } 
                            //. ASE 12/01/2017: case C-001828: check best substitutes in parent assessment
                            for(String crashSubstitute : cloneSubstituteMap.keySet()){
                                if(mapTechIdPartListtoUpdate.containskey(crashSubstitute)){
                                    PartList__c claimSubstitute =  new PartList__c(TECH_OriginalPart__c = cloneSubstituteMap.get(crashSubstitute), RecommendedByAS__c=true, SelectedByBS__c=true);
                                    listPartListToUpdate.add(claimSubstitute);
                                }
                            }
                        }  
                    }            

                    // ASE : 136/11/17 : C-001988 
                    // to process expertOriginalPartsSet here
                    // if assessment is Expert and Proposed, check all originals in expertOriginalPartsSet
                    set<Id> setAssId = new set<Id>();
                    if(listPartListToUpdate.size() > 0){
                        // ASE 12/01/2017: case C-001828
                        upsert listPartListToUpdate TECH_OriginalPart__c;

                        for(PartList__c updPart : listPartListToUpdate){
                            setAssId.add(updPart.Assessment__c);
                            if(updPart.PartNumber__c.StartsWith('ASCR-') && updPart.SelectedByBS__c){
                                if(!crossRefMap.containsKey(updPart.Assessment__c)){
                                    crossRefMap.put(updPart.Assessment__c, new Set<String>{updPart.PartNumber__c});
                                }
                                else{
                                    crossRefMap.get(updPart.Assessment__c).add(updPart.PartNumber__c);
                                }                            
                            }
                        }
                    }  

                    // DUN : 23/11/17 : C-001988 
                    // to process expertOriginalPartsSet here
                    // if assessment is Expert and Proposed, check all originals in expertOriginalPartsSet
                    system.debug('## assessSubstituteListMap '+ assessSubstituteListMap);
                    if(assessSubstituteListMap.size() > 0){
                        for(list<PartList__c> listupdPart : assessSubstituteListMap.values()){
                            for(PartList__c updPart : listupdPart){
                                setAssId.add(updPart.Assessment__c); 
                                system.debug('## updPart.Assessment__c' + updPart.Assessment__c);
                                if(updPart.PartNumber__c.StartsWith('ASCR-') && updPart.SelectedByBS__c){
                                    if(!crossRefMap.containsKey(updPart.Assessment__c)){
                                        crossRefMap.put(updPart.Assessment__c, new Set<String>{updPart.PartNumber__c});
                                    }
                                    else{
                                        crossRefMap.get(updPart.Assessment__c).add(updPart.PartNumber__c);
                                    }                            
                                }
                            }
                        }
                    }
                    
                    if(assessSubstituteListMap.size() == 0){
                        isNevada = false;
                    }

                    for(Id assId : setAssId){
                        if(!crossRefMap.containskey(assId) && assId != null){
                            crossRefMap.put(assId, new Set<String>{'NONE'});
                        }
                    }

                    // ASE : 14/11/17 C-001994 - issue 1
                    system.debug('## listPartListToUpdate:'+crossRefMap);
                    if(crossRefMap.size() > 0){
                        setCrossReferencesFieldForAssessment(crossRefMap);
                    }
                    
                    response = generateResponse(assessMap, assessIdPartsMap, OEMIAMMap, OEMIAMPriceMap, setTechId, claimAssessmentMap, claimAssessSFDCMap, shoppingListExistAssessMap, shopAssessIdPartsMap, false);
                    system.debug('## nevadaResponse:'+nevadaResponse);
                    
                    // ASE: 05/04/17 C-001825 : call restPostAssessment
                    callRESTPostAssessment(assessMap, claimAssessSFDCMap);
                    
                    //VSU: 21/07/17 C-001924 : send json response to NEVADA
                    System.debug('JSA ' +  isNevada);
                    if (isNevada){
                      nevadaResponse = generateResponse(assessMap, assessIdPartsMap, OEMIAMMap, OEMIAMPriceMap, setTechId, claimAssessmentMap, claimAssessSFDCMap, shoppingListExistAssessMap, shopAssessIdPartsMap, true);
                      RESTPostNevada.sendRequest(nevadaResponse);
                    }
                }
            }   
            System.debug('---------------------------------- END RESTUpsertAssessmentV1 - deserialiseResponse ----------------------------------');
        }
        catch(Exception ex){
            JSONGenerator genResults  = JSON.createGenerator(false);
            genResults.writeStartArray();
            genResults.writeStartObject();
                genResults.writeStringField('OperationType', 'Insert');
                genResults.writeNullField('TechnicalId');
                genResults.writeNullField('FunctionalId');
                genResults.writeBooleanField('Success', false);
                genResults.writeNullField('Warning');
                //genResults.writeStringField('ErrorMessage', 'Exceptions: ' + ex.getMessage());
                genResults.writeStringField('ErrorMessage', 'Exceptions: ' + ex.getStackTraceString()); 
            genResults.writeEndObject();
            genResults.writeEndArray(); 

            response = genResults.getAsString();
        }
        return response;
    }

    // check if assessment has missing mandatory fields
    public static Boolean checkMandatoryFields(Map<String, Object> receivedAssessMap, Integer position){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - checkMandatoryFields ----------------------------------');

        Boolean isValid = false;
        Set<String> assessfieldSet;
        Set<String> partFieldSet;
        Set<String> assetFieldSet = new Set<String>();
        Set<String> bsFieldSet;
        Set<String> claimFieldSet;
        

        String assessNum = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;
        Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;
               
        

        // update
        if(assessNum != null && assessNum != ''){
            assessfieldSet  = new Set<String>{'AssessmentNumber', 'callerSystem', 'currentAsset', 'currentBodyShop', 'currentClaim', 'Parts'};
            partFieldSet    = new Set<String>{'PartLabel', 'PartNumber', 'Price', 'Quantity'};
            assetFieldSet.add('Brand');
            bsFieldSet      = new Set<String>{'ReferenceNumber'};
            //claimFieldSet   = new Set<String>{'ClaimReference'};
        }
        // new assessment
        else{
            assessfieldSet  = new Set<String>{'callerSystem', 'VINCheck', 'currentAsset', 'currentBodyShop', 'currentClaim', 'Parts'};
            partFieldSet    = new Set<String>{'PartLabel', 'PartNumber', 'Price', 'Quantity', 'RecordType'};
            assetFieldSet.add('Brand');
            bsFieldSet      = new Set<String>();
            
           
            if(!isShoppingList){
                //assessfieldSet.add('EntityCode');
                assessfieldSet.add('VINCheck');
                bsFieldSet.add('ReferenceNumber');
                claimFieldSet   = new Set<String>{'ClaimReference'};
            }
            else{
                partFieldSet.add('Currency');
                assetFieldSet.add('Model');                
            }         
                
        }

        String missingFields  = checkFields(assessfieldSet, partFieldSet, assetFieldSet, bsFieldSet, claimFieldSet, receivedAssessMap);

        // check if missingFields is blank, asssessment is valid
        if(missingFields == ''){
            isValid = true;
        }
        else{
            isValid = false;
            mapErrorsCreation.put('Assessment at position[' + position +'] ', 'Exceptions: Missing fields: '+ missingFields);
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - checkMandatoryFields ----------------------------------');

        return isValid;
    }

    public static String checkFields(Set<String> assessfieldSet, Set<String> partFieldSet, Set<String> assetFieldSet, Set<String> bsFieldSet, Set<String> claimFieldSet, Map<String, Object> receivedAssessMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - checkFields ----------------------------------');

        Boolean isValid = true;
        String missingFields = '';

        // check if field exists in assessment
        for(String assessField: assessFieldSet){
            if(!receivedAssessMap.containsKey(assessField)){
                isValid         = false;
                missingFields   += assessField + '; ';
            }
        }

        // loop in inner JsonObjects
        if(isValid){
            // loop in Asset
            // build currentAssetMap
            if(receivedAssessMap.get('currentAsset') != null){
                Map<String, Object> currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');

                for(String assetField: assetFieldSet){
                    if(!currentAssetMap.containsKey(assetField)){
                        //isValid = false;
                        missingFields += 'currentAsset.' + assetField + '; ';
                    }

                    if(!currentAssetMap.containsKey('PlateNumber') && !currentAssetMap.containsKey('VINNumber')){
                        missingFields += 'currentAsset.PlateNumber or currentAsset.VINNumber' + '; ';
                    }
                }
            }

             // build currentBSMap
            if(receivedAssessMap.get('currentBodyShop') != null){
                Map<String, Object> currentBSMap = (Map<String, Object>) receivedAssessMap.get('currentBodyShop');

                // loop in bsFieldSet
                for(String bsField: bsFieldSet){
                    if(!currentBSMap.containsKey(BSField)){
                        //isValid = false;
                        missingFields += 'currentBodyShop.' + bsField + '; '; 
                    }
                }
            }

            // build currentClaimMap
            if(receivedAssessMap.get('currentClaim') != null && claimFieldSet != null){
                Map<String, Object> currentClaimMap = (Map<String, Object>) receivedAssessMap.get('currentClaim');

                // loop in ClaimFieldSet
                for(String claimField: claimFieldSet){
                    if(!currentClaimMap.containsKey(claimField)){
                        //isValid = false;
                        missingFields += 'currentClaim.' + claimField + '; ';
                    }                    
                }
            }


            // build List partlistMap
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
        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - checkFields ----------------------------------');

        return missingFields;
    }

    // ASE: 09/09/2016
    public static Map<String, List<Object>> filterAssessment(List<Map<String, Object>> allValidAssessList, map<String, AccountRef__c> accRefMap, Map<String, String> carMapBrandMap, Map<String, String> carMapCrossRefMap, Map<String, list<Object>> shoppingListExistAssessMap){

        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - filterAssessment ----------------------------------');

        //AMI 24/07/17 :
        // build shoppingListExistAssessMap  --> contains assessmentID and all received parts for existing ass only
        // method returning existingAssessMap --> existing assid + all parts received (map <assid,List<Object>parts>)
        // assessmentID = cleanseCallerSystem + assessNum + crashCode

        Map<String, list<Object>> existingAssessMap = new Map<String, list<Object>>(); 
        assessIDEntityCodeMap =  new map <String, String>();  

        //AMI 12/07/17 - duplicate handling
        mapOriginalKeyListPL = new map <string,duplicateSizeCrashCodeWrapper>();
        mapSubstituteKeyListPL = new map <string,duplicateSizeCrashCodeWrapper>();   
        
        for(Map<String, Object> receivedAssessMap : allValidAssessList){
        
            
            String callerSystem = (String.valueOf(receivedAssessMap.get('callerSystem'))).toUpperCase();
            String refNumber    = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentBodyShop')).get('ReferenceNumber')).replaceAll('[^A-Za-z0-9]', '');
            String brand        = String.valueOf(((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('Brand'));
            Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;
            String accountRefkey = callerSystem + '-' + refNumber;
            String brandCallerSystem = (callerSystem.substring(2, 3) == '_') ? callerSystem.right(callerSystem.length()-3) : callerSystem;
            String carMappingKey = (brandCallerSystem + '-' + brand).toUpperCase();

            system.debug('## carMappingKey: '+carMappingKey);

            String entityCode = String.valueOf(receivedAssessMap.get('EntityCode'));

            String assessNum = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;

            String claimRef = String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentClaim')).get('ClaimReference'));
            String plateNum = String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('PlateNumber'));
            plateNum = (plateNum != null) ? removeSpaceHypen(plateNum) : plateNum;
            
            // if plate number is null, take VIN
            String assessCode = (plateNum != null) ? plateNum : String.valueOf( ((Map<String, Object>) receivedAssessMap.get('currentAsset')).get('VINNumber'));
            String receivedCrashCode = (receivedAssessMap.get('crashCode') != null) ? String.valueOf( receivedAssessMap.get('crashCode')) : null;
           
            String crashCode = (receivedCrashCode != null && receivedCrashCode.trim().length() == 1) ? ('0' + receivedCrashCode) : receivedCrashCode;
            
            // case C-001885
            //String crossbrand = carRefMap.get(carMappingKey).CarCrossRef__c;
            String callerCarDest = carMapBrandMap.containsKey(carMappingKey) ? carMapBrandMap.get(carMappingKey) : null;
            String catalogCarDest = callerCarDest != null ? carMapCrossRefMap.get('CATALOG-'+callerCarDest): null;
            system.debug('## callerCarDest: '+callerCarDest);
            system.debug('## catalogCarDest: '+catalogCarDest);
            
            String accountRefMapKey = (accRefMap.get(accountRefkey) != null) ? accRefMap.get(accountRefkey).InternalReference__c : null;
            Account BSAccount; 
            String accRefNumber;
            Boolean isEligibleSubstitution;

            // ASE: 13/03/2017 : No substitution if brand is found in CarBrandExcluded__c
            Boolean carBrandExcluded = false;  

            system.debug('## brand:'+brand);
            system.debug('## callerCarDest:'+callerCarDest);
            if(accountRefMapKey != null){
                system.debug('## BSAccount: '+BSAccount);
                //accRefNumber = (bsRefAccountMap.get(accountRefMapKey) != null) ? bsRefAccountMap.get(accountRefMapKey).ReferenceNumber__c : null;
                BSAccount = (bsRefAccountMap.get(accountRefMapKey) != null) ? bsRefAccountMap.get(accountRefMapKey): null;
                accRefNumber = BSAccount != null ?  BSAccount.ReferenceNumber__c : null;
                //accRefNumber = (bsRefAccountMap.get(accountRefMapKey) != null) ? bsRefAccountMap.get(accountRefMapKey).ReferenceNumber__c : null;
                //isEligibleSubstitution = bsRefAccountMap.get(accountRefMapKey).isEligibleSubstitution__c;
                
                isEligibleSubstitution = BSAccount != null ?  BSAccount.isEligibleSubstitution__c : false;
                

                // ase: 05/12/17 : lien BS evol
                String carBrandExcl;
                // expert BS
                if(claimPlateCarBrandExcludedMap.size() > 0 && claimPlateCarBrandExcludedMap.containskey(accountRefMapKey)){
                    carBrandExcl = claimPlateCarBrandExcludedMap.get(accountRefMapKey);
                }
                // standard BS
                else{
                    carBrandExcl = (bsRefAccountMap.containskey(accountRefMapKey)) ?bsRefAccountMap.get(accountRefMapKey).CarBrandExcluded__c : null;
                }
                system.debug('## carBrandExcl:'+carBrandExcl);
                carBrandExcluded = (carBrandExcl != null && callerCarDest != null) ? ((carBrandExcl.contains(callerCarDest)) ? true : false ): false;
                system.debug('## carBrandExcluded:'+carBrandExcluded);
            }
            else{
                accRefNumber = null;
                isEligibleSubstitution = false;
                carBrandExcluded = false;
            }            

            String assessmentID; 
            String cleanseCallerSystem = (callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) + callerSystem.right(callerSystem.length()-3) : userRolePrefix + callerSystem;
            system.debug('## cleanseCallerSystem:' +cleanseCallerSystem);
            
            if(assessNum == null || assessNum == ''){ 
                if(isShoppingList){
                    //C-001937 : ASE 2017/06/15
                    //assessmentID = userRolePrefix + callerSystem +  ' - ' +datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    assessmentID = cleanseCallerSystem +  ' - ' +datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');                
                }
                else{
                    //C-001937 : ASE 2017/06/15
                    //assessmentID = (userRolePrefix + callerSystem + claimRef + accRefNumber + assessCode + crashCode).toUpperCase() ; 
                    
                    //AMI 24/04/17 :
                    //cleanseCallerSystem --> clean caller system (ex : frdiva)
                    //claimRef            --> ClaimReference on assess
                    //accRefNumber        --> body shop accid (obtained from custom setting)
                    //assessCode          --> if plate num is null, take VIN
                    //crashCode           --> crash code on asses
                    assessmentID = (cleanseCallerSystem + claimRef + accRefNumber + assessCode + crashCode).toUpperCase() ;  
                    assessNum =  (claimRef + accRefNumber + assessCode).toUpperCase(); 
                } 
                          
                // create new part and perform substitution with best match and add in newOriginalMap
                for(Object partList : (List<Object>)receivedAssessMap.get('Parts')){
                    Object p = buildnewOriginalList(partList, isEligibleSubstitution, isShoppingList, carBrandExcluded);
                    if(p != null){
                        if(!newOriginalMap.containskey(assessmentID)){
                            List<Object> partListToReturn = new List<Object>();
                            partListToReturn.add(p);
                            newOriginalMap.put(assessmentID,  partListToReturn);
                        }
                        else{
                            newOriginalMap.get(assessmentID).add(p);
                        }   
                    }               
                } 

                allValidAssessMap.put(assessmentID, receivedAssessMap);    

                // ASE : case C-001828
                if(crashCode != '' || crashCode != null){
                    //assessmentClaimIDSet.add(userRolePrefix + callerSystem + refNumber + crossbrand + claimRef + assessCode);
                    //C-001937 : ASE 2017/06/15
                    //assessmentClaimIDSet.add((userRolePrefix + callerSystem + claimRef + accRefNumber + assessCode).toUpperCase()); 
                    assessmentClaimIDSet.add((cleanseCallerSystem + claimRef + accRefNumber + assessCode).toUpperCase());            
                }           
            }

            // add in existingAssessMap to further get all parts and substitutes using assessmentId
            else{
                //C-001937 : ASE 2017/06/15  
                //assessmentID = (userRolePrefix + callerSystem + assessNum + crashCode).toUpperCase() ;
                assessmentID = (cleanseCallerSystem + assessNum + crashCode).toUpperCase() ;     
                if(isShoppingList){
                    //assessmentID = (userRolePrefix + callerSystem + assessNum).toUpperCase() ;  
                    shoppingListExistAssessMap.put(assessmentID, (List<Object>)receivedAssessMap.get('Parts'));
                } 

                existingAssessMap.put(assessmentID, (List<Object>)receivedAssessMap.get('Parts'));
                isEligibleMap.put(assessmentID, String.ValueOf(isEligibleSubstitution) + ':' + String.ValueOf(isShoppingList) + ':' + String.ValueOf(carBrandExcluded)); 
                allValidAssessMap.put(assessmentID, receivedAssessMap);              
                system.debug('## isEligibleMap:'+isEligibleMap);
                
                // ASE : case C-001828
                if(crashCode != '' || crashCode != null){
                    //assessmentClaimIDSet.add(userRolePrefix + callerSystem + refNumber + crossbrand + claimRef + assessCode);
                    //C-001937 : ASE 2017/06/15     
                    //assessmentClaimIDSet.add((userRolePrefix + callerSystem + assessNum).toUpperCase());   
                    assessmentClaimIDSet.add((cleanseCallerSystem + assessNum).toUpperCase());          
                }
            }

            //AMI 12/07/17 - duplicate handling
            //build mapOriginalKeyListPL and mapSubstituteKeyListPL to know if duplicate parts are being supplied in request
            for(Object partList : (List<Object>)receivedAssessMap.get('Parts')){

                Map<String, Object> partListMap = (Map<String, Object>) partList;

                String partNumber       = String.valueOf(partListMap.get('PartNumber'));
                String partDescription  = String.valueOf(partListMap.get('PartLabel'));
                String partLabel        = partDescription.left(80);
                String alphaScaleMRID   = (partListMap.get('AlphaScaleMRID') != null) ? String.valueOf(partListMap.get('AlphaScaleMRID')) : '';
                //Boolean isSelected      = (partListMap.get('IsSelected') != null) ? Boolean.valueOf(partListMap.get('IsSelected')) : false;
                String manufacturer     = String.ValueOf(partListMap.get('Manufacturer'));
                string crash            = String.ValueOf(partListMap.get('crashCode'));

                //AMI 19/07/17 : New External Id being sent in ass request
                string newExtId         = String.ValueOf(partListMap.get('ExternalID'));
                
                if(alphaScaleMRID == ''){
                    //AMI 19/07/17 : New External Id being sent in ass request
                    String originalKey = '';
                    
                    if(string.isNotBlank(newExtId)){
                        originalKey = (assessmentID + '-' + newExtId).toUpperCase();
                    }
                    else{
                        originalKey = (null + '-' 
                                    + partNumber + '-' 
                                    + partLabel.replaceAll('\\s+', '') + '-' 
                                    + manufacturer + '-' 
                                    + assessmentID + '-' 
                                    + null).toUpperCase();

                    }

                    if(mapOriginalKeyListPL.containsKey(originalKey)){
                        duplicateSizeCrashCodeWrapper temp = mapOriginalKeyListPL.get(originalKey);
                        temp.size = temp.size + 1;
                        temp.crash.add(crash);
                        temp.lstCrash.add(crash);
                        mapOriginalKeyListPL.put(originalKey,temp);
                    }else{
                        mapOriginalKeyListPL.put(originalKey,new duplicateSizeCrashCodeWrapper(1,new set <string>{crash},new list <string>{crash}));
                    }
                }else{
                    string substituteKey = assessmentID +'-'+ alphaScaleMRID +'-'+ partDescription.split(' - ')[0]; 

                    if(mapSubstituteKeyListPL.containsKey(substituteKey)){
                        duplicateSizeCrashCodeWrapper temp = mapSubstituteKeyListPL.get(substituteKey);
                        temp.size = temp.size + 1;
                        temp.crash.add(crash);
                        temp.lstCrash.add(crash);
                        mapSubstituteKeyListPL.put(substituteKey,temp);
                    }else{
                        mapSubstituteKeyListPL.put(substituteKey,new duplicateSizeCrashCodeWrapper(1,new set <string>{crash},new list <string>{crash}));
                    }
                }
            }//end looping in partlist
            system.debug('## <> mapOriginalKeyListPL ' + mapOriginalKeyListPL);
            system.debug('## <> mapSubstituteKeyListPL ' + mapSubstituteKeyListPL);

            //build map <AssessmentId, accountReference__c>
            if (accRefMap != null){
                assessAccountRefMap.put(assessmentID, accRefMap.get(accountRefkey));

                 //build map<assessmentId, CategoriesSet>
                 Set<String> BScategoriesSet;
                 String BScategories = BSAccount != null ?  BSAccount.Categories__c : null;
                 if(BScategories != null){
                     BScategoriesSet = new Set<String>(BScategories.split(';'));
                 }

                 assessBSCategoriesMap.put(assessmentID, BScategoriesSet);
            }
               
            system.debug('## assessBSCategoriesMap: '+assessBSCategoriesMap);       

            //build map <AssessmentId, carRef>
            //assessCarMap.put(assessmentID, carRefMap.get(carMappingKey));
            //map<assessId, brand sent in response; car destination for callerId; car destination for CATALOG>
            //ASE: 02/03/2017: C-001885
             assessCarMap.put(assessmentID, brand + ';' + callerCarDest + ';' + catalogCarDest);

            //build map <AssessmentId, entityCode>
            assessIDEntityCodeMap.put(assessmentID, entityCode);            
        }
        system.debug('## shoppingListExistAssessMap:'+shoppingListExistAssessMap);
        system.debug('## assessmentClaimIDSet:'+assessmentClaimIDSet);
        system.debug('## assessCarMap:'+assessCarMap);
        system.debug('## existingAssessMap:'+existingAssessMap);
        system.debug('## assessCarMap:'+assessCarMap);
        system.debug('## isEligibleMap:'+ isEligibleMap);

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - filterAssessment ----------------------------------');
    
        return existingAssessMap;
    }

    public static String removeSpaceHypen(String s){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - removeSpaceHypen ----------------------------------');

        s = s.replaceAll( '\\s+', '');
        s = s.replaceAll( '-', '');

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - removeSpaceHypen ----------------------------------');
        return s;
    }

    public static void retrievePartHierachy (set<String> existingAssessMapKeySet, set<String> shoppingListExistAssessKeySet, Map<String, Assessment__c> assessMap) {
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - retrievePartHierachy -------------------------------');

        // ASE 22/01/2017: case C-001828
        Set<String> bothAssessSet = new Set<String>();
        bothAssessSet.addAll(assessmentClaimIDSet);
        bothAssessSet.addAll(existingAssessMapKeySet);
        bothAssessSet.addAll(shoppingListExistAssessKeySet);

        system.debug('## assessmentClaimIDSet:'+assessmentClaimIDSet);
        system.debug('## existingAssessMapKeySet:'+existingAssessMapKeySet);
        system.debug('## shoppingListExistAssessKeySet:'+shoppingListExistAssessKeySet);
        system.debug('## assessMap:'+assessMap);
        system.debug('## bothAssessSet:'+bothAssessSet);
     
        for(PartList__c pl : [SELECT Alpha_Scale_MRID__c, DistributorPriceId__c, isDeleted__c, CrossReferenceId__r.IAMPartNumber__c, SelectedByBS__c, OriginalPart__c, OriginalPart__r.TECH_OriginalPart__c, OriginalPart__r.PartNumber__c, OriginalPart__r.Description__c,
                                     Assessment__r.AssessmentNumber__c ,Assessment__r.AssessmentId__c, Assessment__r.RecordTypeId, Description__c, Name, PartNumber__c, Price__c, ProducerName__c, Quantity__c, 
                                     RecordTypeId, Type__c , Compliance__c, InputType__c, Currency__c, Assessment__c ,InterventionCode__c 
                                    ,NBHoursLabourPartLevel1__c, NBHoursLabourPartLevel2__c ,NBHoursLabourPartLevel3__c ,NBHoursLabourPainting__c/*, crashCode__c*/ 
                                    ,ARCAUTOCode__c ,/*Discount__c ,*/VAT__c , CertifyingOrganization__c, TECH_OriginalPart__c, Id, RecordType.Name, Assessment__r.CrossReferences__c,
                                     Assessment__r.callerSystem__c, /*Assessment__r.BSInternalRef__c,*/ Assessment__r.crashCode__c, Assessment__r.Entity__c,    Assessment__r.EntityCode__c,    /*Assessment__r.ExpertValidationDate__c,*/  Assessment__r.MissionNumber__c, Assessment__r.VINCheck__c,  Assessment__r.Status__c,    Assessment__r.TECH_EntityCountryCode__c,Assessment__r.IsShoppingList__c,
                                     Assessment__r.OrderOrigin__c,   Assessment__r.PreviousStatus__c, Assessment__r.Manufacturer__c,  Assessment__r.ModelV2__c,   Assessment__r.PlateNumber2__c,  Assessment__r.FirstRegistrationDate__c, Assessment__r.VINNumber__c, Assessment__r.KMS__c,   Assessment__r.PaintingType__c,  Assessment__r.Colour__c,    /*Assessment__r.Energy__c,*/    Assessment__r.PickupDate__c,
                                     Assessment__r.VDSCode__c,   Assessment__r.ClaimReference__c,    Assessment__r.CompanyName__c,   Assessment__r.DateOfIncident__c,    Assessment__r.RepairsAuthorised__c, Assessment__r.SupposedOfFraud__c,   Assessment__r.TotalLoss__c, Assessment__r.Fleet__c, /*Assessment__r.SpecialRenting__c,*/    Assessment__r.SpecialAgreement__c,  Assessment__r.QuotationAmtExlVAT__c,
                                     Assessment__r.QuotationAmountInclVAT__c,    Assessment__r.TotalAmtLabourPainting__c,    Assessment__r.TotalAmtLabour__c,    Assessment__r.TotalAmtParts__c, Assessment__r.TotalAmtPainting__c,  Assessment__r.TotalAmtExlVAT__c,    Assessment__r.TotalVAT__c,  Assessment__r.TotalAmtInclVAT__c,
                                     Assessment__r.NBHoursLabour__c, Assessment__r.NBHoursLabourLevel1__c,   Assessment__r.NBHoursLabourLevel2__c,   Assessment__r.NBHoursLabourLevel3__c, StandardMargin__c, StandardDiscount__c, Stock__c,
                                     Assessment__r.TotalAmtLabourExlPainting__c, Assessment__r.NBHoursLabourPainting__c, Assessment__r.TotalAmtPaintingInclLabour__c,    /*Assessment__r.AmtOthers__c,*/ Assessment__r.ExcessAmount__c,  Assessment__r.BodyShop__c,  Assessment__r.Name, Assessment__r.ParentAssessment__c, Assessment__r.ParentAssessment__r.AssessmentId__c

                              FROM PartList__c WHERE Assessment__r.AssessmentId__c in: bothAssessSet]){
            system.debug('## pl ' + pl);
            if(shoppingListExistAssessKeySet.contains(pl.Assessment__r.AssessmentId__c)){
                            
                if(!shoppingListExistAssessFound.contains(pl.Assessment__r.AssessmentId__c)){
                    shoppingListExistAssessFound.add(pl.Assessment__r.AssessmentId__c);
                }                       

                if(!assessSFDCIDMap.containskey(pl.Assessment__r.AssessmentId__c)){
                    assessSFDCIDMap.put(pl.Assessment__r.AssessmentId__c, pl.Assessment__c);
                }

                // AMI : Capturing existing assessment in database
                if(!assessMap.containskey(pl.Assessment__r.AssessmentId__c)){
                    system.debug('## assessMap.containskey(pl.Assessment__r.AssessmentId__c');
                    assessMap.put(pl.Assessment__r.AssessmentId__c, new Assessment__c(  AssessmentId__c = pl.Assessment__r.AssessmentId__c,
                                                                                        callerSystem__c = pl.Assessment__r.callerSystem__c,                           
                                                                                        crashCode__c = pl.Assessment__r.crashCode__c,                           
                                                                                        Entity__c = pl.Assessment__r.Entity__c,                         
                                                                                        EntityCode__c = pl.Assessment__r.EntityCode__c,                          
                                                                                        MissionNumber__c = pl.Assessment__r.MissionNumber__c,                           
                                                                                        VINCheck__c = pl.Assessment__r.VINCheck__c,                         
                                                                                        Status__c = pl.Assessment__r.Status__c,                         
                                                                                        TECH_EntityCountryCode__c = pl.Assessment__r.TECH_EntityCountryCode__c,                         
                                                                                        RecordTypeId = pl.Assessment__r.RecordTypeId,                           
                                                                                        IsShoppingList__c = pl.Assessment__r.IsShoppingList__c,                         
                                                                                        OrderOrigin__c = pl.Assessment__r.OrderOrigin__c,                           
                                                                                        PreviousStatus__c = pl.Assessment__r.PreviousStatus__c,                            
                                                                                        Manufacturer__c = pl.Assessment__r.Manufacturer__c,                         
                                                                                        ModelV2__c = pl.Assessment__r.ModelV2__c,                           
                                                                                        PlateNumber2__c = pl.Assessment__r.PlateNumber2__c,                         
                                                                                        FirstRegistrationDate__c = pl.Assessment__r.FirstRegistrationDate__c,                           
                                                                                        VINNumber__c = pl.Assessment__r.VINNumber__c,                           
                                                                                        KMS__c = pl.Assessment__r.KMS__c,                           
                                                                                        PaintingType__c = pl.Assessment__r.PaintingType__c,                         
                                                                                        Colour__c = pl.Assessment__r.Colour__c,                        
                                                                                        PickupDate__c = pl.Assessment__r.PickupDate__c,                         
                                                                                        VDSCode__c = pl.Assessment__r.VDSCode__c,                           
                                                                                        ClaimReference__c = pl.Assessment__r.ClaimReference__c,                         
                                                                                        CompanyName__c = pl.Assessment__r.CompanyName__c,                           
                                                                                        DateOfIncident__c = pl.Assessment__r.DateOfIncident__c,                         
                                                                                        RepairsAuthorised__c = pl.Assessment__r.RepairsAuthorised__c,                           
                                                                                        SupposedOfFraud__c = pl.Assessment__r.SupposedOfFraud__c,                           
                                                                                        TotalLoss__c = pl.Assessment__r.TotalLoss__c,                           
                                                                                        Fleet__c = pl.Assessment__r.Fleet__c,                         
                                                                                        SpecialAgreement__c = pl.Assessment__r.SpecialAgreement__c,                         
                                                                                        QuotationAmtExlVAT__c = pl.Assessment__r.QuotationAmtExlVAT__c,                         
                                                                                        QuotationAmountInclVAT__c = pl.Assessment__r.QuotationAmountInclVAT__c,                         
                                                                                        TotalAmtLabourPainting__c = pl.Assessment__r.TotalAmtLabourPainting__c,                         
                                                                                        TotalAmtLabour__c = pl.Assessment__r.TotalAmtLabour__c,                         
                                                                                        TotalAmtParts__c = pl.Assessment__r.TotalAmtParts__c,                           
                                                                                        TotalAmtPainting__c = pl.Assessment__r.TotalAmtPainting__c,                         
                                                                                        TotalAmtExlVAT__c = pl.Assessment__r.TotalAmtExlVAT__c,                         
                                                                                        TotalVAT__c = pl.Assessment__r.TotalVAT__c,                         
                                                                                        TotalAmtInclVAT__c = pl.Assessment__r.TotalAmtInclVAT__c,                           
                                                                                        NBHoursLabour__c = pl.Assessment__r.NBHoursLabour__c,                           
                                                                                        NBHoursLabourLevel1__c = pl.Assessment__r.NBHoursLabourLevel1__c,                           
                                                                                        NBHoursLabourLevel2__c = pl.Assessment__r.NBHoursLabourLevel2__c,                           
                                                                                        NBHoursLabourLevel3__c = pl.Assessment__r.NBHoursLabourLevel3__c,                           
                                                                                        TotalAmtLabourExlPainting__c = pl.Assessment__r.TotalAmtLabourExlPainting__c,                           
                                                                                        NBHoursLabourPainting__c = pl.Assessment__r.NBHoursLabourPainting__c,                           
                                                                                        TotalAmtPaintingInclLabour__c = pl.Assessment__r.TotalAmtPaintingInclLabour__c,                           
                                                                                        ExcessAmount__c = pl.Assessment__r.ExcessAmount__c,                         
                                                                                        BodyShop__c = pl.Assessment__r.BodyShop__c,                         
                                                                                        AssessmentNumber__c = pl.Assessment__r.AssessmentNumber__c,                         
                                                                                        Name = pl.Assessment__r.Name,
                                                                                        Id = (pl.Assessment__r.RecordTypeId == recordTypeAssessTypeMap.get('Claim')) ? pl.Assessment__c : pl.Assessment__r.ParentAssessment__c                        
                                                                                        ));
                }
            }
                        
            if(pl.originalPart__c == null){
                //this is an original part
                //add in map<OriginalPart.techId, OriginalPart> originalPartsMap
                if(pl.TECH_OriginalPart__c != null){
                    //ASE : 27/03/17 : delete
                    if((pl.Assessment__r.RecordTypeId == recordTypeAssessTypeMap.get('Claim') && !assessmentClaimIDSet.contains(pl.Assessment__r.AssessmentId__c)) 
                        || pl.Assessment__r.RecordTypeId == recordTypeAssessTypeMap.get('Crash')){
                        allOriSubPartsSet.add(pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase());
                    }
                                            
                    originalPartsMap.put(pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase() , pl);                  
                }                 
            }
            // part is a substitute
            else{
                //ASE : 27/03/17 : delete                
                String subKey = pl.Assessment__r.AssessmentId__c + '-' + pl.Alpha_Scale_MRID__c + '-' + pl.Description__c.split(' - ')[0];
                if((pl.Assessment__r.RecordTypeId == recordTypeAssessTypeMap.get('Claim') && !assessmentClaimIDSet.contains(pl.Assessment__r.AssessmentId__c)) 
                        || pl.Assessment__r.RecordTypeId == recordTypeAssessTypeMap.get('Crash')){
                    if(!allAssessSubOriginalMap.containskey(subKey)){
                        allAssessSubOriginalMap.put(subKey, new set<String> {(pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase()});
                    }
                    else{
                        allAssessSubOriginalMap.get(subKey).add((pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase());
                    }
                    allsubPartsMap.put(subKey, pl);

                    allOriSubPartsSet.add(subKey);

                } 
               
                //AMI 10/10/17 - crash management bug (duplicate handling - no upper case was specified)
                if(!originalSubstitutesMap.containskey((pl.Assessment__r.AssessmentId__c + '-' + pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase())){
                    originalSubstitutesMap.put( pl.Assessment__r.AssessmentId__c + '-' + (pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase(), new List<PartList__c> {pl});
                }
                else{
                    originalSubstitutesMap.get(pl.Assessment__r.AssessmentId__c + '-' + (pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase()).add(pl);
                }

                // ASE : 01/03/2017 : split description of substitute
                if(!assessSubOriginalMap.containskey(subKey)){
                    assessSubOriginalMap.put(subKey, new List<String> {(pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase()});
                }
                else{
                    assessSubOriginalMap.get(subKey).add((pl.OriginalPart__r.TECH_OriginalPart__c).toUpperCase());
                }
                
                if(shoppingListExistAssessKeySet.contains(pl.Assessment__r.AssessmentId__c)){
                    if(!shoppingListExistAssessFound.contains(pl.Assessment__r.AssessmentId__c)){
                        shoppingListExistAssessFound.add(pl.Assessment__r.AssessmentId__c);
                    }

                    if(!ASCRPartNumbMap.containskey(pl.Alpha_Scale_MRID__c)){
                        ASCRPartNumbMap.put(pl.Alpha_Scale_MRID__c, pl.CrossReferenceId__r.IAMPartNumber__c);
                    }                    
                }
            }                   
                
            // used for cloning crash assessments, parts and substitutes. 
            if(pl.Assessment__r.RecordTypeId == recordTypeAssessTypeMap.get('Claim') && assessmentClaimIDSet.contains(pl.Assessment__r.AssessmentId__c)){
                if(!claimOriginalSubstitutesMap.containskey(pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase())){
                    claimOriginalSubstitutesMap.put(pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase(), pl);
                }                
            } 

            // used to clone deleted field on claim assessment if assessment sent is a Crash
            // note: this map is populated seperately because when looping through existing parts 
            //during parts creation/ updates, parts to be deleted are not present.
            if(pl.Assessment__r.RecordTypeId == recordTypeAssessTypeMap.get('Crash')){
                if(!claimcrashOriginalSubstitutesMap.containskey(pl.TECH_OriginalPart__c.toUpperCase())){
                    claimcrashOriginalSubstitutesMap.put(pl.TECH_OriginalPart__c.toUpperCase(), pl);                
                }
            }            


        }

        //system.debug('## originalPartsMap: '+originalPartsMap);
        system.debug('## originalSubstitutesMap: '+originalSubstitutesMap);
        /*system.debug('## assessSubOriginalMap: '+assessSubOriginalMap);
        system.debug('## claimOriginalSubstitutesMap: '+claimOriginalSubstitutesMap);
        system.debug('## asessPartSubMap: '+asessPartSubMap);
        system.debug('## assessSFDCIDMap:'+assessSFDCIDMap);
        system.debug('## shoppingListExistAssessFound:'+shoppingListExistAssessFound);
        system.debug('## assessSFDCIDMap:'+assessSFDCIDMap);
        system.debug('## allAssessSubOriginalMap: '+allAssessSubOriginalMap);
        system.debug('## allsubPartsMap: '+allsubPartsMap);
        system.debug('## claimcrashOriginalSubstitutesMap:'+claimcrashOriginalSubstitutesMap);*/

        system.debug('## shoppingListExistAssessKeySet:'+shoppingListExistAssessKeySet);
        system.debug('## assessMap:'+assessMap);

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - retrievePartHierachy ---------------------------------');
    }

    // method that filter partList in Json whether it's an original or a substitute.
    public static void filterExistingPartList(map<String , List<Object>> existingAssessMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - filterExistingPartList ----------------------------------');
        
        set<String> sentPartsSet = new set<String>();         
        
        // parts to be created
        if(existingAssessMap.size() > 0 ){
            for(String assessmentId: existingAssessMap.keyset()){
                String inExistingSubstitutes = '';            
                for (Object receivedPart : existingAssessMap.get(assessmentId)){
                    
                    Map<String, Object> receivedPartMap = (Map<String, Object>)receivedPart;
                    
                    String alphaScaleMRID               = (receivedPartMap.get('AlphaScaleMRID') != null) ? String.valueOf(receivedPartMap.get('AlphaScaleMRID')) : '';
                    String PN                           = String.valueOf(receivedPartMap.get('PartNumber'));
                    String description                  = String.valueOf(receivedPartMap.get('PartLabel'));
                    String partName                     = description.left(80);
                    String manufacturer                 = String.ValueOf(receivedPartMap.get('Manufacturer'));

                    //AMI 19/07/17 : New External Id being sent in ass request
                    string newExtId                     = String.ValueOf(receivedPartMap.get('ExternalID'));
                    system.debug('## newExtId ' + newExtId);

                    if(alphaScaleMRID == ''){
                        //AMI 19/07/17 : New External Id being sent in ass request
                        String orignalKey = assessmentId + '-' + buildPartTechnicalId(assessmentId, PN, partName, manufacturer,newExtId);
                        system.debug('## orignalKey:'+orignalKey);
                        sentPartsSet.add(orignalKey);

                        if(originalSubstitutesMap.get(orignalKey) != null){
                            for(PartList__c substitute : originalSubstitutesMap.get(orignalKey)){
                                String substituteKey = substitute.Assessment__r.AssessmentId__c + '-' + substitute.Alpha_Scale_MRID__c + '-' + substitute.Description__c.split(' - ')[0]; 
                                sentPartsSet.add(substituteKey);
                            }                                                                              
                        }                                           

                        if(!originalPartsMap.containsKey(orignalKey)){
                            //create new part and perform substitution with best match
                            list<String> booleanList = isEligibleMap.get(assessmentId).split(':');
                            Object p = buildnewOriginalList(receivedPart, Boolean.ValueOf(booleanList[0]), Boolean.ValueOf(booleanList[1]), Boolean.ValueOf(booleanList[2]));
                            if(p != null){
                                if(!newOriginalMap.containskey(assessmentID)){
                                    List<Object> partListToReturn = new List<Object>();
                                    partListToReturn.add(p);
                                    newOriginalMap.put(assessmentID,  partListToReturn);
                                }
                                else{
                                    newOriginalMap.get(assessmentID).add(p);
                                }   
                            }                       
                        }                        
                    }
                    else{
                        String substituteKey = assessmentID + '-' + alphaScaleMRID + '-' + description.split(' - ')[0]; 
                        system.debug('## substituteKey:'+substituteKey);
                        // this is a substitute
                        if(!assessSubOriginalMap.containsKey(substituteKey)){
                            inExistingSubstitutes += PN  + ','; 
                        }

                        //build map <assessId-substitute, partList>
                        // ASE : 13/12/16 : adding description to key to differentiate b/w substitutes                    
                        assessSubstituteMap.put(substituteKey, receivedPart);

                        sentPartsSet.add(substituteKey); 
                        //system.debug('## sentPartsSet:'+sentPartsSet); 
                        if(allAssessSubOriginalMap.get(substituteKey) != null){
                            system.debug('original: '+allAssessSubOriginalMap.get(substituteKey));
                            for(String original : allAssessSubOriginalMap.get(substituteKey)){                                
                                sentPartsSet.add(assessmentId + '-' +original);
                                for(PartList__c otherSub : originalSubstitutesMap.get(assessmentId + '-' +original)){
                                    String otherSubKey = otherSub.Assessment__r.AssessmentId__c + '-' + otherSub.Alpha_Scale_MRID__c + '-' + otherSub.Description__c.split(' - ')[0];                                 
                                    sentPartsSet.add(otherSubKey);                                
                                }
                                //system.debug('## sentPartsSet:'+sentPartsSet);                         
                            }                                                                                  
                        }
                    } 
                }
                if(inExistingSubstitutes != ''){
                    //AMI 06/07/2017 - Adding warning message exception handling
                    //mapErrorsCreation.put('Assessment ID ' + assessmentID + 'do not contain substitutes: ', inExistingSubstitutes);  
                    mapWarningCreation.put('Assessment ID ' + assessmentID + 'do not contain substitutes: ', inExistingSubstitutes);              
                }
            }     
        }

        // loop in existing original parts only. Substitutes cannot exist without original.
        system.debug('## allOriSubPartsSet ' + allOriSubPartsSet);
        system.debug('## sentPartsSet ' + sentPartsSet);

        for(string str : allOriSubPartsSet){
            system.debug('## aaaa  ' + str);
        }

        for(string str : sentPartsSet){
            system.debug('## bbbb  ' + str);
        }

        system.debug('## originalPartsMap ' + originalPartsMap);
        system.debug('## originalSubstitutesMap ' + originalSubstitutesMap);
        if(allOriSubPartsSet.size() > 0){
            for(String key : allOriSubPartsSet){
                if(!sentPartsSet.contains(key)){   
                    system.debug('## key ' + key);
                    
                    if(originalPartsMap.containskey(key)){
                        partsToDelSet.add(originalPartsMap.get(key).TECH_OriginalPart__c);
                        if(originalSubstitutesMap.get(key) != null){
                            system.debug('## originalSubstitutesMap.get(key) ' + originalSubstitutesMap.get(key));
                            for(PartList__c substitute : originalSubstitutesMap.get(key)){
                                partsToDelSet.add(substitute.TECH_OriginalPart__c);
                            }                                                                              
                        }                         
                    }
                    else{
                        if(allsubPartsMap.containsKey(key)){
                            partsToDelSet.add(allsubPartsMap.get(key).TECH_OriginalPart__c);
                            if(allAssessSubOriginalMap.get(key) != null){
                                system.debug('## allAssessSubOriginalMap.get(key) ' + allAssessSubOriginalMap.get(key));
                                for(String original : allAssessSubOriginalMap.get(key)){
                                    partsToDelSet.add(original);
                                }                                                                                  
                            }
                        }
                    }
                }                    
            }                    
        }

        system.debug('## partsToDelSet:'+partsToDelSet);
        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - filterExistingPartList ----------------------------------');

    }

    // method that build part.TECH_OriginalPart__c of the received assessments
    //AMI 19/07/17 : New External Id being sent in ass request
    public static String buildPartTechnicalId(String assessmentId, String partNumber, String partLabel, String manufacturer, string extId){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - buildPartTechnicalId ----------------------------------');

        String partExternalId   = '';

        if(string.isNotBlank(extId)){
            partExternalId  = assessmentId + '-' + extId;
        }else{
            partExternalId  = null + '-' 
                            + partNumber + '-' 
                            + partLabel.replaceAll('\\s+', '') + '-' 
                            + manufacturer + '-' 
                            + assessmentId + '-' 
                            + null;
        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - buildPartTechnicalId ----------------------------------');
        return partExternalId.toUpperCase();
    }

    // loop in these partList and select those that have to undergo substitution process
    public static Object buildnewOriginalList (Object receivedPart, Boolean isEligibleSubstitution, Boolean isShoppingList, Boolean carBrandExcluded){
        System.debug('----------------------- START RESTUpsertAssessmentV1 - buildPartToBeSubstitutedList -------------------------------');

        Map<String, Object> receivedPartMap = (Map<String, Object>) receivedPart;

        String recordType                   = String.valueOf(receivedPartMap.get('RecordType'));
        String inputType                    = String.valueOf(receivedPartMap.get('InputType'));
        

        system.debug(recordType);
        system.debug(inputType);
        system.debug(isEligibleSubstitution);
        system.debug(isShoppingList);
        system.debug(carBrandExcluded);


        System.debug('----------------------- END RESTUpsertAssessmentV1 - buildPartToBe--SubstitutedList -------------------------------');

        // parts having record type 'labour' and inputType 'manual' do not require substitution
        if(recordType.toUpperCase() !='LABOUR' && inputType.toUpperCase()  != 'MANUAL' && isEligibleSubstitution && !isShoppingList && !carBrandExcluded){
            return receivedPart;
        }
        else{
            return null;
        }       
        
    }

    public static Map<String, Map<String, List<Object>>> buildSubstitutionMap(Map<String, list<Object>> originalMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - buildSubstitutionMap ----------------------------------');

        //map<entity, map<AssId-AssBrand-CountryCode, list<partList>>>
        Map<String, Map<String, List<Object>>> mapEntitymapAsslistParts = new Map<String, Map<String, List<Object>>>();
        system.debug('## originalMap:'+originalMap);       
        for(String assessmentID: originalMap.keySet()){
            List<Object> receivedPartList = originalMap.get(assessmentID);

            //ASE: 02/03/2017: C-001885
            //String crossRefbrand = assessCarMap.get(assessmentID).CarCrossRef__c;
            String crossRefbrand = assessCarMap.get(assessmentID).split(';')[2];
            system.debug('## RESTCallWsInvoice crossRefbrand:'+crossRefbrand);

            //C-001937
            String techCountryCode = assessmentID.left(2);
            //String entityCode    = userRolePrefix + assessIDEntityCodeMap.get(assessmentID);
            String entityCode    = techCountryCode + assessIDEntityCodeMap.get(assessmentID);

            if(mapEntitymapAsslistParts.containsKey(entityCode)){
                mapEntitymapAsslistParts.get(entityCode).put(assessmentID + '-' + crossRefbrand + '-' + techCountryCode, receivedPartList);
            }
            else{
                mapEntitymapAsslistParts.put(entityCode, new Map<String, List<Object>> {assessmentID + '-' + crossRefbrand + '-' + techCountryCode => receivedPartList});
            }           
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - buildSubstitutionMap ----------------------------------');
        return mapEntitymapAsslistParts;
    }

    public static void processValidAssess(
        Map<String, Map<String, Object>> validAssessMap, 
        Map<String, ASPISServiceSubstitution.SubstituteWrapper> mapEntitySubstituteWrapper, 
        List<Assessment__c> newAssessmentList, 
        map<String, Assessment__c> claimAssessmentMap, 
        List<PartList__c> newPartList, 
        Map<String, List<PartList__c>> assessIdPartsMap, 
        Map<String, List<PartList__c>> assessSubstituteListMap, 
        Map<String, Assessment__c> assessMap, 
        Map<String, List<CrossReference__c>> OEMIAMMap, 
        Map<String, CrossReference__c> OEMIAMPriceMap, 
        set<String> existingAssessMapKeySet,  
        Map<String, List<Object>> shoppingListExistAssessMap, 
        Map<String, List<PartList__c>> shopAssessIdPartsMap){
        
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - processValidAssess ----------------------------------');
        //loop in MapallValidAssessMap again to start processing        
        system.debug('## shoppingListExistAssessMap:'+shoppingListExistAssessMap);
        system.debug('## validAssessMap:'+validAssessMap);
        for(String assessmentID: validAssessMap.keySet()){
            Map<String, Object> receivedAssessMap               = validAssessMap.get(assessmentID);
            
            String techCountryCode    = assessmentID.left(2);
            system.debug('## techCountryCode:'+techCountryCode);
            //String entityCode    = assessIDEntityCodeMap.get(assessmentID);
            String entityCode = (receivedAssessMap.get('EntityCode') != null && receivedAssessMap.get('EntityCode') != '') ? String.valueOf(receivedAssessMap.get('EntityCode')) : system.label.EntityCodeDefaultValue;
            // if crashCode is sent, create claim parent assessment and child crash Assessment
            String crashCode = (receivedAssessMap.get('crashCode') != null) ? String.valueOf( receivedAssessMap.get('crashCode')) : null;           
            String recordType;
            Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;
            String assNumber = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf( receivedAssessMap.get('AssessmentNumber')) : 'none';    
           

            Assessment__c claimAssess;
            //if(crashCode != null && crashCode !='' && !isShoppingList){
            if(crashCode != null && crashCode !='' ){
                recordType = 'Crash';
            }
            else{
                recordType = 'Claim';
            }

            system.debug('## assessmentID:'+assessmentID);
             
            Assessment__c assess; 
            if(!shoppingListExistAssessMap.containsKey(assessmentID)){
                assess = createAssessment(assessmentID, receivedAssessMap, recordType, OEMIAMMap);  
                newAssessmentList.add(assess);            
            } 
            else{
                assess = assessMap.get(assessmentID);
            }    
            system.debug('## assess:'+assess);   
            
            // create partList
            List<PartList__c> newPList                  = new List<PartList__c>();
            List<PartList__c> newSList                  = new List<PartList__c>();
            List<PartList__c> newSubsList               = new List<PartList__c>();
            Map<String, PartList__c> newPartMap         = new Map<String, PartList__c>();
            Map<String, List<String>> newPartDescMap    = new Map<String, List<String>>();

            if(assess != null){
                createPartList(assess.AssessmentID__c,
                               assess.IsShoppingList__c,
                               (List<Object>) receivedAssessMap.get('Parts'),
                               newPList,
                               newPartMap,
                               newPartDescMap,
                               recordType,
                               existingAssessMapKeySet,
                               OEMIAMMap,
                               shopAssessIdPartsMap,
                               shoppingListExistAssessMap.keyset(),
                               assess.CrashCode__c,
                               assess.BodyShop__c,
                               assess.TECH_EntityCountryCode__c + assess.EntityCode__c
                            ); 
                //system.debug('## newPList:'+newPList);
                newPartList.addAll(newPList);
            
                //if(!shoppingListExistAssessMap.containsKey(assessmentID)){
                if(!assess.IsShoppingList__c ){
                    if(mapEntitySubstituteWrapper != null &&
                        mapEntitySubstituteWrapper.containsKey(techCountryCode + entityCode)){
                        //DUN 12/09/2016 MasterRule Updated(added entity code as parameter)
                        newSList = createSubstitute( assess.AssessmentID__c, 
                                                    mapEntitySubstituteWrapper.get(techCountryCode + entityCode).mapAssmapOEMKeylistIAM.get(assess.AssessmentID__c), 
                                                    mapEntitySubstituteWrapper.get(techCountryCode + entityCode).mapAssessmentIAMfinal.get(assess.AssessmentID__c), 
                                                    mapEntitySubstituteWrapper.get(techCountryCode + entityCode).listUpdateFieldsCriteria,
                                                    newPartMap,
                                                    newPartDescMap,
                                                    techCountryCode + entityCode);
                        newSubsList.addAll(newSList);
                    }
                    else{
                        //DUN 12/09/2016 MasterRule Updated(added entity code as parameter)
                        newSList = createSubstitute(  assess.AssessmentID__c, 
                                                                    null, 
                                                                    null, 
                                                                    null,
                                                                    newPartMap,
                                                                    newPartDescMap,
                                                                    techCountryCode + entityCode);
                        newSubsList.addAll(newSList);
                    }
                }
                system.debug('## newSubsList:'+newSubsList);
                 // build Map<assessmentNumber, Assessment__c>
                if(!assessMap.containskey(assess.AssessmentID__c)){
                    assessMap.put(assess.AssessmentID__c, assess);
                }

       
                //AMI 17/07/17 - commented since no crash record will be created (C-001969)
                if(recordType == 'Crash'){
                    String claimAssessParentId = assess.AssessmentID__c.left(assess.AssessmentID__c.length()-2);              
                
                    String crashCodeKey = '(' + assess.AssessmentID__c.right(2) + ')';
                              
                    if(!claimOriginalSubstitutesMap.containskey(claimAssessParentId.split('-')[0])){       
                        // create claim parent first to be able to attach child crash assessment
                        claimAssess = assess.clone(false, true);
                        claimAssess.RecordTypeId = recordTypeAssessTypeMap.get('Claim'); 
                        claimAssess.AssessmentID__c = claimAssessParentId;                   
                        //claimAssessmentList.add(claimAssess);
                        if(!claimAssessmentMap.containskey(claimAssess.AssessmentID__c)){
                            claimAssessmentMap.put(claimAssess.AssessmentID__c, claimAssess);
                        }

                        assess.ParentAssessment__r = new Assessment__c(AssessmentID__c = claimAssessParentId); 
                    }
                        crashClaimIdMap.put(assess.AssessmentID__c, claimAssessParentId);

                    if(newPList.size() > 0){  
                        for(PartList__c pl : newPList){
                            PartList__c clonePL;
                            String partExternalId   = (null + '-'  + pl.PartNumber__c + '-' + pl.Description__c.replaceAll('\\s+', '') + '-' 
                                                             + pl.ProducerName__c  + '-' + claimAssessParentId + crashCodeKey + '-' + null).toUpperCase();

                            system.debug('## partExternalId:'+partExternalId);
                            crashOriClaimOriMap.put(pl.TECH_OriginalPart__c, partExternalId);
                            String claimPartKey = claimAssessParentId + '-' + partExternalId;
                            if(claimOriginalSubstitutesMap.containskey(claimPartKey)){                             
                                if(claimOriginalSubstitutesMap.get(claimPartKey)!= null && (claimOriginalSubstitutesMap.get(claimPartKey).Quantity__c != pl.Quantity__c 
                                        || claimOriginalSubstitutesMap.get(claimPartKey).SelectedByBS__c != pl.SelectedByBS__c
                                        || claimOriginalSubstitutesMap.get(claimPartKey).isDeleted__c != pl.isDeleted__c
                                    )){
                                    system.debug('## here 1');
                                    clonePL =  new PartList__c();
                                    clonePL.TECH_OriginalPart__c = partExternalId;                                
                                    clonePL.Quantity__c = pl.Quantity__c;   
                                    clonePL.SelectedByBS__c = pl.SelectedByBS__c;   
                                    clonePL.isDeleted__c = pl.isDeleted__c;                             
                                }
                            }
                            else{
                                 system.debug('## here 2');
                                clonePL = pl.clone(false, true);
                                clonePL.TECH_OriginalPart__c = partExternalId;
                                clonePL.Assessment__r = new Assessment__c(AssessmentID__c = claimAssessParentId); 

                            }   
                            system.debug('## clone PL: '+ clonePL);
                            if(clonePL != null){
                                if(!assessIdPartsMap.containsKey(claimAssessParentId)){
                                    list<PartList__c> claimPLList = new list<PartList__c>();
                                    claimPLList.add(clonePL);
                                    assessIdPartsMap.put(claimAssessParentId, claimPLList); 
                                }
                                else{
                                    assessIdPartsMap.get(claimAssessParentId).add(clonePL);
                                }                              
                            }                                               
                        }
                    }
                    system.debug('## assessIdPartsMap:'+assessIdPartsMap);
                    if(newSubsList.size() > 0){
                        system.debug('## crashSubCrashOriginalMap:' +crashSubCrashOriginalMap);
                        system.debug('## crashOriClaimOriMap:' +crashOriClaimOriMap);

                        for(PartList__c pl : newSList){
                            PartList__c clonePL;                        

                            String partExternalId   = (pl.TECH_OriginalPart__c.split('-')[0] + '-'
                                                        + pl.PartNumber__c + '-'
                                                        + pl.Name.replaceAll('\\s+', '') + '-'
                                                        + pl.ProducerName__c + '-'
                                                        + claimAssessParentId  + crashCodeKey).toUpperCase(); //+ '-'
                                                       // + pl.Alpha_Scale_MRID__c;      

                            String crashOriginal = (crashSubCrashOriginalMap != null && crashSubCrashOriginalMap.containskey(pl.TECH_OriginalPart__c)) ? crashSubCrashOriginalMap.get(pl.TECH_OriginalPart__c) : null;
                            String techOriginalPart = (crashOriginal != null && crashOriClaimOriMap != null && crashOriClaimOriMap.containskey(crashOriginal)) ? crashOriClaimOriMap.get(crashOriginal) : null;
                            

                            String claimPartKey = claimAssessParentId + '-' + partExternalId;
                            if(claimOriginalSubstitutesMap.containskey(claimPartKey)){                            
                                if(claimOriginalSubstitutesMap.get(claimPartKey)!= null && 
                                    (claimOriginalSubstitutesMap.get(claimPartKey).Quantity__c != pl.Quantity__c 
                                        || claimOriginalSubstitutesMap.get(claimPartKey).SelectedByBS__c != pl.SelectedByBS__c
                                        || claimOriginalSubstitutesMap.get(claimPartKey).isDeleted__c != pl.isDeleted__c)) {
                                    clonePL =  new PartList__c();
                                    clonePL.TECH_OriginalPart__c = partExternalId;                                
                                    clonePL.Quantity__c = pl.Quantity__c;
                                    clonePL.SelectedByBS__c = pl.SelectedByBS__c;
                                    clonePL.isDeleted__c = pl.isDeleted__c; 
                                }
                            }
                            else{                            
                                clonePL = pl.clone(false, true);
                                clonePL.TECH_OriginalPart__c = partExternalId;
                                clonePL.Assessment__r = new Assessment__c(AssessmentID__c = claimAssessParentId);
                                if(techOriginalPart != null){
                                    clonePL.OriginalPart__r = new PartList__c(TECH_OriginalPart__c = techOriginalPart);
                                }
                            } 

                            if(clonePL != null){
                                cloneSubstituteMap.put(pl.TECH_OriginalPart__c, clonePL.TECH_OriginalPart__c);

                                if(!assessSubstituteListMap.containsKey(claimAssessParentId)){
                                    list<PartList__c> claimSubList = new list<PartList__c>();
                                    claimSubList.add(clonePL);
                                    assessSubstituteListMap.put(claimAssessParentId, claimSubList); 
                                }
                                else{
                                    assessSubstituteListMap.get(claimAssessParentId).add(clonePL);
                                }                              
                            }                   
                        }                                  
                    }      
                }//end


                if(!newPList.isEmpty()){
                    assessIdPartsMap.put(assess.AssessmentID__c, newPList);       
                }

                if(!newSubsList.isEmpty()){
                    assessSubstituteListMap.put(assess.AssessmentID__c, newSubsList);             
                }
                system.debug('## assessIdPartsMap:'+assessIdPartsMap);
            }
            else{
                mapErrorsCreation.put('AssessmentID / Assessment Number not found: ', assessmentID + ' / ' +assNumber);      
            }
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - processValidAssess ----------------------------------');
    }

    public static Assessment__c createAssessment(String assessId, Map<String, Object> receivedAssessMap, String recordType, Map<String, List<CrossReference__c>> OEMIAMMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - createAssessment ----------------------------------');

        // build currentAssetMap 
        Map<String, Object> currentAssetMap;
        if(receivedAssessMap.get('currentAsset') != null){
            currentAssetMap = (Map<String, Object>) receivedAssessMap.get('currentAsset');
        }

        // build currentClaimMap
        Map<String, Object> currentClaimMap;
        if(receivedAssessMap.get('currentClaim') != null){
            currentClaimMap = (Map<String, Object>) receivedAssessMap.get('currentClaim');
        }

        Boolean isShoppingList = (receivedAssessMap.get('isShoppingList') != null) ? Boolean.valueOf(receivedAssessMap.get('isShoppingList')) : false;  

        String assessNum = (receivedAssessMap.get('AssessmentNumber') != null) ? String.valueOf(receivedAssessMap.get('AssessmentNumber')) : null;

        Assessment__c newAssessment = new Assessment__c( callerSystem__c            = String.valueOf(receivedAssessMap.get('callerSystem'))
                                                        // ,BSInternalRef__c           = String.valueOf(receivedAssessMap.get('BSInternalRef'))
                                                        ,crashCode__c               = (receivedAssessMap.get('crashCode') != null && receivedAssessMap.get('crashCode') != '') ? Integer.valueOf(receivedAssessMap.get('crashCode')) : null
                                                        ,Entity__c                  = String.valueOf(receivedAssessMap.get('Entity'))
                                                        ,EntityCode__c              = (receivedAssessMap.get('EntityCode') != null && receivedAssessMap.get('EntityCode') != '') ? String.valueOf(receivedAssessMap.get('EntityCode')) : system.label.EntityCodeDefaultValue
                                                        // ,ExpertValidationDate__c    = (receivedAssessMap.get('ExpertValidationDate') != null && !String.isBlank(String.valueOf(receivedAssessMap.get('ExpertValidationDate')))) ? (DateTime) JSON.deserialize('"' + receivedAssessMap.get('ExpertValidationDate') + '"', DateTime.class) : null
                                                        ,MissionNumber__c           = String.valueOf(receivedAssessMap.get('MissionNumber'))
                                                        ,VINCheck__c                = Integer.valueOf(receivedAssessMap.get('VINCheck'))
                                                        ,Status__c                  = 'NEW'
                                                        ,TECH_EntityCountryCode__c  = assessId.left(2)
                                                        ,RecordTypeId               = recordTypeAssessTypeMap.get(recordType)
                                                        ,IsShoppingList__c          = isShoppingList 
                                                        ,OrderOrigin__c             = 'Upsert'   
                                                        ,PreviousStatus__c          = ''   
                                                        ,HasBeenSubstituted__c      = (OEMIAMMap.size() > 0) ? true : false
                                                        ,SourceFailure__c = ''
                                                        ,ReasonFailure__c = ''                
                                                    );

        if(currentAssetMap != null){
            //ASE: 02/03/2017: C-001885
            //newAssessment.Manufacturer__c   = assessCarMap.get(assessId).CarCrossRef__c;
            list<String> assessCarMapList=  assessCarMap.get(assessId).split(';');
            newAssessment.Manufacturer__c   = assessCarMapList[1] != 'null' ? assessCarMapList[1]: assessCarMapList[0];
            newAssessment.ModelV2__c        = String.valueOf(currentAssetMap.get('Model'));
            String PlateNumber = String.valueOf(currentAssetMap.get('PlateNumber'));
            newAssessment.PlateNumber2__c   = (PlateNumber != null) ? removeSpaceHypen(PlateNumber) : PlateNumber ;

            if( currentAssetMap.get('FirstRegistrationDate') != null && 
                !String.isBlank(String.valueOf(currentAssetMap.get('FirstRegistrationDate')))){
                newAssessment.FirstRegistrationDate__c = (Date) JSON.deserialize('"' + currentAssetMap.get('FirstRegistrationDate') + '"', Date.class);
            }

            newAssessment.VINNumber__c      = String.valueOf(currentAssetMap.get('VINNumber'));
            newAssessment.KMS__c            = currentAssetMap.get('KMS') != null ? Integer.valueOf(currentAssetMap.get('KMS')) : null;
            newAssessment.PaintingType__c   = String.valueOf(currentAssetMap.get('PaintingType'));
            newAssessment.Colour__c         = String.valueOf(currentAssetMap.get('Colour'));
            // newAssessment.Energy__c         = String.valueOf(currentAssetMap.get('Energy'));
            newAssessment.PickupDate__c     = (currentAssetMap.get('PickupDate') != null && !String.isBlank(String.valueOf(currentAssetMap.get('PickupDate')))) ? (DateTime) JSON.deserialize('"' + currentAssetMap.get('PickupDate') + '"', DateTime.class) : null;
            newAssessment.VDSCode__c        = String.valueOf(currentAssetMap.get('VDSCode'));
        }

        if(currentClaimMap != null){
            newAssessment.ClaimReference__c             = String.valueOf(currentClaimMap.get('ClaimReference'));
            newAssessment.CompanyName__c                = String.valueOf(currentClaimMap.get('CompanyName'));

            if(currentClaimMap.get('DateOfIncident') != null && !String.isBlank(String.valueOf(currentClaimMap.get('DateOfIncident')))){
                newAssessment.DateOfIncident__c         = (Date) JSON.deserialize('"' + currentClaimMap.get('DateOfIncident') + '"', Date.class);
            }

            newAssessment.RepairsAuthorised__c          = (currentClaimMap.get('RepairsAuthorised') != null) ? Boolean.valueOf(currentClaimMap.get('RepairsAuthorised')) : false;
            newAssessment.SupposedOfFraud__c            = (currentClaimMap.get('Fraud') != null) ? Boolean.valueOf(currentClaimMap.get('Fraud')) : false;
            newAssessment.TotalLoss__c                  = (currentClaimMap.get('TotalLoss') != null) ? Boolean.valueOf(currentClaimMap.get('TotalLoss')) : false;
            newAssessment.Fleet__c                      = (currentClaimMap.get('Fleet') != null) ? Boolean.valueOf(currentClaimMap.get('Fleet')) : false;
            // newAssessment.SpecialRenting__c             = (currentClaimMap.get('Rental') != null) ? Boolean.valueOf(currentClaimMap.get('Rental')) : false;
            newAssessment.SpecialAgreement__c           = (currentClaimMap.get('SpecialAgreement') != null) ? Boolean.valueOf(currentClaimMap.get('SpecialAgreement')) : false;
            newAssessment.QuotationAmtExlVAT__c         = (currentClaimMap.get('QuotationAmountExlVAT') != null) ? Double.valueOf(currentClaimMap.get('QuotationAmountExlVAT')) : null;
            newAssessment.QuotationAmountInclVAT__c     = (currentClaimMap.get('QuotationAmountInclVAT') != null) ? Double.valueOf(currentClaimMap.get('QuotationAmountInclVAT')) : null;
            newAssessment.TotalAmtLabourPainting__c     = (currentClaimMap.get('TotalAmtLabourPainting') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtLabourPainting')) : null;
            newAssessment.TotalAmtLabour__c             = (currentClaimMap.get('TotalAmtLabour') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtLabour')) : null;
            newAssessment.TotalAmtParts__c              = (currentClaimMap.get('TotalAmtParts') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtParts')) : null;
            newAssessment.TotalAmtPainting__c           = (currentClaimMap.get('TotalAmtPainting') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtPainting')) : null;
            newAssessment.TotalAmtExlVAT__c             = (currentClaimMap.get('TotalAmtExlVAT') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtExlVAT')) : null;
            newAssessment.TotalVAT__c                   = (currentClaimMap.get('TotalVAT') != null) ? Double.valueOf(currentClaimMap.get('TotalVAT')) : null;
            newAssessment.TotalAmtInclVAT__c            = (currentClaimMap.get('TotalAmtInclVAT') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtInclVAT')) : null;
            newAssessment.NBHoursLabour__c              = (currentClaimMap.get('NBHoursLabour') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabour')) : null;
            newAssessment.NBHoursLabourLevel1__c        = (currentClaimMap.get('NBHoursLabourLevel1') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourLevel1')) : null;
            newAssessment.NBHoursLabourLevel2__c        = (currentClaimMap.get('NBHoursLabourLevel2') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourLevel2')) : null;
            newAssessment.NBHoursLabourLevel3__c        = (currentClaimMap.get('NBHoursLabourLevel3') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourLevel3')) : null;
            newAssessment.TotalAmtLabourExlPainting__c  = (currentClaimMap.get('TotalAmtLabourExlPainting') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtLabourExlPainting')) : null;
            newAssessment.NBHoursLabourPainting__c      = (currentClaimMap.get('NBHoursLabourPainting') != null) ? Double.valueOf(currentClaimMap.get('NBHoursLabourPainting')) : null;
            newAssessment.TotalAmtPaintingInclLabour__c = (currentClaimMap.get('TotalAmtPaintingInclLabour') != null) ? Double.valueOf(currentClaimMap.get('TotalAmtPaintingInclLabour')) : null;
            // newAssessment.AmtOthers__c                  = (currentClaimMap.get('AmtOthers') != null) ? Double.valueOf(currentClaimMap.get('AmtOthers')) : null;
            newAssessment.ExcessAmount__c               = (currentClaimMap.get('ExcessAmount') != null) ? Double.valueOf(currentClaimMap.get('ExcessAmount')) : null;
        }
        if (assessAccountRefMap.get(assessId) != null){
            newAssessment.BodyShop__c   = assessAccountRefMap.get(assessId).InternalReference__c;
        }
        String refNumber = (newAssessment.BodyShop__c !=null) ? ((bsRefAccountMap.get(newAssessment.BodyShop__c)!= null) ? bsRefAccountMap.get(newAssessment.BodyShop__c).ReferenceNumber__c : null) : null;
        String assessCode = (newAssessment.PlateNumber2__c != null) ? newAssessment.PlateNumber2__c : newAssessment.VINNumber__c; 
        String assessCodeName = (newAssessment.PlateNumber2__c != null) ? newAssessment.PlateNumber2__c.left(5) : newAssessment.VINNumber__c; 

        
        newAssessment.AssessmentNumber__c   = (newAssessment.ClaimReference__c + refNumber + assessCode).toUpperCase();
        //newAssessment.Name =  (newAssessment.ClaimReference__c + assessCodeName).toUpperCase();  
        newAssessment.Name =  (newAssessment.ClaimReference__c != null ? newAssessment.ClaimReference__c : '') + (assessCodeName != null ? assessCodeName : '');
        newAssessment.Name = newAssessment.Name != null ? (newAssessment.Name).toUpperCase(): '';
        
        if(isShoppingList){            
            newAssessment.AssessmentID__c  = assessId;         
        }
        else{
            newAssessment.AssessmentID__c  = assessId; 
            // ASE - 24/01/2018: C-002185
            newAssessment.AssessmentNumber__c   = (assessNum == null || assessNum == '') ? (newAssessment.ClaimReference__c + refNumber + assessCode).toUpperCase() : assessNum ;                
        }
        
        newAssessment.AlreadyQuoted__c = false;//VSU 05/12/17

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - createAssessment ----------------------------------');
        return newAssessment;
    }

    public static void createPartList(String externalId, Boolean shoppingList, List<Object> partList, List<PartList__c> newPartList, Map<String, PartList__c> newPartMap, Map<String, List<String>> newPartDescMap, String recordtype, set<String> existingAssessMapKeySet, Map<String, List<CrossReference__c>> OEMIAMMap, Map<String, List<PartList__c>> shopAssessIdPartsMap, set<String> shoppingListExistAssessKey, Decimal assessCrashCode, Id bodyShopId, String entityCode){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - createPartList ----------------------------------');
        system.debug('## externalId:'+externalId);
        system.debug('## OEMIAMMap :'+OEMIAMMap );   
        //ASE: 02/03/2017: C-001885     
        //String crossRefBrand = assessCarMap.get(externalId).CarCrossRef__c;
        //String crossRefBrand = assessCarMap.get(externalId.split(' - ')[0]).split(';')[2];
        String crossRefBrand = assessCarMap.get(externalId).split(';')[2];
        system.debug('## crossRefBrand:'+crossRefBrand); 
        system.debug('## originalPartsMap:'+originalPartsMap);
        
        //AMI 12/07/17 - duplicate handling
        set <string> setKey = new set <string>();

        // loop in partList and assign assessement__c to ExternalId
        // even parts not existing in Cross reference are created here.
        for(Object part: partList){
            Map<String, Object> partListMap = (Map<String, Object>) part;
            
            String partNumber       = String.valueOf(partListMap.get('PartNumber'));                     
            String partDescription  = String.valueOf(partListMap.get('PartLabel'));
            String partLabel        = partDescription.left(80);
            String alphaScaleMRID   = (partListMap.get('AlphaScaleMRID') != null) ? String.valueOf(partListMap.get('AlphaScaleMRID')) : '';
            Boolean isSelected      = (partListMap.get('IsSelected') != null) ? Boolean.valueOf(partListMap.get('IsSelected')) : false;
            String manufacturer     = String.ValueOf(partListMap.get('Manufacturer'));

            //AMI 19/07/17 : New External Id being sent in ass request
            string newExtId         = String.ValueOf(partListMap.get('ExternalID'));

            //AMI 19/07/17 : New External Id being sent in ass request
            String partExternalId   = '';
            if(string.isNotBlank(newExtId)){
                partExternalId = (externalId + '-' + newExtId).toUpperCase();
            }else{
                partExternalId  = (null + '-' 
                                + partNumber + '-' 
                                + partLabel.replaceAll('\\s+', '') + '-' 
                                + manufacturer + '-' 
                                + externalId + '-' 
                                + null).toUpperCase();
            }
            system.debug('## partNumber       :'+partNumber);   
            system.debug('## partExternalId   : '+partExternalId  );
            Integer quantity    = Integer.ValueOf(partListMap.get('Quantity'));

            PartList__c newPart;

            string crash        = String.ValueOf(partListMap.get('crashCode'));

            // this part is an original
            // map fields for upsert
            if(alphaScaleMRID == ''){

                //AMI 12/07/17 - duplicate handling
                //check dupicates and fill has HasDuplicates__c field
                system.debug('## setKey ' + setKey);
                if(!setKey.contains(partExternalId)){
                    setKey.add(partExternalId);

                    String cleanseOEMKey = cleanseReference(partNumber) + '-' + crossRefBrand;
                    system.debug('## cleanseOEMKey: '+cleanseOEMKey);
                    system.debug('bool:'+existingAssessMapKeySet.contains(externalId));
                    system.debug('bool2:'+ originalPartsMap.isEmpty());
                    system.debug('bool4:' +originalPartsMap.containsKey( externalId + '-' + partExternalId));
                    system.debug('bool3:'+ (OEMIAMMap.isEmpty()) );

                    if((!existingAssessMapKeySet.contains(externalId) || (existingAssessMapKeySet.contains(externalId) && (originalPartsMap.isEmpty() ||(!originalPartsMap.isEmpty() && !originalPartsMap.containsKey( externalId + '-' + partExternalId))) ))&& 
                        (OEMIAMMap.isEmpty() || (!OEMIAMMap.isEmpty() && !OEMIAMMap.containsKey(cleanseOEMKey)))){
                            isSelected = true;
                    }
                    else{
                        isSelected = false;
                    }

                    //AMI 19/07/17 : New External Id being sent in ass request
                    newPart = new PartList__c(Description__c                = partDescription
                                              ,Name                         = partLabel.left(80)
                                              ,PartNumber__c                = partNumber
                                              ,Price__c                     = Double.ValueOf(partListMap.get('Price'))
                                              ,ProducerName__c              = manufacturer
                                              ,Quantity__c                  = quantity
                                              ,RecordTypeId                 = recordTypePartTypeMap.get(String.valueOf(partListMap.get('RecordType')))
                                              ,Type__c                      = 'A'
                                              ,Compliance__c                = (partListMap.get('Compliance') != null) ? Boolean.valueOf(partListMap.get('Compliance')) : false
                                              ,InputType__c                 = String.valueOf(partListMap.get('InputType'))
                                              ,Currency__c                  = String.valueOf(partListMap.get('Currency'))
                                              ,TECH_OriginalPart__c         = partExternalId
                                              ,SelectedByBS__c              = isSelected
                                              ,InterventionCode__c          = String.valueOf(partListMap.get('InterventionCode'))
                                              ,NBHoursLabourPartLevel1__c   = (partListMap.get('NBHoursLabourPartLevel1') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPartLevel1')) : null
                                              ,NBHoursLabourPartLevel2__c   = (partListMap.get('NBHoursLabourPartLevel2') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPartLevel2')) : null
                                              ,NBHoursLabourPartLevel3__c   = (partListMap.get('NBHoursLabourPartLevel3') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPartLevel3')) : null
                                              ,NBHoursLabourPainting__c     = (partListMap.get('NBHoursLabourPainting') != null) ? Double.valueOf(partListMap.get('NBHoursLabourPainting')) : null
                                              ,ARCAUTOCode__c               = String.valueOf(partListMap.get('ARCAUTOCode'))
                                              ,VAT__c                       = (partListMap.get('VATRate') != null) ? Double.ValueOf(partListMap.get('VATRate')) : null
                                              ,CertifyingOrganization__c    = String.ValueOf(partListMap.get('CertifyingOrganization'))
                                              ,isSourced__c                 = false
                                              ,isDeleted__c                 = partsToDelSet.contains(externalId + '-' + partExternalId) ? true : false
                                              ,Stock__c                     = 'Available'                                        
                                              //,crashCode__c                 = (partListMap.get('crashCode') != null && partListMap.get('crashCode') != '') ? Integer.valueOf(partListMap.get('crashCode')) : assessCrashCode
                                              ,ExternalId__c                =  newExtId != null ? newExtId : ''
                                            );
 
                    //AMI 12/07/17 - duplicate handling
                    if(mapOriginalKeyListPL.containsKey(partExternalId)){
                        newPart.HasDuplicates__c = (mapOriginalKeyListPL.get(partExternalId).size > 1) ? true : false;

                        //AMI 13/07/17 - crash code handling
                        newPart.CrashCodes__c = ((string.valueOf(mapOriginalKeyListPL.get(partExternalId).crash).replaceAll('\\{','')).replaceAll('\\}','')).replaceAll(',',';');
                    }

                    newPart.Assessment__r = new Assessment__c(AssessmentID__c = externalId);
                    
                    if(!originalPartsMap.isEmpty() && originalPartsMap.containsKey( externalId + '-' + newPart.TECH_OriginalPart__c)){  
                        newPart.Id = originalPartsMap.get(externalId + '-' + newPart.TECH_OriginalPart__c).Id;
                        newPart.SelectedByBS__c = true;
                        newPart.isDeleted__c  = partsToDelSet.contains(externalId + '-' +newPart.TECH_OriginalPart__c) ? true : false; 

                        if(shoppingList || (!shoppingList && shoppingListExistAssessKey.contains(newPart.Assessment__r.AssessmentId__c))){
                            if(!shopAssessIdPartsMap.containsKey(newPart.Assessment__r.AssessmentId__c)){
                                newPart.SelectedByBS__c = true;
                                shopAssessIdPartsMap.put(newPart.Assessment__r.AssessmentId__c, new list<PartList__c>{newPart});
                            }
                            else{
                                newPart.SelectedByBS__c = true;                                    
                                shopAssessIdPartsMap.get(newPart.Assessment__r.AssessmentId__c).add(newPart);
                            }
                        }              
                    }

                    if(!newPartMap.containskey(newPart.TECH_OriginalPart__c)){
                        newPartMap.put(newPart.TECH_OriginalPart__c, newPart);
                        newPartList.add(newPart);
                    }
                }//end if !setKey.contains(partExternalId)
            }

            // this a substitute. get original part from originalIdPartMap
            else{
                // ASE : 01/03/2017 : split description of substitute
                //string substituteKey = externalId +'-'+ alphaScaleMRID +'-'+ partDescription; 
                string substituteKey = externalId +'-'+ alphaScaleMRID +'-'+ partDescription.split(' - ')[0]; 
                
                //AMI 12/07/17 - duplicate handling
                //check dupicates and fill has HasDuplicates__c field
                if(!setKey.contains(substituteKey)){
                    setKey.add(substituteKey);
                    if(!assessSubOriginalMap.isEmpty() && assessSubOriginalMap.containskey(substituteKey)){
                       if(!originalPartsMap.isEmpty()){ 
                            for(String x: assessSubOriginalMap.get(substituteKey)){
                                if(originalPartsMap.containskey(externalId + '-' + x)){                                 
                                    newPart = originalPartsMap.get(externalId + '-' + x);
                                    newPart.SelectedByBS__c = false;
                                    newPart.Quantity__c = quantity;
                                    newPart.isDeleted__c  = partsToDelSet.contains(externalId + '-' + newPart.TECH_OriginalPart__c) ? true : false;     

                                    //AMI 12/07/17 - duplicate handling
                                    if(mapSubstituteKeyListPL.containsKey(substituteKey)){
                                        if(mapSubstituteKeyListPL.get(substituteKey).size > 1){
                                            //check duplicates on original pl
                                            newPart.HasDuplicates__c = true;

                                            //add to original map to generate response for every substitute
                                            for(integer i=0;i<mapSubstituteKeyListPL.get(substituteKey).size;i++){
                                                //add to original map
                                                if(mapOriginalKeyListPL.containsKey(newPart.TECH_OriginalPart__c)){
                                                    duplicateSizeCrashCodeWrapper temp = mapOriginalKeyListPL.get(newPart.TECH_OriginalPart__c);
                                                    temp.size = temp.size + 1;
                                                    temp.crash = mapSubstituteKeyListPL.get(substituteKey).crash;
                                                    temp.lstCrash.add(mapSubstituteKeyListPL.get(substituteKey).lstCrash[i]);
                                                    mapOriginalKeyListPL.put(newPart.TECH_OriginalPart__c,temp);
                                                }else{
                                                    mapOriginalKeyListPL.put(newPart.TECH_OriginalPart__c,new duplicateSizeCrashCodeWrapper(1,mapSubstituteKeyListPL.get(substituteKey).crash,new list <string>{mapSubstituteKeyListPL.get(substituteKey).lstCrash[i]}));
                                                }
                                            }
                                        }//end if mapSubstituteKeyListPL.get(substituteKey).size > 1
                                        else if(mapSubstituteKeyListPL.get(substituteKey).size == 1){
                                            if(mapOriginalKeyListPL.containsKey(newPart.TECH_OriginalPart__c)){
                                                duplicateSizeCrashCodeWrapper temp = mapOriginalKeyListPL.get(newPart.TECH_OriginalPart__c);
                                                temp.size = temp.size + 1;
                                                temp.crash = mapSubstituteKeyListPL.get(substituteKey).crash;
                                                temp.lstCrash.add(mapSubstituteKeyListPL.get(substituteKey).lstCrash[0]);
                                                mapOriginalKeyListPL.put(newPart.TECH_OriginalPart__c,temp);
                                            }else{
                                                mapOriginalKeyListPL.put(newPart.TECH_OriginalPart__c,new duplicateSizeCrashCodeWrapper(1,mapSubstituteKeyListPL.get(substituteKey).crash,new list <string>{mapSubstituteKeyListPL.get(substituteKey).lstCrash[0]}));
                                            }
                                        }
                                        
                                        //AMI 13/07/17 - crash code handling
                                        newPart.CrashCodes__c = ((string.valueOf(mapOriginalKeyListPL.get(newPart.TECH_OriginalPart__c).crash).replaceAll('\\{','')).replaceAll('\\}','')).replaceAll(',',';');
                                    }

                                    if(!newPartMap.containskey(newPart.TECH_OriginalPart__c)){
                                        newPartMap.put(newPart.TECH_OriginalPart__c, newPart);
                                        newPartList.add(newPart);
                                    } 

                                    PartList__c subsPart = allsubPartsMap.get(substituteKey);

                                    if(shoppingList || (!shoppingList && shoppingListExistAssessKey.contains(subsPart.Assessment__r.AssessmentId__c))){
                                        //AMI 08/09/17 - resolve attempt to dereference null object
                                        //add to original wrapper to build correct response
                                        if(mapSubstituteKeyListPL.containsKey(substituteKey)){
                                            if(mapSubstituteKeyListPL.get(substituteKey).size > 1){
                                                //check duplicates on original pl
                                                subsPart.HasDuplicates__c = true;

                                                //add to original map to generate response for every substitute
                                                for(integer i=0;i<mapSubstituteKeyListPL.get(substituteKey).size;i++){
                                                    //add to original map
                                                    if(mapOriginalKeyListPL.containsKey(subsPart.TECH_OriginalPart__c)){
                                                        duplicateSizeCrashCodeWrapper temp = mapOriginalKeyListPL.get(subsPart.TECH_OriginalPart__c);
                                                        temp.size = temp.size + 1;
                                                        temp.crash = mapSubstituteKeyListPL.get(substituteKey).crash;
                                                        temp.lstCrash.add(mapSubstituteKeyListPL.get(substituteKey).lstCrash[i]);
                                                        mapOriginalKeyListPL.put(subsPart.TECH_OriginalPart__c,temp);
                                                    }else{
                                                        mapOriginalKeyListPL.put(subsPart.TECH_OriginalPart__c,new duplicateSizeCrashCodeWrapper(1,mapSubstituteKeyListPL.get(substituteKey).crash,new list <string>{mapSubstituteKeyListPL.get(substituteKey).lstCrash[i]}));
                                                    }
                                                }
                                            }//end if mapSubstituteKeyListPL.get(substituteKey).size > 1
                                            else if(mapSubstituteKeyListPL.get(substituteKey).size == 1){
                                                if(mapOriginalKeyListPL.containsKey(subsPart.TECH_OriginalPart__c)){
                                                    duplicateSizeCrashCodeWrapper temp = mapOriginalKeyListPL.get(subsPart.TECH_OriginalPart__c);
                                                    temp.size = temp.size + 1;
                                                    temp.crash = mapSubstituteKeyListPL.get(substituteKey).crash;
                                                    temp.lstCrash.add(mapSubstituteKeyListPL.get(substituteKey).lstCrash[0]);
                                                    mapOriginalKeyListPL.put(subsPart.TECH_OriginalPart__c,temp);
                                                }else{
                                                    mapOriginalKeyListPL.put(subsPart.TECH_OriginalPart__c,new duplicateSizeCrashCodeWrapper(1,mapSubstituteKeyListPL.get(substituteKey).crash,new list <string>{mapSubstituteKeyListPL.get(substituteKey).lstCrash[0]}));
                                                }
                                            }
                                            
                                            //AMI 13/07/17 - crash code handling
                                            subsPart.CrashCodes__c = ((string.valueOf(mapOriginalKeyListPL.get(subsPart.TECH_OriginalPart__c).crash).replaceAll('\\{','')).replaceAll('\\}','')).replaceAll(',',';');
                                        }

                                        if(!shopAssessIdPartsMap.containsKey(subsPart.Assessment__r.AssessmentId__c)){
                                            subsPart.SelectedByBS__c = true;
                                            shopAssessIdPartsMap.put(subsPart.Assessment__r.AssessmentId__c, new list<PartList__c>{subsPart});
                                        }
                                        else{
                                            subsPart.SelectedByBS__c = true;                                    
                                            shopAssessIdPartsMap.get(subsPart.Assessment__r.AssessmentId__c).add(subsPart);
                                        }

                                    }                               
                                }
                            }
                        }
                    }
                }//end if !setKey.contains(substituteKey)
            }

            // build map<AssessId-partNUmber-crossRefBrand, list<Part.TECH_OriginalPart__c>> because we may have parts with same partNUmber and different descriptions
            // used in createSubstitutes to clone susbtitutes when working with OEMIAMMap
            if(newPart != null){
                if(!newPartDescMap.containskey(externalId + '-' + newPart.PartNumber__c + '-' + crossRefBrand)){
                    newPartDescMap.put(externalId + '-' + newPart.PartNumber__c + '-' + crossRefBrand, new List<String>{newPart.TECH_OriginalPart__c});
                }
                else{
                    newPartDescMap.get(externalId + '-' + newPart.PartNumber__c + '-' + crossRefBrand).add(newPart.TECH_OriginalPart__c);
                }

                // ASE : 136/11/17 : C-001988 
                //system.debug('## bs type: '+bsRefAccountMap.get(bodyShopId).Type);                
                if(bsRefAccountMap.containsKey(bodyShopId)){
                    String accType = bsRefAccountMap.get(bodyShopId).Type;
                    if(accType == 'Expert'){                        
                        if(!expertOriginalPartsMap.containsKey(entityCode)){
                            expertOriginalPartsMap.put(entityCode, new set<String>{newPart.TECH_OriginalPart__c});
                        }
                        else{
                            expertOriginalPartsMap.get(entityCode).add(newPart.TECH_OriginalPart__c);
                        }                        
                    }
                }
            }         
        }

        system.debug('## shopAssessIdPartsMap:'+shopAssessIdPartsMap);
        system.debug('## newPartList:'+ newPartList);
        system.debug('## newPartMap:'+ newPartMap);
        system.debug('## mapOriginalKeyListPL : '+ mapOriginalKeyListPL);
        system.debug('## expertOriginalPartsMap: '+ expertOriginalPartsMap);

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - createPartList ----------------------------------');
    }

    public static List<PartList__c> createSubstitute(String externalId, Map<String, List<CrossReference__c>> OEMIAMMap, Map<String, CrossReference__c> OEMIAMPriceMap, List<DetailRule__c> listFieldUpdatesDetailRules,  Map<String, PartList__c> newPartMap, Map<String, List<String>> newPartDescMap, String entityRule){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - createSubstitute ----------------------------------');

        system.debug('## assessSubstituteMap: '+assessSubstituteMap);  
        system.debug('## OEMIAMMap:'+OEMIAMMap);

        //DUN 11/08/2016
        List<PartList__c> newPartListToUpdateField = new List<PartList__c>();

        // variables
        List<PartList__c> newPartList   = new List<PartList__c>();

        //ASE: 02/03/2017: C-001885  //String crossRefBrand = assessCarMap.get(externalId).CarCrossRef__c;
        //String crossRefBrand = assessCarMap.get(externalId.split(' - ')[0]).split(';')[2];
        String crossRefBrand = assessCarMap.get(externalId).split(';')[2];
        system.debug('## crossRefBrand:'+crossRefBrand); 

        set<String> categoriesSet = assessBSCategoriesMap.get(externalId);  
        system.debug('## categoriesSet:'+categoriesSet);      

        // loop in newPartMap
        for(String newPartKey : newPartMap.keyset()){
            PartList__c pl = newPartMap.get(newPartKey);
            
            String cleanseOEMKey  = cleanseReference(pl.PartNumber__c) + '-' + crossRefBrand;
            String OEMKey         = pl.PartNumber__c + '-' + crossRefBrand;   
            system.debug('## OEMKey ' + OEMKey);
            system.debug('## externalId ' + externalId);

            String originalNonCleansePartNumber = pl.PartNumber__c;

            //AMI 13/07/17 - duplicate handling - check hasDuplicate on substitute
            boolean hasDuplicate  = (mapOriginalKeyListPL.containsKey(pl.TECH_OriginalPart__c) && mapOriginalKeyListPL.get(pl.TECH_OriginalPart__c).size > 1) ? true : false;

            //AMI 13/07/17 - crash code handling
            string crashSet       = ((string.valueOf(mapOriginalKeyListPL.get(pl.TECH_OriginalPart__c).crash).replaceAll('\\{','')).replaceAll('\\}','')).replaceAll(',',';');

            //AMI 19/07/17 : New External Id being sent in ass request
            string newExtId       = pl.ExternalId__c;

            // if OEMIAMMap contains parts, isSelected of substitutes is based on masterRule
            if(OEMIAMMap != null && OEMIAMMap.containsKey(cleanseOEMKey)){
                for(CrossReference__c CR : OEMIAMMap.get(cleanseOEMKey)){

                    //AMI 20/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                    if(CR.OEMStandardDiscount__c != null || CR.OEMStandardMargin__c != null){
                        mapPartNumCrossRef.put(CR.OEMCleanPartNumber__c,CR);
                    }

                    system.debug('### CR.Distributors__r :'+CR.Distributors__r );

                    
                    String substituteDescription = pl.Description__c + ' - ' + CR.IAMManufacturer__c + ' (' + CR.IAMPartNumber__c + ')';
                    // ASE : 13/12/16 : use original Name - manufacturer (IAM part Number) for substitute description
                    substituteDescription = (CR.IAMCertifyingOrganization__c != null) ? substituteDescription + ' - '+ CR.IAMCertifyingOrganization__c : substituteDescription; 
                    PartList__c newPart = new PartList__c(//Description__c            = CR.IAMPartDescription__c
                                                      //,Name                         = (CR.IAMPartDescription__c == null) ? CR.IAMPartNumber__c : CR.IAMPartDescription__c.left(80)
                                                       Description__c               = substituteDescription
                                                      ,Name                         = substituteDescription.left(80)                                                      
                                                      //,PartNumber__c                = CR.IAMPartNumber__c
                                                      ,PartNumber__c                = CR.Name
                                                      ,Price__c                     = (CR.ASPublicPrice__c == null) ? ((CR.IAMPublicPrice__c == null) ? 0 : CR.IAMPublicPrice__c) : CR.ASPublicPrice__c
                                                      ,ProducerName__c              = CR.IAMManufacturer__c
                                                      ,Type__c                      = CR.IAMPartClass__c
                                                      ,Assessment__r                = new Assessment__c(AssessmentID__c = externalId)
                                                      ,OriginalPart__r              = new PartList__c(TECH_OriginalPart__c = OEMKey + '-' + externalId)
                                                      ,Alpha_Scale_MRID__c          = CR.Name
                                                      ,CrossReferenceId__c          = CR.Id
                                                      ,CertifyingOrganization__c    = CR.IAMCertifyingOrganization__c
                                                      ,isSourced__c                 = false                                                          
                                                      ,Stock__c                     = 'Available'
                                                      ,HasDuplicates__c             = hasDuplicate
                                                      ,CrashCodes__c                = (crashSet != null) ? crashSet : null
                                                      // ASE: 22/02/18
                                                      ,DistributorPriceId__c       = (CR.Distributors__r != null && CR.Distributors__r.size() > 0) ? CR.Distributors__r[0].Id : null
                                                     );
                    system.debug('## newPart ' + newPart);
                    Decimal StandardMargin;
                    Decimal StandardDiscount;

                    system.debug('## CR.ASPublicPrice__c:'+CR.ASPublicPrice__c);
                    system.debug('## CR.ASNetPrice__c:'+CR.ASNetPrice__c);

                    if(CR.ASPublicPrice__c == null && CR.ASNetPrice__c == null){
                        StandardMargin = null;
                        StandardDiscount = null;
                    }
                    else if((CR.ASPublicPrice__c == null || CR.ASPublicPrice__c == 0) && CR.ASNetPrice__c != null){
                        StandardMargin = 0;
                        StandardDiscount = 0;
                    }
                    else{
                        CR.ASNetPrice__c = (CR.ASNetPrice__c != null) ? CR.ASNetPrice__c : CR.ASPublicPrice__c;
                        StandardMargin = CR.ASPublicPrice__c - CR.ASNetPrice__c ;
                        StandardDiscount = ((1 - (CR.ASNetPrice__c / CR.ASPublicPrice__c))*100);
                    }

                    newPart.StandardMargin__c = StandardMargin;
                    newPart.StandardDiscount__c = StandardDiscount;

                    crashSubCrashOriginalMap.put(newPart.TECH_OriginalPart__c, externalId + '-' + OEMKey);

                    // used to build substitutes for all parts having the same partNumber
                    system.debug('## newPartDescMap ' + newPartDescMap);
                    system.debug('## externalIdOEMKey ' + externalId + '-' + OEMKey);
                    if(newPartDescMap.containsKey(externalId + '-' + OEMKey)){
                        for(String partKey: newPartDescMap.get(externalId + '-' + OEMKey)){
                            // 07/12/16: bug when using containsKey
                            //if(newPartMap.containsKey(partKey)){
                            if(newPartKey == partKey){
                                PartList__c newSubstitute = newPart.clone(false, true);

                                //AMI 19/07/17 : New External Id being sent in ass request
                                if(string.isNotBlank(newExtId)){
                                    newSubstitute.TECH_OriginalPart__c  = externalId + '-' + newExtId + '-' + newSubstitute.PartNumber__c;
                                }else{
                                    newSubstitute.TECH_OriginalPart__c  = originalNonCleansePartNumber + '-'
                                                                    + newSubstitute.PartNumber__c + '-'
                                                                    + newSubstitute.Name.replaceAll('\\s+', '') + '-'
                                                                    + newSubstitute.ProducerName__c + '-'
                                                                    + externalId;
                                }

                                newSubstitute.OriginalPart__r       = new PartList__c(TECH_OriginalPart__c = partKey);
                                newSubstitute.Quantity__c           = newPartMap.get(partKey).Quantity__c;
                                newSubstitute.RecordTypeId          = newPartMap.get(partKey).RecordTypeId;
                                newSubstitute.InputType__c          = newPartMap.get(partKey).InputType__c;
                                newSubstitute.Currency__c           = newPartMap.get(partKey).Currency__c;
                                newSubstitute.isDeleted__c          = partsToDelSet.contains(partKey) ? true : false;                                                   

                                //DUN 12/09/2016 MasterRule Updated
                                if(OEMIAMPriceMap != null && OEMIAMPriceMap.containskey(cleanseOEMKey) && OEMIAMPriceMap.get(cleanseOEMKey).Id == cr.Id){
                                    if(mapEntitysetPartListTechId.containsKey(entityRule)){
                                        mapEntitysetPartListTechId.get(entityRule).add(newSubstitute.TECH_OriginalPart__c);
                                    }
                                    else{
                                        mapEntitysetPartListTechId.put(entityRule, new set<String>{newSubstitute.TECH_OriginalPart__c});
                                    }
                                }
                                newPartList.add(newSubstitute);   
                                crashSubCrashOriginalMap.put(newSubstitute.TECH_OriginalPart__c, partKey);                        
                            }
                        }
                    }                
                }
            }
            else{
                // else if originalSubstituteListMap contains parts, the parts are already existing in partList
                if(!originalSubstitutesMap.isEmpty()){
                   
                    if(originalSubstitutesMap.containsKey(externalId + '-' + pl.TECH_OriginalPart__c)){   
                    for(PartList__c existingSubstitute: originalSubstitutesMap.get(externalId + '-' + pl.TECH_OriginalPart__c)){
                            
                            PartList__c updatedSubstitute = existingSubstitute.clone(false, true);
                            updatedSubstitute.Quantity__c = pl.Quantity__c;

                            //AMI 13/07/17 - duplicate handling - check hasDuplicate on substitute
                            updatedSubstitute.HasDuplicates__c = hasDuplicate;

                            //AMI 13/07/17 - crash code handling
                            updatedSubstitute.CrashCodes__c = (crashSet != null) ? crashSet : null;
                                              
                            // the original is sent in the response
                            if(pl.SelectedByBS__c){
                                updatedSubstitute.SelectedByBS__c = false;
                                updatedSubstitute.isDeleted__c = partsToDelSet.contains(externalId + '-' + pl.TECH_OriginalPart__c) ? true : false;
                            }

                            else{
                                // ASE : 13/12/16 : adding description to key to differentiate b/w substitutes
                                //String substituteKey = externalId + '-' + existingSubstitute.Alpha_Scale_MRID__c+ '-' + existingSubstitute.Description__c;                              
                                // ASE : 01/03/2017 : split description of substitute   
                                String substituteKey = externalId + '-' + existingSubstitute.Alpha_Scale_MRID__c+ '-' + existingSubstitute.Description__c.split(' - ')[0];  
                                if(assessSubstituteMap.containskey(substituteKey)){
                                    Map<String, Object> subsMap = (Map<String, Object>) assessSubstituteMap.get(substituteKey);                                  
                                    updatedSubstitute.SelectedByBS__c = true;
                                    updatedSubstitute.isDeleted__c = partsToDelSet.contains(substituteKey) ? true : false;
                                }
                                else{
                                    updatedSubstitute.SelectedByBS__c = false;
                                    updatedSubstitute.isDeleted__c = partsToDelSet.contains(substituteKey) ? true : false;
                                }
                            }
                                                       
                            newPartList.add(updatedSubstitute);

                            if(!asessPartSubMap.containsKey(externalId + '-' + pl.TECH_OriginalPart__c)){
                                asessPartSubMap.put(externalId + '-' + pl.TECH_OriginalPart__c, new List<PartList__c>{updatedSubstitute});
                            }
                            else{
                                asessPartSubMap.get(externalId + '-' + pl.TECH_OriginalPart__c).add(updatedSubstitute);
                            }
                            ASCRPartNumbMap.put(updatedSubstitute.Alpha_Scale_MRID__c, updatedSubstitute.CrossReferenceId__r.IAMPartNumber__c);
                        }           
                    }
                }
            }
        }
        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - createSubstitute ----------------------------------');

        return newPartList;
    } 

     // ABT - 26-AUG-2016 - C-001710
    public static String cleanseReference(String referenceToCleanse){
        return referenceToCleanse.replaceAll('[^A-Za-z0-9]', '').replaceFirst('^0+(?!$)', '').toUpperCase();
    } 

    public static Map<String, Id> insertAll(Map<String, Assessment__c> claimAssessmentMap, List<Assessment__c> newAssessmentList, Map<Id, AccountRef__c> accountRefToUpdate, Map<String, List<PartList__c>> assessIdPartsMap, Map<String, Assessment__c> assessMap, Map<String, List<PartList__c>> assessSubstituteListMap, Map<String, Id> claimAssessSFDCMap){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - insertAll ----------------------------------');
        
        Set<String> assessmentErrorSet  = new Set<String>();
        //map<Assessment__c.AssessmentId, Assessment__c.Id>
        //Map<String, Id> assessSFDCIDMap = new Map<String, Id>();
        list<Assessment__c> claimAssessmentList = new list<Assessment__c>();
        for(String claimKey :  claimAssessmentMap.keyset()){
            claimAssessmentList.add(claimAssessmentMap.get(claimKey));
        }
        
        if(!newAssessmentList.isEmpty()){
           // validate assessmnet before inserting, to check if all fields are filled
            //Map<String, String> mapValidationErrors = validationAssessment(newAssessmentList);

            //setCrossReferencesFieldForAssessment(assessMap, claimAssessmentMap, assessSubstituteListMap);
        
            Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;

            //upserting claim assessment for crash child assessment
            //upsert claimAssessmentList AssessmentID__c;
            

            List<Database.upsertResult> claimResults = Database.upsert(claimAssessmentList, assessExtId, false);
            for(Integer idx = 0; idx < claimResults.size(); idx++) {
                if(claimResults[idx].isSuccess()) {
                    // if success populate the Set of id that has been successful
                    claimAssessSFDCMap.put(claimAssessmentList[idx].AssessmentId__c, claimResults[idx].getId());                    
                }
            }

            //upsert assessments
            List<Database.upsertResult> uResults = Database.upsert(newAssessmentList, assessExtId, false);
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(uResults[idx].isSuccess()) {
                    // if success populate the Set of id that has been successful
                    assessSFDCIDMap.put(newAssessmentList[idx].AssessmentId__c, uResults[idx].getId() );
                    //system.debug('## uResults[idx]:'+uResults[idx]);            
                }
                else {
                    //generate the json that will be used for errors as reponse
                    for(Database.Error err : uResults[idx].getErrors()){

                        mapErrorsCreation.put(newAssessmentList[idx].AssessmentId__c, Label.Error + ': ' + err.getMessage());
                        assessmentErrorSet.add(newAssessmentList[idx].AssessmentId__c);                        
                    }
                    // do not insert partlist, subtitutes related to assessment
                    assessIdPartsMap.remove(newAssessmentList[idx].AssessmentId__c);
                    assessSubstituteListMap.remove(newAssessmentList[idx].AssessmentId__c);
                }
            }
        }

        // update account Ref
        if(!accountRefToUpdate.isEmpty()){
            update accountRefToUpdate.values();
        }
        
        if(!assessIdPartsMap.isEmpty()){
            List<PartList__c> plList =  new List<PartList__c>();
            List<PartList__c> delPlList =  new List<PartList__c>();

            for(String key: assessIdPartsMap.keyset()){
                plList.addAll(assessIdPartsMap.get(key));
            }
            system.debug('## plList ' + plList);
                        
            system.debug('## claimcrashOriginalSubstitutesMap:' + claimcrashOriginalSubstitutesMap);
            system.debug('## partsToDelSet:'+partsToDelSet);
            for(String techPart : partsToDelSet){
                system.debug('## techPart:'+techPart);
                if(claimcrashOriginalSubstitutesMap.containskey(techPart)){
                    PartList__c pl = claimcrashOriginalSubstitutesMap.get(techPart);
                    String crashCode = String.ValueOf(pl.Assessment__r.crashCode__c);
                    crashCode = (crashCode != null && crashCode.trim().length() == 1) ? ('0' + crashCode) : crashCode;        
                    String claimExtId = pl.Assessment__r.ParentAssessment__r.AssessmentId__c ;
                    if(pl.Alpha_Scale_MRID__c == null || pl.Alpha_Scale_MRID__c == ''){
                        String partExternalId   = (null + '-'  + pl.PartNumber__c + '-' + pl.Description__c.replaceAll('\\s+', '') + '-' 
                                                 + pl.ProducerName__c  + '-' + pl.Assessment__r.ParentAssessment__r.AssessmentId__c + '(' + crashCode + ')' + '-' + null).toUpperCase();
                        partsToDelSet.add(partExternalId);
                        String key = pl.Assessment__r.ParentAssessment__r.AssessmentId__c + partExternalId;
                        if(originalSubstitutesMap.get(key) != null){
                            for(PartList__c substitute : OriginalSubstitutesMap.get(key)){
                                partsToDelSet.add(substitute.TECH_OriginalPart__c);
                            }
                        }
                    }
                    else{
                        String partExternalId   = (pl.TECH_OriginalPart__c.split('-')[0] + '-'
                                                    + pl.PartNumber__c + '-'
                                                    + pl.Name.replaceAll('\\s+', '') + '-'
                                                    + pl.ProducerName__c + '-'
                                                    +  pl.Assessment__r.ParentAssessment__r.AssessmentId__c + '(' + crashCode + ')').toUpperCase();//+ '-'
                                                    //+ pl.Alpha_Scale_MRID__c;

                        String subKey =  pl.Assessment__r.ParentAssessment__r.AssessmentId__c +'-'+ pl.Alpha_Scale_MRID__c +'-'+ pl.Description__c.split(' - ')[0];
                        
                        partsToDelSet.add(partExternalId);
                        if(AssessSubOriginalMap.get(subKey) != null){
                            for(String original : AssessSubOriginalMap.get(subKey)){
                                partsToDelSet.add(original);
                            }                                                                                  
                        }
                    }               
                }
            }
            system.debug('## partsToDelSet:'+partsToDelSet);

            for(String techPart : partsToDelSet){
                delPlList.add(new PartList__c(TECH_OriginalPart__c = techPart, isDeleted__c = true));
            }
            system.debug('## delPlList:'+delPlList);
            
            system.debug(delPlList);
            if(delPlList.size() > 0){
                plList.addAll(delPlList);
            }

            system.debug('##plList1.size():'+ plList);

            //AMI 20/07/17 - C-001934 : Upsert Evolution to add margins on original parts
            for(PartList__c pl : plList){
                if(pl.PartNumber__c != null){
                    if(mapPartNumCrossRef.containsKey(cleanseReference(pl.PartNumber__c))){
                        pl.StandardDiscount__c = mapPartNumCrossRef.get(cleanseReference(pl.PartNumber__c)).OEMStandardDiscount__c;
                        pl.StandardMargin__c = mapPartNumCrossRef.get(cleanseReference(pl.PartNumber__c)).OEMStandardMargin__c;
                    }else{
                        //ASE : 08/11/17 : case C-002070
                        String plKey = pl.Assessment__r.AssessmentId__c + '-' + (pl.TECH_OriginalPart__c).toUpperCase();
                        if(originalPartsMap.containsKey(plKey)){
                            PartList__c existingPL = originalPartsMap.get(plKey);
                            system.debug('##existingPL:' +existingPL.StandardDiscount__c +'-' +existingPL.StandardMargin__c);
                            pl.StandardDiscount__c = existingPL.StandardDiscount__c;
                            pl.StandardMargin__c = existingPL.StandardMargin__c;
                        }
                        else{
                            pl.StandardDiscount__c = 0.0;
                            pl.StandardMargin__c = 0.0;
                        }
                    }
                }
            }
            system.debug('##plList2:'+plList);

            for(PartList__c pl : plList){
                system.debug('##xxx : '+pl);
            }
            system.debug('##plList.size():'+plList.size());
            
            upsert plList TECH_OriginalPart__c;

            List<PartList__c> plaList =  new List<PartList__c>();

            for(String key: assessSubstituteListMap.keyset()){
                plaList.addAll(assessSubstituteListMap.get(key));
            }
            
            system.debug('##plaList:'+plaList);
            upsert plaList TECH_OriginalPart__c;

        }

        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - insertAll ----------------------------------');
        return assessSFDCIDMap;
    }   
   

    public static String generateResponse(Map<String, Assessment__c> assessMap, Map<String, List<PartList__c>> assessIdPartsMap, Map<String, List<CrossReference__c>> OEMIAMMap, Map<String, CrossReference__c> OEMIAMPriceMap, set<String> setTechId, map<String, Assessment__c> claimAssessmentMap, Map<String, Id> claimAssessSFDCMap, Map<String, list<Object>> shoppingListExistAssessMap, Map<String, List<PartList__c>> shopAssessIdPartsMap, Boolean isNevada){
        System.debug('---------------------------------- START RESTUpsertAssessmentV1 - generateResponse ----------------------------------');
        String response = '';
        
        // JSONGenerator;
        JSONGenerator genResults = JSON.createGenerator(false);
        // start array of Assessment
        if(isNevada){
            genResults.writeStartObject();
                genResults.writeFieldName('Assessments');
        }
        genResults.writeStartArray();
            if(assessSFDCIDMap != null){
                for(String assessExtId : assessSFDCIDMap.keySet()){
                    if(assessMap.containsKey(assessExtId)){
                        String assessId = assessMap.get(assessExtId).Id; 
                        String assessmentId;
                        String carBrandRes = assessCarMap.get(assessExtId).split(';')[0];
                        String carManBrand = assessCarMap.get(assessExtId).split(';')[2];

                        // start Object Assessment
                        genResults.writeStartObject();
                            if(isNevada){//VSU 24/07/17
                                if(assessMap.get(assessExtId).callerSystem__c != null){
                                    //genResults.writeStringField('callerSystem', assessMap.get(assessExtId).callerSystem__c);
                                    if(assessMap.get(assessExtId).callerSystem__c.contains('DIVA')){
                                        genResults.writeStringField('callerSystem','Lacour' );
                                    }
                                    else if(assessMap.get(assessExtId).callerSystem__c.contains('SIDEXA')){
                                        genResults.writeStringField('callerSystem','Sidexa');
                                    }else{
                                        genResults.writeStringField('callerSystem','FR_ICE');
                                    }
                                }                                
                            }

                            if(assessMap.get(assessExtId).AssessmentNumber__c != null && !assessMap.get(assessExtId).isShoppingList__c){
                                genResults.writeStringField('AssessmentNumber',  assessMap.get(assessExtId).AssessmentNumber__c);
                            } else {
                                genResults.writeStringField('AssessmentNumber',  '');
                            }
                            
                            if(assessMap.get(assessExtId).crashCode__c != null && !(assessMap.get(assessExtId).callerSystem__c).toUpperCase().contains('DIVA')){
                                genResults.writeNumberField('crashCode', assessMap.get(assessExtId).crashCode__c);
                            }

                            if(assessMap.get(assessExtId).Entity__c != null){
                                genResults.writeStringField('Entity', assessMap.get(assessExtId).Entity__c);
                            }
                            genResults.writeStringField('EntityCode', assessMap.get(assessExtId).EntityCode__c);
                            
                            if(assessMap.get(assessExtId).MissionNumber__c != null){
                                genResults.writeStringField('MissionNumber', assessMap.get(assessExtId).MissionNumber__c);
                            }
                            
                            String assessName;

                            if(assessMap.get(assessExtId).isShoppingList__c){
                                if(assessMap.get(assessExtId).Name != null){
                                    assessName = assessMap.get(assessExtId).Name;
                                }
                                else{
                                    assessName = assessMap.get(assessExtId).AssessmentNumber__c;
                                }
                            }
                            else{
                                assessName = assessMap.get(assessExtId).Name;
                            }
                            genResults.writeStringField('Name', assessName);
                            
                            if(assessMap.get(assessExtId).VINCheck__c != null){
                                genResults.writeNumberField('VINCheck', assessMap.get(assessExtId).VINCheck__c);
                            }
                            
                            if(assessMap.get(assessExtId).crashCode__c != null){
                                // get assessmentId of claim assessment
                                if(claimAssessSFDCMap.containskey(crashClaimIdMap.get(assessExtId))){
                                    assessmentId = claimAssessSFDCMap.get(crashClaimIdMap.get(assessExtId));
                                }
                                else{
                                    assessmentId = assessId;
                                }                                
                            }
                            else{                                                               
                                assessmentId = assessId;
                            }                          

                            Blob data = Blob.valueOf(assessmentId);
                            String encryptedAssessId = EncodingUtil.base64Encode(data);
                            String siteURL = system.label.SiteOrder+'?AssessmentId=' + encryptedAssessId;
                            // ASE : 27/02/ 2018: case 2186
                            siteURL = system.label.bypass.contains(assessMap.get(assessExtId).callerSystem__c.left(2)) ? (siteURL + '&Order=1') : siteURL;
                            System.debug(' ## siteURL:' +siteURL);

                            if(!isNevada){
                                genResults.writeStringField('URL', siteURL);
                            }

                            // start write Parts
                            genResults.writeFieldName('Parts');  

                            // start array of Parts
                            genResults.writeStartArray();
                                if(assessIdPartsMap.containskey(assessExtId) && !shoppingListExistAssessMap.containsKey(assessExtId)){
                                    system.debug('## enter noShopping');
                                    //if(assessIdPartsMap.containskey(assessExtId)){
                        
                                    for(PartList__c partList: assessIdPartsMap.get(assessExtId)){
                                        //AMI 12/07/17 - duplicate handling
                                        integer sizeLoop = (mapOriginalKeyListPL.containsKey(partList.TECH_OriginalPart__c)) ? mapOriginalKeyListPL.get(partList.TECH_OriginalPart__c).size : 1;
                                        list <string> tempPartList = mapOriginalKeyListPL.get(partList.TECH_OriginalPart__c).lstCrash;
                                        integer loopSize = 1;

                                        if(tempPartList.size() == sizeLoop){
                                            loopSize = sizeLoop;
                                        }

                                        for(integer i = 0;i < loopSize; i++){
                                            // start Object Part
                                            if(!partList.isDeleted__c){
                                                // ASE : 13/04/17: sent manual parts as well, as per CCH
                                                //if ( (String.valueOf(partList.InputType__c)).toUpperCase() != 'MANUAL'){
                                                    genResults.writeStartObject();
                                                        genResults.writeStringField('PartLabel', partList.Description__c);
                                                        //genResults.writeStringField('Name', partList.Name);
                                                        genResults.writeStringField('PartNumber', partList.PartNumber__c);
                                                        genResults.writeNumberField('Price', partList.Price__c);

                                                        if(partList.ProducerName__c != null){
                                                            genResults.writeStringField('Manufacturer', partList.ProducerName__c);
                                                        }
                                                        
                                                        genResults.writeNumberField('Quantity', partList.Quantity__c);

                                                        if(partList.InputType__c != null){
                                                            genResults.writeStringField('InputType', partList.InputType__c);
                                                        }

                                                        if(isNevada){
                                                            if(partList.InterventionCode__c != null){
                                                                genResults.writeStringField('InterventionCode', partList.InterventionCode__c);
                                                            }
                                                        
                                                            if(partList.NBHoursLabourPartLevel1__c != null){
                                                                genResults.writeNumberField('NBHoursLabourPartLevel1', partList.NBHoursLabourPartLevel1__c);
                                                            }
                                                        
                                                            if(partList.NBHoursLabourPartLevel2__c != null){
                                                                genResults.writeNumberField('NBHoursLabourPartLevel2', partList.NBHoursLabourPartLevel2__c);
                                                            }
                                                        
                                                            if(partList.NBHoursLabourPartLevel3__c != null){
                                                                genResults.writeNumberField('NBHoursLabourPartLevel3', partList.NBHoursLabourPartLevel3__c);
                                                            }
                                                        
                                                            if(partList.NBHoursLabourPainting__c != null){
                                                                genResults.writeNumberField('NBHoursLabourPainting', partList.NBHoursLabourPainting__c);
                                                            }

                                                            if(partList.ARCAUTOCode__c != null){
                                                                genResults.writeStringField('ARCAUTOCode',partList.ARCAUTOCode__c);
                                                            }

                                                            if(partList.Compliance__c != null){
                                                                genResults.writeBooleanField('RecordType',partList.Compliance__c);
                                                            }

                                                            if(partList.RecordTypeId != null){
                                                                genResults.writeStringField('RecordType',partList.RecordTypeId);
                                                            }

                                                        }
                                                        
                                                        if(partList.Currency__c != null){
                                                            genResults.writeStringField('Currency', partList.Currency__c);
                                                        }                                                

                                                        if(partList.Type__c != null){
                                                            genResults.writeStringField('Type', partList.Type__c);
                                                        }

                                                        genResults.writeBooleanField('IsSelected', partList.SelectedByBS__c);

                                                        /*if(assessMap.get(assessExtId).crashCode__c != null && !(assessMap.get(assessExtId).callerSystem__c).contains('DIVA')){
                                                            genResults.writeNumberField('crashCode', assessMap.get(assessExtId).crashCode__c);
                                                        }*/

                                                        //AMI 17/07/17 - Crash code handling (C-001969)
                                                        if(tempPartList[i] != null){
                                                            genResults.writeNumberField('crashCode', integer.valueOf(tempPartList[i]));
                                                        }

                                                        //AMI 19/07/17 : New External Id being sent in ass request
                                                        if(partList.ExternalId__c != null){
                                                            genResults.writeStringField('ExternalID', partList.ExternalId__c);
                                                        }

                                                        //AMI 24/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                                                        if(partList.StandardDiscount__c != null){
                                                            genResults.writeNumberField('OEMStandardDiscount', partList.StandardDiscount__c);
                                                        }

                                                        //AMI 24/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                                                        if(partList.StandardMargin__c != null){
                                                            genResults.writeNumberField('OEMStandardMargin', partList.StandardMargin__c);
                                                        }

                                                        //AMI 24/07/17 - C-001934 : Upsert Evolution to add margins on original parts
                                                        genResults.writeStringField('OEMStock', 'Available');

                                                         // start write Substitutions
                                                        genResults.writeFieldName('Substitutions');
                                                        // start array of Substitution
                                                        genResults.writeStartArray();

                                                        String partKey =  partList.PartNumber__c + '-' + carManBrand;
                                                        String cleansePartKey =  cleanseReference(partList.PartNumber__c) + '-' + carManBrand;
                                                        
                                                        if(OEMIAMMap != null && OEMIAMMap.containskey(cleansePartKey)){
                                                            for(CrossReference__c cr: OEMIAMMap.get(cleansePartKey)){
                                                                // ASE : 13/12/16 : use original Name - manufacturer (IAM part Number) for substitute description
                                                                String substituteDescription = partList.Description__c + ' - ' + CR.IAMManufacturer__c + ' (' + CR.IAMPartNumber__c + ')';
                                                                substituteDescription = (CR.IAMCertifyingOrganization__c != null) ? substituteDescription + ' - '+CR.IAMCertifyingOrganization__c : substituteDescription; 
                                                                
                                                                String subName                      = substituteDescription.left(80);

                                                                //AMI 19/07/17 : New External Id being sent in ass request
                                                                String substituteTECH_OriginalPart  = '';
                                                                if(string.isNotBlank(partList.ExternalId__c)){
                                                                    substituteTECH_OriginalPart  =assessExtId + '-' + partList.ExternalId__c + '-' + cr.Name;
                                                                }else{
                                                                    substituteTECH_OriginalPart  = partList.PartNumber__c + '-'
                                                                                                + cr.Name + '-'
                                                                                                + subName.replaceAll('\\s+', '') + '-'
                                                                                                + cr.IAMManufacturer__c + '-'                                                                                                
                                                                                                + assessExtId ;
                                                                }

                                                                if(!isNevada || (isNevada && (setTechId != null && setTechId.contains(substituteTECH_OriginalPart)))){
                                                                    // start Object Substitution
                                                                    genResults.writeStartObject();
                                                                        //ASE :24/08/2017 - C-002016
                                                                        //if(cr.IAMPartDescription__c != null){
                                                                            genResults.writeStringField('PartLabel', substituteDescription);
                                                                        //}

                                                                        genResults.writeStringField('PartNumber', cr.IAMPartNumber__c);
                                                                        
                                                                        Double subsPrice = (CR.ASPublicPrice__c == null) ? ((CR.IAMPublicPrice__c == null) ? 0 : CR.IAMPublicPrice__c) : CR.ASPublicPrice__c;
                                                                        genResults.writeNumberField('Price',subsPrice);
                                                                        
                                                                        
                                                                        if(cr.IAMManufacturer__c != null){
                                                                            genResults.writeStringField('Manufacturer', cr.IAMManufacturer__c);
                                                                        }                                                            

                                                                        genResults.writeNumberField('Quantity', partList.Quantity__c);

                                                                        if(cr.IAMPartClass__c != null){
                                                                            genResults.writeStringField('Type', cr.IAMPartClass__c);
                                                                        }

                                                                        genResults.writeStringField('AlphaScaleMRID', cr.Name);
                                                                        
                                                                        if(partList.InputType__c != null){
                                                                            genResults.writeStringField('InputType', partList.InputType__c);
                                                                        }
                                                                    
                                                                        if(partList.Currency__c != null){
                                                                            genResults.writeStringField('Currency', partList.Currency__c);
                                                                        }
                                                                        
                                                                        if (cr.IAMCertifyingOrganization__c != null){
                                                                            genResults.writeStringField('CertifyingOrganization', cr.IAMCertifyingOrganization__c);
                                                                        }
                                                                        // ASE : 13/12/16 : use original Name - manufacturer (IAM part Number) for substitute description
                                                                        // ABT - Found it is above now (while merging)
                                                                        // String subName                      = substituteDescription.left(80);
                                                                        // String substituteTECH_OriginalPart  = partList.PartNumber__c + '-'
                                                                        //                                     + cr.Name + '-'
                                                                        //                                     + subName.replaceAll('\\s+', '') + '-'
                                                                        //                                     + cr.IAMManufacturer__c + '-'                                                                                                
                                                                        //                                     + assessExtId ;/*+ '-'
                                                                        //                                     +  cr.Name;*/

                                                                        Decimal StandardMargin;
                                                                        Decimal StandardDiscount;

                                                                        if(CR.ASPublicPrice__c == null && CR.ASNetPrice__c == null){
                                                                            StandardMargin = null;
                                                                            StandardDiscount = null;
                                                                        }
                                                                        else if((CR.ASPublicPrice__c == null || CR.ASPublicPrice__c == 0) && CR.ASNetPrice__c != null){
                                                                            StandardMargin = 0;
                                                                            StandardDiscount = 0;
                                                                        }
                                                                        else{
                                                                            CR.ASNetPrice__c = (CR.ASNetPrice__c != null) ? CR.ASNetPrice__c : CR.ASPublicPrice__c;
                                                                            StandardMargin = CR.ASPublicPrice__c - CR.ASNetPrice__c ;
                                                                            //StandardDiscount = ((CR.ASNetPrice__c / CR.ASPublicPrice__c).setScale(2)*100);
                                                                            StandardDiscount = ((1 - (CR.ASNetPrice__c / CR.ASPublicPrice__c))*100);
                                                                        }
                                                                                
                                                                        if (standardMargin != null){
                                                                            genResults.writeNumberField('StandardMargin', StandardMargin.setScale(2, System.RoundingMode.HALF_UP));
                                                                        }
                                                                        
                                                                        if (standardDiscount != null){
                                                                            genResults.writeNumberField('StandardDiscount', StandardDiscount.setScale(2, System.RoundingMode.HALF_UP));
                                                                        }

                                                                        genResults.writeStringField('Stock', '');

                                                                        if(setTechId != null && setTechId.contains(substituteTECH_OriginalPart)){
                                                                            genResults.writeBooleanField('IsSelected', true);
                                                                        }
                                                                        else{
                                                                            genResults.writeBooleanField('IsSelected', false);
                                                                        }
                                                                        
                                                                    // End Object Substitution`
                                                                    genResults.writeEndObject();
                                                                }
                                                            }
                                                        }

                                                        String subPartKey =  assessExtId + '-' + partList.TECH_OriginalPart__c;
                                                        //system.debug('## subPartKey: '+subPartKey);
                                                        
                                                        if(asessPartSubMap.containskey(subPartKey)){
                                                            
                                                            for(PartList__c sub: asessPartSubMap.get(subPartKey)){
                                                                // start Object Substitution
                                                                if(!sub.isDeleted__c){
                                                                    if(!isNevada || (isNevada && sub.SelectedByBS__c)){
                                                                        genResults.writeStartObject();
                                                                            if(sub.Description__c != null){
                                                                                genResults.writeStringField('PartLabel', sub.Description__c);
                                                                            }
                                                                            //genResults.writeStringField('PartNumber', sub.PartNumber__c);

                                                                            genResults.writeStringField('PartNumber', ASCRPartNumbMap.get(sub.PartNumber__c));
                                                                            
                                                                            genResults.writeNumberField('Price', sub.Price__c);

                                                                            if(sub.ProducerName__c != null){
                                                                                genResults.writeStringField('Manufacturer', sub.ProducerName__c);
                                                                            }
                                                                        
                                                                            genResults.writeNumberField('Quantity', sub.Quantity__c);
                                                                            
                                                                            if(sub.Type__c != null){
                                                                                genResults.writeStringField('Type', sub.Type__c);
                                                                            }

                                                                            genResults.writeStringField('AlphaScaleMRID', sub.Alpha_Scale_MRID__c);
                                                                            
                                                                            if(sub.InputType__c != null){
                                                                                genResults.writeStringField('InputType', sub.InputType__c);
                                                                            }
                                                                            
                                                                            if(sub.Currency__c != null){
                                                                                genResults.writeStringField('Currency', sub.Currency__c);
                                                                            }
                                                                            

                                                                            if (sub.CertifyingOrganization__c != null){
                                                                                genResults.writeStringField('CertifyingOrganization', sub.CertifyingOrganization__c);
                                                                            }

                                                                            if (sub.standardMargin__c != null){
                                                                                genResults.writeNumberField('StandardMargin', sub.StandardMargin__c.setScale(2, System.RoundingMode.HALF_UP));
                                                                            }
                                                                            
                                                                            if (sub.standardDiscount__c != null){
                                                                                genResults.writeNumberField('StandardDiscount', sub.StandardDiscount__c.setScale(2, System.RoundingMode.HALF_UP));
                                                                            }
                                                                            genResults.writeStringField('Stock', '');
                                                                            genResults.writeBooleanField('IsSelected', sub.SelectedByBS__c);

                                                                        // End Object Substitution`
                                                                        genResults.writeEndObject(); 
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        // End Array Substitution
                                                        genResults.writeEndArray();
                                                    // End Object Part
                                                    genResults.writeEndObject();
                                                //}
                                            }
                                        }//end innerfor
                                    }//end for 
                                }//end if assessIdPartsMap.containskey(assessExtId) && !shoppingListExistAssessMap.containsKey(assessExtId)

                                // ShoppingListTrue + existingAssessment 
                                if(shopAssessIdPartsMap != null && shopAssessIdPartsMap.containskey(assessExtId)){
                                    system.debug('## enter isShopping');
                                    for(PartList__c partList: shopAssessIdPartsMap.get(assessExtId)){
                                        system.debug(partList.PartNumber__c);

                                        //AMI 12/07/17 - duplicate handling
                                        integer sizeLoop = (mapOriginalKeyListPL.containsKey(partList.TECH_OriginalPart__c)) ? mapOriginalKeyListPL.get(partList.TECH_OriginalPart__c).size : 1;
                                        list <string> tempPartList = mapOriginalKeyListPL.get(partList.TECH_OriginalPart__c).lstCrash;
                                        integer loopSize = 1;

                                        if(tempPartList.size() == sizeLoop){
                                            loopSize = sizeLoop;
                                        }

                                        for(integer i = 0;i < loopSize; i++){
                                            genResults.writeStartObject();
                                                genResults.writeStringField('PartLabel', partList.Description__c);
                                                //genResults.writeStringField('Name', partList.Name);
                                                genResults.writeStringField('PartNumber', partList.PartNumber__c);
                                                genResults.writeNumberField('Price', partList.Price__c);

                                                if(partList.ProducerName__c != null){
                                                    genResults.writeStringField('Manufacturer', partList.ProducerName__c);
                                                }
                                                
                                                genResults.writeNumberField('Quantity', partList.Quantity__c);

                                                if(partList.InputType__c != null){
                                                    genResults.writeStringField('InputType', partList.InputType__c);
                                                }
                                                
                                                if(partList.Currency__c != null){
                                                    genResults.writeStringField('Currency', partList.Currency__c);
                                                }                                                

                                                if(partList.Type__c != null){
                                                    genResults.writeStringField('Type', partList.Type__c);
                                                }                                            

                                                genResults.writeBooleanField('IsSelected', partList.SelectedByBS__c);  

                                                /*if(assessMap.get(assessExtId).crashCode__c != null && (assessMap.get(assessExtId).callerSystem__c).toUpperCase() != 'DIVA'){
                                                    genResults.writeNumberField('crashCode', assessMap.get(assessExtId).crashCode__c);
                                                }*/

                                                //AMI 17/07/17 - Crash code handling (C-001969)
                                                if(tempPartList[i] != null){
                                                    genResults.writeNumberField('crashCode', integer.valueOf(tempPartList[i]));
                                                }
                                            genResults.writeEndObject();
                                        }
                                    }//end for
                                }

                            // End Array Part
                            genResults.writeEndArray();

                            // write Object currentAsset
                            genResults.writeFieldName('currentAsset');
                            // Start Object currentAsset
                            genResults.writeStartObject();
                                genResults.writeStringField('Brand', carBrandRes);


                                if(assessMap.get(assessExtId).ModelV2__c != null){
                                    genResults.writeStringField('Model', assessMap.get(assessExtId).ModelV2__c);
                                }
                                
                                if(assessMap.get(assessExtId).PlateNumber2__c != null){
                                    genResults.writeStringField('PlateNumber', assessMap.get(assessExtId).PlateNumber2__c);
                                }

                                if(assessMap.get(assessExtId).FirstRegistrationDate__c != null){
                                    genResults.writeDateField('FirstRegistrationDate', assessMap.get(assessExtId).FirstRegistrationDate__c);
                                }
                                
                                if(assessMap.get(assessExtId).VINNumber__c != null){
                                    genResults.writeStringField('VINNumber', assessMap.get(assessExtId).VINNumber__c);
                                }
                            // End Object currentAsset
                            genResults.writeEndObject();

                            // write Object currentBodyshop
                            genResults.writeFieldName('currentBodyshop');
                            // Start Object currentBodyshop
                            genResults.writeStartObject();
                                //AccountRef__c accRef    = assessAccountRefMap.get(assessExtId.split(' - ')[0]);
                                AccountRef__c accRef    = assessAccountRefMap.get(assessExtId);
                                // ASE: 27/10/16: retrieve ReferenceNumber by splitting Name.
                                //genResults.writeStringField('ReferenceNumber', accRef.ExternalReference__c);
                                if (accRef != null){
                                    genResults.writeStringField('ReferenceNumber', accRef.Name.substringAfter('-'));
                                    } else {
                                        genResults.writeStringField('ReferenceNumber', '');
                                    }
                                
                                Account currentBodyShop = null;
                                if (accRef != null){
                                    currentBodyShop = bsRefAccountMap.get(accRef.InternalReference__c);
                                }
                                
                                if(currentBodyShop != null && currentBodyShop.ContactUser__c != null){
                                    genResults.writeStringField('BodyShopEmail', currentBodyShop.ContactUser__r.Email);
                                }
                                else if(currentBodyShop != null && currentBodyShop.ContactEmail__c != null)
                                {
                                    genResults.writeStringField('BodyShopEmail', currentBodyShop.ContactEmail__c);
                                }else {
                                    genResults.writeStringField('BodyShopEmail', '');
                                }
                            // End Object currentBodyshop
                            genResults.writeEndObject();

                            // write Object currentClaim
                            genResults.writeFieldName('currentClaim');
                            // Start Object currentClaim
                            genResults.writeStartObject();
                                if(assessMap.get(assessExtId).ClaimReference__c != null){
                                    genResults.writeStringField('ClaimReference', assessMap.get(assessExtId).ClaimReference__c);
                                }
                                if(assessMap.get(assessExtId).CompanyName__c != null){
                                    genResults.writeStringField('CompanyName', assessMap.get(assessExtId).CompanyName__c);
                                }
                               
                                if(assessMap.get(assessExtId).DateOfIncident__c != null){
                                    genResults.writeDateField('DateOfIncident', assessMap.get(assessExtId).DateOfIncident__c);
                                }
                                
                                //genResults.writeStringField('PolicyNumber', assessMap.get(assessExtId).PolicyNumber__c);
                                genResults.writeBooleanField('RepairsAuthorised', assessMap.get(assessExtId).RepairsAuthorised__c);
                                genResults.writeBooleanField('Fraud', assessMap.get(assessExtId).SupposedOfFraud__c);
                                genResults.writeBooleanField('TotalLoss', assessMap.get(assessExtId).TotalLoss__c);
                                genResults.writeBooleanField('Fleet', assessMap.get(assessExtId).Fleet__c);
                                // genResults.writeBooleanField('Rental', assessMap.get(assessExtId).SpecialRenting__c);
                                genResults.writeBooleanField('SpecialAgreement', assessMap.get(assessExtId).SpecialAgreement__c);

                                if(assessMap.get(assessExtId).ExcessAmount__c != null){
                                    genResults.writeNumberField('ExcessAmount', assessMap.get(assessExtId).ExcessAmount__c);
                                }

                                if(isNevada){
                                    genResults.writeBooleanField('Rental', assessMap.get(assessExtId).SpecialRenting__c);

                                    if(assessMap.get(assessExtId).QuotationAmtExlVAT__c != null){
                                        genResults.writeNumberField('QuotationAmountExlVAT', assessMap.get(assessExtId).QuotationAmtExlVAT__c);
                                    }

                                    if(assessMap.get(assessExtId).QuotationAmountInclVAT__c != null){
                                        genResults.writeNumberField('QuotationAmountInclVAT', assessMap.get(assessExtId).QuotationAmountInclVAT__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtLabourPainting__c != null){
                                        genResults.writeNumberField('TotalAmtLabourPainting', assessMap.get(assessExtId).TotalAmtLabourPainting__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtLabour__c != null){
                                        genResults.writeNumberField('TotalAmtLabour', assessMap.get(assessExtId).TotalAmtLabour__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtParts__c != null){
                                        genResults.writeNumberField('TotalAmtParts', assessMap.get(assessExtId).TotalAmtParts__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtPainting__c != null){
                                        genResults.writeNumberField('TotalAmtPainting', assessMap.get(assessExtId).TotalAmtPainting__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtExlVAT__c != null){
                                        genResults.writeNumberField('TotalAmtExlVAT', assessMap.get(assessExtId).TotalAmtExlVAT__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalVAT__c != null){
                                        genResults.writeNumberField('TotalVAT', assessMap.get(assessExtId).TotalVAT__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtInclVAT__c != null){
                                        genResults.writeNumberField('TotalAmtInclVAT', assessMap.get(assessExtId).TotalAmtInclVAT__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtExlVAT__c != null){
                                        genResults.writeNumberField('TotalAmtExlVAT', assessMap.get(assessExtId).TotalAmtExlVAT__c);
                                    }

                                    if(assessMap.get(assessExtId).NBHoursLabour__c != null){
                                        genResults.writeNumberField('NBHoursLabour', assessMap.get(assessExtId).NBHoursLabour__c);
                                    }

                                    if(assessMap.get(assessExtId).NBHoursLabourLevel1__c != null){
                                        genResults.writeNumberField('NBHoursLabourLevel1', assessMap.get(assessExtId).NBHoursLabourLevel1__c);
                                    }

                                    if(assessMap.get(assessExtId).NBHoursLabourLevel2__c != null){
                                        genResults.writeNumberField('NBHoursLabourLevel2', assessMap.get(assessExtId).NBHoursLabourLevel2__c);
                                    }

                                    if(assessMap.get(assessExtId).NBHoursLabourLevel3__c != null){
                                        genResults.writeNumberField('NBHoursLabourLevel3', assessMap.get(assessExtId).NBHoursLabourLevel3__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtLabourExlPainting__c != null){
                                        genResults.writeNumberField('TotalAmtLabourExlPainting', assessMap.get(assessExtId).TotalAmtLabourExlPainting__c);
                                    }

                                    if(assessMap.get(assessExtId).NBHoursLabourPainting__c != null){
                                        genResults.writeNumberField('NBHoursLabourPainting', assessMap.get(assessExtId).NBHoursLabourPainting__c);
                                    }

                                    if(assessMap.get(assessExtId).TotalAmtPaintingInclLabour__c != null){
                                        genResults.writeNumberField('TotalAmtPaintingInclLabour', assessMap.get(assessExtId).TotalAmtPaintingInclLabour__c);
                                    }

                                    if(assessMap.get(assessExtId).AmtOthers__c != null){
                                        genResults.writeNumberField('AmtOthers', assessMap.get(assessExtId).AmtOthers__c);
                                    }
                                }
                                
                            // End Object currentClaim
                            genResults.writeEndObject();

                        // End Object Assessment
                        genResults.writeEndObject();
                    }
                }
            }
            
            //AMI 06/07/2017 - Adding warning message exception handling
            if(mapWarningCreation.size() > 0){ 
                for(String suc : mapWarningCreation.keySet()){
                    genResults.writeStartObject();
                        genResults.writeStringField('OperationType', 'Insert');
                        genResults.writeNullField('TechnicalId');
                        genResults.writeStringField('FunctionalId', suc);
                        genResults.writeBooleanField('Success', true);
                        genResults.writeStringField('Warning', 'Exceptions: ' + mapWarningCreation.get(suc));
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

            if(shoppingListExistAssessMap.size() > 0){
                for(String key : shoppingListExistAssessMap.keySet()){
                    if(!shoppingListExistAssessFound.contains(key)){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'Upsert');
                            genResults.writeNullField('TechnicalId');
                            genResults.writeStringField('FunctionalId', key);
                            genResults.writeBooleanField('Success', false);
                            genResults.writeNullField('Warning');
                            genResults.writeStringField('ErrorMessage', 'Exceptions: Assessment not found in system.'); 
                        genResults.writeEndObject();
                    }
                }
            }

        // End array of Assessment
        genResults.writeEndArray();
        if(isNevada){
            genResults.writeEndObject();
        }
        
         if(assessSFDCIDMap != null){
                for(String assessExtId : assessSFDCIDMap.keySet()){
                    if(assessMap.containsKey(assessExtId)){
                                if (assessMap.get(assessExtId).Entity__c == '299'){
                                      response = '';
                                }
                            }
                }
         }
        response = genResults.getAsString();
        
        System.debug('---------------------------------- END RESTUpsertAssessmentV1 - generateResponse ----------------------------------');
        return response;
    } 

    /*private static void setCrossReferencesFieldForAssessment(Map<String, Assessment__c> assessMap, Map<String, Assessment__c> claimAssessmentMap, map<String, List<PartList__c>> assessSubstituteListMap) {
        system.debug('## setCrossReferencesFieldForAssessment START:');
        Set<String> crossRefSet = new Set<String>();
        for(String key: assessSubstituteListMap.keyset()){
            if(assessMap.containsKey(key)){
                assessMap.get(key).CrossReferences__c = '';

                for(PartList__c part : assessSubstituteListMap.get(key)){
                    // ASE 13/11/17: C-001994 - add parameters in runValidation Method
                    // issue 1
                    system.debug('## part.SelectedByBS__c:'+part);
                    system.debug('## part.SelectedByBS__c:'+part.SelectedByBS__c);
                    //if(part.SelectedByBS__c){
                        crossRefSet.add(part.PartNumber__c );
                    //}
                } 
                assessMap.get(key).CrossReferences__c = String.join(new List<String>(crossRefSet), ';');
                if(claimAssessmentMap != null){
                    String claimAssessParentId = key.left(key.length()-2); 
                    if(claimAssessmentMap.containskey(claimAssessParentId)){                 
                        claimAssessmentMap.get(claimAssessParentId).CrossReferences__c =  assessMap.get(key).CrossReferences__c; 
                    }  
                }          
            }
        }
        system.debug('## setCrossReferencesFieldForAssessment END');
    } */

    // ASE : 14/11/17 C-001994 - issue 1
    private static void setCrossReferencesFieldForAssessment(map<Id, set<String>> crossRefMap) {
        system.debug('## setCrossReferencesFieldForAssessment START:');
        list<Assessment__c> updAssessList = new list<Assessment__c>();

        system.debug('## crossRefMap:'+crossRefMap);
        for(String key : crossRefMap.keyset()){
            // ASE : 05/12/17: Setting assessment status = 'New' again to trigger sourcing again
            Assessment__c updAssessment = new Assessment__c(Id = key, CrossReferences__c = String.join(new List<String>(crossRefMap.get(key)), ';'), Status__c = 'New', PreviousStatus__c = '', SourceFailure__c ='', ReasonFailure__c = '');
            updAssessList.add(updAssessment);            
        }

        system.debug('## updAssessList:'+updAssessList);
        if(updAssessList.size() > 0){
            update updAssessList;
        }
        system.debug('## setCrossReferencesFieldForAssessment END');
    }  

    //C-001825
    public static void callRESTPostAssessment(Map<String, Assessment__c> assessMap, Map<String, Id> claimAssessSFDCMap){
       System.debug('---------------------------------- START RESTUpsertAssessmentV1 - callRESTPostAssessment -------------------------------');
       system.debug('## assessMap:'+assessMap);
       system.debug('## claimAssessSFDCMap:'+claimAssessSFDCMap);

       Set<Id> postAssesssmentIdSet    = new Set<Id>();
       for(String assessID : assessSFDCIDMap.keyset()){
           if(assessMap.containsKey(assessID)){
               Assessment__c assessment = assessMap.get(assessID);
               if(!assessment.isShoppingList__c && igEntitySet.contains(assessment.TECH_EntityCountryCode__c+assessment.EntityCode__c)){
                   if(assessment.RecordTypeId == recordTypeAssessTypeMap.get('Claim')){
                       system.debug('## Claim Id:'+assessment.Id);
                       postAssesssmentIdSet.add(assessment.Id);
                   }
                   else if(assessment.RecordTypeId == recordTypeAssessTypeMap.get('Crash')){
                       system.debug('##Crash Claim Id:'+claimAssessSFDCMap.get(crashClaimIdMap.get(assessID)));
                       postAssesssmentIdSet.add(claimAssessSFDCMap.get(crashClaimIdMap.get(assessID)));
                   }                        
               }
           }
       }
       system.debug('## postAssesssmentIdSet: '+postAssesssmentIdSet);
       if(postAssesssmentIdSet.size() > 0){
           RESTPostAssessment.buildJSONAsync(postAssesssmentIdSet);
       }
        
       System.debug('---------------------------------- END RESTUpsertAssessmentV1 - callRESTPostAssessment -------------------------------');
    }

    public class duplicateSizeCrashCodeWrapper{
        public integer size;
        public set <string> crash = new set <string>();
        public list <string> lstCrash = new list <string>();
        public duplicateSizeCrashCodeWrapper(integer size,set <string> crash,list <string> lstCrash){
            this.size = size;
            this.crash = crash;
            this.lstCrash = lstCrash;
        }
    }

    //AMI 25/07/17 - C-001927 - upsertAssessent add External ID
    public static void updatePartsKey(List<Map<String, Object>> lstProcessedAssObj){
        system.debug('## Start updatePartsKey');

        map <string,string> mapOldExtIdNewExtId  = new map <string,string>();
        string oldKey,newKey,subNewKey           = '';
        list <PartList__c> partsToBeUpdated      = new list <PartList__c>();
        map <string,string> mapOriOldKeyAssId    = new map <string,string>();
        map <string,string> mapOriOldKeyExtId    = new map <string,string>();

        //build mapOldExtIdNewExtId
        for(map <string,object> assessement : lstProcessedAssObj){
            for(object partList : (list <object>) assessement.get('Parts')){

                map <string, object> partListMap = (map <string, object>) partList;

                oldKey                           = '';
                newKey                           = '';
                string newExtId                  = String.ValueOf(partListMap.get('ExternalID'));

                //process only parts having externalid
                if(string.isNotBlank(newExtId)){

                    //build old key
                    string callerSystem          = (string.valueOf(assessement.get('callerSystem'))).toUpperCase();
                    String cleanseCallerSystem   = (callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) + callerSystem.right(callerSystem.length()-3) : userRolePrefix + callerSystem;
                    string assessNum             = (assessement.get('AssessmentNumber') != null) ? string.valueOf(assessement.get('AssessmentNumber')) : null;
                    string receivedCrashCode     = (assessement.get('crashCode') != null) ? string.valueOf( assessement.get('crashCode')) : null;
                    string crashCode             = (receivedCrashCode != null && receivedCrashCode.trim().length() == 1) ? ('0' + receivedCrashCode) : receivedCrashCode;
                    
                    //AMI 04/10/17 : Catering for crash code on parts
                    string crashCodePart         = string.ValueOf(partListMap.get('crashCode'));

                    string assessmentID          = '';

                    if(!string.isBlank(crashCodePart)){
                        assessmentID             = (cleanseCallerSystem + assessNum + '(' + ((crashCodePart.length() == 1) ? ('0' + crashCodePart) : crashCodePart) + ')').toUpperCase(); 
                    }else{
                        assessmentID             = (cleanseCallerSystem + assessNum + crashCode).toUpperCase(); 
                    }
                     
                    string partNumber            = string.valueOf(partListMap.get('PartNumber'));
                    string partDescription       = string.valueOf(partListMap.get('PartLabel'));
                    string partLabel             = partDescription.left(80);
                    string alphaScaleMRID        = (partListMap.get('AlphaScaleMRID') != null) ? String.valueOf(partListMap.get('AlphaScaleMRID')) : '';
                    string manufacturer          = string.ValueOf(partListMap.get('Manufacturer'));

                    //original
                    if(string.isBlank(alphaScaleMRID)){
                        oldKey                   = null + '-' 
                                                 + partNumber + '-' 
                                                 + partLabel.replaceAll('\\s+', '') + '-' 
                                                 + manufacturer + '-' 
                                                 + assessmentID + '-' 
                                                 + null;

                        //AMI 04/10/17 : assessmentID reconstructed since we cannot take into account old crash code since key in new system
                        //               will always contain null for crashcode
                        newKey                   = (cleanseCallerSystem + assessNum + 'null').toUpperCase() + '-' + newExtId;
                        system.debug('## newKey ' + newKey);
                    }

                    //add to map
                    if(string.isNotBlank(oldKey) && string.isNotBlank(newKey)){
                        mapOldExtIdNewExtId.put(oldKey.toUpperCase(),newKey);
                        mapOriOldKeyAssId.put(oldKey.toUpperCase(),assessmentID);
                        mapOriOldKeyExtId.put(oldKey.toUpperCase(),newExtId);
                    }
                }//end if if(string.isNotBlank(newExtId)){
            }//end looping in parts transmitted
        }//end looping in assessment
        system.debug('## mapOldExtIdNewExtId.size() ' + mapOldExtIdNewExtId);

        //query all parts having old externalid
        for(PartList__c pl : [select id,TECH_OriginalPart__c,OriginalPart__c,PartNumber__c,OriginalPart__r.TECH_OriginalPart__c
                                from PartList__c
                                where TECH_OriginalPart__c IN :mapOldExtIdNewExtId.keySet()
                                or OriginalPart__r.TECH_OriginalPart__c IN :mapOldExtIdNewExtId.keySet()]){
            system.debug('## pl ' + pl);
            subNewKey                           = '';

            //substitute parts
            if(pl.OriginalPart__c != null){ 
                //build old key for subs
                subNewKey                       = mapOriOldKeyAssId.get(pl.OriginalPart__r.TECH_OriginalPart__c) + '-' + 
                                                  mapOriOldKeyExtId.get(pl.OriginalPart__r.TECH_OriginalPart__c) + '-' + pl.PartNumber__c;

                subNewKey                       = subNewKey.replaceAll('\\([0-9]+\\)', 'NULL');

                partsToBeUpdated.add(new PartList__c(id = pl.id,TECH_OriginalPart__c = subNewKey));
            }else{
                //original parts
                partsToBeUpdated.add(new PartList__c(id = pl.id,TECH_OriginalPart__c = mapOldExtIdNewExtId.get(pl.TECH_OriginalPart__c)));
            }
        }//end looping in partlist

        system.debug('## partsToBeUpdated.size() ' + partsToBeUpdated);
        if(!partsToBeUpdated.isEmpty()){
            update partsToBeUpdated;
        }


        list <string> strUpdate = new list <string>();
        for(PartList__c pl : partsToBeUpdated){
            if(pl.TECH_OriginalPart__c.contains('ext01')){
                strUpdate.add(pl.id + pl.TECH_OriginalPart__c);
            }  
        }
        system.debug('## strUpdate ' + strUpdate);

        system.debug('## End updatePartsKey'); 
    }

    //  ASE: 17/11/17 C-002078
    public static String processICEAssessment (map<String, Assessment__c> ICEAssessmentMap, map<String, String> ICEAssessErrorMap,map <string,integer> mapAssIdPositionNumber){
        system.debug('## processICEAssessment START');

        String results = '';

        map<String, String> ICEAssessSuccessMap = new map<String, String>();   

        //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
        //             : list that will contain assessment to update
        list <Assessment__c> assessmentToUpdate = new list <Assessment__c>();

        //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
        //             : set used to check against transmitted assessment id to raise error is latter not present
        set <string> setExistingAssId = new set <string>();

        if(ICEAssessmentMap.size() > 0){
            //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
            //             : Query Assesement based on assessment ID
            for(Assessment__c ass : [select AssessmentID__c
                                        from Assessment__c
                                        where AssessmentID__c IN :ICEAssessmentMap.Keyset()]){
                assessmentToUpdate.add(new Assessment__c(AssessmentID__c = ass.AssessmentID__c,
                                                         Compensated__c = ICEAssessmentMap.get(ass.AssessmentID__c).Compensated__c));

                setExistingAssId.add(ass.AssessmentID__c);
            }//end looping in assessment
            system.debug('## assessmentToUpdate: ' + assessmentToUpdate); 
            system.debug('## setExistingAssId: ' + setExistingAssId);  

            //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
            //             : Check against existing assessment
            //             : if not present raise an error
            for(string assid : ICEAssessmentMap.Keyset()){
                if(!setExistingAssId.contains(assid)){
                    ICEAssessErrorMap.put('Assessment ['+ mapAssIdPositionNumber.get(assid) + ']', 'Assessment ['+ mapAssIdPositionNumber.get(assid) + '] not processed.  No AssessmentNumber or Compensated found.' );
                }
            }

            //AMI 18/12/17 : C-002078 - ICE - Compensation - Check if assessment exist before performing any dml
            //             : updating list to update
            //upsert assessments
            Schema.SObjectField assessExtId = Assessment__c.Fields.AssessmentID__c;
            List<Database.upsertResult> uResults = Database.upsert(assessmentToUpdate, assessExtId, false);
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(uResults[idx].isSuccess()) {
                    // if success populate the Set of id that has been successful
                    ICEAssessSuccessMap.put(assessmentToUpdate[idx].AssessmentId__c, uResults[idx].getId() );                          
                }
                else {
                    //generate the json that will be used for errors as reponse
                    for(Database.Error err : uResults[idx].getErrors()){
                        ICEAssessErrorMap.put(assessmentToUpdate[idx].AssessmentId__c, Label.Error + ': ' + err.getMessage());                                           
                    }             
                }
            }
        }

        system.debug('## ICEAssessSuccessMap:'+ICEAssessSuccessMap);  
        system.debug('## ICEAssessErrorMap:'+ICEAssessErrorMap);  

        if(ICEAssessSuccessMap.size() > 0 || ICEAssessErrorMap.size() > 0){
            JSONGenerator genResults = JSON.createGenerator(false);

            genResults.writeStartArray();
                if(ICEAssessSuccessMap.size() > 0){
                    for(String suc : ICEAssessSuccessMap.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'upsert');
                            genResults.writeStringField('TechnicalId', ICEAssessSuccessMap.get(suc));
                            genResults.writeStringField('FunctionalId', suc);                            
                            genResults.writeBooleanField('Success', true);
                            genResults.writeNullField('Warning');
                            genResults.writeNullField('ErrorMessage');
                        genResults.writeEndObject();
                    }
                }               

                if (ICEAssessErrorMap.size()> 0){
                    for(String err : ICEAssessErrorMap.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'upsert');
                            genResults.writeStringField('TechnicalId', '');
                            genResults.writeStringField('FunctionalId', err);
                            genResults.writeBooleanField('Success', false);
                            genResults.writeNullField('Warning');
                            genResults.writeStringField('ErrorMessage','Exception:' + ICEAssessErrorMap.get(err));                        
                        genResults.writeEndObject();
                    }   
                }
            genResults.writeEndArray();
            
            results = genResults.getAsString();
            system.debug('## results' + results);              
        }

        system.debug('## processICEAssessment END');
        return results;       
    } 
}