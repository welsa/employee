public without sharing class ASPISCreatePOOrderLines {
/************************************************************************************* 
Class Name - ASPISCreatePOOrderLines
Version - 1.0  
Created Date - 10 AUG 2017
Function - Create OL for PO
--------------------------------------------------------------------------------------
* Developer         Date         Description 
* ----------        ----------   -----------------------------------------------------
* Ashwina S         10/08/2017   Initial version 
* Abdool M          22/08/2017   Updated Version
* Ashwina S         16/10/2017   delete all bundle items associated to original and 
*                                create new again in case description changes
* Abdool M          18/10/2017   SAS: Remplacement de pièce
* Ashwina S         08/11/2017   C-002072 -  SAS UAT 03/11/2017    
* Abdool M          23/11/2017   Commenting bundleItemOLMapToUpd and alternativeOLMapToUpd logoc for insert
* Abdool M          14/12/2017   SAS: Remplacement de pièce --> Distributor Price Number should be taken
*                                into account instead of IAMPartNumber on Cross Ref
* Abdool M          22/01/2018   C-002202 - PO non commandés en drafquote 
* Ashwina S         26/01/2018   C-002210 - Duplicate Spare parts - Order Line wrongly generated  
* Abdool M          15/02/2018   C-002041 - Distributor V2 - Saving MRID for asp parts
* Abdool M          15/02/2018   C-002041 - Distributor V2 - Recalculate AS Bodyshop Net Price and AS Bodyshop Price for asp parts only 
* Abdool M          16/02/2018   C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c to query 
*                                                          - Saving MRID in OL generated  
* Ashwina S         22/02/2018   C-002320 - Rebate forced even if we have the information 
* Ashwina S         18/04/2018   C-002477: ASP- Prefix  
* Ashwina S         28/05/2018   changes in calculations           
* Dourga            14/06/2018   case 2580 : Distributor V2 Price/Marging/Discount (when null, consider as 0 instead ) 
* Ruksaar L         30/08/2018   C-002742 : Update PO - alternative part REFUSED – In progress  
* Ruksaar L         13/09/2019   Case 2778 : Call Distributor Stock does not update Status
* Ruksaar L         18/12/2018   Case C-002955 : Draft calls to distributor : Duplicate external id specified
* Ruksaar L         14/01/2019   C-003008: Parts rejected in PO are not updated in SO
* Welsa C           25/03/2019   C-003144: OL ASCR Finale sur OL ASCR Originale
* Welsa C           08/04/2019   C-002854: Update des statusdes OL via UpdatePO
* Welsa C           19/09/2019   C-003388: Error during Order Make Selection
* GBH 21.09.2020 C-003930 - IG - Test classesType a message
* Welsa C           03/03/2021   C-004203: SAS not sending proper SAS Status for FORD brand
*************************************************************************************/  
    
    
    //AMI 15/02/18 - C-002041 - Distributor V2 - Recalculate AS Bodyshop Net Price and AS Bodyshop Price for asp parts only 
    //                        - Get Rebate Associated With Distributor
    public static double Rebate = 0.0;
    public static set<String> notAcceptedOLSet = new set<String>();
    public static map<String, OrderLine__c> notAcceptedOLMap = new map<String, OrderLine__c>();

    //RLA 14/01/2019   C-003008: Parts rejected in PO are not updated in SO
    //Store ORderRequest
    public static String  orRequest = '';

    //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
    public static boolean updateOLRebate = false;

     //RLA 07/07/2020 C-003770: IG - Send Final part to ERP when there is a replacement           
    static Boolean isRepManual = false;
    static String insuranceBroker = '';

    //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
    static Decimal keepToUse = 0.0;
    static Boolean isNONAXA = false;


    //doNotCreateClassicOL : this ensure no ol is created through classic process during update po WS
    public static String ASPISCreatePOOrderLines(map <string, RestDistributorUtility.dist> distLinesMap, 
                                                    Id assessmentId, 
                                                    Map<String, Account> mapDistributorNameDistributor, 
                                                    map<string, PurchaseOrder__c> insertedPOMap, 
                                                    Map<Id, PartList__c> partMap, 
                                                    String POStatus,
                                                    Boolean doNotCreateClassicOL){
        system.debug('## Start ASPISCreatePOOrderLines'); 

        String results; 

        //AMI 18/10/17 : SAS: Remplacement de pièce
        map <Id, PartList__c> updatedPartMap = new map <Id, PartList__c>(); 
        
        if(distLinesMap.size() > 0 ){


            //AMI 16/02/18 : C-002041 - Distributor V2 - Adding Alpha_Scale_MRID__c so query 
            //                                         - saving MRID in OL generated
            //AMI 18/10/17 : SAS: Remplacement de pièce
            //reconstruct partMap so that iam part number can be queried
            //GBH 21.09.2020 C-003930 - IG - Test classesType a message
            for(PartList__c pt : [select id,CrossReferenceId__c,CrossReferenceId__r.IAMPartNumber__c,ForTechSubsNumber__c,
                                        PartNumber__c,Price__c,Type__c,ProducerName__c,Description__c,Quantity__c,
                                        Alpha_Scale_MRID__c, TechCheckForSubstitute__c,TechCatalog_Price_Dist_Connected__c
                                    from PartList__c
                                    where id IN :partMap.keySet()]){
                updatedPartMap.put(pt.Id,pt);
            }

            list<responseToGenerate> sasResList = new list<responseToGenerate>();
            map<Id, list<OrderLine__c>> originalOLMap = new map<Id, list<OrderLine__c>>();
            map<Id, list<OrderLine__c>> alternativeOLMap = new map<Id, list<OrderLine__c>>();
            map<Id, list<OrderLine__c>> bundleItemOLMap = new map<Id, list<OrderLine__c>>();
            map<Id, PurchaseOrder__c> updatedPOMap = new map<Id, PurchaseOrder__c>();
            map<Id, list<OrderLine__c>> originalOLMapToUpd = new map<Id, list<OrderLine__c>>();
            map<Id, list<OrderLine__c>> bundleItemOLMapToUpd = new map<Id, list<OrderLine__c>>();
            map<Id, list<OrderLine__c>> alternativeOLMapToUpd = new map<Id, list<OrderLine__c>>();

            for(String distributor : distLinesMap.keyset()){
                //check if orderlines can be created for this PO    
                String isSuccess = distLinesMap.get(distributor).Success;
                system.debug('## success:'+isSuccess); 
                Account distAcc = mapDistributorNameDistributor.get(distributor);       
                
                String POKey = String.valueOf(assessmentId)+ String.valueOf(distAcc.Id);
                
                if(insertedPOMap.containsKey(POKey)){
                    PurchaseOrder__c PO = insertedPOMap.get(POKey);
                    //processing of PO and OL
                    //AMI 18/10/17 : SAS: Remplacement de pièce
                    if(isSuccess != 'true'){
                        updatedPOMap.put(PO.Id, new PurchaseOrder__c(Id = PO.Id, wsErrorMessage__c = distLinesMap.get(distributor).Message));
                    }
                    else{
                        if(distLinesMap.get(distributor).Lines != null){
                            processPOOL(distLinesMap.get(distributor).Lines, PO, distAcc, updatedPartMap, POStatus, sasResList, originalOLMap, alternativeOLMap, bundleItemOLMap, originalOLMapToUpd, alternativeOLMapToUpd, bundleItemOLMapToUpd, updatedPOMap, false, null, null, null, null);
                        }
                    }
                }
            }
            
            upsertAll(originalOLMap, 
                        alternativeOLMap, 
                        bundleItemOLMap, 
                        originalOLMapToUpd,
                        alternativeOLMapToUpd,
                        bundleItemOLMapToUpd,
                        String.valueOf(assessmentId), 
                        updatedPOMap, 
                        insertedPOMap,
                        doNotCreateClassicOL,
                        sasResList,
                        false, 
                        null,                       
                        '');//RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO Added parameter

            if(!sasResList.isEmpty()){
                results = Json.serialize(sasResList);  
            }
        }
        
        system.debug('## results:'+results);
        system.debug('## End ASPISCreatePOOrderLines'); 
        return results;
    }

    public static OrderLine__c processErrorPartOL(Boolean isUpdate, RestDistributorUtility.Lines line, String POKey, Id POId, Map<String,String> mapTypeDelay){
        system.debug('## start ASPISCreatePOOrderLines processErrorPartOL:'+line.Id);
        String partType = (line.PartNumber == system.label.AdditionalPartNumber) ? 'A' : line.Type;

        OrderLine__c newOL = new OrderLine__c(StatusMessage__c = line.StatusMessage
                                              ,PurchaseOrder__c = POId
                                              ,Suppliable__c = 'NO'
                                              ,SASStatus__c = string.isNotBlank(line.Status) ? line.Status.toUpperCase() : ''
                                              ,ExpectedDeliveryDuration__c = (line.DeliveryDays != null) ? String.valueOf(line.DeliveryDays) : calculateEstimationDuration(partType, line.Status, mapTypeDelay));

        if(!isUpdate){
            newOL.TechExternalId__c = POKey + '-' + line.Id;
        }
        else{
            newOL.Id = line.Id;
        }

        system.debug('## end ASPISCreatePOOrderLines processErrorPartOL:'+line.Id);
        return newOL;

    }


    //AMI 18/10/17 : SAS: Remplacement de pièce
    public static OrderLine__c createOrderline(RestDistributorUtility.Lines OL,  
                                                String POKey, 
                                                Id POId, 
                                                Map<String, String> mapTypeDelay, 
                                                Map<Id, PartList__c> partMap, 
                                                Boolean isUpdate, 
                                                String POStatus,
                                                map <ID, OrderLine__c> originalIdTechIdMap,
                                                Boolean isReplacament,
                                                String originalTechExtId,
                                                Boolean setAddPartToNotSuppliable,
                                                map <ID, OrderLine__c> allIdTechIdMap,
                                                String OrderRequest){
        return createOrderline(OL, POKey, POId, mapTypeDelay, partMap, isUpdate, POStatus, originalIdTechIdMap, isReplacament, originalTechExtId, setAddPartToNotSuppliable, allIdTechIdMap, OrderRequest, Rebate);

    }
     public static OrderLine__c createOrderline(RestDistributorUtility.Lines OL,  
                                                String POKey, 
                                                Id POId, 
                                                Map<String, String> mapTypeDelay, 
                                                Map<Id, PartList__c> partMap, 
                                                Boolean isUpdate, 
                                                String POStatus,
                                                map <ID, OrderLine__c> originalIdTechIdMap,
                                                Boolean isReplacament,
                                                String originalTechExtId,
                                                Boolean setAddPartToNotSuppliable,
                                                map <ID, OrderLine__c> allIdTechIdMap,
                                                String OrderRequest,
                                                Decimal RebateReceived){

        system.debug('## start ASPISCreatePOOrderLines  createOrderline:'+OL.Id);

        // system.debug('## OL ' + OL);
        // system.debug('## status '+POStatus);
        // system.debug('## part:'+partMap.get(OL.Id));
        // system.debug('## isReplacament '+isReplacament);
        // system.debug('## originalTechExtId '+originalTechExtId);
        // system.debug('## OL.DeliveryDays '+OL.DeliveryDays);
        // system.debug('## allIdTechIdMap '+allIdTechIdMap);
        // system.debug('## isFromSearchAssessment '+RESTSearchAssessment.isFromSearchAssessment);
        // system.debug('## RebateReceived '+RebateReceived);
        // system.debug('## updateOLRebate '+updateOLRebate);

        //WCH 08/04/2019 C-002854 Update des statusdes OL via UpdatePO
        Id theOLId = OL.Id;

        //RLA 04/06/2020 3697 - IG Search Assessment
        if (RESTSearchAssessment.isFromSearchAssessment || updateOLRebate){
            Rebate = RebateReceived;
        }
        String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);


        string OLStatus = string.isNotBlank(OL.Status) ? OL.Status.toUpperCase() : '';
        system.debug('## OLStatus ' + OLStatus);
        OrderLine__c newOL; 
        String partType = (OL.PartNumber == system.label.AdditionalPartNumber) ? 'A' : OL.Type;

        String canSupply = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO';

        newOL = new OrderLine__c(   ExpectedDeliveryDuration__c = (OL.DeliveryDays != null) ? String.valueOf(OL.DeliveryDays) : ((allIdTechIdMap!=null && allIdTechIdMap.size()>0 && !String.isBlank(allIdTechIdMap.get(theOLId).SASStatus__c) && !String.isBlank(OLStatus) && allIdTechIdMap.get(theOLId).SASStatus__c.equals('CONFIRMEDWITHDELAY') && OLStatus.equals('CONFIRMED') && isUpdate) ? calculateEstimationDuration(partType, 'CONFIRMEDWITHDELAY', mapTypeDelay) : calculateEstimationDuration(partType, OL.Status, mapTypeDelay))//WCH 03/03/2021 C-004203                                   

                                    //AMI 11/09/17 
                                    //SAS Status            | Suppliable
                                    //Confirmed             | YES  
                                    //Confirmed with Delay  | YES
                                    //Not Found             | NO
                                    //Other                 | NO
                                    //Partial               | NO
                                    //Refused               | YES
                                    // ase: 23/02/2018:,Suppliable__c = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO'
                                    
                                    ,OrderType__c = 'Original'
                                    ,PurchaseOrder__c = POId

                                    //WCH 08/04/2019 C-002854 Update des statusdes OL via UpdatePO                                                
                                    ,SASStatus__c = (allIdTechIdMap!=null && allIdTechIdMap.size()>0 && !String.isBlank(allIdTechIdMap.get(theOLId).SASStatus__c) && !String.isBlank(OLStatus) && allIdTechIdMap.get(theOLId).SASStatus__c.equals('CONFIRMEDWITHDELAY') && OLStatus.equals('CONFIRMED') && isUpdate) ? 'CONFIRMEDWITHDELAY' : OLStatus 
                                );

        //AMI 11/09/17 
        //SAS Status            | Price             | Discount
        //Confirmed             | value from SAS    | value from SAS
        //Confirmed with Delay  | value from SAS    | value from SAS
        //Not Found             | N/A               | N/A
        //Other                 | N/A               | N/A
        //Partial               | N/A               | N/A
        //Refused               | N/A               | N/A
        

        if(OL.CatalogPrice != null && OL.CatalogPrice > 0){
            newOL.CataloguePrice__c = OL.CatalogPrice;
        }
        
        // rebate
        // ASE: 22/02/2018   C-002320
        if(OL.AlphaScaleDiscountAdditional != null  && OL.AlphaScaleDiscountAdditional >= 0){
            newOL.Rebate__c = OL.AlphaScaleDiscountAdditional;
        }
        //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
        if (updateOLRebate){
            newOL.Rebate__c = Rebate * 100;
        }
        //BS %
        if(OL.BodyShopDiscount != null  && OL.BodyShopDiscount > 0){
            newOL.BodyShopDiscount__c = OL.BodyShopDiscount;
        }
        // AS discount %
        if(OL.AlphaScaleDiscount != null  && OL.AlphaScaleDiscount > 0){
            newOL.AXADiscount__c = OL.AlphaScaleDiscount;  
        }

        double discount = OL.AlphaScaleDiscountAdditional > 0 ? (OL.AlphaScaleDiscountAdditional/100) : (Rebate/100 > 0 ? Rebate : 0.0);

        //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
        double ASNETPRICE;
        ASNETPRICE = OL.AlphaScaleDiscount != null ? (OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * (1- (discount))) : 0.0;

        decimal asPublicPrice;
        
        //RLA 04/06/2020 3697 - IG Search Assessment
        if(RESTSearchAssessment.isFromSearchAssessment || updateOLRebate){
           asPublicPrice =  OL.CatalogPrice - (OL.CatalogPrice  *  discount);
        } 
        else{
            //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
           asPublicPrice = OL.AlphaScaleDiscount != null ? (OL.CatalogPrice - (OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * discount)) : 0.0;

        }  
        if (keepToUse != 0.0){
            //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
            ASNETPRICE = OL.AlphaScaleDiscount != null ? (OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * (1- (discount * (1-keepToUse)))) : 0.0;

            //RLA 07/10/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages           
            //RLA 30/04/2022 C-004086: BE - Van Wezel Distributor
            asPublicPrice = OL.AlphaScaleDiscount != null ? (OL.CatalogPrice - (OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * (discount * (1 - keepToUse)))) : 0.0;
            
            
        }
        if (isNonAxa){
            asPublicPrice =OL.CatalogPrice;
        }

        system.debug('## discount: '+discount);
        system.debug('## ASNETPRICE: '+ASNETPRICE);
        system.debug('## asPublicPrice: '+asPublicPrice);

        if(!isUpdate){
            newOL.PartList__c = OL.Id;  

            //AMI 18/10/17 : SAS: Remplacement de pièce
            newOL.OriginalItem__r = (isReplacament) ? new OrderLine__c(TechExternalId__c = originalTechExtId) : null;                
            //newOL.TechExternalId__c = (isReplacament) ? (POKey + '-' + OL.PartNumber + '-' + OL.Description) : POKey + '-' + OL.Id; 

            //RLA 18/12/2018 Case C-002955 : Draft calls to distributor : Duplicate external id specified
            newOL.TechExternalId__c = (isReplacament) ? (POKey + '-' + OL.PartNumber + '-' + OL.Description + '-' + OL.ID) : POKey + '-' + OL.Id;

            // ase: 07/06/2018
            // ase: 07/06/2018 : newOL.Suppliable__c = null; 
            if(notAcceptedOLMap.size() > 0 && notAcceptedOLMap.containsKey(newOL.TechExternalId__c)){
                newOL.Suppliable__c = notAcceptedOLMap.get(newOL.TechExternalId__c).Suppliable__c;
                newOL.AcceptedCheck__c = notAcceptedOLMap.get(newOL.TechExternalId__c).AcceptedCheck__c;
                notAcceptedOLMap.remove(newOL.TechExternalId__c);
            }
            else{
                system.debug('not in notAcceptedOLMap '+asPublicPrice);
                newOL.Suppliable__c = (OrderRequest == 'OrderPO') ? ((OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO'): null;
            }


            PartList__c pl;         
            if(partMap.containsKey(OL.Id)){
                pl=  partMap.get(OL.Id);    
                if (!isRepManual){        
                    if(pl.CrossReferenceId__c == null){
                        //AMI 15/02/18 - C-002041 - Distributor V2 - Saving MRID for asp parts
                        newOL.PartNumber__c = partMap.get(OL.Id).PartNumber__c != null ? partMap.get(OL.Id).PartNumber__c : ''; 
                        system.debug('@@ partnumber here: '+ newOL.PartNumber__c);
                        if (RESTSearchAssessment.isFromSearchAssessment){
                            newOL.PartNumber__c = OL.PartNumber;
                        }

                    }
                    else{
                        newOL.PartNumber__c = OL.PartNumber;  
                    }

                    //AMI 15/02/18 - C-002041 - Distributor V2 - Saving MRID for asp parts
                    if(partMap.get(OL.Id).Alpha_Scale_MRID__c != null && (partMap.get(OL.Id).Alpha_Scale_MRID__c.contains('ASP-') || partMap.get(OL.Id).Alpha_Scale_MRID__c.contains(system.label.desubstitureprefix) && partMap.get(OL.Id).Alpha_Scale_MRID__c.contains(prefixPartNumberIGO)) ){
                        newOL.AlphaScaleMRID__c = partMap.get(OL.Id).Alpha_Scale_MRID__c; 
                        newOL.PartNumber__c = OL.PartNumber; 
                    }

                    //AMI 18/10/17 : SAS: Remplacement de pièce
                    if(isReplacament){
                        newOL.PartNumber__c = OL.PartNumber;  
                    }
                }
                else{
                    newOL.PartNumber__c = partMap.get(OL.Id).PartNumber__c != null ? partMap.get(OL.Id).PartNumber__c : ''; 
                    // newOL.PartNumber__c = (newOL.PartNumber__c.startsWith('ASP-')) ? newOL.PartNumber__c.split('ASP-')[1]: 
                    // (newOL.PartNumber__c.startsWith(system.label.desubstitureprefix)) ? newOL.PartNumber__c.split(system.label.desubstitureprefix)[1]: 
                    // newOL.PartNumber__c;
                    //RLA 09/07/2020 C-003857: IG - Creation IGO 
                    newOL.PartNumber__c = RestDistributorUtility.getOemPartNumber (newOL.PartNumber__c , InsuranceBroker, prefixPartNumberIGO);

                }

                newOL.AssessmentPrice__c = (pl != null) ? pl.Price__c : null;      
                newOL.Type__c = (pl != null) ? pl.Type__c : null; 
                newOL.Manufacturer__c = (pl != null) ? pl.ProducerName__c : null; 
                newOL.Description__c = (pl != null) ? pl.Description__c : null; 
                newOL.Quantity__c = (OL.Quantity != null &&  OL.Quantity > 0) ? OL.Quantity : pl.Quantity__c; 

                //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
                if (updateOLRebate){
                    newOL.VAT__c  = pl.VAT__c;
                }

                //ASE: 11/06/18: // AS discount %
                //if(OL.AlphaScaleDiscount != null  && OL.AlphaScaleDiscount > 0 && partMap.containskey(OL.Id)  && (partMap.get(OL.Id).Alpha_Scale_MRID__c ==null || (partMap.get(OL.Id).Alpha_Scale_MRID__c !=null && !(partMap.get(OL.Id).Alpha_Scale_MRID__c).contains('ASP-')))){
                //    system.debug('## original: '+OL.Id);
                //    newOL.AXADiscount__c = OL.AlphaScaleDiscount;  
                //}
                
                //AMI 15/02/18 - C-002041 - Distributor V2 - Recalculate AS Bodyshop Net Price and AS Bodyshop Price for asp parts only  
                //system.debug('## AlphaScale: '+partMap.get(OL.Id).Alpha_Scale_MRID__c);
                if((OL.Status == 'CONFIRMED' || OL.Status == 'CONFIRMEDWITHDELAY') && (OL.AlphaScaleDiscountAdditional > 0 || Rebate > 0) && partMap.containskey(OL.Id) && partMap.get(OL.Id).ForTechSubsNumber__c !=null && partMap.get(OL.Id).ForTechSubsNumber__c.contains('ASP-')){                
                    if(OL.CatalogPrice > 0){    

                        if (String.isnotBlank(insuranceBroker) && String.isnotBlank(prefixPartNumberIGO) && String.isnotblank(pl.Alpha_Scale_MRID__c) && pl.Alpha_Scale_MRID__c.contains(prefixPartNumberIGO)){
                            map <string,object> inputParamCalc = new map <string,object>();

                            // inputParam.put('discount', discountToUse);
                                    
                            inputParamCalc.put('CatalogPrice',OL.CatalogPrice);
                            inputParamCalc.put('AlphaScaleDiscount',OL.AlphaScaleDiscount);

                            //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
                            inputParamCalc.put('isIG', true);

                            map <string,object> updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPricesOEMConnected(inputParamCalc);
                                        

                            ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;

                            asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;

                            system.debug('^^^^^ newly calculated 1');

                        }                    
                        

                        //DUN 14.06.2018 case 2580 when null, consider as 0 instead                     
                        //if(ASNETPRICE != null){
                        //    newOL.ASBodyshopNetPrice__c = ASNETPRICE;
                        //}
                        newOL.ASBodyshopNetPrice__c = ( ASNETPRICE != null ? ASNETPRICE : 0);

                        
                        /*********ASE : 28/05/2018 : changes in calculations*/
                        //double price = OL.CatalogPrice - ASNETPRICE * (discount);          
                        //DUN 14.06.2018 case 2580 when null, consider as 0 instead                                        
                        //if(asPublicPrice != null){
                        //    newOL.ASBodyshopPrice__c = asPublicPrice; 
                        //}
                        newOL.ASBodyshopPrice__c = ( asPublicPrice != null ? asPublicPrice : 0);
                        //ASE: 11/06/18: newOL.AXADiscount__c = (1 - (ASNETPRICE / asPublicPrice))*100;

                    }//end check on catalogue price
                }//end if if((OL.Status == 'CONFIRMED' || OL.Status == 'CONFIRMEDWITHDELAY') && (OL.AlphaScaleDiscountAdditional > 0 || Rebate > 0)){
            }              
        }
        else{
           
            ////ASE: 11/06/18:
            //if(OL.AlphaScaleDiscount != null  && OL.AlphaScaleDiscount > 0 && allIdTechIdMap.containskey(OL.Id) && (allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c == null || (allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c != null && !(allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c).Contains('ASP-')))){
            //    newOL.AXADiscount__c = OL.AlphaScaleDiscount;
            //}
            /////

            if((OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') && (OL.AlphaScaleDiscountAdditional > 0 || Rebate > 0) && allIdTechIdMap.containskey(OL.Id) && allIdTechIdMap.get(OL.Id).SubstituteType__c != null && allIdTechIdMap.get(OL.Id).SubstituteType__c.contains('ASP-')){                
                if(OL.CatalogPrice > 0){                        
                     //DUN 14.06.2018 case 2580 when null, consider as 0 instead     
                    //if(ASNETPRICE != null){
                    //    newOL.ASBodyshopNetPrice__c = ASNETPRICE;
                    //}

                    if (String.isnotBlank(insuranceBroker) && String.isnotBlank(prefixPartNumberIGO) && String.isnotblank(allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c) && allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c.contains(prefixPartNumberIGO)){
                        map <string,object> inputParamCalc = new map <string,object>();

                        // inputParam.put('discount', discountToUse);
                                
                        inputParamCalc.put('CatalogPrice',OL.CatalogPrice);
                        inputParamCalc.put('AlphaScaleDiscount',OL.AlphaScaleDiscount);

                        //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
                        inputParamCalc.put('isIG', true);

                        map <string,object> updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPricesOEMConnected(inputParamCalc);
                                    

                        ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;

                        asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;

                        system.debug('^^^^^ newly calculated 1');

                    }       
                    newOL.ASBodyshopNetPrice__c = ( ASNETPRICE != null ? ASNETPRICE : 0);
                    
                    /*********ASE : 28/05/2018 : changes in calculations*/
                    //double price = OL.CatalogPrice - ASNETPRICE * (discount);      
                    //DUN 14.06.2018 case 2580 when null, consider as 0 instead                                           
                    //if(asPublicPrice != null){
                    //    newOL.ASBodyshopPrice__c = asPublicPrice; 
                    //}
                    newOL.ASBodyshopPrice__c = ( asPublicPrice != null ? asPublicPrice : 0);
                    ////ASE: 11/06/18: newOL.AXADiscount__c = (1 - (ASNETPRICE / asPublicPrice))*100;

                }//end check on catalogue price
            }
            // has alternatives/ bundles, does not require update
            if(OL.Bundle == true){
                newOL = originalIdTechIdMap.get(OL.Id);  
                newOL.Suppliable__c = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO';
                newOL.OrderType__c = 'Original';
                newOL.SASStatus__c = OLStatus ;
                newOL.ExpectedDeliveryDuration__c = (OL.DeliveryDays != null) ? String.valueOf(OL.DeliveryDays) : calculateEstimationDuration(OL.Type, OL.Status, mapTypeDelay);
            }
            else{
                newOL.Id = OL.Id; 
                //newOL.Quantity__c = (OL.Quantity != null &&  OL.Quantity > 0) ? OL.Quantity : originalIdTechIdMap.get(OL.Id).Quantity__c;  
                if(OL.Quantity != null &&  OL.Quantity > 0){
                    newOL.Quantity__c = OL.Quantity;
                } 
                else{
                    if(originalIdTechIdMap.containsKey(OL.Id)){
                        newOL.Quantity__c = originalIdTechIdMap.get(OL.Id).Quantity__c;
                    }
                }               
            }
        }

        if(setAddPartToNotSuppliable && OL.PartNumber == system.label.AdditionalPartNumber){            
            // ase: 23/02/2018:newOL.Suppliable__c = 'NO';
            newOL.Suppliable__c = null;
            //newOL.SASStatus__c = null;
        }

        if(POStatus != null){
            if(POStatus.toUpperCase() == 'INDELIVERY'){
                system.debug('## canSupply: '+canSupply);
                newOL.Suppliable__c = canSupply;
                newOL.AcceptedCheck__c = (canSupply == 'YES') ? true : false;
                system.debug('## newOL.AcceptedCheck__c:'+newOL.AcceptedCheck__c);
                newOL.PreselectedForOrder__c = (canSupply == 'YES') ? true : ((canSupply== 'NO' && OLStatus == 'REFUSED' ) ? true:  false);                
            }
            if(!isUpdate){
                if(OL.Bundle == false ){
                    newOL.OrderType__c = 'FINAL';
                }
            }
            else{
                if(OL.Bundle == false && ((OL.Parts != null  && OL.Parts.size() == 0) || OL.Parts == null) ){                
                    newOL.OrderType__c = 'FINAL';
                }
            } 
        } 

        
        system.debug('## newOL ' + newOL);
        system.debug('## end createOrderline');
        return newOL;
    }
    //Case C-002955 : Draft calls to distributor : Duplicate external id specified
    //RLA 20/12/2018 Addedcount as parameter
    public static OrderLine__c createAlternative(RestDistributorUtility.Parts AL, 
                                                    String POKey, 
                                                    Id POId, 
                                                    String originalId, 
                                                    String orderType, 
                                                    Id OLId, 
                                                    Map<String, String> mapTypeDelay, 
                                                    String OriginalStatus, 
                                                    Map<Id, PartList__c> partMap, 
                                                    Boolean isUpdate, 
                                                    String POStatus,
                                                    String OrderRequest,
                                                    Integer count){
        system.debug('## start ASPISCreatePOOrderLines  createAlternative');
        system.debug('## status '+POStatus);
         system.debug('## originalId '+originalId);
         system.debug('## OLId '+OLId);
         system.debug('## AL:'+AL);

        String status = (AL.Status != null) ? AL.Status : OriginalStatus;
        String partType = (AL.PartNumber == system.label.AdditionalPartNumber) ? 'A' : AL.Type;
        String canSupply = (status == 'CONFIRMED' || status == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO';

        OrderLine__c newOL = new OrderLine__c(Type__c = partType
                                                ,Manufacturer__c = AL.Manufacturer
                                                ,SASStatus__c = status
                                                ,ExpectedDeliveryDuration__c = calculateEstimationDuration(partType, status, mapTypeDelay)                                               
                                                
                                                
                                                //AMI 11/09/17 
                                                //SAS Status            | Suppliable
                                                //Confirmed             | YES  
                                                //Confirmed with Delay  | YES
                                                //Not Found             | NO
                                                //Other                 | NO
                                                //Partial               | NO
                                                //Refused               | YES 
                                                ,Suppliable__c = ((status).toUpperCase() == 'CONFIRMED' || (status).toUpperCase() == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO'
                                                //,Suppliable__c = null
                                                ,Description__c = AL.Description                                                
                                                ,OrderType__c = orderType
                                                ,PurchaseOrder__c = POId
                                                ,PartNumber__c = AL.PartNumber                                                                                           
                                                ,OriginalItem__r = new OrderLine__c(TechExternalId__c = originalId)
                                                //Case C-002955 : Draft calls to distributor : Duplicate external id specified
                                                ,TechExternalId__c =  POKey + '-' + AL.PartNumber + '-' + AL.Description + '-' + count
                                                
                                            );

        //AMI 11/09/17 
        //SAS Status            | Price             | Discount
        //Confirmed             | value from SAS    | value from SAS
        //Confirmed with Delay  | value from SAS    | value from SAS
        //Not Found             | N/A               | N/A
        //Other                 | N/A               | N/A
        //Partial               | N/A               | N/A
        //Refused               | N/A               | N/A
        if(AL.CatalogPrice != null &&  AL.CatalogPrice > 0){
            newOL.CataloguePrice__c = AL.CatalogPrice;
        } 
        // AS discount %
        if(AL.AlphaScaleDiscount != null &&  AL.AlphaScaleDiscount > 0){
            newOL.AXADiscount__c = AL.AlphaScaleDiscount;
        } 
        //BS %
        if(AL.BodyShopDiscount != null &&  AL.BodyShopDiscount > 0){
            newOL.BodyShopDiscount__c = AL.BodyShopDiscount;
        }

        // ASE: 22/02/2018   C-002320
        if(AL.AlphaScaleDiscountAdditional != null &&  AL.AlphaScaleDiscountAdditional >= 0){
            newOL.Rebate__c = AL.AlphaScaleDiscountAdditional;
        }


        if(AL.Quantity != null &&  AL.Quantity > 0){
            newOL.Quantity__c = AL.Quantity;
        }
        else{ 
            if(partMap.containsKey(OLId)){
                newOL.Quantity__c = partMap.get(OLId).Quantity__c;
            }
        }    
                                                

        if(!isUpdate){
            newOL.PartList__c = OLId;  
            newOL.AssessmentPrice__c = partMap.containsKey(OLId) ? partMap.get(OLId).Price__c : null;              
            // ase: 07/06/2018 : newOL.Suppliable__c = null; 
            //if(notAcceptedOLSet.size() > 0 && notAcceptedOLSet.contains(newOL.TechExternalId__c)){
            //    newOL.Suppliable__c ='NO';
            //    notAcceptedOLSet.remove(newOL.TechExternalId__c);
            //}
            if(notAcceptedOLMap.size() > 0 && notAcceptedOLMap.containsKey(newOL.TechExternalId__c)){
                newOL.Suppliable__c = notAcceptedOLMap.get(newOL.TechExternalId__c).Suppliable__c;
                newOL.AcceptedCheck__c = notAcceptedOLMap.get(newOL.TechExternalId__c).AcceptedCheck__c;
                notAcceptedOLMap.remove(newOL.TechExternalId__c);
            }
            else{
                newOL.Suppliable__c = (OrderRequest == 'OrderPO') ? (((status).toUpperCase() == 'CONFIRMED' || (status).toUpperCase() == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO'): null;
            }

        }
        

        if(POStatus != null){
            if(POStatus.toUpperCase() == 'INDELIVERY'){
                system.debug('canSupply:'+canSupply);
                newOL.Suppliable__c = canSupply;
                newOL.AcceptedCheck__c = (canSupply == 'YES') ? true : false;
                system.debug('## newOL.AcceptedCheck__c:'+newOL.AcceptedCheck__c);
                newOL.PreselectedForOrder__c = (canSupply == 'YES') ? true : ((canSupply == 'NO' && newOL.SASStatus__c == 'REFUSED' ) ? true:  false); 
            }            
        }
        
        system.debug('## end createAlternative : '+newOL);
        return newOL;
    }

      public static OrderLine__c createOrderlineGeneric(map<String, Object> mapInputParams){
        
        String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (insuranceBroker);

        RestDistributorUtility.Lines OL = mapInputParams.containsKey('OL') ? (RestDistributorUtility.Lines) mapInputParams.get('OL')  : null;
        String POKey = mapInputParams.containsKey('POKey') ? (String) mapInputParams.get('POKey')  : null;
        Id POId = mapInputParams.containsKey('POId') ? (Id) mapInputParams.get('POId')  : null;
        Id OLId = mapInputParams.containsKey('OLId') ? (Id) mapInputParams.get('OLId')  : null;
        String POStatus = mapInputParams.containsKey('POStatus') ? (String) mapInputParams.get('POStatus')  : null;
        String OrderRequest = mapInputParams.containsKey('OrderRequest') ? (String) mapInputParams.get('OrderRequest')  : null;
        map<Id,OrderLine__c> mapPartlistOL = mapInputParams.containsKey('mapPartlistOL') ? (map<Id,OrderLine__c>) mapInputParams.get('mapPartlistOL')  : new map<Id,OrderLine__c>();
        String originalTechExtId = mapInputParams.containsKey('originalTechExtId') ? (String) mapInputParams.get('originalTechExtId')  : null;
        Decimal RebateReceived = mapInputParams.containsKey('RebateReceived') ? (Decimal) mapInputParams.get('RebateReceived')  : null;
        Boolean isUpdate = mapInputParams.containsKey('isUpdate') ? (Boolean) mapInputParams.get('isUpdate')  : false;
        Boolean isReplacament = mapInputParams.containsKey('isReplacament') ? (Boolean) mapInputParams.get('isReplacament')  : false;
        Boolean isRepManual = mapInputParams.containsKey('isRepManual') ? (Boolean) mapInputParams.get('isRepManual')  : false;
        Boolean setAddPartToNotSuppliable = mapInputParams.containsKey('setAddPartToNotSuppliable') ? (Boolean) mapInputParams.get('setAddPartToNotSuppliable')  : false;
        Boolean isIG = mapInputParams.containsKey('isIG') ? (Boolean) mapInputParams.get('isIG')  : false;
        Map<String, String> mapTypeDelay = mapInputParams.containsKey('mapTypeDelay') ? (Map<String, String>) mapInputParams.get('mapTypeDelay')  : new Map<String, String>();
        Map<Id, PartList__c> partMap = mapInputParams.containsKey('partMap') ? (Map<Id, PartList__c>) mapInputParams.get('partMap')  : new Map<Id, PartList__c>();
        map <ID, OrderLine__c> originalIdTechIdMap = mapInputParams.containsKey('originalIdTechIdMap') ? (map <ID, OrderLine__c>) mapInputParams.get('originalIdTechIdMap')  :  new map <ID, OrderLine__c>();
        map <ID, OrderLine__c> allIdTechIdMap = mapInputParams.containsKey('allIdTechIdMap') ? (map <ID, OrderLine__c>) mapInputParams.get('allIdTechIdMap')  : new map <ID, OrderLine__c>();
        set<String> setAllowedSubstitutes =  mapInputParams.containsKey('SubstitutesTypes') ? (set<String>)mapInputParams.get('SubstitutesTypes') : new set<String>();      
       

        // system.debug('## start ASPISCreatePOOrderLines  createOrderlineGeneric:'+OL.Id);originalIdTechIdMap

        system.debug('## mapPartlistOL: '+mapPartlistOL);



       //WCH 08/04/2019 C-002854 Update des statusdes OL via UpdatePO
        Id theOLId = OL.Id;

        //RLA 04/06/2020 3697 - IG Search Assessment
        if (RESTSearchAssessment.isFromSearchAssessment || updateOLRebate){
            Rebate = RebateReceived;
        }

        string OLStatus = string.isNotBlank(OL.Status) ? OL.Status.toUpperCase() : '';
        system.debug('## OLStatus ' + OLStatus);
        OrderLine__c newOL; 
        String partType = (OL.PartNumber == system.label.AdditionalPartNumber) ? 'A' : OL.Type;

        String canSupply = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO';

        newOL = new OrderLine__c(   ExpectedDeliveryDuration__c = (OL.DeliveryDays != null) ? String.valueOf(OL.DeliveryDays) : calculateEstimationDuration(partType, OL.Status, mapTypeDelay)                                   

                                    //AMI 11/09/17 
                                    //SAS Status            | Suppliable
                                    //Confirmed             | YES  
                                    //Confirmed with Delay  | YES
                                    //Not Found             | NO
                                    //Other                 | NO
                                    //Partial               | NO
                                    //Refused               | YES
                                    // ase: 23/02/2018:,Suppliable__c = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO'
                                    
                                    ,OrderType__c = isRepManual ? 'Final' : 'Original'
                                    ,PurchaseOrder__c = POId

                                    //WCH 08/04/2019 C-002854 Update des statusdes OL via UpdatePO                                                
                                    ,SASStatus__c = (allIdTechIdMap!=null && allIdTechIdMap.size()>0 && !String.isBlank(allIdTechIdMap.get(theOLId).SASStatus__c) && !String.isBlank(OLStatus) && allIdTechIdMap.get(theOLId).SASStatus__c.equals('CONFIRMEDWITHDELAY') && OLStatus.equals('CONFIRMED') && isUpdate) ? 'CONFIRMEDWITHDELAY' : OLStatus 
                                );

        //AMI 11/09/17 
        //SAS Status            | Price             | Discount
        //Confirmed             | value from SAS    | value from SAS
        //Confirmed with Delay  | value from SAS    | value from SAS
        //Not Found             | N/A               | N/A
        //Other                 | N/A               | N/A
        //Partial               | N/A               | N/A
        //Refused               | N/A               | N/A
        

        if(OL.CatalogPrice != null && OL.CatalogPrice > 0){
            newOL.CataloguePrice__c = OL.CatalogPrice;
        }
        
        // rebate
        // ASE: 22/02/2018   C-002320
        if(OL.AlphaScaleDiscountAdditional != null  && OL.AlphaScaleDiscountAdditional >= 0){
            newOL.Rebate__c = OL.AlphaScaleDiscountAdditional;
        }
        //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
        if (updateOLRebate){
            newOL.Rebate__c = Rebate * 100;
        }
        //BS %
        if(OL.BodyShopDiscount != null  && OL.BodyShopDiscount > 0){
            newOL.BodyShopDiscount__c = OL.BodyShopDiscount;
        }
        // AS discount %
        if(OL.AlphaScaleDiscount != null  && OL.AlphaScaleDiscount > 0){
            newOL.AXADiscount__c = OL.AlphaScaleDiscount;  
        }

        double discount = OL.AlphaScaleDiscountAdditional > 0 ? (OL.AlphaScaleDiscountAdditional/100) : (Rebate/100 > 0 ? Rebate : 0.0);
        double ASNETPRICE = OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * (1- (discount));
        decimal asPublicPrice;
        
        //RLA 04/06/2020 3697 - IG Search Assessment
        if(RESTSearchAssessment.isFromSearchAssessment || updateOLRebate){
           asPublicPrice =  OL.CatalogPrice - (OL.CatalogPrice  *  discount);
            system.debug('## asPublicPrice here: '+asPublicPrice);
        } 
        else{
           asPublicPrice = OL.CatalogPrice - (OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * discount);

        }  

        
        if (keepToUse != 0.0){
            ASNETPRICE = OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * (1- (discount) * (1-keepToUse));
            asPublicPrice = OL.CatalogPrice - (OL.CatalogPrice  * (1 - (OL.AlphaScaleDiscount/100))  * discount * keepToUse);
        }
        
        system.debug('## discount: '+discount);
        system.debug('## ASNETPRICE: '+ASNETPRICE);
        system.debug('## asPublicPrice: '+asPublicPrice);

        if(!isUpdate){
            newOL.PartList__c = OL.Id;  

            //AMI 18/10/17 : SAS: Remplacement de pièce
            newOL.OriginalItem__r = (isReplacament) ? new OrderLine__c(TechExternalId__c = originalTechExtId) : null;                
            //newOL.TechExternalId__c = (isReplacament) ? (POKey + '-' + OL.PartNumber + '-' + OL.Description) : POKey + '-' + OL.Id; 

            
           
            //RLA 18/12/2018 Case C-002955 : Draft calls to distributor : Duplicate external id specified
            newOL.TechExternalId__c = (isReplacament) ? (POKey + '-' + OL.PartNumber + '-' + OL.Description + '-' + OL.ID) : POKey + '-' + OL.Id;
            

            // ase: 07/06/2018
            // ase: 07/06/2018 : newOL.Suppliable__c = null; 
            if(notAcceptedOLMap.size() > 0 && notAcceptedOLMap.containsKey(newOL.TechExternalId__c)){
                newOL.Suppliable__c = notAcceptedOLMap.get(newOL.TechExternalId__c).Suppliable__c;
                newOL.AcceptedCheck__c = notAcceptedOLMap.get(newOL.TechExternalId__c).AcceptedCheck__c;
                notAcceptedOLMap.remove(newOL.TechExternalId__c);
            }
            else{
                system.debug('not in notAcceptedOLMap '+asPublicPrice);
                newOL.Suppliable__c = (OrderRequest == 'OrderPO') ? ((OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO'): null;
            }


            PartList__c pl;         
            if(partMap.containsKey(OL.Id)){
                pl=  partMap.get(OL.Id);    
                if (!isRepManual){        
                    if(pl.CrossReferenceId__c == null){
                        //AMI 15/02/18 - C-002041 - Distributor V2 - Saving MRID for asp parts
                        newOL.PartNumber__c = partMap.get(OL.Id).PartNumber__c != null ? partMap.get(OL.Id).PartNumber__c : ''; 
                        system.debug('@@ partnumber here: '+ newOL.PartNumber__c);
                        if (RESTSearchAssessment.isFromSearchAssessment){
                            newOL.PartNumber__c = OL.PartNumber;
                        }

                    }
                    else{
                        newOL.PartNumber__c = OL.PartNumber;  
                        system.debug('@@ partnumber here: '+ newOL.PartNumber__c);
                    }
                    system.debug('@@ partMap.get(OL.Id).Alpha_Scale_MRID__c '+ partMap.get(OL.Id).Alpha_Scale_MRID__c);

                    //AMI 15/02/18 - C-002041 - Distributor V2 - Saving MRID for asp parts
                    if(partMap.get(OL.Id).Alpha_Scale_MRID__c != null && (partMap.get(OL.Id).Alpha_Scale_MRID__c.contains('ASP-') || partMap.get(OL.Id).Alpha_Scale_MRID__c.contains(system.label.desubstitureprefix) && partMap.get(OL.Id).Alpha_Scale_MRID__c.contains(prefixPartNumberIGO)) ){
                        newOL.AlphaScaleMRID__c = partMap.get(OL.Id).Alpha_Scale_MRID__c; 
                        newOL.PartNumber__c = OL.PartNumber; 
                        system.debug('@@ partnumber here: '+ newOL.PartNumber__c);

                    }

                    //AMI 18/10/17 : SAS: Remplacement de pièce
                    if(isReplacament){
                        newOL.PartNumber__c = OL.PartNumber;  
                        system.debug('@@ partnumber here: '+ newOL.PartNumber__c);

                    }
                    newOL.Description__c = (pl != null) ? pl.Description__c : null; 
                }
                else{
                    newOL.PartNumber__c = OL.PartNumber; 
                    // newOL.PartNumber__c = (newOL.PartNumber__c.startsWith('ASP-')) ? newOL.PartNumber__c.split('ASP-')[1]: 
                    // (newOL.PartNumber__c.startsWith(system.label.desubstitureprefix)) ? newOL.PartNumber__c.split(system.label.desubstitureprefix)[1]: 
                    // newOL.PartNumber__c;
                    //RLA 09/07/2020 C-003857: IG - Creation IGO 
                    newOL.PartNumber__c = RestDistributorUtility.getOemPartNumber (newOL.PartNumber__c , InsuranceBroker, prefixPartNumberIGO);

                    //RLA 10/09/2020 for automatic replacements
                    newOL.TechExternalId__c = mapPartlistOL.containsKey(pl.Id) ? mapPartlistOL.get(pl.Id).TechExternalId__c : (isReplacament) ? (POKey + '-' + OL.PartNumber + '-' + OL.Description + '-' + OL.ID) : POKey + '-' + OL.Id;

                    newOL.Description__c = OL.Description; 

                   
                }

               
                newOL.AssessmentPrice__c = (pl != null) ? pl.Price__c : null;      
                newOL.Type__c = (pl != null) ? pl.Type__c : null; 
                newOL.Manufacturer__c = (pl != null) ? pl.ProducerName__c : null; 
                
                newOL.Quantity__c = (OL.Quantity != null &&  OL.Quantity > 0) ? OL.Quantity : pl.Quantity__c; 

                //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
                if (updateOLRebate){
                    newOL.VAT__c  = pl.VAT__c;
                }

                //ASE: 11/06/18: // AS discount %
                //if(OL.AlphaScaleDiscount != null  && OL.AlphaScaleDiscount > 0 && partMap.containskey(OL.Id)  && (partMap.get(OL.Id).Alpha_Scale_MRID__c ==null || (partMap.get(OL.Id).Alpha_Scale_MRID__c !=null && !(partMap.get(OL.Id).Alpha_Scale_MRID__c).contains('ASP-')))){
                //    system.debug('## original: '+OL.Id);
                //    newOL.AXADiscount__c = OL.AlphaScaleDiscount;  
                //}
                system.debug('## Rebate:'+Rebate);
                
                //AMI 15/02/18 - C-002041 - Distributor V2 - Recalculate AS Bodyshop Net Price and AS Bodyshop Price for asp parts only  
                //system.debug('## AlphaScale: '+partMap.get(OL.Id).Alpha_Scale_MRID__c);
                if((OL.Status == 'CONFIRMED' || OL.Status == 'CONFIRMEDWITHDELAY') && (OL.AlphaScaleDiscountAdditional > 0 || Rebate > 0) && partMap.containskey(OL.Id) && partMap.get(OL.Id).ForTechSubsNumber__c !=null && partMap.get(OL.Id).ForTechSubsNumber__c.contains('ASP-')){                
                    system.debug('## ASP: '+OL.Id);
                    if(OL.CatalogPrice > 0){   

                        
                        if (setAllowedSubstitutes.size() > 0 && setAllowedSubstitutes.contains('Connected Substitute') && String.isnotblank(pl.Alpha_Scale_MRID__c) && pl.Alpha_Scale_MRID__c.contains(system.label.desubstitureprefix) && String.isnotBlank(insuranceBroker)) {
                            newOL.ASBodyshopNetPrice__c = ( ASNETPRICE != null ? ASNETPRICE : 0);
                            system.debug('^^^^^ here 3');

                            newOL.ASBodyshopPrice__c = ( asPublicPrice != null ? asPublicPrice : 0);

                            newOL.TechSubstituteType__c = 'ASP-';
                            if ( mapPartlistOL.containsKey(pl.Id) && mapPartlistOL.get(pl.Id).UpdateOLinfo__c ){
                                system.debug('@@ i will update description here');
                                if(string.isNotBlank(partMap.get(OL.Id).ProducerName__c)){
                                    if (isIG){
                                        newOL.Description__c =OL.Description + ' - ' + partMap.get(OL.Id).ProducerName__c + ' -OEM (' + OL.PartNumber + ')';

                                    }
                                    else{
                                        newOL.Description__c = OL.Description + ' - ' + partMap.get(OL.Id).ProducerName__c + ' (' + OL.PartNumber + ') - ' + system.label.ASPDesc;
                                    }
                                }else{
                                    if (isIG){
                                        newOL.Description__c = OL.Description + ' -OEM ' + '(' + OL.PartNumber + ')';
                                    }
                                    else{
                                        newOL.Description__c = OL.Description + ' - ' + '(' + OL.PartNumber + ') - '+ system.label.ASPDesc;

                                    }
                                }
                            } 
                            newOL.AlphaScaleMRID__c = system.label.desubstitureprefix+OL.PartNumber;                             

                        }       
                        else if ( String.isnotBlank(insuranceBroker)                         
                        ){
                            map <string,object> inputParamCalc = new map <string,object>();

                            // inputParam.put('discount', discountToUse);
                                    
                            inputParamCalc.put('CatalogPrice',OL.CatalogPrice);
                            inputParamCalc.put('AlphaScaleDiscount',OL.AlphaScaleDiscount);

                            //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
                            inputParamCalc.put('isIG', true);

                            map <string,object> updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPricesOEMConnected(inputParamCalc);
                                        

                            ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;

                            asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;

                           if (setAllowedSubstitutes.size() > 0 && setAllowedSubstitutes.contains('Connected OEM') && String.isnotBlank(prefixPartNumberIGO) && String.isnotblank(pl.Alpha_Scale_MRID__c) && pl.Alpha_Scale_MRID__c.contains(prefixPartNumberIGO)){
                                // newOL.TechSubstituteType__c = 'ASP-';    
                                if ( mapPartlistOL.containsKey(pl.Id) && mapPartlistOL.get(pl.Id).UpdateOLinfo__c ){
                                     system.debug('@@ i will update description here');
                                    if(string.isNotBlank(partMap.get(OL.Id).ProducerName__c)){
                                        if (isIG){
                                            newOL.Description__c =OL.Description + ' - ' + partMap.get(OL.Id).ProducerName__c + ' -Original (' + OL.PartNumber + ')';

                                        }
                                        else{
                                            newOL.Description__c = OL.Description + ' - ' + partMap.get(OL.Id).ProducerName__c + ' (' + OL.PartNumber + ') - ' + system.label.ASPDesc;
                                        }
                                    }else{
                                        if (isIG){
                                            newOL.Description__c = OL.Description + ' -Original ' + '(' + OL.PartNumber + ')';
                                        }
                                        else{
                                            newOL.Description__c = OL.Description + ' - ' + '(' + OL.PartNumber + ') - '+ system.label.ASPDesc;

                                        }
                                    }
                                } 
                                newOL.AlphaScaleMRID__c = prefixPartNumberIGO+OL.PartNumber;                           
                            }
                            else{
                                newOL.Rebate__c = 0;
                            }

                            //DUN 14.06.2018 case 2580 when null, consider as 0 instead                     
                            if(ASNETPRICE != null){
                               newOL.ASBodyshopNetPrice__c = ASNETPRICE;
                            }

                            /*********ASE : 28/05/2018 : changes in calculations*/
                            //double price = OL.CatalogPrice - ASNETPRICE * (discount);          
                            //DUN 14.06.2018 case 2580 when null, consider as 0 instead                                        
                            if(asPublicPrice != null){
                               newOL.ASBodyshopPrice__c = asPublicPrice; 
                            }

                            system.debug('^^^^^ newly calculated 1');
                        } 
                        else{
                             //DUN 14.06.2018 case 2580 when null, consider as 0 instead                     
                            if(ASNETPRICE != null){
                               newOL.ASBodyshopNetPrice__c = ASNETPRICE;
                            }

                            /*********ASE : 28/05/2018 : changes in calculations*/
                            //double price = OL.CatalogPrice - ASNETPRICE * (discount);          
                            //DUN 14.06.2018 case 2580 when null, consider as 0 instead                                        
                            if(asPublicPrice != null){
                               newOL.ASBodyshopPrice__c = asPublicPrice; 
                            }

                        }                 
                        

                       
                        
                        //ASE: 11/06/18: newOL.AXADiscount__c = (1 - (ASNETPRICE / asPublicPrice))*100;

                    }//end check on catalogue price
                }//end if if((OL.Status == 'CONFIRMED' || OL.Status == 'CONFIRMEDWITHDELAY') && (OL.AlphaScaleDiscountAdditional > 0 || Rebate > 0)){
            }              
        }
        else{
            system.debug('## allIdTechIdMap:'+allIdTechIdMap);
            system.debug('## OL.Id:'+OL.Id);
            ////ASE: 11/06/18:
            //if(OL.AlphaScaleDiscount != null  && OL.AlphaScaleDiscount > 0 && allIdTechIdMap.containskey(OL.Id) && (allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c == null || (allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c != null && !(allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c).Contains('ASP-')))){
            //    newOL.AXADiscount__c = OL.AlphaScaleDiscount;
            //}
            /////

            if((OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') && (OL.AlphaScaleDiscountAdditional > 0 || Rebate > 0) && allIdTechIdMap.containskey(OL.Id) && allIdTechIdMap.get(OL.Id).SubstituteType__c != null && allIdTechIdMap.get(OL.Id).SubstituteType__c.contains('ASP-')){                
                if(OL.CatalogPrice > 0){                        
                     //DUN 14.06.2018 case 2580 when null, consider as 0 instead     
                    //if(ASNETPRICE != null){
                    //    newOL.ASBodyshopNetPrice__c = ASNETPRICE;
                    //}
                   
                    if (setAllowedSubstitutes.size() > 0 && setAllowedSubstitutes.contains('Connected Substitute') && String.isnotblank(allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c) && allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c.contains(system.label.desubstitureprefix)) {
                        newOL.ASBodyshopNetPrice__c = ( ASNETPRICE != null ? ASNETPRICE : 0);
                        system.debug('^^^^^ here 3');

                        newOL.ASBodyshopPrice__c = ( asPublicPrice != null ? asPublicPrice : 0);

                        newOL.TechSubstituteType__c = 'ASP-';

                         if ( mapPartlistOL.containsKey(allIdTechIdMap.get(OL.Id).Id) && mapPartlistOL.get(allIdTechIdMap.get(OL.Id).Id).UpdateOLinfo__c ){
                                system.debug('@@ i will update description here');
                            if(string.isNotBlank(OL.Brand)){
                                if (isIG){
                                    newOL.Description__c =OL.Description + ' - ' + OL.Brand + ' -OEM (' + OL.PartNumber + ')';

                                }
                                else{
                                    newOL.Description__c = OL.Description + ' - ' + OL.Brand + ' (' + OL.PartNumber + ') - ' + system.label.ASPDesc;
                                }
                            }else{
                                if (isIG){
                                    newOL.Description__c = OL.Description + ' -OEM ' + '(' + OL.PartNumber + ')';
                                }
                                else{
                                    newOL.Description__c = OL.Description + ' - ' + '(' + OL.PartNumber + ') - '+ system.label.ASPDesc;

                                }
                            }
                        } 
                        // newOL.AlphaScaleMRID__c = allIdTechIdMap.get(OL.Id).Alpha_Scale_MRID__c;  


                    }       
                    else if ( String.isnotBlank(insuranceBroker)                     
                    ){
                        map <string,object> inputParamCalc = new map <string,object>();

                        // inputParam.put('discount', discountToUse);
                                
                        inputParamCalc.put('CatalogPrice',OL.CatalogPrice);
                        inputParamCalc.put('AlphaScaleDiscount',OL.AlphaScaleDiscount);

                        //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
                        inputParamCalc.put('isIG', true);

                        map <string,object> updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPricesOEMConnected(inputParamCalc);
                                    

                        ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;

                        asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;

                        if (setAllowedSubstitutes.size() > 0 && setAllowedSubstitutes.contains('Connected OEM') && String.isnotBlank(prefixPartNumberIGO) && String.isnotblank(allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c) && allIdTechIdMap.get(OL.Id).AlphaScaleMRID__c.contains(prefixPartNumberIGO)){
                            // newOL.TechSubstituteType__c = 'ASP-';
                            if ( mapPartlistOL.containsKey(allIdTechIdMap.get(OL.Id).Id) && mapPartlistOL.get(allIdTechIdMap.get(OL.Id).Id).UpdateOLinfo__c ){
                                    system.debug('@@ i will update description here');
                                if(string.isNotBlank(OL.Brand)){
                                    if (isIG){
                                        newOL.Description__c =OL.Description + ' - ' + OL.Brand + ' -Original (' + OL.PartNumber + ')';

                                    }
                                    else{
                                        newOL.Description__c = OL.Description + ' - ' + OL.Brand + ' (' + OL.PartNumber + ') - ' + system.label.ASPDesc;
                                    }
                                }else{
                                    if (isIG){
                                        newOL.Description__c = OL.Description + ' -Original ' + '(' + OL.PartNumber + ')';
                                    }
                                    else{
                                        newOL.Description__c = OL.Description + ' - ' + '(' + OL.PartNumber + ') - '+ system.label.ASPDesc;

                                    }
                                }
                            }  
                            
                        }

                         //DUN 14.06.2018 case 2580 when null, consider as 0 instead     
                        //if(ASNETPRICE != null){
                        //    newOL.ASBodyshopNetPrice__c = ASNETPRICE;
                        //}
                        newOL.ASBodyshopNetPrice__c = ( ASNETPRICE != null ? ASNETPRICE : 0);
                        
                        /*********ASE : 28/05/2018 : changes in calculations*/
                        //double price = OL.CatalogPrice - ASNETPRICE * (discount);      
                        //DUN 14.06.2018 case 2580 when null, consider as 0 instead                                           
                        //if(asPublicPrice != null){
                        //    newOL.ASBodyshopPrice__c = asPublicPrice; 
                        //}
                        newOL.ASBodyshopPrice__c = ( asPublicPrice != null ? asPublicPrice : 0);
                        ////ASE: 11/06/18: newOL.AXADiscount__c = (1 - (ASNETPRICE / asPublicPrice))*100;



                        system.debug('^^^^^ newly calculated 1');
                    } 
                    else{
                         //DUN 14.06.2018 case 2580 when null, consider as 0 instead     
                        //if(ASNETPRICE != null){
                        //    newOL.ASBodyshopNetPrice__c = ASNETPRICE;
                        //}
                        newOL.ASBodyshopNetPrice__c = ( ASNETPRICE != null ? ASNETPRICE : 0);
                        
                        /*********ASE : 28/05/2018 : changes in calculations*/
                        //double price = OL.CatalogPrice - ASNETPRICE * (discount);      
                        //DUN 14.06.2018 case 2580 when null, consider as 0 instead                                           
                        //if(asPublicPrice != null){
                        //    newOL.ASBodyshopPrice__c = asPublicPrice; 
                        //}
                        newOL.ASBodyshopPrice__c = ( asPublicPrice != null ? asPublicPrice : 0);
                        ////ASE: 11/06/18: newOL.AXADiscount__c = (1 - (ASNETPRICE / asPublicPrice))*100;

                    } 

                }//end check on catalogue price
            }
            // has alternatives/ bundles, does not require update
            if(OL.Bundle == true){
                newOL = originalIdTechIdMap.get(OL.Id);  
                newOL.Suppliable__c = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO';
                newOL.OrderType__c = 'Original';
                newOL.SASStatus__c = OLStatus ;
                newOL.ExpectedDeliveryDuration__c = (OL.DeliveryDays != null) ? String.valueOf(OL.DeliveryDays) : calculateEstimationDuration(OL.Type, OL.Status, mapTypeDelay);
            }
            else{
                newOL.Id = OL.Id; 
                //newOL.Quantity__c = (OL.Quantity != null &&  OL.Quantity > 0) ? OL.Quantity : originalIdTechIdMap.get(OL.Id).Quantity__c;  
                if(OL.Quantity != null &&  OL.Quantity > 0){
                    newOL.Quantity__c = OL.Quantity;
                } 
                else{
                    if(originalIdTechIdMap.containsKey(OL.Id)){
                        newOL.Quantity__c = originalIdTechIdMap.get(OL.Id).Quantity__c;
                    }
                }               
            }
        }

        if(setAddPartToNotSuppliable && OL.PartNumber == system.label.AdditionalPartNumber){            
            // ase: 23/02/2018:newOL.Suppliable__c = 'NO';
            newOL.Suppliable__c = null;
            //newOL.SASStatus__c = null;
        }

        if(POStatus != null){
            if(POStatus.toUpperCase() == 'INDELIVERY'){
                system.debug('## canSupply: '+canSupply);
                newOL.Suppliable__c = canSupply;
                newOL.AcceptedCheck__c = (canSupply == 'YES') ? true : false;
                system.debug('## newOL.AcceptedCheck__c:'+newOL.AcceptedCheck__c);
                newOL.PreselectedForOrder__c = (canSupply == 'YES') ? true : ((canSupply== 'NO' && OLStatus == 'REFUSED' ) ? true:  false);                
            }
            if(!isUpdate){
                if(OL.Bundle == false ){
                    newOL.OrderType__c = 'FINAL';
                }
            }
            else{
                if(OL.Bundle == false && ((OL.Parts != null  && OL.Parts.size() == 0) || OL.Parts == null) ){                
                    newOL.OrderType__c = 'FINAL';
                }
            } 
        } 
        return newOL;


    }

    // (CataloguePrice__c * quantity) of all bundles                                                
    public static Double calculateTotalPrice(OrderLine__c ol){
        system.debug('## start calculateTotalPrice');
        return (((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) * 
                ((ol.Quantity__c == null) ? 0 : ol.Quantity__c));
    }

    //(CataloguePrice__c * (1-(AXADiscount__c+TECH_ExtraAS__c)%) * (1- AdditionnalDiscount__c%) * Quantity__c)
    public static Double calculateAXATotalPrice(OrderLine__c ol){
        system.debug('## start calculateAXATotalPrice');
        return (((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) * 
                (1 - ((((ol.AXADiscount__c == null) ? 0 : ol.AXADiscount__c) + ((ol.TECH_ExtraAS__c == null) ? 0 : ol.TECH_ExtraAS__c)) / 100.0)) * 
                (1 - ((ol.AdditionnalDiscount__c == null) ? 0 : ol.AdditionnalDiscount__c) / 100.0)) *
               ((ol.Quantity__c == null) ? 0 : ol.Quantity__c);
    }

    //(CataloguePrice__c * (1-(BodyShopDiscount__c)%) * (1- AdditionnalDiscount__c%) * Quantity__c)
    public static Double calculateBodyShopTotalPrice(OrderLine__c ol){
        system.debug('## start calculateBodyShopTotalPrice');
        return (((ol.CataloguePrice__c == null) ? 0 : ol.CataloguePrice__c) * 
                (1 - ((ol.BodyShopDiscount__c == null) ? 0 : ol.BodyShopDiscount__c) / 100.0) * 
                (1 - ((ol.AdditionnalDiscount__c == null) ? 0 : ol.AdditionnalDiscount__c) / 100.0))*
               ((ol.Quantity__c == null) ? 0 : ol.Quantity__c);
    }

    public static OrderLine__c updateFinalOL(String finalTechExternalId, OrderLine__c finalOL, Double finalTotalPrice, Double finalAXATotalPrice, Double finalBodyShopTotalPrice, double finalQuantity, String maximumDelivery, String bundleDescription){
        system.debug('## start updateFinalOL :'+finalTechExternalId);
        finalOL.TechGeneratedFinal__c = true;
        finalOL.OriginalItem__r =  new OrderLine__c(TechExternalId__c = finalTechExternalId);
        finalOL.TechFinalTotalPrice__c = finalTotalPrice;
        finalOL.TechFinalTotalAxaPrice__c = finalAXATotalPrice;
        finalOL.TechFinalBSTotalPrice__c = finalBodyShopTotalPrice;
        finalOL.Quantity__c = finalQuantity;
        finalOL.AXADiscount__c = (finalTotalPrice > 0) ? ((finalTotalPrice - finalAXATotalPrice) / finalTotalPrice) * 100 : 0;
        finalOL.BodyShopDiscount__c = (finalTotalPrice > 0) ? ((finalTotalPrice - finalBodyShopTotalPrice) / finalTotalPrice) * 100 : 0;
        finalOL.BundleItemsDescription__c = bundleDescription;
        finalOL.OrderType__c = 'FINAL';

        system.debug('## end updateFinalOL');
        return finalOL;
    }   

    public static Map<String,String> getTypeDelayMap(String TypeRegionDelay){
        system.debug('## start getTypeDelayMap');

        Map<String,String> mapTypeDelay = new Map<String,String> ();    
        if(TypeRegionDelay != null && TypeRegionDelay.contains(';')){
            for(String matrixline : TypeRegionDelay.split(';')){
                list<String> matrixValues = matrixline.split(':');
                String partType = matrixValues[0].right(1);
                String delayValue = matrixValues[2];
                if(!mapTypeDelay.containsKey(partType)){
                    mapTypeDelay.put(partType, delayValue);
                }
            }
        }   
        
        system.debug('## end getTypeDelayMap:'+mapTypeDelay);
        return mapTypeDelay;        
    }

    public static string calculateEstimationDuration(String Type, String status, Map<String,String> getTypeDelayMap){
        system.debug('## start calculateEstimationDuration');
        String duration;

        list<String> durationValues = new list <String>();

        if(getTypeDelayMap != null && getTypeDelayMap.containsKey(Type)){
            durationValues = getTypeDelayMap.get(Type).split('_');
        }else{
            return '0';
        }

        if(status.toUpperCase() == 'CONFIRMED'){
            duration = String.ValueOf(Integer.valueOf(durationValues[0]) /24);
        }
        else if (status.toUpperCase() == 'CONFIRMEDWITHDELAY') {
            if (durationValues.size() > 1) {
                duration = String.ValueOf(Integer.valueOf(durationValues[1].replace('}',''))/24);
            }
        }
        else if(status.toUpperCase() == 'PARTIAL'){
            if(durationValues.size() > 1){
                duration = String.ValueOf(Integer.valueOf(durationValues[1].replace('}',''))/24);
            }else{
                duration = '0';
            }
        }
        else{
            duration = '0';
        }
        system.debug('## end calculateEstimationDuration :'+duration);
        return duration;
    } 
    //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check 
    public static void upsertAll(map<Id, list<OrderLine__c>> originalOLMap, 
                                map<Id, list<OrderLine__c>> alternativeOLMap, 
                                map<Id, list<OrderLine__c>> bundleItemOLMap,
                                map<Id, list<OrderLine__c>> originalOLMapToUpd, 
                                map<Id, list<OrderLine__c>> alternativeOLMapToUpd, 
                                map<Id, list<OrderLine__c>> bundleItemOLMapToUpd,  
                                Id assessmentId, 
                                map<Id, PurchaseOrder__c> POMap, 
                                map<string, PurchaseOrder__c> insertedPOMap,
                                Boolean doNotCreateClassicOL,
                                list<responseToGenerate> sasResList,
                                Boolean isUpdate,
                                set<Id> oriOLToDelSet,                                
                                String fromUpdateStockInfo){//RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO
        upsertAll(originalOLMap,alternativeOLMap,bundleItemOLMap, originalOLMapToUpd,alternativeOLMapToUpd,bundleItemOLMapToUpd, assessmentId, POMap, insertedPOMap, doNotCreateClassicOL, sasResList, isUpdate, oriOLToDelSet, null,fromUpdateStockInfo  );

    }

    public static void upsertAll(map<Id, list<OrderLine__c>> originalOLMap, 
                                map<Id, list<OrderLine__c>> alternativeOLMap, 
                                map<Id, list<OrderLine__c>> bundleItemOLMap,
                                map<Id, list<OrderLine__c>> originalOLMapToUpd, 
                                map<Id, list<OrderLine__c>> alternativeOLMapToUpd, 
                                map<Id, list<OrderLine__c>> bundleItemOLMapToUpd,  
                                Id assessmentId, 
                                map<Id, PurchaseOrder__c> POMap, 
                                map<string, PurchaseOrder__c> insertedPOMap,
                                Boolean doNotCreateClassicOL,
                                list<responseToGenerate> sasResList,
                                Boolean isUpdate,
                                set<Id> oriOLToDelSet,   
                                map <Id, PartList__c> updatedPartMap, //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check                              
                                String fromUpdateStockInfo){//RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO

        system.debug('## start upsertOL');

        //String results = '';
        Map<String, String> errorMsgMap = new Map<String, String>();

        Schema.SObjectField OLExtId = OrderLine__c.Fields.TechExternalId__c;

        Set<Id> POSuccessSet = new set<Id>();

        //this map is used to get info on po during error reporting 
        //original map insertedPOMap cannot be used since key used to populate errorMap is not the same as insertedPOMap
        map<string, PurchaseOrder__c> mapInsertedPOReworked = new map<string, PurchaseOrder__c>();

        map<Id, PurchaseOrder__c> POToUpdate = new map<Id, PurchaseOrder__c>(POMap);
        system.debug('## POToUpdate ' + POToUpdate);

        //this map is used for classic order lines creation when WS ol generation failed
        map <id,list <PurchaseOrder__c>> mapAssessmentPurchaseOrders = new map <id,list <PurchaseOrder__c>>();

        //this set is used for classic order lines creation when WS ol generation failed
        set <id> distributorIdSet = new set <id>();

        //this set is used to update po for successfull corresponding ol creation
        set <id> setPOId = new set <id>();

        //build mapInsertedPOReworked
        if(insertedPOMap.size() > 0){
            for(PurchaseOrder__c po : insertedPOMap.values()){
                mapInsertedPOReworked.put(po.Id,po); 
            }
        }//end if insertedPOMap.size() > 0

        //ASE: 16/10/17: delete all bundle items 
        //note: is populated only when updatePO is called
        system.debug('## oriOLToDelSet:'+oriOLToDelSet);
        if(oriOLToDelSet != null && !oriOLToDelSet.isEmpty()){
            map<Id, OrderLine__c> childOLToDelMap = new map<Id, OrderLine__c> ([Select id from OrderLine__c where OriginalItem__c in :oriOLToDelSet or OriginalItem__r.OriginalItem__c in :oriOLToDelSet ]);
            system.debug('## childOLToDelMap :'+childOLToDelMap); 
            if(childOLToDelMap != null && !childOLToDelMap.isEmpty()){
                delete childOLToDelMap.values();
            }
        }


        //upsert original
        system.debug('## originalOLMap ' + originalOLMap); 
        if(!originalOLMap.isEmpty()){
            Map<Id, Offer__c> mapOffersToUpdate = new map<Id, Offer__c>();
            list<OrderLine__c> originalList = new list<OrderLine__c>();
            for(string originalKey: originalOLMap.keyset()){
                originalList.addAll(originalOLMap.get(originalKey));
                //mapPartListOrderline.put()
            }
            system.debug('## originalList:'+originalList);

            List<Database.upsertResult> uResults = Database.upsert(originalList, OLExtId, false);
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(!uResults[idx].isSuccess()) {               
                    // do not insert alternatives/bundle items related to assessment
                    if(!alternativeOLMap.isEmpty()){
                        alternativeOLMap.remove(originalList[idx].PurchaseOrder__c);
                    }
                    if(!bundleItemOLMap.isEmpty()){
                        bundleItemOLMap.remove(originalList[idx].PurchaseOrder__c);
                    }

                    //do not update PO
                    if(POToUpdate.containsKey(originalList[idx].PurchaseOrder__c)){
                        POToUpdate.remove(originalList[idx].PurchaseOrder__c);
                    }

                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('error OL:' +err.getMessage());
                        if(!errorMsgMap.containsKey(originalList[idx].PurchaseOrder__c)){
                            errorMsgMap.put(originalList[idx].PurchaseOrder__c, originalList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                        else{
                            String error = errorMsgMap.get(originalList[idx].PurchaseOrder__c);
                            errorMsgMap.put(originalList[idx].PurchaseOrder__c, error + ';' + originalList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                    }
                }else{
                    //build setPOId
                    setPOId.add(originalList[idx].PurchaseOrder__c);   
                }
            }
            if (fromUpdateStockInfo == 'fromUpdateStockInfo'){
                //RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO Start
                for(Offer__c offer: [select Id,Accepted__c,OrderLine__r.Suppliable__c,Suppliable__c                                         
                                    From Offer__c
                                    Where OrderLine__c IN :originalList ]){
                    if (offer.Accepted__c != offer.OrderLine__r.Suppliable__c
                        && String.isNotBlank(orRequest)
                        && orRequest == 'OrderPO' ){
                        offer.Accepted__c = offer.OrderLine__r.Suppliable__c;
                        offer.Suppliable__c = offer.OrderLine__r.Suppliable__c == 'YES' ? true : false;
                        mapOffersToUpdate.put(offer.Id,offer);
                    }
                }

                if(mapOffersToUpdate.size() > 0){
                    List<Database.SaveResult> uResultsSO = Database.update(mapOffersToUpdate.values(), false);

                }
                //RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO END

                //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
                if(updatedPartMap != null && updatedPartMap.size() > 0){
                    system.debug('## updating Partlist ' + updatedPartMap);

                    // List<Database.SaveResult> uResultsPart = Database.update(updatedPartMap.values(), false);
                    List<Database.UpsertResult> uResultsPart = Database.upsert(updatedPartMap.values(),PartList__c.Fields.TECH_OriginalPart__c, false);
                    

                    system.debug('## uResultsPart ' + uResultsPart);


                }
            }

            system.debug('## setPOId ' + setPOId);
            system.debug('## errorMsgMap ' + errorMsgMap);
        }

        //upsert alternatives
        system.debug('## alternativeOLMap ' + alternativeOLMap);
        if(!alternativeOLMap.isEmpty()){
            Map<Id, Offer__c> mapOffersToUpdate = new map<Id, Offer__c>();            
            list<OrderLine__c> alternativesList = new list<OrderLine__c>();
            for(string altKey: alternativeOLMap.keyset()){
                alternativesList.addAll(alternativeOLMap.get(altKey));
            }
            system.debug('## alternativesList:'+alternativesList);

            List<Database.upsertResult> uResults = Database.upsert(alternativesList, OrderLine__c.Fields.TechExternalId__c, false);
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(!uResults[idx].isSuccess()) {               
                    // do not insert bundle items related to assessment                    
                    if(!bundleItemOLMap.isEmpty()){
                        bundleItemOLMap.remove(alternativesList[idx].PurchaseOrder__c);
                    }

                    //do not update PO
                    if(POToUpdate.containsKey(alternativesList[idx].PurchaseOrder__c)){
                        POToUpdate.remove(alternativesList[idx].PurchaseOrder__c);
                    }


                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('error AL:' +err.getMessage());
                        if(!errorMsgMap.containsKey(alternativesList[idx].PurchaseOrder__c)){
                            errorMsgMap.put(alternativesList[idx].PurchaseOrder__c, alternativesList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                        else{
                            String error = errorMsgMap.get(alternativesList[idx].PurchaseOrder__c);
                            errorMsgMap.put(alternativesList[idx].PurchaseOrder__c, error + ';'+alternativesList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                    }  
                }else{
                    //build setPOId
                    setPOId.add(alternativesList[idx].PurchaseOrder__c);
                } 
            }

            if (fromUpdateStockInfo == 'fromUpdateStockInfo'){

                //RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO Start
                for(Offer__c offer: [select Id,Accepted__c,OrderLine__r.Suppliable__c,Suppliable__c                                         
                                    From Offer__c
                                    Where OrderLine__c IN :alternativesList ]){
                    if (offer.Accepted__c != offer.OrderLine__r.Suppliable__c){
                        offer.Accepted__c = offer.OrderLine__r.Suppliable__c;
                        offer.Suppliable__c = offer.OrderLine__r.Suppliable__c == 'YES' ? true : false;
                        mapOffersToUpdate.put(offer.Id,offer);
                    }
                }

                if(mapOffersToUpdate.size() > 0){
                    List<Database.SaveResult> uResultsSO = Database.update(mapOffersToUpdate.values(), false);

                }
                //RLA 14/01/2019 C-003008: Parts rejected in PO are not updated in SO END
            }
            system.debug('## setPOId ' + setPOId);
            system.debug('## errorMsgMap ' + errorMsgMap);
        }

        //upsert bundleItems
        system.debug('## bundleItemOLMap ' + bundleItemOLMap);
        if(!bundleItemOLMap.isEmpty()){
            list<OrderLine__c>bundleItemList = new list<OrderLine__c>();
            for(string bundleKey: bundleItemOLMap.keyset()){
                bundleItemList.addAll(bundleItemOLMap.get(bundleKey));
            }
            system.debug('## bundleItemList:'+bundleItemList);
            List<Database.upsertResult> uResults = Database.upsert(bundleItemList, OLExtId, false);  
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(!uResults[idx].isSuccess()) {
                    //do not update PO
                    if(POToUpdate.containsKey(bundleItemList[idx].PurchaseOrder__c)){
                        POToUpdate.remove(bundleItemList[idx].PurchaseOrder__c);
                    }

                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('error BUNDLEITEM:' +err.getMessage());
                        if(!errorMsgMap.containsKey(bundleItemList[idx].PurchaseOrder__c)){
                            errorMsgMap.put(bundleItemList[idx].PurchaseOrder__c, bundleItemList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                        else{
                            String error = errorMsgMap.get(bundleItemList[idx].PurchaseOrder__c);
                            errorMsgMap.put(bundleItemList[idx].PurchaseOrder__c,error +  ';'+bundleItemList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                    }  
                }else{
                    //build setPOId
                    setPOId.add(bundleItemList[idx].PurchaseOrder__c);
                } 
            }
            system.debug('## setPOId ' + setPOId);  
            system.debug('## errorMsgMap ' + errorMsgMap);      
        }

        //update OL when calling updateOrderWS
        //update original
        system.debug('## originalOLMapToUpd ' + originalOLMapToUpd);
        if(!originalOLMapToUpd.isEmpty()){
            list<OrderLine__c> originalList = new list<OrderLine__c>();
            for(string originalKey: originalOLMapToUpd.keyset()){
                originalList.addAll(originalOLMapToUpd.get(originalKey)); 
            }
            system.debug('## originalList:'+originalList);
          
            List<Database.SaveResult> uResults = Database.update(originalList, false);
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                system.debug('## uResults:'+uResults[idx]);
                if(!uResults[idx].isSuccess()) {        
                    

                    // do not insert alternatives/bundle items related to assessment
                    //if(!alternativeOLMapToUpd.isEmpty()){
                    //    alternativeOLMapToUpd.remove(originalList[idx].PurchaseOrder__c);
                    //}
                    //if(!bundleItemOLMapToUpd.isEmpty()){
                    //    bundleItemOLMapToUpd.remove(originalList[idx].PurchaseOrder__c);
                    //}

                    //do not update PO
                    if(POToUpdate.containsKey(originalList[idx].PurchaseOrder__c)){
                        POToUpdate.remove(originalList[idx].PurchaseOrder__c);
                    }

                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('error OL:' +err.getMessage());
                        if(!errorMsgMap.containsKey(originalList[idx].PurchaseOrder__c)){
                            errorMsgMap.put(originalList[idx].PurchaseOrder__c, originalList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                        else{
                            String error = errorMsgMap.get(originalList[idx].PurchaseOrder__c);
                            errorMsgMap.put(originalList[idx].PurchaseOrder__c,error +  ';' +originalList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                    }
                }else{
                    //build setPOId
                    setPOId.add(originalList[idx].PurchaseOrder__c);
                }
            }
            system.debug('## setPOId ' + setPOId);
            system.debug('## errorMsgMap ' + errorMsgMap);
        }

        /*//update alternatives
        system.debug('## alternativeOLMapToUpd ' + alternativeOLMap);
        if(!alternativeOLMapToUpd.isEmpty()){
            list<OrderLine__c> alternativesList = new list<OrderLine__c>();
            for(string altKey: alternativeOLMapToUpd.keyset()){
                alternativesList.addAll(alternativeOLMapToUpd.get(altKey));
            }
            system.debug('## alternativesList:'+alternativesList);

            List<Database.SaveResult> uResults = Database.update(alternativesList, false);
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(!uResults[idx].isSuccess()) {               
                    // do not insert bundle items related to assessment                    
                    //if(!bundleItemOLMapToUpd.isEmpty()){
                    //    bundleItemOLMapToUpd.remove(alternativesList[idx].PurchaseOrder__c);
                    //}

                    //do not update PO
                    if(POToUpdate.containsKey(alternativesList[idx].PurchaseOrder__c)){
                        POToUpdate.remove(alternativesList[idx].PurchaseOrder__c);
                    }

                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('error AL:' +err.getMessage());
                        if(!errorMsgMap.containsKey(alternativesList[idx].PurchaseOrder__c)){
                            errorMsgMap.put(alternativesList[idx].PurchaseOrder__c, alternativesList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                        else{
                            String error = errorMsgMap.get(alternativesList[idx].PurchaseOrder__c);
                            errorMsgMap.put(alternativesList[idx].PurchaseOrder__c,error +  ';' +alternativesList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                    }  
                }else{
                    //build setPOId
                    setPOId.add(alternativesList[idx].PurchaseOrder__c);
                } 
            }
            system.debug('## setPOId ' + setPOId);
            system.debug('## errorMsgMap ' + errorMsgMap);
        }*/

        /*//update bundleItems
        system.debug('## bundleItemOLMap ' + bundleItemOLMap);
        if(!bundleItemOLMapToUpd.isEmpty()){
            list<OrderLine__c>bundleItemList = new list<OrderLine__c>();
            for(string bundleKey: bundleItemOLMapToUpd.keyset()){
                bundleItemList.addAll(bundleItemOLMapToUpd.get(bundleKey));
            }
            system.debug('## bundleItemList:'+bundleItemList);
            List<Database.SaveResult> uResults = Database.update(bundleItemList, false);  
            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(!uResults[idx].isSuccess()) {
                    //do not update PO
                    if(POToUpdate.containsKey(bundleItemList[idx].PurchaseOrder__c)){
                        POToUpdate.remove(bundleItemList[idx].PurchaseOrder__c);
                    }

                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('error BUNDLEITEM:' +err.getMessage());
                        if(!errorMsgMap.containsKey(bundleItemList[idx].PurchaseOrder__c)){
                            errorMsgMap.put(bundleItemList[idx].PurchaseOrder__c, bundleItemList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                        else{
                            String error = errorMsgMap.get(bundleItemList[idx].PurchaseOrder__c);
                            errorMsgMap.put(bundleItemList[idx].PurchaseOrder__c,error +  ';' +bundleItemList[idx].PartNumber__c +' - ' + err.getMessage());
                        }
                    }  
                }else{
                    //build setPOId
                    setPOId.add(bundleItemList[idx].PurchaseOrder__c);
                } 
            }
            system.debug('## setPOId ' + setPOId);  
            system.debug('## errorMsgMap ' + errorMsgMap);      
        }*/

        //loop in error Map to update PO with error message
        //only one update on PO should be done
        if(!isUpdate){
            for(string errorKey : errorMsgMap.keySet()){
                if(POToUpdate.containsKey(errorKey)){
                    PurchaseOrder__c tempPO = new PurchaseOrder__c();
                    tempPO = POToUpdate.get(errorKey);
                    tempPO.wsDate__c = system.now();
                    tempPO.wsErrorMessage__c = errorMsgMap.get(errorKey);
                    POToUpdate.put(tempPO.id,tempPO);
                }else{
                    PurchaseOrder__c tempPO = new PurchaseOrder__c(Id = errorKey,
                                                                    wsDate__c = system.now(),
                                                                    wsErrorMessage__c = errorMsgMap.get(errorKey));  
                    
                    POToUpdate.put(errorKey,tempPO);
                }
            }
            system.debug('## POToUpdate ' + POToUpdate);

            //now loop in setPOId to clear wsError for sucessfull update
            system.debug('## setPOId ' + setPOId);
            if(setPOId.size() > 0){
                for(Id POId : setPOId){
                    if(POToUpdate.containsKey(POId)){
                        if(POMap.containsKey(POId) && !errorMsgMap.containsKey(POId)){
                            PurchaseOrder__c tempPO = POToUpdate.get(POId);
                            tempPO.wsDate__c = system.now();
                            tempPO.wsErrorMessage__c = '';
                            POToUpdate.put(POId,tempPO);
                        }
                    }else{
                        POToUpdate.put(POId,new PurchaseOrder__c(id = POId,
                                                                    wsDate__c = system.now(),
                                                                    wsErrorMessage__c = ''));
                    }
                }//end looping in set PO
            }//end if setPOId.size() > 0
        }
        
        //update PO and build state
        if(!POToUpdate.isEmpty()){
            list<PurchaseOrder__c> POList = new list<PurchaseOrder__c>(POToUpdate.values());
            
            List<Database.SaveResult> uResults = Database.update(POList, false);  

            for(Integer idx = 0; idx < uResults.size(); idx++) {
                if(!uResults[idx].isSuccess()) {  
                    for(Database.Error err : uResults[idx].getErrors()){
                        system.debug('error PO:' +err.getMessage());

                        sasResList.add(new responseToGenerate('Update', 
                                                                POList[idx].Tech_ExternalId__c != null ? POList[idx].Tech_ExternalId__c : mapInsertedPOReworked.get(POList[idx].Id).Tech_ExternalId__c, 
                                                                POList[idx].Id, 
                                                                false, 
                                                                null, 
                                                                err.getMessage())); 
                    }  
                } 
                else{
                    sasResList.add(new responseToGenerate('Update', 
                                                            POList[idx].Tech_ExternalId__c != null ? POList[idx].Tech_ExternalId__c : mapInsertedPOReworked.get(POList[idx].Id).Tech_ExternalId__c, 
                                                            POList[idx].Id,
                                                            true, 
                                                            null, 
                                                            null));
                }
            }
        }

        system.debug('## sasResList before removal ' + sasResList);
        //remove response PO for which there is an error in its corresponding child
        for(integer i=0;i<sasResList.size();i++){
            if(errorMsgMap.containsKey(sasResList.get(i).FunctionalId)){
                sasResList.remove(i);
            }
        }
        system.debug('## sasResList after removal ' + sasResList);

        //loop in error reported and for those records, create OL
        system.debug('## errorMsgMap ' + errorMsgMap);
        if(!errorMsgMap.isEmpty()){
            for(string POId : errorMsgMap.keySet()){
                if(mapAssessmentPurchaseOrders.containsKey(mapInsertedPOReworked.get(POId).Assessment__c)){
                    mapAssessmentPurchaseOrders.get(mapInsertedPOReworked.get(POId).Assessment__c).add(mapInsertedPOReworked.get(POId));
                }else{
                    mapAssessmentPurchaseOrders.put(mapInsertedPOReworked.get(POId).Assessment__c, new list <PurchaseOrder__c>{mapInsertedPOReworked.get(POId)});
                }

                distributorIdSet.add(mapInsertedPOReworked.get(POId).Distributor__c);
            }
        }//end if !errorMsgMap.isEmpty()
        system.debug('## mapAssessmentPurchaseOrders ' + mapAssessmentPurchaseOrders);
        system.debug('## distributorIdSet ' + distributorIdSet);

        if(mapAssessmentPurchaseOrders.size() > 0 && distributorIdSet.size() > 0 && !doNotCreateClassicOL){
            //execute ol creation
            PurchaseOrderTriggerHandler poHandler                = new PurchaseOrderTriggerHandler();
            poHandler.createOrderLines(mapAssessmentPurchaseOrders,distributorIdSet);
        }//end if mapAssessmentPurchaseOrders.size() > 0 && distributorIdSet.size() > 0

        //build error state
        if(!errorMsgMap.isEmpty()){
            for(String POKey : errorMsgMap.keyset()){
                if(mapInsertedPOReworked.containsKey(POKey)){  
                    sasResList.add(new responseToGenerate('Update', 
                                                            mapInsertedPOReworked.get(POKey).Name, 
                                                            mapInsertedPOReworked.get(POKey).Id, 
                                                            false, 
                                                            null, 
                                                            errorMsgMap.get(POKey)));  
                }
            }
        }

        system.debug('## sasResList '+ sasResList);

        //return results;
        system.debug('## end sasResList');      
    }

    public static void processPOOL(list<RestDistributorUtility.lines> lines
                                    ,PurchaseOrder__c PO
                                    ,Account distAcc
                                    ,Map<Id, PartList__c> partMap
                                    ,String POStatus
                                    ,list<responseToGenerate> sasResList
                                    ,map<Id, list<OrderLine__c>> originalOLMap
                                    ,map<Id, list<OrderLine__c>> alternativeOLMap
                                    ,map<Id, list<OrderLine__c>> bundleItemOLMap
                                    ,map<Id, list<OrderLine__c>> originalOLMapToUpd
                                    ,map<Id, list<OrderLine__c>> alternativeOLMapToUpd
                                    ,map<Id, list<OrderLine__c>> bundleItemOLMapToUpd
                                    ,map<Id, PurchaseOrder__c> updatedPOMap
                                    ,Boolean isUpdate
                                    ,map <ID, OrderLine__c> originalIdTechIdMap
                                    ,String DistributorOrderReference
                                    ,set<Id> oriOLToDelSet
                                    ,map <ID, OrderLine__c> allIdTechIdMap) {
        system.debug('## start processPOOL');

        system.debug('## originalOLMapToUpd ' + originalOLMapToUpd);
        system.debug('## alternativeOLMapToUpd ' + alternativeOLMapToUpd);
        system.debug('## bundleItemOLMapToUpd ' + bundleItemOLMapToUpd);

        //AMI 15/02/18 - C-002041 - Distributor V2 - Recalculate AS Bodyshop Net Price and AS Bodyshop Price for asp parts only 
        //                                         - Get Distributor Rebate
        Rebate = distAcc.Rebate__C != null ? (distAcc.Rebate__C / 100) : 0.0;
        //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
        Set<String> setAllowedSubstitutes = new Set<String>();
        if (String.isnotBlank(distAcc.Type_of_Substitutes__c)){
            setAllowedSubstitutes = new Set<String>(distAcc.Type_of_Substitutes__c.split(';')) ;
        }
        Boolean isConversionAllowed = setAllowedSubstitutes.size() > 0 ? true : false;
        // Boolean isConversionAllowed = setAllowedSubstitutes.size() > 0 && setAllowedSubstitutes.contains('Connected Substitute') ? true : false;
        // Boolean isConversionToIGOallowed = setAllowedSubstitutes.size() > 0 && setAllowedSubstitutes.contains('Connected OEM') ? true : false;
        // system.debug('## isConversionToASPallowed ' + isConversionToASPallowed);
        // system.debug('## isConversionToIGOallowed ' + isConversionToIGOallowed);



        String OrderRequest = distAcc.OrderRequest__c;
        orRequest = OrderRequest;
        // ASE : 08/11/2017   C-002072 
        map<String, list<String>> duplicateBundleMap = new map<String, list<String>>();

        //AMI 14/12/17 : SAS: Remplacement de pièce --> Distributor Price Number should be taken into account instead of IAMPartNumber on Cross Ref
        //             : build a map of cross ref id with associated part id
        //             : this will be used to query active dist price and also to relate part with corresponding dist price
        map <string,string> mapCrossRefIdPartId = new map <string,string>();
        map <string, set<string>> mapCrossRefIdPartIdSet = new map <string, set<string>>();

        //AMI 14/12/17 : SAS: Remplacement de pièce --> Distributor Price Number should be taken into account instead of IAMPartNumber on Cross Ref
        //             : Get DistributorPartNumber__c from distributor price for ascr only
        map <string,string> mapCombiDistIdPartIdAndDistPNumber = new map <string,string>();

        //RLA 30/08/2018   C-002742 : Update PO - alternative part REFUSED – In progress 
        map<Id, OrderLine__c> mapChildParentOrderLine = new map <Id, OrderLine__c>();
        

        //WCH 25/03/2019 C-003144 - OL ASCR Finale sur OL ASCR Originale
        map<String, Id> TechnicalIdMapOLId = new map <String, Id>();

        String prefixPartNumberIGO = RestDistributorUtility.getConnectedSubPrefix (PO.Assessment__r.InsuranceBroker__c);

        
        //AMI 14/12/17 : SAS: Remplacement de pièce --> Distributor Price Number should be taken into account instead of IAMPartNumber on Cross Ref
        //             : build mapCrossRefIdPartId
        for(PartList__c pt : partMap.values()){
            if(pt.CrossReferenceId__c != null){
                //ASE: 26/01/2018: C-002210
                //mapCrossRefIdPartId.put(pt.CrossReferenceId__c,pt.Id);

                if(!mapCrossRefIdPartIdSet.containsKey(pt.CrossReferenceId__c)){
                    mapCrossRefIdPartIdSet.put(pt.CrossReferenceId__c,new set<string>{pt.Id});
                }
                else{
                    mapCrossRefIdPartIdSet.get(pt.CrossReferenceId__c).add(pt.Id);
                }
            }
        }
        system.debug('## mapCrossRefIdPartId ' + mapCrossRefIdPartId);
        system.debug('## mapCrossRefIdPartIdSet ' + mapCrossRefIdPartIdSet);

        //ASE 06/06/18: set Not acceptedbyBS ol to NO
        map<Id, set<id>> partOLMap = new  map<Id, set<Id>>();

        //RLA 07/07/2020 C-003770: IG - Send Final part to ERP when there is a replacement
        map<Id,OrderLine__c> mapPartlistOL = new map<Id, OrderLine__c>();
        map<Id,OrderLine__c> mapPartlistOriginalOL = new map<Id, OrderLine__c>();

        System.debug('### partMap ### '+ partMap); 
       
        //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
        Decimal keepAXA = 0;
        Decimal keepNonAXA = 0;
        Boolean hasAlreadyRun = false;
        // Boolean isNonAxa = false;
       
        //RLA modified query
        //30/08/2018   C-002742 : Update PO - alternative part REFUSED – In progress 
        for(OrderLine__c ol: [select PartList__c, Id, OriginalItem__c, OrderType__c,TechOLType__c,PartNumber__c,
                                ExpectedDeliveryDuration__c, PurchaseOrder__c, SASStatus__c, CataloguePrice__c, Rebate__c, BodyShopDiscount__c, AXADiscount__c, TechExternalId__c,
                                Suppliable__c, AcceptedCheck__c, AlphaScaleMRID__c, AssessmentPrice__c, Type__c, Description__c, Manufacturer__c, Quantity__c, VAT__c,UpdateOLinfo__c,PurchaseOrder__r.Name,
                                ASBodyshopNetPrice__c, ASBodyshopPrice__c
                                , PurchaseOrder__r.Assessment__r.Bodyshop__r.keepAXA__c, PurchaseOrder__r.Assessment__r.Bodyshop__r.KeepNonAXA__c,
                                PurchaseOrder__r.TECH_AssessmentCountryCode__c, PurchaseOrder__r.TECH_AssessmentEntityRules__c 
                                  from OrderLine__c where PartList__c in: partMap.keyset() and PurchaseOrder__c =: PO.Id]){
            //notAcceptedOLSet.add(ol.TechExternalId__c);
            //system.debug('@@@ ol suppliable__c: '+ol.suppliable__c);
            
            if (ol.suppliable__c == 'NO' || (ol.Suppliable__c == 'YES' && ol.AcceptedCheck__c == false)){
                notAcceptedOLMap.put(ol.TechExternalId__c, ol);
            }

            if (String.isNotBlank(ol.OriginalItem__c) && isUpdate){
                mapChildParentOrderLine.put((String.valueOf((ol.Id))).left(15), new OrderLine__c(id = ol.OriginalItem__c));
            }

            //WCH 25/03/2019 C-003144 - OL ASCR Finale sur OL ASCR Originale
            if(!String.isBlank(ol.TechExternalId__c)){
                TechnicalIdMapOLId.put(ol.TechExternalId__c,ol.Id);
            }

            // system.debug('@@ OL: '+ OL.Description__c + Ol.OrderType__c + OL.TechOLType__c);
            //RLA 07/07/2020 C-003770: IG - Send Final part to ERP when there is a replacement
            if (Ol.OrderType__c == 'Final' && OL.TechOLType__c == 'replacement'){
                mapPartlistOL.put(OL.PartList__c,OL );

            }

            if (Ol.OrderType__c == 'Original' && (String.isBlank(ol.OriginalItem__c))){
                mapPartlistOriginalOL.put(OL.PartList__c,OL );

            }
            //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
            if (!hasAlreadyRun){
                keepAXA = (Ol.PurchaseOrder__r.Assessment__r.Bodyshop__r.keepAXA__c != null && Ol.PurchaseOrder__r.Assessment__r.Bodyshop__r.keepAXA__c != 0 ? (Ol.PurchaseOrder__r.Assessment__r.Bodyshop__r.keepAXA__c) / 100 : 0);

                keepNonAXA = (Ol.PurchaseOrder__r.Assessment__r.Bodyshop__r.KeepNonAXA__c != null && Ol.PurchaseOrder__r.Assessment__r.Bodyshop__r.KeepNonAXA__c != 0 ? (Ol.PurchaseOrder__r.Assessment__r.Bodyshop__r.KeepNonAXA__c) / 100 : 0);

                isNonAxa = NonAxaOrdering.isNonAxaAllowed(new map<String, object>{'country' => Ol.PurchaseOrder__r.TECH_AssessmentCountryCode__c, 'entity' => Ol.PurchaseOrder__r.TECH_AssessmentEntityRules__c, 'fromProcess' => 'Order'});

                hasAlreadyRun = true;
            }

        }

        //RLA 19/05/2021 C-004337: FR - Keep NONAXA/Keep AXA sur des chiffrages
        if (isNonAxa){
            keepToUse = keepNonAXA;
        }
        else {
            keepToUse = keepAXA;
        }
       

        //AMI 14/12/17 : SAS: Remplacement de pièce --> Distributor Price Number should be taken into account instead of IAMPartNumber on Cross Ref
        //             : query distributor price
        for(DistributorPrice__c dp : [Select CrossReference__c, DistributorID__c,DistributorPartNumber__c 
                                        from DistributorPrice__c 
                                        where Active__c = true 
                                        AND isDeleted__c = false 
                                        //AND CrossReference__c in: mapCrossRefIdPartId.keyset()]){
                                        AND CrossReference__c in: mapCrossRefIdPartIdSet.keyset()]){
            //ASE: 26/01/2018: C-002210
            //string key = dp.DistributorID__c + '-' + mapCrossRefIdPartId.get(dp.CrossReference__c);            
            //mapCombiDistIdPartIdAndDistPNumber.put(key,dp.DistributorPartNumber__c);
            if(mapCrossRefIdPartIdSet.get(dp.CrossReference__c).size() > 0){
                for(String partId : mapCrossRefIdPartIdSet.get(dp.CrossReference__c)){
                    mapCombiDistIdPartIdAndDistPNumber.put( dp.DistributorID__c + '-' + partId, dp.DistributorPartNumber__c);
                }
            }
            
        }
        system.debug('## mapCombiDistIdPartIdAndDistPNumber ' + mapCombiDistIdPartIdAndDistPNumber);

        if(PO.Status__c == 'DRAFTQUOTE' || PO.Status__c == 'PREDRAFTQUOTE'){
                            
            Map<String,String> mapTypeDelay = getTypeDelayMap(distAcc.PartTypeRegionDelayMatrix__c);                        
            
            system.debug('## lines ' + lines);

            Integer allPartExceptAddPartSize = 0;
            system.debug('## allPartExceptAddPartSize:'+allPartExceptAddPartSize);
            Integer notSuppliablePartSize = 0;
            Boolean containAddPart = false;
            Boolean setAddPartToNotSuppliable = false; 

            for(RestDistributorUtility.Lines line :lines){
                if(line.PartNumber != system.label.AdditionalPartNumber){
                    allPartExceptAddPartSize ++;
                    if(line.Status != 'CONFIRMED' && line.Status != 'CONFIRMEDWITHDELAY' ){
                        notSuppliablePartSize++;
                    }
                }  
                else{
                    if(OrderRequest != 'OrderPO'){
                        containAddPart = true;
                    }
                } 
            }

            if(containAddPart && allPartExceptAddPartSize == notSuppliablePartSize){
                setAddPartToNotSuppliable = true;
            }
            system.debug('## mapChildParentOrderLine:'+mapChildParentOrderLine);

            for(RestDistributorUtility.Lines line :lines){  
                system.debug('## line.StatusMessage:'+line.StatusMessage);
                if((line.StatusMessage == null || string.isBlank(line.StatusMessage)) && string.isNotBlank(line.PartNumber)){
                    system.debug('## line.PartNumber:'+line.PartNumber);

                    //WCH 25/03/2019 : C-003144 - OL ASCR Finale sur OL ASCR Originale, Uncommented code
                    //Commented by RLA Case 2778 : Call Distributor Stock does not update Status 13/09/2018
                    if(!(line.PartNumber.toUpperCase()).startsWith('ASCR-')){

                        //RLA 07/07/2020 C-003770: IG - Send Final part to ERP when there is a replacement
                        Boolean isIG = false;                        
                        //AMI 18/10/17 : SAS: Remplacement de pièce
                        Boolean isReplacament = false;
                        String originalPN = '';
                        String fluxPN = RESTUpsertAssessmentV2.cleanseReference(line.PartNumber);//RLA 15/06/2020 C-003745:IG - Remove 'false' replacements when calling Stock for German Distributors
                        string OLStatus = string.isNotBlank(line.Status) ? line.Status.toUpperCase() : '';
                        String olCanSupply = (OLStatus == 'CONFIRMED' || OLStatus == 'CONFIRMEDWITHDELAY') ? 'YES' : 'NO';
                        //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
                        String updatedAlphaScaleMRID = null;

                        //build originalPN
                        if(partMap.containsKey(line.ID)){ 
                            PartList__c tempPart = partMap.get(line.ID);
                            updateOLRebate  = false;
                            //system.debug('## line: '+line.ID);
                            //system.debug('## tempPart : '+tempPart.TechCheckForSubstitute__c );
                            insuranceBroker = PO.Assessment__r.InsuranceBroker__c;

                             //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
                            if (String.isnotBlank(PO.Assessment__r.InsuranceBroker__c) && system.label.InsBrokerName.contains(PO.Assessment__r.InsuranceBroker__c) ){
                                isIG = true;

                                if (tempPart.TechCheckForSubstitute__c && isConversionAllowed){
                                    CustomerInformationsMapping__mdt customerInfo = RestDistributorUtility.getcustomerMapping(PO.Assessment__r.InsuranceBroker__c);
                                    if (customerInfo != null
                                        && customerInfo.Optimize_DQC__c
                                        && ((String.isNotBlank(PO.Assessment__r.substitutiontype__c)
                                        && (PO.Assessment__r.substitutiontype__c).contains('A'))
                                            || String.isBlank(PO.Assessment__r.substitutiontype__c))
                                        ){
                                            
                                            RESTSearchAssessment.isFromSearchAssessment = true;

                                            if (setAllowedSubstitutes.contains('Connected Substitute')){
                                                tempPart = createSubstitute(tempPart, line, distAcc, PO.Brand__c);
                                            }
                                            else if (setAllowedSubstitutes.contains('Connected OEM')){
                                                map <string,object> inputParamForIGO = new map <string,object>();
                                                map <string,object> getIGO = new map <string,object>();
                                                map <string, PartList__c> mapTechOriginalPartKeyCorrespondingPart = new map<String, PartList__c> {line.Id => tempPart  };
                                                map <string,Account> mapEligiblePONameELigiblePO = new map <string,Account>();
                                                mapEligiblePONameELigiblePO.put(distAcc.Tech_Distributor__c,distAcc);


                                                inputParamForIGO.put('lineStr',line);
                                                inputParamForIGO.put('mapTechOriginalPartKeyCorrespondingPart',mapTechOriginalPartKeyCorrespondingPart);
                                                inputParamForIGO.put('mapEligiblePONameELigiblePO',mapEligiblePONameELigiblePO);
                                                inputParamForIGO.put('isIG',isIG);
                                                inputParamForIGO.put('notFromRestUpsert',true); 
                                                inputParamForIGO.put('receivedStatus',line.Status);
                                                inputParamForIGO.put('distName',distAcc.Tech_Distributor__c);
                                                inputParamForIGO.put('assessId',PO.Assessment__c);
                                                inputParamForIGO.put('insuranceBroker',PO.Assessment__r.InsuranceBroker__c);
                                                inputParamForIGO.put('brand',PO.Brand__c);

                                                getIGO = RestDistributorUtility.createIGO(inputParamForIGO);
                                                System.debug('@@@ getIGO:'+getIGO);
                                                tempPart = getIGO.containskey('partlist') ? (PartList__c) getIGO.get('partlist') : null;

                                            }
                                            
                                            RESTSearchAssessment.isFromSearchAssessment = false;

                                            partMap.put(line.ID,tempPart );
                                            updatedAlphaScaleMRID = tempPart.Alpha_Scale_MRID__c;

                                    }
                                }
                                
                            }
                            
                            //check if part is ascr
                            if(tempPart.CrossReferenceId__c != null){
                                //AMI 14/12/17 : SAS: Remplacement de pièce --> Distributor Price Number should be taken into account instead of IAMPartNumber on Cross Ref
                                //             : fetch Distributor Price Part Number from Dist Price instead from ASCR
                                string combiKey = distAcc.Id + '-' + tempPart.Id;

                                if(mapCombiDistIdPartIdAndDistPNumber.containsKey(combiKey) && mapCombiDistIdPartIdAndDistPNumber.get(combiKey) != null){
                                    originalPN = mapCombiDistIdPartIdAndDistPNumber.get(combiKey);
                                    /*Ashwina S    18/04/2018  C-002477: ASP- Prefix*/
                                    originalPN = (originalPN.startsWith('ASP-')) ? originalPN.split('ASP-')[1]: originalPN;
                                }else{
                                    originalPN = '';
                                }
                            }else{                               
                                //part is original
                                //RLA 17/06/2020 IG
                                originalPN = tempPart.ForTechSubsNumber__c;
                                /*Ashwina S    18/04/2018  C-002477: ASP- Prefix*/
                                originalPN = (originalPN.startsWith('ASP-')) ? originalPN.split('ASP-')[1]: originalPN;
                            }
                            originalPN =  RESTUpsertAssessmentV2.cleanseReference(originalPN);//RLA 15/06/2020 C-003745:IG - Remove 'false' replacements when calling Stock for German Distributors

                            // tempPart = createSubstitute(tempPart, line, distAcc, PO.Brand__c);
                             if (isIG && mapPartlistOL.containsKey(tempPart.Id)){
                                system.debug('@@ compare with OL instead of Partlist');
                                originalPN = mapPartlistOL.get(tempPart.Id).PartNumber__c;
                                /*Ashwina S    18/04/2018  C-002477: ASP- Prefix*/
                                originalPN = (originalPN.startsWith('ASP-')) ? originalPN.split('ASP-')[1]: originalPN;
                                originalPN = RESTUpsertAssessmentV2.cleanseReference(originalPN);//RLA 15/06/2020 C-003745:IG - Remove 'false' replacements when calling Stock for German Distributors
                                // if(originalPN == fluxPN && mapPartlistOL.get(tempPart.Id).TechOLType__c == 'replacement'){
                                if( mapPartlistOL.get(tempPart.Id).TechOLType__c == 'replacement'){
                                    isRepManual = true;
                                }
                                
                            }
                        
                        }//end if partMap.containsKey(line.ID)
                        system.debug('isReplacament:' +originalPN +' : '+fluxPN );                    
                        system.debug('isUpdate:' + isUpdate );                    
                        if(!isUpdate){ 
                            if(originalPN != fluxPN){
                                isReplacament = true;
                                //when we do searchAssessment and there is a replacement for IG we must not update the original
                                //RLA 10/09/2020 automatic replacements
                                if (isIG){
                                    isRepManual = true;

                                }
                            }
                        }
                        system.debug('## isReplacament ' + isReplacament);

                        OrderLine__c originalOL;
                        OrderLine__c parentOl;
                        if (String.isnotBlank(PO.Assessment__r.InsuranceBroker__c) && system.label.InsBrokerName.contains(PO.Assessment__r.InsuranceBroker__c)){
                            RESTSearchAssessment.isFromSearchAssessment = true;

                        }
                        if (isRepManual &&  mapPartlistOriginalOL.containsKey(line.ID)){
                            originalOL = mapPartlistOriginalOL.get(line.ID);
                            originalOL.OrderType__c = 'ORIGINAL';
                            system.debug('## originalOL ' + originalOL);
                            map<String, Object> mapInputParams = new map <String,Object> ();
                            mapInputParams.put('OL',line);
                            mapInputParams.put('POId',PO.Id);
                            mapInputParams.put('POKey',PO.Name);
                            mapInputParams.put('mapTypeDelay',mapTypeDelay);
                            mapInputParams.put('partMap',partMap);
                            mapInputParams.put('isUpdate',isUpdate);
                            mapInputParams.put('POStatus',POStatus);
                            mapInputParams.put('originalIdTechIdMap',originalIdTechIdMap);
                            mapInputParams.put('mapPartlistOL',mapPartlistOL);
                            mapInputParams.put('isReplacament',true);
                            mapInputParams.put('originalTechExtId',(PO.Name + '-' + line.ID));
                            mapInputParams.put('alternativeExtId',(PO.Name + '-' + line.ID));
                            mapInputParams.put('setAddPartToNotSuppliable',setAddPartToNotSuppliable);
                            mapInputParams.put('allIdTechIdMap',allIdTechIdMap);
                            mapInputParams.put('OrderRequest',OrderRequest);                             
                            mapInputParams.put('isRepManual',isRepManual);                             
                            mapInputParams.put('RebateReceived',rebate);                             
                            mapInputParams.put('SubstitutesTypes',setAllowedSubstitutes);                             
                            mapInputParams.put('isIG',isIG);                             


                            OrderLine__c alterna = createOrderlineGeneric(mapInputParams);                                
                            //RLA 18/06/2020 C-003700: IG - orderConfirmation
                            alterna.TechOLType__c = 'replacement';
                            system.debug('## alterna ' + alterna);

                            //add to upsert map
                            if(alternativeOLMap.containsKey(PO.Id)){
                                alternativeOLMap.get(PO.Id).add(alterna);
                            }else{
                                alternativeOLMap.put(PO.Id,new list <OrderLine__c>{alterna});
                            }  



                        }
                        //create original ol 
                        else if(!isReplacament){
                            originalOL = createOrderline(line, PO.Name, PO.Id, mapTypeDelay, partMap, isUpdate, POStatus, originalIdTechIdMap,false,'', setAddPartToNotSuppliable, allIdTechIdMap, OrderRequest);
                            //system.debug('@@ originalOL: '+originalOL);
                            //RLA 30/08/2018   C-002742 : Update PO - alternative part REFUSED – In progress 
                            if (isUpdate && originalOL.OrderType__c == 'FINAL'
                                && mapChildParentOrderLine != null && mapChildParentOrderLine.containsKey((String.valueOf((originalOL.Id))).left(15))){
                                parentOl = mapChildParentOrderLine.get((String.valueOf((originalOL.Id))).left(15));
                                parentOl.Suppliable__c = originalOL.Suppliable__c;
                            }
                            //system.debug('@@ parentOl: '+parentOl);

                        }else{
                            if(line.Bundle == false && ((line.Parts != null && line.Parts.size() == 0) || line.Parts == null)){
                                //RLA 07/07/2020 C-003770: IG - Send Final part to ERP when there is a replacement           
                                
                                // PartList__c tempPart = partMap.get(line.ID);                    
                            
                                //initialise original in order to update ordertype
                                originalOL = createOrderline(line, PO.Name, PO.Id, mapTypeDelay, partMap, isUpdate, POStatus, originalIdTechIdMap,false,'', setAddPartToNotSuppliable, allIdTechIdMap, OrderRequest);
                                originalOL.OrderType__c = 'ORIGINAL';
                                system.debug('## originalOL ' + originalOL);

                                //create alternaltive
                                OrderLine__c alterna = createOrderline(line, PO.Name, PO.Id, mapTypeDelay, partMap, isUpdate, POStatus, originalIdTechIdMap,true,(PO.Name + '-' + line.ID), setAddPartToNotSuppliable, allIdTechIdMap, OrderRequest);                                
                                //RLA 18/06/2020 C-003700: IG - orderConfirmation
                                alterna.TechOLType__c = 'replacement';
                                system.debug('## alterna ' + alterna);

                                //add to upsert map
                                if(alternativeOLMap.containsKey(PO.Id)){
                                    alternativeOLMap.get(PO.Id).add(alterna);
                                }else{
                                    alternativeOLMap.put(PO.Id,new list <OrderLine__c>{alterna});
                                }  

                            // }


                               
                            }
                        }

                        if (String.isnotBlank(updatedAlphaScaleMRID)){
                            originalOL.AlphaScaleMRID__c = updatedAlphaScaleMRID;
                            originalOL.TechSubstituteType__c = RestDistributorUtility.typeOfSubstitute(updatedAlphaScaleMRID,prefixPartNumberIGO );
                        }
                        system.debug('## originalOL ' + originalOL);
                        RESTSearchAssessment.isFromSearchAssessment = false;

                        
                        // create Original OrderLines           
                        //OrderLine__c originalOL = createOrderline(line, PO.Name, PO.Id, mapTypeDelay, partMap, isUpdate, POStatus, originalIdTechIdMap);
                       
                        if(!isUpdate){
                            if(!originalOLMap.containsKey(PO.Id)){
                                list<OrderLine__c> OLList = new list<OrderLine__c>{originalOL};
                                originalOLMap.put(PO.Id, OLList);
                            }
                            else{
                                originalOLMap.get(PO.Id).add(originalOL);
                            }  
                        }
                        else{
                            if(!originalOLMapToUpd.containsKey(PO.Id)){
                                list<OrderLine__c> OLList = new list<OrderLine__c>{originalOL};
                                originalOLMapToUpd.put(PO.Id, OLList);
                            }
                            else{
                                originalOLMapToUpd.get(PO.Id).add(originalOL);
                            }  
                            //RLA  30/08/2018   C-002742 : Update PO - alternative part REFUSED – In progress 
                            if (originalOLMapToUpd.size() > 0 && parentOl != null){
                                 originalOLMapToUpd.get(PO.Id).add(parentOl);
                            }
                        } 
                        
                        /*//AMI 18/10/17 : SAS: Remplacement de pièce
                        if(line.Bundle == false && ((line.Parts != null && line.Parts.size() == 0) || line.Parts == null)){
                            if(isReplacament){
                                //update original status
                                originalOL.OrderType__c = 'ORIGINAL';

                                //create alternaltive
                                OrderLine__c alterna = originalOL.clone(false, true);
                                system.debug('## originalOL ' + originalOL);
                                system.debug('## alterna ' + alterna);
                                
                                //set partnumber
                                alterna.PartNumber__c = fluxPN;
                                system.debug('## line.PartNumber ' + fluxPN);
                                system.debug('## alterna ' + alterna);
                                //set alternative order type
                                alterna.OrderType__c = 'FINAL';

                                //set alternative external key
                                alterna.TechExternalId__c = PO.Name + '-' + line.PartNumber + '-' + line.Description;

                                //add to upsert map
                                if(alternativeOLMap.containsKey(PO.Id)){
                                    alternativeOLMap.get(PO.Id).add(alterna);
                                }else{
                                    alternativeOLMap.put(PO.Id,new list <OrderLine__c>{alterna});
                                }  
                                system.debug('## alternativeOLMap ' + alternativeOLMap);
                                system.debug('## originalOLMap ' + originalOLMap);
                            }//end if isReplacament
                        }*/
                        //WCH 19/09/2019 C-003388 add check if when bundle=true, parts is not empty
                        if((line.Bundle == true && line.Parts != null) || (line.Bundle == false && line.Parts != null && line.Parts.size() == 1)){
                            String orderType;
                            String originalTechExtId;
                            if(!isUpdate){
                                originalTechExtId =  originalOL.TechExternalId__c;
                            }
                            else{
                                originalTechExtId =  originalIdTechIdMap.get(originalOL.ID).TechExternalId__c;
                                // delete all bundle items associated to original and create new again
                                oriOLToDelSet.add(originalOL.ID);
                            }
                            if(line.Bundle == true && line.Parts.size() > 1) {
                                orderType = 'FINAL';
                                //clone original with orderStatus set to final. TechGeneratedFinal__c = true
                                //assigning TechExternalId__c to be able to generate bundleItems
                                //adding final to TechExternalId__c to avoid duplicates with original
                                system.debug('## originalOL ' + originalOL);
                                OrderLine__c finalOL = originalOL.clone(false, true);
                                system.debug('## finalOL ' + finalOL);
                                if(!isUpdate){
                                    finalOL.TechExternalId__c =  finalOL.TechExternalId__c+ '-' + 'final';
                                }
                                else{
                                    finalOL.TechExternalId__c = originalIdTechIdMap.get(originalOL.ID).TechExternalId__c   + '-' + 'final'; 
                                    if(POStatus.toUpperCase() == 'DRAFT'){
                                        finalOL.PreselectedForOrder__c = (olCanSupply == 'YES') ? true : false;             
                                    }
                                    if(POStatus.toUpperCase() == 'INDELIVERY'){
                                        finalOL.AcceptedCheck__c = (olCanSupply == 'YES') ? true : false;
                                    }

                                    
                                }
                                system.debug('## finalOL :'+ finalOL );
                                system.debug('## finalOL.TechExternalId__c :'+finalOL.TechExternalId__c );
                                system.debug('## originalTechExtId :'+originalTechExtId);
                                finalOL.PurchaseOrder__c = PO.Id;           

                                // create final orderline and  attach bundle items orderline if more than 1 alternative needs to be attached to parent
                                // Variable that will store the bundle description (will be placed in the final order line)
                                String bundleDescription = '';
                                Double finalTotalPrice = 0;
                                Double finalAXATotalPrice = 0;
                                Double finalBodyShopTotalPrice = 0;
                                Double finalQuantity = 0;
                                String maximumDelivery = null;
                                orderType = 'BUNDLEITEM';                               
                                Integer count = 0;
                                for(RestDistributorUtility.Parts part : line.parts){  
                                    system.debug('## finalOL.TechExternalId__c:'+finalOL.TechExternalId__c); 
                                    count++;   
                                    //Case C-002955 : Draft calls to distributor : Duplicate external id specified
                                    //RLA 20/12/2018 send count as parameter which is equal to number of parts          
                                    OrderLine__c bundleItemOL = createAlternative(part, PO.Name, PO.Id, finalOL.TechExternalId__c, orderType, originalOL.PartList__c, mapTypeDelay, originalOL.SASStatus__c, partMap, isUpdate, POStatus, OrderRequest,count);
                                    
                                    // ASE : 08/11/2017   C-002072 
                                    string bundleKey = bundleItemOL.TechExternalId__c;
                                    system.debug('##duplicateBundleMap:'+duplicateBundleMap);
                                    if(!duplicateBundleMap.containsKey(bundleKey)){
                                        bundleItemOL.TechExternalId__c = bundleKey;
                                        duplicateBundleMap.put(bundleKey, new list<String>{bundleKey});
                                    }
                                    else{
                                        system.debug('## duplicateBundleMap.get(bundleKey).size()'+duplicateBundleMap.get(bundleKey));                                    
                                        system.debug('## duplicateBundleMap.get(bundleKey).size()'+duplicateBundleMap.get(bundleKey).size());
                                        bundleItemOL.TechExternalId__c = bundleKey + '_'+ String.ValueOf(duplicateBundleMap.get(bundleKey).size());
                                        duplicateBundleMap.get(bundleKey).add(bundleItemOL.TechExternalId__c);
                                    }
                                    if(!bundleItemOLMap.containsKey(PO.Id)){                                    
                                        List<OrderLine__c> bundleItemList= new List<OrderLine__c>{bundleItemOL};
                                        bundleItemOLMap.put(PO.Id, bundleItemList);
                                    }
                                    else{
                                        bundleItemOLMap.get(PO.Id).add(bundleItemOL);
                                    }                                

                                    // Gathering data of the bundle items
                                    bundleDescription += bundleItemOL.Type__c + ';' + bundleItemOL.PartNumber__c + ';' + bundleItemOL.Description__c + ';' + bundleItemOL.Manufacturer__c + ';' + bundleItemOL.CataloguePrice__c + '|';                                            
                                    
                                    // SUM(CataloguePrice__c * quantity) of all bundles
                                    finalTotalPrice += calculateTotalPrice(bundleItemOL);                                              
                                    
                                    // SUM(CataloguePrice__c * (1-(AXADiscount__c+TECH_ExtraAS__c)%) * (1- AdditionnalDiscount__c%) * Quantity__c)
                                    finalAXATotalPrice += calculateAXATotalPrice(bundleItemOL);                                                
                                    
                                    // SUM(CataloguePrice__c * (1-(BodyShopDiscount__c)%) * (1- AdditionnalDiscount__c%) * Quantity__c)
                                    finalBodyShopTotalPrice += calculateBodyShopTotalPrice(bundleItemOL);
                                    
                                    finalQuantity += (bundleItemOL.Quantity__c == null) ? 0 : bundleItemOL.Quantity__c;
                                    
                                    // MAX(ExpectedDeliveryDuration__c of all bundles)
                                    if(bundleItemOL.ExpectedDeliveryDuration__c != null &&  (maximumDelivery == null || (Integer.valueOf(bundleItemOL.ExpectedDeliveryDuration__c) > Integer.valueOf(maximumDelivery)))){
                                        //maximumDelivery = bundleItemOL.ExpectedDeliveryDuration__c;
                                    }   
                                }
                                //updating values in final generated
                                finalOL = updateFinalOL(originalTechExtId, finalOL, finalTotalPrice,  finalAXATotalPrice, finalBodyShopTotalPrice, finalQuantity, maximumDelivery, bundleDescription);
                                system.debug('## final for bundle:'+finalOL);
                                system.debug('## originalOLMapToUpd:'+originalOLMapToUpd);
                                if(!alternativeOLMap.containsKey(PO.Id)){
                                    List<OrderLine__c> finalOLList= new List<OrderLine__c>{finalOL};
                                    alternativeOLMap.put(PO.Id, finalOLList);
                                }
                                else{
                                    alternativeOLMap.get(PO.Id).add(finalOL);
                                }                            

                            }
                            else{                                
                                /*if(line.Bundle == true && line.Parts.size() <= 1){
                                    sasResList.add(new responseToGenerate('Update', PO.Id ,null, false, null, 'You require a minimum of two parts for bundle items.'));
                                }*/
                                system.debug('## line.Bundle:'+line.Bundle);
                                system.debug('## line.Parts):'+line.Parts);
                                system.debug('## line.Parts.size():'+line.Parts.size());
                                if(line.Bundle == false && line.Parts != null && line.Parts.size() == 1){
                                    //create alternative
                                    orderType = 'FINAL';
                                    RestDistributorUtility.Parts part = line.parts[0];  
                                    system.debug('## part:'+part);     
                                    //Case C-002955 : Draft calls to distributor : Duplicate external id specified
                                    //RLA 20/12/2018 send 1 as parameter because size is always 1                     
                                    OrderLine__c alternativeOL = createAlternative(part, PO.Name, PO.Id, originalTechExtId, orderType, originalOL.PartList__c, mapTypeDelay, originalOL.SASStatus__c, partMap, isUpdate, POStatus, OrderRequest,1);
                                    system.debug('## alternativeOL real alt:'+alternativeOL);
                                    if(!alternativeOLMap.containsKey(PO.Id)){
                                        list<OrderLine__c> AList = new list<OrderLine__c>{alternativeOL};
                                        alternativeOLMap.put(PO.Id, AList);
                                    }
                                    else{
                                        alternativeOLMap.get(PO.Id).add(alternativeOL);
                                    } 
                                }

                            }               
                        } 
                    //WCH 25/03/2019 : C-003144 - OL ASCR Finale sur OL ASCR Originale, Uncommented code
                    //Commented by RLA Case 2778 : Call Distributor Stock does not update Status 13/09/2018
                    //sasResList.add(new responseToGenerate('Update', PO.Id, null, false, null, 'Line not processed:' +line.PartNumber.toUpperCase()));                        
                    }
                    //WCH 25/03/2019 : C-003144 - OL ASCR Finale sur OL ASCR Originale
                    else if(TechnicalIdMapOLId.containskey(PO.Name+ '-' + line.Id)){
                        system.debug('OL ID >>'+TechnicalIdMapOLId.containskey(PO.Name+ '-' + line.Id));
                        OrderLine__c ascrOLToUpd = new OrderLine__c(Id=TechnicalIdMapOLId.get(PO.Name+ '-' + line.Id),TechExternalId__c=PO.Name+ '-' + line.Id,SASStatus__c='NOTFOUND',PurchaseOrder__c=PO.Id);
                        if(!originalOLMap.containsKey(PO.Id)){
                            originalOLMap.put(PO.Id, new list<OrderLine__c>{ascrOLToUpd});
                        }
                        else{
                            originalOLMap.get(PO.Id).add(ascrOLToUpd);
                        }  
                    }
                }//end string.isNotBlank(line.PartNumber)
                else{
                    //sasResList.add(new responseToGenerate('Update', PO.Id, null, false, null, 'PartNumber not found:' +line.Id));
                    OrderLine__c originalOL = processErrorPartOL(isUpdate, line, PO.Name, PO.Id, mapTypeDelay);
                    if(!isUpdate){
                        if(!originalOLMap.containsKey(PO.Id)){
                            list<OrderLine__c> OLList = new list<OrderLine__c>{originalOL};
                            originalOLMap.put(PO.Id, OLList);
                        }
                        else{
                            originalOLMap.get(PO.Id).add(originalOL);
                        }  

                    }
                    else{
                        if(!originalOLMapToUpd.containsKey(PO.Id)){
                            list<OrderLine__c> OLList = new list<OrderLine__c>{originalOL};
                            originalOLMapToUpd.put(PO.Id, OLList);
                        }
                        else{
                            originalOLMapToUpd.get(PO.Id).add(originalOL);
                        }  
                    } 
                }        

            }//end looping in lines

            //update PO if required
            system.debug('## POStatus ' + POStatus);
            if(string.isNotBlank(POStatus)){
                //AMI 22/01/18 : C-002202 - PO non commandés en drafquote    
                //             : removing update of status to draft quote since this should be done if and only if BS click on order
                if(POStatus.toUpperCase() == 'INDELIVERY'){
                    String POKey = String.valueOf(PO.Assessment__c)+ String.valueOf(distAcc.Id);
                    updatedPOMap.put(PO.Id, new PurchaseOrder__c(Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED, Id = PO.Id, Tech_ExternalId__c = POKey, DistributorPOReference__c = DistributorOrderReference));
                }   
            }
            system.debug('## updatedPOMap ' + updatedPOMap);                                        
        }
        else{
            sasResList.add(new responseToGenerate('Update', PO.Id ,null, false, null, 'Updates are only when the Purchase Order is in “DRAFTQUOTE” status'));
        }

        system.debug('## end originalOLMapToUpd ' + originalOLMapToUpd);
        system.debug('## end alternativeOLMapToUpd ' + alternativeOLMapToUpd);
        system.debug('## end bundleItemOLMapToUpd ' + bundleItemOLMapToUpd);
 
        system.debug('## end processPOOL'); 
    }

    //RLA 25/06/2020 C-003701 : IG - Distributor Data Quality Check
    public static PartList__c createSubstitute(PartList__c tempPart, RestDistributorUtility.Lines ln, Account distAcc, String brand){

        system.debug('## Start createSubstitute'); 


        system.debug('@@ line: '+ln);
        system.debug('@@ tempPart: '+tempPart);
        system.debug('@@ distAcc: '+distAcc);
        string receivedStatus = '';
        set<String> setDistName =  new Set<String>((system.label.DistributorsConnectedUseRebate).split(';'));
        set<String> setDistNameLineDiscount =  new Set<String>((system.label.AdditionalPartDistributor).split(';'));

        decimal discountToUse = (setDistNameLineDiscount.contains(distAcc.Tech_Distributor__c)) ? (ln.AlphaScaleDiscountAdditional/100)  : ((setDistName.contains(distAcc.Tech_Distributor__c))? rebate : 0.0); 
        system.debug('@@ discountToUse'+discountToUse);

        decimal rebate = distAcc.Rebate__c != null ? (distAcc.Rebate__c) /100 : 0.0;

        map<String,CountryCodeInformationsMapping__c> mapConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

        if ((ln.Status == 'CONFIRMED' || 
             ln.Status == 'CONFIRMEDWITHDELAY') 
             && (ln.StatusMessage == null || string.isBlank(ln.StatusMessage)) 
             && string.isNotBlank(ln.PartNumber)
             && discountToUse  > 0
                    
        ){
            updateOLRebate = true;
            if (distAcc != null){

                if (ln.Status == 'CONFIRMED'
                    && String.isNotBlank(distAcc.Tech_ATConfirmed__c))
                {
                    receivedStatus = distAcc.Tech_ATConfirmed__c;
                } 
                else if (ln.Status == 'CONFIRMEDWITHDELAY'
                        && String.isNotBlank(distAcc.Tech_ATConfirmedWithDelay__c))
                {
                    receivedStatus = distAcc.Tech_ATConfirmedWithDelay__c;
                } 
                else if (ln.Status == 'PARTIAL'
                        && String.isNotBlank(distAcc.Tech_ATPartial__c))
                {
                    receivedStatus = distAcc.Tech_ATPartial__c;
                } 
                else if (ln.Status == 'NOTFOUND'
                        && String.isNotBlank(distAcc.Tech_ATNotFound__c))
                {
                    receivedStatus = distAcc.Tech_ATNotFound__c;
                } 
                else if (ln.Status == 'OTHER'
                        && String.isNotBlank(distAcc.Tech_ATOther__c))
                {
                    receivedStatus = distAcc.Tech_ATOther__c;
                } 
            }

            string substitutePartNumber =  system.label.DEsubstiturePrefix + ln.PartNumber ;
            String techTypeOfSubsPartNumber = 'ASP-' + ln.PartNumber;

            string substituteKey = ln.ID + '-' +  substitutePartNumber.replaceAll( '\\s+', '');
                
            string description = '';

            if(string.isNotBlank(brand)){
                description = ln.Description + ' - ' + brand + ' -OEM (' + ln.PartNumber + ')';
            }
            else{
                description = ln.Description + ' -OEM ' + '(' + ln.PartNumber + ')';
            }

            decimal asPublicPrice = 0.0,ASNETPRICE = 0.0;
            decimal OEMPrice = 0.0,OEMASNETPRICE = 0.0;

            //AMI 12/02/2018 - C-002041 - Distributor V2 - Update std discount and margin during A' Creation
            decimal oemStdDiscount = 0.0, oemStdMargin = 0.0;

            //ASE: 28/05/2018-C-002041 changes in calculations
            decimal aspStdDiscount = 0.0, aspStdMargin = 0.0;

            //AMI 24/01/18 : C-002041 - Distributor V2 - A' Creation Criteria
            //                        - calculate discount to apply (either as additional discount or rebate)
            //                        
            decimal discount = ln.AlphaScaleDiscountAdditional > 0 ? (ln.AlphaScaleDiscountAdditional/100) : (discountToUse > 0 ? discountToUse : 0.0);

            //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
            //                                         - this map will be used to pass param to calculate price values
            map <string,object> inputParamForPriceCalc = new map <string,object>();

            //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
            //                                         - this map will be used get updated price values
            map <string,object> updatedPricing = new map <string,object>();

            //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
            //                                         - populate inputParamForPriceCalc
            inputParamForPriceCalc.put('entity','fr');                                         
            // ASE: 07/05/18 : C-002528
            //inputParamForPriceCalc.put('discount',discount);
            inputParamForPriceCalc.put('discount', discountToUse);
            
            inputParamForPriceCalc.put('CatalogPrice',ln.CatalogPrice);
            inputParamForPriceCalc.put('AlphaScaleDiscount',ln.AlphaScaleDiscount);

            //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
            inputParamForPriceCalc.put('isIG', true);

            if(ln.CatalogPrice > 0){ 
                //AMI 25/01/18 : C-002041 - Distributor V2 - Do not update price on original during A' Creation
                /*
                OEMPrice = ln.CatalogPrice - (ln.CatalogPrice * (ln.BodyShopDiscount/100));
                OEMASNETPRICE = (ln.CatalogPrice * (ln.BodyShopDiscount/100));*/
                
                //AMI 20/02/18 : C-002041 - Distributor V2 - New pricing algo called externally
                //                                         - get updated values
                updatedPricing = RestUpsertAssessmentPricingAlgo.returnUpdatedPrices(inputParamForPriceCalc);
                

                ASNETPRICE = updatedPricing.containsKey('ASNETPRICE') ? (decimal)updatedPricing.get('ASNETPRICE') : 0.0;
                asPublicPrice = updatedPricing.containsKey('asPublicPrice') ? (decimal)updatedPricing.get('asPublicPrice') : 0.0;
                oemStdDiscount = updatedPricing.containsKey('oemStdDiscount') ? (decimal)updatedPricing.get('oemStdDiscount') : 0.0;
                oemStdMargin = updatedPricing.containsKey('oemStdMargin') ? (decimal)updatedPricing.get('oemStdMargin') : 0.0;
                aspStdDiscount = updatedPricing.containsKey('aspStdDiscount') ? (decimal)updatedPricing.get('aspStdDiscount') : 0.0;
                aspStdMargin = updatedPricing.containsKey('aspStdMargin') ? (decimal)updatedPricing.get('aspStdMargin') : 0.0;

                
            }
            PartList__c tempPartSubs = new PartList__c(TECH_OriginalPart__c = tempPart.TECH_OriginalPart__c,
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
                                                    //Assessment__c = tempPart.Assessment__c,
                                                    // OriginalPart__r = new PartList__c(TECH_OriginalPart__c = ln.ID),
                                                    ASNetPrice__c = ASNETPRICE,
                                                    Alpha_Scale_MRID__c = substitutePartNumber.replaceAll( '\\s+', ''),

                                                    //AMI 19/12/17 : Adding Discount and margin to A' Parts
                                                    //**** ASE: 28/05/2018-C-002041changes in calculations*/
                                                    //StandardDiscount__c = ln.BodyShopDiscount != null ? ln.BodyShopDiscount.setScale(2) : 0.0,
                                                    //StandardMargin__c = ln.BodyShopDiscount != null && ln.BodyShopDiscount > 0 ? (price * (ln.BodyShopDiscount/100)).setScale(2) : 0.0,

                                                    StandardDiscount__c = aspStdDiscount,
                                                    StandardMargin__c = aspStdMargin,

                                                    /****/ 

                                                    //AMI 22/02/18 : C-002041 - Distributor V2 - Adding missing field to ASP Response
                                                    InputType__c = tempPart.InputType__c,
                                                    Currency__c = tempPart.Currency__c 
                                                    //DUN 23/04/2018 case C-002482 : VAT on Invoice lines
                                                    ,VAT__c = (mapConfigCountryCodeInfo.get('DE') != null && mapConfigCountryCodeInfo.get('DE').CountryVAT__c != null) ? mapConfigCountryCodeInfo.get('DE').CountryVAT__c : null
                                                    ,Distributor__c=  distAcc.Id
                                                    ,TECHDistList__c = distAcc.Id                                                    
                                                    ,Distributors__c = distAcc.Id
                                                    //RLA 22/04/2020  Case 3695: Subject	IG - IGP Substitution part
                                                    ,techTypeOfSubsPartNumber__c = techTypeOfSubsPartNumber
                                                    ,TechCheckForSubstitute__c = false
                                                    ,id = tempPart.Id
                                                    );
            tempPartSubs.recalculateFormulas();
            system.debug('@@ tempPartSubs: '+tempPartSubs);
            system.debug('@@ tempPartSubs: '+tempPartSubs.ForTechSubsNumber__c);
            
            return tempPartSubs;



        }

        system.debug('@@ receivedStatus: '+receivedStatus);
        system.debug('@@ tempPart: '+tempPart);


        system.debug('## End createSubstitute'); 


        return tempPart;


    }

    public class responseToGenerate{
        public String OperationType;
        public String TechnicalId;
        public String FunctionalId;
        public Boolean Success;
        public String Warning;
        public String ErrorMessage;

        public responseToGenerate(String O, String T, String F, Boolean S, String W, String E){
            OperationType = O;
            TechnicalId = T;
            FunctionalId = F;
            Success = S;
            Warning = W;
            ErrorMessage = E;

        }
    }
}