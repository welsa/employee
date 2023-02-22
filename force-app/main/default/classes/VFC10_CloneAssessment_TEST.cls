/*************************************************************************************
Class Name - VFC10_CloneAssessment_TEST
Version - 1.0
Created Date - 05 APRIL 2016
Function - TestClass for VFC10_CloneAssessment

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga        19/04/2016  Original Version
*************************************************************************************/
@isTest
public class VFC10_CloneAssessment_TEST {
	static User userAdmin;
    static BusinessHours defaultHours;
    static list<Account> l_Accounts;
    static list<Assessment__c> l_assessments;
    static list <GlobalVariables__c> cs_GlobalVariables;
    static MasterRules__c ruleSet;
    static list <MasterRules__c> l_masterRule;
    static list <DetailRule__c> l_detailRule;
    static list<PartList__c> partLists;
    static list <CountryCodeInformationsMapping__c> countryCodeInfos;


	static{

		l_Accounts = new list<Account>();
        cs_GlobalVariables = new list <GlobalVariables__c>();
        l_masterRule = new list <MasterRules__c>();
        l_detailRule = new list <DetailRule__c>();
        l_Accounts = new list<Account>();
    	partLists = new list<PartList__c>();
        l_assessments = new list<Assessment__c>();
        countryCodeInfos = new list <CountryCodeInformationsMapping__c>();

		userAdmin = TestFactory.createUser('ScUserTest');
		userAdmin.LastName = 'KurryJack';
		userAdmin.FirstName = '';
		insert userAdmin;

		system.runas(userAdmin){

			defaultHours = [select Id,Name from BusinessHours where IsDefault=true];

			Account bs1 = TestFactory.createAccountBodyshop('KurryJack', 'ES');
            bs1.Name = 'KurryJack';
            bs1.isEligible__c = true;
            l_Accounts.add(bs1);

            Account bs2 = TestFactory.createAccountBodyshop('JeanBalack', 'ES');
            l_Accounts.add(bs2);

            Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
            dist1.Categories__c = 'P';
            l_Accounts.add(dist1);

            Account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest2', 'ES');
            l_Accounts.add(dist2);

            insert l_Accounts;

            GlobalVariables__c gb1 = TestFactory.createGlobalVariable('Assessment__c', '1.1', 'Process', 'Eligibility', 'READY');
            cs_GlobalVariables.add(gb1);

            GlobalVariables__c gb2 = TestFactory.createGlobalVariable('Assessment__c', '2.0', 'Process', 'Sourcing', 'CHECKED');
            cs_GlobalVariables.add(gb2);

            GlobalVariables__c gb3 = TestFactory.createGlobalVariable('Assessment__c', '3.0', 'Process', 'Offering', 'OFFERING');
            cs_GlobalVariables.add(gb3);

            GlobalVariables__c gb4 = TestFactory.createGlobalVariable('PrerequisiteOrder__c', '3.2', 'Process', 'PrerequisiteOrder', 'RESPONDED');
            cs_GlobalVariables.add(gb4);

            insert cs_GlobalVariables;

            ruleSet = TestFactory.createMasterRule('ES05', 'PAINTING', 'ES05');
            ruleSet.AutomaticProcess__c = True;
            ruleSet.RecordTypeId = Schema.SObjectType.MasterRules__c.getRecordTypeInfosByName().get('Rule Set').getRecordTypeId();
            insert ruleSet;

            MasterRules__c mr1 = TestFactory.createMasterRule('ES05', 'ELIGIBILITY', 'Assessment__c');
            mr1.FilterLogic__c = '(1 AND 2)';
            mr1.RuleSet__c = ruleSet.Id;
            l_masterRule.add(mr1);

            MasterRules__c mr2 = TestFactory.createMasterRule('ES05', 'Sourcing', 'Assessment__c');
            mr2.FilterLogic__c = '(1 AND 2 AND 3 AND 4)';
            mr2.RuleSet__c = ruleSet.Id;
            l_masterRule.add(mr2);

            MasterRules__c mr3 = TestFactory.createMasterRule('ES05', 'Offering', 'Assessment__c');
            mr3.RuleSet__c = ruleSet.Id;
            l_masterRule.add(mr3);

            insert l_masterRule;

            DetailRule__c dr1 = TestFactory.createDetailRule('Eligibility', l_masterRule[0], 'BodyShopIsEligible__c', 'EQUALS', 'TRUE', 'Filter Condition', 'Assessment__c', 1);
            l_detailRule.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Eligibility', l_masterRule[0], 'RepairsAuthorised__c', 'EQUALS', 'FALSE', 'Filter Condition', 'Assessment__c', 2);
            l_detailRule.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'ShippingCountry', 'EQUALS', 'BodyShop__r.ShippingCountry', 'Filter Condition', 'Account', 1);
            dr3.ValueFrom__c = 'Master sObject';
            l_detailRule.add(dr3);
            
            DetailRule__c dr4 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'RecordType.Name', 'EQUALS', 'DISTRIBUTOR', 'Filter Condition', 'Account', 2);
            dr4.ValueFrom__c = 'Criteria sObject';
            l_detailRule.add(dr4);
            
            DetailRule__c dr5 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'Categories__c', 'IN', 'PartTypes__c', 'Filter Condition', 'Account', 3);
            dr5.ValueFrom__c = 'Master sObject';
            l_detailRule.add(dr5);
            
            DetailRule__c dr6 = TestFactory.createDetailRule('Sourcing', l_masterRule[1], 'DistributorRegionsCovered__c', 'IN', 'BodyShop__r.ShippingPostalCodeLeft2__c', 'Filter Condition', 'Account', 4);
            dr6.ValueFrom__c = 'Master sObject';
            l_detailRule.add(dr6);
            
            DetailRule__c dr7 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'PartList__c', 'GROUPBY', ' 0.1', 'Group By Criteria', 'OrderLine__c', 1);
            l_detailRule.add(dr7);
            
            DetailRule__c dr8 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'TECH_SLARulesFR__c', 'AGMAX', ' 0.1', 'Aggregate Criteria', 'OrderLine__c', 2);
            dr8.Alias__c = 'MAXEDD';
            l_detailRule.add(dr8);
            
            DetailRule__c dr9 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'ASMarginDiscount__c', 'AGMAX', '', 'Aggregate Criteria', 'OrderLine__c', 3);
            dr9.Alias__c = 'AVGMAR';
            l_detailRule.add(dr9);
            
            DetailRule__c dr10 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'MAXEDD', 'EQUALS', '', 'Criteria', 'OrderLine__c', 4);
            l_detailRule.add(dr10);
            
            DetailRule__c dr11 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'AVGMAR', 'NOT_EQUALS', '', 'Criteria', 'OrderLine__c', 5);
            l_detailRule.add(dr11);
            
            DetailRule__c dr12 = TestFactory.createDetailRule('Offering', l_masterRule[2], 'id', 'GROUPBY', '1', 'Group By Criteria', 'OrderLine__c', 6);
            l_detailRule.add(dr12);

            insert l_detailRule;

            Assessment__c ass1 = new Assessment__c(Name ='ASSESS_TEST-0001', BodyShop__c = bs1.Id);
            ass1.Entity__c = '05';
            //ass1.EntityRules__c = 'ES05';
            ass1.EntityCode__c = '05';
            ass1.PartP__c = 1;
            ass1.TECH_EntityCountryCode__c = 'ES';
            ass1.Manufacturer__c = 'MERCEDES';
            l_assessments.add(ass1);

            insert l_assessments;
            system.debug('##ass'+[select Id, Entity__c, EntityRules__c, EntityCode__c,TECH_EntityCountryCode__c from Assessment__c where Id =: l_assessments[0].Id]);

            CountryCodeInformationsMapping__c countryCode1 = TestFactory.createCountryCodeInformationsMapping('DEFAULT',defaultHours.id);
            countryCodeInfos.add(countryCode1);
            CountryCodeInformationsMapping__c countryCode2 = TestFactory.createCountryCodeInformationsMapping('ES',defaultHours.id);    
            countryCodeInfos.add(countryCode2);

            insert countryCodeInfos; 

            PartList__c pl1 = TestFactory.createPartList(l_assessments[0]);
            pl1.Type__c = 'P';
            partLists.add(pl1);

            insert partLists;

        }
    }

    static testMethod void cloneAssessmentTest() {
    	System.Debug('>>> Start cloneAssessmentTest');
        System.runAs(userAdmin){
            test.starttest();  
				ApexPages.StandardController sc = new ApexPages.StandardController(l_assessments[0]);
		        VFC10_CloneAssessment controller = new VFC10_CloneAssessment(sc);
		        PageReference pageRef = Page.VFP10_CloneAssessment;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getParameters().put('Id', l_assessments[0].Id);
		        controller.cloneAssessment();
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select Id from Assessment__c where Id <> null].size(),2);
    }

    static testMethod void cloneAssessmentCatchTest() {
    	System.Debug('>>> Start cloneAssessmentCatchTest');
        System.runAs(userAdmin){
        	l_assessments[0].AssessmentID__c = '1234';
        	update l_assessments[0];
            test.starttest();  
				ApexPages.StandardController sc = new ApexPages.StandardController(l_assessments[0]);
		        VFC10_CloneAssessment controller = new VFC10_CloneAssessment(sc);
		        PageReference pageRef = Page.VFP10_CloneAssessment;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getParameters().put('Id', l_assessments[0].Id);
		        controller.cloneAssessment();
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select Id from Assessment__c where Id <> null].size(),1);
    }

    static testMethod void cloneAssessmentTestNoBS() {
        System.Debug('>>> Start cloneAssessmentTestNoBS');
        System.runAs(userAdmin){
            l_Accounts[0].Name = 'TousseSally';
            update l_Accounts[0];
            test.starttest();  
                ApexPages.StandardController sc = new ApexPages.StandardController(l_assessments[0]);
                VFC10_CloneAssessment controller = new VFC10_CloneAssessment(sc);
                PageReference pageRef = Page.VFP10_CloneAssessment;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id', l_assessments[0].Id);
                controller.cloneAssessment();
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select Id from Assessment__c where Id <> null].size(),2);
    }


}