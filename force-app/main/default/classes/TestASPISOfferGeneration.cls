/*************************************************************************************
Class Name - TestASPISOfferGeneration
Version - 1.0
Created Date - 19 MAY 2015
Function - Test for class ASPISOfferGeneration
 
Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole (SC)    19/05/2015  Original Version
**************************************************************************************/
@isTest
private class TestASPISOfferGeneration {
/*
	static User userAdmin;
	static MasterRules__c ruleSet;
	static list<Assessment__c> assessments;
	static list <Account> accounts;
	static list<PurchaseOrder__c> purchaseOrders;
	static list<OrderLine__c> orderLines;
  public static list<PartList__c> partLists;
	static list <DetailRule__c> detailRuleList;
	static list <MasterRules__c> masterRuleList;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	static map <String,Id> mRRecordTypeMap = new map <String,Id>();
	static map <String,Id> dRRecordTypeMap = new map <String,Id>();
  static double val = 0;
  public static date myDate;


	static{

		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
		mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
		dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);
  
    myDate = date.newInstance(2015, 2, 17);

		userAdmin = new User(Username = 'jk@test.com',
		                     LastName = 'Jack',
		                     FirstName = 'Kurry',
		                     Email = 'KurryJack@test.com',
		                     Alias = 'KJac',
		                     LanguageLocaleKey = 'en_US',
		                     TimeZoneSidKey = 'Europe/Dublin',
		                     LocaleSidKey = 'en_US',
		                     EmailEncodingKey = 'UTF-8',
		                     ProfileId = ASPISConstants.getProfileAdminId()); 
		ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true, BypassTrigger__c = 'AP05;AP07');
        //ASPISTestUtils.setupBypassCustomSetting(true,true,'AP05;AP07','TestASPISOfferGeneration',userAdmin.Id);

        System.runAs(userAdmin){
    		ruleSet = new MasterRules__c(Process__c = 'Offering' , 
    								                Entity__c = 'AXA Direct',
                                    RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                    DifferenceThreshold__c = 15, 
                                    NeedThresholdComparison__c = true, 
                                    sObject__c = 'OrderLine__c', 
                                    FieldComparison__c = 'AXAProfit__c', 
                                    AggregateFunctionComparison__c = 'SUM',
    								                RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET));
    		insert ruleSet;

    		masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'QUICK' , 
                                                       					  Entity__c = 'AXA Direct',
                                                       					  Version__c = 1,
                                                                  IsPrimary__c = true,
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
    		Insert masterRuleList;

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
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'PartList__c', 
                                                                          Operator__c = 'GROUPBY',
                                                                          Number__c = 1),

                                                  new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                        Alias__c = 'MINEDD',
                                                                        Operator__c = 'AGMIN',
                                                                        Number__c = 2),

                                                  new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'AXAProfit__c', 
                                                                        Alias__c = 'MAXPROFIT',
                                                                        Operator__c = 'AGMAX',
                                                                        Number__c = 3),

                                                    new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MINEDD', 
                                                                        Operator__c = 'MIN',
                                                                        Number__c = 4),

                                                    new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MAXPROFIT',
                                                                        Operator__c = 'MAX',
                                                                        Number__c = 5),

                                                    new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'Id', 
                                                                          Operator__c = 'GROUPBY',
                                                                          Number__c = 6),

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


    		accounts = new list<Account>{new Account(Name='BodyShop_ScTest1',
    	      							        			 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
    	      							        			 ReferenceNumber__c = '123',
    	      							        			 ContactEmail__c = 'bt1@gmail.com'),

    						        		new Account(Name='Distributor_ScTest1',
    	      					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
    	      					        					ReferenceNumber__c = '12345',
    	      					        					ContactEmail__c = 'dt1@gmail.com'),

    						        		new Account(Name='Distributor_ScTest2',
    	      					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
    	      					        					ReferenceNumber__c = '12346',
    	      					        					ContactEmail__c = 'dt1@gmail.com'),

    						        		new Account(Name='Distributor_ScTest3',
    	      					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
    	      					        					ReferenceNumber__c = '12347',
    	      					        					ContactEmail__c = 'dt1@gmail.com'),


    						        		new Account(Name='Distributor_ScTest4',
    	      					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
    	      					        					ReferenceNumber__c = '123458',
    	      					        					ContactEmail__c = 'dt1@gmail.com')
            };
            //insert accounts;
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
                                                                             Status__c = 'ISSUED'),

    													new PurchaseOrder__c(Distributor__c = accounts[2].Id,
    																		 Assessment__c = assessments[0].Id,
                                                                             Status__c = 'ISSUED'),

    													new PurchaseOrder__c(Distributor__c = accounts[3].Id,
    																		 Assessment__c = assessments[0].Id,
                                                                             Status__c = 'ISSUED'),

    								                	new PurchaseOrder__c(Distributor__c = accounts[4].Id,
    								                						 Assessment__c = assessments[0].Id,
                                                                             Status__c = 'DRAFTQUOTE')
    		};
    		ASPISTestUtils.generatePurchaseOrder(purchaseOrders);

        partLists = new list<PartList__c>{new PartList__c(Assessment__c = assessments[0].Id,
                                                          Name = 'FRONT LWR AIR GRILLE',
                                                          PartNumber__c = '53102 47020',
                                                          HeldDate__c = myDate,
                                                          Price__c = 68,
                                                          Quantity__c = 1),

                                          new PartList__c(Assessment__c = assessments[0].Id,
                                                          Name = 'FRONT LWR AIR GRILLE2',
                                                          PartNumber__c = '53102 47022',
                                                          HeldDate__c = myDate,
                                                          Price__c = 62,
                                                          Quantity__c = 1)
        };
        ASPISTestUtils.generatePartList(partLists);

		}
	}
	
	static testMethod void generateOffersTest() {
    	System.Debug('>>> Start generateOffersTest');
        System.runAs(userAdmin){
          ruleSet.AggregateFunctionComparison__c = 'COUNT';
          update ruleSet;
          insert  detailRuleList;
        	orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 12,
    															 Suppliable__c =  'Yes',
    															 OrderType__c = 'FINAL',
			  					                                 Quantity__c = 1,
                                                                 PartList__c = partLists[0].Id),

    											new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
			  					                                 Quantity__c = 1,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 12,
    															 Suppliable__c =  'No',
                                   OrderType__c = 'FINAL',
                                   PartList__c = partLists[1].Id)
    		};
    		insert orderLines;
            list <OrderLine__c> orderLinesBundle = new list <OrderLine__c> {new OrderLine__c(OriginalItem__c = orderLines[0].Id,
                                                                                             PurchaseOrder__c = purchaseOrders[0].Id,
                                                                                             CataloguePrice__c  = 10,
                                                                                             OrderType__c = 'BUNDLEITEM',
			  					                                 							 Quantity__c = 1,
                                                                                             PartList__c = partLists[0].Id),

                                                                            new OrderLine__c(OriginalItem__c = orderLines[0].Id,
                                                                                             PurchaseOrder__c = purchaseOrders[0].Id,
                                                                                             CataloguePrice__c  = 2,
			  					                                 							 Quantity__c = 1,
                                                                                             OrderType__c = 'BUNDLEITEM',
                                                                                             PartList__c = partLists[0].Id)
            };
            insert orderLinesBundle;
            //system.debug('## orderLines ' + orderLines);
            test.starttest();  
            	ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
            	a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),4);
        System.Debug('>>> End generateOffersTest');
    }

    static testMethod void generateOffersNotSuppliableTest() {
      System.Debug('>>> Start generateOffersNotSuppliableTest');
      System.runAs(userAdmin){

          ruleSet.AggregateFunctionComparison__c = 'MIN';
          update ruleSet;

          insert  detailRuleList;
          orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                   ExpectedDeliveryDuration__c = '1',
                                   CataloguePrice__c  = 12,
                                   Suppliable__c =  'No',
                                   OrderType__c = 'FINAL',
			  					   Quantity__c = 1,
                                   PartList__c = partLists[0].Id),

                          new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
                                   ExpectedDeliveryDuration__c = '1',
                                   CataloguePrice__c  = 12,
			  					   Quantity__c = 1,
                                   Suppliable__c =  'No',
                                   OrderType__c = 'FINAL',
                                   PartList__c = partLists[0].Id)
          };
          insert orderLines;
          //system.debug('## orderLines ' + orderLines);
          test.starttest();  
            ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
            a_Offer.executeProcess(assessments[0]);
          test.stoptest();  
      }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),0);
        System.Debug('>>> End generateOffersNotSuppliableTest');
    }

    static testMethod void generateOffersCreateCaseTest() {
      System.Debug('>>> Start generateOffersNotSuppliableTest');
      System.runAs(userAdmin){

          insert  detailRuleList;
          test.starttest();  
            ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
            a_Offer.executeProcess(assessments[0]);
          test.stoptest();  
      }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),0);
        System.Debug('>>> End generateOffersNotSuppliableTest');
    }
    static testMethod void generateOffers2POTest() {
    	System.Debug('>>> Start generateOffers2POTest');
        System.runAs(userAdmin){

          ruleSet.AggregateFunctionComparison__c = 'MAX';
          update ruleSet;

          insert  detailRuleList;
        	orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 10,
    															 Suppliable__c =  'Yes',
    															 OrderType__c = 'FINAL',
                                   PartList__c = partLists[0].Id),
    											new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
    															 ExpectedDeliveryDuration__c = '2',
    															 CataloguePrice__c  = 12,
    															 Suppliable__c =  'No',
                                   OrderType__c = 'FINAL',
                                   PartList__c = partLists[0].Id)
    		};
    		ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
            	ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
            	a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
    //@CLA    system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null ].size(),4);
        System.Debug('>>> End generateOffers2POTest');
    }

    static testMethod void generateOffers4POTest() {
    	System.Debug('>>> Start generateOffers4POTest');
        System.runAs(userAdmin){

            insert  detailRuleList;
        	orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 10,
    															 Suppliable__c =  'Yes',
    															 OrderType__c = 'FINAL',
                                   PartList__c = partLists[0].Id),
    											new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 10,
    															 Suppliable__c =  'No',
                                   OrderType__c = 'FINAL',
                                   PartList__c = partLists[0].Id),
    											new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 12,
    															 Suppliable__c =  'Yes',
    															 OrderType__c = 'FINAL',
                                   PartList__c = partLists[0].Id),
    											new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
    															 ExpectedDeliveryDuration__c = '1',
    															 CataloguePrice__c  = 12,
    															 Suppliable__c =  'No',
                                   OrderType__c = 'FINAL',
                                   PartList__c = partLists[1].Id)
    		};
    		ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
            	ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
            	a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
    //@CLA    system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),3);
        System.Debug('>>> End generateOffers4POTest');
    }

    static testMethod void generateOffersQuickTest() {
        System.Debug('>>> Start generateOffersQuickTest');
        System.runAs(userAdmin){
            delete masterRuleList[1];
            delete masterRuleList[2];
            delete masterRuleList[3];
            list <DetailRule__c> detailRuleList2 = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
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
                                                                                            Operator__c = 'MAX'),

                                                                            new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                            RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                            Process__c = 'Offering', 
                                                                                            sObject__c = 'OrderLine__c', 
                                                                                            FieldsAPI__c = 'SUMAXAP', 
                                                                                            Operator__c = 'MAX'),

                                                                            new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                            RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                            Process__c = 'Offering', 
                                                                                            sObject__c = 'OrderLine__c', 
                                                                                            FieldsAPI__c = 'SUMTECHIS/COUNTId', 
                                                                                            Operator__c = 'EQUALS',
                                                                                            Value__c = '0.90')
            };
            insert  detailRuleList2;
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
                                                                 ExpectedDeliveryDuration__c = '2',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
                ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
                a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),2);
        System.Debug('>>> End generateOffersQuickTest');
    }

    static testMethod void generateOffersQuick3Test() {
        System.Debug('>>> Start generateOffersQuick3Test');
        System.runAs(userAdmin){
            delete masterRuleList[1];
            delete masterRuleList[2];
            delete masterRuleList[3];
            list <DetailRule__c> detailRuleList2 = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
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
                                                                                            Value__c = '0.90')
            };
            insert  detailRuleList2;
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 8,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '2',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '2',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
                ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
                a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),1);
        System.Debug('>>> End generateOffersQuick3Test');
    }

    static testMethod void generateOffersQuick2Test() {
        System.Debug('>>> Start generateOffersQuick2Test');
        System.runAs(userAdmin){
            delete masterRuleList[1];
            delete masterRuleList[2];
            delete masterRuleList[3];
            list <DetailRule__c> detailRuleList2 = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
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
                                                                                            Operator__c = 'MAX'),

                                                                            new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                            RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                            Process__c = 'Offering', 
                                                                                            sObject__c = 'OrderLine__c', 
                                                                                            FieldsAPI__c = 'SUMAXAP', 
                                                                                            Operator__c = 'MAX'),

                                                                            new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                            RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                            Process__c = 'Offering', 
                                                                                            sObject__c = 'OrderLine__c', 
                                                                                            FieldsAPI__c = 'SUMTECHIS/COUNTId', 
                                                                                            Operator__c = 'EQUALS',
                                                                                            Value__c = '0.90')
            };
            insert  detailRuleList2;
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
                ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
                a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),2);
        System.Debug('>>> End generateOffersQuick2Test');
    }

    static testMethod void generateOffersGreaterTest() {
        System.Debug('>>> Start generateOffersGreaterTest');
        System.runAs(userAdmin){
            delete masterRuleList[1];
            delete masterRuleList[2];
            delete masterRuleList[3];
            list <DetailRule__c> detailRuleList2 = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                                                Alias__c = 'MAXEDD',
                                                                                                Operator__c = 'AGMIN'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                                                Alias__c = 'SUMTECHIS',
                                                                                                Operator__c = 'AGCOUNT'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'AXAProfit__c', 
                                                                                                Alias__c = 'MAXPROFIT',
                                                                                                Operator__c = 'AGMAX'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'Id', 
                                                                                                Alias__c = 'COUNTID',
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
                                                                                                FieldsAPI__c = 'SUMTECHIS/COUNTID', 
                                                                                                Operator__c = 'GREATER',
                                                                                                Value__c = '0.90'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXEDD',
                                                                                                Operator__c = 'LESS',
                                                                                                Value__c = '1'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXPROFIT', 
                                                                                                Operator__c = 'GREATER',
                                                                                                Value__c = '1')
            };
            insert  detailRuleList2;
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
                ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
                a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),0);
        System.Debug('>>> End generateOffersGreaterTest');
    }

    static testMethod void generateOffersGreaterEqualTest() {
        System.Debug('>>> Start generateOffersGreaterEqualTest');
        System.runAs(userAdmin){
            delete masterRuleList[1];
            delete masterRuleList[2];
            delete masterRuleList[3];
            list <DetailRule__c> detailRuleList2 = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                                                Alias__c = 'MAXEDD',
                                                                                                Operator__c = 'AGMIN'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                                                Alias__c = 'SUMTECHIS',
                                                                                                Operator__c = 'AGCOUNT'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'AXAProfit__c', 
                                                                                                Alias__c = 'MAXPROFIT',
                                                                                                Operator__c = 'AGMAX'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'Id', 
                                                                                                Alias__c = 'COUNTID',
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
                                                                                                FieldsAPI__c = 'SUMTECHIS/COUNTID', 
                                                                                                Operator__c = 'GREATER_EQUALS',
                                                                                                Value__c = '0.90'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXEDD',
                                                                                                Operator__c = 'LESS',
                                                                                                Value__c = '1'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXPROFIT', 
                                                                                                Operator__c = 'GREATER_EQUALS',
                                                                                                Value__c = '1')
            };
            insert  detailRuleList2;
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 10,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
                ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
                a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),0);
        System.Debug('>>> End generateOffersGreaterEqualTest');
    }

    static testMethod void generateOffersLessTest() {
        System.Debug('>>> Start generateOffersLessTest');
        System.runAs(userAdmin){
            delete masterRuleList[1];
            delete masterRuleList[2];
            delete masterRuleList[3];
            list <DetailRule__c> detailRuleList2 = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                                                Alias__c = 'MAXEDD',
                                                                                                Operator__c = 'AGMIN'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                                                Alias__c = 'SUMTECHIS',
                                                                                                Operator__c = 'AGCOUNT'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'AXAProfit__c', 
                                                                                                Alias__c = 'MAXPROFIT',
                                                                                                Operator__c = 'AGMAX'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'Id', 
                                                                                                Alias__c = 'COUNTID',
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
                                                                                                FieldsAPI__c = 'SUMTECHIS/COUNTID', 
                                                                                                Operator__c = 'LESS',
                                                                                                Value__c = '0.90'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXEDD',
                                                                                                Operator__c = 'LESS',
                                                                                                Value__c = '1'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXPROFIT', 
                                                                                                Operator__c = 'LESS',
                                                                                                Value__c = '1')
            };
            insert  detailRuleList2;
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '0.8',
                                                                 CataloguePrice__c  = 0.10,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[1].Id,
                                                                 ExpectedDeliveryDuration__c = '0.7',
                                                                 CataloguePrice__c  = 0.08,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '0.6',
                                                                 CataloguePrice__c  = 0.12,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '0.6',
                                                                 CataloguePrice__c  = 0.12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
                ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
                a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),2);
        System.Debug('>>> End generateOffersLessTest');
    }

    static testMethod void generateOffersLessEqualsTest() {
        System.Debug('>>> Start generateOffersLessEqualsTest');
        System.runAs(userAdmin){
            delete masterRuleList[1];
            delete masterRuleList[2];
            delete masterRuleList[3];
            list <DetailRule__c> detailRuleList2 = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                                                Alias__c = 'MAXEDD',
                                                                                                Operator__c = 'AGMIN'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                                                Alias__c = 'SUMTECHIS',
                                                                                                Operator__c = 'AGCOUNT'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'AXAProfit__c', 
                                                                                                Alias__c = 'MAXPROFIT',
                                                                                                Operator__c = 'AGMAX'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'Id', 
                                                                                                Alias__c = 'COUNTID',
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
                                                                                                FieldsAPI__c = 'SUMTECHIS/COUNTID', 
                                                                                                Operator__c = 'LESS_EQUALS',
                                                                                                Value__c = '0.50'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXEDD',
                                                                                                Operator__c = 'LESS_EQUALS',
                                                                                                Value__c = '1'),

                                                                                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                                                RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                                                Process__c = 'Offering', 
                                                                                                sObject__c = 'OrderLine__c', 
                                                                                                FieldsAPI__c = 'MAXPROFIT', 
                                                                                                Operator__c = 'LESS_EQUALS',
                                                                                                Value__c = '1')
            };
            insert  detailRuleList2;
            orderLines = new list<OrderLine__c>{new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 0.10,
                                                                 Suppliable__c =  'Yes',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[0].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 0.08,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 0.12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL'),
                                                new OrderLine__c(PurchaseOrder__c = purchaseOrders[2].Id,
                                                                 ExpectedDeliveryDuration__c = '1',
                                                                 CataloguePrice__c  = 0.12,
                                                                 Suppliable__c =  'No',
                                                                 OrderType__c = 'FINAL')
            };
            ASPISTestUtils.generateOrderLine(orderLines);
            test.starttest();  
                ASPISOfferGeneration a_Offer = new ASPISOfferGeneration ();
                a_Offer.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select OrderLine__c from Offer__c where OrderLine__c != null].size(),2);
        System.Debug('>>> End generateOffersLessEqualsTest');
    }

    static testMethod void evalDivTest() {
        System.Debug('>>> Start evalDivTest');
        System.runAs(userAdmin){
            test.starttest();  
                ASPISParser  a_Parser = new ASPISParser  ();
                val = a_Parser.evalDouble('6/3');
            test.stoptest();  
        }//end system.runas
        system.assertEquals(val,2.0);
        System.Debug('>>> End evalDivTest');
    }

    static testMethod void evalMulTest() {
        System.Debug('>>> Start evalMulTest');
        System.runAs(userAdmin){
            test.starttest();  
                ASPISParser  a_Parser = new ASPISParser  ();
                val = a_Parser.evalDouble('2*3');
            test.stoptest();  
        }//end system.runas
        system.assertEquals(val,6.0);
        System.Debug('>>> End evalMulTest');
    }

    static testMethod void evalAddTest() {
        System.Debug('>>> Start evalAddTest');
        System.runAs(userAdmin){
            test.starttest();  
                ASPISParser  a_Parser = new ASPISParser  ();
                val = a_Parser.evalDouble('5+8');
            test.stoptest();  
        }//end system.runas
        system.assertEquals(val,13.0);
        System.Debug('>>> End evalAddTest');
    }

    static testMethod void evalSubTest() {
        System.Debug('>>> Start evalSubTest');
        System.runAs(userAdmin){
            test.starttest();  
                ASPISParser  a_Parser = new ASPISParser  ();
                val = a_Parser.evalDouble('6-3');
            test.stoptest();  
        }//end system.runas
        system.assertEquals(val,3.0);
        System.Debug('>>> End evalSubTest');
    }*/
}