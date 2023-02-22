/*************************************************************************************
Class Name - AP27SyncPOSOInternalComment
Version - 1.0
Created Date - 10/02/2016
Function - Sync Internal comment field between SO and PO

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Shamina M        10/02/2016   Initial Version (Case C-001479 - sync field InternalComment__c between SO and PO)
*************************************************************************************/
public class AP27SyncPOSOInternalComment {
	/*
	@TestVisible private static Boolean firstRun = true;

	// method used to determine if code has already been run and hence prevent recursion
	public static Boolean isFirstRun(){
		if(Test.isRunningTest())
			return true;

		//this section cannot be covered in test class
		if(firstRun){
			firstRun = false;
			return true;
		}
		else
			return firstRun;
	}

	//method to update PO Internal Comment from SO internal comment
	public static void updatePOInternalComment(map<Id,PrerequisiteOrder__c> mapSODetails,list<PurchaseOrder__c> lstPO){
		List<PurchaseOrder__c> listPOToUpdate = new List<PurchaseOrder__c>();
		//query all POs related to the SOs that were updated
		for(PurchaseOrder__c po: [select id, InternalComment__c,PrerequisiteOrder__c,PrerequisiteOrder__r.InternalComment__c
									from PurchaseOrder__c
									where PrerequisiteOrder__c IN :mapSODetails.keySet()
									and Id NOT IN:lstPO]){
			po.InternalComment__c = po.PrerequisiteOrder__r.InternalComment__c;
			listPOToUpdate.add(po);
		}

		if(listPOToUpdate.size()> 0)
			update listPOToUpdate;
	}

	//method to update SO internal comment from PO internal comment + all other related PO
	public static void updateSOAndRelatedPOInternalComment(list<PurchaseOrder__c> lstPO){
		List<PrerequisiteOrder__c> listSOToUpdate = new List<PrerequisiteOrder__c>();
		map<Id,PrerequisiteOrder__c> mapSOToUpdate = new map<Id,PrerequisiteOrder__c>();
		//update related SOs for the POs updated
		for(PurchaseOrder__c po : lstPO){
			PrerequisiteOrder__c so = new PrerequisiteOrder__c(Id = po.PrerequisiteOrder__c
									,InternalComment__c=po.InternalComment__c );
			mapSOToUpdate.put(so.Id, so);
		}

		if(mapSOToUpdate.size()> 0) {
			//update related SO
			update mapSOToUpdate.values();

			//update any other existing PO for same SOs updated
			updatePOInternalComment(mapSOToUpdate, lstPO);
		}

	}

	// ----------------------------------------- NEW VERSION -----------------------------------------
	//method to update PO Internal Comment from SO internal comment
	public static void updatePOInternalComment(List<PrerequisiteOrder__c> updatedSalesOrderList)
	{
		// List Storing the purchase orders the need to be sync
		List<PurchaseOrder__c> purchaseOrderToSyncList = new List<PurchaseOrder__c>();

		//query all POs related to the SOs that were updated
		for(PurchaseOrder__c purchaseOrder: [	SELECT	Id, PrerequisiteOrder__r.InternalComment__c
												FROM	PurchaseOrder__c
												WHERE	PrerequisiteOrder__c IN :updatedSalesOrderList])
		{
			purchaseOrder.InternalComment__c = purchaseOrder.PrerequisiteOrder__r.InternalComment__c;
			purchaseOrderToSyncList.add(purchaseOrder);
		}

		if(purchaseOrderToSyncList.size() > 0)
		{
			update purchaseOrderToSyncList;
		}
	}*/
}