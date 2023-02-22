/*************************************************************************************
Class Name - ASPISProcessFlowCreateCasePO
Version - 1.0
Created Date - 21 JAN 2015
Function - Class called  by ASPISCreateCasePOProcess

Modification Log :
-----------------------------------------------------------------------------
* Developer  			Date       	Description
* ---------- 			----------  -----------------------
* Ashwina Seetaram		25/01/2016  Original Version
*************************************************************************************/

public with sharing class ASPISProcessFlowCreateCasePO {
	@InvocableMethod
	public static void createCasePO(list<ASPISProcessBuilderGlobalVariables.variableWrapper> variableList){
		set<Id> POIdSet = new set<Id>();
		map<Id, ASPISProcessBuilderGlobalVariables.variableWrapper> POIdMap = new map<Id, ASPISProcessBuilderGlobalVariables.variableWrapper>();
		//set containing POIds that DO NOT require creation of case
		set<Id> PONoInvoiceIdSet = new set<Id>(); 
		// list of cases to be inserted
		list<Case__c> caseList= new list<Case__c>();

		for(ASPISProcessBuilderGlobalVariables.variableWrapper vw: variableList){
			POIdSet.add(vw.poId);
			POIdMap.put(vw.poId, vw);
		}

		list<PurchaseOrder__c> POList= new list<PurchaseOrder__c>();
		for(PurchaseOrder__c PO: [Select id, (Select Id from Invoices__r) from PurchaseOrder__c where id IN: POIdSet]){
			if(PO.Invoices__r.size() == 0){
				PONoInvoiceIdSet.add(PO.id);
			}
		}
		
   		if(PONoInvoiceIdSet.size()>0){
   			list<ASPISProcessBuilderGlobalVariables.variableWrapper> vwList = new list<ASPISProcessBuilderGlobalVariables.variableWrapper>();
			// create case for remaining PO having no invoices
			for(String POId:PONoInvoiceIdSet){
				vwList.add(POIdMap.get(POId)); 

				PurchaseOrder__c updatedPO = new PurchaseOrder__c(id= POId, TriggeredDelayDate__c = null);
				POList.add(updatedPO);
			}				
			if(vwList.size()>0){
				try{
					//workaround for bug
					//Utils_BusinessDays.isInvokedFromFlow = true;
					ASPISConstants.isInvokedFromFlow = true;
					// create case
					Utils_ManageCaseCustom.createNewCase(vwList); 
					if(POList.size()>0){ 
						update POList;
					}
					ASPISConstants.isInvokedFromFlow = false;
				}
				catch(Exception ex){
					//Shamina M -20160212 - to manage exceptions
					Utils_ManageLogs.createLogFromException('ASPISProcessFlowCreateCasePO', 'PurchaseOrder__c', ex);
				}
				
			}		
   		}    		
	}
}