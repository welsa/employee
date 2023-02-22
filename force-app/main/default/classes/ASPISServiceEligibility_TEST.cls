/*************************************************************************************
Class Name - ASPISServiceEligibility_TEST
Version - 1.0
Created Date - 25 FEB 2016
Function - TestClass for ASPISServiceEligibility

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date           Description
* ----------    ----------     -----------------------
* Dourga        24/02/2016     Reworked Version
*************************************************************************************/
@isTest
public with sharing class ASPISServiceEligibility_TEST {
    
    static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list <GlobalVariables__c> cs_GlobalVariables;
    static list <MasterRules__c> masterRuleList;
    static list <DetailRule__c> detailRuleList;
    static list<PartList__c> partLists;
    static BusinessHours defaultHours;
    static list <CountryCodeInformationsMapping__c> countryCodeInfos;

    static {
	    // initialising variables
	    accounts = new list <Account>();
	    assessments = new list <Assessment__c>();
        cs_GlobalVariables = new list <GlobalVariables__c>();
        masterRuleList = new list <MasterRules__c>();
        detailRuleList = new list <DetailRule__c>();
        partLists = new list <PartList__c>();
        countryCodeInfos = new list <CountryCodeInformationsMapping__c>();
	    
        // creating user
        userAdmin = TestFactory.createUser('ScUserTest');
        insert userAdmin;

        system.runas(userAdmin){

            defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

            Account bs1 = TestFactory.createAccountBodyshop('BodyShop_ScTest1', 'FR');            
            bs1.isEligible__c = true;
            accounts.add(bs1);
        
            Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
            bs2.CarBrandExcluded__c = 'AUDI';
            accounts.add(bs2);    

            insert accounts;

            GlobalVariables__c gb1 = TestFactory.createGlobalVariable('Assessment__c', '1.1', 'Process', 'Eligibility', 'READY');
            cs_GlobalVariables.add(gb1);

            GlobalVariables__c gb2 = TestFactory.createGlobalVariable('Assessment__c', '2.0', 'Process', 'Sourcing', 'CHECKED');
            cs_GlobalVariables.add(gb2);

            GlobalVariables__c gb3 = TestFactory.createGlobalVariable('PurchaseOrder__c', '4.4', 'Process', 'OrderDeliveryConfirmed', 'DELIVEREDCONFIRMED');
            cs_GlobalVariables.add(gb3);

            insert cs_GlobalVariables;

            MasterRules__c mr1 = TestFactory.createMasterRule('AXA Direct', 'ELIGIBILITY', 'Assessment__c');
            mr1.FilterLogic__c = '(1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7)';
            masterRuleList.add(mr1);

            MasterRules__c mr2 = TestFactory.createMasterRule('AXA Direct1', 'ELIGIBILITY', 'Assessment__c');
            mr2.FilterLogic__c = '(1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 13 OR 14 OR 15 OR 16)';
            masterRuleList.add(mr2);

            insert masterRuleList;

            DetailRule__c dr1 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'EntityCode__c', 'EQUALS', '2991', 'Filter Condition', 'Assessment__c', 1);
            detailRuleList.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'TotalNumberOfParts__c', 'NOT_EQUALS', '0', 'Filter Condition', 'Assessment__c', 2);
            detailRuleList.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'VINNumber__c', 'NOT_EQUALS', '', 'Filter Condition', 'Assessment__c', 3);
            detailRuleList.add(dr3);
            
            DetailRule__c dr4 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'Manufacturer__c', 'IN', 'RENAULT;CITROEN;TOYOTA;', 'Filter Condition', 'Assessment__c', 4);
            detailRuleList.add(dr4);
            
            DetailRule__c dr5 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'BuildDate__c', 'GREATER_EQUALS', '27/12/2002', 'Filter Condition', 'Assessment__c', 5);
            detailRuleList.add(dr5);
            
            DetailRule__c dr6 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'ModelV2__c', 'NOT IN', 'TWINGO;ESPACE;MEGANE;PRIUS T4;', 'Filter Condition', 'Assessment__c', 6);
            detailRuleList.add(dr6);
            
            DetailRule__c dr7 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'BodyShopIsEligible__c', 'EQUALS', 'TRUE', 'Filter Condition', 'Assessment__c', 7);
            detailRuleList.add(dr7);
            
            DetailRule__c dr8 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'BuildDate__c', 'LESS', '27/12/2002', 'Filter Condition', 'Assessment__c', 1);
            detailRuleList.add(dr8);
            
            DetailRule__c dr9 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'EntityCode__c', 'EQUALS', '27/12/2002', 'Filter Condition', 'Assessment__c', 2);
            detailRuleList.add(dr9);
            
            DetailRule__c dr10 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'Price__c', 'EQUALS', '0', 'Filter Condition', 'PartList__c', 3);
            detailRuleList.add(dr10);
            
            DetailRule__c dr11 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'PartNumber__c', 'NOT_EQUALS', '53102 47020', 'Filter Condition', 'PartList__c', 4);
            detailRuleList.add(dr11);
            
            DetailRule__c dr12 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'HeldDate__c', 'GREATER', '27/12/2002', 'Filter Condition', 'PartList__c', 5);
            detailRuleList.add(dr12);
            
            DetailRule__c dr13 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'Name', 'CONTAINS', 'AS', 'Filter Condition', 'PartList__c', 6);
            detailRuleList.add(dr13);
            
            DetailRule__c dr14 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'Price__c', 'GREATER', '5', 'Filter Condition', 'PartList__c', 7);
            detailRuleList.add(dr14);
            
            DetailRule__c dr15 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'Price__c', 'LESS', '5', 'Filter Condition', 'PartList__c', 8);
            detailRuleList.add(dr15);
            
            DetailRule__c dr16 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'Price__c', 'LESS_EQUALS', '5', 'Filter Condition', 'PartList__c', 9);
            detailRuleList.add(dr16);
            
            DetailRule__c dr17 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'HeldDate__c', 'LESS_EQUALS', '27/12/2002', 'Filter Condition', 'PartList__c', 10);
            detailRuleList.add(dr17);
            
            DetailRule__c dr18 = TestFactory.createDetailRule('Eligibility', masterRuleList[1], 'HeldDate__c', 'BETWEEN', '27/12/2002', 'Filter Condition', 'PartList__c', 11);
            detailRuleList.add(dr18);
            
            DetailRule__c dr19 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'HeldDate__c', 'INCLUDES', '27/12/2002', 'Filter Condition', 'PartList__c', 12);
            detailRuleList.add(dr19);
            
            DetailRule__c dr20 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'Manufacturer__c', 'EXCLUDES', 'Bodyshop__r.CarBrandExcluded__c', 'Filter Condition', 'Assessment__c', 13);
            detailRuleList.add(dr20);
            
            DetailRule__c dr21 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'Manufacturer__c', 'INCLUDES', 'CHRYSLER;ROVER;PORSCHE', 'Filter Condition', 'Assessment__c', 14);
            detailRuleList.add(dr21);
            
            DetailRule__c dr22 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'Manufacturer__c', 'IN', 'CHRYSLER;ROVER;PORSCHE', 'Filter Condition', 'Assessment__c', 15);
            detailRuleList.add(dr22);
            
            DetailRule__c dr23 = TestFactory.createDetailRule('Eligibility', masterRuleList[0], 'Manufacturer__c', 'NOT_IN', 'CHRYSLER;ROVER;PORSCHE', 'Filter Condition', 'Assessment__c', 16);
            detailRuleList.add(dr23);

            insert detailRuleList;

            Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs1);
            ass1.Entity__c = 'AXA Direct';
            ass1.EntityRules__c = 'AXA Direct';
            ass1.EntityCode__c = '299';
            ass1.VINNumber__c = '444';
            ass1.Manufacturer__c = 'TOYOTA';
            ass1.BuildDate__c = date.today();
            ass1.ModelV2__c = 'PRIUS T4';
            assessments.add(ass1);
        
            Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs1);
            ass2.Entity__c = 'AXA Direct1';
            ass2.EntityRules__c = 'AXA Direct1';
            ass2.EntityCode__c = '213';
            ass2.BuildDate__c = date.today()+1;
            ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            assessments.add(ass2);
        
            Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs1);
            ass3.Entity__c = 'AXA Direct2';
            ass3.EntityRules__c = 'AXA Direct2';
            ass3.EntityCode__c = '299';
            assessments.add(ass3);  

            insert assessments;

            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            countryCodeInfos.add(countryCode1);
            CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('FR',defaultHours.id);    
            countryCodeInfos.add(countryCode2);

            insert countryCodeInfos; 

            PartList__c pl1 = TestFactory.createPartList(assessments[1]);
            partLists.add(pl1);

            insert partLists;
        }
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
            System.assertEquals(true, assessmentsAsserList[0].SourceFailure__c.contains('Entity code; Total Number Of Parts; Model; Manufacturer'));
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
}