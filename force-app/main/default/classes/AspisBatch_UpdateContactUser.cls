global class AspisBatch_UpdateContactUser  implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_UpdateContactUser
-- - Author        : AMI 
-- - Description   : 4th Migration Batch To Run
-- - 			   : This batch will update contact user on BS and uncheck 
-- -			   : Communities Batch 1 : BS to Migrate + check 
-- -               : Communities Batch 1 : Chatter to Migrate
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 22-AUG-2018  AMI   1.0      Initial version
--------------------------------------------------------------------------------------
*/
	//list corresponding as paramaters passes to batch
	public list <string> lstCommunityUsersCreated						= new list <string>();

	//set id containing all acc to be updated based on list of community users creation
	public set <id> setAccidForComUsers									= new set <id>();

	//this map will hold relationship between account and its corresponding com user
	public map <string,string> mapAccidComUser							= new map <string,string>();

    //boolean to detect any issues during batch processing to determine email subject
    public boolean err   												= false; 

    //dml status list for account update
	public list <string> statusUpdate					                = new list <string>();
	
	global AspisBatch_UpdateContactUser(list <string> lstCommunityUsersCreated) {
		system.debug('>>>>> AspisBatch_UpdateContactUser - Constructor Starts <<<<<');

		this.lstCommunityUsersCreated									= lstCommunityUsersCreated;

		//get accid for comm users
		for(User us : [select Id,Contact.AccountId
						from User
						where id IN :lstCommunityUsersCreated]){
			setAccidForComUsers.add(us.Contact.AccountId);

			mapAccidComUser.put(us.Contact.AccountId,us.id);
		}//end looping in users

		system.debug('>>>>> AspisBatch_UpdateContactUser - Constructor Ends <<<<<');	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('>>>>>START AspisBatch_UpdateContactUser - start method <<<<<');

		return Database.getQueryLocator([select id,Communities_Batch_1_BS_to_Migrate__c,
												ContactUser__c,ArchivedContactUser__c 
											from Account 
											where id IN :setAccidForComUsers]);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {
		system.debug('>>>>>AspisBatch_UpdateContactUser - start execute <<<<<');

		list <Account> accToUpdateList									= new list <Account>();

		List <Database.Saveresult> lstResultsAccUpdate;

		//updating contact user,bs to migrate and chatter to migrate
		for(Account acc : scope){
			acc.ContactUser__c 											= mapAccidComUser.get(acc.id);
			acc.Communities_Batch_1_BS_to_Migrate__c 					= false;

			accToUpdateList.add(acc);
		}//end looping in account
		system.debug('## accToUpdateList.size() ' + accToUpdateList.size());

		if(!accToUpdateList.isEmpty()){
			lstResultsAccUpdate 									     = Database.update(accToUpdateList, false);

    		//error management
    		integer index                                                = 0;
    		string errorMsg 										     = '';
    		string successMsg 										     = '';
            
            for(Database.SaveResult lRUA : lstResultsAccUpdate){
            	errorMsg 											     = '';
            	successMsg 											     = '';

                if(!lRUA.isSuccess()){
                	//raise error
                    errorMsg 										     = accToUpdateList[index].id + ',KO,' + lRUA.getErrors()[0].getMessage() + '\n';
                    statusUpdate.add(errorMsg);
                    err                                                  = true;
                }else{
                	//no error
                	successMsg 										     = lRUA.getId() + ',OK,' + '\n';
                	statusUpdate.add(successMsg);
                }

                index++;
            }//end looping in result list
		}//end if !accToUpdateList.isEmpty()

		system.debug('>>>>>AspisBatch_UpdateContactUser - end execute <<<<<');
	}

	global void finish(Database.BatchableContext BC) {
		system.debug('>>>>>AspisBatch_UpdateContactUser - start finish <<<<<');

		if(!statusUpdate.isEmpty()){
			string subject                                              = '';

            if(err){
                subject                                                 = '*Data Integration - Update Contact User';
            }else{
                subject                                                 = 'Data Integration - Update Contact User';
            }

            AspisBatch_CommUserCreation.csvDetails('AspisBatch_UpdateContactUser',
							                       subject,
							                      'Account, Status , Error Message',
							                      'Account Status',
							                       statusUpdate,
							                      '',
							                      '',
							                       new list <string>(),
							                       '',
							                       '',
							                       new list <string>()
							                       );
		}//end if !statusUpdate.isEmpty()

		system.debug('>>>>>AspisBatch_UpdateContactUser - end finish <<<<<');
	}
}