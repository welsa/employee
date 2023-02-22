/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISOfferGeneration_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISOfferGeneration_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 27-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer			Date        Description
  -- ----------			----------  -----------------------
  -- Dourga Unmole (SC) 19/05/2015  Original Version
  -- Welsa Chan (SC)    12/07/2019  C-003320: conflict b/w preOffering and BEMultisourcing because TECH_OrderedCounter__c is incremented and 
                                              and OrderMakeSelection page, the prechecked offers are unchecked. Commenting line where 
                                              TECH_OrderedCounter__c = 1.
 **********************************************************************
*/
@isTest
public class ASPISOfferGeneration_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static List<PartList__c> partList;
	static List<PartList__c> parentPartList;
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

			parentPartList = new List<PartList__c>
			{
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0])
			};

			insert parentPartList; 

			partList = new List<PartList__c>
			{
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0])
			};
			partList[0].OriginalPart__c = parentPartList[0].Id;
			partList[1].OriginalPart__c = parentPartList[1].Id;

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

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
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

	@isTest static void updateParentPartlist_TEST()
	{
		System.runAs(adminUser)
		{
			ruleSetList[0].AggregateFunctionComparison__c = 'COUNT';
			update ruleSetList;

			assessmentList[0].OrderOrigin__c = 'Quotation';
			assessmentList[0].RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			update assessmentList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PartList__c> partListOrderedList = [SELECT	Id, TECH_OrderedCounter__c 
													FROM	PartList__c
													WHERE	Id IN: parentPartList
													AND TECH_OrderedCounter__c > 0];
			//WCH 10/10/2019 C-003320
			//System.assertEquals(2,partListOrderedList.size());
			System.assertEquals(0,partListOrderedList.size());
		}
	}

	@isTest static void generateOffersForBundle_TEST()
	{
		System.runAs(adminUser)
		{
			ruleSetList[0].AggregateFunctionComparison__c = 'COUNT';
			update ruleSetList;

			List<OrderLine__c> bundleOrderLines = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			bundleOrderLines[0].OriginalItem__c = orderLineList[0].Id;
			bundleOrderLines[1].OriginalItem__c = orderLineList[0].Id;

			bundleOrderLines[0].OrderType__c	= 'BUNDLEITEM';
			bundleOrderLines[1].OrderType__c	= 'BUNDLEITEM';

			insert bundleOrderLines;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			// 4 order line so 4 offer
			System.assertEquals(4, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersNotSuppliable_TEST()
	{
		System.runAs(adminUser)
		{
			ruleSetList[0].AggregateFunctionComparison__c = 'MIN';
			update ruleSetList;

			orderLineList[0].Suppliable__c = 'NO';
			orderLineList[1].Suppliable__c = 'NO';

			update orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			// No offer should be created
			System.assertEquals(0, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(0, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersCreateCase_TEST()
	{
		System.runAs(adminUser)
		{
			delete orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			// No order line so no offer
			System.assertEquals(0, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(0, insertedSalesOrder.size());

			List<Case__c> caseInsertedList = [SELECT Id
											  FROM	 Case__c
											  WHERE	 Assesment__c =: assessmentList[0].Id];

			System.assertEquals(2, caseInsertedList.size());
		}
	}

	@isTest static void generateOffersFor2PO_TEST()
	{
		System.runAs(adminUser)
		{
			ruleSetList[0].AggregateFunctionComparison__c = 'MAX';
			update ruleSetList;


			// deleting the orderline list so as to create an orderline belonging to another purchase order
			delete orderLineList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].PartList__c				 = partList[0].Id;
			orderLineList[1].PartList__c				 = partList[1].Id;

			orderLineList[1].ExpectedDeliveryDuration__c = '2';
			orderLineList[1].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
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

	@isTest static void generateOffersFor4PO_TEST()
	{
		System.runAs(adminUser)
		{
			ruleSetList[0].AggregateFunctionComparison__c = 'MAX';
			update ruleSetList;


			// deleting the orderline list so as to create an orderline belonging to another purchase order
			delete orderLineList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].PartList__c				 = partList[0].Id;
			orderLineList[1].PartList__c				 = partList[0].Id;
			orderLineList[2].PartList__c				 = partList[0].Id;
			orderLineList[3].PartList__c				 = partList[1].Id;

			orderLineList[1].Suppliable__c				 = 'NO';
			orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			// 4 order line so 4 offer
			// but 2 of them is not suppliable
			// so we get 2 offers only
			System.assertEquals(2, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersQuick_TEST()
	{
		System.runAs(adminUser)
		{
			// Deleting other master rule so as to trigger the Quick master rule
			delete new List<MasterRules__c>
			{
				masterRuleList[1],
				masterRuleList[2],
				masterRuleList[3]
			};

			// deleting the orderline list so as to create an orderline belonging to another purchase order
			delete orderLineList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].PartList__c				 = partList[0].Id;
			orderLineList[1].PartList__c				 = partList[0].Id;
			orderLineList[2].PartList__c				 = partList[0].Id;
			orderLineList[3].PartList__c				 = partList[1].Id;

			orderLineList[1].Suppliable__c				 = 'NO';
			orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(2, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersGreater_TEST()
	{
		System.runAs(adminUser)
		{
			delete new List<MasterRules__c>
			{
				masterRuleList[1],
				masterRuleList[2],
				masterRuleList[3]
			};

			masterRuleList[0].RuleStatus__c = 'ARCHIVED';
			update masterRuleList[0];

			delete new List<DetailRule__c>
			{
				detailRuleList[0],
				detailRuleList[1],
				detailRuleList[2],
				detailRuleList[3],
				detailRuleList[4],
				detailRuleList[5],
				detailRuleList[6],
				detailRuleList[7]
			};

			masterRuleList[0].RuleStatus__c = 'ACTIVE';
			update masterRuleList[0];

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'ExpectedDeliveryDuration__c',	'AGMIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'TECHIsSuppliable__c',			'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'AXAProfit__c',					'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id',							'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'PurchaseOrder__c',				'GROUPBY',			'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMTECHIS/COUNTID',			'GREATER',			'0.90',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXEDD',						'LESS',				'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXPROFIT',					'GREATER',			'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
			};

			detailRuleList[0].Alias__c = 'MAXEDD';
			detailRuleList[1].Alias__c = 'SUMTECHIS';
			detailRuleList[2].Alias__c = 'MAXPROFIT';
			detailRuleList[3].Alias__c = 'COUNTID';

			insert detailRuleList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			//orderLineList[0].PartList__c				 = partList[0].Id;
			//orderLineList[1].PartList__c				 = partList[0].Id;
			//orderLineList[2].PartList__c				 = partList[0].Id;
			//orderLineList[3].PartList__c				 = partList[1].Id;

			orderLineList[1].Suppliable__c				 = 'NO';
			orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(0, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(0, insertedSalesOrder.size());
		}
	}
	
	@isTest static void generateOffersGreaterEquals_TEST()
	{
		System.runAs(adminUser)
		{
			delete new List<MasterRules__c>
			{
				masterRuleList[1],
				masterRuleList[2],
				masterRuleList[3]
			};

			masterRuleList[0].RuleStatus__c = 'ARCHIVED';
			update masterRuleList[0];

			delete new List<DetailRule__c>
			{
				detailRuleList[0],
				detailRuleList[1],
				detailRuleList[2],
				detailRuleList[3],
				detailRuleList[4],
				detailRuleList[5],
				detailRuleList[6],
				detailRuleList[7]
			};

			masterRuleList[0].RuleStatus__c = 'ACTIVE';
			update masterRuleList[0];

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'ExpectedDeliveryDuration__c',	'AGMIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'TECHIsSuppliable__c',			'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'AXAProfit__c',					'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id',							'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'PurchaseOrder__c',				'GROUPBY',			'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMTECHIS/COUNTID',			'GREATER_EQUALS',	'0.90',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXEDD',						'LESS',				'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXPROFIT',					'GREATER_EQUALS',	'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
			};

			detailRuleList[0].Alias__c = 'MAXEDD';
			detailRuleList[1].Alias__c = 'SUMTECHIS';
			detailRuleList[2].Alias__c = 'MAXPROFIT';
			detailRuleList[3].Alias__c = 'COUNTID';

			insert detailRuleList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			//orderLineList[0].PartList__c				 = partList[0].Id;
			//orderLineList[1].PartList__c				 = partList[0].Id;
			//orderLineList[2].PartList__c				 = partList[0].Id;
			//orderLineList[3].PartList__c				 = partList[1].Id;

			orderLineList[1].Suppliable__c				 = 'NO';
			orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(0, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(0, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersLess_TEST()
	{
		System.runAs(adminUser)
		{
			delete new List<MasterRules__c>
			{
				masterRuleList[1],
				masterRuleList[2],
				masterRuleList[3]
			};

			masterRuleList[0].RuleStatus__c = 'ARCHIVED';
			update masterRuleList[0];

			delete new List<DetailRule__c>
			{
				detailRuleList[0],
				detailRuleList[1],
				detailRuleList[2],
				detailRuleList[3],
				detailRuleList[4],
				detailRuleList[5],
				detailRuleList[6],
				detailRuleList[7]
			};

			masterRuleList[0].RuleStatus__c = 'ACTIVE';
			update masterRuleList[0];

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'ExpectedDeliveryDuration__c',	'AGMIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'TECHIsSuppliable__c',			'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'AXAProfit__c',					'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id',							'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'PurchaseOrder__c',				'GROUPBY',			'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMTECHIS/COUNTID',			'LESS',				'10',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXEDD',						'LESS',				'1.1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXPROFIT',					'LESS',				'1000',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
			};

			detailRuleList[0].Alias__c = 'MAXEDD';
			detailRuleList[1].Alias__c = 'SUMTECHIS';
			detailRuleList[2].Alias__c = 'MAXPROFIT';
			detailRuleList[3].Alias__c = 'COUNTID';

			insert detailRuleList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			//orderLineList[0].PartList__c				 = partList[0].Id;
			//orderLineList[1].PartList__c				 = partList[0].Id;
			//orderLineList[2].PartList__c				 = partList[0].Id;
			//orderLineList[3].PartList__c				 = partList[1].Id;

			orderLineList[0].ExpectedDeliveryDuration__c = '1';
			orderLineList[1].ExpectedDeliveryDuration__c = '1';
			orderLineList[2].ExpectedDeliveryDuration__c = '1';
			orderLineList[3].ExpectedDeliveryDuration__c = '1';

			orderLineList[0].Suppliable__c				 = 'NO';
			orderLineList[1].Suppliable__c				 = 'NO';
			orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(3, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersLessEquals_TEST()
	{
		System.runAs(adminUser)
		{
			delete new List<MasterRules__c>
			{
				masterRuleList[1],
				masterRuleList[2],
				masterRuleList[3]
			};

			masterRuleList[0].RuleStatus__c = 'ARCHIVED';
			update masterRuleList[0];

			delete new List<DetailRule__c>
			{
				detailRuleList[0],
				detailRuleList[1],
				detailRuleList[2],
				detailRuleList[3],
				detailRuleList[4],
				detailRuleList[5],
				detailRuleList[6],
				detailRuleList[7]
			};

			masterRuleList[0].RuleStatus__c = 'ACTIVE';
			update masterRuleList[0];

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'ExpectedDeliveryDuration__c',	'AGMIN',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'TECHIsSuppliable__c',			'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'AXAProfit__c',					'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id',							'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'PurchaseOrder__c',				'GROUPBY',			'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMTECHIS/COUNTID',			'LESS_EQUALS',		'10',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXEDD',						'LESS_EQUALS',		'10',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXPROFIT',					'LESS_EQUALS',		'1000',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
			};

			detailRuleList[0].Alias__c = 'MAXEDD';
			detailRuleList[1].Alias__c = 'SUMTECHIS';
			detailRuleList[2].Alias__c = 'MAXPROFIT';
			detailRuleList[3].Alias__c = 'COUNTID';

			insert detailRuleList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			//orderLineList[1].Suppliable__c				 = 'NO';
			//orderLineList[2].Suppliable__c				 = 'NO';
			//orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(3, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersQuick2_TEST()
	{
		System.runAs(adminUser)
		{
			// Deleting other master rule so as to trigger the Quick master rule
			delete new List<MasterRules__c>
			{
				masterRuleList[1],
				masterRuleList[2],
				masterRuleList[3]
			};

			masterRuleList[0].RuleStatus__c = 'ARCHIVED';
			update masterRuleList[0];

			delete new List<DetailRule__c>
			{
				detailRuleList[0],
				detailRuleList[1],
				detailRuleList[2],
				detailRuleList[3],
				detailRuleList[4],
				detailRuleList[5],
				detailRuleList[6],
				detailRuleList[7]
			};

			masterRuleList[0].RuleStatus__c = 'ACTIVE';
			update masterRuleList[0];

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'ExpectedDeliveryDuration__c',	'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'TECHIsSuppliable__c',			'AGSUM',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'AXAPrice__c',					'AGAVG',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id',							'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'PurchaseOrder__c',				'GROUPBY',			'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXEDD',						'MIN',				'2',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMAXAP',						'MIN',				'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMTECHIS/COUNTID',			'LESS',				'2',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
			};

			detailRuleList[0].Alias__c = 'MAXEDD';
			detailRuleList[1].Alias__c = 'SUMTECHIS';
			detailRuleList[2].Alias__c = 'SUMAXAP';
			detailRuleList[3].Alias__c = 'COUNTID';

			insert detailRuleList;

			// deleting the orderline list so as to create an orderline belonging to another purchase order
			delete orderLineList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].PartList__c				 = partList[0].Id;
			orderLineList[1].PartList__c				 = partList[0].Id;
			orderLineList[2].PartList__c				 = partList[0].Id;
			orderLineList[3].PartList__c				 = partList[1].Id;

			//orderLineList[1].Suppliable__c				 = 'NO';
			//orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(1, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}

	@isTest static void generateOffersQuick3_TEST()
	{
		System.runAs(adminUser)
		{
			// Deleting other master rule so as to trigger the Quick master rule
			delete new List<MasterRules__c>
			{
				masterRuleList[1],
				masterRuleList[2],
				masterRuleList[3]
			};

			masterRuleList[0].RuleStatus__c = 'ARCHIVED';
			update masterRuleList[0];

			delete new List<DetailRule__c>
			{
				detailRuleList[0],
				detailRuleList[1],
				detailRuleList[2],
				detailRuleList[3],
				detailRuleList[4],
				detailRuleList[5],
				detailRuleList[6],
				detailRuleList[7]
			};

			masterRuleList[0].RuleStatus__c = 'ACTIVE';
			update masterRuleList[0];

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'ExpectedDeliveryDuration__c',	'AGMAX',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'TECHIsSuppliable__c',			'AGSUM',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'AXAPrice__c',					'AGAVG',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'Id',							'AGCOUNT',			'1',	ASPISConstants.CRITERIA_RT_LABEL_AggregateCriteria, 'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'PurchaseOrder__c',				'GROUPBY',			'1',	ASPISConstants.CRITERIA_RT_LABEL_GroupByCriteria,	'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'MAXEDD',						'MAX',				'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMAXAP',						'MAX',				'1',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100),
				TestFactory.createDetailRule('Offering', masterRuleList[0], 'SUMTECHIS/COUNTID',			'GREATER',			'0',	ASPISConstants.CRITERIA_RT_LABEL_CRITERIA,			'OrderLine__c', 100)
			};

			detailRuleList[0].Alias__c = 'MAXEDD';
			detailRuleList[1].Alias__c = 'SUMTECHIS';
			detailRuleList[2].Alias__c = 'SUMAXAP';
			detailRuleList[3].Alias__c = 'COUNTID';

			insert detailRuleList;

			// deleting the orderline list so as to create an orderline belonging to another purchase order
			delete orderLineList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].PartList__c				 = partList[0].Id;
			orderLineList[1].PartList__c				 = partList[0].Id;
			orderLineList[2].PartList__c				 = partList[0].Id;
			orderLineList[3].PartList__c				 = partList[1].Id;

			orderLineList[4].ExpectedDeliveryDuration__c = '2';

			//orderLineList[1].Suppliable__c				 = 'NO';
			//orderLineList[3].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(2, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(1, insertedSalesOrder.size());
		}
	}

	@isTest static void noRuleSet_TEST()
	{
		System.runAs(adminUser)
		{
			delete ruleSetList;

			masterRuleList = new List<MasterRules__c>
			{
				TestFactory.createMasterRule('AXA Direct', 'Offering', 'OrderLine__c')
			};

			masterRuleList[0].IsPrimary__c			= true;
			masterRuleList[0].DisplayPriority__c	= 1;

			insert masterRuleList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			System.assertEquals(0, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(0, insertedSalesOrder.size());
		}
	}

	@isTest static void notSuppliableOrderLine_TEST()
	{
		System.runAs(adminUser)
		{
			ruleSetList[0].AggregateFunctionComparison__c = 'MAX';
			update ruleSetList;


			// deleting the orderline list so as to create an orderline belonging to another purchase order
			delete orderLineList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].PartList__c				 = partList[0].Id;
			orderLineList[1].PartList__c				 = partList[0].Id;
			orderLineList[2].PartList__c				 = partList[0].Id;
			orderLineList[3].PartList__c				 = partList[1].Id;
			orderLineList[4].PartList__c				 = partList[1].Id;

			orderLineList[0].Suppliable__c				 = 'NO';
			orderLineList[1].Suppliable__c				 = 'NO';
			orderLineList[2].Suppliable__c				 = 'NO';
			orderLineList[3].Suppliable__c				 = 'NO';
			orderLineList[4].Suppliable__c				 = 'NO';

			insert orderLineList;

			ASPISOfferGeneration offerGenerator = new ASPISOfferGeneration();

			Test.startTest();
				offerGenerator.executeProcess(assessmentList[0]);
			Test.stopTest();

			List<PurchaseOrder__c> canceledPurchaseOrderList = [SELECT	Id, Status__c, Reason__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList
																// ABT - 19-OCT-2016 - C-001677 - Purchase order becomes CLOSEDKO
																AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];
																//AND		Status__c =: ASPISConstants.PUR_ORDER_STATUS_CANCELED];

			System.assertEquals(1,				canceledPurchaseOrderList.size());
			System.assertEquals('QUOTETIMEOUT', canceledPurchaseOrderList[0].Reason__c);

			List<Offer__c> generatedOfferList = [SELECT	Id
												 FROM	Offer__c
												 WHERE	OrderLine__c != null];
			
			// 4 order line so 4 offer
			// but 2 of them is not suppliable
			// so we get 2 offers only
			System.assertEquals(0, generatedOfferList.size());

			List<PrerequisiteOrder__c> insertedSalesOrder = [SELECT Id
															 FROM	PrerequisiteOrder__c
															 WHERE	Id NOT IN: salesOrderList];

			System.assertEquals(0, insertedSalesOrder.size());
		}
	}
}