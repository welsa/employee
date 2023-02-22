/*
  ----------------------------------------------------------------------
  -- - Name          : VFC_PrintPartListForDistributor_TEST
  -- - Author        : ABT
  -- - Description   : Test class for VFC_PrintPartListForDistributor
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 28-SEP-2016  ABT    1.0     Reworked Version
  ----------------------------------------------------------------------
  -- Remarks: The class is run for only 1 PO, so why the function getPurchaseOrder returns a list of PO
 **********************************************************************
*/
@isTest
public class VFC_PrintPartListForDistributor_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShopFR_1', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR_1', 'FR')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('AssessmentFR_1', accountList[0])
			};

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_ISSUED)
			};

			insert purchaseOrderList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
			};

			// Setting the new order line orderType as original
			// Only original
			orderLineList[0].OrderType__c					= 'ORIGINAL';
			orderLineList[0].PartNumber__c					= '00000001';

			// original + alternative
			orderLineList[1].OrderType__c					= 'ORIGINAL';
			orderLineList[1].PartNumber__c					= '00000002';

			orderLineList[2].OrderType__c					= 'FINAL';
			orderLineList[2].PartNumber__c					= '00000003';

			// original + bundle
			orderLineList[3].OrderType__c					= 'ORIGINAL';
			orderLineList[3].PartNumber__c					= '00000004';

			orderLineList[4].OrderType__c					= 'BUNDLEITEM';
			orderLineList[4].PartNumber__c					= '00000005';

			orderLineList[5].OrderType__c					= 'BUNDLEITEM';
			orderLineList[5].PartNumber__c					= '00000006';

			orderLineList[6].OrderType__c					= 'FINAL';
			orderLineList[6].PartNumber__c					= '00000007';
			orderLineList[6].TechGeneratedFinal__c			= true;

			// final original
			orderLineList[7].OrderType__c					= 'FINAL';
			orderLineList[7].PartNumber__c					= '00000008';
			orderLineList[7].AcceptedCheck__c				= false;

			insert orderLineList;

			// Changing order line to bundles
			orderLineList[2].OriginalItem__c	= orderLineList[1].Id;
            orderLineList[4].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[5].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[6].OriginalItem__c	= orderLineList[3].Id;

			update orderLineList;
		}
	}

	@isTest static void constructor_TEST()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test the constructor of the class and assert on the value written by the constructor

			Test.setCurrentPage(Page.VF_PrintPartListForDistributor);

			ApexPages.currentPage().getParameters().put('id', purchaseOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('pdf', 'true'); 
			ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
			ApexPages.currentPage().getParameters().put('force_download', 'true');

			ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrderList[0]);

			Test.startTest();
				VFC_PrintPartListForDistributor controller = new VFC_PrintPartListForDistributor(sc);
			Test.stopTest();

			System.assertNotEquals(null, ApexPages.currentPage().getHeaders().get('content-disposition'));
			System.assertEquals(true, ApexPages.currentPage().getHeaders().get('content-disposition').contains('filename='));
			System.assertEquals(true, ApexPages.currentPage().getHeaders().get('content-disposition').contains(String.valueOf(System.today().day()) + '-' + String.valueOf(System.today().month()) + '-' + String.valueOf(System.today().year()) + '.pdf'));
		}
	}

	@isTest static void getOrderLinesWithPOIssued_TEST()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test the number of OL retruned when the PO is ISSUED status

			Test.setCurrentPage(Page.VF_PrintPartListForDistributor);

			ApexPages.currentPage().getParameters().put('id', purchaseOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('pdf', 'true'); 
			ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
			ApexPages.currentPage().getParameters().put('force_download', 'true');

			ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrderList[0]);
			VFC_PrintPartListForDistributor controller = new VFC_PrintPartListForDistributor(sc);

			Test.startTest();
				List<OrderLine__c> retrunedOrderLineList = controller.getOrderLines();
			Test.stopTest();

			System.assertEquals(4, retrunedOrderLineList.size());
		}
	}

	@isTest static void getOrderLinesWithPOInDelivery_TEST()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test the number of OL retruned when the PO is INDELIVERY status

			purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;

			update purchaseOrderList;

			Test.setCurrentPage(Page.VF_PrintPartListForDistributor);

			ApexPages.currentPage().getParameters().put('id', purchaseOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('pdf', 'true'); 
			ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
			ApexPages.currentPage().getParameters().put('force_download', 'true');

			ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrderList[0]);
			VFC_PrintPartListForDistributor controller = new VFC_PrintPartListForDistributor(sc);

			Test.startTest();
				List<OrderLine__c> retrunedOrderLineList = controller.getOrderLines();
			Test.stopTest();

			// Only 1 OL (final) has Accepted Check as true + 2 bundle item
			System.assertEquals(3, retrunedOrderLineList.size());
		}
	}

	@isTest static void getPurchaseOrder_TEST()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test the number of PO returned by the function getPurchaseOrder
			// NOTE this method is Useless as this class is run for only 1 PO

			Test.setCurrentPage(Page.VF_PrintPartListForDistributor);

			ApexPages.currentPage().getParameters().put('id', purchaseOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('pdf', 'true'); 
			ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
			ApexPages.currentPage().getParameters().put('force_download', 'true');

			ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrderList[0]);
			VFC_PrintPartListForDistributor controller = new VFC_PrintPartListForDistributor(sc);

			Test.startTest();
				List<PurchaseOrder__c> retrunedPurchaseOrderList = controller.getPurchaseOrder();
			Test.stopTest();

			System.assertEquals(1, retrunedPurchaseOrderList.size());
		}
	}

	@isTest static void getDateToday()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test the date returned by the function getDateToday

			Test.setCurrentPage(Page.VF_PrintPartListForDistributor);

			ApexPages.currentPage().getParameters().put('id', purchaseOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('pdf', 'true'); 
			ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
			ApexPages.currentPage().getParameters().put('force_download', 'true');

			ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrderList[0]);
			VFC_PrintPartListForDistributor controller = new VFC_PrintPartListForDistributor(sc);

			Test.startTest();
				String dateReturned = controller.getDateToday();
			Test.stopTest();

			System.assertEquals(String.valueOf(System.today().day()) + '/' + String.valueOf(System.today().month()) + '/' + String.valueOf(System.today().year()), dateReturned);
		}
	}

	@isTest static void getAddress()
	{
		System.runAs(adminUser)
		{
			// In this test method we will test if the address returned by the function contains the bodyshop name and bodyshop address

			Test.setCurrentPage(Page.VF_PrintPartListForDistributor);

			ApexPages.currentPage().getParameters().put('id', purchaseOrderList[0].Id);
			ApexPages.currentPage().getParameters().put('pdf', 'true'); 
			ApexPages.currentPage().getParameters().put('renderAs', 'pdf');
			ApexPages.currentPage().getParameters().put('force_download', 'true');

			ApexPages.StandardController sc = new ApexPages.StandardController(purchaseOrderList[0]);
			VFC_PrintPartListForDistributor controller = new VFC_PrintPartListForDistributor(sc);

			Test.startTest();
				String addressReturned = controller.getAddress();
			Test.stopTest();

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, BodyShopName__c, BodyShopAddress__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			System.assertEquals(true, addressReturned.contains(currentPurchaseOrder.BodyShopName__c));
			System.assertEquals(true, addressReturned.contains(currentPurchaseOrder.BodyShopAddress__c));
		}
	}
}