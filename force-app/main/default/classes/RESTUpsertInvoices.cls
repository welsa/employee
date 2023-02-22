/***************************************************************************************************
Class Name - RESTUpsertInvoices
Version - 1.0
Created Date - 09 JUNE 2016
Function - Class REST to upsert invoice related to its PO/SO sent in the WS

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Ashwina S      09/06/2016     C-001648: Vente réparateur : indiquer le paiement
* Ashutosh B     22/09/2016     C-001728: Added the new function of create attachment
* Ashwina S      28/09/2016     C-001648: if invoice exists in system, update status. 
*                                         if invoice is attached to a SO in request, allow update only
* Ashwina S      19/05/2017     Case C-001904 and C-001926
* Dourga U       11/01/2018     C-002135: Agency Mode V2 
* Vaynee S       23/07/2018     C-002672 : Manage Payment Rejects from Exponens 
* Abdool M       03/09/2018     Community Rollout
* Welsa C        11/10/2018     C-002806 - New flow Exponens for compensated invoices
* Welsa C        30/07/2020     C-003885 - RESTUpsertInvoices error
***************************************************************************************************/
@RestResource(urlMapping='/v1.0/upsertInvoices/*') 
global with sharing class RESTUpsertInvoices {
    static String conversionErrors; 
    static map<String, String> invRefOrderRefMap; 

    @HttpPost
    global static void processResponse() {
        System.debug('########## START METHOD processResponse');
        map<String,String> mapHeaders = new map<String,String>();
        string results = '';
        //retrieve the headers that are received by the request. Synchronous / Asynchronous
        RestRequest req = RestContext.request;
        mapHeaders = req.headers;
               
        //convert the requestbody into a string
        String body = RestContext.request.requestBody.toString();
        system.debug('## body:'+body);
        
        Log__c log = new Log__c();
        log.DateLog__c = system.now();

        // ABT - C-001728 - 22-SEP-2016
        log.Class__c   = 'RESTUpsertInvoices';

        if (body.length() <= 30000){
            log.JSONMessage__c = body;            
        }
        insert log;

        if (body.length() > 30000){
            // ABT - C-001728 - 22-SEP-2016
            //APCreateAttachments.createAttachment(body,log);
            APCreateAttachments.createAttachment('Request', body, log);
        }
        
        if(mapHeaders.containsKey(system.label.CALLTYPE)){
            String cType = mapHeaders.get(system.label.CALLTYPE);
            
            if(system.label.ASYNCHRONOUS == cType){
                log.CallType__c = system.label.ASYNCHRONOUS;
                // call @future method
                upsertInvoiceAsync(log.Id,body);
                results = system.label.MSGASYNCTREATMENT +' '+log.Id;
            }else if(system.label.SYNCHRONOUS == cType){
                log.CallType__c = system.label.SYNCHRONOUS;
                //call synchronous method
                results = upsertInvoiceSync(log.Id,body);
            }
        }
        else{
            log.CallType__c = system.label.SYNCHRONOUS;
            //if no callType in header, by default call synchronous method
            results = upsertInvoiceSync(log.Id,body);
        }

        if(results.contains('Exception')){
            log.Status__c = system.label.STATUSFAILED;
        }
        else{
            log.Status__c = system.label.STATUSPASSED;
        }
        update log;
        RestContext.response.responseBody = Blob.valueOf(results);
        System.debug('########## END METHOD processResponse');
    }

    @future
    public static void upsertInvoiceAsync(Id logId,String body){
        System.debug('########## START METHOD upsertInvoiceAsync');
        //call method that will process json that contains invoices
        string jResp = upsertInvoice(body);
        //call updateLog class
        updateLog(logId,jResp);
        System.debug('########## END METHOD upsertInvoiceAsync');
    }
    
    // call if calltype is sync
    public static string upsertInvoiceSync(Id logId,String body){
        System.debug('########## START METHOD upsertInvoiceSync');
        //call method that will process json that contains invoices
        string jResp = upsertInvoice(body);
        //call updateLog class
        updateLog(logId,jResp);
        System.debug('########## END METHOD upsertInvoiceSync');
        return jResp;       
    }    

    public static String upsertInvoice(String body){
        System.debug('########## START METHOD upsertInvoice');
        // variable
        list<InvoiceDetails> receivedInvoiceList = new list<InvoiceDetails>();
        conversionErrors = '';
        set<String> POSet = new set<String>();
        set<String> SOSet = new set<String>();
        set<String> accountRefSet = new set<String>();
        map<String, PurchaseOrder__c> PONamePOMap = new  map<String, PurchaseOrder__c>();           
        map<String, PrerequisiteOrder__c> SONameSOMap = new  map<String, PrerequisiteOrder__c>();           
        map<String, Account> accNameAccMap = new  map<String, Account>();       
            
        set<Id> POIdSet = new set<Id>();
        set<Id> SOIdSet = new set<Id>();
        map<String, Invoice__c> invoiceRefMap = new map<String, Invoice__c>();
        map<String, list<Invoice__c>> upsertedInvoiceMap = new map<String, list<Invoice__c>>();
        list<Invoice__c> upsertedInvoiceList = new list<Invoice__c>(); 

        // variable when upserting invoices
        map<String,String> successUpdateMap = new map<String,String>();
        map<String,String> errorUpdateMap = new map<String,String>();
        map<String,String> mapExtIdNSFDCID = new map<String,String>();
        String results = null;
        Boolean canCreateInvoice = true;
        String SObjectException = '';
        String noOrderRefException = '';
        String agencyModeException = '';
        invRefOrderRefMap = new map<String, String>(); 

        // generating results
        JSONGenerator genResults;

        //try{
            // deserialize body
            /*JSONParser parser = JSON.createParser(body);            
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            try{
                                //parse block of Invoice into InvoiceDetails
                                InvoiceDetails receivedInvoice = (InvoiceDetails)parser.readValueAsStrict(InvoiceDetails.class);
                                parser.skipChildren();
                                receivedInvoiceList.add(receivedInvoice);
                            }
                            catch(Exception ex){
                                conversionErrors += ex.getMessage() + '-';
                            }
                        }
                    }
                }
            }*/
            
            receivedInvoiceList = (List<InvoiceDetails>)JSON.deserialize(body, list<InvoiceDetails>.class);

            if(receivedInvoiceList.size()>0){
                // loop to build PO, SO and accountRefSet
                for(InvoiceDetails receivedInvoice :receivedInvoiceList){
                    // orderReference returned can be either a PO or SO
                    // build set of PO, SO accordingly
                    String orderReference =  receivedInvoice.OrderReference;
                    if(orderReference!=null){
                        if(orderReference.left(2) == 'PO'){
                            POSet.add(orderReference);          
                        }
                        else if(orderReference.left(2) == 'SO'){
                            SOSet.add(orderReference);          
                        }
                    }
                    
                    // build account set
                    if(receivedInvoice.AccountReference != null){ 
                        accountRefSet.add(receivedInvoice.AccountReference);
                    }
                }// end for loop invoiceObjList
            
                // Query Id from Account, PO and SO
                if(!POSet.isEmpty()){
                    //DUN 11/01/2018  C-002135: Agency Mode V2 change field from AgencyMode__c on assessment to AgencyMode__c on purchase Order
                    list<PurchaseOrder__c> POList = [Select id, Name, Assessment__c
                                                            /* Case C-001904*/ , AgencyMode__c
                                                            , Assessment__r.TECH_EntityCountryCode__c, Distributor__r.ReferenceNumber__c, Distributor__r.ContactUser__c  from PurchaseOrder__c where Name in :POSet];
                    for(PurchaseOrder__c PO: POList){
                        PONamePOMap.put(PO.Name, PO);
                        POIdSet.add(PO.Id);
                    }
                }

                //AMI 03/08/18 : Community Rollout 
                //             : Querying Tech_ContactUserLicenceName__c
                if(!SOSet.isEmpty()){
                    //DUN 11/01/2018  C-002135: Agency Mode V2 commented field from AgencyMode__c on assessment as field is now on purchase Order
                    list<PrerequisiteOrder__c> SOList = [Select id, Name, Assessment__c
                                                            /* Case C-001904, Assessment__r.AgencyMode__c*/
                                                            , Assessment__r.TECH_EntityCountryCode__c, 
                                                            BodyShop__r.ReferenceNumber__c, BodyShop__r.ContactUser__c, 
                                                            BodyShop__r.ContactUser__r.IsActive,
                                                            BodyShop__r.Tech_ContactUserLicenceName__c     
                                                            from PrerequisiteOrder__c 
                                                            where Name in :SOSet];
                    for(PrerequisiteOrder__c SO: SOList){
                        SONameSOMap.put(SO.Name, SO);
                        SOIdSet.add(SO.Id);
                    }
                } 


                if(!accountRefSet.isEmpty()){
                    list<Account> accList = [Select id, ReferenceNumber__c from Account where ReferenceNumber__c in :accountRefSet];
                    for(Account acc: accList){
                        accNameAccMap.put(acc.ReferenceNumber__c, acc);
                    }
                }

                // build map of invoice and status
                if(POIdSet.size() > 0 || SOIdSet.size() > 0){
                    for(Invoice__c invoice: [Select InvoiceReference__c, Status__c, Number__c, OwnerId from Invoice__c where PurchaseOrder__c in :POIdSet or PrerequisiteOrder__c in :SOIdSet]){
                        if(invoice.InvoiceReference__c != null){
                            if(!invoiceRefMap.containsKey(invoice.InvoiceReference__c)){
                                invoiceRefMap.put(invoice.InvoiceReference__c, invoice);
                            } 
                        }          
                    } 
                }               
                
                //AMI 03/09/18 : Community Rollout 
                //             : getting stored custom labels
                string licenseName = string.isNotBlank(system.label.CommunityLicenseName) ? system.label.CommunityLicenseName : '';
                string formattedLicenseName = string.isNotBlank(licenseName) ? licenseName.toLowerCase() : '';
                string contactuserlicence = '';
                id aspisSystemUserId = null;

                if(string.isNotBlank(system.label.UserAspisSystemName)){
                    aspisSystemUserId = [select id,Name from User where Name = :system.label.UserAspisSystemName].Id;
                }

                // loop in invoiceObjList again to create invoice
                for(InvoiceDetails receivedInvoice :receivedInvoiceList){
                    // create Invoice
                    Invoice__c invoice = new Invoice__c();


                    Id POId; 
                    String assessNumber;
                    String invoiceRef;
                    Id SOId;
                    String orderRef = receivedInvoice.OrderReference;  
                    String invoiceNumber = receivedInvoice.InvoiceNumber; 
                    Decimal totalTTCDistributor;   
                    String owner;                 
                    
                    if((PONamePOMap.size() > 0 && PONamePOMap.containsKey(orderRef))|| (SONameSOMap.size() > 0 && SONameSOMap.containsKey(orderRef))){    
                        if(PONamePOMap.containsKey(orderRef)){
                            //DUN 11/01/2018  C-002135: Agency Mode V2 changed field from AgencyMode__c on assessment to AgencyMode__c on purchase Order
                            /* Case C-001904*/if(!PONamePOMap.get(orderRef).AgencyMode__c){
                                POId = PONamePOMap.get(orderRef).Id;
                                assessNumber = PONamePOMap.get(orderRef).Assessment__c;
                                //invoiceRef = PONamePOMap.get(orderRef).Assessment__r.TECH_EntityCountryCode__c+ PONamePOMap.get(orderRef).Distributor__r.ReferenceNumber__c + invoiceNumber;
                                /*C-001926*/invoiceRef = PONamePOMap.get(orderRef).Distributor__r.ReferenceNumber__c + invoiceNumber + orderRef ;
                                totalTTCDistributor = receivedInvoice.TotalTTC;
                                owner = PONamePOMap.get(orderRef).Distributor__r.ContactUser__c;

                                if(!invRefOrderRefMap.containsKey(invoiceRef)){
                                    invRefOrderRefMap.put(invoiceRef, orderRef);
                                }
                            }
                            /* Case C-001904*/else{
                                agencyModeException  += orderRef +', ';  
                                continue;  
                            }                     
                        }
                        else if(SONameSOMap.containsKey(orderRef)){
                            //DUN 11/01/2018  C-002135: Agency Mode V2 removed field from AgencyMode__c on assessment as field is now on purchase Order
                            ///* Case C-001904*/if(!SONameSOMap.get(orderRef).Assessment__r.AgencyMode__c){
                                
                                //AMI 03/09/18 : Community Rollout 
                                //             : getting contact user licence
                                contactuserlicence = 
                                    string.isNotBlank(SONameSOMap.get(orderRef).BodyShop__r.Tech_ContactUserLicenceName__c) ?
                                    SONameSOMap.get(orderRef).BodyShop__r.Tech_ContactUserLicenceName__c : 'fakelicence';

                                SOId = SONameSOMap.get(orderRef).Id;
                                assessNumber = SONameSOMap.get(orderRef).Assessment__c;
                                //invoiceRef = SONameSOMap.get(orderRef).Assessment__r.TECH_EntityCountryCode__c+ SONameSOMap.get(orderRef).BodyShop__r.ReferenceNumber__c  + invoiceNumber;
                                //invoiceRef = SONameSOMap.get(orderRef).BodyShop__r.ReferenceNumber__c  + invoiceNumber;
                                invoiceRef = invoiceNumber;
                                canCreateInvoice = false;
                                if(!invRefOrderRefMap.containsKey(invoiceRef)){
                                    invRefOrderRefMap.put(invoiceRef, orderRef);
                                }
                                //if (SONameSOMap.get(orderRef).BodyShop__r.ContactUser__r.IsActive == true){
                                //owner = SONameSOMap.get(orderRef).BodyShop__r.ContactUser__c;
                                //} else {
                                //    owner = UserInfo.getUserId();
                                //}

                                //AMI 03/09/18 : Community Rollout 
                                //             : Updating Owner to aspis system if and only if bodyshop user has comm licence
                                //owner = SONameSOMap.get(orderRef).BodyShop__r.ContactUser__c;
                                if (SONameSOMap.get(orderRef).BodyShop__r.ContactUser__c != null){
                                    if(string.isBlank(formattedLicenseName) ||
                                       (string.isNotBlank(formattedLicenseName) && 
                                       !formattedLicenseName.contains(contactuserlicence))){
                                        owner = SONameSOMap.get(orderRef).BodyShop__r.ContactUser__c;
                                    }else if(formattedLicenseName.contains(contactuserlicence) &&
                                             aspisSystemUserId != null){
                                        owner = aspisSystemUserId;
                                    }
                                }
                            //}
                            ///* Case C-001904*/else{
                            //    agencyModeException  += orderRef +', ';  
                            //    continue;  
                            //}
                        }                    

                        String status = receivedInvoice.Status; 
                        //WCH 11/10/2018 : C-002806 - New flow Exponens for compensated invoices
                        Integer statusExponens = receivedInvoice.TECH_InvoiceStatusExponens; 
                                                
                        // existing invoices
                        if(invoiceRefMap.containsKey(invoiceRef)){
                            // update status only
                            if(invoiceRefMap.get(invoiceRef).status__c == 'PAYABLE'){
                                invoice.Status__c =  status!= 'PAID'? 'PAYABLE': status;                        
                            } 
                            else if(invoiceRefMap.get(invoiceRef).status__c == 'PAID'){
                                invoice.Status__c =  'PAID';                        
                            } 
                            else{
                                invoice.Status__c =  status;
                            }
                            invoice.InvoiceReference__c = invoiceRef;
                            invoice.Number__c = invoiceRefMap.get(invoiceRef).Number__c;
                            
                            //WCH 30/07/2020 C-003885
                            if(!String.isBlank(owner)){
                                invoice.OwnerId = owner;
                            }
                            //invoice.InvoicePaidDate__c = (receivedInvoice.InvoicePaymentDate != null) ? receivedInvoice.InvoicePaymentDate : null;   
                            //if(receivedInvoice.InvoicePaymentDate != null && receivedInvoice.InvoicePaymentDate != ''){
                            //    invoice.InvoicePaidDate__c = (Date) JSON.deserialize('"' + receivedInvoice.InvoicePaymentDate + '"', Date.class);
                            //} 
                            invoice.InvoicePaidDate__c = (receivedInvoice.InvoicePaymentDate != null && receivedInvoice.InvoicePaymentDate != '') ? (Date) JSON.deserialize('"' + receivedInvoice.InvoicePaymentDate + '"', Date.class) : null; 
                            invoice.EstimatedPaymentDate__c = (receivedInvoice.EstimatedPaymentDate != null && receivedInvoice.EstimatedPaymentDate != '') ? (Date) JSON.deserialize('"' + receivedInvoice.EstimatedPaymentDate + '"', Date.class) : null; 
                            //WCH 11/10/2018 : C-002806 - New flow Exponens for compensated invoices > update TECH_InvoiceStatusExponens__c 
                            invoice.TECH_InvoiceStatusExponens__c= statusExponens;
                        }
                        else{  
                            if(canCreateInvoice && orderRef.left(2) != 'SO'){ 
                                // create invoice                 
                                if(accNameAccMap.containsKey(receivedInvoice.AccountReference)){
                                    invoice.Distributor__c = accNameAccMap.get(receivedInvoice.AccountReference).Id;
                                }
                                invoice.Number__c = invoiceNumber;
                                invoice.Status__c = status;
                                //WCH 11/10/2018 : C-002806 - New flow Exponens for compensated invoices > update TECH_InvoiceStatusExponens__c 
                                invoice.TECH_InvoiceStatusExponens__c= statusExponens;
                                //invoice.Date__c = receivedInvoice.InvoiceDate;                                
                                invoice.Date__c = (receivedInvoice.InvoiceDate != null && receivedInvoice.InvoiceDate != '') ? (Date) JSON.deserialize('"' + receivedInvoice.InvoiceDate + '"', Date.class) : null;                          
                        
                                invoice.Type__c = receivedInvoice.Type.deleteWhitespace();
                                //invoice.DueDateDistributor__c =  receivedInvoice.InvoiceDueDate;
                                invoice.DueDateDistributor__c = (receivedInvoice.InvoiceDueDate != null && receivedInvoice.InvoiceDueDate != '') ? (Date) JSON.deserialize('"' + receivedInvoice.InvoiceDueDate + '"', Date.class) : null;                          
                        
                                
                                invoice.TotalNet__c = receivedInvoice.TotalNET;
                                invoice.VATDistributor__c = receivedInvoice.VAT;   
                                invoice.PurchaseOrder__c = POId;
                                invoice.Assessment__c = assessNumber;
                                invoice.InvoiceReference__c = invoiceRef;
                                invoice.PrerequisiteOrder__c = SOId;  

                                // TODO mapping TotalTTC, ExtReference to replace RESTCreateDistributorInvoice_V1
                                invoice.TotalTTCDistributor__c = totalTTCDistributor;
                                //invoice.InvoicePaidDate__c = (receivedInvoice.InvoicePaymentDate != null) ? receivedInvoice.InvoicePaymentDate : null;
                                
                                invoice.InvoicePaidDate__c = (receivedInvoice.InvoicePaymentDate != null && receivedInvoice.InvoicePaymentDate != '') ? (Date) JSON.deserialize('"' + receivedInvoice.InvoicePaymentDate + '"', Date.class) : null;                          
                                invoice.EstimatedPaymentDate__c = (receivedInvoice.EstimatedPaymentDate != null && receivedInvoice.EstimatedPaymentDate != '') ? (Date) JSON.deserialize('"' + receivedInvoice.EstimatedPaymentDate + '"', Date.class) : null; 
                                invoice.OwnerId = owner;
                                
                            }
                            else{
                                SObjectException += orderRef +', ';   
                            }
                        }   

                        invoice.PaymentFailed__c = receivedInvoice.PaymentFailed;//VSU 19/07/18 C-002672                   

                        if(invoice.InvoiceReference__c != null){
                            if(upsertedInvoiceMap.containsKey(invoice.InvoiceReference__c)){
                                upsertedInvoiceMap.get(invoice.InvoiceReference__c).add(invoice);
                            }
                            else{
                                List<Invoice__c> invList = new List<Invoice__c>();
                                invList.add(invoice);
                                upsertedInvoiceMap.put(invoice.InvoiceReference__c,invList);
                            }
                        }
                        canCreateInvoice = true;
                    }
                    else{
                        //invoice.PurchaseOrder__c = 'a0K000NOORFOUND';
                        //invoice.InvoiceReference__c = orderRef; 
                        //POId = 'a0K000NOORFOUND';                        
                        //invoiceRef= orderRef; 
                        noOrderRefException  += orderRef +', ';   
                    } 
                }// end for loop in invoiceObjList again to create invoice
                for (String invRef : upsertedInvoiceMap.keySet()){
                    List<Invoice__c> invList =  new List<Invoice__c>(); 
                    invList = upsertedInvoiceMap.get(invRef);

                    if (!invList.isEmpty()){
                        upsertedInvoiceList.add(invList[0]);     
                    }
                }
                system.debug('## upsertedInvoiceList:'+upsertedInvoiceList.size());
                
                // upserting list of invoices
                if(!upsertedInvoiceList.isEmpty()){
                    Schema.SObjectField externalField = Invoice__c.Fields.InvoiceReference__c;
                    List<Database.UpsertResult> uResults = Database.upsert(upsertedInvoiceList,externalField,false);

                    // looping in results to separate sucess and errors
                    for(Integer idx = 0; idx < uResults.size(); idx++) {
                        if(uResults[idx].isSuccess()) {
                            successUpdateMap.put(upsertedInvoiceList[idx].InvoiceReference__c, 'Success Update');
                            mapExtIdNSFDCID.put(upsertedInvoiceList[idx].InvoiceReference__c,uResults[idx].getId());
                        }
                        else{
                            for(Database.Error err : uResults[idx].getErrors()){
                               errorUpdateMap.put(upsertedInvoiceList[idx].InvoiceReference__c, system.label.Error+':'+err.getMessage());
                            }
                        }
                    }
                } // end if upsertedInvoiceList
            }
         
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
                }

                //system.debug('## conversionErrors:'+conversionErrors);
                //if(conversionErrors != ''){
                //    conversionErrors = conversionErrors.removeEnd('-');
                //    genResults.writeStartObject();
                //        genResults.writeStringField('OperationType', 'upsert');
                //        genResults.writeStringField('TechnicalId', '');
                //        genResults.writeStringField('FunctionalId', '');
                //        genResults.writeBooleanField('Success', false);
                //        genResults.writeNullField('Warning');
                //        genResults.writeStringField('ErrorMessage','Exception:' + conversionErrors);
                //    genResults.writeEndObject();
                //}

                if (errorUpdateMap.size()> 0){
                    for(String err : errorUpdateMap.keySet()){
                        genResults.writeStartObject();
                            genResults.writeStringField('OperationType', 'upsert');
                            genResults.writeStringField('TechnicalId', '');
                            genResults.writeStringField('FunctionalId', err);
                            genResults.writeStringField('OrderNumber', invRefOrderRefMap.get(err));
                            genResults.writeBooleanField('Success', false);
                            genResults.writeNullField('Warning');
                            //genResults.writeStringField('ErrorMessage','Exception:' + errorUpdateMap.get(err));
                            //if(errorUpdateMap.get(err).contains('a0K000NOORFOUND')){
                            //    genResults.writeStringField('ErrorMessage', 'No Order Reference found for this invoice.');
                            //}
                            //else{
                                genResults.writeStringField('ErrorMessage','Exception:' + errorUpdateMap.get(err));
                           //}
                        genResults.writeEndObject();
                    }   
                }
                
                if (SObjectException != ''){
                    genResults.writeStartObject();
                        genResults.writeStringField('OperationType', 'create');
                        genResults.writeStringField('TechnicalId', '');
                        genResults.writeStringField('FunctionalId', '');
                        genResults.writeBooleanField('Success', false);
                        genResults.writeNullField('Warning');
                        genResults.writeStringField('ErrorMessage','Invoices cannot be created for the following Sales Order: ' + SObjectException.removeEnd(', '));
                    genResults.writeEndObject();
                }

                if (noOrderRefException!= ''){
                    genResults.writeStartObject();
                        genResults.writeStringField('OperationType', 'create');
                        genResults.writeStringField('TechnicalId', '');
                        genResults.writeStringField('FunctionalId', '');
                        genResults.writeBooleanField('Success', false);
                        genResults.writeNullField('Warning');
                        genResults.writeStringField('ErrorMessage','No Order Reference found for the following invoices: ' + noOrderRefException.removeEnd(', '));
                    genResults.writeEndObject();
                }
                //DUN 11/01/2018  C-002135: Agency Mode V2 removed 'and SOs ' in error message
                /* Case C-001904*/if (agencyModeException != ''){
                   genResults.writeStartObject();
                       genResults.writeStringField('OperationType', 'create');
                       genResults.writeStringField('TechnicalId', '');
                       genResults.writeStringField('FunctionalId', '');
                       genResults.writeBooleanField('Success', false);
                       genResults.writeNullField('Warning');
                       genResults.writeStringField('ErrorMessage','Invoices cannot be created for the following POs in agency mode: ' + agencyModeException.removeEnd(', '));
                   genResults.writeEndObject();
                   /* Case C-001904*/
                }
            genResults.writeEndArray();
            results = genResults.getAsString();            
        //}
        //catch(Exception ex){
        //    genResults = JSON.createGenerator(false);
        //    genResults.writeStartObject();
        //        genResults.writeStringField('OperationType', 'create');
        //        genResults.writeNullField('TechnicalId');
        //        genResults.writeNullField('FunctionalId');
        //        genResults.writeBooleanField('Success', false);
        //        genResults.writeNullField('Warning');
        //        genResults.writeStringField('ErrorMessage','Exception:' + ex.getMessage());
        //    genResults.writeEndObject();

        //    results = genResults.getAsString();            
        //}
        System.debug('########## START METHOD upsertInvoice');        
        return results;
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

    class InvoiceDetails{
        public string OrderReference;       
        public string InvoiceNumber;
        public string AccountReference;
        public String InvoiceDate;
        public String InvoiceDueDate;
        public String InvoicePaymentDate;
        public String EstimatedPaymentDate;
        public string Type;
        public string Status;
        public Decimal TotalNET;
//        public Decimal TotalVAT;
        public Decimal VAT;     

        // used to replace RESTCreateDistributorInvoice_V1
        // TODO mapping with Invoice__c fields
        public Decimal TotalTTC;
        public string ExtReference; 
        public Boolean PaymentFailed; 

        //WCH 11/10/2018 : C-002806 - New flow Exponens for compensated invoices
        public Integer TECH_InvoiceStatusExponens;
    }
}