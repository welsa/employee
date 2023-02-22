/*
  ----------------------------------------------------------------------
  -- - Name          : RESTGetBodyshopEligibility
  -- - Author        : ASE
  -- - Description   : Class REST to get isEligibleSubstitution, isEligibleSourcing values of Bodyshop sent
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 09-MAY-2016  ASE    1.0     Created Class
  -- 16-JUN-2016  ASE    1.1     Initial Version
  -- 07-SEP-2016  ABT    1.2     Case C-001716 - Removed AccountRef__c from Account
  -- 01-DEC-2016  ASE    1.3     Case C-001770 - add SendingAccepted and VinCheckAuto in AccountRef__c and response generated 
  -- 13-MAR-2018  ASE    1.4     C-002368 - getBodyshopEligibility - Set the "isEligibileSubstitution" to true
  -- 16-AUG-2018  RLA    1.5     C-002690 Spain audatex assessments in r4     
  -- 18-NOV-2018  WCH    1.6     C-003470 - Provide More visibility on RESTGetBodyshopEligibility     
  ----------------------------------------------------------------------
 **********************************************************************
*/
@RestResource(urlMapping='/v1.0/getBodyshopEligibility/*')
global with sharing class RESTGetBodyshopEligibility {
    // static variables
    static String BSMissingField;
    static String BSNoMappingField;

    @HttpPost
    global static void processResponse() {
        system.debug('########### RESTGetBodyshopEligibility.processResponse START');

        //WCH 18/11/2019 C-003470
        datetime qryStart = datetime.now();
        system.debug('@@@ qryStart: '+qryStart);

        String jsonResponse = '';

        // deserialise response
        //convert the requestbody into a string
        String body = RestContext.request.requestBody.toString();
        // create log
        Log__c log      = new Log__c();
        log.DateLog__c  = System.now();
        log.Class__c  = 'RESTGetBodyshopEligibility';

        insert log;

        if (body.length() <= 30000){
            log.JSONMessage__c = body;
        }
        else {
            //APCreateAttachments.createAttachment(body, log);
            APCreateAttachments.createAttachment('Request', body, log);
        }

        System.debug('## body: ' + body);

        if(body != null && body != ''){
            // call deserialiseResponse method
            jsonResponse = deserialiseResponse(body);

            //if(jsonResponse != null){
                if(!jsonResponse.contains('"ErrorMessage":null')){
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
                    //APCreateAttachments.createAttachment(jsonResponse, log);
                    APCreateAttachments.createAttachment('Response', jsonResponse, log);
                }
            //}
            //else {
            //  log.Status__c = Label.STATUSFAILED;
            //}

            update log;
        }

        System.debug('## jsonResponse: ' + jsonResponse);

        RestContext.response.responseBody = Blob.valueOf(jsonResponse);

        //WCH 18/11/2019 C-003470
        datetime qryEnd = datetime.now();
        decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
        tempExec = (tempExec.divide(1000, 5));
        log.executionTime__c = tempExec;
        update log;
        system.debug('@@@ qryEnd: '+qryEnd);
        system.debug('@@@ tempExec: '+tempExec);
        
        System.debug('---------------------------------- END RESTGetBodyshopEligibility - processResponse ----------------------------------');
    }

    public static String deserialiseResponse(String body){
        system.debug('########### RESTGetBodyshopEligibility.deserialiseResponse START');
        // variable
        JSONGenerator genResults;
        String jsonResponse;
        Map<Id, Account> accRefAccMap = new Map<Id, Account>();
        Map<Id, Assessment__c> mapAssAccRef = new Map<Id, Assessment__c>();
        BSMissingField              = '';
        BSNoMappingField            = '';
        Set<Id> bsIdRefSet          = new Set<Id>();
        Set<String> setAssNumber          = new Set<String>();

        // ABT 07-SEP-2016 C-001716
        Map<String, AccountRef__c> mapAccountRef = new Map<String, AccountRef__c>();
        //RLA 16/08/2018 C-002690 Spain audatex assessments in r4   
        Map<String, String> mapAccRefAssNumber = new Map<String, String>();
        Map<String, Account> mapAssNumberAccount = new Map<String, Account>();

        try{
            List<Object> receivedBSRefList = (List<Object>) JSON.deserializeUntyped(body);
            if(!receivedBSRefList.isEmpty()){
                // The index of the assessment in the objList
                Integer position = 0;

                for(Object receivedBS : receivedBSRefList){
                    system.debug('@@@ receivedBS: '+receivedBS);
                    // Casting the received assessment to a map of string, object
                    Map<String, Object> receivedBSMap = (Map<String, Object>) receivedBS;

                    // check if assessment contains all mandatory fields
                    Boolean isValid = checkMandatoryFields(receivedBSMap, position);
                    // if bodyRef is Valid, check if request contains an assessment number
                    if(isValid){

                        // String refNumber    = String.valueOf(receivedBSMap.get('BodyshopReference')).replaceAll('[^A-Za-z0-9]', '');
                        //RLA 17/12/2020 C-004118: 	Remove the cleansing for the account reference for Italy
                        String refNumber;
                        String callerSystem = String.valueOf(receivedBSMap.get('callerSystem'));
                        String country = ((callerSystem.substring(2, 3) == '_') ? callerSystem.left(2) : '');
                        if (country == 'IT'){
                            refNumber    = String.valueOf(receivedBSMap.get('BodyshopReference'));
                            system.debug('@@ refNumber 1'+refNumber);
                        }
                        else{
                            refNumber    = String.valueOf(receivedBSMap.get('BodyshopReference')).replaceAll('[^A-Za-z0-9]', '');
                            system.debug('@@ refNumber 2'+refNumber);

                        } 
                        
                        String assessmentNumber = receivedBSMap.containsKey('AssessmentNumber') ? String.valueOf(receivedBSMap.get('AssessmentNumber')) : null;

                        // check if mapping exists in Account reference
                        AccountRef__c accRef    = AccountRef__c.getValues(callerSystem.toUppercase() + '-' + refNumber);
                        
                        //RLA 16/08/2018 C-002690 Spain audatex assessments in r4                        
                        if (assessmentNumber != null){
                            setAssNumber.add(assessmentNumber);
                            mapAccRefAssNumber.put(callerSystem + '-' + refNumber, assessmentNumber);
                        }
                        if(accRef != null){
                            bsIdRefSet.add(accRef.InternalReference__c);

                            mapAccountRef.put(callerSystem + '-' + refNumber, accRef);
                        }
                        else{
                            BSNoMappingField += callerSystem + '-' + refNumber + ', ' ;
                        }
                    }

                    position++;
                }
            }
            system.debug('## bsIdRefSet:'+bsIdRefSet);
            system.debug('## mapAccRefAssNumber:'+mapAccRefAssNumber);
            system.debug('## setAssNumber:'+setAssNumber);
            if(bsIdRefSet.size() > 0){
                // serach in Account by mapping account Id with AccountRef__c.InternalReference__c
                //RLA 16/08/2018 C-002690 Spain audatex assessments in r4
                if (bsIdRefSet.size() > 0){
                    accRefAccMap = new Map<Id, Account>  ([SELECT  Id
                                                              // ASE : 01/12/2016 : Case C-001770 : commented fields
                                                              ,ReferenceNumber__c
                                                              ,isEligibleSourcing__c
                                                              ,isEligibleSubstitution__c
                                                              ,ContactUser__r.Email
                                                              ,ContactUser__c
                                                              ,ContactEmail__c
                                                              ,SubstitutionIn__c
                                                              ,OrderFromAT__c
                                                              ,AXA_Partner__c
                                                              ,ShippingCountryCode 
                                                       FROM Account
                                                       WHERE Id IN : bsIdRefSet]);
                }
                system.debug('## accRefAccMap: ' + accRefAccMap);
                if (setAssNumber.size() > 0){

                    for (Assessment__c ass: [SELECT  Id,AssessmentNumber__c
                                                    ,BodyShop__c
                                                    ,BodyShop__r.ReferenceNumber__c
                                                    ,BodyShop__r.isEligibleSourcing__c
                                                    ,BodyShop__r.isEligibleSubstitution__c
                                                    ,BodyShop__r.SubstitutionIn__c
                                                    ,BodyShop__r.OrderFromAT__c
                                                    ,BodyShop__r.AXA_Partner__c
                                                    ,BodyShop__r.ShippingCountryCode 
                                            FROM Assessment__c
                                            Where AssessmentNumber__c IN : setAssNumber
                                            ]){

                        Account tempAcc = new account(Id = ass.BodyShop__c,
                                                      ReferenceNumber__c = ass.BodyShop__r.ReferenceNumber__c,
                                                      isEligibleSourcing__c = ass.BodyShop__r.isEligibleSourcing__c,
                                                      isEligibleSubstitution__c = ass.BodyShop__r.isEligibleSubstitution__c,
                                                      SubstitutionIn__c = ass.BodyShop__r.SubstitutionIn__c,
                                                      OrderFromAT__c = ass.BodyShop__r.OrderFromAT__c,
                                                      AXA_Partner__c = ass.BodyShop__r.AXA_Partner__c,
                                                      ShippingCountryCode = ass.BodyShop__r.ShippingCountryCode );
                        accRefAccMap.put(tempAcc.Id, tempAcc);

                        mapAssNumberAccount.put(ass.AssessmentNumber__c, tempAcc);


                    }

                }
                system.debug('## accRefAccMap assessmentNumber ' + accRefAccMap);

                
            }

            
            system.debug('## mapAccountRef: ' + mapAccountRef);

            jsonResponse = generateResponse(accRefAccMap, mapAccountRef,mapAccRefAssNumber, mapAssNumberAccount);
            //jsonResponse = generateResponse(mapAccountRef);
        }
        catch(Exception e){
            genResults = JSON.createGenerator(false);
            genResults.writeStartObject();
                genResults.writeStringField('OperationType', 'get');
                genResults.writeBooleanField('Success', false);
                genResults.writeNullField('Warning');
                genResults.writeStringField('ErrorMessage', e.getMessage());
            genResults.writeEndObject();
            jsonResponse = genResults.getAsString();
        }
        system.debug('########### RESTGetBodyshopEligibility.deserialiseResponse END');
        return jsonResponse;
    }

    public static String generateResponse(Map<Id, Account> accRefAccMap, 
                                          Map<String, AccountRef__c> mapAccountRef, 
                                          Map<String, String> mapAccountRefExpert,
                                          Map<String, Account> mapAssNumberAccount)
    //public static String generateResponse(Map<String, AccountRef__c> mapAccountRef)
    {
        String invalidAccountRef = '';

        // JSONGenerator;
        JSONGenerator genResults = JSON.createGenerator(false);
        //genResults.writeStringField('Version', System.label.Version);
        genResults.writeStartObject();
        genResults.writeStringField('Version', System.label.Version);
            genResults.writeFieldName('Bodyshops');
                genResults.writeStartArray();
                    // Loop in account Ref as there might be an account Ref with no Account found
                    for(String accountRef: mapAccountRef.keyset())
                    {
                        AccountRef__c accRef = mapAccountRef.get(accountRef);
                        system.debug('@@ accRef: '+accRef);

                        // check if the accountRef.InternalReference is not null and there is an account with that Id
                        if( accRef != null && 
                            accRef.InternalReference__c != null 
                            && accRefAccMap.containsKey(accRef.InternalReference__c)
                            )
                        {
                            Account acc = accRefAccMap.get(accRef.InternalReference__c);
                            system.debug('@@ acc: '+acc);
                            system.debug('@@ mapAccountRefExpert: '+mapAccountRefExpert);
                            system.debug('@@ mapAssNumberAccount: '+mapAssNumberAccount);


                            genResults.writeStartObject();
                                List<String> accountRefStringList = accountRef.split('-', 2);

                                genResults.writeStringField('callerSystem', accountRefStringList[0]);
                                
                                genResults.writeStringField('BodyshopReference', accountRefStringList[1]);
                                // ASE: 01/12/2016 : case C-001770
                                //genResults.writeBooleanField('isEligibleSubstitution', acc.isEligibleSubstitution__c);
                                //ASE : C-002368
                                genResults.writeBooleanField('isEligibleSubstitution', True);
                                 //genResults.writeBooleanField('isEligibleSourcing', acc.isEligibleSourcing__c);
                                // ABT 07-SEP-2016 C-001716
                                //if(accRef != null)
                                //{
                                //    genResults.writeBooleanField('SubstitutionAccepted', accRef.SubstitutionAccepted__c);
                                //}


                                //RLA 16/08/2018 C-002690 Spain audatex assessments in r4
                                //if (acc.ShippingCountryCode == 'ES'){
                                if (mapAccountRefExpert.containskey(accountRef) &&
                                    mapAssNumberAccount.containsKey(mapAccountRefExpert.get(accountRef))){
                                    system.debug('@@@ mapAccountRefExpert.get(accountRef): '+mapAssNumberAccount.get(mapAccountRefExpert.get(accountRef)));    
                                    
                                    if (mapAssNumberAccount.get(mapAccountRefExpert.get(accountRef)).AXA_Partner__c == true
                                        && String.isNotBlank(mapAssNumberAccount.get(mapAccountRefExpert.get(accountRef)).SubstitutionIn__c) ){
                                        genResults.writeStringField('SubstitutionIn', mapAssNumberAccount.get(mapAccountRefExpert.get(accountRef)).SubstitutionIn__c); 
                                                                                   
                                    }
                                    else if (String.isNotBlank(acc.SubstitutionIn__c)){                                            
                                        genResults.writeStringField('SubstitutionIn', acc.SubstitutionIn__c);
                                    }
                                                                       
                                    
                                }
                                else{ 
                                    if (String.isNotBlank(acc.SubstitutionIn__c)){
                                        genResults.writeStringField('SubstitutionIn', checkFieldValue(acc.SubstitutionIn__c));
                                    }
                                }
                                if (acc.OrderFromAT__c != null)
                                {
                                    genResults.writeBooleanField('OrderFromAT', acc.OrderFromAT__c);
                                }
                                //}
                                genResults.writeBooleanField('SendingAccepted', accRef.SendingAccepted__c);
                                genResults.writeBooleanField('VinCheckAuto', accRef.VinCheckAuto__c);
                            genResults.writeEndObject();
                        }
                        else
                        {
                            // The internal reference of the account ref does not exists
                            invalidAccountRef += accountRef + ', ';
                        }
                    }
                genResults.writeEndArray();

                genResults.writeStringField('OperationType', 'get');
                genResults.writeBooleanField('Success', true);

                if(invalidAccountRef != '' || BSMissingField != '' || BSNoMappingField != '')
                {
                    if(invalidAccountRef != '')
                    {
                        invalidAccountRef = invalidAccountRef.removeEnd(', ');
                        genResults.writeStringField('Warning', 'The bodyshops are not found: ' + invalidAccountRef);
                    }

                    if(BSMissingField != '') {
                        BSMissingField = BSMissingField.removeEnd(', ');
                        genResults.writeStringField('Warning', 'Missing fields: ' + BSMissingField);
                    }

                    // Uncommented as if there was 1 good request and 1 bad request, in the response the mapping not found was not written
                    if(BSNoMappingField != '') {
                        BSNoMappingField = BSNoMappingField.removeEnd(', ');
                        genResults.writeStringField('Warning', 'No mapping found for: ' + BSNoMappingField);
                    }
                }
                else
                {
                    genResults.writeNullField('Warning');
                }

                genResults.writeNullField('ErrorMessage');
        genResults.writeEndObject();


        return genResults.getAsString();
    }

    private static String checkFieldValue(String str){
        if (String.isNotBlank(str)){
            return str;
        }
        else{
            return 'null';
        }
    }

    public static Boolean checkMandatoryFields(Map<String, Object> receivedBSMap, Integer position){
        System.debug('---------------------------------- START RESTGetBodyshopEligibility - checkMandatoryFields ----------------------------------');

        Set<String> BSfieldSet;
        Boolean isValid         = false;
        BSfieldSet              = new Set<String>{'callerSystem', 'BodyshopReference'};
        String missingFields    = checkFields(BSfieldSet, receivedBSMap);

        // check if missingFields is blank, asssessment is valid
        if(missingFields == ''){
            isValid = true;
        }
        else{
            isValid = false;
            BSMissingField += 'BodyshopReference at position[' + position + ']: ' + missingFields + ', ' ;
        }

        System.debug('---------------------------------- END RESTGetBodyshopEligibility - checkMandatoryFields ----------------------------------');

        return isValid;
    }

    public static String checkFields(Set<String> BSfieldSet,Map<String, Object> receivedBSMap){
        System.debug('---------------------------------- START RESTGetBodyshopEligibility - checkFields ----------------------------------');

        Boolean isValid         = true;
        String missingFields    = '';

        // check if field exists in assessment
        for(String BSField: BSfieldSet){
            if(!receivedBSMap.containsKey(BSField)){
                isValid         = false;
                missingFields   += BSField + '; ';
            }
        }
        System.debug('---------------------------------- END RESTGetBodyshopEligibility - checkFields ----------------------------------');

        return missingFields;
    }
}