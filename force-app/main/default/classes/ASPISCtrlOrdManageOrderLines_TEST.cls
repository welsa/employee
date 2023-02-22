/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISCtrlOrdManageOrderLines_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISCtrlOrdManageOrderLines_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 27-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Bhavish (sc)	01/06/2015 	Original Version
 **********************************************************************
*/
@isTest
public class ASPISCtrlOrdManageOrderLines_TEST 
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
				TestFactory.createAccountBodyshop('BodyShopFR', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR', 'FR')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment1', accountList[0]),
				TestFactory.createAssessment('Assessment2', accountList[0])
			};

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			insert purchaseOrderList;
			
			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			insert orderLineList;
		}
	}

	@isTest static void getlistOrderedLines_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISPageOrdManageOrderLines);

			Apexpages.StandardController sc			= new Apexpages.StandardController(purchaseOrderList[0]);
			ASPISCtrlOrdManageOrderLines controller	= new ASPISCtrlOrdManageOrderLines(sc);

			Test.startTest();
				List<OrderLine__c> returnedOrderLines = controller.getlistOrderedLines();
			Test.stopTest();

			System.assertEquals(2,					 returnedOrderLines.size());
			System.assertEquals(orderLineList[0].Id, returnedOrderLines[0].Id);
		}
	}

	@isTest static void updateConfirmedLines_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.ASPISPageOrdManageOrderLines);

			Apexpages.StandardController sc			= new Apexpages.StandardController(purchaseOrderList[0]);
			ASPISCtrlOrdManageOrderLines controller = new ASPISCtrlOrdManageOrderLines(sc);

			List<OrderLine__c> returnedOrderLines	= controller.getlistOrderedLines();

			returnedOrderLines[0].AcceptedCheck__c	= false;

			Test.startTest();
				controller.updateConfirmedLines();
			Test.stopTest();

			List<OrderLine__c> updatedOrderLines = [SELECT	Id
													FROM	OrderLine__c
													WHERE	AcceptedCheck__c = false];

			System.assertEquals(1,					 updatedOrderLines.size());
			System.assertEquals(orderLineList[0].Id, updatedOrderLines[0].Id);
		}
	}
}