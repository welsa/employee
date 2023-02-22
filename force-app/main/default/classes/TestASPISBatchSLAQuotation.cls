/*************************************************************************************
Class Name - TestASPISBatchSLAQuotation
Version - 1.0
Created Date - 12 MAY 2015
Function - TestClass to ASPISBatchSLAQuotation

Modification Log :
-----------------------------------------------------------------------------
* Developer  	Date       	Description
* ---------- 	----------  -----------------------
* Yudish R  	12/05/2015 	Original Version
*************************************************************************************/
@isTest
private class TestASPISBatchSLAQuotation {
/*
	static User userAdmin;
	static list<Account> accounts;
	static list<PurchaseOrder__c> purchaseOrders;
	static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static BusinessHours defaultHours;
    static list<OrderLine__c> orderLines;
	static list<Assessment__c> assessments;

	static{
		accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);

        //Get the default business hours (we might need it)
        defaultHours = [select Id from BusinessHours where IsDefault=true];
        
        //ASPISTestUtils.generateBasicTestData();
        
        userAdmin = new User(Username = 'jean.paul1-testingNewName@test.com'  // checking for UNABLE_TO_LOCK_ROW error in running test parallel
            ,LastName = 'paul'
            ,LanguageLocaleKey = 'en_US'
            ,FirstName = 'jean'
            ,Email = 'jea1n@test.com'
            ,Alias = 'jpa'
            ,TimeZoneSidKey = 'Europe/Dublin'
            ,LocaleSidKey = 'en_US'
            ,EmailEncodingKey = 'UTF-8'
            ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        
        system.runas(userAdmin){
        	//insert accounts
        	accounts = new list<Account>{
        		new Account(Name='Distributor_ScTest1'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
        			,ReferenceNumber__c = '12345'
        			,ContactEmail__c = 'dt1@gmail.com'
        		),
        		new Account(Name='Distributor_ScTest2'
        			,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_Distributor)
        			,ReferenceNumber__c = '123456'
        			,ContactEmail__c = 'dt12@gmail.com'
        		),
				new Account(Name='BodyShop_ScTest122'
                    ,RecordTypeId=accRecordTypeMap.get(ASPISConstants.ACCOUNT_RT_DeveloperName_BodyShop)
                    ,ReferenceNumber__c = '9123'
                    ,ContactEmail__c = 'bt122@gmail.com'
                )
        	};
        	ASPISTestUtils.generateAccount (accounts);

            SLAConfiguration__c slaRecord= new SLAConfiguration__c (BusinessHoursID__c=defaultHours.Id
                ,Name='QuotationAXADirect'
                ,SLALevel1Minute__c=30
                ,SLALevel2Minute__c=60
                ,SLALevel3Minute__c=90
                ,Entity__c= 'AXA Direct'
                ,Object__c = 'Purchase Order'
            );
            insert slaRecord;

            datetime myDate = datetime.newInstance(2015, 2, 17);
			
			assessments = new list<Assessment__c>{new Assessment__c(Name='ASSESS_TEST-0003',
																	AssessmentNumber__c = 'ASSESS_TEST-0003',
																	BodyShop__c = accounts[2].Id,
																	Entity__c = 'AXA Direct',
																	MissionNumber__c = '011',
																	PortfolioAgentCode__c = '3551',
																	AssessmentID__c = '09121',
																	TechExternalId__c = '2331',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='SOURCED'),
	                                                
	                                           		new Assessment__c(Name='ASSESS_TEST-0004',
																	AssessmentNumber__c = 'ASSESS_TEST-0004',
																	BodyShop__c = accounts[2].Id,
																	Entity__c = 'AXA Direct1',
																	MissionNumber__c = '021',
																	PortfolioAgentCode__c = '35451',
																	AssessmentID__c = '59121',
																	QuotationEndTime__c=system.now().adddays(-100),
																	Status__c='SOURCED')
	                
	        };
	            
	        insert assessments;
			
            
        	//insert purchase orders
        	purchaseOrders = new list<PurchaseOrder__c>{
        		new PurchaseOrder__c(Distributor__c = accounts[0].Id
                    ,ValidityDate__c=date.today()
                    ,Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE
                   // ,QuotationTimestampStart__c = mydate
                    ,SLAQuotationLevel1__c = mydate.addDays(2)
                    ,SLAQuotationLevel2__c = mydate
                    ,SLAQuotationLevel3__c = mydate.addDays(5)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false
					,Assessment__c = assessments[0].Id
                ),
                new PurchaseOrder__c(Distributor__c = accounts[0].Id
                    ,ValidityDate__c=date.today()
                    ,Status__c =ASPISConstants.PUR_ORDER_STATUS_RESPONDED
                    //,QuotationTimestampStart__c = mydate
                    ,SLAQuotationLevel1__c = (datetime.now()).addDays(2)
                    ,SLAQuotationLevel2__c = (datetime.now()).addDays(3)
                    ,SLAQuotationLevel3__c = (datetime.now()).addDays(5)
                    ,TECHSLAQuotationIsLevel1__c = false
                    ,TECHSLAQuotationIsLevel2__c = false
                    ,TECHSLAQuotationIsLevel3__c = false
					,Assessment__c = assessments[0].Id
                )
        	};
        	insert purchaseOrders;

            orderLines = new list<OrderLine__c>{
                new OrderLine__c (  
                    PurchaseOrder__c = purchaseOrders[0].Id
                    ,Quantity__c = 4
                ),
                new OrderLine__c (  
                    PurchaseOrder__c = purchaseOrders[0].Id
                    ,Quantity__c = 4
                )
            };
            insert orderLines;

            //system.debug('////purchaseOrders:'+purchaseOrders);
        }

    }

	@isTest static void test_BatchSLA() {
		Test.startTest();
		    ASPISBatchSLAQuotation slaQ = new ASPISBatchSLAQuotation();
		    ID batchprocessid = Database.executeBatch(slaQ);
	    Test.StopTest();

        list<PurchaseOrder__c> PurchaseOrderAssertList = [select Id, Name ,TECHSLAQuotationIsLevel1__c,TECHSLAQuotationIsLevel2__c,
                                                            TECHSLAQuotationIsLevel3__c,SuppliableLines__c,UnfilledLines__c
                                                            from PurchaseOrder__c where Id IN : purchaseOrders
                                                            and TECHSLAQuotationIsLevel1__c = true 
                                                            and TECHSLAQuotationIsLevel2__c = true
                                                            and TECHSLAQuotationIsLevel3__c = true];
        //system.debug('////PurchaseOrderAssertList: '+PurchaseOrderAssertList);
        System.AssertEquals(1, PurchaseOrderAssertList.size());
	}
	*/
	
}