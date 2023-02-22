/*
  ----------------------------------------------------------------------
  -- - Name          : AP08EmailServicesHandler_TEST 
  -- - Author        : ABT 
  -- - Description   : AP08EmailServicesHandler_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 25-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Yudish R  		13/07/2015 	Original Version
 **********************************************************************
*/
@isTest
public class AP08EmailServicesHandler_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<User> userList;
	static List<Group> queueList;
	static List<QueueSObject> queueMappingList;
	static List<Email2CaseMailToMapping__c> email2CaseMailMappingList;
	static List<CaseDetailsProcessMapping__c> caseMappingList;
	static List<CountryCodeInformationsMapping__c> countryCodeMappingList;
	static BusinessHours defaultHours;
	
	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShopFR', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR', 'FR')
			};

			insert accountList;

			userList = new List<User>
			{
				TestFactory.createUser('adminUserWithBodyShop'),
				TestFactory.createUser('adminUserWithDistributor')
			};

			userList[0].Email		  = 'ashutosh.betchoo@sc-test.com';
			userList[0].BodyShopID__c = accountList[0].Id;

			userList[1].Email		  = 'ashutosh@sc-test.com';
			userList[1].DistributorID__c = accountList[1].Id;

			insert userList;

			queueList = new List<Group>
			{
				new Group(Name = 'Test Queue 1',
						  Type = 'Queue'),
				new Group(Name = 'Test Queue 2',
						  Type = 'Queue')
			};

			insert queueList;

			queueMappingList = new List<QueueSobject>
			{
				new QueueSobject(QueueId = queueList[0].Id,
								 SobjectType = 'Case__c'),
				new QueueSobject(QueueId = queueList[1].Id,
								 SobjectType = 'Case__c')
			};

			insert queueMappingList;

			email2CaseMailMappingList = new List<Email2CaseMailToMapping__c>
			{
				new Email2CaseMailToMapping__c( Name							= 'DEFAULT',
												CountryCode__c					= 'FR',
												Queue_ID__c						= queueList[0].Id,
												AcknowledgeEmailTemplateID__c	= '00X25000000M1M8'),
				new Email2CaseMailToMapping__c( Name							= 'emailFR@gmail.com',
												CountryCode__c					= 'FR',
												Queue_ID__c						= queueList[1].Id,
												AcknowledgeEmailTemplateID__c	= '00X25000000M1M8')
			};

			insert email2CaseMailMappingList;

			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			
			insert caseMappingList;

			defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			insert countryCodeMappingList;
		}
	}

	@isTest static void defaultEmailCaseTest()
	{
		System.runAs(userList[0])
		{
			// Create a new email and envelope object (Mandatory)
			Messaging.InboundEmail email  = new Messaging.InboundEmail();
			Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

			List<String> toAddrList = new List<String>
			{
				'test@gmail.com'
			};

			// Create the email body
			email.plainTextBody	= 'This should become a note';
			email.fromAddress	= 'ashutosh.betchoo@sc-test.com';
			email.ccAddresses	= new String[] {'Test Domain <test@domain.com>'};
			email.subject		= 'Dummy Subject';
			email.toAddresses	= toAddrList;

			// add an attachment
			Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
			attachment.body									   = Blob.valueOf('my attachment text');
			attachment.fileName								   = 'textfile.txt';
			attachment.mimeTypeSubType						   = 'text/plain';
       
			email.binaryAttachments							   = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

			AP08EmailServicesHandler emailService = new AP08EmailServicesHandler();

			Test.startTest();
				// pass email & enveloper object as parameters here
				Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, env);
			Test.stopTest();

			List<Case__c> caseAssertList = [SELECT	Id, Name, Account_Name__c, Description__c, CountryCode__c, SenderEmail__c, OwnerId
											FROM	Case__c
											WHERE	Account_Name__c =: accountList[0].Id];

			System.assertEquals('This should become a note',	caseAssertList[0].Description__c);
			System.assertEquals('ashutosh.betchoo@sc-test.com',	caseAssertList[0].SenderEmail__c);
			System.assertEquals(queueList[0].Id,				caseAssertList[0].OwnerId);

			// find the attachment
			Attachment a = [SELECT	Id, Name 
							FROM	Attachment 
							WHERE	ParentId =: caseAssertList[0].Id];

			System.assertEquals('textfile.txt', a.Name);
		}
	}

	@isTest static void emailFRCaseTest()
	{
		System.runAs(userList[1])
		{
			// Create a new email and envelope object (Mandatory)
			Messaging.InboundEmail email  = new Messaging.InboundEmail();
			Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

			List<String> toAddrList = new List<String>
			{
				'emailFR@gmail.com'
			};

			// Create the email body
			email.plainTextBody	= 'This should become a note';
			email.fromAddress	= 'ashutosh@sc-test.com';
			email.ccAddresses	= new String[] {'Test Domain <test@domain.com>'};
			email.subject		= 'Dummy Subject';
			email.toAddresses	= toAddrList;

			// add an attachment
			Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
			attachment.body									   = Blob.valueOf('my attachment text');
			attachment.fileName								   = 'textfile.txt';
			attachment.mimeTypeSubType						   = 'text/plain';
       
			email.binaryAttachments							   = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

			AP08EmailServicesHandler emailService = new AP08EmailServicesHandler();

			Test.startTest();
				// pass email & enveloper object as parameters here
				Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, env);
			Test.stopTest();

			List<Case__c> caseAssertList = [SELECT	Id, Name, Account_Name__c, Description__c, CountryCode__c, SenderEmail__c, OwnerId
											FROM	Case__c
											WHERE	Account_Name__c =: accountList[1].Id];

			System.assertEquals('This should become a note',	caseAssertList[0].Description__c);
			System.assertEquals('ashutosh@sc-test.com',	caseAssertList[0].SenderEmail__c);
			System.assertEquals(queueList[1].Id,				caseAssertList[0].OwnerId);

			// find the attachment
			Attachment a = [SELECT	Id, Name 
							FROM	Attachment 
							WHERE	ParentId =: caseAssertList[0].Id];

			System.assertEquals('textfile.txt', a.Name);
		}
	}
}