/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchSLAQuotation_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISBatchSLAQuotation_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-APR-2016  ABT    1.0     Reworked version
  -- 10-MAY-2016  ABT    1.1     Added test for scheduler
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Yudish R  		12/05/2015 	Original Version
 **********************************************************************
*/
@isTest
public class ASPISBatchSLAQuotation_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<OrderLine__c> orderLineList;
	static BusinessHours defaultHours;
	static List<SLAConfiguration__c> slaConfigurationList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountBodyshop('BodyShop_2', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_2', 'FR')
			};
			accountList[0].BillingCity='Nimes';
			accountList[0].BillingCountry='France';
			accountList[0].BillingStreet='st martin de chez yvone';
			accountList[0].BillingPostalCode='12345';
			accountList[1].BillingCity='Nimes';
			accountList[1].BillingCountry='France';
			accountList[1].BillingStreet='st martin de chez yvone';
			accountList[1].BillingPostalCode='12345';
			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment1', accountList[0]),
				TestFactory.createAssessment('Assessment2', accountList[1])
			};

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY),
				TestFactory.createSalesOrder(assessmentList[1], accountList[1], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[2], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[2], ASPISConstants.PUR_ORDER_STATUS_RESPONDED)
			};

			purchaseOrderList[0].SLAQuotationLevel1__c = System.now().addMonths(-2);
			purchaseOrderList[0].SLAQuotationLevel2__c = System.now().addMonths(-2).addDays(1);
			purchaseOrderList[0].SLAQuotationLevel3__c = System.now().addMonths(-2).addDays(2);

			purchaseOrderList[1].SLAQuotationLevel1__c = System.now().addMonths(-2);
			purchaseOrderList[1].SLAQuotationLevel2__c = System.now().addMonths(-2).addDays(1);
			purchaseOrderList[1].SLAQuotationLevel3__c = System.now().addMonths(-2).addDays(2);

			insert purchaseOrderList;

			orderLineList = new List<OrderLine__c>
			{
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY),
				TestFactory.createOrderLineFinal(1000, purchaseOrderList[0], ASPISConstants.ORD_LINE_STATUS_INDELIVERY)
			};

			orderLineList[0].Suppliable__c = 'NO';
			orderLineList[1].Suppliable__c = 'NO';

			insert orderLineList;

			defaultHours = [SELECT	Id 
							FROM	BusinessHours 
							WHERE	IsDefault = true];

			slaConfigurationList = new List<SLAConfiguration__c>
			{
				new SLAConfiguration__c(Name				= 'QuotationAXADirect',
										BusinessHoursID__c	= defaultHours.Id,
										SLALevel1Minute__c	= 30,
										SLALevel2Minute__c	= 60,
										SLALevel3Minute__c	= 90,
										Entity__c			= 'AXA Direct',
										Object__c			= 'Purchase Order')
			};

			insert slaConfigurationList;
		}
	}

	@isTest static void batchSLAQuotation()
	{
		System.runAs(adminUser)
		{
			ASPISBatchSLAQuotation batch = new ASPISBatchSLAQuotation();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrder = [	SELECT	Id, TECHSLAQuotationIsLevel1__c, TECHSLAQuotationIsLevel2__c, TECHSLAQuotationIsLevel3__c
															FROM	PurchaseOrder__c
															WHERE	Id IN: purchaseOrderList
															AND		TECHSLAQuotationIsLevel1__c = true
															AND		TECHSLAQuotationIsLevel2__c = true
															AND		TECHSLAQuotationIsLevel3__c = true];

			System.assertEquals(1, updatedPurchaseOrder.size());
		}
	}

	// ABT 10-MAY-2016 
	@isTest static void scheduleBatchSLAQuotation()
	{
		System.runAs(adminUser)
		{
			ASPISScheduledSLAQuotation scheduler = new ASPISScheduledSLAQuotation();
			String sch = '0 0 0 * * ?';

			Test.startTest();
				Id processId = System.schedule('Test SLA quotation scheduler', sch, scheduler);
			Test.stopTest();

			CronTrigger ct = [SELECT Id, CronExpression
							  FROM	 CronTrigger
							  WHERE	 Id =: processId];

			System.assertEquals(sch, ct.CronExpression);
		}
	}
}