/*************************************************************************************
Class Name - ASPISWithoutSharingExceptions
Version - 1.0
/*************************************************************************************
Class Name - ASPISWithoutSharingExceptions
Version - 1.0
Created Date - 25 MAY 2015
Function - Class wrap all methods that need to break security standard (with sharing)

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* João Dias             25/05/2015  Original Version
* Dourga Unmole         18/08/2015  Added method to insert log
* Cecile Lartaud        19/08/2015  Added method to get informations from Assessment list
* Dourga Unmole         15/09/2015  Change insertion of list to set
* Immo Salo             30/11/2015  Changed Offer__c list update to upsert
* Dourga Unmole         19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c 
                                    to add new field TECH_EntityCountryCode__c)
* Abdool Miskin         11/10/2018  Case C-002045 - Advance case management
                                    Update SO status to Managed if at least one offer is Managed
* Abdool Miskin         29/10/2018  Case C-002045 - Advance case management
                                    If BS update Offer to error again, add new chatter post if case openened, 
                                    else create new case with chatter post
* Welsa Chy             18/12/2018  C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops
* Welsa Chy             27/02/2019  C-003094 - Pb chatter : Update failed. First exception
* Welsa Chy             26/03/2021  C-004292 : Bodyshop Credit Note not generated after distributor returns a spare part
*************************************************************************************/
public without sharing class ASPISWithoutSharingExceptions {
    
    public static void updateAssessmentList(List<Assessment__c> listAssessments2Update){
        set <Assessment__c> setAssessment2Update = new set <Assessment__c>();
        for(Assessment__c ass : listAssessments2Update){
            if(!setAssessment2Update.contains(ass))
                setAssessment2Update.add(ass);
        }
        update new List<Assessment__c>(setAssessment2Update);
        //update listAssessments2Update;
    }
    
    public static List<Assessment__c> getAssessmentsPOChildren(Set<ID> setParentAssessmentIDs){
        return [select id,TECH_EntityCountryCode__c,BodyShop__c,OrderOrigin__c, RecordTypeId, (select name, ValidityDate__c, status__c, reason__c, PrerequisiteOrder__c from PurchaseOrders__r) from Assessment__c where id in :setParentAssessmentIDs];
    }
    
    public static List<Assessment__c> getAssessmentsInfo(List<ID> setAssessmentIDs){
        return [select id,Name,AssessmentNumber__c,VINNumber__c,PlateNumber2__c,Manufacturer__c  from Assessment__c where id in :setAssessmentIDs];
    }
    
    public static List<PurchaseOrder__c> getPurchaseOrderAndOrderLinesRegardingThisSalesOrder(Id SalesOrderID){
        return [select id, AcceptedLines__c, (select id, purchaseOrder__c from OrderLines__r where acceptedCheck__c = true) from PurchaseOrder__c where PrerequisiteOrder__c = :SalesOrderID];
    }
    
    public static Map<Id,List<PurchaseOrder__c>> getPurchaseOrderAndOrderLinesRegardingListOfSalesOrders(List<Id> listSalesOrdersID){
        Map<Id,List<PurchaseOrder__c>> m_SalesOrderId2ListPurchaseOrders = new Map<Id,List<PurchaseOrder__c>>();
        List<PurchaseOrder__c> results =  [select id, AcceptedLines__c, PrerequisiteOrder__c from PurchaseOrder__c where PrerequisiteOrder__c IN :listSalesOrdersID AND Status__c = 'ISSUED'];
        
        for(PurchaseOrder__c po :results ){
            if(m_SalesOrderId2ListPurchaseOrders.containsKey(po.PrerequisiteOrder__c))
                m_SalesOrderId2ListPurchaseOrders.get(po.PrerequisiteOrder__c).add(po);
            else
                m_SalesOrderId2ListPurchaseOrders.put(po.PrerequisiteOrder__c, new List<PurchaseOrder__c>{po});
        }
            
        return m_SalesOrderId2ListPurchaseOrders;
        
    }
    
    public static List<PrerequisiteOrder__c> getSalesOrderWithOffersAndOrderLinesInformationRegardingListSalesOrders(List<Id> listSalesOrdersID){
        return [SELECT Id, 
         (SELECT Id, Accepted__c, Prerequisiteorder__c, Prerequisiteorder__r.Status__c, OrderLine__c, OrderLine__r.OriginalItem__c, OrderLine__r.Suppliable__c, OrderLine__r.PurchaseOrder__c, OrderLine__r.PurchaseOrder__r.Status__c, DeliveryStatus__c, Name FROM Offers__r) 
         FROM PrerequisiteOrder__c WHERE Id IN :listSalesOrdersID];
    }
    
    public static void updatePurchaseOrderList(List<PurchaseOrder__c> listPurchaseOrder2Update){
        set <PurchaseOrder__c> setPurchaseOrder2Update = new set <PurchaseOrder__c>();
        for(PurchaseOrder__c po : listPurchaseOrder2Update){
            if(!setPurchaseOrder2Update.contains(po))
                setPurchaseOrder2Update.add(po);
        }
        update new List<PurchaseOrder__c>(setPurchaseOrder2Update);
        //update listPurchaseOrder2Update;
    }

    public static void updatePrerequisiteOrderList(List<PrerequisiteOrder__c> listPrerequisiteOrder2Update){
        set <PrerequisiteOrder__c> setPrerequisiteOrder2Update = new set <PrerequisiteOrder__c>();
        for(PrerequisiteOrder__c pr : listPrerequisiteOrder2Update){
            if(!setPrerequisiteOrder2Update.contains(pr))
                setPrerequisiteOrder2Update.add(pr);
        }
        update new List<PrerequisiteOrder__c>(setPrerequisiteOrder2Update);
        //update listPurchaseOrder2Update;
    }    
    
    public static void updateOrderLineList(List<OrderLine__c> listOrderLine2Update){
        set <OrderLine__c> setOrderLine2Update = new set <OrderLine__c>();
        for(OrderLine__c ol : listOrderLine2Update){
            if(!setOrderLine2Update.contains(ol))
                setOrderLine2Update.add(ol);
        }
        update new List<OrderLine__c>(setOrderLine2Update);
        //update listOrderLine2Update;
    }
    
    public static List<OrderLine__c> getOrderLinesInfo(List<ID> OrderLinesID){
        return [SELECT Id, AcceptedCheck__c, OriginalItem__c, OriginalItem__r.AcceptedCheck__c, DeliveryStatus__c,
                (SELECT Id, AcceptedCheck__c, OriginalItem__c, OriginalItem__r.AcceptedCheck__c, DeliveryStatus__c
                    From AlternativeItem__r) FROM OrderLine__c WHERE Id IN :OrderLinesID];
    }
    
    public static void insertInvoice(Invoice__c invoice){
        insert invoice;
    }

    public static void insertInvoices(List<Invoice__c> invoices){
        insert invoices;
    }   
    
    public static void insertListOrderLines(List<OrderLine__c> l_orderLines){
        insert l_orderLines;
    }
    
    public static void upsertListOrderLines(List<OrderLine__c> l_orderLines){
        set <OrderLine__c> setOrderLine2Update = new set <OrderLine__c>();
        for(OrderLine__c ol : l_orderLines){
            if(!setOrderLine2Update.contains(ol))
                setOrderLine2Update.add(ol);
        }
        upsert new List<OrderLine__c>(setOrderLine2Update);
        //upsert l_orderLines;
    }
    
    public static void insertListCases(List<Case__c> l_casesToInsert){
        insert l_casesToInsert;
    }
    
    public static void updateOfferLineList(List<Offer__c> listOfferLine2Update){
        set <Offer__c> setOfferLine2Update = new set <Offer__c>();
        for(Offer__c off : listOfferLine2Update){
            if(!setOfferLine2Update.contains(off))
                setOfferLine2Update.add(off);
        }
        upsert new List<Offer__c>(setOfferLine2Update); // this was update, changed 30/11/2015
        //update listOfferLine2Update;
    }

    public static void insertLog(Log__c logToInsert){
        insert logToInsert;
    }

    public static void insertPartLists(list<PartList__c> partListToInsert){
        insert partListToInsert;
    }

    public static list<PurchaseOrder__c> getPOList(Id newClaimOrderAssessmentId){
         return( [SELECT  Assessment__c, status__c, Distributor__r.ReferenceNumber__c, Distributor__r.DistributorConnected__c, Assessment__r.ClaimReference__c, Name, 
                          DistributorPOReference__c, BodyShopOrderNumber__c, Distributor__r.PartTypeRegionDelayMatrix__c, Distributor__r.Categories__c,Distributor__r.Tech_Distributor__c,
                        (SELECT Id, PartNumber__c, Description__c, Type__c, Quantity__c, Manufacturer__c, Suppliable__c, TechExternalId__c,PartList__c from OrderLines__r),//WCH 18/12/2018 C-002958 - MultiSourcing Belgium - Large choice of distributors for Bodyshops, add field PartList__c
                        Assessment__r.BodyShop__r.Name, Assessment__r.BodyShop__r.ReferenceNumber__c, Assessment__r.BodyShop__r.VATNumber__c,
                        Brand__c, AssetModel__c, AssetRegistrationDate__c, PlateNumber__c, VINNumber__c,  ReleaseDate__c, Distributor__r.Name,Distributor__r.Type_of_Substitutes__c 
                     FROM PurchaseOrder__c 
                     WHERE Assessment__c =: newClaimOrderAssessmentId]);
    }

    public static void insertOffers(list<Offer__c> offerToInsert){
        insert offerToInsert;
    }

    public static list<Offer__c> getOfferList(Id assClaimId){
        return([select Id, Type__c, BSTotalPrice__c, OrderLine__r.BodyShopDiscount__c, Quantity__c, OrderLine__r.CataloguePrice__c, OrderLine__r.PartList__c, PartNUmber__c,
                                     OrderLine__r.PartList__r.Name, OrderLine__r.PartList__r.VAT__c, OrderLine__r.PartList__r.Quantity__c, OrderLine__r.TotalPrice__c , Description__c,
                                     OrderLine__r.PartList__r.PartNumber__c, OrderLine__r.PartList__r.Price__c, OrderLine__r.PartList__r.Type__c, Discount__c, Distributor__c,
                                     OrderLine__r.PartList__r.OriginalPart__c, OrderLine__r.PartList__r.Original__c,OrderLine__r.PartList__r.Description__c, 
                                     OrderLine__r.PartList__r.ProducerName__c, OrderLine__r.PartList__r.SelectedByBS__c, 
                                     OrderLine__r.PartList__r.CrossReferenceId__c, OrderLine__r.PartList__r.IsSourced__c, OrderLine__r.PartList__r.Assessment__c, 
                                     OrderLine__r.PartList__r.TECH_OriginalPart__c, OrderLine__r.PurchaseOrder__c, OrderLine__r.PurchaseOrder__r.Distributor__c,
                                     OrderLine__r.PartList__r.InputType__c, OrderLine__r.Suppliable__c,
                                     OrderLine__r.PartList__r.OriginalPart__r.QuantityOrdered__c, OrderLine__r.PartList__r.OriginalPart__r.Quantity__c, CataloguePrice__c,
                                     OrderLine__r.PurchaseOrder__r.Distributor__r.ReferenceNumber__c, OrderLine__r.PurchaseOrder__r.Distributor__r.Name,
                                     OrderLine__r.PurchaseOrder__r.Distributor__r.PartTypeRegionDelayMatrix__c,OrderLine__r.PurchaseOrder__r.Distributor__r.DistributorRegionsCovered__c,
                                     Prerequisiteorder__c, Prerequisiteorder__r.Assessment__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__c,Prerequisiteorder__r.Status__c,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.Status__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.ParentAssessment__c,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.Name, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.BodyShop__c,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.Entity__c,Prerequisiteorder__r.Assessment__r.ParentAssessment__r.SpecialAgreement__c, 
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.SpecialRenting__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.VINCheck__c, 
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.Fleet__c,Prerequisiteorder__r.Assessment__r.ParentAssessment__r.TotalLoss__c,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.SupposedOfFraud__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.DateOfIncident__c, 
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.FirstRegistrationDate__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.EntityCode__c,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.ModelV2__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.MissionNumber__c, 
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.ClaimReference__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.Manufacturer__c,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.EntityRules__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.PlateNumber2__c, 
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.TECH_EntityCountryCode__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.VINNumber__c, 
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.AssessmentID__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__r.BodyShop__r.Type,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.AssessmentNumber__c,Prerequisiteorder__r.Assessment__r.ParentAssessment__r.BodyShop__r.ShippingPostalCodeLeft2__c,
                                     Prerequisiteorder__r.Assessment__r.ParentAssessment__r.BodyShop__r.Payment_Type__c                              
                             from Offer__c 
                             where Prerequisiteorder__r.Assessment__r.ParentAssessment__c =: assClaimId]);
    }

    //AMI 29/10/2018  Case C-002045 - Advance case management
    //                                If BS update Offer to error again, add new chatter post if case openened, 
    //                                else create new case with chatter post
    public static void updatePurchaseOrderDiscussionCase(set<Id> setOlId,set <Id> offToProcessed){
        map<Id,PurchaseOrder__c> mapPOToUpdate = new map<Id,PurchaseOrder__c>();
        map<String,CountryCodeInformationsMapping__c> countryInformations = CountryCodeInformationsMapping__c.getall();

        //AMI 29/10/2018  Case C-002045 - Advance case management
        //                              - these sets will be used to check for any exisiting openend cases
        set <id> setSOIdToCheck = new set <id>();
        set <id> setPOIdToCheck = new set <id>();

        //WCH 27/02/2019 C-003094 Pb chatter : Update failed. First exception
        set <id> setBSLinkedToCase = new set <id>();

        //AMI 29/10/2018  Case C-002045 - Advance case management
        //                              - all opened cases for new notification to be sent
        list <Case__c> lstCasesToProcessed = new list <Case__c>();

        //looping in offer to get SOId and Po Name
        for(Offer__c off : [select id,OrderLine__c,OrderLine__r.PurchaseOrder__r.Id,Prerequisiteorder__c,
                                Prerequisiteorder__r.TECH_BodyshopCountryCode__c
                                ,Prerequisiteorder__r.BodyShop__c //WCH 27/02/2019 C-003094 Pb chatter : Update failed. First exception
                            from Offer__c
                            where id IN : offToProcessed]){
            if(countryInformations.get(off.Prerequisiteorder__r.TECH_BodyshopCountryCode__c) != null &&
               countryInformations.get(off.Prerequisiteorder__r.TECH_BodyshopCountryCode__c).AdvancedCaseManagement__c){
                setSOIdToCheck.add(off.Prerequisiteorder__c);
                setPOIdToCheck.add(off.OrderLine__r.PurchaseOrder__c);

                //WCH 27/02/2019 C-003094 Pb chatter : Update failed. First exception
                setBSLinkedToCase.add(off.Prerequisiteorder__r.BodyShop__c);
            }
        }

        //AMI 29/10/2018  Case C-002045 - Advance case management
        //                              - query all openened cases if any based on setSOIdToCheck and 
        //                              - setPOIdToCheck
        if(!setSOIdToCheck.isEmpty() && !setPOIdToCheck.isEmpty()){

            //WCH 27/02/2019 C-003094 Pb chatter : Update failed. First exception
            setBSLinkedToCase.remove(null);

            for(Case__c ca : [select Id,Purchase_order__r.Distributor__r.ContactUser__c 
                                from Case__c
                                where Purchase_order__c IN :setPOIdToCheck
                                and Sales_order__c IN :setSOIdToCheck
                                and Status__c != :ASPISConstants.caseStatusClosed
                                and Account_Name__c IN : setBSLinkedToCase //WCH 27/02/2019 C-003094 Pb chatter : Update failed. First exception
                                ]){
                lstCasesToProcessed.add(ca);
            }//end looping in case
        }//end if !setSOIdToCheck.isEmpty() && !setPOIdToCheck.isEmpty()

        //AMI 29/10/2018  Case C-002045 - Advance case management
        //                              - post to chatter
        if(!lstCasesToProcessed.isEmpty() && !Test.isRunningTest()){
            for(Case__c ca : lstCasesToProcessed){
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                mentionSegmentInput.id = ca.Purchase_order__r.Distributor__r.ContactUser__c;
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                textSegmentInput.text = ' ' + System.label.NewCommentMessage;
                messageBodyInput.messageSegments.add(textSegmentInput);
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = ca.Id;
                ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            }
        }//end if !lstCasesToProcessed.isEmpty()

        //-------------------------------------------------------------------------------------------------------//
        //-----------------------------Continue this code for all closed cases-----------------------------------//
        for(OrderLine__c ol : [select Id, PurchaseOrder__c , PurchaseOrder__r.Assessment__r.TECH_EntityCountryCode__c
                                from OrderLine__c
                                where Id in: setOlId
                                and PurchaseOrder__r.OrderDiscussionCase__c = false]){
            if(countryInformations.get(ol.PurchaseOrder__r.Assessment__r.TECH_EntityCountryCode__c) != null && 
               countryInformations.get(ol.PurchaseOrder__r.Assessment__r.TECH_EntityCountryCode__c).AdvancedCaseManagement__c){
                if(!mapPOToUpdate.containsKey(ol.PurchaseOrder__c)){
                    mapPOToUpdate.put(ol.PurchaseOrder__c, new PurchaseOrder__c(Id = ol.PurchaseOrder__c, OrderDiscussionCase__c = true));
                }
            }
        }
        if(mapPOToUpdate.size() > 0){
            update mapPOToUpdate.values();
        }
        system.debug('## mapPOToUpdate ' + mapPOToUpdate);
        //-------------------------------------------------------------------------------------------------------//
    }

    //AMI 11/10/2018 : Case C-002045 - Advance case management 
    //                 Update SO status to Managed if offer status is changed to Managed and update SLAManagedEntryDate__c with NOW
    //                 Update should be done if all other parts are in a final status
    public static void updateSOToManage(set <id> setSOToUpdate){
        system.debug('## start updateSOToManage');

        // this map will contain all SO to update
        map <id,PrerequisiteOrder__c> mapSOToUpdateToManage = new map <id,PrerequisiteOrder__c>();

        //custom setting
        map<string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = CountryCodeInformationsMapping__c.getAll();

        //this query will returned all SO having at least one offer in managed status
        for(PrerequisiteOrder__c so : [select id,AcceptedLines__c,NumberCanceledLines__c,DeliveredLines__c,ManagedLines__c,
                                            ErroredLines__c,Status__c,Assessment__r.TECH_EntityCountryCode__c
                                        from PrerequisiteOrder__c
                                        where id in :setSOToUpdate]){
            //status update only for advance case mgt
            if(so.Assessment__r.TECH_EntityCountryCode__c != null &&
                allConfigCountryCodeInfo.containsKey(so.Assessment__r.TECH_EntityCountryCode__c) && 
                allConfigCountryCodeInfo.get(so.Assessment__r.TECH_EntityCountryCode__c).AdvancedCaseManagement__c){

                    //check if all status are in final status before updating to Managed
                    decimal tempFinalStatusManageCheck = so.NumberCanceledLines__c + so.DeliveredLines__c + so.ManagedLines__c;
                    
                    if(tempFinalStatusManageCheck == so.AcceptedLines__c && so.ManagedLines__c > 0){
                        mapSOToUpdateToManage.put(so.id,new PrerequisiteOrder__c(id = so.id,
                                                                                 Status__c = ASPISConstants.PRE_ORDER_STATUS_MANAGED,
                                                                                 SLAManagedEntryDate__c = system.now()));
                    }//end if tempFinalStatusManageCheck == so.AcceptedLines__c
                    else if(so.ErroredLines__c > 0 && so.Status__c == ASPISConstants.PRE_ORDER_STATUS_MANAGED){
                        if(so.DeliveredLines__c > 0){
                            if(so.Status__c != ASPISConstants.PRE_ORDER_STATUS_DELIVERED){
                                mapSOToUpdateToManage.put(so.id,new PrerequisiteOrder__c(id = so.id,
                                                                                        Status__c = ASPISConstants.PRE_ORDER_STATUS_DELIVERED));
                            }
                        }else if(so.Status__c != ASPISConstants.PRE_ORDER_STATUS_INDELIVERY){
                             mapSOToUpdateToManage.put(so.id,new PrerequisiteOrder__c(id = so.id,
                                                                                     Status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY));
                        }
                    }
            }   
        }//end looping in SO
        system.debug('## mapSOToUpdateToManage.size() ' + mapSOToUpdateToManage.size());

        if(mapSOToUpdateToManage.size() > 0){
            update mapSOToUpdateToManage.values();
        }//end if mapSOToUpdateToManage.size() > 0

        system.debug('## end updateSOToManage');  
    }
    //WCH 26/03/2021 C-004292
    public static Map<Id, OrderLine__c> flagOrderLine(Set<Id> offerIds){
        // List to store the sales order to be updated
        Map<Id, OrderLine__c> mapOrderLine = new Map<Id, OrderLine__c>(); 

        // Retrieving the offer that its order line that needs to be flagged
        // Sales order status being delivery confirmed, invoiced or paid
        for (Offer__c offerBeingUpdated : [ SELECT  Id, Prerequisiteorder__c, Prerequisiteorder__r.Status__c, OrderLine__c, OrderLine__r.TECH_ToBeProcessed__c, OrderLine__r.TechGeneratedFinal__c
                                            FROM    Offer__c
                                            WHERE   Id IN: offerIds
                                            AND     (   Prerequisiteorder__r.Status__c =: ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED
                                                    OR  Prerequisiteorder__r.Status__c =: ASPISConstants.PRE_ORDER_STATUS_INVOICED
                                                    OR  Prerequisiteorder__r.Status__c =: ASPISConstants.PRE_ORDER_STATUS_PAID
                                                    OR  Prerequisiteorder__r.Status__c =: ASPISConstants.PRE_ORDER_STATUS_DELIVERED
                                                    OR  Prerequisiteorder__r.Status__c =: ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK)
                                            ])
        {
            if (offerBeingUpdated.OrderLine__c != null && 
                offerBeingUpdated.OrderLine__r.TechGeneratedFinal__c == false && 
                offerBeingUpdated.OrderLine__r.TECH_ToBeProcessed__c == false)
            {
                mapOrderLine.put(offerBeingUpdated.OrderLine__c, new OrderLine__c(Id = offerBeingUpdated.OrderLine__c,
                                                                                   TECH_ToBeProcessed__c = true)
                                  );
            }
        }

        return mapOrderLine;
    }

    //RBE 14/02/2023
    public static void updateObjectField(Map<String,Object> mapInputParam){
        String objJSON = mapInputParam.get('ObjectJSON') != null ? (String) mapInputParam.get('ObjectJSON') : '';
        List<SObject> lstObj = (List<SObject>) JSON.deserialize(objJSON, List<SObject>.class);

        String objField = mapInputParam.get('FieldToUpdate') != null ? (String) mapInputParam.get('FieldToUpdate') : '';

        String fieldValue =  mapInputParam.get('Value') != null ? (String) mapInputParam.get('Value') : '';
        try {
            for(SObject obj : lstObj){
                obj.put(objField, fieldValue);
            }
            update lstObj;
        }
        catch(Exception e){
            System.debug('COULD NOT UPDATE: '+e.getMessage()+' '+e.getStackTraceString());
        }
        
        
    }
}