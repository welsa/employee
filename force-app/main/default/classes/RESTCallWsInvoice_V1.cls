/*************************************************************************************
Class Name - RESTCallWsInvoice_V1
Version - 1.0
Created Date - unknown
Function - RESTCallWsInvoice_V1

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Shamina M     17/02/2016  C-001518: Removed unnecessary debug logs
* Ashwina S     14/03/2016  C-001559: Transmission des éléments de facturation à Cegedim   
                            ds le cadre de leur lot 3
* Dourga U      25/05/2016  Case 1644: Batch to send the invoices to Accounting
*                           (Added method makeCallWsInvoice_V2 to return response)
* Dourga U      27/05/2016  Call from class ASPISBatchSendInvoice
* Dourga U      07/07/2016  C-001663: CdC Remise additionnelle
* Ashutosh B    22/09/2016  C-001728: Added the new function of create attachment
* Welsa C       09/10/2018  C-002567 - Add BodyshopOrderReferences
* Welsa C       23/11/2018  C-002531 - Limiter l'envoi du champ à 35 caractères à Cegedim
* Welsa C       14/02/2019  C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
* Welsa C       29/03/2019  C-002981 - Mettre la référence client dans les 3 documents pdf
* Welsa C       02/05/2019  C-003215 - Invoices not sent to Cegedim
* Welsa C       24/08/2020  C-003838 - Nob - Migrate Billing information to new fields
* Ruksaar L     24/04/2021  C-004326: Items are invoiced 3 times if SAS sends spare parts as a bundle
*************************************************************************************/
public with sharing class RESTCallWsInvoice_V1 {
   
    public static String JsonResp;
    public static void createLog(String results){
        Log__c log = new Log__c();
        log.DateLog__c = system.now();
        log.Class__c = 'RESTCallWsInvoice_V1';  
   

        if (JsonResp.length() <= 30000){
            log.JSONMessage__c = JsonResp;
        }

        if (results.length() <= 30000)
        {
            log.JSONResponse__c = results;
        }
        insert log;

        if (JsonResp.length() > 30000)
        {
            // ABT - C-001728 - 22-SEP-2016
            //APCreateAttachments.createAttachment(JsonResp,log);
            APCreateAttachments.createAttachment('Request', JsonResp, log);
        }

        if (results.length() > 30000)
        {
            // ABT - C-001728 - 22-SEP-2016
            //APCreateAttachments.createAttachment(results,log);
            APCreateAttachments.createAttachment('Response', results, log);
        }
        
    }
  @future(callout=true)
  public static void callWsInvoice_V1(Set<Id> invoices){
    
    //HttpRequest req = buildWebServiceRequest(invoices);
    
    //HttpResponse res = invokeWebService(req);
     makeCallWsInvoice_V1(invoices);
  }
  
  public static void makeCallWsInvoice_V1(Set<Id> invoices){
    system.debug('####### makeCallWsInvoice_V1 Start');
    list<Invoice__c> listInvoices = new list <Invoice__c>();
    HttpRequest req = buildWebServiceRequest(invoices,listInvoices);
    
    
    //Shamina M: 20160119 - removed condition !Test.isRunningTest() since callout coverage is allowed now
    if (req != null)
    {
        HttpResponse res = invokeWebService(req);
    }
    system.debug('####### makeCallWsInvoice_V1 End');
    
  }

  //DUN 25/05/2016 Case 1644
  public static String makeCallWsInvoice_V2(list<Invoice__c> listInvoices){
    system.debug('####### makeCallWsInvoice_V2 Start');
    set<Id> setInvoicesId = new set<Id>();
    HttpRequest req = buildWebServiceRequest(setInvoicesId,listInvoices);
    HttpResponse res;
    String reponse = '';
    
    
    //Shamina M: 20160119 - removed condition !Test.isRunningTest() since callout coverage is allowed now
    if (req != null)
    {
        res = invokeWebService(req);
    }

    if(res != null){
        reponse = res.getStatus();
    }
    system.debug('####### makeCallWsInvoice_V2 End' + reponse);
    return reponse;
    
  }
  //26.05.2016 Case 1644 Added list of invoices as parameter to avoid requery of invoice(already done in batch)
  public static HttpRequest buildWebServiceRequest(set<Id> invoicesToSend, list<Invoice__c> listInvoices){
    system.debug('############### START buildWebServiceRequest');
    String endPointCegedim = null;
    /*String passCegedim = null;
    String userCegedim = null;
    CountryCodeInformationsMapping__c cs = new CountryCodeInformationsMapping__c();
    Map<String, CountryCodeInformationsMapping__c> mcs = CountryCodeInformationsMapping__c.getAll();

    if (mcs.containsKey('FR'))
    {
        cs = mcs.get('FR');

        if (cs.URLInvoiceBodyShop__c != null)
        {
            endPointCegedim = cs.URLInvoiceBodyShop__c;
        }

        if (cs.LoginInvoiceBodyShop__c != null)
        {
            userCegedim = cs.LoginInvoiceBodyShop__c;
        }

        if (cs.PasswordInvoiceBodyShop__c != null)
        {
            passCegedim = cs.PasswordInvoiceBodyShop__c;
        }
    } */
    endPointCegedim = 'callout:FR_CEGEDIM';
    
    if (endPointCegedim != null /*&& userCegedim != null && passCegedim != null*/){
        List<Invoice__c> invList = new list<Invoice__c>();
        //26.05.2016 DUN case 1644 added condition to check if list has values or not to avoid requering invoices
        if(listInvoices.isEmpty()){
            // ASE: 14/03/2016  C-001559: add ReferenceNumber__c (BodyShop__r.ReferenceNumber__c) to be mapped in JSON , WCH 24/08/2020 C-003838
            for(Invoice__c inv : [Select Id,Name,Date__c,Type__c,Number__c,InvoicePaidDate__c,VAT__c,
                        DueDate__c,PrerequisiteOrder__r.Name,PrerequisiteOrder__r.BodyshopOrderNumber__c,Assessment__r.Id, ICEINVTransmit__c,
                                        Assessment__r.AssessmentNumber__c,Assessment__r.ASReference__c, Assessment__r.ClaimReference__c,
                                        Assessment__r.ModelV2__c , Assessment__r.Manufacturer__c,
                                        Assessment__r.AssessmentId__c, BodyShop__r.ReferenceNumber__c, 
                                        BodyShop__r.BillingStreet__c,BodyShop__r.BillingPostalCode__c, BodyShop__r.BillingCountryCode__c,
                                        BodyShop__r.ASEntity__c,
                                        BodyShop__r.BillingCity__c,BodyShop__r.VATNumber__c,BodyShop__r.Name,TotalVAT__c,
                                        BodyShop__r.ContactUser__r.Email, BodyShop__r.ContactEmail__c, BodyShop__r.ContactUser__r.LanguageLocaleKey,
                                        PaymentType__c, EntityCode__c,
                                        Total__c, TotalNet__c,PlateNumber__c,RecordTypeID,CreatedDate,TechAssessmentCountryCode__c,//RLA Added for C-002567 01/11/2018
                                        TechOfferIds__c,//WCH 14/02/2019 C-002910 - Order Lines/Offers are not associated to Invoice/Credit Note
                                        (Select Id,Name,CataloguePrice__c,BSTotalPrice__c,ParentOffer__c,
                                        VAT__c,PartNUmber__c,Description__c,Price__c,Quantity__c,
                                        AdditionnalDiscount__c,Discount__c,RealDeliveryDate__c,PriceWithoutAddDiscount__c
                                        from Offers__r),
                                        (Select Id,Name,CataloguePrice__c,BSTotalPrice__c,
                                        VAT__c,PartNUmber__c,Description__c,Price__c,Quantity__c,
                                        AdditionnalDiscount__c,Discount__c,RealDeliveryDate__c,PriceWithoutAddDiscount__c
                                        from CreditNoteOffers__r) 
                        from Invoice__c where Id in:invoicesToSend AND BodyShop__r.Type != 'Expert']){
              invList.add(inv); 
            }
        }
        else{
            invList = listInvoices;
        }
        if(invList.size() > 0){
            //Calculate max real delivery date
            Map<Id,Date> mapInvoiceMaxDDate = new Map<Id,Date>();

            //WCH 14/02/2019 C-002910 Order Lines/Offers are not associated to Invoice/Credit Note
            Set<String> offerIds = new Set<String>();

            //RLA 28/04/2021 C-004326: Items are invoiced 3 times if SAS sends spare parts as a bundle
            Set<String> parentBundlesOffer = new Set<String>();

            for (Invoice__c inv : invList)
            { 
                if (inv.Offers__r.size() > 0)
                {
                    Date maxDeliveryDate = inv.Offers__r[0].RealDeliveryDate__c;

                    for (Offer__c off : inv.Offers__r)
                    {
                        if (off.RealDeliveryDate__c > maxDeliveryDate)
                        {
                            maxDeliveryDate = off.RealDeliveryDate__c;
                        }

                        //RLA 28/04/2021 C-004326: Items are invoiced 3 times if SAS sends spare parts as a bundle
                        if (String.isBlank(off.ParentOffer__c) ){
                            parentBundlesOffer.add(off.Id);
                    }
                    }

                    mapInvoiceMaxDDate.put(inv.Id,maxDeliveryDate);
                } else { if (inv.CreditNoteOffers__r.size() > 0) {
                    
                        Date maxDeliveryDate = inv.CreditNoteOffers__r[0].RealDeliveryDate__c;
                    
                        for (Offer__c off : inv.CreditNoteOffers__r)
                        {
                            if (off.RealDeliveryDate__c > maxDeliveryDate)
                            {
                                maxDeliveryDate = off.RealDeliveryDate__c;
                            }
                        }
                        mapInvoiceMaxDDate.put(inv.Id,maxDeliveryDate);
                    }
                } 
                //WCH 14/02/2019 C-002910 Order Lines/Offers are not associated to Invoice/Credit Note
                if(!String.isBlank(inv.TechOfferIds__c))
                    offerIds.addAll(inv.TechOfferIds__c.split('-'));
            }

            //WCH 14/02/2019 C-002910 Order Lines/Offers are not associated to Invoice/Credit Note
            // Map<Id,Offer__c> offerIdMapOffer = new Map<ID, Offer__c>([SELECT Id,Name,CataloguePrice__c,BSTotalPrice__c,VAT__c,PartNUmber__c,Description__c,Price__c,Quantity__c,AdditionnalDiscount__c,Discount__c,RealDeliveryDate__c,PriceWithoutAddDiscount__c  FROM Offer__c where Id in: offerIds]);
            Map<Id,Offer__c> offerIdMapOffer = new Map<ID, Offer__c>();
            Set<Id> setBundlesParentOffers = new set<Id>();


            for (Offer__c off: [SELECT Id,Name,CataloguePrice__c,BSTotalPrice__c,VAT__c,PartNUmber__c,Description__c,Price__c,Quantity__c,AdditionnalDiscount__c,Discount__c,RealDeliveryDate__c,PriceWithoutAddDiscount__c, (select id from Offers__r)  FROM Offer__c where Id in: offerIds or Id in: parentBundlesOffer]){

                if (offerIds.contains(off.Id)){
                    offerIdMapOffer.put(off.Id, off);
                }
                //system.debug('@@@ off.Offers__r.size(): '+off.Offers__r.size());
                //system.debug('@@@ off.Quantity__c: '+off.Quantity__c);
                //RLA 28/04/2021 C-004326: Items are invoiced 3 times if SAS sends spare parts as a bundle
                if (parentBundlesOffer.contains(off.Id) && off.Offers__r != null && off.Offers__r.size() == off.Quantity__c  ){
                    setBundlesParentOffers.add(off.Id);
                }

            }
            system.debug('@@@ setBundlesParentOffers: '+setBundlesParentOffers);



          JSONGenerator genResults = JSON.createGenerator(false);
          genResults.writeStartObject();
          genResults.writeFieldName('Document');
                genResults.writeStartArray();
          for(Invoice__c inv : invList){
            // ase: 2016/01/25 : case C-001500
            String invoiceDate;
            genResults.writeStartObject();
              if(inv.Date__c != null){
                String dayStr = String.valueOf(inv.Date__c.day()).leftPad(2).replace(' ', '0');
                String monthStr = String.valueOf(inv.Date__c.Month()).leftPad(2).replace(' ', '0');
                            invoiceDate = dayStr+'/'+monthStr+'/'+inv.Date__c.Year();
                            genResults.writeStringField('-DocumentDate', invoiceDate);
                        }


                        genResults.writeFieldName('Header');
                        //start Header
                        genResults.writeStartObject();
                          if(inv.Type__c == 'INVOICE'){
                            genResults.writeStringField('-DocTypCod', '380');
                          }else if(inv.Type__c == 'CREDITNOTE'){
                            genResults.writeStringField('-DocTypCod', '381');
                        }

                        
                            if(inv.RecordTypeID == Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(ASPISConstants.INVOICE_RT_LABEL_CreditNote).getRecordTypeId()){
                               if(inv.Number__c != null)
                                genResults.writeStringField('-AssociatedInvoiceNum', inv.Number__c);
                            }


                        genResults.writeFieldName('BenefitDate');
                        //start BenefitDate
                        genResults.writeStartObject();
                          genResults.writeFieldName('SimpleDate');
                          //start SimpleDate
                          genResults.writeStartObject();
                            if(mapInvoiceMaxDDate.containsKey(inv.Id)){
                                Date realdeliveryDate = mapInvoiceMaxDDate.get(inv.Id);
                                if (realdeliveryDate != null){
                                    String dayStr = String.valueOf(realdeliveryDate.day()).leftPad(2).replace(' ', '0');
                                    String monthStr = String.valueOf(realdeliveryDate.Month()).leftPad(2).replace(' ', '0');
                                    String cDate = dayStr+'/'+monthStr+'/'+realdeliveryDate.Year();
                                    genResults.writeStringField('-SimpleDateVal',cDate);
                                }
                                // ase: 2016/01/25 : case C-001500
                                else{
                                    genResults.writeStringField('-SimpleDateVal',invoiceDate);
                                }
                            }
                          genResults.writeEndObject();
                          //end SimpleDate
                        genResults.writeEndObject();
                        //end BenefitDate
                        
                        genResults.writeFieldName('MaturityDate');
                        //start MaturityDate
                        genResults.writeStartObject();
                          genResults.writeFieldName('SimpleDate');
                          //start SimpleDate
                          genResults.writeStartObject();
                            if(inv.DueDate__c != null){
                      String dayStr = String.valueOf(inv.DueDate__c.day()).leftPad(2).replace(' ', '0');
                      String monthStr = String.valueOf(inv.DueDate__c.Month()).leftPad(2).replace(' ', '0');
                                        String dueDate = dayStr+'/'+monthStr+'/'+inv.DueDate__c.Year();
                                        genResults.writeStringField('-SimpleDateVal',dueDate);
                                    }
                        
                          genResults.writeEndObject();
                          //end SimpleDate
                        genResults.writeEndObject();
                        //end MaturityDate

                        genResults.writeFieldName('Currency');
                        //start Currency
                        genResults.writeStartObject();
                          genResults.writeStringField('-CurrencyCod','EUR');
                        genResults.writeEndObject();
                        //end Currency

                        genResults.writeFieldName('SettlementTerms');
                        //start SettlementTerms
                        genResults.writeStartArray();
                          genResults.writeStartObject();
                            genResults.writeStringField('-TermsTypQlfCod','1');

                            String paymentType = (String.isNotBlank(inv.PaymentType__c) ? inv.PaymentType__c : '');
                            genResults.writeStringField('-SettlementMethodCod', paymentType);
                            genResults.writeStringField('-TermsTypQlfTxt','Payment method');
                          genResults.writeEndObject();
                        genResults.writeEndArray();
                        //end SettlementTerms

                        genResults.writeFieldName('Reference');
                        //start Reference
                        genResults.writeStartArray();
                          genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Order');

                            if(inv.PrerequisiteOrder__r.Name != null){
                                genResults.writeStringField('-ReferenceCod',inv.PrerequisiteOrder__r.Name);
                            }

                          genResults.writeEndObject();

                          genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Other');
                            genResults.writeStringField('-OtherReferenceQlfTxt','Identifiant technique de la facture');
                            genResults.writeStringField('-ReferenceCod',inv.Id);
                          genResults.writeEndObject();

                          genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Other');
                            genResults.writeStringField('-OtherReferenceQlfTxt','Numéro de chiffrage');

                            if(inv.Assessment__r.AssessmentNumber__c != null){
                               // genResults.writeStringField('-ReferenceCod',inv.Assessment__r.AssessmentNumber__c);
                               genResults.writeStringField('-ReferenceCod',inv.Assessment__r.ASReference__c); 
                            }
 
                          genResults.writeEndObject();
 
                          genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Other');
                            genResults.writeStringField('-OtherReferenceQlfTxt','Numéro de l’événement');

                            if(inv.Assessment__r.ClaimReference__c != null){
                                genResults.writeStringField('-ReferenceCod',inv.Assessment__r.ClaimReference__c);
                            }

                          genResults.writeEndObject();
                          
                           genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Other');
                            genResults.writeStringField('-OtherReferenceQlfTxt','Marque');

                            if(inv.Assessment__r.Manufacturer__c != null){
                                genResults.writeStringField('-ReferenceCod',inv.Assessment__r.Manufacturer__c);
                            }
                            genResults.writeEndObject();
                            
                             genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Other');
                            genResults.writeStringField('-OtherReferenceQlfTxt','Model');

                            if(inv.Assessment__r.ModelV2__c != null){
                                genResults.writeStringField('-ReferenceCod',inv.Assessment__r.ModelV2__c.left(35));
                            }
                            
                            genResults.writeEndObject();
                            
                            genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Other');
                            genResults.writeStringField('-OtherReferenceQlfTxt','Code langue');

                            if(inv.BodyShop__r.ContactUser__r.LanguageLocaleKey != null){
                                genResults.writeStringField('-ReferenceCod',inv.BodyShop__r.ContactUser__r.LanguageLocaleKey.left(2));
                            }
                            
                            genResults.writeEndObject();
                            
                            genResults.writeStartObject();
                            genResults.writeStringField('-ReferenceQlf','Other');
                            genResults.writeStringField('-OtherReferenceQlfTxt','Fichier ICE');
                            genResults.writeStringField('-ReferenceCod', inv.ICEINVTransmit__c == true ? '1' : '0');                            
                            genResults.writeEndObject();

                            genResults.writeStartObject();
                                genResults.writeStringField('-ReferenceQlf','Other');
                                genResults.writeStringField('-OtherReferenceQlfTxt','Id Alpha Scale company');
                                if (inv.BodyShop__r.ASEntity__c != null) {
                                    genResults.writeStringField('-ReferenceCod', inv.BodyShop__r.ASEntity__c);
                                }
                            genResults.writeEndObject();

                            genResults.writeStartObject();
                                genResults.writeStringField('-ReferenceQlf','Other');
                                genResults.writeStringField('-OtherReferenceQlfTxt','Analytic code');
                                if (inv.EntityCode__c != null) {
                                    genResults.writeStringField('-ReferenceCod', inv.EntityCode__c);
                                }
                            genResults.writeEndObject();


                                genResults.writeStartObject();
                                    genResults.writeStringField('-ReferenceQlf','Other');
                                    genResults.writeStringField('-OtherReferenceQlfTxt','N° Immatriculation');

                                    if(inv.PlateNumber__c != null){
                                        genResults.writeStringField('-ReferenceCod',inv.PlateNumber__c);
                                    }

                                genResults.writeEndObject();
                        genResults.writeEndArray();
                        //end Reference


                            genResults.writeFieldName('BuyerData');
                            //start BuyerData
                            genResults.writeStartObject();

                                genResults.writeFieldName('InvoicingData');
                                //start InvoicingData
                                genResults.writeStartObject();

                                    genResults.writeFieldName('CompanyData');
                                    //start CompanyData
                                    genResults.writeStartObject();

                                        genResults.writeFieldName('IdNumber');
                                        //start IdNumber
                                        genResults.writeStartObject();
                                            genResults.writeStringField('-IdTypCod','167');

                                            if(inv.BodyShop__r.VATNumber__c != null){
                                                //WCH 24/08/2020 C-003838
                                                genResults.writeStringField('-IdCod',inv.BodyShop__r.BillingCountryCode__c + inv.BodyShop__r.VATNumber__c);
                                            }

                                        genResults.writeEndObject();
                                        //end IdNumber

                                        genResults.writeFieldName('CorporateName');
                                        //start CorporateName
                                        genResults.writeStartObject();

                                            if(inv.BodyShop__r.Name != null){
                                                genResults.writeStringField('-CorporateNameTxt',inv.BodyShop__r.Name);
                                            }

                                        genResults.writeEndObject();
                                        //end CorporateName

                                        genResults.writeFieldName('Address');
                                        //start Address
                                        genResults.writeStartObject();
                                            
                                            //quickfix C-001482, WCH 24/08/2020 C-003838
                                            if(inv.BodyShop__r.BillingStreet__c != null){
                                                if (inv.BodyShop__r.BillingStreet__c.contains(' - '))
                                                {
                                                    List<String> addresses = inv.BodyShop__r.BillingStreet__c.split(' - ');

                                                    if (addresses.size() > 1)
                                                    {
                                                        genResults.writeStringField('-Address1',addresses[0]);
                                                        genResults.writeStringField('-Address2',addresses[1]);
                                                    }
                                                }else{
                                                    genResults.writeStringField('-Address1',inv.BodyShop__r.BillingStreet__c);
                                                }
                                            }
                                            //genResults.writeNullField('-Address2');
                                            //genResults.writeNullField('-Address3');

                                            //WCH 24/08/2020 C-003838
                                            if(inv.BodyShop__r.BillingPostalCode__c != null){
                                                genResults.writeStringField('-PostCode',inv.BodyShop__r.BillingPostalCode__c);
                                            }

                                            if(inv.BodyShop__r.BillingCity__c != null){
                                                genResults.writeStringField('-City',inv.BodyShop__r.BillingCity__c);
                                            }

                                            if(inv.BodyShop__r.BillingCountryCode__c != null){
                                                genResults.writeStringField('-StateCode', inv.BodyShop__r.BillingCountryCode__c);
                                            }
                                        genResults.writeEndObject();
                                        //end Address

                                        genResults.writeFieldName('OtherId');
                                        //start OtherId
                                        genResults.writeStartObject();
                                       
                                            genResults.writeStringField('-OtherIdTypTxt','Code FCE');

                                            //ASE: 14/03/2016: C-001559
                                            //genResults.writeNullField('-OtherIdCod');
                                            if(inv.BodyShop__r.ReferenceNumber__c != null){
                                                genResults.writeStringField('-OtherIdCod',inv.BodyShop__r.ReferenceNumber__c.substring(2));
                                            }

                                        genResults.writeEndObject();
                                        //end OtherId
                                        
                                        //JSA: 19/09/2016: C-001650
                                        //start CorrespondentData
                                        //DUN 27/09/2016 
                                        String emailAdd;

                                        if(inv.BodyShop__r.ContactUser__c != null){
                                            emailAdd = inv.BodyShop__r.ContactUser__r.Email;
                                        } 
                                        else if(inv.BodyShop__r.ContactEmail__c != null){
                                            emailAdd = inv.BodyShop__r.ContactEmail__c;
                                        }
                                        if(emailAdd != null){
                                            genResults.writeFieldName('CorrespondentData');
                                            genResults.writeStartObject();
                                                
                                                genResults.writeStringField('-Email',emailAdd);

                                            genResults.writeEndObject();
                                        }
                                        //end OtherId

                                    genResults.writeEndObject();
                                    //end CompanyData

                                genResults.writeEndObject();
                                //end InvoicingData

                            genResults.writeEndObject();
                            //end BuyerData

                            //WCH 09/10/2018 - C-002567 - Add BodyshopOrderReferences
                            if(inv.Type__c == 'INVOICE' && inv.PrerequisiteOrder__c!=null && !String.isBlank(inv.PrerequisiteOrder__r.BodyshopOrderNumber__c)
                                && (inv.TechAssessmentCountryCode__c == 'BE' 
                                    ||inv.TechAssessmentCountryCode__c == 'FR'
                                    || inv.TechAssessmentCountryCode__c == 'DE')
                                //RLA Added 01/11/2018
                                ){
                                Set<String> BSOrderRefs = new Set<String>(inv.PrerequisiteOrder__r.BodyshopOrderNumber__c.split(';'));BSOrderRefs.remove('');
                                genResults.writeFieldName('BodyshopOrderReferences');
                                //start BodyshopOrderReferences
                                genResults.writeStartObject();
                                    //WCH 29/03/2019 :C-002981 - Mettre la référence client dans les 3 documents pdf
                                    //WCH 23/11/2018 :C-002531 limiter l'envoi du champ à 35 caractères à Cegedim
                                    genResults.writeStringField('-BodyshopOrderReferences',((String.isBlank((String.join((Iterable<String>)BSOrderRefs,'/')).left(35)) && inv.TechAssessmentCountryCode__c.equals('BE'))?inv.PrerequisiteOrder__r.Name:((String.join((Iterable<String>)BSOrderRefs,'/')).left(35))));
                                genResults.writeEndObject();
                                //end BodyshopOrderReferences
                            }
                        genResults.writeEndObject();
                        //end Header

                        genResults.writeFieldName('Line');
                        genResults.writeStartArray();
                        if(inv.Offers__r.size() > 0){
                            Integer count = 0;
                            for(Integer i = 0; i<inv.Offers__r.size();i++){
                                //RLA 28/04/2021 C-004326: Items are invoiced 3 times if SAS sends spare parts as a bundle
                                if (!setBundlesParentOffers.contains(inv.Offers__r[i].Id)){
                                //start Line
                                genResults.writeStartObject();
                                    count++;
                                    genResults.writeNumberField('-LineNumCod', count);

                                    genResults.writeFieldName('ProductReference');
                                    //start ProductReference
                                    genResults.writeStartObject();
                                        if(inv.Offers__r[i].PartNUmber__c != null){
                                            genResults.writeStringField('-ProductRefCod',inv.Offers__r[i].PartNUmber__c);
                                        }

                                        if(inv.Offers__r[i].Description__c != null){
                                            if(inv.Offers__r[i].Description__c.length() > 35){//vsu 11/05/18 C-002523 
                                              genResults.writeStringField('-ProductRefTxt',inv.Offers__r[i].Description__c.substring(0,35));
                                              system.debug('##Description i: '+inv.Offers__r[i].Description__c.substring(0,35));
                                            }else{
                                              genResults.writeStringField('-ProductRefTxt',inv.Offers__r[i].Description__c); 
                                              system.debug('##Description ii: '+inv.Offers__r[i].Description__c); 
                                            }                                            
                                        }
                                    genResults.writeEndObject();
                                    //end ProductReference

                                    genResults.writeFieldName('Reference');
                                    //start Reference
                                    genResults.writeStartObject();

                                        genResults.writeStringField('-ReferenceQlf','Other');
                                        genResults.writeStringField('-OtherReferenceQlfTxt','Référence fournisseur');
                                        genResults.writeStringField('-ReferenceCod',inv.Offers__r[i].Id);
                                    genResults.writeEndObject();
                                    //end Reference

                                    genResults.writeFieldName('LinePrice');
                                    /*Price__c,Quantity__c,
                                    AdditionnalDiscount__c,Discount__c*/
                                    //start LinePrice
                                    genResults.writeStartObject();
                                        if(inv.Offers__r[i].Quantity__c != null){
                                            genResults.writeNumberField('-LinePriceQte',inv.Offers__r[i].Quantity__c);
                                        }

                                        if(inv.Offers__r[i].PriceWithoutAddDiscount__c != null){
                                            genResults.writeNumberField('-LineDetailPrice',inv.Offers__r[i].PriceWithoutAddDiscount__c);
                                        }

                                        if(inv.Offers__r[i].CataloguePrice__c != null){
                                            genResults.writeNumberField('-LineGrossPrice',inv.Offers__r[i].CataloguePrice__c);
                                        }
                                    
                                    
                                        decimal price;
                                        decimal qty;
                                        //DUN 17/08/2016 ternary
                                        /*if(inv.Offers__r[i].Price__c == null){
                                            price = 0;
                                        }else{
                                            price = inv.Offers__r[i].Price__c;
                                        }*/
                                        price = inv.Offers__r[i].PriceWithoutAddDiscount__c != null ? inv.Offers__r[i].PriceWithoutAddDiscount__c : 0;

                                        //DUN 17/08/2016 ternary
                                        /*if(inv.Offers__r[i].Quantity__c == null){
                                            qty = 0;
                                        }else{
                                            qty = inv.Offers__r[i].Quantity__c;
                                        }*/
                                        qty = inv.Offers__r[i].Quantity__c != null ? inv.Offers__r[i].Quantity__c : 0;

                                        genResults.writeNumberField('-LineVATExclNetPrice', price*qty); 
                                    
                                    genResults.writeEndObject();
                                    //end LinePrice

                                    genResults.writeFieldName('Tax');
                                    //start Tax
                                    genResults.writeStartObject();

                                        if(inv.Offers__r[i].VAT__c != null){
                                            genResults.writeNumberField('-TaxRate',inv.Offers__r[i].VAT__c);
                                        }

                                    genResults.writeEndObject();
                                    //end Tax

                                    genResults.writeFieldName('OtherLine');
                                    //start OtherLine
                                    genResults.writeStartObject();
                                        if(inv.Offers__r[i].AdditionnalDiscount__c != null){
                                            genResults.writeStringField('-OtherLineQlf','Rebate');
                                        }

                                        if(inv.Offers__r[i].Discount__c != null){
                                            genResults.writeStringField('-OtherLineQlfTxt','Remise');
                                        }

                                        //genResults.writeFieldName('OtherLine');
                                        //start OtherLine
                                        //genResults.writeStartObject();

                                            genResults.writeFieldName('LinePrice');
                                            //start LinePrice
                                            genResults.writeStartObject();
                                                genResults.writeStringField('-LinePriceQte','100');

                                            
                                                Decimal addDis;
                                                Decimal dis;

                                                //DUN 07/07/2016 C-001663 Wrong calculation of discount
                                                /*if(inv.Offers__r[i].AdditionnalDiscount__c == null || inv.Offers__r[i].AdditionnalDiscount__c == 0){
                                                    addDis = 1;
                                                }else{
                                                    addDis = inv.Offers__r[i].AdditionnalDiscount__c;
                                                }

                                                if(inv.Offers__r[i].Discount__c == null || inv.Offers__r[i].Discount__c == 0){
                                                    dis = 1;
                                                }else{
                                                    dis = inv.Offers__r[i].Discount__c;
                                                }

                                                genResults.writeNumberField('-LineDetailPrice', addDis * dis);

                                                genResults.writeNumberField('-LineVATExclNetPrice', addDis * dis);*/

                                                //DUN 17/08/2016 ternary
                                                /*if(inv.Offers__r[i].AdditionnalDiscount__c == null){
                                                    addDis = 0;
                                                }else{
                                                    addDis = inv.Offers__r[i].AdditionnalDiscount__c;
                                                }*/
                                                addDis = inv.Offers__r[i].AdditionnalDiscount__c != null ? inv.Offers__r[i].AdditionnalDiscount__c : 0;

                                                //DUN 17/08/2016 ternary
                                                /*if(inv.Offers__r[i].Discount__c == null){
                                                    dis = 0;
                                                }else{
                                                    dis = inv.Offers__r[i].Discount__c;
                                                }*/
                                                dis = inv.Offers__r[i].Discount__c != null ? inv.Offers__r[i].Discount__c : 0;

                                                genResults.writeNumberField('-LineDetailPrice', addDis + dis);

                                                genResults.writeNumberField('-LineVATExclNetPrice', addDis + dis);
                                            
                                            genResults.writeEndObject();
                                            //end LinePrice

                                        //genResults.writeEndObject();
                                        //end OtherLine

                                    genResults.writeEndObject();
                                    //end OtherLine
                                genResults.writeEndObject();
                                //end Line
                                }
                                
                            }
                        }else if(inv.CreditNoteOffers__r.size() > 0){
                            for(Integer i = 0; i<inv.CreditNoteOffers__r.size();i++){
                                //start Line
                                genResults.writeStartObject();
                                    genResults.writeNumberField('-LineNumCod', i+1);

                                    genResults.writeFieldName('ProductReference');
                                    //start ProductReference
                                    genResults.writeStartObject();
                                        if(inv.CreditNoteOffers__r[i].PartNUmber__c != null){
                                            genResults.writeStringField('-ProductRefCod',inv.CreditNoteOffers__r[i].PartNUmber__c);
                                        }

                                        if(inv.CreditNoteOffers__r[i].Description__c != null){
                                            genResults.writeStringField('-ProductRefTxt',inv.CreditNoteOffers__r[i].Description__c);
                                        }
                                    genResults.writeEndObject();
                                    //end ProductReference

                                    genResults.writeFieldName('Reference');
                                    //start Reference
                                    genResults.writeStartObject();

                                        genResults.writeStringField('-ReferenceQlf','Other');
                                        genResults.writeStringField('-OtherReferenceQlfTxt','Référence fournisseur');
                                        genResults.writeStringField('-ReferenceCod',inv.CreditNoteOffers__r[i].Id);
                                    genResults.writeEndObject();
                                    //end Reference

                                    genResults.writeFieldName('LinePrice');
                                    /*Price__c,Quantity__c,
                                    AdditionnalDiscount__c,Discount__c*/
                                    //start LinePrice
                                    genResults.writeStartObject();
                                        if(inv.CreditNoteOffers__r[i].Quantity__c != null){
                                            genResults.writeNumberField('-LinePriceQte',inv.CreditNoteOffers__r[i].Quantity__c);
                                        }

                                        if(inv.CreditNoteOffers__r[i].PriceWithoutAddDiscount__c != null){
                                            genResults.writeNumberField('-LineDetailPrice',inv.CreditNoteOffers__r[i].PriceWithoutAddDiscount__c);
                                        }

                                        if(inv.CreditNoteOffers__r[i].CataloguePrice__c != null){
                                            genResults.writeNumberField('-LineGrossPrice',inv.CreditNoteOffers__r[i].CataloguePrice__c);
                                        }
                                    
                                    
                                        decimal price;
                                        decimal qty;

                                        //DUN 17/08/2016 ternary
                                        /*if(inv.CreditNoteOffers__r[i].Price__c == null){
                                            price = 0;
                                        }else{
                                            price = inv.CreditNoteOffers__r[i].Price__c;
                                        }*/
                                        price = inv.CreditNoteOffers__r[i].PriceWithoutAddDiscount__c != null ? inv.CreditNoteOffers__r[i].PriceWithoutAddDiscount__c : 0;

                                        //DUN 17/08/2016 ternary
                                        /*if(inv.CreditNoteOffers__r[i].Quantity__c == null){
                                            qty = 0;
                                        }else{
                                            qty = inv.CreditNoteOffers__r[i].Quantity__c;
                                        }*/
                                        qty = inv.CreditNoteOffers__r[i].Quantity__c != null ? inv.CreditNoteOffers__r[i].Quantity__c : 0;

                                        genResults.writeNumberField('-LineVATExclNetPrice', price*qty); 
                                    
                                    genResults.writeEndObject();
                                    //end LinePrice

                                    genResults.writeFieldName('Tax');
                                    //start Tax
                                    genResults.writeStartObject();

                                        if(inv.CreditNoteOffers__r[i].VAT__c != null){
                                            genResults.writeNumberField('-TaxRate',inv.CreditNoteOffers__r[i].VAT__c);
                                        }

                                    genResults.writeEndObject();
                                    //end Tax

                                    genResults.writeFieldName('OtherLine');
                                    //start OtherLine
                                    genResults.writeStartObject();
                                        if(inv.CreditNoteOffers__r[i].AdditionnalDiscount__c != null){
                                            genResults.writeStringField('-OtherLineQlf','Rebate');
                                        }

                                        if(inv.CreditNoteOffers__r[i].Discount__c != null){
                                            genResults.writeStringField('-OtherLineQlfTxt','Remise');
                                        }

                                        //genResults.writeFieldName('OtherLine');
                                        //start OtherLine
                                        //genResults.writeStartObject();

                                            genResults.writeFieldName('LinePrice');
                                            //start LinePrice
                                            genResults.writeStartObject();
                                                genResults.writeStringField('-LinePriceQte','100');

                                            
                                                Decimal addDis;
                                                Decimal dis;

                                                //DUN 07/07/2016 C-001663 Wrong calculation of discount
                                                /*if(inv.CreditNoteOffers__r[i].AdditionnalDiscount__c == null || inv.CreditNoteOffers__r[i].AdditionnalDiscount__c == 0){
                                                    addDis = 1;
                                                }else{
                                                    addDis = inv.CreditNoteOffers__r[i].AdditionnalDiscount__c;
                                                }

                                                if(inv.CreditNoteOffers__r[i].Discount__c == null || inv.CreditNoteOffers__r[i].Discount__c == 0){
                                                    dis = 1;
                                                }else{
                                                    dis = inv.CreditNoteOffers__r[i].Discount__c;
                                                }

                                                genResults.writeNumberField('-LineDetailPrice', addDis * dis);

                                                genResults.writeNumberField('-LineVATExclNetPrice', addDis * dis);*/

                                                //DUN 27/09/2016 ternary
                                                /*if(inv.CreditNoteOffers__r[i].AdditionnalDiscount__c == null){
                                                    addDis = 0;
                                                }else{
                                                    addDis = inv.CreditNoteOffers__r[i].AdditionnalDiscount__c;
                                                }*/
                                                addDis = inv.CreditNoteOffers__r[i].AdditionnalDiscount__c != null ? inv.CreditNoteOffers__r[i].AdditionnalDiscount__c : 0;

                                                //DUN 27/09/2016 ternary
                                                /*if(inv.CreditNoteOffers__r[i].Discount__c == null){
                                                    dis = 0;
                                                }else{
                                                    dis = inv.CreditNoteOffers__r[i].Discount__c;
                                                }*/
                                                dis = inv.CreditNoteOffers__r[i].Discount__c != null ? inv.CreditNoteOffers__r[i].Discount__c : 0;

                                                genResults.writeNumberField('-LineDetailPrice', addDis + dis);

                                                genResults.writeNumberField('-LineVATExclNetPrice', addDis + dis);
                                            
                                            genResults.writeEndObject();
                                            //end LinePrice

                                        //genResults.writeEndObject();
                                        //end OtherLine

                                    genResults.writeEndObject();
                                    //end OtherLine
                                genResults.writeEndObject();
                                //end Line
                            }
                        }
                        //WCH 19/02/2019 C-002910 Order Lines/Offers are not associated to Invoice/Credit Note
                        else{
                            integer i=-1;
                            if(!String.isBlank(inv.TechOfferIds__c) && inv.TechOfferIds__c.split('-').size()>0)
                            for(String currentOfferId : inv.TechOfferIds__c.split('-')){
                                //WCH 02/05/2019 C-003215 Invoices not sent to Cegedim
                                if(!String.isBlank(currentOfferId) && currentOfferId.length()==18 && offerIdMapOffer.get(currentOfferId)!=null){
                                    i++;
                                    //start Line
                                    genResults.writeStartObject();
                                        genResults.writeNumberField('-LineNumCod', i+1);

                                        genResults.writeFieldName('ProductReference');
                                        //start ProductReference
                                        genResults.writeStartObject();
                                            if(offerIdMapOffer.get(currentOfferId).PartNUmber__c != null){
                                                genResults.writeStringField('-ProductRefCod',offerIdMapOffer.get(currentOfferId).PartNUmber__c);
                                            }

                                            if(offerIdMapOffer.get(currentOfferId).Description__c != null){
                                                genResults.writeStringField('-ProductRefTxt',offerIdMapOffer.get(currentOfferId).Description__c.left(35));                                            
                                            }
                                        genResults.writeEndObject();
                                        //end ProductReference

                                        genResults.writeFieldName('Reference');
                                        //start Reference
                                        genResults.writeStartObject();
                                            genResults.writeStringField('-ReferenceQlf','Other');
                                            genResults.writeStringField('-OtherReferenceQlfTxt','Référence fournisseur');
                                            genResults.writeStringField('-ReferenceCod',offerIdMapOffer.get(currentOfferId).Id);
                                        genResults.writeEndObject();
                                        //end Reference
                                        genResults.writeFieldName('LinePrice');
                                        //start LinePrice
                                        genResults.writeStartObject();
                                            if(offerIdMapOffer.get(currentOfferId).Quantity__c != null){
                                                genResults.writeNumberField('-LinePriceQte',offerIdMapOffer.get(currentOfferId).Quantity__c);
                                            }
                                            if(offerIdMapOffer.get(currentOfferId).PriceWithoutAddDiscount__c != null){
                                                genResults.writeNumberField('-LineDetailPrice',offerIdMapOffer.get(currentOfferId).PriceWithoutAddDiscount__c);
                                            }
                                            if(offerIdMapOffer.get(currentOfferId).CataloguePrice__c != null){
                                                genResults.writeNumberField('-LineGrossPrice',offerIdMapOffer.get(currentOfferId).CataloguePrice__c);
                                            }
                                            decimal price;
                                            decimal qty;
                                            price = offerIdMapOffer.get(currentOfferId).PriceWithoutAddDiscount__c != null ? offerIdMapOffer.get(currentOfferId).PriceWithoutAddDiscount__c : 0;
                                            qty = offerIdMapOffer.get(currentOfferId).Quantity__c != null ? offerIdMapOffer.get(currentOfferId).Quantity__c : 0;
                                            genResults.writeNumberField('-LineVATExclNetPrice', price*qty); 
                                        genResults.writeEndObject();
                                        //end LinePrice

                                        genResults.writeFieldName('Tax');
                                        //start Tax
                                        genResults.writeStartObject();

                                            if(offerIdMapOffer.get(currentOfferId).VAT__c != null){
                                                genResults.writeNumberField('-TaxRate',offerIdMapOffer.get(currentOfferId).VAT__c);
                                            }

                                        genResults.writeEndObject();
                                        //end Tax

                                        genResults.writeFieldName('OtherLine');
                                        //start OtherLine
                                        genResults.writeStartObject();
                                            if(offerIdMapOffer.get(currentOfferId).AdditionnalDiscount__c != null){
                                                genResults.writeStringField('-OtherLineQlf','Rebate');
                                            }

                                            if(offerIdMapOffer.get(currentOfferId).Discount__c != null){
                                                genResults.writeStringField('-OtherLineQlfTxt','Remise');
                                            }
                                                genResults.writeFieldName('LinePrice');
                                                //start LinePrice
                                                genResults.writeStartObject();
                                                    genResults.writeStringField('-LinePriceQte','100');

                                                
                                                    Decimal addDis;
                                                    Decimal dis;
                                                    addDis = offerIdMapOffer.get(currentOfferId).AdditionnalDiscount__c != null ? offerIdMapOffer.get(currentOfferId).AdditionnalDiscount__c : 0;
                                                    dis = offerIdMapOffer.get(currentOfferId).Discount__c != null ? offerIdMapOffer.get(currentOfferId).Discount__c : 0;

                                                    genResults.writeNumberField('-LineDetailPrice', addDis + dis);

                                                    genResults.writeNumberField('-LineVATExclNetPrice', addDis + dis);
                                                
                                                genResults.writeEndObject();
                                                //end LinePrice

                                            //end OtherLine

                                        genResults.writeEndObject();
                                        //end OtherLine
                                    genResults.writeEndObject();
                                    //end Line

                                }
                            }
                        }
                        genResults.writeEndArray();
                    
                        genResults.writeFieldName('Footer');
                        //start Footer
                        genResults.writeStartObject();

                            genResults.writeFieldName('Tax');
                            //start Tax
                            genResults.writeStartObject();
                                genResults.writeStringField('-TaxTypCod','VAT');
                            
                                if(inv.VAT__c != null){
                                    genResults.writeNumberField('-TaxRate',inv.VAT__c);
                                }

                                if(inv.TotalNet__c != null){
                                    genResults.writeNumberField('-TaxBaseValue',inv.TotalNet__c);
                                }
                            
                                if(inv.TotalVAT__c != null){
                                    genResults.writeNumberField('-TaxValue',inv.TotalVAT__c);
                                }
                            
                            genResults.writeEndObject();
                            //end Tax

                            genResults.writeFieldName('NetPayableAmount');
                            //start NetPayableAmount
                            genResults.writeStartObject();
                             //TotalVAT__c,Total__c, TotalNet__c
                                if(inv.TotalVAT__c != null){
                                    genResults.writeNumberField('-TaxTotalAmount',inv.TotalVAT__c);
                                }

                                if(inv.Total__c != null){
                                    genResults.writeNumberField('-TaxIncludedTotal',inv.Total__c);
                                }

                                if(inv.TotalNet__c != null){
                                    genResults.writeNumberField('-TaxableTotalAmount',inv.TotalNet__c); 
                                }

                                if(inv.Total__c != null){
                                    genResults.writeNumberField('-NetPayableAmount',inv.Total__c);
                                }

                            genResults.writeEndObject();
                            //end NetPayableAmount
                        
                        genResults.writeEndObject();
                        //end Footer
                    

            genResults.writeEndObject();
          }
          genResults.writeEndArray();
                genResults.writeEndObject();

                JsonResp = genResults.getAsString();

                system.debug('///// JsonResp: ' + JsonResp);
        }else{
          JsonResp = 'No invoices';
        }
    
        HttpRequest reqAccess = new HttpRequest();
        reqAccess.setMethod('POST');
        // to update end point custom label on PRODUCTION
        reqAccess.setEndpoint(endPointCegedim);
        //client key
        //String username = userCegedim;  vsu - commented for named credentials
        //client secret
        //String password = passCegedim;  vsu - commented for named credentials
            
       /* Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
               
        reqAccess.setHeader('Authorization', authorizationHeader);*/
        reqAccess.setHeader('Content-Type','application/json;charset=UTF-8');
        reqAccess.setBody(JsonResp);
        // set timeout to max
        reqAccess.setTimeout(120000); 
        system.debug('############### END buildWebServiceRequest:'+reqAccess);
        return reqAccess;
    }
    else{
        return null;
    }
  }
  
  public static HttpResponse invokeWebService(HttpRequest req){
    system.debug('############### START invokeWebService > req=' + req);
    Http httpCall = new Http();
    HTTPResponse res = httpCall.send(req); 
    
    createLog(res.getBody());
    system.debug('############### END invokeWebService');
    return res;
  }
}