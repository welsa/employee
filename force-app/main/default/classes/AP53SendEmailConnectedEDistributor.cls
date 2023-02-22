/*************************************************************************************
Class Name - AP53SendEmailConnectedEDistributor
Version - 1.0
Created Date - 13 FEB 2023
Function - PREv2 Connected - Lot4.4 Order Treatment: Cancellation management

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* -------------- ----------     -----------------------
* Rayhaan B       13/02/2023     Initial Version
*************************************************************************************/
public without sharing class AP53SendEmailConnectedEDistributor {
    @TestVisible
    private static List<Messaging.SendEmailResult> emailResultList;

    @future
    public static void sendPOCancellationEmail(Set<Id> setPOId){
        System.debug('## ----------------------Start sendPOCancellationEmail----------------------');

        PIEC_Config__mdt piecConfig = PIEC_Config__mdt.getInstance('ASPISUpdatePiecPOOrderLines');
        if(piecConfig.AllowDistributorEmails__c == false)
            return;

        List<PurchaseOrder__c> lstPO = [SELECT AssessmentEncodedId__c, Assessment__r.BodyShop__r.Name, Assessment__r.BodyShop__r.ContactUser__c, Assessment__r.bodyshop__r.ContactUser__r.LanguageLocaleKey
                                        FROM PurchaseOrder__c 
                                        WHERE Id IN :setPOId];
        System.debug('## lstPO '+ lstPO);
        if(lstPO.isEmpty()) return;

        List<String> emailTemplateDevNamesList = (String.isNotBlank(piecConfig.EmailTemplateList__c)) ? piecConfig.EmailTemplateList__c.split(';') : new List<String>();
        System.debug('## emailTemplateDevNamesList '+ emailTemplateDevNamesList);
        Map<String, EmailTemplate> mapLanguageCodeEmailTemplate = new Map<String, EmailTemplate>();

        for(EmailTemplate currentEmailTemplate : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN: emailTemplateDevNamesList]){
            String languageCode = currentEmailTemplate.DeveloperName.substringAfter('_');
            system.debug('##languageCode'+ languageCode);
            mapLanguageCodeEmailTemplate.put(languageCode, currentEmailTemplate);
        }

        if(!mapLanguageCodeEmailTemplate.isEmpty()){
            System.debug('##mapLanguageCodeEmailTemplate size >0');
            List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
            for(PurchaseOrder__c po : lstPO){
                if(!mapLanguageCodeEmailTemplate.containsKey(po.Assessment__r.bodyshop__r.ContactUser__r.LanguageLocaleKey))                
                    continue;

                if(piecConfig.AllowDistributorEmails__c){
                    Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(mapLanguageCodeEmailTemplate.get(po.Assessment__r.bodyshop__r.ContactUser__r.LanguageLocaleKey).Id, 
                    po.Assessment__r.BodyShop__r.ContactUser__c, po.Id);
                    system.debug('##currentEmail '+currentEmail);
                    currentEmail.setTargetObjectId(po.Assessment__r.BodyShop__r.ContactUser__c);
                    currentEmail.setSaveAsActivity(false);
                    currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);
                    emailListToSend.add(currentEmail);
                }
            }
            system.debug('## emailListToSend' + emailListToSend);
            if(emailListToSend.size() > 0){
                emailResultList = Messaging.sendEmail(emailListToSend);
                for(Messaging.SendEmailResult result : emailResultList){
                    if(result.isSuccess())
                        System.debug('## Email sent');
                    else
                    System.debug('## Email error: '+result.getErrors());
                }
            }
        }
        System.debug('## ----------------------End sendPOCancellationEmail----------------------');
    }
}