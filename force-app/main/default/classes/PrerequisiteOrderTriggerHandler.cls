/*
----------------------------------------------------------------------
-- - Name          : PrerequisiteOrderTriggerHandler
-- - Author        : ABT
-- - Description   : Handler for the trigger PrerequisiteOrderTrigger
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 28-SEP-2016  ABT     1.0    Initial version
-- 21-JUL-2017  DUN     1.1    case 1669: Frais de port
----------------------------------------------------------------------
-- Flow of PrerequisiteOrderTriggerHandler:
--  Before Insert
--      - Copy Assessment Name to AssessmentName2__c
--      - Populate BodyShopContact__c using BodyShop.ContactUser__c
--
--  After Insert
--      - Share the assessment of the SO to the bodyshop
--      - Create a notification
--
--  Before Update
--      - If the SO Status is Invoiced -> Count the total price of delivered offer -- DEPRECATED
--      - if the bodyshop has changed and bodyshop is not null -> Share the assessment of the SO to the bodyshop
--      - if status has changed
--          -> Set the PreviousStatus__c with the previous status
--          -> if status is responed -> runSLAOnStatus_Responded
--          -> if status is indelievery -> runSLAOnStatus_DeliveryWithRulesEngine
--          -> if status is PREORDERCONFIRMED   -> runSLAOnStatus_DeliveryConfirmed
--                                              -> capture the SO and send it to AP16 to calculate TotalExpectedAmount__c
--
--          -> if status is INACCEPTANCE or RESPONDED -> Set RecordType InAcceptance
--          -> if status is PREORDERCLOSED or PREORDERCONFIRMED or INDELIVERY or DELIVERED -> Set RecordType InDelivery
--          -> if status is CANCELED -> Set RecordType Eliminated
--
--  After Update
--      - if Status is PREORDERCONFIRMED and previous status is not PREORDERCONFIRMED and TechIsInvoiced__c = false -> Capture Id to generate invoice
--      - if HasSomeDeliveryIssuedCaseCreated__c is true and has changed -> Create Case
--      - If status has changed
--          -> If status is CANCELED -> Cancel Assessment
--                                      -> if previous status was INACCEPTANCE -> If Offer's orderline is Suppliable -> Set offer to canceled
--                                      -> Create Canceled Case
--                                      -> Cancel PO
--
--          -> if status is RESPONDED -> if offer Accepted = 'YES' -> Update the orderline AcceptedCheck__c to true and also the Original OrderLine if exists
--                                      -> if offer Accepted = null -> Set offer Accepted to NO
--                                      -> if Number of accepted OrderLine for a PO is > 1 -> Set PO Status to ORDERED
--                                      -> if Number of accepted OrderLine for a PO is <= 1 -> Set PO Status to CANCELED
--
--      - If status has changed or TotalASPrice__c has changed -> Create notification
--      - if AP27SyncPOSOInternalComment is running for the 1st time and InternalComment__c has changed -> Capture the SO to update PO internal comment
--
----------------------------------------------------------------------
-- Previous Class History
----------------------------------------------------------------------
-- Developer    Date        Description
-- ----------   ----------  -----------------------
-- Joao Dias     02/04/2015  Original Version
-- Yudish R      28/04/2015  OnAfterInsert: share parent Account(BodyShop) & parent Assessment
--                           with respective BodyShop Group
-- Yudish R      18/05/2015  Remove codes (Change ApexSharing from Offering and Sourcing processes to Account creation)
-- Dourga U      11/06/2015  Added code to after update when Prerequisite Order is responded (When accepted = null)
-- Cecile L      15/06/2015  Globalize the creation of the Case in a separate class
-- Cecile L      17/06/2015  Add the update of the Assessment status to CANCELED in case the Sales Order is canceled.
-- Yudish R      02/07/2015  OnAfterInsert: logged event in notification obj
-- Dourga U      06/07/2015  Added code to after update when Prerequisite Order Status is INDELIVERY
-- Cecile L      15/07/2015  Automatically put the right record type depending on the status.
-- Dourga U      20/08/2015  Added code to create log in catch part
-- Cecile L      04/09/2015  Autopopulate 1 field (Assessment Name) from assessment on before insert.
-- Immo S        04/11/2015  Update field Sum_of_Total_Price_Net__c for PrerequisiteOrder__c.
-- Shamina M     10/02/2016  Case C-001479 sync field InternalComment__c between SO and PO
-- Dourga        11/02/2016  C-001522: Clarifications sur les rejets et annulations des commandes
-- Ashwina S     09/03/2016  Case C-001496 - Use the Reference Number in Public Group for sharing to BS and Dist
-- Dourga U      01/06/2016  C-001647: Automatic validation failed in Production (bulkify class)
-- Dourga U      01/06/2016  C-001653: Bulkify ASPISServicePrerequisiteOrder
-- Dourga U      08/03/2017  C-001821: Display the assessment after the quotation ask(trello no28)
-- Abdool M      11/07/2017  Set DE PO/SO to CLOSEDOK for Agency Mode
-- Abdool M      26/07/2017  Set status SO directly to closedko as there should be no invoice
-- Abdool M      06/07/2017  C-002027 : POSTSalesOrder / POSTAssessment Defects
-- Vaynee S      24/11/2017  C--002005 Delivery Note 
-- Abdool M      16/01/2018  Conditions for POSTSO were wrongly place in code so callout were not effected as and when required (only call Post assessment were made)
-- Dourga U      13/12/2017  C-001998 : Agency Mode
-- Vaynee S      18/12/2017  Ticket 10 Email DE R4 - Added condition for sending delivery note for R4 
-- Dourga U      11/01/2018  C-002135 : Agency Mode V2
-- Vaynee S      09/01/2018  Ticket 85 Emails Sent By Dev (BE
-- Dourga U      15/01/2018  C-002339 - Fill field EncodedId__c
-- Vaynee S      27/01/2018  C-002410 - Delivery Note should be sent to BS eligible on old process 
-- Vaynee S      04/06/2018  C-002214 - Invoices are not duplicate in some cases in Spain 
-- Dourga U      08/08/2018  C-001851 - Communication between Supplier vs B/S
-- Abdool M      16/10/2018  C-002045 - Advance case management - Update SO status to Managed if at least one offer is managed
--                                      and all other offers are in a final status
-- Abdool M      01/11/2018  C-002781 : Migrate Spain to R4
--                                    : New Distributor Notification Email Template for ES in R4
-- Abdool M      18/01/2019   C-003022: Changing access type from Creatable to Accessible
--                                    : Due to error whan an SO were cancelled by Dist from An OL
-- Welsa C       21/02/2019   C-003092 : Credit Note not created when distributor cancel OL
-- Welsa C       16/08/2019   C-003364 : Email sending to the BS
-- Welsa C       30/08/2019   C-003348 : Include spare part cancellation reason in SO Delivery Slip
-- Welsa C       22/10/2020   C-004015 - NOB - Assessment Sales Order Invoice Visibility Management
**********************************************************************
*/ 
public without sharing class PrerequisiteOrderTriggerHandler
{
    public PrerequisiteOrderTriggerHandler()
    {
    }

    public void onBeforeInsert(List<PrerequisiteOrder__c> newSalesOrderList)
    {
        System.debug('-------------------------- START METHOD PrerequisiteOrderTriggerHandler - onBeforeInsert --------------------------');

        // Set storing all the assessment ids that the newSalesOrderList contains
        Set<Id> assessmentIdSet                         = new Set<Id>();
        // List of sales order that need to have their BodyShopContact__c populated
        List<PrerequisiteOrder__c> ap24SalesOrderList   = new List<PrerequisiteOrder__c>();
        // Set of bodyshop account that needs to be retrieved in AP24
        Set<Id> ap24AccountIdSet                        = new Set<Id>();

        //WCH 22/10/2020 C-004015
        Map<Id,PrerequisiteOrder__c> mapAssessmentSOisVisibleByPrefikar   = new Map<Id,PrerequisiteOrder__c>();

        // Loop to capture all the information required from the sales orders
        for(PrerequisiteOrder__c newSalesOrder : newSalesOrderList)
        {
            // We need to collect all the assessment id of the Sales Order in order to retrive the names of those assessment
            assessmentIdSet.add(newSalesOrder.Assessment__c);

            // if the sales order bodyshop__c is not null, capture the bodyshop id
            if(newSalesOrder.BodyShop__c != null)
            {
                ap24SalesOrderList.add(newSalesOrder);
                ap24AccountIdSet.add(newSalesOrder.BodyShop__c);
            }
            //WCH 22/10/2020 C-004015
            if(newSalesOrder.TECH_BodyshopCountryCode__c == 'FR' && newSalesOrder.Assessment__c!=null){
                mapAssessmentSOisVisibleByPrefikar.put(newSalesOrder.Assessment__c,newSalesOrder);
            }
        }

        // Retrieving all the assessment that the sales order are refering to
        Map<Id, Assessment__c> mapAssessment = new Map<Id, Assessment__c>([ SELECT  Id, Name
                                                                            FROM    Assessment__c
                                                                            WHERE   Id IN: assessmentIdSet]);

        // Loop in the new sales order to make changes to them
        for(PrerequisiteOrder__c newSalesOrder : newSalesOrderList)
        {
            if(mapAssessment.containsKey(newSalesOrder.Assessment__c))
            {
                Assessment__c currentAssessment     = mapAssessment.get(newSalesOrder.Assessment__c);

                // Copying the assessment name to the field AssessmentName2__c
                newSalesOrder.AssessmentName2__c    = currentAssessment.Name;
            }
        }

        // Check if the size of the ap24SalesOrderList is greater than 0 to run the class
        if(ap24SalesOrderList.size() > 0)
        {
            AP24SOPopulateBodyShopUser.populateBodyShopContact(ap24SalesOrderList, ap24AccountIdSet);
        }
        //WCH 22/10/2020 C-004015
        if(mapAssessmentSOisVisibleByPrefikar.size() > 0){
            setVisibleByPrefikar(mapAssessmentSOisVisibleByPrefikar);
        }

        System.debug('-------------------------- END METHOD PrerequisiteOrderTriggerHandler - onBeforeInsert --------------------------');
    }

    public void onAfterInsert(List<PrerequisiteOrder__c> newSalesOrderList)
    {
        System.debug('-------------------------- START METHOD PrerequisiteOrderTriggerHandler - onAfterInsert --------------------------');

        // Set of String storing all the reference number of the bodyshops
        Set<String> bodyshopRefNumberSet                    = new Set<String>();
        // List of assessment sharing rules that needs to be created
        List<Assessment__Share> assessmentSharingRulesList  = new List<Assessment__Share>();
        // List of notifications that needs to be created
        List<Notification__c> notificationList              = new List<Notification__c>();
        // ABT - 26-APR-2017 - C-001827
        // Set of assessment ids that need to be sent to ICE
        Set<Id> assessmentIdSetToSend                       = new Set<Id>();
        Set<String> igEntitySet                             = String.isBlank(Label.ASFRIGEntity) ? new Set<String>() : new Set<String>(Label.ASFRIGEntity.split(';'));
        //VSU 22/11/17 Case C-002005
        Map <String,String> mapSOIdSOName = new Map <String,String> ();
        list <Prerequisiteorder__c> listSOBsToUpdate = new list <Prerequisiteorder__c>();

        //DUN 15/03/2018 C-002339 - Fill field EncodedId__c
        list<Prerequisiteorder__c> listSOEncodedIdToUpdate = new list<Prerequisiteorder__c>();

        // Loop in the newSalesOrderList to retrieve all the information required
        for(PrerequisiteOrder__c newSalesOrder : newSalesOrderList)
        {
            mapSOIdSOName.put(newSalesOrder.id,newSalesOrder.Name);
            bodyshopRefNumberSet.add(newSalesOrder.TECH_BodyshopReferenceNumber__c);
        }

        // Map of Group Name -> Group Id
        Map<String, Id> mapGroupNameId = new Map<String, Id>();

        // Retrieving the groups of the bodyshops
        for(Group currentGroup : [  SELECT  Id, Name
                                    FROM    Group
                                    WHERE   Name IN: bodyshopRefNumberSet])
        {
            mapGroupNameId.put(currentGroup.Name, currentGroup.Id);
        }

        // String containing the profile name of the user
        String currentUserProfileName = getCurrentUserProfileName();

        // Loop in the new sales orders to create sharing rules
        for(PrerequisiteOrder__c newSalesOrder : newSalesOrderList)
        {
            // Check if the group of the bodyshop exists and also if the sales order has an assessment
            if(mapGroupNameId.containsKey(newSalesOrder.TECH_BodyshopReferenceNumber__c) &&
                newSalesOrder.Assessment__c != null)
            {
                // Adding a new sharing rule to the assessment
                assessmentSharingRulesList.add(new Assessment__Share(   UserOrGroupId   = mapGroupNameId.get(newSalesOrder.TECH_BodyshopReferenceNumber__c),
                                                                        ParentId        = newSalesOrder.Assessment__c,
                                                                        AccessLevel     = 'Read'));
            }

            // Creates notification only if the profile name is not ASPIS Interface
            if(currentUserProfileName != 'ASPIS Interface')
            {
                notificationList.add(new Notification__c(   Action__c               = 'CREATE',
                                                            ObjectReferenceId__c    = newSalesOrder.Id,
                                                            Object_Status__c        = newSalesOrder.Status__c,
                                                            AssessmentReference__c  = newSalesOrder.Assessment__c,
                                                            AssessmentStatus__c     = newSalesOrder.TECH_AssessmentStatus__c,
                                                            UserType__c             = (currentUserProfileName == 'Distributor') ? 'DISTRIBUTOR' : 'ADMIN',
                                                            BodyShopReference__c    = newSalesOrder.TECH_BodyshopReferenceNumber__c
                                                            ));
            }

            // ABT - 26-APR-2017 - C-001827
            // checking if the EntityRules of the Assessment Attached is FR299 and FR392
            // the other conditions are in the class RESTPostAssessment
            if( newSalesOrder.Assessment__c != null &&
                newSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE &&
                igEntitySet.contains(newSalesOrder.TECH_AssessmentEntityRules__c))
            {
               assessmentIdSetToSend.add(newSalesOrder.Assessment__c);
            }

            //DUN 15/03/2018 C-002339 - Fill field EncodedId__c
            listSOEncodedIdToUpdate.add(new PrerequisiteOrder__c(Id = newSalesOrder.Id,
                                                                EncodedId__c = encryptBase64(newSalesOrder.Id)));
        }

        //DUN 15/03/2018 C-002339 - Fill field EncodedId__c
        if(listSOEncodedIdToUpdate.size() > 0)
        {
            update listSOEncodedIdToUpdate;
        }

        // checks if the assessmentSharingRulesList size is > 0
        if(assessmentSharingRulesList.size() > 0)
        {
            // ABT 25-NOV-2016 - C-001497
            // insert assessmentSharingRulesList;
        }

        // checks if the notificationList size is > 0
        if(notificationList.size() > 0)
        {
            insert notificationList;
        }

        // ABT - 16-FEB-2017 - C-001827
        if(assessmentIdSetToSend.size() > 0 && !System.isBatch() && !System.isFuture())
        {
            RESTPostAssessment.buildJSONAsync(assessmentIdSetToSend);
        }

       //VSU 22/11/17 Case C-002005
        for(Prerequisiteorder__c so: [select id,bodyshopOrderNumber__c from PrerequisiteOrder__c where id IN: mapSOIdSOName.keyset()]){
            if(so.bodyshopOrderNumber__c == null){
                so.bodyshopOrderNumber__c=mapSOIdSOName.get(so.id);
                listSOBsToUpdate.add(so);
            }                  
        }
        //VSU 22/11/17 Case C-002005
        system.debug('##listSOBsToUpdate: '+listSOBsToUpdate);
        if(listSOBsToUpdate.size() > 0){
            update listSOBsToUpdate;
        }

        System.debug('-------------------------- END METHOD PrerequisiteOrderTriggerHandler - onAfterInsert --------------------------');
    }

    public void onBeforeUpdate(List<PrerequisiteOrder__c> newSalesOrderList, List<PrerequisiteOrder__c> oldSalesOrderList, Map<Id, PrerequisiteOrder__c> mapOldSalesOrder)
    {
        System.debug('-------------------------- START METHOD PrerequisiteOrderTriggerHandler - onBeforeUpdate --------------------------');

        // List of sales order that needs to have their BodyShopContact__c changed
        List<PrerequisiteOrder__c> ap24SalesOrderList   = new List<PrerequisiteOrder__c>();
        // Set of bodyshop account that needs to be retrieved in AP24
        Set<Id> ap24AccountIdSet                        = new Set<Id>();
        // List of sales order that needs to have their total expected amount to be calculated
        List<PrerequisiteOrder__c> ap16SalesOrderList   = new List<PrerequisiteOrder__c>();

        // Loop in the new sales order
        for(Integer i = 0; i < newSalesOrderList.size(); i++)
        {
            // Check if the bodyshop has changed and the new value is not null
            if( newSalesOrderList[i].BodyShop__c != oldSalesOrderList[i].BodyShop__c &&
                newSalesOrderList[i].BodyShop__c != null)
            {
                ap24SalesOrderList.add(newSalesOrderList[i]);
                ap24AccountIdSet.add(newSalesOrderList[i].BodyShop__c);
            }

            // check if there is a change in the status
            if(newSalesOrderList[i].Status__c != oldSalesOrderList[i].Status__c)
            {
                // Copy the old status of the sales order into the field PreviousStatus__c
                if( newSalesOrderList[i].Status__c != ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE &&
                    newSalesOrderList[i].Status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO &&
                    oldSalesOrderList[i].Status__c != ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE &&
                    oldSalesOrderList[i].Status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO &&
                    oldSalesOrderList[i].Status__c != ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK)
                {
                    newSalesOrderList[i].PreviousStatus__c = oldSalesOrderList[i].Status__c;
                }

                // Check if the new status is INACCEPTANCE or RESPONED
                if( newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_RESPONDED)
                {
                    newSalesOrderList[i].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PREREQUISITEORDER_RT_Name_InAcceptance).getRecordTypeId();
                }
                // Check if the new status is INDELIVERY or DELIVERED or PREORDERCONFIRMED
                else if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INDELIVERY ||
                        newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_DELIVERED ||
                        newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED ||
                        newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK ||
                        newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE ||
                        newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO)
                {
                    newSalesOrderList[i].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PREREQUISITEORDER_RT_Name_InDelivery).getRecordTypeId();
                }
                // Check if the new status is CANCELED
                else if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELED)
                {
                    newSalesOrderList[i].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PREREQUISITEORDER_RT_Name_Eliminated).getRecordTypeId();
                }

                // Check if status is in responded
                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_RESPONDED)
                {
                    // Populate the field SLARespondedEntryDate__c on the SO
                    AP07SalesOrderSLA.runSLAOnStatus_Responded(newSalesOrderList[i]);
                }

                // Check if status is INDELIVERY
                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
                {
                    // Populate the field SLAInDeliveryEntryDate__c and other field specified by master rule on the SO
                    AP07SalesOrderSLA.runSLAOnStatus_DeliveryWithRulesEngine(newSalesOrderList[i]);
                }

                // Check if status is in PREORDERCONFIRMED
                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
                {
                    // Populate the field SLADeliveryConfirmedEntryDate__c on the SO and also clear the SLAInDeliveryLevels
                    AP07SalesOrderSLA.runSLAOnStatus_DeliveryConfirmed(newSalesOrderList[i]);

                    // Add the sales order to the list ap16SalesOrderList so that its total expected amount is calculated
                    ap16SalesOrderList.add(newSalesOrderList[i]);
                }
                //DUN 02/06/2017 trello no215 Date and time when SO status is indelivery
                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INDELIVERY){
                    newSalesOrderList[i].customBI1__c = System.now();
                }
            }
        }

        // Calling the AP24 class to populate the bodyshop contact in case there is a changed in the bodyshop__c
        if(ap24SalesOrderList.size() > 0)
        {
            AP24SOPopulateBodyShopUser.populateBodyShopContact(ap24SalesOrderList, ap24AccountIdSet);
        }

        // Calling the function to update the total expected amount on the sales orders
        if(ap16SalesOrderList.size() > 0)
        {
            AP16CalcTotalExpAmtSalesOrder.updateSalesOrder(ap16SalesOrderList);
        }

        System.debug('-------------------------- END METHOD PrerequisiteOrderTriggerHandler - onBeforeUpdate --------------------------');
    }

    public void onAfterUpdate(List<PrerequisiteOrder__c> newSalesOrderList, List<PrerequisiteOrder__c> oldSalesOrderList, Map<Id, PrerequisiteOrder__c> mapOldSalesOrder)
    {
        System.debug('-------------------------- START METHOD PrerequisiteOrderTriggerHandler - onAfterUpdate --------------------------');

        // Map containing Sales Orders that need to have invoice generaated
        Map<Id, PrerequisiteOrder__c> mapSalesOrderToGenerateInvoice    = new Map<Id, PrerequisiteOrder__c>();
        // List of cases that needs to be created in the trigger
        List<Case__c> casesToInsertList                                 = new List<Case__c>();
        // Map containing Assessment that needs to be updated. Used when SO is canceled or INDELIVERY (Cannot be canceled or set to indelivery at same time)
        Map<Id, Assessment__c> mapAssessmentToUpdate                    = new Map<Id, Assessment__c>();
        // Set of sales order whose purchase order needs to be canceled
        Set<Id> salesOrderIdToCancelPOSet                               = new Set<Id>();
        // Set of sales order whose previous status was INACCEPTANCE
        Set<Id> canceledInAcceptanceSalesOrderSet                       = new Set<Id>();
        // Set of sales order whose status is RESPONDED
        Set<Id> respondedSalesOrderSet                                  = new Set<Id>();
        // List of sales order that needs to have their purchase order internal comment sync
        // List<PrerequisiteOrder__c> ap27SalesOrderList                   = new List<PrerequisiteOrder__c>();
        // String containing the profile name of the user
        String currentUserProfileName                                   = getCurrentUserProfileName();
        // List of notifications that needs to be created
        List<Notification__c> notificationList                          = new List<Notification__c>();
        // Map containing offer that needs to be updated
        Map<Id, Offer__c> mapOffersToUpdate                             = new Map<Id, Offer__c>();
        // Map containing order lines that needs to be updated
        Map<Id, OrderLine__c> mapOrderLineToUpdate                      = new Map<Id, OrderLine__c>();
        // Map containing Sales Orders that need to have invoice generaated
        Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdate              = new Map<Id, PurchaseOrder__c>();
        // List of sales order that needs to have their status set to canceledinvoice
        List<PrerequisiteOrder__c> canceledInvoiceSalesOrderList        = new List<PrerequisiteOrder__c>();

        //AMI 26/07/17 : set status SO directly to closedko as there should be no invoice
        List<PrerequisiteOrder__c> closedKOSOList = new List<PrerequisiteOrder__c>();

        // List of sales order that has been updated to paid and needs its status to be updated
        List<PrerequisiteOrder__c> paidSalesOrderToUpdateList           = new List<PrerequisiteOrder__c>();
        // Set of assessment id to check if the assessment status needs to be updated
        Set<Id> assessmentIdSet                                         = new Set<Id>();
        // ABT - 16-FEB-2017 - C-001827
        // Set of sales order ids that need to be sent to ICE
        Set<Id> salesOrderIdSetToSend                                   = new Set<Id>();
        Set<String> igEntitySet                                         = String.isBlank(Label.ASFRIGEntity) ? new Set<String>() : new Set<String>(Label.ASFRIGEntity.split(';'));
        // ABT - 01-MAR-2017
        // Set of sales order Id that needs to have their delivery note send by mail
        Set<Id> salesOrderIdToSendDeliveryNote                          = new Set<Id>();
        Set<Id> postAssesssmentIdSet    = new Set<Id>();
        // vsu commented for C-002410
        // Set <Id> salesOrderIdDE = new Set <Id> ();

        //AMI 11/07/2017 - Set DE SO to CLOSEDOK/CLOSEDKO for Agency Mode
        Set<Id> ap39SODeliveredConfirmedSet = new Set<Id>();

        //DUN 25/08/2017 - set shipping line to delivered
        Set<Id> ap30SODeliveredSet = new Set<Id>();

        // DUN 21-JUL-2017 case 1669 Added code to create shipping cost line
        Set<Id> ap30SetSOID = new Set<Id>();

        //AMI  11/10/2018  : Case C-002045 - Advance case management - 
        //                 : Update SO status to Managed if at least one offer is managed
        //                 : and all other offers are in a final status
        //                 : this set will hold all SO to update
        set <id> setSOToUpdate = new set <id>();

        //RLA 01/09/2020 C-003877 : IG Close PO SO Claim Order
        map<String, Object> mapOrderConfirmation = new map<String,Object>();

        // Loop in the new sales order
        for(Integer i = 0; i < newSalesOrderList.size(); i++)
        {
            // check if there is a change in the status
            if(newSalesOrderList[i].Status__c != oldSalesOrderList[i].Status__c)
            {

                System.debug('## The sales order status was: ' + oldSalesOrderList[i].Status__c + ' -New- ' + newSalesOrderList[i].Status__c);
                
                // Check if the old status of the sales order was not PREORDERCONFIRMED and the new status is PREORDERCONFIRMED and has not already been invoiced
                if( oldSalesOrderList[i].Status__c != ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED &&
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED &&
                    newSalesOrderList[i].TechIsInvoiced__c == false)
                {
                    mapSalesOrderToGenerateInvoice.put(newSalesOrderList[i].Id, newSalesOrderList[i]);
                }

                // Check if the sales order has been canceled
                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELED)
                {
                    // checks if assessment is not null
                    if(newSalesOrderList[i].Assessment__c != null)
                    {
                        // Cancel the Assessment
                        mapAssessmentToUpdate.put(newSalesOrderList[i].Assessment__c, new Assessment__c(Id                  = newSalesOrderList[i].Assessment__c,
                                                                                                        Status__c           = ASPISConstants.ASSESS_STATUS_CANCELED,
                                                                                                        ReasonFailure__c    = ASPISConstants.ASSESS_REASONFAILURE_CANCELEDBYBODYSHOP));
                    }

                    // Check if the previous status of the sales order was INACCEPTANCE
                    // Cancel all the offers that were Suppliable__c == 'YES
                    if(oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
                    {
                        // Capturing the Id of the sales order that is canceled and had Status as INACCEPTANCE before
                        canceledInAcceptanceSalesOrderSet.add(newSalesOrderList[i].Id);
                    }

                    // Needs to cancel the purchase orders of the sales order also
                    salesOrderIdToCancelPOSet.add(newSalesOrderList[i].Id);

                    //AMI 26/07/17 : set status SO directly to closedko as there should be no invoice
                    if( oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INDELIVERY ||
                        oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_DELIVERED){
                         closedKOSOList.add(new PrerequisiteOrder__c( Id = newSalesOrderList[i].Id,
                                                                      Status__c   = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO));
                    }

                    // check if the sales order was canceled from delivered confirmed
                    // When a sales order passes delivered confirmed, it has invoices
                    if( oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED ||
                        oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INVOICED ||
                        oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK)
                    {
                        System.debug('@@ got in oldSalesOrderList[i].Status__c: ' + oldSalesOrderList[i].Status__c);
                        System.debug('@@ changed: ' + oldSalesOrderList[i].Status__c == newSalesOrderList[i].Status__c);
                        // therefore the sales order should be set to canceled invoice
                        canceledInvoiceSalesOrderList.add(new PrerequisiteOrder__c( Id          = newSalesOrderList[i].Id,
                                                                                    Status__c   = ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE));
                    }

                    // Generate the case for the canceled sales order
                    Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-SO', newSalesOrderList[i].TECH_BodyshopCountryCode__c, newSalesOrderList[i].BodyShop__c, newSalesOrderList[i].Assessment__c, null, newSalesOrderList[i].Id, null, UserInfo.getUserId(), '-Canceled');

                    // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                    if(newCase != null)
                    {
                        casesToInsertList.add(newCase);
                    }
                }

                // ABT - 26-FEB-2017
                // check if the sales order is being updated to In Acceptance
                if( newSalesOrderList[i].Assessment__c != null &&
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE &&
                    igEntitySet.contains(newSalesOrderList[i].TECH_AssessmentEntityRules__c))
                {
                    postAssesssmentIdSet.add(newSalesOrderList[i].Assessment__c);
                }

                // Check if the sales order has been responded
                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_RESPONDED)
                {
                    // Capture the id of the sales order that is in the status responded
                    respondedSalesOrderSet.add(newSalesOrderList[i].Id);
                }

                // Check if the sales order new status is INDELIVERY and its Assessment__c is not null
                if( newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INDELIVERY &&
                    newSalesOrderList[i].Assessment__c != null)
                {
                    // Change the Assessment status to INDELIVERY
                    mapAssessmentToUpdate.put(newSalesOrderList[i].Assessment__c, new Assessment__c(Id          = newSalesOrderList[i].Assessment__c,
                                                                                                    Status__c   = ASPISConstants.ASSESS_STATUS_INDELIVERY));

                    // DUN 21-JUL-2017 case 1669 Added code to create shipping cost line
                    ap30SetSOID.add(newSalesOrderList[i].Id);

                    // ABT - 01-MAR-2017
                    // Checking if the TECH_EntityCountryCode is FR or IT
                    //AMI 01/11/2018  C-002781 : Migrate Spain to R4
                    //                         : New Distributor Notification Email Template for ES in R4
                    if(newSalesOrderList[i].TECH_BodyshopCountryCode__c == 'FR' || 
                        newSalesOrderList[i].TECH_BodyshopCountryCode__c == 'IT' || 
                        newSalesOrderList[i].TECH_BodyshopCountryCode__c == 'BE' ||//VSU 09/01/18
                        newSalesOrderList[i].TECH_BodyshopCountryCode__c == 'DE' ||
                        (newSalesOrderList[i].TECH_BodyshopCountryCode__c == 'ES' && 
                        newSalesOrderList[i].Tech_BSCommunityPopulationType__c == 'R4')) //VSU 26/03/18 C-002410 - Delivery Note should be sent to BS eligible on old process
                    {
                        salesOrderIdToSendDeliveryNote.add(newSalesOrderList[i].Id);
                    }
                    //VSU 26/03/18 Commented for C-002410
                   /* if(newSalesOrderList[i].TECH_BodyshopCountryCode__c == 'DE'){ 
                        salesOrderIdDE.add(newSalesOrderList[i].Id);
                    } */

                    //RLA 18/06/2020 C-003700: IG - orderConfirmation
                    if(newSalesOrderList[i].TECH_BodyshopCountryCode__c == 'DE'
                        // && !newPurchaseOrderList[i].AutoValidate_PO__c //RLA 21/08/2020 C-003882 IG - Order Quality Check outside ASPIS 
                    )
                    {
                        // setPOIdsOrderConfirmation.add(newPurchaseOrderList[i].Id);
                        // setPONamesOrderConfirmation.add(newPurchaseOrderList[i].Name);
                        mapOrderConfirmation.put('assessId',newSalesOrderList[i].Assessment__c);

                    }

                }

                //AMI 16/01/18 : Conditions were wrongly place in code so callout were not effected as and when required (only call Post assessment were made)
                //AMI 06/10/17 : C-002027 (call postSO after each status change : INDELIVERY, DELIVERED, PREORDERCONFIRMED, CANCELED, INVOICED)
                if( (newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INDELIVERY ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_DELIVERED ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELED ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INVOICED) &&
                    newSalesOrderList[i].Assessment__c != null &&
                    igEntitySet.contains(newSalesOrderList[i].TECH_AssessmentEntityRules__c)){
                        salesOrderIdSetToSend.add(newSalesOrderList[i].Id);
                }
                system.debug('## salesOrderIdSetToSend ' + salesOrderIdSetToSend);

                // check if the new status of the sales order is PAID (set by AP14 when the invoices are set to PAID)
                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PAID)
                {
                    // therefore the Status__c of the sales order should be updated to CLOSEDOK or CLOSEDKO
                    // check if the old Status__c of the purchase order is CANCELED Invoice__c
                    if( oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE ||
                        oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO)
                    {
                        // set the sales order to CLOSEDKO
                        paidSalesOrderToUpdateList.add(new PrerequisiteOrder__c(Id          = newSalesOrderList[i].Id,
                                                                                Status__c   = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO));
                    }
                    else if(oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INVOICED ||
                            oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK ||
                            oldSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
                    {
                        // the sales order was not canceled, its status should be updated to CLOSEDOK
                        paidSalesOrderToUpdateList.add(new PrerequisiteOrder__c(Id          = newSalesOrderList[i].Id,
                                                                                Status__c   = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK));
                    }
                }

                if( (newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_INVOICED)
                    // C-002002 : assessments status is processed in batch except for those SO not having any invoice , or countryCode =ES                    
                    //&& newSalesOrderList[i].TECH_BodyshopCountryCode__c =='ES' && !newSalesOrderList[i].TechProcessedByBatchInvoice__c
                    )
                {
                    system.debug('##newSalesOrderList[i].id: '+newSalesOrderList[i].id);
                    assessmentIdSet.add(newSalesOrderList[i].Assessment__c);
                }

                //DUN 08/03/2017 case 1821
                if(!mapAssessmentToUpdate.containsKey(newSalesOrderList[i].Assessment__c)){
                    mapAssessmentToUpdate.put(newSalesOrderList[i].Assessment__c, new Assessment__c(Id               = newSalesOrderList[i].Assessment__c,
                                                                                                    OrderStatus__c   = newSalesOrderList[i].Status__c));
                }
                else{
                    mapAssessmentToUpdate.get(newSalesOrderList[i].Assessment__c).OrderStatus__c   = newSalesOrderList[i].Status__c;
                }

                //AMI 11/07/2017 - populate ap39SODeliveredConfirmedSet
                // ABT - When there is a change in status and the status is PREORDERCONFIRMED and it is an agency mode and it is DE
                // DUN 13/12/2017 case 1998 Modify condition, removed CountryCode 
                // DUN 11/01/2018  C-002135 agency Mode V2 removed field from agency mode as it is now on PO
                if( (newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED ||
                    newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE) /*&&
                    newSalesOrderList[i].AgencyMode__c == true*/)
                {
                    system.debug('##ap39 sotrigger'+ newSalesOrderList[i].Status__c);
                    ap39SODeliveredConfirmedSet.add(newSalesOrderList[i].Id); 
                } 
                system.debug('££newSalesOrderList[i].Status__c: '+newSalesOrderList[i].Status__c);

                if(newSalesOrderList[i].Status__c == ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED){
                    ap30SODeliveredSet.add(newSalesOrderList[i].Id); 
                }

            }

            // check if there is a change in the field HasSomeDeliveryIssuedCaseCreated__c and the new value of HasSomeDeliveryIssuedCaseCreated__c is true
            if( newSalesOrderList[i].HasSomeDeliveryIssuedCaseCreated__c != oldSalesOrderList[i].HasSomeDeliveryIssuedCaseCreated__c &&
                newSalesOrderList[i].HasSomeDeliveryIssuedCaseCreated__c == true)
            {
                // Generate the case that will report a delivery issue on that sales order
                //DUN 08/08/2018  C-001851 - Communication between Supplier vs B/S Added AdvancedCaseManagement check 
                if(CountryCodeInformationsMapping__c.getall().get(newSalesOrderList[i].TECH_BodyshopCountryCode__c) == null || 
                  (CountryCodeInformationsMapping__c.getall().get(newSalesOrderList[i].TECH_BodyshopCountryCode__c) != null &&
                   !CountryCodeInformationsMapping__c.getall().get(newSalesOrderList[i].TECH_BodyshopCountryCode__c).AdvancedCaseManagement__c)){
                    //Create for each PO - > need to query Offer.OL.PO.User
                    Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-SO', newSalesOrderList[i].TECH_BodyshopCountryCode__c, newSalesOrderList[i].BodyShop__c, newSalesOrderList[i].Assessment__c, null, newSalesOrderList[i].Id, null, UserInfo.getUserId(), '-DeliveryProblem');

                    // Checks if the case generated by the Utils_ManageCaseCustom is not null as it can be null in case a custiom stetting is inactive
                    if(newCase != null)
                    {
                        casesToInsertList.add(newCase);
                    }
                }
            }

            // check if there is a change in the internal comment
            // if(newSalesOrderList[i].InternalComment__c != oldSalesOrderList[i].InternalComment__c)
            // {
            //     // add the sales order in the list to be used by the class AP24
            //     ap27SalesOrderList.add(newSalesOrderList[i]);
            // }

            // Create a notification in case there is a change in the sales order status or TotalASPrice__c
            if( newSalesOrderList[i].Status__c != oldSalesOrderList[i].Status__c ||
                newSalesOrderList[i].TotalASPrice__c != oldSalesOrderList[i].TotalASPrice__c)
            {
                if(currentUserProfileName != 'ASPIS Interface')
                {
                    notificationList.add(new Notification__c(   Action__c               = 'UPDATE',
                                                                ObjectReferenceId__c    = newSalesOrderList[i].Id,
                                                                Object_Status__c        = newSalesOrderList[i].Status__c,
                                                                AssessmentReference__c  = newSalesOrderList[i].Assessment__c,
                                                                AssessmentStatus__c     = newSalesOrderList[i].TECH_AssessmentStatus__c,
                                                                UserType__c             = (currentUserProfileName == 'Distributor') ? 'DISTRIBUTOR' : 'ADMIN',
                                                                BodyShopReference__c    = newSalesOrderList[i].TECH_BodyshopReferenceNumber__c,
                                                                ObjectImpacted__c       = 'Sales Order'
                                                            ));
                }
            }


            //AMI  11/10/2018  : Case C-002045 - Advance case management 
            //                 : on each SO status change, check if the latter should be updated to Managed or back to indelivery or 
            //                 : partially delivered
            if(newSalesOrderList[i].DeliveredLines__c != oldSalesOrderList[i].DeliveredLines__c ||
                newSalesOrderList[i].NumberCanceledLines__c != oldSalesOrderList[i].NumberCanceledLines__c ||
                newSalesOrderList[i].ManagedLines__c != oldSalesOrderList[i].ManagedLines__c){
                    setSOToUpdate.add(newSalesOrderList[i].Id);
            }
        }

        // Applying logics for canceled and responded sales order
        Set<Id> allSalesOrderIdToQuerySet = new Set<Id>();
        allSalesOrderIdToQuerySet.addAll(canceledInAcceptanceSalesOrderSet);
        allSalesOrderIdToQuerySet.addAll(respondedSalesOrderSet);

        if(allSalesOrderIdToQuerySet.size() > 0)
        {
            for(Offer__c currentOffer : [SELECT Id, Accepted__c, DeliveryStatus__c, CancelReason__c,
                                                OrderLine__c, OrderLine__r.OriginalItem__c, OrderLine__r.Suppliable__c, OrderLine__r.PurchaseOrder__c, OrderLine__r.PurchaseOrder__r.AcceptedLines__c,
                                                OrderLine__r.PreselectedForOrder__c,
                                                Prerequisiteorder__c, Prerequisiteorder__r.Status__c
                                                , OrderLine__r.CancelReason__c//WCH 30/08/2019 C-003348
                                         FROM   Offer__c
                                         WHERE  Prerequisiteorder__c IN : allSalesOrderIdToQuerySet])
            {
                // check if the sales order was canceled with previous status INACCEPTANCE using the set canceledInAcceptanceSalesOrderSet
                // and also if its orderline is accepted = 'YES'
                if( canceledInAcceptanceSalesOrderSet.contains(currentOffer.Prerequisiteorder__c) &&
                    currentOffer.OrderLine__c != null &&
                    currentOffer.OrderLine__r.Suppliable__c == 'YES')
                {
                    // change the offer delivery status to Canceled
                    mapOffersToUpdate.put(currentOffer.Id, new Offer__c(Id                  = currentOffer.Id,
                                                                        Accepted__c         = 'NO',
                                                                        DeliveryStatus__c   = ASPISConstants.OFFER_STATUS_CANCELED));
                }

                // check if the offer is an offer of a responded sales order
                if(respondedSalesOrderSet.contains(currentOffer.Prerequisiteorder__c))
                {
                    // check if the current offer has been accepted or not
                    if(currentOffer.Accepted__c == 'YES')
                    {
                        if(currentOffer.OrderLine__c != null && !currentOffer.OrderLine__r.PreselectedForOrder__c)
                        {
                            // update the field AcceptedCheck__c on the order line of the offer
                            mapOrderLineToUpdate.put(currentOffer.OrderLine__c, new OrderLine__c(Id                 = currentOffer.OrderLine__c,
                                                                                                 AcceptedCheck__c   = true));

                            // Also update the original item of the order line if exists
                            if(currentOffer.OrderLine__r.OriginalItem__c != null)
                            {
                                mapOrderLineToUpdate.put(currentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                 = currentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                     AcceptedCheck__c   = true));
                            }
                        }
                    }
                    // check if the accepted is null and set it to no
                    else if(currentOffer.Accepted__c == null)
                    {
                        mapOffersToUpdate.put(currentOffer.Id, new Offer__c(Id          = currentOffer.Id,
                                                                            Accepted__c = 'NO'));
                    }
                    // ABT - 21-FEB-2017 - C-001816 - Copying Cancel Reason of offer to order line
                    else if(currentOffer.Accepted__c == 'NO')
                    {
                        if(currentOffer.OrderLine__c != null)
                        {
                            // update the field AcceptedCheck__c on the order line of the offer
                            mapOrderLineToUpdate.put(currentOffer.OrderLine__c, new OrderLine__c(Id                 = currentOffer.OrderLine__c,
                                                                                                 AcceptedCheck__c   = false,
                                                                                                 //WCH 30/08/2019 C-003348
                                                                                                 CancelReason__c    = (String.isBlank(currentOffer.OrderLine__r.CancelReason__c) ? currentOffer.CancelReason__c : currentOffer.OrderLine__r.CancelReason__c)));

                            // Also update the original item of the order line if exists
                            if(currentOffer.OrderLine__r.OriginalItem__c != null)
                            {
                                mapOrderLineToUpdate.put(currentOffer.OrderLine__r.OriginalItem__c, new OrderLine__c(Id                 = currentOffer.OrderLine__r.OriginalItem__c,
                                                                                                                     AcceptedCheck__c   = false,
                                                                                                                     //WCH 30/08/2019 C-003348
                                                                                                                     CancelReason__c    = (String.isBlank(currentOffer.OrderLine__r.CancelReason__c) ?currentOffer.CancelReason__c : currentOffer.OrderLine__r.CancelReason__c)));
                            }
                        }
                    }
                }
            }
        }
       /* if(listSOInCanceledInvoice.size() > 0){
            system.debug('££ listSOInCanceledInvoice');
            setSOToDeliveredConfirmed(listSOInCanceledInvoice,ap39SODeliveredConfirmedSet);//VSU 01/06/18
        }*/

        if(ap30SODeliveredSet.size() > 0){
            AP30ShippingLineCreation.updateDeliveredShippingLine(ap30SODeliveredSet);
        }

        // Commiting the changes
        if(mapSalesOrderToGenerateInvoice.size() > 0)
        {
            ASPISServiceBodyShopGenerateInvoice generateInvoice = new ASPISServiceBodyShopGenerateInvoice();
            generateInvoice.executeProcess(mapSalesOrderToGenerateInvoice);
        }

        if(mapOffersToUpdate.size() > 0)
        {
            update mapOffersToUpdate.values();
        }


        if(mapOrderLineToUpdate.size() > 0)
        {
            update mapOrderLineToUpdate.values();
        }

        Set<Id> allPurchaseToQuerySet = new Set<Id>();
        allPurchaseToQuerySet.addAll(salesOrderIdToCancelPOSet);
        allPurchaseToQuerySet.addAll(respondedSalesOrderSet);

        system.debug('##respondedSalesOrderSet: '+ respondedSalesOrderSet);


        if(allPurchaseToQuerySet.size() > 0)
        {
            for(PurchaseOrder__c currentPurchaseOrder : [SELECT Id, AcceptedLines__c, PrerequisiteOrder__c
                                                                ,Tech_BSCommunityPopulationType__c//WCH 16/08/2019 C-003364
                                                         FROM   PurchaseOrder__c
                                                         WHERE  PrerequisiteOrder__c IN: allPurchaseToQuerySet
                                                         AND    Status__c !=: ASPISConstants.PUR_ORDER_STATUS_CANCELED
                                                         AND    Status__c !=: ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE
                                                         AND    Status__c !=: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO])
            {
                // Check of the purchase order id is un the set that needs the purchase order to be canceled
                if(salesOrderIdToCancelPOSet.contains(currentPurchaseOrder.PrerequisiteOrder__c))
                {
                    // add the purchase order in the map to update
                    mapPurchaseOrderToUpdate.put(currentPurchaseOrder.Id, new PurchaseOrder__c( Id          = currentPurchaseOrder.Id,
                                                                                                Status__c   = ASPISConstants.PUR_ORDER_STATUS_CANCELED,
                                                                                                Reason__c   = ASPISConstants.PUR_ORDER_REASON_CANCELEDBYBS));
                }

                // check if the purchase order is in the set of responded sales order
                if(respondedSalesOrderSet.contains(currentPurchaseOrder.PrerequisiteOrder__c))
                {
                    // check if the number of accepted lines is greater than 0
                    if(currentPurchaseOrder.AcceptedLines__c != null && currentPurchaseOrder.AcceptedLines__c > 0)
                    {
                        // add the purchase order in the map to update the PO to ordered
                        mapPurchaseOrderToUpdate.put(currentPurchaseOrder.Id, new PurchaseOrder__c( Id          = currentPurchaseOrder.Id,
                                                                                                    Status__c   = ASPISConstants.PUR_ORDER_STATUS_ORDERED));
                    }
                    else
                    {
                        // add the purchase order in the map to update the PO to canceled

                        //WCH 16/08/2019 C-003364 commented this code
                        /* mapPurchaseOrderToUpdate.put(currentPurchaseOrder.Id, new PurchaseOrder__c( Id          = currentPurchaseOrder.Id,
                                                                                                    Status__c   = ASPISConstants.PUR_ORDER_STATUS_CANCELED,
                                                                                                    Reason__c   = ASPISConstants.PUR_ORDER_REASON_REJECTEDQUOTE)); */

                        //WCH 16/08/2019 C-003364  if R4, PO.reason=canceled by distributor
                        PurchaseOrder__c canceledPO = new PurchaseOrder__c(Id = currentPurchaseOrder.Id, Status__c = ASPISConstants.PUR_ORDER_STATUS_CANCELED);
                        if(currentPurchaseOrder.Tech_BSCommunityPopulationType__c.equals('R3')){
                            canceledPO.Reason__c   = ASPISConstants.PUR_ORDER_REASON_REJECTEDQUOTE;
                        }else{
                            canceledPO.Reason__c   = ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE;
                        }
                        mapPurchaseOrderToUpdate.put(currentPurchaseOrder.Id, canceledPO);
                    }
                }
            }
        }


        if(mapPurchaseOrderToUpdate.size() > 0)
        {
            update mapPurchaseOrderToUpdate.values();
        }
        system.debug('## mapPurchaseOrderToUpdate' + mapPurchaseOrderToUpdate);

        if(casesToInsertList.size() > 0)
        {
            insert casesToInsertList;
        }

        // if(ap27SalesOrderList.size() > 0 && AP27SyncPOSOInternalComment.isFirstRun())
        // {
        //     AP27SyncPOSOInternalComment.updatePOInternalComment(ap27SalesOrderList);
        // }


        if(mapAssessmentToUpdate.size() > 0)
        {
            update mapAssessmentToUpdate.values();
        }

        // Merging the two list to use only 1 dml
        // Should not have duplicate ids as a SalesOrder cannot be canceled and paid at the same time
        List<PrerequisiteOrder__c> allSalesOrderToUpdateList = new List<PrerequisiteOrder__c>();
        allSalesOrderToUpdateList.addAll(canceledInvoiceSalesOrderList);
        allSalesOrderToUpdateList.addAll(paidSalesOrderToUpdateList);

        //AMI 26/07/17 : set status SO directly to closedko as there should be no invoice
        allSalesOrderToUpdateList.addAll(closedKOSOList);

        if(allSalesOrderToUpdateList.size() > 0)
        {
            update allSalesOrderToUpdateList;

            // call the function to generate the invoices/credit note of canceled sales orders
            if(canceledInvoiceSalesOrderList.size() > 0)
            {
                System.debug('@@@ canceledInvoiceSalesOrderList: ' + canceledInvoiceSalesOrderList);
                generateInvoiceForCanceledSalesOrder(canceledInvoiceSalesOrderList);
            }
        }

        //AMI 11/07/2017 - Set DE PO/SO to CLOSEDOK for Agency Mode
        if(ap39SODeliveredConfirmedSet.size() > 0)
        {
            AP39AgencyMode.closedSODEAgencyMode(ap39SODeliveredConfirmedSet);
        }

        if(assessmentIdSet.size() > 0)
        {
            if(System.isBatch() || System.isFuture())
            {
                AP18SetAssessmentStatus.updateAssessmentStatus(assessmentIdSet);
            }
            else
            {
                AP18SetAssessmentStatus.updateAssessmentStatusAsync(assessmentIdSet);
            }
        }

        if(notificationList.size() > 0)
        {
            insert notificationList;
        }

        // ABT - 16-FEB-2017 - C-001827
        if(postAssesssmentIdSet.size() > 0 && !System.isBatch()){
            system.debug('## calling RESTPostAssessment:'+postAssesssmentIdSet);
            RESTPostAssessment.buildJSONAsync(postAssesssmentIdSet);
        }

        if(salesOrderIdSetToSend.size() > 0 && !System.isBatch())
        {
            system.debug('## calling RESTPostSalesOrder:'+salesOrderIdSetToSend);
            if(System.isFuture()){
                RESTPostSalesOrder.buildJSON(salesOrderIdSetToSend,false);
            }else{
                RESTPostSalesOrder.buildJSONAsync(salesOrderIdSetToSend);
            }
        }
        //VSU 26/03/18 Commented for C-002410
        /*if(salesOrderIdDE.size() > 0){
            for(Prerequisiteorder__c so: [Select id 
                                            FROM Prerequisiteorder__c
                                            WHERE id IN: salesOrderIdDE
                                            AND (bodyshop__r.isEligibleSourcing__c = false
                                            OR (bodyshop__r.isEligibleSourcing__c = true AND assessment__r.RecordType.developername =: 'ClaimOrder'))]){               
                salesOrderIdToSendDeliveryNote.add(so.id);
            }
        }*/

        // ABT - 01-MAR-2017
        if(salesOrderIdToSendDeliveryNote.size() > 0)
        {
            AP33SendDeliveryNoteViaEmail.sendDeliveryNoteByEmail(salesOrderIdToSendDeliveryNote);
        }

        // DUN 21-JUL-2017 case 1669 Added code to create shipping cost line
        if(ap30SetSOID.size() > 0){
            AP30ShippingLineCreation.createShippingLine(ap30SetSOID);
        }

        //AMI  11/10/2018  : Case C-002045 - Advance case management - 
        //                 : Update SO status to Managed if offer status is changed to Managed
        //                 : and all other offers status are in a final stage
        system.debug('## setSOToUpdate.size() ' + setSOToUpdate.size());
        if(!setSOToUpdate.isEmpty()){
            ASPISWithoutSharingExceptions.updateSOToManage(setSOToUpdate);
        }
        system.debug('## mapOrderConfirmation.size() ' + mapOrderConfirmation);

        if (!mapOrderConfirmation.isEmpty()){
            map<String, Object> mapReturn = REST_OrderConfirmation.closeClaimOrder(mapOrderConfirmation);
        }

        System.debug('-------------------------- END METHOD PrerequisiteOrderTriggerHandler - onAfterUpdate --------------------------');
    }

    // Variable to store the userProfileName throughout a transaction
    private static String userProfileName;

    public static String getCurrentUserProfileName()
    {
        // Checks is the userProfileName has not been populated yet
        if(userProfileName == null)
        {
            userProfileName = [ SELECT  Id, Name
                                FROM    Profile
                                WHERE   Id =: UserInfo.getProfileId()].Name;
        }

        return userProfileName;
    }

    public static void generateInvoiceForCanceledSalesOrder(List<Prerequisiteorder__c> canceledInvoiceSalesOrderList)
    {
        system.debug('generateInvoiceForCanceledSalesOrder START>>');
        // get the invoices of the canceled sales order
        // selecting all the fields of the invoices so as to clone it
        String invoiceQueryString = 'SELECT ';

        // Using the Schema to get all the fields
        Map<String, Schema.SObjectField> mapInvoiceFields = Schema.SObjectType.Invoice__c.Fields.getMap();

        for(Schema.SObjectField currentField : mapInvoiceFields.values())
        {
            Schema.DescribeFieldResult currentFieldDescription = currentField.getDescribe();
            //AMI 18/01/19 :  C-003022  : Changing access type from Creatable to Accessible
            //                          : Due to error whan an SO were cancelled by Dist from An OL
            if(currentFieldDescription.isAccessible())
            {
                invoiceQueryString += currentFieldDescription.getName() + ', ';
            }
        }


        //WCH 21/02/2019 C-003092 : Credit Note not created when distributor cancel OL
        invoiceQueryString  +=  (invoiceQueryString.contains('PrerequisiteOrder__c') ? '' : 'PrerequisiteOrder__c,' ) + '(SELECT Id, OrderLine__c FROM Offers__r), '
                            +   '(SELECT Id, OrderLine__c FROM CreditNoteOffers__r) '
                            +   'FROM Invoice__c '
                            +   'WHERE PrerequisiteOrder__c IN: canceledInvoiceSalesOrderList';

        System.debug('invoiceQueryString: ' +invoiceQueryString);
        // Map that contains all the offers to update
        Map<Id, Offer__c> mapOffersToUpdate = new Map<Id, Offer__c>();
        // List of cloned to insert
        List<Invoice__c> invoiceToInsertList = new List<Invoice__c>();
        // Map storing the original id and its cloned version
        Map<Id, Invoice__c> mapOriginalClonedInvoice = new Map<Id, Invoice__c>();

        // Map that contains all the orderline to unflag
        Map<Id, OrderLine__c> mapOrderLineToUpdate = new Map<Id, OrderLine__c>();

        // Retrieving the invoices of the sales orders
        for(Invoice__c currentInvoice : Database.query(invoiceQueryString))
        {
            System.debug('@@ currentInvoice: ' +currentInvoice);
            Invoice__c clonedInvoice = currentInvoice.clone(false, true);

            // Clearing the following fields
            clonedInvoice.InvoicePaidDate__c    = null;
            clonedInvoice.Number__c             = null;
            clonedInvoice.InvoiceReference__c   = null;
            clonedInvoice.Date__c               = System.today();
            clonedInvoice.InvoiceSent__c        = false;
            clonedInvoice.TECH_InvoiceParent__c = String.valueOf(System.now()) + String.valueOf(Math.random());
            clonedInvoice.Status__c             = ASPISConstants.INV_STATUS_SENT;
            clonedInvoice.TECH_Number__c        = null;//RLA 15/06/2018 case 2617 - Duplicate TechNumber
            if(currentInvoice.Type__c == ASPISConstants.INV_TYPE_INVOICE)
            {
                clonedInvoice.Type__c = ASPISConstants.INV_TYPE_CREDITNOTE;

                // attaching the cloned invoice to the offer
                for(Offer__c currentOffer : currentInvoice.Offers__r)
                {
                    mapOffersToUpdate.put(currentOffer.Id, new Offer__c(Id              = currentOffer.Id,
                                                                        CreditNote__r   = new Invoice__c(TECH_InvoiceParent__c = clonedInvoice.TECH_InvoiceParent__c)));

                    if(currentOffer.OrderLine__c != null)
                    {
                        mapOrderLineToUpdate.put(currentOffer.OrderLine__c, new OrderLine__c(Id                     = currentOffer.OrderLine__c,
                                                                                             TECH_ToBeProcessed__c  = false));
                    }
                }
            }
            else if(currentInvoice.Type__c == ASPISConstants.INV_TYPE_CREDITNOTE)
            {
                clonedInvoice.Type__c = ASPISConstants.INV_TYPE_INVOICE;

                // attaching the cloned invoice to the offer
                for(Offer__c currentOffer : currentInvoice.CreditNoteOffers__r)
                {
                    mapOffersToUpdate.put(currentOffer.Id, new Offer__c(Id          = currentOffer.Id,
                                                                        Invoice__r  = new Invoice__c(TECH_InvoiceParent__c = clonedInvoice.TECH_InvoiceParent__c)));

                    if(currentOffer.OrderLine__c != null)
                    {
                        mapOrderLineToUpdate.put(currentOffer.OrderLine__c, new OrderLine__c(Id                     = currentOffer.OrderLine__c,
                                                                                             TECH_ToBeProcessed__c  = false));
                    }
                }
            }

            invoiceToInsertList.add(clonedInvoice);
            mapOriginalClonedInvoice.put(currentInvoice.Id, clonedInvoice);
        }

        // inserting the invoices
        if(mapOriginalClonedInvoice.size() > 0)
        {
            System.debug('@@@ mapOriginalClonedInvoice:'+mapOriginalClonedInvoice);
            insert mapOriginalClonedInvoice.values();

            List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();

            // making link with the parents by looping in the newly inserted invoices
            for(Invoice__c newInvoice : mapOriginalClonedInvoice.values())
            {
                // the ParentInvoice__c of the new(cloned) invoice is not null
                if( newInvoice.ParentInvoice__c != null &&
                    mapOriginalClonedInvoice.containsKey(newInvoice.ParentInvoice__c))
                {
                    invoicesToUpdate.add(new Invoice__c(Id                  = newInvoice.Id,
                                                        ParentInvoice__c    = mapOriginalClonedInvoice.get(newInvoice.ParentInvoice__c).Id));
                }
            }

            if(invoicesToUpdate.size() > 0)
            {
                update invoicesToUpdate;
            }
        }

        // updating the offers
        if(mapOffersToUpdate.size() > 0)
        {
            update mapOffersToUpdate.values();
        }

        // updating the orderline
        if(mapOrderLineToUpdate.size() > 0)
        {
            update mapOrderLineToUpdate.values();
        }
    }

    //DUN 15/03/2018 C-002339 - Fill field EncodedId__c 
    public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }
    //WCH 22/10/2020 C-004015
    public void setVisibleByPrefikar(Map<Id,PrerequisiteOrder__c> mapAssIdSO){
        for(Assessment__c currentAssessment : [select Id,VisibleByPrefikar__c from Assessment__c where Id in:mapAssIdSO.keyset()]){
            if(currentAssessment.VisibleByPrefikar__c && mapAssIdSO.containsKey(currentAssessment.Id)){
                mapAssIdSO.get(currentAssessment.Id).VisibleByPrefikar__c=true;
            }
        }
    }
}