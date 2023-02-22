global class AspisBatch_NewBSAccountUpdate implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_NewBSAccountUpdate
-- - Author        : AMI 
-- - Description   : 3rd Migration Batch To Run
-- -               : This batch will update all contact user field on account + 
-- -                 create necessary account ref
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 12-SEP-2018  AMI   1.0      Initial version
-- 04-FEB-2021  WCH   1.1      C-004177 - batch AspisBatch_NewBSContactCreation error
-- 27-APR-2021  WCH   1.2      C-004308 - Automate FR Distributor creation
--------------------------------------------------------------------------------------
*/	
	//this map contain all successfullyCreatedUsers alongside their related contacts 
    public map <id,id> mapConIdCommUserId										= new map <id,id>();
    public map <id,id> mapAccIdDistUserId										= new map <id,id>();

    //dml status list for account update
	public list <string> statusUpdate					                		= new list <string>();

	//dml status list for account ref create
	public list <string> statusCreate					                		= new list <string>();

	//boolean to detect any issues during batch processing to determine email subject
    public boolean err   														= false; 

	global AspisBatch_NewBSAccountUpdate(map <id,id> mapConIdCommUserId) {
		system.debug('## Start AspisBatch_NewBSAccountUpdate Constructor');
		if(!mapConIdCommUserId.isEmpty() && (new List<Id>(mapConIdCommUserId.keyset())[0]).getsobjecttype().getdescribe().getname().equals('Account')){
			this.mapAccIdDistUserId = mapConIdCommUserId;
		}else{
			this.mapConIdCommUserId 												= mapConIdCommUserId;
		}

		system.debug('## End AspisBatch_NewBSAccountUpdate Constructor');
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('## Start AspisBatch_NewBSAccountUpdate - START');

		if(mapConIdCommUserId.isEmpty()){
			return Database.getQueryLocator([select id,createDistributorUser__c,ReferenceNumber__c
												from Account
												where id IN :mapAccIdDistUserId.keySet()]);
		}else{
			return Database.getQueryLocator([select id,AccountId,Account.ContactUser__c,Account.CommunitiesBatchNewBtoMigrate__c,
												Account.Assessment_Tool__c,Account.ReferenceNumber__c,
												Account.Communities_Target_Profile__c,Account.Account_Reference_number__c,
												Account.Locale__c
											from Contact
											where id IN :mapConIdCommUserId.keySet()]);
		}
	}

   	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		system.debug('## Start AspisBatch_NewBSAccountUpdate - execute');

		//list to hold all accounts to be updated
		list <Account> accToUpdateList											= new list <Account>();

		//list acc ref to update
		list <AccountRef__c> accRefList											= new list <AccountRef__c>();

		List <Database.Saveresult> lstResultsAccUpdate;
		List <Database.Saveresult> lstResultsAccRefCreate;

		//set correctly inserted account id
		//this will be used to insert account ref for correctly updated acc
		set <id> setAccountId													= new set <id>();

		//temp constannts
		string extRef 															= '';
		string intRef 															= '';
		string systemCalling 													= '';
		string accRefName 														= '';
		boolean sendAccepted													= false;

		if(mapConIdCommUserId.isEmpty()){
			for(SObject currentSObject : scope){
				Account currentAcc = (Account) currentSObject;
				accToUpdateList.add(new Account(id=currentAcc.Id
												,ContactUser__c = mapAccIdDistUserId.get(currentAcc.Id)
												,createDistributorUser__c=false));
			}
		}else{
			//updating all created contact's account
			for(SObject currentSObject : scope){
				Contact con = (Contact) currentSObject;
				//updating corresponding acc
				accToUpdateList.add(new Account(id 									= con.AccountId,
												ContactUser__c 						= mapConIdCommUserId.get(con.id),
												CommunitiesBatchNewBtoMigrate__c 	= false));

				//creating acc ref
				if(con.Account.Communities_Target_Profile__c != null && con.Account.Communities_Target_Profile__c.toLowerCase().contains('order')){
					
					if(con.Account.Assessment_Tool__c != null && string.isNotBlank(con.Account.ReferenceNumber__c)){

						for(string str : con.Account.Assessment_Tool__c.split(';')){

							//reset constants
							extRef 													= '';
							intRef 													= '';
							systemCalling 											= '';
							accRefName 												= '';
							sendAccepted											= false;

							//external ref
							if(string.isNotBlank(con.Account.ReferenceNumber__c) ||    
							string.isNotBlank(con.Account.Account_Reference_number__c)){
								if(str == ASPISConstants.assToolsFRSIDEXA){
									extRef 											= con.Account.Account_Reference_number__c;
								}else{
									extRef 											= con.Account.ReferenceNumber__c.substring(2);
								}
							}

							//internal ref
							intRef 													= con.AccountId;

							//system calling
							systemCalling 											= str;

							//account ref name
							if(str == ASPISConstants.assToolsBEINFORMEX){
								accRefName 											= str + '-' + extRef;
							}else if(str == ASPISConstants.assToolsFRDIVA){
								accRefName 											= str + '-' + extRef;
							}else if(str == ASPISConstants.assToolsFRSIDEXA){
								accRefName 											= str + '-' + extRef;
							}

							//sending accepted
							if(con.Account.Locale__c != null &&
							con.Account.Locale__c.toLowerCase() == ASPISConstants.ACCOUNT_Locale_French.toLowerCase()){
								sendAccepted										= true;
							}

							//add to insert list
							accRefList.add(new AccountRef__c(
								Name 												= accRefName,
								ExternalReference__c 								= extRef,
								InternalReference__c 								= intRef,
								systemCalling__c 									= systemCalling,
								SendingAccepted__c									= sendAccepted));
						}//end looping in ass tools
					}//end if con.Assessment_Tool__c != null
					else{
						//add error msg 
						err                                                         = true;
						statusCreate.add(con.AccountId + ',KO,Missing Required Fields.\n');
					}
				}//end check on type of profile
			}//end looping in scope
		}
		system.debug('## accToUpdateList.size() ' + accToUpdateList.size());
		system.debug('## accRefList.size() ' + accRefList.size());

		//updating account
		if(!accToUpdateList.isEmpty()){
			lstResultsAccUpdate 									     		= Database.update(accToUpdateList, false);

    		//error management
    		integer index                                                		= 0;
    		string errorMsg 										     		= '';
    		string successMsg 										     		= '';
            
            for(Database.SaveResult lRUA : lstResultsAccUpdate){
            	errorMsg 											     		= '';
            	successMsg 											     		= '';

                if(!lRUA.isSuccess()){
                	//raise error
                    errorMsg 										     		= accToUpdateList[index].id + ',KO,' + lRUA.getErrors()[0].getMessage() + '\n';
                    statusUpdate.add(errorMsg);
                    err                                                  		= true;
                }else{
                	//no error
                	successMsg 										     		= lRUA.getId() + ',OK,' + '\n';
                	statusUpdate.add(successMsg);
                	setAccountId.add(lRUA.getId());
                }

                index++;
            }//end looping in result list
		}//end if !accToUpdateList.isEmpty()

		//remove acc ref for accounts that were not updated
		for(integer i = 0;i <accRefList.size();i++){
			AccountRef__c accRefObj = accRefList[i];
			if(!setAccountId.contains(accRefList[i].InternalReference__c)){
				accRefList.remove(i);
			}
		}

		//inserting account ref
		if(!accRefList.isEmpty()){
			lstResultsAccRefCreate 									     		= Database.insert(accRefList, false);

    		//error management
    		integer indexP                                                		= 0;
    		string errorMsgP 										     		= '';
    		string successMsgP 										     		= '';
            
            for(Database.SaveResult lRCA : lstResultsAccRefCreate){
            	errorMsgP 											     		= '';
            	successMsgP 											     	= '';

                if(!lRCA.isSuccess()){
                	//raise error
                    errorMsgP 										     		= accRefList[indexP].InternalReference__c + ',KO,' + lRCA.getErrors()[0].getMessage() + '\n';
                    statusCreate.add(errorMsgP);
                    err                                                  		= true;
                }else{
                	//no error
                	successMsgP 										     	= lRCA.getId() + ',OK,' + '\n';
                	statusCreate.add(successMsgP);
                }

                indexP++;
            }//end looping in result list
		}//end if !accRefList.isEmpty()

		system.debug('## End AspisBatch_NewBSAccountUpdate - execute');
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('## Start AspisBatch_NewBSAccountUpdate - finish');
		if(!mapConIdCommUserId.isEmpty()){
			//WCH 04/02/2021 C-004177
			system.debug('starting call setContactAlphaScaleOrPrefikarCommunityUser');
			Map<Id,User> mapContactIdToUserObj1=new Map<Id,User>();
			for(User cu : [Select Id,ContactId from User where Id in: mapConIdCommUserId.Values()]){
				mapContactIdToUserObj1.put(cu.ContactId,cu);
			}
			UserTriggerHandler.setContactAlphaScaleOrPrefikarCommunityUser(mapContactIdToUserObj1);
			UserTriggerHandler.createManualSharingForCommunityUserNow(mapConIdCommUserId.Values());
		}

		if(!statusUpdate.isEmpty()){
			string subject                                              = '';

            if(err){
                subject                                                 = '*Data RampUp - Update Contact User';
            }else{
                subject                                                 = 'Data RampUp - Update Contact User';
            }

            AspisBatch_CommUserCreation.csvDetails('AspisBatch_NewBSAccountUpdate',
							                       subject,
							                      'Account, Status , Error Message',
							                      'Account Status',
							                       statusUpdate,
							                      'Account, Status , Error Message',
							                      'Account Ref Status',
							                       statusCreate,
							                       '',
							                       '',
							                       new list <string>()
							                       );
		}else{
            AspisBatch_CommUserCreation.csvDetails('AspisBatch_NewBSAccountUpdate',
                                                    '*Data RampUp - Update Contact User', 
                                                    'Account, Status , Error Message',
                                                    'Account Status',
                                                    new list <string>{',KO,No records were processed'},
                                                    '', 
                                                    '', 
                                                    new list <string>(),
                                                    '',
                                                    '',
                                                    new list <string>());
        }

		system.debug('## End AspisBatch_NewBSAccountUpdate - finish');
	}
}