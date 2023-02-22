/*************************************************************************************
Class Name - TestASPISProcessFlows
Version - 1.0
Created Date - 04 JUNE 2015
Function - Test to test process flow

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole (SC)    04/06/2015  Original Version
**************************************************************************************/
@isTest
private class TestASPISProcessFlows {
    // ABT - 02-DEC-2016 - C-001625
    /*
  static User userAdmin;
  static MasterRules__c ruleSet;
  static list<Assessment__c> assessments;
  static list <Account> accounts;
  static list<PurchaseOrder__c> purchaseOrders = new list<PurchaseOrder__c>();
  static list<OrderLine__c> orderLines = new list<OrderLine__c>();
  static list<PrerequisiteOrder__c> salesOrders = new list<PrerequisiteOrder__c>();
  static list<Offer__c> offers = new list<Offer__c>();
  static list<PrerequisiteOrder__c> salesOrders2 = new list<PrerequisiteOrder__c>();
  static list<Offer__c> offers2 = new list<Offer__c>();
  static list <DetailRule__c> detailRuleList;
  static list <MasterRules__c> masterRuleList;
  static map <String,Id> accRecordTypeMap = new map <String,Id>();
  static map <String,Id> mRRecordTypeMap = new map <String,Id>();
  static map <String,Id> dRRecordTypeMap = new map <String,Id>();
  static Account bodyshop;
  static String jsonAssessment;
  static list <GlobalVariables__c> cs_GlobalVariables;
  static list <CountryCodeInformationsMapping__c> countryCodeInfos;
  static BusinessHours defaultHours;  

  static{

    accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
    mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);
    dRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_CRITERIA);

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
            cs_GlobalVariables = new list<GlobalVariables__c>{new GlobalVariables__c(Object__c = 'Assessment__c',
                                                                                     Order__c ='1.1',
                                                                                     Type__c='Process',
                                                                                     Value__c = 'Eligibility',
                                                                                     Name='READY'),

                                                              new GlobalVariables__c(Object__c = 'Assessment__c',
                                                                                     Order__c ='2.0',
                                                                                     Type__c='Process',
                                                                                     Value__c = 'Sourcing',
                                                                                     Name='CHECKED'),

                                                              new GlobalVariables__c(Object__c = 'PrerequisiteOrder__c',
                                                                                     Order__c ='3.2',
                                                                                     Type__c='Process',
                                                                                     Value__c = 'PrerequisiteOrder',
                                                                                     Name='RESPONDED'),

                                                              new GlobalVariables__c(Object__c = 'PrerequisiteOrder__c',
                                                                                     Order__c ='5.0',
                                                                                     Type__c='Process',
                                                                                     Value__c = 'BodyShopGenerateInvoice',
                                                                                     Name='PREORDERCONFIRMED'),

                                                              new GlobalVariables__c(Object__c = 'Assessment__c',
                                                                                     Order__c ='3.0',
                                                                                     Type__c='Process',
                                                                                     Value__c = 'Offering',
                                                                                     Name='OFFERING')
            };


            insert cs_GlobalVariables;

            //Get the default business hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];

            // custom settings - CountryCodeInfo
            countryCodeInfos = new list<CountryCodeInformationsMapping__c>{
                new CountryCodeInformationsMapping__c(
                    Name='FR'
                    ,BusinessHoursID__c = defaultHours.id
                ),
                 new CountryCodeInformationsMapping__c(
                    Name='DEFAULT'
                    ,BusinessHoursID__c = defaultHours.id
                )
            };
            insert countryCodeInfos;

        ruleSet = new MasterRules__c(Process__c = 'OFFERING' , 
                          Entity__c = 'FRAXA Direct',
                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET));
        insert ruleSet;

        masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'ELIGIBILITY' , 
                                                                          Entity__c = 'FRAXA Direct',
                                                                          sObject__c = 'Assessment__c',
                                                                          Version__c = 2,
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)),

                                                       new MasterRules__c(Process__c = 'Sourcing' , 
                                                                          Entity__c = 'FRAXA Direct',
                                                                          Version__c = 1,
                                                                          sObject__c = 'Assessment__c',
                                                                          FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5)',
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)),

                                                       new MasterRules__c(Process__c = 'QUICK' , 
                                                                          Entity__c = 'FRAXA Direct',
                                                                          Version__c = 1,
                                                                          sObject__c = 'Assessment__c',
                                                                          RuleSet__c = ruleSet.Id,
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)),

                                                       new MasterRules__c(Process__c = 'OPPORTUNITY' , 
                                                                          Entity__c = 'FRAXA Direct',
                                                                          Version__c = 1,
                                                                          sObject__c = 'Assessment__c',
                                                                          RuleSet__c = ruleSet.Id,
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE)),

                                                       new MasterRules__c(Process__c = 'BASIC' , 
                                                                          Entity__c = 'FRAXA Direct',
                                                                          Version__c = 1,
                                                                          sObject__c = 'Assessment__c',
                                                                          RuleSet__c = ruleSet.Id,
                                                                          RuleStatus__c = system.Label.RULESTATUSACTIVELABEL,
                                                                          RecordTypeId=mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_MASTERRULE))
            };
            ASPISTestUtils.generateMasterRules(masterRuleList);

        detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'EntityCode__c', 
                                                                        Operator__c = 'EQUALS',
                                                                        Value__c = 'FRAXA Direct',
                                                                        Number__c = 1),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'TotalNumberOfParts__c', 
                                                                        Operator__c = 'NOT_EQUALS',
                                                                        Value__c = '0',
                                                                        Number__c = 2),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'VINNumber__c', 
                                                                        Operator__c = 'NOT_EQUALS',
                                                                        Value__c = '',
                                                                        Number__c = 3),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'Manufacturer__c', 
                                                                        Operator__c = 'IN',
                                                                        Value__c = 'RENAULT;CITROEN;TOYOTA;',
                                                                        Number__c = 4),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'BuildDate__c', 
                                                                        Operator__c = 'GREATER_EQUALS',
                                                                        Value__c = '27/12/2002',
                                                                        Number__c = 5),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'ModelV2__c', 
                                                                        Operator__c = 'IN',
                                                                        Value__c = 'TWINGO;ESPACE;MEGANE;PRIUS T4;BERLINGO;',
                                                                        Number__c = 6),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[0].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Eligibility', 
                                                                        sObject__c = 'Assessment__c', 
                                                                        FieldsAPI__c = 'BodyShopIsEligible__c', 
                                                                        Operator__c = 'EQUALS',
                                                                        Value__c = 'TRUE',
                                                                        Number__c = 7),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Sourcing', 
                                                                        sObject__c = 'Account', 
                                                                        FieldsAPI__c = 'ShippingCountry', 
                                                                        Operator__c = 'EQUALS',
                                                                        ValueFrom__c = 'Master sObject',
                                                                        Value__c = 'BodyShop__r.ShippingCountry',
                                                                        Number__c = 2),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Sourcing', 
                                                                        sObject__c = 'Account', 
                                                                        FieldsAPI__c = 'RecordType.Name', 
                                                                        Operator__c = 'EQUALS',
                                                                        ValueFrom__c = 'Criteria sObject',
                                                                        Value__c = 'DISTRIBUTOR',
                                                                        Number__c = 1),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Sourcing', 
                                                                        sObject__c = 'Account', 
                                                                        FieldsAPI__c = 'DistributorCarBrandSupplied__c', 
                                                                        Operator__c = 'IN',
                                                                        ValueFrom__c = 'Master sObject',
                                                                        Value__c = 'Manufacturer__c',
                                                                        Number__c = 3),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Sourcing', 
                                                                        sObject__c = 'Account', 
                                                                        FieldsAPI__c = 'Categories__c', 
                                                                        Operator__c = 'IN',
                                                                        ValueFrom__c = 'Master sObject',
                                                                        Value__c = 'PartTypes__c',
                                                                        Number__c = 4),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[1].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_FILTERCONDITION),
                                                                        Process__c = 'Sourcing', 
                                                                        sObject__c = 'Account', 
                                                                        FieldsAPI__c = 'DistributorRegionsCovered__c',
                                                                        Operator__c = 'IN',
                                                                        ValueFrom__c = 'Master sObject',
                                                                        Value__c = 'BodyShop__r.ShippingPostalCodeLeft2__c',
                                                                        Number__c = 5),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'TECH_SLARulesFR__c', 
                                                                        Alias__c = 'MAXEDD',
                                                                        Operator__c = 'AGMAX',
                                                                        Number__c = 1),

                                                        
                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                          Alias__c = 'SUMTECHIS',
                                                                          Operator__c = 'AGSUM',
                                                                          Number__c = 2),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'BodyshopTotalPrice__c', 
                                                                          Alias__c = 'SUMAXAP',
                                                                          Operator__c = 'AGSUM',
                                                                          Number__c = 3),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'Id', 
                                                                          Alias__c = 'COUNTId',
                                                                          Operator__c = 'AGCOUNT',
                                                                          Number__c = 4),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'PurchaseOrder__c',
                                                                          Operator__c = 'GROUPBY',
                                                                          Number__c = 5),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'MAXEDD',
                                                                          Operator__c = 'MIN',
                                                                          Number__c = 6),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'SUMAXAP', 
                                                                          Operator__c = 'MIN',
                                                                          Number__c = 7),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[2].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'SUMTECHIS/COUNTId', 
                                                                          Operator__c = 'GREATER_EQUALS',
                                                                          Value__c = '0.90',
                                                                          Number__c = 8),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'PartList__c', 
                                                                          Operator__c = 'GROUPBY',
                                                                          Number__c = 1),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                        Alias__c = 'MINEDD',
                                                                        Operator__c = 'AGMIN',
                                                                        Number__c = 2),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'AXAProfit__c', 
                                                                        Alias__c = 'MAXPROFIT',
                                                                        Operator__c = 'AGMAX',
                                                                        Number__c = 3),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MINEDD', 
                                                                        Operator__c = 'MIN',
                                                                        Number__c = 4),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MAXPROFIT',
                                                                        Operator__c = 'MAX',
                                                                        Number__c = 5),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[3].Id, 
                                                                          RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                          Process__c = 'Offering', 
                                                                          sObject__c = 'OrderLine__c', 
                                                                          FieldsAPI__c = 'Id', 
                                                                          Operator__c = 'GROUPBY',
                                                                          Number__c = 6),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'ExpectedDeliveryDuration__c', 
                                                                        Alias__c = 'MAXEDD',
                                                                        Operator__c = 'AGMAX',
                                                                        Number__c = 1),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'TECHIsSuppliable__c', 
                                                                        Alias__c = 'SUMTECHIS',
                                                                        Operator__c = 'AGCOUNT',
                                                                        Number__c = 2),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'AXAProfit__c', 
                                                                        Alias__c = 'MAXPROFIT',
                                                                        Operator__c = 'AGMAX',
                                                                        Number__c = 3),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_AggregateCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'Id', 
                                                                        Alias__c = 'COUNTID',
                                                                        Operator__c = 'AGCOUNT',
                                                                        Number__c = 4),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_GroupByCriteria),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'PurchaseOrder__c',
                                                                        Operator__c = 'GROUPBY',
                                                                        Number__c = 5),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'SUMTECHIS/COUNTID', 
                                                                        Operator__c = 'LESS_EQUALS',
                                                                        Value__c = '0.90',
                                                                        Number__c = 6),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MAXEDD',
                                                                        Operator__c = 'MIN',
                                                                        Number__c = 7),

                                                        new DetailRule__c(MasterRule__c = masterRuleList[4].Id, 
                                                                        RecordTypeId = dRRecordTypeMap.get(ASPISConstants.CRITERIA_RT_DeveloperName_CRITERIA),
                                                                        Process__c = 'Offering', 
                                                                        sObject__c = 'OrderLine__c', 
                                                                        FieldsAPI__c = 'MAXPROFIT', 
                                                                        Operator__c = 'MAX',
                                                                        Number__c = 8)


        };
        ASPISTestUtils.generateDetailRule(detailRuleList);

       

        bodyshop = new Account(Name='scBodyShop',
                               RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop),
                               ReferenceNumber__c = 'scBodyShop',
                               ContactEmail__c = 'bt1@gmail.com',
                               ShippingCountry = 'FRANCE',
                               VAT__c = 10);
        insert bodyshop;

        accounts = new list<Account>{new Account(Name='payment_ScTest1',
                                                  RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Payment),
                                                  ReferenceNumber__c = '012345',
                                                  ContactEmail__c = 'PAY1@gmail.com',
                                                  ShippingCountry = 'FRANCE',
                                                  VAT__c = 10),

                                    new Account(Name='Distributor_ScTest1',
                                                  RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                                  ReferenceNumber__c = '12345',
                                                  ContactEmail__c = 'dt1@gmail.com',
                                                  DistributorCarBrandSupplied__c = 'CITROEN',
                                                  Categories__c = 'A',
                                                  ShippingCountry = 'FRANCE',
                                                  VAT__c = 10),

                        new Account(Name='Distributor_ScTest2',
                                  RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                  ReferenceNumber__c = '12346',
                                  ContactEmail__c = 'dt1@gmail.com',
                                                    DistributorCarBrandSupplied__c = 'CITROEN',
                                                    Categories__c = 'A;B;C',
                                                    DistributorRegionsCovered__c = '01',
                                                  VAT__c = 10),

                        new Account(Name='Distributor_ScTest3',
                                  RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                  ReferenceNumber__c = '12347',
                                  ContactEmail__c = 'dt1@gmail.com',
                                                    ShippingCountry = 'FRANCE',
                                                  VAT__c = 10),


                        new Account(Name='Distributor_ScTest4',
                                  RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor),
                                  ReferenceNumber__c = '123458',
                                  ContactEmail__c = 'dt1@gmail.com',
                                                    ShippingCountry = 'FRANCE',
                                                  VAT__c = 10)
            };
            insert accounts;

            //jsonAssessment = '[{"AssessmentNumber":"JSA TEST V 2","TransactionID":"ID01","Entity":"AXA Direct","MissionNumber":"0000012","Name":"JSA TEST V 2","PortfolioAgentCode":"Code123","Status":"New","Parts":[{"Description":"R/ELECTRIC FAN","GuideNo":7794,"HeldDate":"2015-04-13","Name":"R/ELECTRIC FAN","PartNumber":"16361 28360","PartNumberOptimized":"None","Price":114,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"RADIATOR SHROUD","GuideNo":7767,"HeldDate":"2015-04-13","Name":"RADIATOR SHROUD","PartNumber":"16711 37040","PartNumberOptimized":"None","Price":92,"PriceOptimized":0,"Quantity":2,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47031","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20},{"Description":"AUX WATER RADIATOR 2","GuideNo":7752,"HeldDate":"2015-04-15","Name":"AUX WATER RADIATOR","PartNumber":"G9010 47030","PartNumberOptimized":"None","Price":177,"PriceOptimized":0,"Quantity":1,"Recordtype":"Material","Status":"New","Type":"A","VAT":20}],"currentAsset":{"BrakesPedalTravel":"Travel","BuildDate":"2015-04-13","Colour":"SILVER","DamageAreas":"Damage","DirectionImpact":"left","Engine":"1.8 LTR 73KW HYBRID","Manufacturer":"TOYOTA","Model":"PRIUS T4","ModelSheetNumber":"Y3P","ModelSpecs":"FROM 03/2012 1.8 LTR 73KW HYBRID TWO COAT METALLIC","Name":"Asset mock001","Odometer":"Not Known","PaintCode":"Not Known","PlaceOfInspection":"Place","PlateNumber":"245CZE","PreAccidentCondition":"None","PreAccidentDamage":"None","RegistrationMonth":"March","RegistrationNumber":"WV12HKB","RegistrationYear":2012,"SelectionType":"Type","SeverityOfImpact":"None","SteeringRimPly":"None","TreadDepthLHF":"LHF","TreadDepthLHR":"LHR","TreadDepthRHF":"RHF","TreadDepthRHR":"RHR","VINNumber":"JTDKN36U601451563","VehicleStatusInspection":"None"},"currentBodyShop":{"BillingCity":"LEVALLOIS PERRET","BillingStreet":"1 rue de Paris","BillingZipCode":"92309","ClientScoring":"20","InvoicePeriod":"60","Name":"MIDAS Levallois","OrderEmail":"test@test.com","ReferenceNumber":"Auto-MIDAS-001","ShippingCity":"LEVALLOIS PERRET","ShippingStreet":"1 rue de Paris","ShippingZipCode":"92309"},"currentClaim":{"AbleToAuthoriseRepairs":true,"AuthorisationStatus":"Authorised","ClaimReference":"2064150","CompanyName":"CPY","DateOfIncident":"2015-04-13","EstimatedRepairTime":20,"IncidentReference":"Ins123","Name":"Claim 2064150","OtherReference":"26/66893","PolicyNumber":"0Z001","RepairsAuthorised":true,"VATPortionPayable":20,"WorkProvider":"AXA - Commercial"}}]';
              
            //jsonAssessment = '[{"AssessmentNumber":"scAssessment","TransactionID":"TransactionID1","Entity":"AXA Direct","EntityCode":"AXA Direct","MissionNumber":"0000012","Name":"AI360505","PortfolioAgentCode":"Code123","ExpertValidationDate":"2015-04-13","Status":"New","Parts":[{"Description":"Desc","GuideNo":253,"HeldDate":"2015-04-13","Name":"FRONT LWR AIR GRILLE","PartNumber":"2402","PartNumberOptimized":"None","Price":68,"PriceOptimized":0,"Quantity":10,"Recordtype":"Material","Status":"New","Type":"A","VAT":20}],"currentAsset":{"BrakesPedalTravel":"Asset 001","BuildDate":"2015-04-13","Colour":"SILVER","DamageAreas":"Damage","DirectionImpact":"left","Engine":"1.8 LTR 73KW HYBRID","Manufacturer":"Toyota","Model":"PRIUS T4","ModelSheetNumber":"Y3P","ModelSpecs":"FROM 03/2012 1.8 LTR 73KW HYBRID TWO COAT METALLIC","Name":"Asset mock001","Odometer":"Not Known","PaintCode":"Not Known","PlaceOfInspection":"Place","PlateNumber":"245CZE","PreAccidentCondition":"None","PreAccidentDamage":"None","RegistrationMonth":"March","RegistrationNumber":"WV12HKB","RegistrationYear":2012,"SelectionType":"Type","SeverityOfImpact":"None","SteeringRimPly":"None","TreadDepthLHF":"LHF","TreadDepthLHR":"LHR","TreadDepthRHF":"RHF","TreadDepthRHR":"RHR","VINNumber":"JTDKN36U601451563","VehicleStatusInspection":"None"},"currentBodyShop":{"BillingCity":"LEVALLOIS PERRET","BillingStreet":"1 rue de Paris","BillingZipCode":"92309","ClientScoring":"20","InvoicePeriod":"60","Name":"MIDAS Levallois","OrderEmail":"test@test.com","ReferenceNumber":"scBodyShop","ShippingCity":"LEVALLOIS PERRET","ShippingStreet":"1 rue de Paris","ShippingZipCode":"92309"},"currentClaim":{"AbleToAuthoriseRepairs":true,"AuthorisationStatus":"Not authorized","ClaimReference":"240288","CompanyName":"CPY","DateOfIncident":"2015-04-13","EstimatedRepairTime":20,"IncidentReference":"Ins123","Name":"mockclaim1","OtherReference":"26/66893","PolicyNumber":"0Z001","RepairsAuthorised":true,"VATPortionPayable":20,"WorkProvider":"AXA - Commercial"}}]';
        
			jsonAssessment = '[{"TransactionID":"scAssessment","AssessmentNumber":"scAssessment","BodyShopCreationDate":"2015-09-28T08:45:02.000","Entity":"AXA Direct","EntityCode":"AXA Direct","ExpertValidationDate":null,"MissionNumber":"445278","Name":"BNU TEST 001","PortfolioAgentCode":"","Status":"NEW","Parts":[{"Description":"Desc","GuideNo":253,"HeldDate":"2015-04-13","Name":"FRONT LWR AIR GRILLE","PartNumber":"2402","PartNumberOptimized":"None","Price":68,"PriceOptimized":0,"Quantity":10,"Recordtype":"Material","Status":"New","Type":"A","VAT":20}],"currentAsset":{"BrakesPedalTravel":"","BuildDate":"2005-05-23","Colour":"VERT VER","DamageAreas":"","DirectionImpact":"","Engine":"","Manufacturer":"CITROEN","Model":"BERLINGO","ModelSheetNumber":"","ModelSpecs":"","Odometer":"","PaintCode":"","PlaceOfInspection":"1591 BIS AVENUE DE LAMANDIER","PlateNumber":"DL-48XXX","PreAccidentCondition":"","PreAccidentDamage":"","FirstRegistrationDate":"2000-05-23","RegistrationMonth":"mai","RegistrationNumber":"","RegistrationYear":2000,"SelectionType":"","SeverityOfImpact":"","SteeringRimPly":"","TreadDepthLHF":80,"TreadDepthLHR":40,"TreadDepthRHF":80,"TreadDepthRHR":40,"VINNumber":"VF7MFRHYF65482024","VehicleStatusInspection":""},"currentBodyShop":{"BillingCity":"MONTFAVET","BillingStreet":"1591 BIS AVENUE DE LAMANDIER","BillingZipCode":"84140","ClientScoring":"","InvoicePeriod":"","Name":"CARROSSERIE AUTO 2000","OrderEmail":"","ReferenceNumber":"scBodyShop","ShippingCity":"MONTFAVET","ShippingStreet":"1591 BIS AVENUE DE L\'AMANDIER","ShippingZipCode":"84140"},"currentClaim":{"AbleToAuthoriseRepairs":false,"AuthorisationStatus":"Not authorized","ClaimReference":"0000035078915404","CompanyName":"AXA ASSURANCES IARD MUTUELLE","DateOfIncident":"2015-09-21","EstimatedRepairTime":0,"IncidentReference":"","OtherReference":"","PolicyNumber":"","RepairsAuthorised":false,"VATPortionPayable":0,"WorkProvider":""}}]';
		}
  }

  static testMethod void TestFlow(){
    system.Debug('>>> Start TestFlow');
    system.runAs(userAdmin){  
      Restrequest req = new Restrequest();
          Restresponse res = new Restresponse();
          
          test.starttest();
              ASPISTestUtils.createAssessmentViaWebServiceV2(jsonAssessment);
              Assessment__c asmt = [SELECT AssessmentNumber__c, Status__c, Entity__c, EntityCode__c, EntityRules__c, TECHRulesAppliedDescription__c FROM Assessment__c WHERE AssessmentNumber__c = 'scAssessment'];
              //system.debug('## Assessment ' + asmt);
              List <PurchaseOrder__c> listPO = [SELECT Assessment__c, Status__c,(SELECT Id, Suppliable__c FROM OrderLines__r) FROM PurchaseOrder__c WHERE Assessment__c =: asmt.Id];

              //system.debug('## listPO '+listPO);
              for(PurchaseOrder__c po : listPO){
                  //po.Status__c = 'ISSUED';
                  purchaseOrders.add(po);
                  for(OrderLine__c ol : po.OrderLines__r){
                      ol.Suppliable__c = 'YES';
                      ol.OrderType__c = 'FINAL';
                      ol.ExpectedDeliveryDuration__c = '1';
                      orderLines.add(ol);
                  }
              }
            //   system.debug('## Assessment ' + asmt.TECHRulesAppliedDescription__c);
            //   system.debug('## po '+purchaseOrders);
            //   system.debug('## ol '+orderLines);

              if(orderLines.size() > 0){
                  update orderLines;
              }
              for(PurchaseOrder__c po : listPO){
                  po.Status__c = 'ISSUED';
              }

              if(purchaseOrders.size() > 0){
                  update purchaseOrders;
              }
			  test.stoptest();
			  
			  
        //       List <PrerequisiteOrder__c> listSO = [select Id, Assessment__c, Status__c, (select Name, Type__c , Accepted__c, Selected__c, DeliveryStatus__c from Offers__r) from PrerequisiteOrder__c where Assessment__c =: asmt.Id];
        //       system.debug('## SOList ' + listSO);

        //       for(PrerequisiteOrder__c so : listSO){
        //           for(Offer__c off : so.Offers__r){
        //               off.Accepted__c = 'YES';
        //               offers.add(off);
        //           }
        //       }
        //       system.debug('## off '+offers);

        //       if(offers.size() > 0){
        //           update offers;
        //       }

        //       for(PrerequisiteOrder__c so : listSO){
        //           so.Status__c = 'RESPONDED';
        //           salesOrders.add(so);
        //       }
        //       system.debug('## so '+salesOrders);

        //       if(salesOrders.size() > 0){
        //           update salesOrders;
        //       }

        //       for(PrerequisiteOrder__c so : listSO){
        //           for(Offer__c off : so.Offers__r){
        //               off.DeliveryStatus__c = 'DELIVERED';
        //               offers2.add(off);
        //           }
        //       }
        //       system.debug('## off2 '+offers2);

        //       if(offers2.size() > 0){
        //           update offers2;
        //       }
          

        //   system.assertEquals([SELECT Assessment__c, Status__c FROM PurchaseOrder__c WHERE Assessment__c =: asmt.Id].size(),1);
        //   system.assertEquals([select Id, Assessment__c, Status__c from PrerequisiteOrder__c where Assessment__c =: asmt.Id].size(),1);
        //   system.assertEquals([SELECT Id, Suppliable__c FROM OrderLine__c where Id != null].size(),1);
        //   system.assertEquals([select Name, Type__c , Accepted__c, Selected__c, DeliveryStatus__c from Offer__c where Id != null].size(),3);
        //   system.assertEquals([select Name, Assessment__c from Invoice__c where Assessment__c =: asmt.Id].size(),1);
          
    }
    system.Debug('>>> End TestFlow');
  }*/
}