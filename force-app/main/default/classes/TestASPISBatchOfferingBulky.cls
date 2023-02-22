/*************************************************************************************
Class Name - ASPISBatchOfferingBulky
Version - 1.0
Created Date - 22 May 2015
Function - Test class for TestASPISBatchOfferingBulky

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Kevan (sc)		    22/05/2015  Original Version
* Bhavish (sc)			27/05/2015	Added Assert
*************************************************************************************/
@isTest
private class TestASPISBatchOfferingBulky {
/*
	static list<Assessment__c> assessments;
	static list<user> users;

	static{
		users = new list<User>{ new User(Username = 'testclass@test.com',
			                            LastName = 'testuser',
			                            LanguageLocaleKey = 'en_US',
			                            FirstName = 'test',
			                            Email = 'test@test.com',
			                            Alias = 'test',
			                            TimeZoneSidKey = 'Europe/Dublin',
			                            LocaleSidKey = 'en_US',
			                            EmailEncodingKey = 'UTF-8',
			                            ProfileId = ASPISConstants.getProfileAdminId())
	  	}; 
	  	ASPISTestUtils.generateTestUsers(users);
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
	  	system.runas(users[0]){
			ASPISTestUtils.generateBasicTestData();

			assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0003',
																	AssessmentNumber__c = 'ASSESS_TEST-0003',
																	BodyShop__c = ASPISTestUtils.accounts[1].Id,
																	Entity__c = 'AXA Direct',
																	MissionNumber__c = '011',
																	PortfolioAgentCode__c = '3551',
																	AssessmentID__c = '09121',
																	TechExternalId__c = '2331',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='PREOFFERING'),
	                                                
	                                           		new Assessment__c(Name='ASSESS_TEST-0004', 
																	AssessmentNumber__c = 'ASSESS_TEST-0004',
																	BodyShop__c = ASPISTestUtils.accounts[0].Id,
																	Entity__c = 'AXA Direct1',
																	MissionNumber__c = '021',
																	PortfolioAgentCode__c = '35451',
																	AssessmentID__c = '59121',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='PREOFFERING')
	                
	        };
	            
	        insert assessments;
	    
	    	//GlobalVariables__c gVariable = new GlobalVariables__c(name='BatchOffering', Object__c='Assessment__c', Type__c='Constant', Value__c='2');
	    	//insert gVariable;
	    }//end runas
	}

	static testMethod void testGenerateOffer(){
		system.runas(users[0]){
			ASPISBatchOfferingBulky batch = new ASPISBatchOfferingBulky();
			test.starttest();
				database.executeBatch(batch);
			test.stoptest();
			List<Assessment__c> assessmentsList = new List<Assessment__c>([Select Id, Status__c FROM Assessment__c where Id=:assessments[0].id or Id=:assessments[1].Id]);
			System.assertEquals(2, assessmentsList.size());
			System.assertEquals('OFFERING', assessmentsList[0].Status__c);
			System.assertEquals('OFFERING', assessmentsList[1].Status__c);
		}
	}
	*/
}