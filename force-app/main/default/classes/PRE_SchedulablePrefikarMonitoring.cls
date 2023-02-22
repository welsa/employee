/**
 * @description       : Schedulable class for PRE_BatchPrefikarMonitoring
 * @author            : GBH
 * @group             : 
 * @last modified on  : 04-19-2022
 * @last modified by  : GBH 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-19-2022   GBH   Initial Version
**/
global class PRE_SchedulablePrefikarMonitoring  implements schedulable {
    
    public final Integer threshold;
    public List<String> lstUserIds;
    public List<String> lstAddresses;
    public final String cmdtAddresses;
    public final String thresholdOperator;
    public final Integer lastNHours;
    
    public String emailContent;
    public String emailSubject;
    public String Query;
    public Integer scopeSize;

    public Boolean isActive = false;

    public PRE_SchedulablePrefikarMonitoring(String name) {
        PRE_PrefikarMonitoring__mdt pm = PRE_PrefikarMonitoring__mdt.getInstance(name);

        isActive = pm.PRE_Active__c;
        Query = pm.PRE_Query__c;
        threshold = (Integer) pm.PRE_Threshold__c;
        thresholdOperator = pm.PRE_ThresholdOperator__c;
        emailSubject = pm.PRE_EmailSubject__c;
        emailContent = pm.PRE_EmailContent__c;
        lstUserIds = (pm.PRE_Recipients__c != null)? pm.PRE_Recipients__c.split(';') : new List<String>();
        cmdtAddresses = pm.PRE_EmailAddress__c;
        lstAddresses = (cmdtAddresses != null)? cmdtAddresses.split(';') : new List<String>();
        if (pm.PRE_LastNHours__c != null && Query.contains('{0}')) {
            
            lastNHours = (Integer) pm.PRE_LastNHours__c;
            
            DateTime cutOff = System.now().addHours(-lastNHours);
            System.debug('cutOff: '+ cutOff);

            String formattedCutOff = cutOff.formatGMT('yyyy-MM-dd\'T\'kk:mm:ss\'Z\'');
            System.debug('formattedCutOff: '+ formattedCutOff);

            Query = Query.replace('{0}', formattedCutOff);
        }

    }
    
    global void execute(SchedulableContext sc) {
        
        if (isActive) {
            
            Boolean sendEmail = false;
            Integer recordCount = database.countQuery(Query);
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();        
            
            EmailTemplate ET = NOB_DM02_EmailTemplate.getEmailTemplateByDeveloperName('PRE_PrefikarMonitoring');
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = :System.Label.OrgWideEmailAddressPrefikar];
            
            recordCount = (recordCount == null)? 0 : recordCount;
            
            System.debug('Query ' + Query);
            System.debug('lstUserIds ' + lstUserIds);
            System.debug('recordCount ' + recordCount);
            System.debug('thresholdOperator ' + thresholdOperator);
            
            if (thresholdOperator == 'Equal' && recordCount == threshold) {
                sendEmail = true;
    
            } else if (thresholdOperator == 'Greater or Equal' && recordCount >= threshold) {
                sendEmail = true;
    
            } else if (thresholdOperator == 'Less or Equal' && recordCount <= threshold) {
                sendEmail = true;
            }
    
    
            if (sendEmail && (lstUserIds != null || cmdtAddresses != null)) {
                System.debug('send email true');
                emailContent = ( emailContent.contains('{numberOfResults}'))? emailContent.replace('{numberOfResults}', String.valueOf(recordCount)) : emailContent;
                
                String emailBody =  ET.Markup;
                emailBody = emailBody.replace('{0}', emailContent);
    
                //Create emails for each recipient ID
                for (String uid : lstUserIds) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    email.setSaveAsActivity(false);
                    email.setTargetObjectId(uid);
                    email.setOrgWideEmailAddressId( owea[0].Id);
                    email.setSubject(emailSubject);
                    email.setHtmlBody(emailBody);
                    emails.add(email);
                }
                
                //Create a single email for addreses, if not null
                if (cmdtAddresses != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    email.setToAddresses(lstAddresses);
                    email.setOrgWideEmailAddressId( owea[0].Id);
                    email.setSubject(emailSubject);
                    email.setHtmlBody(emailBody);
                    emails.add(email);
                }
                
    
                if ( emails.size()>0 ){ 
                    try {
                        System.debug('Sending emails');
    
                        Messaging.sendEmail(emails, false);
                    } catch (EmailException e) {
                        Utils_ManageLogs.NOBCreateLogFromException('NOBTools.sendEmail()', 'PRE_BatchPrefikarMonitoring', e, null);
                    }
                }
            }
        }
    }
}