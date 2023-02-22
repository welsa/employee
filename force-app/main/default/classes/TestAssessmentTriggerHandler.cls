/*************************************************************************************
Class Name - TestAssessmentTriggerHandler
Version - 1.0
Created Date - 22 May 2015
Function - test class for AssessmentTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Kevan (sc)	     	22/05/2015  Original Version
* Bhavish (sc)			07/06/2015	Added test data and test methods
* Dourga (sc)           17/07/2015  Update test class
************************************************************************************/
@isTest
private class TestAssessmentTriggerHandler {
    /*static list <GlobalVariables__c> cs_GlobalVariables;
	static list <Account> accounts;
	static list <MasterRules__c> masterRuleList;
	static list <DetailRule__c> detailRuleList;
	static list<Assessment__c> assessments;
	static list<PurchaseOrder__c> purchaseOrders;
	static MasterRules__c ruleSet;
	static list<user> users;
	static map <String,Id> accRecordTypeMap;
	static map <String,Id> mRRecordTypeMap;
	static map <String,Id> dRRecordTypeMap;
	static {

		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
		mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
		dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);
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
        	//insert GlobalVariables custom settings
            cs_GlobalVariables = new list<GlobalVariables__c>{
                new GlobalVariables__c(
                    Object__c = 'Assessment__c'
                    ,Order__c ='1.1'
                    ,Type__c='Process'
                    ,Value__c = 'Eligibility'
                    ,Name='READY'
                )
            };
            insert cs_GlobalVariables;

        	accounts = new list<Account>{
        		new Account(Name='BodyShop_ScTest1'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
        			,ReferenceNumber__c = '123'
        			,ContactEmail__c = 'bt1@gmail.com'
        			,ShippingCountry = 'France'
        		),
        		new Account(Name='BodyShop_ScTest2'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
        			,ReferenceNumber__c = '1234'
        			,ContactEmail__c = 'bt2@gmail.com'
        			,ShippingCountry = 'United Kingdom'
        		),
        		new Account(Name='Distributor_ScTest1',
              				RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
      					    ReferenceNumber__c = '12345',
              				ContactEmail__c = 'dt1@gmail.com', 
                            DistributorNextInvoiceDate__c = date.today(),
                            DistributorInvoicePeriod__c = '15',
                            Categories__c='A'
        		)

        	};
        	insert accounts;

            masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'ELIGIBILITY' , 
                                                                          Entity__c = 'AXA Direct',
                                                                          Version__c = 1.1,
                                                                          sObject__c = 'Assessment__c',
                                                                          FilterLogic__c = '(1 OR 2)',
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE))
            											,new MasterRules__c(Process__c = 'ELIGIBILITY' , 
                                                                          Entity__c = 'AXA Direct1',
                                                                          Version__c = 1.1,
                                                                          sObject__c = 'Assessment__c',
                                                                          FilterLogic__c = '(1 AND 2)',
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE))
            											,new MasterRules__c(Process__c = 'ELIGIBILITY' , 
                                                                          Entity__c = 'AXA Direct2',
                                                                          Version__c = 1.1,
                                                                          sObject__c = 'Assessment__c',
                                                                          FilterLogic__c = '(1 AND 2)',
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE))
            };
            ASPISTestUtils.generateMasterRules(masterRuleList);

            detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'Entity__c', 
                                                                        Operator__c = 'EQUALS',
                                                                        Value__c = 'AXA Direct',
                                                                        Number__c = 1),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'Manufacturer__c', 
                                                                        Operator__c = 'IN',
                                                                        Value__c = 'RENAULT;CITROEN;TOYOTA;',
                                                                        Number__c = 2),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'Entity__c', 
                                                                        Operator__c = 'EQUALS',
                                                                        Value__c = 'AXA Direct1',
                                                                        Number__c = 1),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Account', 
                                                                        FieldsAPI__c = 'ShippingCountry', 
                                                                        Operator__c = 'EQUALS',
                                                                        ValueFrom__c = 'Master sObject',
                                                                        Value__c = 'FRANCE',
                                                                        Number__c = 2),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'Entity__c', 
                                                                        Operator__c = 'EQUALS',
                                                                        Value__c = 'AXA Direct3',
                                                                        Number__c = 1),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'PurchaseOrder__c', 
                                                                        FieldsAPI__c = 'PreviousStatus__c', 
                                                                        Operator__c = 'EQUALS',
                                                                        ValueFrom__c = 'Criteria sObject',
                                                                        Value__c = 'DRAFTQUOTE',
                                                                        Number__c = 2)
        	};
        	ASPISTestUtils.generateDetailRule(detailRuleList);

        	
            //insert assessments
            assessments = new list<Assessment__c>{
                new Assessment__c(Name='ASSESS_TEST-0001'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0001'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct'
                    ,MissionNumber__c = '01'
                    ,PortfolioAgentCode__c = '355'
                    ,AssessmentID__c = '0912'
                    ,TechExternalId__c = '233'
                    ,EntityRules__c = 'AXA Direct'
                    ,Manufacturer__c = 'RENAULT'
                    ,Status__c = 'NEW'
                ),
                
                new Assessment__c(Name='ASSESS_TEST-0002'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0002'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct1'
                    ,MissionNumber__c = '02'
                    ,PortfolioAgentCode__c = '3545'
                    ,AssessmentID__c = '5912'
                    ,EntityRules__c = 'AXA Direct1'
                    ,Status__c = 'NEW'
                ),

                new Assessment__c(Name='ASSESS_TEST-0003'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0003'
                    ,BodyShop__c = accounts[1].Id
                    ,Entity__c = 'AXA Direct2'
                    ,MissionNumber__c = '0267'
                    ,PortfolioAgentCode__c = '354577'
                    ,AssessmentID__c = '591274'
                    ,EntityRules__c = 'AXA Direct1'
                    ,Status__c = 'NEW'
                ),

                new Assessment__c(Name='ASSESS_TEST-0004'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0004'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct3'
                    ,MissionNumber__c = '0268'
                    ,PortfolioAgentCode__c = '354578'
                    ,AssessmentID__c = '591275'
                    ,EntityRules__c = 'AXA Direct2'
                    ,Status__c = 'NEW'
                ),

                new Assessment__c(Name='ASSESS_TEST-0005'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0005'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct3'
                    ,MissionNumber__c = '0269'
                    ,PortfolioAgentCode__c = '354579'
                    ,AssessmentID__c = '591276'
                    ,EntityRules__c = 'AXA Direct2'
                    ,Status__c = 'NEW'
                ),

                new Assessment__c(Name='ASSESS_TEST-0006'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0006'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct4'
                    ,MissionNumber__c = '0270'
                    ,PortfolioAgentCode__c = '354580'
                    ,AssessmentID__c = '591277'
                    ,EntityRules__c = 'AXA Direct3'
                    ,Status__c = 'NEW'
                )
            };
			insert assessments;

			purchaseOrders = new list<PurchaseOrder__c>{new PurchaseOrder__c(Distributor__c = accounts[2].Id,
          																  	ValidityDate__c=date.today(),
                              												Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                              								                SLAQuotationLevel1__c = date.today().addDays(2),
                              												SLAQuotationLevel2__c = date.today(),
                              												SLAQuotationLevel3__c = date.today().addDays(5),
                              												TECHSLAQuotationIsLevel1__c = false,
                              												TECHSLAQuotationIsLevel2__c = false,
                              												TECHSLAQuotationIsLevel3__c = false,
                                                                        	Assessment__c=assessments[3].id,
                                                                        	//BodyShop__c=accounts[0].id,
                                                                        	PreviousStatus__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
														,new PurchaseOrder__c(Distributor__c = accounts[2].Id,
          																  	ValidityDate__c=date.today(),
                              												Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
                                                                            SLAQuotationLevel1__c = date.today().addDays(2),
                              												SLAQuotationLevel2__c = date.today(),
                              												SLAQuotationLevel3__c = date.today().addDays(5),
                              												TECHSLAQuotationIsLevel1__c = false,
                              												TECHSLAQuotationIsLevel2__c = false,
                              												TECHSLAQuotationIsLevel3__c = false,
                                                                        	Assessment__c=assessments[4].id,
                                                                        	//BodyShop__c=accounts[0].id,
                                                                        	//ASE16102015:PreviousStatus__c =ASPISConstants.PUR_ORDER_STATUS_UNSUPPLIEDQUOTE,
                                                                        	PreviousStatus__c ='REJECTED.UNSUPPLIEDQUOTE')
			};
			insert purchaseOrders;
     	}	    
	}
	static testmethod void testAssessmentUpdate(){
		assessments[0].Status__c = ASPISConstants.ASSESS_STATUS_READY;
		test.startTest();
			update assessments;
		test.stopTest();
		Assessment__c assessment = [select Status__c 
									from Assessment__c 
									where Id =:assessments[0].id];
		System.assertEquals(ASPISConstants.ASSESS_STATUS_CHECKED, assessment.Status__c);
	}

	static testmethod void testAssessmentUpdate2(){
		assessments[1].Status__c = ASPISConstants.ASSESS_STATUS_READY;
		test.startTest();
			update assessments;
		test.stopTest();
		Assessment__c assessment = [select Status__c 
									from Assessment__c 
									where Id =:assessments[1].id];
		System.assertEquals(ASPISConstants.ASSESS_STATUS_CHECKED, assessment.Status__c);
	}

	static testmethod void testAssessmentUpdate3(){
		assessments[2].Status__c = ASPISConstants.ASSESS_STATUS_READY;
		test.startTest();
			update assessments;
		test.stopTest();
		Assessment__c assessment = [select Status__c 
									from Assessment__c 
									where Id =:assessments[2].id];
		System.assertEquals(ASPISConstants.ASSESS_STATUS_REJECTED, assessment.Status__c);
	}

	static testmethod void testAssessmentUpdate4(){
		assessments[3].Status__c = ASPISConstants.ASSESS_STATUS_READY;
		test.startTest();
			update assessments;
		test.stopTest();
		Assessment__c assessment = [select Status__c 
									from Assessment__c 
									where Id =:assessments[3].id];
		System.assertEquals(ASPISConstants.ASSESS_STATUS_CHECKED, assessment.Status__c);
	}

	static testmethod void testAssessmentUpdate5(){
		assessments[4].Status__c = ASPISConstants.ASSESS_STATUS_READY;
		test.startTest();
			update assessments;
		test.stopTest();
		Assessment__c assessment = [select Status__c 
									from Assessment__c 
									where Id =:assessments[4].id];
		System.assertEquals(ASPISConstants.ASSESS_STATUS_REJECTED, assessment.Status__c);
	}

	static testmethod void testAssessmentUpdate6(){
		assessments[5].Status__c = ASPISConstants.ASSESS_STATUS_READY;
		test.startTest();
			update assessments;
		test.stopTest();
		Assessment__c assessment = [select Status__c 
									from Assessment__c 
									where Id =:assessments[5].id];
		System.assertEquals(ASPISConstants.ASSESS_STATUS_REJECTED, assessment.Status__c);
	}*/
}