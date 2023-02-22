/*
  ----------------------------------------------------------------------
  -- - Name          : AspisBatch_PIEC3DeleteOldOccs 
  -- - Author        : KSM
  -- - Description   : Delete Obsolete Occurences
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------

  ----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class AspisBatch_PIEC3DeleteOldOccs implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {


    static String errorMsg;
    Savepoint sp;
    static Datetime startTime;
    static List<Messaging.SingleEmailMessage> outErrorEmails;

    public AspisBatch_PIEC3DeleteOldOccs(){
    }

    public AspisBatch_PIEC3DeleteOldOccs(Savepoint sv){
        this.sp = sv;
    }

    global void execute(SchedulableContext sc) {
        // Schedule the batch
        Database.executeBatch(new AspisBatch_PIEC3DeleteOldOccs(), 200);  
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('---------------------------------- START AspisBatch_PIEC3DeleteOldOccs - start ----------------------------------');

        errorMsg = ''; 
        startTime = Datetime.now();
    
        String query = 'SELECT Status__c FROM Occurence__c WHERE Status = \'Obselete\'';

        
        system.debug('## query:'+query);
        System.debug('---------------------------------- END AspisBatch_PIEC3DeleteOldOccs - start ----------------------------------'); 

        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List <Occurence__c> scope) {

        System.debug('---------------------------------- START AspisBatch_PIEC3DeleteOldOccs - execute ----------------------------------');


        try{
             Database.delete(scope);
        }
        catch(Exception e){
            errorMsg = 'Error occured during deletion of obselete occurences :  ' +  e.getMessage();
        }

        System.debug('---------------------------------- END AspisBatch_PIEC3DeleteOldOccs - execute ----------------------------------');
        
    }

    global void finish(Database.BatchableContext context) {
        
        System.debug('---------------------------------- START AspisBatch_PIEC3DeleteOldOccs - finish ----------------------------------');
        System.debug('## errorMsg: ' + errorMsg);

        Datetime endTime = Datetime.now();
        Decimal tmpExecTime = endTime.getTime() - startTime.getTime();
        Decimal execTime = tmpExecTime.divide(1000,5);


        Log__c log = new Log__c(); 

        if(String.isNotBlank(errorMsg)){
            Database.rollback(sp);

            log.Status__c = Label.STATUSFAILED;
            log.ErrorDescription__c = errorMsg;

            AsyncApexJob batchJob = [SELECT Id, TotalJobItems, CreatedBy.Email, CreatedBy.Name, ApexClass.Name 
            FROM AsyncApexJob
            WHERE Id =: context.getJobId()];

            List<String> emailAddList = getMailAddresses();
            emailAddList.addAll(new List<String>{'ashwina.seetaram@sc-mauritius.com','welsa.chan@sc-mauritius.com','nprieto@altirc.com'});   

            sendErrorEmail(batchJob, 'AspisBatch_1PricingOccurences Error', errorMsg, emailAddList);

        }
        else{
            log.Status__c = Label.STATUSPASSED;
        }

        log.Name = 'Batch 3 Pricing';  
        log.Class__c = 'AspisBatch_PIEC3DeleteOldOccs';
        log.sObject__c =  'Occurence__c';
        log.DateLog__c = System.now();
        log.ExecutionTime__c = execTime; 
        //log.ExecutionTimePerStep__c = executionTimeLog;
        Database.insert(log);
    }

    
    public List<String> getMailAddresses()
    {
        List<String> mailList       = new List<String>();
        List<String> mailAddresses  = new List<String>(); 

        for (GroupMember gm : [ SELECT UserOrGroupId
                                FROM    GroupMember 
                                WHERE   Group.DeveloperName = 'SystemAdmins']) 
        {
            mailList.add(gm.UserOrGroupId);
        }
    
        if(mailList.size() > 0)
        {
            List<User> userList = [ SELECT  Email 
                                    FROM    User
                                    WHERE   Id IN : mailList];
            for(User usr : userList) 
            {
                mailAddresses.add(usr.Email);
            }
        }       

        return mailAddresses;
    }

    public static void sendErrorEmail(AsyncApexJob a, String subject, String errorMessage, List<String> emailAddressList){
        String emailSubject = 'ASPIS - ' + subject;
        String emailBody = 'Hello, <br/><br/> The batch ' + a.ApexClass.Name + ' launched by ' + a.CreatedBy.Name + ' has treated ' + a.TotalJobItems + ' chunk(s) in the Organisation ' + UserInfo.getOrganizationId()
                         + '<br/><br/> ' + errorMessage + '<br/>Regards, <br/> ASPIS Back Office Team';
                        
        outErrorEmails  = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage l_objMail  = new Messaging.SingleEmailMessage();

        l_objMail.setToAddresses(emailAddressList);
        l_objMail.setSubject(emailSubject);
        
        l_objMail.setHtmlBody(emailBody);
        outErrorEmails.add(l_objMail);
        
        if (outErrorEmails.size() > 0) {
            Messaging.sendEmail(outErrorEmails);
        }
    }

}