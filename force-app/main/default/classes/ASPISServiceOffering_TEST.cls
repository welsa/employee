/*************************************************************************************
Class Name - ASPISServiceOffering_TEST
Version - 1.0
Created Date - 06 OCTOBER 2016
Function - Test Class for class ASPISServiceOffering

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      06/10/2016  Reworked Version
*************************************************************************************/
@isTest
public class ASPISServiceOffering_TEST {
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static List<PartList__c> partList;
	static List<MasterRules__c> ruleSetList;
	static List<MasterRules__c> masterRuleList;
	static List<DetailRule__c> detailRuleList;
	static List<CaseDetailsProcessMapping__c> caseMappingList;
	static List<CountryCodeInformationsMapping__c> countryCodeMappingList;
	static BusinessHours defaultHours;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShopFR', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_1', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_2', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_3', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_4', 'FR')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment1', accountList[0])
			};

			assessmentList[0].EntityRules__c = 'AXA Direct';

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_ISSUED),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[2], ASPISConstants.PUR_ORDER_STATUS_ISSUED),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[3], ASPISConstants.PUR_ORDER_STATUS_ISSUED),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[4], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			insert purchaseOrderList;

			partList = new List<PartList__c>
			{
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0])
			};

			insert partList;
			
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].PartList__c = partList[0].Id;
			orderLineList[1].PartList__c = partList[1].Id;

			insert orderLineList;

			ruleSetList = new List<MasterRules__c>
			{
				TestFactory.createRuleSetSLAPOQuotation('AXA Direct')
			};

			ruleSetList[0].Process__c						= 'Offering';
			ruleSetList[0].DifferenceThreshold__c			= 15;
			ruleSetList[0].NeedThresholdComparison__c		= true;
			ruleSetList[0].sObject__c						= 'OrderLine__c';
			ruleSetList[0].FieldComparison__c				= 'AXAProfit__c';
			ruleSetList[0].AggregateFunctionComparison__c	= 'SUM';
			ruleSetList[0].Version__c						= 20;

			insert ruleSetList;

			masterRuleList = new List<MasterRules__c>
			{
				TestFactory.createMasterRule('AXA Direct', 'QUICK', 'OrderLine__c'),
				TestFactory.createMasterRule('AXA Direct', 'OPPORTUNITY', 'OrderLine__c'),
				TestFactory.createMasterRule('AXA Direct', 'BASIC', 'OrderLine__c'),
				TestFactory.createMasterRule('AXA Direct', 'QUICK1', 'OrderLine__c')
			};

			masterRuleList[0].IsPrimary__c			= true;
			masterRuleList[0].DisplayPriority__c	= 1;
			masterRuleList[0].RuleSet__c			= ruleSetList[0].Id;
			masterRuleList[1].RuleSet__c			= ruleSetList[0].Id;
			masterRuleList[2].RuleSet__c			= ruleSetList[0].Id;
			masterRuleList[3].RuleSet__c			= ruleSetList[0].Id;

			insert masterRuleList;

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'ExpectedDeliveryDuration__c', 'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'TECHIsSuppliable__c',		   'AGSUM',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'AXAPrice__c',				   'AGAVG',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id',						   'AGCOUNT',		'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'PurchaseOrder__c',			   'GROUPBY',		'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXEDD',					   'MIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMAXAP',					   'MIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMTECHIS/COUNTId',		   'EQUALS',		'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),

				TestFactory.createDetailRule('Offering', masterRuleList[1], 'PartList__c',				   'GROUPBY',		'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'ExpectedDeliveryDuration__c', 'AGMIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'AXAProfit__c',				   'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'MINEDD',					   'MIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'MAXPROFIT',				   'MAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'Id',						   'GROUPBY',		'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[1], 'MAXPROFIT',				   'GREATER',		'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),

				TestFactory.createDetailRule('Offering', masterRuleList[2], 'ExpectedDeliveryDuration__c', 'AGMIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[2], 'TECHIsSuppliable__c',		   'AGCOUNT',		'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[2], 'AXAProfit__c',				   'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[2], 'Id',						   'AGCOUNT',		'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[2], 'PurchaseOrder__c',			   'GROUPBY',		'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[2], 'SUMTECHIS/COUNTID',		   'GREATER',		'0.90', ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[2], 'MAXEDD',					   'LESS',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[2], 'MAXPROFIT',				   'LESS_EQUALS',	'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),

				TestFactory.createDetailRule('Offering', masterRuleList[3], 'ExpectedDeliveryDuration__c', 'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[3], 'TECHIsSuppliable__c',		   'AGSUM',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[3], 'AXAPrice__c',				   'AGAVG',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[3], 'Id',						   'AGCOUNT',		'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[3], 'PurchaseOrder__c',			   'GROUPBY',		'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[3], 'MAXEDD',					   'MAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[3], 'SUMAXAP',					   'MIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[3], 'SUMTECHIS/COUNTId',		   'EQUALS',		'0.90', ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
			};

			detailRuleList[0].Alias__c	= 'MAXEDD';
			detailRuleList[1].Alias__c	= 'SUMTECHIS';
			detailRuleList[2].Alias__c	= 'SUMAXAP';
			detailRuleList[3].Alias__c	= 'COUNTId';

			detailRuleList[9].Alias__c	= 'MINEDD';
			detailRuleList[10].Alias__c = 'MAXPROFIT';

			detailRuleList[15].Alias__c = 'MAXEDD';
			detailRuleList[16].Alias__c = 'SUMTECHIS';
			detailRuleList[17].Alias__c = 'MAXPROFIT';
			detailRuleList[18].Alias__c = 'COUNTID';

			detailRuleList[23].Alias__c = 'MAXEDD';
			detailRuleList[24].Alias__c = 'SUMTECHIS';
			detailRuleList[25].Alias__c = 'SUMAXAP';
			detailRuleList[26].Alias__c = 'COUNTId';

			insert detailRuleList;

			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			
			insert caseMappingList;

			defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			countryCodeMappingList[0].AutomaticOrder__c = true;
			countryCodeMappingList[1].AutomaticOrder__c = true;

			insert countryCodeMappingList;
		}
	}

	@isTest static void generateOffers_TEST()
	{
		System.runAs(adminUser)
		{
			ruleSetList[0].AggregateFunctionComparison__c = 'COUNT';
			update ruleSetList;

			ASPISServiceOffering soffer = new ASPISServiceOffering();
			
			Test.startTest();
				soffer.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 -- CLOSEDKO because the purchase orders does not have invoices
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			// 2 order line so 2 offer
			System.assertEquals(2, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}
}