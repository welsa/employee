/*************************************************************************************
Class Name - RESTGetOrderLineReport
Version - 1.0
Created Date - 15 Oct 2015
Function - Web service to get report of Order Lines

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date            Description
* ----------        ----------      -----------------------
* Immo Salo         15/10/2015      Original Version 
* Shamina M         18/02/2016      C-001518: Removed unnecessary debug logs
* Dourga U          07/10/2016      No longer in use
*************************************************************************************/
//@RestResource(urlMapping='/v1.0/getOrderLineReport/*')
global with sharing class RESTGetOrderLineReport {
    /*@HttpGet
    global static List<Map<String,String>> getOrderLineReport() {
        
        String dateLow = RestContext.request.params.get('dateLow');
        String dateHigh = RestContext.request.params.get('dateHigh');
        String isTest = RestContext.request.params.get('isTest');        
        
        Date dateLowDate;
        Date dateHighDate;
        if(isTest=='yes') {
             dateLowDate = Date.parse(date.today().format());
             dateHighDate = Date.parse(date.today().format());
        }
        else {
            dateLowDate = Date.parse(dateLow);
            dateHighDate = Date.parse(dateHigh);
        }
        
        list<Invoice__c> Invoices = New List<Invoice__c>();
        
        //try {    
            Invoices = 
            [select 
       			Id, 
        		Name,
 		        PurchaseOrder__r.Name,
  		        PurchaseOrder__r.PrerequisiteOrder__r.Name,       
				Assessment__c,
    		    Assessment__r.Id,
      		    Assessment__r.EntityCode__c, 
 		        Assessment__r.ClaimReference__c,
      		    Assessment__r.Bodyshop__r.Name, 
		        Date__c,
        		VAT__c,
                Total__c,
 		        VATDistributor__c,
    		    TotalNet__c,
   		        RecordTypeId
    	   		FROM Invoice__c
        		WHERE Date__c = 2014-10-22
        		ORDER BY Assessment__c
    		];
        //DUN 07/10/2016 Exception never occurs
        //}
        //catch(Exception e) {
        //    Map<String,String> messageMap = New Map<String,String>();
        //    String errorMessage = e.getMessage();
        //    messageMap.put('Message',errorMessage);
        //    List<Map<String,String>> message = New List<Map<String,String>>();
        //    message.add(messageMap);
        //    return message;       
        //}


    Id BodyshopCreditnoteID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId();
    Id BodyshopInvoiceID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId();
    Id DistributorCreditnoteID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId();
    Id DistributorInvoiceID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId();    
    
    Map<Id,List<String>> PurchaseOrderOtherValuesMap = New Map<Id,List<String>>();
    List<String> OtherValuesList = New List<String>();

    Map<Id,Decimal> PurchaseOrderTotalInvoiceSumForBodyshopMap = New Map<Id,Decimal>();
    Map<Id,Decimal> PurchaseOrderTotalInvoiceSumForDistributorMap = New Map<Id,Decimal>();    
    
    Map<Id,Decimal> PurchaseOrderTotalInvoiceSumVATForBodyshopMap = New Map<Id,Decimal>();
    Map<Id,Decimal> PurchaseOrderTotalInvoiceSumVATForDistributorMap = New Map<Id,Decimal>();
    
    Map<Id,Decimal> PurchaseOrderBodyshopVATMap = New Map<Id,Decimal>();
    Map<Id,Decimal> PurchaseOrderDistributorVATMap = New Map<Id,Decimal>(); 
    
    Decimal BodyshopTotalPriceWithVAT = 0.0;
    Decimal DistributorTotalPriceWithVAT = 0.0;

    Decimal BodyshopTotalPriceWithoutVAT = 0.0;
    Decimal DistributorTotalPriceWithoutVAT = 0.0;
    
    List<Id> AssessmentIdList = New List<Id>();
    
    for (Invoice__c i : Invoices){
		
    	OtherValuesList.add(string.valueof(i.Assessment__r.EntityCode__c));
    	OtherValuesList.add(string.valueof(i.Assessment__r.ClaimReference__c));
        OtherValuesList.add(string.valueof(i.Assessment__r.Bodyshop__r.Name));
        
        OtherValuesList.add(string.valueof(i.Assessment__r.Id));
        AssessmentIdList.add(i.Assessment__r.Id);
        
        if(i.RecordTypeId == BodyshopInvoiceID){

    		PurchaseOrderBodyshopVATMap.put(i.PurchaseOrder__c,i.VAT__c);
            
            if(i.VAT__c > 0.0){
				BodyshopTotalPriceWithVAT = i.TotalNet__c * (1 + i.VAT__c/100);
            }
            else {
                BodyshopTotalPriceWithVAT = i.TotalNet__c;
            }
        	BodyshopTotalPriceWithVAT = BodyshopTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForBodyshopMap.keyset().contains(i.PurchaseOrder__c) == false) {
                //system.debug('$$$$$$$$$$$$i.TotalNet__c: '+i.TotalNet__c);
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.PurchaseOrder__c,i.TotalNet__c);
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.PurchaseOrder__c,BodyshopTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.PurchaseOrder__c);
                //system.debug('$$$$$$$$$$$$PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.PurchaseOrder__c): '+PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.PurchaseOrder__c));
                //system.debug('$$$$$$$$$$$$PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.PurchaseOrder__c): '+PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.PurchaseOrder__c));                             
                //system.debug('$$$$$$$$$$$$CurrentSum: '+CurrentSum);
                CurrentSum = CurrentSum + i.TotalNet__c;
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.PurchaseOrder__c,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.PurchaseOrder__c);
                CurrentSumVAT = CurrentSumVAT + BodyshopTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.PurchaseOrder__c,CurrentSumVAT);
            }
        }
        else if(i.RecordTypeId == BodyshopCreditnoteID){

    		PurchaseOrderBodyshopVATMap.put(i.PurchaseOrder__c,i.VAT__c);
            
            if(i.VAT__c > 0.0){
				BodyshopTotalPriceWithVAT = i.TotalNet__c * (1 + i.VAT__c/100);
            }
            else {
                BodyshopTotalPriceWithVAT = i.TotalNet__c;
            }
        	BodyshopTotalPriceWithVAT = BodyshopTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForBodyshopMap.keyset().contains(i.PurchaseOrder__c) == false) {
                Decimal negativeTotalNet = -1.0 * i.TotalNet__c;
                //system.debug('$$$$$$ negativeTotalNet: '+negativeTotalNet);
                Decimal negativeBodyshopTotalPriceWithVAT = -1.0 * BodyshopTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.PurchaseOrder__c,negativeTotalNet);
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.PurchaseOrder__c,negativeBodyshopTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.PurchaseOrder__c);
                CurrentSum = CurrentSum - i.TotalNet__c;
                //system.debug('$$$$$$ CurrentSum: '+CurrentSum);
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.PurchaseOrder__c,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.PurchaseOrder__c);
                CurrentSumVAT = CurrentSumVAT - BodyshopTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.PurchaseOrder__c,CurrentSumVAT);
            }
        }
        else if(i.RecordTypeId ==DistributorInvoiceID){

    		PurchaseOrderDistributorVATMap.put(i.PurchaseOrder__c,i.VATDistributor__c);
            
            if(i.VATDistributor__c > 0.0){
				DistributorTotalPriceWithVAT = i.TotalNet__c * (1 + i.VATDistributor__c/100);
            }
            else {
                DistributorTotalPriceWithVAT = i.TotalNet__c;
            }
        	DistributorTotalPriceWithVAT = DistributorTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForDistributorMap.keyset().contains(i.PurchaseOrder__c) == false) {
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.PurchaseOrder__c,i.Total__c);
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.PurchaseOrder__c,DistributorTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForDistributorMap.get(i.PurchaseOrder__c);
                CurrentSum  = CurrentSum + i.TotalNet__c;
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.PurchaseOrder__c,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForDistributorMap.get(i.PurchaseOrder__c);
                CurrentSumVAT = CurrentSumVAT + DistributorTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.PurchaseOrder__c,CurrentSumVAT);
            }
        }
		else {   // i.RecordTypeId ==DistributorCreditnoteID

    		PurchaseOrderDistributorVATMap.put(i.PurchaseOrder__c,i.VATDistributor__c);
            
            if(i.VATDistributor__c > 0.0){
				DistributorTotalPriceWithVAT = i.TotalNet__c * (1 + i.VATDistributor__c/100);
            }
            else {
                DistributorTotalPriceWithVAT = i.TotalNet__c;
            }
        	DistributorTotalPriceWithVAT = DistributorTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForDistributorMap.keyset().contains(i.PurchaseOrder__c) == false) {
                Decimal negativeTotalNet = -1.0 * i.TotalNet__c;
                Decimal negativeDistributorTotalPriceWithVAT = -1.0 * DistributorTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.PurchaseOrder__c,negativeTotalNet);
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.PurchaseOrder__c,negativeDistributorTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForDistributorMap.get(i.PurchaseOrder__c);
                CurrentSum = CurrentSum - i.TotalNet__c;
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.PurchaseOrder__c,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForDistributorMap.get(i.PurchaseOrder__c);
                CurrentSumVAT = CurrentSumVAT - DistributorTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.PurchaseOrder__c,CurrentSumVAT);
            }
        }
        
        PurchaseOrderOtherValuesMap.put(i.PurchaseOrder__c,OtherValuesList);

    }
    
    
    List<PurchaseOrder__c> POList = [select Assessment__r.Id, Name from PurchaseOrder__c where Assessment__c IN:AssessmentIdList];
    List<PrerequisiteOrder__c> SOList = [select Assessment__r.Id, Name from PrerequisiteOrder__c where Assessment__c IN:AssessmentIdList];    
    
    Map<Id,String> AssessmentToPO = New Map<Id,String>();
    Map<Id,String> AssessmentToSO = New Map<Id,String>();
    
    for(PurchaseOrder__c po:POList) {
        AssessmentToPO.put(po.Assessment__r.Id,po.Name);
    }
    for(PrerequisiteOrder__c so:SOList) {
        AssessmentToSO.put(so.Assessment__r.Id,so.Name);
    }
        
        
        
        
    List<Map<String, String>> OrderLineList = New List<Map<String, String>>();
	for (Id key : PurchaseOrderOtherValuesMap.keySet()) {
//  for (Invoice__c o : Invoices){
		List<String> otherValues = PurchaseOrderOtherValuesMap.get(key);
        
        Decimal PurchaseOrderTotalInvoiceSumForBodyshopDecimal =PurchaseOrderTotalInvoiceSumForBodyshopMap.get(key);
        String PurchaseOrderTotalInvoiceSumForBodyshop = '0,0';
        if(PurchaseOrderTotalInvoiceSumForBodyshopDecimal > 0.0){
             PurchaseOrderTotalInvoiceSumForBodyshop = string.valueof(PurchaseOrderTotalInvoiceSumForBodyshopDecimal);
             PurchaseOrderTotalInvoiceSumForBodyshop = PurchaseOrderTotalInvoiceSumForBodyshop.replace('.', ',');
        }
        
    	Decimal PurchaseOrderTotalInvoiceSumForDistributorDecimal = PurchaseOrderTotalInvoiceSumForDistributorMap.get(key);
		String PurchaseOrderTotalInvoiceSumForDistributor = '0,0';
        if(PurchaseOrderTotalInvoiceSumForDistributorDecimal > 0.0) {
            PurchaseOrderTotalInvoiceSumForDistributor = string.valueOf(PurchaseOrderTotalInvoiceSumForDistributorDecimal);
            PurchaseOrderTotalInvoiceSumForDistributor = PurchaseOrderTotalInvoiceSumForDistributor.replace('.', ',');
        }

        Decimal PurchaseOrderTotalInvoiceSumVATForBodyshopDecimal =PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(key);
        String PurchaseOrderTotalInvoiceSumVATForBodyshop = '0,0';
        if(PurchaseOrderTotalInvoiceSumVATForBodyshopDecimal > 0.0){
             PurchaseOrderTotalInvoiceSumVATForBodyshop = string.valueof(PurchaseOrderTotalInvoiceSumVATForBodyshopDecimal);
             PurchaseOrderTotalInvoiceSumVATForBodyshop = PurchaseOrderTotalInvoiceSumVATForBodyshop.replace('.', ',');
        }
        
    	Decimal PurchaseOrderTotalInvoiceSumVATForDistributorDecimal = PurchaseOrderTotalInvoiceSumVATForDistributorMap.get(key);
		String PurchaseOrderTotalInvoiceSumVATForDistributor = '0,0';
        if(PurchaseOrderTotalInvoiceSumVATForDistributorDecimal > 0.0) {
            PurchaseOrderTotalInvoiceSumVATForDistributor = string.valueOf(PurchaseOrderTotalInvoiceSumVATForDistributorDecimal);
            PurchaseOrderTotalInvoiceSumVATForDistributor = PurchaseOrderTotalInvoiceSumVATForDistributor.replace('.', ',');
        }        
        
    	Decimal PurchaseOrderBodyshopVAT = PurchaseOrderBodyshopVATMap.get(key);
    	Decimal PurchaseOrderDistributorVAT = PurchaseOrderDistributorVATMap.get(key);
      
		Map<String, String> SingleOrderLine = New Map<String, String>();
        
        SingleOrderLine.put('Message','OK');
        SingleOrderLine.put('BS Total Price with VAT',PurchaseOrderTotalInvoiceSumVATForBodyshop);
        SingleOrderLine.put('BS Total Price',PurchaseOrderTotalInvoiceSumForBodyshop);
        SingleOrderLine.put('AXA Total Price with VAT',PurchaseOrderTotalInvoiceSumVATForDistributor);
        SingleOrderLine.put('AXA Total Price',PurchaseOrderTotalInvoiceSumForDistributor);
        SingleOrderLine.put('Bodyshop VAT',String.valueOf(PurchaseOrderBodyshopVAT));
        SingleOrderLine.put('Distributor VAT',String.valueOf(PurchaseOrderDistributorVAT));
        SingleOrderLine.put('Real Delivery Date',otherValues[2]);
        SingleOrderLine.put('BS Name',otherValues[1]);
        SingleOrderLine.put('Entity Code',otherValues[0]);
        SingleOrderLine.put('SO Name',AssessmentToSO.get(Id.valueOf(otherValues[3])));
        SingleOrderLine.put('PO Name',AssessmentToPO.get(Id.valueOf(otherValues[3])));
                                                       
        OrderLineList.add(SingleOrderLine);

    }

    if (OrderLineList.size()==0) {
        Map<String,String> messageMap = New Map<String,String>();
        messageMap.put('Message','No results');
        List<Map<String,String>> message = New List<Map<String,String>>();
        message.add(messageMap);
        return message;
    }
    else {
        return OrderLineList;
    }

    }*/
}