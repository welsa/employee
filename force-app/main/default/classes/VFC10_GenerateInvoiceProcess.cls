/*************************************************************************************
Class Name - VFC10_GenerateInvoiceProcess
Version - 1.0
Created Date - 22/03/2016
Function - Class to re-generate all invoices and credit note of SO

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina S            22/03/2016  Original Version
*************************************************************************************/
public without sharing class VFC10_GenerateInvoiceProcess {
    public PrerequisiteOrder__c so{get;set;}
        
    public VFC10_GenerateInvoiceProcess(ApexPages.StandardController controller) {
        system.debug('######## START VFC10_GenerateInvoiceProcess');
        this.so = (PrerequisiteOrder__c)controller.getRecord(); 
        so = [Select Id
                    ,TECH_BodyshopCountryCode__c
                    ,Assessment__c
                    ,BodyShop__c
                    ,PaymentTerms__c
              from PrerequisiteOrder__c 
              where id =:this.so.id];   
        system.debug('######## END VFC10_GenerateInvoiceProcess');
    }

    public PageReference callInvoiceProcess(){
        system.debug('######## START callInvoiceProcess: ');
        // call process freom class ASPISServiceBodyShopGenerateInvoice
        //if(so.TECH_BodyshopCountryCode__c == 'FR'){
            ASPISServiceBodyShopGenerateInvoice generateInvoiceClass = new ASPISServiceBodyShopGenerateInvoice();
            ASPISServiceBodyShopGenerateInvoice.isGenerateAgainProcess = true;
            
            map<Id,PrerequisiteOrder__c> mapIdSalesOrder = new map<Id,PrerequisiteOrder__c>{so.Id => so};
            generateInvoiceClass.executeProcess(mapIdSalesOrder);
        //}
        
        system.debug('######## END callInvoiceProcess');
        return new PageReference('/'+so.Id);
    }
}