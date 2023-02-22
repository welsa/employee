public with sharing class NOB_ActivationDateReparateurs_TEMP implements Schedulable, Database.Batchable<sObject>{
    public NOB_ActivationDateReparateurs_TEMP() {}

    public Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeId = Schema.SObjectType.ServiceContract.getRecordTypeInfosByDeveloperName()
        .get('NOB_BodyshopContract').getRecordTypeId();

        string query = '';
        query += 'SELECT Id, Name, NOB_DateDebutPartenariat__c,NOB_TECH_FirstSCDateFilled__c ,  (SELECT Id, ActivationDate FROM ServiceContracts WHERE RecordTypeId = \''+recordTypeId+'\' AND ActivationDate != NULL ORDER BY ActivationDate ASC LIMIT 1)';
        query += 'FROM Account WHERE NOB_isPrefikar__c = TRUE AND NOB_Statut__c = \'Actif\'';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        if (!scope.isEmpty()){
            List<Account> lstAccount = new List<Account>();
            String errorDML = '';
            for (Account acc : scope){
                system.debug('£ scope ' + scope);
                if (acc.serviceContracts.size() > 0 && acc.serviceContracts[0].ActivationDate != null){
                    
                    /*if (acc.NOB_DateDebutPartenariat__c == null || acc.NOB_TECH_FirstSCDateFilled__c == null){*/
                        Datetime dtAc = acc.serviceContracts[0].ActivationDate;
                        Date activation = date.newinstance(dtAc.year(), dtAc.month(), dtAc.day());
                        Account acct = new Account(Id = acc.Id, NOB_DateDebutPartenariat__c = activation, NOB_TECH_FirstSCDateFilled__c = true);
                        lstAccount.add(acct);
                    /*}*/
                }
            }

            if (!lstAccount.isEmpty() && !lstAccount.contains(null)){
                Database.SaveResult[] srList = Database.update(lstAccount, true);
                for (Integer i = 0; i < lstAccount.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    Account acct = lstAccount[i];
                    if (!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            errorDML += (acct.Id + ',' + acct.Name + ','+ err.getMessage() + '\n');
                        }
                    }
                }
            }

            if (errorDML.length() > 0){
                sendEmailError(errorDML);
                errorDML = '';
            }
        }
    }

    public static void sendEmailError(String errors){
        String header = 'AccountId, AccountName, Error Message\n';
        header += errors;
        Messaging.EmailFileAttachment csvAttchment = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(header);
        string csvName= 'Error_DateDebut_Partenariat_DataLoading.csv';
        csvAttchment.setFileName(csvName);
        csvAttchment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        List<string> toAddresses ;
        toAddresses = (String.isNotBlank(System.Label.NOB_DateFinPartenariatRecipients)) ? System.Label.NOB_DateFinPartenariatRecipients.split(',') : new List<String>();
        String subject ='Date de Debut de Partenariat Batch Dataloading failure';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('The Batch Date de debut de Partenariat updating accounts to failed.');
        email.setOrgWideEmailAddressId(Label.OrgWideEmailAddressId);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttchment});

        Messaging.SendEmailResult [] resultList = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

    public void execute(System.SchedulableContext sm){}

    public void finish(Database.BatchableContext BC){}
}