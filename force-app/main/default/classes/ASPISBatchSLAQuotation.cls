/*************************************************************************************
Class Name - ASPISBatchSLAQuotation
Version - 1.0
Created Date - 08 May 2015
Function - Class generating the Distributor invoice

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Yudish R     			08/05/2015  Original Version
* Shamina M     		16/02/2016  C-001518: Removed unnecessary debug logs
* Vaynee S      		19/07/2018  C-002636: batch SLA level 1 pour l'allemagne
*************************************************************************************/
global class ASPISBatchSLAQuotation implements Schedulable, Database.Batchable<sObject>, Database.Stateful  {

	
	DateTime dt;

	//constructor for permanent Scheduled Batch	
	global ASPISBatchSLAQuotation() {
		
	}	

	global void execute(SchedulableContext sc) {
		Database.executeBatch(new ASPISBatchSLAQuotation(), 15);
		
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query ='';
		string status = ''; 
		dt = Test.isRunningTest()?DateTime.now().addDays(2):DateTime.now();

		status = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE;
		//System.debug('#status =' + status);
		//System.debug('#dt =' + dt);

		query = ' SELECT Id,Name,Status__c,TECHSLAQuotationIsLevel1__c, SuppliableLines__c, UnfilledLines__c, TECHSLAQuotationIsLevel2__c, TECHSLAQuotationIsLevel3__c, SLAQuotationLevel1__c, SLAQuotationLevel2__c, SLAQuotationLevel3__c, distributor__r.OrderRequest__c,TECH_AssessmentCountryCode__c ';
		query += ' FROM PurchaseOrder__c ';
		query += ' WHERE Status__c =:status ';
		query += ' AND ( ' ;
		query += ' (SLAQuotationLevel1__c <=: dt AND TECHSLAQuotationIsLevel1__c=false) ';
		query += ' OR (SLAQuotationLevel2__c <=: dt AND TECHSLAQuotationIsLevel2__c=false) ';
		query += ' OR (SLAQuotationLevel3__c <=: dt AND TECHSLAQuotationIsLevel3__c=false) ';
		query += ' ) ';

		//System.debug('#Batch Constructor no parameters =' + query);		

		return Database.getQueryLocator(query);

	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		System.debug('#ScopeSize =' + scope.size());

		list<PurchaseOrder__c> purchaseOrdersToBeUpdated = new list<PurchaseOrder__c>();
		
		for(SObject obj:scope){
			//System.debug('#obj' + obj);
			
			PurchaseOrder__c pOrder = (PurchaseOrder__c)obj;
			PurchaseOrder__c newPOToUpdate = new PurchaseOrder__c(Id = pOrder.Id);		

			//VSU C-002568 Changed condition to enable sending of email for DE R4
			if(pOrder.SLAQuotationLevel1__c <= dt && pOrder.TECHSLAQuotationIsLevel1__c==false && (pOrder.SuppliableLines__c==0 || (pOrder.distributor__r.OrderRequest__c == 'OrderPO' && pOrder.TECH_AssessmentCountryCode__c == 'DE'))){
				newPOToUpdate.TECHSLAQuotationIsLevel1__c = true;
			}

			if(pOrder.SLAQuotationLevel2__c <= dt && pOrder.TECHSLAQuotationIsLevel2__c==false){
				newPOToUpdate.TECHSLAQuotationIsLevel2__c = true;
			}

			if(pOrder.SLAQuotationLevel3__c <= dt && pOrder.TECHSLAQuotationIsLevel3__c==false){
				newPOToUpdate.TECHSLAQuotationIsLevel3__c = true;
			}

			purchaseOrdersToBeUpdated.add(newPOToUpdate);
		}

		//System.debug('#purchaseOrdersToBeUpdated =' + purchaseOrdersToBeUpdated);
		if(purchaseOrdersToBeUpdated.size()>0){
			update purchaseOrdersToBeUpdated;
		}
	}

	global void finish(Database.BatchableContext BC) {

	}

}