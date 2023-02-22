/*
----------------------------------------------------------------------
-- - Name          : OrderManualPOCreation_TEST
-- - Author        : VSU
-- - Description   : Test for controller OrderManualPOCreation
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 14-JUN-2017  VSU     1.0         Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest 
private class OrderManualPOCreation_TEST{
    static User adminUser;
    static BusinessHours defaultHours;
    static list <Account> accountList;
    static list <Assessment__c> assessmentList;
    static list <PartList__c> PartList;
    static list <DetailRule__c> detailRuleList = new list <DetailRule__c> ();
    static list <MasterRules__c> masterRuleList = new list <MasterRules__c> ();
    static list <MasterRules__c> ruleSetList = new list <MasterRules__c> ();
    static list <CountryCodeInformationsMapping__c> countryMappingList = new list <CountryCodeInformationsMapping__c> ();

    static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			defaultHours = [SELECT  Id 
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            countryMappingList = new List<CountryCodeInformationsMapping__c>
            {
                TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id)
            };
            
            countryMappingList[0].Validity_Duration_Purchase_Order__c = 50;
            
            insert countryMappingList;

            ruleSetList = new List<MasterRules__c>
			{
				TestFactory.createRuleSetSLAPOQuotation('DE515')
			};

			ruleSetList[0].Process__c						= 'Offering';
			ruleSetList[0].DifferenceThreshold__c			= 15;
			ruleSetList[0].NeedThresholdComparison__c		= true;
			ruleSetList[0].sObject__c						= 'OrderLine__c';
			ruleSetList[0].FieldComparison__c				= 'AXAProfit__c';
			ruleSetList[0].AggregateFunctionComparison__c	= 'SUM';
			ruleSetList[0].Version__c						= 20;

			insert ruleSetList;

            masterRuleList = new list <MasterRules__c> {
				TestFactory.createMasterRule('DE515(2)', 'Sourcing', 'Assessment__c'),
				TestFactory.createMasterRule('DE515', 'QUICK', 'OrderLine__c')
            };

            masterRuleList[1].IsPrimary__c			= true;
			masterRuleList[1].DisplayPriority__c	= 1;
			masterRuleList[1].RuleSet__c			= ruleSetList[0].Id;

            masterRuleList[0].FilterLogic__c = '(1 AND 2 AND 3 AND 4)';

            insert masterRuleList;

            detailRuleList = new list <DetailRule__c> {
            	TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'ShippingCountry', 'EQUALS', 'BodyShop__r.ShippingCountry', 'Filter Condition', 'Account', 1),
            	TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'RecordType.Name', 'EQUALS', 'DISTRIBUTOR', 'Filter Condition', 'Account', 2),
            	TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'Categories__c', 'IN', 'SelectedByBSPartTypes__c', 'Filter Condition', 'Account', 3),
            	TestFactory.createDetailRule('Sourcing', masterRuleList[0], 'DistributorRegionsCovered__c', 'IN', 'BodyShop__r.ShippingPostalCodeLeft2__c', 'Filter Condition', 'Account', 4),
            	
            	TestFactory.createDetailRule('Offering', masterRuleList[1], 'ExpectedDeliveryDuration__c', 'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'TECHIsSuppliable__c',		   'AGSUM',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'AXAPrice__c',				   'AGAVG',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'Id',						   'AGCOUNT',		'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'PurchaseOrder__c',			   'GROUPBY',		'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'MAXEDD',					   'MIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'SUMAXAP',					   'MIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'SUMTECHIS/COUNTId',		   'EQUALS',		'0.90', ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
            };

            detailRuleList[0].ValueFrom__c = 'Master sObject';
            detailRuleList[1].ValueFrom__c = 'Criteria sObject';
            detailRuleList[2].ValueFrom__c = 'Master sObject';           
            detailRuleList[3].ValueFrom__c = 'Master sObject';
            detailRuleList[0].Alias__c	= 'MAXEDD';
			detailRuleList[1].Alias__c	= 'SUMTECHIS';
			detailRuleList[2].Alias__c	= 'SUMAXAP';
			detailRuleList[3].Alias__c	= 'COUNTId';
			insert detailRuleList;

			accountList = new List<Account>{
				TestFactory.createAccountBodyshop('BodyShop_1', 'DE'),
				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_1','DE'),
				TestFactory.createAccountDistributor('Distributor_2' ,'DE')
			};

			accountList[0].isEligible__c 	= false;
			accountList[1].isEligible__c 	= true;
			accountList[2].Categories__c    = 'A';

			insert accountList;

			assessmentList = new List<Assessment__c>{
				new Assessment__c(TECH_EntityCountryCode__c = 'DE',status__c = 'READY',bodyshop__c = accountList[0].id, Manufacturer__c = 'xxx'),
				new Assessment__c(TECH_EntityCountryCode__c = 'ES',Status__c = 'New',bodyshop__c = accountList[0].id)
			};
			assessmentList[0].entityCode__c = '515';
			assessmentList[0].RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			insert assessmentList;
			
			PartList = new list <PartList__c>{
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0])
			};

			PartList[0].type__c='A';
			PartList[1].type__c='A';

			insert PartList;
		}
	}

    @isTest static void constructor_TEST(){
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.OrderManualPOCreation);

			ApexPages.currentPage().getParameters().put('Id',assessmentList[0].id);

			Test.startTest();
				OrderManualPOCreation controller = new OrderManualPOCreation();
			Test.stopTest();

			Assessment__c ass = [Select id,(select id from PartsLists__r)
								from Assessment__c 
								where id =: assessmentList[0].id];

			system.debug('##ass'+ ass);
			system.debug('##ass'+ ass.PartsLists__r);
			System.assertEquals(ass.PartsLists__r.size(),controller.noOfParts);
			System.assertEquals(true,controller.manualSourcing);
		}
	} 

	@isTest static void redirectBack_TEST(){
		System.runAs(adminUser){
			Test.setCurrentPage(Page.OrderManualPOCreation);

			ApexPages.currentPage().getParameters().put('Id' , assessmentList[0].id);

			Test.startTest();
				OrderManualPOCreation controller = new OrderManualPOCreation();
			Test.stopTest();

			system.assertEquals('/'+assessmentList[0].id,controller.back().getUrl()); 
		}
	}

	@isTest static void validate_TEST(){
		System.runAs(adminUser){
			Test.setCurrentPage(Page.OrderManualPOCreation);

			ApexPages.currentPage().getParameters().put('Id' , assessmentList[0].id);

			Test.startTest();
				OrderManualPOCreation controller = new OrderManualPOCreation();
			Test.stopTest();

			controller.assessmentDE.PartsLists__r[0].selectedByBS__c = true;

			controller.validate();

			list <purchaseOrder__c> poList = [Select id 
												from purchaseOrder__c 
												where Assessment__c =: assessmentList[0].id];
			system.assert(poList.size()>0);

			Assessment__c ass = [Select status__c,(select selectedByBS__c from PartsLists__r) 
									from Assessment__c 
									where id =: assessmentList[0].id];

			system.assertEquals('SOURCED',ass.status__c);

			system.assertEquals(true,ass.PartsLists__r[0].selectedByBS__c);

			system.assertEquals('/'+assessmentList[0].id,controller.validate().getUrl());
		}
	}

	@isTest static void manualSourcingFalse(){
		System.runAs(adminUser){
			Test.setCurrentPage(Page.OrderManualPOCreation);

			ApexPages.currentPage().getParameters().put('Id' , assessmentList[1].id);

			Test.startTest();
				OrderManualPOCreation controller = new OrderManualPOCreation();
			Test.stopTest();

			system.assertEquals(false,controller.manualSourcing);
		}
	}

	@isTest static void errorUpdatingPartList(){
		System.runAs(adminUser){
			Test.setCurrentPage(Page.OrderManualPOCreation);

			ApexPages.currentPage().getParameters().put('Id' , assessmentList[0].id);
			
			OrderManualPOCreation controller = new OrderManualPOCreation();			

			PartList__c pl = new PartList__c();

			controller.partLists.add(pl);

			Test.startTest();

				controller.validate();

			Test.stopTest();	

			system.assertEquals(true,controller.hasErrors);

			system.assertEquals(false,controller.isToastError);
		}
	}

	@isTest static void errorUpdatingAssessment(){
		System.runAs(adminUser){
			Test.setCurrentPage(Page.OrderManualPOCreation);

			ApexPages.currentPage().getParameters().put('Id' , assessmentList[0].id);
			
			OrderManualPOCreation controller = new OrderManualPOCreation();	

			controller.assessmentDE.id = null;

			Test.startTest();	

				controller.validate();

			Test.stopTest();

			system.assertEquals(true,controller.hasErrors);

			system.assertEquals(false,controller.isToastError);
		}
	}
}