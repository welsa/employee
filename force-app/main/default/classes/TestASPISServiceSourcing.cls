/*************************************************************************************
Class Name - TestASPISServiceSourcing
Version - 1.0
Created Date - 21 MAY 2015
Function - Test for class ASPISServiceSourcing

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole (SC)    21/05/2015  Original Version
* yudish ramdowar (SC)  14/07/2015  Updated Version
* Dourga Unmole		    19/01/2016  Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
**************************************************************************************/
@isTest
private class TestASPISServiceSourcing {
	/*static User userAdmin;
	static MasterRules__c ruleSet;
	//static list<Assessment__c> assessments;
	//static list <Account> accounts;
	static list <DetailRule__c> detailRuleList;
	static list <MasterRules__c> masterRuleList;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	static map <String,Id> mRRecordTypeMap = new map <String,Id>();
	static map <String,Id> dRRecordTypeMap = new map <String,Id>();
	static SLAConfiguration__c slaRecord;
	static BusinessHours defaultHours;    
	static list <CountryCodeInformationsMapping__c> countryCodeInfos;
	
	static{

		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
		mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
		dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);

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

        System.runAs(userAdmin){
        	//ASPISTestUtils.generateBasicTestData();
        	defaultHours = [select Id,Name from BusinessHours where IsDefault=true];
            
        	// custom settings - CountryCodeInfo
	        countryCodeInfos = new list<CountryCodeInformationsMapping__c>{
	            new CountryCodeInformationsMapping__c(
	                Name='FR'
	                ,BusinessHoursID__c = defaultHours.Id
	            ),
	             new CountryCodeInformationsMapping__c(
	                Name='DEFAULT'
	                ,BusinessHoursID__c = defaultHours.Id
	            )
	        };
	        insert countryCodeInfos;

        	slaRecord= new SLAConfiguration__c (BusinessHoursID__c=defaultHours.Id ,
                                          Name='FR-PO-QUOTATION-AXADirect' ,
                                          SLALevel1Minute__c=30 ,
                                          SLALevel2Minute__c=60 ,
                                          SLALevel3Minute__c=90 ,
                                          Entity__c= 'AXA Direct' ,
                                          Object__c = 'Purchase Order');
      		insert slaRecord;

			masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'Sourcing' , 
	                                                   					  Entity__c = 'AXA Direct',
	                                                   					  Version__c = 1,
	                                                   					  sObject__c = 'Assessment__c',
	                                                   					  FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5)',
	                                                   					  RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
	                                                   					  RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE))
			};

			Insert masterRuleList;

			detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
	        															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
	        															Process__c = 'Sourcing', 
	        															sObject__c = 'Account', 
	        															Fields__c = 'ShippingCountry', 
	        															Operator__c = 'EQUALS',
	        															ValueFrom__c = 'Master sObject',
	        															Value__c = 'BodyShop__r.ShippingCountry'),

														new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
	        															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
	        															Process__c = 'Sourcing', 
	        															sObject__c = 'Account', 
	        															Fields__c = 'RecordType.Name', 
	        															Operator__c = 'EQUALS',
	        															ValueFrom__c = 'Criteria sObject',
	        															Value__c = 'DISTRIBUTOR'),

														new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
	        															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
	        															Process__c = 'Sourcing', 
	        															sObject__c = 'Account', 
	        															Fields__c = 'DistributorCarBrandSupplied__c', 
	        															Operator__c = 'IN',
	        															ValueFrom__c = 'Master sObject',
	        															Value__c = 'Manufacturer__c'),

														new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
	        															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
	        															Process__c = 'Sourcing', 
	        															sObject__c = 'Account', 
	        															Fields__c = 'Categories__c', 
	        															Operator__c = 'IN',
	        															ValueFrom__c = 'Master sObject',
	        															Value__c = 'PartTypes__c'),

														new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
	        															RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
	        															Process__c = 'Sourcing', 
	        															sObject__c = 'Account', 
	        															Fields__c = 'DistributorRegionsCovered__c',
	        															Operator__c = 'IN',
	        															ValueFrom__c = 'Master sObject',
	        															Value__c = 'BodyShop__r.ShippingPostalCodeLeft2__c')
			};
	   		insert  detailRuleList;
		}

	}
	
	static testMethod void sourcingTest() {
    	System.Debug('>>> Start sourcingTest');
        System.runAs(userAdmin){

			list <Account> accounts = new list<Account>{new Account(Name='BodyShop_ScTest12',
  							        			 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
  							        			 ReferenceNumber__c = '9123',
  							        			 ContactEmail__c = 'bt1@gmail.com'),

				        		new Account(Name='Distributor_ScTest12',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '912345',
  					        					ContactEmail__c = 'dt1@gmail.com'),

				        		new Account(Name='Distributor_ScTest22',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '912346',
  					        					ContactEmail__c = 'dt1@gmail.com'),

				        		new Account(Name='Distributor_ScTest32',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '912347',
  					        					ContactEmail__c = 'dt1@gmail.com'),


				        		new Account(Name='Distributor_ScTest42',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '9123458',
  					        					ContactEmail__c = 'dt1@gmail.com')
	        };
	        ASPISTestUtils.generateAccount(accounts);

			list<Assessment__c> assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-000123',
					                                       AssessmentNumber__c = 'ASSESS_TEST-000123',
					                                       BodyShop__c = accounts[0].Id,
					                                       EntityRules__c = 'AXA Direct',
					                                       MissionNumber__c = '012',
														   TECH_EntityCountryCode__c = 'FR',
					                                       PortfolioAgentCode__c = '3552',
					                                       AssessmentID__c = '09122',
					                                       TechExternalId__c = '2332',
					                                       TECHRulesAppliedDescription__c='Test')
			};
			ASPISTestUtils.generateAssessment(assessments);

            test.starttest();  
            	ASPISServiceSourcing a_Sourcing = new ASPISServiceSourcing ();
            	a_Sourcing.executeProcess(assessments[0]);
            test.stoptest();  
        }//end system.runas
        system.assertEquals(4,[select Id from PurchaseOrder__c where Id != null].size());
        System.Debug('>>> End sourcingTest');
    }


	static testMethod void sourcingCreateCaseTest() {
    	System.Debug('>>> Start sourcingCreateCaseTest');
        System.runAs(userAdmin){
        	list<Assessment__c> assessmentsV1;
        	list <Account> accountsV1;

			accountsV1 = new list<Account>{new Account(Name='BodyShop_ScTest12',
  							        			 RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
  							        			 ReferenceNumber__c = '9123',
  							        			 ShippingCountryCode = 'FR',
  							        			 ContactEmail__c = 'bt1@gmail.com'),

				        		new Account(Name='Distributor_ScTest12',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '912345',
  					        					DistributorCarBrandSupplied__c = 'Test1',
  					        					ContactEmail__c = 'dt1@gmail.com'),

				        		new Account(Name='Distributor_ScTest22',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '912346',
  					        					DistributorCarBrandSupplied__c = 'Test2',
  					        					ContactEmail__c = 'dt1@gmail.com'),

				        		new Account(Name='Distributor_ScTest32',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '912347',
  					        					DistributorCarBrandSupplied__c = 'Test3',
  					        					ContactEmail__c = 'dt1@gmail.com'),


				        		new Account(Name='Distributor_ScTest42',
  					        					RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
  					        					ReferenceNumber__c = '9123458',
  					        					DistributorCarBrandSupplied__c = 'Test4',
  					        					ContactEmail__c = 'dt1@gmail.com')
	        };
	        ASPISTestUtils.generateAccount(accountsV1);
	        accountsV1[0].ShippingCountryCode = 'FR';
			update accountsV1;
			
			assessmentsV1 = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-000123',
					                                       AssessmentNumber__c = 'ASSESS_TEST-000123',
					                                       BodyShop__c = accountsV1[0].Id,
					                                       EntityRules__c = 'AXA Direct',
					                                       MissionNumber__c = '012',
					                                       PortfolioAgentCode__c = '3552',
														   TECH_EntityCountryCode__c = 'FR',
					                                       AssessmentID__c = '09122',
					                                       TechExternalId__c = '2332',
					                                       TECHRulesAppliedDescription__c='Test')
			};
			ASPISTestUtils.generateAssessment(assessmentsV1);
			

			Assessment__c assrec = [select Id,TECH_EntityCountryCode__c,Name,AssessmentNumber__c,BodyShop__c,
									EntityRules__c,MissionNumber__c,PortfolioAgentCode__c,AssessmentID__c,TechExternalId__c,TECHRulesAppliedDescription__c 
									from Assessment__c 
									where Id=:assessmentsV1[0].Id];
			//system.debug('assrec:'+ assrec);

			CaseDetailsProcessMapping__c caseDetails = new CaseDetailsProcessMapping__c(
				Name = 'FR-ASS-Sourcing',
				Short_Description__c = 'Generate a Case if the sourcing process has returned no result.',
				Origin__c = 'APPLICATION',
				Type__c = 'PROBLEM',
				Priority__c = 'MEDIUM',
				Reason__c = 'DELIVERY',
				Subject__c = 'Action requise : Le sourcing des offres rien donné.',
				Description__c = 'Le sourcing na donné aucun resultat.Veuillez verifier les criteres.',
				Due_Date_Duration__c=2,
				Due_Date_Unity__c = 'H'
			);
			insert caseDetails;

            test.starttest();  
            	ASPISServiceSourcing a_Sourcing = new ASPISServiceSourcing ();
            	a_Sourcing.executeProcess(assrec);
            test.stoptest();  

            system.assertEquals(0,[select Id from PurchaseOrder__c where Id != null].size());
        }//end system.runas

        System.Debug('>>> End sourcingCreateCaseTest');
    }*/
}