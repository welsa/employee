/*
----------------------------------------------------------------------
-- - Name          : VFC13_GeneratePOOrderLineCSV_TEST
-- - Author        : ABT
-- - Description   : Test class for VFC13_GeneratePOOrderLineCSV.
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 06-FEB-2017	ABT		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class VFC13_GeneratePOOrderLineCSV_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;

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

			insert accountList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2])
			};

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};
			
			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),
				TestFactory.createPurchaseOrder(assessmentList[1], new PrerequisiteOrder__c(), accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			purchaseOrderList[0].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();

			insert purchaseOrderList;

			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
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
			orderLineList[8].Suppliable__c					= null;

			// original + alternative
			orderLineList[10].OrderType__c					= 'ORIGINAL';
			orderLineList[10].PartNumber__c					= '00000002';
			orderLineList[10].Manufacturer__c				= 'test manufacturer';

			orderLineList[9].OrderType__c					= 'FINAL';
			orderLineList[9].PartNumber__c					= '00000003';
			orderLineList[9].ExpectedDeliveryDuration__c	= '2';
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
			orderLineList[14].TechGeneratedFinal__c			= true;
			orderLineList[14].TechFinalTotalPrice__c		= 1000;
			orderLineList[14].TechFinalTotalAxaPrice__c		= 1000;
			orderLineList[14].TechFinalBSTotalPrice__c		= 1000;

			orderLineList[12].ExpectedDeliveryDuration__c	= '3';

			// final original
			orderLineList[15].OrderType__c					= 'FINAL';
			orderLineList[15].PartNumber__c					= '00000008';
			orderLineList[15].Manufacturer__c				= 'test manufacturer';
			orderLineList[15].ExpectedDeliveryDuration__c	= '4';

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
		}
	}

	@isTest static void constructorWithoutPO_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP13_GeneratePOOrderLineCSV);

			Test.startTest();
				VFC13_GeneratePOOrderLineCSV controller = new VFC13_GeneratePOOrderLineCSV(new ApexPages.StandardController(new PurchaseOrder__c()));
			Test.stopTest();

			System.assertEquals(null, controller.currentPurchaseOrder.Id);
			System.assertNotEquals(null, controller.mapIdOrderLineWrapper);
			System.assertEquals(0, controller.mapIdOrderLineWrapper.size());
			System.assertNotEquals(null, controller.header);
		}
	}

	@isTest static void constructorWithPO_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP13_GeneratePOOrderLineCSV);

			// Making SELECT to get the RecordTypeId
			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, RecordTypeId
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			Test.startTest();
				VFC13_GeneratePOOrderLineCSV controller = new VFC13_GeneratePOOrderLineCSV(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			System.assertEquals(purchaseOrderList[0].Id, controller.currentPurchaseOrder.Id);
			System.assertNotEquals(null, controller.mapIdOrderLineWrapper);
			System.assertEquals(4, controller.mapIdOrderLineWrapper.size());
			System.assertNotEquals(null, controller.header);
			System.assertEquals(false, controller.isQuotation);
			System.assertEquals(true, controller.mapIdOrderLineWrapper.get(orderLineList[0].Id).isOriginalOnly);
			System.assertEquals(true, controller.mapIdOrderLineWrapper.get(orderLineList[1].Id).isFinalAltenative);
			System.assertEquals(true, controller.mapIdOrderLineWrapper.get(orderLineList[3].Id).isBundle);
			System.assertEquals(true, controller.mapIdOrderLineWrapper.get(orderLineList[7].Id).isFinalOriginal);
		}
	}

	@isTest static void constructorWithPOMessyOL_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP13_GeneratePOOrderLineCSV);

			// Making SELECT to get the RecordTypeId
			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, RecordTypeId
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			Test.startTest();
				VFC13_GeneratePOOrderLineCSV controller = new VFC13_GeneratePOOrderLineCSV(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			System.assertEquals(currentPurchaseOrder.Id, controller.currentPurchaseOrder.Id);
			System.assertNotEquals(null, controller.mapIdOrderLineWrapper);
			System.assertEquals(4, controller.mapIdOrderLineWrapper.size());
			System.assertNotEquals(null, controller.header);
			System.assertEquals(true, controller.isQuotation);
		}
	}
}