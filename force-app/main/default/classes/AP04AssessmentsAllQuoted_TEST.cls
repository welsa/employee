/*
  ----------------------------------------------------------------------
  -- - Name          : AP04AssessmentsAllQuoted_TEST 
  -- - Author        : ABT 
  -- - Description   : AP04AssessmentsAllQuoted_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 22-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Yudish R  		06/05/2015 	Original Version
 **********************************************************************
*/
@isTest
public class AP04AssessmentsAllQuoted_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<CaseDetailsProcessMapping__c> caseMappingList;
	static List<CountryCodeInformationsMapping__c> countryCodeMappingList;
	static BusinessHours defaultHours;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShopFR', 'FR'),
				TestFactory.createAccountDistributor('DistributorFR', 'FR')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment1', accountList[0]),
				TestFactory.createAssessment('Assessment2', accountList[0]),
				TestFactory.createAssessment('Assessment3', accountList[0])
			};

			insert assessmentList;

			salesOrderList = new List<PrerequisiteOrder__c>
			{
				TestFactory.createSalesOrder(assessmentList[0], accountList[0], ASPISConstants.PRE_ORDER_STATUS_INDELIVERY)
			};

			insert salesOrderList;

			purchaseOrderList = new List<PurchaseOrder__c>
			{
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[0], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_ISSUED),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[1], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE),
				TestFactory.createPurchaseOrder(assessmentList[2], salesOrderList[0], accountList[0], accountList[1], ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE)
			};

			insert purchaseOrderList;

			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			
			insert caseMappingList;

			defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			insert countryCodeMappingList;
		}
	}

	@isTest static void testUpdatePO()
	{
		System.runAs(adminUser)
		{
			purchaseOrderList[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
			purchaseOrderList[2].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;

			Test.startTest();
				update purchaseOrderList;
			Test.stopTest();

			List<Assessment__c> updatedAssessmentList = [SELECT Id, Status__c
														 FROM	Assessment__c
														 WHERE	Id IN: assessmentList];

			System.assertEquals('OFFERING', updatedAssessmentList[0].Status__c);
		}
	}

	
	@isTest static void testUpdatePONotTimeout()
	{
		System.runAs(adminUser)
		{
			purchaseOrderList[4].Status__c = ASPISConstants.PUR_ORDER_STATUS_CANCELED;
			purchaseOrderList[4].Reason__c = 'QUOTETIMEOUT';

			Test.startTest();
				update purchaseOrderList[4];
			Test.stopTest();

			Assessment__c updatedAssessment = [SELECT	Id, Status__c
											   FROM		Assessment__c
											   WHERE	Id =: assessmentList[2].Id];

			// Becomes CANCELED due to AP18
			//System.assertEquals('CANCELED', updatedAssessment.Status__c);
			// ABT 19-OCT-2016 - C-001677 - Assessment becomes CLOSEDKO as the purchase order becomes CLOSEDKO and it is the only purchase order
			// for that assessment and the assessment does not have a sales order
			// NOTE: the test data is bad as a purchase order cannot be linked to a sales order of another assessment
			System.assertEquals(ASPISConstants.ASSESS_STATUS_CLOSEDKO, updatedAssessment.Status__c);

			List<Case__c> insertedCase = [SELECT	Id
										  FROM		Case__c
										  WHERE		Assesment__c =: assessmentList[2].Id];

			// Becomes CANCELED due to AP18
			System.assertEquals(1, insertedCase.size());
		}
	}
}