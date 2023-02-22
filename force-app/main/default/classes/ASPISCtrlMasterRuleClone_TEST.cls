/*************************************************************************************
Class Name - TestASPISCtrlMasterRuleClone
Version - 1.0
Created Date - 23 FEB 2016
Function - Test for controller extension class ASPISCtrlMasterRuleClone

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga		23/02/2016  Reworked Version
**************************************************************************************/
@isTest
public with sharing class ASPISCtrlMasterRuleClone_TEST {
	static list<User> l_users;
    static list <DetailRule__c> detailRuleList;
    static MasterRules__c masterRule;
    static MasterRules__c ruleSet;

	static {
        // initialising variables
        l_users = new list<User>();

        // creating user
        User user1 = TestFactory.createUser('ScUserTest');
        l_users.add(user1);
        insert l_users;

        system.runas(l_users[0]){
        	ruleSet = TestFactory.createRuleSetSLAPOQuotation('FR999');
            insert ruleSet;
            
            masterRule = TestFactory.createMasterRuleSLAPOQuotation('FR999', ruleSet);
            insert MasterRule;
            
            detailRuleList = TestFactory.createListCriteriasSLAPOQuotation('FR999', masterRule, '2', '3', '4', 'H');
            insert detailRuleList;
        }
    }

    static testMethod void cloneMasterDetailNoVersionTest() {
    	System.Debug('>>> Start cloneMasterDetailNoVersionTest');
        System.runAs(l_users[0]){
            test.starttest();  
				ApexPages.StandardController sc = new ApexPages.StandardController(masterRule);
		        ASPISCtrlMasterRuleClone controller = new ASPISCtrlMasterRuleClone(sc);
		        PageReference pageRef = Page.ASPISPageMasterRuleClone;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getParameters().put('Id', masterRule.Id);
		        controller.cloneMasterDetail();
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select Process__c from MasterRules__c where Process__c ='QUOTATION'].size(),2);
        System.Debug('>>> End cloneMasterDetailNoVersionTest');
    }

    static testMethod void cloneMasterDetailVersionTest() {
    	System.Debug('>>> Start cloneMasterDetailVersionTest');
        System.runAs(l_users[0]){
            test.starttest();  
            	masterRule.Version__c = 1;
            	update masterRule;
				ApexPages.StandardController sc = new ApexPages.StandardController(masterRule);
		        ASPISCtrlMasterRuleClone controller = new ASPISCtrlMasterRuleClone(sc);
		        PageReference pageRef = Page.ASPISPageMasterRuleClone;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getParameters().put('Id', masterRule.Id);
		        controller.cloneMasterDetail();
            test.stoptest();  
        }//end system.runas
        system.assertEquals([select Process__c from MasterRules__c where Process__c ='QUOTATION'].size(),2);
        System.Debug('>>> End cloneMasterDetailVersionTest');
    }

    static testMethod void cloneMasterDetailCatchTest() {
        System.Debug('>>> Start cloneMasterDetailCatchTest');
        MasterRules__c masRule = new MasterRules__c ( Entity__c = 'AXA Direct');
        System.runAs(l_users[0]){
            test.starttest();  
                ApexPages.StandardController sc = new ApexPages.StandardController(masRule);
                ASPISCtrlMasterRuleClone controller = new ASPISCtrlMasterRuleClone(sc);
                PageReference pageRef = Page.ASPISPageMasterRuleClone;
                Test.setCurrentPage(pageRef);
                controller.cloneMasterDetail();
            test.stoptest();  
        }//end system.runas
        System.assert(ApexPages.GetMessages().size() > 0);
        System.Debug('>>> End cloneMasterDetailCatchTest');
    }

}