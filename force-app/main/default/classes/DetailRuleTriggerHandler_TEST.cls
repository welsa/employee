/*************************************************************************************
Class Name - DetailRuleTriggerHandler_TEST
Version - 1.0
Created Date - 09 MARCH 2015
Function - TestClass to DetailRuleTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      09/03/2016  Reworked Version
*************************************************************************************/
@isTest
private class DetailRuleTriggerHandler_TEST { 
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
            //insert detailRuleList;
        }
    }

    static testMethod void detailRuleTestOnInsert() {
        System.Debug('>>> Start detailRuleTestOnInsert');
        System.runAs(l_users[0]){            
            test.starttest(); 
                insert detailRuleList;
            test.stoptest();  

            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: MasterRule.Id].size(),3);
        }//end system.runas
        System.Debug('>>> End detailRuleTestOnInsert');
    }

    static testMethod void detailRuleTestIncrementOnInsert() {
        System.Debug('>>> Start detailRuleTestIncrementOnInsert');
        System.runAs(l_users[0]){
            insert detailRuleList;
            test.starttest(); 
                insert new DetailRule__c(MasterRule__c = MasterRule.Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Quantity__c', Operator__c = 'CONTAINS');
            test.stoptest();  

            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: MasterRule.Id].size(),4);
        }//end system.runas
        System.Debug('>>> End detailRuleTestIncrementOnInsert');
    }

    static testMethod void detailRuleTestIncrementNullOnInsert() {
        System.Debug('>>> Start detailRuleTestIncrementNullOnInsert');
        System.runAs(l_users[0]){
            insert detailRuleList;
            test.starttest(); 
                insert new DetailRule__c(MasterRule__c = MasterRule.Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Quantity__c', Operator__c = 'CONTAINS');
            test.stoptest();  

            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: MasterRule.Id].size(),4);
        }//end system.runas
        System.Debug('>>> End detailRuleTestIncrementNullOnInsert');
    }

    static testMethod void detailRuleContainDotTestOnInsert() {
        System.Debug('>>> Start detailRuleContainDotTestOnInsert');
        System.runAs(l_users[0]){
            detailRuleList[0].FieldsAPI__c = 'PrerequisiteOrder__r.PreviousStatus__c';
            test.starttest(); 
                insert detailRuleList[0];
            test.stoptest(); 
            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: MasterRule.Id].size(),1); 
        }//end system.runas

        System.Debug('>>> End detailRuleContainDotTestOnInsert');
    }

    static testMethod void detailRuleContainDotTestErrorOnInsert() {
        System.Debug('>>> Start detailRuleContainDotTestErrorOnInsert');
        System.runAs(l_users[0]){
            detailRuleList[0].FieldsAPI__c = 'PurchaseOrder__r.Color';
            test.starttest(); 
            try{
                insert detailRuleList[0];
            }
            catch(exception e){
                //system.debug('##errorMsg '+ e.getMessage());
                system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
            } 
            test.stoptest();
        }//end system.runas

        System.Debug('>>> End detailRuleContainDotTestErrorOnInsert');
    }

    static testMethod void detailRuleContainDotTestErrorOnUpdate() {
        System.Debug('>>> Start detailRuleContainDotTestErrorOnUpdate');
        System.runAs(l_users[0]){
            masterRule.RuleStatus__c = 'DRAFT';
            update masterRule;
            insert detailRuleList[0];
            detailRuleList[0].FieldsAPI__c = 'PurchaseOrder__r.Color';
            detailRuleList[0].sObject__c = 'PurchaseOrder__c';
            detailRuleList[0].RecordTypeId=Schema.SObjectType.DetailRule__c.getRecordTypeInfosByName().get('Filter Condition').getRecordTypeId();
            test.starttest(); 
            try{
                update detailRuleList[0];
            }
            catch(exception e){
                //system.debug('##errorMsg '+ e.getMessage());
                system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
            } 
            test.stoptest(); 
        }//end system.runas

        System.Debug('>>> End detailRuleContainDotTestErrorOnUpdate');
    }

    static testMethod void detailRuleTestOnDelete() {
        System.Debug('>>> Start detailRuleTestOnDelete');
        System.runAs(l_users[0]){
            insert detailRuleList;
            test.starttest(); 
                try{
                    delete detailRuleList;
                }
                catch(exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULENOTDELETE));
                }
            test.stoptest();    
        }//end system.runas

        System.Debug('>>> End detailRuleTestOnDelete');
    }

    static testMethod void detailRuleActiveTestOnUpdate() {
        System.Debug('>>> Start detailRuleActiveTestOnUpdate');
        System.runAs(l_users[0]){
            insert detailRuleList[0];
            detailRuleList[0].FieldsAPI__c = 'PreviousStatus__c';
            test.starttest(); 
                try{
                    update detailRuleList[0];
                }
                catch(exception e){
                    system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULENOTUPDATE));
                }
            test.stoptest();    
        }//end system.runas

        System.Debug('>>> End detailRuleActiveTestOnUpdate');
    }

    static testMethod void detailRuleWrongFieldTestOnInsert() {
        System.Debug('>>> Start detailRuleWrongFieldTestOnInsert');
        System.runAs(l_users[0]){
            detailRuleList[0].FieldsAPI__c = 'Colour__c';
            test.starttest();  
                try{
                    insert detailRuleList[0];
                }
                catch(exception e){
                    system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
                }
            test.stoptest();  

            System.Debug('>>> End detailRuleWrongFieldTestOnInsert');
        }//end system.runas
   
    }
}