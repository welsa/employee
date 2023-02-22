@isTest
private class AspisBatch_NewBSAccountUpdate_TEST
/*
----------------------------------------------------------------------
-- - Name          : AspisBatch_NewCommunityUserCreation_TEST
-- - Author        : AMI

-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- 19-SEP-2018  AMI   1.0      Initial version
----------------------------------------------------------------------
*/
{
	static list <User> userList;
	static List <Account> lstAccount;
	static List <Contact> lstContact;

	static
	{
		//initialising user
		userList 											= new list <User>{TestFactory.createUser('adminUserNewBSAccountUpdate'),
																				TestFactory.createUser('bsUserNewBSAccountUpdatev1'),
																				TestFactory.createUser('bsUserNewBSAccountUpdatev2'),
																				TestFactory.createUser('bsUserNewBSAccountUpdatev3')};
		insert userList;

		system.runAs(userList[0]){
			//creating BS account
			lstAccount 										= new List <Account>{TestFactory.createAccountBodyshop('BodyShopv1', 'BE'),
																					TestFactory.createAccountBodyshop('BodyShopv2', 'FR'),
																					TestFactory.createAccountBodyshop('BodyShopv3', 'FR')};

			lstAccount[0].Communities_Target_Profile__c 	= system.label.CommunitiesTargetProfile;
			lstAccount[0].CommunitiesBatchNewBtoMigrate__c 	= true;
			lstAccount[0].ReferenceNumber__c 				= 'BE000000v0';
			lstAccount[0].Assessment_Tool__c 				= ASPISConstants.assToolsBEINFORMEX;
	
			lstAccount[1].Communities_Target_Profile__c 	= system.label.CommunitiesTargetProfile;
			lstAccount[1].CommunitiesBatchNewBtoMigrate__c 	= true;
			lstAccount[1].ReferenceNumber__c 				= 'FR0000000001';//WCH 23/12/2020 C-004120
			lstAccount[1].Assessment_Tool__c 				= ASPISConstants.assToolsFRSIDEXA;

			lstAccount[2].Communities_Target_Profile__c 	= system.label.CommunitiesTargetProfile;
			lstAccount[2].CommunitiesBatchNewBtoMigrate__c 	= true;
			lstAccount[2].ReferenceNumber__c 				= 'FR0000000002';//WCH 23/12/2020 C-004120
			lstAccount[2].Assessment_Tool__c 				= ASPISConstants.assToolsFRSIDEXA + ';'+ ASPISConstants.assToolsFRDIVA;
		
			insert lstAccount;

			//creating contact
			lstContact 									= new List <Contact>{new Contact(AccountId = lstAccount[0].Id,
																						 LastName = 'BodyShopv1'),
																				new Contact(AccountId = lstAccount[1].Id,
																						    LastName = 'BodyShopv2'),
																				new Contact(AccountId = lstAccount[2].Id,
																						    LastName = 'BodyShopv3')};

			insert lstContact;

			string BypassTrigger 						= 'AccountTrigger;AssessmentTrigger;CaseTriggerHandler;DetailRuleTrigger;' 
														+ 'DiscountTrigger;InvoiceTrigger;MasterRuleTrigger;OfferTrigger;'
														+ 'OrderLineTrigger;PrerequisiteOrderTrigger;PurchaseOrderTrigger;'
														+ 'UserTrigger';
			//inserting bypass
			Bypass__c customSetting 					= new Bypass__c(Name = 'testBypass',
															            SetupOwnerId = userList[0].Id,
															            BypassValidationRules__c = true,
															            BypassWorkflows__c = true,
															            BypassTrigger__c = BypassTrigger);

            Database.upsert(customSetting, Bypass__c.Name.getDescribe().getSObjectField(), false);
		}//end system.runAs
	}//end static

	@isTest static void NewBSAccountUpdateTEST(){
		system.runAs(userList[0]){

			map <id,id> mapConIdCommUserId 				= new map <id,id>();
			list <id> lstUserId 						= new list <id>();

			for(User us : userList){
				lstUserId.add(us.id);
			}

			for(Contact con : lstContact){
				mapConIdCommUserId.put(con.id,lstUserId[0]);
			}
			
			//start test
			Test.startTest();
				AspisBatch_NewBSAccountUpdate batch = new AspisBatch_NewBSAccountUpdate(mapConIdCommUserId);
				Database.executeBatch(batch);
			Test.stopTest();

			//assert
			List<Account> lstAccAssert = [SELECT id FROM Account WHERE id IN :lstAccount and CommunitiesBatchNewBtoMigrate__c = false];
			System.assertEquals(3,lstAccAssert.size());
		}
	}
}