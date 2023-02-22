/*
----------------------------------------------------------------------
-- - Name          : VFC06_SOManageOffers_TEST
-- - Author        : ABT
-- - Description   : Test class for VFP06_SOManageOffers
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 24-JUN-2016  ABT     1.0    Initial version
-- 09-NOV-2016  ABT     1.1    Added test methods for the method setAllOfferAccepted
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class VFC06_SOManageOffers_TEST 
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
        adminUser           = TestFactory.createUser('adminUser');
        insert adminUser;

        System.runAs(adminUser)
        {
            // Generating the account
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_1', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
                TestFactory.createAccountDistributor('Distributor_2', 'ES'),

                TestFactory.createAccountBodyshop('BodyShop_3', 'FR'),
                TestFactory.createAccountBodyshop('BodyShop_Parent', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_4', 'ES'),
                TestFactory.createAccountBodyshop('BodyShop_Parent_ES', 'ES')
            };

            insert accountList;

            accountList[0].ParentId = accountList[5].Id;
            accountList[4].ParentId = accountList[5].Id;

            accountList[2].ParentId = accountList[7].Id;
            accountList[6].ParentId = accountList[7].Id;

            update accountList;

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES', accountList[6])
            };

            assessmentList[1].TECH_EntityCountryCode__c = 'ES';
            assessmentList[1].Manufacturer__c           = 'Citroen';


            insert assessmentList;

            // Generating the salesOrder
            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED),
                TestFactory.createSalesOrder(assessmentList[1], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[2], accountList[6], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
            };

            salesOrderList[0].OfferType__c = 'QUICK';
            salesOrderList[0].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();
            salesOrderList[1].OfferType__c = 'QUICK';
            salesOrderList[1].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
            salesOrderList[3].OfferType__c = 'QUICK';
            insert salesOrderList;

            
            // Generating Purchase Order
            purchaseOrderList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED),
                TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[3], accountList[6], accountList[3], ASPISConstants.PUR_ORDER_STATUS_RESPONDED)
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

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
            };

            // Setting the new order line orderType as original
            // Only original
            orderLineList[0].OrderType__c                   = 'ORIGINAL';
            orderLineList[0].PartNumber__c                  = '00000001';
            orderLineList[0].Suppliable__c                  = 'YES';

            // original + alternative
            orderLineList[1].OrderType__c                   = 'ORIGINAL';
            orderLineList[1].PartNumber__c                  = '00000002';
            orderLineList[1].Suppliable__c                  = 'YES';

            orderLineList[2].OrderType__c                   = 'FINAL';
            orderLineList[2].PartNumber__c                  = '00000003';
            orderLineList[2].ExpectedDeliveryDuration__c    = '2';
            orderLineList[2].Suppliable__c                  = 'YES';

            // original + bundle
            orderLineList[3].OrderType__c                   = 'ORIGINAL';
            orderLineList[3].PartNumber__c                  = '00000004';
            orderLineList[3].Suppliable__c                  = 'YES';

            orderLineList[4].OrderType__c                   = 'BUNDLEITEM';
            orderLineList[4].PartNumber__c                  = '00000005';
            orderLineList[4].Suppliable__c                  = 'YES';

            orderLineList[5].OrderType__c                   = 'BUNDLEITEM';
            orderLineList[5].PartNumber__c                  = '00000006';
            orderLineList[5].Suppliable__c                  = 'YES';

            orderLineList[6].OrderType__c                   = 'FINAL';
            orderLineList[6].PartNumber__c                  = '00000007';
            orderLineList[6].Suppliable__c                  = 'YES';


            orderLineList[4].ExpectedDeliveryDuration__c    = '3';

            // final original
            orderLineList[7].OrderType__c                   = 'FINAL';
            orderLineList[7].PartNumber__c                  = '00000008';
            orderLineList[7].ExpectedDeliveryDuration__c    = '4';
            orderLineList[7].Suppliable__c                  = 'YES';

            /********************* PO2 **************************************/
            // Only original
            orderLineList[8].OrderType__c                   = 'ORIGINAL';
            orderLineList[8].PartNumber__c                  = '00000001';
            orderLineList[8].Manufacturer__c                = 'test manufacturer';
            orderLineList[8].Suppliable__c                  = null;

            // original + alternative
            orderLineList[10].OrderType__c                  = 'ORIGINAL';
            orderLineList[10].PartNumber__c                 = '00000002';
            orderLineList[10].Manufacturer__c               = 'test manufacturer';

            orderLineList[9].OrderType__c                   = 'FINAL';
            orderLineList[9].PartNumber__c                  = '00000003';
            orderLineList[9].ExpectedDeliveryDuration__c    = '2';
            orderLineList[9].Manufacturer__c                = 'test manufacturer';

            // original + bundle
            orderLineList[12].OrderType__c                  = 'ORIGINAL';
            orderLineList[12].PartNumber__c                 = '00000004';
            orderLineList[12].Manufacturer__c               = 'test manufacturer';

            orderLineList[11].OrderType__c                  = 'BUNDLEITEM';
            orderLineList[11].PartNumber__c                 = '00000005';
            orderLineList[11].Manufacturer__c               = 'test manufacturer';

            orderLineList[13].OrderType__c                  = 'BUNDLEITEM';
            orderLineList[13].PartNumber__c                 = '00000006';
            orderLineList[13].Manufacturer__c               = 'test manufacturer';

            orderLineList[14].OrderType__c                  = 'FINAL';
            orderLineList[14].PartNumber__c                 = '00000007';
            orderLineList[14].Manufacturer__c               = 'test manufacturer';


            orderLineList[12].ExpectedDeliveryDuration__c   = '3';

            // final original
            orderLineList[15].OrderType__c                  = 'FINAL';
            orderLineList[15].PartNumber__c                 = '00000008';
            orderLineList[15].Manufacturer__c               = 'test manufacturer';
            orderLineList[15].ExpectedDeliveryDuration__c   = '4';

            
            insert orderLineList;

            // Changing order line to bundles
            orderLineList[2].OriginalItem__c    = orderLineList[1].Id;
            orderLineList[4].OriginalItem__c    = orderLineList[6].Id;
            orderLineList[5].OriginalItem__c    = orderLineList[6].Id;
            orderLineList[6].OriginalItem__c    = orderLineList[3].Id;

            // Changing order line to bundles
            orderLineList[9].OriginalItem__c    = orderLineList[10].Id;
            orderLineList[11].OriginalItem__c   = orderLineList[14].Id;
            orderLineList[13].OriginalItem__c   = orderLineList[14].Id;
            orderLineList[14].OriginalItem__c   = orderLineList[12].Id;

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


            offerList[0].Suppliable__c      = true;
            offerList[0].Accepted__c        = null;
            offerList[0].Type__c            = 'QUICK';
            offerList[1].Suppliable__c      = true;
            offerList[1].Accepted__c        = null;
            offerList[1].Type__c            = 'QUICK';
            offerList[2].Suppliable__c      = true;
            offerList[2].Accepted__c        = null;
            offerList[2].Type__c            = 'QUICK';
            offerList[3].Suppliable__c      = true;
            offerList[3].Accepted__c        = null;
            offerList[3].Type__c            = 'QUICK';

            offerList[4].Suppliable__c      = true;
            offerList[4].Accepted__c        = 'YES';
            offerList[4].Type__c            = 'QUICK';
            offerList[5].Suppliable__c      = true;
            offerList[5].Accepted__c        = 'YES';
            offerList[5].Type__c            = 'QUICK';
            offerList[6].Suppliable__c      = true;
            offerList[6].Accepted__c        = 'YES';
            offerList[6].Type__c            = 'QUICK';
            offerList[7].Suppliable__c      = true;
            offerList[7].Accepted__c        = 'YES';
            offerList[7].Type__c            = 'QUICK';

            insert offerList;


            // bundle item offers should be linked to its parent
            offerList[1].ParentOffer__c     = offerList[3].Id;
            offerList[2].ParentOffer__c     = offerList[3].Id;

            offerList[5].ParentOffer__c     = offerList[7].Id;
            offerList[6].ParentOffer__c     = offerList[7].Id;

            update offerList;




            // access Business Hours 
            defaultHours = [SELECT  Id 
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            countryMappingList = new List<CountryCodeInformationsMapping__c>
            {
                TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
            };
            countryMappingList[0].MinDiscountAS__c                  = 1;
            countryMappingList[0].MinDiscountBS__c                  = 1;
            countryMappingList[0].DiscountException__c              = 'FDP';

            countryMappingList[1].MinDiscountAS__c                  = 1;
            countryMappingList[1].MinDiscountBS__c                  = 1;
            countryMappingList[1].UseAdvancedDiscountManagement__c  = true;
            
            insert countryMappingList;
        }
    }

    @isTest static void constructorInAcceptance_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            Test.startTest();
                VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
                Boolean suppliableByAS          = controller.mapOfferWrapper.get(offerList[3].Id).isSelectedByBodyShop;
                Boolean isNotSuppliable         = controller.mapOfferWrapper.get(offerList[3].Id).isNotSelectedByDistributor;
                Integer rowSpan                 = controller.mapOfferWrapper.get(offerList[3].Id).rowSpan;
                rowSpan                         = controller.mapOfferWrapper.get(offerList[0].Id).rowSpan;
                Boolean isOfferOrginal          = controller.mapOfferWrapper.get(offerList[3].Id).isOfferOriginal;
                Boolean isOfferAlternative      = controller.mapOfferWrapper.get(offerList[3].Id).isOfferAlternative;
                
            Test.stopTest();
    
            System.assertEquals(false, controller.isInDelivery);
            System.assertEquals(false, controller.canBeResponded);
            System.assertEquals(false, controller.isPageReadOnly);
            System.assertEquals(3, controller.accountSelectOptionList.size());
        }
    }

    @isTest static void setWrapperAccepted_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            
            Test.startTest();
                controller.wrapperId        = offerList[3].Id;
                controller.setWrapperAccepted();
            Test.stopTest();

            VFC06_SOManageOffers.OfferWrapper currentWrapper = controller.mapOfferWrapper.get(offerList[3].Id);

            System.assertEquals('YES', currentWrapper.parentOffer.Accepted__c);

            for(Offer__c off : currentWrapper.childOfferList)
            {
                System.assertEquals('YES', off.Accepted__c);
            }
        }
    }

    @isTest static void setWrapperNotAccepted_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            
            Test.startTest();
                controller.wrapperId        = offerList[3].Id;
                controller.setWrapperNotAccepted();
            Test.stopTest();

            VFC06_SOManageOffers.OfferWrapper currentWrapper = controller.mapOfferWrapper.get(offerList[3].Id);

            System.assertEquals('NO', currentWrapper.parentOffer.Accepted__c);

            for(Offer__c off : currentWrapper.childOfferList)
            {
                System.assertEquals('NO', off.Accepted__c);
            }
        }
    }

    @isTest static void changeDisplayingOffer_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.wrapperId        = offerList[3].Id;
            controller.setWrapperNotAccepted();
            
            Test.startTest();
                controller.changeDisplayingOffer();
            Test.stopTest();

            VFC06_SOManageOffers.OfferWrapper currentWrapper = controller.mapOfferWrapper.get(offerList[3].Id);

            System.assertEquals(null, currentWrapper.parentOffer.Accepted__c);

            for(Offer__c off : currentWrapper.childOfferList)
            {
                System.assertEquals(null, off.Accepted__c);
            }
        }
    }

    @isTest static void saveAllChangesInAcceptance_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.wrapperId            = offerList[3].Id;
            controller.setWrapperAccepted();
            
            Test.startTest();
                controller.saveAllChanges();
            Test.stopTest();

            PrerequisiteOrder__c updatedSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];

            System.assertNotEquals(null, updatedSalesOrder.OfferType__c);
            System.assertEquals('QUICK', updatedSalesOrder.OfferType__c);
        }
    }

    @isTest static void saveAllChangesInAcceptanceWithNotAccepted_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.wrapperId            = offerList[3].Id;
            controller.setWrapperNotAccepted();

            VFC06_SOManageOffers.OfferWrapper currentWrapper = controller.mapOfferWrapper.get(offerList[3].Id);

            currentWrapper.parentOffer.CancelReason__c       = 'Wrong spare part';

            for(Offer__c off : currentWrapper.childOfferList)
            {
                off.CancelReason__c                          = 'Wrong spare part';
            }
            
            
            Test.startTest();
                controller.saveAllChanges();
            Test.stopTest(); 

            system.debug('##errormsg'+ApexPages.getMessages());
            System.assertEquals(false, ApexPages.hasMessages(ApexPages.Severity.ERROR));
        }
    }

    @isTest static void saveAllChangesInAcceptanceWithError_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
            currentSalesOrder.RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InAcceptance').getRecordTypeId();
            update currentSalesOrder;
            
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.wrapperId            = offerList[3].Id;
            controller.setWrapperNotAccepted();
            
            Test.startTest();
                controller.saveAllChanges();
            Test.stopTest(); 

            System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
        }
    }
     @isTest static void respondSalesOrderV2_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[3].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.wrapperId            = offerList[0].Id;
            controller.setWrapperAccepted();
            controller.wrapperId            = offerList[3].Id;
            controller.setWrapperAccepted();
            controller.saveAllChanges();

            // so as after responded the function canSalesOrderBeResponded is executed
            controller.canSalesOrderBeResponded();
            
            Test.startTest();
                controller.respondSalesOrder();
            Test.stopTest();

            

            PrerequisiteOrder__c updatedSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[3].Id];

            System.assertNotEquals(null                                  , updatedSalesOrder.OfferType__c);
            System.assertEquals('QUICK'                                  , updatedSalesOrder.OfferType__c);
            // ABT - 20-OCT-2016 - C-001677 - Corrected the status of sales order as the sales order will be updated by the workflow from responded to indelivery as all offers
            // are in delivery and the accepted = yes
            // ABT 15-APR-2017 - The assert was giving RESPONDED Why ? -> PO going to closedko due to the other SO DELIVERED
            System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_RESPONDED, updatedSalesOrder.Status__c);
            // System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INDELIVERY, updatedSalesOrder.Status__c);
            System.assertEquals(true                                     , controller.canRefresh);
        }
    }
    @isTest static void respondSalesOrder_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.wrapperId            = offerList[0].Id;
            controller.setWrapperAccepted();
            controller.wrapperId            = offerList[3].Id;
            controller.setWrapperAccepted();
            controller.saveAllChanges();
            
            Test.startTest();
                controller.respondSalesOrder();
            Test.stopTest();

            // so as after responded the function canSalesOrderBeResponded is executed
            controller.canSalesOrderBeResponded();

            PrerequisiteOrder__c updatedSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];

            //System.assertNotEquals(null                                  , updatedSalesOrder.OfferType__c);
            //System.assertEquals('QUICK'                                  , updatedSalesOrder.OfferType__c);
            //// ABT - 20-OCT-2016 - C-001677 - Corrected the status of sales order as the sales order will be updated by the workflow from responded to indelivery as all offers
            //// are in delivery and the accepted = yes
            //// ABT 15-APR-2017 - The assert was giving RESPONDED Why ? -> PO going to closedko due to the other SO DELIVERED
            //System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_RESPONDED, updatedSalesOrder.Status__c);
            //// System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_INDELIVERY, updatedSalesOrder.Status__c);
            //System.assertEquals(true                                     , controller.canRefresh);
        }
    }

    @isTest static void constructorInDelivery_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[1].Id];
    
            Test.startTest();
                VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            Test.stopTest();
    
            System.assertEquals(true, controller.isInDelivery);
            System.assertEquals(false, controller.isPageReadOnly);
        }
    }

    @isTest static void setAllOfferDeliverable_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[1].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));

            Test.startTest();
                controller.setAllOfferDeliverable();
            Test.stopTest();

            VFC06_SOManageOffers.OfferWrapper currentWrapper = controller.mapOfferWrapper.get(offerList[7].Id);

            System.assertEquals(ASPISConstants.OFFER_STATUS_DELIVERED, currentWrapper.parentOffer.DeliveryStatus__c);

            for(Offer__c off : currentWrapper.childOfferList)
            {
                System.assertEquals(ASPISConstants.OFFER_STATUS_DELIVERED, off.DeliveryStatus__c);
            }
    
            System.assertEquals(true, controller.isInDelivery);
        }
    }


    @isTest static void saveAllChangesInDeliveryWithIssues_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[1].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.setAllOfferDeliverable();
            controller.mapOfferWrapper.get(offerList[4].Id).parentOffer.DeliveryStatus__c = ASPISConstants.OFFER_STATUS_ERROR;
            controller.mapOfferWrapper.get(offerList[7].Id).parentOffer.DeliveryStatus__c = ASPISConstants.OFFER_STATUS_ERROR;

            Test.startTest();
                controller.saveAllChanges();
            Test.stopTest();

            PrerequisiteOrder__c updatedSalesOrder = [  SELECT  Id, HasSomeDeliveryIssuedCaseCreated__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[1].Id];
    
            System.assertEquals(true, controller.isInDelivery);
            System.assertEquals(true, updatedSalesOrder.HasSomeDeliveryIssuedCaseCreated__c);
        }
    }

    @isTest static void saveAllChangesInDeliveryWithoutIssues_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[1].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.setAllOfferDeliverable();
            controller.mapOfferWrapper.get(offerList[7].Id).parentOffer.DeliveryStatus__c = ASPISConstants.OFFER_STATUS_RETURNED;

            Test.startTest();
                controller.saveAllChanges();
            Test.stopTest();
    
            PrerequisiteOrder__c updatedSalesOrder = [  SELECT  Id, HasSomeDeliveryIssuedCaseCreated__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[1].Id];
    
            System.assertEquals(true, controller.isInDelivery);
            System.assertEquals(false, updatedSalesOrder.HasSomeDeliveryIssuedCaseCreated__c);
        }
    }

    @isTest static void setAllOfferAccepted_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            
            Test.startTest();
                controller.setAllOfferAccepted();
            Test.stopTest();

            for(VFC06_SOManageOffers.OfferWrapper currentWrapper : controller.mapOfferWrapper.values())
            {
                System.assertEquals('YES', currentWrapper.parentOffer.Accepted__c);

                for(Offer__c off : currentWrapper.childOfferList)
                {
                    System.assertEquals('YES', off.Accepted__c);
                }
            }
        }
    }

    @isTest static void setAllOfferAcceptedWithInvalidOfferType_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller             = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.currentSalesOrder.OfferType__c   = 'Opportunity';

            Test.startTest();
                controller.setAllOfferAccepted();
            Test.stopTest();

            for(VFC06_SOManageOffers.OfferWrapper currentWrapper : controller.mapOfferWrapper.values())
            {
                System.assertEquals(null, currentWrapper.parentOffer.Accepted__c);

                for(Offer__c off : currentWrapper.childOfferList)
                {
                    System.assertEquals(null, off.Accepted__c);
                }
            }
        }
    }

    @isTest static void setAllOfferAcceptedWithDifferentOfferType_TEST()
    {
        System.runAs(adminUser)
        {
            offerList[0].Type__c = 'Opportunity';

            update offerList[0];

            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            VFC06_SOManageOffers controller             = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.currentSalesOrder.OfferType__c   = 'Opportunity';

            Test.startTest();
                controller.setAllOfferAccepted();
            Test.stopTest();

            VFC06_SOManageOffers.OfferWrapper currentOpportunityWrapper = controller.mapOfferWrapper.get(offerList[0].Id);

            System.assertEquals('YES', currentOpportunityWrapper.parentOffer.Accepted__c);

            for(Offer__c off : currentOpportunityWrapper.childOfferList)
            {
                System.assertEquals('YES', off.Accepted__c);
            }

            VFC06_SOManageOffers.OfferWrapper currentQuickWrapper = controller.mapOfferWrapper.get(offerList[3].Id);

            System.assertEquals(null, currentQuickWrapper.parentOffer.Accepted__c);

            for(Offer__c off : currentQuickWrapper.childOfferList)
            {
                System.assertEquals(null, off.Accepted__c);
            }
        }
    }

    // ABT - 19-NOV-2016 - C-001804
    @isTest static void constructorInAcceptanceWithParentAccount_TEST()
    {
        System.runAs(adminUser)
        {
            delete accountList[5];

            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c,recordtype.developername, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[0].Id];
    
            Test.startTest();
                VFC06_SOManageOffers controller = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
                Boolean suppliableByAS          = controller.mapOfferWrapper.get(offerList[3].Id).isSelectedByBodyShop;
                Boolean isNotSuppliable         = controller.mapOfferWrapper.get(offerList[3].Id).isNotSelectedByDistributor;
                Integer rowSpan                 = controller.mapOfferWrapper.get(offerList[3].Id).rowSpan;
                rowSpan                         = controller.mapOfferWrapper.get(offerList[0].Id).rowSpan;
                Boolean isOfferOrginal          = controller.mapOfferWrapper.get(offerList[3].Id).isOfferOriginal;
                Boolean isOfferAlternative      = controller.mapOfferWrapper.get(offerList[3].Id).isOfferAlternative;
                
            Test.stopTest();
            
            System.assertEquals(false, controller.isInDelivery);
            System.assertEquals(false, controller.canBeResponded);
            System.assertEquals(false, controller.isPageReadOnly);
            System.assertEquals(1, controller.accountSelectOptionList.size());
        }
    }

    // ABT - 28-NOV-2016 - C-001804
    @isTest static void changeBodyShop_TEST()
    {
        System.runAs(adminUser)
        {
            Test.setCurrentPage(Page.VFP06_SOManageOffers);
    
            PrerequisiteOrder__c currentSalesOrder = [  SELECT  Id, OfferType__c, Status__c, RecordTypeId, BodyShop__c, BodyShop__r.ParentId, Assessment__c, Assessment__r.OrderOrigin__c,TECH_BodyshopCountryCode__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[2].Id];
    
            VFC06_SOManageOffers controller             = new VFC06_SOManageOffers(new ApexPages.StandardController(currentSalesOrder));
            controller.currentSalesOrder.BodyShop__c    = accountList[7].Id;

            Test.startTest();
                controller.changeBodyShop();
            Test.stopTest();

            PrerequisiteOrder__c updatedSalesOrder = [  SELECT  Id, BodyShop__c, Assessment__c, Assessment__r.BodyShop__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: salesOrderList[2].Id];

            System.assertEquals(accountList[7].Id, updatedSalesOrder.BodyShop__c);
            System.assertEquals(accountList[7].Id, updatedSalesOrder.Assessment__r.BodyShop__c);
        }
    }
}