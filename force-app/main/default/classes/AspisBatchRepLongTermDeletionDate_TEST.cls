@isTest
private class AspisBatchRepLongTermDeletionDate_TEST
{
	/*
----------------------------------------------------------------------
-- - Name          : AspisBatchRepLongTermDeletionDate_TEST
-- - Author        : RLA
-- - Description   : Test Class AspisBatchRepLongTermDeletionDate
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 01-JUN-2017  RLA   1.0      Initial version
----------------------------------------------------------------------*/	
	static list<Account> l_Accounts;
	static List<Assessment__c> l_Assessments;
	static list<user> l_users;
	static list<PurchaseOrder__c> l_purchaseOrders;
	static list<PrerequisiteOrder__c> l_SalesOrders;	
	static list<Invoice__c> l_Invoices;
	static List<CountryCodeInformationsMapping__c> countryCodeMappingList;
	static BusinessHours defaultHours;
	static set<Id> setAsmnt = new set<Id>();

	static {
		// initialising variables
		l_Accounts = new list<Account>();
		l_Assessments = new list<Assessment__c>();
		l_users = new list<user>();
		l_purchaseOrders = new list<PurchaseOrder__c>();
		l_SalesOrders = new list<PrerequisiteOrder__c>();		
		l_Invoices = new list<Invoice__c>();

		// creating user
		User user1 = TestFactory.createUserIntegration('ScUserTest');
		l_users.add(user1);

		User user2 = TestFactory.createUser('ScUserTest');
		l_users.add(user2);
		insert l_users;

		system.runas(l_users[0]){
			// initialising dates
			DateTime myDateTime = datetime.newInstance(2015, 2, 17);
			Date myDate = date.newInstance(2015, 2, 17);

			// Create several accounts
			Account bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
			bs2.ContactUser__c = l_users[1].Id;
			l_Accounts.add(bs2);

			Account dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
			l_Accounts.add(dist1);

			
			insert l_Accounts;		

			defaultHours = [SELECT	Id
							FROM	BusinessHours 
							WHERE	IsDefault = true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('DE', defaultHours.Id)
			};
			
			
			countryCodeMappingList[1].ValidityOfEligibleAssessment__c		= 20;
			countryCodeMappingList[1].ValidityOfNonEligibleAssessement__c	= 18;

			
			countryCodeMappingList[2].ValidityOfEligibleAssessment__c		= 36;
			countryCodeMappingList[2].ValidityOfNonEligibleAssessement__c	= 30;
			
			insert countryCodeMappingList;



			Assessment__c ass1 = TestFactory.createAssessment('ASSESS_TEST-0001', bs2);	
			ass1.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass1.Status__c  = 'CLOSEDOK';
			ass1.TECH_EntityCountryCode__c = 'DE';		
			l_Assessments.add(ass1);

		
			Assessment__c ass2 = TestFactory.createAssessment('ASSESS_TEST-0002', bs2);	
			ass2.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass2.Status__c  = 'Rejected';	
			ass2.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass2);


			Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs2);
			ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass3.Status__c  = 'Rejected';	
			ass3.TECH_EntityCountryCode__c = 'FR';		
			l_Assessments.add(ass3);

			
			Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs2);
			ass4.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass4.Status__c  = 'CLOSEDKO';
			ass4.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass4);	

			Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs2);	
			ass5.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass5.Status__c  = 'CLOSEDOK';
			ass5.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass5);	


			Assessment__c ass6 = TestFactory.createAssessment('ASSESS_TEST-0006', bs2);	
			ass6.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass6.Status__c  = 'New';
			ass5.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass6);
	
			Assessment__c ass7 = TestFactory.createAssessment('ASSESS_TEST-0007', bs2);	
			ass7.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
			ass7.Status__c  = 'New';
			ass7.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass7);

			Assessment__c ass8 = TestFactory.createAssessment('ASSESS_TEST-0008', bs2);	
			ass8.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
			ass8.Status__c  = 'New';
			ass8.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass8);


			insert l_Assessments;

			ass5 = l_Assessments[4];
			ass5.ParentAssessment__c = 	l_Assessments[0].Id;
			update ass5;


			list<Assessment__c> lstassChildren = new list <Assessment__c>();
			//system.debug('## l_Assessments: ' + l_Assessments.size() + l_Assessments );
			//for (Assessment__c assParent: l_Assessments){
			//	setAsmnt.add(assParent.Id);
			//	for (integer i = 1; i <= 2; i++){

			//		if (assParent.RecordTypeId != Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()){
			//			Assessment__c ass = TestFactory.createAssessment('ASSESS_TEST-000' + i, l_Accounts[0]);	
			//			ass.ParentAssessment__c = assParent.Id;
			//			//ass1.LongTermDeletionDate__c = system.now() - 10 ;
			//			if (assParent.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId())
			//			{
			//				ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();						
			//			}
			//			else{
			//				ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			//			}

			//			lstassChildren.add(ass);
			//		}

			//	}
			//}
			//insert lstassChildren;


			//for (Assessment__c assChildren: lstassChildren){
			//	for (integer i = 1; i <= 2; i++){
			//		// Create severals Sales Orders
			//		PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(assChildren, bs2, 'DELIVEREDCONFIRMED');
			//		l_SalesOrders.add(so1);
			//	}
			//}

			
			//insert l_SalesOrders;

			//for (Assessment__c assChildren: lstassChildren){
			//	for (PrerequisiteOrder__c so: l_SalesOrders){
			//		// Create severals Sales Orders
			//		PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(assChildren, so, bs2,dist1, 'DELIVEREDCONFIRMED');
			//		l_purchaseOrders.add(po1_1);
			//	}
			//}
			
			//insert l_purchaseOrders;
			//system.debug('######### inserted l_purchaseOrders:');


			//for (PurchaseOrder__c po: l_purchaseOrders){
			//	for (integer i = 1; i <= 2; i++){
			//		// Create severals Sales Orders
			//		Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 14.40, 'RECEIVED', po);
			//		l_Invoices.add(inv1);

			//	}
			//}
			//insert l_Invoices;

			
		}
	}
	@isTest
	static void NoParams()
	{
		system.runAs(l_users[0]){
			for (Assessment__c assParent: l_Assessments){
				assParent.LongTermDeletionDate__c = null;
			}
			update l_Assessments;

			Test.startTest();
				Database.executeBatch(new AspisBatchRepriseForLongTermDeletionDate(null, null,null), 200);
			Test.stopTest();

			List<Assessment__c> lstAssert = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c,ParentAssessment__c, TECH_EntityCountryCode__c from Assessment__c];

			List<Assessment__c> lstAssert2 = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c from Assessment__c where Id IN:l_Assessments];


			for (Assessment__c asmnt: lstAssert){
				system.debug('@@ asmnt:'+asmnt);
				if (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()
					|| (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId())
					|| asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()){
					system.assertEquals(true,asmnt.LongTermDeletionDate__c != null);
				}
				else{
					system.assertEquals(true,asmnt.LongTermDeletionDate__c == null);
				}	
			}

			
			System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[0].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(36)));
			System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[1].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(30)));
			System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[2].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(18)));
			System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[3].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[4].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[5].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));   
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[6].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[7].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));  
		} 

	}

	@isTest
	static void AllParams()
	{
		//for (Assessment__c assParent: l_Assessments){
		//	assParent.LongTermDeletionDate__c = null;
		//}
		//update l_Assessments;

		
		Date startDate = date.valueOf(System.now().addMonths(-1));
	  	Date endDate =date.valueOf(System.now().addMonths(1));
		Test.startTest();
			Database.executeBatch(new AspisBatchRepriseForLongTermDeletionDate(startDate, endDate,setAsmnt), 200);
		Test.stopTest();

		//List<Assessment__c> lstAssert = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c,ParentAssessment__c, TECH_EntityCountryCode__c from Assessment__c];

		//List<Assessment__c> lstAssert2 = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c from Assessment__c where Id IN:l_Assessments];
		//system.debug('@@@ assertLla:'+lstAssert);


		//for (Assessment__c asmnt: lstAssert){
		//	system.debug('@@ asmnt:'+asmnt);
		//	if (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()
		//		|| (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId() && asmnt.ParentAssessment__c == null)){
		//		system.assertEquals(true,asmnt.LongTermDeletionDate__c != null);
		//	}
		//	else{
		//		system.assertEquals(true,asmnt.LongTermDeletionDate__c == null);
		//	}	
		//}

		
		//System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[0].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(36)));
		//System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[1].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(30)));
		//System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[2].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(18)));
		//System.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[3].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
		//system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[4].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
		//system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[5].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));      

	}
		
}