/*
  ----------------------------------------------------------------------
  -- - Name          : Utils_ManageCaseCustom_TEST
  -- - Author        : ABT
  -- - Description   : Test class for Utils_ManageCaseCustom
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
public class Utils_ManageCaseCustom_TEST
{
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<PrerequisiteOrder__c> salesOrderList;
	static List<PurchaseOrder__c> purchaseOrderList;
	static List<CaseDetailsProcessMapping__c> caseMappingList;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryMappingList;

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

			// access Business Hours 
            defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};
			
			insert countryMappingList;
		}
	}

	/*@isTest static void calculateDueDateBasedOnCustomSettingsWithD_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				DateTime calculatedDateTime = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(caseMappingList[0], countryMappingList[0], '');
			Test.stopTest();

			//Utils_BusinessDays businessDays = new Utils_BusinessDays(countryMappingList[0].Name);
			BusinessHours businessDays = ASPISConstants.getBusinessHours(countryMappingList[0].Name);
			//DateTime expectedDateTime		= businessDays.getEndOfBusinessDayFromDate(System.today(), Integer.valueOf(caseMappingList[0].Due_Date_Duration__c));
			Datetime expectedDateTime = BusinessHours.add(businessDays.id,datetime.now(),Integer.valueOf(caseMappingList[0].Due_Date_Duration__c)*60*60*1000L);
			System.assertEquals(true, expectedDateTime.isSameDay(calculatedDateTime));
		}
	}*/

	@isTest static void calculateDueDateBasedOnCustomSettingsWithH_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				DateTime calculatedDateTime = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(caseMappingList[2], countryMappingList[1], '');
			Test.stopTest();

			DateTime expectedDateTime		= BusinessHours.add(defaultHours.Id, System.now(), Integer.valueOf(caseMappingList[2].Due_Date_Duration__c) * 60 * 60 * 1000L);
			System.assertEquals(true, expectedDateTime.isSameDay(calculatedDateTime));
		}
	}

	/*@isTest static void calculateDueDateBasedOnCustomSettingsWithM_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				DateTime calculatedDateTime = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(caseMappingList[18], countryMappingList[1], '');
			Test.stopTest();

			DateTime expectedDateTime		= BusinessHours.add(defaultHours.Id, System.now(), Integer.valueOf(caseMappingList[18].Due_Date_Duration__c) * 60 * 1000L);
			System.assertEquals(true, expectedDateTime.isSameDay(calculatedDateTime));
		}
	}*/


	@isTest static void calculateDueDateBasedOnCustomSettingsWithCountryNull_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				DateTime calculatedDateTime = Utils_ManageCaseCustom.calculateDueDateBasedOnCustomSettings(caseMappingList[0], null, '');
			Test.stopTest();

			DateTime expectedDateTime		= System.now() + Integer.valueOf(caseMappingList[0].Due_Date_Duration__c);
			System.assertEquals(true, expectedDateTime.isSameDay(calculatedDateTime));
		}
	}

	@isTest static void runSLAOnStatus_AssignedWithFR_TEST()
	{
		System.runAs(adminUser)
		{
			Case__c newCase = new Case__c(
											Subject__c				= 'subject',
											CountryCode__c			= 'FR',
											SLAAssignationDate__c	= System.now().addDays(1)
										);

			insert newCase;

			Test.startTest();
				Utils_ManageCaseCustom.runSLAOnStatus_Assigned(newCase, 'FR');
			Test.stopTest();

			//Utils_BusinessDays businessDays = new Utils_BusinessDays(countryMappingList[1].Name);
			BusinessHours businessDays = ASPISConstants.getBusinessHours(countryMappingList[1].Name);
			
			//Integer expectedMinutes			= businessDays.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAAssignationDate__c, System.now());
			Integer expectedMinutes			= ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAAssignationDate__c, System.now(),businessDays);

			System.assertEquals(expectedMinutes, newCase.SLAAssignationDurationMinutes__c);
		}
	}

	@isTest static void runSLAOnStatus_AssignedWithDefault_TEST()
	{
		System.runAs(adminUser)
		{
			Case__c newCase = new Case__c(
											Subject__c				= 'subject',
											CountryCode__c			= 'FR',
											SLAAssignationDate__c	= System.now().addDays(1)
										);

			insert newCase;

			Test.startTest();
				Utils_ManageCaseCustom.runSLAOnStatus_Assigned(newCase, 'UNKNOWN');
			Test.stopTest();

			//Utils_BusinessDays businessDays = new Utils_BusinessDays(countryMappingList[1].Name);
			//Integer expectedMinutes			= businessDays.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAAssignationDate__c, System.now());

			BusinessHours businessDays = ASPISConstants.getBusinessHours(countryMappingList[1].Name);
			Integer expectedMinutes			= ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAAssignationDate__c, System.now(),businessDays);

			System.assertEquals(expectedMinutes, newCase.SLAAssignationDurationMinutes__c);
		}
	}

	@isTest static void runSLAOnStatus_ClosedWithFR_TEST()
	{
		System.runAs(adminUser)
		{
			Case__c newCase = new Case__c(
											Subject__c				= 'subject',
											CountryCode__c			= 'FR',
											SLAAssignationDate__c	= System.now().addDays(1)
										);

			insert newCase;

			Test.startTest();
				Utils_ManageCaseCustom.runSLAOnStatus_Closed(newCase, 'FR');
			Test.stopTest();

			//Utils_BusinessDays businessDays = new Utils_BusinessDays(countryMappingList[1].Name);
			//Integer expectedMinutes			= businessDays.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAResolutionDate__c, System.now());

			BusinessHours businessDays = ASPISConstants.getBusinessHours(countryMappingList[1].Name);
			Integer expectedMinutes			= ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAResolutionDate__c, System.now() , businessDays);

			System.assertEquals(expectedMinutes, newCase.SLAResolutionDurationMinutes__c);
		}
	}

	@isTest static void runSLAOnStatus_ClosedWithDefault_TEST()
	{
		System.runAs(adminUser)
		{
			Case__c newCase = new Case__c(
											Subject__c				= 'subject',
											CountryCode__c			= 'FR',
											SLAAssignationDate__c	= System.now().addDays(1)
										);

			insert newCase;

			Test.startTest();
				Utils_ManageCaseCustom.runSLAOnStatus_Closed(newCase, 'UNKNOWN');
			Test.stopTest();

			//Utils_BusinessDays businessDays = new Utils_BusinessDays(countryMappingList[1].Name);
			//Integer expectedMinutes			= businessDays.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAResolutionDate__c, System.now());

			BusinessHours businessDays = ASPISConstants.getBusinessHours(countryMappingList[1].Name);
			Integer expectedMinutes			= ASPISConstants.calculateDifferenceBetweenBusinessDateInMinutes(newCase.SLAResolutionDate__c, System.now(),businessDays);

			System.assertEquals(expectedMinutes, newCase.SLAResolutionDurationMinutes__c);
		}
	}

	@isTest static void createNewCaseWithPrepopulatedInformations_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				Case__c caseCreated = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', 'FR', accountList[1].Id, assessmentList[0].Id, purchaseOrderList[0].Id, salesOrderList[0].Id, '', adminUser.Id, '-NoInvoiceCreated');
			Test.stopTest();

			System.assertNotEquals(null, caseCreated);
		}
	}

	@isTest static void createNewCaseWithPrepopulatedInformationsWithCustomSettingInactive_TEST()
	{
		System.runAs(adminUser)
		{
			caseMappingList[3].Active__c = false;
			update caseMappingList[3];

			Test.startTest();
				Case__c caseCreated = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', 'FR', accountList[1].Id, assessmentList[0].Id, purchaseOrderList[0].Id, salesOrderList[0].Id, '', adminUser.Id, '-NoInvoiceCreated');
			Test.stopTest();

			System.assertEquals(null, caseCreated);
		}
	}

	@isTest static void createNewCaseWithPrepopulatedInformationsWithoutCountry_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
				Case__c caseCreated = Utils_ManageCaseCustom.createNewCaseWithPrepopulatedInformations('-PO', 'UNKNOWN', accountList[1].Id, assessmentList[0].Id, purchaseOrderList[0].Id, salesOrderList[0].Id, '', adminUser.Id, '-NoInvoiceCreated');
			Test.stopTest();

			System.assertEquals(null, caseCreated);
		}
	}

	@isTest static void createNewCase_TEST()
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
				Utils_ManageCaseCustom.createNewCase(variableWrapperList);
			Test.stopTest();

			List<Case__c> caseInsertedList =	[SELECT Id
												 FROM	Case__c
												 WHERE	SubmittedBy__c =: adminUser.Id];

			System.assertEquals(1, caseInsertedList.size());
		}
	}

	@isTest static void createNewCaseWithCustomSettingsInactive_TEST()
	{
		System.runAs(adminUser)
		{
			caseMappingList[3].Active__c = false;
			update caseMappingList[3];

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
				Utils_ManageCaseCustom.createNewCase(variableWrapperList);
			Test.stopTest();

			List<Case__c> caseInsertedList =	[SELECT Id
												 FROM	Case__c
												 WHERE	SubmittedBy__c =: adminUser.Id];

			System.assertEquals(0, caseInsertedList.size());
		}
	}
}