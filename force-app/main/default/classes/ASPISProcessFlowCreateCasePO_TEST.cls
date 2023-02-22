/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISProcessFlowCreateCasePO_TEST
  -- - Author        : ABT
  -- - Description   : Test class for ASPISProcessFlowCreateCasePO
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
public class ASPISProcessFlowCreateCasePO_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
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
			
			purchaseOrderList[0].TriggeredDelayDate__c = System.now();

			insert purchaseOrderList;

			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			
			insert caseMappingList;
		}
	}

	@isTest static void createCasePO_TEST()
	{
		System.runAs(adminUser)
		{
			List<ASPISProcessBuilderGlobalVariables.variableWrapper> variableWrapperList = new List<ASPISProcessBuilderGlobalVariables.variableWrapper>();

			ASPISProcessBuilderGlobalVariables.variableWrapper purchaseOrderWrapper = new ASPISProcessBuilderGlobalVariables.variableWrapper();
			purchaseOrderWrapper.objCode		= '-PO';
			purchaseOrderWrapper.countryCode	= assessmentList[0].TECH_EntityCountryCode__c;
			purchaseOrderWrapper.accountId		= purchaseOrderList[0].Distributor__c;
			purchaseOrderWrapper.assessmentId	= purchaseOrderList[0].Assessment__c;
			purchaseOrderWrapper.poId			= purchaseOrderList[0].Id;
			purchaseOrderWrapper.soId			= purchaseOrderList[0].PrerequisiteOrder__c;
			purchaseOrderWrapper.comment		= '';
			purchaseOrderWrapper.userId			= adminUser.Id;
			purchaseOrderWrapper.csProcessName	= '-NoInvoiceCreated';

			variableWrapperList.add(purchaseOrderWrapper);

			Test.startTest();
				ASPISProcessFlowCreateCasePO.createCasePO(variableWrapperList);
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrderList =	[SELECT Id, 
																		(SELECT Id 
																		 FROM	Cases__r)
																 FROM	PurchaseOrder__c
																 WHERE	TriggeredDelayDate__c = null];
			
			System.assertEquals(1, updatedPurchaseOrderList.size());
			System.assertEquals(1, updatedPurchaseOrderList[0].Cases__r.size());
		}
	}

	@isTest static void createCasePOWithException_TEST()
	{
		System.runAs(adminUser)
		{
			List<ASPISProcessBuilderGlobalVariables.variableWrapper> variableWrapperList = new List<ASPISProcessBuilderGlobalVariables.variableWrapper>();

			ASPISProcessBuilderGlobalVariables.variableWrapper purchaseOrderWrapper = new ASPISProcessBuilderGlobalVariables.variableWrapper();
			purchaseOrderWrapper.objCode		= '-PO';
			purchaseOrderWrapper.countryCode	= assessmentList[0].TECH_EntityCountryCode__c;
			purchaseOrderWrapper.accountId		= purchaseOrderList[0].Distributor__c;
			purchaseOrderWrapper.assessmentId	= 'a00000101010101';
			purchaseOrderWrapper.poId			= purchaseOrderList[0].Id;
			purchaseOrderWrapper.soId			= purchaseOrderList[0].PrerequisiteOrder__c;
			purchaseOrderWrapper.comment		= '';
			purchaseOrderWrapper.userId			= adminUser.Id;
			purchaseOrderWrapper.csProcessName	= '-NoInvoiceCreated';

			variableWrapperList.add(purchaseOrderWrapper);

			Test.startTest();
				ASPISProcessFlowCreateCasePO.createCasePO(variableWrapperList);
			Test.stopTest();

			List<PurchaseOrder__c> updatedPurchaseOrderList =	[SELECT Id
																 FROM	PurchaseOrder__c
																 WHERE	TriggeredDelayDate__c = null];
			
			System.assertEquals(0, updatedPurchaseOrderList.size());
		}
	}
}