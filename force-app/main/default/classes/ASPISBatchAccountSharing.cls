/*************************************************************************************
Class Name - ASPISBatchAccountSharing
Version - 1.0 
Created Date - 29 Jan 2016
Function -  C-1435: Changing the Bodyshop on the assessment
- account sharing batch class for Spanish  accounts 
- select all accounts where created date = today

Modification Log : 
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Ashwina S             29/03/2016  C-1435: Original Version
* Welsa C               02/09/2020  C-003913:NOB - DEVS l'impact si on cr?e un nouveau recordtype pour les experts
*************************************************************************************/

/************************************************************************************
Execute batch on execute Anonymous:
Database.executeBatch(new ASPISBatchAccountSharing(), 200);
*************************************************************************************/
global class ASPISBatchAccountSharing implements Database.Batchable<sObject>{
    
    // select all accounts created today
    public Id BSRecordId = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT).get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop);
    public Set<Id> setAccountRT = new Set<Id>{BSRecordId,ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT).get(ASPISConstants.ACCOUNT_RT_DeveloperName_Expert)};//WCH 02/09/2020 C-003913
    public String query = 'select id , ReferenceNumber__c, TECHParentAccount__c from Account where (CreatedDate = TODAY OR LastModifiedDate= TODAY) and RecordTypeId IN :setAccountRT and ShippingCountryCode=\'ES\'';//WCH 02/09/2020 C-003913
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('####ASPISBatchAccountSharing #### QueryLocator Started');
        // Query all invoices with TECHToBeShared__c checked      
        System.debug('####ASPISBatchAccountSharing #### QueryLocator Started');      
        return Database.getQueryLocator(query);
    }

    //Processing
    global void execute(Database.BatchableContext BC, List <Account> scope) {
        System.debug('####ASPISBatchAccountSharing #### execute Started');
        
        map<Id, String> parentIdRefMap = new map<Id, String>(); 
        
        for(Account accountToBeShare: scope){
            parentIdRefMap.put(accountToBeShare.Id, accountToBeShare.ReferenceNumber__c);
        }

        if(parentIdRefMap.size()>0){
            // call sharing process
            ASPISAccountSharing.accountSharingDefinition(scope, parentIdRefMap);
        }   

        System.debug('####ASPISBatchAccountSharing #### execute Ended');
    }

    global void finish(Database.BatchableContext BC) {        
    }
}