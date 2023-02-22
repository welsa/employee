/*************************************************************************************
Class Name - TestPartListRejectAssessmentChildren
Version - 1.0
Created Date - 22 May 2015
Function - test class for PartListRejectAssessmentChildren

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Kevan (sc)	     	22/05/2015  Original Version
* Bhavish (sc)			29/05/2015	Added Assert
* Dourga (sc)           17/07/2015  Corrected test class for invocableMethod
************************************************************************************/
@isTest
private class TestPartListRejectAssessmentChildren {
	
	/*static list<Assessment__c> assessments;
	static User userAdmin;
	static list<PartList__c> partLists;
	static list <Account> accounts;

	static testmethod void testInvoke(){
		ASPISTestUtils.generateBasicTestData();
        
        userAdmin = new User(Username = 'jean.paul-testingNewName@test.com'  // checking for UNABLE_TO_LOCK_ROW error in running test parallel
            ,LastName = 'paul'
            ,LanguageLocaleKey = 'en_US'
            ,FirstName = 'jean'
            ,Email = 'jean@test.com'
            ,Alias = 'jpa'
            ,TimeZoneSidKey = 'Europe/Dublin'
            ,LocaleSidKey = 'en_US'
            ,EmailEncodingKey = 'UTF-8'
            ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        
        system.runas(userAdmin){
			accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
                  							        RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId(),
                  							        ReferenceNumber__c = '12223',
                  							        ContactEmail__c = 'bt1@gmail.com',
                                               		ShippingCountryCode = 'FR',
            										VAT__c = 10),

    					        		new Account(Name='BodyShop_ScTest2',
          					        					RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('BodyShop').getRecordTypeId(),
          					        					ReferenceNumber__c = '123324',
          					        					ContactEmail__c = 'bt2@gmail.com',
                                      					ShippingCountryCode = 'FR',
    													VAT__c = 10)
            };
            insert accounts;
			assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0003',  
																	AssessmentNumber__c = 'ASSESS_TEST-0003',
																	BodyShop__c = accounts[1].Id,
																	Entity__c = 'AXA Direct',
																	MissionNumber__c = '011',
																	PortfolioAgentCode__c = '3551',
																	AssessmentID__c = '09121',
																	TechExternalId__c = '2331',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='SOURCED'),
	                                                
	                                           		new Assessment__c(Name='ASSESS_TEST-0004',
																	AssessmentNumber__c = 'ASSESS_TEST-0004',
																	BodyShop__c = accounts[0].Id,
																	Entity__c = 'AXA Direct1',
																	MissionNumber__c = '021',
																	PortfolioAgentCode__c = '35451',
																	AssessmentID__c = '59121',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='SOURCED')
	                
	        };
		    insert assessments;
		    partLists = new list<PartList__c>{new PartList__c(Assessment__c = assessments[0].Id,
                                                          Name = 'FRONT LWR AIR GRILLE',
                                                          PartNumber__c = '53102 47020',
                                                          HeldDate__c = date.today(),
                                                          Price__c = 68,
                                                          Quantity__c = 1)
	    									,new PartList__c(Assessment__c = assessments[1].Id,
                                                          Name = 'FRONT LWR AIR GRILLE 2',
                                                          PartNumber__c = '53102 47020',
                                                          HeldDate__c = date.today(),
                                                          Price__c = 68,
                                                          Quantity__c = 1)
	    									};
			insert partLists;
			test.startTest();
				Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
				PartListRejectAssessmentChildren.invoke(new list<ID>{assessments[0].id, assessments[1].id});
			test.stoptest();
			List<PartList__c> listPartLists = new List<PartList__c>([select id
																	from PartList__c
																	where Assessment__c=:assessments[0].Id
																	or Assessment__c=:assessments[1].Id]);
			System.assertEquals(0, listPartLists.size());
		}
	}
	*/
}