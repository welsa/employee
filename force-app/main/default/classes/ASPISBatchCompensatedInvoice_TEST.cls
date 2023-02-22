/*************************************************************************************
Class Name - ASPISBatchCompensatedInvoice_TEST
Version - 1.0
Created Date - 18 DECEMBER 2017
Function - TestClass to ASPISBatchCompensatedInvoice

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      18/12/2017  Original Version
*************************************************************************************/
@isTest
private class ASPISBatchCompensatedInvoice_TEST {
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<Invoice__c> invoiceList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderlineList;
	static list<Offer__c> offerList;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

	static{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser){
            defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			countryMappingList[1].NeedInvoiceDetail__c = true;
			insert countryMappingList;

			accountList = new List<Account>{
				TestFactory.createAccountBodyshop('BodyShop_1', 'ES'),
				TestFactory.createAccountBodyshop('BodyShop_2', 'ES'),
				TestFactory.createAccountDistributor('Distributor1', 'FR'),
				TestFactory.createAccountDistributor('Distributor2', 'ES')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>{
				TestFactory.createAssessment('Assessment1', accountList[0]),
				TestFactory.createAssessment('Assessment2', accountList[1])
			};
			assessmentList[0].TechCompensatedIsChanged__c = true;
			assessmentList[1].TechCompensatedIsChanged__c = true;

			assessmentList[1].TECH_EntityCountryCode__c = 'ES';

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
				TestFactory.createSalesOrder(assessmentList[1], accountList[1], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[2], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[2], ASPISConstants.PUR_ORDER_STATUS_ISSUED),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[1], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[1], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[1], accountList[1], accountList[3], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};
			insert purchaseOrderList;

			invoiceList = new List<Invoice__c>{
				TestFactory.createBodyshopInvoice('INV-2811A', 98, ASPISConstants.INV_STATUS_SENT, salesOrderList[0]),
				TestFactory.createBodyshopInvoice('INV-2811B', 71, ASPISConstants.INV_STATUS_PAID, salesOrderList[0]),
				TestFactory.createBodyshopCreditNote('INV-2811C', 50, ASPISConstants.INV_STATUS_SENT, salesOrderList[1]),
				TestFactory.createBodyshopCreditNote('INV-2811D', 50, ASPISConstants.INV_STATUS_PAID, salesOrderList[1])
			};
			insert invoiceList;


			//Create several orderlines.
			orderlineList = new list<OrderLine__c>{
				TestFactory.createOrderLineFinal(50,purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[0], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[1], 'INDELIVERY'),
				TestFactory.createOrderLineFinal(50,purchaseOrderList[1], 'INDELIVERY')
			};
			insert orderlineList;

			//create offers
			offerList = new list<Offer__c>{
				TestFactory.createOfferLine(orderlineList[0], salesOrderList[0], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[1], salesOrderList[0], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[2], salesOrderList[0], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[3], salesOrderList[1], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[4], salesOrderList[1], 'DELIVERED'),
				TestFactory.createOfferLine(orderlineList[5], salesOrderList[1], 'DELIVERED')
			};
			insert offerList;
		}
	}

	static testmethod void testBatchCompensatedInvoice(){
        system.runas(adminUser){

            Test.startTest();
                Database.executeBatch(new ASPISBatchCompensatedInvoice(), 200); 
            Test.stopTest();

            list<Invoice__c> listInvoices = [Select ToSendToExponens__c from Invoice__c where id =:invoiceList];

            system.assertEquals(true, listInvoices[0].ToSendToExponens__c);
            system.assertEquals(true, listInvoices[1].ToSendToExponens__c);
            system.assertEquals(true, listInvoices[2].ToSendToExponens__c);
            system.assertEquals(true, listInvoices[3].ToSendToExponens__c);
        }
    }
}