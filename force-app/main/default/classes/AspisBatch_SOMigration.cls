global class AspisBatch_SOMigration implements Database.Batchable<sObject>  , Database.Stateful{
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_SOMigration
-- - Author        : LGO 
-- - Description   : 5th Migration Batch To Run
-- -               : This batch will update all SO's notification user so that latter 
-- -               : corresponds to the newly created comm user
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 17-AUG-2018  LGO   1.0     Initial version
--------------------------------------------------------------------------------------
*/
    //dml status list for so update
    public list <string> statusUpdate                                   = new list <string>();

    //boolean to detect any issues during batch processing to determine email subject
    public boolean err                                                  = false;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('>>>>>START AspisBatch_SOMigration - start method <<<<<');

        return Database.getQueryLocator([select Id, BodyShopContact__c,BodyShop__r.ContactUser__c 
                                            FROM PrerequisiteOrder__c 
                                            WHERE CommunitiesSOToMigrate__c = true
                                            AND CreatedDate > 2018-01-01T00:00:00.000+0000]);
    }

    global void execute(Database.BatchableContext BC, List<PrerequisiteOrder__c> scope) {
        system.debug('>>>>>AspisBatch_SOMigration - start execute method <<<<<');

        list <PrerequisiteOrder__c> soToUpdateList                      = new list <PrerequisiteOrder__c>();
        List <Database.Saveresult> lstResultsSOUpdate;

        //updating notification user
        for(PrerequisiteOrder__c so : scope){
            so.BodyShopContact__c = so.BodyShop__r.ContactUser__c;

            soToUpdateList.add(so);
        }//end looping in so
        system.debug('## soToUpdateList.size() ' + soToUpdateList.size());

        if(!soToUpdateList.isEmpty()){
            lstResultsSOUpdate                                          = Database.update(soToUpdateList, false);

            //error management
            integer index                                                = 0;
            string errorMsg                                              = '';
            string successMsg                                            = '';
            
            for(Database.SaveResult lRUS : lstResultsSOUpdate){
                errorMsg                                                 = '';
                successMsg                                               = '';

                if(!lRUS.isSuccess()){
                    //raise error
                    errorMsg                                             = soToUpdateList[index].id + ',' + soToUpdateList[index].BodyShopContact__c + ',KO,' + lRUS.getErrors()[0].getMessage() + '\n';
                    statusUpdate.add(errorMsg);
                    err                                                  = true;
                }else{
                    //no error
                    successMsg                                           = lRUS.getId() + ',' + soToUpdateList[index].BodyShopContact__c + ',OK,' + '\n';
                    statusUpdate.add(successMsg);
                }

                index++;
            }//end looping in result list
        }//end if !accToUpdateList.isEmpty()

        system.debug('>>>>>AspisBatch_SOMigration - end execute method <<<<<');
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('>>>>>AspisBatch_SOMigration - start finish <<<<<');

        if(!statusUpdate.isEmpty()){
            string subject                                              = '';

            if(err){
                subject                                                 = '*Data Integration - SalesOrder Migration';
            }else{
                subject                                                 = 'Data Integration - SalesOrder Migration';
            }

            AspisBatch_CommUserCreation.csvDetails('AspisBatch_SOMigration',
                                                   subject,
                                                  'SalesOrder, Notification User, Status , Error Message',
                                                  'SalesOrder Status',
                                                   statusUpdate,
                                                  '',
                                                  '',
                                                   new list <string>(),
                                                   '',
                                                   '',
                                                   new list <string>()
                                                   );
        }else{
            AspisBatch_CommUserCreation.csvDetails('AspisBatch_SOMigration',
                                                   '*Data Integration - SalesOrder Migration',
                                                  'SalesOrder, Notification User, Status , Error Message',
                                                  'SalesOrder Status',
                                                   new list <string>{',,KO,No SalesOrder Found For Processing'},
                                                  '',
                                                  '',
                                                   new list <string>(),
                                                   '',
                                                   '',
                                                   new list <string>()
                                                   );
        }

        //launch next batch
        Database.executeBatch(new AspisBatch_CaseMigration());

        system.debug('>>>>>AspisBatch_SOMigration - end finish <<<<<');
    }
}