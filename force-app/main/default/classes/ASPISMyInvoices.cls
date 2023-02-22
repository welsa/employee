/*
----------------------------------------------------------------------
-- - Name          : ASPISMyInvoices
-- - Author        : VSU
-- - Description   : Controller for page ASPISInvoice
--
-- Maintenance History:
--
-- Date      Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 31-JUN-2017  VSU    1.0      Initial version
-- 28-MAR-2018  VSU    1.1      Case C-002321 searchByDate soql injection prevention
-- 30-MAR-2018  VSU    1.1      Case C-002315 Penetration Test Report : Cross Site scripting
-- 10-DEC-2019  WCH    1.2      C-003521 Extraction Factures // R4
-- 25-NOV-2020  WCH    1.3      C-004023 : NOB - Contact Management 2.0
-- 20-MAY-2022  WCH    1.4      C-004693 : extract csv de la liste des factures à partir d'ASPIS
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class ASPISMyInvoices extends CustomControllerBase{
    public static list <Invoice__c> listInvoiceBS;
    public String dateFromJs {get;set;}
    public String dateToJs {get;set;}
    public String locale {get; set;}
    public String currentUserId {get;set;}
    public String encodedUserId {get;set;}
    public Boolean hasErrors {get; set;}
    public static Boolean isToastError {get; set;}
    public String userCurrency{get;set;}
    public static Boolean hasInvoices {get;set;}
    public String xmlheader {get;set;}
    public static boolean isExport {get;set;}
    public static list <invoiceWrapper> invoiceWrapperList {get;set;}
    public map <String,String> mapOriginalTranslated {get;set;}
    public String mapOriginalTranslatedJson {get{return JSON.serialize(mapOriginalTranslated);}}
    private static final String  BASE_URL = 'https://' + DomainCreator.getOrgMyDomainHostname();//URL.getSalesforceBaseUrl().toExternalForm();

    public ASPISMyInvoices(){
        system.debug('##ASPISInvoice constructor');
        locale = UserInfo.getLocale()=='nl_BE'?'nl-BE':UserInfo.getLocale();
        hasErrors = false;
        isToastError = false;

        SObject someObject = new Invoice__c();
        String currencyIso = (UserInfo.isMultiCurrencyOrganization() && someObject.get('CurrencyIsoCode') != null ) ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        if(currencyIso != null){
            userCurrency = 
               ('USD' == currencyIso ? '$' : ('CAD' == currencyIso ? '$' : ('EUR' == currencyIso ? '€' : ('GBP' == currencyIso ? '£' : ('JPY' == currencyIso ? '¥' : ('KRW' == currencyIso ? '₩' : ('CNY' == currencyIso ? '元' : currencyIso)))))));
        }

        mapOriginalTranslated = new map<String,String>();//rla 20/03/2018
        for (Schema.PicklistEntry pe: Invoice__c.Status__c.getDescribe().getPicklistValues()) {
            mapOriginalTranslated.put(pe.getValue(),pe.getLabel());
        }

        hasInvoices = false;

        encodedUserId = ApexPages.currentPage().getParameters().get('Id');
        //VSU 28/03/2018 C-002315 

        try{
            
            Id anId = decryptBase64(encodedUserId);
            currentUserId = decryptBase64(encodedUserId);

        } 
        catch(Exception e){
            if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
                hasErrors = true;
                isToastError = true;
                currentUserId = '';
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
            }
        }

        isExport = false;  

        listInvoiceBS = new list <Invoice__c> (); 

        invoiceWrapperList = new list <invoiceWrapper> ();
              
    }

    public String decryptBase64(String encryptedText)
    {
        Blob decryptedData = EncodingUtil.base64Decode(encryptedText);
        String decryptedText = decryptedData.toString();
        System.debug('Decrypted Text ' + decryptedText);

        return decryptedText;
    }

    public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);
        System.debug('Encrypted Text ' + encryptedData);

        return encryptedData;
    }

    public PageReference downloadInvoiceXls(){
        
        isExport = true;
        Boolean isFR = UserInfo.getLocale().contains('FR')?true:false; //WCH 10/12/2019 C-003521
        system.debug('##UserInfo.getLocale() '+UserInfo.getLocale());
        invoiceWrapperList = searchByDate(currentUserId,dateFromJs,dateToJs,(isFR?true:false));//WCH 10/12/2019 C-003521
        PageReference downloadPage;
        system.debug('##invoiceWrapperList download' + invoiceWrapperList);
        system.debug('##dateFromJs '+dateFromJs);
        system.debug('##dateToJs '+dateToJs);
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        if(dateFromJs != null && dateToJs !=null){
            if(invoiceWrapperList.size() > 0 && invoiceWrapperList.size()<=1000){
                downloadPage  = Page.ExportInvoiceXls;
                ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename= ' + system.label.MyInvoices +' '+dateFromJs+ '_' +dateToJs+'.xls');
                downloadPage.setRedirect(false);
                hasErrors = false;
                isToastError = true;
            }else if(invoiceWrapperList.size()>1000){
                isToastError = true;
                hasErrors = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.ChangeSearchPeriod));
                downloadPage = null;
            }
            else{
                isToastError = true;
                hasErrors = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.DataTableEmptyTable));
                downloadPage = null;
            }
        }

        system.debug('##downloadInvoiceXls '+downloadPage);    
        
        return downloadPage;
    }

    /**
     * Function to verify the permission of the user to the assessment
     * @param  currentClaimAssessment The assessment on which the permissions needs to be checked
     * @return                        Whether the user has access to the assessment
     */
    private static Set<Id> verifyPermission(Set<Id> recordIdSet)
    {
        Set<Id> userRecordAccessSet = new Set<Id>();
        for(UserRecordAccess currentRecordAccess : [SELECT  RecordId
                                                    FROM    UserRecordAccess
                                                    WHERE   RecordId IN: recordIdSet
                                                    AND     UserId =: UserInfo.getUserId()
                                                    AND     HasReadAccess = true])
        {
            userRecordAccessSet.add(currentRecordAccess.RecordId);
        }

        return userRecordAccessSet;
    }

    //WCH 10/12/2019 C-003521 add a parameter
    @RemoteAction
    public static list<invoiceWrapper> searchByDate(String currentUserId, String fromDateStr,String toDateStr,Boolean isPdf){
        listInvoiceBS = new list <Invoice__c> ();
        invoiceWrapperList = new list<invoiceWrapper>();
        currentUserId = Id.valueOf(currentUserId);

        //WCH 25/11/2020 C-004023
        String bsAccountId = currentUserId;
        List<User> currentUser = [Select Id,ContactId,Contact.AccountId from User where id=:currentUserId];
        if(currentUser.size()>0 && currentUser[0].ContactId!=null && currentUser[0].Contact.AccountId!=null){
            bsAccountId=currentUser[0].Contact.AccountId;
        }

        String query = 'SELECT Number__c,PrerequisiteOrder__r.Manufacturer__c,prerequisiteOrder__r.Id,TechCountryCode__c,TECH_Number__c,tolabel(Type__c),Date__c,tolabel(Status__c),InvoiceReference__c,TotalNet__c,Total__c,Claim_Reference__c,PlateNumber__c,prerequisiteorder__r.bodyshopordernumber__c,PrerequisiteOrder__r.Name,EstimatedPaymentDate__c , InvoicePaidDate__c, Assessment__r.MissionNumber__c,prerequisiteorder__r.Model__c,CreatedDate,VAT__c,TotalVAT__c ';
               query += 'FROM Invoice__c where bodyshop__c =: bsAccountId ';
        query += ' AND Number__c != null';
        system.debug('##fromDateStr'+ fromDateStr);
        system.debug('##toDateStr' + toDateStr);

        if(fromDateStr!=null && fromDateStr != '')
        {
            try{
                Date dt1 = Date.parse(fromDateStr);
                query += ' AND Date__c >=: dt1';
                system.debug('##dt1 '+dt1);
            }catch(exception ex){
                system.debug('##Error: '+ex.getMessage());
            }
            
        } 

        if(toDateStr!=null && toDateStr != ''){
            try{
                Date dt2 = Date.parse(toDateStr);
                query += ' AND Date__c <=: dt2';
                system.debug('##dt2 '+dt2);
            }catch(exception ex){
                system.debug('##Error: '+ex.getMessage());
            }            
        }

        //WCH 10/12/2019 C-003521
        if(isPdf){
            query += ' ORDER BY Date__c desc LIMIT 1001';
        }else{
            query += ' ORDER BY Date__c desc LIMIT 200';
        }
                            
        system.debug('##Query '+query);

        Set<Id> recordsToVerifyPermission = new Set<Id>();

        try{
            listInvoiceBS = Database.query(query);
            if(listInvoiceBS.size() > 0){
                hasInvoices = true;
                system.debug('##invoices'+listInvoiceBS);

                for(Invoice__c invoice: listInvoiceBS){
                    invoiceWrapperList.add(new invoiceWrapper(invoice));

                    recordsToVerifyPermission.add(invoice.prerequisiteOrder__r.Id);
                }

                Set<Id> recordWithReadPermission = verifyPermission(recordsToVerifyPermission);

                for(invoiceWrapper invWrp : invoiceWrapperList){
                    if(recordWithReadPermission.contains(invWrp.currentInvoice.prerequisiteOrder__r.Id)){
                        invWrp.hasReadPermission = true;
                    }
                }                           
                    
            }

            system.debug(listInvoiceBS.size());
        }
        catch(exception ex){
            system.debug('##Error: '+ex.getMessage());
        }    

        /*if(invoiceWrapperList.size() > 1000 && isExport == true){
            invoiceWrapperList.clear();
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, System.label.RecordLimitExceeded));         
        }*/

        return invoiceWrapperList;              
    }

    public PageReference redirectPage()
    {

        PageReference pageRef = Page.Search;
        pageRef.setRedirect(true);
        return pageRef;

        return null;
    }

    public class invoiceWrapper{

        public Invoice__c currentInvoice {get;set;}
        public boolean hasReadPermission {get;set;}

        public invoiceWrapper(Invoice__c inv){
            currentInvoice = inv;
            hasReadPermission = false;
        }
    }

    //RRJ C-004611 28/10/2022
    @RemoteAction
    public static PageReference searchAttachmentByDate(String currentUserId, String fromDateStr,String toDateStr){
        Date dt1;
        Date dt2;
        string zipUrl ='';
        if(fromDateStr!=null && fromDateStr != '')
        {
            try{
                dt1 = Date.parse(fromDateStr);
                system.debug('##dt1 '+dt1);
            }catch(exception ex){
                system.debug('##Error: '+ex.getMessage());
            }
            
        }
        Datetime date1 = dt1;
        if(toDateStr!=null && toDateStr != ''){
            try{
                dt2 = Date.parse(toDateStr);
                system.debug('##dt2 '+dt2);
            }catch(exception ex){
                system.debug('##Error: '+ex.getMessage());
            }            
        }
        Datetime date2 = dt2;
        boolean iscorrectdate = checkDateLimit(dt1, dt2);
        Pagereference pg = null;
        if(iscorrectdate){
            list<ContentVersion> lstCVToZip = new list<ContentVersion> ();
            invoiceWrapperList = new list<invoiceWrapper>();
            zipUrl=BASE_URL+'/sfc/servlet.shepherd/version/download/';
            //String url = 'https://' + DomainCreator.getOrgMyDomainHostname();
            //system.debug('##'+url);
            currentUserId = Id.valueOf(currentUserId);
            String bsAccountId = currentUserId;
            List<User> currentUser = [Select Id,ContactId,Contact.AccountId from User where id=:currentUserId];
            if(currentUser.size()>0 && currentUser[0].ContactId!=null && currentUser[0].Contact.AccountId!=null){
                bsAccountId=currentUser[0].Contact.AccountId;
            }
            set<Id> setIdInv = new set<Id>();
            Set<Id> recordsToVerifyPermission = new Set<Id>();
            list<Invoice__c> lstInv = [Select id, Date__c, Number__c,PrerequisiteOrder__r.Manufacturer__c,prerequisiteOrder__r.Id,TechCountryCode__c,TECH_Number__c From Invoice__c where bodyshop__c=: bsAccountId And TechwithAttachment__c = true AND Date__c>: date1.date().addDays(-1) AND Date__c<: date2.date().addDays(+1)];
            if(lstInv.size() > 0){
                hasInvoices = true;
                system.debug('##invoices'+lstInv);
        
                for(Invoice__c invoice: lstInv){
                    invoiceWrapperList.add(new invoiceWrapper(invoice));
                    recordsToVerifyPermission.add(invoice.prerequisiteOrder__r.Id);
                }
                Set<Id> recordWithReadPermission = verifyPermission(recordsToVerifyPermission);
                for(invoiceWrapper invWrp : invoiceWrapperList){
                    if(recordWithReadPermission.contains(invWrp.currentInvoice.prerequisiteOrder__r.Id)){
                        invWrp.hasReadPermission = true;
                        setIdInv.add(invWrp.currentInvoice.Id);
                    }
                }       
            }
            system.debug('setIdv'+setIdInv);
            set<Id> idDL = new set<Id>();
            set<Id> idCD = new set<Id>();
            list<contentDocumentLink> lstDL = new list<contentDocumentLink> ();
            if(setIdInv.size()>0){
                lstDL = [Select Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility FROM ContentDocumentLink where LinkedEntityId IN : setIdInv];
            }
            if(lstDL.size() > 0){
                for(contentDocumentLink item : lstDL){
                    idDL.add(item.LinkedEntityId);
                    idCD.add(item.ContentDocumentId);
                }
            }
            if(idCD.size()>0){
                lstCVToZip = [SELECT id, ContentDocumentId, Title,VersionData,FirstPublishLocationId, ContentModifiedDate FROM ContentVersion WHERE ContentDocumentId IN : idCD];
            }
            system.debug('idDL'+idDL);
            
            // string query = 'SELECT id, ContentDocumentId, Title,VersionData,FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId = \'';
            // for(Id idv : idParent){
            //     query += idv+ '\''+' OR FirstPublishLocationId =\'';
            // }
            // query = query.removeEnd('OR FirstPublishLocationId =\'');
            // System.debug('Querry test'+query);
            // lstCVToZip = Database.query(query);
            // System.debug('Querry test'+lstCVToZip);
            if(lstCVToZip.size()>0){
                for(ContentVersion cv : lstCVToZip){
                    zipUrl+=cv.id+'/';
                }
                zipUrl = zipUrl.RemoveEnd('/');
            }
            else{
                zipUrl = '';
            }
            if(zipUrl != ''){
                pg= new Pagereference(zipUrl);
                pg.setRedirect(true);
                system.debug('zipUrl'+zipUrl);
            }   
        }
        return pg;
    }
    

    //RRJ C-004611 28/10/2022
    @RemoteAction
    public static boolean checkDateLimit(date date1,date date2){
        Integer numberDaysDue = date1.daysBetween(date2);
        if(numberDaysDue>=0 && numberDaysDue<=31){
            system.debug('## true');
            return true;
        }
        else{
            system.debug('## false');
            return false;
        }
    }
}