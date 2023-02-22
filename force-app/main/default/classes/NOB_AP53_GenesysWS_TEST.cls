/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 01-27-2021
 * @last modified by  : ARA
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   01-15-2021   ARA   Initial Version
**/
@isTest
public with sharing class NOB_AP53_GenesysWS_TEST {
    static User userAdmin;
    static List<Contact> listContact;
    static List<Account> listAccount;
    static List<NOB_Planning__c> listPlanning;
    static List<NOB_DarvaMessageLog__c> listMessageLog;
    static List<Case> listCase;
    static PFR_WsCredential__c config;
    
    static{
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        insert userAdmin;
        System.runAs(userAdmin){
            //create custom setting for endpoint
            config = new PFR_WsCredential__c();
            config.Name= 'Genesys';
            config.NOB_ClientId__c = 'sfdc_pp_prefikar_com';
            config.NOB_ClientSecret__c = 'MLwn9!HK.CIL-92f-n\'f';
            config.NOB_Endpoint__c = 'https://api-cert-pp.se.axa-go.axa.com/prefikar/aspis-pfk-cti-agenda-api-v1-vrs';
            insert config;

            //create account
            listAccount = new List<Account>{
                TestFactory.createInsurerAccount('Test 1','Nord'),
                TestFactory.createInsurerAccount('Test 2','Bourgogne'),
                TestFactory.createInsurerAccount('Test 3','Bourgogne')
            
            };
            listAccount[0].Nob_CTICampaignNumber__c = 'Test';
            listAccount[1].Nob_CTICampaignNumber__c = 'Test1';
            listAccount[2].Nob_CTICampaignNumber__c = 'Test2';
            insert listAccount;
            //create contacts
            listContact = new List<Contact>{
                TestFactory.createInsuredContact('Luffy', 'Monkey', listAccount[0].Id, 'Nord'),
                TestFactory.createInsuredContact('Roronoa', 'Zoro', listAccount[1].id,'Bourgogne'),
                TestFactory.createInsuredContact('Shanks', 'Akagami', listAccount[2].id,'Bourgogne')
            };
            listContact[0].Phone = '77777777';
            listContact[0].MobilePhone = '7777778877';
            listContact[0].OtherPhone = '7788777777';
            listContact[0].NOB_PhonePro__c='55555555';
            listContact[1].Phone = '88888888';
            listContact[1].MobilePhone = '7777799777';
            listContact[1].OtherPhone = '777999977777';
            listContact[1].NOB_PhonePro__c='555555556';
        
            insert listContact;

            //create case
            listCase = new List<Case>{
                TestFactory.createCaseStandard('Nouvelle', listContact[0].id, listAccount[0].id, 'AUDI', '3061','12345asd','Darva',Datetime.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day() - 3, 10, 00, 0),'AR1234','Body','Réparation'),
                TestFactory.createCaseStandard('Nouvelle', listContact[1].id, listAccount[1].id, 'FORD', '3061','123456ab','Darva',Datetime.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day() - 3, 17, 00, 0),'AR345','Body1','Peinture'),
                TestFactory.createCaseStandard('Nouvelle', listContact[2].id, listAccount[2].id, 'BMW', '3061','145236ab','Darva',Datetime.newInstance(System.today().year(),
                System.today().month(), 
                System.today().day() - 3, 17, 00, 0),'AR345','Body2','Peinture')
                };
            
            listCase[1].NOB_Integration__c = 'Échec';
            
        }
    }
    @isTest
    public static void createTaskTest(){
        
        string jsonRequest  = '{"Segmentation":"PFK","id_CRM":"00T1l00000C0qfwEAB","Hdeb":"11/01/2021 02:30:00","Hfin":"11/01/2021 03:30:00","newState":"Rendez-vous pris","newActName":"Done","WhentoCallBack":"11/01/2021 02:30:00"}';
        Test.startTest();
        System.runAs(userAdmin){
            insert listCase ;
            Test.setMock(HttpCalloutMock.class, new GenesysHttpMockResponse(200,'OK',jsonRequest));
        }
        Test.stopTest();
        List<Case> listCaseInserted = [SELECT Id, NOB_TECH_RulePB_CaseWithoutRepairer__c from Case WHERE Id = :listCase[0].Id];
        System.debug('££££ listCaseInserted' + listCaseInserted);
        List<Task> listTask = [SELECT Id from Task WHERE WhatId = :listCaseInserted[0].Id];
        System.debug('££££ listTask' + listTask);
        List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_Status__c, NOB_MessageSubType__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c WHERE NOB_Case__c =:listCaseInserted[0].Id];
        System.debug('££££ listNOB_DarvaMessageLog' + listNOB_DarvaMessageLog);
        String result = listNOB_DarvaMessageLog[0].NOB_Status__c;
        //Assertion
        System.assertEquals('Sent', result);
    }

    @isTest
    public static void UpdateTaskTest(){
        System.runAs(userAdmin){
        insert listCase ;
        string jsonRequest  = '{"Segmentation":"PFK","id_CRM":"00T1l00000C0qfwEAB","Hdeb":"11/01/2021 02:30:00","Hfin":"11/01/2021 03:30:00","newState":"Rendez-vous pris","newActName":"Done","WhentoCallBack":"11/01/2021 02:30:00"}';
		System.debug('##pch listCase' +listCase);
        List<Case> listCaseInserted = [SELECT Id, NOB_TECH_RulePB_CaseWithoutRepairer__c from Case WHERE Id = :listCase[0].Id];
        System.debug('##pch listCaseInserted'+listCaseInserted);
            
        List<Task> listTask = [SELECT Id from Task WHERE WhatId = :listCaseInserted[0].Id];
        System.debug('##pch listTask'+listTask);
        Test.startTest();
        
            //check if user or list is null
            if(listTask.size()>0){
                update new Task(Status = 'Completed', id = listTask[0].id);
            }

            Test.setMock(HttpCalloutMock.class, new GenesysHttpMockResponse(200,'OK',jsonRequest));
        
        Test.stopTest();
           
        if(userAdmin.NOB_isPrefikar__c){
        List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_Status__c, NOB_MessageSubType__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c WHERE NOB_Case__c =:listCaseInserted[0].Id];
        System.debug('##pch listNOB_DarvaMessageLog[1].NOB_MessageSubType__c' +listNOB_DarvaMessageLog[1].NOB_MessageSubType__c);
        System.debug('##pch listNOB_DarvaMessageLog' + listNOB_DarvaMessageLog);
            String result = listNOB_DarvaMessageLog[1].NOB_MessageSubType__c;
        //Assertion        
            System.assertEquals('UpdateTask', result);
        }
        else{
            System.assertEquals(0, listTask.size());
        }
  }
    }
    @isTest
    public static void UpdateTaskWithPFRStatusEchecTest(){
        System.runAs(userAdmin){
        insert listCase ;
        string jsonRequest  = '{"Segmentation":"PFK","id_CRM":"00T1l00000C0qfwEAB","Hdeb":"11/01/2021 02:30:00","Hfin":"11/01/2021 03:30:00","newState":"Rendez-vous pris","newActName":"Done","WhentoCallBack":"11/01/2021 02:30:00"}';

        List<Case> listCaseInserted = [SELECT Id, NOB_TECH_RulePB_CaseWithoutRepairer__c from Case WHERE Id = :listCase[0].Id];
            List<Task> listTask = [SELECT Id from Task WHERE WhatId = :listCaseInserted[0].Id];
        Test.startTest();
        
            update new Task(Status = 'Completed', id = listTask[0].id, PFR_CallStatus__c = 'Échec',PFR_CallPreferedStartTime__c = system.now()+5,PFR_CallPreferedEndTime__c = system.now());
            
        
            Test.setMock(HttpCalloutMock.class, new GenesysHttpMockResponse(200,'OK',jsonRequest));
        
        Test.stopTest();
        List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_MessageSubType__c,NOB_Status__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c WHERE NOB_Case__c =:listCaseInserted[0].Id];
       }
    }
    @isTest
    public static void checkExceptionTest(){
        string jsonRequest  = '{"Segmentation":"PFK","id_CRM":"00T1l00000C0qfwEAB","Hdeb":"11/01/2021 02:30:00","Hfin":"11/01/2021 03:30:00","newState":"Rendez-vous pris","newActName":"Done","WhentoCallBack":"11/01/2021 02:30:00"}';
        Test.startTest();
        System.runAs(userAdmin){
            insert listCase ;
            Test.setMock(HttpCalloutMock.class, new GenesysHttpMockResponse(404,'Failed',jsonRequest));
        }
        Test.stopTest();
    }

    @isTest
    public static void EchecTest(){
        string jsonRequest  = '{"Segmentation":"PFK","id_CRM":"00T1l00000C0qfwEAB","Hdeb":"11/01/2021 02:30:00","Hfin":"11/01/2021 03:30:00","newState":"Rendez-vous pris","newActName":"Done","WhentoCallBack":"11/01/2021 02:30:00"}';
        Test.startTest();
        System.runAs(userAdmin){
            insert listCase[1] ;
            Test.setMock(HttpCalloutMock.class, new GenesysHttpMockResponse(200,'ok',jsonRequest));
        }
        Test.stopTest();
        List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_MessageSubType__c,NOB_Status__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c WHERE NOB_Case__c =:listCase[1].Id];

        System.assertEquals('Error', listNOB_DarvaMessageLog[0].NOB_Status__c);
    }
    @isTest
    public static void caseWithoutContactId(){
        string jsonRequest  = '{"Segmentation":"PFK","id_CRM":"00T1l00000C0qfwEAB","Hdeb":"11/01/2021 02:30:00","Hfin":"11/01/2021 03:30:00","newState":"Rendez-vous pris","newActName":"Done","WhentoCallBack":"11/01/2021 02:30:00"}';
        Test.startTest();
        System.runAs(userAdmin){
            insert new Case( Status = 'Nouvelle',NOB_BusinessProvider__c =listAccount[0].id,NOB_VehicleBrand__c = 'BMW');
            Test.setMock(HttpCalloutMock.class, new GenesysHttpMockResponse(200,'OK',jsonRequest));
        }
        Test.stopTest();
    }

    // Mock class
    public with sharing class GenesysHttpMockResponse  implements HttpCalloutMock  {
        protected Integer code;
        protected String status;
        protected String body;

        public GenesysHttpMockResponse(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(this.body);
            response.setStatusCode(this.code);
            response.setStatus(this.status);
            return response;
        } 
    }

}