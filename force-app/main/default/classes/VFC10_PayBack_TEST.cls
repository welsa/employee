/*
  ----------------------------------------------------------------------
  -- - Name          : VFC10_PayBack_TEST 
  -- - Author        : DUN 
  -- - Description   : VFC10_PayBack_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 22-APR-2016  DUN    1.0     Initial Vesrion
  ----------------------------------------------------------------------
*/
@isTest
public with sharing class VFC10_PayBack_TEST {

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
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accList[0], accList[2], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accList[0], accList[2], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),

				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accList[1], accList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accList[1], accList[3], ASPISConstants.PUR_ORDER_STATUS_INDELIVERY),

				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[2], accList[0], accList[2], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),

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
			orderLineList[3].TECH_ToBeProcessed__c 			= true;
			orderLineList[4].AdditionalDiscountAmount__c	= -10;
			orderLineList[4].TECH_ToBeProcessed__c 			= true;

			orderLineList[11].AdditionalDiscountAmount__c = -10;
			orderLineList[11].TECH_ToBeProcessed__c 			= true;
			orderLineList[12].AdditionalDiscountAmount__c = -10;
			orderLineList[12].TECH_ToBeProcessed__c 			= true;

			// For PO 5
			orderLineList[14].BodyShopDiscount__c	 = 10;
			orderLineList[15].BodyShopDiscount__c	 = 10;
			orderLineList[15].AdditionalDiscountAmount__c = 10;
			orderLineList[15].TECH_ToBeProcessed__c = true;
			orderLineList[16].BodyShopDiscount__c	 = 10;
			orderLineList[16].AdditionalDiscountAmount__c = -10;
			orderLineList[16].TECH_ToBeProcessed__c = true;

			// For PO 6
			orderLineList[17].BodyShopDiscount__c	 = 10;
			orderLineList[18].BodyShopDiscount__c	 = 10;
			orderLineList[18].AdditionalDiscountAmount__c = 10;
			orderLineList[18].TECH_ToBeProcessed__c 	= true;
			orderLineList[19].BodyShopDiscount__c	 = 10;
			orderLineList[19].AdditionalDiscountAmount__c = -10;
			orderLineList[19].TECH_ToBeProcessed__c 	= true;
			orderLineList[20].BodyShopDiscount__c	 = 10;
			orderLineList[20].AdditionalDiscountAmount__c = -10;
			orderLineList[20].TECH_ToBeProcessed__c 	= true;
			orderLineList[21].BodyShopDiscount__c	 = 10;

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

			// access Business Hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			countryMappingList[1].NeedInvoiceDetail__c = true;
			insert countryMappingList;
		}
	}

	@isTest static void VFC10_PayBack_TEST() {
		system.debug('start VFC10_PayBack_TEST');
		System.runAs(users[0]){
	    	List<Invoice__c> invoiceToUpdate = new List<Invoice__c>();
            ApexPages.StandardController sc1 = new ApexPages.StandardController(salesOrderList[0]);
            VFC10_GenerateInvoiceProcess controller = new VFC10_GenerateInvoiceProcess(sc1);
            controller.callInvoiceProcess();
	    
		    for(Invoice__c invoiceInserted:[SELECT Id FROM Invoice__c WHERE PrerequisiteOrder__c =: salesOrderList[0].Id]){
		    	invoiceInserted.Number__c = invoiceInserted.Id;
		    	invoiceToUpdate.add(invoiceInserted);
		    }

		    update invoiceToUpdate;
		    test.startTest();
				ApexPages.StandardController sc2 = new ApexPages.StandardController(salesOrderList[0]);
	            VFC10_PayBack controller2 = new VFC10_PayBack(sc2);
	            controller2.payBackProcess();
	        test.stopTest(); 
	        List<Invoice__c> invoiceInserted2 = [SELECT Id
										    FROM Invoice__c
											WHERE PrerequisiteOrder__c =: salesOrderList[0].Id];
			System.assertEquals(12, invoiceInserted2.size());
		}
	    system.debug('End VFC10_PayBack_TEST');
    }

}