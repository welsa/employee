/*
  ----------------------------------------------------------------------
  -- - Name          : AP18SetAssessmentStatus_TEST 
  -- - Author        : ABT 
  -- - Description   : AP18SetAssessmentStatus_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 25-APR-2016  ABT    1.0     Reworked version
  -- 07-NOV-2016  ABT    1.1     Added coverage for the method updateAssessmentStatus
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer          Date        Description
  -- ----------         ----------  -----------------------
  -- Ashwina Seetaram   16/10/2015  C-001275: Original Version
 **********************************************************************
*/
@isTest
public class AP18SetAssessmentStatus_TEST 
{
    static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
    static List<InvoiceMargin__c> invoiceMarginList;
    static List<Invoice__c> invoiceList;

    static
    {
        adminUser = TestFactory.createUser('adminUser');
        adminUser.LanguageLocaleKey = 'fr';

        insert adminUser;

        System.runAs(adminUser)
        {
            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
                TestFactory.createAccountDistributor('Distributor_1', 'FR'),

                TestFactory.createAccountBodyshop('BodyShop_ES', 'ES'),
                TestFactory.createAccountDistributor('Distributor_ES', 'ES')
            };
            accountList[0].ContactUser__c = adminUser.Id;

            insert accountList;

            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_FR', accountList[0]),
                TestFactory.createAssessment('Assessment_ES', accountList[2]),
                TestFactory.createAssessment('Assessment_ES', accountList[2])
            };

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
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], 'INDELIVERY'),
                TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], 'INDELIVERY')
            };

            orderLineList[0].AcceptedCheck__c       = false;
            orderLineList[0].PreselectedForOrder__c = true;
            orderLineList[0].Suppliable__c          = 'NO';

            orderLineList[1].AcceptedCheck__c       = false;
            orderLineList[1].PreselectedForOrder__c = true;
            orderLineList[1].Suppliable__c          = 'NO';

            insert orderLineList;

            invoiceMarginList = new List<InvoiceMargin__c>
            {
                new InvoiceMargin__c(Name                = 'FR',
                                     CountryCode__c      = 'FR',
                                     ValidationMargin__c = 1.00)
            };

            insert invoiceMarginList;

            invoiceList = new List<Invoice__c>
            {
                TestFactory.createDistributorInvoice('INV-0001', 1000, ASPISConstants.INV_STATUS_SENT, purchaseOrderList[4])
            };

            insert invoiceList;
        }
    }

    @isTest static void insertPOWithRejectedStatus_TEST()
    {
        System.runAs(adminUser)
        {
            List<PurchaseOrder__c> purchaseOrderToInsertList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[6], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[6], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_REJECTED)
            };

            // Reject reason for rejected purchase order
            purchaseOrderToInsertList[1].Reason__c = 'REJECTEDQUOTE';

            Test.startTest();
                insert purchaseOrderToInsertList;
            Test.stopTest();

            Assessment__c updatedAssessment = [ SELECT  Id, Status__c
                                                FROM    Assessment__c
                                                WHERE   Id =: assessmentList[6].Id];

            System.assertNotEquals(ASPISConstants.ASSESS_STATUS_REJECTED, updatedAssessment.Status__c);
        }
    }

    @isTest static void insertCanceledPO_TEST()
    {
        System.runAs(adminUser)
        {
            List<PurchaseOrder__c> purchaseOrderToInsertList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[6], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[6], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_REJECTED)
            };

            purchaseOrderToInsertList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_CANCELED;

            // Reject reason for rejected purchase order
            purchaseOrderToInsertList[1].Reason__c = 'REJECTEDQUOTE';

            Test.startTest();
                insert purchaseOrderToInsertList;
            Test.stopTest();

            Assessment__c updatedAssessment = [ SELECT  Id, Status__c, ReasonFailure__c
                                                FROM    Assessment__c
                                                WHERE   Id =: assessmentList[6].Id];

            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED,  updatedAssessment.Status__c);
            System.assertEquals('NoPurchaseOrderAvailable',             updatedAssessment.ReasonFailure__c);
        }
    }

    @isTest static void updatePO_TEST()
    {
        System.runAs(adminUser)
        {
            List<PurchaseOrder__c> purchaseOrderToInsertList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[6], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[6], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_REJECTED)
            };

            // Reject reason for rejected purchase order
            purchaseOrderToInsertList[1].Reason__c = 'REJECTEDQUOTE';

            insert purchaseOrderToInsertList;

            purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_REJECTED;
            purchaseOrderList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_CANCELED;

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            Assessment__c updatedAssessment = [ SELECT  Id, Status__c, ReasonFailure__c
                                                FROM    Assessment__c
                                                WHERE   Id =: assessmentList[0].Id];

            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED,  updatedAssessment.Status__c);
            System.assertEquals('NoPurchaseOrderAvailable',             updatedAssessment.ReasonFailure__c);
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

            List<PrerequisiteOrder__c> updatedSalesOrderList = [SELECT  Id, Assessment__c, Status__c, Assessment__r.Status__c
                                                                FROM    PrerequisiteOrder__c
                                                                WHERE   Id IN: salesOrderList];
            
            
            System.assertEquals(ASPISConstants.ASSESS_STATUS_INVOICED, updatedSalesOrderList[0].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_NEW, updatedSalesOrderList[1].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedSalesOrderList[2].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDOK, updatedSalesOrderList[3].Assessment__r.Status__c);
        }
    }

    @isTest static void cancelingPurchaseOrderWithSalesOrder_TEST()
    {
        System.runAs(adminUser)
        {
            salesOrderList[0].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_INVOICED;
            salesOrderList[1].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CANCELEDINVOICE;
            salesOrderList[2].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[3].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[4].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDKO;
            salesOrderList[5].Status__c                 = ASPISConstants.PRE_ORDER_STATUS_CLOSEDOK;

            update salesOrderList;

            purchaseOrderList[0].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CLOSEDOK;
            purchaseOrderList[1].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
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
            

            

            System.assertEquals(ASPISConstants.ASSESS_STATUS_INVOICED, updatedPurchaseOrderList[0].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[1].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[2].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedPurchaseOrderList[3].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CANCELED, updatedPurchaseOrderList[4].Assessment__r.Status__c);
            System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDOK, updatedPurchaseOrderList[5].Assessment__r.Status__c);
            
        }
    }

    @isTest static void cancelingPurchaseOrderWithoutSalesOrder_TEST()
    {
        System.runAs(adminUser)
        {
            // Removing all the sales order of the purchase order assessement
            // This is done to make sure that the assessment of the purchase orders are also updated accordingly
            // after being canceled

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

    @isTest static void updateCanceledByDistributorAssessment_TEST()
    {
        System.runAs(adminUser)
        {
            // updating the purchase order to closedKO
            purchaseOrderList[2].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[3].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[2].Reason__c                          = ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE;
            purchaseOrderList[3].Reason__c                          = ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE;
            purchaseOrderList[2].PrerequisiteOrder__c               = null;
            purchaseOrderList[3].PrerequisiteOrder__c               = null;

            delete salesOrderList[2];
            delete salesOrderList[3];

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<Assessment__c> updatedAssessmentList = [SELECT Id, ReasonFailure__c 
                                                        FROM    Assessment__c
                                                        WHERE   ReasonFailure__c = 'CanceledByDistributor'];
            
            System.assertEquals(2, updatedAssessmentList.size());
        }
    }

    @isTest static void updateCanceledByDistAssClaimOrder_TEST()
    {
        System.runAs(adminUser)
        {
            // updating the purchase order to closedKO
            purchaseOrderList[2].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[3].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[2].Reason__c                          = ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE;
            purchaseOrderList[3].Reason__c                          = ASPISConstants.PUR_ORDER_REASON_UNSUPPLIEDQUOTE;

            assessmentList[2].RecordTypeId                          = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            assessmentList[3].RecordTypeId                          = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            update assessmentList;


            salesOrderList[2].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CANCELED;
            salesOrderList[3].Status__c                             = ASPISConstants.PRE_ORDER_STATUS_CANCELED;
            update salesOrderList;

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<Assessment__c> updatedAssessmentList = [SELECT Id, ReasonFailure__c 
                                                        FROM    Assessment__c
                                                        WHERE   ReasonFailure__c = 'CanceledByDistributor'];
            
            System.assertEquals(2, updatedAssessmentList.size());
        }
    }

    @isTest static void updateAssClaimOrder_TEST()
    {
        System.runAs(adminUser)
        {
            // updating the purchase order to closedKO
            purchaseOrderList[2].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            purchaseOrderList[3].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_CLOSEDKO;
            update purchaseOrderList;

            assessmentList[2].RecordTypeId                          = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            assessmentList[3].RecordTypeId                          = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
            assessmentList[2].Status__c                             = ASPISConstants.ASSESS_STATUS_CANCELED;
            assessmentList[3].Status__c                             = ASPISConstants.ASSESS_STATUS_CANCELED;
            assessmentList[2].OrderOrigin__c                        = 'Order';
            assessmentList[3].OrderOrigin__c                        = 'Order';

            Test.startTest();
                update assessmentList;
            Test.stopTest();

            List<Assessment__c> updatedAssessmentList = [SELECT Id, ReasonFailure__c 
                                                        FROM    Assessment__c
                                                        WHERE   ReasonFailure__c = 'CanceledByDistributor'];
            
            System.assertEquals(2, updatedAssessmentList.size());
        }
    }

    @isTest static void sendEmail_TEST()
    {
        System.runAs(adminUser)
        {

            Test.startTest();
                AP18SetAssessmentStatus.sendEmailToBodyShopAsync(new Set<Id>{assessmentList[0].Id});
            Test.stopTest();
            
            //System.assertNotEquals(null, AP18SetAssessmentStatus.emailResultList);
            //System.assert(AP18SetAssessmentStatus.emailResultList.size() > 0);
        }
    }
}