/*************************************************************************************
Class Name - AP10EmailServiceSupportIT
Version - 1.0
Created Date - 30 July 2015
Function - Class to create case for Support IT

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        	Description
* ----------    ----------  	-----------------------
* Dourga        30/07/2015  	Original Version
* Shamina M     16/02/2016  	C-001518: commented unnecessary debug logs
*************************************************************************************/
global class AP10EmailServiceSupportIT implements Messaging.InboundEmailHandler{
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		system.debug('>>>> START handleInboundEmail method<<<<<');
		
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		//list to store attachment
		list<Attachment> attachList = new List<Attachment>();
		//list to store mailTo addresses
		list<string> mailToList = new list<string>();
		//default config value
		String DEFAULTCONFIG = 'DEFAULT';
		//email config address
		String configId = '';
		//custom setting 
		Email2CaseMailToMapping__c configEmail2Case;

	    Account [] accList = new List<Account>();
	    User[] userlist = new List<User>();
		User[]  userAspisAdminList= new List<User>();
		string [] fromAddressList = new list<string>();

		String userAdminName = 'ASPIS Administrator';
		String PROCESS= '-EmailService';
		Id USER_ID=null, ACCOUNT_ID = null;
		Case__c newCase ;

		//system.debug('>>>> envelope:'+envelope);
		//system.debug('>>>> email:'+email);

		mailToList= email.toAddresses;
		//system.debug('>>>>mailToList.size():'+mailToList.size());

		if(mailToList.size()>0)
			configId = mailToList[0];
		
		// retrieve mapping from cs
		if(Email2CaseMailToMapping__c.getall().containsKey(configId)){
			configEmail2Case = Email2CaseMailToMapping__c.getAll().get(configId);
		}
		else{
			configEmail2Case = Email2CaseMailToMapping__c.getAll().get(DEFAULTCONFIG);
		}
		//system.debug('>>>> configEmail2Case:'+configEmail2Case);

		//system.debug('>>>> emailFrom:'+email.fromAddress);
		//find user with the address from
		userlist = [Select Id,Email,BodyShopID__c,DistributorID__c from User where Email=:email.fromAddress];

		//get the account Id on the user
		if(userlist.size()>0){
			if(userlist[0].BodyShopID__c!=null && userlist[0].DistributorID__c==null){
				ACCOUNT_ID = userlist[0].BodyShopID__c;
			}
			else if(userlist[0].BodyShopID__c==null && userlist[0].DistributorID__c!=null){
				ACCOUNT_ID = userlist[0].DistributorID__c;
			}
			//Setting user id base on user found
			USER_ID = userlist[0].Id;
		}
	    //system.debug('>>>> USER_ID:'+USER_ID);
	    //system.debug('>>>> ACCOUNT_ID:'+ACCOUNT_ID);

	    if(configEmail2Case!=null){
	    	newCase = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('', configEmail2Case.CountryCode__c, ACCOUNT_ID, null, null, null, null, USER_ID, PROCESS);
	    }
		
		//system.debug('>>>> newCase:'+newCase);

	    if(newCase!=null){
	    	newCase.Subject__c = email.subject;
	    	newCase.Description__c = email.plainTextBody;
	    	newCase.SenderEmail__c = email.fromAddress;
	    	newCase.OwnerId = configEmail2Case.Queue_ID__c;
	    	newCase.RecordTypeId = Schema.SObjectType.Case__c.getRecordTypeInfosByName().get('Production support').getRecordTypeId();

	    	insert newCase;
	    	
	    	//system.debug('>>>> newCase:'+newCase);

	        // insert attachments
			if (email.binaryAttachments <> null){
				for(Messaging.InboundEmail.BinaryAttachment attach:email.binaryAttachments){
					Attachment reqAttach = new Attachment();
					reqAttach.Body = attach.Body;
					reqAttach.Name = attach.FileName;
					reqAttach.ParentId = newCase.Id;    
					attachList.add(reqAttach);
	            }
	        
	        	if (attachList.size()>0) insert attachList;
	        }
	    }
		return result;
	}
}