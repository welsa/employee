/*
----------------------------------------------------------------------
-- - Name          : OfferTriggerHandler
-- - Author        : DUN
-- - Description   : Handler for the trigger OfferTrigger
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 07-OCT-2016  DUN     1.0    Reworked version
-- 28-NOV-2016  ASE     1.1    C-001674 : remove status missing and damaged
----------------------------------------------------------------------
-- Flow of OfferTriggerHandler:
--  Before Insert
--      - Nothing
--      
--  After Insert
--      - Nothing
--      
--  Before Update
--      - Nothing
--          
--  After Update
--      -> if Accepted__c has changed && if Accepted__c != null && ParentOffer__c != null 
--          --> Update Parent Offer with same Accepted__c as child
--
--      -> if DeliveryStatus__c has changed 
--          - if old DeliveryStatus__c was DELIVERED and (new DeliveryStatus__c is CANCELED or RETURNED) 
--              --> flag the offer's order line
--          - if (DeliveryStatus__c is CANCELED or RETURNED) and TechIsInvoiced__c is false and Accepted__c = 'YES'
--              --> generate invoice
--          //ASE: 28/11/16 : C-001674:
            //- if DeliveryStatus__c is DAMAGED or ERROR or MISSING  
              - if DeliveryStatus__c is ERROR 
--              --> set the orderline of the offer DeliveryStatus__c to ISSUE and also the child and parent orderlines
--              --> Create Case for the SalesOrder
--          - if DeliveryStatus__c is DELIVERED or CANCELED or RETURNED 
--              --> set orderline of the offer DeliveryStatus__c the same as the Offer.DeliveryStatus__c and also the child and parent orderlines
--
--      -> if (Invoice__c has changed and Invoice__c is not null) or (CreditNote__c has changed or CreditNote__c is not null)
--          --> Update SalesOrder TotalASPrice__c   
----------------------------------------------------------------------
-- Previous Class History
----------------------------------------------------------------------
-- Developer    Date        Description
-- ----------   ----------  -----------------------
-- Cecile L     21/05/2015  Original Version
-- Yudish R     08/06/2015  Updated Version - Generate invoice(credit note), when offers statusDelivery is cancel
-- Dourga U     01/07/2015  OnafterUpdate - update field Total AS Price in sales order
-- Cecile L     10/07/2015  Put by default the value INPROCESS in the field Delivery Status
-- Dourga U     20/08/2015  Added code to create log in catch part
-- Cécile L     27/10/2015  Code Optimization
-- ABT          13/04/2016  Added the functionality to flag the order line when the offer undergoes a change in status
-- Dourga U     28/04/2016  Commented OnBeforeInsert -- no longer in use
-- Dourga U     07/02/2017  case 1669: Set FDP part to delivered when all offers related to a PO is delivered
-- Dourga U     08/08/2018  C-001851 - Communication between Supplier vs B/S
-- Abdool M     17/10/2018  C-002045 - Advance case management
                                     - added status managed for credit note to be generated
-- Abdool M     29/10/2018  Case C-002045 - Advance case management
                                            If BS update Offer to error again, add new chatter post if case openened, 
                                            else create new case with chatter post
-- Welsa C     29/01/2021  C-004153 - Error after deletion of accountshare sharing BS to Distributors
-- Welsa C     26/03/2021  C-004292 : Bodyshop Credit Note not generated after distributor returns a spare part
**********************************************************************
*/
public with sharing class OfferTriggerHandler {

    // ABT - 16-FEB-2017 - C-001816
    public static Boolean hasOnBeforeUpdateRun = false;

    // ABT 14-NOV-2016 - C-001799
    public void onAfterInsert(List<Offer__c> newOfferList)
    {
        System.debug('-------------------------- START METHOD OfferTriggerHandler - onAfterInsert --------------------------');

        Set<Id> ap31OrderLinesIdSet = new Set<Id>();

        for(Offer__c newOffer : newOfferList)
        {
            if(newOffer.OrderLine__c != null)
            {
                ap31OrderLinesIdSet.add(newOffer.OrderLine__c);
            }
        }

        if(ap31OrderLinesIdSet.size() > 0)
        {
            AP31PopulateBodyShopDiscount.updateBodyShopDiscount(ap31OrderLinesIdSet);
        }

        System.debug('-------------------------- END METHOD OfferTriggerHandler - onAfterInsert --------------------------');
    }

    public void onBeforeUpdate(List<Offer__c> newOfferList, List<Offer__c> oldOfferList, Map<Id, Offer__c> mapOldOffer)
    {
        System.debug('-------------------------- START METHOD OfferTriggerHandler - onBeforeUpdate --------------------------');

        
        // Loop in the list of offers
        for(Integer i = 0; i < newOfferList.size(); i++)
        {
            // ABT - 16-FEB-2017 - C-001816
            // Need to check if the offer trigger handler is being called before
            if( !OrderLineTriggerHandler.hasOnBeforeUpdateRun &&
                newOfferList[i].DeliveryStatus__c != oldOfferList[i].DeliveryStatus__c &&
                (newOfferList[i].DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
                 newOfferList[i].DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
              )
            {
                // setting the checkbox to true to indicate that the current offer is being canceled by the bodyshop
                newOfferList[i].IsCanceledByBodyshop__c = true;

                // Setting the static variable to true
                OfferTriggerHandler.hasOnBeforeUpdateRun = true;
            }
        }

        System.debug('-------------------------- END METHOD OfferTriggerHandler - onBeforeUpdate --------------------------');
    }

    public void OnAfterUpdate(list <Offer__c> listOldOffers, list <Offer__c> listNewOffers, Map<ID, Offer__c> mapOldOffers){
        System.debug('-------------------------- START METHOD OfferTriggerHandler - OnAfterUpdate --------------------------');
        //set of salesorder id
        Set<Id> setSalesOrderIdDeliveryCase = new Set<Id>();
        //set of ordelines Ids with delivery status that needs to be updated
        Set<Id> setOrderLineDeliveryStatusId = new Set <Id>();
        //set of alternative orderlines id already updated
        Set<Id> setAlternativeOrderLineId = new Set <Id>();
        //C-001592
        Set<Id> offerHavingDeliveryStatusModified = new Set<Id>();
        //case 1669 
        set<Id> setSalesOrderId = new set<Id>();
        //list of offers to update
        List<Offer__c> listOffersToUpdate = new List<Offer__c>();
        //list of salesorder to update
        List<Prerequisiteorder__c> listSalesOrderToUpdate = new List<Prerequisiteorder__c>();
        //list of orderline to update
        Map<Id,OrderLine__c> mapOrderLinesToUpdate = new Map<Id,OrderLine__c>();
        //map use to generate invoice
        Map<Id, List<Offer__c>> salesOrderOffersMapAp17 = new Map<Id, List<Offer__c>>();
        //map of sales order to update
        Map<Id, Prerequisiteorder__c> mapsalesOrderTotalASPrice = new Map<Id, Prerequisiteorder__c>();
        //map of orderlines flagged
        Map<Id, OrderLine__c> mapOrderLineFlagged = new Map<Id, OrderLine__c>();
        //map of orderlines delivery status
        Map<Id, OrderLine__c> mapOrderLineDeliveryStatus = new Map<Id, OrderLine__c>();
        //map of salesorderId and its list of offers
        Map<Id,list<Offer__c>> mapSOIdOffer = new Map <Id,list<Offer__c>>();
        // map of the Order Lines we need to update, with their alternative items (bundle item or alternative).
        Map<Id,OrderLine__c> m_OrderLineId2Record = new Map<Id,OrderLine__c>();
        //set of Offers Id where partlist parent Tech_OrderedCounter__c field needs to be updated (DUN 02/05/2017 case 1914)
        Set<Id> setOfferId = new Set<Id>();
        //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
        set<Id> setOrderlineId = new set<Id>();

        //AMI 29/10/2018  Case C-002045 - Advance case management
        //                                If BS update Offer to error again, add new chatter post if case openened, 
        //                                else create new case with chatter post
        set<Id> offToProcessed = new set<Id>();

        // ABT 19-MAY-2017 - C-001827
        Set<Id> restPostSalesOrderIdSet = new Set<Id>();
        for(Offer__c off : listNewOffers){
            //Update Parent Offer with same Accepted__c as child
            if(off.Accepted__c != mapOldOffers.get(off.Id).Accepted__c && 
               off.Accepted__c != null && 
               off.ParentOffer__c != null){
                listOffersToUpdate.add(new Offer__c(Id = off.ParentOffer__c, Accepted__c = off.Accepted__c));
            }

            //if DeliveryStatus__c has changed
            if(off.DeliveryStatus__c != mapOldOffers.get(off.Id).DeliveryStatus__c){
                //flag the offer's order line C-001592
                //DUN 21.12.2016 When status changes from error to canceled/returned, a credit note needs to be created

                //AMI 17/10/2018 : C-002045 - Advance case management
                //                          - added status managed for credit note to be generated
                if((mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED || 
                    mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_ERROR ||
                    mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_MANAGED) && 
                   (off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED || 
                    off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)){
                    offerHavingDeliveryStatusModified.add(off.Id);
                    system.debug('##offerHavingDeliveryStatusModified '+offerHavingDeliveryStatusModified);
                }
                //DUN 07/02/2017 case 1669
                if(off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED){
                    setSalesOrderId.add(off.Prerequisiteorder__c);
                }
                system.debug('##setSalesOrderId'+setSalesOrderId);
                
                //generate invoice
                if((off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED || 
                         off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED) && 
                        off.TechIsInvoiced__c == false 
                        && off.Accepted__c == 'YES'){
                    system.debug('## offer returned ' + off.id);
                    if(salesOrderOffersMapAp17.containsKey(off.Prerequisiteorder__c)){
                        salesOrderOffersMapAp17.get(off.Prerequisiteorder__c).add(off);
                    }
                    else{
                        salesOrderOffersMapAp17.put(off.Prerequisiteorder__c, new list<Offer__c>{off});
                    }
                }
                //set the orderline of the offer DeliveryStatus__c to ISSUE and also the child and parent orderlines
                //Create Case for the SalesOrder (update HasSomeDeliveryIssuedCaseCreated__c on SO)
                //C-001674: remove status damaged and missing
                if(//off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DAMAGED || 
                   off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_ERROR  
                   //|| off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_MISSING
                ){
                    setSalesOrderIdDeliveryCase.add(off.Prerequisiteorder__c);
                    // ABT - 17-FEB-2017 - C-001816 - Added the CancelReason__c (copying the offer's DeliveryStatusReason__c to cancel reason)
                    mapOrderLineDeliveryStatus.put(off.OrderLine__c, new OrderLine__c(Id                = off.OrderLine__c, 
                                                                                     DeliveryStatus__c  = ASPISConstants.ORD_LINE_STATUS_ISSUE,
                                                                                     DeliveryStatusReason__c    = off.DeliveryStatusReason__c));
                    //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
                    setOrderlineId.add(off.OrderLine__c);

                    //AMI 29/10/2018  Case C-002045 - Advance case management
                    //                                If BS update Offer to error again, add new chatter post if case openened, 
                    //                                else create new case with chatter post
                    offToProcessed.add(off.Id);
                }
                //set orderline of the offer DeliveryStatus__c the same as the Offer.DeliveryStatus__c and also the child and parent orderlines
                if(off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED || 
                   off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED /*|| 
                   off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED*/){
                    mapOrderLineDeliveryStatus.put(off.OrderLine__c,new OrderLine__c(Id = off.OrderLine__c, DeliveryStatus__c = off.DeliveryStatus__c));
                }

                // ABT - 17-FEB-2017 - C-001816 - Added the CancelReason__c for RETURNED
                if(off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED)
                {
                    mapOrderLineDeliveryStatus.put(off.OrderLine__c, new OrderLine__c(  Id                  = off.OrderLine__c, 
                                                                                        DeliveryStatus__c   = off.DeliveryStatus__c,
                                                                                        DeliveryStatusReason__c     = off.DeliveryStatusReason__c));
                }
                
                  // ABT 19-MAY-2017 - C-001827
                if((mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_INDELIVERY ||
                    mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED ||
                    mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELAYED ||
                    mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
                    mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_ERROR ||
                    mapOldOffers.get(off.Id).DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED) &&
                   (off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED ||
                    off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELAYED ||
                    off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_CANCELED ||
                    off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_ERROR ||
                    off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_RETURNED ||
                    off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_INDELIVERY))
                {
                    restPostSalesOrderIdSet.add(off.PrerequisiteOrder__c);
                }
            }
  
            //Update SalesOrder TotalASPrice__c
            if((off.Invoice__c != null && 
                off.Invoice__c != mapOldOffers.get(off.Id).Invoice__c) || 
               (off.CreditNote__c != null && 
                off.CreditNote__c != mapOldOffers.get(off.Id).CreditNote__c)){
                if(mapSOIdOffer.containsKey(off.Prerequisiteorder__c)){
                    mapSOIdOffer.get(off.Prerequisiteorder__c).add(off);
                }
                else{
                    mapSOIdOffer.put(off.Prerequisiteorder__c,new list <Offer__c>{off});
                }

            }

            //DUN 02/05/2017 case 1914
            if(off.Accepted__c == 'NO' &&
               mapOldOffers.get(off.Id).Accepted__c == 'YES' &&
               off.Suppliable__c == true){
                setOfferId.add(off.Id);
            }
        }
        if(setSalesOrderId.size() > 0){
            setFDPDelivered(setSalesOrderId);
        }

        //C-001592
        if (offerHavingDeliveryStatusModified.size() > 0){
            //WCH 26/03/2021 C-004292
            if(ASPISTools.getCurrentUserInfo().UserRoleId!=null && ASPISTools.getCurrentUserInfo().ProfileId!=null && String.isNotBlank(ASPISTools.getCurrentUserInfo().UserRole.name)&& String.isNotBlank(ASPISTools.getCurrentUserInfo().Profile.Name)&& (ASPISTools.getCurrentUserInfo().UserRole.name).LEFT(2)==ASPISConstants.userCountryCodeES&& system.Label.AspisDistributorProfiles.contains(ASPISTools.getCurrentUserInfo().Profile.Name)){
                mapOrderLineFlagged = ASPISWithoutSharingExceptions.flagOrderLine(offerHavingDeliveryStatusModified);
            }else{
                mapOrderLineFlagged = flagOrderLine(offerHavingDeliveryStatusModified);
            }
        }
        //Selecting the map of orderlines and its childs and adding child to list of orderline to update
        if(mapOrderLineDeliveryStatus.size() > 0){
            m_OrderLineId2Record = new Map<Id,OrderLine__c>(ASPISWithoutSharingExceptions.getOrderLinesInfo(new list <Id>(mapOrderLineDeliveryStatus.KeySet())));
            for(OrderLine__c ol : m_OrderLineId2Record.values()){
                if(ol.AlternativeItem__r.size() > 0){
                    for(OrderLine__c olAlt : ol.AlternativeItem__r){
                        olAlt.DeliveryStatus__c = mapOrderLineDeliveryStatus.get(ol.Id).DeliveryStatus__c;
                        mapOrderLinesToUpdate.put(olAlt.Id,olAlt);
                    }
                }
            }
        }
        //Populating map of mapOrderLinesToUpdate
        for(Id olId : mapOrderLineDeliveryStatus.KeySet()){
            //check if mapOrderLineFlagged already contains this ol, then add its delivery status
            if(mapOrderLineFlagged.containsKey(olId)){
                mapOrderLineFlagged.get(olId).DeliveryStatus__c = mapOrderLineDeliveryStatus.get(olId).DeliveryStatus__c;
                mapOrderLinesToUpdate.put(mapOrderLineFlagged.get(olId).Id,mapOrderLineFlagged.get(olId));
            }
            else{
                mapOrderLinesToUpdate.put(mapOrderLineDeliveryStatus.get(olId).Id,mapOrderLineDeliveryStatus.get(olId));
            }
        }
        for(Id olId : mapOrderLineFlagged.KeySet()){
            mapOrderLinesToUpdate.put(mapOrderLineFlagged.get(olId).Id,mapOrderLineFlagged.get(olId));
        }       
        
        //calculate TotalASPrice
        if(mapSOIdOffer.size() > 0){
            mapsalesOrderTotalASPrice = calculateTotalASPrice(mapSOIdOffer);
        }
        for(Id soId : setSalesOrderIdDeliveryCase){
            if(mapsalesOrderTotalASPrice.containsKey(soId)){
                mapsalesOrderTotalASPrice.get(soId).HasSomeDeliveryIssuedCaseCreated__c = true;
                listSalesOrderToUpdate.add(mapsalesOrderTotalASPrice.get(soId));
            }
            else{
                listSalesOrderToUpdate.add(new PrerequisiteOrder__c(id = soId, HasSomeDeliveryIssuedCaseCreated__c = true));
            }
        }
        for(Id soId : mapsalesOrderTotalASPrice.keySet()){
            if(!setSalesOrderIdDeliveryCase.contains(soId)){
                listSalesOrderToUpdate.add(mapsalesOrderTotalASPrice.get(soId));
            }
        }

        
        if(listOffersToUpdate.size() > 0){
            ASPISWithoutSharingExceptions.updateOfferLineList(listOffersToUpdate);
        }
        
        if(mapOrderLinesToUpdate.size() > 0){
            ASPISWithoutSharingExceptions.updateOrderLineList(mapOrderLinesToUpdate.values());
        }
          
         // Generate the Credit Notes for the lines CANCELED or RETURNED
        if (salesOrderOffersMapAp17.size() > 0){
            AP17GenerateBSInvoiceAndCreditNote.createInvoiceCreditNote(salesOrderOffersMapAp17);
        }

        
        if(listSalesOrderToUpdate.size() > 0){
            //WCH 29/01/2021 C-004153
            //update listSalesOrderToUpdate;
            ASPISWithoutSharingExceptions.updatePrerequisiteOrderList(listSalesOrderToUpdate);
        }

        if(setOfferId.size() > 0){
            updateOrderedCounterPartListParent(setOfferId);
        }
        //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS
        if(restPostSalesOrderIdSet.size() > 0 && !System.isBatch() && !System.isFuture())
        {
            RESTPostSalesOrder.buildJSONAsync(restPostSalesOrderIdSet);
        }

        //AMI 29/10/2018  Case C-002045 - Advance case management
        //                                If BS update Offer to error again, add new chatter post if case openened, 
        //                                else create new case with chatter post
        //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
        if(setOrderlineId.size() > 0){
            updatePODiscussionCase(setOrderlineId,offToProcessed);
        }            
        system.debug('## setOrderlineId ' + setOrderlineId);
   
        System.debug('-------------------------- END METHOD OfferTriggerHandler - OnAfterUpdate --------------------------');
    }

    //methyod to calculate TotalASPrice on salesorder
    public static map<Id,Prerequisiteorder__c> calculateTotalASPrice(Map <Id,list<Offer__c>> mapSOIdOffer){
        map<Id,Prerequisiteorder__c> mapSalesOrder = new map<Id,Prerequisiteorder__c>();
        Double totalInvoice = 0;
        Double totalCreditNote = 0;

        for(Id offId : mapSOIdOffer.keyset()){
            Prerequisiteorder__c newSO = new Prerequisiteorder__c();
            newSO.Id = offId;
            totalInvoice = 0;
            totalCreditNote = 0;
            for(Offer__c off : mapSOIdOffer.get(offId)){
                if(off.Invoice__c != null){
                    totalInvoice += off.TotalASPrice__c;
                }
                if(off.CreditNote__c != null){
                    totalCreditNote += off.ASCreditNotePrice__c;
                }
            }
            newSO.TotalASPrice__c = totalInvoice - totalCreditNote;
            mapSalesOrder.put(offId,newSO);
        }
        
        return mapSalesOrder;
    }
    
    // ABT 13-APR-2016 - C-001592
    // Method to check the status of the sales order before checking the flag
    // Flag is check in case sales order status is in Delivery Confirmed or Invoiced or Paid
    public Map<Id, OrderLine__c> flagOrderLine(Set<Id> offerIds)
    {
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

    //method to set fdp offer to delivered -- case 1669 07/02/2017
    public void setFDPDelivered(set<Id> setSalesOrderId){
        List<Offer__c> listOfferToUpdate = new List<Offer__c>();
        map<Id,List<Offer__c>> mapPOIdOffersNotFDP = new map<Id,List<Offer__c>>();
        map<Id,Offer__c> mapPOIdFDPOffer = new map<Id,Offer__c>();
        Integer countDelievered = 0;

        for(Offer__c off:[select Id, DeliveryStatus__c, OrderLine__r.PurchaseOrder__c, PrerequisiteOrder__c, OrderType__c
                          from Offer__c 
                          where PrerequisiteOrder__c in: setSalesOrderId
                          and Accepted__c = 'Yes'
                          and Suppliable__c = true]){
            if(off.OrderType__c == 'SHIPPING COST'){
                if(!mapPOIdFDPOffer.containsKey(off.OrderLine__r.PurchaseOrder__c)){
                    mapPOIdFDPOffer.put(off.OrderLine__r.PurchaseOrder__c, off);
                }
            }
            else{
                if(mapPOIdOffersNotFDP.containsKey(off.OrderLine__r.PurchaseOrder__c)){
                    mapPOIdOffersNotFDP.get(off.OrderLine__r.PurchaseOrder__c).add(off);
                }
                else{
                    mapPOIdOffersNotFDP.put(off.OrderLine__r.PurchaseOrder__c, new list<Offer__c>{off});
                }
            }
        }
        system.debug('##mapPOIdOffersNotFDP'+mapPOIdOffersNotFDP);
        system.debug('##mapPOIdFDPOffer'+mapPOIdFDPOffer);

        for(Id poId:mapPOIdOffersNotFDP.keySet()){
            countDelievered = 0;
            for(Offer__c off:mapPOIdOffersNotFDP.get(poId)){
                if(off.DeliveryStatus__c == ASPISConstants.OFFER_STATUS_DELIVERED){
                    countDelievered ++;
                }
            }
            if(mapPOIdOffersNotFDP.get(poId).size() == countDelievered && mapPOIdFDPOffer.containsKey(poId)){
                listOfferToUpdate.add(new Offer__c(Id=mapPOIdFDPOffer.get(poId).Id, DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED));
            }
        }

        system.debug('##listOfferToUpdate'+listOfferToUpdate);
        if(listOfferToUpdate.size() > 0){
            update listOfferToUpdate;
        }
    }

    //DUN 02/05/2017 case 1914
    public void updateOrderedCounterPartListParent(set<Id> setOffId){
        system.debug('##setOffId'+setOffId);
        map<Id,PartList__c> mapPartListToUpdate = new map<Id,PartList__c>();

        for(Offer__c off : [select Id, Prerequisiteorder__c, Prerequisiteorder__r.Assessment__c, Prerequisiteorder__r.Assessment__r.ParentAssessment__c, 
                                   Prerequisiteorder__r.Assessment__r.RecordType.DeveloperName, OrderLine__r.PartList__r.OriginalPart__c, 
                                   OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c
                            from Offer__c 
                            where Id in: setOffId
                            and Prerequisiteorder__r.Assessment__r.ParentAssessment__c != null
                            and Prerequisiteorder__r.Assessment__r.RecordType.DeveloperName = 'ClaimOrder'
                            and OrderLine__r.PartList__r.OriginalPart__c != null]){
            if(!mapPartListToUpdate.containsKey(off.OrderLine__r.PartList__r.OriginalPart__c)){
                mapPartListToUpdate.put(off.OrderLine__r.PartList__r.OriginalPart__c, 
                                        new PartList__c(Id = off.OrderLine__r.PartList__r.OriginalPart__c ,
                                                        TECH_OrderedCounter__c = ((off.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c != null && off.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c != 0) ? off.OrderLine__r.PartList__r.OriginalPart__r.TECH_OrderedCounter__c - 1 : 0) 
                                                        )
                                        );
            }
            else{
                mapPartListToUpdate.get(off.OrderLine__r.PartList__r.OriginalPart__c).TECH_OrderedCounter__c = ((mapPartListToUpdate.get(off.OrderLine__r.PartList__r.OriginalPart__c).TECH_OrderedCounter__c != 0) ? mapPartListToUpdate.get(off.OrderLine__r.PartList__r.OriginalPart__c).TECH_OrderedCounter__c - 1 : 0);
            }
        }

        system.debug('##mapPartListToUpdate'+mapPartListToUpdate);
        if(mapPartListToUpdate.size() > 0){
            update mapPartListToUpdate.values();
        }
    }

    //AMI 29/10/2018  Case C-002045 - Advance case management
    //                                If BS update Offer to error again, add new chatter post if case openened, 
    //                                else create new case with chatter post
    //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S
    public void updatePODiscussionCase(set<Id> setOlId,set <Id> offToProcessed){
        ASPISWithoutSharingExceptions.updatePurchaseOrderDiscussionCase(setOlId,offToProcessed);
    }
}