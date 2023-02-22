/*************************************************************************************
Class Name - AP22PopulateContactOnAccount
Version - 1.0
Function - Class to populate the ContactUser__c on Assessment 

Modification Log :
-----------------------------------------------------------------------------
* Developer      Date           Description
* ----------     ----------  -----------------------
* VSU           20-JUN-2018  Original Version
* RLA           07-AUG-2018  Version 2 : No Process Builder (C-002294)
*************************************************************************************/
public class AP44PopulateContactOnAssessment { 

     @TestVisible
    private static List<Messaging.SendEmailResult> emailResultList;

    public static void sendEmail(List<Assessment__c> l_Assessments, Set<Id> s_bodyshopIds){
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();   
        EmailTemplate emailTemplate; 

        for(EmailTemplate currentEmailTemplate : [  SELECT  Id, DeveloperName
                                                    FROM    EmailTemplate
                                                    WHERE   DeveloperName =: system.Label.Assessment_Manual_Ordering_Notify_Bodyshop])
        {
            emailTemplate = currentEmailTemplate;
        }

        if (emailTemplate != null){

            for (Assessment__c ass : l_Assessments)
            {
                if (String.isNotBlank(ass.Notification_User__c))
                {
                    system.debug('Send email' + ass.Notification_User__c);
                    //ass.NotificationUser__c = m_Accounts.get(ass.bodyshop__c);
                    //system.debug('££ass.NotificationUser__c '+ass.NotificationUser__c);

                    Messaging.SingleEmailMessage currentEmail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, ass.Notification_User__c, ass.Id);
                    currentEmail.setTargetObjectId(ass.Notification_User__c);
                    currentEmail.setSubject(currentEmail.getSubject());
                    currentEmail.setHtmlBody(currentEmail.getHtmlBody());
                    currentEmail.setPlainTextBody(currentEmail.getPlainTextBody());
                    currentEmail.setSaveAsActivity(false);
                    currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);

                    emailListToSend.add(currentEmail);

                }
            }

            system.debug('emailListToSend '+emailListToSend);

            if(emailListToSend.size() > 0)
            {
                emailResultList = Messaging.sendEmail(emailListToSend);
            }
            system.debug('emailResultList '+emailResultList);
        }
    }
}