global class AspisBatch_ContactCreation implements Database.Batchable<sObject>, Database.Stateful {

/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_ContactCreation
-- - Author        : CLA 
-- - Description   : 2nd Migration Batch To Run
-- -               : This batch will move Contact User to Archived Contact User for each account
-- -               : and create corresponding community Contact
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 20-AUG-2018  CLA   1.0      Initial version
-- 24-AUG-2018  LGO     2.0     Add error * message
--------------------------------------------------------------------------------------
*/

    global List<String> lstResultsContactInsert = new List<String>();
    global List<String> lstResultsAccountUpdate = new List<String>();
    global map<String, String> mapUserIdToContactId = new map<String, String>();
    global Boolean err;

    global Set<String> setAccountId = new Set<String>();

    global AspisBatch_ContactCreation(Set<String> setAccId) {
        this.setAccountId = setAccId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('>>> AspisBatch_ContactCreation - START');

        return Database.getQueryLocator([SELECT id, ContactUser__c, ArchivedContactUser__c, ContactUser__r.FirstName, 
                                                    ContactUser__r.LastName, ContactUser__r.Email 
                                            FROM Account 
                                            WHERE id IN :setAccountId ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('>>> AspisBatch_ContactCreation - EXECUTE');

        map<String, String> mapAccIdToUserId = new map<String, String>();
        map<String, String> mapAccIdToContactId = new map<String, String>();

        List<Contact> lstContactToCreate = new List<Contact>();
        List<Account> lstAccToUpdate = new List<Account>();

        for(Account acc: scope){
            lstContactToCreate.add(new Contact(FirstName = acc.ContactUser__r.FirstName,
                                                LastName = acc.ContactUser__r.LastName,
                                                Email = acc.ContactUser__r.Email,
                                                AccountID = acc.Id));

            mapAccIdToUserId.put(acc.Id, acc.ContactUser__c);

            acc.ArchivedContactUser__c = acc.ContactUser__c;
            acc.ContactUser__c = null;
            lstAccToUpdate.add(acc);
        }

        system.debug('## lstAccToUpdate.size() ' + lstAccToUpdate.size());
        if(lstAccToUpdate.size() > 0){
            List<Database.Saveresult> lstUpdateResults = Database.update(lstAccToUpdate, false);

            for(Integer i=0; i<lstUpdateResults.size(); i++){
                Database.SaveResult sr = lstUpdateResults[i];
                if (!sr.isSuccess()) {
                    Database.Error error = sr.getErrors().get(0);
                    String errorMsg = error.getMessage();
                    lstResultsAccountUpdate.add(sr.getId() + ',,KO,'+errorMsg+'\n');
                    err= true;
                }
                else{
                    lstResultsAccountUpdate.add(sr.getId() + ',' + lstAccToUpdate[i].ArchivedContactUser__c + ',OK,,\n');
                }
            }
        }

        system.debug('## lstContactToCreate.size() ' + lstContactToCreate.size());
        if(lstContactToCreate.size() > 0){
            List<Database.Saveresult> lstResults = Database.insert(lstContactToCreate, false);

            for(Integer i=0; i<lstResults.size(); i++){
                Database.SaveResult sr = lstResults[i];
                if (!sr.isSuccess()) {
                    Database.Error error = sr.getErrors().get(0);
                    String errorMsg = error.getMessage();
                    lstResultsContactInsert.add(lstContactToCreate[i].AccountId + ',,KO,'+errorMsg+'\n');
                    err= true;
                }
                else{
                    mapAccIdToContactId.put(lstContactToCreate[i].AccountId, sr.getId());
                    lstResultsContactInsert.add(','+sr.getId()+',OK,\n');
                }
            }

            system.debug('## mapAccIdToContactId.size() ' + mapAccIdToContactId.size());
            if(!mapAccIdToContactId.isEmpty()){
                for(String key : mapAccIdToContactId.keySet()){
                    mapUserIdToContactId.put(mapAccIdToUserId.get(key), mapAccIdToContactId.get(key));
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('>>> AspisBatch_ContactCreation - FINISH');
        String emailSubject = '';
        String batchJobName = '';
        String csvHeader1 = '';
        String csvHeader2 = '';

        if(err==true){
             emailSubject = '*Data Integration - Archived User Update and Contact Creation';
        }
        else{
             emailSubject = 'Data Integration - Archived User Update and Contact Creation';
        }
        
        if(lstResultsContactInsert.size() > 0 || lstResultsAccountUpdate.size() > 0){
            batchJobName = 'AspisBatch_ContactCreation';
            csvHeader1 = 'Account ID,Archived Contact User,Status,Error Message';
            csvHeader2 = 'Account ID,Contact ID,Status,Error Message';

            AspisBatch_CommUserCreation.csvDetails(batchJobName, 
                                                    emailSubject, 
                                                    csvHeader1, 
                                                    'Archived Contact User Update', 
                                                    lstResultsAccountUpdate,
                                                    csvHeader2, 
                                                    'Contact Creation Status', 
                                                    lstResultsContactInsert,
                                                    '',
                                                    '',
                                                    new list <string>());

            if(mapUserIdToContactId.size() > 0){
                Database.executeBatch(new AspisBatch_CommUserCreation(mapUserIdToContactId));
            }
        }
    }
}