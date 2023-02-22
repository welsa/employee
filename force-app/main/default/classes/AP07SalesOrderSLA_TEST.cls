/*
  ----------------------------------------------------------------------
  -- - Name          : AP07SalesOrderSLA_TEST
  -- - Author        : ABT
  -- - Description   : Test class for AP07SalesOrderSLA
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-SEP-2016  ABT    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class AP07SalesOrderSLA_TEST
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
				TestFactory.createRuleSetSLAPOQuotation('FR299')
			};

			insert ruleSetList;

			masterRuleList = new List<MasterRules__c>
			{
				TestFactory.createMasterRule('FR299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c')
			};

			masterRuleList[0].RuleSet__c = ruleSetList[0].Id;

			insert masterRuleList;

			detailRuleList = new List<DetailRule__c>
			{
				TestFactory.createDetailRule(null, masterRuleList[0], 'SLAInDeliveryLevel1__c', 'EQUALS', '1', 'Parameters', 'PrerequisiteOrder__c', 1),
				TestFactory.createDetailRule(null, masterRuleList[0], 'SLAInDeliveryLevel2__c', 'EQUALS', '3', 'Parameters', 'PrerequisiteOrder__c', 2),
				TestFactory.createDetailRule(null, masterRuleList[0], 'SLAInDeliveryLevel3__c', 'EQUALS', '5', 'Parameters', 'PrerequisiteOrder__c', 3)
			};

			detailRuleList[0].ValueFrom__c	= 'D';
			detailRuleList[1].ValueFrom__c	= 'D';
			detailRuleList[2].ValueFrom__c	= 'D';

			detailRuleList[0].Active__c		= true;
			detailRuleList[1].Active__c		= true;
			detailRuleList[2].Active__c		= true;

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

			assessmentList[0].EntityRules__c	= 'FR299';
			assessmentList[0].EntityCode__c		= '299';

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

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
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS)
			};

			offerList[0].ExpectedDeliveryDate__c = System.today();
			offerList[1].ExpectedDeliveryDate__c = System.today();
			offerList[2].ExpectedDeliveryDate__c = System.today();

			insert offerList;

			// access Business Hours 
            defaultHours = [SELECT	Id 
							FROM	BusinessHours 
							WHERE	IsDefault = true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id)
			};
			
			insert countryMappingList;
		}
	}

	@isTest static void runSLAOnStatus_Responded_TEST()
	{
		System.runAs(adminUser)
		{
			// The function runSLAOnStatus_Responded is executed in PrerequisiteOrderTriggerHandler Before Update
			// The sales order should be updated to RESPONDED
			salesOrderList[0].Status__c					= ASPISConstants.PRE_ORDER_STATUS_RESPONDED;

			// Ensuring that SLARespondedEntryDate__c is null as the sales order is in acceptance
			salesOrderList[0].SLARespondedEntryDate__c	= null;

			Test.startTest();
				update salesOrderList;
			Test.stopTest();

			List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT	Id, SLARespondedEntryDate__c
																FROM	PrerequisiteOrder__c
																WHERE	Id IN: salesOrderList];

			System.assertNotEquals(null, updatedSalesOrderList[0].SLARespondedEntryDate__c);
		}
	}

	@isTest static void runSLAOnStatus_DeliveryWithRulesEngine_TEST()
	{
		System.runAs(adminUser)
		{
			// The function runSLAOnStatus_DeliveryWithRulesEngine is executed in PrerequisiteOrderTriggerHandler Before Update
			// The sales order should be updated to INDELIVERY
			salesOrderList[0].Status__c					= ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;

			// Ensuring that SLAInDeliveryEntryDate__c is null as the PO is not yet in the status INDELIVERY
			salesOrderList[0].SLAInDeliveryEntryDate__c	= null;

			// The expected delivery date maximum is set to today (roll up formula on the offers)

			Test.startTest();
				update salesOrderList;
			Test.stopTest();

			List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT	Id, SLAInDeliveryEntryDate__c, SLAInDeliveryLevel1__c, SLAInDeliveryLevel2__c, SLAInDeliveryLevel3__c, ExpectedDeliveryDateMaximum__c
																FROM	PrerequisiteOrder__c
																WHERE	Id IN: salesOrderList];

			// Getting an instance of Business Days to make the asserts
			//Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
			BusinessHours businessDays = ASPISConstants.getBusinessHours('FR');
			
			System.assertNotEquals(null, updatedSalesOrderList[0].SLAInDeliveryEntryDate__c);
			System.assertNotEquals(null, updatedSalesOrderList[0].SLAInDeliveryLevel1__c);
			System.assertNotEquals(null, updatedSalesOrderList[0].SLAInDeliveryLevel2__c);
			System.assertNotEquals(null, updatedSalesOrderList[0].SLAInDeliveryLevel3__c);
			System.assertEquals(true, Businesshours.add(businessDays.id,updatedSalesOrderList[0].ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[0].Value__c)).isSameDay(updatedSalesOrderList[0].SLAInDeliveryLevel1__c));
			System.assertEquals(true, Businesshours.add(businessDays.id,updatedSalesOrderList[0].ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[1].Value__c)).isSameDay(updatedSalesOrderList[0].SLAInDeliveryLevel2__c));
			System.assertEquals(true, Businesshours.add(businessDays.id,updatedSalesOrderList[0].ExpectedDeliveryDateMaximum__c, Integer.valueOf(detailRuleList[2].Value__c)).isSameDay(updatedSalesOrderList[0].SLAInDeliveryLevel3__c));
		}
	}

	@isTest static void runSLAOnStatus_DeliveryConfirmed_TEST()
	{
		System.runAs(adminUser)
		{
			// The function runSLAOnStatus_DeliveryConfirmed is executed in PrerequisiteOrderTriggerHandler Before Update
			// The sales order should be updated to PREORDERCONFIRMED
			salesOrderList[0].Status__c					= ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;

			// Ensuring that SLADeliveryConfirmedEntryDate__c is null 
			salesOrderList[0].SLADeliveryConfirmedEntryDate__c	= null;

			// Setting SLAInDeliveryLevel1__c and SLAInDeliveryLevel2__c to see if they are cleared when SO is updated to PREORDERCONFIRMED

			Test.startTest();
				update salesOrderList;
			Test.stopTest();

			List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT	Id, SLADeliveryConfirmedEntryDate__c, SLAInDeliveryLevel1__c, SLAInDeliveryLevel2__c
																FROM	PrerequisiteOrder__c
																WHERE	Id IN: salesOrderList];

			System.assertNotEquals(null, updatedSalesOrderList[0].SLADeliveryConfirmedEntryDate__c);
			System.assertEquals(null, updatedSalesOrderList[0].SLAInDeliveryLevel1__c);
			System.assertEquals(null, updatedSalesOrderList[0].SLAInDeliveryLevel2__c);
		}
	}
}