global class ASPISBatch_DisableFeedNotification implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : ASPISBatch_DisableFeedNotification
-- - Author        : AMI 
-- - Description   : This batch will disable all R4 users std chatter email notification
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 31-JAN-2019  AMI   1.0      Initial version
-- 18-APR-2019  WCH   1.1      Correction of apex class because test class failing
--------------------------------------------------------------------------------------
*/
	//store country code info mapping
	map <string,CountryCodeInformationsMapping__c> allConfigCountryCodeInfo = new map <string,CountryCodeInformationsMapping__c>();

	//dml status list for member update
  public list <string> statusUpdate                                   	  = new list <string>();

  //boolean to detect any issues during batch processing to determine email subject
  public boolean err                                                  	  = false;
	
	global ASPISBatch_DisableFeedNotification() {
		system.debug('## Start ASPISBatch_DisableFeedNotification');

		//get country code info mapping
		allConfigCountryCodeInfo 											= CountryCodeInformationsMapping__c.getAll();

		system.debug('## End ASPISBatch_DisableFeedNotification');
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('## ASPISBatch_DisableFeedNotification - START');
        //WCH 18/04/2019 Correction of apex class because test class failing
        String query = 'SELECT Id,MemberId,Member.Profile.Name,Member.CountryCode,NetworkId,Member.Name FROM NetworkMember WHERE (NOT Network.UrlPathPrefix Like \'r3\') AND PreferencesDisableAllFeedsEmail = false AND Member.CountryCode != null'+(Test.isRunningTest()?' order by createddate desc limit 200':'');
        return Database.getQueryLocator(query);
	}

   global void execute(Database.BatchableContext BC, List<NetworkMember> nwMember) {
		system.debug('## Start ASPISBatch_DisableFeedNotification Execute');

		//network member update list
		List <NetworkMember> memberToUpdate 								= new List<NetworkMember>();

		//check selected user in cs to verify if chatter feed is enabled
		for(NetworkMember ntWork : nwMember){
			if(	allConfigCountryCodeInfo.containsKey(ntWork.Member.CountryCode.toUpperCase()) &&
				allConfigCountryCodeInfo.get(ntWork.Member.CountryCode.toUpperCase()).EnableChatterFeed__c){
					memberToUpdate.add(new NetworkMember(id = ntWork.Id,
														 PreferencesDisableAllFeedsEmail = true));
			}
		}//end looping in network

		system.debug('## memberToUpdate ' + memberToUpdate);
		if(!memberToUpdate.isEmpty()){

			List <Database.Saveresult> lstResultsToUpdate 					=  Database.update(memberToUpdate, false);

			//error management
            integer index                                                	= 0;
            string errorMsg                                              	= '';
            string successMsg                                            	= '';
            
            for(Database.SaveResult res : lstResultsToUpdate){
                errorMsg                                                 	= '';
                successMsg                                               	= '';

                if(!res.isSuccess()){
                    //raise error
                    errorMsg                                             	= memberToUpdate[index].id + ',' + ',KO,' + res.getErrors()[0].getMessage() + '\n';
                    statusUpdate.add(errorMsg);
                    err                                                  	= true;
                }else{
                    //no error
                    successMsg                                           	= res.getId() + ',' + ',OK,' + '\n';
                    statusUpdate.add(successMsg);
                }

                index++;
            }//end looping in result list
		}//end if !memberToUpdate.isEmpty()

		system.debug('## End ASPISBatch_DisableFeedNotification Execute');
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('## Start ASPISBatch_DisableFeedNotification Finish');

        if(!statusUpdate.isEmpty()){
            string subject                                              = '';

            if(err){
                subject                                                 = '*Inactivate Chatter Feed Email';
            }else{
                subject                                                 = 'Inactivate Chatter Feed Email';
            }

            AspisBatch_CommUserCreation.csvDetails('ASPISBatch_DisableFeedNotification',
                                                   subject,
                                                  'NetworkMember Id, Status , Error Message',
                                                  'NetworkMember Status',
                                                   statusUpdate,
                                                  '',
                                                  '',
                                                   new list <string>(),
                                                   '',
                                                   '',
                                                   new list <string>()
                                                   );
        }else{
            AspisBatch_CommUserCreation.csvDetails('ASPISBatch_DisableFeedNotification',
                                                   '*Inactivate Chatter Feed Email',
                                                  'NetworkMember Id, Status , Error Message',
                                                  'NetworkMember Status',
                                                   new list <string>{',KO,No Member Found For Processing'},
                                                  '',
                                                  '',
                                                   new list <string>(),
                                                   '',
                                                   '',
                                                   new list <string>()
                                                   );
        }

        system.debug('## End ASPISBatch_DisableFeedNotification Finish');
	}
}