/*
----------------------------------------------------------------------
-- - Name          : ASPISHeader
-- - Author        : VSU
-- - Description   : Controller for component ASPISHeader
--
-- Maintenance History:
--
-- Date			Name	Version		Remarks
-- -----------  ----	-------		---------------------------------------
-- 20-JUN-2017	VSU		1.0			Initial version
-- 20-May-2022	NPE		1.1			Increased Coverage
----------------------------------------------------------------------
**********************************************************************
*/
@isTest 
private class ASPISHeader_TEST {
	static User adminUser;
	static List<CountryCodeInformationsMapping__c> countryMappingList;
	static BusinessHours defaultHours;

	static
	{
		adminUser = TestFactory.createUser('adminUser');

		insert adminUser;
	}

	@isTest static void retrieveProfileDetails_TEST()
	{
		System.runAs(adminUser)
		{
			Test.startTest();
			
			defaultHours = [select Id from BusinessHours where IsDefault=true];

			countryMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id)
			};

			insert countryMappingList;

			ASPISHeader header = new ASPISHeader();
			Test.stopTest();

			User currentUser = [SELECT Id, SmallPhotoUrl FROM User where id =: adminUser.id];
			
			System.assertEquals(currentUser.Id, header.currentUser.id);
			System.assertEquals(currentUser.SmallPhotoUrl, header.profilepicture);
		}
	}
}