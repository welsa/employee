@RestResource(urlMapping='/v2.0/updatePurchaseOrder/*') 
global without sharing class ASPISUpdatePOOrderLines { 
/*************************************************************************************
Class Name - ASPISUpdatePOOrderLines
Version - 1.0
Created Date - 17 AUG 2015
Function - Class REST for the creation of an Assessment version 2

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Abdool M       17/08/2017     Initial Version
* Abdool M       16/02/2018     C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c to query 
*                                        - Saving MRID in OL generated 
* Ashwina S         28/05/2018   changes in calculations  
* Welsa C        08/04/2019  C-002854: Update des statusdes OL via UpdatePO
* Welsa C        27/09/2019  C-003413: Failed ASPISUpdatePOOrderLines class logs are marked as passed
* Welsa C        10/10/2019  C-003422: Apex Error on APManageLogs
* Welsa C        12/10/2020  C-004004: SAS UpdatePO calls fail
* Welsa C        08/03/2021  C-004230:Switch sur l ASPISUpdatePOOrderLines de SAS
*************************************************************************************/
    //WCH 27/09/2019 C-003413
    private static String purchaseOrderName = '';

    @HttpPost   
    global static void execute() {
        map<String,String> mapHeaders                                       = new map<String,String>();
        string results                                                      = '';
        
        RestRequest req                                                     = RestContext.request;

        //retrieve the headers that are received by the request. Synchronous / Asynchronous
        mapHeaders                                                          = req.headers;

        //convert the requestbody into a string
        String body                                                         = RestContext.request.requestBody.toString();

        //WCH 08/03/2021 C-004230
		List<ConfigurationFlux__mdt> getProperASPISUpdatePOOrderLinesConfigs = [select id,Runnable__c from ConfigurationFlux__mdt where DeveloperName='ASPISUpdatePOOrderLines'];

        //WCH 27/09/2019 C-003413
        APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
        wrapperLog.className = 'ASPISUpdatePOOrderLines';
        wrapperLog.jsonmessage = body != null && body.length() <= 30000 ? body : '';
        wrapperLog.sobjectName = 'PurchaseOrder__c';            
        wrapperLog.inout = 'Inbound';//WCH 10/10/2019 C-003422: Apex Error on APManageLogs
        if(body.length() > 30000){
            wrapperLog.attachmentRequestbody = body;
        }         
        Log__c log = APManageLogs.createWsLog(wrapperLog, 'insert');

        APManageLogs.LogsWrapper wrapperLogUpdate = new APManageLogs.LogsWrapper();
        wrapperLogUpdate.logId = log.Id;

        //get header type to determine context (sync or async)
        String cType                                                        = mapHeaders.containsKey(system.label.CALLTYPE) ?
                                                                                    mapHeaders.get(system.label.CALLTYPE) : '';
        //execute calling context
        if(cType == system.label.ASYNCHRONOUS){
            wrapperLogUpdate.CallType                                                 = system.label.ASYNCHRONOUS;
            // call @future method
            //updatePOAsync(log.Id,body);
            results                      = system.label.MSGASYNCTREATMENT + ' ' + log.Id;
        }else if(cType == system.label.SYNCHRONOUS || string.isBlank(cType)){
            wrapperLogUpdate.CallType                                                 = system.label.SYNCHRONOUS;
            //call synchronous method 
            //WCH 08/03/2021 C-004230
            if(getProperASPISUpdatePOOrderLinesConfigs.size()>0 && getProperASPISUpdatePOOrderLinesConfigs[0].Runnable__c){
                results = updateOrderLines(body);
            }else{
                results = system.label.FakePassedLogResponse;
            }
        }

        List<Object> lstResult = (List<Object>) JSON.deserializeUntyped(results);
        for (Object o: lstResult){
            Map<String, Object> mapResults = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
            if (mapResults.containsKey('Success')){
                if ( mapResults.get('Success') == true){
                    wrapperLogUpdate.Status  = system.label.STATUSPASSED;    
                }  
                else{
                    wrapperLogUpdate.Status  = system.label.STATUSFAILED;    
                    break;
                }  
            }
            else{
                //log status
                if(!results.contains(system.label.MSGASYNCTREATMENT)){ 
                    if(results.contains('Exceptions')){
                        wrapperLogUpdate.Status                                               = system.label.STATUSFAILED;
                    }
                    else{
                        wrapperLogUpdate.Status                                               = system.label.STATUSPASSED;
                    }
                }
                else{
                    wrapperLogUpdate.Status                                                 = system.label.STATUSPASSED;
                }
            }

        }
        

        //WCH 27/09/2019 C-003413
        wrapperLogUpdate.jsonresponse = results; 
        //WCH 10/10/2019 C-003422: Apex Error on APManageLogs
        //wrapperLogUpdate.objectreference = purchaseOrderName;
        APManageLogs.createWsLogFuture(JSON.serialize(wrapperLogUpdate), 'update');

        RestContext.response.responseBody                                   = Blob.valueOf(results);  
    }//end updateOrderLines

    public static String updateOrderLines(string requestBody){
        system.debug('## Start updateOrderLines ' + requestBody);

        string results                                                      = '';

        
        try{
            mainResponse deserilaiseResp                                        = (mainResponse)JSON.deserialize(requestBody, mainResponse.class);
            system.debug('## deserilaiseResp ' + deserilaiseResp);

            //this set will be used to query all PO from sf transmitted in request
            set <string> setPOTransmitted                                       = new set <string>();

            //set assessement id to get parts map
            set <id> setAssessId                                                = new set <id>();

            //all queried PO to build processPO wrapper
            map <string,PurchaseOrder__c> mapPONamePO                           = new map <string,PurchaseOrder__c>();

            //all queried PO distributor to build processPO wrapper
            map <string,Account> mapDistributor                                 = new map <string,Account>();

            //map partList
            map <id, PartList__c> partMap                                       = new map <id, PartList__c>();

            //this list will be used to update OrderLine
            list <processPO> processPOLst                                       = new list <processPO>();

            //this set will be used to update OrderLine
            set <ID> originalIdSet                                              = new set <ID> ();

            //**** ASE: 28/05/2018-C-002041changes in calculations*/
            set <ID> allOLSentIdset                                             = new set <ID> ();
            map <ID, OrderLine__c> allIdTechIdMap                               = new map <ID, OrderLine__c> ();

            //this set will be used to update OrderLine
            map <ID, OrderLine__c> originalIdTechIdMap                          = new map <ID, OrderLine__c> ();

            //variables used to save ol generated and response
            list <ASPISCreatePOOrderLines.responseToGenerate> respToGenerateList = new list <ASPISCreatePOOrderLines.responseToGenerate>();
            map <Id, list<OrderLine__c>> originalOLMap                          = new map <Id, list<OrderLine__c>>();
            map <Id, list<OrderLine__c>> alternativeOLMap                       = new map <Id, list<OrderLine__c>>();
            map <Id, list<OrderLine__c>> bundleItemOLMap                        = new map <Id, list<OrderLine__c>>();
            map <Id, list<OrderLine__c>> originalOLMapToBeUpd                   = new map <Id, list<OrderLine__c>>();
            map <Id, list<OrderLine__c>> alternativeOLMapToBeUpd                = new map <Id, list<OrderLine__c>>();
            map <Id, list<OrderLine__c>> bundleItemOLMapToBeUpd                 = new map <Id, list<OrderLine__c>>();
            map <Id, PurchaseOrder__c> updatedPOMap                             = new map <Id, PurchaseOrder__c>();
            map <string,PurchaseOrder__c> mapExistingPOUpsertKeyPO              = new map <string,PurchaseOrder__c>();
            set<Id> oriOLToDelSet = new  set<Id>();

            if(deserilaiseResp != null){
                //loop in deserialise response
                for(PurchaseOrder PO : deserilaiseResp.PurchaseOrders){
                    if(string.isNotBlank(PO.OrderReference)){
                        setPOTransmitted.add(PO.OrderReference.replaceAll( '\\s+', '')); 
                    }
                }//end looping in received response
            }//end if deserilaiseResp != null
            system.debug('## setPOTransmitted ' + setPOTransmitted);

            //build mapPONamePO, mapDistributor, setAssessId and mapExistingPOUpsertKeyPO
            for(PurchaseOrder__c PO : [select id,Name,Status__c,Assessment__c,Distributor__c,Distributor__r.Name,
                                                Distributor__r.PartTypeRegionDelayMatrix__c,Tech_ExternalId__c,
                                                Distributor__r.Rebate__c, Distributor__r.Tech_Distributor__c, Distributor__r.OrderRequest__c,Distributor__r.Type_of_Substitutes__c,Assessment__r.InsuranceBroker__c /*WCH 12/10/2020 C-004004*/
                                        from PurchaseOrder__c
                                        where Name IN :setPOTransmitted]){
                mapPONamePO.put(PO.Name,PO);
                //WCH 27/09/2019 C-003413
                purchaseOrderName += PO.Name+'; ';

                if(PO.Distributor__c != null){
                    mapDistributor.put(PO.Name,new Account(Id = PO.Distributor__c, Tech_Distributor__c = PO.Distributor__r.Tech_Distributor__c,
                                                            PartTypeRegionDelayMatrix__c = PO.Distributor__r.PartTypeRegionDelayMatrix__c,
                                                            OrderRequest__c = PO.Distributor__r.OrderRequest__c,
                                                            Type_of_Substitutes__c = PO.Distributor__r.Type_of_Substitutes__c/**IG */
                                                            ));
                }

                if(PO.Assessment__c != null){
                    setAssessId.add(PO.Assessment__c);
                }

                if(string.isNotBlank(PO.Tech_ExternalId__c)){
                    mapExistingPOUpsertKeyPO.put(PO.Tech_ExternalId__c,new PurchaseOrder__c(id = PO.Id,
                                                                                                Status__c = PO.Status__c));
                }
            }
            system.debug('## mapPONamePO ' + mapPONamePO);
            system.debug('## mapDistributor ' + mapDistributor);
            system.debug('## setAssessId ' + setAssessId);
            system.debug('## mapExistingPOUpsertKeyPO ' + mapExistingPOUpsertKeyPO);

            if(setAssessId.size() > 0){
                //AMI 16/02/18 : C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c to query 
                //                                         - Saving MRID in OL generated 
                partMap                                                         = new map <id, PartList__c>([select Id, PartNumber__c, 
                                                                                                                    Assessment__r.AssessmentNumber__c, 
                                                                                                                    Assessment__r.AssessmentID__c,
                                                                                                                    Quantity__c,Description__c,
                                                                                                                    Assessment__c,RecordTypeId, 
                                                                                                                    Compliance__c,Price__c,CrossReferenceId__c,Alpha_Scale_MRID__c,TechCatalog_Price_Dist_Connected__c
                                                                                                                from PartList__c
                                                                                                                where Assessment__c IN :setAssessId]);
            }//setAssessId.size() > 0
            system.debug('## partMap ' + partMap);

            //build processPO wrapper to lauch OL Update
            if(deserilaiseResp != null){
                //loop in deserialise response
                for(PurchaseOrder PO : deserilaiseResp.PurchaseOrders){
                    processPO tempPO                                            = new processPO();
                    tempPO.poLines                                              = PO.Lines;
                    tempPO.PO                                                   = (mapPONamePO.containsKey(PO.OrderReference)) ? 
                                                                                        mapPONamePO.get(PO.OrderReference) : new PurchaseOrder__c();
                    tempPO.distributorAcc                                       = (mapDistributor.containsKey(PO.OrderReference)) ? 
                                                                                        mapDistributor.get(PO.OrderReference) : new Account();
                    tempPO.partMap                                              = partMap;
                    tempPO.POStatus                                             = PO.status;
                    tempPO.DistributorOrderReference                            = PO.DistributorOrderReference;
                    for(RestDistributorUtility.Lines line: PO.Lines){
                        if(line.Bundle || (!line.Bundle && line.Parts != null && line.Parts.size() == 1)){
                            originalIdSet.add(line.ID);
                        }
                        /*********ASE : 28/05/2018 : changes in calculations*/
                        allOLSentIdset.add(line.ID);
                    }

                    processPOLst.add(tempPO);
                }//end looping in received response
            }//end if deserilaiseResp != null
            system.debug('## processPOLst ' + processPOLst);
            system.debug('## originalIdSet ' + originalIdSet);

            //**** ASE: 28/05/2018-C-002041changes in calculations*/
            allIdTechIdMap = new map <ID, OrderLine__c>([SELECT Id, TechExternalId__c, AssessmentPrice__c, Type__c, Manufacturer__c, Description__c, Quantity__c, PartNumber__c,
                                                                     ExpectedDeliveryDuration__c, CataloguePrice__c, AXADiscount__c, Rebate__c, BodyShopDiscount__c, PurchaseOrder__c,  AlphaScaleMRID__c
                                                                     ,SASStatus__c/*WCH 08/04/2019 C-002854 Update des statusdes OL via UpdatePO*/ 
                                                                     ,SubstituteType__c /* RLA 25/06/2020 C-003701 */
                                                              from OrderLine__c 
                                                              where id in: allOLSentIdset]);
            system.debug('## allIdTechIdMap ' + originalIdTechIdMap);


            for(Id olId : originalIdSet){
                if(allIdTechIdMap.containsKey(olId)){
                    originalIdTechIdMap.put(olId, allIdTechIdMap.get(olId));
                }
            }
            //generate OL
            if(processPOLst.size() > 0){
                for(processPO po : processPOLst){
                    //generate OL
                    ASPISCreatePOOrderLines.processPOOL(po.poLines, 
                                                        po.PO, 
                                                        po.distributorAcc, 
                                                        po.partMap, 
                                                        po.POStatus, 
                                                        respToGenerateList, 
                                                        originalOLMap, 
                                                        alternativeOLMap, 
                                                        bundleItemOLMap, 
                                                        originalOLMapToBeUpd, 
                                                        alternativeOLMapToBeUpd, 
                                                        bundleItemOLMapToBeUpd, 
                                                        updatedPOMap,
                                                        true,
                                                        originalIdTechIdMap,
                                                        PO.DistributorOrderReference,
                                                        oriOLToDelSet,
                                                        //**** ASE: 28/05/2018-C-002041changes in calculations*/
                                                        allIdTechIdMap);
                }//end looping in processPOLst
            }//end if processPOLst.size() > 0 

            //save ol and generate response
            if(originalOLMap.size() > 0 || updatedPOMap.size() > 0){
                ASPISCreatePOOrderLines.upsertAll(originalOLMap,
                                                    alternativeOLMap,
                                                    bundleItemOLMap,
                                                    originalOLMapToBeUpd,
                                                    alternativeOLMapToBeUpd,
                                                    bundleItemOLMapToBeUpd,
                                                    null,
                                                    updatedPOMap,
                                                    mapExistingPOUpsertKeyPO,
                                                    true,
                                                    respToGenerateList,
                                                    true,
                                                    oriOLToDelSet,
                                                    '');
            }
            system.debug('## End updateOrderLines');

            if(!respToGenerateList.isEmpty()){
                results = Json.serialize(respToGenerateList);  
            }else{
                results = system.label.UpdatePOFailedMsg; 
            }
        }
        catch(Exception ex){
            JSONGenerator genResults  = JSON.createGenerator(false);
            genResults.writeStartArray();
            genResults.writeStartObject();
                genResults.writeStringField('OperationType', 'Update');
                genResults.writeNullField('TechnicalId');
                genResults.writeNullField('FunctionalId');
                genResults.writeBooleanField('Success', false);
                genResults.writeNullField('Warning');
                genResults.writeStringField('ErrorMessage', 'Exceptions: ' + ex.getMessage());
            genResults.writeEndObject();
            genResults.writeEndArray(); 

            results = genResults.getAsString();
        }

        return results; 
    }

    public class mainResponse{
        public list <PurchaseOrder> PurchaseOrders;
    }

    //wrapper to deserialise json response received
    public class PurchaseOrder{
        public string ClaimReference;
        public string OrderReference;
        public string BodyShopOrderReference;
        public string DistributorOrderReference;
        public string status;
        public list <RestDistributorUtility.Lines> Lines;
    }

    //wrapper to process with ol creation
    public class processPO{
        public list <RestDistributorUtility.lines> poLines;
        public PurchaseOrder__c PO;
        public Account distributorAcc;
        public map <Id, PartList__c> partMap;
        public string POStatus;
        public String DistributorOrderReference;
    }
}