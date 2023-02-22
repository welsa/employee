@isTest
private class TestASPISBatchDeleteLogs {
/*
	static list<user> users;
	static list<DelayForDeletion__c> delays;

	static{
		users = new list<User>{ new User(Username = '5testclass@test.com',
			                            LastName = '5testuser',
			                            LanguageLocaleKey = 'en_US',
			                            FirstName = '5test',
			                            Email = '5test@test.com',
			                            Alias = '5test',
			                            TimeZoneSidKey = 'Europe/Dublin',
			                            LocaleSidKey = 'en_US',
			                            EmailEncodingKey = 'UTF-8',
			                            ProfileId = ASPISConstants.getProfileAdminId())
	  	}; 
	  	//insert users;
	  	ASPISTestUtils.generateTestUsers(users);
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = false,BypassTrigger__c = 'AP05;AP07');
		
	}
	
	@isTest static void testDeleteLog() {
		system.runAs(users[0]){
			delays = new list<DelayForDeletion__c>{
				new DelayForDeletion__c(Name = 'DELETE-FROM',PurgePeriodLogsDays__c=1)
	  		};
	  		insert delays;

			List<Log__c> logList = new list<Log__c>{
				new Log__c(Tech_CreatedDate__c = system.now().addMonths(-3)),
				new Log__c(Tech_CreatedDate__c = null)
			};

			insert logList;

			test.startTest();
				ASPISBatchDeleteLogs deleteLogs = new ASPISBatchDeleteLogs();
				database.executebatch(deleteLogs);
			test.stopTest();

			List<Log__c> logListAssert = [Select Id from Log__c where Id in:logList];
			system.assertEquals(1,logListAssert.size());
		}
	}
	
	@isTest static void testNoDeleteLog() {
		system.runAs(users[0]){
			delays = new list<DelayForDeletion__c>{
				new DelayForDeletion__c(Name = 'DELETE-FROM',PurgePeriodLogsDays__c = null)
	  		};
	  		insert delays;

			List<Log__c> logList = new list<Log__c>{
				new Log__c(Tech_CreatedDate__c = system.now().addMonths(-3)),
				new Log__c(Tech_CreatedDate__c = null)
			};

			insert logList;

			test.startTest();
				ASPISBatchDeleteLogs deleteLogs = new ASPISBatchDeleteLogs();
				database.executebatch(deleteLogs);
			test.stopTest();

			List<Log__c> logListAssert = [Select Id from Log__c where Id in:logList];
			system.assertEquals(2,logListAssert.size());
		}
	}
	
	@isTest static void testSchDeleteLog() {
		system.runAs(users[0]){
			delays = new list<DelayForDeletion__c>{
				new DelayForDeletion__c(Name = 'DELETE-FROM',PurgePeriodLogsDays__c=1)
	  		};
	  		insert delays;

			List<Log__c> logList = new list<Log__c>{
				new Log__c(Tech_CreatedDate__c = system.now().addMonths(-3)),
				new Log__c(Tech_CreatedDate__c = null)
			};

			insert logList;

			test.startTest();
				for(CronTrigger c : [Select Id From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'Test testSchDeleteLog' and JobType = '7')]){ 
					System.abortJob(c.id);
				}	
				
				ASPISScheduleBatchDeleteLogs  SchdeleteLogs = new ASPISScheduleBatchDeleteLogs();
				String sch = '0 0 0 * * ?';
				system.schedule('Test testSchDeleteLog', sch, SchdeleteLogs); 
				
				CronTrigger ct =[Select Id,CronExpression, TimesTriggered, NextFireTime From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'Test testSchDeleteLog' and JobType = '7')];
				System.assertEquals('0 0 0 * * ?', ct.CronExpression);    
       			System.assertEquals(0, ct.TimesTriggered);
			test.stopTest();

		}
	}
	*/
	
	
}