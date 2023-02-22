/*************************************************************************************
Class Name - AP09PurchaseOrderInvoiceStatus
Version - 1.0
Created Date - ?
Function - Class to manage the invoice status on Purchase Order.

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* ?     ?   Original Version
* Cecile L      17/07/2015  Remove creation of automatic Case from here because was created a Case EACH time the invoice status was not validated. Move in the PurchaseOrderTriggerHandler.
* Brayan Nunhuck 29/10/2015 Re-Adapt class to set Invoice status on Purchase Order
* Dourga Unmole  17/11/2015 case C-001392
*************************************************************************************/
public with sharing class AP09PurchaseOrderInvoiceStatus {/*
	
	public static void setInvoiceStatusOnPO(list<PurchaseOrder__c> poList){
		for (PurchaseOrder__c po : poList){
			decimal margin = 1;
			if ( null != InvoiceMargin__c.getValues(po.TECH_BodyshopCountryCode__c) && null != InvoiceMargin__c.getValues(po.TECH_BodyshopCountryCode__c).ValidationMargin__c)
			{	
				margin = InvoiceMargin__c.getValues(po.TECH_BodyshopCountryCode__c).ValidationMargin__c;
				System.debug('##margin' + margin);
			}
			System.debug('##margin' + margin);
			if (((po.TotalExpectedAmount__c == null ? 0 : po.TotalExpectedAmount__c) - (po.TotalInvoicesAmount__c == null ? 0 : po.TotalInvoicesAmount__c)) <= margin)
			{
				po.InvoiceStatus__c = 'VALIDATED';
			}else{
				po.InvoiceStatus__c = 'NOTVALIDATED';
				// DUN 17/11/2015 case C-001392
				po.InvoiceStatusNotValidated__c = true;
			}
		}
	
	}
	
    /*public static void updateInvoiceStatus(list<PurchaseOrder__c> poList){
        
        for(PurchaseOrder__c po : poList){
            if(po.PrerequisiteOrder__c != null){
                setSOId.add(po.PrerequisiteOrder__c);
            }
        }

        for(PrerequisiteOrder__c so : [select Id, TotalASPrice__c from PrerequisiteOrder__c where Id in: setSOId]){
            mapSOIdTotalAsPrice.put(so.Id,so.TotalASPrice__c);
        }

        system.debug('####### CLA totalCreditNote ' + totalCreditNote);
        totalNetInvoice = totalInvoice - totalCreditNote;
        for(PurchaseOrder__c po : poList){
            system.debug('##po.TECH_BodyshopCountryCode__c'+po.TECH_BodyshopCountryCode__c);
            if(po.TECH_BodyshopCountryCode__c!=null){
                system.debug('##marginValue'+InvoiceMargin__c.getValues(po.TECH_BodyshopCountryCode__c));
                marginValue = InvoiceMargin__c.getValues(po.TECH_BodyshopCountryCode__c).ValidationMargin__c;
            }
            system.debug('##marginValue'+marginValue);
            if(po.TotalInvoicesAmount__c == null)
                po.TotalInvoicesAmount__c = 0.0;
            if(po.TotalCreditNoteAmount__c == null)
                po.TotalCreditNoteAmount__c = 0.0;
            if(po.TotalInvoicesAmount__c != null && po.TotalCreditNoteAmount__c != null &&  mapSOIdTotalAsPrice.get(po.PrerequisiteOrder__c) != null){
                if(math.abs((po.TotalInvoicesAmount__c - po.TotalCreditNoteAmount__c) - mapSOIdTotalAsPrice.get(po.PrerequisiteOrder__c)) <= marginValue){
                    po.InvoiceStatus__c = 'VALIDATED';
                }
                else{
                    po.InvoiceStatus__c = 'NOTVALIDATED';
               
                }
            }
        }  
        System.Debug('#l_casesToInsert1:'+listcasesToInsert );
    }*/
}