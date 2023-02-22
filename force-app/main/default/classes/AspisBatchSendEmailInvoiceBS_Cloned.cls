/*
----------------------------------------------------------------------
-- - Name          : AspisBatchSendEmailInvoiceBS
-- - Author        : WCH
-- - Description   : Class to send invoices to specific BS in list of specified invoice Ids in custom label AspisBatchSendEmailInvoiceBSINV 

-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 12-APR-2018  WCH   1.0       Initial version
-- 19-APR-2021  WCH   1.1       C-004317 - Create batch to identify BS Invoices to be included in the invoicing recap sent to bodyshops

Executiom code:
database.executebatch(new AspisBatchSendEmailInvoiceBS_Cloned(), 200); 
----------------------------------------------------------------------*/
global class AspisBatchSendEmailInvoiceBS_Cloned implements schedulable, Database.Batchable<sObject>,Database.Stateful {
    
    String query;

    Map <Id,Id> accountIdMapUserId{get;set;}
    Map<String, Id> mapLanguageCodeEmailTemplate{get;set;}
    Map<String, String> mapUserIdCountryCode{get;set;}
    Map<Id,List<Invoice__c>> userMapInvoiceObj{get;set;}

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AspisBatchSendEmailInvoiceBS_Cloned(), 200);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        accountIdMapUserId = new Map <Id,Id> ();
        mapLanguageCodeEmailTemplate = new Map<String, Id>();
        mapUserIdCountryCode = new Map<String, String>();
        userMapInvoiceObj = new Map<Id,List<Invoice__c>>();
        Datetime nowTime = DateTime.now();

        Set<String> setCountry = new Set<String> ();
        if (Label.Invoicing_Handled_by_cegedim != null){
            List<String> temp = (Label.Invoicing_Handled_by_cegedim).split(';');    
            setCountry.addAll(temp);
        }
        system.debug('@@@ setCountry: '+setCountry);
        
        query = 'SELECT PrerequisiteOrder__r.name, Type__c, Status__c, Number__c, Total__c, InvoicePaidDate__c, IsBodyShop__c , recordtype.developername, BodyShop__r.ContactUser__c, BodyShop__r.ContactUser__r.languagelocalekey  ' +
                'FROM Invoice__c WHERE ' +
                (Test.isRunningTest()?('InvoicePaidDate__c != null AND Status__c =\'PAID\' AND IsBodyShop__c = true AND InvoicePaidDate__c >: nowTime AND PaymentType__c!=\''+ASPISConstants.INV_COMPENSATED_INVOICE+'\' AND  TechCountryCode__c IN : setCountry AND TechProcessedByBatchEmail__c = FALSE'):('ResendRecap__c = true and IsBodyShop__c = true AND PaymentType__c!=\''+ASPISConstants.INV_COMPENSATED_INVOICE+'\' and InvoicePaidDate__c!=null '));

        system.debug('##Query '+query);

        List<String> emailTemplateDevNameList = new List<String>
        {
            'Cloned'+Label.BatchInvoiceTemplateDE,
            'Cloned'+Label.BatchInvoiceTemplateFR,
            'Cloned'+Label.BatchInvoiceTemplateBEFR,
            'Cloned'+Label.BatchInvoiceTemplateBENL
        };  

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
                userMapInvoiceObj.put(inv.BodyShop__r.ContactUser__c, new List<Invoice__c>{new Invoice__c(Id=inv.Id,ResendRecap__c = false)});
            }else{
                userMapInvoiceObj.get(inv.BodyShop__r.ContactUser__c).add(new Invoice__c(Id=inv.Id,ResendRecap__c = false));
            }
        }
        system.debug('##mapUserIdCountryCode: '+mapUserIdCountryCode);
        system.debug('##accountIdMapUserId: '+accountIdMapUserId);
    }
    
    global void finish(Database.BatchableContext BC) {
        List<Messaging.SingleEmailMessage> emailToSendList= new List<Messaging.SingleEmailMessage>();
        List<Invoice__c> listInvoice = new List<Invoice__c>();
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
            //update invoices belonging to only the BS which email was sent successfully
            for(List<Invoice__c> theList : userMapInvoiceObj.values()) listInvoice.addAll(theList);
            update listInvoice;
        }
        
    }
}