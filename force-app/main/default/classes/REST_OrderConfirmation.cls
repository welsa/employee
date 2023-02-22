public class REST_OrderConfirmation {

    public static void sendConfirmationBulk(map<String,String> mapOrderConfirmationAsync,map<String,String> mapOrderConfirmationSync){

        if (mapOrderConfirmationAsync != null && mapOrderConfirmationAsync.size() > 0){
            for (String poId : mapOrderConfirmationAsync.keyset()){
                sendConfirmationFuture(poId, mapOrderConfirmationAsync.get(poId));
            }
        }

        if (mapOrderConfirmationSync != null && mapOrderConfirmationSync.size() > 0){
            for (String poId : mapOrderConfirmationSync.keyset()){
                sendConfirmation(poId, mapOrderConfirmationSync.get(poId));
            }
        }
        
        

    }


    @Future(callout=true)
    public static void sendConfirmationFuture(Id poID,string poName){
        sendConfirmation(poID, poName);
    }

    public static void sendConfirmation(Id poID,string poName){

        System.debug('---------------------------------- START REST_OrderConfirmation - sendConfirmation ----------------------------------');

        datetime qryStart = datetime.now();
        // String body = RestContext.request.requestBody.toString();
        // variables
        String jsonResponse= ''; 
        String jsonmessage= ''; 
        PurchaseOrder__c poToUpdate;
        
        if(poID != null ){

            try {
                map<String, Object> mapInputParams = new map<String, Object>();
                mapInputParams.put('poID',poID );

                map<String, Object> mapOutParams = buildOrderConfirmation(mapInputParams);

                jsonmessage =  mapOutParams.containskey('jsonmessage') ? (String) mapOutParams.get('jsonmessage') : null;
                Id assessId =  mapOutParams.containskey('Assessment') ? (Id) mapOutParams.get('Assessment') : null;

                mapInputParams.put('jsonmessage',jsonmessage );
                mapInputParams.put('Assessment',assessId );
                system.debug('@@ assessId: '+assessId);



                if (String.IsNotBlank(jsonmessage)){
                    // jsonResponse = doCallout(jsonmessage,poID);
                    mapOutParams = doCallout(mapInputParams);
                    jsonResponse =  mapOutParams.containskey('jsonResponse') ? (String) mapOutParams.get('jsonResponse') : null;

                }
                system.debug('@@ jsonResponse: '+jsonResponse);
                
            }
            catch(Exception e){
                jsonResponse =  'Exceptions: ' + e.getMessage() + '.  Stack Trace : ' + e.getStackTraceString();
            }

            APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
            wrapperLog.className = 'REST_OrderConfirmation';
            wrapperLog.objectreference = poName;
            wrapperLog.sobjectid = poID;
            wrapperLog.jsonmessage = jsonmessage;
            wrapperLog.sobjectName = 'PurchaseOrder__c';
            wrapperLog.jsonresponse = jsonResponse != null && jsonResponse.length() <= 30000 ? jsonResponse : '';
            // wrapperLog.wsdate = lastCallOut;
            // wrapperLog.wserrormessage = distErrorMsg;
            wrapperLog.inout = 'Inbound;Outbound';
            // wrapperLog.systemcalling = systemCallingAss;
            // wrapperLog.wsRequest = wsRequestCallout;
            // wrapperLog.wSResponse = wSResponseCallout;
            //wrapperLog.TraceVariablesNena = traceVariables;

            if(jsonResponse != null && (jsonResponse.contains('Exceptions') || (jsonResponse.contains('Error') && !jsonResponse.contains('"ErrorMessage":null')))){
                wrapperLog.status = Label.STATUSFAILED;
            }
            else{
                wrapperLog.status = Label.STATUSPASSED;
            }  

            // if(body.length() > 30000){
            //     wrapperLog.attachmentRequestbody = body;
            // }

            if(jsonResponse != null && jsonResponse.length() > 30000){
                wrapperLog.attachmentResponsebody = jsonResponse;
            }  
            datetime qryEnd = datetime.now();
            // Decimal heapsize2 = Limits.getHeapSize() ;
            // system.debug('@@@ heapsize End: '+heapsize2);

            decimal tempExec = (qryEnd.getTime() - qryStart.getTime());
            tempExec = (tempExec.divide(1000, 5));


            wrapperLog.executionTime = tempExec;
            
            // system.debug('@@@ qryEnd: '+qryEnd);
            // system.debug('@@@ tempExec: '+tempExec);
            //system.debug('@@ total'+ (qryEnd.getTime() - qryStart.getTime()) );

            //RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
            APManageLogs.createWsLog(wrapperLog, 'insert');

        }

        // RestContext.response.responseBody = Blob.valueOf(jsonResponse);
        
        System.debug('---------------------------------- END REST_OrderConfirmation - sendConfirmation ----------------------------------');


    }

    public static map<String, Object> buildOrderConfirmation(map<String, Object> mapInputParams ){

        map<PurchaseOrder__c, List<Offer__c>> mapPOandOls = new map<PurchaseOrder__c, List<Offer__c>>();
        Map<Id,PurchaseOrder__c> mapPO = new map<Id,PurchaseOrder__c>();
        map<Id, Offer__c> mapOrderlineOriginal = new map<Id, Offer__c>();
        Map<String,String> mapAccIdAcccRef = new map<String,String>();
        set<String> setBdIds = new set<String>();

        //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS
        String response = '';
        Boolean doOrderConfirmation = true;
        map<String, Object> mapOutParams = new map<String, Object>();
        Id po = mapInputParams.containskey('poID') ? (Id) mapInputParams.get('poID') : null;
        String distName = '';


        for (PurchaseOrder__c POs: [Select Id, Assessment__r.InsBrokerNumber__c, Assessment__r.AssessmentID__c,BodyShopOrderNumber__c, Name, PrerequisiteOrder__c, DistributorName__c,AutoValidate_PO__c,Assessment__c,
                                            AgencyMode__c,DistributorPOReference__c,Assessment__r.BodyShop__r.Id,PrerequisiteOrder__r.Name
                                    From PurchaseOrder__c
                                    Where Id = :po]){
            mapPO.put(POs.Id, POs);   
            if (String.IsNotBlank(POs.Assessment__r.BodyShop__r.Id)){
                setBdIds.add(String.valueOf(POs.Assessment__r.BodyShop__r.Id).substring(0, 15));   
            }    

            if (Pos.AutoValidate_PO__c){
                doOrderConfirmation = false;
            }

            mapOutParams.put('Assessment',POs.Assessment__c );    
            distName = POs.DistributorName__c;                   
        }
        system.debug('@@@ doOrderConfirmation: '+doOrderConfirmation);
        if (doOrderConfirmation){

            for (AccountRef__c  accref: [SELECT ExternalReference__c,InternalReference__c FROM AccountRef__c WHERE InternalReference__c in :setBdIds]){
                mapAccIdAcccRef.put(accref.InternalReference__c, accref.ExternalReference__c);
            }

            for (Offer__c off: [Select Id,Quantity__c,PartNUmber__c,OrderLine__r.PartList__r.Id, OrderLine__r.PartList__r.Description__c,CataloguePrice__c, Discount__c,OrderLine__r.PurchaseOrder__c,ExpectedDeliveryDuration__c,OrderLine__r.ExpectedDeliveryDuration__c,Description__c,
                                        OrderLine__r.AcceptedCheck__c, OrderLine__r.TechOLType__c, OrderLine__r.OriginalItem__r.PartNUmber__c, OrderLine__r.OriginalItem__r.Description__c,OrderLine__r.Description__c,OrderLine__r.Suppliable__c,OrderLine__r.OrderType__c, OrderLine__r.AlphaScaleMRID__c,
                                        OrderLine__r.OriginalItem__r.AlphaScaleMRID__c
                                    from Offer__c
                                    Where OrderLine__r.PurchaseOrder__c in :mapPO.keyset() 
                                    and OrderLine__r.OrderType__c = 'FINAL']){

                if ( (off.OrderLine__r.AcceptedCheck__c == true && off.OrderLine__r.Suppliable__c == 'YES')
                    || (off.OrderLine__r.AcceptedCheck__c == false && off.OrderLine__r.Suppliable__c == 'NO') ){

                    if (off.OrderLine__r.TechOLType__c == 'replacement' && off.OrderLine__r.OriginalItem__c != null && off.OrderLine__r.OrderType__c == 'FINAL'){

                        mapOrderlineOriginal.put(off.OrderLine__c, off);

                    }
                    system.debug('Off'+off);
                    if (mapPOandOls.containskey(mapPO.get(off.OrderLine__r.PurchaseOrder__c))){
                        mapPOandOls.get(mapPO.get(off.OrderLine__r.PurchaseOrder__c)).add(off);

                    }
                    else{
                        mapPOandOls.put(mapPO.get(off.OrderLine__r.PurchaseOrder__c), new list<Offer__c> {off});
                    }
                }
                
            }


            system.debug('@@ mapPO: '+mapPO);
            system.debug('@@ setBdIds: '+setBdIds);
            system.debug('@@ mapAccIdAcccRef: '+mapAccIdAcccRef);
            system.debug('@@ mapOrderlineOriginal: '+mapOrderlineOriginal);
            system.debug('@@ mapPOandOls: '+mapPOandOls);

            JSONGenerator genResults = JSON.createGenerator(false);

            genResults.writeStartObject();
                genResults.writeFieldName('Assessments');
                    genResults.writeStartArray();
                    for (PurchaseOrder__c POs: mapPOandOls.keyset()){
                        genResults.writeStartObject();
                        system.debug('@@ POs.Assessment__r.BodyShop__r.Id: '+POs.Assessment__r.BodyShop__r.Id);

                        genResults.writeStringField('BSReferenceNumber', POs.Assessment__r.BodyShop__r.Id != null && mapAccIdAcccRef.containskey(String.valueOf(POs.Assessment__r.BodyShop__r.Id).substring(0,15)) ? mapAccIdAcccRef.get(String.valueOf(POs.Assessment__r.BodyShop__r.Id).substring(0,15)) : '');
                        genResults.writeStringField('InsBrokerNumber', String.IsNotBlank(POs.Assessment__r.InsBrokerNumber__c) ? POs.Assessment__r.InsBrokerNumber__c : '');
                        genResults.writeStringField('AssessmentID', String.IsNotBlank(POs.Assessment__r.AssessmentID__c) ? POs.Assessment__r.AssessmentID__c : '');
                        genResults.writeStringField('BodyShopOrderReference', String.IsNotBlank(POs.BodyShopOrderNumber__c) ? POs.BodyShopOrderNumber__c : '');
                        genResults.writeStringField('PO', String.IsNotBlank(POs.Name) ? POs.Name : '');
                        genResults.writeStringField('SO', String.IsNotBlank(POs.PrerequisiteOrder__r.Name) ? POs.PrerequisiteOrder__r.Name : '');
                        genResults.writeBooleanField('AgencyMode', POs.AgencyMode__c != null ? POs.AgencyMode__c : false);
                        genResults.writeStringField('Distributor',String.IsNotBlank(POs.DistributorName__c) ? POs.DistributorName__c : '');
                        genResults.writeStringField('DistributorOrderNumber', String.IsNotBlank(POs.DistributorPOReference__c) ? POs.DistributorPOReference__c : '');
                    
                        genResults.writeFieldName('Parts');
                            genResults.writeStartArray();
                                
                                for (Offer__c off: mapPOandOls.get(POs) ){
                                    genResults.writeStartObject();
                                        genResults.writeNumberField('Quantity', off.Quantity__c != null ? off.Quantity__c : 0);
                                        genResults.writeStringField('PartNumber', String.IsNotBlank(off.PartNUmber__c) ? off.PartNUmber__c : '');
                                        // genResults.writeStringField('ID', String.IsNotBlank(off.OrderLine__r.Id) ? off.OrderLine__r.Id : '');
                                        genResults.writeStringField('ID', String.IsNotBlank(off.OrderLine__r.OriginalItem__r.Id) ? off.OrderLine__r.OriginalItem__r.Id : String.IsNotBlank(off.OrderLine__r.Id) ? off.OrderLine__r.Id : '');
                                        genResults.writeStringField('Description',off.OrderLine__r.Description__c != null ? off.OrderLine__r.Description__c : '');
                                        genResults.writeNumberField('Price', off.CataloguePrice__c != null ? off.CataloguePrice__c : 0);
                                        genResults.writeNumberField('Discount', off.Discount__c != null ? off.Discount__c : 0);
                                        genResults.writeStringField('DistributorStatus', off.OrderLine__r.AcceptedCheck__c != null ?  off.OrderLine__r.AcceptedCheck__c ? 'Accepted' : 'Rejected' : 'Rejected' );
                                        genResults.writeStringField('DistributorAction', String.IsNotBlank(off.OrderLine__r.TechOLType__c) ? off.OrderLine__r.TechOLType__c : '');
                                        if (String.IsNotBlank(off.OrderLine__r.ExpectedDeliveryDuration__c)){
                                            genResults.writeNumberField('Delay', String.IsNotBlank(off.OrderLine__r.ExpectedDeliveryDuration__c) ? Integer.valueOf(off.OrderLine__r.ExpectedDeliveryDuration__c) : 0);
                                        }
                                        if ( String.IsNotBlank(off.OrderLine__r.TechOLType__c) && off.OrderLine__r.TechOLType__c == 'replacement' && mapOrderlineOriginal.containskey(off.OrderLine__r.Id)){
                                            genResults.writeStringField('OldPartNumber',String.IsNotBlank(mapOrderlineOriginal.get(off.OrderLine__c).OrderLine__r.OriginalItem__r.AlphaScaleMRID__c) ? mapOrderlineOriginal.get(off.OrderLine__c).OrderLine__r.OriginalItem__r.AlphaScaleMRID__c : String.IsNotBlank(mapOrderlineOriginal.get(off.OrderLine__c).OrderLine__r.OriginalItem__r.PartNUmber__c) ? mapOrderlineOriginal.get(off.OrderLine__c).OrderLine__r.OriginalItem__r.PartNUmber__c : '');
                                            genResults.writeStringField('OldDescription',String.IsNotBlank(mapOrderlineOriginal.get(off.OrderLine__c).OrderLine__r.OriginalItem__r.Description__c) ? mapOrderlineOriginal.get(off.OrderLine__c).OrderLine__r.OriginalItem__r.Description__c : '');

                                        }
                                    genResults.writeEndObject();
                                }
                    
                            genResults.writeEndArray();
                        genResults.writeEndObject();

                    }
                    genResults.writeEndArray();                            
                    // genResults.writeStringField('Message', ErrorMessage);
            genResults.writeEndObject();   

            system.debug('@@ genResults: '+genResults.getAsString()); 

            response =  genResults.getAsString();
            mapOutParams.put('jsonmessage',response);

        }
        else{
            response = 'Order Confirmation will be done by ' + distName;
            mapOutParams.put('jsonmessage',response);

        }

        return mapOutParams;


    }

    // public static string doCallout(string jsonmessage, Id poID){
    public static map<String, Object> doCallout(map<String, Object> mapInputParams){

        String wsResponse = null;
        PurchaseOrder__c poToUpdate;
        //WCH 07/08/2020 C-003864
        Map<String, Object> requestEIPEndpoint = new Map<String, Object>{'ORDERCONFIRMATION_EndPoint' => 'authenticate'};
        Map<String, Object> responseEIPEndpoint = RestDistributorUtility.getEndPoint(requestEIPEndpoint);

        String jsonmessage =  mapInputParams.containskey('jsonmessage') ? (String) mapInputParams.get('jsonmessage') : null;
        Id assessId =  mapInputParams.containskey('Assessment') ? (Id) mapInputParams.get('Assessment') : null;
        Id poID =  mapInputParams.containskey('poID') ? (Id) mapInputParams.get('poID') : null;

        map<String, Object> mapOutParams = new map<String, Object>();


        HTTPRequest request = new HTTPRequest();
		request.setEndpoint((String)responseEIPEndpoint.get('ORDERCONFIRMATION_EndPoint'));//WCH 07/08/2020 C-003864
		request.setHeader('Content-Type','application/json; charset=UTF-8');
		request.setHeader('Accept','application/json');
		request.setBody(jsonmessage);
		request.setMethod('POST');
		request.setTimeout(integer.valueOf(system.label.EIPTimeout));

        HTTP httpCall = new HTTP();

        system.debug('@@ jsonmessage: '+jsonmessage);
		try{
            //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS
            if (jsonmessage != null &&  !jsonmessage.contains('Order Confirmation will be done')){
                HTTPResponse response	= httpCall.send(request);
                System.debug('## request: ' + request);
                System.debug('## response: ' + response);
                String responseSimulated;
                Boolean isSimulation = false;
                Boolean hasError = false;
                if (system.label.responseCalloutOrderConfirmation != 'none' && system.label.responseCalloutOrderConfirmation.StartsWith('a0D')){
                    Log__c logResponse = [Select id,WSResponse__c from Log__c Where Id = :system.label.responseCalloutOrderConfirmation];
                    responseSimulated = logResponse.WSResponse__c;
                    isSimulation = true;
                }
                
                if(response != null){
                    String statusCode = isSimulation ? '200' : String.valueOf(response.getStatusCode());
                    system.debug('## statusCode ' + statusCode);
                    // statusCode = '200'; //remove this line
                    if(statusCode == '200'){
                        
                        wsResponse = isSimulation ? responseSimulated : response.getBody();  

                        // wsResponse = '{"Assessments":[{"AssessmentID":"DEAUDATEXAAD96622-D816-5D85-218C-3BE788C2B5E6-3","PO":"PO-123456","Message":"OKI"}]}';

                        if (wsResponse != null){
                            String poResponse = processResponse(wsResponse);
                            poToUpdate = new PurchaseOrder__c(id = poID,OrderConfirmationDate__c = system.now(), OrderConfirmationErrorMe__c = poResponse.left(250) );

                        }
                    }
                    else{
                        wsResponse ='Error: ' + response.toString() + ' statusCode = '+statusCode;  
                        poToUpdate = new PurchaseOrder__c(id = poID,OrderConfirmationDate__c = system.now(), OrderConfirmationErrorMe__c = wsResponse.left(250) );
						hasError = true;
                    } 
                    //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS
                    mapOutParams.put('jsonResponse',wsResponse);                    
                    mapOutParams.put('PO',poToUpdate );
                    mapOutParams.put('assessId',assessId );
                    mapOutParams.put('hasError',hasError );
                    map<String, Object> mapOutParamsCloseAssess = closeClaimOrder(mapOutParams);
                } 
            }
            //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS
            else{
                poToUpdate = new PurchaseOrder__c(id = poID );

                mapOutParams.put('PO',poToUpdate );
                mapOutParams.put('assessId',assessId );

                map<String, Object> mapOutParamsCloseAssess = closeClaimOrder(mapOutParams);

            }
            


        }

        catch(Exception e){
            wsResponse = (e.getMessage().length() < 1000) ? e.getMessage() + e.getStackTraceString() : system.label.DistributorWSNoInfo;    
            wsResponse = 'Exceptions: ' + wsResponse;
            mapOutParams.put('jsonResponse',wsResponse);                    
        } 

        // return wsResponse;
        return mapOutParams;

    }

    public static string processResponse(string response){

        orderConfirmResponse orderConfirmResponseInstance =  (orderConfirmResponse) System.JSON.deserialize(response, orderConfirmResponse.class);
        system.debug('## orderConfirmResponseInstance:'+orderConfirmResponseInstance);
        string message = '';
        if (orderConfirmResponseInstance != null){
            if (orderConfirmResponseInstance.Assessments != null){
                for (Assessments assess: orderConfirmResponseInstance.Assessments){
                    system.debug('@@ assess: '+assess);
                    message = assess.Message;
                }
            }
        }
        
        

        system.debug('## message:'+message);

        return message;

    }
    //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS
    public static map<String, Object> closeClaimOrder( map<String,Object> mapInputParams){

        system.debug('## closeClaimOrder:'+mapInputParams);


        map<String, Object> mapOutputParams = new map<String,Object> ();
        PurchaseOrder__c po;
        po = mapInputParams.containskey('PO') ? (PurchaseOrder__c) mapInputParams.get('PO') : null;
        Id assessId = mapInputParams.containskey('assessId') ? (Id) mapInputParams.get('assessId') : null;
        Boolean hasError = mapInputParams.containskey('hasError') ? (Boolean) mapInputParams.get('hasError') : false;
        PrerequisiteOrder__c so; 

        system.debug('## po:'+po);
        

        if (po != null && (po.status__c == null || (po.status__c != null && (po.status__c !=  ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK || po.status__c !=  ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)))){
            if (!hasError){
                po.status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;
            }
            update po;
        }

        for(Assessment__c currentAssessment : [ SELECT  Id, RecordType.DeveloperName,InsuranceBroker__c,
                                                        (SELECT Id, Status__c
                                                         FROM   PrerequisiteOrders__r),
                                                        (SELECT Id, Status__c, Reason__c
                                                         FROM   PurchaseOrders__r)
                                                FROM    Assessment__c
                                                WHERE   Id =: assessId])
        {
            if ( String.isNotBlank(currentAssessment.InsuranceBroker__c) && system.label.InsBrokerName.contains(currentAssessment.InsuranceBroker__c)){
                Integer noPurchaseOrderClosedOK         = 0;
                Integer noPurchaseOrderClosedKO         = 0;
                if (currentAssessment.PurchaseOrders__r != null){
                    Integer noOfPurchaseOrder = currentAssessment.PurchaseOrders__r.size();

                    for(PurchaseOrder__c currentPurchaseOrder : currentAssessment.PurchaseOrders__r)
                    {
                        if( currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK )
                        {
                            noPurchaseOrderClosedOK++;
                        }
                        else  if(currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO )
                        {
                            noPurchaseOrderClosedKO++;
                        }
                    }
                    system.debug('@@ noPurchaseOrderClosedOK: '+noPurchaseOrderClosedOK);
                    system.debug('@@ noOfPurchaseOrder: '+noOfPurchaseOrder);
                   
                    for(PrerequisiteOrder__c currentSalesOrder : currentAssessment.PrerequisiteOrders__r)
                    {
                        if (noOfPurchaseOrder ==  noPurchaseOrderClosedKO ){
                            if (currentSalesOrder.status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK && currentSalesOrder.status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO){
                                so = new PrerequisiteOrder__c (Id = currentSalesOrder.Id,
                                                                Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO);
                            }
                        }
                        else if (noOfPurchaseOrder == (noPurchaseOrderClosedOK + noPurchaseOrderClosedKO) ){
                            if (currentSalesOrder.status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK && currentSalesOrder.status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO){
                                so = new PrerequisiteOrder__c (Id = currentSalesOrder.Id,
                                                                Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK);
                            }
                        }
                    }
                    
                }
            }


        }
        system.debug('@@ so: '+so);

        if (so != null){
            // po.status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;
            update so;
            List<Offer__c> offerListToUpdate 			= new List<Offer__c>();
		    Map<Id, OrderLine__c> orderLinesToUpdate 	= new Map<Id, OrderLine__c>();

            for(Offer__c off : [SELECT Id, OrderLine__c, OrderLine__r.OriginalItem__c, OrderLine__r.OriginalItem__r.OriginalItem__c, PrerequisiteOrder__c 
                                FROM Offer__c 
                                WHERE Accepted__c = 'YES' 
                                AND DeliveryStatus__c = 'INDELIVERY'  
                                AND Prerequisiteorder__r.Status__c IN ('CLOSEDOK')
                                AND  Prerequisiteorder__c =: so.Id]){

                offerListToUpdate.add(new Offer__c(	Id = off.Id, 
												DeliveryStatus__c = 'DELIVERED', 
												RealDeliveryDate__c = System.today()));
                
                if(off.OrderLine__c != null &&
			        off.OrderLine__r.OriginalItem__c != null)
                {
                    orderLinesToUpdate.put(off.OrderLine__r.OriginalItem__c, new OrderLine__c(Id 					= off.OrderLine__r.OriginalItem__c,
                                                                                            DeliveryStatus__c 	= 'DELIVERED',
                                                                                            RealDeliveryDate__c 	= System.today()));
                }

            }

            if(offerListToUpdate.size() > 0){
                update offerListToUpdate;
            }

            // Updating the parents of the orderline attached to the offer
            if(orderLinesToUpdate.size() > 0)
            {
                update orderLinesToUpdate.values();
            }
                                

        }

        return mapOutputParams;


    }

    public class orderConfirmResponse{
        public List<Assessments> Assessments;


    }

    

	public class Assessments {
		public String AssessmentID;
		public String PO;
		public String Message;
    }
    
    


}