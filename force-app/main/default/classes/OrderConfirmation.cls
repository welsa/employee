/*************************************************************************************
Class Name - OrderConfirmation
Version - 1.0
Created Date - 20 February 2017
Function - Controller extension for page OrderConfirmation
    
Modification Log :
-----------------------------------------------------------------------------
* Developer    Date        Description
* ----------   ----------  -----------------------
* Dourga       20/02/2017  Original Version (case 1818 : Confirmaton page from )
* Vaynee       03/04/2018   C-002315 - Cross Scripting   
* Welsa        03/06/2019  C-002781 Spain R4
* Kejilen      10/11/2020  C-004026 : Pentest - Insecure Direct Object Reference
* Rojo          31-08-2022   C-004781
**************************************************************************************/
public without sharing class  OrderConfirmation {
    public Assessment__c ass{get;set;}
    public Boolean hasError{get;set;}
    public Boolean hasSO{get;set;}
    public String encryptedText {get; set;}
    public String salesOrderNumber {get; set;}
    public String salesOrderId {get; set;}
    public String notificationMessage {get;set;}
    public String salesOrderCreated {get;set;}
    public String encryptedSourceAssessmentId{get;set;}
    public String sourceAssessmentId{get;set;}
    public Boolean hasErrors {get; set;}
    public Boolean isToastError {get; set;}
    public Boolean fromPainting {get; set;}/*WCH 03/06/2019 C-002781*/
    public Boolean renderEparts {get;set;}//RLA C-004115: FR - E parts orderin
    public Map<Id, partlist__c> mapPartlistsE {get;set;}//RLA C-004115: FR - E parts orderin
    public static Map<Id, PartWrapper> mapPartlistsEWrapper {get;set;}//RLA C-004115: FR - E parts orderin
    public String colorDist {get;set;}
    public static map<String,Account> mapDistLink {get;set;}
    public static Map<String, String> carMapBrandMap = new Map<String, String>();
    public static String partIdToUpdate {get;set;}
    public static Boolean partisOrdered {get;set;}
    public static String assessIdEpart {get;set;}
    public static boolean hasAlreadyRun {get;set;}
    public static String distNames {get;set;}


    //searchURl returned
    public string valueReturned {get; set;}

    public OrderConfirmation() {
        hasError = false;
        hasSO = false;
        hasErrors = false;
        isToastError= false;
        fromPainting= false;/*WCH 03/06/2019 C-002781*/
        renderEparts = false;//RLA C-004115: FR - E parts orderin
        Boolean isNonAxa = false; 
        hasAlreadyRun = false;
        mapPartlistsE = new map<Id, partlist__c>();
        mapPartlistsEWrapper = new map<Id, PartWrapper>();
        colorDist = 'red';
        mapDistLink = new map<String,Account>();
        set<String> setIamManufacturer = new set<String>();
        set<String> setKeyBrand = new set<String>();
        List<partlist__c> lstPartlistE = new list<partlist__c>();
        distNames = '';

        try{
            if(ApexPages.currentPage().getParameters().get('AssessmentId') != null){
                encryptedText  = ApexPages.currentPage().getParameters().get('AssessmentId');
                String assessmentId = decryptBase64AssessmentId(encryptedText);
               
                /*WCH 03/06/2019 C-002781*/
                if(ApexPages.currentPage().getParameters().get('Painting') != null){
                    fromPainting=true;
                }

                if(ApexPages.currentPage().getParameters().get('SourceAssessmentId') != null){
                    encryptedSourceAssessmentId = ApexPages.currentPage().getParameters().get('SourceAssessmentId');
                    sourceAssessmentId = decryptBase64AssessmentId(encryptedSourceAssessmentId);
                }
                //VSU 02/04/18 C-002315
            
                Id idSrc = sourceAssessmentId != null? decryptBase64AssessmentId(encryptedSourceAssessmentId): null;
                Id idAss = decryptBase64AssessmentId(encryptedText);

                ass = [select Name, Status__c, VINNumber__c, PlateNumber2__c, Manufacturer__c, CreatedDate, 
                              BodyShop__r.Type, LastModifiedDate, ParentAssessment__c, ASReference__c, 
                              ParentAssessment__r.ASReference__c, TECH_EntityCountryCode__c,Orderorigin__c, 
                              SelectedByBSPartTypes__c,EntityCode__c,bodyshop__r.Feature__c,
                              (select Id/*,TECH_SASResponse__c*/
                              from Purchaseorders__r),
                              (select Id, Name    
                              from PrerequisiteOrders__r)
                              ,(select Id,PartNumber__c,Distributor__r.name,Description__c,ProducerName__c,E_part_Button_Cliked__c,
                              Assessment__r.manufacturer__c
                              from partslists__r where Type__c = 'E' and SelectedByBS__c = true
                              and  CrossReferenceId__r.Connected__c = false//RBE 15/02/2023: To prevent Connected Es from being selected
                              )
                       from Assessment__c
                       where Id =: assessmentId];
                system.debug('## ass' +ass);

                if(ass.Purchaseorders__r.size() > 0){
                    notificationMessage = fromPainting ? String.format(System.label.NotificationMessage, new List<String>{ass.ASReference__c}):String.format(System.label.NotificationMessage, new List<String>{ass.ParentAssessment__r.ASReference__c});/*WCH 03/06/2019 C-002781*/
                    //DUN 12.04.2017 TECH_SASResponse__c not used
                    //for(PurchaseOrder__c po: ass.Purchaseorders__r){
                    //    if(po.TECH_SASResponse__c != null && po.TECH_SASResponse__c != 'Success'){
                    //        hasError = true;
                    //    }
                    //}   
                }
                if(ass.PrerequisiteOrders__r.size() > 0){
                    hasSO = true;
                    salesOrderCreated = fromPainting ? String.format(System.label.SalesOrderCreated, new List<String>{ass.ASReference__c}):String.format(System.label.SalesOrderCreated, new List<String>{ass.ParentAssessment__r.ASReference__c});/*WCH 03/06/2019 C-002781*/
                    salesOrderNumber = ass.PrerequisiteOrders__r[0].Name;
                    salesOrderId = ass.PrerequisiteOrders__r[0].id;
                }

                system.debug('here 1>>'+ass.bodyshop__r.Feature__c);


                //RLA C-004115: FR - E parts orderin
                if (String.isnotblank(ass.SelectedByBSPartTypes__c) && ass.SelectedByBSPartTypes__c.contains(system.label.commandePieceE) && ass.partslists__r.size() > 0 && String.isnotblank(ass.bodyshop__r.Feature__c) && ass.bodyshop__r.Feature__c.contains('Order Part E')){
                    renderEparts = true;
                    if (String.IsNotBlank(sourceAssessmentId)){
                        assessIdEpart = sourceAssessmentId;
                    }
                    else{
                       assessIdEpart = assessmentId;  
                    }
                    isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => ass.TECH_EntityCountryCode__c, 'entity' => ass.EntityCode__c, 'fromProcess' => 'Order'});

                    if (isNonAxa){
                        renderEparts = false;

            }
                    else{
                        for (partlist__c part: ass.partslists__r){

                            if (String.isnotBlank(part.ProducerName__c)){
                                setIamManufacturer.add(part.ProducerName__c.toUpperCase());
                                setKeyBrand.add(part.ProducerName__c.toUpperCase()+'-'+ass.Manufacturer__c.toUpperCase());
                                lstPartlistE.add(part);
                            }
                        }
                    }                                       
                }
            }

            if (renderEparts){
                system.debug('setKeyBrand>>'+setKeyBrand);

                for(CarMappings__mdt carMapMdt : [Select MasterLabel, CarDestination__c from CarMappings__mdt where MasterLabel = :setKeyBrand ]){
                    if(!carMapBrandMap.containsKey(carMapMdt.MasterLabel)){
                        carMapBrandMap.put(carMapMdt.MasterLabel, carMapMdt.CarDestination__c);
            }
                }
                system.debug('carMapBrandMap>>'+carMapBrandMap);

                map<Id,String> mapdisIdTechDis = new map<Id,String>();
                set<Id> setDisIds = new set<Id>();

                if (setIamManufacturer.size() > 0){
                    for (Account dis: [select Feature__c, E_Part_Backgound_Color__c, 
                        E_part_Order_Link__c, E_Part_Text_Color__c,Tech_Distributor__c
                        from account where Tech_Distributor__c in: setIamManufacturer And DistributorConnected__c = true
                        //HRM where recType distributor
                        ]){
                        mapDistLink.put(dis.Tech_Distributor__c, dis);
                        setDisIds.add(dis.Id);
                        mapdisIdTechDis.put(dis.Id, dis.Tech_Distributor__c);   
                        distNames += dis.Tech_Distributor__c + ';';                     
                    }
                        
                }
                system.debug('mapDistLink>>'+mapDistLink);
                system.debug('distNames>>'+distNames);

                for (partlist__c part: lstPartlistE){
                    Id disId = mapDistLink.containskey(part.ProducerName__c.toUpperCase()) ? mapDistLink.get(part.ProducerName__c.toUpperCase()).Id : null;
                    system.debug('disId>>'+disId);
                    string logo = '';
                   
                    mapPartlistsEWrapper.put(part.Id, new PartWrapper(part, (mapDistLink.containskey(part.ProducerName__c.toUpperCase()) ? mapDistLink.get(part.ProducerName__c.toUpperCase()) : null),logo));

                }
                system.debug('mapPartlistsEWrapper>>'+mapPartlistsEWrapper);
                
            }
            

        }//try
        catch(Exception e){
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){ 
                system.debug(e.getMessage() + e.getStackTraceString());
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID+ e.getStackTraceString()));
            }
            else{
                hasErrors = true;
                isToastError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
        }
    }


    public static String decryptBase64AssessmentId(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();
        System.debug('Decrypted Text ' + decryptedText);

        return decryptedText;
    }

    public PageReference downloadPDFQuote()
    {
        PageReference downloadPage  = Page.VFP17_PrintPartListForAssessment;
        
        downloadPage.getParameters().put('force_download', 'true');
        downloadPage.getParameters().put('Id', ass.id);
        downloadPage.setRedirect(false);

        return downloadPage;
    }

    public PageReference downloadPDFOrder()
    {
        PageReference downloadPage  = Page.VFP14_PrintPartListForBodyshop;

        downloadPage.getParameters().put('force_download', 'true');
        //KPA 10/11/2020  C-004026 
        String SOId = EncodingUtil.base64Encode(Blob.valueof(salesOrderId));
        
        downloadPage.getParameters().put('Id',SOId);
        
       // downloadPage.getParameters().put('Id', salesOrderId);
        downloadPage.getParameters().put('isDeliveryNote', 'true');

        //WCH 23/12/2019 C-003531 isConfirmationDeCommande
        if(ass!=null && ass.TECH_EntityCountryCode__c.equals('FR')){
            downloadPage.getParameters().put('isCDC', 'true');
        }

        downloadPage.setRedirect(false);

        return downloadPage;
    }
    @RemoteAction
    public static String authenticateRem(String accNames){

        try{
            system.debug('@@@ authenticateRem:');
            hasAlreadyRun = true;
            if (String.isnotBlank(accNames)){
                for (String accName: accNames.split(';')){
                    if (accName.toUpperCase() == 'OPISTO'){
                        String accessToken = getAuthentication();
                    }
                }
            }   
            return null;
            
        }
        catch(exception e){
            system.debug(e.getMessage() + e.getStackTraceString());
            return null;
        }

    }

    @RemoteAction
    public static string callDistributor(string partIdToUpdate, String techDis){
        system.debug('@@@ partIdToUpdate:'+partIdToUpdate);
        String response;                
        string errMsg;

        try{

            if (partIdToUpdate != null){
                response = updatePart(partIdToUpdate,techDis);

            }
            
            if (String.isnotBlank(response) && response.contains('Error')){
                errMsg = response;
                response = 'Error';
            }
            // else{
            //     system.debug('@@@@@err'+response);

            //     // ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error'));
            //     return 'Error';
            // }
        }

        catch(Exception e){

            system.debug('@@@@@err'+e.getMessage() + e.getStackTraceString());
            //  hasErrors = true;
            // isToastError = true;
            // ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage() + e.getStackTraceString()));
            errMsg = e.getMessage() + e.getStackTraceString();
            response = 'Error';
            if (String.isnotBlank(errMsg)){
                createLog(techDis,errMsg, null, null,null, null, null);
                
            }
            

        }

        

        return response;


    }
    @future
     public static void createLog (String techDis, String errMsg, string respFromDistributor, string reqStr, Decimal tempExec, String process, string sobjectId){
        system.debug('@@@ i am bigger than :'+respFromDistributor);
        APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
        wrapperLog.className = 'OrderConfirmation';
        wrapperLog.process = 'EpartsOrdering' + '-' + process;
        wrapperLog.objectreference = UserInfo.getName();
        wrapperLog.sobjectName = techDis;
        wrapperLog.jsonmessage = reqStr != null && reqStr.length() <= 30000 ? reqStr : '';
        wrapperLog.sobjectName = 'Partlist__c';
        wrapperLog.jsonresponse = respFromDistributor != null && respFromDistributor.length() <= 30000 ? respFromDistributor : '';

        wrapperLog.wserrormessage = errMsg != null && errMsg.length() <= 30000 ? errMsg : '';
        if(errMsg != null){
            wrapperLog.status = Label.STATUSFAILED;
        }
        else{
            wrapperLog.status = Label.STATUSPASSED;
        }  

        if(reqStr != null && reqStr.length() > 30000){
            wrapperLog.attachmentRequestbody = reqStr;
        }

        if(errMsg != null && errMsg.length() > 30000){
            wrapperLog.attachmentResponsebody = errMsg;
        }  
         
         if(respFromDistributor != null && respFromDistributor.length() > 30000){
             system.debug('@@@ i am bigger than :');
            wrapperLog.attachmentResponsebody = respFromDistributor;
        }  
        
        
        APManageLogs.createWsLog(wrapperLog, 'insert');
    }

    public static string updatePart(string partIdToUpdate, String techDis){
        system.debug('@@@ updatePart method:'+partIdToUpdate);
       
        String responsecallout;

       
        
        techDis = techDis.toUpperCase();
        techDis = RESTUpsertAssessmentV2.cleanseReference(techDis);
       

        if (String.Isnotblank(techDis) && techDis == 'OPISTO'){

            String accessToken = getAuthentication();

            if (String.isnotblank(accessToken)){
            
                map <String, Object> mapReturnCallout = callDistforPart(new map<String, Object> {'accessToken'=> accessToken, 'manufacturerReferences' => '123456', 'partId' => partIdToUpdate});

                if (mapReturnCallout.containsKey('searchUrl')){
                    responsecallout =  mapReturnCallout.containsKey('searchUrl') ? (string)mapReturnCallout.get('searchUrl') : (mapReturnCallout.containsKey('error') ? (string)mapReturnCallout.get('error') : null);
                    // responsecallout =  mapReturnCallout.containsKey('error') ? (string)mapReturnCallout.get('error') : null;

                }
                else{
                    return 'Error';                    
                }

            }
        }
        else {
            return 'Error';
        }    
            
        return responsecallout;
      
        
    }

    public static String getAuthentication(){
        String accessToken;
        for (Log__c log: [select id,ETL_DATA_NAME__c,DateLog__c from Log__c where ETL_INTERFACE_NAME__c = 'OPISTO' Limit 1]){
            if (string.isnotBlank(log.ETL_DATA_NAME__c) && log.DateLog__c != null && !isTokenExpired(log.DateLog__c)){
                if (String.isNotBlank(log.ETL_DATA_NAME__c)){
                    accessToken = log.ETL_DATA_NAME__c;
                }
            }
            else{
                Map<String, Object> mapResponseAuthenticate = authenticateOpisto(log.Id);
                accessToken = mapResponseAuthenticate.containsKey('accessToken') ? (String)mapResponseAuthenticate.get('accessToken') : null;

            }
        }

        return accessToken;
    }

    public static Boolean isTokenExpired(Datetime expiryDate){
        Datetime rightnow = system.now();
        Integer secondsExpiry = Integer.ValueOf(system.label.tokenOpistoExpiryDate);
        expiryDate = expiryDate.addSeconds(secondsExpiry);
        
        if (rightnow > expiryDate ){
            system.debug('@@ token has expired');
            return true;
        }
        else{
            system.debug('@@ token has not expired');

            return false;
        }
    }

    public static DateTime epochToHuman(long timeStamp){

        return (DateTime.newInstance(timeStamp* 1000));
    }

    public static Map<String, Object>  authenticateOpisto(Id LogId){

        List<ConfigurationFlux__mdt> getConfigs = [select id,Runnable__c,SecretId__c from ConfigurationFlux__mdt where DeveloperName='OrderConfirmationAuthenticate'];
        String accessToken = '';
        Long expiration;
        Map<String, Object> mapResultAuthenticate = new map<String, Object>();
        string errMsg;
        string respFromDistributor;
        string reqStr;
        Decimal tempExec;
        datetime qryStart = datetime.now();
        try{        
            // string secretId = '';
            if ((getConfigs.size() > 0 && getConfigs[0].Runnable__c) || (Test.isRunningTest())){

                HTTPRequest request = new HTTPRequest();
                request.setEndpoint('callout:OpistoAuthenticate');
                System.debug('HRM Auth endpoint: '+request.getEndpoint());
                request.setMethod('POST');
                string secretId = getConfigs[0].SecretId__c;
               
                reqStr = '{"secretId":"'+secretId+'","userName":"{!$Credential.UserName}","password":"{!$Credential.Password}"}';
                system.debug('@@@reqStr: '+reqStr);


                request.setBody(reqStr);

                request.setHeader('Content-Type','application/json; charset=UTF-8');
                request.setHeader('Accept','text/plain');
                
            
                request.setTimeout(integer.valueOf(system.label.EIPTimeout));

                HTTP httpCall = new HTTP();
                if (String.isnotBlank(reqStr)){
                    
                    System.debug('## request: ' + request);
                    System.debug('## request: ' + request.getBody());
                    
                    HTTPResponse response	= httpCall.send(request);
                        System.debug('## response: ' + response);
                    if(response != null){
                        String statusCode = String.valueOf(response.getStatusCode());
                        if(statusCode == '200'){
                                
                            system.debug(response.getBody()); 
                            respFromDistributor =  response.getBody();
                            responseOpisto responseOpistoIns =  (responseOpisto) System.JSON.deserialize(respFromDistributor, responseOpisto.class);
                            Map<String, Object> responseDistMap = (Map<String, Object>)JSON.deserializeUntyped(respFromDistributor);
                            System.debug('## responseOpistoIns: ' + responseOpistoIns);
                            System.debug('## responseDistMap: ' + responseDistMap);
                            if (responseOpistoIns != null ){
                                
                                if (responseOpistoIns.message != null){
                                    system.debug('***************error'+ responseOpistoIns.message);
                                }
                                else if (responseOpistoIns.Data != null){
                                Data dataOpisto = responseOpistoIns.Data;
                                accessToken = dataOpisto.accessToken;
                                expiration = dataOpisto.expiration;
                                DateTime dateOfExpiry = epochToHuman(expiration);
                                    updatelog(accessToken,dateOfExpiry,LogId);
                                }                            

                            }
                        
                        }
                        else{
                            accessToken = 'Error';
                        }

                    }

                }
            }
        }
        catch(Exception e){
            errMsg = e.getMessage() + e.getStackTraceString();
        }
        mapResultAuthenticate.put('accessToken',accessToken);
        mapResultAuthenticate.put('expiration',expiration);
        datetime qryEnd = datetime.now();
        tempExec = (qryEnd.getTime() - qryStart.getTime());
        tempExec = (tempExec.divide(1000, 5));
        createLog('Partlist__c', errMsg, respFromDistributor, reqStr, tempExec, 'Authentication Callout to Opisto',null);



        return mapResultAuthenticate;


    }
    @future
    public static void updatelog(String accessToken,DateTime dateOfExpiry, id LogId ){
        
        Log__c log = (new log__c (Id = LogId, ETL_DATA_NAME__c = accessToken, Status__c = 'Passed', DateLog__c = dateOfExpiry));        
        update log;
    }

    public static map<String, Object> callDistforPart(Map<String, Object> mapParams){
        
        system.debug('@@@ start of callDistforPart:');

        string accessToken = mapParams.containsKey('accessToken') ? (string)mapParams.get('accessToken') : null;
        string manufacturerReferences = mapParams.containsKey('manufacturerReferences') ? (string)mapParams.get('manufacturerReferences') : null;
        String partId =  mapParams.containsKey('partId') ? (string)mapParams.get('partId') : null;
        Map<String, Object> mapInputParams = new map<String,Object>();
        Map<String, Object> mapResultcallDistforPart = new map<String,Object>();
        String searchUrl;

        // ass
        if(partId != null){
             system.debug('@@@ partId:'+partId);

            Partlist__c part = [select id,ProducerName__c,E_part_Button_Cliked__c,CrossReferenceId__r.OEMCleanPartNumber__c, CrossReferenceId__r.OEMManufacturer__c,Assessment__r.bodyshop__r.ReferenceNumber__c, Assessment__r.TECH_EntityCountryCode__c, Assessment__r.callerSystem__c from Partlist__c where id = :partId];
            Boolean partisOrdered = part.E_part_Button_Cliked__c;    
            manufacturerReferences = part.CrossReferenceId__r.OEMCleanPartNumber__c;
            // CrossReference__c xref = [select id from CrossReference__c where Id =: ]        

            Account dist;
        	system.debug('@@@ part:'+part);
            if (part.ProducerName__c != null){
                System.debug('HRM Part ProducerName: '+part.ProducerName__c);
                for (Account dis: [select ReferenceNumber__c,Tech_Distributor__c,Remove_A_from_Partnumber__c
                        from account where Tech_Distributor__c =: part.ProducerName__c
                        ]){
                    dist = dis;
                }
            }           
			system.debug('@@@ dist:'+dist);
            system.debug('@@@ manufacturerReferences:'+manufacturerReferences);
            if (dist != null && part.Assessment__r.bodyshop__r.ReferenceNumber__c != null && String.isnotBlank(manufacturerReferences) ){
                system.debug('@@@ dist:');
                if (String.isnotBlank(system.label.AllowedBrandsforAPrefix) && dist.Remove_A_from_Partnumber__c){
                    List<String> lstMercedes = (system.label.AllowedBrandsforAPrefix).split(';');
                    if (String.IsNotBlank(part.CrossReferenceId__r.OEMManufacturer__c) 
                        && lstMercedes.contains(part.CrossReferenceId__r.OEMManufacturer__c.toUpperCase())
                        && String.isNotBlank(manufacturerReferences)
                        && manufacturerReferences.startsWith('A')){
                        
                        manufacturerReferences = manufacturerReferences.removeStart('A');
                        system.debug('@@ manufacturerReferences in Mercedes'+manufacturerReferences);

                    }
                
                }   

                String key = dist.Tech_Distributor__c + '-' + part.Assessment__r.bodyshop__r.ReferenceNumber__c;
                String bsExtId = RestDistributorUtility.getBSExtId (key.toUpperCase());
                system.debug('## bsExtId' +bsExtId);
                mapInputParams.put('manufacturerReferences', manufacturerReferences);
                mapInputParams.put('accessToken', accessToken);
                mapInputParams.put('bsExtId', bsExtId);
                // searchUrl = calloutToDist(new mapInputParams<String,Object>{'manufacturerReferences' => manufacturerReferences, 'accessToken' => accessToken, 'bsExtId' => bsExtId});
                if (String.isBlank(bsExtId)){
                    mapResultcallDistforPart.put('error', system.label.AsPartnerNoREf);
                    createLog('Partlist__c', system.label.AsPartnerNoREf, null, null, null, 'Authentication Callout to Opisto',null);
                }
                else{
                    searchUrl = calloutToDist(mapInputParams);
                    mapResultcallDistforPart.put('searchUrl' , searchUrl);
                }
                                
            }
            else{
                mapResultcallDistforPart.put('error', system.label.AsPartnerNoREf);
                createLog('Partlist__c', system.label.AsPartnerNoREf, null, null, null, 'Authentication Callout to Opisto',null);

            }

            if (String.IsnotBlank(searchUrl)){
                system.debug('@@@searchUrl: '+searchUrl);
                system.debug('@@@partisOrdered: '+partisOrdered);
                system.debug('@@@partId: '+partId);
                
                if (partId != null && partisOrdered != null && !partisOrdered){
                    system.debug('@@ am here');
                   
                    Partlist__c partUp = new Partlist__c(id = partId, E_part_Button_Cliked__c = true);
                     system.debug('@@ partUp'+partUp);
                    update partUp;
                }
            }  

        }
        else{
            mapResultcallDistforPart.put('error', 'no partId was found');

        }

        return mapResultcallDistforPart;
    }

    public static string calloutToDist(Map<String, Object> mapParams){
        system.debug('@@@ Start of callout to Opisto');
        List<ConfigurationFlux__mdt> getConfigs = [select id,Runnable__c,SecretId__c from ConfigurationFlux__mdt where DeveloperName='OrderConfirmationCallOpisto'];
        String searchUrl;
        string accessToken = mapParams.containsKey('accessToken') ? (string)mapParams.get('accessToken') : null;
        string bsExtId = mapParams.containsKey('bsExtId') ? (string)mapParams.get('bsExtId') : null;
        string manufacturerReferences = mapParams.containsKey('manufacturerReferences') ? (string)mapParams.get('manufacturerReferences') : null;
        manufacturerReferences = String.isnotBlank(manufacturerReferences) ?  RESTUpsertAssessmentV2.cleanseReference(manufacturerReferences) : manufacturerReferences;
        String reqStr;
        string respFromDistributor;
        datetime qryStart = datetime.now();
        String errMsg;
        if ((getConfigs.size() > 0 && getConfigs[0].Runnable__c) || (Test.isRunningTest())){
			
            try{

                HTTPRequest request = new HTTPRequest();
                    request.setEndpoint('callout:OpistoStockCallout');
                    request.setEndpoint(
                        String.format(
                            'callout:OpistoStockCallout/Parts?clientId={0}&manufacturerReferences={1}&langId=1&offset=0&page=0&itemsPerPage=10',
                            new String[]{bsExtId, manufacturerReferences}
                        )
                    );


                    request.setMethod('GET');

                request.setHeader('Accept','text/plain');
                request.setHeader('Token',accessToken);
            
                request.setTimeout(integer.valueOf(system.label.EIPTimeout));

                HTTP httpCall = new HTTP();
                    reqStr = String.valueof(request);
                // if (String.isnotBlank(reqStr)){
                    HTTPResponse response	= httpCall.send(request);

                    System.debug('## request: ' + request);
                    System.debug('## request: ' + request.getBody());
                        System.debug('## response: ' + response);

                    if(response != null){
                        String statusCode = String.valueOf(response.getStatusCode());
                        if(statusCode == '200'){
                                
                            system.debug(response.getBody()); 
                            respFromDistributor =  response.getBody();
                            // responseOpisto responseOpistoIns =  (responseOpisto) System.JSON.deserialize(respFromDistributor, responseOpisto.class);
                            System.debug('## respFromDistributor: ' + respFromDistributor);

                            // List<Object> objList = (List<Object>) JSON.deserializeUntyped(respFromDistributor);
                            // for(Object responseDist : objList){
                                Map<String, Object> responseDistMap = (Map<String, Object>) JSON.deserializeUntyped(respFromDistributor);
                                if(responseDistMap.get('data') != null){
                                    Map<String, Object> currentDataMap = (Map<String, Object>) responseDistMap.get('data'); 
                                    System.debug('## currentDataMap: ' + currentDataMap);

                                    searchUrl = (currentDataMap.get('searchUrl') != null && currentDataMap.get('searchUrl') != '') ? String.valueOf(currentDataMap.get('searchUrl')) : 'Error';

                                    System.debug('## searchUrl: ' + searchUrl);
                                    // mapResultcallDistforPart.put('searchUrl' , searchUrl);                               


                                }
                                else{
                                    searchUrl = 'Error';
                                }
                                
                        }
                        else{
                            searchUrl = 'Error';
                        }

                    }

            }
            catch(Exception e){
                errMsg = e.getMessage() + e.getStackTraceString();
                searchUrl = 'Error';
            }
        }
        datetime qryEnd = datetime.now();
        decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
        tempExec = (tempExec.divide(1000, 5));
        createLog('Partlist__c', errMsg, respFromDistributor, reqStr, tempExec, 'Callout to Opisto',null);

        return searchUrl;

    }
    //WCH 30/08/2022 C-004781
    public static string calloutToDistFerron(Map<String, Object> mapParams){
        system.debug('@@@ Start of callout to Ferron');
        List<ConfigurationFlux__mdt> getConfigs = [select id,Runnable__c,SecretId__c from ConfigurationFlux__mdt where DeveloperName='OrderConfirmationAuthenticateFerron'];
        String searchUrl;
        String reqStr;
        string respFromDistributor;
        datetime qryStart = datetime.now();
        String errMsg;
        if ((getConfigs.size() > 0 && getConfigs[0].Runnable__c) || (Test.isRunningTest())){
			//RRJ 30/08/2022 C-004781
            try{
                generateJWTFerron newConnection = new generateJWTFerron();
                searchUrl=newConnection.generateJWT(mapParams);

            }
            catch(Exception e){
                errMsg = e.getMessage() + e.getStackTraceString();
                searchUrl = 'Error';
            }
        }
        datetime qryEnd = datetime.now();
        decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
        tempExec = (tempExec.divide(1000, 5));
        createLog('Partlist__c', errMsg, respFromDistributor, reqStr, tempExec, 'Callout to Ferron',null);//verifier en prod c'est comment?


        return searchUrl;

    }

    //RLA C-004115: FR - E parts orderin
    public without sharing class PartWrapper
    {
        public PartList__c currentPart {get; set;}
        public Boolean isOrdered {get;set;}
        public String orderLink {get;set;}
        public Boolean isAdvanced {get;set;}
        public String backgrounColorButton {get;set;}
        public String textColorButton {get;set;}
        public String textDis {get;set;}
        public String logoBase64 {get;set;}
        public string FileId {get;set;}
        public VFC29_ASPartners.Distributeur distLog {get;set;}
        

        public PartWrapper(PartList__c currentPartlist, Account dis, String imageStr)
        {
            currentPart = currentPartlist;
            isOrdered = currentPartlist.E_part_Button_Cliked__c;
            orderLink = '';
            backgrounColorButton= '';
            textColorButton= '';
            isAdvanced = dis != null && string.isnotBlank(dis.Feature__c) && dis.Feature__c.contains('E Distributor Advanced feature') ? true : false;
            FileId = imageStr;
            
            if ( isAdvanced && dis != null){
                orderLink = dis.E_part_Order_Link__c;
                if (String.isnotblank(currentPartlist.Assessment__r.manufacturer__c) && String.isnotblank(currentPartlist.ProducerName__c)){
                    string keybrand = currentPartlist.ProducerName__c.toUppercase() + '-' + currentPartlist.Assessment__r.manufacturer__c.toUpperCase();
                    system.debug('@@ keybrand: '+keybrand);
                    string brandToRep = carMapBrandMap.containskey(keybrand) ? carMapBrandMap.get(keybrand) : '';
                    if (string.isnotblank(orderLink)){
                        if (String.isnotblank(brandToRep)){
                            orderLink = orderLink.replace('brand', brandToRep);
                        }
                        else{
                            orderLink = orderLink.replace('brand', currentPartlist.Assessment__r.manufacturer__c);
                        }
                    }

                }
                backgrounColorButton = dis.E_Part_Backgound_Color__c;
                textColorButton = dis.E_Part_Text_Color__c;
                textDis = dis.Tech_Distributor__c;
                List<VFC29_ASPartners.Distributeur> lstDistlog = VFC29_ASPartners.getDistributorlogo(new Map<Id, Account> {dis.Id => dis}, 'LOGOEPART');
                // List<VFC29_ASPartners.Distributeur> lstDistlog = NULL;
                if (lstDistlog.size() > 0){
                    distLog = lstDistlog[0];
                }
                

            }


        }

    }

    public class Distributeur {
            public Account distributor {get; set;}
            public String distributorLogo {get; set;}
            
            public Distributeur(Account distributor, String logo)	{
                this.distributor = distributor;
                this.distributorLogo = logo;
         }
    }

    public class responseOpisto{
        public Data data;
        public Integer errorCode;   
        public String message;
    }

    public class Data {
        public String accessToken;
        public Long expiration;
        public Integer apiUserId;
    }
    //RRJ 30/08/2022 C-004781
    public class generateJWTFerron {

        public String generateJWT(Map<String, Object> mapParams){
    
        Auth.JWT jwt = new Auth.JWT();

        // add query on named credentials
        //JwtFormulaSubject invalid
        //string str = (string)mapParams.get('NamedCredentialDevName')
        NamedCredential NamedCred = [SELECT Id, DeveloperName, MasterLabel, Endpoint, PrincipalType,JwtFormulaSubject, JwtIssuer, JwtValidityPeriodSeconds, JwtAudience, AuthTokenEndpointUrl FROM NamedCredential where DeveloperName = 'FerronJWT'];

        jwt.setIss(NamedCred.JwtIssuer);//JwtIssuer

        jwt.setAud(NamedCred.JwtAudience);//JwtAudience

        // ID du bodyShop Connecté
        jwt.setSub((string)mapParams.get('bsReferenceNo')); //mapParams.get('bsReferenceNo')

        jwt.setValidityLength(NamedCred.JwtValidityPeriodSeconds);//JwtValidityPeriodSeconds

        // Generate token

        Auth.JWS signedToken = new Auth.JWS(jwt, 'sfdc_ferron');

        String serializedToken = signedToken.getCompactSerialization();

        return NamedCred.Endpoint+serializedToken;//concatenate with Endpoint
    
        }
    
    }
}