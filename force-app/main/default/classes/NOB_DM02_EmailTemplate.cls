/**
 * @description       : Query class for Email Templates
 * @author            : GBH
 * @group             : 
 * @last modified on  : 11-18-2021
 * @last modified by  : GBH 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   11-18-2021   GBH   Initial Version
**/
public without sharing class NOB_DM02_EmailTemplate {
    private static EmailTemplate emailTemplateInstance = null;
    private static String currentDeveloperName = null;

    public static EmailTemplate getEmailTemplateByDeveloperName(String DevName){
        if (emailTemplateInstance == null || (currentDeveloperName != DevName)) {
            List<EmailTemplate> lstET = [SELECT Subject, Body, HtmlValue, Markup, TemplateType, DeveloperName FROM EmailTemplate where DeveloperName = :DevName];
            emailTemplateInstance = (lstET.size()>0)? lstET[0] : null;
            System.debug('Query'+DevName);
            currentDeveloperName = DevName;
        }
        return emailTemplateInstance;
    }
}