global without sharing class ASPISBatchCompensatedInvoice implements schedulable, Database.Batchable<sObject>{

/*
  ----------------------------------------------------------------------
  -- - Name          : AP44UpdateInvoiceForCompensatedAssess
  -- - Author        : ABT
  -- - Description   : updates InvoiceSent__c on all invoices when compensation changes on Assessment
  --
  -- Maintenance History:
  --
  -- Date           Name  Version   Remarks
  -- -----------    ----  -------   ---------------------------------------
  -- 06-DEC-2017    ASE     1.0     C-002061 - Initial version
  ----------------------------------------------------------------------
*/
    private static Id bodyshopInvoiceId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
    private static Id bodyshopCreditNoteId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();

    public void execute(SchedulableContext sc){     
        Database.executeBatch(new ASPISBatchCompensatedInvoice(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('## ASPISBatchCompensatedInvoice.QueryLocator start');

        String query =  'Select ToSendtoExponens__c from Invoice__c '+
                         'Where (Assessment__r.ParentAssessment__r.TechCompensatedIsChanged__c = true or Assessment__r.TechCompensatedIsChanged__c = true)'+
                                 'and (RecordTypeId =: bodyshopInvoiceId OR RecordTypeId =: bodyshopCreditNoteId) '+
                                 'and PrerequisiteOrder__c != null';    

        
        system.debug('## QueryLocator end');
  
        return Database.getQueryLocator(query);         
    }

    global void execute(Database.BatchableContext BC, List <Invoice__c> scope) {
        system.debug('## execute start');

        list <Invoice__c> listInvoicesToUpdate = new list<Invoice__c>();

        for (Invoice__c inv : scope){
            listInvoicesToUpdate.add(new Invoice__c(id= inv.Id, ToSendToExponens__c = true));
        }

        if(listInvoicesToUpdate.size() > 0){
            update listInvoicesToUpdate;
        }
        system.debug('## execute end');

    }

    global void finish(Database.BatchableContext context) {

    }
}