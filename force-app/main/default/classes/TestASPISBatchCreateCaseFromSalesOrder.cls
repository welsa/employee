/*************************************************************************************
Class Name - TestASPISBatchCreateCaseFromSalesOrder
Version - 1.0
Created Date - 04 June 2015
Function - test class for ASPISBatchCreateCaseFromSalesOrder

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga (sc)           17/07/2015  Original version 
* Dourga (sc)       	19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c 
									to add new field TECH_EntityCountryCode__c)
************************************************************************************/
@isTest
private class TestASPISBatchCreateCaseFromSalesOrder {
/*
	static list<user> users;
	static list<OrderLine__c> orderLineList;
	static list<PrerequisiteOrder__c> prerequisiteOrders;
	static map <String,Id> proRecordTypeMap = new map <String,Id>();


	static {
		ASPISTestUtils.generateBasicTestData();

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
	  	//ASPISTestUtils.setupBypassCustomSetting(true,false,'AP05;AP07','TestASPISBatchCreateCaseFromSalesOrder',users[0].Id);
	}

	static testMethod void testinsertListCases(){
		System.Debug('>>> Start testinsertListCases');
		proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);
		prerequisiteOrders= new list<PrerequisiteOrder__c>{new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
																					Assessment__c = ASPISTestUtils.assessments[0].Id,
																					RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
																					SLAInDeliveryLevel1__c = system.today()),
                                                  	
                                  							new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
																					Assessment__c = ASPISTestUtils.assessments[0].Id,
																					OfferType__c = 'BASIC',
																					RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
																					SLAInDeliveryLevel2__c = system.today())
        };
        insert prerequisiteOrders;	
        CaseDetailsProcessMapping__c caseMap1 = new CaseDetailsProcessMapping__c(Name = 'FR-SO-DELIVERYCONFIRMEDSLA1' ,Description__c = 'The delivery should be done last business day and the Bodyshop has not confirmed the delivery yet.', Due_Date_Duration__c = 1, Due_Date_Unity__c = 'D',Origin__c = 'APPLICATION' ,Priority__c = 'MEDIUM', Reason__c = 'DELIVERY' ,Short_Description__c = 'If the Bodyshop has not confirmed the delivery yet, 1 day after the estimated delivery date, create a Case to the admin.	', Subject__c = 'The Bodyshop has not confirmed the delivery yet.', Type__c = 'OTHER', Active__c= true);
	    insert caseMap1;
	    CaseDetailsProcessMapping__c caseMap2 = new CaseDetailsProcessMapping__c(Name = 'FR-SO-DELIVERYCONFIRMEDSLA2' ,Description__c = 'The delivery should be done last business day and the Bodyshop has not confirmed the delivery yet.', Due_Date_Duration__c = 1, Due_Date_Unity__c = 'D',Origin__c = 'APPLICATION' ,Priority__c = 'MEDIUM', Reason__c = 'DELIVERY' ,Short_Description__c = 'If the Bodyshop has not confirmed the delivery yet, 1 day after the estimated delivery date, create a Case to the admin.	', Subject__c = 'The Bodyshop has not confirmed the delivery yet.', Type__c = 'OTHER', Active__c= true);
	    insert caseMap2;
		system.runas(users[0]){
			test.starttest();
				ASPISBatchCreateCaseFromSalesOrder insertCase = new ASPISBatchCreateCaseFromSalesOrder();
				database.executebatch(insertCase);
			test.stoptest();
		}
		system.assertEquals(2 ,[select Id from Case__c where Id <> null].size());
		System.Debug('>>> End testinsertListCases');
	}

	static testMethod void testinsertListCasesStatusCanceled(){
		System.Debug('>>> Start testinsertListCasesStatusCanceled');
		proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);
		prerequisiteOrders= new list<PrerequisiteOrder__c>{new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
																					Assessment__c = ASPISTestUtils.assessments[0].Id,
																					RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
																					SLAInDeliveryLevel1__c = system.today(),
																					Status__c = 'CANCELED'),
                                                  	
                                  							new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
																					Assessment__c = ASPISTestUtils.assessments[0].Id,
																					OfferType__c = 'BASIC',
																					RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
																					SLAInDeliveryLevel2__c = system.today(),
																					Status__c = 'CANCELED')
        };
        insert prerequisiteOrders;	
        CaseDetailsProcessMapping__c caseMap1 = new CaseDetailsProcessMapping__c(Name = 'FR-SO-DELIVERYCONFIRMEDSLA1' ,Description__c = 'The delivery should be done last business day and the Bodyshop has not confirmed the delivery yet.', Due_Date_Duration__c = 1, Due_Date_Unity__c = 'D',Origin__c = 'APPLICATION' ,Priority__c = 'MEDIUM', Reason__c = 'DELIVERY' ,Short_Description__c = 'If the Bodyshop has not confirmed the delivery yet, 1 day after the estimated delivery date, create a Case to the admin.	', Subject__c = 'The Bodyshop has not confirmed the delivery yet.', Type__c = 'OTHER');
	    insert caseMap1;
	    CaseDetailsProcessMapping__c caseMap2 = new CaseDetailsProcessMapping__c(Name = 'FR-SO-DELIVERYCONFIRMEDSLA2' ,Description__c = 'The delivery should be done last business day and the Bodyshop has not confirmed the delivery yet.', Due_Date_Duration__c = 1, Due_Date_Unity__c = 'D',Origin__c = 'APPLICATION' ,Priority__c = 'MEDIUM', Reason__c = 'DELIVERY' ,Short_Description__c = 'If the Bodyshop has not confirmed the delivery yet, 1 day after the estimated delivery date, create a Case to the admin.	', Subject__c = 'The Bodyshop has not confirmed the delivery yet.', Type__c = 'OTHER');
	    insert caseMap2;
		system.runas(users[0]){
			test.starttest();
				ASPISBatchCreateCaseFromSalesOrder insertCase = new ASPISBatchCreateCaseFromSalesOrder();
				database.executebatch(insertCase);
			test.stoptest();
		}
		system.assertEquals(0 ,[select Id from Case__c where Id <> null].size());
		System.Debug('>>> End testinsertListCasesStatusCanceled');
	}
	*/
}