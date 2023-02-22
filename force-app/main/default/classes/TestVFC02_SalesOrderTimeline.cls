/*************************************************************************************
Class Name - TestVFC02_SalesOrderTimeline
Version - 1.0
Created Date - 13 MAY 2015
Function - TestClass to VFC02_SalesOrderTimeline

Modification Log :
-----------------------------------------------------------------------------
* Developer     Date        Description
* ----------    ----------  -----------------------
* Yudish R      13/05/2015  Original Version
* Dourga U      23/11/2015  Case C-001258 
*************************************************************************************/
@isTest
private class TestVFC02_SalesOrderTimeline {
 /*   static User userAdmin;
    static list<Account> accounts;
    static list<Assessment__c> assessments;
    static list<PrerequisiteOrder__c> prerequisiteOrders;
    static list<Invoice__c> invoices;

    static map <String,Id> accRecordTypeMap = new map <String,Id>();
    static map <String,Id> proRecordTypeMap = new map <String,Id>();

    static{

        accRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_ACCOUNT);
        proRecordTypeMap = ASPISConstants.getDeveloperIdMap(ASPISConstants.SOBJECT_PREREQUISITEORDER);

        userAdmin = new User(Username = 'jean.paul@test.com'
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

        system.runas(userAdmin){
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
            };
            
            ASPISTestUtils.generateAssessment (assessments);

            //PrerequisiteOrder
            prerequisiteOrders= new list<PrerequisiteOrder__c>{
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                ),
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InDelivery)
                ),
                new PrerequisiteOrder__c(BodyShop__c = accounts[0].Id
                    ,Assessment__c = assessments[0].Id
                    ,RecordTypeId = proRecordTypeMap.get(ASPISConstants.PREREQUISITEORDER_RT_DeveloperName_InAcceptance)
                )
            };
            ASPISTestUtils.generatePrerequisiteOrder (prerequisiteOrders);
            
            //invoices
            invoices = new list<Invoice__c>{
                new Invoice__c(BodyShop__c=accounts[0].Id
                    ,Status__c = ASPISConstants.INV_STATUS_SENT
                    ,Assessment__c =  assessments[0].Id
                    ,PrerequisiteOrder__c = prerequisiteOrders[2].id
                    ,RecordTypeID = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('BodyShop Invoice').getRecordTypeId()
                )
            };
            ASPISTestUtils.generateInvoice(invoices);
        }

    }

    @isTest static void test_salesOrderTimeLineV1() {
        system.debug('#### Start of method test_salesOrderTimeLineV2');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP02_SalesOrderTimeline;
                Test.setCurrentPage(pageRef);

                ApexPages.StandardController sc = new ApexPages.StandardController(prerequisiteOrders[2]);
                VFC02_SalesOrderTimeline sOrder = new VFC02_SalesOrderTimeline(sc);

                system.assertEquals(1,sOrder.stepNumber);
            test.stoptest();
        }
    }
    
    @isTest static void test_salesOrderTimeLineV2() {
        system.debug('#### Start of method test_salesOrderTimeLine');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP02_SalesOrderTimeline;
                Test.setCurrentPage(pageRef);

                prerequisiteOrders[0].Status__c = ASPISConstants.PRE_ORDER_STATUS_RESPONDED;
                update prerequisiteOrders[0];

                ApexPages.StandardController sc = new ApexPages.StandardController(prerequisiteOrders[0]);
                VFC02_SalesOrderTimeline sOrder = new VFC02_SalesOrderTimeline(sc);

                system.assertEquals(2,sOrder.stepNumber);
            test.stoptest();
        }
    }
    
    @isTest static void test_salesOrderTimeLineV3() {
        system.debug('#### Start of method test_salesOrderTimeLineV1');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP02_SalesOrderTimeline;
                Test.setCurrentPage(pageRef);

                prerequisiteOrders[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_INDELIVERY;
                update prerequisiteOrders[1];

                ApexPages.StandardController sc = new ApexPages.StandardController(prerequisiteOrders[1]);
                VFC02_SalesOrderTimeline sOrder = new VFC02_SalesOrderTimeline(sc);

                system.assertEquals(3,sOrder.stepNumber);
            test.stoptest();
        }
    }
    
    @isTest static void test_salesOrderTimeLineV4() {
        system.debug('#### Start of method test_salesOrderTimeLineV1');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP02_SalesOrderTimeline;
                Test.setCurrentPage(pageRef);

                prerequisiteOrders[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_DELIVERED;
                update prerequisiteOrders[1];

                ApexPages.StandardController sc = new ApexPages.StandardController(prerequisiteOrders[1]);
                VFC02_SalesOrderTimeline sOrder = new VFC02_SalesOrderTimeline(sc);

                system.assertEquals(4,sOrder.stepNumber);
            test.stoptest();
        }
    }
    
    @isTest static void test_salesOrderTimeLineV5() {
        system.debug('#### Start of method test_salesOrderTimeLineV1');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP02_SalesOrderTimeline;
                Test.setCurrentPage(pageRef);

                prerequisiteOrders[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_PREORDERCONFIRMED;
                update prerequisiteOrders[1];

                ApexPages.StandardController sc = new ApexPages.StandardController(prerequisiteOrders[1]);
                VFC02_SalesOrderTimeline sOrder = new VFC02_SalesOrderTimeline(sc);

                system.assertEquals(5,sOrder.stepNumber);
            test.stoptest();
        }
    }
    
    @isTest static void test_salesOrderTimeLineV6() {
        system.debug('#### Start of method test_salesOrderTimeLineV1');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP02_SalesOrderTimeline;
                Test.setCurrentPage(pageRef);

                prerequisiteOrders[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_INVOICED;
                update prerequisiteOrders[1];

                ApexPages.StandardController sc = new ApexPages.StandardController(prerequisiteOrders[1]);
                VFC02_SalesOrderTimeline sOrder = new VFC02_SalesOrderTimeline(sc);

                system.assertEquals(6,sOrder.stepNumber);
            test.stoptest();
        }
    }
    
    @isTest static void test_salesOrderTimeLineV7() {
        system.debug('#### Start of method test_salesOrderTimeLineV3');
        
        system.runAs(userAdmin){
            test.starttest();
                PageReference pageRef = Page.VFP02_SalesOrderTimeline;
                Test.setCurrentPage(pageRef);

                prerequisiteOrders[1].Status__c = ASPISConstants.PRE_ORDER_STATUS_PAID;
                update prerequisiteOrders[1];

                ApexPages.StandardController sc = new ApexPages.StandardController(prerequisiteOrders[1]);
                VFC02_SalesOrderTimeline sOrder = new VFC02_SalesOrderTimeline(sc);

                system.assertEquals(7,sOrder.stepNumber);
            test.stoptest();
        }
    }
    */
}