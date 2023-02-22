/*************************************************************************************
Class Name - AP16CalcTotalExpAmtSalesOrder
Version - 1.0
Created Date - 07 OCT 2015
Function - Calculate Total Expected amount for SalesOrder

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date         Description
* ----------        ----------  -----------------------
* Brayan N          07/10/2015    Original Version
* Shamina M         17/02/2016    C-001518: Removed unnecessary debug logs
*************************************************************************************/
public with sharing class AP16CalcTotalExpAmtSalesOrder { 
    //@future
    // public static void updateSalesOrder(set<Id> salesOrderIdSet){
    //     system.debug('########### updateSalesOrder Start salesOrderIdSet');
    //     list <PrerequisiteOrder__c> salesOrderList = new list <PrerequisiteOrder__c>();
    //     Double totalBSPrice = 0;

    //     Map<Id,List<Offer__c>> mapSoOff = new Map<Id,List<Offer__c>>();
    //     for (Offer__c o : [select Id, BSTotalPrice__c, Accepted__c,Prerequisiteorder__c
    //                        from Offer__c 
    //                        where Accepted__c = 'YES'
    //                        and DeliveryStatus__c = 'DELIVERED'
    //                        and Prerequisiteorder__c in :salesOrderIdSet
    //                        and ParentOffer__c=null]){
    //         if(mapSoOff.containsKey(o.Prerequisiteorder__c)){
    //             mapSoOff.get(o.Prerequisiteorder__c).add(o);
    //         }
    //         else{
    //             List<Offer__c> oList = new List<Offer__c>();
    //             oList.add(o);
    //             mapSoOff.put(o.Prerequisiteorder__c,oList);
    //         }
    //     }

    //     for(Id so: mapSoOff.keyset()){            
    //         totalBSPrice = 0;
    //         for(Offer__c off : mapSoOff.get(so)){
    //             totalBSPrice += off.BSTotalPrice__c;
    //         }            
    //         salesOrderList.add(new Prerequisiteorder__c(Id= so, TotalExpectedAmount__c = totalBSPrice ));            
    //     }

    //     if(salesOrderList.size() > 0){
    //         update salesOrderList;
    //     }
    //     system.debug('########### updateSalesOrder End salesOrderIdSet');        
    // }


    /**
     * Function to take a set of SO Ids and return a list of SO with total expected amount. Used for the batch ASPISBatchCreateInvoiceAddDis
     * @param  salesOrderIdSet The set of sales Order Id that will have the total expected amount calculated
     * @return                 The list of sales order with Total Expected Amount populated
     */
    public static List<PrerequisiteOrder__c> updateSalesOrder(Set<Id> salesOrderIdSet)
    {
        List<PrerequisiteOrder__c> salesOrderToUpdateList = new List<PrerequisiteOrder__c>();

        for(Id currentSalesOrderId : salesOrderIdSet)
        {
            salesOrderToUpdateList.add(new PrerequisiteOrder__c(Id = currentSalesOrderId));
        }

        // Check if the size of salesOrderToUpdateList > 0 and populate the total expected amount of the so
        if(salesOrderToUpdateList.size() > 0)
        {
            updateSalesOrder(salesOrderToUpdateList);
        }

        return salesOrderToUpdateList;
    }

    // ABT Commented 23-NOV-2016 - C-001677
    // public static void updateSalesOrder(set<Id> salesOrderIdSet, List<PrerequisiteOrder__c> soLIst){
    //     system.debug('########### updateSalesOrder Start salesOrderIdSet, soLIst');
    //     list <PrerequisiteOrder__c> salesOrderList = new list <PrerequisiteOrder__c>();
    //     Double totalBSPrice = 0;
    //     Double creditNotePrice = 0;

    //     Map<Id,List<Offer__c>> mapSoOf = new Map<Id,List<Offer__c>>();
    //     /*for (Offer__c o : [select Id, BSTotalPrice__c, Accepted__c,Prerequisiteorder__c,(Select Id from Offers__r)
    //                        from Offer__c 
    //                        where Accepted__c = 'YES'
    //                        and DeliveryStatus__c = 'DELIVERED'
    //                        and Prerequisiteorder__c in :salesOrderIdSet])*/
    //     for (Offer__c o : [select Id, BSTotalPrice__c, Accepted__c,Prerequisiteorder__c
    //                        from Offer__c 
    //                        where Accepted__c = 'YES'
    //                        and DeliveryStatus__c = 'DELIVERED'
    //                        and Prerequisiteorder__c in :salesOrderIdSet
    //                        and ParentOffer__c=null])
    //     {
    //         //if (o.Offers__r.size() == 0)
    //         //{
    //             if(mapSoOf.containsKey(o.Prerequisiteorder__c)){
    //                 mapSoOf.get(o.Prerequisiteorder__c).add(o);
    //             }else{
    //                 List<Offer__c> oList = new List<Offer__c>();
    //                 oList.add(o);
    //                 mapSoOf.put(o.Prerequisiteorder__c,oList);
    //             }    
    //         //}
    //     }

    //     /*Map<Id,List<Invoice__c>> mapSoInv = new Map<Id,List<Invoice__c>>();
    //     For(Invoice__c inv : [select Id,PrerequisiteOrder__c, TotalNet__c 
    //                             from Invoice__c 
    //                             where RecordTypeId =: Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId()
    //                             and PrerequisiteOrder__c in :salesOrderIdSet])
    //     {
    //         If (mapSoInv.containsKey(inv.PrerequisiteOrder__c)){
    //             mapSoInv.get(inv.PrerequisiteOrder__c).add(inv);
    //         }else{
    //             List<Invoice__c> invList = new List<Invoice__c>();
    //             invList.add(inv);
    //             mapSoInv.put(inv.PrerequisiteOrder__c,invList);
    //         }
    //     }*/

    //     for(PrerequisiteOrder__c so : soLIst){
    //         if(mapSoOf.containsKey(so.Id)){
    //             for(Offer__c off : mapSoOf.get(so.Id)){
    //                 totalBSPrice += off.BSTotalPrice__c;
    //             }
    //         }
    //         /*if(mapSoInv.containsKey(so.Id)){
    //             for(Invoice__c inv : mapSoInv.get(so.Id)){
    //                 if(inv.TotalNet__c != null)
    //                     creditNotePrice += inv.TotalNet__c;
    //             }
    //         }*/
             
    //         so.TotalExpectedAmount__c = totalBSPrice; //- creditNotePrice;
    //         system.debug('########### updateSalesOrder End salesOrderIdSet, soLIst');
        
    //     }
    // }

	// ----------------------------------------------- NEW VERSION -----------------------------------------------
	public static void updateSalesOrder(List<PrerequisiteOrder__c> salesOrderList)
	{
		Map<Id, List<Offer__c>> mapSalesOrderIdOffers = new Map<Id, List<Offer__c>>();

		// Retrieve the offers of the salesOrder passed.
		// Put the offers in the map mapSalesOrderIdOffers according to their salesOrder
		for (Offer__c off : [	SELECT	Id, BSTotalPrice__c, Accepted__c, Prerequisiteorder__c
								FROM	Offer__c
								WHERE	Accepted__c = 'YES'
								AND		DeliveryStatus__c = 'DELIVERED'
								AND		Prerequisiteorder__c IN: salesOrderList
								AND		ParentOffer__c = null])
		{
			// Check if the Offer's sales order is already present in the map
			if(mapSalesOrderIdOffers.containsKey(off.Prerequisiteorder__c))
			{
				mapSalesOrderIdOffers.get(off.Prerequisiteorder__c).add(off);
			}
			else
			{
				mapSalesOrderIdOffers.put(off.Prerequisiteorder__c, new List<Offer__c>{off});
			}
		}

		for(PrerequisiteOrder__c currentSalesOrder : salesOrderList)
		{
			// Set the total expected amount to 0 before calculating it using the offers in the map
			// It also sets the total expected amount to 0 even if there are no offers satisfying the conditions above
			currentSalesOrder.TotalExpectedAmount__c = 0;

			// Check if the currentSalesOrder exists in the map mapSalesOrderIdOffers
			if(mapSalesOrderIdOffers.containsKey(currentSalesOrder.Id))
			{
				// Loop in the offers of that SO and populate the field total expected amount
				for(Offer__c off : mapSalesOrderIdOffers.get(currentSalesOrder.Id))
				{
					currentSalesOrder.TotalExpectedAmount__c += off.BSTotalPrice__c;
				}
			}
		}
	}
}