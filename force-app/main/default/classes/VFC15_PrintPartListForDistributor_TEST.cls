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
-- 10-OCT-2018  WCH     1.1         C-002634 Ergonomie Bon de livraison PO
-- 09-Nov-2020  KPA     2.0        C-004026 : Pentest - Insecure Direct Object Reference
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class VFC15_PrintPartListForDistributor_TEST
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

			for(Account theAccount : accountList){
				theAccount.Type = 'STANDARD';
				theAccount.ExpertSubstitutionMethod__c = 'FORCED';
			}

			accountList[0].ContactUser__c = adminUser.Id;
			accountList[1].ContactUser__c = adminUser.Id;

			insert accountList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR_Quotation', accountList[0]),
				TestFactory.createAssessment('Assessment_FR_Order', accountList[0])
			};

			Id claimOrderId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();

			assessmentList[0].OrderOrigin__c = 'Quotation';
			assessmentList[1].OrderOrigin__c = 'Order';

			assessmentList[0].RecordTypeId = claimOrderId;
			assessmentList[1].RecordTypeId = claimOrderId;

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[1], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			salesOrderList[0].OfferType__c = null;
			salesOrderList[0].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();

			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				// Quotation
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_RESPONDED),
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_RESPONDED),

				// Order
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[0], accountList[1], 'PREDRAFTQUOTE'),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[0], accountList[1], 'PREDRAFTQUOTE')
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

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS)



				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),


				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				// TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
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
			orderLineList[8].Suppliable__c					= 'YES';
			orderLineList[8].PreselectedForOrder__c			= true;
			orderLineList[8].AcceptedCheck__c				= true;

			// original + alternative
			orderLineList[10].OrderType__c					= 'ORIGINAL';
			orderLineList[10].PartNumber__c					= '00000002';
			orderLineList[10].Manufacturer__c				= 'test manufacturer';
			orderLineList[10].Suppliable__c					= 'YES';
			orderLineList[10].PreselectedForOrder__c			= true;
			orderLineList[10].AcceptedCheck__c				= true;

			orderLineList[9].OrderType__c					= 'FINAL';
			orderLineList[9].PartNumber__c					= '00000003';
			orderLineList[9].ExpectedDeliveryDuration__c	= '2';
			orderLineList[9].Manufacturer__c				= 'test manufacturer';
			orderLineList[9].Suppliable__c					= 'YES';
			orderLineList[9].PreselectedForOrder__c			= true;
			orderLineList[9].AcceptedCheck__c				= true;

			// original + bundle
			orderLineList[12].OrderType__c					= 'ORIGINAL';
			orderLineList[12].PartNumber__c					= '00000004';
			orderLineList[12].Manufacturer__c				= 'test manufacturer';
			orderLineList[12].Suppliable__c					= 'YES';
			orderLineList[12].PreselectedForOrder__c			= true;
			orderLineList[12].AcceptedCheck__c				= true;

			orderLineList[11].OrderType__c					= 'BUNDLEITEM';
			orderLineList[11].PartNumber__c					= '00000005';
			orderLineList[11].Manufacturer__c				= 'test manufacturer';
			orderLineList[11].Suppliable__c					= 'YES';
			orderLineList[11].PreselectedForOrder__c			= true;
			orderLineList[11].AcceptedCheck__c				= true;

			orderLineList[13].OrderType__c					= 'BUNDLEITEM';
			orderLineList[13].PartNumber__c					= '00000006';
			orderLineList[13].Manufacturer__c				= 'test manufacturer';
			orderLineList[13].Suppliable__c					= 'YES';
			orderLineList[13].PreselectedForOrder__c			= true;
			orderLineList[13].AcceptedCheck__c				= true;

			orderLineList[14].OrderType__c					= 'FINAL';
			orderLineList[14].PartNumber__c					= '00000007';
			orderLineList[14].Manufacturer__c				= 'test manufacturer';
			orderLineList[14].Suppliable__c					= 'YES';
			orderLineList[14].PreselectedForOrder__c			= true;
			orderLineList[14].AcceptedCheck__c				= true;

			// final original
			orderLineList[15].OrderType__c					= 'FINAL';
			orderLineList[15].PartNumber__c					= '00000008';
			orderLineList[15].Manufacturer__c				= 'test manufacturer';
			orderLineList[15].ExpectedDeliveryDuration__c	= '4';
			orderLineList[15].Suppliable__c					= 'YES';
			orderLineList[15].PreselectedForOrder__c			= true;
			orderLineList[15].AcceptedCheck__c				= true;

			
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

	@isTest static void constructor_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP15_PrintPartListForDistributor);

            ApexPages.currentPage().getParameters().put('Id', '');
            ApexPages.currentPage().getParameters().put('force_download', 'true');

            Test.startTest();
                VFC15_PrintPartListForDistributor controller = new VFC15_PrintPartListForDistributor();
                controller.getAlphaScaleFranceContactInfo();
            Test.stopTest();

            System.assertEquals('pdf', controller.renderAs);
            System.assertEquals(0, controller.mapOrderLineWrapper.size());
            System.assertEquals(System.today().format(), controller.currentDate);
            System.assertEquals(false, controller.hasPreselectedParts);
        }
    }

    @isTest static void quotationPurchaseOrder_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP15_PrintPartListForDistributor);
            
           //KPA 06/11/2020  C-004026  
           String PO1Id = EncodingUtil.base64Encode(Blob.valueof(purchaseOrderList[0].Id));
        
            ApexPages.currentPage().getParameters().put('Id',PO1Id);

           
           

           
            ApexPages.currentPage().getParameters().put('force_download', 'true');

			Test.startTest();
				VFC15_PrintPartListForDistributor controller = new VFC15_PrintPartListForDistributor();
			Test.stopTest();

			System.assertEquals('pdf', controller.renderAs);
			System.assertEquals(4, controller.mapOrderLineWrapper.size());
			System.assertEquals(System.today().format(), controller.currentDate);
			System.assertEquals(false, controller.hasPreselectedParts);
			// In haste of deployment
			System.assertNotEquals(null, controller.getAddress());
		}
	}

	@isTest static void orderPurchaseOrder_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP15_PrintPartListForDistributor);

            //KPA 06/11/2020  C-004026 
            String PO3Id = EncodingUtil.base64Encode(Blob.valueof(purchaseOrderList[2].Id));
            
             
            ApexPages.currentPage().getParameters().put('Id',PO3Id);
           
           
            ApexPages.currentPage().getParameters().put('force_download', 'false');

			Test.startTest();
				VFC15_PrintPartListForDistributor controller = new VFC15_PrintPartListForDistributor();
			Test.stopTest();

			System.assertEquals('pdf', controller.renderAs);
			System.assertEquals(4, controller.mapOrderLineWrapper.size());
			System.assertEquals(System.today().format(), controller.currentDate);
			System.assertEquals(true, controller.hasPreselectedParts);
			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[15].Id).isFinalOriginal);
			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[15].Id).isPreselectedForOrder);
			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[15].Id).isAcceptedByBS);
			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[15].Id).isSuppliable);

			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[10].Id).isFinalAltenative);

			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[12].Id).isBundle);
			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[12].Id).isPreselectedForOrder);
			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[12].Id).isAcceptedByBS);
			System.assertEquals(true, controller.mapOrderLineWrapper.get(orderLineList[12].Id).isSuppliable);
		}
	}
}