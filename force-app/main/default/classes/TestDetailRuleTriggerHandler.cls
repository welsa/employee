/*************************************************************************************
Class Name - TestDetailRuleTriggerHandler 
Version - 1.0
Created Date - 09 APR 2015
Function - Test Class for DetailRuleTriggerHandler

Modification Log :
-----------------------------------------------------------------------------
* Developer    Date         Description
* ----------   ----------  -----------------------
* Dourga(SC)   29/04/2015   Original Version
*************************************************************************************/
@isTest
private class TestDetailRuleTriggerHandler {
    /*static User userAdmin;
    static list <DetailRule__c> detailRuleList;
    static list <MasterRules__c> masterRuleList;
    static map <String,Id> drRecordTypeMap;

    static{
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
        //ASPISTestUtils.setupBypassCustomSetting(true,true,'','TestDetailRuleTriggerHandler',userAdmin.Id);
        System.runAs(userAdmin){
            drRecordTypeMap = ASPISConstants.getDeveloperIdMap('DetailRule__c');

            masterRuleList = new list <MasterRules__c>{new MasterRules__c(Process__c = 'Offering' , Entity__c = 'AXA Direct'),
                                                       new MasterRules__c(Process__c = 'Orders' , Entity__c = 'AXA Direct')
            };
            insert masterRuleList;

            detailRuleList = new list <DetailRule__c>{new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 1 ,sObject__c = 'OrderLine__c', FieldsAPI__c = 'BodyShopPrice__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 2 , sObject__c = 'OrderLine__c', FieldsAPI__c = 'Description__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', Number__c = 3 , sObject__c = 'OrderLine__c', FieldsAPI__c = 'Type__c', Operator__c = 'EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'PurchaseOrder__c', Operator__c = 'GREATER_EQUALS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Quantity__c', Operator__c = 'CONTAINS'),
                                                      new DetailRule__c(MasterRule__c = masterRuleList[1].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Suppliable__c', Operator__c = 'CONTAINS')
            };
        }
    }

    static testMethod void detailRuleTestOnInsert() {
        System.Debug('>>> Start detailRuleTestOnInsert');
        System.runAs(userAdmin){            
            test.starttest(); 
                insert detailRuleList;
            test.stoptest();  

            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: masterRuleList[0].Id].size(),5);
            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: masterRuleList[1].Id].size(),1);
        }//end system.runas
        System.Debug('>>> End detailRuleTestOnInsert');
    }

    static testMethod void detailRuleTestIncrementOnInsert() {
        System.Debug('>>> Start detailRuleTestIncrementOnInsert');
        System.runAs(userAdmin){
            insert detailRuleList;
            test.starttest(); 
                insert new DetailRule__c(MasterRule__c = masterRuleList[0].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Quantity__c', Operator__c = 'CONTAINS');
            test.stoptest();  

            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: masterRuleList[0].Id].size(),6);
        }//end system.runas
        System.Debug('>>> End detailRuleTestIncrementOnInsert');
    }

    static testMethod void detailRuleTestIncrementNullOnInsert() {
        System.Debug('>>> Start detailRuleTestIncrementNullOnInsert');
        System.runAs(userAdmin){
            insert detailRuleList[5];
            test.starttest(); 
                insert new DetailRule__c(MasterRule__c = masterRuleList[1].Id, Process__c = 'Offering', sObject__c = 'OrderLine__c', FieldsAPI__c = 'Quantity__c', Operator__c = 'CONTAINS');
            test.stoptest();  

            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: masterRuleList[1].Id].size(),2);
        }//end system.runas
        System.Debug('>>> End detailRuleTestIncrementNullOnInsert');
    }

    static testMethod void detailRuleContainDotTestOnInsert() {
        System.Debug('>>> Start detailRuleContainDotTestOnInsert');
        System.runAs(userAdmin){
            detailRuleList[1].FieldsAPI__c = 'PurchaseOrder__r.InvoiceStatus__c';
            test.starttest(); 
                insert detailRuleList[1];
            test.stoptest(); 
            system.assertEquals([select Id,MasterRule__c from DetailRule__c where MasterRule__c =: masterRuleList[0].Id].size(),1); 
        }//end system.runas

        System.Debug('>>> End detailRuleContainDotTestOnInsert');
    }

    static testMethod void detailRuleContainDotTestErrorOnInsert() {
        System.Debug('>>> Start detailRuleContainDotTestErrorOnInsert');
        System.runAs(userAdmin){
            detailRuleList[1].FieldsAPI__c = 'PurchaseOrder__r.Color';
            test.starttest(); 
            try{
                insert detailRuleList[1];
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
        System.runAs(userAdmin){
            insert detailRuleList[1];
            //system.debug('## dt'+detailRuleList[1]);
            detailRuleList[1].FieldsAPI__c = 'Colour__c';
            detailRuleList[1].sObject__c = 'PurchaseOrder__c';
            detailRuleList[1].RecordTypeId=drRecordTypeMap.get('FILTERCONDITION');
            test.starttest(); 
            try{
                //system.debug('## dt'+detailRuleList[1]);
                update detailRuleList[1];
                //system.debug('## dt'+detailRuleList[1]);
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
        System.runAs(userAdmin){
            masterRuleList[0].RuleStatus__c = 'ACTIVE';
            update masterRuleList[0];
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
        System.runAs(userAdmin){
            masterRuleList[0].RuleStatus__c = 'ACTIVE';
            update masterRuleList[0];
            insert detailRuleList[0];
            detailRuleList[0].sObject__c = 'AcceptedCheck__c';
            test.starttest(); 
                try{
                    update detailRuleList[0];
                }
                catch(exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULENOTUPDATE));
                }
            test.stoptest();    
        }//end system.runas

        System.Debug('>>> End detailRuleActiveTestOnUpdate');
    }

    static testMethod void detailRuleWrongFieldTestOnInsert() {
        System.Debug('>>> Start detailRuleWrongFieldTestOnInsert');
        System.runAs(userAdmin){
            detailRuleList[2].FieldsAPI__c = 'Colour__c';
            test.starttest();  
                try{
                    insert detailRuleList[1];
                }
                catch(exception e){
                    //system.debug('##errorMsg '+ e.getMessage());
                    system.assertEquals(true, e.getMessage().contains(System.Label.DETAILRULEINVALIDFIELD));
                }
            test.stoptest();  

            System.Debug('>>> End detailRuleWrongFieldTestOnInsert');
        }//end system.runas
   
    }*/
}