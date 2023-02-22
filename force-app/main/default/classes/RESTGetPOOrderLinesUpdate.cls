/*************************************************************************************
Class Name -  
Version - 1.0
Created Date - 16 DEC 2015
Function - Class REST for update PO OrderLines selected

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* --------------    ----------  -----------------------
* Ashwina Seetaram    16/12/2015    version 1
* Shamina M           18/02/2016    C-001518: Removed unnecessary debug logs
* Ashutosh B          22/09/2016    C-001728: Added the new function of create attachment
* Anthony B           21/10/2016    DEPRECATED, class changed by RESTUpdatePurchaseOrders => Class to delete
*************************************************************************************/
@RestResource(urlMapping='/v1.0/updatePOOrderLines/*')
global with sharing class RESTGetPOOrderLinesUpdate{
    /*
    @HttpPost   
    global static void updatePOOrderLines() {
        map<String,String> mapHeaders = new map<String,String>();
        string results = '';
        //retrieve the headers that are received by the request. Synchronous / Asynchronous
        RestRequest req = RestContext.request;
        mapHeaders = req.headers;
        //system.debug('////mapHeaders: '+mapHeaders);
        
        //convert the requestbody into a string3
        String body = RestContext.request.requestBody.toString();
        
        // create log instance and insert body received
        Log__c log = new Log__c();
        log.DateLog__c = system.now();

        // ABT - C-001728 - 22-SEP-2016
        log.Class__c   = 'RESTGetPOOrderLinesUpdate';

        //System.debug('/// Json Message : '+body);
        if (body.length() <= 30000){
            log.JSONMessage__c = body;      
        }
        insert log;
        
        if (body.length() > 30000){
            // ABT - C-001728 - 22-SEP-2016
            //APCreateAttachments.createAttachment(body,log);
            APCreateAttachments.createAttachment('Request', body, log);
        }
        
        //system.debug('/// system.label.CALLTYPE: ' + system.label.CALLTYPE);
        //system.debug('/// mapHeaders: ' + mapHeaders);
        //system.debug('/// mapHeaders.containsKey(system.label.CALLTYPE): ' + mapHeaders.containsKey(system.label.CALLTYPE));
        if(mapHeaders.containsKey(system.label.CALLTYPE)){
            String cType = mapHeaders.get(system.label.CALLTYPE);
            
            if(system.label.ASYNCHRONOUS == cType){
                log.CallType__c = system.label.ASYNCHRONOUS;
                // call @future method
                updatePOAsync(log.Id,body);
                results = system.label.MSGASYNCTREATMENT +' '+log.Id;
            }
            else if(system.label.SYNCHRONOUS == cType){
                log.CallType__c = system.label.SYNCHRONOUS;
                //call synchronous method 
                results = updatePOSync(log.Id,body);
            }
        }
        else{
            log.CallType__c = system.label.SYNCHRONOUS;     
            //if no callType in header, by default call synchronous method
            results = updatePOSync(log.Id,body);
        }
    
        if(!results.contains(system.label.MSGASYNCTREATMENT)){ 
            if(results.contains('Exceptions')){
                log.Status__c = system.label.STATUSFAILED;
            }
            else{
                log.Status__c = system.label.STATUSPASSED;
            }
        }
        else{
            log.Status__c = system.label.STATUSPASSED;
        }
        
        update log;
        RestContext.response.responseBody = Blob.valueOf(results);  
    }
    
    // call if calltype is async
    @future
    public static void updatePOAsync(Id logId,String body){
        System.debug('########## START METHOD updatePOAsync');
        //call method that will process json that contains assessments
        string jResp = updatePO(body);
        //call updateLog class
        updateLog(logId,jResp);
        System.debug('########## END METHOD updatePOAsync');
    }
    
    // call if calltype is sync
    public static string updatePOSync(Id logId,String body){
        System.debug('########## START METHOD updatePOSync');
        //call method that will process json that contains assessments
        string jResp = updatePO(body);
        //call updateLog class
        updateLog(logId,jResp);
        System.debug('########## END METHOD updatePOSync');
        return jResp;       
    }
    
    public static void updateLog(Id logId,String jResp){
        System.debug('########## START METHOD updateLog');
        list<Log__c> logToUpdate = new list<Log__c>();      
        //get log id to update
        for(Log__c l : [Select Id, JSONResponse__c from Log__c where Id =:logId]){
            if (jResp.length() > 30000){
                // ABT - C-001728 - 22-SEP-2016
                //APCreateAttachments.createAttachment(jResp,l);
                APCreateAttachments.createAttachment('Response', jResp, l);
            }else{
                l.JSONResponse__c = jResp;
            }
            logToUpdate.add(l);
        }
        
        //update log
        if(logToUpdate.size()  > 0){
            update logToUpdate;
        }   
        System.debug('########## END METHOD updateLog');
    }
    
    public static string updatePO(string body){
        System.debug('########## START METHOD updatePO');
        map<String,String> successUpdateMap = new map<String,String>();
        JSONGenerator genResults;
        String results = '';
        Boolean isOLUpdated = false;
        //convert the requestbody into a string
        //Map<String,Object>  mapRawObject= (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        //////////////
        //for testing purposes
        string body2 = '{"PurchaseOrders":[{"PurchaseOrderID":"PO-24422","DistributorID":"OV-531890","DistributorPOReference":"PO-24422","AssessmentReference":"Assessment Test 5","PlateNumber":"","Status":"DELIVEREDCONFIRMED","ValidityDate":"2015-09-25","SpareParts":[{"SparePartID":"OL-035346","PartNumber":"9004 K6","Type":"A","Manufacturer":"","DeliveryDuration":"","EstimatedDeliveryDate":null,"CatalogPrice":365.70,"Quantity":1,"AlphaScaleDiscount":0.00,"BodyShopDiscount":0.00,"Suppliable":"","AcceptedByBS":false,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-10-24"}],"BodyShopDetails":{"Name":"MILLE AUTO","Address":"Avenue Commandant Bicheray<br>76000, ROUEN<br>France","Email":"","PhoneNumber":"(+33)232102527","RegionCode":"76"},"VehiclepDetails":{"Brand":"","Model":"TOYOTA","FirstRegistrationDate":"2014-01-01","PlateNumber":"","VinNumber":""}},{"PurchaseOrderID":"PO-25339","DistributorID":"OV-531890","DistributorPOReference":"","AssessmentReference":"Assessment Test 5","PlateNumber":"","Status":"DELIVEREDCONFIRMED","ValidityDate":"2015-09-28","SpareParts":[{"SparePartID":"OL-035346","PartNumber":"9004 K6","Type":"A","Manufacturer":"","DeliveryDuration":"","EstimatedDeliveryDate":null,"CatalogPrice":365.70,"Quantity":1,"AlphaScaleDiscount":0.00,"BodyShopDiscount":0.00,"Suppliable":"","AcceptedByBS":false,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-10-24"},{"SparePartID":"OL-037012","PartNumber":"G9010 47031","Type":"A","Manufacturer":"","DeliveryDuration":"1","EstimatedDeliveryDate":"2015-09-22","CatalogPrice":177.00,"Quantity":1,"AlphaScaleDiscount":0.00,"BodyShopDiscount":0.00,"Suppliable":"YES","AcceptedByBS":true,"BodyShopDeliveryStatus":"DELIVERED","BodyShopDeliveryDate":"2015-09-22"}],"BodyShopDetails":{"Name":"MILLE AUTO","Address":"Avenue Commandant Bicheray<br>76000, ROUEN<br>France","Email":"","PhoneNumber":"(+33)232102527","RegionCode":"76"},"VehiclepDetails":{"Brand":"TOYOTA","Model":"TOYOTA","FirstRegistrationDate":"2014-01-01","PlateNumber":"","VinNumber":"123456789"}}],"OperationType":"get","Success":"true","Warning":"","ErrorMessage":""}';
        // deserialising json body
        //try{      
            //Map<String,Object> mapRawObject= (Map<String,Object>) JSON.deserializeUntyped(body);
            Map<String,Object> mapPO= new Map<String,Object>();
            Map<String,Object> mapSparePart= new Map<String,Object>();
            Map<String,Object> mapAlternative= new Map<String,Object>();
            // list to save PO orders
            List<PurchaseOrder__c> POList= new List<PurchaseOrder__c>();
            // list to save OrderLine list          
            List<OrderLine__c> OLList= new List<OrderLine__c>();
            // list to save Alternative list            
            List<OrderLine__c> alternativeList= new List<OrderLine__c>();
            // set to save POExternal Ids
            Set<String> POExtIdSet = new Set<String>();         
            //set to save POExternalIds and ids
            map<String,Id> ExtIdMap = new map<String,Id>();
            //set to save ids and POExternalIds
            map<Id,String> IdExtMap = new map<Id,String>();
            // extract POList from response
            //List<Object> objList =  (List<Object>)mapRawObject.get('PurchaseOrders');
            List<Object> objList =  (List<Object>)JSON.deserializeUntyped(body);
            //System.debug('########### objList:'+objList);
            if(objList.size()>0){
                // build a set of POExternalID to retrive corresponding IDs
                for(Object POObj:objList){
                    // accessing purchase Order fields and save in mapPO
                    mapPO = (Map<String, Object>)POObj;
                    for(Object POExtIDObj: (List<Object>)mapPO.get('PurchaseOrders')){
                        Map<String, Object> POExtIDMap = new map <String, Object>((Map<String, Object>)POExtIDObj);
                        POExtIdSet.add(String.valueOf(POExtIDMap.get('POExternalID')));
                        //system.debug('###### POExtIdSet:'+POExtIdSet);
                    }                   
                }
                for(PurchaseOrder__c PO: [Select Id, DistributorPOReference__c, (Select Name, Id from OrderLines__r) from PurchaseOrder__c where DistributorPOReference__c in :POExtIdSet]){
                    ExtIdMap.put(PO.DistributorPOReference__c,PO.Id);
                    IdExtMap.put(PO.Id,PO.DistributorPOReference__c);
                    for(OrderLine__c OL:PO.OrderLines__r){
                        ExtIdMap.put(OL.Name,OL.Id);                        
                    }                   
                }
                //System.debug('###### ExtIdMap:'+ExtIdMap);
                
                for(Object POObj:objList){      
                    // accessing purchase Order fields and save in mapPO
                    mapPO = (Map<String, Object>)POObj;
                    for(Object POExtIDObj: (List<Object>)mapPO.get('PurchaseOrders')){
                        Map<String, Object> POExtIDMap = new map <String, Object>((Map<String, Object>)POExtIDObj);
                        // creating new instance of PO
                        PurchaseOrder__c newPO = new PurchaseOrder__c(ValidityDate__c =Date.valueOf(String.valueOf(POExtIDMap.get('ValidityDate'))), Id =ExtIdMap.get(String.valueOf(POExtIDMap.get('POExternalID'))));
                        POList.add(newPO);                  
                        
                        // accessing list spareparts
                        if((List<Object>)POExtIDMap.get('SpareParts')!=null){
                            for(Object sparepartObj: (List<Object>)POExtIDMap.get('SpareParts')){
                                mapSparePart = (Map<String, Object>)sparepartObj;
                                //System.debug('########### SparePartID:'+mapSparePart.get('SparePartID'));
                                OrderLine__c updOL = new OrderLine__c();
                                updOL.ExpectedDeliveryDuration__c = String.valueOf(mapSparePart.get('DeliveryDuration'));
                                updOL.EstimatedDeliveryDate__c =mapSparePart.get('EstimatedDeliveryDate')!=null?Date.valueOf(String.valueOf(mapSparePart.get('EstimatedDeliveryDate'))):null;
                                updOL.CataloguePrice__c = Double.valueOf(mapSparePart.get('CatalogPrice'));
                                updOL.Quantity__c = Integer.valueOf(mapSparePart.get('Quantity'));
                                updOL.AXADiscount__c = Double.valueOf(mapSparePart.get('AlphaScaleDiscount'));
                                updOL.TECH_DistributorCode__c = String.valueOf(mapSparePart.get('AlphaScaleDiscountCode'));
                                updOL.AdditionnalDiscount__c = Integer.valueOf(mapSparePart.get('AlphaScaleExtraDiscount'));                            
                                updOL.BodyShopDiscount__c = Double.valueOf(mapSparePart.get('BodyShopDiscount'));
                                updOL.Suppliable__c = String.valueOf(mapSparePart.get('Suppliable'));
                                updOL.AcceptedCheck__c = Boolean.valueOf(mapSparePart.get('AcceptedByBS'));
                                updOL.DeliveryStatus__c = String.valueOf(mapSparePart.get('BodyShopDeliveryStatus'));
                                updOL.RealDeliveryDate__c = Date.valueOf(String.valueOf(mapSparePart.get('BodyShopDeliveryDate')));
                                updOL.PurchaseOrder__c = newPO.Id;
                                updOL.Id =ExtIdMap.get(String.valueOf(mapSparePart.get('SparePartID')));
                                OLList.add(updOL);
                                // accessing list of alternatives
                                //System.debug('#### alternative:'+(List<Object>)mapSparePart.get('Alternatives'));
                                if((List<Object>)mapSparePart.get('Alternatives')!=null){
                                    for(Object alternativeObj: (List<Object>)mapSparePart.get('Alternatives')){
                                        mapAlternative = (Map<String, Object>)alternativeObj;
                                        //System.debug('########### SparePartID:'+mapAlternative.get('SparePartID'));
                                        OrderLine__c updAlternative = new OrderLine__c();
                                        updAlternative.PartNumber__c = String.valueOf(mapAlternative.get('PartNumber'));                
                                        updAlternative.Type__c = String.valueOf(mapAlternative.get('Type'));                            
                                        updAlternative.Manufacturer__c = String.valueOf(mapAlternative.get('Manufacturer'));                            
                                        updAlternative.ExpectedDeliveryDuration__c = String.valueOf(mapAlternative.get('DeliveryDuration'));                            
                                        updAlternative.EstimatedDeliveryDate__c = Date.valueOf(String.valueOf(mapAlternative.get('EstimatedDeliveryDate')));                            
                                        updAlternative.CataloguePrice__c = Double.valueOf(mapAlternative.get('CatalogPrice'));                          
                                        updAlternative.Quantity__c = Integer.valueOf(mapAlternative.get('Quantity'));                           
                                        updAlternative.BodyShopDiscount__c = Double.valueOf(mapAlternative.get('AlphaScaleDiscount'));                          
                                        updAlternative.TECH_DistributorCode__c = String.valueOf(mapAlternative.get('AlphaScaleDiscountCode'));                          
                                        updAlternative.AdditionnalDiscount__c = Integer.valueOf(mapAlternative.get('AlphaScaleExtraDiscount'));                         
                                        updAlternative.BodyShopDiscount__c = Double.valueOf(mapAlternative.get('BodyShopDiscount'));            
                                        updAlternative.PurchaseOrder__c = newPO.Id; 
                                        updAlternative.OriginalItem__c = updOL.Id; 
                                        updAlternative.Id =ExtIdMap.get(String.valueOf(mapAlternative.get('SparePartID')));                             
                                        OLList.add(updAlternative);
                                    }
                                }
                            }
                        }   
                    }
                }                   
            }
            //System.debug('############# POList:'+POList);
            //System.debug('############# OLList:'+OLList);
            
            // update Orderlines.  If operation fails, stop all update
            if(OLList.size()>0){
                update OLList;      
                isOLUpdated = true;
            }
            
            // updating PO and lists
            if(POList.size()>0){
                List<Database.SaveResult> uResults = database.update(POList,Schema.PurchaseOrder__c.DistributorPOReference__c);
    
                for(Integer idx = 0; idx < uResults.size(); idx++) {
                    if(uResults[idx].isSuccess()) {
                        successUpdateMap.put(IdExtMap.get(POList[idx].Id), 'Success Update');
                    }
                }
                //System.debug('####### successUpdateMap:'+successUpdateMap);
            }
            
            //System.debug('######## isOLUpdated:'+isOLUpdated);
            genResults = JSON.createGenerator(false);
            genResults.writeStartArray();
                if(successUpdateMap.size() > 0){
                    for(String suc : successUpdateMap.keySet()){
                        //System.debug('########## PO Name: '+suc);
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'Update');
                            genResults.writeStringField('TechnicalId', '');
                            genResults.writeStringField('FunctionalId', suc);
                            genResults.writeBooleanField('Success', true);
                            genResults.writeNullField('Warning');
                            genResults.writeNullField('ErrorMessage');
                        genResults.writeEndObject();
                    }
                }
                else{
                    if (isOLUpdated){
                        for (OrderLine__c o : OLList){  
                            //System.debug('########## OL Name: '+o.Id);                        
                            genResults.writeStartObject();
                                genResults.writeStringField('OperationType', 'Update');
                                genResults.writeStringField('TechnicalId', o.Id);
                                genResults.writeNullField('FunctionalId');
                                genResults.writeBooleanField('Success', true);
                                genResults.writeNullField('Warning');
                                genResults.writeNullField('ErrorMessage');
                            genResults.writeEndObject();
                        }                       
                    }
                    else{
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'Update');
                            genResults.writeNullField('TechnicalId');
                            genResults.writeNullField('FunctionalId');
                            genResults.writeBooleanField('Success', false);
                            genResults.writeStringField('Warning','No update was done in this operation.');
                            genResults.writeNullField('ErrorMessage');
                        genResults.writeEndObject();
                    }
                }
            genResults.writeEndArray();
            
        //}// end try
        //catch(Exception e){
        //    System.debug('########## Exception e'+e.getMessage());
        //    genResults = JSON.createGenerator(false);
        //    genResults.writeStartObject();
        //      genResults.writeStringField('OperationType', 'Update');
        //      genResults.writeNullField('TechnicalId');
        //      genResults.writeNullField('FunctionalId');
        //      genResults.writeBooleanField('Success', false);
        //      genResults.writeNullField('Warning');
        //      genResults.writeStringField('ErrorMessage','Exceptions : '+e.getMessage());
        //      genResults.writeEndObject();
        //      results = genResults.getAsString();
        //}
        System.debug('########## END METHOD updatePO');
        results = genResults.getAsString();
        return results;
    }*/
}