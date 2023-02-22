/*************************************************************************************
Class Name - RESTCreateDistributorInvoice_V1
Version - 1.0
Created Date - 21 JULY 2015
Function - Class REST to create distributor invoice

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Brayan Nunhuck 21/07/2015     Original Version
* Ashwina S      04/01/2015     set TechToBeProcessed__c on PO to true
* Ashwina S      05/01/2015     move dev of TechToBeProcessed__c to trigger
* Dourga U       19/01/2016     Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
* Ashwina S      11/02/2015     C-001526: Exponens : Json error return not complete
* Shamina M      17/02/2016     C-001518: Removed unnecessary debug logs
* Ashwina S      19/02/2016     C-001535: Upsert of invoices sent by Exponens
* Ashutosh B     22/09/2016     C-001728: Added the new function of create attachment
* Ashwina S      16/02/2017     InvoiceReference__c must contain the invoice Number
* Ashwina S      19/05/2017     Case C-001904 and C-001926
* Dourga U       08/01/2018     C-002135: Agency Mode V2 
* Vaynee S       23/07/2018  C-002672: Manage Payment Rejects from Exponens
* Neha P         07/12/2021     C-004384: Update CreateDistributorInvoice_V1 response when there are PO's in Agency Mode
*************************************************************************************/
@RestResource(urlMapping='/v1.0/upsertDistributorInvoice/*')
global with sharing class RESTCreateDistributorInvoice_V1 {
    static map<String, String> invRefOrderRefMap; 
    @HttpPost
    global static void createDisInv() {
        map<String,String> mapHeaders = new map<String,String>();
        string results = '';
        //retrieve the headers that are received by the request. Synchronous / Asynchronous
        RestRequest req = RestContext.request;
        mapHeaders = req.headers;
        //system.debug('////mapHeaders: '+mapHeaders);
        
        //to be commented////////////////////////////////////////////////////
        //mapHeaders.put(system.label.CALLTYPE,system.label.ASYNCHRONOUS);
        //////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////
        
        //convert the requestbody into a string
        String body = RestContext.request.requestBody.toString();
        
        Log__c log = new Log__c();
        log.DateLog__c = system.now();

        // ABT - C-001728 - 22-SEP-2016
        log.Class__c   = 'RESTCreateDistributorInvoice_V1';

        //System.debug('/// Json Message : '+body);
        if (body.length() <= 30000){
            log.JSONMessage__c = body;
            
        }
        insert log;

        if (body.length() > 30000)
        {
            // ABT - C-001728 - 22-SEP-2016
            //APCreateAttachments.createAttachment(body,log);
            APCreateAttachments.createAttachment('Request', body, log);
        }

        
        if(mapHeaders.containsKey(system.label.CALLTYPE)){
            String cType = mapHeaders.get(system.label.CALLTYPE);
            
            if(system.label.ASYNCHRONOUS == cType){
                log.CallType__c = system.label.ASYNCHRONOUS;
                // call @future method
                createDisInvoiceAsync(log.Id,body);
                results = system.label.MSGASYNCTREATMENT +' '+log.Id;
            }else if(system.label.SYNCHRONOUS == cType){
                log.CallType__c = system.label.SYNCHRONOUS;
                //call synchronous method
                results = createDisInvoiceSync(log.Id,body);
            }
        }else{
            log.CallType__c = system.label.SYNCHRONOUS;
            //if no callType in header, by default call synchronous method
            results = createDisInvoiceSync(log.Id,body);
        }
        if(results.contains('Exception')){
            log.Status__c = system.label.STATUSFAILED;
        }else{
            log.Status__c = system.label.STATUSPASSED;
        }
        update log;
        RestContext.response.responseBody = Blob.valueOf(results);
    }

    @future
    public static void createDisInvoiceAsync(Id logId,String body){
        list<Log__c> logToUpdate = new list<Log__c>();
        //call method that will process json that contains assessments
        string jResp = createDisInvoice(body);
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
    }

    // call if calltype is sync
    public static string createDisInvoiceSync(Id logId,String body){
        list<Log__c> logToUpdate = new list<Log__c>();
        //call method that will process json that contains assessments
        string jResp = createDisInvoice(body);
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
        return jResp;
    }

    set<String> POInvOrdRef = new set<String>();


    public static string createDisInvoice(String body){
        list<InvoiceDetails> invDetList = new list<InvoiceDetails>();
        list<Invoice__c> invoiceListToInsert = new list<Invoice__c>();
        map<String,InvoiceDetails> mapInvoiceRef = new map<String,InvoiceDetails>();
        map<String,Account> mapDistributor = new map<String,Account>();
        map<String,PurchaseOrder__c> mapPurchaseOrder = new map<String,PurchaseOrder__c>();
        map<String,PurchaseOrder__c> mapPORDistOrder = new map<String,PurchaseOrder__c>();
        set<String> setPORef = new set<String>();
        set<String> setDistributorRef = new set<String>();
        //Ashwina S: 19/02/16
        map<String, String> mapInvoicesRef = new map<String, String>();    
        //
        map<String,String> successUpdateMap = new map<String,String>();
        map<String,String> errorUpdateMap = new map<String,String>();
        map<String,String> mapExtIdNSFDCID = new map<String,String>();
        String results = null;
        JSONGenerator genResults;
        String conversionErrors = null;
        Map<String,List<Invoice__c>> mapInvoices = new Map<String,List<Invoice__c>>();
        invRefOrderRefMap = new map<String, String>(); 
        //String agencyModeException = '';
        //NPE C-004384: Update CreateDistributorInvoice_V1 response when there are PO's in Agency Mode
        string [] agencyModePo = new list<string>();
        /*
        // ASE 04/01/15: instatiate map to save POid and TechToBeProcessed__c
         map<Id,PurchaseOrder__c> toUpdatePOMap = new map<Id,PurchaseOrder__c>();*/
    

        try{
            JSONParser parser = JSON.createParser(body);
            
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            try{
                                //parse block of Invoice into InvoiceDetails
                                InvoiceDetails idet = (InvoiceDetails)parser.readValueAs(InvoiceDetails.class);
                                parser.skipChildren();
                                //system.debug(' // invoice details: ' + idet);
                                invDetList.add(idet);
                            }catch(Exception ex){
                                if(conversionErrors == null){
                                    conversionErrors = ex.getMessage();
                                }else{
                                    conversionErrors += '-'+ex.getMessage();
                                }
                            }
                        }
                    }
                }
            }
            system.debug('/// invDetList: ' + invDetList);

            if(invDetList.size() > 0){
                for(InvoiceDetails ide : invDetList){
                    setPORef.add(ide.PurchaseOrderReference);
                    setDistributorRef.add(ide.AccountReference);
                }
            }

            for(Account a : [Select Id, ReferenceNumber__c, Invoicing_Order_Reference__c from Account where ReferenceNumber__c in:setDistributorRef]){
                mapDistributor.put(a.ReferenceNumber__c,a);
            }
            //for(PurchaseOrder__c po : [Select Id,Assessment__c,Name,Assessment__r.TECH_BodyshopCountryCode__c, TechToBeProcessed__c, Assessment__r.TECH_EntityCountryCode__c,
            //DUN 08/01/2018  C-002135: Agency Mode V2 change field from AgencyMode__c on assessment to AgencyMode__c on purchase Order
            //kem
            for(PurchaseOrder__c po : [Select Id,Assessment__c,Name,DistributorOrderReference__c, Assessment__r.TECH_EntityCountryCode__c
                                        , AgencyMode__c
                                        ,(Select InvoiceReference__c, Status__c from Invoices__r)                                       
                                      from PurchaseOrder__c 
                                      where Name in:setPORef or DistributorOrderReference__c in:setPORef]){
                mapPurchaseOrder.put(po.Name,po);
                mapPORDistOrder.put(po.DistributorOrderReference__c,po);
                //ASE: 19/02/16
                for(Invoice__c inv: po.Invoices__r){
                    mapInvoicesRef.put(inv.InvoiceReference__c,inv.Status__c);
                } 
            }
            //system.debug('/// invDetList: ' + invDetList.size());
            if(invDetList.size() > 0){
                for(InvoiceDetails ide : invDetList){ 

                    Boolean agencyMode = false;
                        
                    Invoice__c invDisToInsert = new Invoice__c();
                    /*if(mapDistributor.containsKey(ide.AccountReference)){
                        invDisToInsert.Distributor__c = mapDistributor.get(ide.AccountReference).Id;
                    }*/                    
                    System.debug('<<<<<ide.PurchaseOrderReference>>>>>' + ide.PurchaseOrderReference);
                    System.debug('<<<<<mapPurchaseOrder>>>>>' + mapPurchaseOrder);
                    System.debug('<<<<<mapPORDistOrder>>>>>' + mapPORDistOrder);

                    if(mapPurchaseOrder.containsKey(ide.PurchaseOrderReference) || mapPORDistOrder.containsKey(ide.PurchaseOrderReference) ){
                        //kem
                        PurchaseOrder__c PO = (mapDistributor.containsKey(ide.AccountReference) && mapDistributor.get(ide.AccountReference).Invoicing_Order_Reference__c == 'Distributor Order Reference' && mapPORDistOrder.containsKey(ide.PurchaseOrderReference)?mapPORDistOrder.get(ide.PurchaseOrderReference): mapPurchaseOrder.get(ide.PurchaseOrderReference));
                       

                        System.debug('<<<<<PO>>>>>' + PO);


                        invDisToInsert.PurchaseOrder__c = PO.Id;
                        invDisToInsert.Assessment__c = PO.Assessment__c;
                        //ASE : 16/02/17: InvoiceReference__c is the invoice Number
                        //invDisToInsert.InvoiceReference__c = mapPurchaseOrder.get(ide.PurchaseOrderReference).Assessment__r.TECH_EntityCountryCode__c+ ide.AccountReference + ide.InvoiceNumber;
                        //invDisToInsert.InvoiceReference__c = ide.InvoiceNumber;
                        invDisToInsert.InvoiceReference__c = ide.AccountReference + ide.InvoiceNumber + ide.PurchaseOrderReference;  
                        if(!invRefOrderRefMap.containsKey(invDisToInsert.InvoiceReference__c )){
                            invRefOrderRefMap.put(invDisToInsert.InvoiceReference__c , ide.PurchaseOrderReference);
                        }                      
                        
                        if(!mapInvoicesRef.containsKey(invDisToInsert.InvoiceReference__c)){
                            invDisToInsert.Status__c = ide.Status;                    
                        }
                        else{
                            if(mapInvoicesRef.get(invDisToInsert.InvoiceReference__c) == 'PAYABLE'){
                                invDisToInsert.Status__c =  ide.Status!= 'PAID'? 'PAYABLE':  ide.Status;                        
                            } 
                            else if(mapInvoicesRef.get(invDisToInsert.InvoiceReference__c) == 'PAID'){
                                invDisToInsert.Status__c =  'PAID';                        
                            } 
                            else{
                                invDisToInsert.Status__c =  ide.Status;
                            }                           
                        } 

                        //if(ide.AccountReference == PO.distributor__r.ReferenceNumber__c){
                            if(mapDistributor.containsKey(ide.AccountReference)){
                                invDisToInsert.Distributor__c = mapDistributor.get(ide.AccountReference).Id;
                            }
                        /*}
                        else{
                            invDisToInsert.Distributor__c = 'a0K00NODISFOUND';
                            invDisToInsert.InvoiceReference__c = ide.PurchaseOrderReference; 
                        }*/
                        //DUN 08/01/2018  C-002135: Agency Mode V2 change field from AgencyMode__c on assessment to AgencyMode__c on purchase Order
                        if(PO.AgencyMode__c){   
                            agencyMode = true; 

                            //NPE commented due to case C-004384                 
                            //agencyModeException  += ide.AccountReference + ide.InvoiceNumber + ide.PurchaseOrderReference  +', '; 
                            
                            //NPE C-004384: Update CreateDistributorInvoice_V1 response when there are PO's in Agency Mode
                            agencyModePo.add(ide.PurchaseOrderReference);
                        }
                    }
                    // ase: 11022016: C-001526:in case PO does not exist, PO on invoice a0K000NOPOFOUND and InvoiceReference__c to ide.PurchaseOrderReference
                    // thus InvoiceReference__c is not null, and error is captured for each PO failed, and no global exception is sent.
                    else{
                        invDisToInsert.PurchaseOrder__c = 'a0K000NOPOFOUND';
                        invDisToInsert.InvoiceReference__c = ide.PurchaseOrderReference; 
                    }

                    invDisToInsert.PaymentFailed__c = ide.PaymentFailed;//VSU 19/07/18 C-002672
                    invDisToInsert.Number__c = ide.InvoiceNumber; 
                    
                    //invDisToInsert.Date__c = ide.InvoiceDate;
                    invDisToInsert.Date__c = (ide.InvoiceDate != null && ide.InvoiceDate != '') ? (Date) JSON.deserialize('"' + ide.InvoiceDate + '"', Date.class) : null;                          
                        
                    // ASE 2016/01/05: remove whiteSpace
                    if(ide.Type != null){
                        invDisToInsert.Type__c = ide.Type.deleteWhitespace();
                    }
                    //invDisToInsert.DueDateDistributor__c = ide.InvoiceDueDate;
                    invDisToInsert.DueDateDistributor__c = (ide.InvoiceDueDate != null && ide.InvoiceDueDate != '') ? (Date) JSON.deserialize('"' + ide.InvoiceDueDate + '"', Date.class) : null;                          
                     
                    invDisToInsert.TotalNet__c = ide.TotalNET;
                    invDisToInsert.VATDistributor__c = ide.VAT;
                    //invDisToInsert.TechToBeProcessed__c = true;
                    // ASE 04/01/15: case C-001469
                    invDisToInsert.TotalTTCDistributor__c = ide.TotalTTC;
                    
                    if(!agencyMode){
                        if (mapInvoices.containsKey(invDisToInsert.InvoiceReference__c))
                        {
                            mapInvoices.get(invDisToInsert.InvoiceReference__c).add(invDisToInsert);
                        }else{
                            List<Invoice__c> invList = new List<Invoice__c>();
                            invList.add(invDisToInsert);
                            mapInvoices.put(invDisToInsert.InvoiceReference__c,invList);
                        }
                    }
                    //invoiceListToInsert.add(invDisToInsert);      
                }
            }

            for (String s : mapInvoices.keySet()){
                List<Invoice__c> invList =  new List<Invoice__c>(); 
                invList = mapInvoices.get(s);

                if (invList.size() > 0){
                    invoiceListToInsert.add(invList[0]);     
                }
            }

            
            System.debug('//// invoiceListToInsert.size(): ' + invoiceListToInsert.size());
            if(invoiceListToInsert.size() > 0){
                
                Schema.SObjectField f = Invoice__c.Fields.InvoiceReference__c;
                List<Database.UpsertResult> uResults = Database.upsert(invoiceListToInsert,f,false);

                for(Integer idx = 0; idx < uResults.size(); idx++) {
                    if(uResults[idx].isSuccess()) {
                        successUpdateMap.put(invoiceListToInsert[idx].InvoiceReference__c, 'Success Update');
                        mapExtIdNSFDCID.put(invoiceListToInsert[idx].InvoiceReference__c,uResults[idx].getId());
                        //System.debug('//// sucess: ');
                        /* code moved to trigger invoiceAfterInsert
                        // 04/01/15: instatiate map to save POid and TechToBeProcessed__c
                        //verify if invoice has a PO and invoice creation is successful
                        if(invoiceListToInsert[idx].PurchaseOrder__c!=null){
                            if(!toUpdatePOMap.containsKey(invoiceListToInsert[idx].PurchaseOrder__c)){
                                toUpdatePOMap.put(invoiceListToInsert[idx].PurchaseOrder__c, new PurchaseOrder__c(Id=invoiceListToInsert[idx].PurchaseOrder__c, TechToBeProcessed__c = true));
                            }   
                        }*/
                    }else{
                        for(Database.Error err : uResults[idx].getErrors()){
                            //System.debug('//// err: '+err.getMessage());
                            errorUpdateMap.put(invoiceListToInsert[idx].InvoiceReference__c, system.label.Error+':'+err.getMessage());
                        }
                    }
                }
            }

            //System.debug('//// sucess successUpdateMap: '+ successUpdateMap);
            //System.debug('//// sucess errorUpdateMap: '+ errorUpdateMap);

            genResults = JSON.createGenerator(false);

            genResults.writeStartArray();
                if(successUpdateMap.size() > 0){
                    for(String suc : successUpdateMap.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'upsert');
                            genResults.writeStringField('TechnicalId', mapExtIdNSFDCID.get(suc));
                            genResults.writeStringField('FunctionalId', suc);
                            genResults.writeStringField('OrderNumber', invRefOrderRefMap.get(suc));
                            genResults.writeBooleanField('Success', true);
                            genResults.writeNullField('Warning');
                            genResults.writeNullField('ErrorMessage');
                        genResults.writeEndObject();
                    }
                    /* code moved to trigger invoiceAfterInsert
                    // update PO
                    if(toUpdatePOMap.size()>0){
                        update toUpdatePOMap.values();
                    }       */          
                }

                if(conversionErrors != null){
                    genResults.writeStartObject();
                        genResults.writeStringField('OperationType', 'upsert');
                        genResults.writeStringField('TechnicalId', '');
                        genResults.writeStringField('FunctionalId', '');
                        genResults.writeBooleanField('Success', false);
                        genResults.writeNullField('Warning');
                        genResults.writeStringField('ErrorMessage','Exception:' + conversionErrors);
                    genResults.writeEndObject();
                }
                System.debug('//// sucess successUpdateMap: '+ successUpdateMap);
                system.debug('## errorUpdateMap ' + errorUpdateMap);
                if (errorUpdateMap.size()> 0){
                    for(String err : errorUpdateMap.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'upsert');
                            genResults.writeStringField('TechnicalId', '');
                            genResults.writeStringField('FunctionalId', err);
                            if(invRefOrderRefMap.get(err) != null){
                                genResults.writeStringField('OrderNumber', invRefOrderRefMap.get(err));
                            }
                            genResults.writeBooleanField('Success', false);
                            genResults.writeNullField('Warning');
                            if(errorUpdateMap.get(err).contains('a0K000NOPOFOUND')){
                                genResults.writeStringField('ErrorMessage', 'This purchase order does not exist.');
                            }
                            else{
                                genResults.writeStringField('ErrorMessage','Exception:' + errorUpdateMap.get(err));
                            }
                        genResults.writeEndObject();
                    }   
                }

                //NPE C-004384 - Update CreateDistributorInvoice_V1 response when there are PO's in Agency Mode
                //if (agencyModeException != ''){
                    if (agencyModePo != null){
                        for (String po: agencyModePo) {
                            genResults.writeStartObject();
                                genResults.writeStringField('OperationType', 'create');
                                genResults.writeStringField('TechnicalId', '');
                                genResults.writeStringField('FunctionalId', '');
                                genResults.writeBooleanField('Success', false);
                                genResults.writeNullField('Warning');
                                
                                //NPE commented due to case C-004384      
                                //genResults.writeStringField('ErrorMessage','Invoices cannot be created for the following POs in agency mode: ' + agencyModeException.removeEnd(', '));
    
                                //NPE C-004384: Update CreateDistributorInvoice_V1 response when there are PO's in Agency Mode
                                genResults.writeStringField('ErrorMessage','Invoice cannot be created for this PO in agency mode: ' + po);
                            genResults.writeEndObject();
                        }
                    }
            genResults.writeEndArray();


            results = genResults.getAsString();

            return results;
      }catch(Exception ex){
            genResults = JSON.createGenerator(false);
            genResults.writeStartObject();
                genResults.writeStringField('OperationType', 'create');
                genResults.writeNullField('TechnicalId');
                genResults.writeNullField('FunctionalId');
                genResults.writeBooleanField('Success', false);
                genResults.writeNullField('Warning');
                genResults.writeStringField('ErrorMessage','Exception:' + ex.getMessage());
            genResults.writeEndObject();

            results = genResults.getAsString();

            return results;
        }
    }

    class InvoiceDetails{
        public String PurchaseOrderReference;
        public String InvoiceNumber; 
        public String AccountReference;
        public String ExtReference;
        public String InvoiceDate;
        public String InvoiceDueDate;
        public String Type;
        public String Status;
        public Decimal TotalNET;
        public Decimal TotalTTC;
        public Decimal VAT;
        public Boolean PaymentFailed;
    }
}