/*************************************************************************************
Class Name - TestVFC01_AssessTimeline
Version - 1.0
Created Date -01 JUNE 2015
Function - Test class for VFC01_AssessTimeline

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Bhavish (sc)			01/06/2015	Original Version
*************************************************************************************/
@isTest
private class TestVFC01_AssessTimeline {
/*
	static list<user> users;
	static list<Assessment__c> assessmentList;
	static list<PurchaseOrder__c> purchaseOrderList;
	static list<PrerequisiteOrder__c> prerequisiteOrderList;
	static list<Invoice__c> invoiceList;
	static{
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
	  	//ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestVFC01_AssessTimeline',users[0].Id);
      system.runas(users[0]){
        ASPISTestUtils.generateBasicTestData();
  			assessmentList = new List<Assessment__c>{
  				new Assessment__c(Name='ASSESS_TEST-0003',
                                   AssessmentNumber__c = 'ASSESS_TEST-0003',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_SOURCED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0004',
                                   AssessmentNumber__c = 'ASSESS_TEST-0004',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0005', 
                                   AssessmentNumber__c = 'ASSESS_TEST-0005',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0006',
                                   AssessmentNumber__c = 'ASSESS_TEST-0006',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0007',
                                   AssessmentNumber__c = 'ASSESS_TEST-0007',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0008',
                                   AssessmentNumber__c = 'ASSESS_TEST-0008',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0009',  
                                   AssessmentNumber__c = 'ASSESS_TEST-0009',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0010', 
                                   AssessmentNumber__c = 'ASSESS_TEST-0010',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  				,new Assessment__c(Name='ASSESS_TEST-0011',
                                   AssessmentNumber__c = 'ASSESS_TEST-0011',
                                   BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                   Status__c = ASPISConstants.ASSESS_STATUS_CHECKED
                                   )
  			};
  			ASPISTestUtils.generateAssessment(assessmentList);

  			purchaseOrderList = new List<PurchaseOrder__c>{
  				new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
								  	ValidityDate__c=date.today(),
								  	Status__c =ASPISConstants.PUR_ORDER_STATUS_DRAFTQUOTE,
								  	SLAQuotationLevel1__c = date.today().addDays(2),
								  	SLAQuotationLevel2__c = date.today(),
								  	SLAQuotationLevel3__c = date.today().addDays(5),
								  	TECHSLAQuotationIsLevel1__c = false,
								  	TECHSLAQuotationIsLevel2__c = false,
								  	TECHSLAQuotationIsLevel3__c = false,
								  	Assessment__c=assessmentList[1].id
                  )
  				,new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
								  	ValidityDate__c=date.today(),
								  	Status__c =ASPISConstants.PUR_ORDER_STATUS_ISSUED,
								  	SLAQuotationLevel1__c = date.today().addDays(2),
								  	SLAQuotationLevel2__c = date.today(),
								  	SLAQuotationLevel3__c = date.today().addDays(5),
								  	TECHSLAQuotationIsLevel1__c = false,
								  	TECHSLAQuotationIsLevel2__c = false,
								  	TECHSLAQuotationIsLevel3__c = false,
								  	Assessment__c=assessmentList[2].id
                  )
  				,new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
								  	ValidityDate__c=date.today()-2,
								  	Status__c = 'ORDERED',
								  	SLAQuotationLevel1__c = date.today().addDays(2),
								  	SLAQuotationLevel2__c = date.today(),
								  	SLAQuotationLevel3__c = date.today().addDays(5),
								  	TECHSLAQuotationIsLevel1__c = false,
								  	TECHSLAQuotationIsLevel2__c = false,
								  	TECHSLAQuotationIsLevel3__c = false,
								  	Assessment__c=assessmentList[4].id
                  )
  				,new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
								  	ValidityDate__c=date.today(),
								  	Status__c = 'INDELIVERY',
								  	SLAQuotationLevel1__c = date.today().addDays(2),
								  	SLAQuotationLevel2__c = date.today(),
								  	SLAQuotationLevel3__c = date.today().addDays(5),
								  	TECHSLAQuotationIsLevel1__c = false,
								  	TECHSLAQuotationIsLevel2__c = false,
								  	TECHSLAQuotationIsLevel3__c = false,
								  	Assessment__c=assessmentList[5].id
                  )
  				,new PurchaseOrder__c(Distributor__c = ASPISTestUtils.accounts[2].Id,
								  	ValidityDate__c=date.today(),
								  	Status__c = 'DELIVEREDCONFIRMED',
								  	SLAQuotationLevel1__c = date.today().addDays(2),
								  	SLAQuotationLevel2__c = date.today(),
								  	SLAQuotationLevel3__c = date.today().addDays(5),
								  	TECHSLAQuotationIsLevel1__c = false,
								  	TECHSLAQuotationIsLevel2__c = false,
								  	TECHSLAQuotationIsLevel3__c = false,
								  	Assessment__c=assessmentList[6].id
                  )
  			};
  			ASPISTestUtils.generatePurchaseOrder(purchaseOrderList);

  			prerequisiteOrderList = new List<PrerequisiteOrder__c>{
  				new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
										Assessment__c = assessmentList[3].Id,
										RecordTypeId = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER).get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
										Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
  				,new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
										Assessment__c = assessmentList[4].Id,
										RecordTypeId = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER).get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
										Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
  				,new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
										Assessment__c = assessmentList[5].Id,
										RecordTypeId = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER).get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
										Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
  				,new PrerequisiteOrder__c(BodyShop__c = ASPISTestUtils.accounts[0].Id,
										Assessment__c = assessmentList[6].Id,
										RecordTypeId = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER).get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance),
										Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED)
  			};
  			ASPISTestUtils.generatePrerequisiteOrder(prerequisiteOrderList);

  			invoiceList = new List<Invoice__c>{
  				new Invoice__c(Assessment__c = assessmentList[7].Id,
                                                BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                                PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
                                                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
                                                Date__c = system.today(),
                                                Status__c = ASPISConstants.INV_STATUS_SENT)
  				,new Invoice__c(Assessment__c = assessmentList[8].Id,
                                                BodyShop__c = ASPISTestUtils.accounts[0].Id,
                                                PrerequisiteOrder__c = ASPISTestUtils.prerequisiteOrders[0].Id,
                                                RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId(),
                                                Date__c = system.today(),
                                                Status__c = ASPISConstants.INV_STATUS_PAID)
  			};
  			ASPISTestUtils.generateInvoice(invoiceList);
  		}
	}
  
	static testMethod void testVFC01_AssessTimelineStepNum1(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[0]));
        	test.stoptest();
        	System.assertEquals(1, ctrl.stepNumber);
    	}
	}
  
	static testMethod void testVFC01_AssessTimelineStepNum2(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[1]));
        	test.stoptest();
        	System.assertEquals(2, ctrl.stepNumber);
    	}
	}

	static testMethod void testVFC01_AssessTimelineStepNum3(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[2]));
        	test.stoptest();
        	System.assertEquals(3, ctrl.stepNumber);
    	}
	}

	static testMethod void testVFC01_AssessTimelineStepNum4(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[3]));
        	test.stoptest();
        	System.assertEquals(4, ctrl.stepNumber);
    	}
	}

	static testMethod void testVFC01_AssessTimelineStepNum5(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[4]));
        	test.stoptest();
        	System.assertEquals(5, ctrl.stepNumber);
    	}
	}

	static testMethod void testVFC01_AssessTimelineStepNum6(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[5]));
        	test.stoptest();
        	System.assertEquals(6, ctrl.stepNumber);
    	}
	}

	static testMethod void testVFC01_AssessTimelineStepNum7(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[6]));
        	test.stoptest();
        	System.assertEquals(7, ctrl.stepNumber);
    	}
	}

	static testMethod void testVFC01_AssessTimelineStepNum8(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[7]));
        	test.stoptest();
        	System.assertEquals(8, ctrl.stepNumber);
    	}
	}

	static testMethod void testVFC01_AssessTimelineStepNum9(){
        system.runas(users[0]){
        	test.starttest();
        		VFC01_AssessTimeline ctrl = new VFC01_AssessTimeline(new ApexPages.StandardController(assessmentList[8]));
        	test.stoptest();
        	System.assertEquals(9, ctrl.stepNumber);
    	}
	}*/
}