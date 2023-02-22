/*************************************************************************************
Class Name - AP15CalculateTotalExpAmtPurchaseOrder
Version - 1.0
Created Date - 06 OCT 2015
Function - Calculate Total Expected amount for PurchaseOrder

Modification Log :
-----------------------------------------------------------------------------
* Developer      		Date         Description
* ----------     	----------  -----------------------
* Brayan N          06/10/2015    Original Version
* Shamina M         04/02/2016    case 1514 - Corrected issue update failed: INSUFFICIENT_ACCESS_OR_READONLY
*************************************************************************************/
public class AP15CalculateTotalExpAmtPurchaseOrder { /*
	private final Static String OBJECTCODE = '-PO'; 
    private final Static String PROCESSNOTDELIVERED = '-NotDelivered';

	public static void updatePurchaseOrder(set <Id> setPOId){
        list<PurchaseOrder__c> listPOToUpdate = new list<PurchaseOrder__c>();
        List<Case__c> l_casesToInsert = new List<Case__c>();
        Double totalASPrice = 0;
        Double creditNotePrice = 0;
		
		//added by BNU 06102015
		Map<Id,List<OrderLine__c>> mapPoOl = new Map<Id,List<OrderLine__c>>();
		for (OrderLine__c ord : [select Id, AXATotalPrice__c, AcceptedCheck__c, PurchaseOrder__c,AdditionnalDiscount__c, (Select Id from AlternativeItem__r)
                                 from OrderLine__c 
                                 where AcceptedCheck__c = true
								 and PurchaseOrder__c in:setPOId
								 and DeliveryStatus__c = 'DELIVERED'
								 and TechGeneratedFinal__c = false])
		{
			if (ord.AlternativeItem__r.size() == 0)
			{
				if (mapPoOl.containsKey(ord.PurchaseOrder__c))
				{
					mapPoOl.get(ord.PurchaseOrder__c).add(ord);
				}else{
					List<OrderLine__c> oList = new List<OrderLine__c>();
					oList.add(ord);
					mapPoOl.put(ord.PurchaseOrder__c,oList);
				}
			}
		}

        for(PurchaseOrder__c po : [select Id,TotalExpectedAmount__c, TECH_BodyshopCountryCode__c, Distributor__c, Assessment__c,Status__c,PrerequisiteOrder__c, 
                                            
                                            (select Id, TotalNet__c 
                                             from Invoices__r
                                             where RecordTypeId =: Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId())
                                       from PurchaseOrder__c
                                       where Id in: setPOId]){
            if(mapPoOl.containsKey(po.Id)){
                for(OrderLine__c ol : mapPoOl.get(po.Id)){
                    totalASPrice += ol.AXATotalPrice__c;
                }
            }
			//////////////////
			/*
            if(po.Invoices__r != null && po.Invoices__r.size() > 0){
                for(Invoice__c inv : po.Invoices__r){
                    if(inv.TotalNet__c != null)
                        creditNotePrice += inv.TotalNet__c;
                }
            }*/
			////////////////////////////////
			/*
			//Dourga      01/10/2015
			if(po.Status__c != 'DELIVEREDCONFIRMED'){
				Case__c newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations(OBJECTCODE, po.TECH_BodyshopCountryCode__c, po.Distributor__c, po.Assessment__c, po.Id,  po.PrerequisiteOrder__c, null, UserInfo.getUserId(), PROCESSNOTDELIVERED);
				if(newCase != null)
                	l_casesToInsert.add(newCase);
			}

            po.TotalExpectedAmount__c = totalASPrice ;//- creditNotePrice;
            listPOToUpdate.add(po);
        }

        system.debug('##listPOToUpdate'+listPOToUpdate);
        if(listPOToUpdate.size() > 0)
            update listPOToUpdate;
		
		System.debug('## l_casesToInsert '+ l_casesToInsert.size());
		if(!l_casesToInsert.isEmpty())
        	ASPISWithoutSharingExceptions.insertListCases(l_casesToInsert);
    }*/

	// public static void updatePurchaseOrder(set <Id> setPOId, List<PurchaseOrder__c> listPO){
	// 	list<PurchaseOrder__c> listPOToUpdate = new list<PurchaseOrder__c>();
    //     List<Case__c> l_casesToInsert = new List<Case__c>();
    //     Double totalASPrice = 0;
    //     //Double creditNotePrice = 0;
		
	// 	//added by BNU 06102015
	// 	Map<Id,List<OrderLine__c>> mapPoOl = new Map<Id,List<OrderLine__c>>();
	// 	for (OrderLine__c ord : [select Id, AXATotalPrice__c, AcceptedCheck__c, PurchaseOrder__c,AdditionnalDiscount__c, (Select Id from AlternativeItem__r)
    //                              from OrderLine__c 
    //                              where AcceptedCheck__c = true
	// 							 and PurchaseOrder__c in:setPOId
	// 							 and DeliveryStatus__c = 'DELIVERED'
	// 							 and TechGeneratedFinal__c = false])
	// 	{
	// 		if (ord.AlternativeItem__r.size() == 0)
	// 		{
	// 			if (mapPoOl.containsKey(ord.PurchaseOrder__c))
	// 			{
	// 				mapPoOl.get(ord.PurchaseOrder__c).add(ord);
	// 			}else{
	// 				List<OrderLine__c> oList = new List<OrderLine__c>();
	// 				oList.add(ord);
	// 				mapPoOl.put(ord.PurchaseOrder__c,oList);
	// 			}
	// 		}
	// 	}

	// 	/*Map<Id,List<Invoice__c>> mapPoInv = new Map<Id,List<Invoice__c>>();
	// 	For(Invoice__c inv : [select Id,PurchaseOrder__c, TotalNet__c 
	// 							from Invoice__c 
	// 							where RecordTypeId =: Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId()
	// 							and PurchaseOrder__c in :setPOId])
	// 	{
	// 		If (mapPoInv.containsKey(inv.PurchaseOrder__c)){
	// 			mapPoInv.get(inv.PurchaseOrder__c).add(inv);
	// 		}else{
	// 			List<Invoice__c> invList = new List<Invoice__c>();
	// 			invList.add(inv);
	// 			mapPoInv.put(inv.PurchaseOrder__c,invList);
	// 		}
	// 	}*/

    //     for(PurchaseOrder__c po : listPO){
    //         if(mapPoOl.containsKey(po.Id)){
    //             for(OrderLine__c ol : mapPoOl.get(po.Id)){
    //                 totalASPrice += ol.AXATotalPrice__c;
    //             }
    //         }
    //         /*if(mapPoInv.containsKey(po.Id)){
    //             for(Invoice__c inv : mapPoInv.get(po.Id)){
    //                 if(inv.TotalNet__c != null)
    //                     creditNotePrice += inv.TotalNet__c;
    //             }
    //         }*/

    //         po.TotalExpectedAmount__c = totalASPrice; //- creditNotePrice;
	// 	}
	// }
	
	// public static void purchaseOrderToUpdate(set <Id> setPOId, List<PurchaseOrder__c> listPO){
	// 	list<PurchaseOrder__c> listPOToUpdate = new list<PurchaseOrder__c>();
    //     List<Case__c> l_casesToInsert = new List<Case__c>();
    //     Double totalASPrice = 0;
    //     //Double creditNotePrice = 0;
		
	// 	//added by BNU 06102015
	// 	Map<Id,List<OrderLine__c>> mapPoOl = new Map<Id,List<OrderLine__c>>();
	// 	for (OrderLine__c ord : [select Id, AXATotalPrice__c, AcceptedCheck__c, PurchaseOrder__c,AdditionnalDiscount__c, (Select Id from AlternativeItem__r)
    //                              from OrderLine__c 
    //                              where AcceptedCheck__c = true
	// 							 and PurchaseOrder__c in:setPOId
	// 							 and DeliveryStatus__c = 'DELIVERED'
	// 							 and TechGeneratedFinal__c = false])
	// 	{
	// 		if (ord.AlternativeItem__r.size() == 0)
	// 		{
	// 			if (mapPoOl.containsKey(ord.PurchaseOrder__c))
	// 			{
	// 				mapPoOl.get(ord.PurchaseOrder__c).add(ord);
	// 			}else{
	// 				List<OrderLine__c> oList = new List<OrderLine__c>();
	// 				oList.add(ord);
	// 				mapPoOl.put(ord.PurchaseOrder__c,oList);
	// 			}
	// 		}
	// 	}
		
	// 	for(PurchaseOrder__c po : listPO){
    //         if(mapPoOl.containsKey(po.Id)){
    //             for(OrderLine__c ol : mapPoOl.get(po.Id)){
    //                 totalASPrice += ol.AXATotalPrice__c;
    //             }
    //         }
    //         po.TotalExpectedAmount__c = totalASPrice; //- creditNotePrice;
	// 		listPOToUpdate.add(new PurchaseOrder__c(Id = po.Id, TotalExpectedAmount__c = totalASPrice));
	// 	}
		
    //     //Shamina M-case 1514 - calling existing method from ASPISWithoutSharingExceptions to prevent insufficient rights
	// 	if(listPOToUpdate.size() > 0){
	// 		ASPISWithoutSharingExceptions.updatePurchaseOrderList(listPOToUpdate);
    //         //update listPOToUpdate;
	// 	}
	// }

	// ----------------------------------------------- NEW VERSION -----------------------------------------------
	public static void updatePurchaseOrder(List<PurchaseOrder__c> purchaseOrderList)
	{
		Map<Id, List<OrderLine__c>> mapPurchaseOrderIdOrderLines = new Map<Id, List<OrderLine__c>>();

		for(OrderLine__c currentOrderLine : [SELECT Id, AXATotalPrice__c, PurchaseOrder__c, 
													(SELECT Id 
													 FROM	AlternativeItem__r)
											 FROM	OrderLine__c
											 WHERE	AcceptedCheck__c = true
											 AND	PurchaseOrder__c IN: purchaseOrderList
											 AND	DeliveryStatus__c = 'DELIVERED'
											 AND    OrderType__c != 'SHIPPING COST'
											 AND	TechGeneratedFinal__c = false])
		{
			if(currentOrderLine.AlternativeItem__r.size() == 0)
			{
				// Check if the Offer's sales order is already present in the map
				if(mapPurchaseOrderIdOrderLines.containsKey(currentOrderLine.PurchaseOrder__c))
				{
					mapPurchaseOrderIdOrderLines.get(currentOrderLine.PurchaseOrder__c).add(currentOrderLine);
				}
				else
				{
					mapPurchaseOrderIdOrderLines.put(currentOrderLine.PurchaseOrder__c, new List<OrderLine__c>{currentOrderLine});
				}
			}
		}

		for(PurchaseOrder__c currentPurchaseOrder : purchaseOrderList)
		{
			// Set the total expected amount to 0 before calculating it using the offers in the map
			// It also sets the total expected amount to 0 even if there are no offers satisfying the conditions above
			currentPurchaseOrder.TotalExpectedAmount__c = 0;

			// Check if the currentPurchaseOrder exists in the map mapPurchaseOrderIdOrderLines
			if(mapPurchaseOrderIdOrderLines.containsKey(currentPurchaseOrder.Id))
			{
				// Loop in the offers of that SO and populate the field total expected amount
				for(OrderLine__c currentOrderLine : mapPurchaseOrderIdOrderLines.get(currentPurchaseOrder.Id))
				{
					currentPurchaseOrder.TotalExpectedAmount__c += currentOrderLine.AXATotalPrice__c;
				}
			}
		}
	}

	public static Map<Id, PurchaseOrder__c> purchaseOrderToUpdate(Set<Id> purchaseOrderIdSet)
	{
        Map<Id, List<OrderLine__c>> mapPurchaseOrderIdOrderLines = new Map<Id, List<OrderLine__c>>();

		for(OrderLine__c currentOrderLine : [SELECT Id, AXATotalPrice__c, PurchaseOrder__c, 
													(SELECT Id 
													 FROM	AlternativeItem__r)
											 FROM	OrderLine__c
											 WHERE	AcceptedCheck__c = true
											 AND	PurchaseOrder__c IN: purchaseOrderIdSet
											 AND	DeliveryStatus__c = 'DELIVERED'
											 AND    OrderType__c != 'SHIPPING COST'
											 AND	TechGeneratedFinal__c = false])
		{
			if(currentOrderLine.AlternativeItem__r.size() == 0)
			{
				// Check if the Offer's sales order is already present in the map
				if(mapPurchaseOrderIdOrderLines.containsKey(currentOrderLine.PurchaseOrder__c))
				{
					mapPurchaseOrderIdOrderLines.get(currentOrderLine.PurchaseOrder__c).add(currentOrderLine);
				}
				else
				{
					mapPurchaseOrderIdOrderLines.put(currentOrderLine.PurchaseOrder__c, new List<OrderLine__c>{currentOrderLine});
				}
			}
		}

        Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdate = new Map<Id, PurchaseOrder__c>();

		for(Id purchaseOrderId : purchaseOrderIdSet)
		{
			// Set the total expected amount to 0 before calculating it using the order lines in the map
			// It also sets the total expected amount to 0 even if there are no order lines satisfying the conditions above
			PurchaseOrder__c currentPurchaseOrder = new PurchaseOrder__c(	Id						= purchaseOrderId,
																			TotalExpectedAmount__c	= 0);

			// Check if the currentPurchaseOrder exists in the map mapPurchaseOrderIdOrderLines
			if(mapPurchaseOrderIdOrderLines.containsKey(purchaseOrderId))
			{
				// Loop in the offers of that SO and populate the field total expected amount
				for(OrderLine__c currentOrderLine : mapPurchaseOrderIdOrderLines.get(currentPurchaseOrder.Id))
				{
					currentPurchaseOrder.TotalExpectedAmount__c += currentOrderLine.AXATotalPrice__c;
				}
			}

			mapPurchaseOrderToUpdate.put(purchaseOrderId, currentPurchaseOrder);
		}
		
        return mapPurchaseOrderToUpdate;
	}
}