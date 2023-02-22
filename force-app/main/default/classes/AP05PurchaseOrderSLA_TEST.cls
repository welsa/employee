/*
  ----------------------------------------------------------------------
  -- - Name          : AP05PurchaseOrderSLA_TEST
  -- - Author        : ABT
  -- - Description   : Test class for AP05PurchaseOrderSLA
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-SEP-2016  ABT    1.0     Initial Version
  -- 05-JAN-2017  AMI    1.1     Changing API name from MaximumDeliveryDuration__c to MaxDeliveryDuration__c
                                 and commenting assignement since field is a RollUp now
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class AP05PurchaseOrderSLA_TEST
{
    static User adminUser;
    static List<MasterRules__c> ruleSetList;
    static List<MasterRules__c> masterRuleList;
    static List<DetailRule__c> detailRuleList;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PrerequisiteOrder__c> salesOrderList;
    static List<PurchaseOrder__c> purchaseOrderList;
    static BusinessHours defaultHours;
    static List<CountryCodeInformationsMapping__c> countryMappingList;

    static
    {
        adminUser = TestFactory.createUser('adminUser');

        insert adminUser;

        System.runAs(adminUser)
        {
            ruleSetList = new List<MasterRules__c>
            {
                TestFactory.createRuleSetSLAPOQuotation('FR299')
            };

            insert ruleSetList;

            masterRuleList = new List<MasterRules__c>
            {
                TestFactory.createMasterRule('FR299', 'QUOTATION', 'PurchaseOrder__c')
            };

            masterRuleList[0].RuleSet__c = ruleSetList[0].Id;

            insert masterRuleList;

            detailRuleList = new List<DetailRule__c>
            {
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel1__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 1),
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel2__c', 'EQUALS', '30', 'Parameters', 'PurchaseOrder__c', 2),
                TestFactory.createDetailRule(null, masterRuleList[0], 'SLAQuotationLevel3__c', 'EQUALS', '25', 'Parameters', 'PurchaseOrder__c', 3)
            };

            detailRuleList[0].ValueFrom__c  = 'H';
            detailRuleList[1].ValueFrom__c  = 'H';
            detailRuleList[2].ValueFrom__c  = 'H';

            insert detailRuleList;

            system.debug('##list2: '+[select fieldsAPI__c,value__c from DetailRule__c where id IN: detailRuleList]);

            accountList = new List<Account>
            {
                TestFactory.createAccountBodyshop('BodyShop_FR', 'FR'),
                TestFactory.createAccountDistributor('Distributor_FR', 'FR')
            };

            insert accountList;

            assessmentList = new List<Assessment__c>
            {
                TestFactory.createAssessment('Assessment_FR', accountList[0])
            };

            assessmentList[0].EntityRules__c    = 'FR299';
            assessmentList[0].EntityCode__c     = '299';

            insert assessmentList;

            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_DELIVERED)
            };

            insert salesOrderList;

            // access Business Hours 
            defaultHours = [SELECT  Id 
                            FROM    BusinessHours 
                            WHERE   IsDefault = true];

            countryMappingList = new List<CountryCodeInformationsMapping__c>
            {
                TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
                TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id)
            };
            
            insert countryMappingList;

            purchaseOrderList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
            };

            insert purchaseOrderList;
            
        }
    }

    @isTest static void initiateSLAProcess_QuotationUsingRuleEngine_TEST()
    {
        System.runAs(adminUser)
        {
            // The function initiateSLAProcess_QuotationUsingRuleEngine is executed on PurchaseOrderTriggerHandler Before Insert
            // The purchase order should be draft quote

            List<PurchaseOrder__c> purchaseOrderToInsertList = new List<PurchaseOrder__c>
            {
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
                TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
            };

            // Setting the SLAQuotationEntryDate__c to null to cover the part where the SLAQuotationEntryDate__c is filled by the class
            purchaseOrderToInsertList[0].SLAQuotationEntryDate__c = null;
            purchaseOrderToInsertList[1].SLAQuotationEntryDate__c = null;

            Test.startTest();
                insert purchaseOrderToInsertList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLAQuotationEntryDate__c, SLAQuotationLevel1__c, SLAQuotationLevel2__c, SLAQuotationLevel3__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderToInsertList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            
            //System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationEntryDate__c);
            //System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel1__c);
            //System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel2__c);
            //System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel3__c);
            System.assertEquals(true, BusinessHours.add(businessDays.id,updatedPurchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[0].Value__c)*60*60*1000L).isSameDay(updatedPurchaseOrderList[0].SLAQuotationLevel1__c));
            System.assertEquals(true, BusinessHours.add(businessDays.id,updatedPurchaseOrderList[0].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[1].Value__c)*60*60*1000L).isSameDay(updatedPurchaseOrderList[0].SLAQuotationLevel1__c));


            //System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationEntryDate__c);
            //System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationLevel1__c);
            //System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationLevel2__c);
            //System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationLevel3__c);
            System.assertEquals(true, BusinessHours.add(businessDays.id,updatedPurchaseOrderList[1].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[0].Value__c)*60*60*1000L).isSameDay(updatedPurchaseOrderList[1].SLAQuotationLevel1__c));
            System.assertEquals(true, BusinessHours.add(businessDays.id,updatedPurchaseOrderList[1].SLAQuotationEntryDate__c, Integer.valueOf(detailRuleList[1].Value__c)*60*60*1000L).isSameDay(updatedPurchaseOrderList[1].SLAQuotationLevel1__c));
        }
    }

    @isTest static void runSLAOnStatus_Acceptance_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_Acceptance is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to RESPONDED or ISSUED
            purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
            purchaseOrderList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_ISSUED;

            // Ensuring that SLAAcceptanceEntryDate__c was null before
            // Setting the SLAAcceptanceEntryDate__c to null to cover the part where the SLAAcceptanceEntryDate__c is filled by the class
            purchaseOrderList[0].SLAAcceptanceEntryDate__c  = null;
            purchaseOrderList[1].SLAAcceptanceEntryDate__c  = null;

            // Ensuring that the field SLAQuotationEntryDate__c is filled (this field is filled on insert of PO)
            purchaseOrderList[0].SLAQuotationEntryDate__c   = System.now();
            purchaseOrderList[1].SLAQuotationEntryDate__c   = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLAQuotationEntryDate__c, SLAAcceptanceEntryDate__c, SLAQuotationDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAAcceptanceEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLAQuotationEntryDate__c, updatedPurchaseOrderList[0].SLAAcceptanceEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLAQuotationDuration__c);


            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAAcceptanceEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLAQuotationEntryDate__c, updatedPurchaseOrderList[1].SLAAcceptanceEntryDate__c,businessDays), updatedPurchaseOrderList[1].SLAQuotationDuration__c);
        }
    }

    @isTest static void runSLAOnStatus_Ordered_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_Ordered is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to ordered
            purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_ORDERED;
            purchaseOrderList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_ORDERED;

            // Ensuring that SLAOrderedEntryDate__c was null before
            // Setting the SLAOrderedEntryDate__c to null to cover the part where the SLAOrderedEntryDate__c is filled by the class
            purchaseOrderList[0].SLAOrderedEntryDate__c     = null;
            purchaseOrderList[1].SLAOrderedEntryDate__c     = null;

            // Ensuring that the field SLAAcceptanceEntryDate__c is filled (this is because PO goes to order after being accepted)
            purchaseOrderList[0].SLAAcceptanceEntryDate__c  = System.now();
            purchaseOrderList[1].SLAAcceptanceEntryDate__c  = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLAAcceptanceEntryDate__c, SLAOrderedEntryDate__c, SLAAcceptanceDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            Businesshours businessDays = ASPISConstants.getBusinesshours('FR');

            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAAcceptanceEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAAcceptanceDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLAAcceptanceEntryDate__c, updatedPurchaseOrderList[0].SLAOrderedEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLAAcceptanceDuration__c);


            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAAcceptanceEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAAcceptanceDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLAAcceptanceEntryDate__c, updatedPurchaseOrderList[1].SLAOrderedEntryDate__c,businessDays), updatedPurchaseOrderList[1].SLAAcceptanceDuration__c);
        }
    }

    @isTest static void runSLAOnStatus_Delivery_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_Delivery is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to INDELIVERY
            purchaseOrderList[0].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;
            purchaseOrderList[1].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_INDELIVERY;

            // Ensuring that SLADeliveryEntryDate__c was null before
            // Setting the SLADeliveryEntryDate__c to null to cover the part where the SLADeliveryEntryDate__c is filled by the class
            purchaseOrderList[0].SLADeliveryEntryDate__c    = null;
            purchaseOrderList[1].SLADeliveryEntryDate__c    = null;

            // Ensuring that the field SLAAcceptanceEntryDate__c is filled (this is because PO goes to delivered after being ordered)
            purchaseOrderList[0].SLAOrderedEntryDate__c     = System.now();
            purchaseOrderList[1].SLAOrderedEntryDate__c     = System.now();

            // Setting the maximum delivery duration so that the estimated delivery date is filled in
            
            //AMI 05/01/18 : Commenting Maximum Delivery Duration since field is a rollup now and api changed to MaxDeliveryDuration__c
            //purchaseOrderList[0].MaximumDeliveryDuration__c = 1;
            //purchaseOrderList[1].MaximumDeliveryDuration__c = 3;

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            //AMI 05/01/18 : Changing API from MaximumDeliveryDuration__c to MaxDeliveryDuration__c
            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLADeliveryEntryDate__c, SLAOrderedEntryDate__c, SLAOrderedDuration__c, MaxDeliveryDuration__c, EstimatedDeliveryDate__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLADeliveryEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAOrderedDuration__c);

            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLAOrderedEntryDate__c, updatedPurchaseOrderList[0].SLADeliveryEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLAOrderedDuration__c);
            
            Datetime dt1 = BusinessHours.add(businessDays.id,updatedPurchaseOrderList[0].SLADeliveryEntryDate__c, 1*10*60*60*1000L);

            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLADeliveryEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLAOrderedEntryDate__c, updatedPurchaseOrderList[1].SLADeliveryEntryDate__c ,businessDays), updatedPurchaseOrderList[1].SLAOrderedDuration__c);
            
            Datetime dt2 = BusinessHours.add(businessDays.id,updatedPurchaseOrderList[1].SLADeliveryEntryDate__c, 1*10*60*60*1000L);
        }
    }

    @isTest static void runSLAOnStatus_DeliveredConfirmedWithOrderedToDeliveredConfirmed_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_DeliveredConfirmed is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to DELIVEREDCONFIRMED
            purchaseOrderList[0].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
            purchaseOrderList[1].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;

            // Ensuring that SLADeliveryConfirmedEntryDate__c was null before
            // Setting the SLADeliveryConfirmedEntryDate__c to null to cover the part where the SLADeliveryConfirmedEntryDate__c is filled by the class
            purchaseOrderList[0].SLADeliveryConfirmedEntryDate__c   = null;
            purchaseOrderList[1].SLADeliveryConfirmedEntryDate__c   = null;

            // This one is tricky and comes in 2 flavours
            // This method will consider that the delivery entry is null and the order entry date is not null
            // That is there has been a changed from ordered to delivered confirmed directly
            purchaseOrderList[0].SLADeliveryEntryDate__c            = null;
            purchaseOrderList[1].SLADeliveryEntryDate__c            = null;

            purchaseOrderList[0].SLAOrderedEntryDate__c             = System.now();
            purchaseOrderList[1].SLAOrderedEntryDate__c             = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLADeliveryConfirmedEntryDate__c, SLADeliveryEntryDate__c, SLAOrderedEntryDate__c, SLAOrderedDuration__c, SLADeliveryDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLADeliveryConfirmedEntryDate__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLADeliveryEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAOrderedDuration__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLADeliveryDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLAOrderedEntryDate__c, updatedPurchaseOrderList[0].SLADeliveryConfirmedEntryDate__c, businessDays), updatedPurchaseOrderList[0].SLAOrderedDuration__c);

            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLADeliveryConfirmedEntryDate__c);
            System.assertEquals(null, updatedPurchaseOrderList[1].SLADeliveryEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedDuration__c);
            System.assertEquals(null, updatedPurchaseOrderList[1].SLADeliveryDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLAOrderedEntryDate__c, updatedPurchaseOrderList[1].SLADeliveryConfirmedEntryDate__c, businessDays), updatedPurchaseOrderList[1].SLAOrderedDuration__c);
        }
    }

    @isTest static void runSLAOnStatus_DeliveredConfirmedWithDeliveredToDeliveredConfirmed_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_DeliveredConfirmed is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to DELIVEREDCONFIRMED
            purchaseOrderList[0].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;
            purchaseOrderList[1].Status__c                          = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;

            // Ensuring that SLADeliveryConfirmedEntryDate__c was null before
            // Setting the SLADeliveryConfirmedEntryDate__c to null to cover the part where the SLADeliveryConfirmedEntryDate__c is filled by the class
            purchaseOrderList[0].SLADeliveryConfirmedEntryDate__c   = null;
            purchaseOrderList[1].SLADeliveryConfirmedEntryDate__c   = null;

            // This one is the other method
            // This method will consider that the delivery entry is already filled in. (done by trigger when the purchase order is in delivered Status)
            purchaseOrderList[0].SLADeliveryEntryDate__c            = System.now();
            purchaseOrderList[1].SLADeliveryEntryDate__c            = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLADeliveryConfirmedEntryDate__c, SLADeliveryEntryDate__c, SLAOrderedEntryDate__c, SLAOrderedDuration__c, SLADeliveryDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLADeliveryConfirmedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLADeliveryEntryDate__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLAOrderedDuration__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLADeliveryDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLADeliveryEntryDate__c, updatedPurchaseOrderList[0].SLADeliveryConfirmedEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLADeliveryDuration__c);

            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLADeliveryConfirmedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLADeliveryEntryDate__c);
            System.assertEquals(null, updatedPurchaseOrderList[1].SLAOrderedDuration__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLADeliveryDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLADeliveryEntryDate__c, updatedPurchaseOrderList[1].SLADeliveryConfirmedEntryDate__c,businessDays), updatedPurchaseOrderList[1].SLADeliveryDuration__c);
        }
    }

    @isTest static void runSLAOnStatus_ClosedFromQuotation_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_Closed is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to CANCELED or REJECTED
            purchaseOrderList[0].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[1].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_REJECTED;

            // Ensuring that SLAClosedEntryDate__c was null before
            // Setting the SLAClosedEntryDate__c to null to cover the part where the SLAClosedEntryDate__c is filled by the class
            purchaseOrderList[0].SLAClosedEntryDate__c      = null;
            purchaseOrderList[1].SLAClosedEntryDate__c      = null;

            // Ensuring that the field SLAQuotationEntryDate__c is filled (this field is filled on insert of PO)
            purchaseOrderList[0].SLAQuotationEntryDate__c   = System.now();
            purchaseOrderList[1].SLAQuotationEntryDate__c   = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLAQuotationEntryDate__c, SLAClosedEntryDate__c, SLAQuotationDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAQuotationDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLAQuotationEntryDate__c, updatedPurchaseOrderList[0].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLAQuotationDuration__c);


            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAQuotationDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLAQuotationEntryDate__c, updatedPurchaseOrderList[1].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[1].SLAQuotationDuration__c);
        }
    }

    @isTest static void runSLAOnStatus_ClosedFromInAcceptance_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_Closed is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to CANCELED or REJECTED
            purchaseOrderList[0].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[1].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_REJECTED;

            // Ensuring that SLAClosedEntryDate__c was null before
            // Setting the SLAClosedEntryDate__c to null to cover the part where the SLAClosedEntryDate__c is filled by the class
            purchaseOrderList[0].SLAClosedEntryDate__c      = null;
            purchaseOrderList[1].SLAClosedEntryDate__c      = null;

            // Ensuring that the field SLAAcceptanceEntryDate__c is filled (this field is filled when PO gets in the status InAcceptance)
            purchaseOrderList[0].SLAAcceptanceEntryDate__c  = System.now();
            purchaseOrderList[1].SLAAcceptanceEntryDate__c  = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLAAcceptanceEntryDate__c, SLAClosedEntryDate__c, SLAAcceptanceDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAAcceptanceEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAAcceptanceDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLAAcceptanceEntryDate__c, updatedPurchaseOrderList[0].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLAAcceptanceDuration__c);


            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAAcceptanceEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAAcceptanceDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLAAcceptanceEntryDate__c, updatedPurchaseOrderList[1].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[1].SLAAcceptanceDuration__c);
        }
    }

    @isTest static void runSLAOnStatus_ClosedFromOrdered_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_Closed is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to CANCELED or REJECTED
            purchaseOrderList[0].Status__c              = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[1].Status__c              = ASPISConstants.PUR_ORDER_STATUS_REJECTED;

            // Ensuring that SLAClosedEntryDate__c was null before
            // Setting the SLAClosedEntryDate__c to null to cover the part where the SLAClosedEntryDate__c is filled by the class
            purchaseOrderList[0].SLAClosedEntryDate__c  = null;
            purchaseOrderList[1].SLAClosedEntryDate__c  = null;

            // Ensuring that the field SLAOrderedEntryDate__c is filled (this field is filled when PO gets in the status Ordered)
            purchaseOrderList[0].SLAOrderedEntryDate__c = System.now();
            purchaseOrderList[1].SLAOrderedEntryDate__c = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLAOrderedEntryDate__c, SLAClosedEntryDate__c, SLAOrderedDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');
            
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAOrderedDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLAOrderedEntryDate__c, updatedPurchaseOrderList[0].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLAOrderedDuration__c);


            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAOrderedDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLAOrderedEntryDate__c, updatedPurchaseOrderList[1].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[1].SLAOrderedDuration__c);
        }
    }

    @isTest static void runSLAOnStatus_ClosedFromDelivered_TEST()
    {
        System.runAs(adminUser)
        {
            // The function runSLAOnStatus_Closed is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to CANCELED or REJECTED
            purchaseOrderList[0].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
            purchaseOrderList[1].Status__c                  = ASPISConstants.PUR_ORDER_STATUS_REJECTED;

            // Ensuring that SLAClosedEntryDate__c was null before
            // Setting the SLAClosedEntryDate__c to null to cover the part where the SLAClosedEntryDate__c is filled by the class
            purchaseOrderList[0].SLAClosedEntryDate__c      = null;
            purchaseOrderList[1].SLAClosedEntryDate__c      = null;

            // Ensuring that the field SLADeliveryEntryDate__c is filled (this field is filled when PO gets in the status Delivered)
            purchaseOrderList[0].SLADeliveryEntryDate__c    = System.now();
            purchaseOrderList[1].SLADeliveryEntryDate__c    = System.now();

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLADeliveryEntryDate__c, SLAClosedEntryDate__c, SLADeliveryDuration__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];


            // Getting an instance of Business Days to check if the date in SLA is the same date as expected
            //Utils_BusinessDays businessDays = new Utils_BusinessDays('FR');
            BusinessHours businessDays = ASPISConstants.getBusinesshours('FR');

            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLADeliveryEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[0].SLADeliveryDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[0].SLADeliveryEntryDate__c, updatedPurchaseOrderList[0].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[0].SLADeliveryDuration__c);


            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLADeliveryEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLAClosedEntryDate__c);
            System.assertNotEquals(null, updatedPurchaseOrderList[1].SLADeliveryDuration__c);
            System.assertEquals(ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(updatedPurchaseOrderList[1].SLADeliveryEntryDate__c, updatedPurchaseOrderList[1].SLAClosedEntryDate__c,businessDays), updatedPurchaseOrderList[1].SLADeliveryDuration__c);
        }
    }

    @isTest static void finishSLAProcess_Quotation_TEST()
    {
        System.runAs(adminUser)
        {
            // The function finishSLAProcess_Quotation is executed on PurchaseOrderTriggerHandler Before Update
            // The purchase order should be updated to RESPONDED
            // It clears all the SLA Levels on the purchase order that was set on insert
            purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
            purchaseOrderList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;

            Test.startTest();
                update purchaseOrderList;
            Test.stopTest();

            List<PurchaseOrder__c> updatedPurchaseOrderList = [ SELECT  Id, SLAQuotationLevel1__c, SLAQuotationLevel2__c, SLAQuotationLevel3__c
                                                                FROM    PurchaseOrder__c
                                                                WHERE   Id IN: purchaseOrderList];

            System.assertEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel1__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel2__c);
            System.assertEquals(null, updatedPurchaseOrderList[0].SLAQuotationLevel3__c);

            System.assertEquals(null, updatedPurchaseOrderList[1].SLAQuotationLevel1__c);
            System.assertEquals(null, updatedPurchaseOrderList[1].SLAQuotationLevel2__c);
            System.assertEquals(null, updatedPurchaseOrderList[1].SLAQuotationLevel3__c);
        }
    }
}