/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchSendInvoicesToCegedim 
  -- - Author        : WCH 
  -- - Description   : Class sending invoices
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 13-NOV-2016  WCH    1.0     Purpose is to send invoices to cegedim to get the pdf identifier before 1 year span. case C-003271
  ----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class ASPISBatchSendInvoicesToCegedim implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    String errorMsg;

    //WCH 10/12/2018: C-002942 - When invocation of cegedim webservice by ASPISBatchSendInvoicesToCegedim fails no log created
    String JsonResp;

    private static Id bodyshopInvoiceId         = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
    private static Id bodyshopCreditNoteId      = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();

    global void execute(SchedulableContext sc) {
        // Schedule the batch
        Database.executeBatch(new ASPISBatchSendInvoicesToCegedim(), 50);  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('---------------------------------- START ASPISBatchSendInvoicesToCegedim - start ----------------------------------');
        Boolean isEnvSandbox = [select id,isSandbox from organization].isSandbox;
        system.debug('isEnvSandbox>>'+isEnvSandbox);
        List<ASPISBatchSendInvoicesToCegedim_Configs__mdt> getProperConfigs = [select id,MasterLabel,DateLiteral__c,EndDate__c,StartDate__c,UseDateLiteral__c from ASPISBatchSendInvoicesToCegedim_Configs__mdt where DeveloperName=:(Test.isRunningTest()?'TEST':(isEnvSandbox ? UserInfo.getUserName().substringAfterLast('.').toUpperCase() : 'PROD'))];
        system.debug('getProperConfigs>>'+getProperConfigs);
        errorMsg = ''; 
        String query = 'Select Id, Number__c,TECH_Number__c,TechCountryCode__c '+
                       ' From Invoice__c ' +
                       ' Where TECH_Number__c=\'\' and InvoiceReference__c!=\'\' and Number__c!=\'\' and TechCountryCode__c!=\'ES\' and (RecordTypeId =: bodyshopInvoiceId OR RecordTypeId =: bodyshopCreditNoteId) AND PrerequisiteOrder__c != null';
        if(getProperConfigs!= null && !getProperConfigs.isEmpty()){
            if(getProperConfigs.get(0).UseDateLiteral__c){
                query+=' and Createddate='+getProperConfigs.get(0).DateLiteral__c;
            }else{
                String startdatetime = getProperConfigs.get(0).startdate__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                String enddatetime = getProperConfigs.get(0).EndDate__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                query+=' and Createddate>='+startdatetime+' and Createddate<'+enddatetime;
            }
        }

        system.debug('## query:'+query);

        System.debug('---------------------------------- END ASPISBatchSendInvoicesToCegedim - start ----------------------------------'); 

        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List <Invoice__c> scope) {

        System.debug('---------------------------------- START ASPISBatchSendInvoicesToCegedim - execute ----------------------------------');

        map <Id,Invoice__c> mapInvtoCegedim = new map<Id,Invoice__c>();
        
        for (Invoice__c inv : scope){
            mapInvtoCegedim.put(inv.Id,inv);
        }
        
        if(mapInvtoCegedim.size() > 0){
            try{
                callCegedimWebservice(mapInvtoCegedim);
            }
            catch(Exception ex){
                system.debug('@@ ex.getMessage(): '+ex.getMessage());
                errorMsg    += 'The following error has occured while calling Cegedim: '
                            + '<br/><br/><table border="1"><tr>'
                            + '<td><b>Error Message: </b></td><td>'
                            + ex.getMessage() 
                            + '</td></tr><tr><td><b>'
                            + 'Error Stack Trace: </b></td><td>' 
                            + ex.getStackTraceString() 
                            + '</td></tr></table><br/>';

                /* APManageLogs.LogsWrapper logToCreate = new APManageLogs.LogsWrapper();
                logToCreate.className='ASPISBatchSendInvoicesToCegedim';
                //logToCreate.jsonmessage= JsonResp;
                logToCreate.jsonResponse= 'The following error has occured while calling Cegedim: ' + ex.getMessage() + ' ' + ex.getStackTraceString()+'.';
                APManageLogs.createWsLog(logToCreate, 'insert'); */
            }
        }
        System.debug('---------------------------------- END ASPISBatchSendInvoicesToCegedim - execute ----------------------------------');
    }

    global void finish(Database.BatchableContext context) {
        System.debug('---------------------------------- START ASPISBatchSendInvoicesToCegedim - finish ----------------------------------');
        System.debug('## errorMsg: ' + errorMsg);
        if(errorMsg != ''){

            AsyncApexJob batchJob = [   SELECT Id, TotalJobItems, CreatedBy.Email, CreatedBy.Name, ApexClass.Name 
                                        FROM AsyncApexJob
                                        WHERE Id =: context.getJobId()];

            List<String> emailAddList = getMailAddresses();
            //emailAddList.addAll(new List<String>{'ashwina.seetaram@sc-mauritius.com','welsa.chan@sc-mauritius.com','nprieto@altirc.com'});
            emailAddList.addAll(new List<String>{'welsa.chan@sc-mauritius.com'});

            sendErrorEmail(batchJob, 'ASPISBatchSendInvoicesToCegedim Error', errorMsg, emailAddList);
        }
        System.debug('---------------------------------- END ASPISBatchSendInvoicesToCegedim - finish ----------------------------------');
        
    }

    private static List<Messaging.SingleEmailMessage> outErrorEmails = null;
    public static void sendErrorEmail(AsyncApexJob a, String subject, String errorMessage, List<String> emailAddressList){
        String emailSubject = 'ASPIS - ' + subject;
        String emailBody = 'Hello, <br/><br/> The batch ' + a.ApexClass.Name + ' launched by ' + a.CreatedBy.Name + ' has treated ' + a.TotalJobItems + ' chunk(s) in the Organisation ' + UserInfo.getOrganizationId()
                         + '<br/><br/> ' + errorMessage + '<br/>Regards, <br/> ASPIS Back Office Team';
                        
        outErrorEmails                          = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage l_objMail  = new Messaging.SingleEmailMessage();

        l_objMail.setToAddresses(emailAddressList);
        l_objMail.setSubject(emailSubject);
        
        l_objMail.setHtmlBody(emailBody);
        outErrorEmails.add(l_objMail);
        
        if (outErrorEmails.size() > 0) {
            Messaging.sendEmail(outErrorEmails);
        }
    }

    public List<String> getMailAddresses()
    {
        List<String> mailList       = new List<String>();
        List<String> mailAddresses  = new List<String>(); 

        for (GroupMember gm : [ SELECT UserOrGroupId
                                FROM    GroupMember 
                                WHERE   Group.DeveloperName = 'SystemAdmins']) 
        {
            mailList.add(gm.UserOrGroupId);
        }
    
        if(mailList.size() > 0)
        {
            List<User> userList = [ SELECT  Email 
                                    FROM    User
                                    WHERE   Id IN : mailList];
            for(User usr : userList) 
            {
                mailAddresses.add(usr.Email);
            }
        }       

        return mailAddresses;
    }

    global void callCegedimWebservice(map <Id,Invoice__c> mapInvoiceIdInvoice){
        Map<Id,Invoice__c> mapInvoiceIdToInvoice = new Map<Id,Invoice__c>();
        String cegedimResponse = '';
        for (Invoice__c inv : mapInvoiceIdInvoice.values()){
            cegedimResponse=RESTPostInvoice.sendRequestForPdf(inv.Number__c,inv.Id, inv.TECH_Number__c,inv.TechCountryCode__c,true);
            mapInvoiceIdToInvoice.put(inv.Id,new Invoice__c(Id=inv.Id,TECH_Number__c=cegedimResponse));
            system.debug('cegedimResponse>>'+cegedimResponse);
        }
        List<Database.SaveResult> updateResults = Database.update(mapInvoiceIdToInvoice.values(), false);
    }
}