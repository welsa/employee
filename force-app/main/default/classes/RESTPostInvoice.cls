/*
----------------------------------------------------------------------
-- - Name          : RESTPostInvoice
-- - Author        : VSU
-- - Description   : Class used to get identifier for invoice
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 22-AUG-2017  VSU     1.0         Initial version
-- 24-APR-2018  VSU     1.1         Added log 
-- 24-MAY-2018  RLA     1.2         C-002561 : Log Api Call to build with Cegedim
-- 15-JUN-2018  VSU     1.2         C-002578 use another method from Cegedim that will send back only 1 Iddoc
-- 07-DEC-2018  WCH     1.3         C-002924 : Download Pdf Invoice in ASPIS for France, Belgium, Germany
-- 13-NOV-2019  WCH     1.4         C-003271 : Review the Cegedim API Call Implemented to be able to download archived invoices
-- 20-Aug-2020  KPA     1.5         C-003899 : RESTPostInvoice.sendRequestForPdf error not stored
-- 14-Nov-2022  RRJ     1.6         C-004611 : Permettre un téléchargement en masse des factures sur une période
----------------------------------------------------------------------
**********************************************************************
*/
//WCH 07/12/2018, C-002924 declare class as global, so that it can be accessed in detail page button
global without sharing class RESTPostInvoice{

  private static String objReference = '';
  //RRJ C-004611
  public static Boolean isFromBatch = false;

  public RESTPostInvoice(CustomControllerBase controller){

    }
  //WCH 13/11/2019 C-003271
  @RemoteAction
    WebService static String sendRequestForPdf(String invNumber,String invId, String invoiceTechNo,String invCountryCode){
    return sendRequestForPdf(invNumber,invId,invoiceTechNo,invCountryCode,false);
  }
  //WCH 13/11/2019 C-003271
    //WCH 07/12/2018, C-002924 declare method as WebService, so that it can be accessed in detail page button
    public static String sendRequestForPdf(String invNumber,String invId, String invoiceTechNo,String invCountryCode,Boolean isBulk){
      system.debug('## invoiceTechNo '+invoiceTechNo);
      system.debug('## invNumber '+invNumber);
      system.debug('## countryCode '+invCountryCode);

      Boolean isSuccessful = true;
    String pdfid;
    String statusCode = '';
    String errorMessage = '';     
    String encodedpdf;
    Id invoiceId;

    String countryCode =  CountryCodeInformationsMapping__c.getInstance(invCountryCode).pdfCode__c;

    // C-002561 : Log Api Call to build with Cegedim 24/05/2018
    if (String.isNotBlank(invId)){
      Invoice__c inv = [Select TECH_Number__c from Invoice__c where Id =: invId];
      if (inv != null){
        invoiceTechNo = inv.TECH_Number__c; 
      }
    }

    //system.debug('##custom setting '+CountryCodeInformationsMapping__c.getInstance(invCountryCode));
    if(invoiceTechNo != '' && invoiceTechNo != null){
      pdfid = invoiceTechNo;
      encodedpdf = retrievePdfBody(pdfid,invId);
      system.debug('##1RESTInvoice'+pdfid);
    }else{
        
      HttpResponse response = new HttpResponse();
            Http h = new http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:PDFIDENTIFIER_CEGEDIM');
            req.setMethod('POST');

            string username = '{!$Credential.UserName}';
            string password = '{!$Credential.Password}';

            //VSU C-002578 Change callout to cegedim comment previous xml
            //String strReq='<?xml version="1.0" encoding="UTF-8"?><GETLSTDF><ENTETE><LOGIN>'+username+'</LOGIN><PASSWORD>'+password+'</PASSWORD></ENTETE><CRITERIA><IDDOCEM><IDCTRCPT>'+countryCode+'</IDCTRCPT></IDDOCEM><IDMSG>'+invNumber+'</IDMSG></CRITERIA><NBVO>15</NBVO><PAGE><ID>1</ID></PAGE></GETLSTDF>';
      //VSU C-002578 Change callout to cegedim 
      String strReq=
      '<?xml version="1.0" encoding="UTF-8"?><GETLSTLR><ENTETE><LOGIN>'+username+'</LOGIN><PASSWORD>'+password+'</PASSWORD></ENTETE><CRITERIA><SENS>EM</SENS><CURDATORI_INF>2016-01-01</CURDATORI_INF><NUMFAC>'+invNumber+'</NUMFAC><ESPARCHI><IDCTRCPT>'+countryCode+'</IDCTRCPT></ESPARCHI></CRITERIA></GETLSTLR>';
      system.debug('##strReq '+strReq);
            req.setbody(strReq);
            req.setHeader('Accept','application/xml');
            req.setHeader('Content-Type', 'application/xml');
      response = h.send(req);
      system.debug('## response.getBody() ' + response.getBody());
      system.debug('## response.getStatus() ' + response.getStatus());
      system.debug('## response.getBodyDocument() ' + response.getBodyDocument());

      Dom.Document doc = response.getBodyDocument();
          
      Dom.XmlNode getlstdf = doc.getRootElement();
      for (Dom.XmlNode node : getlstdf.getChildElements()) {        
        system.debug('##node.getName() '+node.getName());

        if(node.getName()== 'VO'){
          pdfid = node.getChildElement('IDDOC', null).getText();
          //break;
        }

        if(node.getName() == 'CODRET'){
          statusCode = node.getText();
          break;
        }
      }
      system.debug('##pdfid1'+pdfid);
      
      if(pdfid != null && !isBulk){//WCH 13/11/2019 C-003271
        encodedpdf = retrievePdfBody(pdfid,invId);
        Invoice__c invToUpdate = new Invoice__c(id=invId, TECH_Number__c=pdfid);
        if(invToUpdate != null){
          update invToUpdate;
        }
      }else{
        encodedpdf = '';
      }
      system.debug('##pdfid'+pdfid);
      system.debug('##statusCode '+statusCode);
      

      isSuccessful = statusCode != '200' ? false: true;

      errorMessage = statusCode == '190502'? 'Aucune facture ne correspond aux critères de recherche':('StatusCode: '+response.getStatuscode()+' Status: '+response.getStatus()); //KPA 20/08/2020  C-003899

      invoiceId = invId;

      if(!isBulk)//WCH 13/11/2019 C-003271
        createLog(strReq , response.getBody(), isSuccessful,'Cegedim', 'RESTPostInvoice.sendRequestForPdf', 'Invoice__c', errorMessage ,invoiceId, pdfid);    
    }
    
    system.debug('##encodedpdf '+encodedpdf);
    return (isBulk ? pdfid : encodedpdf);//WCH 13/11/2019 C-003271
  }

  public static String retrievePdfBody(String invIdentifier, Id invId){
        
      String errorMessage = '';
      String statusCode = '';
      Id invoiceId;
      Boolean isSuccessful = true;

      HttpResponse responsePDF = new HttpResponse();
            Http h = new http();
            HttpRequest req = new HttpRequest();
            String responsePDFStr = '';
            req.setEndpoint('callout:PDF_CEGEDIM');
            req.setMethod('POST');

      string username = '{!$Credential.UserName}';
          string password = '{!$Credential.Password}';
      String strReq=
      '<?xml version="1.0" encoding="UTF-8"?><GETORI><ENTETE><LOGIN>'+username+'</LOGIN><PASSWORD>'+password+'</PASSWORD></ENTETE><CRITERIA><IDDOC>'+invIdentifier+'</IDDOC><SENS>EM</SENS><POSITION>1</POSITION><DECODE>0</DECODE></CRITERIA></GETORI>';
      system.debug('##strReq '+strReq);
            req.setbody(strReq);
            req.setHeader('Accept','application/xml');
            req.setHeader('Content-Type', 'application/xml');

            try{
        responsePDF = h.send(req);

        statusCode = responsePDF.getStatusCode() != null ? String.valueOf(responsePDF.getStatusCode()) : '' ;

        //responseBlobBody = responsePDF.getBodyAsBlob();

        //system.debug('## response.getBody() ' + responsePDF.getBody());
        system.debug('## response.getStatus() ' + responsePDF.getStatus());
        system.debug('## response.StatusCode() ' + responsePDF.getStatusCode());
        system.debug('## response.getHeader() ' + responsePDF.getHeader('Content-Type'));
        system.debug('## response.getHeader filename() ' + responsePDF.getHeader('Content-Disposition')); 
        if(responsePDF.getHeader('Content-Type') == 'application/xml'){
          responsePDFStr = 'Error';
          Dom.Document doc = responsePDF.getBodyDocument();
            
          Dom.XmlNode getlstdf = doc.getRootElement();
          for (Dom.XmlNode node : getlstdf.getChildElements()) {        
            system.debug('##node.getName() '+node.getName());

            if(node.getName() == 'CODRET'){
              statusCode = node.getText();
              system.debug('@@ statusCode1:'+statusCode);
              break;
            }
          }

          
        }
        else{
          responsePDFStr = responsePDF.getBody();
        } 
      }
      catch(exception e){
        errorMessage = 'Error: ' + e.getMessage();
        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'bla bla bla time out'));
        responsePDFStr = errorMessage;
      }

      system.debug('##statusCode '+statusCode);
      isSuccessful = statusCode != '200' ? false: true;
      system.debug('@@ isSuccessful:'+isSuccessful);


      if(statusCode ==  '180802'){
        errorMessage =  'document inexistant';
      }else if(statusCode ==  '18080032'){
        errorMessage =  'document hors périmètre utilisateur';
      }

      //system.debug('##responsePDFStr '+responsePDFStr);

      invoiceId = invId;
      //RRJ C-004611
      if(!isFromBatch){
        createLog(strReq , responsePDF.getBody(), isSuccessful,'Cegedim', 'RESTPostInvoice.retrievePdfBody', 'Invoice__c', errorMessage, InvoiceId, invIdentifier);
      }

      return responsePDFStr;
    }

  public static void createLog(String request, String response, Boolean isSuccessful, String systemCalling, String classUsed, 
    String obj , String errorMessage, Id InvoiceId, String pdfId){

    //RLA 26/03/18 Case-2177: Corrections/evolutions sur les logs
        APManageLogs.LogsWrapper wrapperLog = new APManageLogs.LogsWrapper();
        wrapperLog.className = classUsed;
        wrapperLog.sobjectName = obj;            
        wrapperLog.inout = 'Outbound';
        wrapperLog.status = (isSuccessful) ? 'Passed' : 'Failed';
        wrapperLog.systemCalling = systemCalling; 
    wrapperLog.errorDescription =  errorMessage;
    wrapperLog.sObjectId =  invoiceId;
    wrapperLog.wSResponse = pdfId;

    // Check if the length of the request is less or equal to 32768 -> add request in JSONMessage__c
    if(request.length() <= 32768)
    {
       wrapperLog.jsonmessage = request;
    }

    // Check if the length of the response is less or equal to 32768 -> add request in JSONResponse__c
    if(response.length() <= 32768)
    {
      wrapperLog.jsonResponse = response;
    }

    // In case the request was too big create an attachment for it
    if(request.length() > 32768)
    {
      wrapperLog.attachmentRequestbody = request;
    }

    // In case the response was too big create an attachment for it
    if(response.length() > 32768)
    {
      wrapperLog.attachmentResponsebody = response;
    }

        wrapperLog.objectreference = objReference;

    APManageLogs.createWsLog(wrapperLog, 'insert');
  }
}