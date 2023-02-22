/*************************************************************************************
Class Name - AP14SetSOStatus
Version - 1.0
Created Date - 06 OCT 2015
Function - Au moins 1 facture réparateur émise (statut Envoyé. on a le N° de facture envoyé par Cegedim) => le statut du SO passe à "Facturé"
         - Toutes les factures associées au SO sont "Payé" => le SO passe à "Payé"

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date         Description
* ----------        ----------  -----------------------
* Ashwina Seetaram    06/10/2015    C-001254: Original Version
*************************************************************************************/
public with sharing class AP14SetSOStatus{
    // ABT Commented 23-NOV-2016 - C-001677
    //Au moins 1 facture réparateur émise (statut Envoyé. on a le N° de facture envoyé par Cegedim) => le statut du SO passe à "Facturé"
    // public static void updateSalesOrderInvoiced(set<Id> SOIdSet){
    //  List<PrerequisiteOrder__c> updatedSOList = new List<PrerequisiteOrder__c>();

    //  //looping in SOIdSet and update the salesOrder to Invoiced
    //  for(String SOId:SOIdSet){
    //      PrerequisiteOrder__c updatedSO = new PrerequisiteOrder__c(status__c='INVOICED', Id =SOId);
    //      updatedSOList.add(updatedSO);
    //  }

    //  //updating updatedSOList
    //  if(updatedSOList.size()>0){
    //      update updatedSOList;
    //  }
    // }

    // Toutes les factures associées au SO sont "Payé" => le SO passe à "Payé"
    // C-001888 : @future to avoid Apex CPU time limit exceeded
    // ABT 13-JUN-2017 - Commented on Jonathan request
    // @future
    // public static void updateSalesOrderPaidAsync(Set<Id> SOIdSet)
    // {
    //     updateSalesOrderPaid(SOIdSet);
    // }

    // public static void updateSalesOrderPaid(set<Id> SOIdSet){
    //     Map<String, List<String>> paidInvMap = new Map<String, List<String>>();
    //     List<PrerequisiteOrder__c> updatedSOList = new List<PrerequisiteOrder__c>();

    //     // build map of <Sales Order, list of invoices status> based on AggregateResult function
    //     for(AggregateResult ar: [select count(id) invSize, PrerequisiteOrder__c,Status__c from invoice__c where PrerequisiteOrder__c IN:SOIdSet GROUP BY PrerequisiteOrder__c, Status__c ORDER BY PrerequisiteOrder__c]){
    //         if(!paidInvMap.containsKey((String)ar.get('PrerequisiteOrder__c'))){
    //             List<String> statusList = new List<String>();
    //             statusList.add((String) ar.get('Status__c'));
    //             paidInvMap.put((String) ar.get('PrerequisiteOrder__c'), statusList);
    //         }
    //         else{
    //             paidInvMap.get((String) ar.get('PrerequisiteOrder__c')).add((String) ar.get('Status__c'));
    //         }
    //     }

    //     //looping in map paidInvMap to update status of SOs which has all its invoices's status set to PAID
    //     for(String SOId:paidInvMap.keySet()){
    //         if(paidInvMap.get(SOId).size()==1 && paidInvMap.get(SOId).get(0).trim()=='PAID'){
    //             PrerequisiteOrder__c updatedSO = new PrerequisiteOrder__c(status__c='PAID', Id =SOId);
    //             updatedSOList.add(updatedSO);
    //         }
    //     }

    //     //updating updatedSOList
    //     if(updatedSOList.size()>0){
    //         update updatedSOList;
    //     }
    // }

    //public static void updateSalesOrderPaidV2(Set<Id> SOIdSet)
    //{
    //  Map<Id, List<String>> mapInvoiceStatus      = new Map<Id, List<String>>();
    //  List<PrerequisiteOrder__c> updatedSOList    = new List<PrerequisiteOrder__c>();
    //
    //  // build map of <Sales Order, list of invoices status> based on AggregateResult function
    //  for(AggregateResult ar: [SELECT count(id) invSize, PrerequisiteOrder__c, Status__c
    //                           FROM   Invoice__c
    //                           WHERE  PrerequisiteOrder__c IN: SOIdSet
    //                           GROUP BY PrerequisiteOrder__c, Status__c
    //                           ORDER BY PrerequisiteOrder__c])
    //  {
    //      if(!mapInvoiceStatus.containsKey((Id) ar.get('PrerequisiteOrder__c')))
    //      {
    //          List<String> statusList = new List<String>();
    //          statusList.add((String) ar.get('Status__c'));
    //          mapInvoiceStatus.put((Id) ar.get('PrerequisiteOrder__c'), statusList);
    //      }
    //      else
    //      {
    //          mapInvoiceStatus.get((Id) ar.get('PrerequisiteOrder__c')).add((String) ar.get('Status__c'));
    //      }
    //  }
    //
    //  //looping in map mapInvoiceStatus to update status of SOs which has all its invoices's status set to PAID
    //  for(Id SOId:mapInvoiceStatus.keySet())
    //  {
    //      if( mapInvoiceStatus.get(SOId).size() == 1 && 
    //          mapInvoiceStatus.get(SOId).get(0).trim() == 'PAID')
    //      {
    //          PrerequisiteOrder__c updatedSO = new PrerequisiteOrder__c(  Status__c   = 'PAID', 
    //                                                                      Id          = SOId);
    //          updatedSOList.add(updatedSO);
    //      }
    //  }
    //
    //  //updating updatedSOList
    //  if(updatedSOList.size()>0)
    //  {
    //      update updatedSOList;
    //  }
    //}

    // C-001888 : @future to avoid Apex CPU time limit exceeded
    // ABT - 05-JUL-2017 - C-001938 - Commented as it is no more called in trigger
    // @future
    // public static void updateSalesOrderInvoicedV2Async(Set<Id> salesOrderIdSet)
    // {
    //     updateSalesOrderInvoicedV2(salesOrderIdSet);
    // }

    // public static void updateSalesOrderInvoicedV2(Set<Id> salesOrderIdSet)
    // {
    //     List<PrerequisiteOrder__c> salesOrderToUpdateList = new List<PrerequisiteOrder__c>();

    //     // Loop in the sales order having invoice as sent
    //     // Removinge the sales order that are already in canceled invoice as it does not need to be updated
    //     for(PrerequisiteOrder__c currentSalesOrder : [  SELECT  Id, Status__c
    //                                                     FROM    PrerequisiteOrder__c
    //                                                     WHERE   Id IN: salesOrderIdSet
    //                                                     AND     Status__c !=: ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE])
    //     {
    //         // check if the current status of the sales order is closedko
    //         if(currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO)
    //         {
    //             // Reopen the sales order to canceled invoice
    //             currentSalesOrder.Status__c = ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE;
    //         }
    //         else
    //         {
    //             // for other status set them to INVOICED even it was in closedOK
    //             currentSalesOrder.Status__c = ASPISConstants.PRE_ORDER_STATUS_INVOICED;
    //         }

    //         salesOrderToUpdateList.add(currentSalesOrder);
    //     }

    //     if(salesOrderToUpdateList.size() > 0)
    //     {
    //         update salesOrderToUpdateList;
    //     }
    // }

    // ABT - 06-DEC-2016 - C-001677
    // C-001888 : @future to avoid Apex CPU time limit exceeded
    // ABT 13-JUN-2017 - Commented on Jonathan request
    // @future
    // public static void updateSpanishSalesOrderAsync(Set<Id> salesOrderIdSet)
    // {
    //     updateSpanishSalesOrder(salesOrderIdSet);
    // }

    // public static void updateSpanishSalesOrder(Set<Id> salesOrderIdSet)
    // {
    //     List<PrerequisiteOrder__c> spanishSalesOrderToUpdate = new List<PrerequisiteOrder__c>();

    //     for(PrerequisiteOrder__c currentSalesOrder : [  SELECT  Id, Status__c,
    //                                                             (SELECT Id, InvoiceSent__c
    //                                                              FROM   Invoices__r
    //                                                              WHERE  ParentInvoice__c != null)
    //                                                     FROM    PrerequisiteOrder__c
    //                                                     WHERE   Id IN: salesOrderIdSet
    //                                                     AND     TECH_BodyshopCountryCode__c = 'ES'
    //                                                     FOR UPDATE])
    //     {
    //         Integer invoiceSentTrueCounter = 0;

    //         for(Invoice__c currentInvoice : currentSalesOrder.Invoices__r)
    //         {
    //             if(currentInvoice.InvoiceSent__c)
    //             {
    //                 invoiceSentTrueCounter++;
    //             }
    //         }

    //         if( invoiceSentTrueCounter > 0 && 
    //             invoiceSentTrueCounter == currentSalesOrder.Invoices__r.size())
    //         {
    //             if(currentSalesOrder.Status__c == ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE)
    //             {
    //                 spanishSalesOrderToUpdate.add(new PrerequisiteOrder__c(Id = currentSalesOrder.Id,
    //                                                                         Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO));
    //             }
    //             else
    //             {
    //                 spanishSalesOrderToUpdate.add(new PrerequisiteOrder__c(Id = currentSalesOrder.Id,
    //                                                                         Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK));
    //             }
    //         }
    //     }

    //     if(spanishSalesOrderToUpdate.size() > 0)
    //     {
    //         update spanishSalesOrderToUpdate;
    //     }
    // }
}