/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchSendInvoice 
  -- - Author        : DUN 
  -- - Description   : Class sending invoices
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 24-MAY-2016  DUN    1.0     Case 1644: Batch to send the invoices to Accounting
  -- 08-SEP-2016  ABT    1.1     Case C-001715: Added try/catch and send email in case of error(ASE also)
  -- 25-SEP-2017  VSU    1.2     Case C-001922: Nmaed Credentials
  -- 06-DEC-2017  ASE    1.3     C-002061 - add compensated requirement. select BS invoices/CR with  
                                 ToSendToExponens__c = true and invNumber != null to send to Exponens
  -- 26-MAR-2018  DUN    1.4     C-002406 : Invoice Sent Failed
  -- 28-NOV-2018  WCH    1.5     C-002567 - Add BodyshopOrderReferences
  -- 10-DEC-2018  WCH    1.6     C-002942 - When invocation of cegedim webservice by ASPISBatchSendInvoice fails no log created
  -- 14-FEB-2019  WCH    1.7     C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
  -- 24-AUG-2020  WCH    1.7     C-003838 - Nob - Migrate Billing information to new fields
  -- 16-DEC-2020  RLA    1.8     C-004117: logs for AspisBatchSendInvoice
  -- 18-MAY-2020  WCH    1.9     C-004356 : Error log after SendInvoice batch failed was not created
  -- 12-JUL-2021  WCH    2.0     C-004403 : Distributor invoices are not being marked as SENT after PAYABLE status is sent to Exponens
  ----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class ASPISBatchSendInvoice implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    // ASE: case 1715
    String errorMsg;

    //WCH 10/12/2018: C-002942 - When invocation of cegedim webservice by ASPISBatchSendInvoice fails no log created
    String JsonResp;

    //RLA 16/12/2020 C-004117: logs for AspisBatchSendInvoice
    String responseExp;
    String logId;
    global void execute(SchedulableContext sc) {
        // Schedule the batch
        Database.executeBatch(new ASPISBatchSendInvoice(), 200);  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('---------------------------------- START ASPISBatchSendInvoice - start ----------------------------------');

        errorMsg = ''; 
        //WCH 24/08/2020 C-003838
        String query = 'Select Id, ICEINVTransmit__c, Number__c, PurchaseOrder__r.Name ,Status__c, RecordTypeId,Assessment__r.AssessmentNumber__c,Assessment__r.ASReference__c, Assessment__r.ClaimReference__c, Assessment__r.ModelV2__c , Assessment__r.Manufacturer__c, '+
                            ' Name,Date__c,Type__c,InvoicePaidDate__c,VAT__c, DueDate__c, PrerequisiteOrder__r.Name,Assessment__r.Id, Assessment__r.AssessmentId__c, Assessment__r.RecordTypeId, TechCountryCode__c, ' +
                            ' BodyShop__r.BillingStreet__c,BodyShop__r.BillingPostalCode__c, BodyShop__r.ContactUser__r.LanguageLocaleKey, BodyShop__r.BillingCountryCode__c, Assessment__r.Compensated__c, Assessment__r.ParentAssessment__r.Compensated__c, ' +
                            ' BodyShop__r.ReferenceNumber__c, BodyShop__r.BillingCity__c,BodyShop__r.VATNumber__c, PaymentType__c, EntityCode__c, BodyShop__r.ASEntity__c, ToSendToExponens__c, PrerequisiteOrder__r.BodyshopOrderNumber__c,TechAssessmentCountryCode__c,'+//WCH 28/11/2018 : C-002567 add fields PrerequisiteOrder__r.BodyshopOrderNumber__c,TechAssessmentCountryCode__c
                            'TechOfferIds__c,'+//WCH 14/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note, add field TechOfferIds__c
                            ' Total__c, TotalNet__c,PlateNumber__c,CreatedDate, BodyShop__r.Name,TotalVAT__c,  BodyShop__r.ContactUser__r.Email, BodyShop__r.ContactEmail__c,' +
                            ' (Select Id,Name,CataloguePrice__c,BSTotalPrice__c, VAT__c,PartNUmber__c,Description__c,Price__c,Quantity__c,PriceWithoutAddDiscount__c, ParentOffer__c, '+ 
                                ' AdditionnalDiscount__c,Discount__c,RealDeliveryDate__c '+
                            ' from Offers__r), '+
                            ' (Select Id,Name,CataloguePrice__c,BSTotalPrice__c, VAT__c,PartNUmber__c,Description__c,Price__c,Quantity__c,PriceWithoutAddDiscount__c, '+
                                ' AdditionnalDiscount__c,Discount__c,RealDeliveryDate__c '+
                            ' from CreditNoteOffers__r)'+
                       ' From Invoice__c ' +
                       ' Where (InvoiceSent__c = false and TechCountryCode__c IN ' + System.label.CountryCodeList + ' AND BodyShop__r.Type != \'Expert\')';
                       // 26/03/2018 DUN C-002406 : Invoice Sent Failed or ToSendToExponens__c = true'; 
        // Query all invoices with TechToBeProcessed__c checked     
        system.debug('## query:'+query);
        System.debug('---------------------------------- END ASPISBatchSendInvoice - start ----------------------------------'); 

        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List <Invoice__c> scope) {

        System.debug('---------------------------------- START ASPISBatchSendInvoice - execute ----------------------------------');

        map <Id,Invoice__c> mapInvoiceDistributor = new map<Id,Invoice__c>();
        map <Id,Invoice__c> mapInvoiceBodyShop = new map<Id,Invoice__c>();
        map <Id,Invoice__c> mapBSInvtoExponens = new map<Id,Invoice__c>();
        list <Invoice__c> listInvoicesToUpdate = new list<Invoice__c>();
        list <Invoice__c> listInvoicesBSToUpdate = new list<Invoice__c>();
        list <Invoice__c> listInvoicesDSToUpdate = new list<Invoice__c>();
        String responseDistributor;
        String responseBodyShop;
        
        for (Invoice__c inv : scope){
            if((((inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Credit Note').getRecordTypeId())
                || (inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId())))){
                if(inv.Number__c == null){
                    mapInvoiceBodyShop.put(inv.Id,inv);
                }
                // 26/03/2018 DUN C-002406 : Invoice Sent Failed
                // ASE 06/12/17: C-002061
                //else{
                //    if(inv.ToSendToExponens__c == true && inv.TechCountryCode__c == 'FR'){
                //        mapInvoiceDistributor.put(inv.Id, inv);
                //    }
                //}
            }
            else if((((inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Credit Note').getRecordTypeId())
                || (inv.RecordTypeId == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Distributor Invoice').getRecordTypeId())))
                && inv.Status__c == 'PAYABLE'){
                mapInvoiceDistributor.put(inv.Id,inv);
            }
        }
        
        if(mapInvoiceDistributor.size() > 0){
            try{
                responseDistributor = callExponensWebservice(mapInvoiceDistributor);
                system.debug('@@ responseDistributor: '+responseDistributor);

                if(responseDistributor == 'OK'){
                    for(Invoice__c invDis : mapInvoiceDistributor.values()){
                        invDis.InvoiceSent__c = true;
                    }
                    listInvoicesDSToUpdate.addAll(mapInvoiceDistributor.values());
                }

                //RLA 16/12/2020 C-004117: logs for AspisBatchSendInvoice
 
                Integer heapsize = Limits.getLimitHeapSize() - 4000000;

                if (Limits.getHeapSize() > heapsize
                    || (test.isRunningTest())){

                    Log__c logReturned = new Log__c();	

                    logReturned.ErrorDescription__c = errorMsg != null && errorMsg.length() <= 30000 ? errorMsg : '';

                    if(String.isNotBlank(errorMsg) && (errorMsg.contains('Exceptions') || (errorMsg.contains('Error') && !errorMsg.contains('"ErrorMessage":null'))) || jsonResp.length() > 65 ) {

                    	logReturned.Status__c = Label.STATUSFAILED;
                    }
                    else{
                    	logReturned.Status__c = Label.STATUSPASSED;
                    }  
                    system.debug('@@ logid: '+logid);	

                    if (logid == null){
                        logReturned.Class__c = 'ASPISBatchSendInvoice -  Exponens';
                        logReturned.JSONMessage__c = jsonResp != null && JsonResp.length() <= 30000 ? JsonResp : '';
                        logReturned.sObject__c = 'Invoice__c';		
                        logReturned.DateLog__c  = System.now();
                        logReturned.JSONResponse__c = responseExp != null && responseExp.length() <= 30000 ? responseExp : '';

                        insert logReturned;	
                    }
                    else{	
                        logReturned.Id = logId;					
                        update logReturned;	

                    }

                    logId = logReturned.Id;
                    if(String.isNotBlank(jsonResp)){
                        String datetoday = String.valueof(date.today());
                        datetoday = datetoday.remove('-');
                        Attachment attachment	= new Attachment(
                                                    Body		= Blob.valueOf(jsonResp),
                                                    Name		= 'Errors'+datetoday+'.csv',
                                                    ParentId	= logId
                                                );
                        insert attachment;

                    }

                    jsonResp = '';
                }
                
			

            }
            catch(Exception ex){
                system.debug('@@ ex.getMessage(): '+ex.getMessage());
                errorMsg    += 'The following error has occured while calling Exponens: '
                            + '<br/><br/><table border="1"><tr>'
                            + '<td><b>Error Message: </b></td><td>'
                            + ex.getMessage() 
                            + '</td></tr><tr><td><b>'
                            + 'Error Stack Trace: </b></td><td>' 
                            + ex.getStackTraceString() 
                            + '</td></tr></table><br/>';
                //WCH 10/12/2018: C-002942 - When invocation of cegedim webservice by ASPISBatchSendInvoice fails no log created
                APManageLogs.LogsWrapper logToCreate = new APManageLogs.LogsWrapper();
                logToCreate.className='ASPISBatchSendInvoice';
                logToCreate.jsonmessage= JsonResp;
                logToCreate.jsonResponse= 'The following error has occured while calling Cegedim: ' + ex.getMessage() + ' ' + ex.getStackTraceString()+'.';
                APManageLogs.createWsLog(logToCreate, '');
            }
        }
        
        if(mapInvoiceBodyShop.size() > 0){
            try{
                responseBodyShop = RESTCallWsInvoice_V1.makeCallWsInvoice_V2(mapInvoiceBodyShop.values());
                system.debug('@@ responseBodyShop: '+responseBodyShop);
                
                if(responseBodyShop == 'OK'){
                    for(Invoice__c invBS : mapInvoiceBodyShop.values()){
                        invBS.InvoiceSent__c = true;
                    }
                    listInvoicesBSToUpdate.addAll(mapInvoiceBodyShop.values());
                }
                system.debug('## listInvoicesToUpdate ' + listInvoicesToUpdate);

            }
            catch(Exception ex){
                //errorMsg += 'The following error has occured while calling Cegedim: ' + ex.getMessage() + ' ' + ex.getStackTraceString();
                system.debug('@@ ex.getMessage(): '+ex.getMessage());
                //WCH 10/12/2018: C-002942 - When invocation of cegedim webservice by ASPISBatchSendInvoice fails no log created
                RESTCallWsInvoice_V1.createLog('The following error has occured while calling Cegedim: ' + ex.getMessage() + ' ' + ex.getStackTraceString()+'.');
                
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

        listInvoicesToUpdate.addAll(listInvoicesDSToUpdate);
        listInvoicesToUpdate.addAll(listInvoicesBSToUpdate);
        if(listInvoicesToUpdate.size() > 0){
                    update listInvoicesToUpdate;
        }

        System.debug('---------------------------------- END ASPISBatchSendInvoice - execute ----------------------------------');
        
    }

    global void finish(Database.BatchableContext context) {
        System.debug('---------------------------------- START ASPISBatchSendInvoice - finish ----------------------------------');
        System.debug('## errorMsg: ' + errorMsg);
        if(errorMsg != ''){

            AsyncApexJob batchJob = [   SELECT Id, TotalJobItems, CreatedBy.Email, CreatedBy.Name, ApexClass.Name 
                                        FROM AsyncApexJob
                                        WHERE Id =: context.getJobId()];

            List<String> emailAddList = getMailAddresses();
            /*
            List<String> emailAddList = new List<String>
            {
                'ashwina.seetaram@sc-mauritius.com'
            };*/
            emailAddList.addAll(new List<String>{'ashwina.seetaram@sc-mauritius.com','welsa.chan@sc-mauritius.com','nprieto@altirc.com'});
            //emailAddList.add('ashutosh.betchoo@sc-mauritius.com');      

            sendErrorEmail(batchJob, 'ASPISBatchSendInvoice Error', errorMsg, emailAddList);
        }
        if (String.isBlank(logId)
			|| test.isRunningTest()){
			// AspisCataloguePricingCommon.insertLog(countryCode, languageCode,errorMessages,strErroredCrossRefs,'AspisBatchCrossRefsScoping',null  );
                Log__c logReturned = new Log__c();	
    
                logReturned.ErrorDescription__c = errorMsg != null ? errorMsg.left(32000) : '';
    
                if(String.isNotBlank(errorMsg) && (errorMsg.contains('Exceptions') || (errorMsg.contains('Error') && !errorMsg.contains('"ErrorMessage":null'))) || (String.isNotBlank(jsonResp) && jsonResp.length() > 65) ) {
    
                    logReturned.Status__c = Label.STATUSFAILED;
                }
                else{
                    logReturned.Status__c = Label.STATUSPASSED;
                }  
                system.debug('@@ logid: '+logid);	
    
                if (logid == null){
                    logReturned.Class__c = 'ASPISBatchSendInvoice';
                    logReturned.JSONMessage__c = jsonResp; 
                    logReturned.sObject__c = 'Invoice__c';		
                    logReturned.DateLog__c  = System.now();
                    logReturned.JSONResponse__c = responseExp != null && responseExp.length() <= 30000 ? responseExp : '';
    
                    insert logReturned;	
                    // logReturned = APManageLogs.createWsLog(wrapperLog, 'insert');
                }
                else{	
                    logReturned.Id = logId;					
                    update logReturned;	
    
                }
    
                logId = logReturned.Id;
                if(String.isNotBlank(jsonResp)){
                    String datetoday = String.valueof(date.today());
                    datetoday = datetoday.remove('-');
                    Attachment attachment	= new Attachment(
                                                Body		= Blob.valueOf(jsonResp),
                                                Name		= 'Errors'+datetoday+'.csv',
                                                ParentId	= logId
                                            );
                    insert attachment;
    
                }

				jsonResp = '';
            }
        System.debug('---------------------------------- END ASPISBatchSendInvoice - finish ----------------------------------');
        
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

    global String callExponensWebservice(map <Id,Invoice__c> mapInvoiceDistributor){
        String endPointExponens = null;
        //String passExponens = null;
        //String userExponens = null;
        String response = null;

        JSONGenerator genResults = JSON.createGenerator(false);
        genResults.writeStartArray();
        for (Invoice__c inv : mapInvoiceDistributor.values()){
            genResults.writeStartObject();
                genResults.writeStringField('User', 'aspis');//UserInfo.getName()

                genResults.writeStringField('Password', 'aspisVMC2423');

                if (inv.Number__c != null){
                    genResults.writeStringField('Number', inv.Number__c);
                }

                if (inv.PurchaseOrder__r.Name != null){
                    genResults.writeStringField('PO', inv.PurchaseOrder__r.Name);
                }

                if (inv.Status__c != null){
                    genResults.writeStringField('Status', inv.Status__c);
                }
                // C
                system.debug('## inv.ToSendToExponens__c ' + inv.ToSendToExponens__c);
                //26/03/2018 DUN C-002406 : Invoice Sent Failed
                //if (inv.ToSendToExponens__c == true){
                //    system.debug('## inv.ToSendToExponens__c ' + inv.ToSendToExponens__c);
                //    if(inv.PrerequisiteOrder__r.Name != null){
                //        genResults.writeStringField('SO', inv.PrerequisiteOrder__r.Name);
                //    }

                //    if(inv.TechCountryCode__c == 'FR' && inv.Assessment__r.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId()){
                //        if (inv.Assessment__r.Compensated__c){
                //            genResults.writeStringField('PaymentType', '97');
                //        } 
                //        else{
                //            genResults.writeStringField('PaymentType', '49');
                //        }
                //    }
                //    else if(inv.TechCountryCode__c == 'FR' && inv.Assessment__r.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId()){
                //        if(inv.Assessment__r.ParentAssessment__r.Compensated__c){
                //            genResults.writeStringField('PaymentType', '97');
                //        } 
                //        else{
                //            genResults.writeStringField('PaymentType', '49');
                //        }
                //    }   
                //}

            genResults.writeEndObject();  
        }
        genResults.writeEndArray();

        //WCH 10/12/2018: C-002942 - When invocation of cegedim webservice by ASPISBatchSendInvoice fails no log created
        JsonResp = genResults.getAsString();

        endPointExponens = 'callout:FR_EXPONENS';       
        System.debug(' ##### JsonResp:'+JsonResp);
        
        /*CountryCodeInformationsMapping__c cs = new CountryCodeInformationsMapping__c();
        Map<String, CountryCodeInformationsMapping__c> mcs = CountryCodeInformationsMapping__c.getAll();

        if (mcs.containsKey('FR')){
            cs = mcs.get('FR');
            
            if (cs.URLInvoiceDistributor__c != null){
                endPointExponens = cs.URLInvoiceDistributor__c;
            }

            if (cs.LoginInvoiceDistributor__c != null){
                userExponens = cs.LoginInvoiceDistributor__c;
            }

            if (cs.PasswordInvoiceDistributor__c != null){
                passExponens = cs.PasswordInvoiceDistributor__c;
            }
        }*/
    
        if (endPointExponens != null /*&& userExponens != null && passExponens != null*/){              
            HttpRequest reqAccess = new HttpRequest();
            reqAccess.setMethod('POST');
            // to update end point custom label on PRODUCTION
            reqAccess.setEndpoint(endPointExponens);
            
            // clientKey= userExponens
            // client secret = passExponens
            /*Blob headerValue            = Blob.valueOf(userExponens + ':' + passExponens);
            String authorizationHeader  = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            reqAccess.setTimeout(120000);
            reqAccess.setHeader('Authorization', authorizationHeader);*/
            reqAccess.setHeader('Content-Type','application/json;charset=UTF-8');
            reqAccess.setBody(JsonResp);
            reqAccess.setTimeout(120000);
            Http httpCall               = new Http();
            system.debug('##reqAccess.getEndpoint() '+reqAccess.getEndpoint());
            HTTPResponse res            = httpCall.send(reqAccess);
            response                    = res.getStatus();
            responseExp = 'Status' + response + ( res != null && res.getBody() != null ? res.getBody() : 'No Response');
        }
        system.debug('## response:' +response);
        return response;
    }
}