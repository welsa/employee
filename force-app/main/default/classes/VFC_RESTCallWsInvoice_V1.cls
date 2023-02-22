/*************************************************************************************
Class Name - VFC_RESTCallWsInvoice_V1
Version - 1.0
Created Date - 12 NOV 2015
Function - Makes RESTCallWsInvoice_V1 callout on SO
Modification Log :
-----------------------------------------------------------------------------
* Developer      		Date         Description 
* ----------     	----------  -----------------------
* Ashwina Seetaram    12/11/2015    original Version
* Ashwina Seetaram    04/03/2016    C-001436: put the button on Invoice object and send 
									the invoice the user has selected.
* Dourga U 	          27/05/2016  Commented class, moved logic in class ASPISBatchSendInvoice
*************************************************************************************/

public with sharing class VFC_RESTCallWsInvoice_V1{
	/*public Set<Id> invoicesIdSet;
	public Invoice__c invoice{get;Set;}
	
	public VFC_RESTCallWsInvoice_V1(ApexPages.StandardController stdcontroller){
		system.debug('###### Start VFC_RESTCallWsInvoice_V1');
		this.invoice = (Invoice__c)stdcontroller.getRecord();
		Invoice__c invoice  = [Select RecordTypeId, TechCountryCode__c from Invoice__c where id= :this.invoice.Id];
		invoicesIdSet= new Set<Id>(); 
		// select BodyShop invoice and creditNote
		if(((invoice.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId()) 
		    ||(invoice.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId())) 
			&& invoice.TechCountryCode__c == 'FR'){

			invoicesIdSet.add(invoice.Id);
		}
		system.debug('###### End VFC_RESTCallWsInvoice_V1');	
	}
	
	public PageReference callWsInvoice_V1(){   
		system.debug('###### Start callWsInvoice_V1');		
		if(invoicesIdSet.size()>0){
			RESTCallWsInvoice_V1.makeCallWsInvoice_V1(invoicesIdSet);
		}
		system.debug('###### End callWsInvoice_V1');		
				
		return new PageReference('/'+invoice.Id); 
  	}*/
}