@isTest
/*
----------------------------------------------------------------------
-- - Name          : ASPISBatchRestPostSO_TEST
-- - Author        : ABT
-- - Description   : Test class for ASPISBatchRestPostSO
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 28-FEB-2018  AMI     1.0    Initial version
----------------------------------------------------------------------
*/
private class ASPISBatchRestPostSO_TEST {
	
	static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
	static List<PartList__c> partList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
    static List<OrderLine__c> orderLineList;
    static List<Offer__c> offerList;
    static Id newAssessmentRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
    static Id claimRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
    static Id claimOrderRecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();

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
                TestFactory.createAccountDistributor('Distributor_2', 'ES')
            };

			accountList[0].AXAPartner__c = true;
			accountList[2].AXAPartner__c = true;

            insert accountList;

            // Generating the assessments
            assessmentList = new List<Assessment__c>
            {
				TestFactory.createAssessment('Assessment_FR_NewAssessment', accountList[0]),
				TestFactory.createAssessment('Assessment_FR_Claim', accountList[0]),
				TestFactory.createAssessment('Assessment_FR_ClaimOrder', accountList[0]),
				TestFactory.createAssessment('Assessment_FR_ClaimOrder_InDelivery', accountList[0])
            };

            assessmentList[0].TECH_EntityCountryCode__c = 'FR';
            assessmentList[1].TECH_EntityCountryCode__c = 'FR';
            assessmentList[2].TECH_EntityCountryCode__c = 'FR';
            assessmentList[3].TECH_EntityCountryCode__c = 'FR';

            assessmentList[0].EntityCode__c             = '299';
            assessmentList[1].EntityCode__c             = '392';
            assessmentList[2].EntityCode__c             = '392';
            assessmentList[3].EntityCode__c             = '392';

            assessmentList[0].EntityRules__c            = 'FR299';
            assessmentList[1].EntityRules__c            = 'FR392';
            assessmentList[2].EntityRules__c            = 'FR392';
            assessmentList[3].EntityRules__c            = 'FR392';

            assessmentList[0].RecordTypeId              = newAssessmentRecordTypeId;
            assessmentList[1].RecordTypeId              = claimRecordTypeId;
            assessmentList[2].RecordTypeId              = claimOrderRecordTypeId;
            assessmentList[3].RecordTypeId              = claimOrderRecordTypeId;

            insert assessmentList;

            assessmentList[2].ParentAssessment__c       = assessmentList[1].Id;
            assessmentList[3].ParentAssessment__c       = assessmentList[1].Id;

            update assessmentList;

			partList = new List<PartList__c>
            {
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),

                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1]),

                TestFactory.createPartList(assessmentList[2]),
                TestFactory.createPartList(assessmentList[2]),

                TestFactory.createPartList(assessmentList[3]),
                TestFactory.createPartList(assessmentList[3])
            };

            insert partList;

            salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INACCEPTANCE),
                TestFactory.createSalesOrder(assessmentList[2], accountList[0], 'PREACCEPTANCE'),
                TestFactory.createSalesOrder(assessmentList[3], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
            };

            insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[1], accountList[0], accountList[1], 'PREDRAFTQUOTE'),
				TestFactory.createPurchaseOrder(assessmentList[3], salesOrderList[1], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY)
			};

			purchaseOrderList[0].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId();
			purchaseOrderList[1].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId();
			purchaseOrderList[2].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();

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

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INPROCESS),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			// Setting the new order line orderType as original
			// Only original
			orderLineList[0].OrderType__c					= 'ORIGINAL';
			orderLineList[0].PartNumber__c					= '00000001';

			// original + alternative
			orderLineList[1].OrderType__c					= 'ORIGINAL';
			orderLineList[1].PartNumber__c					= '00000002';

			orderLineList[2].OrderType__c					= 'FINAL';
			orderLineList[2].PartNumber__c					= '00000003';
			orderLineList[2].ExpectedDeliveryDuration__c	= '2';

			// original + bundle
			orderLineList[3].OrderType__c					= 'ORIGINAL';
			orderLineList[3].PartNumber__c					= '00000004';

			orderLineList[4].OrderType__c					= 'BUNDLEITEM';
			orderLineList[4].PartNumber__c					= '00000005';

			orderLineList[5].OrderType__c					= 'BUNDLEITEM';
			orderLineList[5].PartNumber__c					= '00000006';

			orderLineList[6].OrderType__c					= 'FINAL';
			orderLineList[6].PartNumber__c					= '00000007';
			orderLineList[6].TechGeneratedFinal__c			= true;
			orderLineList[6].TechFinalTotalPrice__c			= 1000;
			orderLineList[6].TechFinalTotalAxaPrice__c		= 1000;
			orderLineList[6].TechFinalBSTotalPrice__c		= 1000;


			orderLineList[4].ExpectedDeliveryDuration__c	= '3';

			// final original
			orderLineList[7].OrderType__c					= 'FINAL';
			orderLineList[7].PartNumber__c					= '00000008';
			orderLineList[7].ExpectedDeliveryDuration__c	= '4';

			/********************* PO2 **************************************/
			// Only original
			orderLineList[8].OrderType__c					= 'ORIGINAL';
			orderLineList[8].PartNumber__c					= '00000001';
			orderLineList[8].Manufacturer__c				= 'test manufacturer';

			// original + alternative
			orderLineList[10].OrderType__c					= 'ORIGINAL';
			orderLineList[10].PartNumber__c					= '00000002';
			orderLineList[10].Manufacturer__c				= 'test manufacturer';

			orderLineList[9].OrderType__c					= 'FINAL';
			orderLineList[9].PartNumber__c					= '00000003';
			orderLineList[9].ExpectedDeliveryDuration__c	= '2';
			orderLineList[9].Manufacturer__c				= 'test manufacturer';

			// original + bundle
			orderLineList[12].OrderType__c					= 'ORIGINAL';
			orderLineList[12].PartNumber__c					= '00000004';
			orderLineList[12].Manufacturer__c				= 'test manufacturer';

			orderLineList[11].OrderType__c					= 'BUNDLEITEM';
			orderLineList[11].PartNumber__c					= '00000005';
			orderLineList[11].Manufacturer__c				= 'test manufacturer';

			orderLineList[13].OrderType__c					= 'BUNDLEITEM';
			orderLineList[13].PartNumber__c					= '00000006';
			orderLineList[13].Manufacturer__c				= 'test manufacturer';

			orderLineList[14].OrderType__c					= 'FINAL';
			orderLineList[14].PartNumber__c					= '00000007';
			orderLineList[14].Manufacturer__c				= 'test manufacturer';
			orderLineList[14].TechGeneratedFinal__c			= true;
			orderLineList[14].TechFinalTotalPrice__c		= 1000;
			orderLineList[14].TechFinalTotalAxaPrice__c		= 1000;
			orderLineList[14].TechFinalBSTotalPrice__c		= 1000;


			orderLineList[12].ExpectedDeliveryDuration__c	= '3';

			// final original
			orderLineList[15].OrderType__c					= 'FINAL';
			orderLineList[15].PartNumber__c					= '00000008';
			orderLineList[15].Manufacturer__c				= 'test manufacturer';
			orderLineList[15].ExpectedDeliveryDuration__c	= '4';

			/********************* PO3 **************************************/
			// Only original
			orderLineList[16].OrderType__c					= 'ORIGINAL';
			orderLineList[16].PartNumber__c					= '00000001';
			orderLineList[16].Manufacturer__c				= 'test manufacturer';

			// original + alternative
			orderLineList[18].OrderType__c					= 'ORIGINAL';
			orderLineList[18].PartNumber__c					= '00000002';
			orderLineList[18].Manufacturer__c				= 'test manufacturer';

			orderLineList[17].OrderType__c					= 'FINAL';
			orderLineList[17].PartNumber__c					= '00000003';
			orderLineList[17].ExpectedDeliveryDuration__c	= '2';
			orderLineList[17].Manufacturer__c				= 'test manufacturer';

			// original + bundle
			orderLineList[20].OrderType__c					= 'ORIGINAL';
			orderLineList[20].PartNumber__c					= '00000004';
			orderLineList[20].Manufacturer__c				= 'test manufacturer';

			orderLineList[19].OrderType__c					= 'BUNDLEITEM';
			orderLineList[19].PartNumber__c					= '00000005';
			orderLineList[19].Manufacturer__c				= 'test manufacturer';

			orderLineList[21].OrderType__c					= 'BUNDLEITEM';
			orderLineList[21].PartNumber__c					= '00000006';
			orderLineList[21].Manufacturer__c				= 'test manufacturer';

			orderLineList[22].OrderType__c					= 'FINAL';
			orderLineList[22].PartNumber__c					= '00000007';
			orderLineList[22].Manufacturer__c				= 'test manufacturer';
			orderLineList[22].TechGeneratedFinal__c			= true;
			orderLineList[22].TechFinalTotalPrice__c		= 1000;
			orderLineList[22].TechFinalTotalAxaPrice__c		= 1000;
			orderLineList[22].TechFinalBSTotalPrice__c		= 1000;


			orderLineList[20].ExpectedDeliveryDuration__c	= '3';

			// final original
			orderLineList[23].OrderType__c					= 'FINAL';
			orderLineList[23].PartNumber__c					= '00000008';
			orderLineList[23].Manufacturer__c				= 'test manufacturer';
			orderLineList[23].ExpectedDeliveryDuration__c	= '4';

			insert orderLineList;

			// Changing order line to bundles
			orderLineList[2].OriginalItem__c	= orderLineList[1].Id;
            orderLineList[4].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[5].OriginalItem__c	= orderLineList[6].Id;
            orderLineList[6].OriginalItem__c	= orderLineList[3].Id;

			// Changing order line to bundles
			orderLineList[9].OriginalItem__c	= orderLineList[10].Id;
            orderLineList[11].OriginalItem__c	= orderLineList[14].Id;
            orderLineList[13].OriginalItem__c	= orderLineList[14].Id;
            orderLineList[14].OriginalItem__c	= orderLineList[12].Id;

			orderLineList[17].OriginalItem__c	= orderLineList[18].Id;
            orderLineList[19].OriginalItem__c	= orderLineList[22].Id;
            orderLineList[21].OriginalItem__c	= orderLineList[22].Id;
            orderLineList[22].OriginalItem__c	= orderLineList[20].Id;

			update orderLineList;

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[4], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[5], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], ASPISConstants.OFFER_STATUS_INPROCESS),

				TestFactory.createOfferLine(orderLineList[8], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),
				TestFactory.createOfferLine(orderLineList[14], salesOrderList[1], ASPISConstants.OFFER_STATUS_INPROCESS),

				TestFactory.createOfferLine(orderLineList[16], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[17], salesOrderList[1], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[22], salesOrderList[1], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[19], salesOrderList[1], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[21], salesOrderList[1], ASPISConstants.OFFER_STATUS_INDELIVERY)
			};

			insert offerList;

			offerList[2].ParentOffer__c		= offerList[4].Id;
			offerList[3].ParentOffer__c		= offerList[4].Id;

			offerList[7].ParentOffer__c		= offerList[9].Id;
			offerList[8].ParentOffer__c		= offerList[9].Id;

			offerList[13].ParentOffer__c	= offerList[12].Id;
			offerList[14].ParentOffer__c	= offerList[12].Id;

			update offerList;
        }
    }

    //Purpose of this test method is to check whether or not batch is executed. As far as callout is concerned, this is already covered in RestPostSalesOrder_Test
	@isTest static void testExecuteBatch() {
		system.debug('## Start testExecuteBatch');

		System.runAs(adminUser){
			List<PrerequisiteOrder__c> salesOrderToUpdateList = [SELECT Id, Name
																 FROM	PrerequisiteOrder__c
																 WHERE	Id IN: salesOrderList];

			salesOrderToUpdateList[0].Status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;
			salesOrderToUpdateList[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;

			id jobId = null;

			Test.startTest();
				update salesOrderToUpdateList;

				jobId = database.executeBatch(new ASPISBatchRestPostSO(new set <id>{salesOrderToUpdateList[0].Id,salesOrderToUpdateList[1].Id}),100);
			Test.stopTest();

			system.assert(jobId != null);
		}//end static

		system.debug('## End testExecuteBatch');
	}	
}