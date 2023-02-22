/*************************************************************************************
Class Name - AP13SetPOStatus
Version - 1.0
Created Date - 09 Dec 2015
Function -  Exponens met à jour les facture distributeur au statut "payé" quand le paiement a eté effectué
=> besoin d'ajouter une statut "payé" sur le PO correspondant, pour etre coherent avec la facture associée,
de la mme maniere que pour les SO

Modification Log :
---------------------------------------------------------------------------------------------------------------------
* Developer             Date         Description
* ----------        ----------  -----------------------
* Ashwina Seetaram    09/12/2015  C-001405: Nouveau statut "payé"
* Ashwina S           05/01/2015  Modify RESTCreateDistributorInvoice_V1 to set field TechToBeProcessed__c to True
* Ashwina S           18/01/17 : C-001860 status changes from payable to delivered Confirmed when atleast an OL is cancelled, and atleast one is delivered 
* Dourga              12/06/2018  C-002214 : Invoices Spain
* Neha P              18/10/2021  C-004496 : Total Invoices is not recalculated if PO is in status PAYABLE
*********************************************************************************************************************/
public with sharing class AP13SetPOStatus{ 
    /*public static void updatePurchaseOrder(Set<Id> POIdSet){
        System.debug('######## POIdSet:'+POIdSet);
        Map<String, List<String>> payableInvMap = new Map<String, List<String>>();
        Map<String, String> previousStatusMap = new Map<String, String>();
        List<PurchaseOrder__c> updatedPOList = new List<PurchaseOrder__c>();

        // build a map of POid and a list of its related invoices' status
        for(AggregateResult ar: [select count(id) invSize, PurchaseOrder__c,Status__c from invoice__c where PurchaseOrder__c IN:POIdSet GROUP BY PurchaseOrder__c, Status__c ORDER BY PurchaseOrder__c]){
            if(!payableInvMap.containsKey((String)ar.get('PurchaseOrder__c'))){
                List<String> statusList = new List<String>();
                statusList.add((String) ar.get('Status__c'));
                payableInvMap.put((Id) ar.get('PurchaseOrder__c'), statusList);
            }
            else{
                payableInvMap.get((Id) ar.get('PurchaseOrder__c')).add((String) ar.get('Status__c'));
            }
        } 
        System.debug('############# payableInvMap:'+payableInvMap);
        //looping in map payableInvMap to update status of POs which has all its invoices's status set to PAID
        if(payableInvMap.size()>0){
            for(Id POId:payableInvMap.keySet()){
                if(payableInvMap.get(POId).size()>1){
                    PurchaseOrder__c updatedPO = new PurchaseOrder__c(status__c= 'PAYABLE', Id =POId);
                    updatedPOList.add(updatedPO);
                }
                else{
                    if(payableInvMap.get(POId).size()==1 && payableInvMap.get(POId).get(0)!=null){
                        if(payableInvMap.get(POId).get(0).trim()=='PAID'){
                            PurchaseOrder__c updatedPO = new PurchaseOrder__c(status__c='PAID', Id =POId);
                            updatedPOList.add(updatedPO);
                        }
                    }
                }
            }
            System.debug('####### updatedPOList:'+updatedPOList);
            //updating updatedPOList
            if(updatedPOList.size()>0){
                update updatedPOList;
            }
        }

    }*/

    // method added by Ashwina Seetaram on 05/01/2015
    // after insert of invoices of type distributor, set TechToBeProcessed__c on its PO to true
    // ABT Commented 23-NOV-2016 - C-001677
    // public static void updatePurchaseOrderField(Set<Id> POIdSet){
    //  list<PurchaseOrder__c> POList = new LIST<PurchaseOrder__c>();

    //  for(PurchaseOrder__c PO: [Select TechToBeProcessed__c from PurchaseOrder__c where id in :POIdSet]){
    //      if(PO.TechToBeProcessed__c!= true){
    //          POList.add(new PurchaseOrder__c(Id = PO.Id, TechToBeProcessed__c =true));
    //      }
    //  }

    //  if(POList.size()>0){
    //      update POList;
    //  }
    // }

    // C-001677 17-OCT-2016
    // C-001888 : @future to avoid Apex CPU time limit exceeded
    @future
    public static void reopenPurchaseOrderAsync(Set<Id> purchaseOrderIdSet)
    {
        reopenPurchaseOrder(purchaseOrderIdSet);
    }

    public static void reopenPurchaseOrder(Set<Id> purchaseOrderIdSet)
    {
        // List of purchase order to update
        List<PurchaseOrder__c> purchaseOrderToUpdateList = new List<PurchaseOrder__c>();

        // Loop in the purchase orders
        for(PurchaseOrder__c currentPurchaseOrder : [SELECT Id, Status__c
                                                    FROM    PurchaseOrder__c
                                                    WHERE   Id IN: purchaseOrderIdSet
                                                    AND     (   Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK
                                                            OR  Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)])
        {
            if(currentPurchaseOrder.Status__c == ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO)
            {
                currentPurchaseOrder.Status__c = ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE;
            }
            else
            {
                // currentPurchaseOrder is in CLOSEDOK
                // ABT - C-001938 - Changed PAYABLE to DELIVEREDCONFIRMED
                currentPurchaseOrder.Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
            }

            currentPurchaseOrder.InvoiceStatus__c       = null;
            currentPurchaseOrder.TotalInvoicesAmount__c = null;

            purchaseOrderToUpdateList.add(currentPurchaseOrder);
        }

        if(purchaseOrderToUpdateList.size() > 0)
        {
            update purchaseOrderToUpdateList;
        }
    }

    // C-001888 : @future to avoid Apex CPU time limit exceeded
    @future
    public static void reopenPurchaseOrderWithCanceledOrderLineAsync(Set<Id> purchaseOrderIdSet)
    {
        reopenPurchaseOrderWithCanceledOrderLine(purchaseOrderIdSet);
    }

    public static void reopenPurchaseOrderWithCanceledOrderLine(Set<Id> purchaseOrderIdSet)
    {
        // List of purchase order to update
        List<PurchaseOrder__c> purchaseOrderToUpdateList = new List<PurchaseOrder__c>();

        // Loop in the purchase orders
        for(PurchaseOrder__c currentPurchaseOrder : [   SELECT  Id, Status__c
                                                        FROM    PurchaseOrder__c
                                                        WHERE   Id IN: purchaseOrderIdSet
                                                        AND     (Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK
                                                        // ASE C-001860 18/01/17 : status changes from payable to delivered Confirmed when atleast an OL is cancelled, and atleast one is delivered 
                                                                 OR Status__c =: ASPISConstants.PUR_ORDER_STATUS_PAYABLE)
                                                        //DUN 05/06/2018 case 2214 
                                                        AND AgencyMode__c = false])
        {
            
            currentPurchaseOrder.Status__c              = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
            currentPurchaseOrder.InvoiceStatus__c       = null;
            currentPurchaseOrder.TotalInvoicesAmount__c = null;

            purchaseOrderToUpdateList.add(currentPurchaseOrder);
        }

        if(purchaseOrderToUpdateList.size() > 0)
        {
            update purchaseOrderToUpdateList;
        }
    }

    //NPE 18/10/2021 C-004496
    public static void updatePoTotalExpectedAmount(Set<Id> purchaseOrderIdSet)
    {
        List<PurchaseOrder__c> lstUpdateTotalExpectedAmount = new List<PurchaseOrder__c>(); 
        //Loop in the purchase orders to select id and Recalculate_total_expected_amount__c
        for(PurchaseOrder__c po: [Select id, Recalculate_total_expected_amount__c
                                        From PurchaseOrder__c 
                                        where id IN:purchaseOrderIdSet ]){
                                            
                //change Recalculate_total_expected_amount__c to true
                lstUpdateTotalExpectedAmount.add(new PurchaseOrder__c (id = po.id, Recalculate_total_expected_amount__c = true));
        }
        if (lstUpdateTotalExpectedAmount.size() >0 ){
            update lstUpdateTotalExpectedAmount;
        }
    }
}