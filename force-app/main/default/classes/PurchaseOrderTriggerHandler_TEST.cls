/*
  ----------------------------------------------------------------------
  -- - Name          : PurchaseOrderTriggerHandler_TEST
  -- - Author        : ABT
  -- - Description   : Test class for PurchaseOrderTriggerHandler
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 27-OCT-2016  ABT    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class PurchaseOrderTriggerHandler_TEST
{
    static User adminUser;
    static List<MasterRules__c> ruleSetList;
    static List<MasterRules__c> masterRuleList;
    static List<DetailRule__c> detailRuleList;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PartList__c> partList;
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

            caseMappingList = TestFactory.createCaseDetailsProcessMapping();
            caseMappingList.addAll(new List<CaseDetailsProcessMapping__c>
            {
                new CaseDetailsProcessMapping__c(   Name                    = 'FR-PO-ASMarginTooLow',
                                                    Description__c          = 'Au moins une des pieces de cette commande a un prix ou une remise inappropriée.',
                                                    Due_Date_Duration__c    = 1,
                                                    Due_Date_Unity__c       = 'D',
                                                    Origin__c               = 'APPLICATION',
                                                    Priority__c             = 'MEDIUM',
                                                    Reason__c               = 'DELIVERY',
                                                    Short_Description__c    = 'Case created when at less one Order line of the Purchase Order has an AS Margin too low.',
                                                    Subject__c              = 'Prix ou remise inappropriée',
                                                    Type__c                 = 'PROBLEM',
                                                    Active__c               = true),
                new CaseDetailsProcessMapping__c(   Name                    = 'FR-PO-ASDiscountTooLow',
                                                    Description__c          = 'Seulement pour la classe de test',
                                                    Due_Date_Duration__c    = 4,
                                                    Due_Date_Unity__c       = 'D',
                                                    Origin__c               = 'APPLICATION',
                                                    Priority__c             = 'HIGH',
                                                    Reason__c               = 'DELIVERY',
                                                    Short_Description__c    = 'Case created when the final AS discount (default AS% + extra % defined by the Distributor) is lower than the Low Level Discount defined on the Discount object.',
                                                    Subject__c              = 'ASDiscountTooLow pour classe de test',
                                                    Type__c                 = 'PROBLEM',
                                                    Active__c               = true),
                new CaseDetailsProcessMapping__c(   Name                    = 'FR-PO-DistributorPriceHigh',
                                                    Description__c          = 'Seulement pour la classe de test',
                                                    Due_Date_Duration__c    = 1,
                                                    Due_Date_Unity__c       = 'D',
                                                    Origin__c               = 'APPLICATION',
                                                    Priority__c             = 'HIGH',
                                                    Reason__c               = 'DELIVERY',
                                                    Short_Description__c    = 'Offered price by the Distributor is higher than the assessment price',
                                                    Subject__c              = 'DistributorPriceHigh pour classe de test',
                                                    Type__c                 = 'PROBLEM',
                                                    Active__c               = true)
            });

            insert caseMappingList;

            ruleSetList = new List<MasterRules__c>
            {
                TestFactory.createRuleSetSLAPOQuotation('FR299'),
                TestFactory.createRuleSetSLAPOQuotation('ES299'),
                TestFactory.createRuleSetSLAPOQuotation('IT299')
            };

            insert ruleSetList;

            masterRuleList = new List<MasterRules__c>
            {
                TestFactory.createMasterRule('FR299', 'QUOTATION', 'PurchaseOrder__c'),
                TestFactory.createMasterRule('ES299', 'QUOTATION', 'PurchaseOrder__c'),
                TestFactory.createMasterRule('IT299', 'QUOTATION', 'PurchaseOrder__c'),
                TestFactory.createMasterRule('ES299', 'ORDERQUOTATION', 'PurchaseOrder__c')
            };

            masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
            masterRuleList[1].RuleSet__c = ruleSetList[1].Id;
            masterRuleList[2].RuleSet__c = ruleSetList[2].Id;

            insert masterRuleList;

            detailRuleList = new List<DetailRule__c>
            {
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel1__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel2__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel3__c', 'EQUALS', '25', 'Parameters', 'PurchaseOrder__c', 3),

                TestFactory.createDetailRule(null, masterRuleList[1], 'SLAQuotationLevel1__c', 'EQUALS', '1', 'Parameters', 'PurchaseOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[1], 'SLAQuotationLevel2__c', 'EQUALS', '2', 'Parameters', 'PurchaseOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[1], 'SLAQuotationLevel3__c', 'EQUALS', '8', 'Parameters', 'PurchaseOrder__c', 3),

                TestFactory.createDetailRule(null, masterRuleList[2], 'SLAQuotationLevel1__c', 'EQUALS', '15', 'Parameters', 'PurchaseOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[2], 'SLAQuotationLevel2__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[2], 'SLAQuotationLevel3__c', 'EQUALS', '45', 'Parameters', 'PurchaseOrder__c', 3),

                TestFactory.createDetailRule(null, masterRuleList[3], 'SLAQuotationLevel1__c', 'EQUALS', '15', 'Parameters', 'PurchaseOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[3], 'SLAQuotationLevel2__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[3], 'SLAQuotationLevel3__c', 'EQUALS', '45', 'Parameters', 'PurchaseOrder__c', 3)
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

            insert detailRuleList;

            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
                TestFactory.createAccountDistributor('Distributor_FR', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_ES', 'ES'),
                TestFactory.createAccountDistributor('Distributor_ES', 'ES')
            };

            accountList[3].ContactUser__c = adminUser.Id;

            insert accountList;

            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
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
            assessmentList[5].VINNumber__c              = '123456';
            assessmentList[5].Manufacturer__c           = 'CITROEN';
            assessmentList[5].PlateNumber2__c           = '123456';
            assessmentList[5].Status__c                 = 'NEW';
            assessmentList[5].RecordTypeId              = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();

            assessmentList[6].EntityRules__c            = 'ES299';
            assessmentList[6].EntityCode__c             = '299';
            assessmentList[6].TECH_EntityCountryCode__c = 'ES';
            assessmentList[6].VINNumber__c              = '987654';
            assessmentList[6].Manufacturer__c           = 'CITROEN';
            assessmentList[6].PlateNumber2__c           = '987654';
            assessmentList[6].Status__c                 = 'NEW';

            assessmentList[7].OrderOrigin__c            = 'Quotation';
            assessmentList[7].EntityRules__c            = 'ES299';
            assessmentList[7].EntityCode__c             = '299';
            assessmentList[7].TECH_EntityCountryCode__c = 'ES';
            assessmentList[7].VINNumber__c              = '987654';
            assessmentList[7].Manufacturer__c           = 'CITROEN';
            assessmentList[7].PlateNumber2__c           = '987654';
            assessmentList[7].OrderOrigin__c            = 'Order';
            assessmentList[7].RecordTypeId              = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
        

            insert assessmentList;

            partList = new List<PartList__c>
            {
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[2]),
                TestFactory.createPartList(assessmentList[3]),
                TestFactory.createPartList(assessmentList[4]),
                TestFactory.createPartList(assessmentList[5]),
                TestFactory.createPartList(assessmentList[6]),
                TestFactory.createPartList(assessmentList[7])
            };

            insert partList;

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

            invoiceList = new List<Invoice__c>
            {
                TestFactory.createDistributorInvoice('INV-0001', 1000, ASPISConstants.INV_STATUS_SENT, purchaseOrderList[4])
            };

            insert invoiceList;
        }
    }

    @isTest static void slaPurchaseOrder_TEST(){
        System.runAs(adminUser){

            List<PurchaseOrder__c> purchaseOrderToInsertList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[5], salesOrderList[5], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[7], new PrerequisiteOrder__c(), accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
            };

            purchaseOrderToInsertList[1].Manual_Creation__c = true;

            Test.startTest();
                insert purchaseOrderToInsertList;
            Test.stopTest();

            List<PurchaseOrder__c> insertedPurchaseOrderList = [SELECT  AssessmentName2__c, AssessmentNumber__c, VINNumber__c, Brand__c, PlateNumber__c,
                                                                        SLAQuotationEntryDate__c, SLAQuotationLevel1__c, SLAQuotationLevel2__c, SLAQuotationLevel3__c,
                                                                        DistributorContact__c, Assessment__c, Assessment__r.Status__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderToInsertList];
            assessmentList[5].OrderOrigin__c = 'Order';
            update assessmentList[5];
            System.assertEquals(assessmentList[5].Name, insertedPurchaseOrderList[0].AssessmentName2__c); 
            System.assertEquals(assessmentList[5].AssessmentNumber__c, insertedPurchaseOrderList[0].AssessmentNumber__c);
            System.assertEquals(assessmentList[5].VINNumber__c, insertedPurchaseOrderList[0].VINNumber__c);
            System.assertEquals(assessmentList[5].Manufacturer__c, insertedPurchaseOrderList[0].Brand__c);
            System.assertEquals(assessmentList[5].PlateNumber2__c, insertedPurchaseOrderList[0].PlateNumber__c);

            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationEntryDate__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationLevel1__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationLevel2__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationLevel3__c);

            System.assertEquals(adminUser.Id, insertedPurchaseOrderList[0].DistributorContact__c);
            System.assertEquals('INVOICED', insertedPurchaseOrderList[0].Assessment__r.Status__c); 

            System.assertEquals(assessmentList[7].Name, insertedPurchaseOrderList[1].AssessmentName2__c); 
            System.assertEquals(assessmentList[7].AssessmentNumber__c, insertedPurchaseOrderList[1].AssessmentNumber__c);
            System.assertEquals(assessmentList[7].VINNumber__c, insertedPurchaseOrderList[1].VINNumber__c);
            System.assertEquals(assessmentList[7].Manufacturer__c, insertedPurchaseOrderList[1].Brand__c);
            System.assertEquals(assessmentList[7].PlateNumber2__c, insertedPurchaseOrderList[1].PlateNumber__c);
        }
    }

    @isTest static void onBeforeInsert_TEST()
    {
        System.runAs(adminUser)
        {
            List<PurchaseOrder__c> purchaseOrderToInsertList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[5], salesOrderList[5], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[6], new PrerequisiteOrder__c(), accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
            };


            purchaseOrderToInsertList[1].Manual_Creation__c = true;

            Test.startTest();
                insert purchaseOrderToInsertList;
            Test.stopTest();

            List<PurchaseOrder__c> insertedPurchaseOrderList = [SELECT  AssessmentName2__c, AssessmentNumber__c, VINNumber__c, Brand__c, PlateNumber__c,
                                                                        SLAQuotationEntryDate__c, SLAQuotationLevel1__c, SLAQuotationLevel2__c, SLAQuotationLevel3__c,
                                                                        DistributorContact__c, Assessment__c, Assessment__r.Status__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderToInsertList];

            System.assertEquals(assessmentList[5].Name, insertedPurchaseOrderList[0].AssessmentName2__c);
            System.assertEquals(assessmentList[5].AssessmentNumber__c, insertedPurchaseOrderList[0].AssessmentNumber__c);
            System.assertEquals(assessmentList[5].VINNumber__c, insertedPurchaseOrderList[0].VINNumber__c);
            System.assertEquals(assessmentList[5].Manufacturer__c, insertedPurchaseOrderList[0].Brand__c);
            System.assertEquals(assessmentList[5].PlateNumber2__c, insertedPurchaseOrderList[0].PlateNumber__c);

            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationEntryDate__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationLevel1__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationLevel2__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[0].SLAQuotationLevel3__c);

            System.assertEquals(adminUser.Id, insertedPurchaseOrderList[0].DistributorContact__c);
            System.assertEquals('INVOICED', insertedPurchaseOrderList[0].Assessment__r.Status__c);

            System.assertEquals(assessmentList[6].Name, insertedPurchaseOrderList[1].AssessmentName2__c);
            System.assertEquals(assessmentList[6].AssessmentNumber__c, insertedPurchaseOrderList[1].AssessmentNumber__c);
            System.assertEquals(assessmentList[6].VINNumber__c, insertedPurchaseOrderList[1].VINNumber__c);
            System.assertEquals(assessmentList[6].Manufacturer__c, insertedPurchaseOrderList[1].Brand__c);
            System.assertEquals(assessmentList[6].PlateNumber2__c, insertedPurchaseOrderList[1].PlateNumber__c);

            System.assertNotEquals(null, insertedPurchaseOrderList[1].SLAQuotationEntryDate__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[1].SLAQuotationLevel1__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[1].SLAQuotationLevel2__c);
            System.assertNotEquals(null, insertedPurchaseOrderList[1].SLAQuotationLevel3__c);

            System.assertEquals(adminUser.Id, insertedPurchaseOrderList[1].DistributorContact__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_SOURCED, insertedPurchaseOrderList[1].Assessment__r.Status__c);
        }
    }

    @isTest static void onAfterInsert_TEST()
    {
        system.debug('##Start onAfterInsert_TEST');
        System.runAs(adminUser)
        {
            List<PurchaseOrder__c> purchaseOrderToInsertList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[5], salesOrderList[5], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[5], salesOrderList[5], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[6], new PrerequisiteOrder__c(), accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_CANCELED)
            };

            purchaseOrderList[0].Manual_Creation__c             = true;
            purchaseOrderToInsertList[0].BodyShopOrderNumber__c = '0001';
            purchaseOrderToInsertList[1].BodyShopOrderNumber__c = '0002';

            purchaseOrderToInsertList[2].Reason__c              = ASPISConstants.PUR_ORDER_REASON_REJECTEDQUOTE;

            Test.startTest();
                insert purchaseOrderToInsertList;
            Test.stopTest();

            List<PurchaseOrder__c> insertedPurchaseOrderList = [SELECT  Assessment__c, Assessment__r.Status__c, PrerequisiteOrder__c, PrerequisiteOrder__r.BodyShopOrderNumber__c,
                                                                        (SELECT Id
                                                                         FROM   OrderLines__r)
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderToInsertList];
            system.debug('##status'+insertedPurchaseOrderList[0].Assessment__r.Status__c);
            System.assertEquals(1, insertedPurchaseOrderList[0].OrderLines__r.size());
            System.assertEquals(1, insertedPurchaseOrderList[1].OrderLines__r.size());
            System.assertEquals(purchaseOrderList[5].BodyShopOrderNumber__c + ';' +
                                purchaseOrderToInsertList[0].BodyShopOrderNumber__c + ';' +
                                purchaseOrderToInsertList[1].BodyShopOrderNumber__c, insertedPurchaseOrderList[0].PrerequisiteOrder__r.BodyShopOrderNumber__c);
            System.assertEquals('INVOICED', insertedPurchaseOrderList[0].Assessment__r.Status__c);


            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, insertedPurchaseOrderList[2].Assessment__r.Status__c);
            system.debug('##End onAfterInsert_TEST');
        }
    }

    @isTest static void onBeforeUpdate_TEST()
    {
        System.runAs(adminUser)
        {
            Test.startTest();
                orderLineList[4].AcceptedCheck__c   = true;
                orderLineList[4].DeliveryStatus__c  = ASPISConstants.ORD_LINE_STATUS_DELIVERED;

                update orderLineList;

                purchaseOrderList[0].Status__c      = ASPISConstants.PUR_ORDER_STATUS_ISSUED;
                purchaseOrderList[1].Status__c      = ASPISConstants.PUR_ORDER_STATUS_ORDERED;
                purchaseOrderList[2].Status__c      = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;
                purchaseOrderList[3].Status__c      = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
                purchaseOrderList[4].Status__c      = ASPISConstants.PUR_ORDER_STATUS_REJECTED;

                purchaseOrderList[0].Distributor__c = accountList[3].Id;

                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  SLAQuotationEntryDate__c, SLAQuotationLevel1__c, SLAQuotationLevel2__c, SLAQuotationLevel3__c,
                                                                        DistributorContact__c, SLAAcceptanceEntryDate__c, SLAOrderedEntryDate__c, SLADeliveryEntryDate__c,
                                                                        SLADeliveryConfirmedEntryDate__c, SLAClosedEntryDate__c, TotalExpectedAmount__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];

            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAAcceptanceEntryDate__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel1__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel2__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel3__c);

            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[2].SLADeliveryEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[3].SLADeliveryConfirmedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[4].SLAClosedEntryDate__c);

            System.assertEquals(8, updatedPurchaseOrderList[3].TotalExpectedAmount__c);
        }
    }

    @isTest static void onAfterUpdate_TEST()
    {
        System.runAs(adminUser)
        {
            System.debug('@@@ test starts');
            Test.startTest();
                assessmentList[5].TECH_EntityCountryCode__c  = 'FR';
                assessmentList[5].OrderOrigin__c            = 'Order';
                update assessmentList[5];

                purchaseOrderList[1].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_ISSUED;
                purchaseOrderList[2].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;

                update purchaseOrderList;

                orderLineList[0].AcceptedCheck__c                   = true;
                orderLineList[1].AcceptedCheck__c                   = true;
                //orderLineList[2].AcceptedCheck__c                     = true;
                orderLineList[3].AcceptedCheck__c                   = true;
                orderLineList[4].AcceptedCheck__c                   = true;
                orderLineList[5].AcceptedCheck__c                   = true;
                orderLineList[6].AcceptedCheck__c                   = true;

                update orderLineList;

                purchaseOrderList[0].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
                // purchaseOrderList[0].InternalComment__c             = 'Test 1';
                purchaseOrderList[0].InvoiceStatusNotValidated__c   = true;

                purchaseOrderList[1].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
                // purchaseOrderList[1].InternalComment__c             = 'Test 2';

                purchaseOrderList[2].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
                purchaseOrderList[2].Reason__c                      = ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE;

                purchaseOrderList[3].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;
                purchaseOrderList[3].BodyShopOrderNumber__c         = '123456789';
                purchaseOrderList[3].DelayedCaseCreated__c          = true;
                purchaseOrderList[3].ASMarginTooLowCaseCreated__c   = true;
                purchaseOrderList[3].ASDiscountLowCaseCreated__c    = true;
                purchaseOrderList[3].DistributorPriceHigger__c      = true;
                purchaseOrderList[3].TECHSLAQuotationIsLevel2__c    = true;

                purchaseOrderList[4].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
                purchaseOrderList[4].InvoiceStatus__c               = ASPISConstants.PUR_ORDER_INVOICESTATUS_VALIDATED;

                purchaseOrderList[5].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
                purchaseOrderList[5].TECHSLAQuotationIsLevel2__c    = true;

                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  PrerequisiteOrder__c, PrerequisiteOrder__r.Status__c, PrerequisiteOrder__r.BodyShopOrderNumber__c, /*PrerequisiteOrder__r.InternalComment__c,*/
                                                                        Assessment__c, Assessment__r.Status__c,
                                                                        (SELECT Id, CountryCode__c, TECH_AutomaticCreationFromProcess__c
                                                                         FROM   Cases__r),
                                                                        (SELECT Id, DeliveryStatus__c
                                                                         FROM   OrderLines__r),
                                                                        (SELECT Id, Status__c
                                                                         FROM   Invoices__r)
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];

            //System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[0].PrerequisiteOrder__r.Status__c);
            System.assertEquals(ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED, updatedPurchaseOrderList[0].PrerequisiteOrder__r.Status__c);
            // System.assertEquals(purchaseOrderList[0].InternalComment__c, updatedPurchaseOrderList[0].PrerequisiteOrder__r.InternalComment__c);
            System.assertEquals(3, updatedPurchaseOrderList[0].Cases__r.size());

            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedPurchaseOrderList[1].Assessment__r.Status__c);
            // System.assertEquals(purchaseOrderList[1].InternalComment__c, updatedPurchaseOrderList[1].PrerequisiteOrder__r.InternalComment__c);
            System.assertEquals(3, updatedPurchaseOrderList[1].Cases__r.size());
            System.assertEquals(ASPISConstants.ORD_LINE_STATUS_CANCELED, updatedPurchaseOrderList[1].OrderLines__r[0].DeliveryStatus__c);

            System.assertEquals('CLOSEDKO', updatedPurchaseOrderList[2].Assessment__r.Status__c);
            System.assertEquals(3, updatedPurchaseOrderList[2].Cases__r.size());
            System.assertEquals(ASPISConstants.ORD_LINE_STATUS_CANCELED, updatedPurchaseOrderList[2].OrderLines__r[0].DeliveryStatus__c);
            System.assertEquals(ASPISConstants.ORD_LINE_STATUS_CANCELED, updatedPurchaseOrderList[2].OrderLines__r[1].DeliveryStatus__c);

            System.assertEquals(purchaseOrderList[3].BodyShopOrderNumber__c, updatedPurchaseOrderList[3].PrerequisiteOrder__r.BodyShopOrderNumber__c);
            System.assertEquals(4, updatedPurchaseOrderList[3].Cases__r.size());

            System.assertEquals(ASPISConstants.INV_STATUS_PAYABLE, updatedPurchaseOrderList[4].Invoices__r[0].Status__c);

            //System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDOK, updatedPurchaseOrderList[5].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedPurchaseOrderList[5].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ORD_LINE_STATUS_CANCELED, updatedPurchaseOrderList[5].OrderLines__r[0].DeliveryStatus__c);
        }
    }

    @isTest static void onAfterUpdateStatusIssued_TEST()
    {
        System.runAs(adminUser)
        {
            System.debug('@@@ test starts');
            Test.startTest();
                assessmentList[5].TECH_EntityCountryCode__c  = 'FR';
                assessmentList[5].OrderOrigin__c            = 'Order';
                update assessmentList[5];

                assessmentList[4].TECH_EntityCountryCode__c  = 'DE';
                assessmentList[4].InsuranceBroker__c  = system.label.InsBrokerName;
                
                assessmentList[4].OrderOrigin__c            = 'Order';
                update assessmentList[4];
                
                assessmentList[3].TECH_EntityCountryCode__c  = 'BE';
                assessmentList[3].OrderOrigin__c            = 'Order';
                update assessmentList[3];


                purchaseOrderList[4].AutoValidate_PO__c                      = true;
                purchaseOrderList[4].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
                purchaseOrderList[1].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_ISSUED;
                purchaseOrderList[1].AutoValidate_PO__c                      = true;
                purchaseOrderList[3].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
                update purchaseOrderList;

                orderLineList[1].AcceptedCheck__c                   = true;
                
                update orderLineList;

                purchaseOrderList[1].Status__c                      = ASPISConstants.PUR_ORDER_STATUS_ISSUED;

                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  PrerequisiteOrder__c, PrerequisiteOrder__r.Status__c, PrerequisiteOrder__r.BodyShopOrderNumber__c, /*PrerequisiteOrder__r.InternalComment__c,*/
                                                                        Assessment__c, Assessment__r.Status__c,
                                                                        (SELECT Id, CountryCode__c, TECH_AutomaticCreationFromProcess__c
                                                                         FROM   Cases__r),
                                                                        (SELECT Id, DeliveryStatus__c
                                                                         FROM   OrderLines__r),
                                                                        (SELECT Id, Status__c
                                                                         FROM   Invoices__r)
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];

        
            System.assertEquals(ASPISConstants.ASSESS_STATUS_OFFERING, updatedPurchaseOrderList[1].Assessment__r.Status__c);
            // System.assertEquals(purchaseOrderList[1].InternalComment__c, updatedPurchaseOrderList[1].PrerequisiteOrder__r.InternalComment__c);
            System.assertEquals(2, updatedPurchaseOrderList[1].Cases__r.size());
            System.assertEquals(ASPISConstants.ORD_LINE_STATUS_INPROCESS, updatedPurchaseOrderList[1].OrderLines__r[0].DeliveryStatus__c);

        }
    }

    @isTest static void cancelingPurchaseOrderWithoutSalesOrder_TEST()
    {
        System.runAs(adminUser)
        {
            // Removing all the sales order of the purchase order assessement
            // This is done to make sure that the assessment of the purchase orders are also updated accordingly
            // after being canceled

            assessmentList[5].TECH_EntityCountryCode__c  = 'FR';
            update assessmentList[5];

            delete salesOrderList;

            purchaseOrderList[0].PrerequisiteOrder__c   = null;
            purchaseOrderList[1].PrerequisiteOrder__c   = null;
            purchaseOrderList[2].PrerequisiteOrder__c   = null;
            purchaseOrderList[3].PrerequisiteOrder__c   = null;
            purchaseOrderList[4].PrerequisiteOrder__c   = null;
            purchaseOrderList[5].PrerequisiteOrder__c   = null;

            purchaseOrderList[0].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[1].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[2].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[3].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[4].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[5].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
        

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Status__c, Assessment__c, Assessment__r.Status__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];
            
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[0].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[1].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[2].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[3].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE, updatedPurchaseOrderList[4].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[5].Status__c);

            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[0].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[1].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[2].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[3].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedPurchaseOrderList[4].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[5].Assessment__r.Status__c);
            
        }
    }

    @isTest static void setPurchaseOrderToPaid_TEST()
    {
        System.runAs(adminUser)
        {
            purchaseOrderList[0].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE;
            purchaseOrderList[1].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE;
            purchaseOrderList[2].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE;
            
            update purchaseOrderList;

            purchaseOrderList[0].Status__c              = ASPISConstants.PUR_ORDER_STATUS_PAID;
            purchaseOrderList[1].Status__c              = ASPISConstants.PUR_ORDER_STATUS_PAID;
            purchaseOrderList[2].Status__c              = ASPISConstants.PUR_ORDER_STATUS_PAID;
            purchaseOrderList[3].Status__c              = ASPISConstants.PUR_ORDER_STATUS_PAID;
            purchaseOrderList[4].Status__c              = ASPISConstants.PUR_ORDER_STATUS_PAID;
            purchaseOrderList[5].Status__c              = ASPISConstants.PUR_ORDER_STATUS_PAID;
        

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Status__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];
            system.debug('##updatedPurchaseOrderList '+updatedPurchaseOrderList);
            system.debug('##orderLineList[5].DeliveryStatus__c '+orderLineList[5].DeliveryStatus__c);
            
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[0].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[1].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO, updatedPurchaseOrderList[2].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[3].Status__c);
            // Due to @future in InvoiceTriggerHandler....the PO is reopended
            //System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_PAYABLE, updatedPurchaseOrderList[4].Status__c);
            //Change to delivered confirmed as PO is reopened to delivered confirmed
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED, updatedPurchaseOrderList[4].Status__c);
            // System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[4].Status__c);
            System.assertEquals(ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK, updatedPurchaseOrderList[5].Status__c);
        }   
    }

    @isTest static void cancelingPurchaseOrderWithSalesOrder_TEST()
    {
        System.runAs(adminUser)
        {

            assessmentList[5].TECH_EntityCountryCode__c = 'FR';
            update assessmentList[5];

            salesOrderList[0].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_INVOICED;
            salesOrderList[1].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE;
            salesOrderList[2].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[3].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[4].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[5].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK;

            update salesOrderList;

            purchaseOrderList[0].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;
            purchaseOrderList[1].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;
            purchaseOrderList[2].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[3].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[4].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELEDINVOICE;
            purchaseOrderList[5].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Status__c, Assessment__c, Assessment__r.Status__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];
            For (PurchaseOrder__c p: updatedPurchaseOrderList){
                System.debug('@@ p: '+p);
                System.debug('@@ p: '+p.Assessment__r.Status__c);
            }
            

            System.assertEquals(ASPISConstants.ASSESS_STATUS_INVOICED, updatedPurchaseOrderList[0].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedPurchaseOrderList[1].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[2].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[3].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedPurchaseOrderList[4].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDOK, updatedPurchaseOrderList[5].Assessment__r.Status__c);
            
        }
    }

    @isTest static void createOrderLines_WithSubstitute_TEST()
    {
        System.runAs(adminUser)
        {
            String crossRefIAMPartNumber = 'IAM12345';
        
            CrossReference__c crossRef1 = TestFactory.createCrossReference('FR', 'A1238261299', 'CITROEN', 50.0, true);
            //crossRef1.Name = crossRefName;
            crossRef1.IAMPublicPrice__c = 50.0;
            crossRef1.IAMPartNumber__c = crossRefIAMPartNumber;
            insert crossRef1;

            CrossReference__c crossRef2 = [SELECT Name, ActiveForSubstitution__c FROM CrossReference__c WHERE Id = :crossRef1.Id];
            String crossRefName = crossRef2.Name;            
            crossRef2.ActiveForSubstitution__c = true;
            update crossRef2;
            system.debug('## crossRef2: '+crossRef2);

            List<Account> accList = new List<Account>();
            Account distributor = TestFactory.createAccountDistributor('DistributorTest_FR', 'FR');
            Account bodyshop = TestFactory.createAccountBodyshop('BodyShopTest_FR', 'FR');
            accList.add(distributor);            
            accList.add(bodyshop);
            insert accList;

            DistributorPrice__c dp = TestFactory.createDistributorPrice(distributor.Id, crossRef1.Id);
            dp.DistributorPublicPrice__c = 100.0; // test to get this price and not the Assessment standard price
            dp.DistributorPartNumber__c = 'IAM12345';
            //dp.Active__c = true;
           // dp.isDeleted__c = false;
            insert dp;



            DistributorPrice__c dpUpd= [Select id, Active__c from DistributorPrice__c where DistributorPartNumber__c = 'IAM12345'];
            dpUpd.Active__c = true;
            dpUpd.isDeleted__c = false;

            update dpUpd;
            
            Assessment__c assessment = TestFactory.createAssessment('ASSESS_TEST-0001', bodyshop);
            assessment.CrossReferences__c = crossRefName;
            insert assessment;

            // should add value to Assessment.CrossReferences__c (partNumber__c starting with 'ASCR-')
            PartList__c part = TestFactory.createPartList(assessment);
            part.PartNumber__c = crossRefName;
            part.Price__c = 150.0;
            part.Distributor__c = distributor.Id;
            part.CrossReferenceId__c = crossRef1.Id;
            part.DistributorPriceId__c = dp.Id;
            insert part;

            PurchaseOrder__c purchaseOrder = TestFactory.createPurchaseOrder(assessment, salesOrderList[5], bodyshop, distributor, ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE);
            purchaseOrder.Manual_Creation__c             = true;
            purchaseOrder.BodyShopOrderNumber__c = '0001';

             // Test
             Test.startTest();
                insert purchaseOrder;

                // Check
                List<PurchaseOrder__c> insertedPurchaseOrderList = [SELECT  Assessment__c, Assessment__r.Status__c, PrerequisiteOrder__c, PrerequisiteOrder__r.BodyShopOrderNumber__c,
                                                                            (SELECT Id, PartNumber__c, CataloguePrice__c, DistributorPrice__c
                                                                            FROM   OrderLines__r)
                                                                    FROM    PurchaseOrder__c
                                                                    WHERE   Id = :purchaseOrder.Id];
            Test.stopTest();

            System.assertEquals(1, insertedPurchaseOrderList[0].OrderLines__r.size());

            System.assertEquals(crossRefIAMPartNumber, insertedPurchaseOrderList[0].OrderLines__r[0].PartNumber__c);
            System.assertEquals(dp.DistributorPublicPrice__c, insertedPurchaseOrderList[0].OrderLines__r[0].CataloguePrice__c);
            System.assertEquals(dp.Id, insertedPurchaseOrderList[0].OrderLines__r[0].DistributorPrice__c);
        }
    }
}