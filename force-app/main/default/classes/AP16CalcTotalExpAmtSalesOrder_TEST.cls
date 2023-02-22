/*
  ----------------------------------------------------------------------
  -- - Name          : AP16CalcTotalExpAmtSalesOrder_TEST 
  -- - Author        : ABT 
  -- - Description   : AP16CalcTotalExpAmtSalesOrder_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 25-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer      Date        Description
  -- ----------     ----------  -----------------------
  -- Brayan N       19/11/2015  Original Version
 **********************************************************************
*/
@isTest
public class AP16CalcTotalExpAmtSalesOrder_TEST 
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
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
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
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
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
            };

            insert orderLineList;

            offerList = new List<Offer__c>
            {
                TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
                TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
                TestFactory.createOfferLine(orderLineList[2], salesOrderList[1], ASPISConstants.OFFER_STATUS_INDELIVERY),
                TestFactory.createOfferLine(orderLineList[3], salesOrderList[1], ASPISConstants.OFFER_STATUS_INDELIVERY)
            };

            insert offerList;

            invoiceMarginList = new List<InvoiceMargin__c>
            {
                new InvoiceMargin__c(Name                = 'FR',
                                     CountryCode__c      = 'FR',
                                     ValidationMargin__c = 1.00)
            };

            insert invoiceMarginList;
        }
    }

	// ABT 19-OCT-2016 - C-001677 - Commented as the calculation of total expected amount has been removed in invoice trigger handler
    // @isTest static void invoiceInsert_TEST()
    // {
    //     System.runAs(adminUser)
    //     {
    //         List<Invoice__c> invoiceToBeInsertedList = new List<Invoice__c>
    //         {
    //             TestFactory.createBodyshopCreditNote('00000001', 1000, 'SENT', salesOrderList[0]),
    //             TestFactory.createBodyshopInvoice('00000002', 1000, 'SENT', salesOrderList[0])
    //         };
	// 
    //         Test.startTest();
    //             insert invoiceToBeInsertedList;
    //         Test.stopTest();
	// 
    //         PrerequisiteOrder__c updatedSaleOrder = [SELECT Id, TotalExpectedAmount__c
    //                                                  FROM   PrerequisiteOrder__c
    //                                                  WHERE  Id =: salesOrderList[0].Id];
    //         // (1000 * 0.9) + (1000 * 0.9)
    //         System.assertEquals(1800, updatedSaleOrder.TotalExpectedAmount__c);
    //     }
    // }

    @isTest static void salesOrderUpdate_TEST()
    {
        System.runAs(adminUser)
        {
            offerList[2].DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;
            offerList[3].DeliveryStatus__c = ASPISConstants.OFFER_STATUS_DELIVERED;

            update offerList;

            salesOrderList[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;

            Test.startTest();
                update salesOrderList;
            Test.stopTest();

            PrerequisiteOrder__c updatedSaleOrder = [SELECT Id, TotalExpectedAmount__c
                                                     FROM   PrerequisiteOrder__c
                                                     WHERE  Id =: salesOrderList[1].Id];
            // (1000 * 0.9) + (1000 * 0.9)
            System.assertEquals(1800, updatedSaleOrder.TotalExpectedAmount__c);
        }
    }
}