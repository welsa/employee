/*************************************************************************************
Class Name - NOB_AP66_ZoneInterventionUtility
Created by - hansrajmohiputlall@spoonconsulting.com
Version - 1.0
Created Date - 03-12-2021
Function - email utility for 9311 and batch xxx
#Ticket  - RSIW : 9311

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* HMO           03-12-2021   Initial version
*/
public with sharing class NOB_AP67_EmailDateFinPartenariat {
    public NOB_AP67_EmailDateFinPartenariat() {

    }
 

    @InvocableMethod(label = 'passRecordId' description = '9311')
    public static void getRecordId(List<Account> lstAccs){
        if (lstAccs.size() > 0 && !lstAccs.contains(null)){
            NOB_AP67_EmailDateFinPartenariat.sendEmail(lstAccs);
        }
    }


    public static void sendEmail(List<Account> lstAccs){

        String emailTemplateDevName;
        EmailTemplate template = new EmailTemplate();
        List<Messaging.SendEmailResult> emailResultList;
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
        List<Account> lstAccsToUpdate = new List<Account>();
        String errorMessages = '';
        String errorDML = '';

        try{
            if (system.isBatch()){
                emailTemplateDevName = (String.isNotBlank(System.Label.NOB_DateFinPartenariat_Inactive)) ? System.Label.NOB_DateFinPartenariat_Inactive : '';
            }
            else{
                emailTemplateDevName = (String.isNotBlank(System.Label.NOB_DateFinPartenariat_preAvis)) ? System.Label.NOB_DateFinPartenariat_preAvis : '';
            }

            template = NOB_DM02_EmailTemplate.getEmailTemplateByDeveloperName(emailTemplateDevName);
            Map<Id, Account> mapAcct = getAccwithSC(lstAccs);
            List<String> toAddresses = getUserEmails();

            if (template != null && mapAcct != null){
                for (Id id :mapAcct.keySet()){   

                    if(mapAcct.containsKey(id)){
                        if (!system.isBatch() && !toAddresses.isEmpty()){
                            emailListToSend.add(sendEmail2(template, mapAcct.get(Id), toAddresses));
                        }
    
                        if (System.isBatch()){
                            mapAcct.get(Id).NOB_StatusReason__c = mapAcct.get(Id).NOB_TechRaisondeStatut__c;
                            mapAcct.get(Id).NOB_Statut__c = 'Inactif';
    
                            lstAccsToUpdate.add(mapAcct.get(Id));
                        }
                    }
                }
            }

            if (System.isBatch() && !lstAccsToUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(lstAccsToUpdate, false);
                for (Integer i = 0; i < lstAccsToUpdate.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Account acct = lstAccsToUpdate[i];
                    if (sr.isSuccess() &&  !toAddresses.isEmpty()){
                        emailListToSend.add(sendEmail2(template, acct, toAddresses));
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            errorDML += (acct.Id + ',' + acct.Name + ','+ err.getMessage() + '\n');
                        }
                    }
                }
            }


            if(emailListToSend.size() > 0)
            {
                System.debug('£££ emailz : '+ emailListToSend);
                emailResultList = Messaging.sendEmail(emailListToSend);
            }

        }catch(Exception e){
            errorMessages += 'Error: ' + e.getMessage() + ' Trace String: ' + e.getStackTraceString();
            system.debug('£ error : ' + errorMessages);
        }

        if (system.isBatch() && errorDML.length() > 0){
            sendEmailError(errorDML);
            errorDML = '';
        }
    }

    public static List<String> getUserEmails(){
        List<String> toAddressList = new list<string>();
        List<String> profiles;
        Group pGroupUsers;
        Set<Id> setUsersGroup = new Set<Id>();
        for (Group pg : [SELECT Id FROM Group WHERE Name = 'NOB_dateFinPartenariatRecipients' LIMIT 1]){
            pGroupUsers = new Group();
            pGroupUsers = pg;
        }
        if (pGroupUsers != null){
            for (GroupMember member : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =:pGroupUsers.Id]){
                if (String.valueOf(member.UserOrGroupId).startsWith('005')){
                    setUsersGroup.add(member.UserOrGroupId);
                }
            }
        }

        profiles = (String.isNotBlank(System.Label.NOB_DateFinPartenariatProfiles)) ? System.Label.NOB_DateFinPartenariatProfiles.split(';') : new List<String>();
         for (User u : [SELECT Id, email from User where (profile.Name IN: profiles OR Id IN: setUsersGroup ) AND IsActive = true]){
            toAddressList.add(u.Email);
         }
       // for (User u : [SELECT Id, email from User where Id IN: setUsersGroup AND IsActive = true]){
           // toAddressList.add(u.Email);
       // }

        return toAddressList;
    }


    public static Map<Id, Account> getAccwithSC(List<Account> lstAccs){
        Map<Id, Account> mapAccs = new Map<Id, Account>();
        Set<Id> setIds = (new Map<Id,Account>(lstAccs)).keySet().clone();
        for (Account acc : [Select Id, Name, BillingCity, BillingPostalCode, BillingStreet, BillingCountry, NOB_TechRaisondeStatut__c, NumeroClient__c, NOB_DateFinPartenariat__c , NOB_StatusReason__c, NOB_Statut__c, (SELECT Id, Name from ServiceContracts where Status = 'Active' Order By CreatedDate DESC Limit 1) from Account where Id IN: setIds AND NOB_isPrefikar__c = true]){
            mapAccs.put(acc.Id, acc);
        }
        return mapAccs;
    }

    public static void sendEmailError(String errors){
        String header = 'AccountId, AccountName, Error Message\n';
        header += errors;
        Messaging.EmailFileAttachment csvAttchment = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(header);
        string csvName= 'Error_DateFin_Partenariat.csv';
        csvAttchment.setFileName(csvName);
        csvAttchment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        List<string> toAddresses = new List<String>();
        toAddresses = (String.isNotBlank(System.Label.NOB_DateFinPartenariatRecipients)) ? System.Label.NOB_DateFinPartenariatRecipients.split(',') : new List<String>();

        //toAddresses.add('hansraj.mohiputlall@spoonconsulting.com');

        String subject ='Date de Fin de Partenariat Batch failure';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(System.Label.NOB_DateFinEmailErrBody);
        email.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttchment});

        Messaging.SendEmailResult [] resultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    

    public static Messaging.SingleEmailMessage sendEmail2(EmailTemplate template, Account acc, List<String> toAddressList){
        String htmlBody = template.Markup;

        //HMO -- 24/12/2021
        Map<String, String> mapString;
        String raison = '';
        if (acc.NOB_TechRaisondeStatut__c != null){
            mapString = new Map<String, String>();
            mapString = getPicklistValues(Account.NOB_StatusReason__c);
        }

        if (!mapString.isEmpty() && mapString.containsKey(acc.NOB_TechRaisondeStatut__c)){
            raison = mapString.get(acc.NOB_TechRaisondeStatut__c);
        }


        htmlBody =  htmlBody.replace('{!relatedTo.NOB_StatusReason__c}', String.isNotBlank(raison) ? raison : '');        
        htmlBody =  htmlBody.replace('{!relatedTo.BillingStreet}', String.isNotBlank(acc.BillingStreet)?acc.BillingStreet : '' );
        htmlBody =  htmlBody.replace('{!relatedTo.Name}', String.isNotBlank(acc.Name) ? acc.Name : '');
        htmlBody =  htmlBody.replace('{!relatedTo.BillingPostalCode}', String.isNotBlank(acc.BillingPostalCode) ? acc.BillingPostalCode : '');
        htmlBody =  htmlBody.replace('{!relatedTo.BillingCity}', String.isNotBlank(acc.BillingCity) ? acc.BillingCity : '');
        htmlBody =  htmlBody.replace('{!relatedTo.BillingCountry}', String.isNotBlank(acc.BillingCountry) ? acc.BillingCountry : '');

        htmlBody = htmlBody.replace('{!relatedTo.NumeroClient__c}', String.isNotBlank(acc.NumeroClient__c) ? acc.NumeroClient__c : '');

        if (acc.serviceContracts.size() >0 && !acc.serviceContracts.contains(null)){
            htmlBody =  htmlBody.replace('{lastScName}', acc.serviceContracts[0].Name);
        }else{
            htmlBody =  htmlBody.replace('{lastScName}', 'Pas de contrat actif');
        }

        if (template.DeveloperName == System.Label.NOB_DateFinPartenariat_preAvis){
            if (acc.NOB_DateFinPartenariat__c != null){
                htmlBody =  htmlBody.replace('{!relatedTo.NOB_DateFinPartenariat__c}', getDateFormat(acc.NOB_DateFinPartenariat__c));
            }
            else{
                htmlBody =  htmlBody.replace('{!relatedTo.NOB_DateFinPartenariat__c}', '');
            }
        }
        
        
        Messaging.SingleEmailMessage currentEmail = new Messaging.SingleEmailMessage();
        currentEmail.setToAddresses(toAddressList);
        currentEmail.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);
        currentEmail.setSubject('FIN DE PARTENARIAT');
        currentEmail.setSaveAsActivity(false);
        currentEmail.setHtmlBody(htmlBody);

        return currentEmail;
    }

    public static string getDateFormat(Date dateToFormat){
         string str = dateToFormat.day() + '/' + dateToFormat.month() + '/' + dateToFormat.year();
         return str;
    }


    public static void clearRaisonAccount(Set<Id> setAccsToUpdate){
        List<Account> lstToUpdate = new List<Account>();
        for (Id accId : setAccsToUpdate){
            Account acct = new Account(Id = accId, NOB_StatusReason__c= null, NOB_TechRaisondeStatut__c = null);
            lstToUpdate.add(acct);
        }

        if (lstToUpdate != null && !lstToUpdate.isEmpty()){
            try{
                update lstToUpdate;
            }catch(DmlException e){
                System.debug('DML error : '+ e.getMessage() + 'cause : ' + e.getCause());
            }
        }
    }




    //HMO -- 24-12-2021
    public static Map<String,String> getPicklistValues(Schema.sObjectField field) {
        Map<String,String> item = new Map<String,String>();
        List<Schema.PicklistEntry> entries = field.getDescribe().getPickListValues();
        List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                item.put(entry.getValue(), entry.getLabel());
            }
        }
        return item;
    }
}