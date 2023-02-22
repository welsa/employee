global class AspisBatch_NewCommunityUserCreation  implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_NewCommunityUserCreation
-- - Author        : AMI 
-- - Description   : 2nd Migration Batch To Run
-- -               : This batch will create all community users + assign 
-- -			   : necessary permission set
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 12-SEP-2018  AMI   1.0      Initial version
-- 21-AUG-2020  WCH   1.1      C-003838 - Nob - Migrate Billing information to new fields
-- 04-FEB-2021  WCH   1.2      C-004177: batch AspisBatch_NewBSContactCreation error
--------------------------------------------------------------------------------------
*/	
	//this set will be used to store newly created contact id 
    public set <id> newlyCreatedContact                                         = new set <id>();	

    //dml status list for user create
    public list <string> statusCreate                                   		= new list <string>();

    //dml status list for permission set create
    public list <string> statusPermSetCreate                            		= new list <string>();

    //community painting permission set id
    public string communityPermissionSet                                		= '';

    //boolean to detect any issues during batch processing to determine email subject
    public boolean err                                                  		= false;

    //map containing corresponding LocaleSidKey based on locale
    public map <string,string> mapLocaldLocaleSidKey;

    //map containing corresponding TimeZoneSidKey based on locale
    public map <string,string> mapLocaleTimeZoneSidKey;

    //map containing corresponding LanguageLocaleKey based on locale
    public map <string,string> mapLocaleLanguageLocaleKey;

    //this map will contain all successfullyCreatedUsers (to be used to assign permission set and pass as param in next batch)
    public map <id,id> mapConIdCommUserId										= new map <id,id>();
	
	global AspisBatch_NewCommunityUserCreation(set <id> newlyCreatedContact) {
		system.debug('## Start AspisBatch_NewCommunityUserCreation Constructor');

		//assign param from previous batch
		this.newlyCreatedContact 												= newlyCreatedContact;

		//build communityPermissionSet
		communityPermissionSet                                          		= system.label.PaintingPermissionSetId.split('-')[1];

		//build mapLocaldLocaleSidKey,mapLocaleTimeZoneSidKey and mapLocaleLanguageLocaleKey
		mapLocaldLocaleSidKey 													= new map <string,string>{'dutchbelgium' => 'nl_BE',
																											'frenchbelgium' => 'fr_BE',
																											'french' => 'fr_FR',
																											'german' => 'de_DE',
																											'spanish' => 'es_ES'};

		mapLocaleTimeZoneSidKey 												= new map <string,string>{'dutchbelgium' => 'Europe/Brussels',
																											'frenchbelgium' => 'Europe/Brussels',
																											'french' => 'Europe/Paris',
																											'german' => 'Europe/Berlin',
																											'spanish' => 'Europe/Paris'};

		mapLocaleLanguageLocaleKey 												= new map <string,string>{'dutchbelgium' => 'nl_BE',
																											'frenchbelgium' => 'fr_BE',
																											'french' => 'fr',
																											'german' => 'de',
																											'spanish' => 'es'};

		system.debug('## End AspisBatch_NewCommunityUserCreation Constructor');
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('## Start AspisBatch_NewCommunityUserCreation - START');
        //WCH 21/08/2020 C-003838
		return Database.getQueryLocator([select id,Account.Locale__c,Account.Permission_Sets__c,Account.CCUsername__c,
												Account.ContactEmail__c,Account.Communities_Target_Profile__c,
												Account.ReferenceNumber__c,Account.BillingStreet__c,Account.BillingCity__c,
												Account.BillingState__c,Account.BillingPostalCode__c,Account.BillingCountry__c,
												Account.BillingAddress__c,Account.Name,Account.Phone,Account.Fax
											from Contact
											where id IN :newlyCreatedContact]);
	}

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		system.debug('## Start AspisBatch_NewCommunityUserCreation - execute');

		//list to hold all community users to be created
        list <User> userToInsertList                                     		= new list <User>();

        //list to hold new permssion set assigned
        list <PermissionSetAssignment> permSetToInsertList               		= new list <PermissionSetAssignment>();

        //this map will hold the corressponding contact id and all permission set to assign
        map <string,list <string>> mapConIdListPermId                           = new map <string, list <string>>();

        List <Database.Saveresult> lstResultsUserCreate;
        List <Database.Saveresult> lstResultsPermSetCreate;
        List<AspisBatchUserCreation__mdt> getASPISBatchUserCreationConfig = [select id,userActive__c from AspisBatchUserCreation__mdt where DeveloperName='AspisBatch_NewCommunityUserCreation'];

        //looping in scope to create related community user
        for(Contact con : scope){
    		//all required field present
    		//community user creation
    		User tempUser 													= new User();
    		
    		tempUser.isActive                 								= (getASPISBatchUserCreationConfig.size()>0 ? getASPISBatchUserCreationConfig[0].userActive__c:false);
            tempUser.LastName                 								= con.Account.Name;
            tempUser.ContactId                								= con.id;
            tempUser.ProfileId                								= (string.valueOf(con.Account.Communities_Target_Profile__c)).split(';')[1];
            tempUser.Username                 								= con.Account.CCUsername__c;
            tempUser.Email                    								= con.Account.ContactEmail__c;
            tempUser.Alias                    								= con.Account.Name.trim().left(3) + con.Account.Name.trim().right(2);
            tempUser.Phone                                                  = con.Account.Phone;
            tempUser.Fax                                                    = con.Account.Fax;

            tempUser.TimeZoneSidKey           								= mapLocaleTimeZoneSidKey.containsKey(con.Account.Locale__c.toLowerCase()) ? 
            																mapLocaleTimeZoneSidKey.get(con.Account.Locale__c.toLowerCase()) : 'Europe/Paris';

            tempUser.LocaleSidKey             								= mapLocaldLocaleSidKey.containsKey(con.Account.Locale__c.toLowerCase()) ? 
            																mapLocaldLocaleSidKey.get(con.Account.Locale__c.toLowerCase()) : 'fr_FR';

            tempUser.LanguageLocaleKey       								= mapLocaleLanguageLocaleKey.containsKey(con.Account.Locale__c.toLowerCase()) ? 
            																mapLocaleLanguageLocaleKey.get(con.Account.Locale__c.toLowerCase()) : 'fr';
            
            tempUser.EmailEncodingKey         								= 'ISO-8859-1';
            tempUser.CurrencyIsoCode 										= 'EUR';
            tempUser.CommunityNickname        								= con.Account.Name.trim().left(3) + con.Account.Name.trim().right(2)+String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            tempUser.BodyShopID__c            								= con.Account.ReferenceNumber__c;
            tempUser.isaspis__c             								= true;

            //WCH 21/08/2020 C-003838
            if(con.Account.BillingAddress__c != null){
            	tempUser.Street                   							= string.isNotBlank(con.Account.BillingStreet__c) ? con.Account.BillingStreet__c : '';
                tempUser.City                     							= string.isNotBlank(con.Account.BillingCity__c) ? con.Account.BillingCity__c : '';
                tempUser.State                    							= string.isNotBlank(con.Account.BillingState__c) ? con.Account.BillingState__c : '';
                tempUser.PostalCode               							= string.isNotBlank(con.Account.BillingPostalCode__c) ? con.Account.BillingPostalCode__c : '';
                tempUser.Country                  							= string.isNotBlank(con.Account.BillingCountry__c) ? con.Account.BillingCountry__c : '';
            }

            //add to updatev list
    		userToInsertList.add(tempUser);

    		//permission set
    		if(con.Account.Permission_Sets__c != null){
                list <string> listPermId                                    = con.Account.Permission_Sets__c.split(';');
                mapConIdListPermId.put(con.id,new list <string>(listPermId));
    		}
        }//end looping in contact 
        system.debug('## userToInsertList.size() ' + userToInsertList.size());
        system.debug('## mapConIdListPermId.size() ' + mapConIdListPermId.size());

        //create community users
        if(!userToInsertList.isEmpty()){ 
            lstResultsUserCreate                                         		= Database.insert(userToInsertList, false);

            //error management
            integer index                                                		= 0;
            string errorMsg                                              		= '';
            string successMsg                                            		= '';
            
            for(Database.SaveResult lRUC : lstResultsUserCreate){
                errorMsg                                                 		= '';
                successMsg                                               		= '';

                if(!lRUC.isSuccess()){
                    //raise error
                    errorMsg                                             		=  userToInsertList[index].ContactId + ',KO,' + lRUC.getErrors()[0].getMessage() + '\n';
                    statusCreate.add(errorMsg);
                    err                                                  		= true;
                }else{
                    //no error
                    successMsg                                           		=  lRUC.getId() + ',OK,' + '\n';
                    statusCreate.add(successMsg);
                    mapConIdCommUserId.put(userToInsertList[index].ContactId,lRUC.getId());
                }

                index++;
            }//end looping in result list

            //assign required permission set
            system.debug('## statusCreate.size() ' + statusCreate);
            system.debug('## mapConIdCommUserId.size() ' + mapConIdCommUserId.size());
            if(mapConIdCommUserId.size() > 0){
            	for(id conId : mapConIdCommUserId.keySet()){
                    if(mapConIdListPermId.containsKey(conId)){
                        for(string permid : mapConIdListPermId.get(conId)){
                            permSetToInsertList.add(
                                new PermissionSetAssignment(AssigneeId          = mapConIdCommUserId.get(conId),
                                                            PermissionSetId     = permid));
                        }
                    }
            	}
            }//end if mapConIdCommUserId.size()

            //update permission set assignment
            system.debug('## permSetToInsertList.size() ' + permSetToInsertList.size());
            if(!permSetToInsertList.isEmpty()){
                lstResultsPermSetCreate                                 		= Database.insert(permSetToInsertList, false);

                //error management
                integer indexP                                          		= 0;
                string errorMsgP                                        		= '';
                string successMsgP                                      		= '';
                
                for(Database.SaveResult lRPC : lstResultsPermSetCreate){
                    errorMsgP                                           		= '';
                    successMsgP                                          		= '';

                    if(!lRPC.isSuccess()){
                        //raise error
                        errorMsgP                                       		= permSetToInsertList[indexP].AssigneeId + ',KO,' + lRPC.getErrors()[0].getMessage() + '\n';
                        statusPermSetCreate.add(errorMsgP);
                        err                                             		= true;
                    }else{
                        //no error
                        successMsgP                                      		= permSetToInsertList[indexP].AssigneeId + ',OK,' + '\n';
                        statusPermSetCreate.add(successMsgP);
                    }

                    indexP++;
                }//end looping in result list
            }//end if !permSetToInsertList.isEmpty()
        }//end if !userToInsertList.isEmpty()

		system.debug('## End AspisBatch_NewCommunityUserCreation - execute');
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('## Start AspisBatch_NewCommunityUserCreation - finish');

		if(!statusCreate.isEmpty() || !statusPermSetCreate.isEmpty()){
            string subject                                              		= '';

            if(err){
                subject                                                 		= '*Data RampUp - Community User Creation';
            }else{
                subject                                                 		= 'Data RampUp - Community User Creation';
            }

            AspisBatch_CommUserCreation.csvDetails('AspisBatch_NewCommunityUserCreation',
								                       subject,
								                      'Created User, Status , Error Message',
								                      'Created Users Status',
								                       statusCreate,
								                      'Users Id, Status, Error Message',
								                      'PermissionSet Assignment Status',
								                       statusPermSetCreate,
								                       '',
								                       '',
								                       new list <String>()
								                       );
        }//end if !statusCreate.isEmpty() || !statusPermSetCreate.isEmpty()
        else{
            AspisBatch_CommUserCreation.csvDetails('AspisBatch_NewCommunityUserCreation',
                                                    '*Data RampUp - Community User Creation', 
                                                    'Created User, Status , Error Message',
                                                    'Created Users Status',
                                                    new list <string>{',KO,No records were processed'},
                                                    '', 
                                                    '', 
                                                    new list <string>(),
                                                    '',
                                                    '',
                                                    new list <string>());
        }

        //call next batch
        if(mapConIdCommUserId.size() > 0){
            Database.executeBatch(new AspisBatch_NewBSAccountUpdate(mapConIdCommUserId));
        }

		system.debug('## End AspisBatch_NewCommunityUserCreation - finish');
	}
}