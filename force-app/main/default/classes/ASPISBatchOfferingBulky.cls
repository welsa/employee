/*************************************************************************************
Class Name - ASPISBatchOfferingBulky
Version - 1.0
Created Date - 22 April 2015
Function - Class that delegate/generate Offers

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Joao Dias		     	22/04/2015  Original Version
* Joao Dias				11/05/2015	Avoid Trigger action (stops changing assessment status to execute offering)
*************************************************************************************/
/************************************************************************************
Batch Calling on execute Anonymous:
ASPISBatchOfferingBulky batchProc = new ASPISBatchOfferingBulky();
System.scheduleBatch(batchProc, 'Offering Process', 0);
*************************************************************************************/

global class ASPISBatchOfferingBulky{
// ABT 06-MAY-2016 - Commented
/* implements Database.Batchable<sObject> {


	String query = 'select id, name, bodyshop__c, entity__c from Assessment__c where QuotationExpired__c = true and status__c = \'PREOFFERING\'';

	global ASPISBatchOfferingBulky() {
		System.debug('#Batch Constructor ASPISBatchOfferingBulky =' + query);		
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
			ass.status__c		= 'OFFERING';
			listAss.add(ass);
		}
		if(listAss.size()>0){
			update listAss;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('#Batch Finished =' + DateTime.now());
		//Calculating BusinessTime limite for next execution
		String interval = GlobalVariables__c.getall().get('BatchOffering').value__c;
		BusinessHours businessHoursObj = [select id from businesshours where name = 'BatchOffering'];
		//Added 1 minute to predefined interval (n custom setting) cos addGMT truncates seconds  
		DateTime nextExecution = BusinessHours.addGmt(businessHoursObj.id, Datetime.now(), (Integer.valueOf(interval)+1)*60*1000L);
		system.debug(nextExecution);		
		ASPISBatchPreOfferingLockPOs batchProc = new ASPISBatchPreOfferingLockPOs();
		System.scheduleBatch(batchProc, 'PreOffering Process',(Integer)(nextExecution.getTime()-datetime.now().getTime())/(60*1000));
	}
	*/
}