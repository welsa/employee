/*
  ----------------------------------------------------------------------
  -- - Name          : AP15CalculateTotalExpAmtPO_TEST 
  -- - Author        : ABT 
  -- - Description   : AP15CalculateTotalExpAmtPO_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 25-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Brayan N  		07/10/2015 	Original Version
 **********************************************************************
*/
@isTest
public class AP15CalculateTotalExpAmtPO_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static List<InvoiceMargin__c> invoiceMarginList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR')
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
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
			};

			insert orderLineList;

			invoiceMarginList = new List<InvoiceMargin__c>
			{
				new InvoiceMargin__c(Name				 = 'FR',
									 CountryCode__c		 = 'FR',
									 ValidationMargin__c = 1.00)
			};

			insert invoiceMarginList;
		}
	}

	@isTest static void updatePurchaseOrder_TEST()
	{
		System.runAs(adminUser)
		{
			purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;

			Test.startTest();
				update purchaseOrderList;
			Test.stopTest();

			PurchaseOrder__c updatedPurchaseOrder = [SELECT	Id, TotalExpectedAmount__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];
			// AXA Dis = 20%
			// (1000 * 0.8) + (1000 * 0.8) + (1000 * 0.8)
			System.assertEquals(2400, updatedPurchaseOrder.TotalExpectedAmount__c);
		}
	}

	@isTest static void purchaseOrderToUpdate_TEST()
	{
		System.runAs(adminUser)
		{
			orderLineList[0].DeliveryStatus__c		= ASPISConstants.ORD_LINE_STATUS_CANCELED;
			orderLineList[1].AdditionalDiscountAmount__c = 100;
			orderLineList[2].AdditionalDiscountAmount__c = 100;

			Test.startTest();
				update orderLineList;
			Test.stopTest();

			PurchaseOrder__c updatedPurchaseOrder = [SELECT	Id, TotalExpectedAmount__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];
			// AXA Dis = 20%
			// ((1000 * 0.8) - 100) + ((1000 * 0.8) - 100)
			System.assertEquals(1400, updatedPurchaseOrder.TotalExpectedAmount__c);
		}
	}
}