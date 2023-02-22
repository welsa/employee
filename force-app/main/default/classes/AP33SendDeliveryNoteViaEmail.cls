/*
----------------------------------------------------------------------
-- - Name          : AP33SendDeliveryNoteViaEmail
-- - Author        : ABT
-- - Description   : Class is in without sharing as the code will be executed by distributors
--
--  NOTE: PATCH (RUSTINE) : The sending of email is also sent to inactive users. Therefore this is beneficial for France
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 02-MAR-2017  ABT     1.0         Initial version
-- 11-JAN-2018  VSU     1.1         Ticket 89 Email R4 BE
-- 06-DEC-2018  AMI     1.2         C-002781 : Migrate Spain to R4
                                             : Removing ASF in email attachment for Spain
-- 06-JAN-2020  WCH     1.3         C-003531 : Modify all email and delivery note templates sent to BS and Distributor
-- 02-FEB-2020  WCH     1.4         C-003642 : When no claim ref on claim do not put any expert in copy
-- 01-JUN-2020  WCH     1.5         C-003728 : AlphaStore for FR Covid-19
-- 15-JUN-2020  RLA     1.9        C-003773: IG - New Custom Setting: CustomerInformationMapping
-- 12-AUG-2020  WCH     2.0        C-003622: La mention BL doit être affichée au nom de la pièce jointe envoyé au BS²
-- 10-Nov-2020  KPA     2.1        C-004026 : Pentest - Insecure Direct Object Reference----------------------------------------------------------------------
**********************************************************************
*/
public without sharing class AP33SendDeliveryNoteViaEmail
{
    @TestVisible
    private static List<Messaging.SendEmailResult> emailResultList;

    @future(callout=true)
    public static void sendDeliveryNoteByEmail(Set<Id> salesOrderIdToSendDeliveryNote)
    {
        system.debug('## start sendDeliveryNoteByEmail');
        // Retrieving the required data
        List<PrerequisiteOrder__c> salesOrderList = [SELECT Id, Name, BodyShopContact__c, BodyShopContact__r.LanguageLocaleKey, Manufacturer__c, PlateNumber__c, TECH_BodyshopCountryCode__c,ClaimReference__c /* WCH 06/01/2019 C-003531 */,Assessment__r.isAlphaStore__c/* WCH 06/01/2020 C-003728*/, Assessment__r.InsuranceBroker__c/*RLA 15/06/2020  C-003773*/
                                                     FROM   PrerequisiteOrder__c
                                                     WHERE  Id IN: salesOrderIdToSendDeliveryNote 
                                                     AND    BodyShopContact__c != null];
        //WCH 06/01/2019 C-003531 retrieve experts
        Set<String> claimRefs = new Set<String>();
        Set<String> countryCodes = new Set<String>();//WCH 02/03/2020 C-003642
        Map<String,String> claimRefsMapExpertEmail = new Map<String,String>();
        for(PrerequisiteOrder__c theSO : salesOrderList){
            //WCH 02/03/2020 C-003642
            if(String.isNotBlank(theSO.ClaimReference__c)){
                claimRefs.add(theSO.ClaimReference__c);
                countryCodes.add(theSO.TECH_BodyshopCountryCode__c);
            }
        }
        //WCH 02/03/2020 C-003642 add filter on TECH_EntityCountryCode__c
        for(Assessment__c theExpAss : [SELECT id,Bodyshop__r.ContactEmail__c,claimreference__c FROM   Assessment__c WHERE  claimreference__c IN: claimRefs AND BodyShop__r.type='Expert' and Recordtype.Name = :ASPISConstants.ASSESS_RT_DeveloperName_Claim and TECH_EntityCountryCode__c = :countryCodes order by createddate desc]){
            if(!claimRefsMapExpertEmail.containsKey(theExpAss.claimreference__c) && String.isNotBlank(theExpAss.Bodyshop__r.ContactEmail__c)){
                claimRefsMapExpertEmail.put(theExpAss.claimreference__c,theExpAss.Bodyshop__r.ContactEmail__c);
            }
        }

        List<String> emailTemplateDevNamesList = (String.isNotBlank(Label.SendDeliveryNoteEmailTemplateDevName)) ? Label.SendDeliveryNoteEmailTemplateDevName.split(';') : new List<String>();
        Map<String, EmailTemplate> mapLanguageCodeEmailTemplate = new Map<String, EmailTemplate>();

        for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                    FROM    EmailTemplate
                                                    WHERE   DeveloperName IN: emailTemplateDevNamesList])
        {
            String languageCode = currentEmailTemplate.DeveloperName.substringAfter('_'); //10-01-12 Replaced tech_countrycode
            system.debug('##languageCode'+ languageCode);
            mapLanguageCodeEmailTemplate.put(languageCode, currentEmailTemplate);
        }

        // Retrieving the email template to be used
        // EmailTemplate currentEmailTemplate = [  SELECT  Id
        //                                         FROM    EmailTemplate
        //                                         WHERE   DeveloperName =: Label.SendDeliveryNoteEmailTemplateDevName];
        
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();


        // if(currentEmailTemplate != null)
        if(mapLanguageCodeEmailTemplate.size() > 0)
        {
            system.debug('##mapLanguageCodeEmailTemplate size >0');
            for(PrerequisiteOrder__c currentSalesOrder : salesOrderList)
            {
                // checking if the email template for that country is found in the map
                // else skip it
                
                if(!mapLanguageCodeEmailTemplate.containsKey(currentSalesOrder.BodyShopContact__r.LanguageLocaleKey))
                {
                    continue;
                }
                //RLA 15/06/2020  C-003773: IG - New Custom Setting: CustomerInformationMapping
                CustomerInformationsMapping__mdt customerInformationsMapping;
                Boolean allowEmails = true;
                if (String.isnotblank(currentSalesOrder.Assessment__r.InsuranceBroker__c)){
                    customerInformationsMapping = RestDistributorUtility.getcustomerMapping(currentSalesOrder.Assessment__r.InsuranceBroker__c);
                }
                if (customerInformationsMapping != null && !customerInformationsMapping.AllowBodyshopEmails__c ){
                    allowEmails = false;
                }

                // Getting the PDF as a blob
                PageReference currentPage = Page.VFP14_PrintPartListForBodyshop;
                
                //KPA 10/11/2020  C-004026 
                String SOId = EncodingUtil.base64Encode(Blob.valueof(currentSalesOrder.Id));
                
                currentPage.getParameters().put('Id',SOId);
                
                // currentPage.getParameters().put('Id', currentSalesOrder.Id);
                currentPage.getParameters().put('lang', currentSalesOrder.BodyShopContact__r.LanguageLocaleKey);
                //WCH 06/01/2019 C-003531
                if(currentSalesOrder.TECH_BodyshopCountryCode__c.equals('FR')){
                    currentPage.getParameters().put('isBDL_FR', 'true');
                }

                Blob attachmentBlob;
                try
                {
                    // Note that Salesforce Internal Error cannot be catched
                    // In test class we cannot run getContentAsPDF
                    attachmentBlob = (!Test.isRunningTest()) ? currentPage.getContentAsPDF() : Blob.valueOf('This is for test class. getContentAsPDF is not supported in test methods');
                }
                catch (Exception e)
                {
                    attachmentBlob = Blob.valueOf(e.getStackTraceString());
                }

                if (allowEmails){

                Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(mapLanguageCodeEmailTemplate.get(currentSalesOrder.BodyShopContact__r.LanguageLocaleKey).Id, currentSalesOrder.BodyShopContact__c, currentSalesOrder.Id);
                system.debug('##currentEmail '+currentEmail);
                currentEmail.setTargetObjectId(currentSalesOrder.BodyShopContact__c);

                //WCH 06/01/2019 C-003531
                if(String.isNotBlank(System.label.CountriesToSendDeliveryNoteCCToExpert) && System.label.CountriesToSendDeliveryNoteCCToExpert.contains(currentSalesOrder.TECH_BodyshopCountryCode__c) && claimRefsMapExpertEmail.containsKey(currentSalesOrder.ClaimReference__c)){
                    currentEmail.setCcAddresses(new List<String>{claimRefsMapExpertEmail.get(currentSalesOrder.ClaimReference__c)});
                }
                //WCH 06/01/2020 C-003728
                if(currentSalesOrder.TECH_BodyshopCountryCode__c.equals('FR') && currentSalesOrder.Assessment__r.isAlphaStore__c){
                    currentEmail.setSubject('Votre commande Alpha Scale France - '+ currentSalesOrder.Name);
                }else{
                    currentEmail.setSubject(currentEmail.getSubject());
                }
                currentEmail.setHtmlBody(currentEmail.getHtmlBody());
                currentEmail.setPlainTextBody(currentEmail.getPlainTextBody());
                currentEmail.setSaveAsActivity(false);
                currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);

                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();

                //AMI 06/12/18 : C-002781 : Migrate Spain to R4
                //                        : Removing ASF in email attachment for Spain
                if(currentSalesOrder.TECH_BodyshopCountryCode__c != null &&  currentSalesOrder.TECH_BodyshopCountryCode__c.toUpperCase() == ASPISConstants.userCountryCodeES){
                    emailAttachment.setFileName(String.format(Label.ESDeliveryNoteName, new List<String>{currentSalesOrder.Manufacturer__c, currentSalesOrder.PlateNumber__c, System.now().format('dd-MM-YYY')}));
                }
                //WCH 06/01/2020 C-003728
                else if(currentSalesOrder.TECH_BodyshopCountryCode__c != null &&  currentSalesOrder.TECH_BodyshopCountryCode__c.toUpperCase().equals('FR') && currentSalesOrder.Assessment__r.isAlphaStore__c){
                    emailAttachment.setFileName(String.format(Label.AlphaStoreDeliveryNoteNameFR, new List<String>{currentSalesOrder.Name, System.now().format('dd-MM-YYY')}));
                }
                //WCH 12/08/2020 C-003622
                else if(currentSalesOrder.TECH_BodyshopCountryCode__c != null &&  currentSalesOrder.TECH_BodyshopCountryCode__c.toUpperCase().equals('FR')){
                    emailAttachment.setFileName(String.format(Label.FRDeliveryNoteName, new List<String>{currentSalesOrder.Manufacturer__c, currentSalesOrder.PlateNumber__c, System.now().format('dd-MM-YYY')}));
                }
                else{
                    emailAttachment.setFileName(String.format(Label.DeliveryNoteName, new List<String>{currentSalesOrder.Manufacturer__c, currentSalesOrder.PlateNumber__c, System.now().format('dd-MM-YYY')}));
                }

                
                emailAttachment.setBody(attachmentBlob);

                currentEmail.setFileAttachments(new List<Messaging.EmailFileAttachment>{emailAttachment});

                emailListToSend.add(currentEmail);
                }
            }
            
            system.debug('## End emailListToSend' + emailListToSend);

            if(emailListToSend.size() > 0)
            {
                emailResultList = Messaging.sendEmail(emailListToSend);
            }
        }

        system.debug('## End sendDeliveryNoteByEmail');
    }
}