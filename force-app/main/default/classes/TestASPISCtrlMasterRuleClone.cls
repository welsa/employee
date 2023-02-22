/*************************************************************************************
Class Name - TestASPISCtrlMasterRuleClone
Version - 1.0
Created Date - 04 MAY 2015
Function - Test for controller extension class ASPISCtrlMasterRuleClone

Modification Log :
-----------------------------------------------------------------------------
* Developer             Date        Description
* ----------            ----------  -----------------------
* Dourga Unmole (SC)    04/05/2015  Original Version
**************************************************************************************/
@isTest
private class TestASPISCtrlMasterRuleClone {
	/*static User userAdmin;
    static list <DetailRule__c> detailRuleList; 
    static list <MasterRules__c> masterRuleList;

	static{
        ASPISTestUtils.generateBasicTestData();
        
        userAdmin = new User(Username = 'jean.paul-testingNewName@test.com'  // checking for UNABLE_TO_LOCK_ROW error in running test parallel
            ,LastName = 'paul'
            ,LanguageLocaleKey = 'en_US'
            ,FirstName = 'jean'
            ,Email = 'jean@test.com'
            ,Alias = 'jpa'
            ,TimeZoneSidKey = 'Europe/Dublin'
            ,LocaleSidKey = 'en_US'
            ,EmailEncodingKey = 'UTF-8'
            ,ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        //ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestASPISCtrlMasterRuleClone',userAdmin.Id);
        system.runas(userAdmin){

            masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct'),
                                                       new MasterRules__c(Process__c = 'Orders' , Entity__c = 'AXA Direct',version__c = 1)};
            insert masterRuleList;

            detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 1 ,sObject__c = 'OrderLine__c', FieldsAPI__c = 'BodyShopPrice__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 2 , sObject__c = 'OrderLine__c', FieldsAPI__c = 'Description__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 3 , sObject__c = 'OrderLine__c', FieldsAPI__c = 'Type__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'PurchaseOrder__c', Operator__c = 'GREATER_EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Quantity__c', Operator__c = 'CONTAINS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[1].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Suppliable__c', Operator__c = 'CONTAINS')
            };
            insert  detailRuleList;

        }
    }

    static testMethod void cloneMasterDetailNoVersionTest() {
    	System.Debug('>>> Start cloneMasterDetailNoVersionTest');
        System.runAs(userAdmin){
            test.starttest();  
				ApexPages.StandardController sc = new ApexPages.StandardController(masterRuleList[0]);
		        ASPISCtrlMasterRuleClone controller = new ASPISCtrlMasterRuleClone(sc);
		        PageReference pageRef = Page.ASPISPageMasterRuleClone;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getParameters().put('Id', masterRuleList[0].Id);
		        controller.cloneMasterDetail();
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select Process__c from MasterRules__c where Process__c ='Offering'].size(),3);
        System.Debug('>>> End cloneMasterDetailNoVersionTest');
    }

    static testMethod void cloneMasterDetailVersionTest() {
    	System.Debug('>>> Start cloneMasterDetailVersionTest');
        System.runAs(userAdmin){
            test.starttest();  
				ApexPages.StandardController sc = new ApexPages.StandardController(masterRuleList[1]);
		        ASPISCtrlMasterRuleClone controller = new ASPISCtrlMasterRuleClone(sc);
		        PageReference pageRef = Page.ASPISPageMasterRuleClone;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getParameters().put('Id', masterRuleList[1].Id);
		        controller.cloneMasterDetail();
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select Process__c from MasterRules__c where Process__c ='Orders'].size(),3);
        System.Debug('>>> End cloneMasterDetailVersionTest');
    }

    static testMethod void cloneMasterDetailCatchTest() {
        System.Debug('>>> Start cloneMasterDetailCatchTest');
        MasterRules__c masRule = new MasterRules__c ( Entity__c = 'AXA Direct');
        System.runAs(userAdmin){
            test.starttest();  
                ApexPages.StandardController sc = new ApexPages.StandardController(masRule);
                ASPISCtrlMasterRuleClone controller = new ASPISCtrlMasterRuleClone(sc);
                PageReference pageRef = Page.ASPISPageMasterRuleClone;
                Test.setCurrentPage(pageRef);
                //ApexPages.currentPage().getParameters().put('Id', masRule.Id);
                controller.cloneMasterDetail();
            test.stoptest();  
        }//end system.runas
        System.assert(ApexPages.GetMessages().size() > 0);
        System.Debug('>>> End cloneMasterDetailCatchTest');
    }*/
}