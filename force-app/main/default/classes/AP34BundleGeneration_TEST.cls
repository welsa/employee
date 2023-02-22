/*
----------------------------------------------------------------------
-- - Name          : AP34BundleGeneration_TEST
-- - Author        : ABT
-- - Description   : Test class for AP34BundleGeneration
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 31-MAR-2017  ABT     1.0         Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class AP34BundleGeneration_TEST
{
	static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
	
	static
	{
		adminUser		= TestFactory.createUser('adminUser');
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

			Id claimOrderId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();

			assessmentList[1].TECH_EntityCountryCode__c = 'ES';
			assessmentList[1].Manufacturer__c			= 'Citroen';

			assessmentList[0].RecordTypeId				= claimOrderId;
			assessmentList[1].RecordTypeId				= claimOrderId;

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			salesOrderList[0].OfferType__c = null;
			salesOrderList[0].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();
			salesOrderList[1].OfferType__c = 'QUICK';
			salesOrderList[1].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();

			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			insert purchaseOrderList;

			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

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
			orderLineList[0].Suppliable__c					= 'YES';
			orderLineList[0].AcceptedCheck__c				= true;
			orderLineList[0].PreselectedForOrder__c			= true;

			// original + alternative
			orderLineList[1].OrderType__c					= 'ORIGINAL';
			orderLineList[1].PartNumber__c					= '00000002';
			orderLineList[1].Suppliable__c					= 'YES';
			orderLineList[1].AcceptedCheck__c				= true;
			orderLineList[1].PreselectedForOrder__c			= true;

			orderLineList[2].OrderType__c					= 'FINAL';
			orderLineList[2].PartNumber__c					= '00000003';
			orderLineList[2].ExpectedDeliveryDuration__c	= '2';
			orderLineList[2].Suppliable__c					= 'YES';
			orderLineList[2].AcceptedCheck__c				= true;
			orderLineList[2].PreselectedForOrder__c			= true;

			// original + bundle
			orderLineList[3].OrderType__c					= 'ORIGINAL';
			orderLineList[3].PartNumber__c					= '00000004';
			orderLineList[3].Suppliable__c					= 'YES';
			orderLineList[3].AcceptedCheck__c				= true;
			orderLineList[3].PreselectedForOrder__c			= true;

			orderLineList[4].OrderType__c					= 'BUNDLEITEM';
			orderLineList[4].PartNumber__c					= '00000005';
			orderLineList[4].Suppliable__c					= 'YES';
			orderLineList[4].AcceptedCheck__c				= true;
			orderLineList[4].PreselectedForOrder__c			= true;

			orderLineList[5].OrderType__c					= 'BUNDLEITEM';
			orderLineList[5].PartNumber__c					= '00000006';
			orderLineList[5].Suppliable__c					= 'YES';
			orderLineList[5].AcceptedCheck__c				= true;
			orderLineList[5].PreselectedForOrder__c			= true;

			orderLineList[6].OrderType__c					= 'FINAL';
			orderLineList[6].PartNumber__c					= '00000007';
			orderLineList[6].Suppliable__c					= 'YES';
			orderLineList[6].AcceptedCheck__c				= true;
			orderLineList[6].PreselectedForOrder__c			= true;

			// final original
			orderLineList[7].OrderType__c					= 'FINAL';
			orderLineList[7].PartNumber__c					= '00000008';
			orderLineList[7].ExpectedDeliveryDuration__c	= '4';
			orderLineList[7].Suppliable__c					= 'YES';
			orderLineList[7].AcceptedCheck__c				= true;
			orderLineList[7].PreselectedForOrder__c			= true;

			/********************* PO2 **************************************/
			// Only original
			orderLineList[8].OrderType__c					= 'ORIGINAL';
			orderLineList[8].PartNumber__c					= '00000001';
			orderLineList[8].Manufacturer__c				= 'test manufacturer';
			orderLineList[8].Suppliable__c					= null;
			orderLineList[0].AcceptedCheck__c				= false;
			orderLineList[0].PreselectedForOrder__c			= false;

			// original + alternative
			orderLineList[10].OrderType__c					= 'ORIGINAL';
			orderLineList[10].PartNumber__c					= '00000002';
			orderLineList[10].Manufacturer__c				= 'test manufacturer';
			orderLineList[10].AcceptedCheck__c				= true;
			orderLineList[10].PreselectedForOrder__c		= true;

			orderLineList[9].OrderType__c					= 'FINAL';
			orderLineList[9].PartNumber__c					= '00000003';
			orderLineList[9].ExpectedDeliveryDuration__c	= '2';
			orderLineList[9].Manufacturer__c				= 'test manufacturer';
			orderLineList[9].AcceptedCheck__c				= true;
			orderLineList[9].PreselectedForOrder__c			= true;

			// original + bundle
			orderLineList[12].OrderType__c					= 'ORIGINAL';
			orderLineList[12].PartNumber__c					= '00000004';
			orderLineList[12].Manufacturer__c				= 'test manufacturer';
			orderLineList[12].AcceptedCheck__c				= true;
			orderLineList[12].PreselectedForOrder__c		= true;

			orderLineList[11].OrderType__c					= 'BUNDLEITEM';
			orderLineList[11].PartNumber__c					= '00000005';
			orderLineList[11].Manufacturer__c				= 'test manufacturer';
			orderLineList[11].AcceptedCheck__c				= true;
			orderLineList[11].PreselectedForOrder__c		= true;

			orderLineList[13].OrderType__c					= 'BUNDLEITEM';
			orderLineList[13].PartNumber__c					= '00000006';
			orderLineList[13].Manufacturer__c				= 'test manufacturer';
			orderLineList[13].AcceptedCheck__c				= true;
			orderLineList[13].PreselectedForOrder__c		= true;

			orderLineList[14].OrderType__c					= 'FINAL';
			orderLineList[14].PartNumber__c					= '00000007';
			orderLineList[14].Manufacturer__c				= 'test manufacturer';
			orderLineList[14].AcceptedCheck__c				= true;
			orderLineList[14].PreselectedForOrder__c		= true;

			// final original
			orderLineList[15].OrderType__c					= 'FINAL';
			orderLineList[15].PartNumber__c					= '00000008';
			orderLineList[15].Manufacturer__c				= 'test manufacturer';
			orderLineList[15].ExpectedDeliveryDuration__c	= '4';
			orderLineList[15].AcceptedCheck__c				= true;
			orderLineList[15].PreselectedForOrder__c		= true;

			
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
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[3], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[7], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),

				TestFactory.createOfferLine(orderLineList[10], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[12], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[15], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS)
			};


			offerList[0].Suppliable__c			= true;
			offerList[0].Accepted__c			= 'YES';
			offerList[0].PreselectedForOrder__c	= true;
			offerList[0].Type__c				= 'QUICK';
			offerList[1].Suppliable__c			= true;
			offerList[1].Accepted__c			= 'YES';
			offerList[1].PreselectedForOrder__c	= true;
			offerList[1].Type__c				= 'QUICK';
			offerList[2].Suppliable__c			= true;
			offerList[2].Accepted__c			= 'YES';
			offerList[2].PreselectedForOrder__c	= true;
			offerList[2].Type__c				= 'QUICK';


			offerList[3].PreselectedForOrder__c	= true;
			offerList[3].Suppliable__c			= true;
			offerList[3].Accepted__c			= 'YES';
			offerList[3].Type__c				= 'QUICK';
			offerList[4].PreselectedForOrder__c	= true;
			offerList[4].Suppliable__c			= true;
			offerList[4].Accepted__c			= 'YES';
			offerList[4].Type__c				= 'QUICK';
			offerList[5].PreselectedForOrder__c	= true;
			offerList[5].Suppliable__c			= true;
			offerList[5].Accepted__c			= 'YES';
			offerList[5].Type__c				= 'QUICK';

			insert offerList;
		}
	}

	@isTest static void updatePOToResponded()
	{
		System.runAs(adminUser)
		{
			purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
			purchaseOrderList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;

			Test.startTest();
				update purchaseOrderList;
			Test.stopTest();

			Map<Id, List<Offer__c>> mapSOOffers = new Map<Id, List<Offer__c>>();

			for(Offer__c currentOffer : [SELECT Id, PrerequisiteOrder__c
										 FROM	Offer__c
										 WHERE	PrerequisiteOrder__c IN: salesOrderList])
			{
				if(mapSOOffers.containsKey(currentOffer.PrerequisiteOrder__c))
				{
					mapSOOffers.get(currentOffer.PrerequisiteOrder__c).add(currentOffer);
				}
				else
				{
					mapSOOffers.put(currentOffer.PrerequisiteOrder__c, new List<Offer__c>{currentOffer});
				}
			}

			System.assertEquals(5, mapSOOffers.get(salesOrderList[0].Id).size());
			System.assertEquals(5, mapSOOffers.get(salesOrderList[1].Id).size());
		}
	}
}