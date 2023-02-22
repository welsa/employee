global class AspisBatch_FreezeUsers implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_FreezeUsers
-- - Author        : CLA 
-- - Description   : 1st Migration Batch To Run
-- -               : This batch will freeze all force.com users to be migrated
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 17-AUG-2018  CLA     1.0     Initial version
-- 24-AUG-2018  LGO     2.0     Add error * message
--------------------------------------------------------------------------------------
*/
    global List<String> lstResultMsg = new List<String>();
    global Boolean err = false;

    // Store account id whose Contact User has successfully been frozen
    global Set<String> setAccountId = new Set<String>();

    global AspisBatch_FreezeUsers () {
        System.debug('>>> AspisBatch_FreezeUsers');
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('>>> AspisBatch_FreezeUsers - START');
        return Database.getQueryLocator([SELECT Id,Name,ContactUser__c, 
                                            (SELECT id, Lastname FROM Contacts) 
                                        FROM Account 
                                        WHERE ContactUser__c != null 
                                        AND Communities_Batch_1_BS_to_Migrate__c = true]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('>>> AspisBatch_FreezeUsers - EXECUTE');
        Map<String, String> mapUserToAcc = new Map<String, String>();
        Set<String> setUserIdToFreeze = new Set<String>();
        List<UserLogin> lstUsersToFreeze = new List<UserLogin>();

        for(Account acc: scope){
            if(acc.Contacts.size() == 0){
                setUserIdToFreeze.add(acc.ContactUser__c);
                mapUserToAcc.put(acc.ContactUser__c, acc.Id);
            }
            else{
                lstResultMsg.add(acc.Id +','+ acc.ContactUser__c +',KO,This account already has a contact associated.\n');
                err= true;
            }
        }

        if(setUserIdToFreeze.size() > 0){
            for(UserLogin usr: [SELECT Id, IsFrozen, UserId 
                                FROM UserLogin 
                                WHERE UserId IN :setUserIdToFreeze]){
                usr.isFrozen = true;
                lstUsersToFreeze.add(usr);
            }

            system.debug('## lstUsersToFreeze.size() ' + lstUsersToFreeze.size());
            if(lstUsersToFreeze.size() > 0){
                List<Database.Saveresult> lstResults = Database.update(lstUsersToFreeze, false);

                for(Integer i=0; i<lstResults.size(); i++){
                    Database.SaveResult sr = lstResults[i];            
                    if (!sr.isSuccess()) {
                        Database.Error error = sr.getErrors().get(0);
                        String errorMsg = error.getMessage();
                        lstResultMsg.add(mapUserToAcc.get(lstUsersToFreeze[i].UserId) +','+ lstUsersToFreeze[i].UserId +','+ 'KO' +','+ errorMsg +'\n');
                        err= true;
                    }
                    else{
                        lstResultMsg.add(mapUserToAcc.get(lstUsersToFreeze[i].UserId) +','+ lstUsersToFreeze[i].UserId +','+ 'OK' +',,\n');
                        setAccountId.add(mapUserToAcc.get(lstUsersToFreeze[i].UserId));
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('>>> AspisBatch_FreezeUsers - FINISH');
        
        String emailSubject = '';
        String batchJobName = '';
        String csvHeader = '';

        if(err==true){
             emailSubject = '*Data Integration - Freeze Users';
        }
        else{
            emailSubject = 'Data Integration - Freeze Users';
        }

        system.debug('## lstResultMsg.size() ' + lstResultMsg.size());
        if(lstResultMsg.size()>0){
            batchJobName = 'AspisBatch_FreezeUsers';
           
            csvHeader = 'Account ID,User ID,Status,Error Message';

            AspisBatch_CommUserCreation.csvDetails(batchJobName, 
                                                    emailSubject,
                                                    csvHeader,
                                                    'Freeze Users Status',
                                                    lstResultMsg,
                                                    '',
                                                    '',
                                                    new list<String>(),
                                                    '',
                                                    '',
                                                    new list <string>());

            if(!setAccountId.isEmpty()){
                Database.executeBatch(new AspisBatch_ContactCreation(setAccountId));
            }
        }
    }
}