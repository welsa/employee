@isTest
private class AspisBatchReplaceCrossRefs_TEST  {
	
	static User adminUser;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;
	static List<CrossReference__c> crossReferenceList;
	static List<DistributorPrice__c> distributorPriceList;
	static List<PartList__c> partList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;


		System.runAs(adminUser)
		{
			// Generating the account
			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('BodyShop_2', 'FR'),
				TestFactory.createAccountDistributor('Distributor_2', 'FR')
			};

			insert accountList;	
			System.debug('@@ accountList: '+accountList.size());


			// Generating the assessments
			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('Assessment_FR0', accountList[0]),
				TestFactory.createAssessment('Assessment_FR1', accountList[2]),
				TestFactory.createAssessment('Assessment_FR2', accountList[0]),
				TestFactory.createAssessment('Assessment_FR3', accountList[2]),
				TestFactory.createAssessment('Assessment_FR4', accountList[0]),
				TestFactory.createAssessment('Assessment_FR5', accountList[2]),
				TestFactory.createAssessment('Assessment_FR6', accountList[0]),
				TestFactory.createAssessment('Assessment_FR7', accountList[2]),
				TestFactory.createAssessment('Assessment_FR8', accountList[0]),
				TestFactory.createAssessment('Assessment_FR9', accountList[2]),
				TestFactory.createAssessment('Assessment_FR10', accountList[0]),
				TestFactory.createAssessment('Assessment_FR11', accountList[2])
			};

			insert assessmentList;
			System.debug('@@ assessmentList: '+assessmentList.size());


			crossReferenceList = new list<CrossReference__c>();
			for(Integer i=0;i<200;i++){
				//if (i< 400){
					CrossReference__c cf = TestFactory.createCrossReference('FR', 'ABC'+i, 'TOYOYA', 200, false);
					cf.LanguageCode__c = 'fr';
					cf.IAMManufacturer__c = 'TOYOYA';
					//cf.ActiveForSubstitution__c = false;
					//System.debug(cf.CountryCode__c);
					//System.debug(cf.LanguageCode__c);
					//System.debug(cf.OEMCleanPartNumber__c);
					//System.debug(cf.IAMCleanPartNumber__c);
					//System.debug(cf.OEMManufacturer__c);
					//System.debug(cf.IAMManufacturer__c);
					cf.CrossReferenceExtID__c = cf.CountryCode__c+cf.LanguageCode__c+cf.OEMCleanPartNumber__c+cf.IAMCleanPartNumber__c+cf.OEMManufacturer__c+cf.IAMManufacturer__c+String.valueOf(i);
					

					crossReferenceList.add(cf);
				//}
				
			}
			for(Integer i=0;i<200;i++){
				//if (i< 400){
					CrossReference__c cf = TestFactory.createCrossReference('FR', 'ABC'+i, 'TOYOYA', 200, false);
					cf.LanguageCode__c = 'fr';
					cf.IAMManufacturer__c = 'TOYOYA';

					//cf.ActiveForSubstitution__c = false;
					cf.CrossReferenceExtID__c = cf.CountryCode__c+cf.LanguageCode__c+cf.OEMCleanPartNumber__c+cf.IAMCleanPartNumber__c+cf.OEMManufacturer__c+cf.IAMManufacturer__c+String.valueOf(i)+'_';
					

					crossReferenceList.add(cf);
				//}
				
			}


			insert crossReferenceList;

			Integer counter = 0;
			for(CrossReference__c cf: crossReferenceList){
				cf.IAMManufacturer__c = 'TOYOYA';

				if (counter< 200){
					cf.ActiveForSubstitution__c = false;

					if(counter< 150){
						cf.DeactivationDate__c = Date.today() - 30;
					}else{
						cf.DeactivationDate__c = Date.today() - 15;	
					}
				}
				else{
					
					cf.ActiveForSubstitution__c = true;

				}
				counter++;
			}
			System.debug('@@ crossReferenceList: '+crossReferenceList.size());
			System.debug('@@ crossReferenceList: '+crossReferenceList);

			distributorPriceList = new list<DistributorPrice__c>();
			for(Integer i=0;i<400;i++){
				//System.debug('@@ crossReferenceList: '+crossReferenceList[i].CrossReferenceExtID__c);
				//System.debug('@@ ActiveForSubstitution__c: '+crossReferenceList[i].ActiveForSubstitution__c);
				
				
				DistributorPrice__c dp = TestFactory.createDistributorPrice(accountList[1].Id,crossReferenceList[i].Id);
				distributorPriceList.add(dp);			
				
			}
			insert distributorPriceList;
			System.debug('@@ distributorPriceList: '+distributorPriceList.size());

			Integer count = 0;

			partList = new list<PartList__c>();

			for (Assessment__c ass: assessmentList){
				ass.recordtypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
				for (Integer i=0; i<40;i++){
					//System.debug('@@ count: '+count);
					//System.debug('@@ count: '+crossReferenceList[count]);
					//System.debug('@@ count: '+distributorPriceList[count]);

					if (i< 15){
						partList.add(TestFactory.createPartListASCR(ass,crossReferenceList[count],distributorPriceList[count]));
						count++;
					}
					else{
						partList.add(TestFactory.createPartList(ass));
					}
					
				}		
			}
			update assessmentList;

			insert partList;
			System.debug('@@ partList: '+partList);

			

        }
    }

    @isTest static void allCrossRefs_TEST()
	{
		System.runAs(adminUser)
		{
			Date startDeactivationDateXref = Date.today() - 31;
			Date endDeactivationDateXref = Date.today() - 14;
			Datetime createdDateXref = Datetime.now().addDays(-1);
			Datetime startCreatedDatePartlist = Datetime.now().addDays(-1);
			Datetime endCreatedDatePartlist = Datetime.now().addDays(1);

			System.debug('@@ createdDateXref: '+createdDateXref);

			update crossReferenceList;



			Test.startTest();
				Id processId = Database.executeBatch(new AspisBatchReplaceCrossRefs(startDeactivationDateXref,endDeactivationDateXref,createdDateXref,startCreatedDatePartlist,endCreatedDatePartlist), 200);

				AspisBatchReplaceCrossRefs runTwice = new AspisBatchReplaceCrossRefs(startDeactivationDateXref,endDeactivationDateXref,createdDateXref,startCreatedDatePartlist,endCreatedDatePartlist);

				runTwice.createCSV('header', new List<String> {'test1','test2'});
			Test.stopTest();
		}
	}

	 @isTest static void allCrossRefsMock_TEST()
	{
		System.runAs(adminUser)
		{
			Date startDeactivationDateXref = Date.today() - 31;
			Date endDeactivationDateXref = Date.today() - 14;
			Datetime createdDateXref = Datetime.now().addDays(-1);
			Datetime startCreatedDatePartlist = Datetime.now().addDays(-1);
			Datetime endCreatedDatePartlist = Datetime.now().addDays(1);

			System.debug('@@ createdDateXref: '+createdDateXref);

			update crossReferenceList;



			Test.startTest();
				Id processId = Database.executeBatch(new AspisBatchReplaceCrossRefsMock(startDeactivationDateXref,endDeactivationDateXref,createdDateXref,startCreatedDatePartlist,endCreatedDatePartlist), 200);

				AspisBatchReplaceCrossRefsMock runTwice = new AspisBatchReplaceCrossRefsMock(startDeactivationDateXref,endDeactivationDateXref,createdDateXref,startCreatedDatePartlist,endCreatedDatePartlist);

				runTwice.createCSV('header', new List<String> {'test1','test2'});
			Test.stopTest();
		}
	}
	
}