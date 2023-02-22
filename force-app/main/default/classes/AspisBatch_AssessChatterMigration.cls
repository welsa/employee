global class AspisBatch_AssessChatterMigration implements Database.Batchable<sObject>  , Database.Stateful{
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_AssessChatterMigration
-- - Author        : LGO 
-- - Description   : 8th Migration Batch To Run
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
        system.debug('>>>>>AspisBatch_AssessChatterMigration - start method <<<<<');

        return Database.getQueryLocator([select id,Body,Visibility,ParentId 
                                            from FeedItem 
                                            where ParentId IN (select id 
                                                                from Assessment__c 
                                                                where BodyShop__r.ContactUser__c != NULL 
                                                                AND BodyShop__r.ArchivedContactUser__c != NULL 
                                                                AND BodyShop__r.Communities_Batch_1_Chatter_to_Migrate__c=true) 
                                            and Visibility = 'InternalUsers']);
    }

    global void execute(Database.BatchableContext BC, List<FeedItem> scope) {
        system.debug('>>>>>AspisBatch_AssessChatterMigration - start execute method <<<<<');

        list <FeedItem> feedToUpdateList                                 = new list <FeedItem>();
        List <Database.Saveresult> lstResultsFeedUpdate;
        set <id> setAssessmentId                                         = new set <id>();
        map <id,Account> mapAcctoUpdate                                  = new map <id,Account>();

        //updating chatter feed visibility
        for(FeedItem fd : scope){
            if(fd.body != null){
                feedToUpdateList.add(new FeedItem(id                     = fd.id,
                                                  Visibility             = 'AllUsers'));
            }

            setAssessmentId.add(fd.ParentId);
        }//end looping in feeed
        system.debug('## feedToUpdateList.size() ' + feedToUpdateList.size());
        system.debug('## setAssessmentId.size() ' + setAssessmentId.size());

        //updating accounts Communities Batch 1 : Chatter to Migrate
        for(Assessment__c ass : [select id,BodyShop__c
                                   from  Assessment__c
                                   where id IN :setAssessmentId]){
            if(!mapAcctoUpdate.containsKey(ass.BodyShop__c)){
                mapAcctoUpdate.put(ass.BodyShop__c, new Account(id = ass.BodyShop__c,
                                                                Communities_Batch_1_Chatter_to_Migrate__c = false));
            }
        }
        system.debug('## mapAcctoUpdate.size() ' + mapAcctoUpdate.size());

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

            //update accounts
            if(mapAcctoUpdate.size() > 0){
                Database.update(mapAcctoUpdate.values(), false);
            }
        }//end if !feedToUpdateList.isEmpty()

        system.debug('>>>>>AspisBatch_AssessChatterMigration - end execute method <<<<<');
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('>>>>>AspisBatch_AssessChatterMigration - start finish <<<<<');

        if(numberSuccess > 0 || numberFail > 0){
            string subject                                              = '';

            if(err){
                subject                                                 = '*Data Integration - Assessment Chatter Migration';
            }else{
                subject                                                 = 'Data Integration - Assessment Chatter Migration';
            }

            AspisBatch_SOChatterMigration.csvDetails('AspisBatch_AssessChatterMigration',
                                                        subject,
                                                        numberSuccess,
                                                        numberFail,
                                                        false);
        }else{
            AspisBatch_SOChatterMigration.csvDetails('AspisBatch_AssessChatterMigration',
                                                        '*Data Integration - Assessment Chatter Migration',
                                                        0,
                                                        0,
                                                        true);
        }

        system.debug('>>>>>AspisBatch_AssessChatterMigration - end finish <<<<<');
    }
}