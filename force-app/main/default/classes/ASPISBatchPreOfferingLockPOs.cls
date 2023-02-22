//public with sharing class ASPISBatchPreOfferingLockPOs

/*************************************************************************************
Class Name - ASPISBatchPreOfferingLockPOs
Version - 1.0
Created Date - 22 April 2015
Function - Class that Locks Assessment children Purchase Orders before Offering process running

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Joao Dias		     	19/05/2015  Original Version
************************************************************************************
Batch Calling on execute Anonymous:
ASPISBatchPreOfferingLockPOs batchProc = new ASPISBatchPreOfferingLockPOs();
System.scheduleBatch(batchProc, 'PreOffering Process', 0);
*/

global class ASPISBatchPreOfferingLockPOs {
// ABT - 02-NOV-2016 - C-001625 - Commented
/*
implements Database.Batchable<sObject> {

	String query = 'select id, name, bodyshop__c, entity__c from Assessment__c where QuotationExpired__c = true and status__c = \'SOURCED\'';
	//constructor for permanent Scheduled Batch	
	global ASPISBatchPreOfferingLockPOs() {
		System.debug('#Batch Constructor no parameters =' + query);		
	}	
	
	//constructor for pontual Schedule Batch 
	global ASPISBatchPreOfferingLockPOs(String q) {
		query = q;
		System.debug('#Batch Constructor Query =' + query);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('#Batch Started =' + DateTime.now());
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		System.debug('#Batch Executing =' + DateTime.now());
   		List<Assessment__c> listAss = new List<Assessment__c>();
		for(SObject obj:scope){
			Assessment__c ass 	= (Assessment__c) obj;
			ass.status__c		= 'PREOFFERING';
			listAss.add(ass);
		}
		update listAss;
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('#Batch Finished =' + DateTime.now());
		// ABT 06-MAY-2016 - Commented as the ASPISBatchOfferingBulky in no more in use
		//ASPISBatchOfferingBulky batchProc = new ASPISBatchOfferingBulky();
		//System.scheduleBatch(batchProc, 'Offering Process',0);
	}*/
}