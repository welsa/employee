global class AspisBatch_CommUserCreation  implements Database.Batchable<sObject>, Database.Stateful {
/* 
--------------------------------------------------------------------------------------
-- - Name          : AspisBatch_CommUserCreation
-- - Author        : AMI 
-- - Description   : 3rd Migration Batch To Run
-- - 			   : This batch will inactivate old force.com user and create
-- -			   : corresponding community user
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -------------------------------------------------------
-- 20-AUG-2018  AMI   1.0      Initial version
--------------------------------------------------------------------------------------
*/
	//map force.com user id --> contact id created from batch 2
	public map <String, String> mapUserIdToContactId 				    = new map<String, String>();

	//map force.com user id --> acc info
	public map <String, String> mapUserIdAccInfo 					    = new map<String, String>();

	//dml status list for user update
	public list <string> statusUpdate					                = new list <string>();

	//dml status list for user create
	public list <string> statusCreate						            = new list <string>();

    //dml status list for permission set create
    public list <string> statusPermSetCreate                            = new list <string>();

	//all community users created -> to be used as param for next batch
	public list <string> communityUsersCreated 						    = new list <string>();

    //all force.com users having painting permission set
    //this set reference contact instead of user
    public set <string> setPaintingUsers                                = new set <string>();

    //force.com painting permission set id
    public string forcecomPermissionSetId                               = '';

    //community painting permission set id
    public string communityPermissionSet                                = '';

    //boolean to detect any issues during batch processing to determine email subject
    public boolean err                                                  = false;

	public AspisBatch_CommUserCreation(map<String, String> mapUserIdToContactId) {
		system.debug('## Start AspisBatch_CommUserCreation - Constructor');

		//get created contact id from previous batch
		this.mapUserIdToContactId 									    = mapUserIdToContactId;

		string profileId 											    = '';

		//query account info from user 
		for(Account acc : [select id,Communities_Target_Profile__c,ArchivedContactUser__c
  							from Account
  							where ArchivedContactUser__c IN :mapUserIdToContactId.keySet()]){
		    //get profile id from picklist
			profileId 												    = '';

			if(string.isNotBlank(acc.Communities_Target_Profile__c)){
			    profileId 											    = acc.Communities_Target_Profile__c.split(';')[1];
				mapUserIdAccInfo.put(acc.ArchivedContactUser__c,profileId);
			}
		}//end account query

        //build forcecomPermissionSetId and communityPermissionSet
        forcecomPermissionSetId                                         = system.label.PaintingPermissionSetId.split('-')[0];
        communityPermissionSet                                          = system.label.PaintingPermissionSetId.split('-')[1];

        //query all users having painting (force.com) permission set
        for(PermissionSetAssignment ps : [select id,AssigneeId
                                          from PermissionSetAssignment
                                          where AssigneeId IN :mapUserIdToContactId.keySet()
                                          and PermissionSetId = :forcecomPermissionSetId]){
            if(mapUserIdToContactId.containsKey(ps.AssigneeId)){
                setPaintingUsers.add(mapUserIdToContactId.get(ps.AssigneeId));
            }
        }//end PermissionSetAssignment query 
	}//end constructor

	global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('## Start AspisBatch_CommUserCreation - START');

        return Database.getQueryLocator([select id, Name, FirstName, LastName, ContactId, ProfileId, Username, 
                    							Email, Alias, TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey, 
                                                EmailEncodingKey, CommunityNickname, Street, Phone,
                    							City, State, PostalCode, Country, BodyShopID__c, General_Agreement__c, 
                                                isActive,HideSiteWelcomePopup__c
							        	from User
							        	where id IN :mapUserIdToContactId.keySet()]);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {
    	system.debug('## Start AspisBatch_CommUserCreation - execute');

    	//list to inactivate all force.com users
    	list <User> userToUpdateList 								     = new list <User>();

    	//list to hold all community users to be created
    	list <User> userToInsertList 								     = new list <User>();

        //list to hold new permssion set assigned
        list <PermissionSetAssignment> permSetToInsertList               = new list <PermissionSetAssignment>();

    	List <Database.Saveresult> lstResultsUserUpdate;
    	List <Database.Saveresult> lstResultsUserCreate;
        List <Database.Saveresult> lstResultsPermSetCreate;

        //all contacts for community users created
        //map contact id for community users and community users id
        map <string,string> mapContactIdCommUserId                       = new map <string,string>();

    	for(User us : scope){
    		//inactivate force.com user
    		userToUpdateList.add(new User(id 						     = us.id,
										  isActive 				         = false,
										  username 				         = us.username + '.migratedcc'));

    		//create community users
    		if(mapUserIdToContactId.containsKey(us.id) && mapUserIdAccInfo.containsKey(us.id)){
	    		userToInsertList.add(new User(isActive 			         = true,
	    										FirstName 			     = us.FirstName,
									    		LastName 			     = us.LastName,
									    		ContactId 			     = mapUserIdToContactId.get(us.id),
									    		ProfileId 			     = mapUserIdAccInfo.get(us.id),
									    		Username 			     = us.Username,
									    		Email 				     = us.Email,
									    		Alias 				     = us.Alias,
									    		TimeZoneSidKey 		     = us.TimeZoneSidKey,
									    		LocaleSidKey 		     = us.LocaleSidKey,
									    		LanguageLocaleKey 	     = us.LanguageLocaleKey,
									    		EmailEncodingKey 	     = us.EmailEncodingKey,
                                                CommunityNickname        = us.Alias,
									    		//CommunityNickname 	     = us.Email.substringBefore('@'),
									    		//CommunityNickname 	     = us.LastName.substring(0,5),
									    		Street 				     = us.Street,
									    		City 				     = us.City,
									    		State 				     = us.State,
									    		PostalCode 			     = us.PostalCode,
									    		Country 			     = us.Country,
                                                Phone                    = us.Phone,
									    		BodyShopID__c 		     = us.BodyShopID__c,
									    		General_Agreement__c     = us.General_Agreement__c,
                                                HideSiteWelcomePopup__c  = us.HideSiteWelcomePopup__c));
    		}//end if (mapUserIdToContactId.containsKey(us.id) && mapUserIdAccInfo.containsKey(us.id)
    	}//end looping in scope
    	system.debug('## userToUpdateList.size() ' + userToUpdateList.size());
    	system.debug('## userToInsertList.size() ' + userToInsertList.size());

        //deactivate force.com users
    	if(!userToUpdateList.isEmpty()){
    		lstResultsUserUpdate 									     = Database.update(userToUpdateList, false);

    		//error management
    		string errorMsg 										     = '';
    		string successMsg 										     = '';
            
            for(Database.SaveResult lRUU : lstResultsUserUpdate){
        	   errorMsg 											     = '';
        	   successMsg 											     = '';

                if(!lRUU.isSuccess()){
                	//raise error
                    errorMsg 										         = lRUU.getId() + ',KO,' + lRUU.getErrors()[0].getMessage() + '\n';
                    statusUpdate.add(errorMsg);
                    err                                                      = true;
                }else{
                  	//no error
                  	successMsg 										         = lRUU.getId() + ',OK,' + '\n';
                  	statusUpdate.add(successMsg);
                }
            }//end looping in result list
    	}//end if !userToUpdateList.isEmpty()
    	system.debug('## statusUpdate.size() ' + statusUpdate.size());

        //create community users
    	if(!userToInsertList.isEmpty()){ 
    		lstResultsUserCreate 									     = Database.insert(userToInsertList, false);

    		//error management
    		integer index                                                = 0;
    		string errorMsg 										     = '';
    		string successMsg 										     = '';
            
            for(Database.SaveResult lRUC : lstResultsUserCreate){
            	errorMsg 											     = '';
            	successMsg 											     = '';

                if(!lRUC.isSuccess()){
                	//raise error
                    errorMsg 										     =  userToInsertList[index].ContactId + ',KO,' + lRUC.getErrors()[0].getMessage() + '\n';
                    statusCreate.add(errorMsg);
                    err                                                  = true;
                }else{
                	//no error
                	successMsg 										     =  lRUC.getId() + ',OK,' + '\n';
                	communityUsersCreated.add(lRUC.getId());
                    mapContactIdCommUserId.put(userToInsertList[index].ContactId,lRUC.getId());
                	statusCreate.add(successMsg);
                }

                index++;
            }//end looping in result list

            //create permission set for community
            system.debug('## mapContactIdCommUserId.size() ' + mapContactIdCommUserId.size());
            system.debug('## setPaintingUsers.size() ' + setPaintingUsers.size());
            for(string str : mapContactIdCommUserId.keySet()){
                if(setPaintingUsers.contains(str)){
                    permSetToInsertList.add(
                        new PermissionSetAssignment(AssigneeId          = mapContactIdCommUserId.get(str),
                                                    PermissionSetId     = communityPermissionSet));
                }//end if setPaintingUsers.contains(str)   
            }//end looping in communityUsersCreated

            //update permission set assignment
            system.debug('## permSetToInsertList.size() ' + permSetToInsertList.size());
            if(!permSetToInsertList.isEmpty()){
                lstResultsPermSetCreate                                 = Database.insert(permSetToInsertList, false);

                //error management
                integer indexP                                          = 0;
                string errorMsgP                                        = '';
                string successMsgP                                      = '';
                
                for(Database.SaveResult lRPC : lstResultsPermSetCreate){
                    errorMsgP                                           = '';
                    successMsgP                                          = '';

                    if(!lRPC.isSuccess()){
                        //raise error
                        errorMsgP                                       = permSetToInsertList[indexP].AssigneeId + ',KO,' + lRPC.getErrors()[0].getMessage() + '\n';
                        statusPermSetCreate.add(errorMsgP);
                        err                                             = true;
                    }else{
                        //no error
                        successMsgP                                      = permSetToInsertList[indexP].AssigneeId + ',OK,' + '\n';
                        statusPermSetCreate.add(successMsgP);
                    }

                    indexP++;
                }//end looping in result list
            }//end if !permSetToInsertList.isEmpty()
    	}//end if !userToInsertList.isEmpty()
    	system.debug('## statusCreate.size() ' + statusCreate.size());
        system.debug('## statusPermSetCreate.size() ' + statusPermSetCreate.size());

    	system.debug('## End AspisBatch_CommUserCreation - execute');
    }

    global void finish(Database.BatchableContext BC) {
    	system.debug('## Start AspisBatch_CommUserCreation - finish');

    	if(!statusUpdate.isEmpty() || !statusCreate.isEmpty()){
            string subject                                              = '';

            if(err){
                subject                                                 = '*Data Integration - Community User Creation';
            }else{
                subject                                                 = 'Data Integration - Community User Creation';
            }

            csvDetails('AspisBatch_CommUserCreation',
                       subject,
                      'Deactivated User, Status , Error Message',
                      'Deactivated Users Status',
                       statusUpdate,
                      'Created User, Status , Error Message',
                      'Created Users Status',
                       statusCreate,
                       'Users Id, Status, Error Message',
                       'PermissionSet Assignment Status',
                       statusPermSetCreate
                       );
        }//end if !statusUpdate.isEmpty() || !statusCreate.isEmpty()

        //call next batch
        if(!communityUsersCreated.isEmpty()){
            Database.executeBatch(new AspisBatch_UpdateContactUser(communityUsersCreated));
        }
        system.debug('## End AspisBatch_CommUserCreation - finish');
    }

    public static void csvDetails(string batchName, 
    						   	  string emailSubject,
                                  string header1,
                                  string attName1,
                                  list <string> lstResults1,
                                  string header2,
                                  string attName2,
    	                          list <string> lstResults2,
                                  string header3,
                                  string attName3,
                                  list <string> lstResults3){
        system.debug('## Start AspisBatch_CommUserCreation - csvDetails');

	    string body                                           	  = 'Your batch job ' + batchName +' has finished. \n' 
                                                                  + 'Please find the status lists attached to this mail.';
        // Creating the CSV file
        string finalstr1                                          = '';
        string finalstr2                                          = '';
        string finalstr3                                          = '';

		// Define the email
        Messaging.SingleEmailMessage email                        = new Messaging.SingleEmailMessage(); 

        // Define email attachments
        list <Messaging.EmailFileAttachment> emailAtts            = new list <Messaging.EmailFileAttachment>();
        
        // Create the email attachments  
        Messaging.EmailFileAttachment efa1                        = new Messaging.EmailFileAttachment();
        if(!lstResults1.isEmpty()){
            efa1.setFileName(attName1 +'.csv');

            //build status
            finalstr1                                             = header1 + ' \n';

            for(string str : lstResults1){
                finalstr1                                         += str;                         
            }

            finalstr1                                             = finalstr1.removeEnd('\n');

            efa1.setBody(Blob.valueOf(finalstr1));

            //add to list attachments
            emailAtts.add(efa1);
        }//end if !lstResults1.isEmpty()

        Messaging.EmailFileAttachment efa2                        = new Messaging.EmailFileAttachment();
        if(!lstResults2.isEmpty()){
            efa2.setFileName(attName2 +'.csv');

            //build status
            finalstr2                                             = header2 + ' \n';

            for(string str : lstResults2){
                finalstr2                                         += str;                         
            }

            finalstr2                                             = finalstr2.removeEnd('\n');

            efa2.setBody(Blob.valueOf(finalstr2));

            //add to list attachments
            emailAtts.add(efa2);
        }//end if !lstResults2.isEmpty()

        Messaging.EmailFileAttachment efa3                        = new Messaging.EmailFileAttachment();
        if(!lstResults3.isEmpty()){
            efa3.setFileName(attName3 +'.csv');

            //build status
            finalstr3                                             = header3 + ' \n';

            for(string str : lstResults3){
                finalstr3                                         += str;                         
            }

            finalstr3                                             = finalstr3.removeEnd('\n');

            efa3.setBody(Blob.valueOf(finalstr3));

            //add to list attachments
            emailAtts.add(efa3);
        }//end if !lstResults3.isEmpty()

        String[] toAddresses = System.label.BAT01_emailAddress.split(';');

        // Sets the paramaters of the email
        email.setSubject(emailSubject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(body);
        email.setFileAttachments(emailAtts);

        // Sends the email
        Messaging.SendEmailResult [] r= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 

        system.debug('## End AspisBatch_CommUserCreation - csvDetails');  
    }
}