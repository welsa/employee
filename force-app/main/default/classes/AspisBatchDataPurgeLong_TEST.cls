/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-15-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class AspisBatchDataPurgeLong_TEST
{
/*
----------------------------------------------------------------------
-- - Name          : AspisBatchDataPurgeLong_TEST
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
	static List<Case__c> caseList;


	static {
		// initialising variables
		l_Accounts = new list<Account>();
		l_Assessments = new list<Assessment__c>();
		l_users = new list<user>();
		l_purchaseOrders = new list<PurchaseOrder__c>();
		l_SalesOrders = new list<PrerequisiteOrder__c>();		
		l_Invoices = new list<Invoice__c>();
		caseList = new list<Case__c>();
		Account bs2;
		Account dist1;

		// creating user
		User user1 = TestFactory.createUserInterface('ScUserInterfaceFR');
		l_users.add(user1);

		User user2 = TestFactory.createUser('ScUserTest');
		l_users.add(user2);

		User user3 = TestFactory.createUserInterface('ScUserInterfaceDE');
		user3.CountryCode = 'DE';
		user3.userRoleId = [SELECT Id from UserRole where DeveloperName='DE_AlphaScale'].Id;
		l_users.add(user3);

		insert l_users;
		List<String> listValidStatus = (system.label.PurgeLongValidStatus).split(';');

		System.DEBUG('@@ l_users:'+l_users);

		system.runas(l_users[1]){
			// initialising dates
			DateTime myDateTime = datetime.newInstance(2015, 2, 17);
			Date myDate = date.newInstance(2015, 2, 17);

			// Create several accounts
			bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'DE');
			//bs2.ContactUser__c = l_users[1].Id;
			l_Accounts.add(bs2);

			dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'ES');
			//l_Accounts.add(dist1);

			
			//insert l_Accounts;	

			defaultHours = [SELECT	Id
							FROM	BusinessHours 
							WHERE	IsDefault = true];

			countryCodeMappingList = new List<CountryCodeInformationsMapping__c>
			{
				TestFactory.createCountryCodeInformationsMapping('DEFAULT', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('FR', defaultHours.Id),
				TestFactory.createCountryCodeInformationsMapping('DE', defaultHours.Id)
			};
			
			
			countryCodeMappingList[1].ValidityOfEligibleAssessment__c		= -20;
			countryCodeMappingList[1].ValidityOfNonEligibleAssessement__c	= -18;

			
			countryCodeMappingList[2].ValidityOfEligibleAssessment__c		= -36;
			countryCodeMappingList[2].ValidityOfNonEligibleAssessement__c	= -30;
			
			insert countryCodeMappingList;	


		}//END TEST USER


		system.runas(l_users[2]){

			bs2 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'DE');
			//bs2.ContactUser__c = l_users[1].Id;
			insert bs2;

			dist1 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'DE');
			insert dist1;

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
			ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass3.Status__c  = 'Rejected';	
			ass3.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass3);


			Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs2);	
			ass4.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass4.Status__c  = 'CLOSEDKO';	
			ass4.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass4);

			Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs2);	
			ass5.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass5.Status__c  = 'closed';	
			ass5.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass5);

			Assessment__c ass6= TestFactory.createAssessment('ASSESS_TEST-0006', bs2);	
			ass6.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass6.Status__c  = 'CANCELED';	
			ass6.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass6);

			Assessment__c ass7 = TestFactory.createAssessment('ASSESS_TEST-0007', bs2);	
			ass7.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass7.Status__c  = 'NEW';	
			ass7.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass7);

			Assessment__c ass8 = TestFactory.createAssessment('ASSESS_TEST-0008', bs2);	
			ass8.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass8.Status__c  = 'Ready';	
			ass8.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass8);

			Assessment__c ass9 = TestFactory.createAssessment('ASSESS_TEST-0009', bs2);	
			ass9.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass9.Status__c  = 'SUBSTITUTION';	
			ass9.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass9);

			Assessment__c ass10 = TestFactory.createAssessment('ASSESS_TEST-00010', bs2);	
			ass10.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass10.Status__c  = 'checked';	
			ass10.TECH_EntityCountryCode__c = 'DE';
			l_Assessments.add(ass10);

			Assessment__c ass11 = TestFactory.createAssessment('ASSESS_TEST-00011', bs2);
			ass11.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass11.Status__c  = 'INDELIVERY';
			ass11.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass11);

			Assessment__c ass12 = TestFactory.createAssessment('ASSESS_TEST-00012', bs2);
			ass12.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
			ass12.Status__c  = 'INVOICED';
			ass12.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass12);


			Assessment__c ass13 = TestFactory.createAssessment('ASSESS_TEST-00013', bs2);
			ass13.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
			ass13.Status__c  = 'INVOICED';
			ass13.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass13);

			insert l_Assessments;


			list<Assessment__c> lstassChildren = new list <Assessment__c>();
			system.debug('## l_Assessments: ' + l_Assessments.size() + l_Assessments );
			
			integer counter = 0;
			for (Assessment__c assParent: l_Assessments){
				setAsmnt.add(assParent.Id);
				for (integer i = 1; i <= 2; i++){

					Assessment__c ass = TestFactory.createAssessment('ASSESS_TEST-000' , l_Accounts[0]);	
					ass.ParentAssessment__c = assParent.Id;
					//ass1.LongTermDeletionDate__c = system.now() - 10 ;
					if (assParent.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId())
					{
						ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();	
						system.debug('@@counter: '+counter);
						if (counter < 9){
							ass.Status__c = listValidStatus[counter];	
						}	
						if (counter == 9){
							if (i==1){
								ass.Status__c = 'INDELIVERY'; 	
							}	
							else{
								ass.Status__c = 'CLOSED';
							}
						}
						if (counter == 10){
							if (i==1){
								ass.Status__c = 'INVOICED'; 	
							}	
							else{
								ass.Status__c = 'CLOSEDOK';
							}
						}				
					}
					else{
						ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId();
					}
					
					lstassChildren.add(ass);
				}
				counter++;
			}
			insert lstassChildren;
			system.debug('## lstassChildren: ' + lstassChildren.size() + lstassChildren );


			for (Assessment__c assChildren: lstassChildren){
				//for (integer i = 1; i <= 2; i++){
					// Create severals Sales Orders
					PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(assChildren, bs2, 'DELIVEREDCONFIRMED');
					l_SalesOrders.add(so1);
					Case__c c =	new Case__c(Account_Name__c = bs2.Id,
							Assesment__c = assChildren.Id,
							SubmittedBy__c = l_users[2].ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',																						
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM');
					caseList.add(c);
				//}
			}
			
			insert l_SalesOrders;
			insert caseList;
			system.debug('## l_SalesOrders: ' + l_SalesOrders.size() + l_SalesOrders );

			integer count = 0;
			for (integer i=0; i< 26; i++){
				//for (PrerequisiteOrder__c so: l_SalesOrders){
					// Create severals Sales Orders
					if (math.mod(i,2) == 0 && i != 0){
						count++;
					}

					system.debug('@@ count: '+count);
					PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(lstassChildren[i], l_SalesOrders[i], bs2,dist1, 'DELIVEREDCONFIRMED');
					l_purchaseOrders.add(po1_1);
				//}
			}
			
			insert l_purchaseOrders;
			system.debug('######### inserted l_purchaseOrders:');
			system.debug('## l_purchaseOrders: ' + l_purchaseOrders.size() + l_purchaseOrders );


			for (PurchaseOrder__c po: l_purchaseOrders){
				//for (integer i = 1; i <= 2; i++){
					// Create severals Sales Orders
					Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 14.40, 'RECEIVED', po);
					l_Invoices.add(inv1);

				//}
			}
			insert l_Invoices;
			system.debug('## l_Invoices: ' + l_Invoices.size() + l_Invoices );

		}//END USER DE

		system.runas(l_users[0]){

			account bs3 = TestFactory.createAccountBodyshop('BodyShop_ScTest2', 'FR');
			//bs2.ContactUser__c = l_users[1].Id;
			insert bs3;

			account dist2 = TestFactory.createAccountDistributor('Distributor_ScTest1', 'FR');
			insert dist2;


			l_Assessments = new List<Assessment__c>();
			Assessment__c ass3 = TestFactory.createAssessment('ASSESS_TEST-0003', bs3);
			ass3.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass3.Status__c  = 'Rejected';	
			ass3.TECH_EntityCountryCode__c = 'FR';
			ass3.Assessment_to_be_deleted__c=true;		
			l_Assessments.add(ass3);

			
			Assessment__c ass4 = TestFactory.createAssessment('ASSESS_TEST-0004', bs3);
			ass4.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass4.Status__c  = 'CLOSEDKO';
			ass4.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass4);	

			Assessment__c ass5 = TestFactory.createAssessment('ASSESS_TEST-0005', bs3);
			ass5.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass5.Status__c  = 'CLOSEDOK';
			ass5.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass5);	

			Assessment__c ass6 = TestFactory.createAssessment('ASSESS_TEST-0006', bs3);
			ass6.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass6.Status__c  = 'closed';
			ass6.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass6);	

			Assessment__c ass7 = TestFactory.createAssessment('ASSESS_TEST-0007', bs3);
			ass7.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass7.Status__c  = 'CANCELED';
			ass7.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass7);	

			Assessment__c ass8 = TestFactory.createAssessment('ASSESS_TEST-0008', bs3);
			ass8.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass8.Status__c  = 'NEW';
			ass8.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass8);	

			Assessment__c ass9 = TestFactory.createAssessment('ASSESS_TEST-0009', bs3);
			ass9.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass9.Status__c  = 'Ready';
			ass9.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass9);	

			Assessment__c ass10 = TestFactory.createAssessment('ASSESS_TEST-00010', bs3);
			ass10.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass10.Status__c  = 'SUBSTITUTION';
			ass10.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass10);	

			Assessment__c ass11 = TestFactory.createAssessment('ASSESS_TEST-0004', bs3);
			ass11.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass11.Status__c  = 'checked';
			ass11.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass11);	

			Assessment__c ass12 = TestFactory.createAssessment('ASSESS_TEST-00012', bs3);
			ass12.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass12.Status__c  = 'INDELIVERY';
			ass12.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass12);

			Assessment__c ass13 = TestFactory.createAssessment('ASSESS_TEST-00013', bs3);
			ass13.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
			ass13.Status__c  = 'INVOICED';
			ass13.TECH_EntityCountryCode__c = 'FR';	
			l_Assessments.add(ass13);

			Assessment__c ass14 = TestFactory.createAssessment('ASSESS_TEST-00014', bs3);
			ass14.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
			ass14.Status__c  = 'CLOSEDOK';
			ass14.TECH_EntityCountryCode__c = 'FR';	
			ass14.Assessment_to_be_deleted__c=true;	
			l_Assessments.add(ass14);	
		
			insert l_Assessments;

			ass5 = l_Assessments[2];
			ass5.ParentAssessment__c = 	l_Assessments[0].Id;
			update ass5;

			list<Assessment__c> lstassChildren = new list <Assessment__c>();
			system.debug('@@@ l_Assessments: ' + l_Assessments.size() + l_Assessments );
			for (Assessment__c assParent: l_Assessments){
				setAsmnt.add(assParent.Id);
				//for (integer i = 1; i <= 2; i++){

					Assessment__c ass = TestFactory.createAssessment('ASSESS_TEST-000' , l_Accounts[0]);	
					ass.ParentAssessment__c = assParent.Id;
					//ass1.LongTermDeletionDate__c = system.now() - 10 ;
					if (assParent.RecordTypeId == Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId())
					{
						ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Claim Order').getRecordTypeId();						
					}
					else{
						ass.RecordTypeId = Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('NewAssessment').getRecordTypeId();
					}

					lstassChildren.add(ass);

				//}
			}

			insert lstassChildren;
			system.debug('@@@ lstassChildren: ' + lstassChildren.size() + lstassChildren );


			l_SalesOrders = new list<PrerequisiteOrder__c>();
			caseList = new list<Case__c>();
			for (Assessment__c assChildren: lstassChildren){
				//for (integer i = 1; i <= 2; i++){
					// Create severals Sales Orders
					PrerequisiteOrder__c so1 = TestFactory.createSalesOrder(assChildren, bs3, 'DELIVEREDCONFIRMED');
					l_SalesOrders.add(so1);

					Case__c c =	new Case__c(Account_Name__c = bs3.Id,
							Assesment__c = assChildren.Id,
							//SubmittedBy__c = l_users[0].ID,
							Description__c = 'TEST',
							CountryCode__c = 'FR',
							Origin__c = 'APPLICATION',
							Priority__c = 'LOW',																						
							Status__c = 'New',
							Subject__c = 'TEST',
							Type__c = 'PROBLEM');
					caseList.add(c);
				//}

			

			}
			insert l_SalesOrders;
			system.debug('## caseList: ' + caseList.size() + caseList );

			insert caseList;
			system.debug('## l_SalesOrders: ' + l_SalesOrders.size() + l_SalesOrders );


			l_purchaseOrders = new list<PurchaseOrder__c>();

			integer count = 0;
			for (integer i=0; i< 12; i++){
				//for (PrerequisiteOrder__c so: l_SalesOrders){
					// Create severals Sales Orders
					if (math.mod(i,2) == 0 && i != 0){
						count++;
					}

					system.debug('@@ count: '+count);
					PurchaseOrder__c po1_1 = TestFactory.createPurchaseOrder(lstassChildren[i], l_SalesOrders[i], bs3,dist2, 'DELIVEREDCONFIRMED');
					l_purchaseOrders.add(po1_1);
				//}
			}
			
			insert l_purchaseOrders;
			system.debug('######### inserted l_purchaseOrders:');
			system.debug('## l_purchaseOrders: ' + l_purchaseOrders.size() + l_purchaseOrders );



			l_Invoices = new list<Invoice__c>();
			for (PurchaseOrder__c po: l_purchaseOrders){
				//for (integer i = 1; i <= 2; i++){
					// Create severals Sales Orders
					Invoice__c inv1 = TestFactory.createDistributorCreditNote('INV-2812A', 14.40, 'RECEIVED', po);
					l_Invoices.add(inv1);

				//}
			}
			insert l_Invoices;
			system.debug('## l_Invoices: ' + l_Invoices.size() + l_Invoices );

		}//END USER FR
		
	}


	@isTest
	static void itShould()
	{
		Test.startTest();
			List<Assessment__c> lstAssert = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c,ParentAssessment__c, TECH_EntityCountryCode__c from Assessment__c];
			system.debug('@@ lstAssert: '+lstAssert.size());
			for (Assessment__c asmnt: lstAssert){
				system.debug('@@ asmnt:'+asmnt.RecordType.Name + '; ' +asmnt.Status__c + '; ' + asmnt.LongTermDeletionDate__c);
				if (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()
					|| asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId()
					|| asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()
					){
					system.assertEquals(true,asmnt.LongTermDeletionDate__c != null);
				}
				else{
					system.assertEquals(true,asmnt.LongTermDeletionDate__c == null);
				}	
			}
		
			Database.executeBatch(new AspisBatchDataPurgeLong(), 200);
		

			List<PurchaseOrder__c> listPos = [Select Id, CreatedDate, Assessment__c from PurchaseOrder__c];
			List<Invoice__c> listInvs = [Select Id from Invoice__c ];
			List<PrerequisiteOrder__c> listSos = [Select Id from PrerequisiteOrder__c];
			List<Case__c> listcase = [Select Id from Case__c];
			List<Assessment__c> listAss = [Select Id from Assessment__c];
		Test.stopTest();
			
			system.debug('@@ listAss:'+listAss);

			System.assertEquals(listAss.size(), 63);
			System.assertEquals(listPos.size(), 38);
			System.assertEquals(listInvs.size(), 38);
			System.assertEquals(listSos.size(), 38);
			System.assertEquals(listcase.size(), 38);


	}
		@isTest
	static void test_AspisBatchDataPurgeLong_Cloned()
	{
		Test.startTest();
			List<Assessment__c> lstAssert = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c,ParentAssessment__c, TECH_EntityCountryCode__c from Assessment__c];
			system.debug('@@ lstAssert: '+lstAssert.size());
			for (Assessment__c asmnt: lstAssert){
				system.debug('@@ asmnt:'+asmnt.RecordType.Name + '; ' +asmnt.Status__c + '; ' + asmnt.LongTermDeletionDate__c);
				if (asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_Claim).getRecordTypeId()
					|| asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get(ASPISConstants.ASSESS_RT_DeveloperName_NewAssessment).getRecordTypeId()
					|| asmnt.RecordTypeId ==  Schema.SObjectType.Assessment__c.getRecordTypeInfosByName().get('Substitution Only').getRecordTypeId()
					){
					system.assertEquals(true,asmnt.LongTermDeletionDate__c != null);
				}
				else{
					system.assertEquals(true,asmnt.LongTermDeletionDate__c == null);
				}	
			}

			Database.executeBatch(new AspisBatchDataPurgeLong_Cloned(), 200);
		

			List<PurchaseOrder__c> listPos = [Select Id, CreatedDate, Assessment__c from PurchaseOrder__c];
			List<Invoice__c> listInvs = [Select Id from Invoice__c ];
			List<PrerequisiteOrder__c> listSos = [Select Id from PrerequisiteOrder__c];
			List<Case__c> listcase = [Select Id from Case__c];
			List<Assessment__c> listAss = [Select Id from Assessment__c];
		Test.stopTest();

		System.assertEquals(listAss.size(), 63);
		System.assertEquals(listPos.size(), 38);
		System.assertEquals(listInvs.size(), 38);
		System.assertEquals(listSos.size(), 38);
		System.assertEquals(listcase.size(), 38);
	}
	@isTest
	static void AspisBatchDataPurge2020_TEST()
	{
		Test.startTest();
			List<Assessment__c> lstAssert = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c,ParentAssessment__c, TECH_EntityCountryCode__c,Tech_PurgeVerification2020__c from Assessment__c where Assessment_to_be_deleted__c=true];
			system.debug('@@ lstAssert: '+lstAssert.size());
			for (Assessment__c asmnt: lstAssert){
				system.assertEquals(false,asmnt.Tech_PurgeVerification2020__c);	
			}

		
			Database.executeBatch(new AspisBatchDataPurge2020(), 200);
		

			List<PurchaseOrder__c> listPos = [Select Id, CreatedDate, Assessment__c from PurchaseOrder__c];
			List<Invoice__c> listInvs = [Select Id from Invoice__c ];
			List<PrerequisiteOrder__c> listSos = [Select Id from PrerequisiteOrder__c];
			List<Case__c> listcase = [Select Id from Case__c];
			List<Assessment__c> listAss = [Select Id from Assessment__c];
		Test.stopTest();

		System.assertEquals(listAss.size(), 63);
		System.assertEquals(listPos.size(), 38);
		System.assertEquals(listInvs.size(), 38);
		System.assertEquals(listSos.size(), 38);
		System.assertEquals(listcase.size(), 38);
	}
	@isTest
	static void AspisBatchDataPurge2020_Cloned_TEST()
	{
		Test.startTest();
			List<Assessment__c> lstAssert = [Select Id,LongTermDeletionDate__c, RecordTypeId, RecordType.Name,Status__c,ParentAssessment__c, TECH_EntityCountryCode__c,Tech_PurgeVerification2020__c from Assessment__c where Assessment_to_be_deleted__c=true];
			system.debug('@@ lstAssert: '+lstAssert.size());
			for (Assessment__c asmnt: lstAssert){
				system.assertEquals(false,asmnt.Tech_PurgeVerification2020__c);
			}

		
			Database.executeBatch(new AspisBatchDataPurge2020_Cloned(), 200);
		

			List<PurchaseOrder__c> listPos = [Select Id, CreatedDate, Assessment__c from PurchaseOrder__c];
			List<Invoice__c> listInvs = [Select Id from Invoice__c ];
			List<PrerequisiteOrder__c> listSos = [Select Id from PrerequisiteOrder__c];
			List<Case__c> listcase = [Select Id from Case__c];
			List<Assessment__c> listAss = [Select Id from Assessment__c];
		Test.stopTest();

		System.assertEquals(listAss.size(), 63);
		System.assertEquals(listPos.size(), 38);
		System.assertEquals(listInvs.size(), 38);
		System.assertEquals(listSos.size(), 38);
		System.assertEquals(listcase.size(), 38);
	}
}