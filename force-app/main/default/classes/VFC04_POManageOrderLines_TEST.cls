/*
----------------------------------------------------------------------
-- - Name          : VFC04_POManageOrderLines_TEST
-- - Author        : ABT
-- - Description   : Test class for VFC04_POManageOrderLines
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 10-JUN-2016	ABT		1.0    Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
public class VFC04_POManageOrderLines_TEST 
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
	static List<CaseDetailsProcessMapping__c> caseMappingList;
	
	static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			caseMappingList.addAll(new List<CaseDetailsProcessMapping__c>
			{
				new CaseDetailsProcessMapping__c(Name                   = 'ES-PO-OrderLineRectification',
												 Description__c         = 'Le distributeur a modifié la/les ligne(s) de commande(s) {0} au tarif de {1} sur la {2}.',
												 Internal_Comments__c 	= 'Veuillez contacter le distributeur rapidement.',
												 Due_Date_Duration__c 	= 1,
												 Due_Date_Unity__c 		= 'D',
												 Origin__c 				= 'APPLICATION',
												 Priority__c 			= 'CRITICAL',
												 Reason__c 				= 'APPLICATION',
												 Short_Description__c 	= 'Case is created when the order lines have been modified when the purchase order is InDelivery on the page VFP04_POManageOrderLines',
												 Subject__c 			= 'Une ligne de commande a été modifié par un distributeur',
												 Type__c 				= 'PROBLEM',
												 Active__c 				= true)
			});

			insert caseMappingList;

			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES'),

				TestFactory.createAccountBodyshop('BS_3', 'DE'),
				TestFactory.createAccountDistributor('Distributor_3', 'DE')

				

			};

			accountList[0].VAT__c = 20;
			accountList[1].VAT__c = 20;
			accountList[2].VAT__c = 21;
			accountList[3].VAT__c = 21;
			accountList[4].VAT__c = 21;
			accountList[5].VAT__c = 21;

			insert accountList;

			Id claimRecordTypeId 			= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id claimOrderRecordTypeId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id newAssessmentRecordTypeId	= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();	

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2]),
				TestFactory.createAssessment('Assessment_DE', accountList[4])
				
			};

			assessmentList[1].TECH_EntityCountryCode__c = 'ES';
			assessmentList[1].Manufacturer__c			= 'Citroen';

			assessmentList[2].TECH_EntityCountryCode__c = 'DE';
			assessmentList[2].InsuranceBroker__c= system.label.InsBrokerName;



			assessmentList[2].RecordTypeId 		= claimOrderRecordTypeId;

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
				TestFactory.createSalesOrder(assessmentList[2], accountList[4], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], new PrerequisiteOrder__c(), accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], new PrerequisiteOrder__c(), accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),

				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0],		   accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED),
				TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[1], accountList[4], accountList[5], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY)

			};

			purchaseOrderList[0].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId();
			purchaseOrderList[1].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('DraftQuote').getRecordTypeId();
			purchaseOrderList[2].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();
			purchaseOrderList[3].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();

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

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INPROCESS)
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
			orderLineList[8].Suppliable__c					= null;

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

			/************************* PO3 *******************************/
			// Only original
			orderLineList[16].OrderType__c					= 'ORIGINAL';
			orderLineList[16].PartNumber__c					= '00000001';

			// original + alternative
			orderLineList[17].OrderType__c					= 'ORIGINAL';
			orderLineList[17].PartNumber__c					= '00000002';

			orderLineList[18].OrderType__c					= 'FINAL';
			orderLineList[18].PartNumber__c					= '00000003';
			orderLineList[18].ExpectedDeliveryDuration__c	= '2';

			// original + bundle
			orderLineList[19].OrderType__c					= 'ORIGINAL';
			orderLineList[19].PartNumber__c					= '00000004';

			orderLineList[20].OrderType__c					= 'BUNDLEITEM';
			orderLineList[20].PartNumber__c					= '00000005';

			orderLineList[21].OrderType__c					= 'BUNDLEITEM';
			orderLineList[21].PartNumber__c					= '00000006';

			orderLineList[22].OrderType__c					= 'FINAL';
			orderLineList[22].PartNumber__c					= '00000007';


			orderLineList[20].ExpectedDeliveryDuration__c	= '3';

			// final original
			orderLineList[23].OrderType__c					= 'FINAL';
			orderLineList[23].PartNumber__c					= '00000008';
			orderLineList[23].ExpectedDeliveryDuration__c	= '4';
			orderLineList[24].OrderType__c					= 'SHIPPING COST';

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

			// Changing order line to bundles
			orderLineList[18].OriginalItem__c	= orderLineList[17].Id;
            orderLineList[20].OriginalItem__c	= orderLineList[22].Id;
            orderLineList[21].OriginalItem__c	= orderLineList[22].Id;
            orderLineList[22].OriginalItem__c	= orderLineList[19].Id;

			update orderLineList;

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[16], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[17], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[18], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[19], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[20], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[21], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[22], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY),
				TestFactory.createOfferLine(orderLineList[23], salesOrderList[0], ASPISConstants.OFFER_STATUS_INDELIVERY)
			};

			insert offerList;

			discountList = new List<Discount__c>
			{
				TestFactory.createDistributorDiscount(accountList[3], 10.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 50.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 10.0, 'B', 'Citroen')
			};

			discountList[0].Manufacturer__c = 'test manufacturer';
			discountList[1].Manufacturer__c = 'test manufacturer';
			discountList[2].Manufacturer__c = 'test manufacturer';

			insert discountList;

			// access Business Hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};
			countryMappingList[0].MinDiscountAS__c					= 1;
			countryMappingList[0].MinDiscountBS__c					= 1;
			countryMappingList[0].DiscountException__c				= 'FDP';

			countryMappingList[1].MinDiscountAS__c					= 1;
			countryMappingList[1].MinDiscountBS__c					= 1;
			countryMappingList[1].UseAdvancedDiscountManagement__c	= true;
			
			insert countryMappingList;
		}
	}

	@isTest static void constructorFR_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
				// controller.getPercentageFormatString();
				Integer rowSpan = controller.mapIdOrderLineWrapper.get(orderLineList[0].Id).rowSpan;
				rowSpan = controller.mapIdOrderLineWrapper.get(orderLineList[1].Id).rowSpan;
				rowSpan = controller.mapIdOrderLineWrapper.get(orderLineList[3].Id).rowSpan;
			Test.stopTest();

			System.assertEquals(true, controller.isQuotation);
			System.assertEquals(false, controller.isEditable);
		}
	}

	@isTest static void constructorES_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			System.assertEquals(true, controller.isQuotation);
			System.assertEquals(false, controller.isEditable);
		}
	}
@isTest static void constructorES_FB_TEST()
  {
    System.runAs(adminUser)
    {
      Test.setCurrentPage(Page.VFP04_POManageOrderLines);

      PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
                              Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
                           FROM  PurchaseOrder__c
                           WHERE  Id =: purchaseOrderList[1].Id];

      Test.startTest();
        VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
      Test.stopTest();
      Map<Id, VFC04_POManageOrderLines.OrderLineWrapper> mapIdOrderLineWrapper1= new Map<Id, VFC04_POManageOrderLines.OrderLineWrapper>();
      mapIdOrderLineWrapper1.put(orderLineList[1].Id,new VFC04_POManageOrderLines.OrderLineWrapper(orderLineList[1]));

      List<VFC04_POManageOrderLines.BundleItemWrapper> bundleItemList1=new List<VFC04_POManageOrderLines.BundleItemWrapper>();
      bundleItemList1.add(new VFC04_POManageOrderLines.BundleItemWrapper(orderLineList[1]));
      mapIdOrderLineWrapper1.get(orderLineList[1].Id).bundleItemList=bundleItemList1;

      controller.mapIdOrderLineWrapper=mapIdOrderLineWrapper1;
      controller.wrapperId=orderLineList[1].Id;
      controller.wrapperIdFamily='XXX';
      controller.setWrapperBrand();
      controller.bundleItemIndexChanged=0;
      controller.updateSpecificOrderLineBundleFB();

      System.assertEquals(true, controller.isQuotation);
      System.assertEquals(false, controller.isEditable);
    }
  }
	@isTest static void constructorFRQuotationWithDifferentPOStatus_TEST()
	{
		System.runAs(adminUser)
		{
			purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_ISSUED;

			update purchaseOrderList[0];

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			System.assertEquals(false, controller.isPageReadOnly);
			System.assertEquals(true, controller.isQuotation);

		}
	}

	@isTest static void constructorWithNoCountryMapping_TEST()
	{
		System.runAs(adminUser)
		{
			// removing the entries of the custom settings to produce and an apex error message
			delete countryMappingList;

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
		}
	}

	@isTest static void setEditMode_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				controller.setEditMode();
			Test.stopTest();

			System.assertEquals(true, controller.isEditable);
		}
	}

	@isTest static void AddANewLine_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c, Assessment__c, Name, Rebate__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c, PrerequisiteOrder__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				controller.setEditMode();
				controller.addNewPlOlOff();
				controller.listnewOrderline[0].finalOrderLine.PartNumber__c = '33334444';
                controller.listnewOrderline[0].finalOrderLine.Description__c = '33334444';
                controller.listnewOrderline[0].finalOrderLine.Quantity__c = 1;
                controller.listnewOrderline[0].finalOrderLine.CataloguePrice__c = 12.5;
                controller.listnewOrderline[0].finalOrderLine.Type__c = 'A';
                controller.listnewOrderline[0].finalOrderLine.ExpectedDeliveryDuration__c = '2';
                controller.listnewOrderline[0].finalOrderLine.Id = null;
                controller.listnewOrderline[0].finalOrderLine.AXADiscount__c =5;
                controller.listnewOrderline[0].finalOrderLine.BodyShopDiscount__c=5;
				controller.saveAllChanges();
			Test.stopTest();

			System.assertEquals(false, controller.isEditable);
		}
	}   

	@isTest static void setWrapperSuppliable_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			// taking id of the original for the bundle so as to make maximum coverage
			controller.wrapperId				= orderLineList[3].Id;

			Test.startTest();
				controller.setWrapperSuppliable();
			Test.stopTest();

			VFC04_POManageOrderLines.OrderLineWrapper modifiedWrapper = controller.mapIdOrderLineWrapper.get(orderLineList[3].Id);
			System.assertEquals('YES', modifiedWrapper.originalOrderLine.Suppliable__c);
		}
	}

	@isTest static void setWrapperUnsuppliable_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			// taking id of the original for the bundle so as to make maximum coverage
			controller.wrapperId				= orderLineList[3].Id;

			Test.startTest();
				controller.setWrapperUnsuppliable();
			Test.stopTest();

			VFC04_POManageOrderLines.OrderLineWrapper modifiedWrapper = controller.mapIdOrderLineWrapper.get(orderLineList[3].Id);
			System.assertEquals('NO', modifiedWrapper.originalOrderLine.Suppliable__c);
		}
	}

	@isTest static void removeAlternative_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			// taking id of the original for the bundle so as to make maximum coverage
			controller.wrapperId				= orderLineList[1].Id;

			Test.startTest();
				controller.removeCurrentLine();
				controller.saveAllChanges();
			Test.stopTest();

			VFC04_POManageOrderLines.OrderLineWrapper modifiedWrapper = controller.mapIdOrderLineWrapper.get(orderLineList[1].Id);
			System.assertEquals(true, modifiedWrapper.isFinalOriginal);
		}
	}

	@isTest static void removeBundle_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			// taking id of the original for the bundle so as to make maximum coverage
			controller.wrapperId				= orderLineList[3].Id;
			controller.bundleItemIndexToRemove	= 0;

			Test.startTest();
				controller.removeCurrentLine();
			Test.stopTest();

			VFC04_POManageOrderLines.OrderLineWrapper modifiedWrapper = controller.mapIdOrderLineWrapper.get(orderLineList[3].Id);
			System.assertEquals(true, modifiedWrapper.isFinalAltenative);
		}
	}

	@isTest static void addOrderLine_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			// taking id of the original order line only so as to make maximum coverage
			controller.wrapperId				= orderLineList[0].Id;

			Test.startTest();
				controller.addNewOrderLine();
				// Performing a remove (for alternative) so that the original 
				// order line becomes a final order line
				controller.removeCurrentLine();
				controller.addNewOrderLine();
				controller.addNewOrderLine();
				controller.addNewOrderLine();
			Test.stopTest();

			VFC04_POManageOrderLines.OrderLineWrapper modifiedWrapper = controller.mapIdOrderLineWrapper.get(orderLineList[0].Id);
			System.assertEquals(true, modifiedWrapper.isBundle);
		}
	}

	@isTest static void setAllSuppliableAndDeliveryFR_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			VFC04_POManageOrderLines.OrderLineWrapper modifiedWrapper = controller.mapIdOrderLineWrapper.get(orderLineList[0].Id);
			modifiedWrapper.originalOrderLine.Suppliable__c			  = 'NO';
			
			controller.wrapperId									  = orderLineList[1].Id;
			Test.startTest();
				controller.saveAllChanges();
				controller.setAllSuppliableAndDelivery();
				controller.addNewOrderLine();
				controller.setAllSuppliableAndDelivery();
				controller.addNewOrderLine();
				controller.setAllSuppliableAndDelivery();
			Test.stopTest();

			VFC04_POManageOrderLines.OrderLineWrapper updatedWrapper = controller.mapIdOrderLineWrapper.get(orderLineList[1].Id);

			System.assertEquals('YES', updatedWrapper.originalOrderLine.Suppliable__c);
		}
	}
	
	@isTest static void validatePurchaseOrder_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				controller.validatePurchaseOrder();
			Test.stopTest();

			System.assertEquals(true, controller.canRefresh);
		}
	}

	@isTest static void validatePurchaseOrderWithError_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			//delete salesOrderList;

			VFC04_POManageOrderLines controller		= new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			controller.currentPurchaseOrder.Id		= 'a0K000101010101';

			Test.startTest();
				controller.validatePurchaseOrder();
			Test.stopTest();

			System.assertEquals(true, controller.canRefresh);
			//System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
		}
	}

	@isTest static void saveAllChanges_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			controller.setEditMode();

			Test.startTest();
				controller.saveAllChanges();
			Test.stopTest();

			System.assertEquals(false, controller.isEditable);
		}
	}

	@isTest static void saveAllChangesASError_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			controller.mapIdOrderLineWrapper.get(orderLineList[0].Id).originalOrderLine.AXADiscount__c		= 0;
			controller.setAllSuppliableAndDelivery();

			Test.startTest();
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[0].Id).originalOrderLine.AXADiscount__c	= 10;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[1].Id).finalOrderLine.AXADiscount__c		= 10;
				controller.saveAllChanges();

				for (VFC04_POManageOrderLines.BundleItemWrapper bundleWrapper : controller.mapIdOrderLineWrapper.get(orderLineList[3].Id).bundleItemList)
				{
					bundleWrapper.bundleItem.AXADiscount__c = 10;
				}
				controller.saveAllChanges();
			Test.stopTest();

			System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
		}
	}

	@isTest static void saveAllChangesBSError_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			
			controller.mapIdOrderLineWrapper.get(orderLineList[0].Id).originalOrderLine.BodyShopDiscount__c		= 0;
			controller.setAllSuppliableAndDelivery();

			Test.startTest();
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[0].Id).originalOrderLine.BodyShopDiscount__c = 10;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[1].Id).finalOrderLine.BodyShopDiscount__c	= 10;
				controller.saveAllChanges();

				for (VFC04_POManageOrderLines.BundleItemWrapper bundleWrapper : controller.mapIdOrderLineWrapper.get(orderLineList[3].Id).bundleItemList)
				{
					bundleWrapper.bundleItem.BodyShopDiscount__c = 10;
				}
				controller.saveAllChanges();
			Test.stopTest();

			System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
		}
	}

	@isTest static void saveAllChangesWithNewBundle_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			controller.wrapperId				= orderLineList[1].Id;

			controller.setEditMode();
			controller.addNewOrderLine();

			Test.startTest();
				controller.saveAllChanges();
			Test.stopTest();

			System.assertEquals(false, controller.isEditable);
		}
	}

	@isTest static void onSelectDistributorCodeES_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				// for original order line only
				controller.wrapperId																					= orderLineList[8].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[8].Id).originalOrderLine.Discount__c					= discountList[1].Id;
				controller.onSelectDistributorCode();

				controller.mapIdOrderLineWrapper.get(orderLineList[8].Id).originalOrderLine.Discount__c					= null;
				controller.onSelectDistributorCode();

				// for alternative order line
				controller.wrapperId																					= orderLineList[10].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.Discount__c					= discountList[1].Id;
				controller.onSelectDistributorCode();

				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.Discount__c					= null;
				controller.onSelectDistributorCode();

				// for bundle order line
				controller.wrapperId																					= orderLineList[12].Id;
				controller.bundleItemIndexChanged																		= 0;
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.Discount__c		= discountList[1].Id;
				controller.onSelectDistributorCode();

				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.Discount__c		= null;
				controller.onSelectDistributorCode();
			Test.stopTest();

			System.assertEquals(0.00, controller.mapIdOrderLineWrapper.get(orderLineList[8].Id).originalOrderLine.AXADiscount__c);
			System.assertEquals(0.00, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.AXADiscount__c);
			System.assertEquals(0.00, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.AXADiscount__c);
		}
	}

	@isTest static void updateSpecificOrderLineWithDiscountES_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				// NOTE: Only alternative and bundle item can have their part type and manufacturer changed
				
				// for alternative order line
				controller.wrapperId																					= orderLineList[10].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.Type__c						= 'B';
				controller.updateSpecificOrderLine();

				// for bundle order line
				controller.wrapperId																					= orderLineList[12].Id;
				controller.bundleItemIndexChanged																		= 0;
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.Type__c			= 'B';
				controller.updateSpecificOrderLine();
			Test.stopTest();

			// None + 1 discount
			System.assertEquals(2, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(2, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void updateSpecificOrderLineWithoutDiscountES_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				// NOTE: Only alternative and bundle item can have their part type and manufacturer changed

				controller.wrapperId																					= orderLineList[8].Id;
				controller.updateSpecificOrderLine();
				
				// for alternative order line
				controller.wrapperId																					= orderLineList[10].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.Manufacturer__c				= 'ABC Manufacturer';
				controller.updateSpecificOrderLine();

				// for bundle order line
				controller.wrapperId																					= orderLineList[12].Id;
				controller.bundleItemIndexChanged																		= 0;
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.Manufacturer__c	= 'ABC Manufacturer';
				controller.updateSpecificOrderLine();
			Test.stopTest();

			// None Option
			System.assertEquals(1, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(1, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void constructorNonQuotationFR_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[2].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
				Boolean isDelivered = controller.mapIdOrderLineWrapper.get(orderLineList[17].Id).isFinalAlternativeDelivered;
				isDelivered = controller.mapIdOrderLineWrapper.get(orderLineList[19].Id).bundleItemList[0].isBundleDelivered;
				isDelivered = controller.mapIdOrderLineWrapper.get(orderLineList[23].Id).isFinalOriginalDelivered;
			Test.stopTest();

			System.assertEquals(false, controller.isQuotation);
			System.assertEquals(false, controller.isEditable);
		}
	}

	@isTest static void saveAllChangesNonQuotationFR_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[2].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				controller.mapIdOrderLineWrapper.get(orderLineList[16].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[16].Id).finalOrderLine.DeliveryStatus__c		= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
				controller.mapIdOrderLineWrapper.get(orderLineList[17].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[17].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
				controller.mapIdOrderLineWrapper.get(orderLineList[19].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[19].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
				controller.mapIdOrderLineWrapper.get(orderLineList[23].Id).finalOrderLine.DeliveryStatus__c		= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();
			Test.stopTest();

			List<Offer__c> updatedOffers = [SELECT	Id
											FROM	Offer__c
											WHERE	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_DELAYED];

			System.assertEquals(1, updatedOffers.size());
		}
	}

	@isTest static void setDistributorCodeForWholeWrapperWithGlobalDiscountES_TEST()
	{
		System.runAs(adminUser)
		{
			// Inserting global discounts
			List<Discount__c> globalDiscounts = new List<Discount__c>
			{
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 40.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'B', 'Citroen')
			};

			insert globalDiscounts;

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			// None + 2 normal discount + 2 global discount
			System.assertEquals(5, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(5, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void setDistributorCodeForWholeWrapperWithGlobalDiscountOnlyES_TEST()
	{
		System.runAs(adminUser)
		{
			// deleting the existing discounts
			delete discountList;

			// Inserting global discounts
			List<Discount__c> globalDiscounts = new List<Discount__c>
			{
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 40.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'B', 'Citroen')
			};

			insert globalDiscounts;

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			// None + 2 global discount
			System.assertEquals(3, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(3, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void setDistributorCodeForWholeWrapperWithoutDiscountsES_TEST()
	{
		System.runAs(adminUser)
		{
			// deleting the existing discounts
			delete discountList;

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			Test.startTest();
				VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			Test.stopTest();

			// None + 2 global discount
			System.assertEquals(1, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(1, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void updateSpecificOrderLineWithGlobalDiscountES_TEST()
	{
		System.runAs(adminUser)
		{
			// Inserting global discounts
			List<Discount__c> globalDiscounts = new List<Discount__c>
			{
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 40.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'B', 'Citroen')
			};

			insert globalDiscounts;

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				// NOTE: Only alternative and bundle item can have their part type and manufacturer changed
				
				// for alternative order line
				controller.wrapperId																					= orderLineList[10].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.Type__c						= 'B';
				controller.updateSpecificOrderLine();

				// for bundle order line
				controller.wrapperId																					= orderLineList[12].Id;
				controller.bundleItemIndexChanged																		= 0;
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.Type__c			= 'B';
				controller.updateSpecificOrderLine();
			Test.stopTest();

			// None + 1 normal discount + 1 Global Discount
			System.assertEquals(3, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(3, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void updateSpecificOrderLineWithGlobalDiscountOnlyES_TEST()
	{
		System.runAs(adminUser)
		{
			// deleting the existing discounts
			delete discountList;

			// Inserting global discounts
			List<Discount__c> globalDiscounts = new List<Discount__c>
			{
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 40.0, 'A', 'Citroen'),
				TestFactory.createDistributorDiscount(accountList[3], 20.0, 'B', 'Citroen')
			};

			insert globalDiscounts;

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				// NOTE: Only alternative and bundle item can have their part type and manufacturer changed
				
				// for alternative order line
				controller.wrapperId																					= orderLineList[10].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.Type__c						= 'B';
				controller.updateSpecificOrderLine();

				// for bundle order line
				controller.wrapperId																					= orderLineList[12].Id;
				controller.bundleItemIndexChanged																		= 0;
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.Type__c			= 'B';
				controller.updateSpecificOrderLine();
			Test.stopTest();

			// None + 1 Global Discount
			System.assertEquals(2, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(2, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void updateSpecificOrderLineWithoutAnyDiscountES_TEST()
	{
		System.runAs(adminUser)
		{
			// deleting the existing discounts
			delete discountList;

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				// NOTE: Only alternative and bundle item can have their part type and manufacturer changed
				
				// for alternative order line
				controller.wrapperId																					= orderLineList[10].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.Type__c						= 'B';
				controller.updateSpecificOrderLine();

				// for bundle order line
				controller.wrapperId																					= orderLineList[12].Id;
				controller.bundleItemIndexChanged																		= 0;
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.Type__c			= 'B';
				controller.updateSpecificOrderLine();
			Test.stopTest();

			// None 
			System.assertEquals(1, controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLineDistributorCodeOptions.size());
			System.assertEquals(1, controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].distributorCodeOptions.size());
		}
	}

	@isTest static void saveAllChangesNonQuotationFRInDelivery_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[2].Id];

			currentPurchaseOrder.SLADeliveryEntryDate__c = System.now();

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				controller.mapIdOrderLineWrapper.get(orderLineList[16].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[16].Id).finalOrderLine.DeliveryStatus__c		= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
				controller.mapIdOrderLineWrapper.get(orderLineList[17].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[17].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
				controller.mapIdOrderLineWrapper.get(orderLineList[19].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();

				controller.mapIdOrderLineWrapper.get(orderLineList[19].Id).originalOrderLine.DeliveryStatus__c	= ASPISConstants.ORD_LINE_STATUS_INDELIVERY;
				controller.mapIdOrderLineWrapper.get(orderLineList[23].Id).finalOrderLine.DeliveryStatus__c		= ASPISConstants.ORD_LINE_STATUS_DELAYED;
				controller.saveAllChanges();
			Test.stopTest();

			List<Offer__c> updatedOffers = [SELECT	Id
											FROM	Offer__c
											WHERE	DeliveryStatus__c =: ASPISConstants.OFFER_STATUS_DELAYED];

			System.assertEquals(1, updatedOffers.size());
		}
	}

	@isTest static void saveAllChangesInDeliveryWithoutDiscountManagementWithPORectification_TEST()
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c, PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[2].Id];

			currentPurchaseOrder.SLADeliveryEntryDate__c = System.now();

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				controller.mapIdOrderLineWrapper.get(orderLineList[17].Id).finalOrderLine.ExpectedDeliveryDuration__c		= '4';
				controller.mapIdOrderLineWrapper.get(orderLineList[19].Id).bundleItemList[0].bundleItem.CataloguePrice__c	= 10000;
				controller.mapIdOrderLineWrapper.get(orderLineList[19].Id).bundleItemList[1].bundleItem.AXADiscount__c		= 50;
				controller.mapIdOrderLineWrapper.get(orderLineList[23].Id).finalOrderLine.BodyShopDiscount__c				= 50;
				controller.saveAllChanges();
			Test.stopTest();

			List<Case__c> insertedCase = [	SELECT	Id
											FROM	Case__c
											WHERE	Purchase_order__c =: purchaseOrderList[2].Id
											AND		TECH_AutomaticCreationFromProcess__c = '-PO-OrderLineRectification'];

			System.assertEquals(1, insertedCase.size());
		}
	}

	@isTest static void saveAllChangesInDeliveryWithDiscountManagementWithPORectification_TEST()
	{
		System.runAs(adminUser)
		{
			purchaseOrderList[1].Status__c = ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED;

			update purchaseOrderList[1];

			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c,  PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[1].Id];

			currentPurchaseOrder.SLADeliveryEntryDate__c = System.now();

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

			Test.startTest();
				controller.mapIdOrderLineWrapper.get(orderLineList[10].Id).finalOrderLine.ExpectedDeliveryDuration__c		= '4';
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[0].bundleItem.CataloguePrice__c	= 10000;
				controller.mapIdOrderLineWrapper.get(orderLineList[12].Id).bundleItemList[1].bundleItem.Discount__c			= discountList[1].Id;
				controller.mapIdOrderLineWrapper.get(orderLineList[15].Id).finalOrderLine.TECH_ExtraAS__c					= 50;
				controller.saveAllChanges();
			Test.stopTest();

			List<Case__c> insertedCase = [	SELECT	Id
											FROM	Case__c
											WHERE	Purchase_order__c =: purchaseOrderList[1].Id
											AND		TECH_AutomaticCreationFromProcess__c = '-PO-OrderLineRectification'];

			System.assertEquals(1, insertedCase.size());
		}
	}

	@isTest static void orderLinesWithAdditionalDiscountAmount()
	{
		System.runAs(adminUser)
		{
			orderLineList[0].AdditionalDiscountAmount__c = 100;
			orderLineList[1].AdditionalDiscountAmount__c = 100;
			orderLineList[2].AdditionalDiscountAmount__c = 100;
			orderLineList[3].AdditionalDiscountAmount__c = 100;
			orderLineList[4].AdditionalDiscountAmount__c = 100;
			orderLineList[5].AdditionalDiscountAmount__c = 100;
			orderLineList[6].AdditionalDiscountAmount__c = 100;
			orderLineList[7].AdditionalDiscountAmount__c = 100;

			update orderLineList;
			
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Brand__c,
															Distributor__c, RecordTypeId, SLADeliveryEntryDate__c,  PurchaseOrder__c.Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[0].Id];

			VFC04_POManageOrderLines controller = new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			controller.setEditMode();

			Test.startTest();
				controller.saveAllChanges();
			Test.stopTest();

			System.assertEquals(false, controller.isEditable);
		}
	}

	@isTest static void OrderConfirmationButton_Test() {

		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP04_POManageOrderLines);

			PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c,RecordTypeId, Distributor__r.AdditionalPartButton__c
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[3].Id];

			

			VFC04_POManageOrderLines controller		= new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));
			
			controller.currentPurchaseOrder.OrderConfirmationErrorMe__c = 'Error';
			controller.currentPurchaseOrder.OrderConfirmationDate__c =System.now();

			Test.startTest();
				controller.callsendOrderConfirmation();
			Test.stopTest();

			

		}

		
	}

	@isTest static void OnLoad_test(){
		Test.setCurrentPage(Page.VFP04_POManageOrderLines);

		PurchaseOrder__c currentPurchaseOrder = [SELECT Id, Status__c, Reason__c, TECH_AssessmentCountryCode__c, Distributor__r.AdditionalPartButton__c,RecordTypeId
													 FROM	PurchaseOrder__c
													 WHERE	Id =: purchaseOrderList[3].Id];

		VFC04_POManageOrderLines controller		= new VFC04_POManageOrderLines(new ApexPages.StandardController(currentPurchaseOrder));

		controller.currentPurchaseOrder.OrderConfirmationErrorMe__c = 'Error';
		controller.currentPurchaseOrder.OrderConfirmationDate__c =System.now();
		

		Test.startTest();
			controller.onLoad();
		Test.stopTest();

	}
}