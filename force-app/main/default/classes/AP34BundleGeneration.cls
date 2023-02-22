/*
----------------------------------------------------------------------
-- - Name          : AP34BundleGeneration
-- - Author        : ABT
-- - Description   : Class to generate bundles when the offers are already generated
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 30-MAR-2017  ABT     1.0         Initial version
-- 11-A{R-2017  ABT     1.1         Commented Shipping Cost as it is not used for the moment
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class AP34BundleGeneration
{
	public static void generateBundlesOffers(Set<Id> purchaseOrderIdSet)
	{
		// we are in a Purchase Order Trigger Handler
		// so we have the purchase order -> Id or the object?

		// SELECT all the orderlines that is accepted by bs and is preselected for order
		// bring the offers also so that it can be updated
		// create bundle item offers and attach them to the parent offer that is the existing one that will be updated

		// must add preselected copying to alternative or bundle items or finals

		Map<Id, OrderLineWrapper> mapIdOrderLineWrapper = new Map<Id, OrderLineWrapper>();

		for(OrderLine__c currentOrderLine : [SELECT Id, OrderType__c, OriginalItem__c, OriginalItem__r.OriginalItem__c,
													(SELECT Id, PrerequisiteOrder__c, Type__c
													 FROM Offers__r)
											 FROM	OrderLine__c
											 WHERE	PurchaseOrder__c 		=: purchaseOrderIdSet
											 AND	PreselectedForOrder__c 	= true
											 AND	AcceptedCheck__c		= true
											 AND	Suppliable__c			= 'YES'])
		{
			if (currentOrderLine.OrderType__c == 'ORIGINAL')
			{
				if (!mapIdOrderLineWrapper.containsKey(currentOrderLine.Id))
				{
					mapIdOrderLineWrapper.put(currentOrderLine.Id, new OrderLineWrapper(currentOrderLine));
				}
				else
				{
					mapIdOrderLineWrapper.get(currentOrderLine.Id).setOriginalItem(currentOrderLine);
				}
			}
			// check if the order line is a final one
			else if (currentOrderLine.OrderType__c == 'FINAL')
			{
				// there are two types for the final order line
				// One can be the original one itself (that has been converted to final)
				// --- Therefore OriginalItem__c should be null
				// The second one is that the final order line is the alternative or final of a bundle
				// --- Therefore OriginalItem__c should not be null

				if (currentOrderLine.OriginalItem__c == null)
				{
					// Original that has been converted to final
					if (!mapIdOrderLineWrapper.containsKey(currentOrderLine.Id))
					{
						mapIdOrderLineWrapper.put(currentOrderLine.Id, new OrderLineWrapper(currentOrderLine));
					}
				}
				else
				{
					// Final can be alternative or final for bundle
					if (!mapIdOrderLineWrapper.containsKey(currentOrderLine.OriginalItem__c))
					{
						mapIdOrderLineWrapper.put(currentOrderLine.OriginalItem__c, new OrderLineWrapper(currentOrderLine));
					}
					else
					{
						mapIdOrderLineWrapper.get(currentOrderLine.OriginalItem__c).setFinalItem(currentOrderLine);
					}
				}
			}
			// check if it is a bundle item
			else if (currentOrderLine.OrderType__c == 'BUNDLEITEM')
			{
				if (!mapIdOrderLineWrapper.containsKey(currentOrderLine.OriginalItem__r.OriginalItem__c))
				{
					mapIdOrderLineWrapper.put(currentOrderLine.OriginalItem__r.OriginalItem__c, new OrderLineWrapper(currentOrderLine));
				}
				else
				{
					mapIdOrderLineWrapper.get(currentOrderLine.OriginalItem__r.OriginalItem__c).addBundleItem(currentOrderLine);
				}
			}
			// else if (currentOrderLine.OrderType__c == 'SHIPPING COST')
			// {
			// 	mapIdOrderLineWrapper.put(currentOrderLine.Id, new OrderLineWrapper(currentOrderLine));
			// }
		}


		// After populating the wrapper, loop in map to create the offers
		List<Offer__c> offerToUpdateList = new List<Offer__c>();
		List<Offer__c> offerToInsertList = new List<Offer__c>();
		for(OrderLineWrapper currentOLWrapper : mapIdOrderLineWrapper.values())
		{
			// Check if the wrapper is not an original final (that is only 1 OL in the wrapper)
			// As it would already have its own offer and does not need any update
			if(!currentOLWrapper.isFinalOriginal)
			{
				// whether it is an alternative or a bundle, the offer needs to be updated
				if(currentOLWrapper.originalOrderLine != null && currentOLWrapper.originalOrderLine.Offers__r.size() > 0)
				{
					// there should always be one offer for an order line
					Offer__c parentOffer 		= currentOLWrapper.originalOrderLine.Offers__r[0];
					parentOffer.OrderLine__c 	= currentOLWrapper.finalOrderLine.Id;

					// adding the parent to be updated
					offerToUpdateList.add(parentOffer);

					// checking if it is a bundle
					if(currentOLWrapper.isBundle)
					{
						// Loop in each order line and generate the offer
						for(OrderLine__c currentBundleItem : currentOLWrapper.bundleItemList)
						{
							offerToInsertList.add(new Offer__c(	ParentOffer__c 			= parentOffer.Id,
																OrderLine__c			= currentBundleItem.Id,
																Suppliable__c			= true,
																Accepted__c				= 'YES',
																PrerequisiteOrder__c 	= parentOffer.PrerequisiteOrder__c,
																Type__c					= parentOffer.Type__c));
						}
					}
				}
			}
		}

		// updating the offers that had a change in order line
		if(offerToUpdateList.size() > 0)
		{
			update offerToUpdateList;
		}

		if(offerToInsertList.size() > 0)
		{
			insert offerToInsertList;
		}
	}

	public class OrderLineWrapper
	{
		// the original order line
		public OrderLine__c originalOrderLine {get; set;}

		// the final order line
		public OrderLine__c finalOrderLine {get; set;}
		
		// the list of bundle items
		public List<OrderLine__c> bundleItemList {get; set;}

		// variable to know if the wrapper contains an original order line with OrderType = FINAL
		public Boolean isFinalOriginal
		{
			get
			{
				return (finalOrderLine != null && 
						(finalOrderLine.OrderType__c == 'FINAL'/* ||
						 finalOrderLine.OrderType__c == 'SHIPPING COST'*/) && 
						finalOrderLine.OriginalItem__c == null);
			}
		}

		// Not used in the class...keeping it in case there is an evolution
		// variable to know if there is an alternative for the original order line
		// public Boolean isFinalAltenative
		// {
		// 	get
		// 	{
		// 		return (finalOrderLine != null &&
		// 				finalOrderLine.OrderType__c == 'FINAL' && 
		// 				finalOrderLine.OriginalItem__c != null &&
		// 				bundleItemList.size() == 0);
		// 	}
		// }

		// variable to know if the wrapper is a bundle one
		public Boolean isBundle
		{
			get
			{
				return (bundleItemList.size() > 0);
			}
		}

		public OrderLineWrapper(OrderLine__c currentOL)
		{
			// Initialising the list
			bundleItemList              = new List<OrderLine__c>();

			if (currentOL.OrderType__c == 'ORIGINAL')
			{
				originalOrderLine = currentOL;
			}
			else if (currentOL.OrderType__c == 'FINAL'/* ||
					 currentOL.OrderType__c == 'SHIPPING COST'*/)
			{
				finalOrderLine = currentOL;
			}
			else if (currentOL.OrderType__c == 'BUNDLEITEM')
			{
				bundleItemList.add(currentOL);
			}
		}

		public void setOriginalItem(OrderLine__c originalOL)
		{
			if(originalOrderLine == null)
			{
				originalOrderLine = originalOL;
			}
		}

		public void setFinalItem(OrderLine__c finalOL)
		{
			finalOrderLine = finalOL;
		}

		public void addBundleItem(OrderLine__c currentOL)
		{
			bundleItemList.add(currentOL);
		}
	}
}