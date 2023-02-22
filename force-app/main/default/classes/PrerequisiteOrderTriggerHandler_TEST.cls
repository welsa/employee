/*
  ----------------------------------------------------------------------
  -- - Name          : PrerequisiteOrderTriggerHandler_TEST
  -- - Author        : ABT
  -- - Description   : Test class for PrerequisiteOrderTriggerHandler
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 24-OCT-2016  ABT    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class PrerequisiteOrderTriggerHandler_TEST
{
    static User adminUser;
    static List<MasterRules__c> ruleSetList;
    static List<MasterRules__c> masterRuleList;
    static List<DetailRule__c> detailRuleList;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
    static List<Invoice__c> invoiceList;
    static List<CaseDetailsProcessMapping__c> caseMappingList;
    static BusinessHours defaultHours;
    static List<CountryCodeInformationsMapping__c> countryMappingList;

    static
    {
        adminUser = TestFactory.createUser('adminUser');

        insert adminUser;

        System.runAs(adminUser)
        {
            // access Business Hours
            defaultHours = [SELECT  Id 
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            countryMappingList = new List<CountryCodeInformationsMapping__c>
            {
                TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
            };

            countryMappingList[2].NeedInvoiceDetail__c = true;

            insert countryMappingList;

            ruleSetList = new List<MasterRules__c>
            {
                TestFactory.createRuleSetSLAPOQuotation('FR299'),
                TestFactory.createRuleSetSLAPOQuotation('ES299'),
                TestFactory.createRuleSetSLAPOQuotation('IT299')
            };

            insert ruleSetList;

            masterRuleList = new List<MasterRules__c>
            {
                TestFactory.createMasterRule('FR299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c'),
                TestFactory.createMasterRule('ES299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c'),
                TestFactory.createMasterRule('IT299', 'DELIVERYCONFIRMATION', 'PrerequisiteOrder__c')
            };

            masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
            masterRuleList[1].RuleSet__c = ruleSetList[1].Id;
            masterRuleList[2].RuleSet__c = ruleSetList[2].Id;

            insert masterRuleList;

            detailRuleList = new List<DetailRule__c>
            {
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAInDeliveryLevel1__c', 'EQUALS', '1', 'Parameters', 'PrerequisiteOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAInDeliveryLevel2__c', 'EQUALS', '2', 'Parameters', 'PrerequisiteOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAInDeliveryLevel3__c', 'EQUALS', '3', 'Parameters', 'PrerequisiteOrder__c', 3),

                TestFactory.createDetailRule(null, masterRuleList[1], 'SLAInDeliveryLevel1__c', 'EQUALS', '1', 'Parameters', 'PrerequisiteOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[1], 'SLAInDeliveryLevel2__c', 'EQUALS', '2', 'Parameters', 'PrerequisiteOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[1], 'SLAInDeliveryLevel3__c', 'EQUALS', '8', 'Parameters', 'PrerequisiteOrder__c', 3),

                TestFactory.createDetailRule(null, masterRuleList[2], 'SLAInDeliveryLevel1__c', 'EQUALS', '15', 'Parameters', 'PrerequisiteOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[2], 'SLAInDeliveryLevel2__c', 'EQUALS', '30', 'Parameters', 'PrerequisiteOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[2], 'SLAInDeliveryLevel3__c', 'EQUALS', '45', 'Parameters', 'PrerequisiteOrder__c', 3)
            };

            detailRuleList[0].ValueFrom__c  = 'D';
            detailRuleList[1].ValueFrom__c  = 'D';
            detailRuleList[2].ValueFrom__c  = 'D';

            detailRuleList[3].ValueFrom__c  = 'H';
            detailRuleList[4].ValueFrom__c  = 'H';
            detailRuleList[5].ValueFrom__c  = 'H';

            detailRuleList[6].ValueFrom__c  = 'M';
            detailRuleList[7].ValueFrom__c  = 'M';
            detailRuleList[8].ValueFrom__c  = 'M';

            // Also needs to set it active
            detailRuleList[0].Active__c     = true;
            detailRuleList[1].Active__c     = true;
            detailRuleList[2].Active__c     = true;

            detailRuleList[3].Active__c     = true;
            detailRuleList[4].Active__c     = true;
            detailRuleList[5].Active__c     = true;

            detailRuleList[6].Active__c     = true;
            detailRuleList[7].Active__c     = true;
            detailRuleList[8].Active__c     = true;

            insert detailRuleList;

            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
                TestFactory.createAccountDistributor('Distributor_FR', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_ES', 'ES'),
                TestFactory.createAccountDistributor('Distributor_ES', 'ES')
            };

            accountList[2].ContactUser__c = adminUser.Id;

            insert accountList;

            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2])
            };

            assessmentList[2].EntityRules__c            = 'FR299';
            assessmentList[2].EntityCode__c             = '299';
            assessmentList[3].EntityRules__c            = 'FR299';
            assessmentList[3].EntityCode__c             = '299';
            assessmentList[4].EntityRules__c            = 'FR299';
            assessmentList[4].EntityCode__c             = '299';
            assessmentList[5].EntityRules__c            = 'ES299';
            assessmentList[5].EntityCode__c             = '299';
            assessmentList[5].TECH_EntityCountryCode__c = 'ES';

            insert assessmentList;

            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[1], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[2], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[3], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[4], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[5], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE)
            };

            insert salesOrderList;

            purchaseOrderList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[2], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[3], salesOrderList[3], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[4], salesOrderList[4], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[5], salesOrderList[5], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
            };

            insert purchaseOrderList;

            orderLineList = new List<OrderLine__c>
            {
                TestFactory.createOrderLineFinal(10, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(10, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(10, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(10, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(10, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(10, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
                TestFactory.createOrderLineFinal(10, purchaseOrderList[5], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
            };

            orderLineList[2].OrderType__c = 'ORIGINAL';
            orderLineList[3].OrderType__c = 'FINAL';

            insert orderLineList;

            orderLineList[3].OriginalItem__c = orderLineList[2].Id;

            update orderLineList;

            offerList = new List<Offer__c>
            {
                TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[1], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[3], salesOrderList[2], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[4], salesOrderList[3], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[5], salesOrderList[4], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[6], salesOrderList[5], ASPISConstants.OFFER_STATUS_INPROCESS)
            };

            offerList[0].ExpectedDeliveryDate__c    = System.today();
            offerList[0].Accepted__c                = 'YES';
            offerList[0].DeliveryStatus__c          = ASPISConstants.OFFER_STATUS_DELIVERED;
            offerList[1].ExpectedDeliveryDate__c    = System.today();
            offerList[2].ExpectedDeliveryDate__c    = System.today();
            offerList[3].ExpectedDeliveryDate__c    = System.today();
            offerList[3].Accepted__c                = 'YES';
            offerList[3].DeliveryStatus__c          = ASPISConstants.OFFER_STATUS_DELIVERED;
            offerList[4].ExpectedDeliveryDate__c    = System.today();
            offerList[4].Accepted__c                = null;
            offerList[5].ExpectedDeliveryDate__c    = System.today();
            offerList[5].Accepted__c                = 'YES';
            offerList[5].DeliveryStatus__c          = ASPISConstants.OFFER_STATUS_DELIVERED;

            insert offerList;

            caseMappingList = TestFactory.createCaseDetailsProcessMapping();

            insert caseMappingList;
        }
    }

    @isTest static void onBeforeInsert_TEST()
    {
        System.runAs(adminUser)
        {
            PrerequisiteOrder__c newSalesOrder = TestFactory.createSalesOrder(assessmentList[5], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE);

            // testing the insertion of the sales order
            Test.startTest();
                insert newSalesOrder;
            Test.stopTest();

            // The sales order AssessmentName2__c and BodyShopContact__c should have been populated
            PrerequisiteOrder__c insertedSalesOrder = [ SELECT  Id, AssessmentName2__c, BodyShopContact__c
                                                        FROM    PrerequisiteOrder__c
                                                        WHERE   Id =: newSalesOrder.Id];

            System.assertEquals(assessmentList[5].Name, insertedSalesOrder.AssessmentName2__c);
            System.assertEquals(adminUser.Id, insertedSalesOrder.BodyShopContact__c);
        }
    }

    @isTest static void onAfterInsert_TEST()
    {
        System.runAs(adminUser)
        {
            PrerequisiteOrder__c newSalesOrder = TestFactory.createSalesOrder(assessmentList[5], accountList[2], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE);

            // testing the insertion of the sales order
            Test.startTest();
                insert newSalesOrder;
            Test.stopTest();

            // The assessment of the sales order will be shared and a notification will be created
            List<Group> groupList = [SELECT Id
                                     FROM   Group
                                     WHERE  Name =: accountList[2].ReferenceNumber__c];
            
            System.assertEquals(1, groupList.size());

            List<Assessment__Share> assessmentShareList = [ SELECT  Id
                                                            FROM    Assessment__Share
                                                            WHERE   UserOrGroupId =: groupList[0].Id
                                                            AND     ParentId =: assessmentList[5].Id];
            
            System.assertEquals(1, assessmentShareList.size());

            List<Notification__c> notificationList = [  SELECT  Id
                                                        FROM    Notification__c
                                                        WHERE   ObjectReferenceId__c =: newSalesOrder.Id
                                                        AND     Action__c = 'CREATE'];
            
            System.assertEquals(1, notificationList.size());
        }
    }

    @isTest static void onBeforeUpdate_TEST()
    {
        System.runAs(adminUser)
        {
            salesOrderList[0].BodyShop__c   = accountList[2].Id;
            salesOrderList[1].Status__c     = ASPISConstants.PRE_ORDER_STATUS_RESPONDED;
            salesOrderList[2].Status__c     = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;
            salesOrderList[3].Status__c     = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;
            salesOrderList[4].Status__c     = ASPISConstants.PRE_ORDER_STATUS_CANCELED;

            salesOrderList[2].SLAInDeliveryEntryDate__c = null;

            Test.startTest();
                update salesOrderList;
            Test.stopTest();

            List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT  Id, RecordTypeId, BodyShopContact__c, SLARespondedEntryDate__c, SLAInDeliveryEntryDate__c, SLAInDeliveryLevel1__c, SLAInDeliveryLevel2__c, SLAInDeliveryLevel3__c,
                                                                        SLADeliveryConfirmedEntryDate__c, TotalExpectedAmount__c
                                                                FROM    PrerequisiteOrder__c
                                                                WHERE   Id IN: salesOrderList];

            System.assertEquals(adminUser.Id, updatedSalesOrderList[0].BodyShopContact__c);
            
            Id inAcceptanceRecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PREREQUISITEORDER_RT_Name_InAcceptance).getRecordTypeId();
            Id inDeliveryRecordTypeId   = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PREREQUISITEORDER_RT_Name_InDelivery).getRecordTypeId();
            Id eliminatedRecordTypeId   = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get(ASPISConstants.PREREQUISITEORDER_RT_Name_Eliminated).getRecordTypeId();
            
            // The responded sales order will continue execution and will become in delivery
            System.assertEquals(inDeliveryRecordTypeId, updatedSalesOrderList[1].RecordTypeId);
            System.assertEquals(inDeliveryRecordTypeId, updatedSalesOrderList[2].RecordTypeId);
            System.assertEquals(inDeliveryRecordTypeId, updatedSalesOrderList[3].RecordTypeId);
            // As it is canceled before being in Delivery Confirmed, the status will remain CANCELED
            System.assertEquals(eliminatedRecordTypeId, updatedSalesOrderList[4].RecordTypeId);


            System.assertNotEquals(null, updatedSalesOrderList[1].SLARespondedEntryDate__c);

            System.assertNotEquals(null, updatedSalesOrderList[2].SLAInDeliveryEntryDate__c);
            System.assertNotEquals(null, updatedSalesOrderList[2].SLAInDeliveryLevel1__c);
            System.assertNotEquals(null, updatedSalesOrderList[2].SLAInDeliveryLevel2__c);
            System.assertNotEquals(null, updatedSalesOrderList[2].SLAInDeliveryLevel3__c);

            System.assertNotEquals(null, updatedSalesOrderList[3].SLADeliveryConfirmedEntryDate__c);
            System.assertEquals(null, updatedSalesOrderList[3].SLAInDeliveryLevel1__c);
            System.assertEquals(null, updatedSalesOrderList[3].SLAInDeliveryLevel2__c);

            // Only the one converted to delivery confirmed will have the total expected amount set
            System.assertEquals(9, updatedSalesOrderList[3].TotalExpectedAmount__c);
        }
    }

    @isTest static void onAfterUpdate_TEST()
    {
        System.runAs(adminUser)
        {
            salesOrderList[0].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;
            salesOrderList[1].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CANCELED;
            salesOrderList[2].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_RESPONDED;
            salesOrderList[3].HasSomeDeliveryIssuedCaseCreated__c   = true;
            // salesOrderList[3].InternalComment__c                 = 'This is a test case 1';
            salesOrderList[4].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_RESPONDED;
            // salesOrderList[4].InternalComment__c                 = 'This is a test case 2';

            Test.startTest();
                update salesOrderList;
            Test.stopTest();

            // Invoices should be generated for the 1st sales order
            List<Invoice__c> invoicesCreatedList = [SELECT  Id
                                                    FROM    Invoice__c
                                                    WHERE   PrerequisiteOrder__c =: salesOrderList[0].Id];
            
            System.assertEquals(1, invoicesCreatedList.size());

            // The purchase order of the sales order will be CANCELED and it will be in closed KO
            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id
                                                                FROM    PurchaseOrder__c
                                                                WHERE   PrerequisiteOrder__c =: salesOrderList[1].Id
                                                                AND     Status__c =: ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO];

            System.assertEquals(1, updatedPurchaseOrderList.size());

            List<Offer__c> canceledOfferList = [SELECT  Id
                                                FROM    Offer__c
                                                WHERE   PrerequisiteOrder__c =: salesOrderList[1].Id
                                                AND     DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_CANCELED];

            System.assertEquals(1, canceledOfferList.size());

            // the order line of the responded sales order will be updated
            List<PrerequisiteOrder__c> repondedSalesOrder = new List<PrerequisiteOrder__c>
            {
                salesOrderList[2],
                salesOrderList[4]
            };

            List<Offer__c> respondedOfferList = [   SELECT  Id, OrderLine__c, OrderLine__r.AcceptedCheck__c, OrderLine__r.OriginalItem__c, OrderLine__r.OriginalItem__r.AcceptedCheck__c, Accepted__c
                                                    FROM    Offer__c
                                                    WHERE   PrerequisiteOrder__c IN: repondedSalesOrder];
            
            System.assertEquals(true, respondedOfferList[0].OrderLine__r.AcceptedCheck__c);
            System.assertEquals(true, respondedOfferList[0].OrderLine__r.OriginalItem__r.AcceptedCheck__c);

            System.assertEquals('NO', respondedOfferList[1].Accepted__c);
            

            // Case should have been generated for the salesOrderList[3]
            List<Case__c> createdCaseList = [SELECT Id
                                             FROM   Case__c
                                             WHERE  Sales_order__c =: salesOrderList[3].Id];
            
            System.assertEquals(2, createdCaseList.size());

            // The purchase order internal comment should be sync for both sales order
            // List<PrerequisiteOrder__c> syncSalesOrder = new List<PrerequisiteOrder__c>
            // {
            //  salesOrderList[3],
            //  salesOrderList[4]
            // };

            // List<PurchaseOrder__c> syncPurchaseOrderList = [SELECT   Id, InternalComment__c
            //                                              FROM    PurchaseOrder__c
            //                                              WHERE   PrerequisiteOrder__c IN: syncSalesOrder];
            
            // System.assertEquals('This is a test case 1', syncPurchaseOrderList[0].InternalComment__c);
            // System.assertEquals('This is a test case 2', syncPurchaseOrderList[1].InternalComment__c);
        }
    }

    @isTest static void cancelSalesOrderWhenDeliveryConfirmed_TEST()
    {
        System.runAs(adminUser)
        {
            // setting the sales order to Delivery Confirmed before
            salesOrderList[0].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;
            salesOrderList[5].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;
            update salesOrderList;

            // Updating the sales order to canceled
            salesOrderList[0].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CANCELED;
            salesOrderList[5].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CANCELED;

            Test.startTest();
                update salesOrderList;
            Test.stopTest();

            List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT  Id, Status__c, Assessment__c, Assessment__r.Status__c
                                                                FROM    PrerequisiteOrder__c
                                                                WHERE   Status__c =: ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE
                                                                ];
            
            
            System.assertEquals(2, updatedSalesOrderList.size());
            System.assertEquals(salesOrderList[0].Id, updatedSalesOrderList[0].Id);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedSalesOrderList[0].Assessment__r.Status__c);
            System.assertEquals(salesOrderList[5].Id, updatedSalesOrderList[1].Id);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedSalesOrderList[1].Assessment__r.Status__c);
        }
    }

    @isTest static void updateSalesOrderToUpdateAssessment_TEST()
    {
        System.runAs(adminUser)
        {

            // updating the purchase order to closedKO
            purchaseOrderList[2].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[3].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;

            update purchaseOrderList;

            // Setting the status of the sales order
            salesOrderList[0].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_INVOICED;
            salesOrderList[1].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE;
            salesOrderList[2].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[3].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK;
            
            Test.startTest();

                update salesOrderList;
            Test.stopTest();

            List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT  Id,Status__c, Assessment__c, Assessment__r.Status__c
                                                                FROM    PrerequisiteOrder__c
                                                                WHERE   Id IN: salesOrderList];
            
            System.assertEquals(ASPISConstants.ASSESS_STATUS_INVOICED, updatedSalesOrderList[0].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedSalesOrderList[1].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedSalesOrderList[2].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDOK, updatedSalesOrderList[3].Assessment__r.Status__c);
        }
    }

    @isTest static void updateSalesOrderToPaid_TEST()
    {
        System.runAs(adminUser)
        {
            // Setting the status of the sales order
            salesOrderList[0].Status__c = ASPISConstants.PRE_ORDER_STATUS_INVOICED;
            salesOrderList[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE;
            salesOrderList[2].Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[3].Status__c = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK;
            salesOrderList[4].Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;
            
            update salesOrderList;

            salesOrderList[0].Status__c = ASPISConstants.PRE_ORDER_STATUS_PAID;
            salesOrderList[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_PAID;
            salesOrderList[2].Status__c = ASPISConstants.PRE_ORDER_STATUS_PAID;
            salesOrderList[3].Status__c = ASPISConstants.PRE_ORDER_STATUS_PAID;
            salesOrderList[4].Status__c = ASPISConstants.PRE_ORDER_STATUS_PAID;
            

            Test.startTest();
                update salesOrderList;
            Test.stopTest();

            List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT  Id, Status__c
                                                                FROM    PrerequisiteOrder__c
                                                                WHERE   Id IN: salesOrderList];
            
            System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[0].Status__c);
            System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO, updatedSalesOrderList[1].Status__c);
            System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO, updatedSalesOrderList[2].Status__c);
            System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[3].Status__c);
            System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedSalesOrderList[4].Status__c);
        }
    }

    @isTest static void updateSalesOrderWithNoAcceptedLines_TEST()
    {
        System.runAs(adminUser)
        {
            // setting the offer to Accepted__c no
            offerList[0].Accepted__c            = 'NO';

            update offerList;

            // also updating the orderline of the offer
            orderLineList[0].AcceptedCheck__c   = false;

            update orderLineList;

            // Setting the status of the sales order
            salesOrderList[0].Status__c         = ASPISConstants.PRE_ORDER_STATUS_RESPONDED;

            Test.startTest();
                update salesOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, Status__c, Reason__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   PrerequisiteOrder__c IN: salesOrderList];
            
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[0].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE, updatedPurchaseOrderList[0].Reason__c);
        }
    }
}