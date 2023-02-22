global class AspisBatch_SOChatterMigration implements Database.Batchable<sObject>  , Database.Stateful{
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_SOChatterMigration
-- - Author        : LGO 
-- - Description   : 7th Migration Batch To Run
-- -               : This batch will update all chatter feeds on so that
-- -               : latter becomes visible to portal users 
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 17-AUG-2018  LGO   1.0     Initial version
--------------------------------------------------------------------------------------
*/
    //boolean to detect any issues during batch processing to determine email subject
    public boolean err                                                  = false;

    //integr to count success and failure
    public Integer numberSuccess                                        = 0;
    public Integer numberFail                                           = 0;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('>>>>>AspisBatch_SOChatterMigration - start method <<<<<');

		return Database.getQueryLocator([select id,Body,Visibility 
                                            from FeedItem 
                                            where ParentId IN (select id 
                                                                from PrerequisiteOrder__c 
                                                                where BodyShop__r.ContactUser__c != NULL 
                                                                AND BodyShop__r.ArchivedContactUser__c != NULL 
                                                                AND BodyShop__r.Communities_Batch_1_Chatter_to_Migrate__c=true) 
                                            and Visibility = 'InternalUsers']);
	}

   	global void execute(Database.BatchableContext BC, List<FeedItem> scope) {
		system.debug('>>>>>AspisBatch_SOChatterMigration - start execute method <<<<<');

		list <FeedItem> feedToUpdateList                                 = new list <FeedItem>();

        List <Database.Saveresult> lstResultsFeedUpdate;

        //updating chatter feed visibility
        for(FeedItem fd : scope){
            if(fd.body != null){
                feedToUpdateList.add(new FeedItem(id                     = fd.id,
                                                  Visibility             = 'AllUsers'));
            }
        }//end looping in feeed
        system.debug('## feedToUpdateList.size() ' + feedToUpdateList.size());

        if(!feedToUpdateList.isEmpty()){
            lstResultsFeedUpdate                                         = Database.update(feedToUpdateList, false);

            //error management
            for(Database.SaveResult lRUC : lstResultsFeedUpdate){
                if(!lRUC.isSuccess()){
                    //raise error
                    err                                                  = true;
                    numberFail++;
                }else{
                    //no error
                    numberSuccess++;
                }
            }//end looping in result list
        }//end if !feedToUpdateList.isEmpty()

        system.debug('>>>>>AspisBatch_SOChatterMigration - end execute method <<<<<');
	}
	
    global void finish(Database.BatchableContext BC) {
        system.debug('>>>>>AspisBatch_SOChatterMigration - start finish <<<<<');

        if(numberSuccess > 0 || numberFail > 0){
            string subject                                              = '';

            if(err){
                subject                                                 = '*Data Integration - SO Chatter Migration';
            }else{
                subject                                                 = 'Data Integration - SO Chatter Migration';
            }

            csvDetails('AspisBatch_SOChatterMigration',
                        subject,
                        numberSuccess,
                        numberFail,
                        false);
        }else{
            csvDetails('AspisBatch_SOChatterMigration',
                        '*Data Integration - SO Chatter Migration',
                        0,
                        0,
                        true);
        }

        //launch next batch
        Database.executeBatch(new AspisBatch_AssessChatterMigration());

        system.debug('>>>>>AspisBatch_SOChatterMigration - end finish <<<<<');
    }

    public static void csvDetails(string batchName, 
                                   string emailSubject,
                                   Integer numSuccess,
                                   Integer numFailure,
                                   boolean noChatter){
        system.debug('>>>>>AspisBatch_SOChatterMigration - start csvDetails <<<<<');

        string body                                                     = 'Your batch job '+ batchName +' has finished. \n' 
                                                                        + 'Number of Success : '+ numSuccess + '\n'
                                                                        + 'Number of Failure : '+ numFailure + '\n';

        if(noChatter){
            body                                                        = 'Your batch job '+ batchName +' has finished. \n' 
                                                                        + 'No Chatter feeds were found to be processed. \n';
        }

        string subject                                                  = emailSubject;

        
        // Define the email
        Messaging.SingleEmailMessage email                              = new Messaging.SingleEmailMessage(); 

        String[] toAddresses                                            = System.label.BAT01_emailAddress.split(';');

        // Sets the paramaters of the email
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(body);

        // Sends the email
        Messaging.SendEmailResult [] r                                  = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
    
        system.debug('>>>>>AspisBatch_SOChatterMigration - end csvDetails <<<<<');
    }
}