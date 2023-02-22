/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 06-02-2023
 * @last modified by  : RBE
**/
public without sharing class RestDistributorUtility implements Queueable,Database.AllowsCallouts { 
/*************************************************************************************
Class Name - RestDistributorUtility
Version - 1.0
Created Date - 02/08/2017
Function - RestDistributorUtility 

Modification Log :
-------------------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  ---------------------------------------------------------
* Abdool M      02/08/2017  Initial Version (C-001808)  
* Abdool M      12/10/2017  SAS : Envoyer l'IAMManufacturer des pièces issues de la substitution que pour les pièces de type autre que A
* Abdool M      01/12/2017  Distributor Price Part Number should be send for ASCR insteat of IAM Part Number on Cross Ref
* Abdool M      05/12/2017  Distributor name should be fetch from Tech_Distributor__c instead of referencing name directly
* Abdool M      12/12/2017  Creating LOG for distributor callout (EIP Request and Response)
* Abdool M      04/01/2018  C-002150 - Appel STOCK SAS avec 2 fois la même pièce
* Ashwina S    18/04/2018  C-002477: ASP- Prefix
* Ashwina S    10/07/2018  C-002659 : Prices & Part Type to be sent to Coler  
* Ruksaar L    18/05/2020  C-3697 : IG - searchAssessment
* Ruksaar L       12/06/2020   C-003754: IG - Update Query Call for Coler
* Welsa C      17/08/2020   C-003578 - Expert Assessment KO when claim reference does not meet required conditions
* Welsa C      07/08/2020   C-003864 - 2020 Connectivity changes for EIP
* Ruksaar L    23/03/2021   C-004102: FR - Aniel Distributor Integration
*************************************************************************************/

    public static set <string> setDistributorName                        = new set <string>();
    public static map <string, Account> mapDistributorNameDistributor    = new map <string, Account>();
    public static map <id,Account> distributorMap;
    public static Boolean POisUpdate;

    //do not run ws if no distributor eligible 
    public static boolean doNotRunWS                                     = false;                        

    //constructor variables
    public Assessment__c assRecord;
    public list <Account> distributorLst;
    public map <Id, PartList__c> partMap; 
    public Boolean isUpdate;
    public Boolean isFromSearchAssessment;

    //RBE 31/02/2023
    // public static Map<String, Id> mapOccNameId;

    public RestDistributorUtility(Assessment__c assRecord,list <Account> distributorLst,map <Id, PartList__c> partMap, Boolean isUpdate, Boolean isFromSearchAssessment){
        this.assRecord = assRecord;
        this.distributorLst = distributorLst;
        this.partMap = partMap;
        this.isUpdate = isUpdate;
        this.isFromSearchAssessment = isFromSearchAssessment; //RLA 18/05/2020  C-3697 : IG - searchAssessment
    }

    public void execute(QueueableContext context) {
        //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
        //                new param variable to hold class name when generating log for distributor callout (in VFC_RESTUpdatePOOrderLines)
        initialiseWSCallOut(assRecord, distributorLst, partMap, isUpdate, isFromSearchAssessment, new map <string,PurchaseOrder__c>(),'');
    }
    //RLA 18/05/2020  C-3697 : IG - searchAssessment
    public static string initialiseWSCallOut(Assessment__c assRecord,
                                                list <Account> distributorLst,
                                                map <Id, PartList__c> partMap,
                                                Boolean isUpdate,
                                                map <string,PurchaseOrder__c> mapExistingPOUpsertKeyPO,
                                                string className){
        return initialiseWSCallOut(assRecord, distributorLst, partMap, isUpdate, false, new map <string,PurchaseOrder__c>(),'');
        
    }
     
    //mapExistingPOUpsertKeyPO ==> this map determines if PO needs to be created 
    public static string initialiseWSCallOut(Assessment__c assRecord,
                                                list <Account> distributorLst,
                                                map <Id, PartList__c> partMap,
                                                Boolean isUpdate,
                                                Boolean isFromSearchAssessment, //RLA 18/05/2020  C-3697 : IG - searchAssessment
                                                map <string,PurchaseOrder__c> mapExistingPOUpsertKeyPO,
                                                string className){
        system.debug('## Start initialiseWSCallOut');
        
        //boolean to determine request status (applies mainly for re launch of ws within button)
        POisUpdate                                                       = isUpdate;
        system.debug('## POisUpdate:'+POisUpdate);

        //initialise rest callout
        HttpResponse response                                            = new HttpResponse();
        Http http                                                        = new http();
        HttpRequest request                                              = new HttpRequest();

        //build request body
        string strReq                                                    = buildDistributorRequest(assRecord, distributorLst, partMap,isFromSearchAssessment);

        //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
        //                Initialise Log Object
        Log__c log                                                       = new Log__c();
        String attachmentReq, attachmentRes;
        
        //WCH 07/08/2020 C-003864
        Map<String, Object> requestEIPEndpoint = new Map<String, Object>{'EIP_EndPoint' => 'authenticate'};
        Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(requestEIPEndpoint);


        if(string.isNotBlank(className) && string.isNotBlank(strReq)){
            log.DateLog__c                                             = System.now(); 
            log.SystemCalling__c                                       = 'Draft';
            log.Class__c                                               = className;
            //   log.JSONMessage__c                                         = strReq;
            if (strReq.length() < 30000) {      
                log.JSONMessage__c = strReq;
            }
            else{
                attachmentRes = strReq;
                //createAttachment(log, wrapperLog.wsRequest, 'WSRequest');
            }

        }
        
        //get results of orderline upsert status
        string OLUpsertStatus                                            = '';

        //doNotRunWS is true when no distributor is connected (all distributors from sourcing are not connected)
        if(doNotRunWS){
            OLUpsertStatus                                               = processResponse(assRecord,
                                                                                            setDistributorName,
                                                                                            distributorLst,
                                                                                            '',
                                                                                            response.getBody(),
                                                                                            'X',
                                                                                            partMap,
                                                                                            mapExistingPOUpsertKeyPO);  
        }else{
            if(string.isNotBlank((String)responseEIPEndpoint.get('EIP_EndPoint'))){ //WCH 07/08/2020 C-003864
                request.setEndpoint((String)responseEIPEndpoint.get('EIP_EndPoint'));//WCH 07/08/2020 C-003864
                request.setMethod('POST');
                request.setTimeout(integer.valueOf(system.label.EIPTimeout));
                request.setHeader('Content-Type','application/json; charset=UTF-8');
                request.setbody(strReq);

                try{

                    datetime calloutStart = datetime.now();
                    response                                                 = http.send(request);
                    system.debug('## response <> ' + response);
                    datetime calloutEnd = datetime.now();
                    decimal tempExec = (calloutEnd.getTime() - calloutStart.getTime());
                    tempExec = (tempExec.divide(1000, 5));

                    log.ExecutionTime__c = tempExec;



                    if(response != null){
                        //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
                        //                save response received from EIP
                        // log.JSONResponse__c                                   = response.getBody();
                         if (response.getBody().length() < 30000) {      
                            log.JSONResponse__c = response.getBody();
                        }
                        else{
                            attachmentRes = response.getBody();
                            //createAttachment(log, wrapperLog.wsRequest, 'WSRequest');
                        }

                        if(response.getStatusCode() == 200){

                            if (isFromSearchAssessment){
                                String s = RESTSearchAssessment.processResponseParts(assRecord,partMap,response.getBody());
                                OLUpsertStatus = response.getBody();
                                // system.debug('## OLUpsertStatus' + OLUpsertStatus);
                                log.sObject__c = 'Assessment__c';
                                log.ObjectReference__c = assRecord.AssessmentID__c;


                            }
                            else{
                                OLUpsertStatus                                   = processResponse(assRecord,
                                                                                                setDistributorName,
                                                                                                distributorLst,
                                                                                                response.getBody(),
                                                                                                '',
                                                                                                string.valueOf(response.getStatusCode()),
                                                                                                partMap,
                                                                                                mapExistingPOUpsertKeyPO);

                            }
                            


                            Map<String, Object> responseObjMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                            String message = responseObjMap.containsKey('Message') ? (String.ValueOf(responseObjMap.get('Message')) != null ?  String.ValueOf(responseObjMap.get('Message')) : null ): null; 

                            if(message == '' || message == null){ 
                                log.Status__c  = 'Passed';
                            }
                            else{
                                log.Status__c  = 'Failed';
                            }
                        }else{
                            if (isFromSearchAssessment){
                                String s = RESTSearchAssessment.processResponseParts(null,null,null);
                                log.sObject__c = 'Assessment__c';
                                log.ObjectReference__c = assRecord.AssessmentID__c;


                                OLUpsertStatus = response.getBody();
                                // system.debug('## OLUpsertStatus' + OLUpsertStatus);



                            }
                            else{
                                OLUpsertStatus                                   = processResponse(assRecord,
                                                                                                setDistributorName,
                                                                                                distributorLst,
                                                                                                '',
                                                                                                response.getBody(),
                                                                                                string.valueOf(response.getStatusCode()),
                                                                                                partMap,
                                                                                                mapExistingPOUpsertKeyPO); 
                            }
                            log.Status__c  = 'Failed';
                        }
                    }//end if response != null*/
                }catch(System.CalloutException e) {
                    //return error message
                    //call out exception
                    system.debug('### Exception callout ' + e);
                    
                    //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
                    //                save response received from EIP
                    log.JSONResponse__c                                      = e.getMessage();
                    log.Status__c  = 'Failed';
                    

                    if (isFromSearchAssessment){
                        String s = RESTSearchAssessment.processResponseParts(assRecord,partMap,null);
                        log.sObject__c = 'Assessment__c';
                        log.ObjectReference__c = assRecord.AssessmentID__c;

                        OLUpsertStatus = response.getBody();
                        // system.debug('## OLUpsertStatus' + OLUpsertStatus);


                    }
                    else{
                        OLUpsertStatus                                           = processResponse(assRecord,
                                                                                                setDistributorName,
                                                                                                distributorLst,
                                                                                                '',
                                                                                                e.getMessage(),
                                                                                                '408',
                                                                                                partMap,
                                                                                                mapExistingPOUpsertKeyPO); 

                    }
                    
                }
            }else{
                //return error message
                //no endpt found
            }
        }

        //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
        //                insert log
        system.debug('## log ' + log);
        if(log != null){
            insert log;
        }
        if (String.isNotBlank(attachmentReq )){
           APCreateAttachments.createAttachment('WSRequest', attachmentReq, log);           
        }

        if (String.isNotBlank(attachmentRes)){
            APCreateAttachments.createAttachment('WSResponse' , attachmentRes, log);           
        }

        system.debug('## End initialiseWSCallOut'); 
        // system.debug('## OLUpsertStatus ' + OLUpsertStatus);
        return OLUpsertStatus;
    }
        //RLA 18/05/2020  C-3697 : IG - searchAssessment
    public static string buildDistributorRequest(Assessment__c assRecord, list <Account> distributorLst, Map<Id, PartList__c> partMap){
        return buildDistributorRequest(assRecord, distributorLst, partMap,false);

    
    }

    //method used to construct request to call Distributor WS
    public static string buildDistributorRequest(Assessment__c assRecord, list <Account> distributorLst, Map<Id, PartList__c> partMap,Boolean isFromSearchAssessment){
        system.debug('## Start buildDistributorRequest');

        string req                                                       = '';
        string recordTypeIdMaterial                                      = '';

        map <string,object> distributorObj                               = new map <string,object>();
    
        //DUN 05.12.2017 sourcing check make
        //AMI 05/12/17 : Adding Tech_Distributor__c in query
        distributorMap                                                   = new map <id,Account>([select id, Name,Tech_Distributor__c, Categories__c, PartTypeRegionDelayMatrix__c,DistributorConnected__c,DistributorCarBrandSupplied__c,Type_of_Substitutes__c,
                                                                                                        Rebate__c,OrderRequest__c,ReferenceNumber__c /*RLA 4018 */ 
                                                                                                    from Account
                                                                                                    where id IN :distributorLst
                                                                                                    // and DistributorConnected__c = true
                                                                                                    and Type_of_Substitutes__c Includes ('Distributor Connected')
                                                                                                    ]);
        //no connected distributor found
        system.debug('## distributorMap ' + distributorMap);
        if(distributorMap.isEmpty()){
            doNotRunWS = true;
        }
        
        map <id,Account> mapBodyshop                                     = new map <id,Account>([select id,Name,VATNumber__c,ReferenceNumber__c
                                                                                                    from Account
                                                                                                    where id = :assRecord.BodyShop__c]); 
        
        system.debug('## mapBodyshop ' + mapBodyshop);

        system.debug('## doNotRunWS:'+doNotRunWS);

        //get cross reference info in order to send IAM Manufacturer for ascr only
        map <id,CrossReference__c> mapPartIdCrossRef                     = new map <id,CrossReference__c>();

        //get cross reference info in order to send IAM PartNumber for ascr only
        map <id,CrossReference__c> mapPartIdCrossRefForPN                = new map <id,CrossReference__c>();

        //AMI 01/12/17 : Get DistributorPartNumber__c from distributor price for ascr only
        map <string,string> mapCombiDistIdPartIdAndDistPNumber           = new map <string,string>();

        map<id, set<Id>> mapPartIdDistributorPrice                       = new map<id, set<Id>>(); 

        //AMI 04/01/18 : C-002150 - Appel STOCK SAS avec 2 fois la même pièce
        //             : build map cross ref id and list of associated parts
        //             : this is because same parts can be present more than once
        map<Id, set <Id>> mapCrossRefPart                                = new map<Id, set <Id>>(); 

        //RLa 15/03/18 : Map of Partlists and orderlines
        map <String, OrderLine__c> mapPartsOrderlines       = new map <String, OrderLine__c>();
        map <Id, Boolean> mapPOAgency = new map <Id, Boolean>();

        //RLA 15/05/2020 : C-003697 : IG - searchAssessment
        Boolean isIG = assRecord != null && isFromSearchAssessment && String.isNotBlank(assRecord.InsuranceBroker__c) && system.label.InsBrokerName.contains(assRecord.InsuranceBroker__c) ? true : false;

        string insuranceBroker = assRecord.InsuranceBroker__c;

        //RLA 11/08/2020 C-003697: IG - searchAssessmen
        // Map<String, String> mapLabelCarDestination = RestDistributorUtility.getCarMappingsMatrixV2();
        String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);


        //build mapRTNameRTId
         for(RecordType rType : [SELECT Id, DeveloperName 
                            FROM    RecordType 
                            WHERE   SobjectType =: Label.SOBJECTPARTLIST]){
            if(rType.DeveloperName == 'Material'){
                recordTypeIdMaterial = rType.Id;
                break;
            }
        }

        BodyShop BodyShop ;
        Vehicle Vehicle ;
        mainRequest mainRequest ; 
        system.debug('## partMap ' + partMap);

        //RLa 26/03/18 : to store the brand name from custom metadata type of vehicle
        String brandName;
        String distBrand;



        //build mapPartIdCrossRef
        //AMI 12/10/17 : SAS : Envoyer l'IAMManufacturer des pièces issues de la substitution que pour les pièces de type autre que A
        for(PartList__c pt : [select id,CrossReferenceId__c,CrossReferenceId__r.IAMPartNumber__c,CrossReferenceId__r.IAMManufacturer__c,Type__c, /*Case 2659*/ Assessment__r.TECH_EntityCountryCode__c
                                from PartList__c
                                where id IN :partMap.KeySet()
                                and CrossReferenceId__c != null]){
            if(pt.Type__c != 'A'){
                mapPartIdCrossRef.put(pt.id,new CrossReference__c(id = pt.CrossReferenceId__c,
                                                                   IAMManufacturer__c = pt.CrossReferenceId__r.IAMManufacturer__c));

                
            }
            
            mapPartIdCrossRefForPN.put(pt.id,new CrossReference__c(id = pt.CrossReferenceId__c,
                                                                    IAMPartNumber__c = pt.CrossReferenceId__r.IAMPartNumber__c));

            //AMI 04/01/18 : C-002150 - Appel STOCK SAS avec 2 fois la même pièce
            //             : build map cross ref id and list of associated parts
            //             : this is because same parts can be present more than once
            if(mapCrossRefPart.containsKey(pt.CrossReferenceId__c)){
                mapCrossRefPart.get(pt.CrossReferenceId__c).add(pt.id);
            }else{
                mapCrossRefPart.put(pt.CrossReferenceId__c, new set <id>{pt.id});
            }
        }

        //build mapPartsOrderlines
        //RLA 15/03/18
        for(OrderLine__c ol : [select id,PartList__c, PurchaseOrder__c, PurchaseOrder__r.Distributor__c, PurchaseOrder__r.AgencyMode__c
                                from OrderLine__c
                                where PartList__c IN :partMap.KeySet()
                                      AND OrderType__c = 'FINAL'
                                ]){            
      
            mapPartsOrderlines.put(ol.PartList__c + '-' + ol.PurchaseOrder__r.Distributor__c, ol);
            if(!mapPOAgency.containsKey(ol.PurchaseOrder__r.Distributor__c)){
                mapPOAgency.put(ol.PurchaseOrder__r.Distributor__c, ol.PurchaseOrder__r.AgencyMode__c);
            } 

            
        }
        system.debug('## mapCrossRefPart:'+mapCrossRefPart);
        system.debug('## mapPartIdCrossRef: ' + mapPartIdCrossRef);
        system.debug('## mapPartIdCrossRefForPN: ' + mapPartIdCrossRefForPN); 
        system.debug('## mapPartsOrderlines: ' + mapPartsOrderlines); 

        // ASE: 27/11/17: check if we have distributor prices for cross Ref
        //AMI 04/01/18 : C-002150 - Appel STOCK SAS avec 2 fois la même pièce
        //             : update mapPartIdDistributorPrice and mapCombiDistIdPartIdAndDistPNumber 
        //             : since same parts can be present more than once
        for(DistributorPrice__c dp : [Select CrossReference__c, DistributorID__c,DistributorPartNumber__c 
                                        from DistributorPrice__c 
                                        where Active__c = true 
                                        AND isDeleted__c = false 
                                        AND CrossReference__c in: mapCrossRefPart.keyset()]){
            
            if(!mapPartIdDistributorPrice.containsKey(dp.DistributorID__c)){
                mapPartIdDistributorPrice.put(dp.DistributorID__c, new set<id>(mapCrossRefPart.get(dp.CrossReference__c))); 
            } 
            else{
                mapPartIdDistributorPrice.get(dp.DistributorID__c).addAll(mapCrossRefPart.get(dp.CrossReference__c));  
            }  

            //AMI 01/12/17 : build mapCombiDistIdPartIdAndDistPNumber
            if(mapCrossRefPart.get(dp.CrossReference__c).size() > 1){
                for(string idPart : mapCrossRefPart.get(dp.CrossReference__c)){
                    mapCombiDistIdPartIdAndDistPNumber.put(dp.DistributorID__c + '-' + idPart,dp.DistributorPartNumber__c);
                }
            }else{
                list <id> tempListId = new list <id>(mapCrossRefPart.get(dp.CrossReference__c));
                 mapCombiDistIdPartIdAndDistPNumber.put(dp.DistributorID__c + '-' + tempListId[0],dp.DistributorPartNumber__c);
            }
        }
        //zzz
        for(DistributorPrice__c dp : [Select CrossReference__c, DistributorID__c,DistributorPartNumber__c 
                                        from DistributorPrice__c 
                                        where Active__c = true 
                                        AND isDeleted__c = false 
                                        AND CrossReference__c in: mapCrossRefPart.keyset()]){
                                        }
        //RLA 13/01/2020 C-001921: Optimisation : Review Upsert performance
        set<String> setBrandDist = new set<String>();
        for(id accId : distributorMap.keySet()){

            for(String prtId : partMap.keyset()){
                PartList__c prt = partMap.get(prtId);

                String manufacturer = mapPartIdCrossRef.containsKey(prt.Id) ? (mapPartIdCrossRef.get(prt.Id).IAMManufacturer__c != null ? (mapPartIdCrossRef.get(prt.Id).IAMManufacturer__c).toUpperCase() : assRecord.Manufacturer__c) : assRecord.Manufacturer__c;

                String distBrandLocal = distributorMap.get(accId).Tech_Distributor__c;
                setBrandDist.add((distBrandLocal + '-' +manufacturer).toUpperCase());
                // String manufacturerFinal = mapLabelCarDestination.get((distBrand + '-' +manufacturer).toUpperCase());
            }

        }
        Map<String, String> mapLabelCarDestination = getCarMappingsMatrixV3(setBrandDist);

        
        system.debug('## mapPartIdDistributorPrice: ' + mapPartIdDistributorPrice);
        system.debug('## mapCombiDistIdPartIdAndDistPNumber: ' + mapCombiDistIdPartIdAndDistPNumber); 
        
        //populating distributorObj
        for(id accId : distributorMap.keySet()){
            //build setDistributorName
            //used during po creation
            //
            //AMI 05/12/17 : Fetch Tech_Distributor__c instead of distributor name
            setDistributorName.add(distributorMap.get(accId).Tech_Distributor__c);

            //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
            Set<String> setAllowedSubstitutes = new Set<String>();
            if (String.isnotBlank(distributorMap.get(accId).Type_of_Substitutes__c)){
                setAllowedSubstitutes = new Set<String>(distributorMap.get(accId).Type_of_Substitutes__c.split(';')) ;
            }
            
            //AMI 05/12/17 : add Tech_Distributor__c as key instead of distributor name
            mapDistributorNameDistributor.put(distributorMap.get(accId).Tech_Distributor__c, distributorMap.get(accId));

            //build parts to be asscoiated with each distributor
            list <Parts> tempSuppliedParts                               = new list <Parts>(); 

            //build categories associated with each distributor
            set <string> setCategory                                     = new set <string>();

            if(distributorMap.get(accId).Categories__c != null){
                setCategory                                              = new set <string>(new list <string>(distributorMap.get(accId).Categories__c.split(';')));
            }//end if distributorMap.get(accId).Categories__c != null
            
            set<Id> setPartIdDistributorPrice = mapPartIdDistributorPrice.get(accId);   
            //RLA 31/10/2020 C-004018: IG - Efa requirements
            Integer j = 0;

            for(String prtId : partMap.keyset()){
                PartList__c prt = partMap.get(prtId);
                Boolean makeSupplied = (distributorMap.get(accId).DistributorCarBrandSupplied__c != null && distributorMap.get(accId).DistributorCarBrandSupplied__c.contains(assRecord.Manufacturer__c));
                // system.debug('@@ prt: '+prt);
                //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
                if(prt.RecordTypeId == recordTypeIdMaterial && prt.Quantity__c > 0 && ((prt.PartNumber__c.contains('ASCR') && setAllowedSubstitutes.contains('CatalogSubstitute')) || (!prt.PartNumber__c.contains('ASCR') && setAllowedSubstitutes.contains('Update OEM') )) ){
                    system.debug('@@ prt: '+prt);

                    //RLA 31/10/2020 C-004018: IG - Efa requirements
                    j++;
                    String sequenceID = String.valueOf(j);
                    // String sequenceID = String.valueOf(i)+String.valueOf(j);

                    //AMI 01/12/17 : build key which will be used to fetch distributor part number for ascr
                    string combiKey                                      = accId + '-' + prtId;

                    /*********ASE : 28/05/2018 : changes in calculations*/
                    //String partIdToSend = distributorMap.get(accId).OrderRequest__c == 'OrderPO' ? mapPartsOrderlines.get(prt.Id).Id : prt.Id;
                    String partIdToSend =  isFromSearchAssessment ? prt.TECH_OriginalPart__c : prt.Id;
                    
                    /*ASE : 18/04/18 C-002477*/
                    String partNumber = mapCombiDistIdPartIdAndDistPNumber.containsKey(combiKey) ? (mapCombiDistIdPartIdAndDistPNumber.get(combiKey) != null ? mapCombiDistIdPartIdAndDistPNumber.get(combiKey) : ''): prt.PartNumber__c; 
                    
                    //RLA 23/03/18  Case-002380 CarMapping for SearchDistributor
                    distBrand = distributorMap.get(accId).Tech_Distributor__c;
                    //String manufacturer = (prt.CrossReferenceId__c != null) ? (prt.CrossReferenceId__r.IAMManufacturer__c != null ? prt.CrossReferenceId__r.IAMManufacturer__c : assRecord.Manufacturer__c) : (string.isNotBlank(prt.ProducerName__c) ?  prt.ProducerName__c : assRecord.Manufacturer__c);
                    
                    String manufacturer = mapPartIdCrossRef.containsKey(prt.Id) ? (mapPartIdCrossRef.get(prt.Id).IAMManufacturer__c != null ? (mapPartIdCrossRef.get(prt.Id).IAMManufacturer__c).toUpperCase() : assRecord.Manufacturer__c) : assRecord.Manufacturer__c;

                    //manufacturer = (distBrand + '-'+assRecord.Manufacturer__c).toUpperCase();  

                    //RLA to revert back
                    // String manufacturerFinal = RestDistributorUtility.getCarMappingsMatrix((distBrand + '-' +manufacturer).toUpperCase());

                    String manufacturerFinal = mapLabelCarDestination.get((distBrand + '-' +manufacturer).toUpperCase());

                    if (String.isBlank(manufacturerFinal)){
                        manufacturerFinal = manufacturer;   
                    }
                    // system.debug('@@ manufacturerFinal2:'+manufacturerFinal);
                    // system.debug('@@ makeSupplied:'+makeSupplied);
                    // system.debug('@@partNumber:'+partNumber);
                    //AMI 01/12/17 : fetch distributor part number for ascr
                    //if(setCategory.size() > 0){
                    if((setCategory.size() > 0 && setCategory.contains(prt.Type__c) && makeSupplied) || (!setCategory.contains(prt.Type__c) && setPartIdDistributorPrice != null && setPartIdDistributorPrice.size()> 0 && setPartIdDistributorPrice.contains(prt.Id))){
                        system.debug('@@here 1:');

                        if(mapPartsOrderlines != null && mapPartsOrderlines.containsKey(partIdToSend + '-' + accId) && mapPartsOrderlines.get(partIdToSend + '-' + accId).PurchaseOrder__c!= null && mapPartsOrderlines.get(partIdToSend + '-' + accId).PurchaseOrder__r.Distributor__c != null && mapPartsOrderlines.get(partIdToSend + '-' + accId).PurchaseOrder__r.Distributor__c == accId ){
                            tempSuppliedParts.add(new Parts(integer.valueOf(prt.Quantity__c),
                                                            'false',
                                                            //string.valueOf(prt.Id), Commented by RLA
                                                            partIdToSend,
                                                            /*ASE : 18/04/18 C-002477*/
                                                            // (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: (partNumber.startsWith(system.label.DEsubstiturePrefix)) ? partNumber.split(system.label.DEsubstiturePrefix)[1] : partNumber,
                                                            //RLA 09/07/2020 C-003857: IG - Creation IGO 
                                                            RestDistributorUtility.getOemPartNumber (partNumber , InsuranceBroker, prefixPartNumberIGO),
                                                            prt.Type__c,
                                                            manufacturerFinal,
                                                            prt.Description__c
                                                            ,sequenceID  //RLA 31/10/2020 C-004018: IG - Efa requirements
                                                            ));
                        }    
                        else if (isIG && isFromSearchAssessment){
                            // system.debug('@@here 4:');

                            tempSuppliedParts.add(new Parts(integer.valueOf(prt.Quantity__c),
                                                            'false',
                                                            //string.valueOf(prt.Id), Commented by RLA
                                                            partIdToSend,
                                                            /*ASE : 18/04/18 C-002477*/
                                                            // (partNumber.startsWith(system.label.DEsubstiturePrefix)) ? partNumber.split(system.label.DEsubstiturePrefix)[1]: partNumber,
                                                             //RLA 09/07/2020 C-003857: IG - Creation IGO 
                                                            RestDistributorUtility.getOemPartNumber (partNumber , InsuranceBroker, prefixPartNumberIGO),
                                                            prt.Type__c,
                                                            manufacturerFinal,                                                        
                                                            prt.Description__c
                                                            ,sequenceID  //RLA 31/10/2020 C-004018: IG - Efa requirements
                                                            ));

                        }                    
                    }
                    //}
                    else{         
                        system.debug('@@here 2:');
                        //can supply all parts
                        if(mapPartsOrderlines != null && mapPartsOrderlines.containsKey(partIdToSend + '-' + accId) && mapPartsOrderlines.get(partIdToSend + '-' + accId).PurchaseOrder__c!= null && mapPartsOrderlines.get(partIdToSend + '-' + accId).PurchaseOrder__r.Distributor__c != null && mapPartsOrderlines.get(partIdToSend + '-' + accId).PurchaseOrder__r.Distributor__c == accId ){
                            system.debug('@@here 3:');

                            tempSuppliedParts.add(new Parts(integer.valueOf(prt.Quantity__c),
                                                            'false',
                                                            //string.valueOf(prt.Id), Commented by RLA
                                                            partIdToSend,
                                                            /*ASE : 18/04/18 C-002477*/
                                                            // (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: (partNumber.startsWith(system.label.DEsubstiturePrefix)) ? partNumber.split(system.label.DEsubstiturePrefix)[1] : partNumber,
                                                             //RLA 09/07/2020 C-003857: IG - Creation IGO 
                                                            RestDistributorUtility.getOemPartNumber (partNumber , InsuranceBroker,prefixPartNumberIGO),
                                                            prt.Type__c,
                                                            manufacturerFinal,                                                        
                                                            prt.Description__c
                                                            ,sequenceID  //RLA 31/10/2020 C-004018: IG - Efa requirements
                                                            ));
                        }   
                        else if (isIG && isFromSearchAssessment){
                            system.debug('@@here 4:');

                            tempSuppliedParts.add(new Parts(integer.valueOf(prt.Quantity__c),
                                                            'false',
                                                            //string.valueOf(prt.Id), Commented by RLA
                                                            partIdToSend,
                                                            /*ASE : 18/04/18 C-002477*/
                                                            // (partNumber.startsWith(system.label.DEsubstiturePrefix)) ? partNumber.split(system.label.DEsubstiturePrefix)[1]: partNumber,
                                                             //RLA 09/07/2020 C-003857: IG - Creation IGO 
                                                            RestDistributorUtility.getOemPartNumber (partNumber , InsuranceBroker, prefixPartNumberIGO),
                                                            prt.Type__c,
                                                            manufacturerFinal,                                                        
                                                            prt.Description__c
                                                            ,sequenceID //RLA 31/10/2020 C-004018: IG - Efa requirements
                                                            ));  

                        }                      
                    }
                }
            }//end looping in partlist
            system.debug('## supplied parts '+ tempSuppliedParts);
            //build distributorObj
            //AMI 05/12/17 : add Tech_Distributor__c instead of distributor name
            Boolean AgencyMode = mapPOAgency.containsKey(accId) ? mapPOAgency.get(accId) : false; 
            // system.debug('## AgencyMode:'+AgencyMode);
            //RLA 31/10/2020 C-004018: IG - Efa requirements
            String bsExtId = getBSExtId (distributorMap.get(accId).Tech_Distributor__c + '-' + mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c);
                
            
            distributorObj.put(distributorMap.get(accId).Tech_Distributor__c,new distributor('', (distributorMap.get(accId).OrderRequest__c == 'OrderPO' ? AgencyMode : null),true, tempSuppliedParts,bsExtId));//RLA 11/06/2020 C-003754: IG - Update Query Call for Coler
        
        }//end looping in account
        // system.debug('## distributorMap:'+distributorMap);
        // system.debug('## mapDistributorNameDistributor:'+mapDistributorNameDistributor);

        //build bodyshop
        if(mapBodyshop.size() > 0){
            BodyShop                                                     = new BodyShop(
                mapBodyshop.get(assRecord.BodyShop__c).Name,
                // ASE: this line should be commented in Prod
                //RLA 15/09/2020 C-003940: Check on Bodyshop Reference number to send to Distributor
                isColer(mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c) ? system.label.FakeBodyshopReference: string.isNotBlank(mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c) ? mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c : '', //RLA Case 2603                
                //string.isNotBlank(mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c) ? mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c : '',
                string.isNotBlank(mapBodyshop.get(assRecord.BodyShop__c).VATNumber__c) ? mapBodyshop.get(assRecord.BodyShop__c).VATNumber__c : '');
        }//end if mapBodyshop.size() > 0
        else{
            BodyShop                                                     = new BodyShop('','','');
        }

        //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
        distBrand += ('-'+assRecord.Manufacturer__c).toUpperCase(); 
        brandName = getCarMappingsMatrix(distBrand);

        if ( String.isBlank(brandName)){
            brandName =  string.isNotBlank(assRecord.Manufacturer__c) ? assRecord.Manufacturer__c : '';   
        
        }

        //build vehicle
        Vehicle                                                          = new Vehicle(
            brandName,
            string.isNotBlank(assRecord.ModelV2__c) ? assRecord.ModelV2__c : '',
            assRecord.FirstRegistrationDate__c != null ? string.valueOf(assRecord.FirstRegistrationDate__c) : '',
            string.isNotBlank(assRecord.PlateNumber2__c) ? assRecord.PlateNumber2__c : '',
            string.isNotBlank(assRecord.VINNumber__c) ? assRecord.VINNumber__c : '',
            null);

        //build main request
        mainRequest                                                      = new mainRequest(
            string.isNotBlank(assRecord.ClaimReference__c) ? assRecord.ClaimReference__c : '',
            false,
            'Draft',
            '',
            (object)distributorObj,
            BodyShop,
            Vehicle);

        //serialise request while eliminating null param
        req                                                              = Json.serialize(mainRequest,true);
        
        // system.debug('## req ' + req);
        system.debug('## End buildDistributorRequest');

        return req; 
    }

    //RBE 30/02/2023 C-004898: PREv2 Connected - Lot 3.4 - Order - Stock Call For Occurence
    public static string buildConnectedEDistributorRequest(Assessment__c assRecord, List<Occurence__c> lstOcc){        
        MainRequest mainRequest;
        BodyShop BodyShop;
        Vehicle Vehicle;
        Map <string,object> distributorObj          = new map <string,object>();
        List<String> lstXref                        = new List<String>();
        Map<String, List<Occurence__c>> mapDistOcc  = new Map<String, List<Occurence__c>>();
        Map <Id,Account> mapBodyshop                = new map <id,Account>([SELECT Id,Name,VATNumber__c,ReferenceNumber__c
                                                                            FROM Account
                                                                            WHERE Id = :assRecord.BodyShop__c]);

        for(Occurence__c occ : lstOcc){
            if(!mapDistOcc.containskey(occ.Distributor__c)){
                mapDistOcc.put(occ.Distributor__c, new List<Occurence__c>());
            }
            mapDistOcc.get(occ.Distributor__c).add(occ); 
        }

        for(Id distId : mapDistOcc.keyset()){
            String distName                     = mapDistOcc.get(distId)[0].Distributor__r.Tech_Distributor__c;            
            List<PartsConnectedE> lstPartsE     = new List<PartsConnectedE>();
            for(Occurence__c occ : mapDistOcc.get(distId)){
                lstPartsE.add(new PartsConnectedE(occ.Name,occ.DistributorReference__c));
            }
            distributorObj.put(distName, new distributorXref('',null,true,lstPartsE,mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c));
        }
        
        if(mapBodyshop.size() > 0){
            BodyShop = new BodyShop(
                mapBodyshop.get(assRecord.BodyShop__c).Name,
                string.isNotBlank(mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c)    ? mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c : '',
                string.isNotBlank(mapBodyshop.get(assRecord.BodyShop__c).VATNumber__c)          ? mapBodyshop.get(assRecord.BodyShop__c).VATNumber__c : '');
        }
        else{
            BodyShop = new BodyShop('','','');
        }
        
        Vehicle = new Vehicle(
            assRecord.Manufacturer__c.toUpperCase(),
            string.isNotBlank(assRecord.ModelV2__c)         ? assRecord.ModelV2__c : '',
            assRecord.FirstRegistrationDate__c != null      ? string.valueOf(assRecord.FirstRegistrationDate__c) : '',
            string.isNotBlank(assRecord.PlateNumber2__c)    ? assRecord.PlateNumber2__c : '',
            string.isNotBlank(assRecord.VINNumber__c)       ? assRecord.VINNumber__c : '',
            null);
            
        mainRequest = new mainRequest(
            string.isNotBlank(assRecord.ClaimReference__c) ? assRecord.ClaimReference__c : '',
            false,
            'Draft',
            '',
            (object)distributorObj,
            BodyShop,
            Vehicle);

        return Json.serialize(mainRequest,true);       
    } 

    //method used to construct request to call Distributor WS

    //public static string buildDistributorRequestV2(Assessment__c assRecord, list <Account> distributorLst, Map<Id, PartList__c> partMap){
    //    system.debug('## Start buildDistributorRequest');

    //    string req                                                       = '';
    //    string recordTypeIdMaterial                                      = '';

    //    map <string,object> distributorObj                               = new map <string,object>();
    
    //    //DUN 05.12.2017 sourcing check make
    //    //AMI 05/12/17 : Adding Tech_Distributor__c in query

    //    //RLA avoid select and fill map with information retrieved from parent class
    //    distributorMap  = new map <id,Account>(distributorLst);

        
    //    //no connected distributor found
    //    system.debug('## distributorMap ' + distributorMap);
    //    if(distributorMap.isEmpty()){
    //        doNotRunWS = true;
    //    }
        
    //    map <id,Account> mapBodyshop  = new map <id,Account>{assRecord.BodyShop__c => New account( Id = assRecord.BodyShop__c,
    //                                                                                               Name = assRecord.BodyShop__r.Name,
    //                                                                                               VATNumber__c = assRecord.BodyShop__r.VATNumber__c,
    //                                                                                               ReferenceNumber__c = assRecord.BodyShop__r.ReferenceNumber__c
    //                                                                                               )
    //                                                        };
       
        
    //    system.debug('## mapBodyshop ' + mapBodyshop);

    //    system.debug('## doNotRunWS:'+doNotRunWS);

    //    //get cross reference info in order to send IAM Manufacturer for ascr only
    //    map <id,CrossReference__c> mapPartIdCrossRef                     = new map <id,CrossReference__c>();

    //    //get cross reference info in order to send IAM PartNumber for ascr only
    //    map <id,CrossReference__c> mapPartIdCrossRefForPN                = new map <id,CrossReference__c>();

    //    //AMI 01/12/17 : Get DistributorPartNumber__c from distributor price for ascr only
    //    map <string,string> mapCombiDistIdPartIdAndDistPNumber           = new map <string,string>();

    //    map<id, set<Id>> mapPartIdDistributorPrice                       = new map<id, set<Id>>(); 

    //    //AMI 04/01/18 : C-002150 - Appel STOCK SAS avec 2 fois la même pièce
    //    //             : build map cross ref id and list of associated parts
    //    //             : this is because same parts can be present more than once
    //    map<Id, set <Id>> mapCrossRefPart                                = new map<Id, set <Id>>(); 

    //    //RLa 26/03/18 : to store the brand name from custom metadata type of vehicle
    //    String brandName;

    //    String distBrand;

    //    //build mapRTNameRTId
    //     for(RecordType rType : [SELECT Id, DeveloperName 
    //                        FROM    RecordType 
    //                        WHERE   SobjectType =: Label.SOBJECTPARTLIST]){
    //        if(rType.DeveloperName == 'Material'){
    //            recordTypeIdMaterial = rType.Id;
    //            break;
    //        }
    //    }

    //    BodyShop BodyShop ;
    //    Vehicle Vehicle ;
    //    mainRequest mainRequest ; 

    //    system.debug('## partMap ' + partMap);


        
    //    system.debug('## mapCrossRefPart:'+mapCrossRefPart);
    //    system.debug('## mapPartIdCrossRef: ' + mapPartIdCrossRef);
    //    system.debug('## mapPartIdCrossRefForPN: ' + mapPartIdCrossRefForPN); 

    //    system.debug('## mapPartIdDistributorPrice: ' + mapPartIdDistributorPrice);
    //    system.debug('## mapCombiDistIdPartIdAndDistPNumber: ' + mapCombiDistIdPartIdAndDistPNumber); 
        
    //    //populating distributorObj
    //    for(id accId : distributorMap.keySet()){
    //        //build setDistributorName
    //        //used during po creation
    //        //
    //        //AMI 05/12/17 : Fetch Tech_Distributor__c instead of distributor name
    //        setDistributorName.add(distributorMap.get(accId).Tech_Distributor__c);
            
    //        //AMI 05/12/17 : add Tech_Distributor__c as key instead of distributor name
    //        mapDistributorNameDistributor.put(distributorMap.get(accId).Tech_Distributor__c, distributorMap.get(accId));

    //        //build parts to be asscoiated with each distributor
    //        list <Parts> tempSuppliedParts                               = new list <Parts>(); 

    //        //build categories associated with each distributor
    //        set <string> setCategory                                     = new set <string>();

    //        if(distributorMap.get(accId).Categories__c != null){
    //            setCategory                                              = new set <string>(new list <string>(distributorMap.get(accId).Categories__c.split(';')));
    //        }//end if distributorMap.get(accId).Categories__c != null
            
    //        //set<Id> setPartIdDistributorPrice = mapPartIdDistributorPrice.get(accId); 

    //        for(String prtId : partMap.keyset()){
    //            PartList__c prt = partMap.get(prtId);
    //            Boolean makeSupplied = (distributorMap.get(accId).DistributorCarBrandSupplied__c != null && distributorMap.get(accId).DistributorCarBrandSupplied__c.contains(assRecord.Manufacturer__c));
    //            if(prt.RecordTypeId == recordTypeIdMaterial && prt.Quantity__c > 0  ){

    //                //AMI 01/12/17 : build key which will be used to fetch distributor part number for ascr
    //                string combiKey                                      = accId + '-' + prtId;

    //                distBrand = distributorMap.get(accId).Tech_Distributor__c;

    //                //RLA 23/03/18  Case-002380 CarMapping for SearchDistributor
    //                String manufacturer = (prt.CrossReferenceId__c != null) ? (prt.CrossReferenceId__r.IAMManufacturer__c != null ? prt.CrossReferenceId__r.IAMManufacturer__c : assRecord.Manufacturer__c) : (string.isNotBlank(prt.ProducerName__c) ?  prt.ProducerName__c : assRecord.Manufacturer__c);
                    

    //                //manufacturer = (distBrand + '-'+assRecord.Manufacturer__c).toUpperCase();  

    //                system.debug('@@ manufacturer:'+manufacturer);
                    
    //                String manufacturerFinal = RestDistributorUtility.getCarMappingsMatrix((distBrand + '-' +manufacturer).toUpperCase());
    //                system.debug('@@ manufacturerFinal:'+manufacturerFinal);

    //                if (String.isBlank(manufacturerFinal)){
    //                    manufacturerFinal = manufacturer;   
    //                }
    //                system.debug('@@ manufacturerFinal2:'+manufacturerFinal);


    //                /*ASE : 18/04/18 C-002477*/
    //                String partNumber = (prt.DistributorPriceId__c != null) ? prt.DistributorPriceId__r.DistributorPartNumber__c : ( prt.CrossReferenceId__c !=null ? (prt.CrossReferenceId__r.OEMPartNumber__c) : prt.PartNumber__c);
    //                //AMI 01/12/17 : fetch distributor part number for ascr
    //                if(setCategory.size() > 0){
    //                    if((setCategory.contains(prt.Type__c) && makeSupplied) || (!setCategory.contains(prt.Type__c) &&  prt.DistributorPriceId__c != null) ){
    //                        tempSuppliedParts.add(new Parts(integer.valueOf(prt.Quantity__c),
    //                                                        'false',
    //                                                        string.valueOf(prt.Id),
    //                                                        /*ASE : 18/04/18 C-002477*/
    //                                                        (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: partNumber,
    //                                                        prt.Type__c,
    //                                                        manufacturerFinal,
    //                                                        prt.Description__c));  
    //                    }
    //                }else{
    //                    //can supply all parts
    //                    tempSuppliedParts.add(new Parts(integer.valueOf(prt.Quantity__c),
    //                                                    'false',
    //                                                    string.valueOf(prt.Id),
    //                                                    /*ASE : 18/04/18 C-002477*/
    //                                                    (partNumber.startsWith('ASP-')) ? partNumber.split('ASP-')[1]: partNumber,
    //                                                    prt.Type__c,
    //                                                    manufacturerFinal,
    //                                                    prt.Description__c));     
    //                }
    //                system.debug('## tempSuppliedParts:'+tempSuppliedParts);

    //            }
    //        }//end looping in partlist

    //        //build distributorObj
    //        //AMI 05/12/17 : add Tech_Distributor__c instead of distributor name
    //        distributorObj.put(distributorMap.get(accId).Tech_Distributor__c,new distributor('',tempSuppliedParts));
            
    //    }//end looping in account
    //    system.debug('## distributorMap:'+distributorMap);
    //    system.debug('## mapDistributorNameDistributor:'+mapDistributorNameDistributor);

    //    //build bodyshop
    //    if(mapBodyshop.size() > 0){
    //        BodyShop                                                     = new BodyShop(
    //            mapBodyshop.get(assRecord.BodyShop__c).Name,
    //            string.isNotBlank(mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c) ? mapBodyshop.get(assRecord.BodyShop__c).ReferenceNumber__c : '',
    //            string.isNotBlank(mapBodyshop.get(assRecord.BodyShop__c).VATNumber__c) ? mapBodyshop.get(assRecord.BodyShop__c).VATNumber__c : '');
    //    }//end if mapBodyshop.size() > 0
    //    else{
    //        BodyShop                                                     = new BodyShop('','','');
    //    }

    //    //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
    //    distBrand += ('-'+assRecord.Manufacturer__c).toUpperCase(); 
    //    brandName = getCarMappingsMatrix(distBrand);
    //    system.debug('@@@ brandName:'+brandName);

    //    if ( String.isBlank(brandName)){
    //        brandName =  string.isNotBlank(assRecord.Manufacturer__c) ? assRecord.Manufacturer__c : '';   
        
    //    }
    //    system.debug('@@@ brandName2:'+brandName);


    //    ////build vehicle
    //    Vehicle  = new Vehicle(
    //        brandName,
    //        string.isNotBlank(assRecord.ModelV2__c) ? assRecord.ModelV2__c : '',
    //        assRecord.FirstRegistrationDate__c != null ? string.valueOf(assRecord.FirstRegistrationDate__c) : '',
    //        string.isNotBlank(assRecord.PlateNumber2__c) ? assRecord.PlateNumber2__c : '',
    //        string.isNotBlank(assRecord.VINNumber__c) ? assRecord.VINNumber__c : '',
    //        null);

    //    //build main request
    //    mainRequest                                                      = new mainRequest(
    //        string.isNotBlank(assRecord.ClaimReference__c) ? assRecord.ClaimReference__c : '',
    //        false,
    //        'Draft',
    //        '',
    //        (object)distributorObj,
    //        BodyShop,
    //        Vehicle);

    //    //serialise request while eliminating null param
    //    req                                                              = Json.serialize(mainRequest,true);
        
    //    system.debug('## req ' + req);
    //    system.debug('## End buildDistributorRequest');

    //    return req;
    //}


    //method used to process response
    public static string processResponse(Assessment__c assRecord, 
                                            set <string> setDistributorName,
                                            list <Account> distributorLst,
                                            string receivedResponse,
                                            string errorReported,
                                            string statusCode,
                                            map<Id, PartList__c> partMap,
                                            map <string,PurchaseOrder__c> mapExistingPOUpsertKeyPO){
        system.debug('## Start processResponse : '+receivedResponse);  

        //get orderline upsert status
        string orderLineStatus                                           = '';    

        //deserailse response to get Message
        map <string,object> deserialisedResponseMap                      = new map <string,object>();
        
        //build map distributor name distributor wrapper
        map <string,dist> deserialiseDist;

        //map to return successfull PO creation key alongside with ID / map<POkey, POId>
        map <string,PurchaseOrder__c> mapSuccessfullPOUpsertKeyPO        = new map <string,PurchaseOrder__c>();

        //this map is used for order lines creation for non connected distributors
        map <id,list <PurchaseOrder__c>> mapAssessmentPurchaseOrders     = new map <id,list <PurchaseOrder__c>>();

        //set use to store account id of distributors returned in json response
        set <id> setDistIdWithDistInfo                                   = new set <id>();

        //this set is used for order lines creation for non connected distributors
        set <id> distributorIdSet                                        = new set <id>();
        
        //this boolean prevent further ol creation
        boolean doNotCreateOL                                            = false;

        if(string.isNotBlank(receivedResponse)){
            //deserialise to get lines info
            deserialiseDist                                              = deserialiseRespIntoDistributors(receivedResponse);

            //build deserialisedResponseMap to get message
            deserialisedResponseMap                                      = (map <string,object>)JSON.deserializeUntyped(receivedResponse);
        }
        system.debug('## deserialisedResponseMap ' + deserialisedResponseMap);

        if(string.isNotBlank((string)deserialisedResponseMap.get('Message'))){
            receivedResponse                                             = '';
            errorReported                                                = (string)deserialisedResponseMap.get('Message');
            statusCode                                                   = '400';
        }

        //loop in original connected distributors returned
        for(string distName : setDistributorName){
            if(deserialiseDist != null){
                //check against received distributor
                if(deserialiseDist.containsKey(distName)){
                    //create PO with distributor info
                    setDistIdWithDistInfo.add(mapDistributorNameDistributor.get(distName).Id);
                }
            }
        }//end looping in setDistributorName 

        system.debug('## errorReported : ' + errorReported); 
        system.debug('## statusCode : '+ statusCode);
        //create PO
        //this part is used when ws is recalled from button
        if(mapExistingPOUpsertKeyPO.size() > 0){
            //if error received when button is clicked, update exisiting PO with errors reported
            if(statusCode != '200'){
                //update PO if ws call could not be made
                list <PurchaseOrder__c> lstPOToUpdate                       = new list <PurchaseOrder__c>();

                //returned wrapper after po finishes update
                list <ASPISCreatePOOrderLines.responseToGenerate> OLUpsertResp = new list <ASPISCreatePOOrderLines.responseToGenerate>();

                for(PurchaseOrder__c PO : mapExistingPOUpsertKeyPO.values()){
                    PurchaseOrder__c tempPO                                 = PO;
                    tempPO.wsDate__c                                        = system.now();
                    tempPO.wsErrorMessage__c                                = string.isNotBlank(errorReported) ? ((errorReported.length() > 1000) ? system.label.DistributorWSNoInfo : errorReported)  : system.label.DistributorWSNoInfo;
                    
                    //add to update list
                    lstPOToUpdate.add(tempPO); 

                    //add to wrapper list
                    OLUpsertResp.add(new ASPISCreatePOOrderLines.responseToGenerate('Update', 
                                                                                    PO.Tech_ExternalId__c,
                                                                                    PO.Id, 
                                                                                    false, 
                                                                                    POisUpdate ? 'DRAFT': null, 
                                                                                    string.isNotBlank(errorReported) ? ((errorReported.length() > 1000) ? system.label.DistributorWSNoInfo : errorReported)  : system.label.DistributorWSNoInfo)); 
                }

                if(!lstPOToUpdate.isEmpty()){
                    update lstPOToUpdate;
                }

                if(!OLUpsertResp.isEmpty()){
                    return Json.serialize(OLUpsertResp);  
                }
            }else{
                //if no error,continue with OL generation but without creating PO again
                mapSuccessfullPOUpsertKeyPO                              = new map <string,PurchaseOrder__c>(mapExistingPOUpsertKeyPO);
            }
        }else{
            //this statuscode indicates that no call out has been effected since distributor is not connected
            //thus create PO normally without updating ws technical fields
            //this part executes for newly created assessment only
            if(statusCode == 'X'){
                mapSuccessfullPOUpsertKeyPO                              = ASPISPurchaseOrder.createOrders(assRecord,
                                                                                                            distributorLst,
                                                                                                            '',
                                                                                                            null,
                                                                                                            setDistIdWithDistInfo,
                                                                                                            distributorMap);
                
                //generate order lines creation 
                //do proceed with order lines creation further below which applies for connected distributors
                //loop in created PO and check ones where wsDate and wsErrorMessage is empty
                if(!mapSuccessfullPOUpsertKeyPO.isEmpty()){
                    for(PurchaseOrder__c PO : mapSuccessfullPOUpsertKeyPO.values()){
                        if(mapAssessmentPurchaseOrders.containsKey(PO.Assessment__c)){
                            mapAssessmentPurchaseOrders.get(PO.Assessment__c).add(PO);
                        }else{
                            mapAssessmentPurchaseOrders.put(PO.Assessment__c, new list <PurchaseOrder__c>{PO});
                        }

                        distributorIdSet.add(PO.Distributor__c);
                    }//end loop in po created
                }//end if !mapSuccessfullPOUpsertKeyPO.isEmpty()

                system.debug('## mapAssessmentPurchaseOrders ' + mapAssessmentPurchaseOrders);
                system.debug('## distributorIdSet ' + distributorIdSet);
                if(mapAssessmentPurchaseOrders.size() > 0 && distributorIdSet.size() > 0){
                    //execute ol creation
                    PurchaseOrderTriggerHandler poHandler                = new PurchaseOrderTriggerHandler();
                    poHandler.createOrderLines(mapAssessmentPurchaseOrders,distributorIdSet);

                    doNotCreateOL                                        = true;
                }//end if mapAssessmentPurchaseOrders.size() > 0 && distributorIdSet.size() > 0

            }else{
                mapSuccessfullPOUpsertKeyPO                              = ASPISPurchaseOrder.createOrders(assRecord,
                                                                                                            distributorLst,
                                                                                                            errorReported,
                                                                                                            system.now(),
                                                                                                            setDistIdWithDistInfo,
                                                                                                            distributorMap);
               
                //generate order lines creation for non connected PO and for connected PO having error reported on ws
                //proceed with ol generation for connected po further below
                //loop in created PO and check ones where wsDate and wsErrorMessage is empty
                if(!mapSuccessfullPOUpsertKeyPO.isEmpty()){
                    for(PurchaseOrder__c PO : mapSuccessfullPOUpsertKeyPO.values()){
                        if((PO.wsDate__c == null && string.isBlank(PO.wsErrorMessage__c)) || PO.wsDate__c != null && string.isNotBlank(PO.wsErrorMessage__c)){
                            if(mapAssessmentPurchaseOrders.containsKey(PO.Assessment__c)){
                                mapAssessmentPurchaseOrders.get(PO.Assessment__c).add(PO);
                            }else{
                                mapAssessmentPurchaseOrders.put(PO.Assessment__c, new list <PurchaseOrder__c>{PO});
                            }

                            distributorIdSet.add(PO.Distributor__c);
                        }
                    }//end loop in po created
                }//end if !mapSuccessfullPOUpsertKeyPO.isEmpty()

                system.debug('## mapAssessmentPurchaseOrders ' + mapAssessmentPurchaseOrders);
                system.debug('## distributorIdSet ' + distributorIdSet);
                if(mapAssessmentPurchaseOrders.size() > 0 && distributorIdSet.size() > 0){
                    system.debug('## execute ol creation');
                    //execute ol creation
                    PurchaseOrderTriggerHandler poHandler                = new PurchaseOrderTriggerHandler();
                    poHandler.createOrderLines(mapAssessmentPurchaseOrders,distributorIdSet);
                }//end if mapAssessmentPurchaseOrders.size() > 0 && distributorIdSet.size() > 0
            }  
        }
        system.debug('## mapSuccessfullPOUpsertKeyPO:'+mapSuccessfullPOUpsertKeyPO); 

        if(mapSuccessfullPOUpsertKeyPO.size() > 0){
            if(deserialiseDist != null && !doNotCreateOL){
                orderLineStatus  = ASPISCreatePOOrderLines.ASPISCreatePOOrderLines(
                    deserialiseDist,                                                                                           
                    assRecord.Id, 
                    mapDistributorNameDistributor, 
                    mapSuccessfullPOUpsertKeyPO,
                    partMap, 
                    POisUpdate ? 'DRAFT': null, 
                    false);
            }
        }

        system.debug('## End processResponse');
        return orderLineStatus;
    }

    public static map <string,RestDistributorUtility.dist> deserialiseRespIntoDistributors(string receivedResponse){
        system.debug('## Start deserialiseRespIntoDistributors');

        //deserialise received response
        map <string,object> deserialiseJSONResp                          = (map <string,object>)JSON.deserializeUntyped(receivedResponse);
        system.debug('## deserialiseJSONResp : '+deserialiseJSONResp);

        //deserialise received distributor
        map <string,object> mapDistributor                               = (map <string,object>)deserialiseJSONResp.get('Distributors');
        system.debug('## mapDistributor ' + mapDistributor);

        //serialised again so that we can get map with distributor and dist wrapper
        string serialiseDistributor                                      = JSON.serialize(mapDistributor);                                 
        system.debug('## serialiseDistributor ' + serialiseDistributor);

        //build map distributor name distributor wrapper       
        map <string,dist> deserialiseDist                               = (map <string,dist>)JSON.deserialize(serialiseDistributor, map <string,dist>.class);
        system.debug('## deserialiseDist:' +deserialiseDist);
        system.debug('## End deserialiseRespIntoDistributors');
        return deserialiseDist;       
    }

    //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
    public static String getCarMappingsMatrix(string distBrand){
        
        String carOrigin = '';
        // System.debug('@@ distBrand :' + distBrand);


        List<CarMappings__mdt> carmapping = [SELECT CarDestination__c,carOrigin__c,DeveloperName,Label,MasterLabel FROM CarMappings__mdt where MasterLabel =: distBrand];     

        if (carmapping.size() > 0){
            carOrigin = carmapping[0].CarDestination__c;
        }  

        // System.debug('@@ carOrigin :' + carOrigin);
        return carOrigin;
    } 

    //RLA 24/10/2018 C-002776 : Optimisation of RestUpsertAssessmentV2
    public static Map<String, String> getCarMappingsMatrixV3(Set<String> setDistBrands){
        Map<String, String> mapLabelCarDestination = new Map<String, String>();

        For (CarMappings__mdt carmapping: [SELECT CarDestination__c,carOrigin__c,DeveloperName,Label,MasterLabel FROM CarMappings__mdt where MasterLabel in :setDistBrands ] ){
            mapLabelCarDestination.put(carmapping.MasterLabel, CarMapping.CarDestination__c);
        }

        return mapLabelCarDestination;

    } 

    //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
    public static Map<String, String> getCarMappingsMatrixV2(){
        Map<String, String> mapLabelCarDestination = new Map<String, String>();

        For (CarMappings__mdt carmapping: [SELECT CarDestination__c,carOrigin__c,DeveloperName,Label,MasterLabel FROM CarMappings__mdt ] ){
            mapLabelCarDestination.put(carmapping.MasterLabel, CarMapping.CarDestination__c);
        }

        return mapLabelCarDestination;

    } 


    //RLA 12/06/2018 Case-2603 Allow a hard coded value for testing Coler Integration
    public static boolean isColer(String referenceNumber){
        // system.debug('$$$$$$ techDist:'+techDist);
        // set<String> setDistName =  new Set<String>((system.label.DistributorsConnectedUseRebate).split(';'));
        
        // if ((setDistName.contains(techDist))){
        // // if (techDist == 'COLER' || techDist == 'LACK' || techDist == 'NORA'){
        //     return true;
        // }
        // else{
        //     return false;
        // }
        //RLA 15/09/2020 C-003940: Check on Bodyshop Reference number to send to Distributor
        if (string.isNotBlank(referenceNumber) && referenceNumber.endswith('!!')){
        // if (techDist == 'COLER' || techDist == 'LACK' || techDist == 'NORA'){
            return true;
        }
        else{
            return false;
        }
    }

    //RLA 15/06/2020  C-003773: IG - New Custom Setting: CustomerInformationMapping
    public static CustomerInformationsMapping__mdt getcustomerMapping(String countryCallersystem){
        // system.debug('$$$$$$ countryCallersystem:'+countryCallersystem);
        list<CustomerInformationsMapping__mdt> listCustomerInformationsMapping = new list<CustomerInformationsMapping__mdt>();
       
        if (String.isNotBlank(countryCallersystem)){
            For (CustomerInformationsMapping__mdt customerMapping: [SELECT AllowBodyshopEmails__c,AllowDistributorEmails__c,DeveloperName,Customer_ID__c,Optimize_DQC__c, 
                                                                            Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName,ConnectedOEMPrefix__c,Activate_Connected_OEM__c 
                                                                    FROM CustomerInformationsMapping__mdt
                                                                    where MasterLabel = :countryCallersystem  ] ){
                listCustomerInformationsMapping.add(customerMapping);
            }

            if (listCustomerInformationsMapping.size() > 0){
                return listCustomerInformationsMapping[0];
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }
     //RLA 09/07/2020 C-003857: IG - Creation IGO 
    public static map <string,object> createIGO(map <string,object> inputParam){

        RestUpsertAssessmentV2.Line ln;

        if (inputParam.containsKey('line')){
             ln = (RestUpsertAssessmentV2.Line)inputParam.get('line');
        }
        else if (inputParam.containsKey('lineStr')){
            //string linestr = (String)inputParam.get('lineStr');
            //system.debug('@@ linestr before:'+linestr);
            //linestr = linestr.replace('[','{');
            //linestr = linestr.replace(']','}');
            //linestr = JSON.stringify(linestr);
             //system.debug('@@ linestr:'+linestr);
             RestDistributorUtility.Lines laaa = (RestDistributorUtility.Lines)inputParam.get('lineStr');
             string linestr = JSON.Serialize(laaa);

            ln = (RestUpsertAssessmentV2.Line) JSON.deserialize(linestr, RestUpsertAssessmentV2.Line.class);
        }

        // RestUpsertAssessmentV2.Line ln = inputParam.containsKey('line') ? (RestUpsertAssessmentV2.Line)inputParam.get('line') : null;

        string description;

        map <string, PartList__c> mapTechOriginalPartKeyCorrespondingPart = inputParam.containsKey('mapTechOriginalPartKeyCorrespondingPart') ? (map <string, PartList__c>)inputParam.get('mapTechOriginalPartKeyCorrespondingPart') : new map <string, PartList__c> ();

        map <string,Account> mapEligiblePONameELigiblePO = inputParam.containsKey('mapEligiblePONameELigiblePO') ? (map <string,Account>)inputParam.get('mapEligiblePONameELigiblePO') : new map <string,Account> ();

		Boolean isIG = inputParam.containsKey('isIG') ? (Boolean)inputParam.get('isIG') :false;

        String receivedStatus = inputParam.containsKey('receivedStatus') ? (String)inputParam.get('receivedStatus') : '';

        String distName = inputParam.containsKey('distName') ? (String)inputParam.get('distName') : '';

        String assessId = inputParam.containsKey('assessId') ? (String)inputParam.get('assessId') : '';

        String insuranceBroker = inputParam.containsKey('insuranceBroker') ? (String)inputParam.get('insuranceBroker') : '';
        String brand = inputParam.containsKey('brand') ? (String)inputParam.get('brand') : '';

        Boolean notFromRestUpsert = inputParam.containsKey('notFromRestUpsert') ? (Boolean)inputParam.get('notFromRestUpsert') :false;

       
        map<String,CountryCodeInformationsMapping__c> mapConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

        String prefixPartNumber = getConnectedSubPrefix (insuranceBroker);

        if (notFromRestUpsert){
             if(string.isNotBlank(brand)){
                if (isIG){
                    description =ln.Description + ' - ' + brand + ' -Original (' + ln.PartNumber + ')';

                }
                else{
                    description = ln.Description + ' - ' + brand + ' (' + ln.PartNumber + ') - ' + system.label.ASPDesc;
                }
            }else{
                if (isIG){
                    description = ln.Description + ' -Original ' + '(' + ln.PartNumber + ')';
                }
                else{
                    description = ln.Description + ' - ' + '(' + ln.PartNumber + ') - '+ system.label.ASPDesc;

                }
            }

        }
        //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
        else if(mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID)){
            if(string.isNotBlank(ln.Brand)){
                if (isIG){
                    description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' - ' + ln.Brand + ' -Original (' + ln.PartNumber + ')';

                }
                else{
                    description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' - ' + ln.Brand + ' (' + ln.PartNumber + ') - ' + system.label.ASPDesc;
                }
            }else{
                if (isIG){
                    description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' -Original ' + '(' + ln.PartNumber + ')';
                }
                else{
                    description = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Description__c + ' - ' + '(' + ln.PartNumber + ') - '+ system.label.ASPDesc;

                }
            }
           
        } 

        string substitutePartNumber = isIG ? prefixPartNumber + ln.PartNumber : 'ASP-' + ln.PartNumber;
        String techTypeOfSubsPartNumber = 'ASP-' + ln.PartNumber;

        //AMI 14/02/18 - C-002041 - Distributor V2 - adding cleanse reference key to techoriginalpart since if asp was selected in second call, 
        //                                         - isSelected checkbox was not updated 
        string substituteKey = ln.ID + '-' +  substitutePartNumber.replaceAll( '\\s+', '');

        map <string,object> inputParamCalc = new map <string,object>();

        // inputParam.put('discount', discountToUse);
                
        inputParamCalc.put('CatalogPrice',ln.CatalogPrice);
        inputParamCalc.put('AlphaScaleDiscount',ln.AlphaScaleDiscount);

        //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
        inputParamCalc.put('isIG', isIG);

         map <string,object> updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPricesOEMConnected(inputParamCalc);
                    

        decimal ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;
        decimal asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;
        decimal aspStdDiscount = updatedPricing.containsKey('aspStdDiscount') ? (decimal)updatedPricing.get('aspStdDiscount') : 0.0;
        decimal aspStdMargin = updatedPricing.containsKey('aspStdMargin') ? (decimal)updatedPricing.get('aspStdMargin') : 0.0;

                
        map<String, object> returnMap = new map<String, object>();
        system.debug('@@ igo distributor name: '+ distName);
        system.debug('@@ mapEligiblePONameELigiblePO: '+ mapEligiblePONameELigiblePO);

        PartList__c tempPart = new PartList__c(TECH_OriginalPart__c = substituteKey,
                                                Name = description.left(80),
                                                ProducerName__c = ln.Manufacturer,
                                                Quantity__c = integer.valueOf(ln.Quantity),
                                                Type__c = ln.Type,
                                                Stock__c = receivedStatus,

                                                //AMI 15/02/18 - C-002041 - Distributor V2 - Removing 'ASP' in part number 
                                                //ASE 17/04/18 C-002477: PartNumber__c = ln.PartNumber.replaceAll( '\\s+', ''),
                                                PartNumber__c = substitutePartNumber.replaceAll( '\\s+', ''),
                                                Description__c = description,
                                                Price__c = asPublicPrice.setScale(2), 
                                                // Assessment__r = new Assessment__c(AssessmentID__c = assessId),
                                                // OriginalPart__r = new PartList__c(TECH_OriginalPart__c = ln.ID),                                               
                                                ASNetPrice__c = ASNETPRICE.setScale(2),
                                                Alpha_Scale_MRID__c = substitutePartNumber.replaceAll( '\\s+', ''),

                                                //AMI 19/12/17 : Adding Discount and margin to A' Parts
                                                //**** ASE: 28/05/2018-C-002041changes in calculations*/
                                                //StandardDiscount__c = ln.BodyShopDiscount != null ? ln.BodyShopDiscount.setScale(2) : 0.0,
                                                //StandardMargin__c = ln.BodyShopDiscount != null && ln.BodyShopDiscount > 0 ? (price * (ln.BodyShopDiscount/100)).setScale(2) : 0.0,

                                                StandardDiscount__c = aspStdDiscount,
                                                StandardMargin__c = aspStdMargin,

                                                /****/ 

                                                //AMI 22/02/18 : C-002041 - Distributor V2 - Adding missing field to ASP Response
                                                InputType__c = mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID) ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).InputType__c : '',
                                                Currency__c = mapTechOriginalPartKeyCorrespondingPart.containsKey(ln.ID) ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Currency__c : ''
                                                //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
                                                ,VAT__c = (assessId != null && mapConfigCountryCodeInfo.get(assessId.left(2)) != null && mapConfigCountryCodeInfo.get(assessId.left(2)).CountryVAT__c != null) ? mapConfigCountryCodeInfo.get(assessId.left(2)).CountryVAT__c : null
                                                ,Distributor__c= mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null
                                                ,TECHDistList__c = mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null
                                                //RLA 03/04/2019 C-3133 
                                                ,NextDistributors__c = mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).NextDistributors__c !=null ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).NextDistributors__c : null
                                                ,Distributors__c = isIG ? mapEligiblePONameELigiblePO.containsKey(distName) ? mapEligiblePONameELigiblePO.get(distName).Id : null : mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Distributors__c != null ? mapTechOriginalPartKeyCorrespondingPart.get(ln.ID).Distributors__c : null,
                                                //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
                                                techTypeOfSubsPartNumber__c = techTypeOfSubsPartNumber
                                                );

        if (notFromRestUpsert){
            // tempPart.Assessment__r = null;
            // tempPart.OriginalPart__r = null;

            tempPart.Assessment__c = assessId;
            // tempPart.OriginalPart__c = ln.ID;
            tempPart.TECH_OriginalPart__c = mapTechOriginalPartKeyCorrespondingPart.get(ln.Id).TECH_OriginalPart__c;
            tempPart.TechCheckForSubstitute__c = false;

            tempPart.recalculateFormulas();

        }
        else{
            tempPart.Assessment__r = new Assessment__c(AssessmentID__c = assessId);
            tempPart.OriginalPart__r = new PartList__c(TECH_OriginalPart__c = ln.ID)  ;
        }
       
       system.debug('@@ tempPart'+tempPart);
       
        returnMap.put('partlist',tempPart);
       return returnMap;



    }

    public static string getConnectedSubPrefix (String insuranceBroker){

        CustomerInformationsMapping__mdt customerInformationsMapping;

        if (String.isnotblank(insuranceBroker)){
            customerInformationsMapping = RestDistributorUtility.getcustomerMapping(insuranceBroker);
        }

        String prefixPartNumber = customerInformationsMapping != null ? customerInformationsMapping.ConnectedOEMPrefix__c : '' ; 

        return prefixPartNumber;

    }

    public static string getOemPartNumber (String partNumber, String insuranceBroker, String prefixPartNumberIGO){

        // String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);

        if (partNumber.startsWith('ASP-')){
            return partNumber.split('ASP-')[1];
        }
        else if (partNumber.startsWith(system.label.desubstitureprefix)){
            return partNumber.split(system.label.desubstitureprefix)[1];
        }
        else if (String.isNotBlank(prefixPartNumberIGO)
                && partNumber.startsWith(prefixPartNumberIGO)){
            return partNumber.split(prefixPartNumberIGO)[1];
        }
        else if (partNumber.startsWith('ASCR-')){
            return partNumber.split('ASCR-')[1];
        }
        else{
            return partNumber;
        }

        
    }


    public static string typeOfSubstitute (String partNumber, String prefixPartNumberIGO){

        // String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);
        system.debug('@@@ partNumbers:'+partNumber);
        if (String.isnotblank(partNumber)){
            if (partNumber.startsWith('ASP-')  
                || partNumber.startsWith(system.label.desubstitureprefix)
                ){
                return 'ASP-' ;
            }
            else if (partNumber.startsWith('ASCR-')){
                return 'ASCR-';
            }
            else{
                return null;
            }
        }        
        else{
            return null;
        }

        
    }
    //WCH 17/08/2020 C-003578
    public static map<String,Object> isExpertAssessmentCorrect(map <string,object> inputParamForExpertAss){
        map <string,object> response = new map <string,object>();
        if(inputParamForExpertAss.get('ExpertAssessment')!=null){
            Assessment__c currentAssessment = (Assessment__c)inputParamForExpertAss.get('ExpertAssessment');
            if(currentAssessment.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId() 
            && currentAssessment.BodyShop__c != null
             //&& String.isNotBlank(currentAssessment.ClaimReference__c) Commented by RLA 16//11/2021 C-004481
              && currentAssessment.PlateNumber2__c != null 
             // && System.label.ExpertAssessmentClaimReferenceLastTwoDigits.contains(currentAssessment.ClaimReference__c.right(2))  Commented by RLA 16//11/2021 C-004481
              //&& currentAssessment.ClaimReference__c.length() == Integer.valueOf(System.label.ExpertAssessmentClaimReferenceLength)  Commented by RLA 16//11/2021 C-004481
              && !currentAssessment.isShoppingList__c){
                response.put('isExpertAssessmentCorrect',true);
            }else{
                response.put('isExpertAssessmentCorrect',false);
            }
        }else response.put('isExpertAssessmentCorrect',false);
        return response;
    }
    //WCH 07/08/2020 C-003864
    public static map<String,Object> getEndPoint(map <string,object> inputParamForEndPoint){
        map <string,object> response = new map <string,object>();
        if (inputParamForEndPoint.containsKey('EIP_EndPoint') && inputParamForEndPoint.get('EIP_EndPoint')!=null && (String)inputParamForEndPoint.get('EIP_EndPoint')=='authenticate'){
            response.put('EIP_EndPoint','callout:EIP/searchDistributorStores');
            //response.put('EIP_EndPoint',system.label.EIPEndPoint);
        }else if (inputParamForEndPoint.containsKey('NEVADA_EndPoint') && inputParamForEndPoint.get('NEVADA_EndPoint')!=null && (String)inputParamForEndPoint.get('NEVADA_EndPoint')=='authenticate'){
            response.put('NEVADA_EndPoint','callout:EIP/postAssessment');
            //response.put('NEVADA_EndPoint',system.label.URLNevada);
        }else if (inputParamForEndPoint.containsKey('ORDERCONFIRMATION_EndPoint') && inputParamForEndPoint.get('ORDERCONFIRMATION_EndPoint')!=null && (String)inputParamForEndPoint.get('ORDERCONFIRMATION_EndPoint')=='authenticate'){
            response.put('ORDERCONFIRMATION_EndPoint','callout:EIP/orderConfirmation');
        }
        else response.put('NONE','INVALID_ENDPOINT');
        return response;
    }

     //RLA 31/10/2020 C-004018: IG - Efa requirements
    public static string getBSExtId (String key){
        AccountRef__c accRef = AccountRef__c.getValues(key);
        String bsExtId = '';
        if (accRef != null){            
            bsExtId = accRef.ExternalReference__c;
        }
        return bsExtId;
    }

    //RLA 05/11/2020 C-004028 Add parts NOTFOUND in SAS recovery
    //return true if partnumber is found in fake references
    public static boolean isFakeRef (String partnumber){

        if (String.isnotblank(partNumber) && system.label.FakeReferences.contains(partNumber)){
            return true;
        }
        else{
            return false;
        }

    }

    //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
    public static boolean isConnectedDist (String parameters){

        if (String.isnotblank(parameters) && parameters.contains('Distributor Connected')){
            return true;
        }
        else{
            return false;
        }

    }

    //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
    public static boolean canMakeDraftCall (String parameters){

        if (String.isnotblank(parameters) && parameters.contains('Draft Call')){
            return true;
        }
        else{
            return false;
        }

    }

    //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
    public static boolean canMakeOrderCall (String parameters){

        if (String.isnotblank(parameters) && parameters.contains('Order Call')){
            return true;
        }
        else{
            return false;
        }

    }

    /**** request container ****/

    public class mainRequest{
        public string ClaimReference;
        public boolean AutomaticValidation;
        public string Request;
        public string AlphaScalePO;
        public Object Distributors;
        public BodyShop BodyShop;
        public Vehicle Vehicle;
        public string Message;

        public mainRequest(string ClaimReference, boolean AutomaticValidation, string Request, string AlphaScalePO, Object Distributors, BodyShop BodyShop, Vehicle Vehicle){
            this.ClaimReference                                          = ClaimReference;
            this.AutomaticValidation                                     = AutomaticValidation;
            this.Request                                                 = Request;
            this.AlphaScalePO                                            = AlphaScalePO;
            this.Distributors                                            = Distributors;
            this.BodyShop                                                = BodyShop;
            this.Vehicle                                                 = Vehicle;
        }
    }

    public class distributor{
        public string ExternalOrderReference;
        public Boolean AgencyMode;
        public Boolean Option1; //RLA 11/06/2020 C-003754: IG - Update Query Call for Coler
        // public Boolean Test;
        public list <Parts> Parts;
        public string BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements

        public distributor(string ExternalOrderReference, Boolean AgencyMode, Boolean Option1, list <Parts> Parts, string BSExternalReference){
        // public distributor(string ExternalOrderReference, Boolean AgencyMode, list <Parts> Parts){
            this.ExternalOrderReference                                  = ExternalOrderReference;
            this.AgencyMode                                              = AgencyMode;
            this.Option1                                                 = Option1;
            this.Parts                                                   = Parts;
            this.BSExternalReference                                     = BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements
        }
    }

    //KEM 17/01/projectPre
    public class distributorXref{
        public string ExternalOrderReference;
        public Boolean AgencyMode;
        public Boolean Option1; //RLA 11/06/2020 C-003754: IG - Update Query Call for Coler
        // public Boolean Test;
        public list <PartsConnectedE> lines;
        public string BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements

        public distributorXref(string ExternalOrderReference, Boolean AgencyMode, Boolean Option1, list <PartsConnectedE> lines, string BSExternalReference){
        // public distributor(string ExternalOrderReference, Boolean AgencyMode, list <Parts> Parts){
            this.ExternalOrderReference                                  = ExternalOrderReference;
            this.AgencyMode                                              = AgencyMode;
            this.Option1                                                 = Option1;
            this.lines                                                   = lines;
            this.BSExternalReference                                     = BSExternalReference;//RLA 31/10/2020 C-004018: IG - Efa requirements
        }
    }

    public class Parts{
        //used for request
        public decimal Quantity;
        public string AllowAlternatives;
        public string ID;
        public string PartNumber;
        public string Type;
        public string Manufacturer;
        public string Description;
        public string SequenceID;//RLA 31/10/2020 C-004018: IG - Efa requirements
        public string DistributorRef;

        //used for response
        public double CatalogPrice;
        public double AlphaScaleDiscount;
        public double AlphaScaleDiscountAdditional;
        public double BodyShopDiscount;
        public string Status;
        public string StatusMessage;

        public Parts(decimal Quantity, string AllowAlternatives, string ID, string PartNumber, string Type, string Manufacturer, string Description, string SequenceID){
            this.Quantity                                                = Quantity;
            this.AllowAlternatives                                       = AllowAlternatives;
            this.ID                                                      = ID;
            this.PartNumber                                              = PartNumber;
            this.Type                                                    = Type;
            this.Manufacturer                                            = Manufacturer;
            this.Description                                             = Description;
            //RLA 31/10/2020 C-004018: IG - Efa requirements
            this.SequenceID                                              = SequenceID;
        }
    }

    //KEM 17/01/projectPre
    public class PartsConnectedE{

        //used for request
        public string ID;
        public string DistributorRef;

        //used for response
        public string Status;

        public PartsConnectedE(string ID, string DistributorRef){
            this.ID                                                      = ID;
            this.DistributorRef                                          = DistributorRef;
        }
    }

    public class BodyShop{
        public string Name;
        public string ExternalReference;
        public string VATNumber;

        public BodyShop(string Name, string ExternalReference, string VATNumber){
            this.Name                                                    = Name;
            //this.ExternalReference                                       = '12345678901234';
            this.ExternalReference                                       = ExternalReference;
            this.VATNumber                                               = VATNumber;
        }
    }

    public class Vehicle{
        public string Brand;
        public string Model;
        public string FirstRegistrationDate;
        public string PlateNumber;
        public string VinNumber;
        public string BuildDate;

        public Vehicle(string Brand, string Model, string FirstRegistrationDate, string PlateNumber, string VinNumber, string BuildDate){
            this.Brand                                                   = Brand;
            this.Model                                                   = Model;
            this.FirstRegistrationDate                                   = FirstRegistrationDate;
            this.PlateNumber                                             = PlateNumber;
            this.VinNumber                                               = VinNumber;
            this.BuildDate                                               = BuildDate;
        }
    }

    /**** response container ****/

    public class dist{
        public string ExternalOrderReference;
        public string Message;
        public string Success;
        public string PurchaseOrderReference;
        public list <Lines> Lines;
        // ASE: 10/07/2018: C-002659 : Prices & Part Type to be sent to Coler  
        public string DistributorOrderReference;
    }

    public class Lines{
        public decimal Quantity;
        public string ID;
        //RBE 02/02/2023 C-004898: PREv2 Connected - Lot 3.4 - Order - Stock Call For Occurence
        public string DistributorReference;
        public string PartNumber;
        public string Type;
        public string Manufacturer;
        public string Description;
        public decimal CatalogPrice;
        public decimal AlphaScaleDiscount;
        public decimal AlphaScaleDiscountAdditional;
        public decimal BodyShopDiscount;
        public decimal DeliveryDays;
        public string Status;
        public string StatusMessage;
        public string Brand;//RLA 14/10/2020 IG Remplacements
        public boolean Bundle;
        public list <Parts> Parts;
        public list <Alternatives> Alternatives;
    }

    public class Alternatives{
        public string PartNumber;
        public string Description;
        public string Manufacturer;
        public decimal CatalogPrice;
        public decimal Quantity;
        public decimal AlphaScaleDiscount;
        public decimal AlphaScaleDiscountAdditional;
        public decimal BodyShopDiscount;
        public string Type;
        public string Status;
        public string StatusMessage;
    }
}