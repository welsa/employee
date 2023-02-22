/*
----------------------------------------------------------------------
-- - Name          : AspisBatchSendEmailInvoiceBS
-- - Author        : VSU
-- - Description   : Class to send invoices to BS when the estimated payment date is known 
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 27-APR-2018  VSU   1.0      Case C-002296 Initial version
-- 26-JUL-2018  RLA   1.1      C-002296 : Avis regarding the SEPA mandates (invoices) per Body Shop
-- 30-AUG-2018  WCH   1.2      C-002296 : Avis regarding the SEPA mandates (invoices) per Body Shop(compensated invoices should not be sent)
-- 01-OCT-2018  WCH   1.3      C-002296 : Avis regarding the SEPA mandates (invoices) per Body Shop(compensated invoices should not be sent) >Set BCC to Aspis Support
-- 11-OCT-2018  WCH   1.4      C-002806 : New flow Exponens for compensated invoices > prevent invoice to be sent by mail,if exponens updates invoice to compensated
-- 15-OCT-2018  WCH   1.5      C-002850 : Correction of logic in Batch Send Email Invoice to BS
-- 18-OCT-2018  WCH   1.6      C-002857 : Logs Batch Email Invoice
-- 19-FEB-2019  WCH   1.7      C-003088 : Add the mailbox of AS Belgium to emailing invoices debited for Belgium BS
-- 24-DEC-2019  WCH   1.8      C-003973 : changement de mail axa vers prefikar
Executiom code:
database.executebatch(new AspisBatchSendEmailInvoiceBS(), 200); 
----------------------------------------------------------------------*/
global class AspisBatchSendEmailInvoiceBS implements schedulable, Database.Batchable<sObject>,Database.Stateful {
    
    String query;

    Map <Id,Id> accountIdMapUserId{get;set;}
    Map<String, Id> mapLanguageCodeEmailTemplate{get;set;}
    Map<String, String> mapUserIdCountryCode{get;set;}
    Map<Id,List<Invoice__c>> userMapInvoiceObj{get;set;}
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AspisBatchSendEmailInvoiceBS(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        accountIdMapUserId = new Map <Id,Id> ();
        mapLanguageCodeEmailTemplate = new Map<String, Id>();
        mapUserIdCountryCode = new Map<String, String>();
        userMapInvoiceObj = new Map<Id,List<Invoice__c>>();
        Datetime nowTime = DateTime.now();

        //RLA 26/07/2018 C-002296 : Avis regarding the SEPA mandates (invoices) per Body Shop
        Set<String> setCountry = new Set<String> ();
        if (Label.Invoicing_Handled_by_cegedim != null){
            List<String> temp = (Label.Invoicing_Handled_by_cegedim).split(';');    
            setCountry.addAll(temp);
        }
        system.debug('@@@ setCountry: '+setCountry);
        
        query = 'SELECT Name,PrerequisiteOrder__r.name, Type__c, Status__c, Number__c, Total__c, InvoicePaidDate__c, IsBodyShop__c , recordtype.developername, BodyShop__r.ContactUser__c, BodyShop__r.ContactUser__r.languagelocalekey  ' +
                'FROM Invoice__c ' +
                'WHERE InvoicePaidDate__c != null AND Status__c in (\'PAID\',\'CLOSED\') AND IsBodyShop__c = true AND InvoicePaidDate__c >: nowTime ' //AND Type__c = \'Invoice\''
                //WCH 16/10/2018 C-002850 : Correction of logic in Batch Send Email Invoice to BS > commented this line+ ' AND Assessment__r.Compensated__c!=true'//WCH 30/08/2018 C-002296 : if invoice compensated do not send email 
                + ' AND PaymentType__c!=\''+ASPISConstants.INV_COMPENSATED_INVOICE+'\''//WCH 11/10/2018 C-002806 - New flow Exponens for compensated invoices
                + ' AND  TechCountryCode__c IN : setCountry AND TechProcessedByBatchEmail__c = FALSE';//RLA 26/07/2018 C-002296 : Avis regarding the SEPA mandates (invoices) per Body Shop
                //VSU : To decide if batch will be launched for sending emails
        system.debug('##Query '+query);

        List<String> emailTemplateDevNameList = new List<String>{Label.BatchInvoiceTemplateFR,Label.BatchInvoiceTemplateDE,Label.BatchInvoiceTemplateBEFR,Label.BatchInvoiceTemplateBENL};  

        for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                    FROM    EmailTemplate
                                                    WHERE   DeveloperName IN: emailTemplateDevNameList])
        {
            String languageCode = currentEmailTemplate.DeveloperName.substringAfter('_'); //10-01-12 Replaced tech_countrycode
            mapLanguageCodeEmailTemplate.put(languageCode, currentEmailTemplate.id);
        }

        system.debug('##mapLanguageCodeEmailTemplate '+mapLanguageCodeEmailTemplate);

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> scope) {
        system.debug('### scope.size()' + scope.size());
        for(Invoice__c inv: scope){
            if(!accountIdMapUserId.containsKey(inv.BodyShop__c)){
                accountIdMapUserId.put(inv.BodyShop__c,inv.BodyShop__r.ContactUser__c);
            }
            if(!mapUserIdCountryCode.containsKey(inv.BodyShop__r.ContactUser__c)){
                mapUserIdCountryCode.put(inv.BodyShop__r.ContactUser__c,inv.BodyShop__r.ContactUser__r.languagelocalekey);
            }
            if(!userMapInvoiceObj.containsKey(inv.BodyShop__r.ContactUser__c)){
                userMapInvoiceObj.put(inv.BodyShop__r.ContactUser__c, new List<Invoice__c>{new Invoice__c(Id=inv.Id,TechProcessedByBatchEmail__c = true)});
            }else{
                userMapInvoiceObj.get(inv.BodyShop__r.ContactUser__c).add(new Invoice__c(Id=inv.Id,TechProcessedByBatchEmail__c = true));
            }
        }
        system.debug('##mapUserIdCountryCode: '+mapUserIdCountryCode);
        system.debug('##accountIdMapUserId: '+accountIdMapUserId);
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('##mapUserIdCountryCode: '+mapUserIdCountryCode);
        system.debug('##accountIdMapUserId: '+accountIdMapUserId);
        system.debug('##userMapInvoiceObj: '+userMapInvoiceObj);
        Database.executeBatch(new AspisBatch_SendEmail(mapUserIdCountryCode,accountIdMapUserId,userMapInvoiceObj),3);
        /* List<Messaging.SingleEmailMessage> emailToSendList= new List<Messaging.SingleEmailMessage>();
        List<Id> listInvoice = new List<Id>();
        List<Log__c> logsToInsert = new List<Log__c>();
        //remove nulls if exist in maps
        mapUserIdCountryCode.remove(null);accountIdMapUserId.remove(null);

        //loop in each BS to create the email
        for(Id bsId: accountIdMapUserId.keyset()){
            //check if there is a template for the BS user according to language
            if(mapLanguageCodeEmailTemplate.get(mapUserIdCountryCode.get(accountIdMapUserId.get(bsId))) != null){
                Messaging.SingleEmailMessage currentEmail = new Messaging.SingleEmailMessage();
                currentEmail = Messaging.renderStoredEmailTemplate(mapLanguageCodeEmailTemplate.get(mapUserIdCountryCode.get(accountIdMapUserId.get(bsId))), accountIdMapUserId.get(bsId) , bsId);
                currentEmail.setTargetObjectId(accountIdMapUserId.get(bsId));
                currentEmail.setSubject(currentEmail.getSubject());
                //currentEmail.setCcAddresses(bccAddress);
                                
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

        if(emailToSendList.size() > 0){
            Messaging.SendEmailResult [] mailResult = Messaging.sendEmail(emailToSendList);
            for(Messaging.SendEmailResult singleEmailResult:mailResult){
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
            //update invoices belonging to only the BS which email was sent successfully
            for(List<Invoice__c> theList : userMapInvoiceObj.values()){
                for(Invoice__c currentInv1 : theList){
                    listInvoice.add(currentInv1.Id);
                }
            }
            Database.executeBatch(new AspisBatch_InvoicesUpdate(listInvoice));
        } */
        
    }
}