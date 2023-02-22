/*************************************************************************************
Class Name - ASPISBatchSendInvoiceExponens
Version - 1.0
Created Date - 23 Nov 2015
Function - Class sending invoices with status Payable and  record type Distributor to Exponens every night

Modification Log :
----------------------------------------------------------------------------- 
* Developer             Date        Description
* ----------            ----------  -----------------------  
* Ashwina S             23/05/2015  Original Version
* Ashwina S             18/01/2016  Uncomment 'update updatedInvoiceList' and replace field TechToBeProcessed__c by of TECH_InvoiceSentToExponens__c
* Dourga U     	        19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
* Shamina M     		16/02/2016  C-001518: Removed unnecessary debug logs
* Dourga U 				27/05/2016  Commented class, moved logic in class ASPISBatchSendInvoice
*************************************************************************************/
global without sharing class ASPISBatchSendInvoiceExponens {/*implements schedulable, Database.Batchable<sObject> , Database.AllowsCallouts {
	
   global void execute(SchedulableContext sc) {
        // Start the batch, limit it to 10 to avoid callout governor limit.
        // sending 1 so as not to exceed Too many DML rows: 10001
        Database.executeBatch(new ASPISBatchSendInvoiceExponens(), 200);  
    }

   
    global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('####ASPISBatchSendInvoiceExponens#### Batch Started = ' + DateTime.now());
		String query = 'Select  Number__c, PurchaseOrder__r.Name ,Status__c From Invoice__c Where PurchaseOrder__c!=null and Status__c = \'PAYABLE\' and TechToBeProcessed__c = true and TechCountryCode__c = \'FR\' and  ((RecordTypeId =\''+Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId()+'\''+') or (RecordTypeId =\''+Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId()+'\''+'))'; 
        // Query all invoices with TechToBeProcessed__c checked		
		System.debug('####ASPISBatchSendInvoiceExponens end:'+query);        
		return Database.getQueryLocator(query); 
	}

    global void execute(Database.BatchableContext BC, List <Invoice__c> scope) { 
		System.debug('############ START execute METHOD'); 
		
		Set<Id> invoiceIdSet = new Set<Id>();
		List <Invoice__c> updatedInvoiceList = new List <Invoice__c>();
		String endPointExponens = null;
		String passExponens = null;
		String userExponens = null;
		
		JSONGenerator genResults = JSON.createGenerator(false);
		genResults.writeStartArray();
		for (Invoice__c inv : scope){
			genResults.writeStartObject();
				genResults.writeStringField('User','aspis');//UserInfo.getName()

				genResults.writeStringField('Password','aspisVMC2423');

				if (inv.Number__c != null)
				genResults.writeStringField('Number',inv.Number__c);

				if (inv.PurchaseOrder__r.Name != null)
				genResults.writeStringField('PO',inv.PurchaseOrder__r.Name);

				if (inv.Status__c != null)
				genResults.writeStringField('Status',inv.Status__c);

			genResults.writeEndObject();  
			invoiceIdSet.add(inv.Id);
		}
		genResults.writeEndArray();
		String JsonResp = genResults.getAsString();	
		//System.debug(' ##### JsonResp:'+JsonResp);
		
		CountryCodeInformationsMapping__c cs = new CountryCodeInformationsMapping__c();
		Map<String, CountryCodeInformationsMapping__c> mcs = CountryCodeInformationsMapping__c.getAll();

		if (mcs.containsKey('FR')){
			cs = mcs.get('FR');
			
			if (cs.URLInvoiceDistributor__c != null){
				endPointExponens = cs.URLInvoiceDistributor__c;
			}

			if (cs.LoginInvoiceDistributor__c != null){
				userExponens = cs.LoginInvoiceDistributor__c;
			}

			if (cs.PasswordInvoiceDistributor__c != null){
				passExponens = cs.PasswordInvoiceDistributor__c;
			}
		}
	
		if (endPointExponens != null && userExponens != null && passExponens != null){				
			HttpRequest reqAccess = new HttpRequest();
			reqAccess.setMethod('POST');
			// to update end point custom label on PRODUCTION
			reqAccess.setEndpoint(endPointExponens);
			
			// clientKey= userExponens
			// client secret = passExponens
			Blob headerValue = Blob.valueOf(userExponens + ':' + passExponens);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            reqAccess.setTimeout(120000);
			reqAccess.setHeader('Authorization', authorizationHeader);
			reqAccess.setHeader('Content-Type','application/json;charset=UTF-8');
			reqAccess.setBody(JsonResp);
			Http httpCall = new Http();
			HTTPResponse res = httpCall.send(reqAccess);			
			//System.debug(' ##### res:'+res);
			
			if(res.getStatus() == 'OK'){
				for(Id invoiceId : invoiceIdSet){
					Invoice__c updatedInvoice = new Invoice__c(Id= invoiceId, TechToBeProcessed__c= false);
					updatedInvoiceList.add(updatedInvoice);
				}
				update updatedInvoiceList;
			}
		}
		System.debug('############ END execute METHOD');
    }

    global void finish(Database.BatchableContext info) {
		
	}    */    
}