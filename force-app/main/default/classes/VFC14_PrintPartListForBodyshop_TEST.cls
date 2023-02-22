/*
----------------------------------------------------------------------
-- - Name          : VFC14_PrintPartListForBodyshop_TEST
-- - Author        : ABT
-- - Description   : Test class for VFC14_PrintPartListForBodyshop
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 02-MAR-2017	ABT		1.0			Initial version
-- 24-AUG-2020	WCH		1.1			C-003838 - Nob - Migrate Billing information to new fields
-- 09-Nov-2020  KPA     1.2         C-004026 : Pentest - Insecure Direct Object Reference
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public with sharing class VFC14_PrintPartListForBodyshop_TEST
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
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
				TestFactory.createSalesOrder(assessmentList[0], accountList[2], ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
			};

			salesOrderList[0].OfferType__c = null;
			salesOrderList[0].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();
			salesOrderList[1].OfferType__c = 'QUICK';
			salesOrderList[1].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();

			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_RESPONDED),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
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

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
			};

			// Setting the new order line orderType as original
			// Only original
			orderLineList[0].OrderType__c					= 'ORIGINAL';
			orderLineList[0].PartNumber__c					= '00000001';
			orderLineList[0].Suppliable__c					= 'YES';

			// original + alternative
			orderLineList[1].OrderType__c					= 'ORIGINAL';
			orderLineList[1].PartNumber__c					= '00000002';
			orderLineList[1].Suppliable__c					= 'YES';

			orderLineList[2].OrderType__c					= 'FINAL';
			orderLineList[2].PartNumber__c					= '00000003';
			orderLineList[2].ExpectedDeliveryDuration__c	= '2';
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


			orderLineList[4].ExpectedDeliveryDuration__c	= '3';

			// final original
			orderLineList[7].OrderType__c					= 'FINAL';
			orderLineList[7].PartNumber__c					= '00000008';
			orderLineList[7].ExpectedDeliveryDuration__c	= '4';
			orderLineList[7].Suppliable__c					= 'YES';

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

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[4], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[5], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),

				TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[14], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED)
			};


			offerList[0].Suppliable__c		= true;
			offerList[0].Accepted__c		= null;
			offerList[0].Type__c			= 'QUICK';
			offerList[1].Suppliable__c		= true;
			offerList[1].Accepted__c		= null;
			offerList[1].Type__c			= 'QUICK';
			offerList[2].Suppliable__c		= true;
			offerList[2].Accepted__c		= null;
			offerList[2].Type__c			= 'QUICK';
			offerList[3].Suppliable__c		= true;
			offerList[3].Accepted__c		= null;
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

			offerList[7].DeliveryStatus__c = ASPISConstants.OFFER_STATUS_CANCELED;

			update offerList;
		}
	}

    @isTest static void salesOrderFR_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP14_PrintPartListForBodyshop);
            
           //KPA 09/11/2020  C-004026  
           String SO1Id = EncodingUtil.base64Encode(Blob.valueof(salesOrderList[0].Id));
        
            ApexPages.currentPage().getParameters().put('Id',SO1Id);


           
            ApexPages.currentPage().getParameters().put('force_download', 'true');
            
            Test.startTest();
                VFC14_PrintPartListForBodyshop controller = new VFC14_PrintPartListForBodyshop();
            Test.stopTest();

            System.assertEquals(salesOrderList[0].Id, controller.currentSalesOrder.Id);
            System.assertEquals('pdf', controller.renderAs);
            System.assertEquals(System.today().format(), controller.currentDate);
            System.assertEquals(2, controller.mapOfferWrapper.size());
            System.assertEquals(true, controller.mapOfferWrapper.get(offerList[0].Id).isSelectedByBodyShop);
            System.assertEquals(false, controller.mapOfferWrapper.get(offerList[0].Id).isNotSelectedByBodyShop);
            System.assertEquals(false, controller.mapOfferWrapper.get(offerList[0].Id).isCanceledByDistributor);
            System.assertEquals(false, controller.mapOfferWrapper.get(offerList[0].Id).isNotSelectedByDistributor);
            System.assertEquals(true, controller.mapOfferWrapper.get(offerList[3].Id).isOfferAlternative);

            // System.assertNotEquals(null, controller.getAddress());
        }
    }

    @isTest static void salesOrderES_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP14_PrintPartListForBodyshop);

            //KPA 09/11/2020  C-004026  
            String SO2Id = EncodingUtil.base64Encode(Blob.valueof(salesOrderList[1].Id));
        
            ApexPages.currentPage().getParameters().put('Id',SO2Id);

            ApexPages.currentPage().getParameters().put('force_download', 'true');
            
            Test.startTest();
                VFC14_PrintPartListForBodyshop controller = new VFC14_PrintPartListForBodyshop();
            Test.stopTest();

            System.assertEquals(salesOrderList[1].Id, controller.currentSalesOrder.Id);
            System.assertEquals('pdf', controller.renderAs);
            System.assertEquals(System.today().format(), controller.currentDate);
            System.assertEquals(2, controller.mapOfferWrapper.size());
            System.assertEquals(true, controller.mapOfferWrapper.get(offerList[4].Id).isSelectedByBodyShop);
            System.assertEquals(true, controller.mapOfferWrapper.get(offerList[7].Id).isOfferAlternative);
			System.assertEquals(true, controller.mapOfferWrapper.get(offerList[7].Id).isSelectedByBodyShop);
			System.assertEquals(false, controller.mapOfferWrapper.get(offerList[7].Id).isNotSelectedByBodyShop);
            System.assertEquals(false, controller.mapOfferWrapper.get(offerList[7].Id).isCanceledByDistributor);
            System.assertEquals(false, controller.mapOfferWrapper.get(offerList[7].Id).isNotSelectedByDistributor);

            // System.assertNotEquals(null, controller.getAddress());
        }
    }

    @isTest static void salesOrderDE_TEST()
    {
        System.runAs(adminUser)
        {
            // Changing the Country of the bodyshop
            accountList[2].BillingCountryCode__c   = 'DE';
            accountList[2].ShippingCountryCode  = 'DE';

            update accountList[2];

            Test.setCurrentPage(Page.VFP14_PrintPartListForBodyshop);

            
            //KPA 09/11/2020  C-004026  
            String SO2Id = EncodingUtil.base64Encode(Blob.valueof(salesOrderList[1].Id));
        
            ApexPages.currentPage().getParameters().put('Id',SO2Id);

            
            Test.startTest();
                VFC14_PrintPartListForBodyshop controller = new VFC14_PrintPartListForBodyshop();
            Test.stopTest();

            System.assertEquals(salesOrderList[1].Id, controller.currentSalesOrder.Id);
            System.assertEquals('pdf', controller.renderAs);
            System.assertEquals(System.today().format(), controller.currentDate);
            System.assertEquals(2, controller.mapOfferWrapper.size());
            System.assertEquals(true, controller.mapOfferWrapper.get(offerList[4].Id).isSelectedByBodyShop);
            System.assertEquals(true, controller.mapOfferWrapper.get(offerList[7].Id).isOfferAlternative);

            // System.assertNotEquals(null, controller.getAddress());
            System.assertEquals(true, ApexPages.currentPage().getHeaders().get('content-disposition').startsWith('inline;'));
        }
    }
}