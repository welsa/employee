/*************************************************************************************
Class Name - TestASPISServiceOffering
Version - 1.0
Created Date - 22 May 2015
Function - test class for ASPISServiceOffering

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Kevan (sc)	     	22/05/2015  Original Version
* Bhavish (sc)			03/05/2015  Added test data and assertion
************************************************************************************/
@isTest
private class TestASPISServiceOffering {
	// ABT - 02-DEC-2016 - C-001625
	/*
	static list<user> users;
	static MasterRules__c ruleSet;
	static list<Assessment__c> assessments;
	static list <Account> accounts;
	static list<PurchaseOrder__c> purchaseOrders;
	static list<OrderLine__c> orderLines;
	static list <DetailRule__c> detailRuleList;
	static list <MasterRules__c> masterRuleList;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	static map <String,Id> mRRecordTypeMap = new map <String,Id>();
	static map <String,Id> dRRecordTypeMap = new map <String,Id>();

	static {
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
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true,BypassTrigger__c = 'AP05;AP07');
	  	system.runas(users[0]){
	  		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
			mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
			dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);
			ruleSet = new MasterRules__c(Process__c = 'Offering' , 
    								      Entity__c = 'AXA Direct',
                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
    								      RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET));
    		insert ruleSet;

    		masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'QUICK' , 
                                                       					  Entity__c = 'AXA Direct',
                                                       					  Version__c = 1,
                                                       					  RuleSet__c = ruleSet.Id,
                                                       					  RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                       					  RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)),

                                                       new MasterRules__c(Process__c = 'OPPORTUNITY' , 
                                                                          Entity__c = 'AXA Direct',
                                                                          Version__c = 1,
                                                                          RuleSet__c = ruleSet.Id,
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)),

                                                       new MasterRules__c(Process__c = 'BASIC' , 
                                                       					  Entity__c = 'AXA Direct',
                                                       					  Version__c = 1,
                                                       					  RuleSet__c = ruleSet.Id,
                                                       					  RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                       					  RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)),

                                                       new MasterRules__c(Process__c = 'QUICK1' , 
                                                                          Entity__c = 'AXA Direct',
                                                                          Version__c = 1,
                                                                          RuleSet__c = ruleSet.Id,
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE))
            };
    		ASPISTestUtils.generateMasterRules(masterRuleList);

    		detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
            															Alias__c = 'MAXEDD',
            															Operator__c = 'AGMAX'),

    													new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'TECHIsSuppliable__c', 
            															Alias__c = 'SUMTECHIS',
            															Operator__c = 'AGSUM'),

    													new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'AXAPrice__c', 
            															Alias__c = 'SUMAXAP',
            															Operator__c = 'AGAVG'),

    													new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'Id', 
            															Alias__c = 'COUNTId',
            															Operator__c = 'AGCOUNT'),

    													new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'PurchaseOrder__c',
            															Operator__c = 'GROUPBY'),

    													new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'MAXEDD',
            															Operator__c = 'MIN'),

    													new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'SUMAXAP', 
            															Operator__c = 'MIN'),

    													new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'SUMTECHIS/COUNTId', 
            															Operator__c = 'EQUALS',
            															Value__c = '1'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
            															Alias__c = 'MAXEDD',
            															Operator__c = 'AGMIN'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'TECHIsSuppliable__c', 
            															Alias__c = 'SUMTECHIS',
            															Operator__c = 'AGCOUNT'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'AXAProfit__c', 
            															Alias__c = 'MAXPROFIT',
            															Operator__c = 'AGMAX'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'Id', 
            															Alias__c = 'COUNTID',
            															Operator__c = 'AGCOUNT'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'PurchaseOrder__c',
            															Operator__c = 'GROUPBY'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'SUMTECHIS/COUNTID', 
            															Operator__c = 'GREATER_EQUALS',
            															Value__c = '0.90'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'MAXEDD',
            															Operator__c = 'LESS_EQUALS',
                                                                        Value__c = '1'),

    													new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
            															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
            															Process__c = 'Offering', 
            															sObject__c = 'OrderLine__c', 
            															FieldsAPI__c = 'MAXPROFIT', 
            															Operator__c = 'GREATER',
                                                                        Value__c = '1'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                        Alias__c = 'MAXEDD',
                                                                        Operator__c = 'AGMIN'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                        Alias__c = 'SUMTECHIS',
                                                                        Operator__c = 'AGCOUNT'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'AXAProfit__c', 
                                                                        Alias__c = 'MAXPROFIT',
                                                                        Operator__c = 'AGMAX'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'Id', 
                                                                        Alias__c = 'COUNTID',
                                                                        Operator__c = 'AGCOUNT'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'PurchaseOrder__c',
                                                                        Operator__c = 'GROUPBY'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'SUMTECHIS/COUNTID', 
                                                                        Operator__c = 'GREATER',
                                                                        Value__c = '0.90'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MAXEDD',
                                                                        Operator__c = 'LESS',
                                                                        Value__c = '1'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MAXPROFIT', 
                                                                        Operator__c = 'LESS_EQUALS',
                                                                        Value__c = '1'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                        Alias__c = 'MAXEDD',
                                                                        Operator__c = 'AGMAX'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                        Alias__c = 'SUMTECHIS',
                                                                        Operator__c = 'AGSUM'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'AXAPrice__c', 
                                                                        Alias__c = 'SUMAXAP',
                                                                        Operator__c = 'AGAVG'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'Id', 
                                                                        Alias__c = 'COUNTId',
                                                                        Operator__c = 'AGCOUNT'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'PurchaseOrder__c',
                                                                        Operator__c = 'GROUPBY'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MAXEDD',
                                                                        Operator__c = 'MAX'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'SUMAXAP', 
                                                                        Operator__c = 'MIN'),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'SUMTECHIS/COUNTId', 
                                                                        Operator__c = 'EQUALS',
                                                                        Value__c = '0.90')


    		};
    		ASPISTestUtils.generateDetailRule(detailRuleList);

    		

    		accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
    	      							        			 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
    	      							        			 ReferenceNumber__c = '123',
    	      							        			 ContactEmail__c = 'bt1@gmail.com'),

    						        		new Account(Name='Distributor_ScTest1',
    	      					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
    	      					        					ReferenceNumber__c = '12345',
    	      					        					ContactEmail__c = 'dt1@gmail.com')
            };
            ASPISTestUtils.generateAccount(accounts);

    		assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0001',
    				                                       AssessmentNumber__c = 'ASSESS_TEST-0001',
    				                                       BodyShop__c = accounts[0].Id,
    				                                       EntityRules__c = 'AXA Direct',
    				                                       MissionNumber__c = '01',
    				                                       PortfolioAgentCode__c = '355',
    				                                       AssessmentID__c = '0912',
    				                                       TechExternalId__c = '233')
    		};
    		ASPISTestUtils.generateAssessment(assessments);

    		purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[1].Id,
    																		 Assessment__c = assessments[0].Id,
                                                                             Status__c = 'ISSUED')
    		};
    		ASPISTestUtils.generatePurchaseOrder(purchaseOrders);
    		orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 12,
    															 Suppliable__c =  'Yes',
    															 OrderType__c = 'FINAL'),

    											new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 12,
    															 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
    		};
    		ASPISTestUtils.generateOrderLine(orderLines);	
  		}
	}

	static testMethod void testProcess(){
		System.runAs(users[0]){
			ASPISServiceOffering soffer = new ASPISServiceOffering();
			test.starttest();
				soffer.executeProcess(assessments[0]);
			test.stoptest();
			system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),8);
		}
	}
	*/
}