/*
----------------------------------------------------------------------
-- - Name          : AP35R4SendPurchaseOrderEmail
-- - Author        : ABT
-- - Description   : Class is in without sharing as the code will be executed by bodyshops
--
--  NOTE: PATCH (RUSTINE) : The sending of email is also sent to inactive users. Therefore this is beneficial for France
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 05-APR-2017  ABT     1.0         Initial version
-- 12-SEP-2017  DUN     1.1         Case 2020 
-- 03-OCT-2017  DUN     1.3         ticket 403,406 
-- 11-DEC-2017  VSU     1.4         ticket 10 Emails for DE R4
-- 09-JAN-2018  VSU     1.5         ticket 85 Emails sent by dev(BE)
-- 11-JUN-2018  DUN     1.6         C-002236 : l'allemagne (et donc Coler), c'est pareil que ce soit un Connecté ou pas
-- 01-NOV-2018  AMI     1.7         C-002781 : Migrate Spain to R4
--                                           : New Distributor Notification Email Template for ES in R4
-- 06-DEC-2018  AMI     1.8         C-002781 : Migrate Spain to R4
                                             : Removing ASF in email attachment for Spain
-- 23-NOV-2019  WCH     1.9         C-003531 : Modify all email and delivery note templates sent to BS and Distributor
-- 15-JUN-2020  RLA     1.9        C-003773: IG - New Custom Setting: CustomerInformationMapping
-- 09-Nov-2020  KPA     2.0        C-004026 : Pentest - Insecure Direct Object Reference
-- 23/03/2021   RLA     2.1        C-004102: FR - Aniel Distributor Integration

**********************************************************************
*/
public without sharing class AP35R4SendPurchaseOrderEmail 
{
    @TestVisible
    private static List<Messaging.SendEmailResult> emailResultList;

    @future(callout=true)
    public static void sendEmailASync(Set<Id> orderEmailIdSet, Set<Id> quotationEmailIdSet, Set<Id> quotationOrderEmailIdSet)
    {
        sendEmail(orderEmailIdSet, quotationEmailIdSet, quotationOrderEmailIdSet);
    }

    public static void sendEmail(Set<Id> orderEmailIdSet, Set<Id> quotationEmailIdSet, Set<Id> quotationOrderEmailIdSet)
    {
        system.debug('## Start sendEmail');
        // combining all the sets
        Set<Id> purchaseOrderIdSet = new Set<Id>();
        purchaseOrderIdSet.addAll(orderEmailIdSet);
        purchaseOrderIdSet.addAll(quotationEmailIdSet);
        purchaseOrderIdSet.addAll(quotationOrderEmailIdSet);
        
        
        // Retrieving the required data
        //AMI 01/11/18 C-002781 : Migrate Spain to R4
        //                      : Query Tech_BSCommunityPopulationType__c
        List<PurchaseOrder__c> purchaseOrderList = [SELECT  Id, Name, Brand__c, DistributorContact__c, DistributorContact__r.Email,wsErrorMessage__c , Distributor__r.DistributorConnected__c,Distributor__r.Type_of_Substitutes__c,DistributorContact__r.LanguageLocaleKey
                                                            ,Assessment__r.BodyShop__r.DistributorConnected__c,TECH_AssessmentCountryCode__c,Tech_BSCommunityPopulationType__c,
                                                            Assessment__r.InsuranceBroker__c//RLA 15/06/2020  C-003773: IG - New Custom Setting: CustomerInformationMapping
                                                    FROM    PurchaseOrder__c
                                                    WHERE   Id IN: purchaseOrderIdSet
                                                    AND     DistributorContact__c != null];
                                                    

        // Retrieving the email templates
        Map<String, EmailTemplate> mapEmailTemplateDevName = new Map<String, EmailTemplate>();

        //AMI 01/11/18 C-002781 : Migrate Spain to R4
        //                      : New Distributor Notification Email Template for ES in R4
        List<String> emailTemplateDevNameList = new List<String>
        {
            Label.R4POOrderEmailTemplateFR,
            Label.R4POQuotationEmailTemplateFR,
            Label.R4POQuotationOrderedEmailTemplateFR,
            Label.R4POOrderEmailTemplateFROrder,
            Label.R4POOrderEmailTemplateFRStock,
            Label.R4POQuotationEmailTemplateDE,
            Label.R4POQuotationOrderedEmailTemplateDE,
            Label.R4POOrderEmailTemplateDE,
            Label.R4POOrderEmailTemplatedBE_FR,
            Label.R4POOrderEmailTemplatedBE_NL,
            Label.R4POQuotationEmailTemplateES,
            Label.R4POQuotationOrderedEmailTemplateES
        };  

        for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                    FROM    EmailTemplate
                                                    WHERE   DeveloperName IN: emailTemplateDevNameList])
        {
            system.debug('##currentEmailTemplate: '+currentEmailTemplate);
            mapEmailTemplateDevName.put(currentEmailTemplate.DeveloperName, currentEmailTemplate);
        }
        
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
        
        if(mapEmailTemplateDevName != null && mapEmailTemplateDevName.size() > 0)
        {
            for(PurchaseOrder__c currentPurchaseOrder : purchaseOrderList)
            {
                //RLA 15/06/2020  C-003773: IG - New Custom Setting: CustomerInformationMapping
                CustomerInformationsMapping__mdt customerInformationsMapping;
                Boolean allowEmails = true;
                if (String.isnotblank(currentPurchaseOrder.Assessment__r.InsuranceBroker__c)){
                    customerInformationsMapping = RestDistributorUtility.getcustomerMapping(currentPurchaseOrder.Assessment__r.InsuranceBroker__c);
                }
                if (customerInformationsMapping != null && !customerInformationsMapping.AllowDistributorEmails__c ){
                    allowEmails = false;
                }

                // Getting the PDF as a blob
                PageReference currentPage = Page.VFP15_PrintPartListForDistributor;
               
               //KPA 06/11/2020  C-004026 
                String POId = EncodingUtil.base64Encode(Blob.valueof(currentPurchaseOrder.Id));
               
                currentPage.getParameters().put('Id',POId);
                System.debug('~~~~~~~ POId '+POId);

                //WCH 23/12/2019 C-003531 is demande de livraison
                if(currentPurchaseOrder.TECH_AssessmentCountryCode__c.equals('FR')){
                    currentPage.getParameters().put('isDDL', 'true');
                }
                system.debug('## currentPurchaseOrder.Id ' + currentPurchaseOrder.Id);

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

                system.debug('## attachmentBlob ' + attachmentBlob);

                String templateId;

                if (orderEmailIdSet.contains(currentPurchaseOrder.Id) && 
                    //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
                    RestDistributorUtility.isConnectedDist (currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c) &&
                    currentPurchaseOrder.wsErrorMessage__c != null &&
                    !currentPurchaseOrder.wsErrorMessage__c.contains(system.label.R4POOrderErrorReported) && 
                    !currentPurchaseOrder.wsErrorMessage__c.contains(system.label.R4POOrderOrderSuccessfullySent) &&
                    !currentPurchaseOrder.wsErrorMessage__c.contains(system.label.R4POClientNonTrouve) &&
                    currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'FR'){
                    system.debug('## case 1');
                        
                    
  
                     

                    templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplateFRStock).Id;
                }
                //DUN 04/12/2017 PILOT BS
                else if (orderEmailIdSet.contains(currentPurchaseOrder.Id) && 
                    //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
                    RestDistributorUtility.isConnectedDist (currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c) &&
                    !currentPurchaseOrder.Assessment__r.BodyShop__r.DistributorConnected__c)
                {   
                    system.debug('## case TOREMOVE PILOT ');
                    if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'FR'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplateFR).Id;
                    }
                }

                //11/06/2018 DUN C-002236 : l'allemagne (et donc Coler), c'est pareil que ce soit un Connecté ou pas
                //RLA 15/06/2020  C-003773: IG - New Custom Setting: CustomerInformationMapping
                else if(orderEmailIdSet.contains(currentPurchaseOrder.Id) && 
                        currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE'
                        && allowEmails){
                    system.debug('## case 2 DE');
                    templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplateDE).Id;
                }
                else if (orderEmailIdSet.contains(currentPurchaseOrder.Id) && 
                    //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
                    (!RestDistributorUtility.isConnectedDist (currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c)
                    || (RestDistributorUtility.isConnectedDist (currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c)
                        && String.isnotblank(currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c) && !((currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c).contains('Order Call'))
                        )
                    )
                )
                {   
                    system.debug('## case 2');
                    if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'FR')
                    {
                        templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplateFR).Id;
                    }
                    //else if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE'){
                    //    templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplateDE).Id;                        
                    //}
                    else if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'BE'){
                        system.debug('##techcode BE');
                        if(currentPurchaseOrder.DistributorContact__r.LanguageLocaleKey == 'fr_BE'){
                            system.debug('##label template BEFR: '+mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplatedBE_FR));
                            templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplatedBE_FR).Id;
                        }
                        else if(currentPurchaseOrder.DistributorContact__r.LanguageLocaleKey == 'nl_BE'){
                            system.debug('##label template NL: '+mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplatedBE_NL));
                            templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplatedBE_NL).Id;
                        }
                    }
                    
                }
                else if (orderEmailIdSet.contains(currentPurchaseOrder.Id) && 
                    //RLA 23/03/2021 C-004102: FR - Aniel Distributor Integration
                    RestDistributorUtility.isConnectedDist (currentPurchaseOrder.Distributor__r.Type_of_Substitutes__c) &&
                    currentPurchaseOrder.wsErrorMessage__c != null &&
                        currentPurchaseOrder.wsErrorMessage__c.contains(system.label.R4POOrderErrorReported))
                {
                    system.debug('## case 3');
                    if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'FR'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POOrderEmailTemplateFROrder).Id;
                    }
                }
                else if (quotationEmailIdSet.contains(currentPurchaseOrder.Id))
                {
                    system.debug('## case 4');
                    if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'FR'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POQuotationEmailTemplateFR).Id;
                    }
                    else if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POQuotationEmailTemplateDE).Id;
                    }
                    //AMI 01/11/18 C-002781 : Migrate Spain to R4
                    //                      : New Distributor Notification Email Template for ES in R4
                    else if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'ES' && currentPurchaseOrder.Tech_BSCommunityPopulationType__c == 'R4'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POQuotationEmailTemplateES).Id;
                    }
                }
                else if (quotationOrderEmailIdSet.contains(currentPurchaseOrder.Id))
                {
                    system.debug('## case 5');
                    if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'FR'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POQuotationOrderedEmailTemplateFR).Id;
                    }
                    else if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'DE'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POQuotationOrderedEmailTemplateDE).Id;
                    }
                    //AMI 01/11/18 C-002781 : Migrate Spain to R4
                    //                      : New Distributor Notification Email Template for ES in R4
                    else if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'ES' && currentPurchaseOrder.Tech_BSCommunityPopulationType__c == 'R4'){
                        templateId = mapEmailTemplateDevName.get(Label.R4POQuotationOrderedEmailTemplateES).Id;
                    }
                }


                if(templateId != null && templateId != ''){

                    Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(templateId, currentPurchaseOrder.DistributorContact__c, currentPurchaseOrder.Id);
                    currentEmail.setTargetObjectId(currentPurchaseOrder.DistributorContact__c);
                    currentEmail.setSubject(currentEmail.getSubject());
                    currentEmail.setHtmlBody(currentEmail.getHtmlBody());
                    currentEmail.setPlainTextBody(currentEmail.getPlainTextBody());
                    System.debug('KEM '+ currentEmail.getPlainTextBody());
                    currentEmail.setSaveAsActivity(false);
                    currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);

                    system.debug('@@@ currentEmail'+currentEmail.getPlainTextBody());
                    system.debug('@@@ currentEmail'+currentEmail.getHtmlBody());
                    // string str = Sring.value
                    

                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();

                    //AMI 06/12/18 : C-002781 : Migrate Spain to R4
                    //                        : Removing ASF in email attachment for Spain
                    if(currentPurchaseOrder.TECH_AssessmentCountryCode__c == 'ES' && currentPurchaseOrder.Tech_BSCommunityPopulationType__c == 'R4'){
                        emailAttachment.setFileName(String.format(Label.ESDeliveryNoteName, new List<String>{currentPurchaseOrder.Name, currentPurchaseOrder.Brand__c, System.now().format('dd-MM-YYY')}));
                    }else{
                        emailAttachment.setFileName(String.format(Label.DeliveryNoteName, new List<String>{currentPurchaseOrder.Name, currentPurchaseOrder.Brand__c, System.now().format('dd-MM-YYY')}));
                    }
                    
                    emailAttachment.setBody(attachmentBlob);
                    System.debug('KEM '+ currentEmail);

                    currentEmail.setFileAttachments(new List<Messaging.EmailFileAttachment>{emailAttachment});

                    emailListToSend.add(currentEmail);
                }
            }

            if(emailListToSend.size() > 0)
            {
                emailResultList = Messaging.sendEmail(emailListToSend);
            }
        }
    }

}