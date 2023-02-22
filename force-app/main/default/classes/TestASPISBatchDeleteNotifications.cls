/*************************************************************************************
Class Name - TestASPISBatchDeleteNotifications
Version - 1.0
Created Date - 05 AUG 2015
Function - Test class for Batch to delete Notifications

Modification Log :
-----------------------------------------------------------------------------
* Developer  	 Date       	Description
* ---------- 	 ----------  -----------------------
* Brayan Nunhuck 05/08/2015 	Original Version
*************************************************************************************/
@isTest
private class TestASPISBatchDeleteNotifications {
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
	
	@isTest static void testDeleteNotifications() {
		system.runAs(users[0]){
			delays = new list<DelayForDeletion__c>{
				new DelayForDeletion__c(Name = 'DELETE-FROM',PurgePeriodNotificationsDays__c=1)
	  		};
	  		insert delays;

			List<Notification__c> notList = new list<Notification__c>{
				new Notification__c(Tech_CreatedDate__c = system.now().addMonths(-3)),
				new Notification__c(Tech_CreatedDate__c = null)
			};

			insert notList;

			test.startTest();
				ASPISBatchDeleteNotifications deleteNotification = new ASPISBatchDeleteNotifications();
				database.executebatch(deleteNotification);
			test.stopTest();

			List<Notification__c> notListAssert = [Select Id from Notification__c where Id in:notList];
			system.assertEquals(1,notListAssert.size());
		}
	}

	@isTest static void testNODeleteNotifications() {
		system.runAs(users[0]){
			delays = new list<DelayForDeletion__c>{
				new DelayForDeletion__c(Name = 'DELETE-FROM',PurgePeriodNotificationsDays__c = null)
	  		};
	  		insert delays;

			List<Notification__c> notList = new list<Notification__c>{
				new Notification__c(Tech_CreatedDate__c = system.now().addMonths(-3)),
				new Notification__c(Tech_CreatedDate__c = null)
			};

			insert notList;

			test.startTest();
				ASPISBatchDeleteNotifications deleteNotification = new ASPISBatchDeleteNotifications();
				database.executebatch(deleteNotification);
			test.stopTest();

			List<Notification__c> notListAssert = [Select Id from Notification__c where Id in:notList];
			system.assertEquals(2,notListAssert.size());
		}
	}
	
	@isTest static void testSchDeleteNotifications() {
		system.runAs(users[0]){
			delays = new list<DelayForDeletion__c>{
				new DelayForDeletion__c(Name = 'DELETE-FROM',PurgePeriodNotificationsDays__c=1)
	  		};
	  		insert delays;

			List<Notification__c> notList = new list<Notification__c>{
				new Notification__c(Tech_CreatedDate__c = system.now().addMonths(-3)),
				new Notification__c(Tech_CreatedDate__c = null)
			};

			insert notList;

			test.startTest();
				for(CronTrigger c : [Select Id From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'SchASPISBatchDeleteNotifications' and JobType = '7')]){ 
					System.abortJob(c.id);
				}	
				
				ASPISScheduleBatchDeleteNotifications  SchASPISBatchDeleteNotifications = new ASPISScheduleBatchDeleteNotifications();
				String sch = '0 0 0 * * ?';
				system.schedule('SchASPISBatchDeleteNotifications', sch, SchASPISBatchDeleteNotifications); 
				
				CronTrigger ct =[Select Id,CronExpression, TimesTriggered, NextFireTime From CronTrigger Where CronJobDetailId IN (Select Id From CronJobDetail where Name = 'SchASPISBatchDeleteNotifications' and JobType = '7')];
				System.assertEquals('0 0 0 * * ?', ct.CronExpression);    
       			System.assertEquals(0, ct.TimesTriggered);
			test.stopTest();
		}
	}*/
}