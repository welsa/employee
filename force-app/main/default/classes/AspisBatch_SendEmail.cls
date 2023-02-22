global class AspisBatch_SendEmail implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_SendEmail
-- - Author        : WCH 
-- - Description   : send email
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 28-OCT-2021  WCH   1.0      Initial version
--------------------------------------------------------------------------------------
*/  
    public List<Id> listInvoice = new List<Id>();
    public List<Log__c> logsToInsert = new List<Log__c>();
    public Map<String, String> mapUserIdCountryCode = new Map<String, String>();
    public Map <Id,Id> accountIdMapUserId= new Map <Id,Id> ();
    public Map<Id,List<Invoice__c>> userMapInvoiceObj = new Map<Id,List<Invoice__c>>();
    Map<String, Id> mapLanguageCodeEmailTemplate{get;set;}


    //boolean to detect any issues during batch processing to determine email subject
    public boolean err = false; 

    global AspisBatch_SendEmail(Map<String, String> mapUserIdCountryCode1, Map <Id,Id> accountIdMapUserId1, Map<Id,List<Invoice__c>> userMapInvoiceObj1) {
        system.debug('## Start AspisBatch_SendEmail Constructor');
        mapLanguageCodeEmailTemplate = new Map<String, Id>();
        //remove nulls if exist in maps
        mapUserIdCountryCode.remove(null);accountIdMapUserId.remove(null);
        
        if(mapUserIdCountryCode1!=null && !mapUserIdCountryCode1.isEmpty()){
            this.mapUserIdCountryCode = mapUserIdCountryCode1;
        }
        if(accountIdMapUserId1!=null && !accountIdMapUserId1.isEmpty()){
            this.accountIdMapUserId = accountIdMapUserId1;
        }
        if(userMapInvoiceObj1!=null && !userMapInvoiceObj1.isEmpty()){
            this.userMapInvoiceObj = userMapInvoiceObj1;
        }
        List<String> emailTemplateDevNameList = new List<String>{Label.BatchInvoiceTemplateFR,Label.BatchInvoiceTemplateDE,Label.BatchInvoiceTemplateBEFR,Label.BatchInvoiceTemplateBENL};  
        for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                    FROM    EmailTemplate
                                                    WHERE   DeveloperName IN: emailTemplateDevNameList])
        {
            String languageCode = currentEmailTemplate.DeveloperName.substringAfter('_'); //10-01-12 Replaced tech_countrycode
            mapLanguageCodeEmailTemplate.put(languageCode, currentEmailTemplate.id);
        }

        system.debug('##mapLanguageCodeEmailTemplate '+mapLanguageCodeEmailTemplate);
        system.debug('## End AspisBatch_SendEmail Constructor');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_SendEmail - START');

        return Database.getQueryLocator([select id
                                                from account
                                                where id IN :accountIdMapUserId.keyset()]);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        system.debug('## Start AspisBatch_SendEmail - execute');
        List<Messaging.SingleEmailMessage> emailToSendList= new List<Messaging.SingleEmailMessage>();

        for(SObject currentSObject : scope){
                Account currentAct = (Account) currentSObject;
                Id bsId=currentAct.Id;
                
                //loop in each BS to create the email
                //check if there is a template for the BS user according to language
                if(mapLanguageCodeEmailTemplate.get(mapUserIdCountryCode.get(accountIdMapUserId.get(bsId))) != null){
                    Messaging.SingleEmailMessage currentEmail = new Messaging.SingleEmailMessage();
                    currentEmail = Messaging.renderStoredEmailTemplate(mapLanguageCodeEmailTemplate.get(mapUserIdCountryCode.get(accountIdMapUserId.get(bsId))), accountIdMapUserId.get(bsId) , bsId);
                    currentEmail.setTargetObjectId(accountIdMapUserId.get(bsId));
                    currentEmail.setSubject(currentEmail.getSubject());
                    //currentEmail.setCcAddresses(bccAddress);
                    //currentEmail.setBccAddresses(new List<String>{'aspis.support@axa.com'}); re-enable when moving to other env
                    
                    //WCH 19/02/19 C-003088 Add the mailbox of AS Belgium to emailing invoices debited for Belgium BS
                    String BccEmails = Label.AspisBatchSendEmailInvoiceBCCAdmins  + ((mapUserIdCountryCode.get(accountIdMapUserId.get(bsId))!=null && mapUserIdCountryCode.get(accountIdMapUserId.get(bsId)).contains(ASPISConstants.TECH_EntityCountryCodeBE))? (';'+Label.BatchInvoiceTemplateBccBE) : ''); //WCH 24/12/2020 C-003973
                    currentEmail.setBccAddresses(new List<String>(BccEmails.split(';')));

                    currentEmail.setHtmlBody(currentEmail.getHtmlBody());
                    currentEmail.setPlainTextBody(currentEmail.getPlainTextBody());
                    currentEmail.setSaveAsActivity(false);
                    currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);  
                    emailToSendList.add(currentEmail);
                }
   
                
        }
        system.debug('emailToSendList>>'+emailToSendList);
        if(emailToSendList.size() > 0){
            Messaging.SendEmailResult [] mailResult = Messaging.sendEmail(emailToSendList);
            for(Messaging.SendEmailResult singleEmailResult:mailResult){
                system.debug('singleEmailResult>>'+singleEmailResult);
                if(!singleEmailResult.IsSuccess()){
                    Messaging.SendEmailError[] errArr = singleEmailResult.getErrors(); 

                    //create log to be inserted
                    APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
                    wrapperLog.className = 'AspisBatchSendEmailInvoiceBS';
                    wrapperLog.sobjectid = errArr[0].getTargetObjectId();
                    wrapperLog.sobjectName = 'Invoice__c';
                    wrapperLog.errorcode = String.valueOf(errArr[0].getStatusCode());
                    wrapperLog.wserrormessage = errArr[0].getMessage()+'|Invoices not sent by email for BS='+JSON.serialize(userMapInvoiceObj.get(errArr[0].getTargetObjectId()));
                    wrapperLog.status = Label.STATUSFAILED;
                    logsToInsert.add(APManageLogs.createWsLog(wrapperLog, 'insert'));

                    userMapInvoiceObj.remove(errArr[0].getTargetObjectId());
                }
            }

            insert logsToInsert;
        }
        system.debug('## End AspisBatch_SendEmail - execute');
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_SendEmail - start');
        //update invoices belonging to only the BS which email was sent successfully
        for(List<Invoice__c> theList : userMapInvoiceObj.values()){
            for(Invoice__c currentInv1 : theList){
                listInvoice.add(currentInv1.Id);
            }
        }
        Database.executeBatch(new AspisBatch_InvoicesUpdate(listInvoice));
        system.debug('## End AspisBatch_SendEmail - finish');
    }
}