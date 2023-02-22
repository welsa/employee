/*************************************************************************************
Class Name - MasterRuleTriggerHandler
Version - 1.0
Created Date - 27 APRIL 2016
Function - Test Class fer class MasterRuleTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Dourga U      27/04/2016  Reworked Version
*************************************************************************************/
@isTest
private class MasterRuleTriggerHandler_TEST {
	static User userAdmin;
    static list <DetailRule__c> detailRuleList;
    static list <MasterRules__c> masterRuleList;
    static list <MasterRules__c> ruleSetList;
    static MasterRules__c masRule;

    static{
    	detailRuleList = new list <DetailRule__c>();
    	masterRuleList = new list <MasterRules__c>();
    	ruleSetList = new list <MasterRules__c>();

        userAdmin = TestFactory.createUser('ScUserTest');
        insert userAdmin;

        System.runAs(userAdmin){

        	MasterRules__c mr1 = TestFactory.createMasterRule('AXA Direct', 'Offering', 'Assessment__c');
        	mr1.Version__c = 1;
            mr1.RuleStatus__c = 'DRAFT';
            masterRuleList.add(mr1);

        	MasterRules__c mr2 = TestFactory.createMasterRule('AXA Direct', 'Offering', 'Assessment__c');
        	mr2.Version__c = 2;
            mr2.RuleStatus__c = 'DRAFT';
            masterRuleList.add(mr2);

            MasterRules__c mr3 = TestFactory.createMasterRule('AXA Direct', 'Offering', 'Assessment__c');
        	mr3.Version__c = 3;
            mr3.RuleStatus__c = 'DRAFT';
        	mr3.RecordTypeId = Schema.SObjectType.MasterRules__c.getRecordTypeInfosByName().get('Rule Set').getRecordTypeId();
            ruleSetList.add(mr3);

        	MasterRules__c mr4 = TestFactory.createMasterRule('AXA Direct', 'Offering', 'Assessment__c');
        	mr4.Version__c = 4;
            mr4.RuleStatus__c = 'DRAFT';
        	mr4.RecordTypeId = Schema.SObjectType.MasterRules__c.getRecordTypeInfosByName().get('Rule Set').getRecordTypeId();
            ruleSetList.add(mr4);

            masRule = TestFactory.createMasterRule('AXA Direct2', 'Offering', 'Assessment__c');
        	mr4.Version__c = 5;

            insert masRule;

            DetailRule__c dr1 = TestFactory.createDetailRule('Offering', masRule, 'BodyShopPrice__c', 'EQUALS', '', 'Filter Condition', 'OrderLine__c', 1);
            detailRuleList.add(dr1);

            DetailRule__c dr2 = TestFactory.createDetailRule('Offering', masRule, 'Description__c', 'EQUALS', '', 'Filter Condition', 'OrderLine__c', 2);
            detailRuleList.add(dr2);

            DetailRule__c dr3 = TestFactory.createDetailRule('Offering', masRule, 'PartList__c', 'EQUALS', '', 'Filter Condition', 'OrderLine__c', 3);
            detailRuleList.add(dr3);
            
            DetailRule__c dr4 = TestFactory.createDetailRule('Offering', masRule, 'PartNumber__c', 'EQUALS', '', 'Criteria', 'OrderLine__c', 4);
            detailRuleList.add(dr4);

            insert detailRuleList;
        }
    }

    static testMethod void masterRulePrimaryTestOnInsert() {
        System.Debug('>>> Start masterRulePrimaryTestOnInsert');
        //masterRuleList[1].RuleStatus__c = 'ACTIVE';
        insert ruleSetList;
        masterRuleList[0].IsPrimary__c = true;
        masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
        System.runAs(userAdmin){
            test.starttest(); 
                insert masterRuleList;
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Entity__c from MasterRules__c where Entity__c ='AXA Direct'].size(),4);
        System.Debug('>>> End masterRulePrimaryTestOnInsert');
    }

    static testMethod void masterRulePrimaryTestOnUpdate() {
        System.Debug('>>> Start masterRulePrimaryTestOnUpdate');
        //masterRuleList[1].RuleStatus__c = 'ACTIVE';
        insert ruleSetList;
        insert masterRuleList;
        masterRuleList[0].IsPrimary__c = true;
        masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
        masterRuleList[1].IsPrimary__c = true;
        masterRuleList[1].RuleSet__c = ruleSetList[0].Id;
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    update masterRuleList;
                }
                catch(Exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.MASTERRULES));
                }
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Entity__c from MasterRules__c where Entity__c ='AXA Direct'].size(),4);
        System.Debug('>>> End masterRulePrimaryTestOnUpdate');
    }

    static testMethod void masterRulePrimaryTestOnInsert2() {
        System.Debug('>>> Start masterRulePrimaryTestOnInsert2');
        //masterRuleList[1].RuleStatus__c = 'ACTIVE';
        insert ruleSetList;
        masterRuleList[0].IsPrimary__c = true;
        masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
        masterRuleList[1].IsPrimary__c = true;
        masterRuleList[1].RuleSet__c = ruleSetList[0].Id;
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    insert masterRuleList;
                }
                catch(Exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.MASTERRULES));
                }
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Entity__c from MasterRules__c where Entity__c ='AXA Direct'].size(),4);
        System.Debug('>>> End masterRulePrimaryTestOnInsert2');
    }

    static testMethod void masterRulePrimaryTestOnUpdate2() {
        System.Debug('>>> Start masterRulePrimaryTestOnUpdate2');
        //masterRuleList[1].RuleStatus__c = 'ACTIVE';
        insert ruleSetList;
        masterRuleList[0].IsPrimary__c = true;
        masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
        masterRuleList[1].RuleSet__c = ruleSetList[0].Id;
        masterRuleList.add(new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct', RuleSet__c = ruleSetList[0].Id));
        insert masterRuleList;
        masterRuleList[1].IsPrimary__c = true;
        masterRuleList[2].IsPrimary__c = true;
        system.debug('##RuleSet__c'+[select RuleSet__c from MasterRules__c where Id in: masterRuleList]);
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    update masterRuleList;
                }
                catch(Exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.MASTERRULES));
                }
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Entity__c from MasterRules__c where Entity__c ='AXA Direct'].size(),5);
        System.Debug('>>> End masterRulePrimaryTestOnUpdate2');
    }

    static testMethod void masterRulePrimaryTestOnUpdate3() {
        System.Debug('>>> Start masterRulePrimaryTestOnUpdate3');
        //masterRuleList[1].RuleStatus__c = 'ACTIVE';
        insert ruleSetList;
        masterRuleList[0].IsPrimary__c = true;
        masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
        masterRuleList[1].RuleSet__c = ruleSetList[0].Id;
        //insert masterRuleList;
        masterRuleList.add(new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct', IsPrimary__c = true,RuleSet__c = ruleSetList[0].Id));
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    insert masterRuleList;
                }
                catch(Exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.MASTERRULES));
                }
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Entity__c from MasterRules__c where Entity__c ='AXA Direct'].size(),5);
        System.Debug('>>> End masterRulePrimaryTestOnUpdate3');
    }
    static testMethod void masterRuleTestOnInsert() {
        System.Debug('>>> Start masterRuleTestOnInsert');
        //masterRuleList[1].RuleStatus__c = 'ACTIVE';
        System.runAs(userAdmin){
            test.starttest(); 
                insert masterRuleList;
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Entity__c from MasterRules__c where Entity__c ='AXA Direct'].size(),2);
        System.Debug('>>> End masterRuleTestOnInsert');
    }

    static testMethod void masterRuleTestOnUpdate() {
        System.Debug('>>> Start masterRuleTestOnUpdate');
        System.runAs(userAdmin){
            ruleSetList[0].RuleStatus__c = 'ACTIVE';
            insert ruleSetList;
            ruleSetList[1].RuleStatus__c = 'ACTIVE';
            test.starttest(); 
                update ruleSetList;
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Process__c, Entity__c, RuleStatus__c from MasterRules__c where Entity__c ='AXA Direct'][0].RuleStatus__c,'ARCHIVED');
        System.Debug('>>> End masterRuleTestOnUpdate');
    }

    static testMethod void ruleSetActiveTestOnUpdate() {
        System.Debug('>>> Start ruleSetActiveTestOnUpdate');
        System.runAs(userAdmin){
            insert ruleSetList;
            masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
            masterRuleList[1].RuleSet__c = ruleSetList[0].Id;
            insert masterRuleList;
            test.starttest(); 
                ruleSetList[0].RuleStatus__c = 'ACTIVE';
                update ruleSetList;
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Process__c, Entity__c, RuleStatus__c from MasterRules__c where Entity__c ='AXA Direct'][0].RuleStatus__c,'ACTIVE');
        System.Debug('>>> End ruleSetActiveTestOnUpdate');
    }

    static testMethod void ruleSetTestOnUpdate() {
        System.Debug('>>> Start ruleSetTestOnUpdate');
        System.runAs(userAdmin){
            masterRuleList[0].RuleStatus__c = 'ACTIVE';
            insert masterRuleList;
            masterRuleList[1].RuleStatus__c = 'ACTIVE';
            test.starttest(); 
                update masterRuleList;
            test.stoptest();  
        }//end system.runas

        system.assertEquals([select Process__c, Entity__c, RuleStatus__c from MasterRules__c where Entity__c ='AXA Direct'][0].RuleStatus__c,'ARCHIVED');
        System.Debug('>>> End ruleSetTestOnUpdate');
    }

    static testMethod void masterRuleFilterTestOnUpdate() {
        System.Debug('>>> Start masterRuleFilterTestOnUpdate');
        masRule.RuleStatus__c = 'ACTIVE';
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    update masRule;
                }
                catch(exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
                }
            test.stoptest();  
        }//end system.runas

        System.Debug('>>> End masterRuleFilterTestOnUpdate');
    }

    static testMethod void masterRuleFilterConTestOnUpdate() {
        System.Debug('>>> Start masterRuleFilterConTestOnUpdate');
        masRule.ConditionLogic__c = '1';
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    update masRule;
                }
                catch(exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
                }
            test.stoptest();  
        }//end system.runas

        System.Debug('>>> End masterRuleFilterConTestOnUpdate');
    }

    static testMethod void masterRuleFilterCon2TestOnUpdate() {
        System.Debug('>>> Start masterRuleFilterCon2TestOnUpdate');
        masRule.ConditionLogic__c = '2 AND 3';
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    update masRule;
                }
                catch(exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
                }
            test.stoptest();  
        }//end system.runas

        System.Debug('>>> End masterRuleFilterCon2TestOnUpdate');
    }

    static testMethod void masterRuleFilterCon3TestOnUpdate() {
        System.Debug('>>> Start masterRuleFilterCon3TestOnUpdate');
        System.runAs(userAdmin){
            insert masterRuleList;
            masterRuleList[0].ConditionLogic__c = '1';
            test.starttest(); 
                try{
                    update masterRuleList;
                }
                catch(exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
                }
            test.stoptest();  
        }//end system.runas

        System.Debug('>>> End masterRuleFilterCon3TestOnUpdate');
    }
}