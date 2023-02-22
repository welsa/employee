/*************************************************************************************
Class Name - TestASPISServiceEligibility
Version - 1.0
Created Date - 05 June 2015
Function - TestClass for ASPISServiceEligibility

Modification Log : 
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Yudish R      05/06/2015  Original Version
* Dourga U      14/07/2015  Updated the test class
* Yudish R      21/07/2015  Updated the test class - coverage on ASPIS TOOLS And Natural Language
* Dourga U      24/11/2015  Updated the test class for case C-001210
*************************************************************************************/
@isTest
private class TestASPISServiceEligibility {
    
    /*static User userAdmin;
    static list<Account> accounts;
    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static list<Assessment__c> assessments;
    static list <GlobalVariables__c> cs_GlobalVariables;
    static list <MasterRules__c> masterRuleList;
    static list <DetailRule__c> detailRuleList;
    static map <String,Id> mRRecordTypeMap = new map <String,Id>();
    static map <String,Id> dRRecordTypeMap = new map <String,Id>();
    static list<PartList__c> partLists;
    public static date myDate;
    static BusinessHours defaultHours;
    

    static list <CountryCodeInformationsMapping__c> countryCodeInfos;

    static{
        accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
        mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
        dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);
        
        //ASPISTestUtils.generateBasicTestData();
        
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
            // insert accounts
            accounts = new list<Account>{
                new Account(Name='BodyShop_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '1238'
                    ,ContactEmail__c = 'bt1@gmail.com'
                    ,isEligible__c = true
                ),
                new Account(Name='BodyShop_ScTest2'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '12834'
                    ,ContactEmail__c = 'bt2@gmail.com'
					,CarBrandExcluded__c = 'AUDI'
                )
            };
            //insert accounts;
            ASPISTestUtils.generateAccount (accounts);

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];
            
            //insert GlobalVariables custom settings
            cs_GlobalVariables = new list<GlobalVariables__c>{
                new GlobalVariables__c(
                    Object__c = 'Assessment__c'
                    ,Order__c ='1.1'
                    ,Type__c='Process'
                    ,Value__c = 'Eligibility'
                    ,Name='READY'
                ),
                new GlobalVariables__c(
                    Object__c = 'Assessment__c'
                    ,Order__c ='2.0'
                    ,Type__c='Process'
                    ,Value__c = 'Sourcing'
                    ,Name='CHECKED'
                ),
                new GlobalVariables__c(
                    Object__c = 'PurchaseOrder__c'
                    ,Order__c ='4.4'
                    ,Type__c='Process'
                    ,Value__c = 'OrderDeliveryConfirmed'
                    ,Name='DELIVEREDCONFIRMED'
                )
            };
            insert cs_GlobalVariables;

            masterRuleList = new list <MasterRules__c>{
                new MasterRules__c(Process__c = 'ELIGIBILITY' , 
                    Entity__c = 'AXA Direct',
                    sObject__c = 'Assessment__c',
                    Version__c = 2,
                    FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7)',
                    RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                    RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)
                ),
                /*
                new MasterRules__c(Process__c = 'ELIGIBILITY' , 
                    Entity__c = 'AXA Direct1',
                    Version__c = 1,
                    sObject__c = 'Assessment__c',
                    FilterLogic__c = '(1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 13 OR 14 OR 15 OR 16)',
                    RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                    RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)
                )
                
            };
            ASPISTestUtils.generateMasterRules(masterRuleList);

            detailRuleList = new list <DetailRule__c>{
                //master rule [0]
                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'EntityCode__c', 
                    Operator__c = 'EQUALS',
                    Value__c = '2991',
                    Number__c = 1
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'TotalNumberOfParts__c', 
                    Operator__c = 'NOT_EQUALS',
                    Value__c = '0',
                    Number__c = 2
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'VINNumber__c', 
                    Operator__c = 'NOT_EQUALS',
                    Value__c = '',
                    Number__c = 3
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'Manufacturer__c', 
                    Operator__c = 'IN',
                    Value__c = 'RENAULT;CITROEN;TOYOTA;',
                    Number__c = 4
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'BuildDate__c', 
                    Operator__c = 'GREATER_EQUALS',
                    Value__c = '27/12/2002',
                    Number__c = 5
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'ModelV2__c', 
                    Operator__c = 'NOT IN',
                    Value__c = 'TWINGO;ESPACE;MEGANE;PRIUS T4;',
                    Number__c = 6
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'BodyShopIsEligible__c', 
                    Operator__c = 'EQUALS',
                    Value__c = 'TRUE',
                    Number__c = 7
                ),
                    
                //master rule [1]
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'BuildDate__c', 
                    Operator__c = system.Label.OPERATORLESS,
                    Value__c = '27/12/2002',
                    Number__c = 1
                ),

                 new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'EntityCode__c', 
                    Operator__c = 'EQUALS',
                    //Value__c = '27/12/2002',
                    Number__c = 2
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'Price__c', 
                    Operator__c = 'EQUALS',
                    Value__c = '0',
                    Number__c = 3
                ),

                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'PartNumber__c', 
                    Operator__c = 'NOT_EQUALS',
                    Value__c = '53102 47020',
                    Number__c = 4
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'HeldDate__c', 
                    Operator__c = system.Label.OPERATORGREATER,
                    Value__c = '27/12/2002',
                    Number__c = 5
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'Name', 
                    Operator__c = system.Label.OPERATORCONTAINS,
                    Value__c = 'AS',
                    Number__c = 6
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'Price__c', 
                    Operator__c = system.Label.OPERATORGREATER,
                    Value__c = '5',
                    Number__c = 7
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'Price__c', 
                    Operator__c = system.Label.OPERATORGREATEREQUALS,
                    Value__c = '5',
                    Number__c = 7
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'Price__c', 
                    Operator__c = system.Label.OPERATORLESS,
                    Value__c = '5',
                    Number__c = 8
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'Price__c', 
                    Operator__c = system.Label.OPERATORLESSEQUALS,
                    Value__c = '5',
                    Number__c = 9
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'HeldDate__c', 
                    Operator__c = system.Label.OPERATORLESSEQUALS,
                   Value__c = '27/12/2002',
                    Number__c = 10
                ),
                new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'HeldDate__c', 
                    Operator__c = system.Label.OPERATORBETWEEN ,
                    Value__c = '27/12/2002',
                    Number__c = 11
                ),
                 new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'PartList__c', 
                    FieldsAPI__c = 'HeldDate__c', 
                    Operator__c = 'INCLUDES',
                    Value__c = '27/12/2002',
                    Number__c = 12
                ),
                 new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'Manufacturer__c', 
                    Operator__c = 'EXCLUDES',
                    Value__c = 'Bodyshop__r.CarBrandExcluded__c',
                    Number__c = 13
                ),
                 new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'Manufacturer__c', 
                    Operator__c = 'INCLUDES',
                    Value__c = 'CHRYSLER;ROVER;PORSCHE',
                    Number__c = 14
                ),
                 new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'Manufacturer__c', 
                    Operator__c = 'IN',
                    Value__c = 'CHRYSLER;ROVER;PORSCHE',
                    Number__c = 15
                ),
                 new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'Manufacturer__c', 
                    Operator__c = 'NOT_IN',
                    Value__c = 'CHRYSLER;ROVER;PORSCHE',
                    Number__c = 16
                ),
                 new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                    RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                    Process__c = 'Eligibility', 
                    sObject__c = 'Assessment__c', 
                    FieldsAPI__c = 'Manufacturer__c', 
                    //Operator__c = 'NOT_IN',
                    Value__c = 'CHRYSLER;ROVER;PORSCHE',
                    Number__c = 17
                )
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
                    ,EntityCode__c = '299'
                    ,VINNumber__c = '444'
                    ,Manufacturer__c = 'TOYOTA'
                    ,BuildDate__c = date.today()
                    ,ModelV2__c = 'PRIUS T4'
                ),
                
                new Assessment__c(Name='ASSESS_TEST-0002'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0002'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct1'
                    ,MissionNumber__c = '02'
                    ,PortfolioAgentCode__c = '3545'
                    ,AssessmentID__c = '5912'
                    ,EntityRules__c = 'AXA Direct1'
                    ,EntityCode__c = '213'
                    ,BuildDate__c = date.today()+1
                ),

                new Assessment__c(Name='ASSESS_TEST-0003'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0003'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct2'
                    ,MissionNumber__c = '0267'
                    ,PortfolioAgentCode__c = '354577'
                    ,AssessmentID__c = '591274'
                    ,EntityRules__c = 'AXA Direct2'
                    ,EntityCode__c = '299'
                )
                
            };
            //insert  assessments;
            ASPISTestUtils.generateAssessment(assessments);
            
        }
        //system.debug('#### assessmentsTest:'+assessments);


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

        myDate = date.newInstance(2015, 2, 17);
        partLists = new list<PartList__c>{
            new PartList__c(
                Assessment__c = assessments[1].Id,
                Name = 'FRONT LWR AIR GRILLE',
                PartNumber__c = '53102 47020',
                HeldDate__c = myDate,
                Price__c = 68,
                Quantity__c = 1
            )
          };
        insert partLists;
    }

    
    @isTest static void test_EligibilityV1() {
        system.debug('#### Start of test_EligibilityV1');

        system.runAs(userAdmin){    
            test.starttest();
                assessments[0].Status__c = ASPISConstants.ASSESS_STATUS_READY;
                update assessments[0];
            test.stoptest();

            List<Assessment__c> assessmentsAsserList = new List<Assessment__c>([select Id,TECHRulesAppliedDescription__c,SourceFailure__c
                                                                            from Assessment__c 
                                                                            where Id =:assessments[0].Id
                                                                            ]);
			
            System.assertNotEquals(null, assessmentsAsserList[0].TECHRulesAppliedDescription__c);
            System.assertEquals(true, assessmentsAsserList[0].TECHRulesAppliedDescription__c.contains('F'));
            System.assertEquals(true, assessmentsAsserList[0].TECHRulesAppliedDescription__c.contains('T'));
            System.assertEquals(true, assessmentsAsserList[0].SourceFailure__c.contains('Entity code, Total Number Of Parts, Model, Manufacturer'));
        }
    }

    @isTest static void test_EligibilityV2() {
        system.debug('#### Start of test_EligibilityV2');

        system.runAs(userAdmin){    
            test.starttest();
                assessments[1].Status__c = ASPISConstants.ASSESS_STATUS_READY;
                update assessments[1];
            test.stoptest();
        }

        List<Assessment__c> assessmentsAsserList = new List<Assessment__c>([select Id,TECHRulesAppliedDescription__c
                                                                            from Assessment__c 
                                                                            where Id =:assessments[1].Id
                                                                            ]);
            
        System.assertNotEquals(null, assessmentsAsserList[0].TECHRulesAppliedDescription__c);
        System.assertEquals(true, assessmentsAsserList[0].TECHRulesAppliedDescription__c.contains('F'));
        System.assertEquals(true, assessmentsAsserList[0].TECHRulesAppliedDescription__c.contains('T'));
    }

   
    @isTest static void test_EligibilityV3() {
        system.debug('#### Start of test_EligibilityV3');

        system.runAs(userAdmin){    
            test.starttest();
				ASPISTools.fmtIN('a,b,c');
                assessments[2].Status__c = ASPISConstants.ASSESS_STATUS_READY;
                update assessments[2];
            test.stoptest();

            
        }

        List<Assessment__c> assessmentsAsserList = new List<Assessment__c>([select Id,TECHRulesAppliedDescription__c,Status__c
                                                                            from Assessment__c 
                                                                            where Id =:assessments[2].Id
                                                                            ]);
            
        System.assertEquals('REJECTED', assessmentsAsserList[0].Status__c);
    }

   /* @isTest static void test_EligibilityV4() {
        system.debug('#### Start of test_EligibilityV4');
       
        String result = '';
        String result0 = '';  
        String result1 = ''; 
        String result2 = '';     
        system.runAs(userAdmin){    
            test.starttest();
                result = ASPISTools.getSLABasedOnBusinessHour(defaultHours.name , System.now(), System.now().addDays(3), 1);
                result1 = ASPISTools.getSLABasedOnBusinessHour(defaultHours.name , System.now(), System.now().addSeconds(6), 6*1000);
                result2 = ASPISTools.getSLABasedOnBusinessHour(defaultHours.name , System.now().addDays(2), System.now(), 1);
            test.stoptest();
            
            System.assertEquals( result, system.Label.SLALOWPERFORMANCE);
            //System.assertEquals( result1, system.Label.SLAHIGHPERFORMANCE);
            //System.assertEquals( result2, system.Label.SLAHIGHPERFORMANCE);
            //System.assertEquals( result, system.Label.SLAHIGHPERFORMANCE);
            //System.assertEquals( result1, system.Label.SLAHIGHPERFORMANCE);
            //System.assertEquals( result2, system.Label.SLAHIGHPERFORMANCE);
        } 
    }*/

    
}