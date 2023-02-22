global class AspisBatch_CaseMigration implements Database.Batchable<sObject>  , Database.Stateful{
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_CaseMigration
-- - Author        : LGO 
-- - Description   : 6th Migration Batch To Run
-- -               : This batch will update all Cases submitted by user so that latter 
-- -               : corresponds to the newly created comm user and also update 
-- -               : tech_bs account so that community sharing can be done
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 20-AUG-2018  LGO   1.0     Initial version
--------------------------------------------------------------------------------------
*/
    //dml status list for so update
    public list <string> statusUpdate                                   = new list <string>();

    //boolean to detect any issues during batch processing to determine email subject
    public boolean err                                                  = false;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('>>>>>AspisBatch_CaseMigration - start method <<<<<');

        return Database.getQueryLocator([select Id, SubmittedBy__c 
                                            FROM Case__c 
                                            WHERE CommunitiesCASEToMigrate__c = true
                                            AND CreatedDate > 2018-01-01T00:00:00.000+0000]);
    }

    global void execute(Database.BatchableContext BC, List <Case__c> scope) {
        system.debug('>>>>>AspisBatch_CaseMigration - start execute method <<<<<');

        //set containing all deactivated force.com user id
        set <id> setDeactivatedUserId                                   = new set <id>();

        //map that will be used to check against case that needs to be updated
        //map force.com user id --> account id
        map <id,string> mapUserIdCombiAccIdCommUserID                   = new map <id,string>();

        list <Case__c> caseToUpdateList                                 = new list <Case__c>();

        List <Database.Saveresult> lstResultsCaseUpdate;

        string commUserId                                               = '';

        string commUserAccId                                            = '';

        //get all deactivated force.com user id
        for(Case__c cs : scope){
            setDeactivatedUserId.add(cs.SubmittedBy__c);
        }//end looping in case
        system.debug('## setDeactivatedUserId.size() ' + setDeactivatedUserId.size());

        //check all accounts related to those deactivated force.com user to see if it was migrated
        for(Account acc : [select id,ContactUser__c,ArchivedContactUser__c
                            from Account
                            where ArchivedContactUser__c IN :setDeactivatedUserId
                            and ContactUser__c != null]){
            mapUserIdCombiAccIdCommUserID.put(acc.ArchivedContactUser__c,acc.id + '-' + acc.ContactUser__c);
        }//end looping in account
        system.debug('## mapUserIdCombiAccIdCommUserID.size() ' + mapUserIdCombiAccIdCommUserID.size());

        //update required case
        for(Case__c cs : scope){
            //reinitialse variable
            commUserId                                                  = '';
            commUserAccId                                               = '';

            if(mapUserIdCombiAccIdCommUserID.containsKey(cs.SubmittedBy__c)){
                commUserAccId                                           = (mapUserIdCombiAccIdCommUserID.get(cs.SubmittedBy__c)).split('-')[0];
                commUserId                                              = (mapUserIdCombiAccIdCommUserID.get(cs.SubmittedBy__c)).split('-')[1];
                
                caseToUpdateList.add(new Case__c(id = cs.id,
                                                 SubmittedBy__c = commUserId,
                                                 Tech_BSAccount__c = commUserAccId));
            }
        }//end looping in case
        system.debug('## caseToUpdateList.size() ' + caseToUpdateList.size()); 

        if(!caseToUpdateList.isEmpty()){
            lstResultsCaseUpdate                                          = Database.update(caseToUpdateList, false);

            //error management
            integer index                                                = 0;
            string errorMsg                                              = '';
            string successMsg                                            = '';
            
            for(Database.SaveResult lRUC : lstResultsCaseUpdate){
                errorMsg                                                 = '';
                successMsg                                               = '';

                if(!lRUC.isSuccess()){
                    //raise error
                    errorMsg                                             = caseToUpdateList[index].id + 
                                                                           ',' + 
                                                                           caseToUpdateList[index].SubmittedBy__c + 
                                                                           ',' + 
                                                                           caseToUpdateList[index].Tech_BSAccount__c + 
                                                                           ',KO,' + 
                                                                           lRUC.getErrors()[0].getMessage() + '\n';
                    statusUpdate.add(errorMsg);
                    err                                                  = true;
                }else{
                    //no error
                    successMsg                                           = lRUC.getId() + 
                                                                           ',' + 
                                                                           caseToUpdateList[index].SubmittedBy__c + 
                                                                           ',' + 
                                                                           caseToUpdateList[index].Tech_BSAccount__c + 
                                                                           ',OK,' + '\n';
                    statusUpdate.add(successMsg);
                }

                index++;
            }//end looping in result list
        }//end if !accToUpdateList.isEmpty()
        system.debug('>>>>>AspisBatch_CaseMigration - end execute method <<<<<');
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('>>>>>AspisBatch_CaseMigration - start finish <<<<<');

        if(!statusUpdate.isEmpty()){
            string subject                                              = '';

            if(err){
                subject                                                 = '*Data Integration - Case Migration';
            }else{
                subject                                                 = 'Data Integration - Case Migration';
            }

            AspisBatch_CommUserCreation.csvDetails('AspisBatch_CaseMigration',
                                                   subject,
                                                  'Case, Submitted By, Tech BS Account, Status, Error Message',
                                                  'Case Status',
                                                   statusUpdate,
                                                  '',
                                                  '',
                                                   new list <string>(),
                                                   '',
                                                   '',
                                                   new list <string>()
                                                   );
        }else{
            AspisBatch_CommUserCreation.csvDetails('AspisBatch_CaseMigration',
                                                   '*Data Integration - Case Migration',
                                                  'Case, Submitted By, Tech BS Account, Status, Error Message',
                                                  'Case Status',
                                                   new list <string>{',,,KO,No Case Found For Processing'},
                                                  '',
                                                  '',
                                                   new list <string>(),
                                                   '',
                                                   '',
                                                   new list <string>()
                                                   );
        }
        
        system.debug('>>>>>AspisBatch_CaseMigration - end finish <<<<<');
    }
}