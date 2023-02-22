//Dourga U     07/10/2016   No longer in use
public with sharing class VFC_CSV_reports {

/*private List<Invoice__c> Invoices = New List<Invoice__c>();
private List<String> toAddresses = New List<String>();

public String inputEmail{get;set;}
    
public PageReference sendAsCSV() {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

    Invoices = [select 
        Id, 
        Name,
        PurchaseOrder__r.Id,
        //PurchaseOrder__r.PrerequisiteOrder__r.Name,                
		Assessment__c,
        Assessment__r.Id,
        Assessment__r.EntityCode__c, 
        Assessment__r.ClaimReference__c,
        Assessment__r.Bodyshop__r.Name,
                
        Date__c,
        VAT__c,
        VATDistributor__c,
        Total__c,
        TotalNet__c,
        RecordTypeId
        FROM Invoice__c
        WHERE Date__c = 2014-11-30
        ORDER BY Assessment__c
    ];
    
    Id BodyshopCreditnoteID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId();
    Id BodyshopInvoiceID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId();
    Id DistributorCreditnoteID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId();
    Id DistributorInvoiceID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId();    
    
    Map<Id,List<String>> PurchaseOrderOtherValuesMap = New Map<Id,List<String>>(); // PO Id, String
    Map<Id,List<String>> SalesOrderOtherValuesMap = New Map<Id,List<String>>();      // Assessment Id, String

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
    
    Set<Id> AssessmentIdSet = New Set<Id>();
    Set<Id> PurchaseOrderIDsForOrderLines = New Set<Id>();
    
    for (Invoice__c i : Invoices){

        //system.debug('$$$$ Invoice ID: '+i.Id);
        //system.debug('$$$$ Invoice RecordType: '+i.RecordTypeId);
        List<String> OtherValuesList = New List<String>();
    	OtherValuesList.add(string.valueof(i.Assessment__r.EntityCode__c));
    	OtherValuesList.add(string.valueof(i.Assessment__r.ClaimReference__c));
        OtherValuesList.add(string.valueof(i.Assessment__r.Bodyshop__r.Name));
            
        OtherValuesList.add(string.valueof(i.Assessment__r.Id));
        AssessmentIdSet.add(i.Assessment__r.Id);
        
        if(i.RecordTypeId == BodyshopInvoiceID){
            
    		PurchaseOrderBodyshopVATMap.put(i.Assessment__r.Id,i.VAT__c);
            
            if(i.VAT__c > 0.0){
				BodyshopTotalPriceWithVAT = i.TotalNet__c * (1 + i.VAT__c/100);
            }
            else {
                BodyshopTotalPriceWithVAT = i.TotalNet__c;
            }
        	BodyshopTotalPriceWithVAT = BodyshopTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForBodyshopMap.keyset().contains(i.Assessment__r.Id) == false) {
                //system.debug('$$$$$$$$$$$$i.TotalNet__c: '+i.TotalNet__c);
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.Assessment__r.Id,i.TotalNet__c);
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.Assessment__r.Id,BodyshopTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.Assessment__r.Id);
                //system.debug('$$$$$$$$$$$$PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.PurchaseOrder__c): '+PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.PurchaseOrder__c));
                //system.debug('$$$$$$$$$$$$PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.PurchaseOrder__c): '+PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.PurchaseOrder__c));                             
                //system.debug('$$$$$$$$$$$$CurrentSum: '+CurrentSum);
                CurrentSum = CurrentSum + i.TotalNet__c;
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.Assessment__r.Id,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.Assessment__r.Id);
                CurrentSumVAT = CurrentSumVAT + BodyshopTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.Assessment__r.Id,CurrentSumVAT);
            }
            PurchaseOrderOtherValuesMap.put(i.Assessment__r.Id,OtherValuesList);

        }
        else if(i.RecordTypeId == BodyshopCreditnoteID){      

    		PurchaseOrderBodyshopVATMap.put(i.Assessment__r.Id,i.VAT__c);
            
            if(i.VAT__c > 0.0){
				BodyshopTotalPriceWithVAT = i.TotalNet__c * (1 + i.VAT__c/100);
            }
            else {
                BodyshopTotalPriceWithVAT = i.TotalNet__c;
            }
        	BodyshopTotalPriceWithVAT = BodyshopTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForBodyshopMap.keyset().contains(i.Assessment__r.Id) == false) {
                Decimal negativeTotalNet = -1.0 * i.TotalNet__c;
                //system.debug('$$$$$$ negativeTotalNet: '+negativeTotalNet);
                Decimal negativeBodyshopTotalPriceWithVAT = -1.0 * BodyshopTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.Assessment__r.Id,negativeTotalNet);
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.Assessment__r.Id,negativeBodyshopTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForBodyshopMap.get(i.Assessment__r.Id);
                CurrentSum = CurrentSum - i.TotalNet__c;
                //system.debug('$$$$$$ CurrentSum: '+CurrentSum);
                PurchaseOrderTotalInvoiceSumForBodyshopMap.put(i.Assessment__r.Id,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForBodyshopMap.get(i.Assessment__r.Id);
                CurrentSumVAT = CurrentSumVAT - BodyshopTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForBodyshopMap.put(i.Assessment__r.Id,CurrentSumVAT);
            }
            PurchaseOrderOtherValuesMap.put(i.Assessment__r.Id,OtherValuesList);
        }
        else if(i.RecordTypeId ==DistributorInvoiceID){
            //system.debug('XXX i.RecordTypeId ==DistributorInvoiceID');

    		PurchaseOrderDistributorVATMap.put(i.Assessment__r.Id,i.VATDistributor__c);
            
            if(i.VATDistributor__c > 0.0){
				DistributorTotalPriceWithVAT = i.TotalNet__c * (1 + i.VATDistributor__c/100);
            }
            else {
                DistributorTotalPriceWithVAT = i.TotalNet__c;
            }
        	DistributorTotalPriceWithVAT = DistributorTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForDistributorMap.keyset().contains(i.Assessment__r.Id) == false) {
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.Assessment__r.Id,i.Total__c);
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.Assessment__r.Id,DistributorTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForDistributorMap.get(i.Assessment__r.Id);
                CurrentSum  = CurrentSum + i.TotalNet__c;
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.Assessment__r.Id,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForDistributorMap.get(i.Assessment__r.Id);
                CurrentSumVAT = CurrentSumVAT + DistributorTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.Assessment__r.Id,CurrentSumVAT);
            }
            PurchaseOrderIDsForOrderLines.add(i.PurchaseOrder__r.Id);
        }
		else {   // i.RecordTypeId ==DistributorCreditnoteID

            	//system.debug('XXX i.RecordTypeId ==DistributorCreditnoteID');
    		PurchaseOrderDistributorVATMap.put(i.Assessment__r.Id,i.VATDistributor__c);
            
            if(i.VATDistributor__c > 0.0){
				DistributorTotalPriceWithVAT = i.TotalNet__c * (1 + i.VATDistributor__c/100);
            }
            else {
                DistributorTotalPriceWithVAT = i.TotalNet__c;
            }
        	DistributorTotalPriceWithVAT = DistributorTotalPriceWithVAT.setScale(2);
            if(PurchaseOrderTotalInvoiceSumVATForDistributorMap.keyset().contains(i.Assessment__r.Id) == false) {
                Decimal negativeTotalNet = -1.0 * i.TotalNet__c;
                Decimal negativeDistributorTotalPriceWithVAT = -1.0 * DistributorTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.Assessment__r.Id,negativeTotalNet);
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.Assessment__r.Id,negativeDistributorTotalPriceWithVAT);
            }
            else {
                Decimal CurrentSum = PurchaseOrderTotalInvoiceSumForDistributorMap.get(i.Assessment__r.Id);
                CurrentSum = CurrentSum - i.TotalNet__c;
                PurchaseOrderTotalInvoiceSumForDistributorMap.put(i.Assessment__r.Id,CurrentSum);
                
                Decimal CurrentSumVAT = PurchaseOrderTotalInvoiceSumVATForDistributorMap.get(i.Assessment__r.Id);
                CurrentSumVAT = CurrentSumVAT - DistributorTotalPriceWithVAT;
                PurchaseOrderTotalInvoiceSumVATForDistributorMap.put(i.Assessment__r.Id,CurrentSumVAT);
            }
        }
        PurchaseOrderIDsForOrderLines.add(i.PurchaseOrder__r.Id);
    }
    
    
    List<PurchaseOrder__c> POList = [select Assessment__r.Id, Name from PurchaseOrder__c where Assessment__c IN:AssessmentIdSet];
    List<PrerequisiteOrder__c> SOList = [select Assessment__r.Id, Name from PrerequisiteOrder__c where Assessment__c IN:AssessmentIdSet];    
    
    Map<Id,String> AssessmentToPO = New Map<Id,String>();
    Map<Id,String> AssessmentToSO = New Map<Id,String>();
    
    for(PurchaseOrder__c po:POList) {
        AssessmentToPO.put(po.Assessment__r.Id,po.Name);
    }
    for(PrerequisiteOrder__c so:SOList) {
        AssessmentToSO.put(so.Assessment__r.Id,so.Name);
    }

	// now the problem is here, if there's no invoice with PO reference, there's no Order Lines and then no RealDeliveryDate 23/10/2015    
    List<OrderLine__c> OrderLineList = [select RealDeliveryDate__c, PurchaseOrder__r.Assessment__r.Id from OrderLine__c WHERE RealDeliveryDate__c != null AND PurchaseOrder__c IN :PurchaseOrderIDsForOrderLines];   
    
    Map<Id,Date> RealDeliveryDatesMap = New Map<Id,Date>();
    Id AssessmentThis;
    Id AssessmentPrevious;  
    Date DeliveryTimeThis;
    Date DeliveryTimePrevious;
    
    for(OrderLine__c ol:OrderLineList) {
        //system.debug('XXX In OL LIST! '+ol.RealDeliveryDate__c);
        AssessmentThis = ol.PurchaseOrder__r.Assessment__r.Id;
        //system.debug('ol.PurchaseOrder__r.Assessment__r.Id --> '+ol.PurchaseOrder__r.Assessment__r.Id);
        DeliveryTimeThis = ol.RealDeliveryDate__c;
        if (AssessmentThis != AssessmentPrevious) {  
            DeliveryTimePrevious = date.newInstance(1900, 01, 01);
            //system.debug('date.newInstance(1900, 01, 01)');
        }
            
        if(DeliveryTimePrevious > DeliveryTimeThis) {
             //system.debug('XXX DeliveryTimePrevious > DeliveryTimeThis -->'+DeliveryTimePrevious);
        }
        else {
             //system.debug('ol.RealDeliveryDate__c: '+ol.RealDeliveryDate__c);
             RealDeliveryDatesMap.put(ol.PurchaseOrder__r.Assessment__r.Id, ol.RealDeliveryDate__c);
        }
        
        AssessmentPrevious = ol.PurchaseOrder__r.Assessment__r.Id;
        DeliveryTimePrevious = ol.RealDeliveryDate__c;
    }
    
    String csvContent = 'Purchase Order Name; Sales Order Name; Entity Code; Claim Reference; Bodyshop Name; VAT Distributor; VAT Bodyshop; AXA Total Price; AXA Total Price With VAT; Bodyshop Total Price; Bodyshop Total Price With VAT; Delivery Time\n';
	for (Id key : PurchaseOrderOtherValuesMap.keySet()) {

        //system.debug('$$$$ KEY IS: '+key);
        
    	List<String> otherValues = PurchaseOrderOtherValuesMap.get(key);
        
        Decimal PurchaseOrderTotalInvoiceSumForBodyshopDecimal =PurchaseOrderTotalInvoiceSumForBodyshopMap.get(key);
        String PurchaseOrderTotalInvoiceSumForBodyshop = '0,0';
        if(PurchaseOrderTotalInvoiceSumForBodyshopDecimal > 0.0){            
             PurchaseOrderTotalInvoiceSumForBodyshop = string.valueof(PurchaseOrderTotalInvoiceSumForBodyshopDecimal);
             PurchaseOrderTotalInvoiceSumForBodyshop = PurchaseOrderTotalInvoiceSumForBodyshop.replace('.', ',');
        }
        
    	Decimal PurchaseOrderTotalInvoiceSumForDistributorDecimal = PurchaseOrderTotalInvoiceSumForDistributorMap.get(Id.valueOf(otherValues[3]));
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
        
    	Decimal PurchaseOrderTotalInvoiceSumVATForDistributorDecimal = PurchaseOrderTotalInvoiceSumVATForDistributorMap.get(Id.valueOf(otherValues[3]));
		String PurchaseOrderTotalInvoiceSumVATForDistributor = '0,0';
        if(PurchaseOrderTotalInvoiceSumVATForDistributorDecimal > 0.0) {
            PurchaseOrderTotalInvoiceSumVATForDistributor = string.valueOf(PurchaseOrderTotalInvoiceSumVATForDistributorDecimal);
            PurchaseOrderTotalInvoiceSumVATForDistributor = PurchaseOrderTotalInvoiceSumVATForDistributor.replace('.', ',');
        }        
        
    	Decimal PurchaseOrderBodyshopVAT = PurchaseOrderBodyshopVATMap.get(key);
    	Decimal PurchaseOrderDistributorVAT = PurchaseOrderDistributorVATMap.get(key);
        
        String RealDeliveryDay;
        //system.debug('otherValues[3] -->'+otherValues[3]);
        //system.debug('RealDeliveryDatesMap.get(Id.valueOf(otherValues[3])) -->'+RealDeliveryDatesMap.get(Id.valueOf(otherValues[3])));
        if(RealDeliveryDatesMap.get(key) != null){
            RealDeliveryDay = String.valueOf(RealDeliveryDatesMap.get(key)).substring(0,10);
            //system.debug('HERE 1');
        }
        else {
            RealDeliveryDay = '-';
            //system.debug('HERE 2');
        }
        
        csvContent = csvContent + 
        //otherValues[0] //i.PurchaseOrder__r.Name
        AssessmentToPO.get(key)
        + ';' +         
        //otherValues[1] //i.PurchaseOrder__r.PrerequisiteOrder__r.Name
        AssessmentToSO.get(key)        
        + ';' + 
        otherValues[0] //i.PurchaseOrder__r.Assessment__r.EntityCode__c
        + ';' + 
        otherValues[1] //i.PurchaseOrder__r.Assessment__r.ClaimReference__c
        + ';' + 
        otherValues[2] //i.PurchaseOrder__r.BodyShopName__c  
        + ';' +       
        Integer.valueOf(PurchaseOrderDistributorVAT) //i.VATDistributor__c
        + ';' +       
        Integer.valueOf(PurchaseOrderBodyshopVAT) //i.VAT__c
        + ';' +       
        PurchaseOrderTotalInvoiceSumForDistributor //AXATotalPriceReport  
        + ';' +       
        PurchaseOrderTotalInvoiceSumVATForDistributor //AXATotalPriceWithVATReport  
        + ';' +       
        PurchaseOrderTotalInvoiceSumForBodyshop //BodyshopTotalPriceReport  
        + ';' +       
        PurchaseOrderTotalInvoiceSumVATForBodyshop //BodyshopTotalPriceWithVATReport
        + ';' +
    	RealDeliveryDay                      
        + '\n';

	}    
    
    Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

    blob csvBlob = Blob.valueOf(csvContent);
    string csvname= 'test.csv';
    csvAttc.setFileName(csvname);
    csvAttc.setBody(csvBlob);

    toAddresses.add(inputEmail);
    String subject ='Assessments CSV';

    email.setSubject('CSV: Order Lines from ASPIS');
    email.setToAddresses( toAddresses );
    email.setPlainTextBody('CSV: Order Lines from ASPIS');
    email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
    return null;

}*/

}