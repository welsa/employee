/*
----------------------------------------------------------------------
-- - Name          : InvoiceTriggerHandler
-- - Author        : ABT
-- - Description   : Handler for the trigger InvoiceTriggerHandler
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 28-SEP-2016  ABT     1.0    Initial version
----------------------------------------------------------------------
-- Flow of InvoiceTriggerHandler:
--  - BEFORE INSERT 87142
--
--      -> if Type__c is null -- Set Type__c according to recordtypeId
--      -> if Type__c is not null -- Set recordtypeId according to Type__c
--      -> if assessment__c is null -- if PurchaseOrder__c is not null -- Get the Assessment__c and Distributor__c from the PurchaseOrder__c and set it to the invoice
--                                  -- ELSE if PrerequisiteOrder__c is not null -- Get the Assessment__c from Sales Order and set it to the invoice
--
--  - AFTER INSERT
--
--      -> if invoice is a Distributor Invoice/Credit Note and PurchaseOrder__c is not null -- Reopen PurchaseOrder if the status of the purchase order is CLOSEDOK or CLOSEDKO
--      -> if invoice is a BodyShop Invoice/Credit Note and PrerequisiteOrder__c is not null -- if invoice status is SENT and Number__c is not null --> Get the sales order not having status CANCELEDINVOICE
--                                                                                                                                                  --> if Sales Order is in CLOSEDKO --> Update Sales Order to CANCELEDINVOICE
--                                                                                                                                                  --> Else update sales order status to INVOICED
--                                                                                           -- if invoice status is PAID --> Check that all Invoices are PAID and set the status of the Sales Order status to PAID
--
--  - BEFORE UPDATE
--
--      -> if assessment__c is null -- if PurchaseOrder__c is not null -- Get the Assessment__c and Distributor__c from the PurchaseOrder__c and set it to the invoice
--                                  -- ELSE if PrerequisiteOrder__c is not null -- Get the Assessment__c from Sales Order and set it to the invoice
--
--  - AFTER UPDATE
--
--      -> if invoice status is PAID -- Set the assessment status to CLOSED
--      -> if invoice status is SENT -- Set the assessment status to INVOICED
--      -> if invoice is Distributor Invoice/Credit Note and PurchaseOrder__c is not null and status has changed and new status is PAID -- Set the purchase order TechToBeProcessed__c to true using AP13
--      -> if invoice is BodyShop Invoice/Credit Note and PrerequisiteOrder__c is not null and status has changed and new status is SENT -- Update the Sales Order status to INVOICED
--      -> if invoice is BodyShop Invoice/Credit Note and PrerequisiteOrder__c is not null and status has changed and new status is PAID -- Check that all Invoice are PAID and set the status of the Sales Order status to PAID (Done in AP14)
--
--  - AFTER DELETE
--
--      -> Nothing
----------------------------------------------------------------------
-- Previous Class History
----------------------------------------------------------------------
-- Developer    Date        Description
-- ----------   ----------  -----------------------
-- Cecile L.    17/06/2015  Original Version
-- Cecile L.    24/06/2015  Add the automatic population of the Type based on the Record Type
-- Dourga U     29/06/2015  Added code for update of total invoice amount on purchase order
-- Brayan N     16/07/2015  When invoice or credit note of type BS is created send invoice on web service
-- Cecile L     16/07/2015  Added syncronisation between record type and TYpe.
-- Dourga U     24/07/2015  Added code for update of total invoice amount on purchase order in after update
-- Dourga U     23/09/2015  Added code for update of Total Expected Amount on purchase order in after create and after update (case C-001235)
-- Dourga U     24/09/2015  Added code for update of Total Expected Amount on sales order in after create and after update (case C-001234)
-- Dourga U     01/10/2015  Added code for case C-001241 in after create and after update
-- Ashwina S    06/10/2015  Added code for case C-001255 in after create and after update
-- Ashwina S    06/10/2015  Added code for case C-001254 in after create and after update
-- Cécile L     08/10/2015  Added code for update of Total Expected Amount on purchase order in after delete (case C-001235)
-- Ashwina S    12/11/2015  not make RESTCallWsInvoice_V1 callout in after update
-- Dourga U     27/11/2015  Case C-001363,added code in after update
-- Ashwina S    05/01/2015  Modify RESTCreateDistributorInvoice_V1 to set field TechToBeProcessed__c to True
-- Dourga U     11/02/2016  Added code for case 1525 in before create and before update
-- Shamina M    18/02/2016  C-001518: Removed unnecessary debug logs
-- Ashwina S    23/02/2016  C-001405: check PO's TechToBeProcessed when invoice's status changes to PAID
-- Welsa C      20/03/2020  C-003623 - Update the status of the child Bodyshop Invoice that's attached to Spanish PO's based on 
                            the status of the parent invoice attached to the SO
-- Welsa C      20/03/2020  C-003675 - Apex Trigger Exception due to NULL value in Spanish PO Bodyshop Invoice 
-- Welsa C      22/10/2020   C-004015 - NOB - Assessment Sales Order Invoice Visibility Management
-- Welsa C      12/11/2020   C-003980 - NOB - Compensated Invoices
-- Welsa C      23/03/2021   C-004196 - Optimize code on compensation
-- Welsa C      31/08/2021   C-004420 : Logs for Cegedim calls
-- Welsa C      11/10/2021   C-004483 : Apex CPU time limit exceeded on Flow "NOB_InvoiceRecoveryDocumentFinancier" and "AspisBatchSendEmailInvoiceBS"
-- Neha P       18/10/2021   C-004496 : Total Invoices is not recalculated if PO is in status PAYABLE
***********************************************************************/
public without sharing class InvoiceTriggerHandler
{
    public InvoiceTriggerHandler()
    {
    }

    private static Id distributorInvoiceId      = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_DISTRIBUTORINVOICE).getRecordTypeId();
    private static Id distributorCreditNoteId   = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_DISTRIBUTORCREDITNOTE).getRecordTypeId();
    private static Id bodyshopInvoiceId         = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
    private static Id bodyshopCreditNoteId      = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();

    public void onBeforeInsert(List<Invoice__c> newInvoiceList)
    {
        System.debug('-------------------------- START METHOD InvoiceTriggerHandler - onBeforeInsert --------------------------');
        System.debug('---------------newInvoiceList' +newInvoiceList.size() + '-' +newInvoiceList);

        // List of invoices that has Assessment__c null and need to set it
        List<Invoice__c> invoiceToSetAssessmentList = new List<Invoice__c>();
        // Set of invoice's purchase order Id where the invoice assessment is null
        Set<Id> purchaseOrderIdSet                  = new Set<Id>();
        // Set of invoice's sales order Id where the invoice assessment is null
        Set<Id> salesOrderIdSet                     = new Set<Id>();
        Map<Id,List<Invoice__c>> mapSOIdInvisVisibleByPrefikar = new Map<Id,List<Invoice__c>>();//WCH 22/10/2020 C-004015
        // ABT 30-NOV-2016 - C-001497
        //Map<Id, List<Invoice__c>> mapPurchaseOrderIdInvoiceList = new Map<Id, List<Invoice__c>>();
        //Map<Id, List<Invoice__c>> mapSalesOrderIdInvoiceList    = new Map<Id, List<Invoice__c>>();
        Map<string,Set<Invoice__c>> mapClaimNumberInvoices = new Map<string,Set<Invoice__c>>();//WCH 09/11/2020 C-003980
        Map<String,CountryCodeInformationsMapping__c> countryCodeMapping = CountryCodeInformationsMapping__c.getall();//WCH 09/11/2020 C-003980
        set<Id> setInvoiceAssessmentIds = new set<Id>();//WCH 09/11/2020 C-003980

        // Loop in the new invoice list to do the filtering
        for(Invoice__c newInvoice : newInvoiceList)
        {
            // check if the Type__c is null
            if(newInvoice.Type__c == null)
            {
                // using the recordtypeId to set the Type__c
                if( newInvoice.RecordTypeId == bodyshopCreditNoteId ||
                    newInvoice.RecordTypeId == distributorCreditNoteId)
                {
                    newInvoice.Type__c = ASPISConstants.INV_TYPE_CREDITNOTE;
                }
                else
                {
                    newInvoice.Type__c = ASPISConstants.INV_TYPE_INVOICE;
                }

                // using recordtypeId to set the boolean IsBodyShop
                if( newInvoice.RecordTypeId == bodyshopInvoiceId ||
                    newInvoice.RecordTypeId == bodyshopCreditNoteId)
                {
                    newInvoice.IsBodyShop__c = true;
                }
                else
                {
                    newInvoice.IsBodyShop__c = false;
                }

            }
            else
            {
                // using Type__c and IsBodyShop__c to set the recordtypeId
                if(newInvoice.IsBodyShop__c)
                {
                    if(newInvoice.Type__c == ASPISConstants.INV_TYPE_INVOICE)
                    {
                        newInvoice.RecordTypeId = bodyshopInvoiceId;
                    }
                    else
                    {
                        newInvoice.RecordTypeId = bodyshopCreditNoteId;
                    }
                }
                else
                {
                    if(newInvoice.Type__c == ASPISConstants.INV_TYPE_INVOICE)
                    {
                        newInvoice.RecordTypeId = distributorInvoiceId;
                    }
                    else
                    {
                        newInvoice.RecordTypeId = distributorCreditNoteId;
                    }
                }
            }

            // check if assessment__c is null
            if(newInvoice.Assessment__c == null)
            {
                if(newInvoice.PurchaseOrder__c != null)
                {
                    purchaseOrderIdSet.add(newInvoice.PurchaseOrder__c);
                    invoiceToSetAssessmentList.add(newInvoice);                 
                }
                else if(newInvoice.PrerequisiteOrder__c != null)
                {
                    salesOrderIdSet.add(newInvoice.PrerequisiteOrder__c);
                    invoiceToSetAssessmentList.add(newInvoice); 
                }
            }

            //WCH 22/10/2020 C-004015
            if(newInvoice.IsBodyShop__c && newInvoice.PrerequisiteOrder__c!=null){
                if(mapSOIdInvisVisibleByPrefikar.containsKey(newInvoice.PrerequisiteOrder__c)){
                    mapSOIdInvisVisibleByPrefikar.get(newInvoice.PrerequisiteOrder__c).add(newInvoice);
                }else{
                    mapSOIdInvisVisibleByPrefikar.put(newInvoice.PrerequisiteOrder__c,new List<Invoice__c>{newInvoice});
                }
            }
            //WCH 09/11/2020 C-003980, 23/03/2021 C-004196
            if(String.isNotBlank(newInvoice.ClaimNumber__c) && newInvoice.Assessment__c!=null && (newInvoice.recordtypeId==bodyshopCreditNoteId || newInvoice.recordtypeId==bodyshopInvoiceId)){
                if(mapClaimNumberInvoices.containsKey(newInvoice.ClaimNumber__c)){
                    mapClaimNumberInvoices.get(newInvoice.ClaimNumber__c).add(newInvoice);
                }else{
                    mapClaimNumberInvoices.put(newInvoice.ClaimNumber__c,new Set<Invoice__c>{newInvoice});
                }
                setInvoiceAssessmentIds.add(newInvoice.Assessment__c);
            }

            // ABT 30-NOV-2016 - C-001497
            // check if the invoice is a distributor invoice and the PurchaseOrder__c is not null
            // if(  (newInvoice.RecordTypeId == distributorInvoiceId ||
            //   newInvoice.RecordTypeId == distributorCreditNoteId) &&
            //   newInvoice.PurchaseOrder__c != null) 
            // {
            //  if(!mapPurchaseOrderIdInvoiceList.containsKey(newInvoice.PurchaseOrder__c))
            //  {
            //      mapPurchaseOrderIdInvoiceList.put(newInvoice.PurchaseOrder__c, new List<Invoice__c>{newInvoice});
            //  }
            //  else
            //  {
            //      mapPurchaseOrderIdInvoiceList.get(newInvoice.PurchaseOrder__c).add(newInvoice);
            //  }
            // }

            // check if the invoice is a BodyShop invoice and the PrerequisiteOrder__c is not null
            // if(  (newInvoice.RecordTypeId == bodyshopInvoiceId ||
            //   newInvoice.RecordTypeId == bodyshopCreditNoteId) &&
            //  newInvoice.PrerequisiteOrder__c != null)
            // {
            //  if(!mapSalesOrderIdInvoiceList.containsKey(newInvoice.PrerequisiteOrder__c))
            //  {
            //      mapSalesOrderIdInvoiceList.put(newInvoice.PrerequisiteOrder__c, new List<Invoice__c>{newInvoice});
            //  }
            //  else
            //  {
            //      mapSalesOrderIdInvoiceList.get(newInvoice.PrerequisiteOrder__c).add(newInvoice);
            //  }
            // }
        }

        if(invoiceToSetAssessmentList.size() > 0)
        {
            setInvoiceAssessment(invoiceToSetAssessmentList, purchaseOrderIdSet, salesOrderIdSet);
        }

        // if(  mapPurchaseOrderIdInvoiceList.size() > 0 ||
        //  mapSalesOrderIdInvoiceList.size() > 0)
        // {
        //  setInvoiceOwner(mapPurchaseOrderIdInvoiceList, mapSalesOrderIdInvoiceList);
        // }
        //WCH 22/10/2020 C-004015
        if(mapSOIdInvisVisibleByPrefikar.size() > 0){
            setVisibleByPrefikar(mapSOIdInvisVisibleByPrefikar);
        }
        //WCH 09/11/2020 C-003980
        if(mapClaimNumberInvoices.size()>0){
            setIsCompensated(mapClaimNumberInvoices,setInvoiceAssessmentIds);
        }

        System.debug('-------------------------- END METHOD InvoiceTriggerHandler - onBeforeInsert --------------------------');
    }

    public void onAfterInsert(List<Invoice__c> newInvoiceList, Map<Id, Invoice__c> newInvoiceMap)
    //public void onAfterInsert(List<Invoice__c> newInvoiceList)
    {
        System.debug('-------------------------- START METHOD InvoiceTriggerHandler - onAfterInsert --------------------------');


        // Map assessment to Update
        // Map<Id, Assessment__c> mapAssessmentToUpdate     = new Map<Id, Assessment__c>();
        // Set of purchase order id to reopen the purchase order
        Set<Id> purchaseOrderIdSet                      = new Set<Id>();
        map <Id, list <Invoice__c>> mapInvPO = new map <Id,list <Invoice__c>> ();
        list <Invoice__c>listInvToUpdateOwner = new list <Invoice__c> ();
        map <Id,list <Invoice__c>>  mapInvSO = new map <Id,list <Invoice__c>> ();
        // Set of sales order to set thier status to INVOICED
        // Set<Id> salesOrderIdToSetInvoicedSet            = new Set<Id>();
        // Set of sales order to set thier status to Paid
        // Set<Id> salesOrderIdToSetPaidSet                = new Set<Id>();

        // Loop in the new invoice list to do the filtering
        for(Invoice__c newInvoice : newInvoiceList)
        {
            // check if the newInvoice status is SENT
            // if(  newInvoice.Status__c == ASPISConstants.INV_STATUS_SENT &&
            //  newInvoice.Assessment__c != null)
            // {
            //  // set assessment to INVOICED
            //  if(!mapAssessmentToUpdate.containsKey(newInvoice.Assessment__c))
            //  {
            //      mapAssessmentToUpdate.put(newInvoice.Assessment__c, new Assessment__c(  Id          = newInvoice.Assessment__c,
            //                                                                              Status__c   = ASPISConstants.ASSESS_STATUS_INVOICED));
            //  }
            // }
            // check if the invoice is a distributor invoice
            if( (newInvoice.RecordTypeId == distributorInvoiceId ||
                 newInvoice.RecordTypeId == distributorCreditNoteId) &&
                newInvoice.PurchaseOrder__c != null)
            {
                purchaseOrderIdSet.add(newInvoice.PurchaseOrder__c);
                //VSU 29/03/18  Case C-002407
                if(mapInvPO.containsKey(newInvoice.PurchaseOrder__c)){
                    mapInvPO.get(newInvoice.PurchaseOrder__c).add(newInvoice);
                }
                else{
                    mapInvPO.put(newInvoice.PurchaseOrder__c,new list <Invoice__c> {newInvoice});
                }//VSU 29/03/18 C-002407               
            }else if((newInvoice.RecordTypeId == bodyshopInvoiceId ||
                newInvoice.RecordTypeId == bodyshopCreditNoteId) &&
                newInvoice.PrerequisiteOrder__c != null){

                if(mapInvSO.containsKey(newInvoice.PrerequisiteOrder__c)){
                    mapInvSO.get(newInvoice.PrerequisiteOrder__c).add(newInvoice);
                }
                else{
                    mapInvSO.put(newInvoice.PrerequisiteOrder__c,new list <Invoice__c> {newInvoice});
                }
            }

            // check if the invoice is a BodyShop invoice and the PrerequisiteOrder__c is not null
            // ABT 03-JUL-2017 - As there are no uncommented code inside the if.....it is commented
            // if( (newInvoice.RecordTypeId == bodyshopInvoiceId ||
            //      newInvoice.RecordTypeId == bodyshopCreditNoteId) &&
            //     newInvoice.PrerequisiteOrder__c != null)
            // {
                // ABT 03-JUL-2017 - No BS invoice/credit note is created with invoice number so it is useless
                // if( newInvoice.Status__c == ASPISConstants.INV_STATUS_SENT &&
                //     newInvoice.Number__c != null)
                // {
                //     salesOrderIdToSetInvoicedSet.add(newInvoice.PrerequisiteOrder__c);
                // }

                // ABT 13-JUN-2017 - Commented on Jonathan request
                // if(newInvoice.Status__c == ASPISConstants.INV_STATUS_PAID)
                // {
                //     salesOrderIdToSetPaidSet.add(newInvoice.PrerequisiteOrder__c);
                // }
            // }
        }

        // if(mapAssessmentToUpdate.size() > 0)
        // {
        //  update mapAssessmentToUpdate.values();
        // }

        if(System.isBatch() || System.isFuture())
        {
            updateInvoice(newInvoiceMap.keySet());
        }
        else
        {
            updateInvoiceAsync(newInvoiceMap.keySet());
        }

        if(purchaseOrderIdSet.size() > 0)
        {
            //VSU 29/03/18 C-002407
            for(PurchaseOrder__c po: [Select id,Distributor__r.contactUser__c
                                        From PurchaseOrder__c 
                                        where id IN:purchaseOrderIdSet ]){
                    for(Invoice__c inv: mapInvPO.get(po.id)){
                        if(inv.OwnerId != po.Distributor__r.contactUser__c && po.Distributor__r.contactUser__c!= null){
                             
                             listInvToUpdateOwner.add(new Invoice__c (id = inv.id, OwnerId = po.Distributor__r.contactUser__c));
                    }
                }
            }
            // Open the closed purchase orders
            
            if(System.isBatch() || System.isFuture())
            {
                AP13SetPOStatus.reopenPurchaseOrder(purchaseOrderIdSet);
            }
            else
            {
                AP13SetPOStatus.reopenPurchaseOrderAsync(purchaseOrderIdSet);
                //NPE 18/10/2021 C-004496
                AP13SetPOStatus.updatePoTotalExpectedAmount(purchaseOrderIdSet);
            }
        }

        //AMI 26/06/18 : Community Rollout 
        //             : Prevent changing owner from aspis system to bs user
        /*//VSU 29/03/18 C-002407
        if(mapInvSO.keySet().size() > 0){
            for(PrerequisiteOrder__c so: [Select id,BodyShop__r.contactUser__c
                                            From PrerequisiteOrder__c 
                                            where id IN: mapInvSO.keySet()]){
                for(Invoice__c inv: mapInvSO.get(so.id)){
                    if(inv.OwnerId != so.BodyShop__r.contactUser__c && so.BodyShop__r.contactUser__c != null){
                         listInvToUpdateOwner.add(new Invoice__c (id = inv.id, OwnerId = so.BodyShop__r.contactUser__c));
                    }
                }
            }
        }*/

        if(listInvToUpdateOwner.size() > 0){
            update listInvToUpdateOwner;
        }

        // ABT 03-JUL-2017 - No BS invoice/credit note is created with invoice number so it is useless
        // if(salesOrderIdToSetInvoicedSet.size() > 0)
        // {
        //     if(System.isBatch() || System.isFuture())
        //     {
        //         AP14SetSOStatus.updateSalesOrderInvoicedV2(salesOrderIdToSetInvoicedSet);
        //     }
        //     else
        //     {
        //         AP14SetSOStatus.updateSalesOrderInvoicedV2Async(salesOrderIdToSetInvoicedSet);
        //     }
        // }

        // ABT 13-JUN-2017 - Commented on Jonathan request
        // if(salesOrderIdToSetPaidSet.size() > 0)
        // {
        //     if(System.isBatch() || System.isFuture())
        //     {
        //         AP14SetSOStatus.updateSalesOrderPaid(salesOrderIdToSetPaidSet);
        //     }
        //     else
        //     {
        //         AP14SetSOStatus.updateSalesOrderPaidAsync(salesOrderIdToSetPaidSet);
        //     }
        // }

        System.debug('-------------------------- END METHOD InvoiceTriggerHandler - onAfterInsert --------------------------');
    }

    // replace WF44InvoicePopulateAssessmentCountryCode by code (C-001888 : @future to avoid Apex CPU time limit exceeded with 2000 invoices + no Before/After Update after WF update field)
    @future
    private static void updateInvoiceAsync(Set<Id> newInvoiceIdSet) {
        updateInvoice(newInvoiceIdSet);
    }

    private static void updateInvoice(Set<Id> newInvoiceIdSet) {
        List<Invoice__c> invoiceToUpdate = new List<Invoice__c>();
        for (Invoice__c invoice :  [SELECT Id, Assessment__r.TECH_EntityCountryCode__c, TechAssessmentCountryCode__c FROM Invoice__c WHERE Id IN :newInvoiceIdSet]) {
            if (invoice.Assessment__r.TECH_EntityCountryCode__c != invoice.TechAssessmentCountryCode__c) {
                invoice.TechAssessmentCountryCode__c = invoice.Assessment__r.TECH_EntityCountryCode__c;
                invoiceToUpdate.add(invoice);
            }
        }

        if (!invoiceToUpdate.isEmpty()) {
            update invoiceToUpdate;
        }
    }

    public void onBeforeUpdate(List<Invoice__c> newInvoiceList, List<Invoice__c> oldInvoiceList, Map<Id, Invoice__c> mapOldInvoice)
    {
        System.debug('-------------------------- START METHOD InvoiceTriggerHandler - onBeforeUpdate --------------------------');



        // List of invoices to set assessment
        List<Invoice__c> invoiceToSetAssessmentList = new List<Invoice__c>();
        // Set of invoice's purchase order Id where the invoice assessment is null
        Set<Id> purchaseOrderIdSet                  = new Set<Id>();
        // Set of invoice's sales order Id where the invoice assessment is null
        Set<Id> salesOrderIdSet                     = new Set<Id>();

        for(Integer i = 0; i < newInvoiceList.size(); i++)
        {
            // check if the assessment is null
            if(newInvoiceList[i].Assessment__c == null)
            {
                invoiceToSetAssessmentList.add(newInvoiceList[i]);

                if(newInvoiceList[i].PurchaseOrder__c != null)
                {
                    purchaseOrderIdSet.add(newInvoiceList[i].PurchaseOrder__c);
                    invoiceToSetAssessmentList.add(newInvoiceList[i]);                  
                }
                else if(newInvoiceList[i].PrerequisiteOrder__c != null)
                {
                    salesOrderIdSet.add(newInvoiceList[i].PrerequisiteOrder__c);
                    invoiceToSetAssessmentList.add(newInvoiceList[i]);  
                }
            }

            if( newInvoiceList[i].Status__c != oldInvoiceList[i].Status__c &&
                newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_PAID)
            {
                //newInvoiceList[i].InvoicePaidDate__c = System.now();
            }
        }

        if(invoiceToSetAssessmentList.size() > 0)
        {
            setInvoiceAssessment(invoiceToSetAssessmentList, purchaseOrderIdSet, salesOrderIdSet);
        }

        System.debug('-------------------------- END METHOD InvoiceTriggerHandler - onBeforeUpdate --------------------------');
    }

    public void onAfterUpdate(List<Invoice__c> newInvoiceList, List<Invoice__c> oldInvoiceList, Map<Id, Invoice__c> mapOldInvoice, Map<Id, Invoice__c> mapNewInvoice)
    //public void onAfterUpdate(List<Invoice__c> newInvoiceList, List<Invoice__c> oldInvoiceList, Map<Id, Invoice__c> mapOldInvoice)
    {
        System.debug('-------------------------- START METHOD InvoiceTriggerHandler - onAfterUpdate --------------------------');
        
        User currentUser = ASPISTools.getCurrentUserInfo();
        List<Invoice__c> lstInvUpdatedCegedim = new List<Invoice__c>();//WCH 31/08/2021 C-004420
        // Map of assessment that needs to be updated
        // Map<Id, Assessment__c> mapAssessmentToUpdate     = new Map<Id, Assessment__c>();
        // Set of purchase order id to set TechToBeProcessed__c to true
        //Set<Id> purchaseOrderIdSet                        = new Set<Id>();
        // Set of sales order to set thier status to INVOICED
        // ABT - 30-JUN-2017 - C-001938 - Commented moved in ASPISBatchCreateInvoiceAddDis
        // Set<Id> salesOrderIdToSetInvoicedSet            = new Set<Id>();
        // Set of sales order to set thier status to Paid
        // Set<Id> salesOrderIdToSetPaidSet                = new Set<Id>();
        // Set of spanish sales order to set to closed
        // Set<Id> spanishSalesOrderIdToSetClosed          = new Set<Id>();

        // Map of bodyshops that need to have their Last Direct Debit Payment Date updated
        Map<Id, Account> mapBodyShopToUpdate         = new Map<Id, Account>();

        // get invoices with Case to created
        Set<Id> invoiceIdWithCaseSet = new Set<Id>();

        Set<Id> setParentInvoiceIds = new Set<Id>();//WCH 04/02/2020 C-003623
        for(Integer i = 0; i < newInvoiceList.size(); i++)
        {
            // // check if status is PAID
            // if(newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_PAID)
            // {
            //  if(!mapAssessmentToUpdate.containsKey(newInvoiceList[i].Assessment__c))
            //  {
            //      mapAssessmentToUpdate.put(newInvoiceList[i].Assessment__c, new Assessment__c(Id         = newInvoiceList[i].Assessment__c,
            //                                                                                   Status__c  = ASPISConstants.ASSESS_STATUS_CLOSEDOK));
            //  }
            // }

            // // check if status is SENT
            // if(newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_SENT)
            // {
            //  if(!mapAssessmentToUpdate.containsKey(newInvoiceList[i].Assessment__c))
            //  {
            //      mapAssessmentToUpdate.put(newInvoiceList[i].Assessment__c, new Assessment__c(Id         = newInvoiceList[i].Assessment__c,
            //                                                                                   Status__c  = ASPISConstants.ASSESS_STATUS_INVOICED));
            //  }
            // }
            
            // check if the invoice is a distributor invoice
            // if(  newInvoiceList[i].Status__c != oldInvoiceList[i].Status__c &&
            //  (newInvoiceList[i].RecordTypeId == distributorInvoiceId ||
            //      newInvoiceList[i].RecordTypeId == distributorCreditNoteId) &&
            //  newInvoiceList[i].PurchaseOrder__c != null &&
            //  newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_PAID)
            // {
            //  purchaseOrderIdSet.add(newInvoiceList[i].PurchaseOrder__c);
            // }

            // check if the invoice is a BodyShop invoice and the PrerequisiteOrder__c is not null
            if( (newInvoiceList[i].RecordTypeId == bodyshopInvoiceId ||
                 newInvoiceList[i].RecordTypeId == bodyshopCreditNoteId))
            {
                if(newInvoiceList[i].PrerequisiteOrder__c != null)
                {
                    // ABT - 30-JUN-2017 - C-001938 - Commented moved in ASPISBatchCreateInvoiceAddDis
                    // if( (newInvoiceList[i].Status__c != oldInvoiceList[i].Status__c || newInvoiceList[i].Number__c != oldInvoiceList[i].Number__c) && 
                    //     newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_SENT &&
                    //     newInvoiceList[i].Number__c != null)
                    // {
                    //     salesOrderIdToSetInvoicedSet.add(newInvoiceList[i].PrerequisiteOrder__c);
                    // }

                    // ABT - 06-DEC-2016 - C-001677
                    // ABT 13-JUN-2017 - Commented on Jonathan request
                    // if( newInvoiceList[i].ParentInvoice__c != null &&
                    //     newInvoiceList[i].InvoiceSent__c != oldInvoiceList[i].InvoiceSent__c &&
                    //     newInvoiceList[i].InvoiceSent__c == true)
                    // {
                    //     spanishSalesOrderIdToSetClosed.add(newInvoiceList[i].PrerequisiteOrder__c);
                    // }

                    // ABT 13-JUN-2017 - Commented on Jonathan request
                    // if( newInvoiceList[i].Status__c != oldInvoiceList[i].Status__c && 
                    //     newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_PAID)
                    // {
                    //     salesOrderIdToSetPaidSet.add(newInvoiceList[i].PrerequisiteOrder__c);
                    // }
                }

                // replace Process Builder InvoiceProcess for better performance (C-001888 : @future to avoid Apex CPU time limit exceeded)
                if (newInvoiceList[i].BodyShop__c != null &&
                    newInvoiceList[i].RecordTypeId == bodyshopInvoiceId &&
                    newInvoiceList[i].Status__c != oldInvoiceList[i].Status__c && 
                    newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_PAID &&
                    newInvoiceList[i].PaymentType__c == '49')
                 {
                    mapBodyShopToUpdate.put(newInvoiceList[i].BodyShop__c, new Account( Id                              = newInvoiceList[i].BodyShop__c,
                                                                                      LastPaymentDirectDebitDate__c   = System.today()));
                 }
                 //WCH 31/08/2021 C-004420
        
                 if(currentUser!=null  && (Test.isRunningTest() || system.Label.AspisCegedimUsers.contains(currentUser.Name)) && !String.isBlank(newInvoiceList[i].InvoiceReference__c) && !String.isBlank(newInvoiceList[i].Number__c) && mapOldInvoice.get(newInvoiceList[i].Id)!=null && String.isBlank(mapOldInvoice.get(newInvoiceList[i].Id).InvoiceReference__c) && String.isBlank(mapOldInvoice.get(newInvoiceList[i].Id).Number__c)){
                        lstInvUpdatedCegedim.add(new Invoice__c(Id=newInvoiceList[i].Id,InvoiceReference__c=newInvoiceList[i].InvoiceReference__c,Number__c=newInvoiceList[i].Number__c));
                 }

            }
            // replace Process Builder InvoiceProcess for better performance (C-001888 : @future to avoid Apex CPU time limit exceeded)
            else if (newInvoiceList[i].Status__c != oldInvoiceList[i].Status__c && 
                    newInvoiceList[i].Status__c == ASPISConstants.INV_STATUS_PAYABLE &&
                    (newInvoiceList[i].RecordTypeId == distributorInvoiceId || newInvoiceList[i].RecordTypeId == distributorCreditNoteId))
            {
                invoiceIdWithCaseSet.add(newInvoiceList[i].Id);
            }
            //WCH 04/03/2020 C-003623 - 23/03/2020 C-003675
            if(String.isNotBlank(newInvoiceList[i].TechCountryCode__c) && newInvoiceList[i].TechCountryCode__c.equals('ES') && String.isNotBlank(system.label.Purge2020ValidINVStatus) && newInvoiceList[i].ParentInvoice__c==null && system.label.Purge2020ValidINVStatus.contains(newInvoiceList[i].Status__c==null? 'NOT_APPLICABLE' : newInvoiceList[i].Status__c)){
                setParentInvoiceIds.add(newInvoiceList[i].Id);
            }
           
        }

        // if(mapAssessmentToUpdate.size() > 0)
        // {
        //  update mapAssessmentToUpdate.values();
        // }

        // Commented as it not used any more
        // if(purchaseOrderIdSet.size() > 0)
        // {
        //   AP13SetPOStatus.updatePurchaseOrderField(purchaseOrderIdSet);
        // }

        //onAfterUpdateFuture(salesOrderIdToSetInvoicedSet, spanishSalesOrderIdToSetClosed, salesOrderIdToSetPaidSet);
        // ABT - 30-JUN-2017 - C-001938 - Commented moved in ASPISBatchCreateInvoiceAddDis
        // if(salesOrderIdToSetInvoicedSet.size() > 0)
        // {
        //     if(System.isBatch() || System.isFuture())
        //     {
        //         AP14SetSOStatus.updateSalesOrderInvoicedV2(salesOrderIdToSetInvoicedSet);
        //     }
        //     else
        //     {
        //         AP14SetSOStatus.updateSalesOrderInvoicedV2Async(salesOrderIdToSetInvoicedSet);
        //     }
        // }

        // ABT 06-DEC-2016 - C-001677
        // ABT 13-JUN-2017 - Commented on Jonathan request
        // if(spanishSalesOrderIdToSetClosed.size() > 0)
        // {
        //     if(System.isBatch() || System.isFuture())
        //     {
        //         AP14SetSOStatus.updateSpanishSalesOrder(spanishSalesOrderIdToSetClosed);
        //     }
        //     else
        //     {
        //         AP14SetSOStatus.updateSpanishSalesOrderAsync(spanishSalesOrderIdToSetClosed);
        //     }
        // }

        // ABT 13-JUN-2017 - Commented on Jonathan request
        // if(salesOrderIdToSetPaidSet.size() > 0)
        // {
        //     if(System.isBatch() || System.isFuture())
        //     {
        //         AP14SetSOStatus.updateSalesOrderPaid(salesOrderIdToSetPaidSet);
        //     }
        //     else
        //     {
        //         AP14SetSOStatus.updateSalesOrderPaidAsync(salesOrderIdToSetPaidSet);
        //     }
        // }

        if (!mapBodyShopToUpdate.isEmpty())
        {
            // if bad performance, maybe use @future
            update mapBodyShopToUpdate.values();
        }

        if (!invoiceIdWithCaseSet.isEmpty()) {
            // replace Process Builder InvoiceProcess for better performance (C-001888 : @future to avoid Apex CPU time limit exceeded)
            if(System.isBatch() || System.isFuture())
            {
                ASPISProcessFlow.updatePoInvoiceSync(invoiceIdWithCaseSet, null);
                Utils_ManageCaseCustom.createNewCase(invoiceIdWithCaseSet);
            }
            else
            {
                ASPISProcessFlow.updatePoInvoice(invoiceIdWithCaseSet, null);
                Utils_ManageCaseCustom.createNewCaseAsync(invoiceIdWithCaseSet);
            }
        }
        //WCH 04/03/2020 C-003623
        if(System.isBatch() || System.isFuture()){
            updateChildInvoice(setParentInvoiceIds);
        }
        else{
            updateChildInvoiceAsync(setParentInvoiceIds);
        }
        if(!lstInvUpdatedCegedim.isEmpty()){
            Utils_ManageLogs.createCegedimLog('CegedimInvoiceUpdate','Invoice__c',JSON.serialize(lstInvUpdatedCegedim));
        }
        System.debug('-------------------------- END METHOD InvoiceTriggerHandler - onAfterUpdate --------------------------');
    }
    //WCH 04/03/2020 C-003623
    @future
    private static void updateChildInvoiceAsync(Set<Id> newParentInvoiceIdSet) {
        updateChildInvoice(newParentInvoiceIdSet);
    }
    private static void updateChildInvoice(Set<Id> newParentInvoiceIdSet) {
        List<Invoice__c> invoiceToUpdate = new List<Invoice__c>();
        for (Invoice__c invoice :  [SELECT Id, Status__c,parentinvoice__r.status__c FROM Invoice__c WHERE parentinvoice__c IN :newParentInvoiceIdSet and PrerequisiteOrder__c!=null and InvoiceSent__c=true and TechCountryCode__c='ES']) {
            invoiceToUpdate.add(new Invoice__c(Id=invoice.Id,Status__c=invoice.parentinvoice__r.status__c));
        }
        if (!invoiceToUpdate.isEmpty()) {
            update invoiceToUpdate;
        }
    }
/*
    // update bodyshop accounts
    // replace Process Builder InvoiceProcess for better performance (C-001888 : @future to avoid Apex CPU time limit exceeded)
    @future
    private static void updateBodyshopAsync(Set<Id> invoiceSet) {
        List<Account> bodyshopList = new List<Account>();
        Set<Id> bodyshopIdSet = new Set<Id>();

        for (Invoice__c invoice : [SELECT Id, BodyShop__c FROM Invoice__c WHERE Id IN :newInvoiceIdSet AND Status__c = :ASPISConstants.INV_STATUS_PAID AND RecordTypeId = :bodyshopInvoiceId AND PaymentType__c  = '49']) {
            if (bodyshopIdSet.add(invoice.Bodyshop__c)) {
                Account bs = new Account(Id = invoice.Bodyshop__c, LastPaymentDirectDebitDate__c = System.today());
                bodyshopList.add(bs);
            }
        }

        if (!bodyshopList.isEmpty()) {
            update bodyshopList;
        }
    }
*/
    public void setInvoiceAssessment(List<Invoice__c> invoiceToSetAssessmentList, Set<Id> setPOIds, Set<Id> setSOIds)
    {
        Map<Id, PurchaseOrder__c> mapPurchaseOrderQueried   = new Map<Id, PurchaseOrder__c>(); 
        Map<Id, PrerequisiteOrder__c> mapSalesOrderQueried  = new Map<Id, PrerequisiteOrder__c>(); 

        if(setPOIds.size() > 0)
        {
            mapPurchaseOrderQueried = new Map<Id, PurchaseOrder__c>([SELECT Id, Assessment__c, Distributor__c 
                                                                     FROM   PurchaseOrder__c 
                                                                     WHERE  Id IN: setPOIds]);
        }

        if(setSOIds.size() > 0)
        {
            mapSalesOrderQueried = new Map<Id, PrerequisiteOrder__c>([  SELECT  Id, Assessment__c 
                                                                        FROM    PrerequisiteOrder__c 
                                                                        WHERE   Id IN: setSOIds]);
        }

        for(Invoice__c currentInvoice : invoiceToSetAssessmentList)
        {
            if( currentInvoice.PurchaseOrder__c != null && 
                mapPurchaseOrderQueried.containsKey(currentInvoice.PurchaseOrder__c))
            {
                PurchaseOrder__c currentPurchaseOrder = mapPurchaseOrderQueried.get(currentInvoice.PurchaseOrder__c);
                currentInvoice.Assessment__c    = currentPurchaseOrder.Assessment__c;
                currentInvoice.Distributor__c   = currentPurchaseOrder.Distributor__c;
            }
            else if(currentInvoice.PrerequisiteOrder__c != null && 
                    mapSalesOrderQueried.containsKey(currentInvoice.PrerequisiteOrder__c))
            {
                currentInvoice.Assessment__c = mapSalesOrderQueried.get(currentInvoice.PrerequisiteOrder__c).Assessment__c;
            }
        }
    }

    // public void setInvoiceOwner(Map<Id, List<Invoice__c>> mapPurchaseOrderIdInvoiceList, Map<Id, List<Invoice__c>> mapSalesOrderIdInvoiceList)
    // {
    //  if(mapPurchaseOrderIdInvoiceList.size() > 0)
    //  {
    //      for(PurchaseOrder__c currentPurchaseOrder : [SELECT Id, Distributor__r.OwnerId
    //                                                   FROM   PurchaseOrder__c
    //                                                   WHERE  Id IN: mapPurchaseOrderIdInvoiceList.keySet()])
    //      {
    //          if(mapPurchaseOrderIdInvoiceList.containsKey(currentPurchaseOrder.Id))
    //          {
    //              for(Invoice__c currentInvoice : mapPurchaseOrderIdInvoiceList.get(currentPurchaseOrder.Id))
    //              {
    //                  currentInvoice.OwnerId = currentPurchaseOrder.Distributor__r.OwnerId;
    //              }
    //          }
    //      }
    //  }

    //  if(mapSalesOrderIdInvoiceList.size() > 0)
    //  {
    //      for(PrerequisiteOrder__c currentSalesOrder : [SELECT    Id, BodyShop__r.OwnerId
    //                                                    FROM      PrerequisiteOrder__c
    //                                                    WHERE     Id IN: mapSalesOrderIdInvoiceList.keySet()])
    //      {
    //          if(mapSalesOrderIdInvoiceList.containsKey(currentSalesOrder.Id))
    //          {
    //              for(Invoice__c currentInvoice : mapSalesOrderIdInvoiceList.get(currentSalesOrder.Id))
    //              {
    //                  currentInvoice.OwnerId = currentSalesOrder.BodyShop__r.OwnerId;
    //              }
    //          }
    //      }
    //  }
    // }
    //WCH 22/10/2020 C-004015
    public void setVisibleByPrefikar(Map<Id,List<Invoice__c>> mapSOIdInv){
        for(PrerequisiteOrder__c currentSO : [select Id,VisibleByPrefikar__c from PrerequisiteOrder__c where Id in:mapSOIdInv.keyset()]){
            if(currentSO.VisibleByPrefikar__c && mapSOIdInv.containsKey(currentSO.Id)){
                for(Invoice__c currentInv : mapSOIdInv.get(currentSO.Id)){
                    currentInv.VisibleByPrefikar__c=true;
                }
            }
        }
    }
    //WCH 09/11/2020 C-003980
    public void setIsCompensated(Map<string,Set<Invoice__c>> mapClaimNumberInvoices,Set<Id> setInvoiceAssessmentIds)
    {   system.debug('mapClaimNumberInvoices>>'+mapClaimNumberInvoices);
       system.debug('setInvoiceAssessmentIds>>'+setInvoiceAssessmentIds);
        Map<String,Boolean> mapAssClaimRefNewCompensatedProcess = new  Map<String,Boolean>();
        Set<Id> setBodyshopsForClaimAssInv = new Set<Id>();
        List<Case> setCaseToUpdate = new List<Case>();
        Map<Id,assessment__c> mapCOToUpdate = new Map<Id,assessment__c>();
        Map<Id,Id> mapCOToParentAss = new Map<Id,Id>();
        List<String> validEntityCodes= (system.label.ASFRPrefikarEntity).split(';');
        for(assessment__c currentAssessment : [select Id,ClaimReference__c,ParentAssessment__c,ParentAssessment__r.NewCompensatedProcess__c,BodyShop__c,compensated__c from assessment__c where Id in : setInvoiceAssessmentIds and recordtype.developername =: ASPISConstants.ASSESS_RT_DeveloperName_ClaimOrder and Bodyshop__r.IceInvTransmit__c=true and Bodyshop__r.AXAPartner__c=true and isShoppingList__c=false and EntityCode__c in :validEntityCodes]){
            mapAssClaimRefNewCompensatedProcess.put(currentAssessment.ClaimReference__c,currentAssessment.ParentAssessment__r.NewCompensatedProcess__c);
            setBodyshopsForClaimAssInv.add(currentAssessment.BodyShop__c);
            mapCOToParentAss.put(currentAssessment.Id,currentAssessment.ParentAssessment__c);
        }
        for(Case currentCase : [Select Id,PFR_TECH_STDClaimNr__c,PFR_ASCompDecisionFinal__c,PFR_ASCompDecisionEstim__c from Case where PFR_TECH_STDClaimNr__c in : mapClaimNumberInvoices.keyset()]){
            system.debug('currentCase>>'+currentCase);
            system.debug('PFR_ASCompDecisionFinal__c is null 1>>'+currentCase.PFR_ASCompDecisionFinal__c);
            if(mapClaimNumberInvoices.containsKey(currentCase.PFR_TECH_STDClaimNr__c) && mapAssClaimRefNewCompensatedProcess.containsKey(currentCase.PFR_TECH_STDClaimNr__c) && mapAssClaimRefNewCompensatedProcess.get(currentCase.PFR_TECH_STDClaimNr__c)){
                if(!String.isBlank(currentCase.PFR_ASCompDecisionFinal__c) && currentCase.PFR_ASCompDecisionFinal__c.equals(ASPISConstants.PFR_ASCompDecisionFinalOui)){
                    for(Invoice__c currentInv : mapClaimNumberInvoices.get(currentCase.PFR_TECH_STDClaimNr__c)){
                        currentInv.CompensatedV2__c=true;
                        mapCOToUpdate.put(currentInv.Assessment__c,new assessment__c(Id=currentInv.Assessment__c,compensated__c=true));
                        if(mapCOToParentAss.containsKey(currentInv.Assessment__c) && mapCOToParentAss.get(currentInv.Assessment__c)!=null){
                            mapCOToUpdate.put(mapCOToParentAss.get(currentInv.Assessment__c),new assessment__c(Id=mapCOToParentAss.get(currentInv.Assessment__c),compensated__c=true));
                        }
                    }
                }else if(String.isBlank(currentCase.PFR_ASCompDecisionFinal__c)){
                    system.debug('PFR_ASCompDecisionFinal__c is null>>'+currentCase.PFR_ASCompDecisionFinal__c);
                    for(Invoice__c currentInv : mapClaimNumberInvoices.get(currentCase.PFR_TECH_STDClaimNr__c)){
                        currentInv.CompensatedV2__c=currentCase.PFR_ASCompDecisionEstim__c;
                        mapCOToUpdate.put(currentInv.Assessment__c,new assessment__c(Id=currentInv.Assessment__c,compensated__c=currentCase.PFR_ASCompDecisionEstim__c));
                        if(mapCOToParentAss.containsKey(currentInv.Assessment__c) && mapCOToParentAss.get(currentInv.Assessment__c)!=null){
                            mapCOToUpdate.put(mapCOToParentAss.get(currentInv.Assessment__c),new assessment__c(Id=mapCOToParentAss.get(currentInv.Assessment__c),compensated__c=currentCase.PFR_ASCompDecisionEstim__c));
                        }
                    }
                    currentCase.PFR_ASCompDecisionFinal__c=currentCase.PFR_ASCompDecisionEstim__c?ASPISConstants.PFR_ASCompDecisionFinalOui:ASPISConstants.PFR_ASCompDecisionFinalNon;
                    setCaseToUpdate.add(currentCase);
                }
            }
        }
        system.debug('setCaseToUpdate>>'+setCaseToUpdate);
        if(setCaseToUpdate.size()>0){
            Database.update(setCaseToUpdate,false);
        }
        system.debug('mapCOToUpdate>>'+mapCOToUpdate);
        if(!mapCOToUpdate.isEmpty()){
            Database.update(mapCOToUpdate.values(),false);
        }
    }
}