public without sharing class AP50_Send_Email_From_Action_Template {
    public void SendEmail(list<Action__c> lstActionTemplate, Sobject record) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
        list<string> lstMailAlert = new list<String>();
        map<string, EmailTemplate> mapEmailtemp = new map<string, EmailTemplate> ();
        map<string,string> mapActionTempl = new map<string,string> ();
        system.debug('## record = '+record);
        if(lstActionTemplate.size()>0){
            for(Action__c act : lstActionTemplate){ 
                mapActionTempl.put(act.Email_Alert__c, act.Recipient__c);
            }
        }
        if(mapActionTempl.size()>0){
            for(string str: mapActionTempl.keyset()){
                lstMailAlert.add(str);
            }
        }
        list<EmailTemplate> lstEmailTemp = new list<EmailTemplate>();
        lstEmailTemp = [SELECT id, DeveloperName From EmailTemplate WHERE DeveloperName IN : lstMailAlert];
        system.debug('## lstEmailTemp = '+lstEmailTemp);
        if(lstEmailTemp.size()>0){
            for(EmailTemplate emailtemp : lstEmailTemp){
                mapEmailtemp.put(emailtemp.DeveloperName,emailtemp);
            }
        }
        try {
            if(mapEmailtemp.size()>0){
                for(string key : mapEmailtemp.keyset()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    list<string> toAddresses = mapActionTempl.get(key).split(';');
                    mail.setTemplateId(mapEmailtemp.get(key).Id);
                    mail.setTargetObjectId(UserInfo.getUserId());
                    mail.setToAddresses(toAddresses);
                    mail.setSaveAsActivity(false);
                    mail.setwhatId(record.Id);
                    emaillisttosend.add(mail);
                }
                system.debug('mail >>>> '+emaillisttosend);
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(emaillisttosend);
                }
            }
            
        } catch (Exception ex) {
            system.System.debug('##error'+ex.getMessage());
        }
    }
}