/********************************************************************************************
Class Name - FeedCommentTriggerHandler
Version - 1.0
Function - Class to Manage FeedComment Changes

Modification Log :
---------------------------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------------------------------------------------
* Abdool        28/01/2019  Original Version (Trigger Notification To BS on Each New Comment)
* Welsa         31/07/2019  C-003341 - add SO number just after Assessment number
*********************************************************************************************/
public without sharing class FeedCommentTriggerHandler {
	//	this check will prevent trigger from recurssion
	public static boolean alreadyRun = false;

	public void OnAfterInsert(FeedComment[] oldFeedItems,FeedComment[] newFeedItems){
		if(!alreadyRun){
			notifyBS(newFeedItems);
		}
	}

	public static void notifyBS(list <FeedComment> fdItemList){
		system.debug('## Start notifyBS');
		//Note :
		//Sending of email was not bulkified since method was devised to 
		//notify bs upon new chatter comment (had to disable std email due to link)

		//this check will prevent trigger from recurssion
		alreadyRun 																= true;

		map <string,FeedComment> mapAssIdFeedItem 								= new map <string,FeedComment>();
		map <string,FeedComment> mapSoIdFeedItem								= new map <string,FeedComment>();
		map <string,FeedComment> mapCaseIdFeedItem 								= new map <string,FeedComment>();
		map <string,EmailTemplate> mapEmailTemplate 							= new map <string,EmailTemplate>();

		//this set will be used to check if created user has a community license
		set <id> setTriggeredUserId 											= new set <id>();

		//set containing all users without profile bodyshop order
		set <id> setValidatedUsers 												= new set <id>();

		//filter only feeditem having as parent ASS,SO or Case
		for(FeedComment fd : fdItemList){
			system.debug('## fd ' + fd);
			if(fd.ParentId != null && 
				(string.valueOf(fd.ParentId).substring(0,3) == system.label.assObjPrefix ||
				string.valueOf(fd.ParentId).substring(0,3) == system.label.soObjPrefix ||
				string.valueOf(fd.ParentId).substring(0,3) == system.label.caseObjPrefix)){
					
				//build setTriggeredUserId
				setTriggeredUserId.add(fd.InsertedById);

				if(string.valueOf(fd.ParentId).substring(0,3) == system.label.assObjPrefix ){
					mapAssIdFeedItem.put(string.valueOf(fd.ParentId),fd);
				}else if(string.valueOf(fd.ParentId).substring(0,3) == system.label.soObjPrefix ){
					mapSoIdFeedItem.put(string.valueOf(fd.ParentId),fd);
				}else{
					mapCaseIdFeedItem.put(string.valueOf(fd.ParentId),fd);
				}
			}	
		}//end looping in fdItemList

		//query user to check if notification should be sent
		for(User usr : [select id,Profile.Name,Profile.UserLicense.Name
						from User
						where id IN :setTriggeredUserId]){
			if(!(((usr.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunity).toLowerCase() ||
				(usr.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunityLogin).toLowerCase()))){
					setValidatedUsers.add(usr.id);
			}
		}
		system.debug('@@ setValidatedUsers: '+setValidatedUsers);

		if(!setValidatedUsers.isEmpty()){
			//query email templates
			for(EmailTemplate et : [SELECT Id,Subject,Name,HtmlValue,Body,DeveloperName
									FROM EmailTemplate 
									WHERE (DeveloperName = 'Assessment_R4_Chatter_Notification_ES'
									OR DeveloperName = 'SalesOrder_R4_Chatter_Notification_ES'
									OR DeveloperName = 'Case_R4_Chatter_Notification_ES')]){
				if(et.DeveloperName.contains('Assessment_R4_Chatter_Notification_ES')){
					mapEmailTemplate.put('ass',et);
				}else if(et.DeveloperName.contains('SalesOrder_R4_Chatter_Notification_ES')){
					mapEmailTemplate.put('so',et);
				}else if(et.DeveloperName.contains('Case_R4_Chatter_Notification_ES')){
					mapEmailTemplate.put('cas',et);
				}
			}

			//get org wide address
			OrgWideEmailAddress owea = [select Id 
										from OrgWideEmailAddress 
										where DisplayName =  :system.label.OrgWideAddressDisplayName limit 1];

			// Define the email
        	Messaging.SingleEmailMessage email  									= new Messaging.SingleEmailMessage(); 
        	Boolean sendEmail 														= false;

			//get info from assessment if parent == ass
			if(!mapAssIdFeedItem.isEmpty() && mapEmailTemplate.containsKey('ass')){
				for(Assessment__c ass : [select id,Name,BodyShop__r.ContactUser__c,BodyShop__r.ContactUser__r.Profile.Name,EncodedId__c,Manufacturer__c,ModelV2__c,PlateNumber2__c
											from Assessment__c
											where id IN :mapAssIdFeedItem.keySet()
											and BodyShop__c != null limit 1]){
					if(ass.BodyShop__r.ContactUser__c != null &&
						((ass.BodyShop__r.ContactUser__r.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunity).toLowerCase() ||
						(ass.BodyShop__r.ContactUser__r.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunityLogin).toLowerCase())
						){
						sendEmail 													= true;
						email.setTargetObjectId(ass.BodyShop__r.ContactUser__c);
						email.setTemplateID(mapEmailTemplate.get('ass').Id);

						// process the merge fields
						string pageUrl 												= (system.label.EmailLinkForCommunity.replaceAll('r3/','')) + 'OrderChooseAssessment?AssessmentId=' + ass.EncodedId__c;
					    String htmlBody 											= mapEmailTemplate.get('ass').HtmlValue;
					    htmlBody 													= htmlBody.replace('{!1}', ass.Manufacturer__c + ' - ' + ass.ModelV2__c + ' - ' + ass.PlateNumber2__c);
					    htmlBody 													= htmlBody.replace('{!2}', pageUrl);
					    htmlBody 													= htmlBody.replace('{!4}', 'Comment');

					    if(string.isNotBlank(mapAssIdFeedItem.get(ass.id).CommentBody)){
					    	htmlBody 												= htmlBody.replace('{!3}', mapAssIdFeedItem.get(ass.id).CommentBody);
					    }
					    
					    String plainBody 											= mapEmailTemplate.get('ass').Body;
					    plainBody 													= plainBody.replace('{!1}', ass.Manufacturer__c + ' - ' + ass.ModelV2__c + ' - ' + ass.PlateNumber2__c);
					    plainBody 													= plainBody.replace('{!2}', pageUrl);
					    plainBody 													= plainBody.replace('{!4}', 'Comment');

					    if(string.isNotBlank(mapAssIdFeedItem.get(ass.id).CommentBody)){
					    	plainBody 												= plainBody.replace('{!3}', mapAssIdFeedItem.get(ass.id).CommentBody);
					    }

					    email.setHtmlBody(htmlBody);
	    				email.setPlainTextBody(plainBody);
	    				email.setSubject(mapEmailTemplate.get('ass').Subject.replace('{!4}', 'Comment'));

	    				if(owea != null){
						    email.setOrgWideEmailAddressId(owea.Id);
						}
					}
				}//end looping in assessment
			}else if(!mapSoIdFeedItem.isEmpty() && mapEmailTemplate.containsKey('so')){
				//get info from SO if parent == SO
				for(PrerequisiteOrder__c so : [select id,Name,Assessment__r.BodyShop__c,Assessment__r.BodyShop__r.ContactUser__c,EncodedId__c,Assessment__r.BodyShop__r.ContactUser__r.Profile.Name
												from PrerequisiteOrder__c
												where id IN :mapSoIdFeedItem.keySet()
												and Assessment__c != null limit 1]){
					if(so.Assessment__r.BodyShop__c != null && so.Assessment__r.BodyShop__r.ContactUser__c != null &&
						((so.Assessment__r.BodyShop__r.ContactUser__r.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunity).toLowerCase() ||
						(so.Assessment__r.BodyShop__r.ContactUser__r.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunityLogin).toLowerCase())
						){
						sendEmail 													= true;
						email.setTargetObjectId(so.Assessment__r.BodyShop__r.ContactUser__c);
						email.setTemplateID(mapEmailTemplate.get('so').Id);

						// process the merge fields
						string pageUrl 												= (system.label.EmailLinkForCommunity.replaceAll('r3/','')) + 'ASPISSalesOrder?id=' + so.EncodedId__c;
					    String htmlBody 											= mapEmailTemplate.get('so').HtmlValue;
					    htmlBody 													= htmlBody.replace('{!1}', so.Name);
					    htmlBody 													= htmlBody.replace('{!2}', pageUrl);
					    htmlBody 													= htmlBody.replace('{!4}', 'Comment');

					    if(string.isNotBlank(mapSoIdFeedItem.get(so.id).CommentBody)){
					    	htmlBody 												= htmlBody.replace('{!3}', mapSoIdFeedItem.get(so.id).CommentBody);
					    }
					    
					    String plainBody 											= mapEmailTemplate.get('so').Body;
					    plainBody 													= plainBody.replace('{!1}', so.Name);
					    plainBody 													= plainBody.replace('{!2}', pageUrl);
					    plainBody 													= plainBody.replace('{!4}', 'Comment');

					    if(string.isNotBlank(mapSoIdFeedItem.get(so.id).CommentBody)){
					    	plainBody 												= plainBody.replace('{!3}', mapSoIdFeedItem.get(so.id).CommentBody);
					    }

					    email.setHtmlBody(htmlBody);
	    				email.setPlainTextBody(plainBody);
	    				email.setSubject(mapEmailTemplate.get('so').Subject.replace('{!4}', 'Comment'));

	    				if(owea != null){
						    email.setOrgWideEmailAddressId(owea.Id);
						}
					}					
				}//end looping in SO
			}else if(!mapCaseIdFeedItem.isEmpty()){
				//get info from Case if parent == CASE
				for(Case__c cas : [select id,Name,Tech_BSAccount__c,Tech_BSAccount__r.ContactUser__c,Tech_BSAccount__r.ContactUser__r.Profile.Name, Assesment__r.AssessmentNumber__c /*RLA 10/07/2019 */,Sales_order__r.Name /* WCH 31/07/2019 C-003341 */
									from Case__c
									where id IN :mapCaseIdFeedItem.keySet()
									and Tech_BSAccount__c != null limit 1]){
					if(cas.Tech_BSAccount__c != null && cas.Tech_BSAccount__r.ContactUser__c != null &&
						((cas.Tech_BSAccount__r.ContactUser__r.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunity).toLowerCase() ||
						(cas.Tech_BSAccount__r.ContactUser__r.Profile.Name).toLowerCase() == (system.label.R4BSProfileNameCommunityLogin).toLowerCase())
						){
						sendEmail 													= true;
						email.setTargetObjectId(cas.Tech_BSAccount__r.ContactUser__c);
						email.setTemplateID(mapEmailTemplate.get('cas').Id);

						// process the merge fields
						string pageUrl 												= (system.label.EmailLinkForCommunity.replaceAll('r3/','')) + 'ASPISMyCaseDetail?id=' + encryptBase64(cas.Id);
					    String htmlBody 											= mapEmailTemplate.get('cas').HtmlValue;
					    htmlBody 													= htmlBody.replace('{!1}', cas.Name);
					    htmlBody 													= htmlBody.replace('{!2}', pageUrl);
					    htmlBody 													= htmlBody.replace('{!4}', 'Comment');
						//RLA 10/07/2019
					    htmlBody = htmlBody.replace('{!5}',cas.Assesment__r.AssessmentNumber__c+(cas.Sales_order__c==null?'':(', '+cas.Sales_order__r.Name)));//WCH 31/07/2019 C-003341 added SO Number
					    if(string.isNotBlank(mapCaseIdFeedItem.get(cas.id).CommentBody)){
					    	htmlBody 												= htmlBody.replace('{!3}', mapCaseIdFeedItem.get(cas.id).CommentBody);
					    }
					    
					    String plainBody 											= mapEmailTemplate.get('cas').Body;
					    plainBody 													= plainBody.replace('{!1}', cas.Name);
					    plainBody 													= plainBody.replace('{!2}', pageUrl);
					    plainBody 													= plainBody.replace('{!4}', 'Comment');
						//RLA 10/07/2019
					    plainBody = plainBody.replace('{!5}',cas.Assesment__r.AssessmentNumber__c);
					    if(string.isNotBlank(mapCaseIdFeedItem.get(cas.id).CommentBody)){
					    	plainBody 												= plainBody.replace('{!3}', mapCaseIdFeedItem.get(cas.id).CommentBody);
					    }

					    email.setHtmlBody(htmlBody);
	    				email.setPlainTextBody(plainBody);
	    				email.setSubject(mapEmailTemplate.get('cas').Subject.replace('{!4}', 'Comment'));

	    				if(owea != null){
						    email.setOrgWideEmailAddressId(owea.Id);
						}
					}
				}//end loopping in case
			}

			//send email
			if(sendEmail){
		        // Sets the paramaters of the email
		        email.saveAsActivity 											= false;

		        // Sends the email
		        Messaging.SendEmailResult [] r 									= Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
			}
		}//end if !setValidatedUsers.isEmpty()

		system.debug('## End notifyBS');
	}

	public static String encryptBase64(String text){
        Blob encryptedBlob = Blob.valueOf(text);
        String encryptedData = EncodingUtil.base64Encode(encryptedBlob);

        return encryptedData;
    }
	
}