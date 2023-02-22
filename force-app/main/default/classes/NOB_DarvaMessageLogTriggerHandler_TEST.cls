/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 01-25-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01-25-2021   ARA   Initial Version
**/
@isTest
public with sharing class NOB_DarvaMessageLogTriggerHandler_TEST {
    static User userAdmin;
    static List<Contact> listContact;
    static List<Account> listAccount;
    static List<NOB_Planning__c> listPlanning;
    static List<NOB_DarvaMessageLog__c> listMessageLog;
    static List<WorkOrder> ListWorkOrder;
    static List<Case> listCase;

    static{
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        insert userAdmin;

        System.runAs(userAdmin){
            //create account
            listAccount = new List<Account>{
                TestFactory.createInsurerAccount('Test 1','Nord'),
                TestFactory.createInsurerAccount('Test 2','Bourgogne'),
                TestFactory.createPrefikarBodyAccount('Test 3', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarBodyAccount('Test 4', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035')
            };
            listAccount[2].BillingCity = 'Paris';
            listAccount[2].BillingCountry = 'France';
            listAccount[2].BillingStreet = '5 RUE EMILE LEPEU';
            listAccount[2].BillingPostalCode = '75011';
            listAccount[3].BillingCity = 'Paris';
            listAccount[3].BillingCountry = 'France';
            listAccount[3].BillingStreet = '5 RUE EMILE LEPEU';
            listAccount[3].BillingPostalCode = '75011';

            insert listAccount;
            //create contacts
            listContact = new List<Contact>{
                TestFactory.createInsuredContact('Luffy', 'Monkey', listAccount[0].Id, 'Nord'),
                TestFactory.createInsuredContact('Roronoa', 'Zoro', listAccount[1].id,'Bourgogne')
            };
            listContact[0].Phone = '77777777';
            listContact[1].Phone = '88888888';

            insert listContact;
            //create Planning
            listPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(listAccount[2].Id),
                TestFactory.createPlanning(listAccount[3].Id)
            };
            insert listPlanning;
            //create case
            listCase = new List<Case>{
                TestFactory.createCaseStandard('Nouvelle', listContact[0].id, listAccount[0].id, 'AUDI', '3061','12345asd','Darva',Datetime.newInstance(System.today().year(),
                System.today().month(), System.today().day()-2, 17, 00, 0),'AR1234','Body','Réparation'),
                TestFactory.createCaseStandard('Nouvelle', listContact[1].id, listAccount[1].id, 'BMW', '3061','123456ab','Email',Datetime.newInstance(System.today().year(),
                System.today().month(), System.today().day()-2, 17, 00, 0),'AR345','Body1','Peinture')
               
            };
            listCase[0].NOB_TECH_DispoId__c = listPlanning[0].Id;
            listCase[0].NOB_BodyShop__c = listAccount[2].Id;
            listCase[0].NOB_ScenarioCode__c = '36';
            listCase[0].PFR_TECH_EngineerClaimNR__c = 'CH1';

            insert listCase;
            System.debug('##pch listCase'+listCase);

            //create Work Order
            ListWorkOrder = new List<WorkOrder>{
                TestFactory.createWorkOrder('Nouveau', listCase[0].Id)
                // TestFactory.createWorkOrder('Nouveau', listCase[1].Id)
            };
            String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
            ListWorkOrder[0].recordTypeId = recordTypeWo;
            
            // Message Log
            listMessageLog = new List<NOB_DarvaMessageLog__c>{ 
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'SD40',NOB_MessageSubType__c ='Type 2' , /*NOB_Status__c = 'New',*/NOB_Status__c='En attente AS',NOB_Case__c = listCase[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'Genesys',NOB_MessageSubType__c ='CreateTask' , NOB_Status__c = 'New',NOB_Case__c = listCase[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'SD40',NOB_MessageSubType__c ='Type 2' ,NOB_Status__c='En attente AS' ,NOB_Case__c=listCase[0].Id, NOB_ActionType__c= 'New')
                    
            };
            

        }
    }
    /*@isTest
    public static void onBeforeInsertTest(){
        System.debug('##pch onBeforeInsertTest');
        System.runAs(userAdmin){            
            Test.startTest();
            //listMessageLog[0].NOB_Status__c='En attente AS';
            //
            insert ListWorkOrder;
            insert listMessageLog[0];
            System.debug('##pch ListWorkOrder' +ListWorkOrder);
            System.debug('##pch listMessageLog'+listMessageLog[0]);
            Test.stopTest();
        }
        
    }*/
    @isTest
    public static void onAfterInsertTest(){
        System.runAs(userAdmin){
            Test.startTest();
            insert ListWorkOrder;
            insert listMessageLog;

            Test.stopTest();
            List<Case> listCaseInserted = [SELECT Id, NOB_TECH_RulePB_CaseWithoutRepairer__c from Case WHERE Id = :listCase[1].Id];
            List<Task> listTask = [SELECT Id from Task WHERE WhatId = :listCaseInserted[0].Id];
            System.debug('listTask'+listTask);
        }
        
    }

    @isTest
    public static void onAfterUpdateTest(){
        System.runAs(userAdmin){
            insert ListWorkOrder;
            insert listMessageLog;
            List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_Status__c, NOB_MessageSubType__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c];
            
            List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLogToUpdate = new List<NOB_DarvaMessageLog__c>();
            for(NOB_DarvaMessageLog__c dl : listNOB_DarvaMessageLog){
                dl.NOB_Status__c = 'New';
                listNOB_DarvaMessageLogToUpdate.add(dl);
            }
            Test.startTest();
            update listNOB_DarvaMessageLogToUpdate; 
            Test.stopTest();
            List<Case> listCaseInserted = [SELECT Id, NOB_TECH_RulePB_CaseWithoutRepairer__c from Case WHERE Id = :listCase[1].Id];
            List<Task> listTask = [SELECT Id from Task WHERE WhatId = :listCaseInserted[0].Id];
            System.debug('listTask'+listTask);
        }
        
    }
    
    @isTest
    public static void loadCasesTest(){
        System.runAs(userAdmin){
            Test.startTest();
            listMessageLog[2].NOB_Case__c=listCase[0].Id;
            insert listMessageLog[2];
            Test.stopTest();
            List<Case> listCaseInserted = [SELECT Id, PFR_TECH_EngineerClaimNR__c, NOB_TECH_IsAXAorDA__c, NOB_ScenarioCode__c, NOB_BodyShop__c,NOB_BodyShop__r.NOB_NetworkCategory__c FROM Case WHERE Id =: listMessageLog[2].NOB_Case__c];

            
        }
        
    }
}