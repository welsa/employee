/*
  ----------------------------------------------------------------------
  -- - Name          : Utils_SLARulesEngine_TEST
  -- - Author        : ABT
  -- - Description   : Test class for Utils_SLARulesEngine
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 21-SEP-2016  ABT    1.0     Initial Version
  -- 17-SEP-2020  KPA    1.1     C-003930: Test Classes IG
  ----------------------------------------------------------------------
  -- Remarks:	-- Will result into error if the field passed as parameter is date/time and the field in which the calculated value would be written is a date field 
  --			-- For SO the field is castes to Date, this will may make the calculation of BusinessHours go wrong as the time is lost in casting
 **********************************************************************
*/
@isTest
public class Utils_SLARulesEngine_TEST
{
	static User adminUser;
	static List<MasterRules__c> ruleSetList;
	static List<MasterRules__c> masterRuleList;
	static List<DetailRule__c> detailRuleList;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static List<Offer__c> offerList;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			ruleSetList = new List<MasterRules__c>
			{
				TestFactory.createRuleSetSLAPOQuotation('FR299'),
				TestFactory.createRuleSetSLAPOQuotation('ES299'),
				TestFactory.createRuleSetSLAPOQuotation('IT299'),
				TestFactory.createRuleSetSLAPOQuotation('DE299')
			};

			insert ruleSetList;

			masterRuleList = new List<MasterRules__c>
			{
				TestFactory.createMasterRule('FR299', 'QUOTATION', 'PurchaseOrder__c'),
				TestFactory.createMasterRule('ES299', 'QUOTATION', 'PurchaseOrder__c'),
				TestFactory.createMasterRule('IT299', 'QUOTATION', 'PurchaseOrder__c'),

				// ------------------ SALES ORDER --------------------------------
				TestFactory.createMasterRule('FR299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c'),
				TestFactory.createMasterRule('ES299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c'),
				TestFactory.createMasterRule('IT299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c'),

				TestFactory.createMasterRule('DE299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c')
			};

			masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
			masterRuleList[1].RuleSet__c = ruleSetList[1].Id;
			masterRuleList[2].RuleSet__c = ruleSetList[2].Id;

			// The sales order master rule belong to the same rules set as the PO master rule
			masterRuleList[3].RuleSet__c = ruleSetList[0].Id;
			masterRuleList[4].RuleSet__c = ruleSetList[1].Id;
			masterRuleList[5].RuleSet__c = ruleSetList[2].Id;

			masterRuleList[6].RuleSet__c = ruleSetList[3].Id;

			insert masterRuleList;

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel1__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel2__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 2),
				TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel3__c', 'EQUALS', '25', 'Parameters', 'PurchaseOrder__c', 3),

				TestFactory.createDetailRule(null, masterRuleList[1], 'SLAQuotationLevel1__c', 'EQUALS', '1', 'Parameters', 'PurchaseOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[1], 'SLAQuotationLevel2__c', 'EQUALS', '2', 'Parameters', 'PurchaseOrder__c', 2),
				TestFactory.createDetailRule(null, masterRuleList[1], 'SLAQuotationLevel3__c', 'EQUALS', '8', 'Parameters', 'PurchaseOrder__c', 3),

				TestFactory.createDetailRule(null, masterRuleList[2], 'SLAQuotationLevel1__c', 'EQUALS', '15', 'Parameters', 'PurchaseOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[2], 'SLAQuotationLevel2__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 2),
				TestFactory.createDetailRule(null, masterRuleList[2], 'SLAQuotationLevel3__c', 'EQUALS', '45', 'Parameters', 'PurchaseOrder__c', 3),


				// -------------------------------------------- SALES ORDER -------------------------------------------------------
				TestFactory.createDetailRule(null, masterRuleList[3], 'SLAInDeliveryLevel1__c', 'EQUALS', '1', 'Parameters', 'PrerequisiteOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[3], 'SLAInDeliveryLevel2__c', 'EQUALS', '2', 'Parameters', 'PrerequisiteOrder__c', 2),
				TestFactory.createDetailRule(null, masterRuleList[3], 'SLAInDeliveryLevel3__c', 'EQUALS', '3', 'Parameters', 'PrerequisiteOrder__c', 3),

				TestFactory.createDetailRule(null, masterRuleList[4], 'SLAInDeliveryLevel1__c', 'EQUALS', '1', 'Parameters', 'PrerequisiteOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[4], 'SLAInDeliveryLevel2__c', 'EQUALS', '2', 'Parameters', 'PrerequisiteOrder__c', 2),
				TestFactory.createDetailRule(null, masterRuleList[4], 'SLAInDeliveryLevel3__c', 'EQUALS', '8', 'Parameters', 'PrerequisiteOrder__c', 3),

				TestFactory.createDetailRule(null, masterRuleList[5], 'SLAInDeliveryLevel1__c', 'EQUALS', '15', 'Parameters', 'PrerequisiteOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[5], 'SLAInDeliveryLevel2__c', 'EQUALS', '30', 'Parameters', 'PrerequisiteOrder__c', 2),
				TestFactory.createDetailRule(null, masterRuleList[5], 'SLAInDeliveryLevel3__c', 'EQUALS', '45', 'Parameters', 'PrerequisiteOrder__c', 3),

				TestFactory.createDetailRule(null, masterRuleList[6], 'SLADeliveryConfirmedEntryDate__c', 'EQUALS', '1', 'Parameters', 'PrerequisiteOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[6], 'SLARespondedEntryDate__c', 'EQUALS', '2', 'Parameters', 'PrerequisiteOrder__c', 2)
			};

			detailRuleList[0].ValueFrom__c	= 'H';
			detailRuleList[1].ValueFrom__c	= 'H';
			detailRuleList[2].ValueFrom__c	= 'H';

			detailRuleList[3].ValueFrom__c	= 'H';
			detailRuleList[4].ValueFrom__c	= 'H';
			detailRuleList[5].ValueFrom__c	= 'H';

			detailRuleList[6].ValueFrom__c	= 'H';
			detailRuleList[7].ValueFrom__c	= 'H';
			detailRuleList[8].ValueFrom__c	= 'H';

			detailRuleList[9].ValueFrom__c	= 'H';
			detailRuleList[10].ValueFrom__c = 'H';
			detailRuleList[11].ValueFrom__c = 'H';

			detailRuleList[12].ValueFrom__c	= 'H';
			detailRuleList[13].ValueFrom__c = 'H';
			detailRuleList[14].ValueFrom__c = 'H';

			detailRuleList[15].ValueFrom__c	= 'H';
			detailRuleList[16].ValueFrom__c = 'H';
			detailRuleList[17].ValueFrom__c = 'H';

			detailRuleList[18].ValueFrom__c	= 'H';
			detailRuleList[19].ValueFrom__c = 'H';
			
			// Also needs to set it active
			detailRuleList[9].Active__c		= true;
			detailRuleList[10].Active__c	= true;
			detailRuleList[11].Active__c	= true;

			detailRuleList[12].Active__c	= true;
			detailRuleList[13].Active__c	= true;
			detailRuleList[14].Active__c	= true;

			detailRuleList[15].Active__c	= true;
			detailRuleList[16].Active__c	= true;
			detailRuleList[17].Active__c	= true;

			detailRuleList[18].Active__c	= true;
			detailRuleList[19].Active__c	= true;

			insert detailRuleList;

			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
				TestFactory.createAccountDistributor('Distributor_FR', 'FR')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0])
			};

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_DELIVERED)
			};

			salesOrderList[0].SLAInDeliveryEntryDate__c = System.now();

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
			};

			// for PO with date coverage
			purchaseOrderList[0].EstimatedDeliveryDate__c = System.today();

			insert purchaseOrderList;

			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
			};

			insert orderLineList;

			// Generating offers
			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY)
			};

			offerList[0].ExpectedDeliveryDate__c = System.today();
			offerList[1].ExpectedDeliveryDate__c = System.today();
			offerList[2].ExpectedDeliveryDate__c = System.today();

			insert offerList;

			// access Business Hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('IT', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id)
			};
			
			insert countryMappingList;
		}
	}

	@isTest static void getRules_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'FR299'
			};

			// Calling the function getRules with the passed parameters
			Test.startTest();
				Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('QUOTATION', entityRulesSet, 'PurchaseOrder__c');
			Test.stopTest();

			System.assertNotEquals(null, mapEntityDetailRules);
			System.assertEquals(1, mapEntityDetailRules.size());
			System.assertNotEquals(null, mapEntityDetailRules.get('FR299'));
			System.assertEquals(3, mapEntityDetailRules.get('FR299').size());
		}
	}

	@isTest static void calSLALevelsUsingRulesEngineV2_D_WithPODateTime_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'FR299'
			};
			
			// Calling the function getRules with the passed parameters
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('QUOTATION', entityRulesSet, 'PurchaseOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('FR');

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(purchaseOrderList[0], 'FR299', 'purchaseOrder', 'SLAQuotationEntryDate__c', 'FR', mapEntityDetailRules, 60 * 60 * 1000L, businessDays);
			Test.stopTest();

			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel1__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel2__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel3__c);
			system.debug('##purchaseOrderList[0].SLAQuotationLevel1__c: '+purchaseOrderList[0].SLAQuotationLevel1__c);
			system.debug('##businesshours: '+BusinessHours.add(businessDays.id,purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[0].Value__c)));
			System.assertEquals(true, BusinessHours.add(businessDays.id,purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[0].Value__c)*60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel1__c));
			System.assertEquals(true, BusinessHours.add(businessDays.id,purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[1].Value__c)*60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel2__c));
			System.assertEquals(true, BusinessHours.add(businessDays.id,purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[2].Value__c)*60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel3__c));
		}
	}

	@isTest static void calSLALevelsUsingRulesEngineV2_D_WithPODate_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'FR299'
			};
			
			// Calling the function getRules with the passed parameters
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('QUOTATION', entityRulesSet, 'PurchaseOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('FR');

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(purchaseOrderList[0], 'FR299', 'purchaseOrder', 'EstimatedDeliveryDate__c', 'FR', mapEntityDetailRules, 60 * 60 * 1000L, businessDays);
			Test.stopTest();

			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel1__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel2__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel3__c);
			System.assertEquals(true, BusinessHours.add(businessDays.id,purchaseOrderList[0].EstimatedDeliveryDate__c, Integer.valueOf(detailRuleList[0].Value__c)*60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel1__c.date()));
			System.assertEquals(true, BusinessHours.add(businessDays.id,purchaseOrderList[0].EstimatedDeliveryDate__c, Integer.valueOf(detailRuleList[1].Value__c)*60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel2__c.date()));
			System.assertEquals(true, BusinessHours.add(businessDays.id,purchaseOrderList[0].EstimatedDeliveryDate__c, Integer.valueOf(detailRuleList[2].Value__c)*60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel3__c.date()));
		}
	}

	@isTest static void calSLALevelsUsingRulesEngineV2_H_WithPO_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'ES299'
			};
			
			// Calling the function getRules with the passed parameters for ES299
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('QUOTATION', entityRulesSet, 'PurchaseOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('ES');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('ES');

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(purchaseOrderList[0], 'ES299', 'purchaseOrder', 'SLAQuotationEntryDate__c', 'ES', mapEntityDetailRules, 60 * 60 * 1000L, businessDays);
			Test.stopTest();

			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel1__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel2__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel3__c);
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[3].Value__c) * 60 * 60 * 1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel1__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[4].Value__c) * 60 * 60 * 1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel2__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[5].Value__c) * 60 * 60 * 1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel3__c));
		}
	}

	@isTest static void calSLALevelsUsingRulesEngineV2_M_WithPO_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'IT299'
			};
			
			// Calling the function getRules with the passed parameters for IT299
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('QUOTATION', entityRulesSet, 'PurchaseOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('IT');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('IT');

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(purchaseOrderList[0], 'IT299', 'purchaseOrder', 'SLAQuotationEntryDate__c', 'IT', mapEntityDetailRules, 60 * 60 * 1000L, businessDays);
			Test.stopTest();

			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel1__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel2__c);
			System.assertNotEquals(null, purchaseOrderList[0].SLAQuotationLevel3__c);
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[6].Value__c) *60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel1__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[7].Value__c) *60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel2__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, purchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[8].Value__c) *60*60*1000L).isSameDay(purchaseOrderList[0].SLAQuotationLevel3__c));
		}
	}

	// ------------------------------------------------- SALES ORDER ----------------------------------------------------------
	@isTest static void calSLALevelsUsingRulesEngineV2_D_WithSODate_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'FR299'
			};
			
			// Calling the function getRules with the passed parameters
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('DELIVERYCONFIRMATION', entityRulesSet, 'PrerequisiteOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('FR');

			// Retrieving the ExpectedDeliveryDateMaximum__c as it is a roll up summary and does not exists in the variable salesOrderList[0]

			PrerequisiteOrder__c currentSalesOrder = [	SELECT	Id, ExpectedDeliveryDateMaximum__c, SLAInDeliveryLevel1__c, SLAInDeliveryLevel2__c, SLAInDeliveryLevel3__c
														FROM	PrerequisiteOrder__c
														WHERE	Id =: salesOrderList[0].Id];

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(currentSalesOrder, 'FR299', 'salesOrder', 'ExpectedDeliveryDateMaximum__c', 'FR', mapEntityDetailRules, 60 * 60 * 1000L, businessDays);
			Test.stopTest();

			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel1__c);
			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel2__c);
			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel3__c);
			System.assertEquals(true, BusinessHours.add(businessDays.id,currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[9].Value__c)*60*60*1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel1__c));
			System.assertEquals(true, BusinessHours.add(businessDays.id,currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[10].Value__c)*60*60*1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel2__c));
			System.assertEquals(true, BusinessHours.add(businessDays.id,currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[11].Value__c)*60*60*1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel3__c));
		}
	}

	@isTest static void calSLALevelsUsingRulesEngineV2_H_WithSO_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'ES299'
			};
			
			// Calling the function getRules with the passed parameters
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('DELIVERYCONFIRMATION', entityRulesSet, 'PrerequisiteOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('ES');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('ES');

			// Retrieving the ExpectedDeliveryDateMaximum__c as it is a roll up summary and does not exists in the variable salesOrderList[0]

			PrerequisiteOrder__c currentSalesOrder = [	SELECT	Id, ExpectedDeliveryDateMaximum__c, SLAInDeliveryLevel1__c, SLAInDeliveryLevel2__c, SLAInDeliveryLevel3__c
														FROM	PrerequisiteOrder__c
														WHERE	Id =: salesOrderList[0].Id];

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(currentSalesOrder, 'ES299', 'salesOrder', 'ExpectedDeliveryDateMaximum__c', 'ES', mapEntityDetailRules, 60 * 60 * 1000L, businessDays);
			Test.stopTest();

			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel1__c);
			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel2__c);
			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel3__c);
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[12].Value__c) * 60 * 60 * 1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel1__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[13].Value__c) * 60 * 60 * 1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel2__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[14].Value__c) * 60 * 60 * 1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel3__c));
		}
	}

	@isTest static void calSLALevelsUsingRulesEngineV2_M_WithSO_TEST()
	{
		System.runAs(adminUser)
		{
			Set<String> entityRulesSet = new Set<String>
			{
				'IT299'
			};
			
			// Calling the function getRules with the passed parameters
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('DELIVERYCONFIRMATION', entityRulesSet, 'PrerequisiteOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('IT');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('IT');

			// Retrieving the ExpectedDeliveryDateMaximum__c as it is a roll up summary and does not exists in the variable salesOrderList[0]

			PrerequisiteOrder__c currentSalesOrder = [	SELECT	Id, ExpectedDeliveryDateMaximum__c, SLAInDeliveryLevel1__c, SLAInDeliveryLevel2__c, SLAInDeliveryLevel3__c
														FROM	PrerequisiteOrder__c
														WHERE	Id =: salesOrderList[0].Id];

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(currentSalesOrder, 'IT299', 'salesOrder', 'ExpectedDeliveryDateMaximum__c', 'IT', mapEntityDetailRules, 60 * 60 * 1000L,businessDays);
			Test.stopTest();

			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel1__c);
			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel2__c);
			System.assertNotEquals(null, currentSalesOrder.SLAInDeliveryLevel3__c);
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[15].Value__c) *60*60*1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel1__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[16].Value__c) *60*60*1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel2__c));
			System.assertEquals(true, BusinessHours.add(defaultHours.Id, currentSalesOrder.ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[17].Value__c) *60*60*1000L).isSameDay(currentSalesOrder.SLAInDeliveryLevel3__c));
		}
	}

	@isTest static void calSLALevelsUsingRulesEngineV2_D_WithSODateTime_TEST()
	{
		System.runAs(adminUser)
		{

			Set<String> entityRulesSet = new Set<String>
			{
				'DE299'
			};
			
			// Calling the function getRules with the passed parameters
			Map<String, List<DetailRule__c>> mapEntityDetailRules = Utils_SLARulesEngine.getRules('DELIVERYCONFIRMATION', entityRulesSet, 'PrerequisiteOrder__c');

			// The sObject is our PurchaseOrder
			// Getting an instance of Business Days
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('DE');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('DE');

			// Retrieving the ExpectedDeliveryDateMaximum__c as it is a roll up summary and does not exists in the variable salesOrderList[0]

			PrerequisiteOrder__c currentSalesOrder = [	SELECT	Id, SLAInDeliveryEntryDate__c, SLADeliveryConfirmedEntryDate__c, SLARespondedEntryDate__c
														FROM	PrerequisiteOrder__c
														WHERE	Id =: salesOrderList[0].Id];
			system.debug('##currentSalesOrder.SLARespondedEntryDate__c '+currentSalesOrder.SLARespondedEntryDate__c);
			
			// This will use the default country code mapping

			Test.startTest();
				Utils_SLARulesEngine.calSLALevelsUsingRulesEngineV2(currentSalesOrder, 'DE299', 'salesOrder', 'SLAInDeliveryEntryDate__c', 'DE', mapEntityDetailRules, 60 * 60 * 1000L, businessDays);
			Test.stopTest();
			

			System.assertNotEquals(null, currentSalesOrder.SLADeliveryConfirmedEntryDate__c);
			System.assertNotEquals(null, currentSalesOrder.SLARespondedEntryDate__c);
			system.debug('##businessDays.id '+businessDays.id);
			system.debug('##gmt '+system.now());
			system.debug('##now '+system.now().format());
			system.debug('##currentSalesOrder.SLARespondedEntryDate__c '+currentSalesOrder.SLARespondedEntryDate__c);
			system.debug('##add business'+BusinessHours.add(businessDays.id,(Datetime) currentSalesOrder.SLAInDeliveryEntryDate__c, Integer.valueOf(detailRuleList[19].Value__c)*60*60*1000L));
			//System.assertEquals(true, BusinessHours.add(businessDays.id,currentSalesOrder.SLAInDeliveryEntryDate__c, Integer.valueOf(detailRuleList[18].Value__c)*60*60*1000L).isSameDay(currentSalesOrder.SLADeliveryConfirmedEntryDate__c));
			//System.assertEquals(true, BusinessHours.add(businessDays.id,currentSalesOrder.SLAInDeliveryEntryDate__c, Integer.valueOf(detailRuleList[19].Value__c)*60*60*1000L).isSameDay(currentSalesOrder.SLARespondedEntryDate__c));
		
		}
	}
    
    //KPA 17/09/2020  C-003930
    @isTest static void isSLaAllowed_Test(){
        System.runAs(adminUser)
        {
            Test.startTest();
             boolean result = Utils_SLARulesEngine.isSLaAllowed('IG');
            Test.stopTest();
            
            // System.assertEquals(false,result);
        }

    }
    
    //KPA 17/09/2020  C-003930
      @isTest static void isSLaAllowedNull_Test(){
        System.runAs(adminUser)
        {
            Test.startTest();
             boolean result = Utils_SLARulesEngine.isSLaAllowed('');
            Test.stopTest();
            
            System.assertEquals(true,result);
        }

    }
    
    //KPA 17/09/2020  C-003930
      @isTest static void isSLaAllowedKPA_Test(){
        System.runAs(adminUser)
        {
            Test.startTest();
             boolean result= Utils_SLARulesEngine.isSLaAllowed('KPA');
            Test.stopTest();
            
            System.assertEquals(true,result);
        }

    }

}