/*
----------------------------------------------------------------------
-- - Name          : AP33SendDeliveryNoteViaEmail_TEST
-- - Author        : ABT
-- - Description   : Test class for AP33SendDeliveryNoteViaEmail
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------------------------------
-- 02-MAR-2017  ABT     1.0         Initial version
-- 18-SEP-2020  KPA     1.1         C-003930 : Test Classes IG
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class AP33SendDeliveryNoteViaEmail_TEST
{
    static User adminUser,frUser,beNlUser,beFrUser,deUser,itUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
    
    static
    {
        adminUser           = TestFactory.createUser('adminUser');
        frUser              = TestFactory.createUser('frUser');
        beNlUser            = TestFactory.createUser('BeNlUser');
        beFrUser            = TestFactory.createUser('BeFrUser');
        deUser              = TestFactory.createUser('DeUser');
        itUser              = TestFactory.createUser('ItUser');

        list <User> userlist = new list <User> {adminUser,frUser,beNlUser,beFrUser,deUser,itUser};
        frUser.LanguageLocaleKey = 'fr';
        beNlUser.LanguageLocaleKey = 'nl_BE';
        beFrUser.LanguageLocaleKey = 'fr_BE';
        deUser.LanguageLocaleKey = 'de';
        itUser.LanguageLocaleKey = 'it';
        insert userlist;



        System.runAs(adminUser)
        {
            // Generating the account
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
                TestFactory.createAccountDistributor('Distributor_FR', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_DE', 'DE'),
                TestFactory.createAccountDistributor('Distributor_DE', 'DE'),

                TestFactory.createAccountBodyshop('BodyShop_IT', 'IT'),
                TestFactory.createAccountDistributor('Distributor_IT', 'IT'),

                TestFactory.createAccountBodyshop('BodyShop_BENL', 'BE'),
                TestFactory.createAccountDistributor('Distributor_BENL', 'BE'),

                TestFactory.createAccountBodyshop('BodyShop_BEFR', 'BE'),
                TestFactory.createAccountDistributor('Distributor_BEFR', 'BE')
            };

            accountList[0].ContactUser__c = frUser.Id;
            accountList[2].ContactUser__c = deUser.Id;
            accountList[3].ContactUser__c = itUser.Id;
            accountList[4].ContactUser__c = beNlUser.Id;
            accountList[5].ContactUser__c = beFrUser.Id;

            insert accountList;

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_DE', accountList[2]),
                TestFactory.createAssessment('Assessment_IT', accountList[4]),
                TestFactory.createAssessment('Assessment_BENL', accountList[6]),
                TestFactory.createAssessment('Assessment_BEFR', accountList[8])
            };

            insert assessmentList;

            // Generating the salesOrder
            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
                TestFactory.createSalesOrder(assessmentList[0], accountList[2], ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED),
                TestFactory.createSalesOrder(assessmentList[0], accountList[4], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
                TestFactory.createSalesOrder(assessmentList[0], accountList[6], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
                TestFactory.createSalesOrder(assessmentList[0], accountList[8], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
            };

            salesOrderList[0].OfferType__c = null;
            salesOrderList[0].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
            salesOrderList[1].OfferType__c = 'QUICK';
            salesOrderList[1].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
            salesOrderList[2].OfferType__c = 'QUICK';
            salesOrderList[2].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
            salesOrderList[3].OfferType__c = 'QUICK';
            salesOrderList[3].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();
            salesOrderList[4].OfferType__c = 'QUICK';
            salesOrderList[4].RecordTypeId = Schema.SObjectType.PrerequisiteOrder__c.getRecordTypeInfosByName().get('InDelivery').getRecordTypeId();

            insert salesOrderList;

            // Generating Purchase Order
            purchaseOrderList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),
                TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED),
                TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[2], accountList[4], accountList[5], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED),
                TestFactory.createPurchaseOrder(assessmentList[3], salesOrderList[3], accountList[6], accountList[7], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED),
                TestFactory.createPurchaseOrder(assessmentList[4], salesOrderList[4], accountList[8], accountList[9], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
            };

            insert purchaseOrderList;

            // Generating Order Line
            orderLineList = new List<OrderLine__c>
            {
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_DELIVERED),

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_DELIVERED),

                TestFactory.createOrderLineFinal(1000, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
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
            orderLineList[2].OriginalItem__c    = orderLineList[0].Id;
            orderLineList[4].OriginalItem__c    = orderLineList[3].Id;   
            orderLineList[5].OriginalItem__c    = orderLineList[3].Id;

            // Changing order line to bundles

            update orderLineList;

            offerList = new List<Offer__c>
            {
                TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[4], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[5], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
                TestFactory.createOfferLine(orderLineList[6], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),

                TestFactory.createOfferLine(orderLineList[9], salesOrderList[2], ASPISConstants.OFFER_STATUS_DELIVERED),
                TestFactory.createOfferLine(orderLineList[11], salesOrderList[3], ASPISConstants.OFFER_STATUS_DELIVERED),
                TestFactory.createOfferLine(orderLineList[13], salesOrderList[4], ASPISConstants.OFFER_STATUS_DELIVERED),
                TestFactory.createOfferLine(orderLineList[14], salesOrderList[4], ASPISConstants.OFFER_STATUS_DELIVERED)
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
        }
    }

    @isTest static void sendDeliveryNoteByEmail_TEST()
    {
        System.runAs(adminUser)
        {
            Test.startTest();
                AP33SendDeliveryNoteViaEmail.sendDeliveryNoteByEmail(new Set<Id>{salesOrderList[0].Id,salesOrderList[1].Id,
                    salesOrderList[2].Id,salesOrderList[3].Id,salesOrderList[4].Id});
            Test.stopTest();
            system.debug('##AP33SendDeliveryNoteViaEmail.emailResultList: '+AP33SendDeliveryNoteViaEmail.emailResultList);
            System.assertNotEquals(null, AP33SendDeliveryNoteViaEmail.emailResultList);
            System.assert(AP33SendDeliveryNoteViaEmail.emailResultList.size() > 0);
        }
    }

   //KPA 18/09/2020 C-003930
 @isTest static void InsuranceBroker_IG()
 {
    System.runAs(adminUser)
    {

        assessmentList[0].InsuranceBroker__c='IG';
        //assessmentList[0].Name='Painting';
        //assessmentList[0].isAlphaStore__c=True;
        update assessmentList;

        Test.startTest();
           AP33SendDeliveryNoteViaEmail.sendDeliveryNoteByEmail(new Set<Id>{salesOrderList[0].Id,salesOrderList[1].Id,salesOrderList[2].Id,salesOrderList[3].Id,salesOrderList[4].Id});
        Test.stopTest();
        system.debug('~~~~~AP33SendDeliveryNoteViaEmail.emailResultList: '+AP33SendDeliveryNoteViaEmail.emailResultList);
      //  system.debug('~~~~~is AlphaStore: '+assessmentList[0].isAlphaStore__c);

        
    }
 }



}