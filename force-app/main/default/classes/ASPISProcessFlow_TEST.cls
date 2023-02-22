/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISProcessFlow_TEST
  -- - Author        : ABT
  -- - Description   : Test class for ASPISProcessFlow
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 20-SEP-2016  ABT    1.0     Initial Version
  ----------------------------------------------------------------------
 **********************************************************************
*/
@isTest
public class ASPISProcessFlow_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<Invoice__c> invoiceList;
	static List<CaseDetailsProcessMapping__c> caseMappingList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
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

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_DELIVERED)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DELIVEREDCONFIRMED)
			};

			insert purchaseOrderList;

			invoiceList = new List<Invoice__c>
			{
				TestFactory.createDistributorInvoice('INV-00001', 2000.0, ASPISConstants.INV_STATUS_PAID, purchaseOrderList[0])
			};

			insert invoiceList;

			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			
			insert caseMappingList;
		}
	}

	@isTest static void updateDateField_TEST()
	{
		System.runAs(adminUser)
		{
			List<ASPISProcessFlow.variableWrapper> variableWrapperList = new List<ASPISProcessFlow.variableWrapper>();

			ASPISProcessFlow.variableWrapper purchaseOrderWrapper = new ASPISProcessFlow.variableWrapper();
			purchaseOrderWrapper.sObjectId		= purchaseOrderList[0].Id;
			purchaseOrderWrapper.sObjectType	= 'PurchaseOrder';

			variableWrapperList.add(purchaseOrderWrapper);

			ASPISProcessFlow.variableWrapper invoiceWrapper = new ASPISProcessFlow.variableWrapper();
			invoiceWrapper.sObjectId		= invoiceList[0].Id;
			invoiceWrapper.sObjectType		= 'Invoice';

			variableWrapperList.add(invoiceWrapper);

			Test.startTest();
				ASPISProcessFlow.updateDateField(variableWrapperList);
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrderList =	[SELECT Id
																 FROM	PurchaseOrder__c
																 WHERE	TriggeredDelayDate__c != null];
			
			System.assertEquals(1, updatedPurchaseOrderList.size());

			List<Invoice__c> updatedInvoiceList =	[SELECT Id
													 FROM	Invoice__c
													 WHERE	TriggeredDelayDate__c != null];
			
			System.assertEquals(1, updatedInvoiceList.size());
		}
	}
}