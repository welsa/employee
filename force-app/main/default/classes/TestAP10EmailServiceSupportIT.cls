/*************************************************************************************
Class Name - TestAP10EmailServiceSupportIT
Version - 1.0
Created Date - 30 July 2015
Function - TestClass to AP10EmailServiceSupportIT

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       		Description
* ---------- 	----------  	-----------------------
* Dourga     	30/07/2015 		Original Version
*************************************************************************************/
@isTest
private class TestAP10EmailServiceSupportIT {
/*
	static User userAdmin;
	static list<User> users;
	static list<Account> accounts;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	static list<Group> groups;
	static list<Email2CaseMailToMapping__c>emailCs;
	static list<QueuesObject> QueueObjs;

	static{

		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
		
		userAdmin = new User(Username = 'jean.paul@test.com'
                    ,LastName = 'paul'
                    ,LanguageLocaleKey = 'en_US'
                    ,FirstName = 'jean'
                    ,Email = 'jean@test.com'
                    ,Alias = 'jpa'
                    ,TimeZoneSidKey = 'Europe/Dublin'
                    ,LocaleSidKey = 'en_US'
                    ,EmailEncodingKey = 'UTF-8'
                    ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        ASPISTestUtils.generateTestUser(userAdmin);
        
        system.runas(userAdmin){

			// insert accounts
	        accounts = new list<Account>{
	            new Account(Name='BodyShop_ScTest1'
	                ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
	            ),
	            new Account(Name='Distributor_ScTest1'
	                ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
	            )
	        };
	        ASPISTestUtils.generateAccount (accounts);

	        users = new list<User>{
	        	new User(Username = 'testclassAP01@test.com',
	                            LastName = 'testuser',
	                            LanguageLocaleKey = 'en_US',
	                            FirstName = 'test',
	                            Email = 'yudish.ramdowar@sc.com',
	                            Alias = 'test',
	                            TimeZoneSidKey = 'Europe/Dublin',
	                            LocaleSidKey = 'en_US',
	                            EmailEncodingKey = 'UTF-8',
	                            ProfileId = ASPISConstants.getProfileAdminId(),
	                            BodyShopID__c = accounts[0].Id
	            ),
	            new User(Username = 'testclassAP02@test.com',
	                            LastName = 'testuser',
	                            LanguageLocaleKey = 'en_US',
	                            FirstName = 'test',
	                            Email = 'yudish.test@sc.com',
	                            Alias = 'test',
	                            TimeZoneSidKey = 'Europe/Dublin',
	                            LocaleSidKey = 'en_US',
	                            EmailEncodingKey = 'UTF-8',
	                            ProfileId = ASPISConstants.getProfileAdminId(),
	                            DistributorID__c = accounts[1].Id
	            )

	        };
	        insert users;

			
			//insert groups
            groups = new list<Group>{
            	new Group(Name='test group1', Type='Queue'),
            	new Group(Name='test group2', Type='Queue')
            };
            insert groups;
            //system.debug('Groups:'+groups);
			
			QueueObjs = new list<QueueSObject>{
				new QueueSObject (QueueID = groups[0].Id, SobjectType = 'Case__c')
				,new QueueSObject(QueueID = groups[1].Id, SobjectType = 'Case__c')
			};
			insert QueueObjs;

            String countryCode='FR';

            //insert emailCs
            emailCs =new list<Email2CaseMailToMapping__c>{
            	new Email2CaseMailToMapping__c(
            		CountryCode__c=countryCode
	                ,Name='DEFAULT'
	           		,Queue_ID__c = Groups[0].Id
	           		,AcknowledgeEmailTemplateID__c = '00X25000000M1M8'
            	),
            	new Email2CaseMailToMapping__c(
            		CountryCode__c=countryCode
	                ,Name='emailFR@gmail.com'
	           		,Queue_ID__c = Groups[1].Id
	           		,AcknowledgeEmailTemplateID__c = '00X25000000M1M8'
            	)
            };
            insert emailCs;

            //insert caseDetails
            CaseDetailsProcessMapping__c caseDetails = new CaseDetailsProcessMapping__c(
            	Name=countryCode+'-EmailService'
            	,Description__c='An User send an email to the Email2Case service.'
            	,Origin__c='EMAIL'
            	,Type__c='QUESTION'
            	,Priority__c='LOW'
            	,Short_Description__c='Test'
            	,Due_Date_Unity__c ='D'
				,Active__c = true
            );
            insert caseDetails;

        }
    }
    
	@isTest static void test_DefaultEmailCs() {
		// Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        list<string> toAddrList = new list<string>{'test@gmail.com'};

        // Create the email body
        email.plainTextBody = 'This should become a note';
        email.fromAddress ='yudish.ramdowar@sc.com';
        String contactEmail = 'test@domain.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'Dummy Subject';
        email.toAddresses = toAddrList;

		// add an attachment
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfile.txt';
		attachment.mimeTypeSubType = 'text/plain';
       
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        
        system.runAs(users[0]){

        	AP10EmailServiceSupportIT edr = new AP10EmailServiceSupportIT();
	        Test.startTest();
		        // pass email & enveloper object as parameters here
		        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
	        Test.stopTest();

	        List<Case__c> caseAssertList = new List<Case__c>([select Name
																	,Account_Name__c
																	,Description__c
																	,CountryCode__c
																	,SenderEmail__c
																	,OwnerId
																from Case__c
																where Account_Name__c=:accounts[0].id]);
			//System.debug('######## caseAssertList:'+caseAssertList);
			System.assertEquals('This should become a note', caseAssertList[0].Description__c);
			System.assertEquals('yudish.ramdowar@sc.com', caseAssertList[0].SenderEmail__c);
			System.assertEquals(Groups[0].Id, caseAssertList[0].OwnerId);

			// find the attachment
			Attachment a = [select name from attachment where parentId = :caseAssertList[0].id];

			System.assertEquals(a.name,'textfile.txt');
		}

	}

	@isTest static void test_emailFRCs() {
		// Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        list<string> toAddrList = new list<string>{'emailFR@gmail.com'};

        // Create the email body
        email.plainTextBody = 'This should become a note1';
        email.fromAddress ='yudish.test@sc.com';
        String contactEmail = 'test@domain.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'Dummy Subject1';
        email.toAddresses = toAddrList;

		// add an attachment
		Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		attachment.body = blob.valueOf('my attachment text');
		attachment.fileName = 'textfile1.txt';
		attachment.mimeTypeSubType = 'text/plain';
       
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

        
        system.runAs(users[1]){

        	AP10EmailServiceSupportIT edr = new AP10EmailServiceSupportIT();
	        Test.startTest();
		        // pass email & enveloper object as parameters here
		        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
	        Test.stopTest();

	        List<Case__c> caseAssertList = new List<Case__c>([select Name
																	,Account_Name__c
																	,Description__c
																	,CountryCode__c
																	,SenderEmail__c
																	,OwnerId
																from Case__c
																where Account_Name__c=:accounts[1].id]);
			System.assertEquals('This should become a note1', caseAssertList[0].Description__c);
			System.assertEquals('yudish.test@sc.com', caseAssertList[0].SenderEmail__c);
			System.assertEquals(Groups[1].Id, caseAssertList[0].OwnerId);

			// find the attachment
			Attachment a = [select name from attachment where parentId = :caseAssertList[0].id];

			System.assertEquals(a.name,'textfile1.txt');
		}

	}
	*/
}