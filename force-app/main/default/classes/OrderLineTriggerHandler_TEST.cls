/*************************************************************************************
Class Name - OrderLineTriggerHandler
Version - 1.0
Created Date - 29 APRIL 2016
Function - Test Class fer class OrderLineTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      29/04/2016  Reworked Version
*************************************************************************************/
@isTest
private class OrderLineTriggerHandler_TEST 
{
	static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
	static List<Discount__c> discountList;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

	static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES')
			};

			accountList[1].ReferentialASforAParts__c	= 25;
			accountList[1].ReferentialASforBCParts__c	= 25;

			accountList[3].ReferentialASforAParts__c	= 25;
			accountList[3].ReferentialASforBCParts__c	= 25;

			insert accountList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2])
			};

			assessmentList[0].EntityRules__c 			= 'FR299';
			assessmentList[0].EntityCode__c 			= '299';
			assessmentList[0].TECH_EntityCountryCode__c = 'FR';
			assessmentList[0].Manufacturer__c			= 'CITROEN';
			
			assessmentList[1].EntityRules__c 			= 'ES299';
			assessmentList[1].EntityCode__c 			= '299';
			assessmentList[1].TECH_EntityCountryCode__c = 'ES';
			assessmentList[1].Manufacturer__c			= 'FORD';

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], 'INDELIVERY'),
				TestFactory.createSalesOrder(assessmentList[1], accountList[2], 'INDELIVERY')
			};
			
			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], 'INDELIVERY'),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], 'INDELIVERY')
			};

			insert purchaseOrderList;

			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], 'INDELIVERY'),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], 'INDELIVERY')
			};

			// Setting the new order line orderType as original
			// Only original
			orderLineList[0].OrderType__c					= 'ORIGINAL';
			orderLineList[0].PartNumber__c					= '00000001';
			orderLineList[0].Suppliable__c					= 'NO';

			// original + alternative
			orderLineList[1].OrderType__c					= 'ORIGINAL';
			orderLineList[1].PartNumber__c					= '00000002';
			orderLineList[1].Suppliable__c					= 'YES';

			orderLineList[2].OrderType__c					= 'FINAL';
			orderLineList[2].PartNumber__c					= '00000003';
			orderLineList[2].Suppliable__c					= 'YES';

			// original + bundle
			orderLineList[3].OrderType__c					= 'ORIGINAL';
			orderLineList[3].PartNumber__c					= '00000004';
			orderLineList[3].Suppliable__c					= 'YES';

			orderLineList[4].OrderType__c					= 'BUNDLEITEM';
			orderLineList[4].PartNumber__c					= '00000005';
			orderLineList[4].Suppliable__c					= 'YES';

			orderLineList[5].OrderType__c					= 'BUNDLEITEM';
			orderLineList[5].PartNumber__c					= '00000006';
			orderLineList[5].Suppliable__c					= 'YES';

			orderLineList[6].OrderType__c					= 'FINAL';
			orderLineList[6].PartNumber__c					= '00000007';
			orderLineList[6].Suppliable__c					= 'YES';
			orderLineList[6].TechGeneratedFinal__c			= true;
			orderLineList[6].TechFinalTotalPrice__c			= 1000;
			orderLineList[6].TechFinalTotalAxaPrice__c		= 1000;
			orderLineList[6].TechFinalBSTotalPrice__c		= 1000;

			// final original
			orderLineList[7].OrderType__c					= 'FINAL';
			orderLineList[7].PartNumber__c					= '00000008';
			orderLineList[7].Suppliable__c					= 'NO';

			/********************* PO2 **************************************/
			// Only original
			orderLineList[8].OrderType__c					= 'ORIGINAL';
			orderLineList[8].PartNumber__c					= '00000001';
			orderLineList[8].Manufacturer__c				= 'test manufacturer';
			orderLineList[8].Suppliable__c					= 'NO';

			// original + alternative
			orderLineList[10].OrderType__c					= 'ORIGINAL';
			orderLineList[10].PartNumber__c					= '00000002';
			orderLineList[10].Manufacturer__c				= 'test manufacturer';

			orderLineList[9].OrderType__c					= 'FINAL';
			orderLineList[9].PartNumber__c					= '00000003';
			orderLineList[9].Manufacturer__c				= 'test manufacturer';

			// original + bundle
			orderLineList[12].OrderType__c					= 'ORIGINAL';
			orderLineList[12].PartNumber__c					= '00000004';
			orderLineList[12].Manufacturer__c				= 'test manufacturer';

			orderLineList[11].OrderType__c					= 'BUNDLEITEM';
			orderLineList[11].PartNumber__c					= '00000005';
			orderLineList[11].Manufacturer__c				= 'test manufacturer';

			orderLineList[13].OrderType__c					= 'BUNDLEITEM';
			orderLineList[13].PartNumber__c					= '00000006';
			orderLineList[13].Manufacturer__c				= 'test manufacturer';

			orderLineList[14].OrderType__c					= 'FINAL';
			orderLineList[14].PartNumber__c					= '00000007';
			orderLineList[14].Manufacturer__c				= 'test manufacturer';

			// final original
			orderLineList[15].OrderType__c					= 'FINAL';
			orderLineList[15].PartNumber__c					= '00000008';
			orderLineList[15].Manufacturer__c				= 'test manufacturer';
			orderLineList[15].Suppliable__c					= 'NO';


			insert orderLineList;

			// Changing order line to bundles
			orderLineList[2].OriginalItem__c	= orderLineList[1].Id;
            orderLineList[4].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[5].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[6].OriginalItem__c	= orderLineList[3].Id;

			// Changing order line to bundles
			orderLineList[9].OriginalItem__c	= orderLineList[10].Id;
            orderLineList[11].OriginalItem__c	= orderLineList[14].Id;
            orderLineList[13].OriginalItem__c	= orderLineList[14].Id;
            orderLineList[14].OriginalItem__c	= orderLineList[12].Id;

			update orderLineList;

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[4], salesOrderList[0], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[5], salesOrderList[0], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], 'INDELIVERY'),

				TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], 'INDELIVERY'),
				TestFactory.createOfferLine(orderLineList[14], salesOrderList[1], 'INDELIVERY')
			};


			offerList[0].Suppliable__c		= true;
			offerList[0].Accepted__c		= 'YES';
			offerList[0].Type__c			= 'QUICK';
			offerList[1].Suppliable__c		= true;
			offerList[1].Accepted__c		= 'YES';
			offerList[1].Type__c			= 'QUICK';
			offerList[2].Suppliable__c		= true;
			offerList[2].Accepted__c		= 'YES';
			offerList[2].Type__c			= 'QUICK';
			offerList[3].Suppliable__c		= true;
			offerList[3].Accepted__c		= 'YES';
			offerList[3].Type__c			= 'QUICK';

			offerList[4].Suppliable__c		= true;
			offerList[4].Accepted__c		= 'YES';
			offerList[4].Type__c			= 'QUICK';
			offerList[5].Suppliable__c		= true;
			offerList[5].Accepted__c		= 'YES';
			offerList[5].Type__c			= 'QUICK';
			offerList[6].Suppliable__c		= true;
			offerList[6].Accepted__c		= 'YES';
			offerList[6].Type__c			= 'QUICK';
			offerList[7].Suppliable__c		= true;
			offerList[7].Accepted__c		= 'YES';
			offerList[7].Type__c			= 'QUICK';

			insert offerList;

			// bundle item offers should be linked to its parent
			offerList[1].ParentOffer__c		= offerList[3].Id;
			offerList[2].ParentOffer__c		= offerList[3].Id;

			offerList[5].ParentOffer__c		= offerList[7].Id;
			offerList[6].ParentOffer__c		= offerList[7].Id;

			update offerList;

			discountList = new List<Discount__c>
			{
				TestFactory.createDistributorDiscount(accountList[1], 30.0, 'A', 'CITROEN'),
				TestFactory.createBodyshopDiscount(accountList[0], 20.0, 'A', 'CITROEN'),
				TestFactory.createBodyshopDiscount(accountList[2], 20.0, 'B;C', 'FORD')
			};

			insert discountList;

			// access Business Hours
            defaultHours = [SELECT	Id
							FROM	BusinessHours
							WHERE	IsDefault = true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			countryMappingList[0].DefaultBSDiscount__c 				= 10;
			countryMappingList[1].DefaultBSDiscount__c 				= 20;
			countryMappingList[1].UseAdvancedDiscountManagement__c	= true;

			insert countryMappingList;
		}
	}

	@isTest static void onAfterInsert_TEST()
	{
		System.runAs(adminUser)
		{
			List<OrderLine__c> orderLineToInsertList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
			};

			Test.startTest();
				insert orderLineToInsertList;
			Test.stopTest();

			PurchaseOrder__c updatedPurchaseOrder = [SELECT Id, DistributorPriceHigger__c
													FROM	PurchaseOrder__c
													WHERE	Id =: purchaseOrderList[0].Id];
			
			System.assertEquals(true, updatedPurchaseOrder.DistributorPriceHigger__c);
		}
	}

	@isTest static void onBeforeUpdate_TEST()
	{
		System.runAs(adminUser)
		{
			orderLineList[0].AXADiscount__c 				= 5;
			orderLineList[1].AXADiscount__c 				= 5;
			orderLineList[2].AXADiscount__c 				= 5;

			orderLineList[1].AdditionalDiscountAmount__c 	= 10;
			orderLineList[2].AdditionalDiscountAmount__c 	= 10;

			Test.startTest();
				update orderLineList;
			Test.stopTest();

			List<OrderLine__c> updatedOrderLineList = [	SELECT 	Id, BodyShopDiscount__c, TECH_ToBeProcessed__c
														FROM	OrderLine__c
														WHERE	Id IN: orderLineList];

			System.assertNotEquals(null, updatedOrderLineList[0].BodyShopDiscount__c);
			System.assertNotEquals(null, updatedOrderLineList[1].BodyShopDiscount__c);
			System.assertNotEquals(null, updatedOrderLineList[2].BodyShopDiscount__c);

			System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[0].BodyShopDiscount__c);
			System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[1].BodyShopDiscount__c);
			System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[2].BodyShopDiscount__c);

			System.assertEquals(false, updatedOrderLineList[0].TECH_ToBeProcessed__c);
			System.assertEquals(true, updatedOrderLineList[1].TECH_ToBeProcessed__c);
			System.assertEquals(true, updatedOrderLineList[2].TECH_ToBeProcessed__c);
		}
	}

	@isTest static void onAfterUpdate_TEST()
	{
		System.runAs(adminUser)
		{
			orderLineList[1].DeliveryStatus__c				= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
			orderLineList[2].DeliveryStatus__c				= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
			orderLineList[2].EstimatedDeliveryDate__c 		= System.today().addDays(3);

			orderLineList[4].AXADiscount__c 				= 5;
			orderLineList[4].Discount__c 					= discountList[0].Id;
			orderLineList[5].CataloguePrice__c 				= 2000;

			orderLineList[9].DeliveryStatus__c				= ASPISConstants.ORD_LINE_STATUS_RETURNED;
			orderLineList[9].AdditionalDiscountAmount__c 	= 100;

			// ABT - 23-JAN-2017 - C-001620
			orderLineList[4].AdditionalDiscountAmount__c = 100;
			orderLineList[5].AdditionalDiscountAmount__c = 100;

			Test.startTest();
				update orderLineList;
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT 	Id, ASDiscountLowCaseCreated__c, DistributorPriceHigger__c, TotalExpectedAmount__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList];

			System.assertEquals(true, updatedPurchaseOrderList[0].ASDiscountLowCaseCreated__c);
			System.assertEquals(true, updatedPurchaseOrderList[0].DistributorPriceHigger__c);
			System.assertEquals(0, updatedPurchaseOrderList[1].TotalExpectedAmount__c);

			List<Offer__c> updatedOfferList = [	SELECT 	Id, ExpectedDeliveryDate__c, DeliveryStatus__c
												FROM	Offer__c
												WHERE	OrderLine__c IN: orderLineList];
			
			System.assertEquals(orderLineList[2].EstimatedDeliveryDate__c, updatedOfferList[0].ExpectedDeliveryDate__c);
			System.assertEquals(orderLineList[2].DeliveryStatus__c, updatedOfferList[0].DeliveryStatus__c);

			System.assertEquals(orderLineList[9].DeliveryStatus__c, updatedOfferList[4].DeliveryStatus__c);

			List<OrderLine__c> updatedOrderLineList = [	SELECT 	Id, AXADiscount__c, BodyShopDiscount__c, TechFinalTotalPrice__c, TechFinalTotalAxaPrice__c,
																TechFinalBSTotalPrice__c
														FROM	OrderLine__c
														WHERE	Id IN: orderLineList];

			System.assertEquals(1000, updatedOrderLineList[6].TechFinalTotalPrice__c);		
			System.assertEquals(800, updatedOrderLineList[6].TechFinalTotalAxaPrice__c);		
			System.assertEquals(800, updatedOrderLineList[6].TechFinalBSTotalPrice__c);		
			System.assertEquals((200.0 / 1000.0) * 100, updatedOrderLineList[6].AXADiscount__c);		
			System.assertEquals((200.0 / 1000.0) * 100, updatedOrderLineList[6].BodyShopDiscount__c);		
		}
	}

	@isTest static void updatePurchaseOrderBooleanOnly_TEST()
	{
		System.runAs(adminUser)
		{
			orderLineList[4].AXADiscount__c 				= 5;
			orderLineList[4].Discount__c 					= discountList[0].Id;
	
			orderLineList[9].CataloguePrice__c				= 2000;

			Test.startTest();
				update orderLineList;
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT 	Id, ASDiscountLowCaseCreated__c, DistributorPriceHigger__c, TotalExpectedAmount__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList];

			System.assertEquals(true, updatedPurchaseOrderList[0].ASDiscountLowCaseCreated__c);
			System.assertEquals(true, updatedPurchaseOrderList[1].DistributorPriceHigger__c);
		}
	}

	@isTest static void reopenClosedPO_TEST()
	{
		System.runAs(adminUser)
		{
			orderLineList[0].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			orderLineList[1].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			orderLineList[2].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			orderLineList[3].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			orderLineList[4].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			orderLineList[5].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			orderLineList[6].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			orderLineList[7].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_DELIVERED;
			
			update orderLineList;
			
			purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;

			update purchaseOrderList;

			orderLineList[4].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_RETURNED;
			orderLineList[5].DeliveryStatus__c = ASPISConstants.ORD_LINE_STATUS_CANCELED;

			Test.startTest();
				update orderLineList;
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrderList = [	SELECT 	Id, Status__c, TotalExpectedAmount__c
																FROM	PurchaseOrder__c
																WHERE	Id IN: purchaseOrderList];

			System.assertEquals(2400, updatedPurchaseOrderList[0].TotalExpectedAmount__c);
			System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED, updatedPurchaseOrderList[0].Status__c);
		}
	}
}