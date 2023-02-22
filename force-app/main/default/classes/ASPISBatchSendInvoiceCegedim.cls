/*************************************************************************************
Class Name - ASPISBatchSendInvoiceCegedim
Version - 1.0
Created Date - 23 Nov 2015
Function - Class sending invoices with TECHToBeProcessedCegedim__c checked and  record type Distributor to Cegedim

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------  
* Ashwina S             23/02/2016  Case 1390: Original Version
* Dourga U 				27/05/2016  Commented class, moved logic in class ASPISBatchSendInvoice
*************************************************************************************/
global without sharing class ASPISBatchSendInvoiceCegedim {/*implements Database.Batchable<sObject> , Database.AllowsCallouts {
	
	public String query = 'Select  Id From Invoice__c Where TECHToBeProcessedCegedim__c = true and TechCountryCode__c = \'FR\' and  ((RecordTypeId =\''+Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId()+'\''+') or (RecordTypeId =\''+Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId()+'\''+'))';      
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('####ASPISBatchSendInvoiceCegedim#### Batch Started = ' + DateTime.now());
        // Query all invoices with TECHToBeProcessedCegedim__c checked		
		System.debug('####ASPISBatchSendInvoiceCegedim end');        
		return Database.getQueryLocator(query);
	} 

    global void execute(Database.BatchableContext BC, List <Invoice__c> scope) { 
		System.debug('############ START execute METHOD');
		list<Invoice__c> updatedInvList = new list<Invoice__c>();
		if(scope != null && scope.size() > 0){
			Map<Id, Invoice__c> invIdMap = new Map<Id, Invoice__c>(scope);
			RESTCallWsInvoice_V1.makeCallWsInvoice_V1(invIdMap.keySet()); 

			for(Id invId: invIdMap.keySet()){
				updatedInvList.add(new Invoice__c(id=invId, TECHToBeProcessedCegedim__c = false));
			}
			system.debug('####### updatedInvList:'+updatedInvList);

			if(updatedInvList.size()>0){
				update updatedInvList;
			}
		}
		System.debug('############ END execute METHOD');
    }

    global void finish(Database.BatchableContext info) {
		
	}        */
}