/*************************************************************************************
Class Name - ASPISBatchGenerateCSVBodyshopInvoices
Version - 1.0
Created Date - 30 November 2015
Function - Batch to generate a CSV file with all Bodyshop Invoices in status "SEND" and Purchase Orders.

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Cécile L              30/11/2015  Original Version
*************************************************************************************/
/************************************************************************************
Execute batch on execute Anonymous:
Database.executeBatch(new ASPISBatchGenerateCSVBodyshopInvoices(), 200);
*************************************************************************************/
global class ASPISBatchGenerateCSVBodyshopInvoices{
// ABT 06-MAY-2016 - Commented
/* implements Database.Batchable<sObject>,Database.Stateful {
    
    public String query = 'SELECT Id, ClaimNumber__c, Type__c, Date__c, TotalVAT__c, TotalNet__c, VAT__c, BodyShop__r.LocalReferenceNumber__c, TotalGrossAmount__c, BodyShop__r.ReferenceNumber__c, BodyShop__r.VAT_Type__c, PrerequisiteOrder__c, PrerequisiteOrder__r.Name FROM Invoice__c WHERE Status__c = \'SENT\' AND IsBodyShop__c = true AND PrerequisiteOrder__r.TECH_BodyshopCountryCode__c = \'ES\'';        
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('####ASPISBatchGenerateCSVBodyshopInvoices#### Batch Started = ' + DateTime.now());
        // Query all the Bodyshop invoices where the SO status is INVOICED
        
        System.debug('####ASPISBatchGenerateCSVBodyshopInvoices#### query = ' + query);
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Invoice__c> scope) {
        System.debug('####ASPISBatchGenerateCSVBodyshopInvoices#### Batch Executed with ' +scope.size()+ ' records.');
        if(scope != null && scope.size() > 0)
            AP20GenerateBodyshopInvoicesWithPOinCSV.generateCSVFileForSOstatusInvoices(scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('####ASPISBatchGenerateCSVBodyshopInvoices#### Batch Finished = ' + DateTime.now());       
    }*/
}