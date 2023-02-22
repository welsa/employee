/*
  ----------------------------------------------------------------------
  -- - Name          : ASPISBatchCreateCaseFromSalesOrder_TEST 
  -- - Author        : ABT 
  -- - Description   : ASPISBatchCreateCaseFromSalesOrder_TEST
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 26-APR-2016  ABT    1.0     Reworked version
  ----------------------------------------------------------------------
  -- Previous Test Class History
  ----------------------------------------------------------------------
  -- Developer		Date        Description
  -- ----------		----------  -----------------------
  -- Dourga (sc)	17/07/2015 	Original Version
  -- Dourga (sc)	19/01/2016 	Case 1470 (remove field TECH_BodyshopCountryCode__c to add new field TECH_EntityCountryCode__c)
 **********************************************************************
*/
@isTest
public class ASPISBatchCreateCaseFromSalesOrder_TEST 
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;

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
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountBodyshop('BodyShop_2', 'FR')
			};

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

			salesOrderList[0].SLAInDeliveryLevel1__c = System.today();
			salesOrderList[1].SLAInDeliveryLevel2__c = System.today();

			insert salesOrderList;

			caseMappingList = TestFactory.createCaseDetailsProcessMapping();
			
			insert caseMappingList;

			defaultHours = [SELECT	Id 
							FROM	BusinessHours 
							WHERE	IsDefault = true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};

			insert countryCodeMappingList;
		}
	}

	@isTest static void batchCreateCaseFromSalesOrder()
	{
		System.runAs(adminUser)
		{
			ASPISBatchCreateCaseFromSalesOrder batch = new ASPISBatchCreateCaseFromSalesOrder();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Case__c> insertedCaseList = [	SELECT	Id
												FROM	Case__c
												WHERE	Sales_order__c IN: salesOrderList
												AND		(	TECH_AutomaticCreationFromProcess__c LIKE '%-DELIVERYCONFIRMEDSLA1' 
														OR	TECH_AutomaticCreationFromProcess__c LIKE '%-DELIVERYCONFIRMEDSLA2')];

			System.assertEquals(2, insertedCaseList.size());
		}
	}

	@isTest static void batchCreateCaseFromSalesOrderWithSOCanceled()
	{
		System.runAs(adminUser)
		{
			// changing the status of the sales order to canceled
			salesOrderList[0].Status__c = ASPISConstants.PRE_ORDER_STATUS_CANCELED;
			salesOrderList[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_CANCELED;

			update salesOrderList;

			ASPISBatchCreateCaseFromSalesOrder batch = new ASPISBatchCreateCaseFromSalesOrder();

			Test.startTest();
				Id processId = Database.executeBatch(batch);
			Test.stopTest();

			List<Case__c> insertedCaseList = [	SELECT	Id
												FROM	Case__c
												WHERE	Sales_order__c IN: salesOrderList
												AND		(	TECH_AutomaticCreationFromProcess__c LIKE '%-DELIVERYCONFIRMEDSLA1' 
														OR	TECH_AutomaticCreationFromProcess__c LIKE '%-DELIVERYCONFIRMEDSLA2')];

			System.assertEquals(2, insertedCaseList.size());
		}
	}

	// ABT 10-MAY-2016
	@isTest static void scheduleBatchCreateCaseFromSalesOrder()
	{
		System.runAs(adminUser)
		{
			ASPISSCHBatchCreateCaseFromSalesOrder scheduler = new ASPISSCHBatchCreateCaseFromSalesOrder();
			String sch = '0 0 0 * * ?';

			Test.startTest();
				Id processId = System.schedule('Test create case from sales order scheduler', sch, scheduler);
			Test.stopTest();

			CronTrigger ct = [SELECT Id, CronExpression
							  FROM	 CronTrigger
							  WHERE	 Id =: processId];

			System.assertEquals(sch, ct.CronExpression);
		}
	}
}