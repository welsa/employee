/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchGetInvoicePDFToAttachment 
  -- - Author        : RRJ 
  -- - Description   : Class get Invoice PDF to Attachment
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 27-OCT-2022  RRJ    1.0     Permettre un téléchargement en masse des factures sur une période case C-004611
  ----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class ASPISBatchGetInvoicePDFToAttachment implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    String errorMsg;

    //WCH 10/12/2018: C-002942 - When invocation of cegedim webservice by ASPISBatchSendInvoicesToCegedim fails no log created
    String JsonResp;

    private static Id bodyshopInvoiceId         = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_Draft).getRecordTypeId();
    private static Id bodyshopCreditNoteId      = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId();

    global void execute(SchedulableContext sc) {
        // Schedule the batch
        Database.executeBatch(new ASPISBatchGetInvoicePDFToAttachment(), 50);  
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('---------------------------------- START ASPISBatchGetInvoicePDFToAttachment - start ----------------------------------');
        errorMsg = ''; 
        //date lastModif = system.today().format();
        //system.debug('lastModif'+lastModif);
        String query = 'Select Id, Number__c, TECH_Number__c, TechwithAttachment__c, Name, TechCountryCode__c, LastModifiedDate'+
                       ' From Invoice__c ' +
                       ' Where TECH_Number__c !=\'\' and InvoiceReference__c!=\'\' and Number__c!=\'\' and TechCountryCode__c=\'FR\' and (RecordTypeId =: bodyshopInvoiceId OR RecordTypeId =: bodyshopCreditNoteId) AND PrerequisiteOrder__c != null AND LastModifiedDate =LAST_N_DAYS:1' ;
       
        system.debug('## query:'+query);

        System.debug('---------------------------------- END ASPISBatchGetInvoicePDFToAttachment - start ----------------------------------'); 

        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List <Invoice__c> scope) {

        System.debug('---------------------------------- START ASPISBatchGetInvoicePDFToAttachment - execute ----------------------------------');

        map <Id,Invoice__c> mapInvtoCegedim = new map<Id,Invoice__c>();
        
        for (Invoice__c inv : scope){
            mapInvtoCegedim.put(inv.Id,inv);
        }
        
        if(mapInvtoCegedim.size() > 0){
            try{
                callFunctionCreateAttachment(mapInvtoCegedim);
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
            }
        }
        System.debug('---------------------------------- END ASPISBatchGetInvoicePDFToAttachment - execute ----------------------------------');
    }

    global void finish(Database.BatchableContext context) {
        System.debug('---------------------------------- START ASPISBatchGetInvoicePDFToAttachment - finish ----------------------------------');
        System.debug('## errorMsg: ' + errorMsg);
        if(errorMsg != ''){
            
        }
        System.debug('---------------------------------- END ASPISBatchGetInvoicePDFToAttachment - finish ----------------------------------');
        
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

    global void callFunctionCreateAttachment(map <Id,Invoice__c> mapInvoiceIdInvoice){
        system.debug('start callFunctionCreateAttachment');
        map<Id, ContentVersion> mapCV = new map<Id, ContentVersion>();
        List<ContentVersion> lstCV = new List<ContentVersion>();
        list<Invoice__c> invoicetoUpdate = new list<Invoice__c>();
        for (Invoice__c inv : mapInvoiceIdInvoice.values()){
            if(inv.TechwithAttachment__c == false){
                RESTPostInvoice.isFromBatch = true;
                string blobAttachmentInvoice = RESTPostInvoice.retrievePdfBody(inv.TECH_Number__c, inv.Id);
                //String base64Content = ( String ) JSON.deserialize( blobAttachmentInvoice, String.class );
                system.debug('blobAttachmentInvoice = '+blobAttachmentInvoice);
                ContentVersion cv = new ContentVersion();
                //cv.FileExtension = 'PDF';
                //Blob pdfContent = Blob.toPdf(blobAttachmentInvoice);
                cv.VersionData = EncodingUtil.base64Decode(blobAttachmentInvoice);
                //cv.VersionData =EncodingUtil.base64Decode(blobAttachmentInvoice);
                //cv.filetype = 'PDF';
                cv.ContentModifiedDate = system.today();
                cv.PathOnClient = inv.Name+'.PDF';
                cv.Title = inv.Name;
                lstCV.add(cv);
                mapCV.put(inv.Id,cv);
                invoicetoUpdate.add(inv);
            }
        }
        // for (Invoice__c inv : mapInvoiceIdInvoice.values()){
        //     if(inv.withAttachment__c == false){
        //         system.debug('## Test with new attachment and add new attachment');
        //         lstAttachment.add(AP47_ASPISCreateAttachmentFroInvoice.createAttachment(inv.Id, inv.TECH_Number__c,inv.Name));
        //         invoicetoUpdate.add(inv);
        //     }
        // }
        if(invoicetoUpdate.size()>0){
            for(Invoice__c invoice : invoicetoUpdate){
                invoice.TechwithAttachment__c = true;
            }
            update invoicetoUpdate;
        }
        // set<id> invIdexist = new set<Id>();
        // Integer count =0;
        // for (Invoice__c inv : mapInvoiceIdInvoice.values()){
        //     invIdexist.add(inv.Id);
        // }
        // List<Attachment> lstAttachmentOld = new list<Attachment>();
        // lstAttachmentOld = [Select Id, Name, ParentId From Attachment where ParentId IN : invIdexist];
        // system.debug('lstAttachmentOld.size = '+lstAttachmentOld.size());
        // system.debug('lstAttachmentOld = '+lstAttachmentOld);
        // list<Attachment> lstAttachment = new list<Attachment> ();
        // list<Invoice__c> lstInvs = new list<Invoice__c> ();
        // if(lstAttachmentOld.size()>0){
        //     system.debug('## Test with attachment old');
        //     for (Invoice__c inv : mapInvoiceIdInvoice.values()){
        //         for(Attachment atch : lstAttachmentOld){
        //             if(atch.ParentId != inv.Id){
        //                 system.debug('## Test with attachment old and add new attachment');
        //                 count ++;
        //                 system.debug('count = '+count);
        //                 lstInvs.add(inv);
        //                 system.debug('lstInvs ='+lstInvs);
        //             }
        //         }
        //     }
        // }
        // if(count != lstAttachmentOld.size() && lstInvs.size()>0){
        //     for (Invoice__c inv : lstInvs){
        //         system.debug('## Test with new attachment and add new attachment');
        //         lstAttachment.add(AP47_ASPISCreateAttachmentFroInvoice.createAttachment(inv.Id, inv.TECH_Number__c,inv.Name));
        //     }
        // }
        if(lstCV.size()>0){
            insert lstCV;
            system.debug('## lstCV : '+lstCV);
            List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
            for(ContentVersion cv :[SELECT id, ContentDocumentId, Title,VersionData,FirstPublishLocationId FROM ContentVersion WHERE id IN :lstCV]){
                for(id idInvTomap : mapCV.keyset()){
                    ContentVersion cvinmap = mapCV.get(idInvTomap);
                    if(cv.Title == cvinmap.Title){
                        lstCDL.add(new contentDocumentLink(ContentDocumentId = cv.ContentDocumentId ,LinkedEntityId = idInvTomap, ShareType = 'V' ,Visibility = 'AllUsers'));
                    }
                }
            }
            system.debug('## lstCDL ='+lstCDL);
            if(lstCDL != null){
                insert lstCDL;
                system.debug('## lstCDL '+lstCDL);
            }
        }
        else{
            system.debug('No data found');
        }
        system.debug('stop callFunctionCreateAttachment');
    }

    /*private static blob b64toBlob(String data, String contentType, Integer sliceSize) {
        contentType = '';
        sliceSize = 512;
        List<Integer> byteArrays;
        for (Integer offset = 0; offset < data.length(); offset += sliceSize) {
            List<String> slice = slice(data,offset, offset + sliceSize);
    
            List<Integer> byteNumbers = new List<Integer>;
            for (Integer i = 0; i < slice.size(); i++) {
                byteNumbers.add(slice.charCodeAt(i));
            }
    
            List<Integer> byteArray;
            for(Integer i=0; i<byteNumbers.size(); i+=8) {
                byteArray.add(byteNumbers.substring(i, i+8));
            }
    
            byteArrays.add(byteArray);
        }
    
        /* Blob blob = new Blob(byteArrays, {
            type: contentType
        });
        // Blob blob = Blob.valueOf(String.valueOf(byteArrays));
        blob.toPDF(String.valueOf(String.valueOf(byteArrays));
        return blob;
    }  */
}