/*************************************************************************************
Class Name - ASPISServiceOrderDeliveryConfirmed
Version - 1.0
Created Date - 09 APR 2015
Function - Class to Trigger actions when one PurchaseOrder is Delivery Confirmed

Modification Log :
-----------------------------------------------------------------------------
* Developer  			Date       	Description
* ---------- 			----------  -----------------------
* João Dias			 	09/04/2015 	Original Version
* Shamina M     		17/02/2016  C-001518: Removed unnecessary debug logs
* Dourga U 				29/06/2016  C-001651: Bulkify ASPISServiceOrderDeliveryConfirmed
*************************************************************************************/
public class ASPISServiceOrderDeliveryConfirmed{ 
	//DUN commented C-001651: Bulkify
	/*implements ASPISService{


	public void executeProcess(sObject obj){
	
		PurchaseOrder__c purchaseOrder = (PurchaseOrder__c) obj;
		Boolean allAreConfirmed=true;
		list<PrerequisiteOrder__c>  prerequisiteOrders = new list<PrerequisiteOrder__c>();

		//system.debug('##LISTPO='+[select name,status__c from PurchaseOrder__c where PreRequisiteOrder__c=:purchaseOrder.PrerequisiteOrder__c]);
		//Checking just purchase orders that have at least 1 line to order
		for(PurchaseOrder__c po:[select name,status__c from PurchaseOrder__c where 
										PreRequisiteOrder__c=:purchaseOrder.PrerequisiteOrder__c and
										( status__c = 'ORDERED' or status__c = 'INDELIVERY' OR status__c = 'DELIVERED' or status__c = 'DELIVEREDCONFIRMED')
		]){
			//system.debug('##ITERATION PO='+po.name+po.status__c);
			if(po.status__c!='DELIVEREDCONFIRMED'){
				allAreConfirmed = false;
				//system.debug('###At least one is not confirmedas delivered###'+po.name);
				break;
			}			
		} 
		//system.debug('##confirm###='+allAreConfirmed);
		if(allAreConfirmed){
			prerequisiteOrders = [select id  from PrerequisiteOrder__c where id = :purchaseOrder.PrerequisiteOrder__c];
			if(prerequisiteOrders.size()>0){
				PrerequisiteOrder__c preOrd = prerequisiteOrders[0];
				preOrd.status__c ='PREORDERCONFIRMED';
				preOrd.RecordTypeID = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
				//update assessment status
				update preOrd;
			}
			
		} else {
			prerequisiteOrders = [select id  from PrerequisiteOrder__c where id = :purchaseOrder.PrerequisiteOrder__c];
			if(prerequisiteOrders.size()>0){
				PrerequisiteOrder__c preOrd = prerequisiteOrders[0];
				preOrd.status__c ='RESPONDED';
				preOrd.RecordTypeID = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
			}
		}
	}*/

	public static void executeServiceOrderDeliveryConfirmed(set<Id> setSOId){
		system.debug('## Start executeServiceOrderDeliveryConfirmed');
		//boolean allPOAreDelivered which will determine the status of SO
		Boolean allPOAreDelivered;

		//list of sales orders to update
		list<PrerequisiteOrder__c> listSalesOrderToUpdate = new list<PrerequisiteOrder__c>();

		//map of Sales Order id and its puurchase orders
		map<Id,list<PurchaseOrder__c>> mapSOIdlistPO = new map<Id,list<PurchaseOrder__c>>();

		//looping through a selected list of po to build map mapSOIdlistPO
		for(PurchaseOrder__c po : [select Id , PreRequisiteOrder__c, Status__c 
									from PurchaseOrder__c 
									where PreRequisiteOrder__c in :setSOId 
										and ( status__c = 'ORDERED' 
											or status__c = 'INDELIVERY' 
											or status__c = 'DELIVERED' 
											or status__c = 'DELIVEREDCONFIRMED')]){
			if(mapSOIdlistPO.containsKey(po.PreRequisiteOrder__c)){
				mapSOIdlistPO.get(po.PreRequisiteOrder__c).add(po);
			}
			else{
				mapSOIdlistPO.put(po.PreRequisiteOrder__c,new list<PurchaseOrder__c>{po});
			}
		}

		//looping through map mapSOIdlistPO to add Sales orders to list listSalesOrderToUpdate
		for(Id soId : mapSOIdlistPO.keySet()){
			allPOAreDelivered = true;
			PrerequisiteOrder__c newSalesOrder = new PrerequisiteOrder__c(
														Id = soId, 
														RecordTypeID = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId());
			for(PurchaseOrder__c po : mapSOIdlistPO.get(soId)){
				if(po.status__c != 'DELIVEREDCONFIRMED'){
					allPOAreDelivered = false;
					//break if at least one po is not delivered;
					break;
				}
			}
			//if all Po are delivered, set SO status to PREORDERCONFIRMED
			if(allPOAreDelivered){
				newSalesOrder.Status__c ='PREORDERCONFIRMED'; 
			}
			//else{
			//	newSalesOrder.Status__c ='RESPONDED'; 
			//}
			listSalesOrderToUpdate.add(newSalesOrder);
		}

		if(listSalesOrderToUpdate.size() > 0){
			update listSalesOrderToUpdate;
		}
		system.debug('## End executeServiceOrderDeliveryConfirmed');
	}
	
}