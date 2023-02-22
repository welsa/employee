/*************************************************************************************
Class Name - TestASPISBatchBodyShopCredit
Version - 1.0
Created Date - 08 Jul 2015
Function - TestClass to ASPISBatchBodyShopCredit

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Yudish R  	08/07/2015 	Original Version
*************************************************************************************/
@isTest
private class TestASPISBatchBodyShopCredit {
	/*
	static User userAdmin;
	static list<Account> accounts;
	static list<Assessment__c> assessments;
	static list<PrerequisiteOrder__c> prerequisiteOrders;
	static list<Invoice__c> invoices;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
	static map <String,Id> invRecordTypeMap = new map <String,Id>();
	static map <String,Id> proRecordTypeMap = new map <String,Id>();

	static{
		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
		proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);
		invRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_INVOICE);

		userAdmin = new User(Username = 'testclass@test.com',
                                        LastName = 'testuser',
                                        LanguageLocaleKey = 'en_US',
                                        FirstName = 'test',
                                        Email = 'test@test.com',
                                        Alias = 'test',
                                        TimeZoneSidKey = 'Europe/Dublin',
                                        LocaleSidKey = 'en_US',
                                        EmailEncodingKey = 'UTF-8',
                                        ProfileId = ASPISConstants.getProfileAdminId());
        ASPISTestUtils.generateTestUser(userAdmin);
        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        //ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestASPISBatchBodyShopCredit',userAdmin.Id);

        system.runas(userAdmin){
            // insert accounts
            accounts = new list<Account>{
                new Account(Name='BodyShop_ScTest1'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '1263'
                    ,ContactEmail__c = 'bt1@gmail.com'
                ),
                new Account(Name='BodyShop_ScTest2'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '12634'
                    ,ContactEmail__c = 'bt2@gmail.com'
                )
            };
            //insert accounts;
            ASPISTestUtils.generateAccount (accounts);

			//assessments
            assessments = new list<Assessment__c>{
                new Assessment__c(Name='ASSESS_TEST-0001'
                    ,AssessmentNumber__c = 'ASSESS_TEST-0001'
                    ,BodyShop__c = accounts[0].Id
                    ,Entity__c = 'AXA Direct'
                    ,MissionNumber__c = '01'
                    ,PortfolioAgentCode__c = '355'
                    ,AssessmentID__c = '0912'
                    ,TechExternalId__c = '233'
                )

            };
            //insert assessments ;
            ASPISTestUtils.generateAssessment (assessments);

			//PrerequisiteOrder
            prerequisiteOrders= new list<PrerequisiteOrder__c>{
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                ),
                new PrerequisiteOrder__c(BodyShop__c = accounts[1].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                )
            };
            //insert prerequisiteOrders;
            ASPISTestUtils.generatePrerequisiteOrder (prerequisiteOrders);
            
            //
            invoices = new list<Invoice__c>{
            	//bodyshop[0]
            	new Invoice__c(
            		BodyShop__c=accounts[0].Id
            		,Status__c = ASPISConstants.INV_STATUS_SENT
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[0].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_Draft)
            		,TotalNet__c = 98
            	),
            	new Invoice__c(
                    BodyShop__c=accounts[0].Id
            		,Status__c = ASPISConstants.INV_STATUS_SENT
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[0].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_Draft)
            		,TotalNet__c = 71
            	),
				new Invoice__c(
            		BodyShop__c=accounts[0].Id
            		,Status__c = ASPISConstants.INV_STATUS_PAID
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[0].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_Draft)
            		,TotalNet__c = 98
            	),
            	new Invoice__c(
            		BodyShop__c=accounts[0].Id
            		,Status__c = ASPISConstants.INV_STATUS_PAID
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[0].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_Draft)
            		,TotalNet__c = 200
            	),
            	new Invoice__c(
            		BodyShop__c=accounts[0].Id
            		,Status__c = ASPISConstants.INV_STATUS_SENT
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[0].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_CreditNote)
            		,TotalNet__c = 50
            	),

            	//bodyshop[1]
            	new Invoice__c(
            		BodyShop__c=accounts[1].Id
            		,Status__c = ASPISConstants.INV_STATUS_SENT
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[1].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_Draft)
            		,TotalNet__c = 213
            	),
            	new Invoice__c(
            		BodyShop__c=accounts[1].Id
            		,Status__c = ASPISConstants.INV_STATUS_PAID
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[1].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_Draft)
            		,TotalNet__c = 89
            	),
            	new Invoice__c(
            		BodyShop__c=accounts[1].Id
            		,Status__c = ASPISConstants.INV_STATUS_SENT
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[1].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_Draft)
            		,TotalNet__c = 250
            	),
            	new Invoice__c(
            		BodyShop__c=accounts[1].Id
            		,Status__c = ASPISConstants.INV_STATUS_SENT
            		,Assessment__c =  assessments[0].Id
            		,PrerequisiteOrder__c = prerequisiteOrders[1].id
            		,RecordTypeId = invRecordTypeMap.get(ASPISConstants.INVOICE_RT_DeveloperName_CreditNote)
            		,TotalNet__c = 150
            	)
            };
            //insert invoices;
            ASPISTestUtils.generateInvoice(invoices);
        }
	}

	@isTest static void test_BatchBSCredit() {
		Test.startTest();
		    ASPISBatchBodyShopCredit bsCredit = new ASPISBatchBodyShopCredit();
		    ID batchprocessid = Database.executeBatch(bsCredit);
	    Test.StopTest();
		
		list<Account> accAssertList = [select Id, Name, Credit__c, CreditLimit__c
										from Account where Id IN : accounts
										order by Name asc];
        //system.debug('////accAssertList: '+accAssertList);

        System.AssertEquals(119, accAssertList[0].Credit__c);
        System.AssertEquals(313, accAssertList[1].Credit__c);

	}
	*/
	
}