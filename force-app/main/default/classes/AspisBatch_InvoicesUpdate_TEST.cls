/*
----------------------------------------------------------------------
-- - Name          : AspisBatch_InvoicesUpdate_TEST
-- - Author        : NPE
-- - Description   : Test class for the batch of AspisBatch_InvoicesUpdate
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 08-Nov-2021	NPE		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class AspisBatch_InvoicesUpdate_TEST {

    static User adminUser;
    static List <Invoice__c> lstInvoices;
    static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
    static List<Account> bodyshopList;
    static List<Account> distributorList;
    static List<Account> accountList;
    static List <id> lstIDInvoices = new List<id>();

	static List<PartList__c> partList;
	static List<OrderLine__c> orderLineList;
	static List<Offer__c> offerList;
	static List<Invoice__c> invoiceList;

    static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser){

            // Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor_2', 'ES')
			};
			accountList[0].BillingCity='Nimes';
			accountList[0].BillingCountry='France';
			accountList[0].BillingStreet='st martin de chez yvone';
			accountList[0].BillingPostalCode='12345';
			accountList[2].BillingCity='Nimes';
			accountList[2].BillingCountry='France';
			accountList[2].BillingStreet='st martin de chez yvone';
			accountList[2].BillingPostalCode='12345';
			insert accountList;	

			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR', accountList[0]),
				TestFactory.createAssessment('Assessment_ES', accountList[2])
			};

			assessmentList[0].TECH_EntityCountryCode__c = 'FR';
			assessmentList[1].TECH_EntityCountryCode__c = 'ES';

			assessmentList[0].PlateNumber2__c 			= '1234MR17';
			assessmentList[1].PlateNumber2__c 			= '4567MR17';

			assessmentList[0].Manufacturer__c 			= 'NISSAN';
			assessmentList[1].Manufacturer__c 			= 'BMW';

			insert assessmentList;

			partList = new List<PartList__c>
            {
                TestFactory.createPartList(assessmentList[0]),
                TestFactory.createPartList(assessmentList[0]),

                TestFactory.createPartList(assessmentList[1]),
                TestFactory.createPartList(assessmentList[1])
            };

            insert partList;

			salesOrderList = new List<PrerequisiteOrder__c>
            {
                TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED),
                TestFactory.createSalesOrder(assessmentList[1], accountList[2], ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
            };

            insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[2], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
			};

			purchaseOrderList[0].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();
			purchaseOrderList[1].RecordTypeId = Schema.SObjectType.PurchaseOrder__c.getRecordTypeInfosByName().get('In Delivery').getRecordTypeId();

			purchaseOrderList[0].InvoiceStatus__c = ASPISConstants.PUR_ORDER_INVOICESTATUS_VALIDATED;
			purchaseOrderList[1].InvoiceStatus__c = ASPISConstants.PUR_ORDER_INVOICESTATUS_VALIDATED;

			purchaseOrderList[0].TotalExpectedAmount__c = 1000;
			purchaseOrderList[1].TotalExpectedAmount__c = 1000;

			insert purchaseOrderList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_DELIVERED),

				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[1], ASPISConstants.ORD_LINE_STATUS_DELIVERED)
			};

			insert orderLineList;

			offerList = new List<Offer__c>
			{
				TestFactory.createOfferLine(orderLineList[0], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[1], salesOrderList[0], ASPISConstants.OFFER_STATUS_DELIVERED),

				TestFactory.createOfferLine(orderLineList[2], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED),
				TestFactory.createOfferLine(orderLineList[3], salesOrderList[1], ASPISConstants.OFFER_STATUS_DELIVERED)
			};

			insert offerList;

			invoiceList = new List<Invoice__c>
			{
				TestFactory.createBodyshopInvoice('INV-0001', 1000, ASPISConstants.INV_STATUS_PAYABLE, salesOrderList[0]),

				TestFactory.createBodyshopInvoice('INV-0002', 1000, ASPISConstants.INV_STATUS_PAYABLE, salesOrderList[1]),
				TestFactory.createBodyshopInvoice('INV-0002-A', 1000, ASPISConstants.INV_STATUS_PAYABLE, salesOrderList[1]),

				TestFactory.createBodyshopCreditNote('INV-0003', 1000, ASPISConstants.INV_STATUS_PAYABLE, salesOrderList[1]),
				TestFactory.createBodyshopCreditNote('INV-0003-A', 1000, ASPISConstants.INV_STATUS_PAYABLE, salesOrderList[1]),

				TestFactory.createBodyshopInvoice('INV-0004', 1000, ASPISConstants.INV_STATUS_PAYABLE, salesOrderList[1]),
				TestFactory.createBodyshopInvoice('INV-0004-A', 1000, ASPISConstants.INV_STATUS_PAYABLE, salesOrderList[1]),
				
				TestFactory.createDistributorInvoice('INV-0005', 1000, ASPISConstants.INV_STATUS_PAYABLE, purchaseOrderList[0]),

				TestFactory.createDistributorInvoice('INV-0006', 1000, ASPISConstants.INV_STATUS_PAYABLE, purchaseOrderList[1]),
				TestFactory.createDistributorInvoice('INV-0007', 1000, ASPISConstants.INV_STATUS_PAYABLE, purchaseOrderList[1]),
				TestFactory.createDistributorCreditNote('INV-0008', 1000, ASPISConstants.INV_STATUS_PAYABLE, purchaseOrderList[1])
			};

			// invoiceList[2].PurchaseOrder__c = purchaseOrderList[1].Id;
			// invoiceList[4].PurchaseOrder__c = purchaseOrderList[1].Id;
			// invoiceList[6].PurchaseOrder__c = purchaseOrderList[1].Id;
            //on- 0,1,2,5,6- add invoicelist[0].number and invoice reference

            invoiceList[0].Number__c = purchaseOrderList[1].Id;
			invoiceList[1].Number__c = purchaseOrderList[1].Id;
			invoiceList[2].Number__c = purchaseOrderList[1].Id;
            invoiceList[5].Number__c = purchaseOrderList[1].Id;
            invoiceList[6].Number__c = purchaseOrderList[1].Id;

            // invoiceList[3].Number__c = purchaseOrderList[1].Id;
            // invoiceList[4].Number__c = purchaseOrderList[1].Id;
            // invoiceList[7].Number__c = purchaseOrderList[1].Id;
            // invoiceList[8].Number__c = purchaseOrderList[1].Id;
            // invoiceList[9].Number__c = purchaseOrderList[1].Id;
            // invoiceList[10].Number__c = purchaseOrderList[1].Id;

            invoiceList[0].InvoiceReference__c = '044999999';
			invoiceList[1].InvoiceReference__c = '054999999';
			invoiceList[2].InvoiceReference__c = '064999999';
            invoiceList[5].InvoiceReference__c = '074999999';
            invoiceList[6].InvoiceReference__c = '084999999';

            // invoiceList[3].InvoiceReference__c = '074999999';
            // invoiceList[4].InvoiceReference__c = '084999999';
            // invoiceList[7].InvoiceReference__c = '074999999';
            // invoiceList[8].InvoiceReference__c = '084999999';
            // invoiceList[9].InvoiceReference__c = '074999999';
            // invoiceList[10].InvoiceReference__c = '084999999';
			insert invoiceList;

            if (invoiceList.size() > 0) {
                for (Integer i =0; i<= 10; i++){
                    lstIDInvoices.add(invoiceList[i].id);
    
                }
            }

        }
    }

    @isTest static void InvoicesUpdate_TEST(){
        System.runAs(adminUser){
            try{
                // Launch batch to update invoices
                //start test
                Test.startTest();
                    Database.executeBatch(new AspisBatch_InvoicesUpdate(lstIDInvoices));
                Test.stopTest();
            }
            catch (System.UnexpectedException theException){ // this exeption will not be caught because it is probably thown in a separate transaction
                System.debug(theException.getMessage());
			}

            //assert
            List<Invoice__c> lstInvoicesAssert = [SELECT id FROM Invoice__c WHERE id IN :lstIDInvoices];
            System.assertEquals(11,lstInvoicesAssert.size());
        }
    }

}