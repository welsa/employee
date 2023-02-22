/***********************************************************************************************************
Trigger Name - AP12SetInvoiceStatus
Version - 1.0
Created Date - 24 SEP 2015
Function - Class to set invoice status

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Brayan        24/09/2015  Original Version
* Ashwina		01/12/2015 commenting classes
************************************************************************************************************/
public with sharing class AP12SetInvoiceStatus{
	/*
    @future
    public static void determinePOStatus(Set<Id> poIdSet){
        LIST<PurchaseOrder__c> poListToUpdate = new LIST<PurchaseOrder__c>();

        //new dev 23/11/2015
        List<Invoice__c> invoicesToCheck = [Select Id,TotalNet__c,RecordTypeId,PurchaseOrder__r.Id from Invoice__c where PurchaseOrder__c in:poIdSet];
        Map<Id,List<Invoice__c>> invoicesMap = New Map<Id,List<Invoice__c>>();
        for (Invoice__c inv : invoicesToCheck){
            if(invoicesMap.keyset().contains(inv.PurchaseOrder__r.Id) == true){
                List<Invoice__c> tempInvoiceList = invoicesMap.get(inv.PurchaseOrder__r.Id);
                tempInvoiceList.add(inv);
                invoicesMap.put(inv.PurchaseOrder__r.Id,tempInvoiceList);
            }
            else {
                List<Invoice__c> tempInvoiceList = New List<Invoice__c>();
                tempInvoiceList.add(inv);
                invoicesMap.put(inv.PurchaseOrder__r.Id,tempInvoiceList);
            }
        }
        
        // this was commented out 23/11/2015
        //for(PurchaseOrder__c po : [select Id,InvoiceStatus__c,TotalExpectedAmount__c, TECH_AssessmentCountryCode__c, 
        //                            (Select Id,TotalNet__c,RecordTypeId from Invoices__r) from PurchaseOrder__c where Id in:poIdSet])
        for(PurchaseOrder__c po : [select Id,InvoiceStatus__c,TotalExpectedAmount__c, TECH_AssessmentCountryCode__c from PurchaseOrder__c where Id in:poIdSet])                                    
        {
            Decimal totalInvoice = 0;
            Decimal totalCreditNote = 0;
            Decimal total = 0;
            
            system.debug('####### CLA InvoiceMargin__c '+InvoiceMargin__c.getAll());
            InvoiceMargin__c config = InvoiceMargin__c.getAll().get(po.TECH_AssessmentCountryCode__c);
            
            // this loop has been changed 23/11/2015
            if(invoicesMap.keyset().contains(po.Id) == true){
                for(Invoice__c inv : invoicesMap.get(po.Id)){
                    if(inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId()){
                        totalInvoice += inv.TotalNet__c == null ? 0 : inv.TotalNet__c;
                    }else if(inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId()){
                        totalCreditNote += inv.TotalNet__c == null ? 0 : inv.TotalNet__c;
                    }
                }
            }
            
            total = totalInvoice - totalCreditNote;
            
            if(config != null){
                if(po.TotalExpectedAmount__c <= total + config.ValidationMargin__c
                  && po.TotalExpectedAmount__c >= total - config.ValidationMargin__c){
                    po.InvoiceStatus__c = 'VALIDATED';
                }else{
                    po.InvoiceStatus__c = 'NOTVALIDATED';
                    po.InvoiceStatusNotValidated__c = true;
                }
            } else {
                if(po.TotalExpectedAmount__c == total){
                    po.InvoiceStatus__c = 'VALIDATED';
                }else{
                    po.InvoiceStatus__c = 'NOTVALIDATED';
                    po.InvoiceStatusNotValidated__c = true;
                }
            }
            
            poListToUpdate.add(po);
        }
        
        System.debug('///// poListToUpdate: ' + poListToUpdate.size());
        if(poListToUpdate.size()>0){
            update poListToUpdate;
        }
    }*/

}