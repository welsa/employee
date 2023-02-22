/*
----------------------------------------------------------------------
-- - Name          : VFC13_GeneratePOOrderLineCSV
-- - Author        : ABT
-- - Description   : Extensions for the page VFP13_GeneratePurchaseOrderOrderLineCSV
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 06-FEB-2017	ABT		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
public with sharing class VFC13_GeneratePOOrderLineCSV
{
	public PurchaseOrder__c currentPurchaseOrder {get; set;}
	public String header {get; set;}

	// Map Id of Original Order line and its wrapper
	public Map<Id, OrderLineWrapper> mapIdOrderLineWrapper {get; set;}

	public Boolean isQuotation {get; set;}

	public VFC13_GeneratePOOrderLineCSV(ApexPages.StandardController sc)
	{
		currentPurchaseOrder 	= (PurchaseOrder__c) sc.getRecord();
		mapIdOrderLineWrapper 	= new Map<Id, OrderLineWrapper>();
		header 					= '"Column 1","Column 2","Column 3","Column 4","Column 5","Column 6"';
		isQuotation				= (currentPurchaseOrder.RecordTypeId == Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId());

		for(OrderLine__c currentOrderLine: [SELECT	Id, PartNumber__c, Quantity__c, OrderType__c, OriginalItem__c, OriginalItem__r.OriginalItem__c, AcceptedCheck__c, Suppliable__c
											FROM	OrderLine__c
											WHERE	PurchaseOrder__c =: currentPurchaseOrder.Id])
		{
			// check if the order line is an original one
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
		}
	}

	// Wrapper class for order lines
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
						finalOrderLine.OrderType__c == 'FINAL' && 
						finalOrderLine.OriginalItem__c == null);
			}
		}

		// variable to know if there is an alternative for the original order line
		public Boolean isFinalAltenative
		{
			get
			{
				return (finalOrderLine != null &&
						finalOrderLine.OrderType__c == 'FINAL' && 
						finalOrderLine.OriginalItem__c != null &&
						bundleItemList.size() == 0);
			}
		}

		// variable to know if the wrapper is a bundle one
		public Boolean isBundle
		{
			get
			{
				return (bundleItemList.size() > 0);
			}
		}

		// variable to know if the wrapper contains an original order line only
		public Boolean isOriginalOnly
		{
			get
			{
				return (originalOrderLine != null && 
						originalOrderLine.OrderType__c == 'ORIGINAL' && 
						finalOrderLine == null &&
						bundleItemList.size() == 0);
			}
		}

		public OrderLineWrapper(OrderLine__c currentOL)
		{
			// Initialising the list
			bundleItemList				= new List<OrderLine__c>();

			if (currentOL.OrderType__c == 'ORIGINAL')
			{
				originalOrderLine = currentOL;
			}
			else if (currentOL.OrderType__c == 'FINAL')
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