/*************************************************************************************
Class Name - TestMasterRuleTriggerHandler 
Version - 1.0
Created Date - 30 APR 2015
Function - Test Class for MasterRuleTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date         Description
* ----------        ----------  -----------------------
* Dourga(SC)        30/04/2015   Original Version
* Dourga Unmole     17/08/2015  Added code for case 1162 (Only 1 rule in a Rule Set can be 
                                indicated as Primary.)
*************************************************************************************/
@isTest
private class TestMasterRuleTriggerHandler { 
	/*static User userAdmin;
    static list <DetailRule__c> detailRuleList;
    static list <MasterRules__c> masterRuleList;
    static list <MasterRules__c> ruleSetList;
    static MasterRules__c masRule;
    static map <String,Id> drRecordTypeMap;
    static map <String,Id> mRRecordTypeMap; 

    static{
    	drRecordTypeMap = ASPISConstants.getDeveloperIdMap('DetailRule__c');
        mRRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_MASTER_RULE);

        userAdmin = new User(Username = 'testclassAP01@test.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = ASPISConstants.getProfileAdminId()); 
                        
        //insert userAdmin;
        ASPISTestUtils.generateTestUser(userAdmin);

        //insert new Bypass__c(SetupOwnerId =userAdmin.Id, BypassValidationRules__c=true,BypassWorkflows__c = true);
        //ASPISTestUtils.setupBypassCustomSetting(true,true,'','MasterRuleTriggerHandler',userAdmin.Id);
        System.runAs(userAdmin){
            masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct',version__c = 1),
                                                       new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct',version__c = 2)};

            ruleSetList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct',RecordTypeId = mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET),version__c = 3),
                                                    new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct',RecordTypeId = mRRecordTypeMap.get(ASPISConstants.MASTER_RULE_RT_DeveloperName_RULESET),version__c = 4)};

            masRule = new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct2',version__c = 5);
            insert masRule;

            detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masRule.Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'BodyShopPrice__c', Operator__c = 'EQUALS', RecordTypeId=drRecordTypeMap.get('FILTERCONDITION')),
                                                      new DetailRule__c(MasterRule__c = masRule.Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Description__c', Operator__c = 'EQUALS', RecordTypeId=drRecordTypeMap.get('FILTERCONDITION')),
                                                      new DetailRule__c(MasterRule__c = masRule.Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'PartList__c', Operator__c = 'EQUALS', RecordTypeId=drRecordTypeMap.get('FILTERCONDITION')),
                                                      new DetailRule__c(MasterRule__c = masRule.Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'PartNumber__c', Operator__c = 'EQUALS', RecordTypeId=drRecordTypeMap.get('FILTERINPUT'))};
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
        masterRuleList[0].IsPrimary__c = true;
        masterRuleList[0].RuleSet__c = ruleSetList[0].Id;
        insert masterRuleList;
        masterRuleList[1].IsPrimary__c = true;
        masterRuleList[1].RuleSet__c = ruleSetList[0].Id;
        System.runAs(userAdmin){
            test.starttest(); 
                try{
                    update masterRuleList[1];
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
        insert masterRuleList;
        masterRuleList[1].IsPrimary__c = true;
        masterRuleList[1].RuleSet__c = ruleSetList[0].Id;
        masterRuleList.add(new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct', IsPrimary__c = true,RuleSet__c = ruleSetList[0].Id));
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
    }*/
}