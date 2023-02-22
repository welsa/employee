/*************************************************************************************
Class Name - TestAP04AssessmentsAllQuoted
Version - 1.0
Created Date - 25 MAY 2015
Function - Test Class for AP04AssessmentsAllQuoted

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* yudish R   05/06/2015   Original Version
*************************************************************************************/
@isTest
private class TestAP04AssessmentsAllQuoted {
	/*
	static list<user> users;
	static list<Account> accounts;
	static list<Assessment__c> assessments;
	static list<PurchaseOrder__c> purchaseOrders;

	static map <String,Id> accRecordTypeMap = new map <String,Id>();

	static {
		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);

		users = new list<User>{ new User(Username = 'testclass@test.com',
			                            LastName = 'testuser',
			                            LanguageLocaleKey = 'en_US',
			                            FirstName = 'test',
			                            Email = 'test@test.com',
			                            Alias = 'test',
			                            TimeZoneSidKey = 'Europe/Dublin',
			                            LocaleSidKey = 'en_US',
			                            EmailEncodingKey = 'UTF-8',
			                            ProfileId = ASPISConstants.getProfileAdminId())
	  	}; 
	  	ASPISTestUtils.generateTestUsers(users);
	  	//insert new Bypass__c(SetupOwnerId =users[0].Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
	  	
	  	system.runas(users[0]){
	  		// insert accounts
            accounts = new list<Account>{
                new Account(Name='BodyShop_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                ),
                new Account(Name='Distributor_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
                )
            };
            ASPISTestUtils.generateAccount (accounts);

            //assessments
            assessments = new list<Assessment__c>{
                new Assessment__c(BodyShop__c = accounts[0].Id)
                ,new Assessment__c(BodyShop__c = accounts[0].Id) 
            };
            
            ASPISTestUtils.generateAssessment (assessments);

            datetime myDate = datetime.newInstance(2015, 2, 17);

			//insert purchase orders
        	purchaseOrders = new list<PurchaseOrder__c>{
        		new PurchaseOrder__c(Distributor__c = accounts[1].Id
                    ,ValidityDate__c=date.today()
                    ,Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                    ,SLAQuotationLevel1__c = mydate.addDays(2)
                    ,SLAQuotationLevel2__c = mydate
                    ,SLAQuotationLevel3__c = mydate.addDays(5)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false
                    ,Assessment__c = assessments[0].Id
                ),
                new PurchaseOrder__c(Distributor__c = accounts[1].Id
                    ,ValidityDate__c=date.today()
                    ,Status__c =ASPISConstants.PUR_ORDER_STATUS_ISSUED
                    ,SLAQuotationLevel1__c = (datetime.now()).addMinutes(10)
                    ,SLAQuotationLevel2__c = (datetime.now()).addMinutes(20)
                    ,SLAQuotationLevel3__c = (datetime.now()).addMinutes(30)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false
                    ,Assessment__c = assessments[0].Id
                ),
                new PurchaseOrder__c(Distributor__c = accounts[1].Id
                    ,ValidityDate__c=date.today()+5
                    ,Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                    ,SLAQuotationLevel1__c = mydate.addDays(2)
                    ,SLAQuotationLevel2__c = mydate
                    ,SLAQuotationLevel3__c = mydate.addDays(5)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false
                    ,Assessment__c = assessments[1].Id
                ),
                 new PurchaseOrder__c(Distributor__c = accounts[1].Id
                    ,ValidityDate__c=date.today()+5
                    ,Status__c = ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                    ,SLAQuotationLevel1__c = (datetime.now()).addMinutes(10)
                    ,SLAQuotationLevel2__c = (datetime.now()).addMinutes(20)
                    ,SLAQuotationLevel3__c = (datetime.now()).addMinutes(30)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false
                    ,Assessment__c = assessments[1].Id
                )
        	};
        	insert purchaseOrders;
		}
	}

	@isTest static void test_updatePo() {
		system.debug('#### Start of method test_updatePo');
		
		system.runAs(users[0]){
			test.starttest();
				purchaseOrders[0].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
				purchaseOrders[2].Status__c = ASPISConstants.PUR_ORDER_STATUS_RESPONDED;
				update purchaseOrders;

		    test.stoptest();

		    List<Assessment__c> asssesmentAssertList = new List<Assessment__c>([select Id,Status__c,MaximumValidityDate__c
																	from Assessment__c
																	where (Id=:assessments[0].Id OR Id=:assessments[1].Id)
																	]);
			System.assertEquals('OFFERING', asssesmentAssertList[0].Status__c);
			
		}
	}
	*/
	
}