global class AspisBatch_InvoicesUpdate implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_InvoicesUpdate
-- - Author        : WCH 
-- - Description   : bulk update of invoices sent in parameter
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 28-OCT-2021  WCH   1.0      Initial version
--------------------------------------------------------------------------------------
*/  
    //this List contain all invoices to be updated
    public List<Id> lstInvoicesToUpdate = new List<Id>();


    //boolean to detect any issues during batch processing to determine email subject
    public boolean err                                                          = false; 

    global AspisBatch_InvoicesUpdate(List<Id> lstInvsToUpdate) {
        system.debug('## Start AspisBatch_InvoicesUpdate Constructor');
        if(lstInvsToUpdate!=null && !lstInvsToUpdate.isEmpty()){
            this.lstInvoicesToUpdate = lstInvsToUpdate;
        }

        system.debug('## End AspisBatch_InvoicesUpdate Constructor');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_InvoicesUpdate - START');

        return Database.getQueryLocator([select id,TechProcessedByBatchEmail__c
                                                from Invoice__c
                                                where id IN :lstInvoicesToUpdate]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        system.debug('## Start AspisBatch_InvoicesUpdate - execute');

        //list to hold all accounts to be updated
        list <Invoice__c> invToUpdateList = new list <Invoice__c>();

        List <Database.Saveresult> lstResultsInvUpdate;

        //set correctly inserted account id
        //this will be used to insert account ref for correctly updated acc
        set <id> setAccountId                                                   = new set <id>();

        //temp constannts
        string extRef                                                           = '';
        string intRef                                                           = '';
        string systemCalling                                                    = '';
        string accRefName                                                       = '';
        boolean sendAccepted                                                    = false;

        for(SObject currentSObject : scope){
                Invoice__c currentInv = (Invoice__c) currentSObject;
                invToUpdateList.add(new Invoice__c(id=currentInv.Id,TechProcessedByBatchEmail__c=true));
        }
        system.debug('## invToUpdateList.size() ' + invToUpdateList.size());
        
        //updating invoice
        if(!invToUpdateList.isEmpty()){
            lstResultsInvUpdate = Database.update(invToUpdateList, false);
        }//end if 

        system.debug('## End AspisBatch_InvoicesUpdate - execute');
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_InvoicesUpdate - start');
        system.debug('## End AspisBatch_InvoicesUpdate - finish');
    }
}