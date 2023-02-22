global class AspisBatch_NewBSContactCreation  implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_NewBSContactCreation
-- - Author        : AMI 
-- - Description   : 1st Migration Batch To Run
-- -               : This batch will create associated contacts for selected BS
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 06-SEP-2018  AMI   1.0      Initial version
--------------------------------------------------------------------------------------
*/
    //this set will be used to store newly created contact id 
    public set <id> newlyCreatedContact                                         = new set <id>();

	//dml status list for contact created
    public list <string> statusCreate 											= new list <string>();

    //boolean to detect any issues during batch processing to determine email subject
    public boolean err 															= false;

	global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_NewBSContactCreation - START');

        return Database.getQueryLocator([select id,Name,Locale__c,CCUsername__c,ContactEmail__c,
                                                Communities_Target_Profile__c,ReferenceNumber__c,
        										(select id
        											from Contacts)
	                                        from Account
	                                        where CommunitiesBatchNewBtoMigrate__c = true]);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
    	system.debug('## Start AspisBatch_NewBSContactCreation - execute');

    	//list to hold new permssion set assigned
        list <Contact> contactToInsertList               						= new list <Contact>();

        List <Database.Saveresult> lstResultsConCreate;

        //creating new contact
        for(Account acc : scope){
            //check required fields
            if(string.isBlank(acc.CCUsername__c) ||
               string.isBlank(acc.ContactEmail__c) ||
               string.isBlank(acc.Locale__c) ||
               string.isBlank(acc.Communities_Target_Profile__c) ||
               string.isBlank(acc.ReferenceNumber__c)){
                    err                                                         = true;
                    statusCreate.add(acc.Id + ',,KO,Missing Required Fields.\n');
            }else{
                //all required fields present
                //check if there is no contact first
                if(acc.contacts.isEmpty()){
                    contactToInsertList.add(new Contact(LastName                    = acc.Name,
                                                        Email                       = acc.ContactEmail__c,
                                                        AccountID                   = acc.Id,
                                                        CurrencyIsoCode             = 'EUR'));
                }else{
                    statusCreate.add(acc.Id + ',,KO,This account already has a contact associated.\n');
                    err                                                             = true;
                }
            }//end check on required fields	
        }//end looping in account

        //create contact
        system.debug('## contactToInsertList.size() ' + contactToInsertList.size());
        if(!contactToInsertList.isEmpty()){
            lstResultsConCreate                                                 = Database.insert(contactToInsertList, false);

            //error management
            integer index                                                       = 0;
            string errorMsg                                                     = '';
            string successMsg                                                   = '';
            
            for(Database.SaveResult lRCC : lstResultsConCreate){
                errorMsg                                                        = '';
                successMsg                                                      = '';

                if(!lRCC.isSuccess()){
                    //raise error
                    errorMsg                                                    = contactToInsertList[index].AccountID + ',,KO,' + lRCC.getErrors()[0].getMessage() + '\n';
                    statusCreate.add(errorMsg);
                    err                                                         = true;
                }else{
                    //no error
                    successMsg                                                  = ',' + lRCC.getId() + ',OK,' + '\n';
                    statusCreate.add(successMsg);

                    //get successfully created contact
                    newlyCreatedContact.add(lRCC.getId());
                }

                index++;
            }//end looping in result list
        }//end if !contactToInsertList.isEmpty()

    	system.debug('## End AspisBatch_NewBSContactCreation - execute');
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('>>>Start AspisBatch_NewBSContactCreation - FINISH');

        String emailSubject                                                     = '';
        String batchJobName                                                     = '';
        String csvHeader                                                        = '';

        if(err == true){
             emailSubject                                                       = '*Data RampUp - New Contact Creation';
        }
        else{
             emailSubject                                                       = 'Data RampUp - New Contact Creation';
        }
        
        if(!statusCreate.isEmpty()){
            batchJobName                                                        = 'AspisBatch_NewBSContactCreation';
            csvHeader                                                           = 'Account ID,Contact ID,Status,Error Message';

            AspisBatch_CommUserCreation.csvDetails(batchJobName, 
                                                    emailSubject, 
                                                    csvHeader, 
                                                    'Contact Creation Status', 
                                                    statusCreate,
                                                    '', 
                                                    '', 
                                                    new list <string>(),
                                                    '',
                                                    '',
                                                    new list <string>());
        }else{
            AspisBatch_CommUserCreation.csvDetails(batchJobName, 
                                                    '*Data RampUp - New Contact Creation', 
                                                    csvHeader, 
                                                    'Contact Creation Status', 
                                                    new list <string>{',,KO,No records were processed'},
                                                    '', 
                                                    '', 
                                                    new list <string>(),
                                                    '',
                                                    '',
                                                    new list <string>());
        }

        if(!newlyCreatedContact.isEmpty()){
            Database.executeBatch(new AspisBatch_NewCommunityUserCreation(newlyCreatedContact));
        }

        system.debug('>>>End AspisBatch_NewBSContactCreation - FINISH');
    }
}