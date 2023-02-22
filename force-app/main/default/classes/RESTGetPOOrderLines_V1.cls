/*************************************************************************************
Class Name - RESTGetPOOrderLines_V1
Version - 1.0
Created Date - 07 DEC 2015
Function - Class REST to get orderLines

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  -----------------------
* Ashwina Seetaram  07/12/2015  Original Version
* Shamina M         18/02/2016  C-001518: Removed unnecessary debug logs
* Ashutosh B        22/09/2016  C-001728: Added the new function of create attachment
* Anthony B         21/10/2016  C-001746: DEPRECATED class changed by RESTGetPurchaseOrders => Class to delete
*************************************************************************************/
@RestResource(urlMapping='/v1.0/getPOOrderLines/*')
global with sharing class RESTGetPOOrderLines_V1 {
    //wrapper classes
/*    
    public class requestWrapper{
        public String DateBeginValue;
        public String DateEndValue;
        public String MaxNumberOfRecordsValue;
        public String NbRecordBeginValue;
        public String NbRecordEndValue;
        public String POStatus;
        public list<ParamWrapper> paramList;
    }

    public class ParamWrapper{
        public String PurchaseOrderID;
        public String POExternalID;
    }

    @HttpPost
    global static void getOrderLines() {
        // stores the list of assessment references sent in Body request
        ///List<assessmentWrapper> assessList= new List<assessmentWrapper>();
        
        // stores the list PO references sent in Body request
        List<requestWrapper> requestList= new List<requestWrapper>();
        
        //stores set of assessment references
        //set<String> assessSet= new set<String>(); 
        //Log object
        Log__c log = new Log__c();  
        // use to build list of alternatives
        list<OrderLine__c> alternativeList;
        // strores orderLine and corresponding alternatives
        map<String, list<OrderLine__c>> orderLinealternativeMap = new map<String, list<OrderLine__c>>();
        
        map<String, OrderLine__c> orderLineMap = new map<String, OrderLine__c>();
        
        // set containg PO external Ids obtained from request
        Set<String> POExternalIDSet = new Set<String>();
        
        // JSONGenerator;
        JSONGenerator genResults;
            
        // retieve AssessmentID__c from  WS reponse
        String body = RestContext.request.requestBody.toString();
        
        // string to build dynamic query
        String query = null;
        
        // list saving all POs
        List<PurchaseOrder__c> POList = new List<PurchaseOrder__c>();
        
        List<PurchaseOrder__c> newPOList = new List<PurchaseOrder__c>();
                
        log.DateLog__c = system.now();

        // ABT - C-001728 - 22-SEP-2016
        log.Class__c   = 'RESTGetPOOrderLines_V1';

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
        
        //try{
            //assessList = (List<assessmentWrapper>)JSON.deserializeStrict(body,List<assessmentWrapper>.class);
            //for(assessmentWrapper assess:assessList){
            //    assessSet.add(assess.AssessmentReference);          
            //}
            //System.debug('######## assessSet: '+assessSet);
            requestList = (List<requestWrapper>)JSON.deserializeStrict(body,List<requestWrapper>.class);
            //get list of PO
            if(requestList[0].paramList.size()>0){
                for(ParamWrapper pw: requestList[0].paramList){
                    POExternalIDSet.add(pw.POExternalID);
                }
                //System.debug('######### POExternalIDSet:'+POExternalIDSet);
            }
            
            // building query
            query = 'Select Id,Name,Distributor__r.ReferenceNumber__c,DistributorPOReference__c,Assessment__r.Name,Assessment__r.PlateNumber2__c,Status__c,(Select Name,PartNumber__c, Type__c, OriginalItem__c,Manufacturer__c, ExpectedDeliveryDuration__c,   EstimatedDeliveryDate__c,CataloguePrice__c,Quantity__c,AXADiscount__c,BodyShopDiscount__c,Suppliable__c,AcceptedCheck__c, RealDeliveryDate__c, DeliveryStatus__c from OrderLines__r), ';
            query+= 'BodyShopName__c,BodyShopEmail__c,BodyShopPhoneNumber__c,BodyShopDepartment__c,BodyShopAddress__c,Brand__c,AssetModel__c,AssetRegistrationDate__c,PlateNumber__c,VINNumber__c,ValidityDate__c  from PurchaseOrder__c where DistributorPOReference__c in : POExternalIDSet';
            
            // add date parameters in query
            //start date
            if(requestList[0].DateBeginValue !=null || requestList[0].DateBeginValue !=''){
                //Integer y;
                //Integer m;
                //Integer d;
                //if(requestList[0].DateBeginValue .contains('-')){
                //    List<String> da = requestList[0].DateBeginValue .split('-');
                //
                //    if(da.size() > 2){
                //        y = integer.valueOf(da[0]);
                //        m = integer.valueOf(da[1]);
                //        d = integer.valueOf(da[2]);
                //
                //    }
                //}
                //
                //if(y != null && m !=null && d!=null){
                //    datetime dtBeg = datetime.newInstance(y, m, d);
                //    System.debug('######## dtBeg:'+dtBeg);
                //    query += ' and LastModifiedDate >=:dtBeg'; 
                //}
                query += ' and LastModifiedDate >=:Date.valueOf(requestList[0].DateBeginValue)'; 
            }
            
            // end date
            if(requestList[0].DateEndValue !=null || requestList[0].DateEndValue !=''){
                //Integer y;
                //Integer m;
                //Integer d;
                //if(requestList[0].DateEndValue.contains('-')){
                //    List<String> da = requestList[0].DateEndValue.split('-');
                //
                //    if(da.size() > 2){
                //        y = integer.valueOf(da[0]);
                //        m = integer.valueOf(da[1]);
                //        d = integer.valueOf(da[2]);
                //
                //    }
                //}
                //
                //if(y != null && m !=null && d!=null){
                //    datetime dtEnd = datetime.newInstance(y, m, d);
                //    System.debug('######## dtEnd:'+dtEnd);
                //    query += ' and LastModifiedDate <=:dtEnd';
                //}
                query += ' and LastModifiedDate <=:Date.valueOf(requestList[0].DateEndValue)';
            }
            
            // add PO status
            if(requestList[0].POStatus !=null && requestList[0].POStatus !=''){
                List<String> statusList= requestList[0].POStatus.split('; ');
                Set<String> statusSet = new Set<String>(statusList);
                //System.debug('######### statusSet:'+statusSet);
                query += ' and status__c in :statusSet';
            }

            //add MaxNumberOfRecordsValue;
            if(requestList[0].MaxNumberOfRecordsValue !=null && requestList[0].MaxNumberOfRecordsValue !=''){           
                Integer maxNum = Integer.valueof(requestList[0].MaxNumberOfRecordsValue.trim());
                //System.debug('########## maxNum:'+maxNum);
                query += ' limit '+maxNum;
            }
            //System.debug('############# query:'+query);
            if(query != null){
                newPOList = Database.query(query);
                //System.debug('/// newPOList: ' + newPOList); 
            }
            
            //System.debug(requestList[0].MaxNumberOfRecordsValue);
            //System.debug(requestList[0].NbRecordBeginValue);
            //System.debug(requestList[0].NbRecordEndValue);
            // adding NbRecordBeginValue and NbRecordEndValue
            if((requestList[0].MaxNumberOfRecordsValue ==null || requestList[0].MaxNumberOfRecordsValue =='') &&requestList[0].NbRecordBeginValue != null&& requestList[0].NbRecordBeginValue != '' &&requestList[0].NbRecordEndValue != null && requestList[0].NbRecordEndValue != '' && newPOList.size()>0){
                for(integer i = (Integer.valueof(requestList[0].NbRecordBeginValue.trim()) -1); i<Integer.valueof(requestList[0].NbRecordEndValue.trim()); i++){
                    //System.debug('###################### xxxxxxxxxxxxxxx');
                    POList.add(newPOList[i]);
                }           
            }
            else{
                POList.addAll(newPOList);
            }
            //system.debug('####### POList:'+POList);
            
            if(POList.size()>0){
                genResults = JSON.createGenerator(false);
                // start response Object
                genResults.writeStartObject();
                    // build JSON for purchase order
                    // writing block for PurchaseOrders List                    
                    genResults.writeFieldName('PurchaseOrders');
                    // start PO array
                    genResults.writeStartArray();
                    for(PurchaseOrder__c PO: POList){
                        // building map of Orderlines and alternatives
                        if(PO.OrderLines__r.size()>0){
                            //loop in orderLines to build alternative
                            for(OrderLine__c orderLine:PO.OrderLines__r){
                                // check if orderLine is an alternative. If yes, build a map of orderline and corresponding alternatives
                                if(orderLine.OriginalItem__c!=null){
                                    if(!orderLinealternativeMap.containsKey(orderLine.OriginalItem__c)){
                                        //alternativeWrapper alternativeWrapper1 =new alternativeWrapper(orderLine.Name,orderLine.PartNumber__c,orderLine.Type__c,orderLine.Manufacturer__c,orderLine.ExpectedDeliveryDuration__c,orderLine.EstimatedDeliveryDate__c,orderLine.CataloguePrice__c,orderLine.Quantity__c,orderLine.AXADiscount__c,orderLine.BodyShopDiscount__c);
                                        alternativeList = new list<OrderLine__c>();
                                        //alternativeList.add(new alternativeWrapper(orderLine.Name,orderLine.PartNumber__c,orderLine.Type__c,orderLine.Manufacturer__c,orderLine.ExpectedDeliveryDuration__c,orderLine.EstimatedDeliveryDate__c,orderLine.CataloguePrice__c,orderLine.Quantity__c,orderLine.AXADiscount__c,orderLine.BodyShopDiscount__c));
                                        alternativeList.add(orderLine);
                                        orderLinealternativeMap.put(orderLine.OriginalItem__c,alternativeList);
                                    }
                                    else{
                                        orderLinealternativeMap.get(orderLine.OriginalItem__c).add(orderLine);
                                    }
                                }
                                else{
                                    orderLineMap.put(orderLine.Id,orderLine);
                                }               
                            }
                            //System.debug('######## orderLinealternativeMap:'+orderLinealternativeMap);
                            //System.debug('######## orderLineMap:'+orderLineMap);
                        }// end if(PO.OrderLines__r.size()>0)           
                        
                        
                        //  start PurchaseOrder Object
                        genResults.writeStartObject();
                            // write PurchaseOrderID
                            genResults.writeStringField('PurchaseOrderID', PO.Name==null?'':PO.Name);
                
                            // write DistributorID
                            genResults.writeStringField('DistributorID', PO.Distributor__r.ReferenceNumber__c==null?'': PO.Distributor__r.ReferenceNumber__c);
                
                            // write POExternalID
                            genResults.writeStringField('POExternalID', PO.DistributorPOReference__c==null?'':PO.DistributorPOReference__c);
                
                            // write AssessmentReference
                            genResults.writeStringField('AssessmentReference', PO.Assessment__r.Name==null?'':PO.Assessment__r.Name);
                
                            // write PlateNumber
                            genResults.writeStringField('PlateNumber', PO.Assessment__r.PlateNumber2__c==null?'':PO.Assessment__r.PlateNumber2__c);
                
                            // write Status
                            genResults.writeStringField('Status', PO.Status__c==null?'':PO.Status__c);
                
                            // write ValidityDate                           
                            if( PO.ValidityDate__c==null){
                                genResults.writeNullField('ValidityDate');
                            }
                            else{
                                genResults.writeDateField('ValidityDate', PO.ValidityDate__c);
                            }
                            //build spareparts block            
                            if(orderLineMap.size()>0){
                                // write array for SpareParts 
                                genResults.writeFieldName('SpareParts');
                                genResults.writeStartArray();
                                //loop in orderLines to build spartPart wrapper
                                for(String orderlineId: orderLineMap.keySet()){
                                    // start spartpart Object                                        
                                    genResults.writeStartObject();
                                        //SparePartID
                                        genResults.writeStringField('SparePartID', orderLineMap.get(orderLineId).Name==null?'':orderLineMap.get(orderLineId).Name);
                                        
                                        //PartNumber
                                        genResults.writeStringField('PartNumber', orderLineMap.get(orderLineId).PartNumber__c==null?'':orderLineMap.get(orderLineId).PartNumber__c);
                                        
                                        //Type
                                        genResults.writeStringField('Type', orderLineMap.get(orderLineId).Type__c==null?'':orderLineMap.get(orderLineId).Type__c);
                                        
                                        //Manufacturer
                                        genResults.writeStringField('Manufacturer', orderLineMap.get(orderLineId).Manufacturer__c==null?'':orderLineMap.get(orderLineId).Manufacturer__c);
                                        
                                        //DeliveryDuration
                                        genResults.writeStringField('DeliveryDuration', orderLineMap.get(orderLineId).ExpectedDeliveryDuration__c==null?'':orderLineMap.get(orderLineId).ExpectedDeliveryDuration__c);
                                        
                                        //EstimatedDeliveryDate
                                        if(orderLineMap.get(orderLineId).EstimatedDeliveryDate__c==null){
                                            genResults.writeNullField('EstimatedDeliveryDate');
                                        }
                                        else{
                                            genResults.writeDateField('EstimatedDeliveryDate',orderLineMap.get(orderLineId).EstimatedDeliveryDate__c);
                                        }
                                        
                                        //CatalogPrice
                                        if(orderLineMap.get(orderLineId).CataloguePrice__c==null){
                                            genResults.writeNullField('CatalogPrice');
                                        }
                                        else{
                                            genResults.writeNumberField('CatalogPrice',orderLineMap.get(orderLineId).CataloguePrice__c);
                                        }
                                        
                                        //Quantity
                                        if(orderLineMap.get(orderLineId).Quantity__c==null){
                                            genResults.writeNullField('Quantity');
                                        }
                                        else{
                                            genResults.writeNumberField('Quantity',orderLineMap.get(orderLineId).Quantity__c);
                                        }
                                        
                                        //AlphaScaleDiscount
                                        if(orderLineMap.get(orderLineId).AXADiscount__c==null){
                                            genResults.writeNullField('AlphaScaleDiscount');
                                        }
                                        else{
                                            genResults.writeNumberField('AlphaScaleDiscount',orderLineMap.get(orderLineId).AXADiscount__c);
                                        }
                                        
                                        //BodyShopDiscount
                                        if(orderLineMap.get(orderLineId).BodyShopDiscount__c==null){
                                            genResults.writeNullField('BodyShopDiscount');
                                        }
                                        else{
                                            genResults.writeNumberField('BodyShopDiscount',orderLineMap.get(orderLineId).BodyShopDiscount__c);
                                        }
                                        
                                        //Suppliable
                                        genResults.writeStringField('Suppliable', orderLineMap.get(orderLineId).Suppliable__c==null?'':orderLineMap.get(orderLineId).Suppliable__c);
                                        
                                        //AcceptedByBS                                      
                                        genResults.writeBooleanField('AcceptedByBS', orderLineMap.get(orderLineId).AcceptedCheck__c);
                                        
                                        //BodyShopDeliveryStatus
                                        genResults.writeStringField('BodyShopDeliveryStatus', orderLineMap.get(orderLineId).DeliveryStatus__c==null?'':orderLineMap.get(orderLineId).DeliveryStatus__c);
                                        
                                        //BodyShopDeliveryDate
                                        if(orderLineMap.get(orderLineId).RealDeliveryDate__c==null){
                                            genResults.writeNullField('BodyShopDeliveryDate');
                                        }
                                        else{
                                            genResults.writeDateField('BodyShopDeliveryDate',orderLineMap.get(orderLineId).RealDeliveryDate__c);
                                        }
                                        
                                        // building Alternatives block
                                        //System.debug('############## orderLinealternativeMap.get(orderLineId):'+orderLinealternativeMap.get(orderLineId));
                                        if(orderLinealternativeMap.get(orderLineId)!=null){
                                            if(orderLinealternativeMap.get(orderLineId).size()>0){
                                                // write array for Alternatives
                                                genResults.writeFieldName('Alternatives');
                                                genResults.writeStartArray();                                                   
                                                    //loop in orderLines to build alternatives
                                                    for(OrderLine__c alt: orderLinealternativeMap.get(orderLineId)){
                                                        // Start alternative Object
                                                        genResults.writeStartObject();
                                                            //SparePartID
                                                            genResults.writeStringField('SparePartID', alt.Name==null?'':alt.Name);
                                                            
                                                            //PartNumber
                                                            genResults.writeStringField('PartNumber', alt.PartNumber__c==null?'':alt.PartNumber__c);
                                                            
                                                            //Type
                                                            genResults.writeStringField('Type', alt.Type__c==null?'':alt.Type__c);
                                                            
                                                            //Manufacturer
                                                            genResults.writeStringField('Manufacturer', alt.Manufacturer__c==null?'':alt.Manufacturer__c);
                                                            
                                                            //DeliveryDuration
                                                            genResults.writeStringField('DeliveryDuration', alt.ExpectedDeliveryDuration__c==null?'':alt.ExpectedDeliveryDuration__c);
                                                            
                                                            //EstimatedDeliveryDate
                                                            if(alt.EstimatedDeliveryDate__c==null){
                                                                genResults.writeNullField('EstimatedDeliveryDate');
                                                            }
                                                            else{
                                                                genResults.writeDateField('EstimatedDeliveryDate', alt.EstimatedDeliveryDate__c);
                                                            }                                                   
                                                        
                                                            //CatalogPrice
                                                            if(alt.CataloguePrice__c==null){
                                                                genResults.writeNullField('CatalogPrice');
                                                            }
                                                            else{
                                                                genResults.writeNumberField('CatalogPrice',alt.CataloguePrice__c);
                                                            }
                                                            
                                                            //Quantity
                                                            if(alt.Quantity__c==null){
                                                                genResults.writeNullField('Quantity');
                                                            }
                                                            else{
                                                                genResults.writeNumberField('Quantity',alt.Quantity__c);
                                                            }
                                                            
                                                            //AlphaScaleDiscount
                                                            if(alt.AXADiscount__c==null){
                                                                genResults.writeNullField('AlphaScaleDiscount');
                                                            }
                                                            else{
                                                                genResults.writeNumberField('AlphaScaleDiscount',alt.AXADiscount__c);
                                                            }
                                                            
                                                            //BodyShopDiscount
                                                            if(alt.BodyShopDiscount__c==null){
                                                                genResults.writeNullField('BodyShopDiscount');
                                                            }
                                                            else{
                                                                genResults.writeNumberField('BodyShopDiscount',alt.BodyShopDiscount__c);
                                                            }
                                                        // end alternative Object
                                                        genResults.writeEndObject();                                                    
                                                    }// end loop in orderLines to build alternatives
                                                // End array for Alternatives
                                                genResults.writeEndArray();
                                            }// end alternativeMap size                                         
                                        }                                       
                                    // end spartpart Object
                                    genResults.writeEndObject();                                                                
                                }// end loop in orderLines
                                // end array for SpareParts 
                                genResults.writeEndArray();
                            }// end if orderLineMap size                            
                            
                            genResults.writeFieldName('BodyShopDetails');
                            // write BodyShopDetails object                         
                            genResults.writeStartObject();
                                //Name
                                genResults.writeStringField('Name', PO.BodyShopName__c==null?'':PO.BodyShopName__c);
                            
                                //Address
                                genResults.writeStringField('Address', PO.BodyShopAddress__c==null?'':PO.BodyShopAddress__c);
                            
                                //Email
                                genResults.writeStringField('Email', PO.BodyShopEmail__c==null?'':PO.BodyShopEmail__c);
                            
                                //PhoneNumber
                                genResults.writeStringField('PhoneNumber', PO.BodyShopPhoneNumber__c==null?'':PO.BodyShopPhoneNumber__c);
                            
                                //RegionCode
                                genResults.writeStringField('RegionCode', PO.BodyShopDepartment__c==null?'':PO.BodyShopDepartment__c);
                            
                            // end write BodyShopDetails object
                            genResults.writeEndObject();
                            
                            genResults.writeFieldName('VehiclepDetails');
                            // Start VehiclepDetails object
                            genResults.writeStartObject();
                                //Brand
                                genResults.writeStringField('Brand', PO.Brand__c==null?'':PO.Brand__c);
                            
                                //Model
                                genResults.writeStringField('Model', PO.AssetModel__c==null?'':PO.AssetModel__c);
                            
                                //FirstRegistrationDate
                                if(PO.AssetRegistrationDate__c==null){
                                    genResults.writeNullField('FirstRegistrationDate');
                                }
                                else{
                                    genResults.writeDateField('FirstRegistrationDate', PO.AssetRegistrationDate__c);
                                }   
                            
                                //PlateNumber
                                genResults.writeStringField('PlateNumber', PO.PlateNumber__c==null?'':PO.PlateNumber__c);
                            
                                //VinNumber
                                genResults.writeStringField('VinNumber', PO.VINNumber__c==null?'':PO.VINNumber__c);                                         
                            
                            // End VehiclepDetails object
                            genResults.writeEndObject();
                            
                        // end PurchaseOrder object
                        genResults.writeEndObject();
                        
                    }// end for PO list
                    // end PO array
                    genResults.writeEndArray();
                
                    //OperationType                 
                    genResults.writeStringField('OperationType','get');
                    
                    //Success                   
                    genResults.writeStringField('Success','true');
                    
                    //Warning                   
                    genResults.writeStringField('Warning','');
                    
                    //Warning                   
                    genResults.writeStringField('ErrorMessage','');
                // end response Object  
                genResults.writeEndObject();
            }// end if POList
            else{
                genResults = JSON.createGenerator(false);
                genResults.writeStartObject();
                    genResults.writeStringField('OperationType', 'Get');
                    genResults.writeBooleanField('Success', false);
                    genResults.writeNullField('Warning');
                    genResults.writeStringField('ErrorMessage', 'No Orderlines.');
                genResults.writeEndObject();                    
            }// end else
        //}//end try
        //catch(Exception e){
        //    genResults = JSON.createGenerator(false);
        //    genResults.writeStartObject();
        //        genResults.writeStringField('OperationType', 'Get');
        //        genResults.writeBooleanField('Success', false);
        //        genResults.writeNullField('Warning');
        //        genResults.writeStringField('ErrorMessage', e.getMessage());
        //    genResults.writeEndObject();
        //}
        
        if(genResults!=null){
            String results = genResults.getAsString();
            //System.debug('######### results:'+results);
            // if results <=3000, insert in log object else create attachment
            if (results.length() <= 30000){
                log.JSONResponse__c = String.valueOf(Blob.valueOf(results));
                update log;
            }
            else{
                // ABT - C-001728 - 22-SEP-2016
                //APCreateAttachments.createAttachment(results,log);
                APCreateAttachments.createAttachment('Response', results, log);
            }
            // response
            RestContext.response.responseBody = Blob.valueOf(results);      
            //System.debug('###### log Id:'+log);
        }       
    }*/
}