/*
----------------------------------------------------------------------
-- - Name          : OrderLineTriggerHandler
-- - Author        : ABT
-- - Description   : Handler for the trigger OrderLineTriggerHandler
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 08-OCT-2016	ABT		1.0    Initial version
-- 18-JAN-2017  ASE     1.1    case 1860: status changes from payable to delivered Confirmed when atleast an OL is cancelled, and atleast one is delivered 
-- 05-MAY-2017	DUN     1.2    case 1905: set BodyShop Discount for Germany 
-- 17-JAN-2019  RLA     1.3    C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
----------------------------------------------------------------------
-- Flow of OrderLineTriggerHandler:
--	ORDERLINE TRIGGER HANDLER
--	
--	- BEFORE INSERT
--		
--		Nothing
--		
--	- AFTER INSERT
--		
--		-> if CataloguePrice__c is not null or AssessmentPrice__c is not null -- if CataloguePrice__c > AssessmentPrice__c --> Create Case for Purchase Order
--		
--	- BEFORE UPDATE
--		
--		-> if (TECH_ExtraAS__c has changed and it is not null)  or (AXADiscount__c has changed and it is not null) -- Populate the BodyShopDiscount__c
--		-> if AdditionalDiscount__c has changed and it is not null -- Set TECH_ToBeProcessed__c to true
--		
--	- AFTER UPDATE
--	
--		-> if (EstimatedDeliveryDate__c has changed) or (DeliveryStatus__c has changed and the new value is DELIVERED or CANCELED or INDELIVERY or DELAYED) --> get the offers and update thier ExpectedDeliveryDate__c and DeliveryStatus__c is needed
--		-> if (TECH_ExtraAS__c has changed and it is not null)  or (AXADiscount__c has changed and it is not null) -- if TECH_ExtraAS__c + AXADiscount__c < TECHASLowLevel__c --> Create Case
--		-> if CataloguePrice__c is not null or AssessmentPrice__c is not null -- if CataloguePrice__c > AssessmentPrice__c --> Create Case for Purchase Order
--		-> if (AdditionalDiscount__c has changed and it is not null nor 0) or (DeliveryStatus__c has changed and DeliveryStatus__c is RETURNED or CANCELED) -> Update the total expected amount of the purchase order
--
----------------------------------------------------------------------
-- Previous Class History
----------------------------------------------------------------------
-- Developer	Date        Description
-- ----------	----------  -----------------------
-- Joao Dias	02/04/2015  Original Version
-- Joao Dias	08/04/2015  Changing Accepted(YES/NO/Blank) to AcceptedCheck(true/false) checkbox
-- Cecile L 	12/06/2015  Update Offers when Estimated delivery date is modified on Order Lines
-- Dourga U 	20/08/2015  Added code to create log in catch part
-- Dourga U 	14/10/2015  Added code for case 1306 in before insert and before update
-- Dourga U 	15/10/2015  Added code for case 1305 in after insert and after update
-- Dourga U 	19/11/2015  Added code for case 1385 in after insert and after update
-- Dourga U 	08/12/2015  Added code for case 1390 in after update to update invoice
-- Dourga U 	28/01/2016  Added code for update in case 1390 -- moved logic in batch
-- 							and added code in before update
-- Dourga U		09/03/2016  Added code for case C-001560
-- Ashwina S	02/09/2016  case C-001713: commented fillBSDiscountField on before insert
-- Dourga U		08/11/2017  case C-002055: Discount for Total Loss Assessment\
-- Vaynee S     06/03/2018  Case C-002284: OrderLineTrigger : Bodyshop discount too large
-- Dourga U     13/03/2018  Case C-002383: BE : Bug sur les changements de pièces
-- Dourga U     19/06/2018  Case C-002313: Copying AcceptedByBS and PreSelectedForOrder on Bundles
-- Dourga U     31/08/2018  Case C-001895 : Spare Part Recovery
-- Abdool M     05/10/2018  Case C-002045 - Advance case management - Update offer status (managed) to that of orderline   
**********************************************************************
*/
public without sharing class OrderLineTriggerHandler 
{
	// ABT - 16-FEB-2017 - C-001816
	public static Boolean hasOnBeforeUpdateRun = false;

	public OrderLineTriggerHandler()
	{
	}

	public void onBeforeInsert(List<OrderLine__c> newOrderLineList)
	{
		System.debug('-------------------------- START METHOD OrderLineTriggerHandler - onBeforeInsert --------------------------');

		//DUN 05/05/2017 case 1905 
		Map<Id, List<OrderLine__c>> mapAP31POIdlistOLDE = new Map<Id, List<OrderLine__c>>();
		Set<Id> setAP31DiscountIdDE = new Set<Id>();

		//DUN 08/03/2018: C-002383 Bug BE discount not displayed for alternatives on SO
		Map<Id, List<OrderLine__c>> ap31MapPurchaseOrderOrderLines	= new Map<Id, List<OrderLine__c>>();

		//DUN 19/06/2018  Case C-002313: Copying AcceptedByBS and PreSelectedForOrder on Bundles
		map <Id, list<OrderLine__c>> mapParentIdListOrderlines = new map <Id, list<OrderLine__c>>();

		for(Integer i = 0; i < newOrderLineList.size(); i++)
		{
			if(	newOrderLineList[i].PurchaseOrder__c != null && newOrderLineList[i].AXADiscount__c != null && newOrderLineList[i].Discount__c != null)
			{
				if(!mapAP31POIdlistOLDE.containsKey(newOrderLineList[i].PurchaseOrder__c))
				{
					mapAP31POIdlistOLDE.put(newOrderLineList[i].PurchaseOrder__c, new List<OrderLine__c>{newOrderLineList[i]});
				}
				else
				{
					mapAP31POIdlistOLDE.get(newOrderLineList[i].PurchaseOrder__c).add(newOrderLineList[i]);
				}
				setAP31DiscountIdDE.add(newOrderLineList[i].Discount__c);
			}
			//DUN 08/03/2018 C-002383 : Bug BE discount not displayed for alternatives on SO
			if(	newOrderLineList[i].PurchaseOrder__c != null &&
			   (newOrderLineList[i].TECH_ExtraAS__c != null || newOrderLineList[i].AXADiscount__c != null))
			{
				system.debug('##TECH_ExtraAS__c + AXADiscount__c:'+newOrderLineList[i].TECH_ExtraAS__c+ ' ' +newOrderLineList[i].AXADiscount__c);
				if(newOrderLineList[i].TECH_ExtraAS__c != null && newOrderLineList[i].AXADiscount__c != null 
					&& (newOrderLineList[i].TECH_ExtraAS__c + newOrderLineList[i].AXADiscount__c) >= 100){
					newOrderLineList[i].addError(system.label.BsDiscountTooLarge);//vsu 06/03/18 Case C-002284
				}
				else{

					if(!ap31MapPurchaseOrderOrderLines.containsKey(newOrderLineList[i].PurchaseOrder__c))
					{
						
						ap31MapPurchaseOrderOrderLines.put(newOrderLineList[i].PurchaseOrder__c, new List<OrderLine__c>{newOrderLineList[i]});
					}
					else
					{						
						ap31MapPurchaseOrderOrderLines.get(newOrderLineList[i].PurchaseOrder__c).add(newOrderLineList[i]);
					}
				}
			}			

			//DUN 19/06/2018  Case C-002313: Copying AcceptedByBS and PreSelectedForOrder on Bundles
			if(newOrderLineList[i].OrderType__c == 'BUNDLEITEM' || (newOrderLineList[i].OrderType__c == 'FINAL' && newOrderLineList[i].OriginalItem__c != null)){
				if(mapParentIdListOrderlines.containsKey(newOrderLineList[i].OriginalItem__c)){
					mapParentIdListOrderlines.get(newOrderLineList[i].OriginalItem__c).add(newOrderLineList[i]);
				}
				else{
					mapParentIdListOrderlines.put(newOrderLineList[i].OriginalItem__c,new list<OrderLine__c> {newOrderLineList[i]});
				}
			}

		}
		system.debug('## mapAP31POIdlistOLDE ' + mapAP31POIdlistOLDE);
		system.debug('## setAP31DiscountIdDE ' + setAP31DiscountIdDE);
		if(mapAP31POIdlistOLDE.size() > 0 && setAP31DiscountIdDE.size() > 0){
			AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountFieldDE(mapAP31POIdlistOLDE,setAP31DiscountIdDE);
		}

		//DUN 08/03/2018: C-002383 Bug BE discount not displayed for alternatives on SO
		system.debug('## ap31MapPurchaseOrderOrderLines:'+ap31MapPurchaseOrderOrderLines);
		if(ap31MapPurchaseOrderOrderLines.size() > 0)
		{
			AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountField(ap31MapPurchaseOrderOrderLines);
		}

		//DUN 19/06/2018  Case C-002313: Copying AcceptedByBS and PreSelectedForOrder on Bundles
		system.debug('## mapParentIdListOrderlines:'+mapParentIdListOrderlines);
		if(mapParentIdListOrderlines.size() > 0){
			mapValuesOnBundles(mapParentIdListOrderlines);
		}

		System.debug('-------------------------- END METHOD OrderLineTriggerHandler - onBeforeInsert --------------------------');
	}

	public void onAfterInsert(List<OrderLine__c> newOrderLineList)
	{
		System.debug('-------------------------- START METHOD OrderLineTriggerHandler - onAfterInsert --------------------------');

		// Map of Purchase Order to update
		Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdate = new Map<Id, PurchaseOrder__c>();
		for(OrderLine__c newOrderLine : newOrderLineList)
		{
			// check if CataloguePrice__c is not null or AssessmentPrice__c is not null
			if(	(newOrderLine.CataloguePrice__c != null || newOrderLine.AssessmentPrice__c != null) &&
				newOrderLine.CataloguePrice__c > newOrderLine.AssessmentPrice__c)
			{
				mapPurchaseOrderToUpdate.put(newOrderLine.PurchaseOrder__c, new PurchaseOrder__c(Id							= newOrderLine.PurchaseOrder__c,
																								 DistributorPriceHigger__c	= true));
			}

		}

		if(mapPurchaseOrderToUpdate.size() > 0)
		{
			update mapPurchaseOrderToUpdate.values();
		}

		System.debug('-------------------------- END METHOD OrderLineTriggerHandler - onAfterInsert --------------------------');
	}

	public void onBeforeUpdate(List<OrderLine__c> newOrderLineList, List<OrderLine__c> oldOrderLineList, Map<Id, OrderLine__c> mapOldOrderLine)
	{
		System.debug('-------------------------- START METHOD OrderLineTriggerHandler - onBeforeUpdate --------------------------');
		
		// // List of order lines that need to have their bodyshop discount updated
		// List<OrderLine__c> orderLinesToUpdateBodyShopDiscount	= new List<OrderLine__c>();
		// // Set of purchase order that are need to update the order lines bodyshop discount
		// Set<Id>	purchaseOrderIdToUpdateBodyShopDiscountSet		= new Set<Id>();

		// ABT - 17-NOV-2016 - C-001802
		// Map of purchase order and list of order lines that need to have their bodyshop discount updated
		Map<Id, List<OrderLine__c>> ap31MapPurchaseOrderOrderLines	= new Map<Id, List<OrderLine__c>>();

		//DUN 05/05/2017 case 1905 
		Map<Id, List<OrderLine__c>> mapAP31POIdlistOLDE = new Map<Id, List<OrderLine__c>>();
		Set<Id> setAP31DiscountIdDE = new Set<Id>();
		
		// Loop in the list of orderlines to get the informations required
		for(Integer i = 0; i < newOrderLineList.size(); i++)
		{
			// check if (TECH_ExtraAS__c has changed and it is not null)  or (AXADiscount__c has changed and it is not null)
			// added the check if purchaseOrder != null then we update the bodyshop discount
			//DUN 08/11/2017 case 2055 Discount for Total Loss Assessment
			if(	newOrderLineList[i].PurchaseOrder__c != null &&
				(
					((newOrderLineList[i].TECH_ExtraAS__c != oldOrderLineList[i].TECH_ExtraAS__c) && newOrderLineList[i].TECH_ExtraAS__c != null) ||
					((newOrderLineList[i].AXADiscount__c != oldOrderLineList[i].AXADiscount__c) && newOrderLineList[i].AXADiscount__c != null) ||
					((newOrderLineList[i].Suppliable__c != oldOrderLineList[i].Suppliable__c) && newOrderLineList[i].Suppliable__c == 'YES')
				))
			{
				// orderLinesToUpdateBodyShopDiscount.add(newOrderLineList[i]);
				// purchaseOrderIdToUpdateBodyShopDiscountSet.add(newOrderLineList[i].PurchaseOrder__c);
				system.debug('##TECH_ExtraAS__c + AXADiscount__c'+newOrderLineList[i].TECH_ExtraAS__c +' '+ newOrderLineList[i].AXADiscount__c);
				if(newOrderLineList[i].TECH_ExtraAS__c != null && newOrderLineList[i].AXADiscount__c != null &&
					(newOrderLineList[i].TECH_ExtraAS__c + newOrderLineList[i].AXADiscount__c) >= 100){
					newOrderLineList[i].addError(system.label.BsDiscountTooLarge);//vsu 06/03/18 Case C-002284
				}
				else{

					if(!ap31MapPurchaseOrderOrderLines.containsKey(newOrderLineList[i].PurchaseOrder__c))
					{
						
						ap31MapPurchaseOrderOrderLines.put(newOrderLineList[i].PurchaseOrder__c, new List<OrderLine__c>{newOrderLineList[i]});
					}
					else
					{						
						ap31MapPurchaseOrderOrderLines.get(newOrderLineList[i].PurchaseOrder__c).add(newOrderLineList[i]);
					}
				}
			}

			//DUN 05/05/2017 case 1905 
			if(	newOrderLineList[i].PurchaseOrder__c != null &&
				(
					(newOrderLineList[i].Discount__c != oldOrderLineList[i].Discount__c && newOrderLineList[i].Discount__c != null) ||
				    (newOrderLineList[i].AXADiscount__c != oldOrderLineList[i].AXADiscount__c && newOrderLineList[i].AXADiscount__c != null) 
				    || (newOrderLineList[i].BodyShopDiscount__c != oldOrderLineList[i].BodyShopDiscount__c)
				    // vsu Case C-002039 - Added condition to allow correct upsert of bundleitem's BodyshopDiscount 
				))
			{
				if(!mapAP31POIdlistOLDE.containsKey(newOrderLineList[i].PurchaseOrder__c))
				{
					mapAP31POIdlistOLDE.put(newOrderLineList[i].PurchaseOrder__c, new List<OrderLine__c>{newOrderLineList[i]});
				}
				else
				{
					mapAP31POIdlistOLDE.get(newOrderLineList[i].PurchaseOrder__c).add(newOrderLineList[i]);
				}
				setAP31DiscountIdDE.add(newOrderLineList[i].Discount__c);
			}

			// ABT - 17-JAN-2017 - C-001620
			// Changed AdditionnalDiscount__c to AdditionalDiscountAmount__c
			// removed check additional discount is not null as it can happen that the user wants to remove the AdditionalDiscountAmount__c
			// check if additional discount has changed 
			if(newOrderLineList[i].AdditionalDiscountAmount__c != oldOrderLineList[i].AdditionalDiscountAmount__c)
			{
				// set the order line TECH_ToBeProcessed__c to true
				newOrderLineList[i].TECH_ToBeProcessed__c = true;
			}

			// ABT - 16-FEB-2017 - C-001816
			if(	!OfferTriggerHandler.hasOnBeforeUpdateRun &&
				newOrderLineList[i].DeliveryStatus__c != oldOrderLineList[i].DeliveryStatus__c &&
				newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED)
			{
				// setting the checkbox to true to indicate that the current orderline is being canceled by the distributor
				newOrderLineList[i].IsCanceledByDistributor__c = true;

				// Setting the static variable to true
				OrderLineTriggerHandler.hasOnBeforeUpdateRun = true;
			}
		}

		// check if the orderLinesToUpdateBodyShopDiscount is greater than 0
		system.debug('## ap31MapPurchaseOrderOrderLines:'+ap31MapPurchaseOrderOrderLines);
		system.debug('## isInvokedFromOfferTrigger:'+AP31PopulateBodyShopDiscount.isInvokedFromOfferTrigger);
		if(	ap31MapPurchaseOrderOrderLines.size() > 0 &&
			!AP31PopulateBodyShopDiscount.isInvokedFromOfferTrigger)
		{
			// AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountField(orderLinesToUpdateBodyShopDiscount, purchaseOrderIdToUpdateBodyShopDiscountSet);
			AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountField(ap31MapPurchaseOrderOrderLines);
		}

		system.debug('## mapAP31POIdlistOLDE ' + mapAP31POIdlistOLDE);
		system.debug('## setAP31DiscountIdDE ' + setAP31DiscountIdDE);
		//DUN 05/05/2017 case 1905
		if(mapAP31POIdlistOLDE.size() > 0 && setAP31DiscountIdDE.size() > 0){
			AP31PopulateBodyShopDiscount.fillOrderLineBodyShopDiscountFieldDE(mapAP31POIdlistOLDE,setAP31DiscountIdDE);
		}
		System.debug('-------------------------- END METHOD OrderLineTriggerHandler - onBeforeUpdate --------------------------');
		

	}

	public void onAfterUpdate(List<OrderLine__c> newOrderLineList, List<OrderLine__c> oldOrderLineList, Map<Id, OrderLine__c> mapOldOrderLine)
	{
		System.debug('-------------------------- START METHOD OrderLineTriggerHandler - onAfterUpdate --------------------------');

		
		// Map of order lines that has a change in delivery date and sync thier offer
		Map<Id, OrderLine__c> mapOrderLineHavingChangeInDeliveryDate	= new Map<Id, OrderLine__c>();
		// Set of order lines that has a change in delivery status and sync thier offer
		Map<Id, OrderLine__c> mapOrderLineHavingChangeInDeliveryStatus	= new Map<Id, OrderLine__c>();
		// Set of purchase order that has ASDiscount too low
		Set<Id> purchaseOrderHavingASDiscountTooLowSet					= new Set<Id>();
		// Set of purchase order that has distributor price higher
		Set<Id> purchaseOrderHavingDistributorPriceHigher				= new Set<Id>();
		// Set of purchase order that need to have their total expected amount updated
		Set<Id> purchaseOrderToUpdateAmountSet							= new Set<Id>();
		// Set of purchase order that needs to be reopened
		Set<Id> ap13PurchaseOrderIdSet									= new Set<Id>();
		// ABT - 23-JAN-2017 - C-001620
		Map<Id, Decimal> mapParentOrderLineAdditionalDiscountDiff		= new Map<Id, Decimal>();
		
		// Set of orderline ids that has Accepted By BS changed
		Map<Id, OrderLine__c> mapOrderLineHavingChangeInAcceptedCheck	= new Map<Id, OrderLine__c>();

		//17-01/2020 RLA C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
		Set<Id> setIdPoToRecalculateTotExpAmt	= new set<Id>();

		//DUN 31/08/2018  Case C-001895 : Spare Part Recovery
		Map<Id, PartList__c> mapPLToUpdate = new Map<Id, PartList__c>();

		for(Integer i = 0; i < newOrderLineList.size(); i++)
		{
			// check if (EstimatedDeliveryDate__c has changed)
			if(newOrderLineList[i].EstimatedDeliveryDate__c != oldOrderLineList[i].EstimatedDeliveryDate__c)
			{
				mapOrderLineHavingChangeInDeliveryDate.put(newOrderLineList[i].Id, newOrderLineList[i]);
			}

			// check if there is a change in delivery status and the delivery status is now indelivery or delivered or delayed or canceled
			if(	(newOrderLineList[i].DeliveryStatus__c != oldOrderLineList[i].DeliveryStatus__c) && 
				(newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_INDELIVERY ||
				 newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELIVERED ||
				 newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_DELAYED ||
				 newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED ||
				 // ASE : 19/01/17 : case 1860
				 newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_RETURNED ||
				 //AMI  05/10/2018  : Case C-002045 - Advance case management - Update offer status (managed) to that of orderline   
				 newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_MANAGED 
				 ))
			{
				mapOrderLineHavingChangeInDeliveryStatus.put(newOrderLineList[i].Id, newOrderLineList[i]);

				// ABT 06-DEC-2016 - C-001677
				if(newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED ||
					// ASE : 19/01/17 : case 1860
				   newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_RETURNED )
				{
					ap13PurchaseOrderIdSet.add(newOrderLineList[i].PurchaseOrder__c);
				}
			}
			
			// check if (TECH_ExtraAS__c has changed and it is not null)  or (AXADiscount__c has changed and it is not null)
			if(	((newOrderLineList[i].TECH_ExtraAS__c != oldOrderLineList[i].TECH_ExtraAS__c) && newOrderLineList[i].TECH_ExtraAS__c != null) ||
				((newOrderLineList[i].AXADiscount__c != oldOrderLineList[i].AXADiscount__c) && newOrderLineList[i].AXADiscount__c != null))
			{
				if(	(
						((newOrderLineList[i].TECH_ExtraAS__c != null) ? newOrderLineList[i].TECH_ExtraAS__c : 0)  + 
						((newOrderLineList[i].AXADiscount__c != null) ? newOrderLineList[i].AXADiscount__c : 0)
					)  < newOrderLineList[i].TECHASLowLevel__c)
				{
					purchaseOrderHavingASDiscountTooLowSet.add(newOrderLineList[i].PurchaseOrder__c);
				}
			}

			// check if CataloguePrice__c is not null or AssessmentPrice__c is not null
			if(	(((newOrderLineList[i].CataloguePrice__c != oldOrderLineList[i].CataloguePrice__c) && newOrderLineList[i].CataloguePrice__c != null) ||
				 ((newOrderLineList[i].AssessmentPrice__c != oldOrderLineList[i].AssessmentPrice__c) && newOrderLineList[i].AssessmentPrice__c != null)) &&
				newOrderLineList[i].CataloguePrice__c > newOrderLineList[i].AssessmentPrice__c)
			{
				purchaseOrderHavingDistributorPriceHigher.add(newOrderLineList[i].PurchaseOrder__c);
			}

			// ABT - 18-JAN-2017 - C-001620 - Changed AdditionalDiscount__c to AdditionalDiscountAmount__c and
			// also removing check if AdditionalDiscount__c != null
			// check if additional discount has changed and it is not null or 0
			// or delivery status has changed and the delivery status is returned or canceled
			if(	(newOrderLineList[i].AdditionalDiscountAmount__c != oldOrderLineList[i].AdditionalDiscountAmount__c) ||
				(newOrderLineList[i].DeliveryStatus__c != oldOrderLineList[i].DeliveryStatus__c && 
				 (newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_RETURNED ||
				  newOrderLineList[i].DeliveryStatus__c == ASPISConstants.ORD_LINE_STATUS_CANCELED)
				))
			{
				purchaseOrderToUpdateAmountSet.add(newOrderLineList[i].PurchaseOrder__c);
			}

			// ABT - 23-JAN-2017 - C-001620 - Update the final in case there is a change in the additional discount of the bundle item
			if(	newOrderLineList[i].OrderType__c == 'BUNDLEITEM' &&
				newOrderLineList[i].AdditionalDiscountAmount__c != oldOrderLineList[i].AdditionalDiscountAmount__c &&
				newOrderLineList[i].OriginalItem__c != null)
			{
				Decimal additionalDiscountDiff = (newOrderLineList[i].AdditionalDiscountAmount__c != null ? newOrderLineList[i].AdditionalDiscountAmount__c : 0) -
												 (oldOrderLineList[i].AdditionalDiscountAmount__c != null ? oldOrderLineList[i].AdditionalDiscountAmount__c : 0);
				
				if(!mapParentOrderLineAdditionalDiscountDiff.containsKey(newOrderLineList[i].OriginalItem__c))
				{
					mapParentOrderLineAdditionalDiscountDiff.put(newOrderLineList[i].OriginalItem__c, additionalDiscountDiff);
				}
				else
				{
					mapParentOrderLineAdditionalDiscountDiff.put(newOrderLineList[i].OriginalItem__c, 
																 mapParentOrderLineAdditionalDiscountDiff.get(newOrderLineList[i].OriginalItem__c) + 
																 additionalDiscountDiff);
				}
			}

			if(	newOrderLineList[i].AcceptedCheck__c != oldOrderLineList[i].AcceptedCheck__c &&
				newOrderLineList[i].PreselectedForOrder__c)
			{
				mapOrderLineHavingChangeInAcceptedCheck.put(newOrderLineList[i].Id, newOrderLineList[i]);
			}

			//DUN 31/08/2018  Case C-001895 : Spare Part Recovery
			if(newOrderLineList[i].Suppliable__c == 'YES' && oldOrderLineList[i].Suppliable__c != newOrderLineList[i].Suppliable__c){
				mapPLToUpdate.put(newOrderLineList[i].PartList__c,new PartList__c(Id= newOrderLineList[i].PartList__c, Suppliable__c = true));
			}
			//17-01/2020 RLA C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
			if(oldOrderLineList[i].Rebate__c  != newOrderLineList[i].Rebate__c 
			  || oldOrderLineList[i].CataloguePrice__c  != newOrderLineList[i].CataloguePrice__c 
			  || oldOrderLineList[i].AXADiscount__c  != newOrderLineList[i].AXADiscount__c ){
				setIdPoToRecalculateTotExpAmt.add(newOrderLineList[i].Id);
			}

		}

		Set<Id> allOrderLineIdNeededToQueryOffer = new Set<Id>();
		allOrderLineIdNeededToQueryOffer.addAll(mapOrderLineHavingChangeInDeliveryDate.keySet());
		allOrderLineIdNeededToQueryOffer.addAll(mapOrderLineHavingChangeInDeliveryStatus.keySet());
		allOrderLineIdNeededToQueryOffer.addAll(mapOrderLineHavingChangeInAcceptedCheck.keySet());

		// List of offers to update
		List<Offer__c> offersToUpdateList = new List<Offer__c>();

		// ABT - 25-JAN-2017 - Optimisation
		if(allOrderLineIdNeededToQueryOffer.size() > 0)
		{
			for(Offer__c currentOffer : [SELECT	Id, OrderLine__c, Accepted__c
										FROM	Offer__c
										WHERE	OrderLine__c IN: allOrderLineIdNeededToQueryOffer
										/*AND	Accepted__c = 'YES'*/])
			{
				if(currentOffer.Accepted__c == 'YES')
				{
					// check if the current offer's orderline had a change in the expected delivery date
					if(mapOrderLineHavingChangeInDeliveryDate.containsKey(currentOffer.OrderLine__c))
					{
						currentOffer.ExpectedDeliveryDate__c = mapOrderLineHavingChangeInDeliveryDate.get(currentOffer.OrderLine__c).EstimatedDeliveryDate__c;
					}

					// check if the current offer's orderline had a change in the delivery status and set it the same as the order line
					if(mapOrderLineHavingChangeInDeliveryStatus.containsKey(currentOffer.OrderLine__c))
					{
						currentOffer.DeliveryStatus__c = mapOrderLineHavingChangeInDeliveryStatus.get(currentOffer.OrderLine__c).DeliveryStatus__c;
					}
				}

				if(mapOrderLineHavingChangeInAcceptedCheck.containsKey(currentOffer.OrderLine__c))
				{
					if(mapOrderLineHavingChangeInAcceptedCheck.get(currentOffer.OrderLine__c).AcceptedCheck__c)
					{
						currentOffer.Accepted__c = 'YES';
						currentOffer.Suppliable__c = true;
					}
					else
					{
						currentOffer.Accepted__c = 'NO';
						currentOffer.Suppliable__c = false;
					}
				}

				offersToUpdateList.add(currentOffer);
			}
		}

		// Map of purchase order to update
		Map<Id, PurchaseOrder__c> mapPurchaseOrderToUpdate	= new Map<Id, PurchaseOrder__c>();

		// check if the set purchaseOrderToUpdateAmountSet is greater than 0
		if(purchaseOrderToUpdateAmountSet.size() > 0)
		{
			mapPurchaseOrderToUpdate.putAll(AP15CalculateTotalExpAmtPurchaseOrder.purchaseOrderToUpdate(purchaseOrderToUpdateAmountSet));
		}

		// now loop in the set that has cases to create
		// the purchase order with ASDiscount too low
		for(Id purchaseOrderId : purchaseOrderHavingASDiscountTooLowSet)
		{
			if(!mapPurchaseOrderToUpdate.containsKey(purchaseOrderId))
			{
				mapPurchaseOrderToUpdate.put(purchaseOrderId, new PurchaseOrder__c(	Id							= purchaseOrderId,
																					ASDiscountLowCaseCreated__c = true));
			}
			else
			{
				mapPurchaseOrderToUpdate.get(purchaseOrderId).ASDiscountLowCaseCreated__c = true;
			}
		}

		// the purchase order with distributor price higher
		for(Id purchaseOrderId : purchaseOrderHavingDistributorPriceHigher)
		{
			if(!mapPurchaseOrderToUpdate.containsKey(purchaseOrderId))
			{
				mapPurchaseOrderToUpdate.put(purchaseOrderId, new PurchaseOrder__c(	Id							= purchaseOrderId,
																					DistributorPriceHigger__c	= true));
			}
			else
			{
				mapPurchaseOrderToUpdate.get(purchaseOrderId).DistributorPriceHigger__c = true;
			}
		}
		system.debug('## offersToUpdateList ' + offersToUpdateList );
		// check if there are offers to update
		if(offersToUpdateList.size() > 0)
		{
			update offersToUpdateList;
		}

		// check if the size of mapPurchaseOrderToUpdate is greater than 0
		if(mapPurchaseOrderToUpdate.size() > 0)
		{
			update mapPurchaseOrderToUpdate.values();
		}

		if(ap13PurchaseOrderIdSet.size() > 0)
		{
			AP13SetPOStatus.reopenPurchaseOrderWithCanceledOrderLine(ap13PurchaseOrderIdSet);
		}

		if(mapParentOrderLineAdditionalDiscountDiff.size() > 0
		   || setIdPoToRecalculateTotExpAmt.size() > 0)
		{
			List<OrderLine__c> finalOrderLinesToUpdate = new List<OrderLine__c>();
			Map<Id,PurchaseOrder__c> mapPurchaseOrderToUpdateTotExp = new Map<Id,PurchaseOrder__c>();
			
			for(OrderLine__c currentFinalOrderLine: [	SELECT 	Id, TechFinalTotalPrice__c, TechFinalTotalAxaPrice__c, TechFinalBSTotalPrice__c, 
																AXADiscount__c, BodyShopDiscount__c,PurchaseOrder__c
														FROM	OrderLine__c
														WHERE	(Id IN: mapParentOrderLineAdditionalDiscountDiff.keySet()
																	AND		OrderType__c = 'FINAL')
																OR (Id IN: setIdPoToRecalculateTotExpAmt
														    		AND PurchaseOrder__r.Recalculate_total_expected_amount__c = false
																	AND PurchaseOrder__r.TotalExpectedAmount__c != null)//RLA C-003507
														])
			{
				if(mapParentOrderLineAdditionalDiscountDiff.containsKey(currentFinalOrderLine.Id))
				{
					// Getting the amount of Additional Discount to remove from the TechFinalTotalAxaPrice__c and TechFinalBSTotalPrice__c
					Decimal additionalDiscountAmountDiff = mapParentOrderLineAdditionalDiscountDiff.get(currentFinalOrderLine.Id);

					// Substracting the diff from the totals
					// currentFinalOrderLine.TechFinalTotalAxaPrice__c -= additionalDiscountAmountDiff;
					// currentFinalOrderLine.TechFinalBSTotalPrice__c 	-= additionalDiscountAmountDiff;
					currentFinalOrderLine.TechFinalTotalAxaPrice__c = (currentFinalOrderLine.TechFinalTotalAxaPrice__c != null ? currentFinalOrderLine.TechFinalTotalAxaPrice__c : 0) - additionalDiscountAmountDiff;
					currentFinalOrderLine.TechFinalBSTotalPrice__c 	= (currentFinalOrderLine.TechFinalBSTotalPrice__c != null ? currentFinalOrderLine.TechFinalBSTotalPrice__c : 0) - additionalDiscountAmountDiff;

					// Calculating the AXADiscount__c from the new values obtained
					currentFinalOrderLine.AXADiscount__c 		= 	(currentFinalOrderLine.TechFinalTotalPrice__c > 0) ? 
																	((currentFinalOrderLine.TechFinalTotalPrice__c - currentFinalOrderLine.TechFinalTotalAxaPrice__c) / 
																	currentFinalOrderLine.TechFinalTotalPrice__c) * 100 : 0;

					system.debug('##currentFinalOrderLine.TechFinalTotalPrice__c '+currentFinalOrderLine.TechFinalTotalPrice__c);
					system.debug('##currentFinalOrderLine.TechFinalTotalAxaPrice__c '+currentFinalOrderLine.TechFinalTotalAxaPrice__c);
					system.debug('##currentFinalOrderLine.TechFinalBSTotalPrice__c '+currentFinalOrderLine.TechFinalBSTotalPrice__c);
					system.debug('##currentFinalOrderLine.AXADiscount__c '+currentFinalOrderLine.AXADiscount__c);

					// Calculating the BodyShopDiscount__c from the new values obtained
					currentFinalOrderLine.BodyShopDiscount__c 	= 	(currentFinalOrderLine.TechFinalTotalPrice__c > 0) ? 
																	((currentFinalOrderLine.TechFinalTotalPrice__c - currentFinalOrderLine.TechFinalBSTotalPrice__c) / 
																	currentFinalOrderLine.TechFinalTotalPrice__c) * 100 : 0;
					finalOrderLinesToUpdate.add(currentFinalOrderLine);

				}
				//17-01/2020 RLA C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
				else if (setIdPoToRecalculateTotExpAmt.contains(currentFinalOrderLine.Id)){
					mapPurchaseOrderToUpdateTotExp.put(currentFinalOrderLine.PurchaseOrder__c,new PurchaseOrder__c( Id = currentFinalOrderLine.PurchaseOrder__c, Recalculate_total_expected_amount__c = true));

				}
			}
			if(finalOrderLinesToUpdate.size() > 0)
			{
				update finalOrderLinesToUpdate;
			}
			system.debug('@@@ mapPurchaseOrderToUpdateTotExp: '+mapPurchaseOrderToUpdateTotExp);
			//17-01/2020 RLA C-003507 : Review when Total Expected and Total Invoices amount fields are updated in PO's
			if(mapPurchaseOrderToUpdateTotExp.size() > 0)
			{
				update mapPurchaseOrderToUpdateTotExp.values();
			}
		}
		//DUN 31/08/2018  Case C-001895 : Spare Part Recovery
		if(mapPLToUpdate.size() > 0){
			update mapPLToUpdate.values();
		}
		System.debug('-------------------------- END METHOD OrderLineTriggerHandler - onAfterUpdate --------------------------');
	}
	
	//DUN 19/06/2018  Case C-002313: Copying AcceptedByBS and PreSelectedForOrder on Bundles
	public static void mapValuesOnBundles(map <Id, list<OrderLine__c>> mapParentIdListOL){

		map<Id,OrderLine__c> mapIdOrderLine = new map<Id,OrderLine__c>([Select Id, AcceptedCheck__c, PreselectedForOrder__c, OriginalItem__c, 
																			   OriginalItem__r.AcceptedCheck__c, OriginalItem__r.PreselectedForOrder__c
																		from OrderLine__c
																		where Id in: mapParentIdListOL.keySet()
																		and (  (AcceptedCheck__c = true 
																			   and PreselectedForOrder__c = true)
																			or (OriginalItem__r.AcceptedCheck__c = true
																			   and OriginalItem__r.PreselectedForOrder__c = true))
																		and PurchaseOrder__r.Distributor__r.AdditionalPartButton__c = true]);

		system.debug('##mapIdOrderLine '+mapIdOrderLine);

		for(Id parentId : mapParentIdListOL.keySet()){
			for(OrderLine__c bundle : mapParentIdListOL.get(parentId)){
				system.debug('##bundle '+bundle);
				system.debug('##mapIdOrderLine.get(parentId) '+mapIdOrderLine.get(parentId));
				if(mapIdOrderLine != null && mapIdOrderLine.get(parentId) != null){
					if(bundle.OrderType__c == 'BUNDLEITEM'){
						bundle.AcceptedCheck__c = mapIdOrderLine.get(parentId).OriginalItem__r.AcceptedCheck__c;
						bundle.PreselectedForOrder__c = mapIdOrderLine.get(parentId).OriginalItem__r.PreselectedForOrder__c;
					}
					else if(bundle.OrderType__c == 'FINAL' && bundle.OriginalItem__c != null){
						bundle.AcceptedCheck__c = mapIdOrderLine.get(parentId).AcceptedCheck__c;
						bundle.PreselectedForOrder__c = mapIdOrderLine.get(parentId).PreselectedForOrder__c;
					}
				}
			}
		} 
	}
}