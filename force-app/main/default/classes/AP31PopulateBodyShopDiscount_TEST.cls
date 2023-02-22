/*
  ----------------------------------------------------------------------
  -- - Name          : AP31PopulateBodyShopDiscount
  -- - Author        : ABT
  -- - Description   : Class to populate the bodyshop discount on OrderLines
  --
  -- Maintenance History:
  --
  -- Date           Name  Version  Remarks
  -- -----------    ----  -------  ---------------------------------------
  -- 15-NOV-2016    ABT    1.0     Initial Version
    ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
private class AP31PopulateBodyShopDiscount_TEST
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
        adminUser = TestFactory.createUser('adminUser');

        insert adminUser;

        System.runAs(adminUser)
        {
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
                TestFactory.createAccountDistributor('Distributor_FR', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_ES', 'ES'),
                TestFactory.createAccountDistributor('Distributor_ES', 'ES'),

                TestFactory.createAccountBodyshop('BodyShop_DE', 'DE'),
                TestFactory.createAccountDistributor('Distributor_DE', 'DE')
            };

            accountList[1].ReferentialASforAParts__c    = 25;
            accountList[1].ReferentialASforBCParts__c   = 25;

            accountList[3].ReferentialASforAParts__c    = 25;
            accountList[3].ReferentialASforBCParts__c   = 25;

            insert accountList;

            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_DE', accountList[4])
            };

            assessmentList[0].EntityRules__c            = 'FR299';
            assessmentList[0].EntityCode__c             = '299';
            assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            assessmentList[0].Manufacturer__c           = 'CITROEN';
            
            assessmentList[1].EntityRules__c            = 'ES299';
            assessmentList[1].EntityCode__c             = '299';
            assessmentList[1].TECH_EntityCountryCode__c = 'ES';
            assessmentList[1].Manufacturer__c           = 'FORD';

            assessmentList[2].EntityRules__c            = 'ES299';
            assessmentList[2].EntityCode__c             = '299';
            assessmentList[2].TECH_EntityCountryCode__c = 'ES';
            assessmentList[2].Manufacturer__c           = 'FORD';

            assessmentList[3].EntityRules__c            = 'DE299';
            assessmentList[3].EntityCode__c             = '299';
            assessmentList[3].TECH_EntityCountryCode__c = 'DE';
            assessmentList[3].Manufacturer__c           = 'FORD';

            insert assessmentList;

            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[1], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[2], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[3], accountList[4], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
            };

            insert salesOrderList;

            purchaseOrderList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[2], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[3], salesOrderList[3], accountList[4], accountList[5], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
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

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
            };

            orderLineList[14].Type__c           = 'B';
            orderLineList[15].Type__c           = 'B';
            orderLineList[16].Type__c           = 'B';
            orderLineList[17].Type__c           = 'B';
            orderLineList[18].Type__c           = 'B';
            orderLineList[19].Type__c           = 'B';
            orderLineList[20].Type__c           = 'B';

            // Setting the new order line orderType as original
            // Only final
            orderLineList[0].OrderType__c           = 'FINAL';
            orderLineList[0].PartNumber__c          = '00000001';
            orderLineList[0].BodyShopDiscount__c    = null;

            // original + alternative
            orderLineList[1].OrderType__c           = 'ORIGINAL';
            orderLineList[1].PartNumber__c          = '00000002';
            orderLineList[1].BodyShopDiscount__c    = null;

            orderLineList[2].OrderType__c           = 'FINAL';
            orderLineList[2].PartNumber__c          = '00000003';
            orderLineList[2].BodyShopDiscount__c    = null;

            // original + bundle
            orderLineList[3].OrderType__c           = 'ORIGINAL';
            orderLineList[3].PartNumber__c          = '00000004';
            orderLineList[3].BodyShopDiscount__c    = null;

            orderLineList[4].OrderType__c           = 'BUNDLEITEM';
            orderLineList[4].PartNumber__c          = '00000005';
            orderLineList[4].BodyShopDiscount__c    = null;

            orderLineList[5].OrderType__c           = 'BUNDLEITEM';
            orderLineList[5].PartNumber__c          = '00000006';
            orderLineList[5].BodyShopDiscount__c    = null;

            orderLineList[6].OrderType__c           = 'FINAL';
            orderLineList[6].PartNumber__c          = '00000007';
            orderLineList[6].BodyShopDiscount__c    = null;

            /******************** PO2 ************************************/

            // Only final
            orderLineList[7].OrderType__c           = 'FINAL';
            orderLineList[7].PartNumber__c          = '00000001';
            orderLineList[7].BodyShopDiscount__c    = null;

            // original + alternative
            orderLineList[8].OrderType__c           = 'ORIGINAL';
            orderLineList[8].PartNumber__c          = '00000002';
            orderLineList[8].BodyShopDiscount__c    = null;

            orderLineList[9].OrderType__c           = 'FINAL';
            orderLineList[9].PartNumber__c          = '00000003';
            orderLineList[9].BodyShopDiscount__c    = null;

            // original + bundle
            orderLineList[10].OrderType__c          = 'ORIGINAL';
            orderLineList[10].PartNumber__c         = '00000004';
            orderLineList[10].BodyShopDiscount__c   = null;

            orderLineList[11].OrderType__c          = 'BUNDLEITEM';
            orderLineList[11].PartNumber__c         = '00000005';
            orderLineList[11].BodyShopDiscount__c   = null;

            orderLineList[12].OrderType__c          = 'BUNDLEITEM';
            orderLineList[12].PartNumber__c         = '00000006';
            orderLineList[12].BodyShopDiscount__c   = null;

            orderLineList[13].OrderType__c          = 'FINAL';
            orderLineList[13].PartNumber__c         = '00000007';
            orderLineList[13].BodyShopDiscount__c   = null;

            /******************** PO2 ************************************/

            // Only final
            orderLineList[14].OrderType__c          = 'FINAL';
            orderLineList[14].PartNumber__c         = '00000001';
            orderLineList[14].BodyShopDiscount__c   = null;

            // original + alternative
            orderLineList[15].OrderType__c          = 'ORIGINAL';
            orderLineList[15].PartNumber__c         = '00000002';
            orderLineList[15].BodyShopDiscount__c   = null;

            orderLineList[16].OrderType__c          = 'FINAL';
            orderLineList[16].PartNumber__c         = '00000003';
            orderLineList[16].BodyShopDiscount__c   = null;

            // original + bundle
            orderLineList[17].OrderType__c          = 'ORIGINAL';
            orderLineList[17].PartNumber__c         = '00000004';
            orderLineList[17].BodyShopDiscount__c   = null;

            orderLineList[18].OrderType__c          = 'BUNDLEITEM';
            orderLineList[18].PartNumber__c         = '00000005';
            orderLineList[18].BodyShopDiscount__c   = null;

            orderLineList[19].OrderType__c          = 'BUNDLEITEM';
            orderLineList[19].PartNumber__c         = '00000006';
            orderLineList[19].BodyShopDiscount__c   = null;

            orderLineList[20].OrderType__c          = 'FINAL';
            orderLineList[20].PartNumber__c         = '00000007';
            orderLineList[20].BodyShopDiscount__c   = null;

            orderLineList[21].OrderType__c          = 'FINAL';
            orderLineList[21].PartNumber__c         = '00000008';
            orderLineList[21].BodyShopDiscount__c   = null;

            orderLineList[22].OrderType__c          = 'FINAL';
            orderLineList[22].PartNumber__c         = '00000009';
            orderLineList[22].BodyShopDiscount__c   = null;

            orderLineList[23].OrderType__c          = 'FINAL';
            orderLineList[23].PartNumber__c         = '00000010';
            orderLineList[23].BodyShopDiscount__c   = null;

            orderLineList[24].OrderType__c          = 'FINAL';
            orderLineList[24].PartNumber__c         = '00000011';
            orderLineList[24].BodyShopDiscount__c   = null;

            insert orderLineList;

            // Changing order line to bundles
            orderLineList[2].OriginalItem__c    = orderLineList[1].Id;
            orderLineList[4].OriginalItem__c    = orderLineList[6].Id;
            orderLineList[5].OriginalItem__c    = orderLineList[6].Id;
            orderLineList[6].OriginalItem__c    = orderLineList[3].Id;

            // Changing order line to bundles
            orderLineList[9].OriginalItem__c    = orderLineList[8].Id;
            orderLineList[11].OriginalItem__c   = orderLineList[13].Id;
            orderLineList[12].OriginalItem__c   = orderLineList[13].Id;
            orderLineList[13].OriginalItem__c   = orderLineList[10].Id;

            // Changing order line to bundles
            orderLineList[16].OriginalItem__c   = orderLineList[15].Id;
            orderLineList[18].OriginalItem__c   = orderLineList[20].Id;
            orderLineList[19].OriginalItem__c   = orderLineList[20].Id;
            orderLineList[20].OriginalItem__c   = orderLineList[17].Id;

            update orderLineList;

            offerList = new List<Offer__c>
            {
                TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[4], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[5], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(orderLineList[7], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[12], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(orderLineList[14], salesOrderList[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[16], salesOrderList[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[18], salesOrderList[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[19], salesOrderList[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[20], salesOrderList[2], ASPISConstants.OFFER_STATUS_INPROCESS)
            };

            // No need to make the link between BUNDLEITEM and FINAL offers for this test class

            discountList = new List<Discount__c>
            {
                TestFactory.createBodyshopDiscount(accountList[0], 10.0, 'A', 'CITROEN'),
                TestFactory.createBodyshopDiscount(accountList[2], 20.0, 'B;C', 'FORD'),
                TestFactory.createBodyshopDiscount(accountList[3], 20.0, 'A', 'FORD')
            };
            discountList[2].ASKeep__c = 3;

            // access Business Hours 
            defaultHours = [SELECT  Id 
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            countryMappingList = new List<CountryCodeInformationsMapping__c>
            {
                TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('DE', defaultHours.Id)
            };
            countryMappingList[0].DefaultBSDiscount__c              = 10;
            countryMappingList[1].DefaultBSDiscount__c              = 20;
            countryMappingList[2].DefaultBSDiscount__c              = 20;

            countryMappingList[1].UseAdvancedDiscountManagement__c  = true;
            
            insert countryMappingList;
        }
    }

    @isTest static void orderLineUpdateWithoutDiscount_TEST()
    {
        System.runAs(adminUser)
        {
            // We update the finals and Bundle Items' AXADiscount__c or TECH_ExtraAS__c only
            orderLineList[0].AXADiscount__c     = 5;
            orderLineList[2].AXADiscount__c     = 5;
            orderLineList[4].AXADiscount__c     = 5;
            orderLineList[5].AXADiscount__c     = 5;
            orderLineList[6].AXADiscount__c     = 5;

            orderLineList[7].TECH_ExtraAS__c    = 10;
            orderLineList[9].TECH_ExtraAS__c    = 10;
            orderLineList[11].TECH_ExtraAS__c   = 10;
            orderLineList[12].TECH_ExtraAS__c   = 10;
            orderLineList[13].TECH_ExtraAS__c   = 10;

            orderLineList[14].TECH_ExtraAS__c   = 10;
            orderLineList[16].TECH_ExtraAS__c   = 10;
            orderLineList[18].TECH_ExtraAS__c   = 10;
            orderLineList[19].TECH_ExtraAS__c   = 10;
            orderLineList[20].TECH_ExtraAS__c   = 10;

            orderLineList[14].AXADiscount__c    = null;
            orderLineList[16].AXADiscount__c    = null;
            orderLineList[18].AXADiscount__c    = null;
            orderLineList[19].AXADiscount__c    = null;
            orderLineList[20].AXADiscount__c    = null;

            Test.startTest();
                update orderLineList;
            Test.stopTest();

            List<OrderLine__c> updatedOrderLineList = [ SELECT  Id, BodyShopDiscount__c
                                                        FROM    OrderLine__c
                                                        WHERE   Id IN: orderLineList];

            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[0].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[1].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[2].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[3].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[4].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[5].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[6].BodyShopDiscount__c);

            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[7].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[8].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[9].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[10].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[11].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[12].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[13].BodyShopDiscount__c);

            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[14].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[15].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[16].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[17].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[18].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[19].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[20].BodyShopDiscount__c);
        }
    }

    @isTest static void orderLineUpdateWithDiscountDE_TEST()
    {
        System.runAs(adminUser)
        {
            insert discountList;

            // We update the finals AXADiscount__c
            orderLineList[21].AXADiscount__c    = 5;
            orderLineList[22].AXADiscount__c    = 5;
            orderLineList[23].AXADiscount__c    = 2;
            orderLineList[24].AXADiscount__c    = 3;

            orderLineList[21].Discount__c   = discountList[2].Id;
            orderLineList[22].Discount__c   = discountList[2].Id;
            orderLineList[23].Discount__c   = discountList[2].Id;
            orderLineList[24].Discount__c   = discountList[2].Id;

            Test.startTest();
                update orderLineList;
            Test.stopTest();

            List<OrderLine__c> updatedOrderLineList = [ SELECT  Id, BodyShopDiscount__c
                                                        FROM    OrderLine__c
                                                        WHERE   Id IN: orderLineList
                                                        AND     Discount__c =: discountList[2].Id];

            System.assertEquals(2, updatedOrderLineList[0].BodyShopDiscount__c);
            System.assertEquals(2, updatedOrderLineList[1].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[2].DefaultBSDiscount__c, updatedOrderLineList[2].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[2].DefaultBSDiscount__c, updatedOrderLineList[3].BodyShopDiscount__c);
        }
    }

    @isTest static void offerLineInsertWithoutDiscount_TEST()
    {
        System.runAs(adminUser)
        {
            Test.startTest();
                insert offerList;
            Test.stopTest();

            List<OrderLine__c> updatedOrderLineList = [ SELECT  Id, BodyShopDiscount__c
                                                        FROM    OrderLine__c
                                                        WHERE   Id IN: orderLineList];

            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[0].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[1].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[2].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[3].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[4].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[5].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[6].BodyShopDiscount__c);

            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[7].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[8].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[9].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[10].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[11].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[12].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[13].BodyShopDiscount__c);

            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[14].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[15].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[16].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[17].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[18].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[19].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[20].BodyShopDiscount__c);
        }
    }

    @isTest static void orderLineUpdateWithDiscount_TEST()
    {
        System.runAs(adminUser)
        {
            insert discountList;

            // We update the finals and Bundle Items' AXADiscount__c or TECH_ExtraAS__c only
            orderLineList[0].AXADiscount__c     = 5;
            orderLineList[2].AXADiscount__c     = 10;
            orderLineList[4].AXADiscount__c     = 15;
            orderLineList[5].AXADiscount__c     = 25;
            orderLineList[6].AXADiscount__c     = 30;

            orderLineList[7].AXADiscount__c     = null;
            orderLineList[9].AXADiscount__c     = null;
            orderLineList[11].AXADiscount__c    = null;
            orderLineList[12].AXADiscount__c    = null;
            orderLineList[13].AXADiscount__c    = null;

            orderLineList[7].TECH_ExtraAS__c    = 5;
            orderLineList[9].TECH_ExtraAS__c    = 10;
            orderLineList[11].TECH_ExtraAS__c   = 15;
            orderLineList[12].TECH_ExtraAS__c   = 25;
            orderLineList[13].TECH_ExtraAS__c   = 30;

            orderLineList[14].AXADiscount__c    = null;
            orderLineList[16].AXADiscount__c    = null;
            orderLineList[18].AXADiscount__c    = null;
            orderLineList[19].AXADiscount__c    = null;
            orderLineList[20].AXADiscount__c    = null;

            orderLineList[14].TECH_ExtraAS__c   = 5;
            orderLineList[16].TECH_ExtraAS__c   = 10;
            orderLineList[18].TECH_ExtraAS__c   = 15;
            orderLineList[19].TECH_ExtraAS__c   = 25;
            orderLineList[20].TECH_ExtraAS__c   = 30;

            Test.startTest();
                update orderLineList;
            Test.stopTest();

            List<OrderLine__c> updatedOrderLineList = [ SELECT  Id, BodyShopDiscount__c
                                                        FROM    OrderLine__c
                                                        WHERE   Id IN: orderLineList];

            System.assertEquals(5, updatedOrderLineList[0].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[1].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[0].DefaultBSDiscount__c, updatedOrderLineList[2].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[3].BodyShopDiscount__c);
            System.assertEquals(15, updatedOrderLineList[4].BodyShopDiscount__c);
            System.assertEquals(25, updatedOrderLineList[5].BodyShopDiscount__c);
            System.assertEquals(20, updatedOrderLineList[6].BodyShopDiscount__c);

            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[7].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[8].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[9].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[10].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[11].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[12].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[13].BodyShopDiscount__c);

            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[14].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[15].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[16].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[17].BodyShopDiscount__c);
            System.assertEquals(5, updatedOrderLineList[18].BodyShopDiscount__c);
            System.assertEquals(15, updatedOrderLineList[19].BodyShopDiscount__c);
            System.assertEquals(10, updatedOrderLineList[20].BodyShopDiscount__c);
        }
    }

    @isTest static void offerLineInsertWithDiscount_TEST()
    {
        System.runAs(adminUser)
        {
            insert discountList;
            
            Test.startTest();
                insert offerList;
            Test.stopTest();

            List<OrderLine__c> updatedOrderLineList = [ SELECT  Id, BodyShopDiscount__c
                                                        FROM    OrderLine__c
                                                        WHERE   Id IN: orderLineList];

            System.assertEquals(20, updatedOrderLineList[0].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[1].BodyShopDiscount__c);
            System.assertEquals(20, updatedOrderLineList[2].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[3].BodyShopDiscount__c);
            System.assertEquals(20, updatedOrderLineList[4].BodyShopDiscount__c);
            System.assertEquals(20, updatedOrderLineList[5].BodyShopDiscount__c);
            System.assertEquals(20, updatedOrderLineList[6].BodyShopDiscount__c);

            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[7].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[8].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[9].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[10].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[11].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[12].BodyShopDiscount__c);
            System.assertEquals(countryMappingList[1].DefaultBSDiscount__c, updatedOrderLineList[13].BodyShopDiscount__c);

            System.assertEquals(10, updatedOrderLineList[14].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[15].BodyShopDiscount__c);
            System.assertEquals(10, updatedOrderLineList[16].BodyShopDiscount__c);
            System.assertEquals(null, updatedOrderLineList[17].BodyShopDiscount__c);
            System.assertEquals(10, updatedOrderLineList[18].BodyShopDiscount__c);
            System.assertEquals(10, updatedOrderLineList[19].BodyShopDiscount__c);
            System.assertEquals(10, updatedOrderLineList[20].BodyShopDiscount__c);
        }
    }
}