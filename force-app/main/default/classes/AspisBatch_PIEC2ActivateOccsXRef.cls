/*
  ----------------------------------------------------------------------
  -- - Name          : AspisBatch_PIEC2ActivateOccsXRef 
  -- - Author        : KSM
  -- - Description   : Change Occ status, Switch temp fields with active fields on xref, Activate/Deactivate xref
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------

  ----------------------------------------------------------------------
 **********************************************************************
*/ 
global without sharing class AspisBatch_PIEC2ActivateOccsXRef implements schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {


    static String errorMsg;
    set<String> setTechDist;
    Savepoint sp;
    static Datetime startTime;
    static List<Messaging.SingleEmailMessage> outErrorEmails;

    public AspisBatch_PIEC2ActivateOccsXRef(set<String> setTechDist ,Savepoint sv){
        this.setTechDist = setTechDist;
        this.sp = sv;
    }

    public AspisBatch_PIEC2ActivateOccsXRef(){

    }

        
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AspisBatch_PIEC2ActivateOccsXRef(), 200);  
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('---------------------------------- START AspisBatch_PIEC2ActivateOccsXRef - start ----------------------------------');

        startTime = Datetime.now();
        errorMsg = ''; 
    
        String query =  'SELECT Status__c, CrossReference__r.PRE_Price_tmp__c, CrossReference__r.NONPARTNER_PRE_Price_tmp__c, Distributor__r.Tech_Distributor__c, CrossReference__r.ActiveForSubstitution__c' +
                        'CrossReference__r.AdditionalMargin_tmp__c, CrossReference__r.Quality_tmp__c, ' +
                        'CrossReference__r.PRE_Price__c, CrossReference__r.NONPARTNER_PRE_Price__c, ' +
                        'CrossReference__r.AdditionalMargin__c, CrossReference__r.Quality__c ' +
                        'FROM Occurence__c' + 
                        'WHERE Status != \'Obselete\' ';
        
        system.debug('## query:'+query);
        System.debug('---------------------------------- END AspisBatch_PIEC2ActivateOccsXRef - start ----------------------------------'); 

        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List <Occurence__c> scope) {

        System.debug('---------------------------------- START AspisBatch_PIEC2ActivateOccsXRef - execute ----------------------------------');

        Map<Id, List<Occurence__c>> mapXrefOccs = new Map<Id, List<Occurence__c>>(); 
       
        for(Occurence__c occ : scope){
            // 1- Update status of occurences for distributors not excluded
            if(!setTechDist.contains(occ.Distributor__r.Tech_Distributor__c)){
                if(occ.Status__c == 'Active'){
                    occ.Status__c = 'Obselete';
                }
                else if(occ.Status__c == 'New'){
                    occ.Status__c = 'Active';
                }
            }

            //use loop to also build map of xref with their list of occurences
            if(mapXrefOccs.containsKey(occ.CrossReference__c)){
                mapXrefOccs.get(occ.CrossReference__c).add(occ);
            }
            else{
                mapXrefOccs.put(occ.CrossReference__c, new List<Occurence__c>{occ});
            }

            //2 - 
            //Do the switching of field in same loop, assuming it will perform better than
            //querying the xref directly and relooping through the list of xref to perform the update
            occ.CrossReference__r.PRE_Price__c = Occ.CrossReference__r.PRE_Price_tmp__c;
            occ.CrossReference__r.NONPARTNER_PRE_Price__c = occ.CrossReference__r.NONPARTNER_PRE_Price_tmp__c;
            occ.CrossReference__r.AdditionalMargin__c = occ.CrossReference__r.AdditionalMargin_tmp__c;
            occ.CrossReference__r.OEMStandardDiscount__c = occ.CrossReference__r.OEMStandardDiscount_tmp__c;
            occ.CrossReference__r.Quality__c = occ.CrossReference__r.Quality_tmp__c;

        }

        //Build Map of Cross Reference => Consider taking map from previous batch as params, if null, regenerate batch
        //Can perform the update in the loop above which will perform redundante update through the occurences or query xref directly and update

        //3 - Activate / Deactivate Xref
        for(Id xref : mapXrefOccs.keySet()){
            if(mapXrefOccs.get(xref).size() < 1){
                mapXrefOccs.get(xref)[0].CrossReference__r.ActiveForSubstitution__c = false;
            }
            else if(mapXrefOccs.get(xref).size() > 0){
                mapXrefOccs.get(xref)[0].CrossReference__r.ActiveForSubstitution__c = true;
            }
        }

        try{
            Database.update(scope);
        }
        catch(Exception e){
            errorMsg = 'Error occured during update of occurences in batch AspisBatch_PIEC2ActivateOccsXRef : ' +  e.getMessage();
        }

        System.debug('---------------------------------- END AspisBatch_PIEC2ActivateOccsXRef - execute ----------------------------------');
        
    }

    global void finish(Database.BatchableContext context) {
        
        System.debug('---------------------------------- START AspisBatch_PIEC2ActivateOccsXRef - finish ----------------------------------');
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

        log.Name = 'Batch 2 Pricing';  
        log.Class__c = 'AspisBatch_PIEC2ActivateOccsXRef';
        log.sObject__c =  'Occurence__c';
        log.DateLog__c = System.now();
        log.ExecutionTime__c = execTime; 
        //log.ExecutionTimePerStep__c = executionTimeLog;
        Database.insert(log);


        if(String.isBlank(errorMsg)){
            //call next batch & pass savepoint as parameter
            Database.executeBatch(new  AspisBatch_PIEC3DeleteOldOccs(sp) , 200);
        }

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
                        
        outErrorEmails                          = new List<Messaging.SingleEmailMessage>();
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