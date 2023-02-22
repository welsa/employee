/*************************************************************************************
Class Name - ASPISUpdatePiecPOOrderLines
Version - 1.0
Created Date - 08 FEB 2023
Function - PREv2 Connected - Lot 4 - Order Treatment. Allow a connected Distributor to update only one part of his PO

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Rayhaan B       08/02/2023     Initial Version
*************************************************************************************/
@RestResource(urlMapping='/v2.0/updatePiecPurchaseOrder/*') 
global without sharing class ASPISUpdatePiecPOOrderLines {
    static Map<String,String> mapRespondStatus     = new Map<String,String> {'CONFIRMED' => 'INDELIVERY', 'REFUSED' => 'CANCELED'};

    @HttpPost   
    global static void execute() {        
        RestRequest req                         = RestContext.request;
        Map<String, String> mapHeaders          = req.headers;
        String body                             = '';
        string results                          = '';
        String fakeLog                          = System.label.ASPISUpdatePiecPOOrderLines_Fake_Log;
        List<Log__c> logResponse;

        if (fakeLog != 'none' && fakeLog.StartsWith('a0D')){
            logResponse = [SELECT id,JSONMessage__c, JSONResponse__c FROM Log__c WHERE Id = :fakeLog];
            if (logResponse[0] != null && logResponse[0].JSONMessage__c != null)
                body = logResponse[0].JSONMessage__c;
        }        
        else{ 
            if(req.requestBody != null && String.isNotBlank(req.requestBody.toString()))
                body = req.requestBody.toString();
        }

        //getInstance requires api version 56.0
        ConfigurationFlux__mdt fluxConfig   = ConfigurationFlux__mdt.getInstance('ASPISUpdatePiecPOOrderLines');            

        String callType                             = mapHeaders.containsKey(System.label.CALLTYPE) ? mapHeaders.get(System.label.CALLTYPE) : '';
        if(callType == System.label.ASYNCHRONOUS){
            // wrapperLog.CallType    = System.label.ASYNCHRONOUS;
            //results                      = System.label.MSGASYNCTREATMENT + ' ' + log.Id;
        }else if(callType == System.label.SYNCHRONOUS || String.isBlank(callType)){
            // wrapperLog.CallType  = System.label.SYNCHRONOUS;
            if(fluxConfig != null && fluxConfig.Runnable__c){
                results = updateOrderLines(body);
            }else{
                results = '{"Success":false,"OrderReference":"Null","ErrorMessage":"Error: Flux is not Runnable"}';
            }
        }
        
        if(fluxConfig.CreateLog__c){
            APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
            if(String.isNotBlank(body)){
                if (body.length() <= 30000) 
                    wrapperLog.jsonmessage = body;
                else
                    wrapperLog.attachmentRequestbody = body;
            } 
            wrapperLog.className                = 'ASPISUpdatePiecPOOrderLines';
            wrapperLog.sobjectName              = 'PurchaseOrder__c';            
            wrapperLog.inout                    = 'Inbound';
            wrapperLog.CallType                 = String.isNotBlank(callType) ? callType : System.label.SYNCHRONOUS;
            wrapperLog.jsonresponse             = results;
            APManageLogs.createWsLogFuture(JSON.serialize(wrapperLog), 'insert');
        }
            
        RestContext.response.responseBody = Blob.valueOf(results);
    }

    public static String updateOrderLines(string requestBody){
        JSONWrapper deserializeRequest;
        JSONWrapper deserializeResponse = new JSONWrapper();
        try{
            deserializeRequest = (JSONWrapper) JSON.deserialize(requestBody,JSONWrapper.class);
            System.debug('## deserializeRequest: '+ deserializeRequest);

            //DistributorOrderReference => (Map DistributorReference => Orderline)
            Map<String,Map<String,Orderline__c>> mapDistSentOl = deserializeRequest.buildMapDistOrderRefOl();           
            System.debug('## mapDistSentOl: '+ mapDistSentOl);

            //DistributorOrderReference => (Map DistributorReference => Orderline)
            Map<String,Map<String,Orderline__c>> mapPoOrderLine = buildMapPOOrderline(mapDistSentOl.keyset(), deserializeRequest.PurchaseOrders[0].DistributorCode); 
            System.debug('## mapPoOrderLine: '+ mapPoOrderLine);
            
            List<Offer__c>  lstOfferToUpdate        = new List<Offer__c>();    
            List<Orderline__c> lstOrderlineToUpdate = new List<Orderline__c>();
            // List<PurchaseOrder__c> lstPOToProcess = new List<PurchaseOrder__c>();
            List<PurchaseOrder__c> lstPOToRespond   = new List<PurchaseOrder__c>();
            Set<Id> setPOSendMail                   = new Set<Id>();

            //Loop over PurchaseOrders sent by distributor
            for(String orderRef : mapDistSentOl.keyset()){
                Integer numRespondedOl          = 0;
                PurchaseOrders respPO           = new PurchaseOrders(orderRef);
                // Boolean cancelPO                = true;
                Boolean respondPO = false;
                Boolean sendMailPO = false;
                //If the distributor sent a DistributorOrderReference which does not match with any POs found from the query
                if(mapPoOrderLine.containsKey(orderRef)){
                    PurchaseOrder__c currentPO  = mapPoOrderLine.get(orderRef).values()[0].PurchaseOrder__r;            
                    if(currentPO.Status__c == 'DRAFTQUOTE'){
                        respPO.Lines  = new List<Lines>();
                        //Loop over Orderlines sent in request
                        for(String disRef : mapDistSentOl.get(orderRef).keyset()){
                            if(mapPoOrderLine.get(orderRef).containsKey(disRef)){        
                                Orderline__c receivedOl = mapDistSentOl.get(orderRef).get(disRef);   
                                Orderline__c olToUpdate = mapPoOrderLine.get(orderRef).get(disRef);                    
                                if(mapRespondStatus.containsKey(receivedOl.DeliveryStatus__c)){
                                    //DistributorReference and Status are valid, update OL and Offer values
                                    processOrderline(olToUpdate, receivedOl);
                                    lstOrderlineToUpdate.add(olToUpdate);
                                    lstOfferToUpdate.add(new Offer__c(Id = olToUpdate.Offers__r[0].Id, DeliveryStatus__c = olToUpdate.DeliveryStatus__c));                    
                                    respPO.addSuccessLine(disRef, receivedOl.DeliveryStatus__c);
                                }
                                else{   //If the distributor sent an unrecognised status for an OL
                                    System.debug('##Invalid Status:' + receivedOl.DeliveryStatus__c);    
                                    respPO.addErrorLine(disRef, 'Invalid Status: ' + receivedOl.DeliveryStatus__c);
                                }
                            }
                            else{ //If the distributor sent a distributor reference which does not match with any OLs found from the query
                                System.debug('##Invalid Distributor Reference:' + disRef);
                                respPO.addErrorLine(disRef, 'Invalid Distributor Reference');   
                            }
                        }//Looping over orderlines done

                        //Loop over all Ols in PO
                        for(Orderline__c ol : mapPoOrderLine.get(orderRef).values()){
                            if(mapRespondStatus.values().contains(ol.DeliveryStatus__c)){
                                //Ol was responded
                                numRespondedOl++;
                                if(ol.DeliveryStatus__c == 'INDELIVERY'){
                                    //Tag PO to be updated if one Ol is INDELIVERY, if all OLs are responded
                                    respondPO = true;
                                }
                                if(ol.DeliveryStatus__c == 'CANCELED'){
                                    //Tag PO to send mail if one OL is canceled, if all OLs are responded
                                    sendMailPO = true;
                                }
                            }
                        }                       
                        System.debug('## PO: '+ orderRef + ' Ol Responded: ' + numRespondedOl + '/' + mapPoOrderLine.get(orderRef).size());
                        //If all Ols in the PO have been processed
                        if(numRespondedOl == mapPoOrderLine.get(orderRef).size()){
                            if(sendMailPO){
                                System.debug('## Cancel PO');
                                setPOSendMail.add(currentPO.Id);
                            }
                            if(respondPO){
                                System.debug('## Set PO to responded');
                                lstPOToRespond.add(currentPO);
                            }
                        }
                        respPO.Success = true;
                        deserializeResponse.PurchaseOrders.add(respPO);   
                    }
                    else{
                        System.debug('##Invalid Purchase order status:' + currentPO.Status__c);
                        deserializeResponse.addErrorPO(orderRef, 'Current purchase order status must be DRAFTQUOTE. Invalid Purchase order status:' + currentPO.Status__c);
                    }
                }
                else{
                    System.debug('##Invalid order reference:' + orderRef);
                    deserializeResponse.addErrorPO(orderRef,'Invalid order reference');
                }
            } //Looping over POs done

            System.debug('## lstOrderlineToUpdate: '+ lstOrderlineToUpdate);            
            System.debug('## lstOfferToUpdate: '    + lstOfferToUpdate);
            try{
                //Update PO and Offers
                update lstOfferToUpdate;
                update lstOrderlineToUpdate;                   
                if(lstPOToRespond.size() > 0){
                    System.debug('## lstPOToRespond: '       + lstPOToRespond);
                    Map<String,Object> mapInput = new Map<String,Object>();
                    mapInput.put('ObjectJSON',JSON.serialize(lstPOToRespond));
                    mapInput.put('FieldToUpdate','Status__c');
                    mapInput.put('Value', ASPISConstants.PUR_ORDER_STATUS_RESPONDED);
                    ASPISWithoutSharingExceptions.updateObjectField(mapInput);
                }

                if(setPOSendMail.size() > 0){
                    System.debug('## setPOSendMail '+ setPOSendMail);
                    AP53SendEmailConnectedEDistributor.sendPOCancellationEmail(setPOSendMail);
                }
            }
            catch(DMLException de)
            {
                System.debug(de.getMessage());
                deserializeResponse.errorMessage = 'Error in updating Records: ' + de.getMessage() + de.getStackTraceString();
            }
        }
        catch(Exception e){
            deserializeResponse.errorMessage = 'Error in request: ' + e.getMessage() + e.getStackTraceString();
        }
        return JSON.serialize(deserializeResponse, true); //suppressApexObjectNulls
    }

    public static void processOrderline(Orderline__c ol, Orderline__c receivedOl){
        ol.DeliveryStatus__c = mapRespondStatus.get(receivedOl.DeliveryStatus__c);        
        ol.Suppliable__c     = (ol.DeliveryStatus__c == 'INDELIVERY' ? 'YES' : 'NO');
        if(ol.DeliveryStatus__c == 'CANCELED')
            ol.CancelReason__c   = 'No stock/quality defect';        
    }

    //Get Orderlines Where the DistributorOrderReference matches those sent in the request. 
    //Get also the PurchaseOrder and the Offers related to the OLs and build a map in the same format as mapDistSenOl
    public static Map<String,Map<String,Orderline__c>> buildMapPOOrderline(Set<String> setOrderRef, String disCode){
        Map<String,Map<String,Orderline__c>> mapPoOrderLine = new Map<String,Map<String,Orderline__c>>();  
        for(Orderline__c ol : [SELECT DistributorReference__c, DeliveryStatus__c, Suppliable__c,CancelReason__c,
                                    PurchaseOrder__r.DistributorOrderReference__c, PurchaseOrder__r.Status__c, 
                                    PurchaseOrder__r.Assessment__r.BodyShop__r.Name, PurchaseOrder__r.Assessment__r.BodyShop__r.ContactUser__r.Email, PurchaseOrder__r.Assessment__r.BodyShop__r.ContactUser__c,
                                    (SELECT Id, DeliveryStatus__c FROM Offers__r) 
                                    FROM Orderline__c 
                                    WHERE OrderType__c = 'final' AND PurchaseOrder__r.DistributorOrderReference__c IN :setOrderRef AND PurchaseOrder__r.Distributor__r.Tech_Distributor__c = :disCode]){
                if(!mapPoOrderLine.containskey(ol.PurchaseOrder__r.DistributorOrderReference__c))
                    mapPoOrderLine.put(ol.PurchaseOrder__r.DistributorOrderReference__c, new Map<String,Orderline__c>());
                mapPoOrderLine.get(ol.PurchaseOrder__r.DistributorOrderReference__c).put(ol.DistributorReference__c,ol);                                
            }
        return mapPoOrderLine;
    }

    public class JSONWrapper {
        public List<PurchaseOrders> PurchaseOrders; 
        public String errorMessage;
        //Constructor for response
        public JSONWrapper (){
            PurchaseOrders = new List<PurchaseOrders>();
        }

        public void addErrorPO(String orderRef, String ErrorMessage){
            PurchaseOrders p = new PurchaseOrders(orderRef);
            p.Success  = false;
            p.ErrorMessage = ErrorMessage;
            PurchaseOrders.add(p);
        }

        //Create Orderlines from the lines object, and build a map of DistributorOrderReference to a map of DistributorReferense to Orderline
        Map<String,Map<String,Orderline__c>> buildMapDistOrderRefOl(){
            Map<String,Map<String,Orderline__c>> mapDistSentOl = new Map<String,Map<String,Orderline__c>> ();
            for(PurchaseOrders p : PurchaseOrders){
                if(!mapDistSentOl.containsKey(p.DistributorOrderReference))
                    mapDistSentOl.put(p.DistributorOrderReference, new  Map<String,Orderline__c>());
                for(Lines line : p.lines){
                    mapDistSentOl.get(p.DistributorOrderReference).put(line.DistributorReference,new Orderline__c(DistributorReference__c   = line.DistributorReference, 
                                                                                                                  DeliveryStatus__c         = line.Status,
                                                                                                                  CancelReason__c           = line.CancellationReason));
                } 
            }
            return mapDistSentOl;
        }        
    }    

    public class PurchaseOrders{
        public String DistributorCode;
        public String DistributorOrderReference;
        public String Status;
        public List<Lines> Lines;

        //For Response
        public String OrderReference;
        public Boolean Success;
        public String ErrorMessage;

        public PurchaseOrders(String OrderReference){
            this.OrderReference = OrderReference;
        }

        public PurchaseOrders(String OrderReference, Boolean Success, String ErrorMessage){
            this.OrderReference = OrderReference;
            this.Success        = Success;
            this.ErrorMessage   = ErrorMessage;
        }

        public void setError(String ErrorMessage){
            this.Success      = false;
            this.ErrorMessage = ErrorMessage;
        }

        public void addErrorLine(String disRef, String errMsg){
            Lines line          = new Lines(disRef);
            line.Success        = false;
            line.ErrorMessage   = errMsg;
            Lines.add(line);
        }

        public void addSuccessLine(String disRef, String status){
            Lines line      = new Lines(disRef);
            line.Success    = true;
            line.Status     = status;
            Lines.add(line);
        }
    }

    public class Lines{
        public String DistributorReference;
        public String Status;
        public String CancellationReason;

        //For response
        public Boolean Success;
        public String errorMessage;

        public Lines (String DistributorReference){
            this.DistributorReference = DistributorReference;
        }
    }
}