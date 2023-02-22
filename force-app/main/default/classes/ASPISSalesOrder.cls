/*
----------------------------------------------------------------------
-- - Name          : ASPISSalesOrder
-- - Author        : ABT
-- - Description   : Controller for ASPISSalesOrder
--
-- Maintenance History:
--
-- Date      Name  Version    Remarks
-- -----------  ----  -------    ---------------------------------------
-- 20-MAR-2017  ABT    1.0      Initial version
-- 31-JUL-2017  VSU    1.1     
-- 30-AUG-2017  VSU    1.2      Added extension to call remote action RestPostInvoice
-- 03-APR-2018  VSU    1.3      C-002315 Cross Scripting 
-- 23-NOV-2018  AMI    1.4      C-002781 : Migrate Spain to R4
--                                       : Display Cases In Related List
-- 14-DEC-2018  AMI    1.5      C-002781 : Migrate Spain to R4
--                                       : Display Chatter Feed
-- 07-AUG-2019  WCH    1.6      C-003318 : Add "Download Delivery Note" button to R4
-- 21-NOV-2019  WCH    1.7      C-003486 : Download Delivery Note button on R4 should create a Delivery Note PDF, not an Order Confirmation
-- 10-NOV-2020  KPA    1.8      C-004026 : Pentest - Insecure Direct Object Reference
-- 21-NOV-2019  WCH    1.9      C-004148 : cancellation button on AspissalesOrder page for R3
----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class ASPISSalesOrder extends CustomControllerBase
{
  public String encodedSalesOrderId {get;set;}
  public Boolean hasSalesOrderId {get; set;}
  public PrerequisiteOrder__c currentSalesOrder {get; set;}
  public Boolean hasErrors {get; set;}
  public Boolean isToastError {get; set;}
  public String backURL {get; set;}
  public list <Invoice__c> invoiceList {get;set;}
  public boolean hasInvoice {get;set;}
  public integer numberOfOffers {get;set;}
  public String userCurrency{get;set;}
  public boolean hasReadPermission {get;set;}
  public Boolean redirectionInErrorModal {get; set;}
  public Boolean showDownloadDeliveryNoteButton {get; set;}//WCH 07/08/2019 C-003318
  public Boolean showBSCancelSOButton {get; set;}//WCH 21/01/2021 C-004148
  
  //AMI 23/11/18  C-002781 : Migrate Spain to R4
  //                       : Display Cases In Related List
  //                       : boolean to determine whether to display cases in relatedList
  public boolean showCases {get;set;}

  //AMI 23/11/18  C-002781 : Migrate Spain to R4
  //                       : Display Cases In Related List
  //                       : wrapper containing case to display
  public list <CaseWrapper> lstCaseWrapper {get;set;}

  //AMI 14/12/18  C-002781 : Migrate Spain to R4
  //                       : Display Chatter Feed
  //                       : boolean to determine whether to display chatter feed
  public boolean showFeed {get;set;}

  public ASPISSalesOrder()
  {
    hasErrors      = false;
    isToastError    = false;
    currentSalesOrder  = new PrerequisiteOrder__c();
    encodedSalesOrderId = ApexPages.currentPage().getParameters().get('Id');
    hasSalesOrderId    = false;
    hasInvoice = false;
    numberOfOffers = 0;
    hasReadPermission = false;

    //AMI 23/11/18  C-002781 : Migrate Spain to R4
    //                       : Display Cases In Related List
    //                       : initialise boolean
    showCases = false;

    //AMI 23/11/18  C-002781 : Migrate Spain to R4
    //                       : Display Cases In Related List
    //                       : initialise wrapper
    lstCaseWrapper = new list <CaseWrapper>();

    //AMI 14/12/18  C-002781 : Migrate Spain to R4
    //                       : Display Chatter Feed
    //                       : boolean to determine whether to display chatter feed
    showFeed = false;

    //WCH 07/08/2019 C-003318
    showDownloadDeliveryNoteButton=false;
    
    //WCH 21/01/2021 C-004148
        showBSCancelSOButton=false;

    SObject someObject = new Invoice__c();
    String currencyIso = (UserInfo.isMultiCurrencyOrganization() && someObject.get('CurrencyIsoCode') != null ) ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
    if(currencyIso != null){
        userCurrency = 
           ('USD' == currencyIso ? '$' : ('CAD' == currencyIso ? '$' : ('EUR' == currencyIso ? '€' : ('GBP' == currencyIso ? '£' : ('JPY' == currencyIso ? '¥' : ('KRW' == currencyIso ? '₩' : ('CNY' == currencyIso ? '元' : currencyIso)))))));
    }

    try
    {
      if(encodedSalesOrderId != null){
        String salesOrderId = decryptBase64(encodedSalesOrderId);
        //VSU 02/04/18 C-002315
        Id anId = salesOrderId;

        //AMI 23/11/18  C-002781 : Migrate Spain to R4
        //                       : Display Cases In Related List
        //                       : query case to display
        currentSalesOrder = [SELECT  Id, Name ,Assessment__c, Assessment__r.ParentAssessment__c, Status__c, BodyShopOrderNumber__c, TECH_BodyshopCountryCode__c,
                      Assessment__r.PlateNumber2__c, Assessment__r.VINNumber__c, Assessment__r.Manufacturer__c, Assessment__r.ModelV2__c, Assessment__r.ClaimReference__c, Assessment__r.MissionNumber__c,Assessment__r.Recordtype.DeveloperName,CancelationReason__c,/* WCH 21/01/2021 C-004148 */
                      (SELECT tolabel(Type__c),TechCountryCode__c,tolabel(Status__c),Number__c,TotalNet__c,Total__c,EstimatedPaymentDate__c,TECH_Number__c FROM Invoices__r where Number__c != null),
                      (SELECT id from Offers__r),
                      (Select id,Name,Description__c,Comment__c,Purchase_order__c,Purchase_order__r.Distributor__r.Name,Type__c,Subject__c,SLAIcon__c,Status__c,CreatedDate
                        from Cases__r)
                   FROM  PrerequisiteOrder__c
                   WHERE  Id =: salesOrderId];

        hasSalesOrderId = true;

        invoiceList = currentSalesOrder.Invoices__r;

        if(invoiceList.size() >0 ){
          hasInvoice = true;
        }

        //AMI 23/11/18  C-002781 : Migrate Spain to R4
        //                       : Display Cases In Related List
        //                       : boolean to determine whether to display cases in relatedList
        if(currentSalesOrder != null && currentSalesOrder.TECH_BodyshopCountryCode__c == ASPISConstants.userCountryCodeES){
          showCases = true;
        }else{
          showCases = false;
        }

        //AMI 23/11/18  C-002781 : Migrate Spain to R4
        //                       : Display Cases In Related List
        //                       : building lstCaseWrapper
        if(currentSalesOrder != null && currentSalesOrder.Cases__r.size() > 0){
          for(case__c cs : currentSalesOrder.Cases__r){
            CaseWrapper cseWrap = new CaseWrapper();
            cseWrap.cse = cs;
            cseWrap.cseEncodedId = encryptBase64(string.valueOf(cs.Id));
            lstCaseWrapper.add(cseWrap);
          }
        }

        //AMI 14/12/18  C-002781 : Migrate Spain to R4
        //                       : Display Chatter Feed
        //                       : boolean to determine whether to display chatter feed
        Map<String, CountryCodeInformationsMapping__c> mapCountryCodeMapping = CountryCodeInformationsMapping__c.getAll();

        if(string.isNotBlank(currentSalesOrder.TECH_BodyshopCountryCode__c) && mapCountryCodeMapping.containsKey((currentSalesOrder.TECH_BodyshopCountryCode__c).toUpperCase())){
            showFeed = mapCountryCodeMapping.get((currentSalesOrder.TECH_BodyshopCountryCode__c).toUpperCase()).EnableChatterFeed__c;

            //WCH 07/08/2019 C-003318
            showDownloadDeliveryNoteButton = mapCountryCodeMapping.get((currentSalesOrder.TECH_BodyshopCountryCode__c).toUpperCase()).R4DeliveryNoteDownloadable__c;
            
            //WCH 21/01/2021 C-004148
                    showBSCancelSOButton=(currentSalesOrder.Assessment__r.Recordtype.DeveloperName==ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment && currentSalesOrder.Status__c==ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE && mapCountryCodeMapping.get((currentSalesOrder.TECH_BodyshopCountryCode__c).toUpperCase()).SOCancellationButton__c)?true:false;
        }
      }

      Set<Id> recordsToVerifyPermission = new Set<Id>();

      recordsToVerifyPermission.add(currentSalesOrder.id);

      Set<Id> recordWithReadPermission = verifyPermission(recordsToVerifyPermission);

      if(recordWithReadPermission.contains(currentSalesOrder.id)){
        hasReadPermission = true;
      }
      else
      {
        hasErrors = true;
        isToastError = false;
        redirectionInErrorModal = true;
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.InsufficientPrivileges));
        system.debug('##redirectionInErrorModal: '+redirectionInErrorModal);
      }

      if(currentSalesOrder.Offers__r.size() > 0){
        numberOfOffers = currentSalesOrder.Offers__r.size();
      }

      // Using this code so as for Italian R3 assessment can be shown on the Search Page in the recently viewed
      if(currentSalesOrder.TECH_BodyshopCountryCode__c == 'IT' && currentSalesOrder.Assessment__c != null && currentSalesOrder.Assessment__r.ParentAssessment__c == null)
      {
        Assessment__c currentAssessment = [  SELECT   Id
                          FROM  Assessment__c
                          WHERE  Id =: currentSalesOrder.Assessment__c
                          FOR VIEW];
      }
      
    }
    catch (Exception e)
    {
      //VSU 30/03/18 C-002315 
      if(e.getMessage().contains('Invalid id') || e.getMessage().contains('BLOB is not a valid UTF-8 string')){
        hasErrors = true;
        isToastError = true;
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UnauthorizedID));
        system.debug('## Exception' + e.getMessage());
      }else{
        hasErrors = true;
        isToastError = false;
        redirectionInErrorModal = true;
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Invalid Request'));
        system.debug('## Exception' + e.getMessage());
      }     
    }

    backURL = back();
  }

  public String decryptBase64(String encryptedText)
    {
        Blob decryptedData      = EncodingUtil.base64Decode(encryptedText);
        String decryptedText    = decryptedData.toString();

        return decryptedText;
    }
  
  public String encryptBase64(String text)
    {
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }

  public PageReference redirectPage()
  {

      PageReference pageRef = Page.Search;
      pageRef.setRedirect(true);
      return pageRef;

      return null;
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

  public String back()
  {
    PageReference currentPageRef;
    
    if(currentSalesOrder != null && currentSalesOrder.Assessment__c != null && currentSalesOrder.Assessment__r.ParentAssessment__c != null)
    {
      currentPageRef = Page.OrderChooseAssessment;
      currentPageRef.getParameters().put('AssessmentId', encryptBase64(currentSalesOrder.Assessment__r.ParentAssessment__c));
    }
    else
    {
      currentPageRef = Page.Search;
    }

    return currentPageRef.getUrl();
  }

  //AMI 23/11/18  C-002781 : Migrate Spain to R4
  //                       : Display Cases In Related List
  //                       : wrapper containing case to display
  public class CaseWrapper{
    public Case__c cse {get;set;}
    public String cseEncodedId {get;set;}

    public CaseWrapper(){
      cse = new Case__c();
      cseEncodedId = '';
    } 
  }
  //WCH 09/08/19  C-003318 : Add "Download Delivery Note" button to R4
  public PageReference downloadPDFSO()
    {
        PageReference downloadPage  = Page.VFP14_PrintPartListForBodyshop;

        downloadPage.getParameters().put('force_download', 'true');
        //KPA 10/11/2020  C-004026 
        String SOId = EncodingUtil.base64Encode(Blob.valueof(currentSalesOrder.Id));
        
        downloadPage.getParameters().put('Id',SOId);
        
        //downloadPage.getParameters().put('Id', currentSalesOrder.Id);
        downloadPage.getParameters().put('isDeliveryNote', 'false');//WCH 21/11/2019 C-003486 set isDeliveryNote=false. then pdf is really deliverynote
        //WCH 06/01/2019 C-003531
        if(currentSalesOrder.TECH_BodyshopCountryCode__c.equals('FR')){
            downloadPage.getParameters().put('isBDL_FR', 'true');
        }
        downloadPage.getParameters().put('printDeliveryNote', 'true');
        downloadPage.setRedirect(false);

        return downloadPage;
    }
    //WCH 21/01/21  C-004148
    public PageReference cancelCurrentSO(){
        String SOId = EncodingUtil.base64Encode(Blob.valueof(currentSalesOrder.Id));
        PageReference redirectToAfterCancelSO = new PageReference('/apex/ASPISSalesOrder?Id=' + SOId);
        if(currentSalesOrder!=null && currentSalesOrder.cancelationReason__c != '' && currentSalesOrder.cancelationReason__c != null){
            currentSalesOrder.Comment__c = currentSalesOrder.cancelationReason__c;
            currentSalesOrder.Status__c = 'CANCELED';
        }else{ 
            hasErrors = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, system.label.CancellationReasonIsRequired));
            return null;
        }
        try{
            update currentSalesOrder;  
            showBSCancelSOButton=false;
            //return redirectToAfterCancelSO;
        }catch (Exception e){
            hasErrors = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,  e.getMessage() + ' : ' + e.getStackTraceString()));
        }
        return null;
    }
}