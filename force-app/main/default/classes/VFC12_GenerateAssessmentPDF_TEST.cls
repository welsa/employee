/*
----------------------------------------------------------------------
-- - Name          : VFC12_GenerateAssessmentPDF_TEST
-- - Author        : ABT
-- - Description   : Test class for VFC12_GenerateAssessmentPDF
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 21-DEC-2016	ABT		1.0			Initial version
----------------------------------------------------------------------
**********************************************************************
*/
@isTest
private class VFC12_GenerateAssessmentPDF_TEST 
{
	static User adminUser;
    static List<Account> accountList;
    static List<Assessment__c> assessmentList;
    static List<PartList__c> partList;

	static
	{
		adminUser			= TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_DE', 'DE'),
				TestFactory.createAccountDistributor('Distributor_DE', 'DE')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_DE_1', accountList[0]),
				TestFactory.createAssessment('Assessment_DE_2', accountList[0])
			};

			assessmentList[0].Manufacturer__c 	= 'MERCEDES';
			assessmentList[0].ModelV2__c		= 'Classe A';
			assessmentList[0].PlateNumber2__c	= '123AZ123';
			assessmentList[0].VINNumber__c		= '123456789';
			assessmentList[1].Manufacturer__c	= 'MERCEDES';
			assessmentList[1].ModelV2__c		= 'Classe B';
			assessmentList[1].PlateNumber2__c	= '123BZ123';
			assessmentList[1].VINNumber__c		= '987654321';

			insert assessmentList;

			partList = new List<PartList__c>
			{
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0]),
				TestFactory.createPartList(assessmentList[0])
			};

			insert partList;
		}
	}
	
	@isTest static void constructor_TEST() 
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP12_GenerateAssessmentPDF);

			Test.startTest();
				VFC12_GenerateAssessmentPDF controller = new VFC12_GenerateAssessmentPDF(new ApexPages.StandardController(new Assessment__c()));
			Test.stopTest();

			System.assertEquals(null, controller.currentAssessment.Id);
			System.assertEquals(0, controller.partList.size());
		}
	}
	
	@isTest static void assessmentWithParts_TEST() 
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP12_GenerateAssessmentPDF);

			Assessment__c currentAssessment = [	SELECT	Id, CreatedDate, Name, Manufacturer__c, ModelV2__c, PlateNumber2__c, VINNumber__c, AssessmentNumber__c
												FROM	Assessment__c
												WHERE	Id =: assessmentList[0].Id];

			Test.startTest();
				VFC12_GenerateAssessmentPDF controller = new VFC12_GenerateAssessmentPDF(new ApexPages.StandardController(currentAssessment));
			Test.stopTest();

			System.assertNotEquals(null, controller.currentAssessment.Id);
			System.assertEquals(assessmentList[0].Id, controller.currentAssessment.Id);
			System.assertEquals(4, controller.partList.size());
		}
	}

	@isTest static void assessmentWithNoParts_TEST() 
	{
		System.runAs(adminUser)
		{
			Test.setCurrentPage(Page.VFP12_GenerateAssessmentPDF);

			Assessment__c currentAssessment = [	SELECT	Id, CreatedDate, Name, Manufacturer__c, ModelV2__c, PlateNumber2__c, VINNumber__c, AssessmentNumber__c
												FROM	Assessment__c
												WHERE	Id =: assessmentList[1].Id];

			Test.startTest();
				VFC12_GenerateAssessmentPDF controller = new VFC12_GenerateAssessmentPDF(new ApexPages.StandardController(currentAssessment));
			Test.stopTest();

			System.assertNotEquals(null, controller.currentAssessment.Id);
			System.assertEquals(assessmentList[1].Id, controller.currentAssessment.Id);
			System.assertEquals(0, controller.partList.size());
		}
	}
}