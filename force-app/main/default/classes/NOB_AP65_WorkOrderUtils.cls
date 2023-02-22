/**
 * @description       : Business logic for workOrderTriggerHandler
 * @author            : GBH
 * @group             : 
 * @last modified on  : 12-09-2021
 * @last modified by  : GBH 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   12-01-2021   GBH   Initial Version
**/
public without sharing class NOB_AP65_WorkOrderUtils {

    public static void buildAffectationEmail(List<WorkOrder> lstWO) {
        List<Map<String,String>> lstEmailContents = new List<Map<String,String>> ();
        Map<String, Id> mapOwnerIdContactId = new Map<String,String> ();
        Set<Id> setOwnerIds = new Set<Id> ();
        List<User> lstUsers = new List<User> ();

        EmailTemplate ET = NOB_DM02_EmailTemplate.getEmailTemplateByDeveloperName('NOB_MailAffectationMission');
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :System.Label.OrgWideEmailAddressPrefikar];

        for (WorkOrder wo : lstWO) {
            setOwnerIds.add(wo.OwnerId);
        }

        lstUsers = [SELECT Id, ContactId FROM User WHERE id IN :setOwnerIds];

        for (User u : lstUsers) {
            mapOwnerIdContactId.put(u.Id, u.ContactId);
        }

        for (WorkOrder wo : lstWO) {
            Map<String, String> mapEmailContent = new Map<String, String>();

            DateTime startDateTime= NOBTools.convertTimeToOtherTimeZone(wo.NOB_TECHDateRendezVousPrisEnCharge__c, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString());

            String startDate = NOBTools.dateTimeToString(startDateTime).right(10);
            String startTime = NOBTools.dateTimeToString(startDateTime).left(5);
            String htmlBody = ET.Markup;

            htmlBody=  htmlBody.replace('{!relatedTo.NOB_TECH_StartDate__c}', startDate);
            htmlBody=  htmlBody.replace('{!relatedTo.NOB_TECH_StartTime__c}', startTime);            

            mapEmailContent.put('TargetObjectId', mapOwnerIdContactId.get(wo.OwnerId));
            mapEmailContent.put('OrgWideEmailAddressId', owea[0].Id);
            mapEmailContent.put('Subject', 'Confirmation de rendez-vous');
            mapEmailContent.put('SaveAsActivity', 'true');
            mapEmailContent.put('HtmlBody', htmlBody);
            
            lstEmailContents.add(mapEmailContent);
        }

        NOBTools.sendEmail(lstEmailContents);
    }
}