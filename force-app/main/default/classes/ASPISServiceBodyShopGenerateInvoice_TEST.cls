/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISServiceBodyShopGenerateInvoice_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISServiceBodyShopGenerateInvoice_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 20-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer             Date        Description
  -- ----------            ----------  -----------------------
  -- Kevan (sc)            22/05/2015  Original Version
  -- Bhavish (sc)          28/05/2015  Increased coverage to 100%, Added Assert
  -- Dourga Unmole         24/07/2015  case C-001234
  -- Welsa chan            10/10/2019  Spain R4
 **********************************************************************
*/
@isTest
public class ASPISServiceBodyShopGenerateInvoice_TEST 
{
	static List<User> users;
	static List<Account> accList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static List<Offer__c> offerList;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

	static
	{
		users = new List<User>();
		users.add( TestFactory.createUser('adminUser'));

		insert users;

		System.runAs(users[0])
		{

			// access Business Hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			countryMappingList[1].NeedInvoiceDetail__c = true;
			insert countryMappingList;

			// Generating the account
			accList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distrubutor_1', 'FR'),
				TestFactory.createAccountDistributor('Distrubutor_2', 'ES'),
				TestFactory.createAccountPayment('Payment_1', 'FR'),
				TestFactory.createAccountPayment('Payment_2', 'ES')
				
			};

			insert accList;

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_1', accList[0]),
				TestFactory.createAssessment('Assessment_1', accList[1])
			};

			assessmentList[1].TECH_EntityCountryCode__c = 'ES';

			insert assessmentList;

			// Generating the salesOrder
			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
				TestFactory.createSalesOrder(assessmentList[1], accList[1], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),

				TestFactory.createSalesOrder(assessmentList[0], accList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
				TestFactory.createSalesOrder(assessmentList[1], accList[1], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			// Generating Purchase Order
			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accList[0], accList[2], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accList[0], accList[2], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),

				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accList[1], accList[3], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accList[1], accList[3], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),

				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[2], accList[0], accList[2], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),

				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[3], accList[1], accList[3], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[3], accList[1], accList[3], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY)

			};

			insert purchaseOrderList;

			// Generating Order Line
			orderLineList = new List<OrderLine__c>
			{
				// FR and Purchase Order 1 and 2
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),

				// ES and Purchase Order 3 and 4
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[2], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[3], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),

				// FR and Purchase Order 5
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[4], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),

				// ES and Purchase Order 6
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[5], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[5], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[5], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[5], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[6], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			// Credit Note
			orderLineList[1].AdditionalDiscountAmount__c	= 10;
			orderLineList[1].TECH_ToBeProcessed__c 			= true;
			orderLineList[2].AdditionalDiscountAmount__c	= 10;
			orderLineList[2].TECH_ToBeProcessed__c 			= true;
			
			orderLineList[9].AdditionalDiscountAmount__c	= 10;
			orderLineList[9].TECH_ToBeProcessed__c 			= true;
			orderLineList[10].AdditionalDiscountAmount__c	= 10;
			orderLineList[10].TECH_ToBeProcessed__c 		= true;

			// Invoice
			orderLineList[3].AdditionalDiscountAmount__c	= -10;
			orderLineList[3].TECH_ToBeProcessed__c 		= true;
			orderLineList[4].AdditionalDiscountAmount__c	= -10;
			orderLineList[4].TECH_ToBeProcessed__c 		= true;

			orderLineList[11].AdditionalDiscountAmount__c 	= -10;
			orderLineList[11].TECH_ToBeProcessed__c 		= true;
			orderLineList[12].AdditionalDiscountAmount__c 	= -10;
			orderLineList[12].TECH_ToBeProcessed__c 		= true;

			// For PO 5
			orderLineList[14].BodyShopDiscount__c	 		= 10;
			orderLineList[14].TECH_ToBeProcessed__c 		= true;
			orderLineList[15].BodyShopDiscount__c	 		= 10;
			orderLineList[15].AdditionalDiscountAmount__c 	= 10;
			orderLineList[15].TECH_ToBeProcessed__c 		= true;
			orderLineList[16].BodyShopDiscount__c	 		= 10;
			orderLineList[16].AdditionalDiscountAmount__c 	= -10;
			orderLineList[16].TECH_ToBeProcessed__c 		= true;

			// For PO 6
			orderLineList[17].BodyShopDiscount__c	 		= 10;
			orderLineList[18].BodyShopDiscount__c	 		= 10;
			orderLineList[18].AdditionalDiscountAmount__c 	= 10;
			orderLineList[18].TECH_ToBeProcessed__c 		= true;
			orderLineList[19].BodyShopDiscount__c	 		= 10;
			orderLineList[19].AdditionalDiscountAmount__c 	= -10;
			orderLineList[19].TECH_ToBeProcessed__c 		= true;
			orderLineList[20].BodyShopDiscount__c	 		= 10;
			orderLineList[20].AdditionalDiscountAmount__c 	= -10;
			orderLineList[20].TECH_ToBeProcessed__c 		= true;
			orderLineList[21].BodyShopDiscount__c	 		= 10;

			insert orderLineList;

			offerList = new List<Offer__c>
			{
				// Sales order 1 FR
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[2], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[3], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[4], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[5], salesOrderList[0], ASPISConstants.OFFER_STATUS_CANCELED),
				TestFactory.createOfferLine(orderLineList[6], salesOrderList[0], ASPISConstants.OFFER_STATUS_RETURNED),

				// Sales order 2 ES
				TestFactory.createOfferLine(orderLineList[7], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[8], salesOrderList[1], ASPISConstants.OFFER_STATUS_CANCELED),
				TestFactory.createOfferLine(orderLineList[9], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[10], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[11], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[12], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[13], salesOrderList[1], ASPISConstants.OFFER_STATUS_RETURNED),

				// Sales Order 3 FR
				TestFactory.createOfferLine(orderLineList[14], salesOrderList[2], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[15], salesOrderList[2], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[16], salesOrderList[2], ASPISConstants.OFFER_STATUS_DELIVERED),

				// Sales Order 4 ES
				TestFactory.createOfferLine(orderLineList[17], salesOrderList[3], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[18], salesOrderList[3], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[19], salesOrderList[3], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[20], salesOrderList[3], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[21], salesOrderList[3], ASPISConstants.OFFER_STATUS_CANCELED)
			};

			insert offerList;
		}
	}

	@isTest static void generateInvoiceForFR()
	{
		System.runAs(users[0])
		{
			ASPISServiceBodyShopGenerateInvoice invoiceGenerator = new ASPISServiceBodyShopGenerateInvoice();

			// Should retrieve the formula fields
			map <Id,Prerequisiteorder__c> salesOrder = new map <Id,Prerequisiteorder__c>([SELECT Id, Name, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c 
											   FROM	  Prerequisiteorder__c 
											   WHERE  Id =: salesOrderList[0].Id]);

			for(Prerequisiteorder__c so : salesOrder.values()){
				so.status__c = 'PREORDERCONFIRMED';
			}
			Test.startTest();
				//invoiceGenerator.executeProcess(salesOrder);
				update salesOrder.values();
			Test.stopTest();

			List<Invoice__c> invoiceInserted = [SELECT Id
												FROM Invoice__c
												WHERE PrerequisiteOrder__c =: salesOrderList[0].Id];

			System.assertEquals(3, invoiceInserted.size());
		}
	}

	@isTest static void generateInvoiceForES()
	{
		System.runAs(users[0])
		{
			ASPISServiceBodyShopGenerateInvoice invoiceGenerator = new ASPISServiceBodyShopGenerateInvoice();

			// Should retrieve the formula fields
			map <Id,Prerequisiteorder__c> salesOrder = new map <Id,Prerequisiteorder__c>([SELECT Id, Name, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c 
											   FROM	  Prerequisiteorder__c 
											   WHERE  Id =: salesOrderList[1].Id]);

			for(Prerequisiteorder__c so : salesOrder.values()){
				so.status__c = 'PREORDERCONFIRMED';
			}
			Test.startTest();
				//invoiceGenerator.executeProcess(salesOrder);
				update salesOrder.values();
			Test.stopTest();

			List<Invoice__c> invoiceInserted = [SELECT Id
												FROM Invoice__c
												WHERE PrerequisiteOrder__c =: salesOrderList[1].Id];

			// 3 Parent Invoice
			// For Main Invoice -> 2 Child (Invoice + Credit Note) (2 PO)
			// For Parent Invoice -> 2 Child (Invoice + Credit Note) (2 PO)
			// For Parent Credit Note -> 2 Child (Invoice + Credit Note) (2 PO)
			// Total = 2 + 2 + 2 + 3 = 9
			System.assertEquals(9, invoiceInserted.size());
		}
	}

	@isTest static void generateInvoiceBulk()
	{
		System.runAs(users[0])
		{
			ASPISServiceBodyShopGenerateInvoice invoiceGenerator = new ASPISServiceBodyShopGenerateInvoice();

			// Should retrieve the formula fields
			map <Id,Prerequisiteorder__c> salesOrder = new map <Id,Prerequisiteorder__c>([SELECT Id, Name, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c 
											   FROM	  Prerequisiteorder__c 
											   WHERE  Id =: salesOrderList]);

			for(Prerequisiteorder__c so : salesOrder.values()){
				so.status__c = 'PREORDERCONFIRMED';
			}
			Test.startTest();
				//invoiceGenerator.executeProcess(salesOrder);
				update salesOrder.values();
			Test.stopTest();

			List<Invoice__c> invoiceInserted = [SELECT Id
												FROM Invoice__c
												WHERE PrerequisiteOrder__c =: salesOrderList];

			System.assertEquals(23, invoiceInserted.size());
		}
	}

	@isTest static void generateInvoiceForFRWithPriceTest()
	{
		System.runAs(users[0])
		{
			ASPISServiceBodyShopGenerateInvoice invoiceGenerator = new ASPISServiceBodyShopGenerateInvoice();

			// Should retrieve the formula fields
			map <Id,Prerequisiteorder__c> salesOrder = new map <Id,Prerequisiteorder__c>([SELECT Id, Name, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c 
											   FROM	  Prerequisiteorder__c 
											   WHERE  Id =: salesOrderList[2].Id]);

			for(Prerequisiteorder__c so : salesOrder.values()){
				so.status__c = 'PREORDERCONFIRMED';
			}
			Test.startTest();
				//invoiceGenerator.executeProcess(salesOrder);
				update salesOrder.values();
			Test.stopTest();

			List<Invoice__c> invoiceInserted = [SELECT Id, TechOfferIds__c, TotalGrossAmount__c, TotaldiscountAmount__c, TotalNet__c
												FROM Invoice__c
												WHERE PrerequisiteOrder__c =: salesOrderList[2].Id];

			System.assertEquals(3, invoiceInserted.size());

			//WCH 10/10/2019 
			List<String> lstOffers1 = (offerList[14].Id + '-' + offerList[15].Id + '-' + offerList[16].Id).split('-');
			List<String> lstTechOfferIds = (invoiceInserted[0].TechOfferIds__c).split('-');
			lstOffers1.sort();
			lstTechOfferIds.sort();

			// Main Invoice
			System.assertEquals(lstTechOfferIds, lstOffers1);
			// 900 + 900 + 900 = 2700
			//System.assertEquals(invoiceInserted[0].TotalGrossAmount__c, 3000);
			//System.assertEquals(invoiceInserted[0].TotaldiscountAmount__c, 300);
			//System.assertEquals(invoiceInserted[0].TotalNet__c, 2700);
			
			//// Credit Note
			//System.assertEquals(invoiceInserted[1].TechOfferIds__c, offerList[15].Id);
			//// Credit Note of Additional Discount Amount
			//System.assertEquals(invoiceInserted[1].TotalNet__c, 10);

			//// Invoice Note
			//System.assertEquals(invoiceInserted[2].TechOfferIds__c, offerList[16].Id);
			//// Invoice of Additional Discount Amount
			//System.assertEquals(invoiceInserted[2].TotalNet__c, 10);
			
		}
	}

	@isTest static void generateInvoiceForESWithPriceTest()
	{
		System.runAs(users[0])
		{
			ASPISServiceBodyShopGenerateInvoice invoiceGenerator = new ASPISServiceBodyShopGenerateInvoice();

			// Should retrieve the formula fields
			map <Id,Prerequisiteorder__c> salesOrder = new map <Id,Prerequisiteorder__c>([SELECT Id, Name, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c 
											   FROM	  Prerequisiteorder__c 
											   WHERE  Id =: salesOrderList[3].Id]);

			for(Prerequisiteorder__c so : salesOrder.values()){
				so.status__c = 'PREORDERCONFIRMED';
			}
			Test.startTest();
				//invoiceGenerator.executeProcess(salesOrder);
				update salesOrder.values();
			Test.stopTest();

			List<Invoice__c> invoiceInserted = [SELECT Id, TechOfferIds__c, TotalGrossAmount__c, TotaldiscountAmount__c, TotalNet__c
												FROM Invoice__c
												WHERE PrerequisiteOrder__c =: salesOrderList[3].Id];

			System.assertEquals(8, invoiceInserted.size());

			//WCH 10/10/2019 
			List<String> lstOffers1 = (offerList[17].Id + '-' + offerList[18].Id + '-' + offerList[19].Id + '-' + offerList[20].Id + '-' + offerList[21].Id).split('-');
			List<String> lstTechOfferIds = (invoiceInserted[0].TechOfferIds__c).split('-');
			lstOffers1.sort();
			lstTechOfferIds.sort();

			// Main Invoice
			System.assertEquals(lstOffers1, lstTechOfferIds);
			// 900 + 900 + 900 + 900 + 900 = 4500
			//System.assertEquals(5000, invoiceInserted[0].TotalGrossAmount__c);
			//System.assertEquals(500, invoiceInserted[0].TotaldiscountAmount__c);
			//System.assertEquals(4500, invoiceInserted[0].TotalNet__c);
			
			//// Parent Credit Note
			//System.assertEquals(offerList[18].Id + '-' + offerList[21].Id, invoiceInserted[1].TechOfferIds__c);
			//// 900 for canceled + 10 of the AdditionalDiscountAmount__c
			//System.assertEquals(910, invoiceInserted[1].TotalNet__c);
			
			//// Invoice Note
			//System.assertEquals(invoiceInserted[2].TechOfferIds__c, offerList[19].Id + '-' + offerList[20].Id);
			//// (10)* 2
			//System.assertEquals(20, invoiceInserted[2].TotalNet__c);
			
			//// Main Invoice will be splitted into 2 Child invoice (beacause of 2 PO)
			//// 1st PO
			//System.assertEquals(offerList[17].Id + '-' + offerList[18].Id + '-' + offerList[19].Id + '-' + offerList[20].Id, invoiceInserted[3].TechOfferIds__c);
			//System.assertEquals(4000,	invoiceInserted[3].TotalGrossAmount__c);
			//System.assertEquals(400,	invoiceInserted[3].TotaldiscountAmount__c);
			//System.assertEquals(3600,	invoiceInserted[3].TotalNet__c);
			//// 2nd PO
			//System.assertEquals(offerList[21].Id, invoiceInserted[4].TechOfferIds__c);
			//System.assertEquals(1000,	invoiceInserted[4].TotalGrossAmount__c);
			//System.assertEquals(100,	invoiceInserted[4].TotaldiscountAmount__c);
			//System.assertEquals(900,	invoiceInserted[4].TotalNet__c);

			//// Parent Credit Note will have 2 Child credit note
			//// 1st PO
			//System.assertEquals(offerList[18].Id, invoiceInserted[5].TechOfferIds__c);
			//System.assertEquals(10,	invoiceInserted[5].TotalNet__c);
			//// 2nd PO
			//System.assertEquals(offerList[21].Id, invoiceInserted[6].TechOfferIds__c);
			//System.assertEquals(900,	invoiceInserted[6].TotalNet__c);

			//// Parent Invoice will have 1 invoice as both offer belong to the same PO
			//System.assertEquals(offerList[19].Id + '-' + offerList[20].Id, invoiceInserted[7].TechOfferIds__c);
			//System.assertEquals(20,	invoiceInserted[7].TotalNet__c);
		}
	}

	@isTest static void generateInvoiceForFRWithGenerateAgain()
	{
		System.runAs(users[0])
		{
			ASPISServiceBodyShopGenerateInvoice invoiceGenerator = new ASPISServiceBodyShopGenerateInvoice();

			// Should retrieve the formula fields
			map <Id,Prerequisiteorder__c> salesOrder = new map <Id,Prerequisiteorder__c>([SELECT Id, Name, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c 
											   FROM	  Prerequisiteorder__c 
											   WHERE  Id =: salesOrderList[0].Id]);

			for(Prerequisiteorder__c so : salesOrder.values()){
				so.status__c = 'PREORDERCONFIRMED';
			}
			
			update salesOrder.values();

			ASPISServiceBodyShopGenerateInvoice.isGenerateAgainProcess = true;
			Test.startTest();
				invoiceGenerator.executeProcess(salesOrder);
			Test.stopTest();

			List<Invoice__c> invoiceInserted = [SELECT Id
												FROM Invoice__c
												WHERE PrerequisiteOrder__c =: salesOrderList[0].Id];

			System.assertEquals(6, invoiceInserted.size());
		}
	}

	@isTest static void generateInvoiceForESWithGenerateAgain()
	{
		System.runAs(users[0])
		{
			ASPISServiceBodyShopGenerateInvoice invoiceGenerator = new ASPISServiceBodyShopGenerateInvoice();

			// Should retrieve the formula fields
			map <Id,Prerequisiteorder__c> salesOrder = new map <Id,Prerequisiteorder__c>([SELECT Id, Name, Assessment__c, BodyShop__c, PaymentTerms__c, TECH_BodyshopCountryCode__c 
											   FROM	  Prerequisiteorder__c 
											   WHERE  Id =: salesOrderList[1].Id]);

			for(Prerequisiteorder__c so : salesOrder.values()){
				so.status__c = 'PREORDERCONFIRMED';
			}
			
			update salesOrder.values();

			Test.startTest();
				ASPISServiceBodyShopGenerateInvoice.isGenerateAgainProcess = true;
				invoiceGenerator.executeProcess(salesOrder);
			Test.stopTest();

			List<Invoice__c> invoiceInserted = [SELECT Id
												FROM Invoice__c
												WHERE PrerequisiteOrder__c =: salesOrderList[1].Id];

			// 3 Parent Invoice
			// For Main Invoice -> 2 Child (Invoice + Credit Note) (2 PO)
			// For Parent Invoice -> 2 Child (Invoice + Credit Note) (2 PO)
			// For Parent Credit Note -> 2 Child (Invoice + Credit Note) (2 PO)
			// Total = 2 + 2 + 2 + 3 = 9 * 2
			System.assertEquals(18, invoiceInserted.size());
		}
	}
}