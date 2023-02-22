/*
----------------------------------------------------------------------
-- - Name          : AP32PopulatePurchaseOrderFromAccount
-- - Author        : ABT
-- - Description   : Class to do all the operations for pooulating fields on purchase order from account
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 13-JAN-2016	ABT		1.0			Initial version - C-001856
----------------------------------------------------------------------
**********************************************************************
*/
public class AP32PopulatePurchaseOrderFromAccount
{
	public static void populatePurchaseOrder(List<PurchaseOrder__c> purchaseOrderList, Set<Id> distributorIdSet)
	{
		// Retrieve the distributors
		Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT 	Id, ContactUser__c, Rebate__c
															FROM	Account
															WHERE	Id IN: distributorIdSet]);

		// Loop in the purchase order and populate the required fields
		for(PurchaseOrder__c currentPurchaseOrder : purchaseOrderList)
		{
			if(mapAccount.containsKey(currentPurchaseOrder.Distributor__c))
			{
				Account currentAccount = mapAccount.get(currentPurchaseOrder.Distributor__c);

				currentPurchaseOrder.DistributorContact__c 	= currentAccount.ContactUser__c;
				currentPurchaseOrder.Rebate__c 				= currentAccount.Rebate__c;
			}
		}
	}
}