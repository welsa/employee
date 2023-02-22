global without sharing class VFC_RESTUpdatePOOrderLines { 
/**********************************************************************************************************************
Class Name - VFC_RESTUpdatePOOrderLines  
Version - 1.0
Created Date - 18 AUG 2017
Function - Distributor Callout for initial failed call
-----------------------------------------------------------------------------------------------------------------------
* Developer         Date         Description 
* ----------        ----------   --------------------------------------------------------------------------------------
* Abdool M          18/08/2017   Initial Version
* Abdool M          05/12/2017   Distributor name should be fetch from Tech_Distributor__c instead of 
*                                referencing name directly
* Abdool M          12/12/2017   Creating LOG for distributor callout (EIP Request and Response)
* Abdool M          16/02/2018   C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c to query 
*                                         - Saving MRID in OL generated  
* Ruksaar L         14/03/18     Case-002380 CarMapping for SearchDistributor
* Ashwina S         09/07/2018   C-002659 : Prices & Part Type to be sent to Coler 
* Ruksaar L         18/09/18     Case-
* Ashwina S         30/11/18     C-002947: R3 Assessmnets not sent to Coler
* Ruksaar L         17/04/19     C-003193 : Created from scratch R3 assessments not sent to Coler
* Ruksaar L         12/06/2020   C-003754: IG - Update Query Call for Coler
* Neha  P           10/02/2022   C-004587: Send default value on PO's First Registration Date field for OrderMakeSelection calls to SAS if value is NULL                                                                                                                


**********************************************************************************************************************/ 

    global VFC_RESTUpdatePOOrderLines(ApexPages.StandardController sc){ 
        system.debug('## Start constructor');

        
        system.debug('## End constructor'); 
    }

    @RemoteAction
    global static string launchDistributorCallOut(string POID){
        system.debug('## Start launchDistributorCallOut');

        system.debug('## End launchDistributorCallOut');
        //return launchDisOld(POID); 

        try{
            string s =  launchDis(POID); 
            system.debug('@@@ s: '+s);
            return s;
        }
        catch(Exception e){
            // system.debug('@@ here'+e.getMessage());

            return 'Error: ' + system.label.UpdateStockinfoErrMsg; //send an error message here
        }
    }

    global static string launchDisOLd(string POID){
        system.debug('## Start launchDistributorCallOut');

        //get current page variables
        //AMI 05/12/17 : Adding Tech_Distributor__c in query
        PurchaseOrder__c currentPurchaseOrder                       = [select id, Assessment__c, Assessment__r.BodyShop__r.DistributorConnected__c, Distributor__c,Distributor__r.Name,
                                                                            Distributor__r.DistributorConnected__c, Distributor__r.Type_of_Substitutes__c,Tech_ExternalId__c, Status__c, wsDate__c, wsErrorMessage__c,
                                                                            Distributor__r.Tech_Distributor__c, Distributor__r.Rebate__c, Distributor__r.OrderRequest__c
                                                                       from PurchaseOrder__c
                                                                       where id = :POID];

        //check po status before attempting call
        if(!currentPurchaseOrder.Assessment__r.BodyShop__r.DistributorConnected__c){
            return string.valueOf(system.label.DistributorNotConnected);
        }
        // if(currentPurchaseOrder.Distributor__r.DistributorConnected__c == false){
        if(RestDistributorUtility.isConnectedDist(currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c) == false){
            return string.valueOf(system.label.DistributorNotConnected);
        }// Wrong status
        else if(currentPurchaseOrder.Status__c == 'RESPONDED' || 
               (currentPurchaseOrder.Status__c == 'DRAFTQUOTE' 
                    && currentPurchaseOrder.wsDate__c != null && (currentPurchaseOrder.wsErrorMessage__c == null || currentPurchaseOrder.wsErrorMessage__c.contains('Order successfully sent')) && currentPurchaseOrder.Distributor__r.OrderRequest__c == 'OrderR4')){
            system.debug('## Start filterPO');
            return string.valueOf(system.label.DistributorAlreadyLaunchMsg);
        }

        map <string,object> wsResponse                              = new map <string,object>();
        map <Id, PartList__c> partMap                               = new map <Id, PartList__c>();
        Assessment__c assRecord                                     = null;

        //current distributor to send to WS for current PO
        list <Account> distributorLst                               = (currentPurchaseOrder.Distributor__c != null) ? 
                                                                        new list <Account>{new Account(id = currentPurchaseOrder.Distributor__c)} : 
                                                                        new list <Account>();

        //build set distributor name used to process WS Response
        //AMI 05/12/17 : Fetch Tech_Distributor__c instead of distributor name
        RestDistributorUtility.setDistributorName                   = new set <string>{currentPurchaseOrder.Distributor__r.Tech_Distributor__c};

        //getting existing po info
        map <string,PurchaseOrder__c> mapExistingPOUpsertKeyPO      = new map <string,PurchaseOrder__c>();

        //get orderline upsert status
        string OLStatus                                             = '';

        //AMI 16/02/2018   C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c to query 
        //                          - Saving MRID in OL generated  
        //query current PO assesssment and parts associated
        if(string.isNotBlank(currentPurchaseOrder.Assessment__c)){
            for(Assessment__c ass : [select id,BodyShop__c,Manufacturer__c,ModelV2__c,FirstRegistrationDate__c,PlateNumber2__c,
                                                VINNumber__c,ClaimReference__c,BuildDate__c,
                                        (select id,Type__c,Quantity__c,PartNumber__c,ProducerName__c,Description__c,Price__c,RecordTypeId,Alpha_Scale_MRID__c 
                                         from PartsLists__r)
                                        from Assessment__c
                                        where id = :currentPurchaseOrder.Assessment__c]){
                //get assessment associated with current PO
                assRecord                                           = ass;

                //get all parts associated with assessment
                if(!ass.PartsLists__r.isEmpty()){
                    partMap                                         = new map <Id, PartList__c>(ass.PartsLists__r);
                }
            }//end looping in assessment

            //get current PO info
            mapExistingPOUpsertKeyPO.put(currentPurchaseOrder.Tech_ExternalId__c,
                                        new PurchaseOrder__c(id = currentPurchaseOrder.Id,
                                                             Status__c = currentPurchaseOrder.Status__c));
        }//end if string.isNotBlank(currentPurchaseOrder.Assessment__c)
        
        system.debug('## assRecord ' + assRecord);
        system.debug('## partMap ' + partMap);
        system.debug('## mapExistingPOUpsertKeyPO ' + mapExistingPOUpsertKeyPO);
        
        //launch distributor Call Out callout
        //AMI 12/12/17 :  Creating LOG for distributor callout (EIP Request and Response)
        //                new param variable to hold class name when generating log for distributor callout (in VFC_RESTUpdatePOOrderLines)
        OLStatus = RestDistributorUtility.initialiseWSCallOut(assRecord,distributorLst,partMap,true,mapExistingPOUpsertKeyPO,'VFC_RESTUpdatePOOrderLines');

        system.debug('## End launchDistributorCallOut: '+OLStatus);
        return OLStatus;  
    }

    public static PurchaseOrder__c retrieveAssessment(Id POId){
        system.debug('## Start retrieveAssessment');

        PurchaseOrder__c PO = [Select Id, Assessment__c, Distributor__c, Status__c, wsDate__c, wsErrorMessage__c, AgencyMode__c, Tech_ExternalId__c, Name,  BodyShopOrderNumber__c, OrderComment__c,
                                      Distributor__r.DistributorConnected__c, Distributor__r.Tech_Distributor__c, Distributor__r.Categories__c, 
                                      Distributor__r.DistributorCarBrandSupplied__c, Distributor__r.Rebate__c, Distributor__r.PartTypeRegionDelayMatrix__c, 
                                      Distributor__r.OrderRequest__c, Distributor__r.Name, Assessment__r.BodyShop__c, Assessment__r.Manufacturer__c, 
                                      Assessment__r.ModelV2__c, Assessment__r.FirstRegistrationDate__c, Assessment__r.PlateNumber2__c, 
                                      Assessment__r.VINNumber__c, Assessment__r.ClaimReference__c, Assessment__r.BuildDate__c, Distributor__r.Type_of_Substitutes__c,
                                      Assessment__r.BodyShop__r.DistributorConnected__c, Assessment__r.BodyShop__r.Name, /* ASE 30/11/18 : C-002947 */Assessment__r.OrderOrigin__c, Brand__c,Distributor__r.Tech_ATConfirmed__c,Distributor__r.Tech_ATConfirmedWithDelay__c,Distributor__r.Tech_ATPartial__c,Distributor__r.Tech_ATNotFound__c,Distributor__r.Tech_ATOther__c, /*RLA 3701 */
                                      Assessment__r.BodyShop__r.ReferenceNumber__c, Assessment__r.BodyShop__r.VATNumber__c, Assessment__r.TECH_EntityCountryCode__c,Assessment__r.InsuranceBroker__c, /*RLA 3753 */
                                      Assessment__r.BodyShop__r.Id, Assessment__r.InsBrokerNumber__c, Assessment__r.AssessmentID__c,  PrerequisiteOrder__r.Name,DistributorName__c,DistributorPOReference__c,Assessment__r.substitutiontype__c,/*RLA IG */
                                      (Select PartList__r.Id, PartList__r.quantity__c, PartList__r.PartNumber__c, 
                                                PartList__r.Description__c, PartList__r.Type__c, PartList__r.CrossReferenceId__c, PartList__r.InputType__c,
                                              PartList__r.CrossReferenceId__r.IAMManufacturer__c, PartList__r.CrossReferenceId__r.OEMPartNumber__c, PartList__r.TechCheckForSubstitute__c,
                                              PartList__r.DistributorPriceId__c, PartList__r.DistributorPriceId__r.DistributorPartNumber__c, PartList__r.ProducerName__c,
                                              Id, quantity__c, PartNumber__c, Type__c, Description__c, DistributorPrice__r.DistributorPartNumber__c, Suppliable__c, AcceptedCheck__c 
                                       from OrderLines__r)
                               from PurchaseOrder__c
                               where id = :POId];
        
        system.debug('## End retrieveAssessment');
        return PO;
    }

    public static String filterPO(PurchaseOrder__c currentPurchaseOrder){
        system.debug('## Start filterPO');
        //BS not connected
        if(!currentPurchaseOrder.Assessment__r.BodyShop__r.DistributorConnected__c){
            system.debug('## Start filterPO');
            return string.valueOf(system.label.DistributorNotConnected);
        }

        //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
        if(!RestDistributorUtility.canMakeDraftCall(currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c)){
            return string.valueOf(system.label.DistributorNoDraftCall);
        }

        //Distributor not connected
        // if(!currentPurchaseOrder.Distributor__r.DistributorConnected__c){
        if(!RestDistributorUtility.isConnectedDist(currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c)){
            return string.valueOf(system.label.DistributorNotConnected);
        }
        // Wrong status
        else if(currentPurchaseOrder.Status__c == 'RESPONDED' || 
               (currentPurchaseOrder.Status__c == 'DRAFTQUOTE' 
                    && currentPurchaseOrder.wsDate__c != null && (currentPurchaseOrder.wsErrorMessage__c == null || currentPurchaseOrder.wsErrorMessage__c.contains('Order successfully sent')) && currentPurchaseOrder.Distributor__r.OrderRequest__c == 'OrderR4')){
            system.debug('## Start filterPO');
            return string.valueOf(system.label.DistributorAlreadyLaunchMsg);
        }
        else{
            string wsResponse = ''; 
            map <Id, PartList__c> partMap = new map <Id, PartList__c>();
            String wsRequest = buildRequest(currentPurchaseOrder, 'Draft', partMap);
            //String wsRequest ='{"Vehicle":{"VinNumber":"WBASN61030C456078","PlateNumber":"KARU2001","Model":"5er-Reihe GT (F07) Lim. ab 09/09-02/17","FirstRegistrationDate":"2012-03-01","Brand":"Audi"},"Request":"Draft","Distributors":{"COLER":{"Parts":[{"Type":"B","Quantity":1,"PartNumber":"030 131 503 F","Manufacturer":"Hella","ID":"a0H8E000004lCcxUAE","Description":"SCHEINWERFER L KPL - Hella (1ZS 010 130-611)","AllowAlternatives":"false"},{"Type":"A","Quantity":1,"PartNumber":"1K0 615 301 AA","Manufacturer":"Audi","ID":"a0H8E000004lCcyUAE","Description":"SCHEIBENRAD ALU V R","AllowAlternatives":"false"},{"Type":"A","Quantity":1,"PartNumber":"030 131 503 C","Manufacturer":"Audi","ID":"a0H8E000004lCczUAE","Description":"SCHEIBENRAD ALU V L","AllowAlternatives":"false"}],"ExternalOrderReference":""}},"ClaimReference":"83RLA1234574","BodyShop":{"VATNumber":"DE297568611","Name":"Brillant GmbH Fachbetrieb Karosserie Lackiertechnik und Mechanik","ExternalReference":"123456789 "},"AutomaticValidation":false,"AlphaScalePO":""}';
            if(wsRequest != null){

                map <string, Account> mapDistributorNameDistributor = new map <string,Account>{currentPurchaseOrder.Distributor__r.Tech_Distributor__c => currentPurchaseOrder.Distributor__r};
                map <string, PurchaseOrder__c> mapPOExtIDPO = new map <string, PurchaseOrder__c>{currentPurchaseOrder.Tech_ExternalId__c => currentPurchaseOrder};
                
                wsResponse = OrderMakeSelection.makeDraftCall(wsRequest, mapDistributorNameDistributor, currentPurchaseOrder.Assessment__c, mapPOExtIDPO, partMap, true, currentPurchaseOrder.Distributor__r.OrderRequest__c, 'VFC_RESTUpdatePOOrderLines', 'fromUpdateStockInfo');//RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO
            }
            system.debug('## End filterPO :'+wsResponse);
            return wsResponse; 
        }       
    }

    public static String initiateCall(PurchaseOrder__c currentPurchaseOrder, Boolean callTypeDraft){
        system.debug('## Start initiateCall');
        map <Id, PartList__c> partMap = new map <Id, PartList__c>();
        String wsRequest = buildRequest(currentPurchaseOrder, 'Draft', partMap);
        String wsResponse = '';
        if(wsRequest != null){

            map <string, Account> mapDistributorNameDistributor = new map <string,Account>{currentPurchaseOrder.Distributor__r.Tech_Distributor__c => currentPurchaseOrder.Distributor__r};
            map <string, PurchaseOrder__c> mapPOExtIDPO = new map <string, PurchaseOrder__c>{currentPurchaseOrder.Tech_ExternalId__c => currentPurchaseOrder};
            
            try{
                wsResponse = OrderMakeSelection.makeDraftCall(wsRequest, mapDistributorNameDistributor, currentPurchaseOrder.Assessment__c, mapPOExtIDPO, partMap, callTypeDraft, currentPurchaseOrder.Distributor__r.OrderRequest__c, 'VFC_RESTUpdatePOOrderLines', 'fromUpdateStockInfo');
            }
            catch(exception e){
                wsResponse = e.getMessage();
            }
        }
        system.debug('## End initiateCall: '+wsResponse);
        return wsResponse;
    }

    public static String buildRequest(PurchaseOrder__c PO, String callType, map <Id, PartList__c> partMap){
        system.debug('## Start buildRequest');
        String brandName;
        
        Id recordTypeIdMaterial = [SELECT Id FROM RecordType WHERE SobjectType =: Label.SOBJECTPARTLIST and DeveloperName = 'Material'].Id;
        ASPISConstants.BodyShop BodyShop;  
        RestDistributorUtility.BodyShop BodyShop1;  
        //RLA 01/07/2020 C-003770: IG - Send Final part to ERP when there is a replacement
        Boolean isIG = false;
        //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
        set<String> setBdIds = new set<String>();
        Map<String,String> mapAccIdAcccRef = new map<String,String>();



         if (String.isnotBlank(PO.Assessment__r.InsuranceBroker__c) && system.label.InsBrokerName.contains(PO.Assessment__r.InsuranceBroker__c)){
            isIG = true;
        }
        system.debug('@@ isIG: '+ isIG);
        if(PO.Assessment__r.BodyShop__c != null){
            Account BS = PO.Assessment__r.BodyShop__r;
            BodyShop1 = new RestDistributorUtility.BodyShop(BS.Name,
                                                    //string.isNotBlank(BS.ReferenceNumber__c) ? BS.ReferenceNumber__c : '',
                                                    // // ASE: this line should be commented in Prod
                                                    //RLA 15/09/2020 C-003940: Check on Bodyshop Reference number to send to Distributor
                                                    RestDistributorUtility.isColer(BS.ReferenceNumber__c)? system.label.FakeBodyshopReference: string.isNotBlank(BS.ReferenceNumber__c) ? BS.ReferenceNumber__c : '', //RLA case 2603
                                                    string.isNotBlank(BS.VATNumber__c) ? BS.VATNumber__c : '');
            BodyShop = new ASPISConstants.BodyShop(BodyShop1.Name, BodyShop1.ExternalReference, BodyShop1.VATNumber);
        }        
        else{
            BodyShop = new ASPISConstants.BodyShop('','','');
        }
        
        
        //build vehicle
        Assessment__c assess = PO.Assessment__r;
        //RLA 14/03/18  Case-002380 CarMapping for SearchDistributor
        String distBrand = (PO.Distributor__r.Tech_Distributor__c+'-'+assess.Manufacturer__c).toUpperCase();
        brandName = RestDistributorUtility.getCarMappingsMatrix(distBrand);

        if ( String.isBlank(brandName)){
            brandName =  string.isNotBlank(assess.Manufacturer__c) ? assess.Manufacturer__c : '';   
        
        }

        ASPISConstants.Vehicle Vehicle= new ASPISConstants.Vehicle( brandName,
                                                                    string.isNotBlank(assess.ModelV2__c) ? assess.ModelV2__c : '',
                                                                    assess.FirstRegistrationDate__c != null ? string.valueOf(assess.FirstRegistrationDate__c) : '01/01/1900', //NPE 10/02/2022 C-004587
                                                                    string.isNotBlank(assess.PlateNumber2__c) ? assess.PlateNumber2__c : '',
                                                                    string.isNotBlank(assess.VINNumber__c) ? assess.VINNumber__c : '',
                                                                    null);


        // build parts
        Boolean makeSupplied = (PO.Distributor__r.DistributorCarBrandSupplied__c != null && PO.Distributor__r.DistributorCarBrandSupplied__c.contains(assess.Manufacturer__c));
        
        set <string> setCategory = new set <string>();
        if(PO.Distributor__r.Categories__c != null){
            setCategory = new set <string>(new list <string>(PO.Distributor__r.Categories__c.split(';')));
        }

        map <string, object> distributorObj = new map <string, object>();
        list <ASPISConstants.Parts> tempSuppliedParts = new list <ASPISConstants.Parts>(); 
        system.debug('## PO:'+PO);
        //Commented by RLA 18/09/2018 Case 
        //if(PO.OrderLines__r.size() > 0){
            set<String> processedIdSet = new set<String>();
            integer count = 0;

            map<Id, OrderLine__c> mapOriOlIdFinalOl = new map<Id, OrderLine__c>();
            //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
            map<Id, OrderLine__c> mapFinalOl = new map<Id, OrderLine__c>();

            if (isIG){
                //RLA 01/07/2020 C-003770: IG - Send Final part to ERP when there is a replacement
                for (OrderLine__c OL : [SELECT   Id, Name, OrderType__c, PartNumber__c, Type__c, Description__c, Manufacturer__c,
                                                OriginalItem__r.Id,Discount__c, AcceptedCheck__c, TechOLType__c,
                                                OriginalItem__r.PartNUmber__c, OriginalItem__r.Description__c,
                                                (SELECT Id, CataloguePrice__c, Price__c,Discount__c, OrderLine__r.AcceptedCheck__c,
                                                OrderLine__r.TechOLType__c,OrderLine__r.OriginalItem__c,OrderLine__r.OriginalItem__r.PartNUmber__c,OrderLine__r.OriginalItem__r.Description__c
                                                from Offers__r
                                                // where OrderType__c = 'FINAL'
                                                )                                                
                                                FROM     OrderLine__c
                                                WHERE    PurchaseOrder__c =: PO.Id
                                                AND OrderType__c = 'Final'
                                                // AND OriginalItem__c != null
                                                ORDER BY Name ASC]){

                    if (OL.OriginalItem__c != null){
                        mapOriOlIdFinalOl.put(OL.OriginalItem__r.Id, OL);
                    }
                    
                    //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                    mapFinalOl.put(OL.Id, OL);

                    // system.debug('OL.offers__r:'+OL.offers__r);
                    // system.debug('OL:'+OL);
                }
            }
            system.debug('@@ mapOriOlIdFinalOl:'+mapOriOlIdFinalOl);
            system.debug('@@ mapFinalOl:'+ mapFinalOl);
            //RLA 31/10/2020 C-004018: IG - Efa requirements
            Integer i = 0;
            //Commented by RLA 18/09/2018 Case 
            //When orderlines exceed 150 it fails. Therefore instead of accessing the child records directly
            //We added a query to access the child records
            //for(OrderLine__c OL : PO.OrderLines__r){
            for(OrderLine__c OL : [SELECT   Id, Name, OrderType__c, PartNumber__c, Type__c, Description__c, Manufacturer__c,
                                            ExpectedDeliveryDuration__c, CataloguePrice__c, Quantity__c, TotalPrice__c,
                                             AXADiscount__c, BodyShopDiscount__c, AXATotalPrice__c, PartList__r.CompliantPart__c, Suppliable__c, OriginalItem__c, OriginalItem__r.OriginalItem__c,
                                             AdditionnalDiscount__c, PurchaseOrder__c, PartList__c, VAT__c, TECH_ExtraAS__c, PartList__r.Compliance__c, TECH_DistributorCode__c, Discount__c,
                                             Discount__r.DistributorCode__c, DeliveryStatus__c, AcceptedCheck__c, BodyshopTotalPrice__c, CancelReason__c, Rebate__c, AdditionalDiscountAmount__c, DistributorPrice__c,
                                             IsCanceledByDistributor__c, PreselectedForOrder__c, DeliveryStatusReason__c, PurchaseOrder__r.TECH_AssessmentCountryCode__c, TechExternalId__c, PartList__r.Quantity__c,  PartList__r.CrossReferenceId__c, PartList__r.CrossReferenceId__r.IAMManufacturer__c, PartList__r.ProducerName__c, PartList__r.DistributorPriceId__r.DistributorPartNumber__c, PartList__r.CrossReferenceId__r.OEMPartNumber__c,
                                             PartList__r.Description__c, PartList__r.DistributorPriceId__c, PartList__r.Type__c,
                                              PartList__r.PartNumber__c, PartList__r.RecordTypeId,PartList__r.ForTechSubsNumber__c
                                              ,AXAPrice__c,BodyShopPrice__c, //RLA 10/06/2020  C-003753
                                              
                                              PurchaseOrder__r.DistributorName__c, PurchaseOrder__r.DistributorPOReference__c,
                                              PurchaseOrder__r.Assessment__r.BodyShop__r.Id,
                                               PartList__r.TECH_OriginalPart__c,//RLA 14/10/2020 C-004005
                                            (SELECT Id, CataloguePrice__c, Price__c
                                                from Offers__r
                                                where OrderType__c = 'FINAL')
                                    FROM     OrderLine__c
                                    WHERE    PurchaseOrder__c =: PO.Id
                                    ORDER BY Name ASC] ){

                if((callType == 'Draft' && OL.AcceptedCheck__c) || (callType == 'Order' && OL.Suppliable__c == 'YES' && /* ASE 30/11/18 : C-002947 */((PO.Assessment__r.OrderOrigin__c == 'Legacy'   
                    //RLA 17/04/19 C-003193
                || PO.Assessment__r.OrderOrigin__c == 'ManualCreation' ) || (PO.Assessment__r.OrderOrigin__c == 'Order'  && OL.AcceptedCheck__c)))) {//ASE 06/11/2018 Case-2889
                    PartList__c prt= OL.PartList__r;

                    
                    //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                    if (String.IsNotBlank(OL.PurchaseOrder__r.Assessment__r.BodyShop__r.Id)){
                        setBdIds.add(String.valueOf(OL.PurchaseOrder__r.Assessment__r.BodyShop__r.Id).substring(0, 15));   
                    }  

                    if(prt.RecordTypeId == recordTypeIdMaterial && prt.Quantity__c > 0 ){
                        String type;
                        Integer quantity; 
                        String idToSend;
                        String partNumber;
                        //String manufacturer = (prt.CrossReferenceId__c != null) ? (prt.CrossReferenceId__r.IAMManufacturer__c != null ? prt.CrossReferenceId__r.IAMManufacturer__c : '') : (PO.Assessment__r.Manufacturer__c!= null ? PO.Assessment__r.Manufacturer__c : '');
                        String manufacturer = (prt.CrossReferenceId__c != null) ? (prt.CrossReferenceId__r.IAMManufacturer__c != null ? prt.CrossReferenceId__r.IAMManufacturer__c : PO.Assessment__r.Manufacturer__c) : (string.isNotBlank(prt.ProducerName__c) ?  prt.ProducerName__c : PO.Assessment__r.Manufacturer__c);
                        String description;
                        Id disPriceId;
                        //RLA 10/06/2020 C-003753: IG - New features for Order Call.
                        Double alphaScalePublicPrice;
                        Double bodyshopNetPrice;
                        double Discount;//RLA 25/08/2020 C-003882:
                        string DistributorStatus;//RLA 25/08/2020 C-003882:
                        string DistributorAction;//RLA 25/08/2020 C-003882:
                        string OldPartNumber;//RLA 25/08/2020 C-003882:
                        string OldDescription;//RLA 25/08/2020 C-003882:
                        //RLA 31/10/2020 C-004018: IG - Efa requirements
                        i++;
                        String sequenceID = String.valueOf(i);

                        //RLA 23/03/18  Case-002380 CarMapping for SearchDistributor
                        String manufacturerFinal = RestDistributorUtility.getCarMappingsMatrix(PO.Distributor__r.Tech_Distributor__c+'-'+manufacturer);

                        if (String.isBlank(manufacturerFinal)){
                            manufacturerFinal = manufacturer;   
                        }


             //         if(PO.Distributor__r.OrderRequest__c == 'OrderPO'){
             //             type = OL.Type__c;
                            //quantity = integer.valueOf(OL.Quantity__c);
                            //idToSend = string.valueOf(OL.Id);
                            //partNumber = (OL.DistributorPrice__c != null) ? OL.DistributorPrice__r.DistributorPartNumber__c : ( prt.CrossReferenceId__c !=null ? (prt.CrossReferenceId__r.OEMPartNumber__c) : prt.PartNumber__c);
                            //description = OL.Description__c;
                            //disPriceId = OL.DistributorPrice__c;
             //         }
             //         else{
                            type = prt.Type__c;
                            quantity = integer.valueOf(OL.Quantity__c);
                            idToSend = string.valueOf(prt.Id);
                            if (isIG && mapOriOlIdFinalOl.containsKey(OL.Id)){

                                partNumber = (prt.DistributorPriceId__c != null) ? prt.DistributorPriceId__r.DistributorPartNumber__c : ( prt.CrossReferenceId__c !=null ? (prt.CrossReferenceId__r.OEMPartNumber__c) : mapOriOlIdFinalOl.get(OL.Id).PartNumber__c);
                                description = mapOriOlIdFinalOl.get(OL.Id).Description__c;

                                if (mapOriOlIdFinalOl.get(OL.Id).Offers__r != null && mapOriOlIdFinalOl.get(OL.Id).Offers__r.size() > 0){
                                    for (Offer__c off: mapOriOlIdFinalOl.get(OL.Id).Offers__r){
                                        alphaScalePublicPrice = off.CataloguePrice__c;
                                        bodyshopNetPrice = off.Price__c;   
                                        //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                                        Discount = off.Discount__c;//RLA 25/08/2020 C-003882:
                                        DistributorStatus = off.OrderLine__r.AcceptedCheck__c != null ?  off.OrderLine__r.AcceptedCheck__c ? 'Accepted' : 'Rejected' : 'Rejected';//RLA 25/08/2020 C-003882:
                                        DistributorAction = off.OrderLine__r.TechOLType__c;//RLA 25/08/2020 C-003882:

                                        if ( String.IsNotBlank(off.OrderLine__r.TechOLType__c) && off.OrderLine__r.TechOLType__c == 'replacement' && off.OrderLine__r.OriginalItem__c != null){
                                            OldPartNumber = off.OrderLine__r.OriginalItem__r.PartNUmber__c;

                                            OldDescription = off.OrderLine__r.OriginalItem__r.Description__c;

                                        }                                    

                                    } 
                                }
                                


                            }
                            else{
                                partNumber = (prt.DistributorPriceId__c != null) ? prt.DistributorPriceId__r.DistributorPartNumber__c : ( prt.CrossReferenceId__c !=null ? (prt.CrossReferenceId__r.OEMPartNumber__c) : prt.ForTechSubsNumber__c);
                                description = prt.Description__c;
                            }
                            
                            disPriceId = prt.DistributorPriceId__c;

                            //RLA 10/06/2020 C-003753: IG - New features for Order Call.
                            if (OL.Offers__r != null && OL.Offers__r.size() > 0){
                                for (Offer__c off: OL.Offers__r){
                                    alphaScalePublicPrice = off.CataloguePrice__c;
                                    bodyshopNetPrice = off.Price__c;
                                }                                
                            }
                        //}
                            //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
                            if (isIG && mapFinalOl.containskey(OL.Id)){
                                
                                if (mapFinalOl.get(OL.Id).Offers__r != null && mapFinalOl.get(OL.Id).Offers__r.size() > 0){
                                    

                                    for (Offer__c off: mapFinalOl.get(OL.Id).Offers__r){
                                        

                                        Discount = off.Discount__c;//RLA 25/08/2020 C-003882:
                                        DistributorStatus = off.OrderLine__r.AcceptedCheck__c != null ?  off.OrderLine__r.AcceptedCheck__c ? 'Accepted' : 'Rejected' : 'Rejected';//RLA 25/08/2020 C-003882:
                                        DistributorAction = off.OrderLine__r.TechOLType__c;//RLA 25/08/2020 C-003882:

                                        if ( String.IsNotBlank(off.OrderLine__r.TechOLType__c) && off.OrderLine__r.TechOLType__c == 'replacement' && off.OrderLine__r.OriginalItem__c != null){
                                            OldPartNumber = off.OrderLine__r.OriginalItem__r.PartNUmber__c;

                                            OldDescription = off.OrderLine__r.OriginalItem__r.Description__c;

                                        }

                                    }

                                }

                            }
                        
                        //if(!processedIdSet.contains(idToSend) &&((setCategory.size() == 0) || ((setCategory.size() > 0 && (setCategory.contains(type) && makeSupplied) || (!setCategory.contains(type) && disPriceId != null))))){
                        if(!processedIdSet.contains(idToSend)){ 
                            tempSuppliedParts.add(new ASPISConstants.Parts(quantity
                                                                            ,'false'
                                                                            ,idToSend
                                                                            //ASE 17/04/18 C-002477:
                                                                            ,partNumber.startsWith('ASP-') ? partNumber.split('ASP-')[1]: partNumber
                                                                            //ASE 09/07/2018 C-002659 : Prices & Part Type to be sent to Coler  
                                                                            ,(PO.Assessment__r.TECH_EntityCountryCode__c == 'DE' && (prt.PartNUmber__c).startsWith(system.label.desubstiturePrefix) && prt.Type__c == 'A' && callType == 'Order') ? 'APRIME': prt.Type__c
                                                                            ,manufacturerFinal //Changed from manufacturer
                                                                            ,description
                                                                            ,alphaScalePublicPrice
                                                                            ,bodyshopNetPrice
                                                                            ,Discount
                                                                            ,DistributorStatus
                                                                            ,DistributorAction
                                                                            ,OldPartNumber
                                                                            ,OldDescription
                                                                            ,sequenceID  //RLA 31/10/2020 C-004018: IG - Efa requirements
                                                                            ));     
                            processedIdSet.add(idToSend);                   
                        }  
                        partMap.put(prt.id, prt);
                    }
                }
            }
            //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
            for (AccountRef__c  accref: [SELECT ExternalReference__c,InternalReference__c FROM AccountRef__c WHERE InternalReference__c in :setBdIds]){
                mapAccIdAcccRef.put(accref.InternalReference__c, accref.ExternalReference__c);
            }
            String externalOrderReference = '';
            String bodyShopOrderNumber = null;
            String Comment = null;
            String BSReferenceNumber = '';
            String InsBrokerNumber = '';
            String AssessmentID = '';
            String SO = '';
            String Distributor = '';
            String DistributorOrderNumber = '';
            
            system.debug('## PO.Name:'+PO.Name);
            if(callType == 'Order'){
                externalOrderReference = PO.Name;
                bodyShopOrderNumber = PO.BodyShopOrderNumber__c;
                Comment = PO.OrderComment__c;
                          
            }

            //RLA 10/06/2020 C-003753: IG - New features for Order Call.
            String agencyMode = '';

            //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
            BSReferenceNumber = PO.Assessment__r.BodyShop__r.Id != null && mapAccIdAcccRef.containskey(String.valueOf(PO.Assessment__r.BodyShop__r.Id).substring(0,15)) ? mapAccIdAcccRef.get(String.valueOf(PO.Assessment__r.BodyShop__r.Id).substring(0,15)) : '';
            InsBrokerNumber = PO.Assessment__r.InsBrokerNumber__c;
            AssessmentID = PO.Assessment__r.AssessmentID__c;
            SO = PO.PrerequisiteOrder__r.Name;
            Distributor = PO.DistributorName__c;
            DistributorOrderNumber = PO.DistributorPOReference__c; 
           
            //RLA 12/01/2021 C-004137: IG - New features for Order Call reviewed
            if (PO.AgencyMode__c == false && String.isnotBlank(PO.Assessment__r.InsuranceBroker__c) && system.label.InsBrokerName.contains(PO.Assessment__r.InsuranceBroker__c)){
                agencyMode = 'IG';
            }
            else{
                agencyMode = String.valueOf(PO.AgencyMode__c);
            }
            system.debug('@@ agencyMode: '+agencyMode);
            system.debug('@@ DistributorOrderNumber: '+DistributorOrderNumber);
            //RLA 31/10/2020 C-004018: IG - Efa requirements
            String bsExtId = RestdistributorUtility.getBSExtId (PO.Distributor__r.Tech_Distributor__c + '-' + PO.Assessment__r.BodyShop__r.ReferenceNumber__c);

            // distributorObj.put(PO.Distributor__r.Tech_Distributor__c, new ASPISConstants.distributor(externalOrderReference, (PO.Distributor__r.OrderRequest__c == 'OrderPO' ? agencyMode : null), bodyShopOrderNumber, Comment,true, tempSuppliedParts));
             //RLA    06/02/2020  C-003882 IG - Order Quality Check outside ASPIS
            distributorObj.put(PO.Distributor__r.Tech_Distributor__c, new ASPISConstants.distributor(externalOrderReference, agencyMode , bodyShopOrderNumber, Comment,true, tempSuppliedParts,bsExtId));
        //} 

        //buid request
        //// ASE: 14/06/18
        if(tempSuppliedParts.size() > 0){
            ASPISConstants.mainRequest mainRequest = new ASPISConstants.mainRequest(string.isNotBlank(assess.ClaimReference__c) ? assess.ClaimReference__c : '',
                                                             false,
                                                             callType,
                                                             '',
                                                             (object)distributorObj,
                                                             BodyShop,
                                                             Vehicle,
                                                             BSReferenceNumber, InsBrokerNumber, AssessmentID, SO, Distributor, DistributorOrderNumber);
            return Json.serialize(mainRequest,true);      
        }  
        else{
            return 'No call initiated: No parts selected.';
        }
    }
 
    global static string launchDis(string POID){
        system.debug('## Start launchDis');

        PurchaseOrder__c PO = retrieveAssessment(POId);
        String wsResponse = filterPO(PO);

        system.debug('## end launchDis:'+wsResponse);
        return wsResponse;      
    }
}