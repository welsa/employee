/*************************************************************************************
Class Name - NOB_BatchMyDocs
#Ticket  - RSIW : 5798

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* RLA           30-11-2021   Initial version
* HMO           04/02/2022   RSIW 11528
*************************************************************************************/
public class NOB_BatchMyDocs implements Schedulable, Database.Batchable<SObject>, Database.Stateful {

    //Set<Id> setAcctsIdGlo;

    public NOB_BatchMyDocs(/*Set<Id> setAcctsId*/) {
        /*system.debug('@@ setAcctsId: '+setAcctsId);
        setAcctsIdGlo = new set<Id>();
        if (setAcctsId != null){
            for (Id id: setAcctsId){
                setAcctsIdGlo.add(id);
            }   
        }*/
        
       
        //system.debug('@@ setAcctsIdGlo: '+setAcctsIdGlo);
        
        
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeId = Schema.SObjectType.Nob_MesDocuments__c.getRecordTypeInfosByDeveloperName().get('Attestation').getRecordTypeId();
        String recordTypeIdBS = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BODYSHOP').getRecordTypeId();
        
        String query = '';
        query = 'SELECT Id,ContactEmail__c, (SELECT Id,Name, NOB_DateDebut__c, NOB_DateFin__c,NOB_Status__c,NOB_CompagnieAssurance__c,NOB_Account__c,RecordTypeId,NOB_LastSentEmail__c,NOB_Account__r.OwnerId,Contact__c, Contact__r.email  ';
        query += 'FROM MesDocuments__r ';
        query += 'WHERE RecordTypeId = \''+recordTypeId+'\' ';
        query += ' ORDER BY NOB_LastSentEmail__c ASC NULLS FIRST)';
        query += ' , (select Id, Name, Phone, email from Contacts where NOB_FunctionServices__c includes( \'Dirigeant\') AND NOB_Status__c = \'Actif\' Order by createdDate ASC Limit 1)';
        query += ' FROM Account Where NOB_Statut__c = \'Actif\' AND RecordTypeId = \'' + recordTypeIdBS +'\'   ';
        // AND ID = \'0015E00001TYcntQAD\'
        /*if (setAcctsIdGlo.size() > 0){
            query += 'AND Id IN: setAcctsIdGlo';

        }*/
        system.debug('@@ query: '+query);

        return Database.getQueryLocator(query);
    }

    public void execute (SchedulableContext sc){
        // NOB_Batch_UpdateEngagementServiceContrat batchEngagement = new NOB_Batch_UpdateEngagementServiceContrat(runAllSC, majHistorique);
        // ID batchprocessid = Database.executeBatch(batchEngagement);   
    }

    public void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('## start of execute method NOB_BatchMyDocs');
        System.debug('££££ scope NOB_BatchMyDocs  '+ scope);
        // String recordTypeIdTask = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Nob_TaskDocuments').getRecordTypeId();
        List<Nob_MesDocuments__c> lstSMesDocsToUpdate = new List<Nob_MesDocuments__c>();
        List<Nob_MesDocuments__c> lstSMesDocsWillExpire = new List<Nob_MesDocuments__c>();
        List<Nob_MesDocuments__c> lstSMesDocsExpiredToday = new List<Nob_MesDocuments__c>();
        Map<Id,Task> mapTaksToInsert = new Map<Id,Task>();
        Map<Id, Contact> mapEmailBS = new map<Id,Contact>();
        Date dateFrequencyAfter = getDatesAfter();
        Date dateFrequencyBefore = getDatesBefore();
        set<Id> setExcludeEmails = new set<Id>();

        //HMO - 11528 - 04-02-2022
        Map<Id, List<Task>> mapTaskClose = new Map<Id, List<Task>>();
        Set<Id> setDocsExpired;
        map<Id, Set<Id>> mapDocsReps = new Map<Id, Set<Id>>();
    

        
        for (Account acc: scope){

            Boolean isActive = false;
            //HMO -- 08-02-2022
            setDocsExpired = new Set<Id>();

            if (acc.MesDocuments__r != null && acc.MesDocuments__r.size() > 0){

                Boolean accAttestIsExpired = true;
                Boolean sendEmailNoActiveDoc = false;
                Nob_MesDocuments__c msDocsExpired;


                if (acc.Contacts != null && acc.Contacts.size() > 0){
                    if (String.IsNotBlank(acc.Contacts[0].email)){
                       mapEmailBS.put(acc.Id,acc.Contacts[0]) ;
                    }
                }
                // else if (String.IsNotBlank(acc.ContactEmail__c)){
                //     mapEmailBS.put(acc.Id,acc.ContactEmail__c) ;
                // }


                for (Nob_MesDocuments__c ms : acc.MesDocuments__r){
                    System.debug('££££ ms '+ ms);
                    System.debug('££££ NOB_Status__c '+ ms.NOB_Status__c);
                    System.debug('££££ NOB_LastSentEmail__c '+ ms.NOB_LastSentEmail__c);
                    System.debug('££££ NOB_DateFin__c '+ ms.NOB_DateFin__c);
                    System.debug('££££ dateFrequencyAfter '+ dateFrequencyAfter);
                    System.debug('££££ dateFrequencyBefore '+ dateFrequencyBefore);
                    // Nob_MesDocuments__c msToUpdate = (new Nob_MesDocuments__c (id = ms.Id,name= ms.Name, NOB_LastSentEmail__c = ms.NOB_LastSentEmail__c));


                    //HMO - 08-02-2022
                    /*if (ms.NOB_Status__c == 'Expired'){
                       
                        if (!setDocsExpired.contains(ms.Id)){
                            setDocsExpired.add(ms.Id);
                        }
                    }

                    if (ms.NOB_Status__c == 'Active'){
                        if (!isActive){
                            isActive = true;
                            
                        }
                    }
                    */



                    if (ms.NOB_DateFin__c < Date.Today() &&  ms.NOB_Status__c != 'Expired'){
                        //utility send email expired
                        System.debug('££££ i am expiring today '+ ms.name);
                        ms.NOB_Status__c = 'Expired';
                        ms.NOB_LastSentEmail__c = Date.today();
                        accAttestIsExpired = true;
                        lstSMesDocsExpiredToday.add(ms);
                        lstSMesDocsToUpdate.add(ms);
                        // mapTaksToInsert.put(ms.Id,createTask(new map<String,Object>{'MesDocs' => ms, 'hasExpired' => true, 'RcordType' => recordTypeIdTask}));

                        //HMO - 08-02-2022
                      
                        if (!setDocsExpired.contains(ms.Id)){
                            setDocsExpired.add(ms.Id);
                        }
                       
                    }
                    else if (ms.NOB_DateDebut__c == Date.Today() && ms.NOB_Status__c != 'Active' ){
                        //utility send email expired
                        ms.NOB_Status__c = 'Active';
                        accAttestIsExpired = false;
                        lstSMesDocsToUpdate.add(ms);
                        setExcludeEmails.add(ms.Id);
                       

                        //HMO - 08-02-2022
                        if (!isActive){
                            isActive = true;
                           
                        }

                    }
                    else if (ms.NOB_DateFin__c == dateFrequencyAfter || (ms.NOB_DateFin__c <= dateFrequencyAfter && ms.NOB_Status__c == 'Active' && (ms.NOB_LastSentEmail__c == null || ms.NOB_LastSentEmail__c >= dateFrequencyAfter))){
                        //utility it will expired in 15 days
                        ms.NOB_LastSentEmail__c = Date.today();
                        accAttestIsExpired = false;
                        lstSMesDocsWillExpire.add(ms);
                        lstSMesDocsToUpdate.add(ms);
                        // mapTaksToInsert.put(ms.Id,createTask(new map<String,Object>{'MesDocs' => ms, 'willExpire' => true, 'RcordType' => recordTypeIdTask}));
                        // Task task = createTask(map<String,Object>{'MesDocs' => ms, 'willExpire' => true}));
                        // lstTaksToInsert.add(task);
                        System.debug('££££ i will expire in 15 days '+ ms.name);

                        //HMO - 08-02-2022
                        if (!isActive){
                            isActive = true;
                            
                        }

                    }
                    else if (ms.NOB_DateFin__c > Date.Today()){
                        accAttestIsExpired = false;
                        System.debug('££££ i am active '+ ms.name);

                        //HMO - 08-02-2022
                        if (!isActive){
                            isActive = true;
                            
                        }

                    }
                    else if (ms.NOB_DateFin__c < Date.Today() && (ms.NOB_LastSentEmail__c ==  dateFrequencyBefore)){                       
                        sendEmailNoActiveDoc = true;
                        ms.NOB_LastSentEmail__c = Date.Today();
                        msDocsExpired = ms;
                        
                        System.debug('££££ i have already expired since long '+ ms.name);

                        //HMO - 08-02-2022
                        
                        if (!setDocsExpired.contains(ms.Id)){
                            setDocsExpired.add(ms.Id);
                        }
                        

                    }

                    //HMO - 08-02-2022
                    else if (ms.NOB_Status__c == 'Expired'){
                        
                        if (!setDocsExpired.contains(ms.Id)){
                            setDocsExpired.add(ms.Id);
                        }
                       
                    }

                }
                System.debug('££££ sendEmailNoActiveDoc '+ sendEmailNoActiveDoc);
                System.debug('££££ accAttestIsExpired '+ accAttestIsExpired);

                if (sendEmailNoActiveDoc && accAttestIsExpired){
                     //utility it has expired since some days
                    if (msDocsExpired != null){
                        lstSMesDocsToUpdate.add(msDocsExpired);
                        // mapTaksToInsert.put(msDocsExpired.Id,createTask(new map<String,Object>{'MesDocs' => msDocsExpired, 'hasExpired' => true, 'RcordType' => recordTypeIdTask}));
                        // Task task = createTask(map<String,Object>{'MesDocs' => ms, 'hasExpired' => true}));
                        // lstTaksToInsert.add(task);

                    }                    

                }


                //HMO -- 08-02-2022
                if (setDocsExpired != null && !setDocsExpired.isEmpty() && isActive){
                   
                    mapDocsReps.put(acc.Id, setDocsExpired);
                   
                }
            }
        }

        system.debug('@@ lstSMesDocsToUpdate: '+lstSMesDocsToUpdate);
         List<Messaging.SingleEmailMessage> lstmails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate ETExpired = NOB_DM02_EmailTemplate.getEmailTemplateByDeveloperName('NOB_MailAttestationExpired');
        EmailTemplate ETWillExpire = NOB_DM02_EmailTemplate.getEmailTemplateByDeveloperName('NOB_MailAttestationWillExpire');
        

        for (Nob_MesDocuments__c ms:lstSMesDocsToUpdate){

            // Contact contactEmail = mapEmailBS.containskey(ms.NOB_Account__c) ? mapEmailBS.get(ms.NOB_Account__c) : null;
            // system.debug('@@ contactEmail'+contactEmail);

            if ( ms.Contact__c  != null && ms.NOB_DateFin__c != null && !setExcludeEmails.contains(ms.Id)){
                Boolean hasExpired = checkIfExpired(ms.NOB_DateFin__c);
                EmailTemplate emailTemplateToSend = hasExpired ? ETExpired : ETWillExpire;
                
                Messaging.SingleEmailMessage mailReturned = sendEmail(new map<String,Object>{'MesDocs' => ms, 'contactEmail' => ms.Contact__c , 'EmailTemplate' => emailTemplateToSend});

                //HMO -- 03-03-2022 RSIW 11528
                if ( ms.Contact__r.email != null){
                    lstmails.add(mailReturned);
                   
                }

            } 
            // else if (mapTaksToInsert.containskey(ms.Id)){
            //     mapTaksToInsert.remove(ms.Id);
            // }         

        }

        if (lstmails.size() > 0){
            Messaging.sendEmail(lstmails, true);
            // NOBTools.sendEmail(lstEmailContents);
        }

        if (lstSMesDocsToUpdate.size() > 0){
            update lstSMesDocsToUpdate;
        }
        

        // if (mapTaksToInsert.size() > 0){
        //     insert mapTaksToInsert.values();
        // }
        // System.debug('## mapTaksToInsert'+mapTaksToInsert);
        

        //HMO - RSIW 11598
        if (!mapDocsReps.isEmpty() && !mapDocsReps.containsKey(null)){

            try{
                List<Task> recordsToUpdate = getTasks(mapDocsReps);
               
                if (!recordsToUpdate.isEmpty()){
                   
                    update recordsToUpdate;
                }
            }catch(DmlException dmle){
                system.debug(LoggingLevel.ERROR, 'Error : '+ dmle.getMessage() + 'at' + dmle.getStackTraceString());
            }
        }

    }


    public void finish(Database.BatchableContext BC){
        System.debug('## start of finish method in NOB_BatchMyDocs');
    }

    public static Date getDatesAfter (){

        Integer frequency = Integer.ValueOf(system.label.FrequencyForEmailsMsDocs);
       return Date.Today().addDays(frequency);

    }

    public static Date getDatesBefore (){

        Integer frequency = Integer.ValueOf(system.label.FrequencyForEmailsMsDocs);
        return Date.Today().addDays(frequency*-1);

    }
    public static string getDateFormat(Date dateToFormat){
        //String Str = dateToFormat.format('dd/MM/yyyy'); 
        //string str = dateToFormat.day() + '/' + dateToFormat.month() + '/' + dateToFormat.year();
        //system.debug('@@ Str'+Str);
        
        Date dat = Date.today();
        Datetime dt = dateToFormat;
        String Str = dt.format('dd/MM/yyyy');

         return str;
    }

    // public static Task createTask(map<String,Object> mapInputParams){
    //     Nob_MesDocuments__c ms = mapInputParams.containskey('MesDocs') ? (Nob_MesDocuments__c)mapInputParams.get('MesDocs') : null;
    //     Boolean hasExpired = mapInputParams.containskey('hasExpired') ? true : false;
    //     String recordTypeIdTask = mapInputParams.containskey('RcordType') ? (string)mapInputParams.get('RcordType') : null;

    //     // Integer frequency = Integer.ValueOf(system.label.FrequencyForEmailsMsDocs);
    //     Task tsk = new Task();
    //     if (hasExpired){
    //         system.debug('@@ has expired');
    //         String textSub = system.label.taskSubjecthasExpired;
    //          system.debug('@@ will expired'+textSub);
    //         textSub = textSub.replace('{1}',ms.Name);
    //         system.debug('@@ will expired'+textSub);

    //         if (ms.NOB_LastSentEmail__c != null){
    //             textSub = textSub.replace('{2}',String.ValueOf(ms.NOB_LastSentEmail__c));
    //         }
    //         else{
    //             textSub = textSub.replace('{2}','');
    //         }
    //         system.debug('@@ will expired'+textSub);

            
    //         tsk.Subject = textSub;
    //         tsk.Status = 'Closed';

    //     }
    //     else{
    //         system.debug('@@ will expired');

    //         String textSub = system.label.taskSubjectWillExpire;
    //         system.debug('@@ will expired'+textSub);

    //         textSub = textSub.replace('{1}',ms.Name);
    //         textSub = textSub.replace('{2}',system.label.FrequencyForEmailsMsDocs);
    //         system.debug('@@ will expired'+textSub);

    //         tsk.Subject = textSub;
    //         tsk.Status = 'Open';
    //     }
        
        
    //     tsk.Priority = 'Normal';
    //     tsk.WhatId = ms.NOB_Account__c;
    //     tsk.OwnerId =  ms.NOB_Account__r.OwnerId;
    //     tsk.RecordTypeId  = recordTypeIdTask;

    //     return tsk;
    // }

    public static Boolean checkIfExpired(Date dateTocheck){

        if (dateTocheck > date.today()){
            return false;
        }
        else{
            return true;
        }
    }

    public static DateTime convertTimeZone(Datetime param){
        DateTime startDateTime= NOBTools.convertTimeToOtherTimeZone(param, UserInfo.getTimezone().toString(), Timezone.getTimeZone('Europe/Paris').toString());

        return startDateTime;
    }

    public static  Messaging.SingleEmailMessage  sendEmail(map<String,Object> mapInputParams){

        Nob_MesDocuments__c ms = mapInputParams.containskey('MesDocs') ? (Nob_MesDocuments__c)mapInputParams.get('MesDocs') : null;
        String emailadd = mapInputParams.containskey('Email') ? (String)mapInputParams.get('Email') : null;
        Id contactEmail = mapInputParams.containskey('contactEmail') ? (Id)mapInputParams.get('contactEmail') : null;
        EmailTemplate ET = mapInputParams.containskey('EmailTemplate') ? (EmailTemplate)mapInputParams.get('EmailTemplate') : null;
        Boolean hasExpired = mapInputParams.containskey('hasExpired') ? true : false;
        String subInvite = '';

        List<String> lstEmailAds = new list<String>{emailadd};
        Map<String, String> mapEmailContent = new Map<String, String>();

        
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: system.label.OrgWideAddressDisplayName];

        String htmlBody = ET.Markup;


        system.debug('@@ ms:'+ms);
        system.debug('@@ contactEmail:'+contactEmail);
        system.debug('@@ owea:'+owea);
        
            

        htmlBody=  htmlBody.replace('{!relatedTo.NOB_DateFin__c}', getDateFormat(ms.NOB_DateFin__c));
         String subject = (string) ET.get('Subject');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactEmail);
        //mail.setSenderDisplayName('SAD');
        mail.setOrgWideEmailAddressId(owea[0].Id);
        mail.setSubject(subject);
        mail.setSaveAsActivity(true);
        mail.setHtmlBody(htmlBody);

        //HMO - 23-02-2022
        mail.setWhatId(ms.Id);



        // mapEmailContent.put('TargetObjectId', contactEmail);
        // mapEmailContent.put('OrgWideEmailAddressId', owea[0].Id);
        // mapEmailContent.put('Subject', subject);
        // mapEmailContent.put('SaveAsActivity', 'true');
        // mapEmailContent.put('HtmlBody', htmlBody);



        return mail;
    }

    //HMO - RSIW 11528 : 08-02-2022
    private static List<Task> getTasks(Map<Id, Set<Id>> mapAtts){
      
        List<Task> lstTasksToClose = new List<Task>();

        if (!mapAtts.isEmpty()){

            List<Id> records = new List<Id>();
            for (Set<Id> grouping : mapAtts.values()){
                records.addAll(grouping);
            }
           

            //Subject = 'Echeance will arrive' or 'Echeance reached'
            for(Task task : [select Id, status, subject from Task where AccountId IN: mapAtts.keySet() and TaskSubtype = 'Email' and Status = 'Open' and whatId IN: records]){
                task.status = 'Completed';
                lstTasksToClose.add(task);
            }
        }
        

        return (lstTasksToClose.size() > 0 && !lstTasksToClose.contains(null)) ? lstTasksToClose : new List<Task>();
    }
    
}