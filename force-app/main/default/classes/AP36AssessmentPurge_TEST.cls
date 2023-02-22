/*
  ----------------------------------------------------------------------
  -- - Name          : AP36AssessmentPurge_TEST
  -- - Author        : ABT
  -- - Description   : Test class for AP36AssessmentPurge
  --
  -- Maintenance History:
  --
  -- Date         	Name  Version  	Remarks
  -- -----------  	----  -------  	---------------------------------------
  -- 02-MAY-2017	ABT		1.0    	Initial version
  ----------------------------------------------------------------------
  **********************************************************************
*/
@isTest
private class AP36AssessmentPurge_TEST
{
	static User adminUser;
	static BusinessHours defaultHours;
	static List<CountryCodeInformationsMapping__c> countryCodeMappingList;
	static List<Account> accountList;
	static List<Assessment__c> assessmentList;

	static
	{
		adminUser = TestFactory.createUser('adminUser');
		insert adminUser;

		System.runAs(adminUser)
		{
			defaultHours = [SELECT	Id
							FROM	BusinessHours 
							WHERE	IsDefault = true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('ES', defaultHours.Id)
			};
			
			countryCodeMappingList[1].ValidityOfClaimShoppingList__c		= 1;
			countryCodeMappingList[1].ValidityOfClaimOrders__c				= 1;
			countryCodeMappingList[1].ValidityOfEligibleAssessment__c		= 24;
			countryCodeMappingList[1].ValidityOfNonEligibleAssessement__c	= 20;

			countryCodeMappingList[2].ValidityOfClaimShoppingList__c		= 1;
			countryCodeMappingList[2].ValidityOfClaimOrders__c				= 1;
			countryCodeMappingList[2].ValidityOfEligibleAssessment__c		= 24;
			countryCodeMappingList[2].ValidityOfNonEligibleAssessement__c	= 20;
			
			insert countryCodeMappingList;

			accountList = new List<Account>
			{
				TestFactory.createAccountBodyshop('FR_BodyShop_1', 'FR'),
				TestFactory.createAccountDistributor('FR_Distributor_1', 'FR'),

				TestFactory.createAccountBodyshop('ES_BodyShop_1', 'ES'),
				TestFactory.createAccountDistributor('ES_Distributor_1', 'ES'),

				TestFactory.createAccountBodyshop('DE_BodyShop_1', 'DE'),
				TestFactory.createAccountDistributor('DE_Distributor_1', 'DE')
			};

			insert accountList;

			assessmentList = new List<Assessment__c>
			{
				TestFactory.createAssessment('FR Claim Assessment', accountList[0]),
				TestFactory.createAssessment('FR Claim Order Order Assessment', accountList[0]),

				TestFactory.createAssessment('FR Claim Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Crash Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Shopping Claim Order Order Assessment', accountList[0]),
				
				// ES
				TestFactory.createAssessment('ES Claim Assessment', accountList[2]),
				TestFactory.createAssessment('ES Claim Order Order Assessment', accountList[2]),

				TestFactory.createAssessment('ES Claim Shopping Assessment', accountList[2]),
				TestFactory.createAssessment('ES Crash Shopping Assessment', accountList[2]),
				TestFactory.createAssessment('ES Shopping Claim Order Order Assessment', accountList[2]),

				// DE
				TestFactory.createAssessment('DE Claim Assessment', accountList[4]),
				TestFactory.createAssessment('DE Claim Order Order Assessment', accountList[4]),

				TestFactory.createAssessment('DE Claim Shopping Assessment', accountList[4]),
				TestFactory.createAssessment('DE Crash Shopping Assessment', accountList[4]),
				TestFactory.createAssessment('DE Shopping Claim Order Order Assessment', accountList[4])
			};

			Id claimOrderId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id claimId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id crashId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Crash').getRecordTypeId();

			assessmentList[0].RecordTypeId 				= claimId;
			assessmentList[0].TECH_EntityCountryCode__c = 'FR';

			assessmentList[1].RecordTypeId 				= claimOrderId;
			assessmentList[1].TECH_EntityCountryCode__c = 'FR';
			assessmentList[1].OrderOrigin__c 			= 'Order';

			// ----------------------------------------------------
			assessmentList[2].RecordTypeId 				= claimId;
			assessmentList[2].TECH_EntityCountryCode__c = 'FR';
			assessmentList[2].isShoppingList__c 		= true;

			assessmentList[3].RecordTypeId 				= crashId;
			assessmentList[3].TECH_EntityCountryCode__c = 'FR';
			assessmentList[3].isShoppingList__c 		= true;

			assessmentList[4].RecordTypeId 				= claimOrderId;
			assessmentList[4].TECH_EntityCountryCode__c = 'FR';
			assessmentList[4].isShoppingList__c 		= true;
			assessmentList[4].OrderOrigin__c 			= 'Order';

			// ES Assessments

			assessmentList[5].RecordTypeId 				= claimId;
			assessmentList[5].TECH_EntityCountryCode__c = 'ES';

			assessmentList[6].RecordTypeId 				= claimOrderId;
			assessmentList[6].TECH_EntityCountryCode__c = 'ES';
			assessmentList[6].OrderOrigin__c 			= 'Order';

			// ----------------------------------------------------
			assessmentList[7].RecordTypeId 				= claimId;
			assessmentList[7].TECH_EntityCountryCode__c = 'ES';
			assessmentList[7].isShoppingList__c 		= true;

			assessmentList[8].RecordTypeId 				= crashId;
			assessmentList[8].TECH_EntityCountryCode__c = 'ES';
			assessmentList[8].isShoppingList__c 		= true;

			assessmentList[9].RecordTypeId 				= claimOrderId;
			assessmentList[9].TECH_EntityCountryCode__c = 'ES';
			assessmentList[9].isShoppingList__c 		= true;
			assessmentList[9].OrderOrigin__c 			= 'Order';

			// DE Assessments

			assessmentList[10].RecordTypeId					= claimId;
			assessmentList[10].TECH_EntityCountryCode__c	= 'DE';

			assessmentList[11].RecordTypeId 				= claimOrderId;
			assessmentList[11].TECH_EntityCountryCode__c	= 'DE';
			assessmentList[11].OrderOrigin__c 				= 'Order';

			// ----------------------------------------------------
			assessmentList[12].RecordTypeId 				= claimId;
			assessmentList[12].TECH_EntityCountryCode__c 	= 'DE';
			assessmentList[12].isShoppingList__c 			= true;

			assessmentList[13].RecordTypeId 				= crashId;
			assessmentList[13].TECH_EntityCountryCode__c 	= 'DE';
			assessmentList[13].isShoppingList__c 			= true;

			assessmentList[14].RecordTypeId 				= claimOrderId;
			assessmentList[14].TECH_EntityCountryCode__c 	= 'DE';
			assessmentList[14].isShoppingList__c 			= true;
			assessmentList[14].OrderOrigin__c 				= 'Order';

			insert assessmentList;

			assessmentList[1].ParentAssessment__c = assessmentList[0].Id;
			assessmentList[3].ParentAssessment__c = assessmentList[2].Id;
			assessmentList[4].ParentAssessment__c = assessmentList[2].Id;

			assessmentList[6].ParentAssessment__c = assessmentList[5].Id;
			assessmentList[8].ParentAssessment__c = assessmentList[7].Id;
			assessmentList[9].ParentAssessment__c = assessmentList[7].Id;

			assessmentList[11].ParentAssessment__c = assessmentList[10].Id;
			assessmentList[13].ParentAssessment__c = assessmentList[12].Id;
			assessmentList[14].ParentAssessment__c = assessmentList[12].Id;

			update assessmentList;
		}
	}

	@isTest static void insertAssessment_TEST()
	{
		System.runAs(adminUser)
		{
			List<Assessment__c> assessmentToInsertList = new List<Assessment__c>
			{
				TestFactory.createAssessment('FR Claim Assessment', accountList[0]),
				TestFactory.createAssessment('FR Claim Order Order Assessment', accountList[0]),

				TestFactory.createAssessment('FR Claim Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Crash Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('FR Shopping Claim Order Order Assessment', accountList[0]),
				
				
				TestFactory.createAssessment('ES Claim Assessment', accountList[0]),
				TestFactory.createAssessment('ES Claim Order Order Assessment', accountList[0]),

				TestFactory.createAssessment('ES Claim Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('ES Crash Shopping Assessment', accountList[0]),
				TestFactory.createAssessment('ES Shopping Claim Order Order Assessment', accountList[0])
			};

			Id claimOrderId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();
			Id claimId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			Id crashId 		= Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Crash').getRecordTypeId();

			assessmentToInsertList[0].RecordTypeId 				= claimId;
			assessmentToInsertList[0].TECH_EntityCountryCode__c = 'FR';

			assessmentToInsertList[1].RecordTypeId 				= claimOrderId;
			assessmentToInsertList[1].TECH_EntityCountryCode__c = 'FR';
			assessmentToInsertList[1].OrderOrigin__c 			= 'Order';

			// ----------------------------------------------------
			assessmentToInsertList[2].RecordTypeId 				= claimId;
			assessmentToInsertList[2].TECH_EntityCountryCode__c = 'FR';
			assessmentToInsertList[2].isShoppingList__c 		= true;

			assessmentToInsertList[3].RecordTypeId 				= crashId;
			assessmentToInsertList[3].TECH_EntityCountryCode__c = 'FR';
			assessmentToInsertList[3].isShoppingList__c 		= true;

			assessmentToInsertList[4].RecordTypeId 				= claimOrderId;
			assessmentToInsertList[4].TECH_EntityCountryCode__c = 'FR';
			assessmentToInsertList[4].isShoppingList__c 		= true;
			assessmentToInsertList[4].OrderOrigin__c 			= 'Order';

			// ES Assessments

			assessmentToInsertList[5].RecordTypeId 				= claimId;
			assessmentToInsertList[5].TECH_EntityCountryCode__c = 'ES';

			assessmentToInsertList[6].RecordTypeId 				= claimOrderId;
			assessmentToInsertList[6].TECH_EntityCountryCode__c = 'ES';
			assessmentToInsertList[6].OrderOrigin__c 			= 'Order';

			// ----------------------------------------------------
			assessmentToInsertList[7].RecordTypeId 				= claimId;
			assessmentToInsertList[7].TECH_EntityCountryCode__c = 'ES';
			assessmentToInsertList[7].isShoppingList__c 		= true;

			assessmentToInsertList[8].RecordTypeId 				= crashId;
			assessmentToInsertList[8].TECH_EntityCountryCode__c = 'ES';
			assessmentToInsertList[8].isShoppingList__c 		= true;

			assessmentToInsertList[9].RecordTypeId 				= claimOrderId;
			assessmentToInsertList[9].TECH_EntityCountryCode__c = 'ES';
			assessmentToInsertList[9].isShoppingList__c 		= true;
			assessmentToInsertList[9].OrderOrigin__c 			= 'Order';
			

			Test.startTest();
				insert assessmentToInsertList;
			Test.stopTest();

			List<Assessment__c> insertedAssessmentList = [SELECT Id, ShortTermDeletionDate__c
														 FROM	Assessment__c
														 WHERE	Id IN: assessmentToInsertList];

			System.assertEquals(null, insertedAssessmentList[0].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[1].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[2].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[3].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[4].ShortTermDeletionDate__c);

			// ES
			System.assertEquals(null, insertedAssessmentList[5].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[6].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[7].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[8].ShortTermDeletionDate__c);
			System.assertNotEquals(null, insertedAssessmentList[9].ShortTermDeletionDate__c);
		}
	}

	@isTest static void updateClaimShoppingList()
	{
		System.runAs(adminUser)
		{
			assessmentList[2].ShortTermDeletionDate__c	= null;
			assessmentList[4].ShortTermDeletionDate__c	= null;
			assessmentList[7].ShortTermDeletionDate__c	= null;
			assessmentList[9].ShortTermDeletionDate__c	= null;
			assessmentList[12].ShortTermDeletionDate__c	= null;
			assessmentList[14].ShortTermDeletionDate__c	= null;

			Test.startTest();
				update assessmentList;
			Test.stopTest();

			List<Assessment__c> updatedAssessmentList = [SELECT Id, ShortTermDeletionDate__c
														 FROM	Assessment__c
														 WHERE	Id IN: assessmentList];

			System.assertEquals(null, updatedAssessmentList[2].ShortTermDeletionDate__c);
			System.assertEquals(null, updatedAssessmentList[3].ShortTermDeletionDate__c);
			System.assertEquals(null, updatedAssessmentList[4].ShortTermDeletionDate__c);

			System.assertEquals(null, updatedAssessmentList[7].ShortTermDeletionDate__c);
			System.assertEquals(null, updatedAssessmentList[8].ShortTermDeletionDate__c);
			System.assertEquals(null, updatedAssessmentList[9].ShortTermDeletionDate__c);

			System.assertEquals(null, updatedAssessmentList[12].ShortTermDeletionDate__c);
			System.assertEquals(null, updatedAssessmentList[13].ShortTermDeletionDate__c);
			System.assertEquals(null, updatedAssessmentList[14].ShortTermDeletionDate__c);
		}
	}


	@isTest static void insertAssesmntFR()
	{
		User user1 = TestFactory.createUserInterface('ScUserInterfaceFR');
		insert  user1;
		system.debug('@@ user1: '+user1);
		system.debug('@@ pro ' + [SELECT Id FROM Profile WHERE Name LIKE '%ASPIS Interface%' LIMIT 1].Id);
		System.runAs(user1)
		{
			system.debug('JSA ' + Userinfo.getProfileId() + ' JSA2 '  + System.label.InterfaceProfileID);
			list<Account> l_Accounts = new list<Account>();
			list<Assessment__c> l_Assessments = new list<Assessment__c>();
			list<user>l_users = new list<user>();
			list<PurchaseOrder__c> l_purchaseOrders = new list<PurchaseOrder__c>();
			list<PrerequisiteOrder__c> l_SalesOrders = new list<PrerequisiteOrder__c>();		
			list<Invoice__c> l_Invoices = new list<Invoice__c>();
			set<Id> setAsmnt = new set<Id>();
			//Account bs3;
			//Account dist2;
			account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
			//bs2.ContactUser__c = l_users[1].Id;
			insert bs3;
			l_Accounts.add(bs3);


			account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
			insert dist2;

			system.debug('JSA ' + Userinfo.getProfileId() + ' JSA2 '  + System.label.InterfaceProfileID);
			l_Assessments = new List<Assessment__c>();
			Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs3);
			ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass3.Status__c  = 'Rejected';	
			ass3.TECH_EntityCountryCode__c = 'FR';		
			l_Assessments.add(ass3);

			
			Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs3);
			ass4.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass4.Status__c  = 'CLOSEDKO';
			ass4.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass4);	

			Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs3);	
			ass5.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass5.Status__c  = 'CLOSEDOK';
			ass5.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass5);	

			Assessment__c ass6 = TestFactory.createAssessment('ASSESS_TEST-0006', bs3);	
			ass6.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
			ass6.Status__c  = 'CLOSEDOK';
			ass6.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass6);	

		
			insert l_Assessments;

			system.debug('JSA ' + Userinfo.getProfileId() + ' JSA2 '  + System.label.InterfaceProfileID);
			list<Assessment__c> lstassChildren = new list <Assessment__c>();
			system.debug('## l_Assessments: ' + l_Assessments.size() + l_Assessments );
			for (Assessment__c assParent: l_Assessments){
				setAsmnt.add(assParent.Id);
				for (integer i = 1; i <= 2; i++){

					Assessment__c ass = TestFactory.createAssessment('ASSESS_TEST-000' + i, l_Accounts[0]);	
					ass.ParentAssessment__c = assParent.Id;
					//ass1.LongTermDeletionDate__c = system.now() - 10 ;
					if (assParent.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId())
					{
						ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();						
					}
					else if (assParent.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId()){
						ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
					}
					else if (assParent.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()){
						ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
					}

					lstassChildren.add(ass);

				}
			}

			Test.startTest();
				insert lstassChildren;
				//Set<Id> setAsmnt = (new Map<Id,Assessment__c>(lstassChildren)).keySet();
				system.debug('## lstassChildren: ' + lstassChildren.size() + lstassChildren );
				system.debug('## l_Assessments: ' + l_Assessments.size() + l_Assessments );
			Test.stopTest();

			List<Assessment__c> updatedAssessmentList = [SELECT LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c,ParentAssessment__c, TECH_EntityCountryCode__c
														 FROM	Assessment__c where (Id in :lstassChildren or Id in: l_Assessments)
														];

			for (Assessment__c asmnt: updatedAssessmentList){
				system.debug('@@ asmnt:'+asmnt.RecordType.Name + '; ' +asmnt.Status__c + '; ' + asmnt.LongTermDeletionDate__c);
				if (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()
					|| asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId()
					|| asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()){
					system.assertEquals(true,asmnt.LongTermDeletionDate__c != null);
				}
				else{
					system.assertEquals(true,asmnt.LongTermDeletionDate__c == null);
				}	
			}

			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[0].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));  
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[1].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(24)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[2].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(24)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[3].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));   

			
		}//end
	}

	@isTest static void updateAssesmntFR()
	{
		User user1 = TestFactory.createUserInterface('ScUserInterfaceFR');
		insert  user1;
		System.runAs(user1)
		{
			system.debug('JSA ' + Userinfo.getProfileId() + ' JSA2 '  + System.label.InterfaceProfileID);
			list<Account> l_Accounts = new list<Account>();
			list<Assessment__c> l_Assessments = new list<Assessment__c>();
			list<user>l_users = new list<user>();
			list<PurchaseOrder__c> l_purchaseOrders = new list<PurchaseOrder__c>();
			list<PrerequisiteOrder__c> l_SalesOrders = new list<PrerequisiteOrder__c>();		
			list<Invoice__c> l_Invoices = new list<Invoice__c>();
			set<Id> setAsmnt = new set<Id>();
			//Account bs3;
			//Account dist2;
			account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
			//bs2.ContactUser__c = l_users[1].Id;
			insert bs3;
			l_Accounts.add(bs3);


			account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
			insert dist2;

			system.debug('JSA ' + Userinfo.getProfileId() + ' JSA2 '  + System.label.InterfaceProfileID);
			l_Assessments = new List<Assessment__c>();
			Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs3);
			ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass3.Status__c  = 'Rejected';	
			ass3.TECH_EntityCountryCode__c = 'FR';		
			l_Assessments.add(ass3);			
			

			Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs3);	
			ass5.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass5.Status__c  = 'CLOSEDOK';
			ass5.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass5);	

			Assessment__c ass6 = TestFactory.createAssessment('ASSESS_TEST-0006', bs3);	
			ass6.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
			ass6.Status__c  = 'CLOSEDOK';
			ass6.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass6);	

		
			insert l_Assessments;
 
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[0].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[1].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(24)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[2].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20))); 

			l_Assessments[0].Status__c = 'CLOSEDOK';
			l_Assessments[1].Status__c = 'REJECTED';
			l_Assessments[2].Status__c = 'CLOSEDOK';

			Test.startTest();
				update l_Assessments;
				//Set<Id> setAsmnt = (new Map<Id,Assessment__c>(lstassChildren)).keySet();
				
				system.debug('## l_Assessments: ' + l_Assessments.size() + l_Assessments );
			Test.stopTest();
			 
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[0].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
			//HMO -- 26-01-2021
			//system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[1].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20)));
			system.assertEquals(Date.valueOf([Select LongTermDeletionDate__c from Assessment__c where Id =: l_Assessments[2].Id].LongTermDeletionDate__c),Date.valueOf((System.now()).addMonths(20))); 

			
		}//end
	}
}