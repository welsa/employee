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
public with sharing class NOB_AP51_DarvaWS_TEST {
    static User userAdmin;
    static List<Contact> listContact;
    static List<Account> listAccount;
    static List<NOB_Planning__c> listPlanning;
    static NOB_DarvaWSConfig__c config;
    static List<NOB_DarvaMessageLog__c> listMessageLog;
    static List<WorkOrder> ListWorkOrder;
    static List<Case> listCase;
    static List<PFR_FinancialDocument__c> docFin = new List<PFR_FinancialDocument__c>();
    static List<NOB_DARVA_Tag__c> lstDarvaTag;
	 static List<NOB_TauxNeg__c> TauxNeg;
    static List<NOB_AccountRelationship__c> RelatioCompte =  new List<NOB_AccountRelationship__c>();
    static{
        userAdmin = TestFactory.createPrefikarUser('adminUser');
        insert userAdmin;

        System.runAs(userAdmin){
            lstDarvaTag = new List<NOB_DARVA_Tag__c>();
             config = new NOB_DarvaWSConfig__c();
              config = new NOB_DarvaWSConfig__c(Name = 'configTest', NOB_ClientId__c = 'test', NOB_ClientSecret__c = 'test', NOB_Endpoint__c = 'test');
            insert config;
             TauxNeg = new List<NOB_TauxNeg__c>();
            //create account

            
            listAccount = new List<Account>{
                TestFactory.createInsurerAccount('Test 1','Nord'),
                TestFactory.createInsurerAccount('Test 2','Bourgogne'),
                TestFactory.createPrefikarBodyAccount('Test 3', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarBodyAccount('Test 4', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035'),
                TestFactory.createPrefikarBodyAccount('Test 4', 'Réseau Premium', '44057565200035','Actif')
            };
            listAccount[2].BillingCity = 'Paris';
            listAccount[2].BillingCountry = 'France';
            listAccount[2].BillingStreet = '5 RUE EMILE LEPEU';
            listAccount[2].BillingPostalCode = '75011';
            listAccount[3].BillingCity = 'Paris';
            listAccount[3].BillingCountry = 'France';
            listAccount[3].BillingStreet = '5 RUE EMILE LEPEU';
            listAccount[3].BillingPostalCode = '75011';
			listAccount[5].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NOB_Expert').getRecordTypeId();

            insert listAccount;
            
           
            //create contacts
            listContact = new List<Contact>{
                TestFactory.createInsuredContact('Luffy', 'Monkey', listAccount[0].Id, 'Nord'),
                TestFactory.createInsuredContact('Roronoa', 'Zoro', listAccount[1].id,'Bourgogne')
            };
            listContact[0].Phone = '77777777';
            listContact[0].MailingCity = 'Paris';
            listContact[0].MailingCity = 'France';
            listContact[0].MailingCity = '5 RUE EMILE LEPEU';
            listContact[0].MailingCity = '75011';

            listContact[1].MailingCity = 'Paris';
            listContact[1].MailingCity = 'France';
            listContact[1].MailingCity = '5 RUE EMILE LEPEU';
            listContact[1].MailingCity = '75011';
            listContact[1].Phone = '88888888';

            insert listContact;
            //create Planning
            listPlanning = new List<NOB_Planning__c>{
                TestFactory.createPlanning(listAccount[2].Id),
                TestFactory.createPlanning(listAccount[3].Id),
                TestFactory.createPlanning(listAccount[2].Id)
            };
            
            insert listPlanning;
            //create case
            listCase = new List<Case>{
                TestFactory.createCaseStandard('Nouvelle', listContact[0].id, listAccount[0].id, 'AUDI', '3061','12345asd','Darva',Datetime.newInstance(System.today().year(),
                System.today().month(), System.today().day()-2, 17, 00, 0),'AR1234','Body','Réparation'),
                TestFactory.createCaseStandard('Nouvelle', listContact[1].id, listAccount[1].id, 'BMW', '3061','123456ab','Email',Datetime.newInstance(System.today().year(),
                System.today().month(), System.today().day()-2, 17, 00, 0),'AR345','Body1','Peinture'),
                TestFactory.createCaseStandard('Nouvelle', listContact[1].id, listAccount[1].id, 'BMW', '3061','123456ab','Email',Datetime.newInstance(System.today().year(),
                System.today().month(), System.today().day()-2, 17, 00, 0),'AR345','Body1','Peinture')
               
            };
            listCase[0].NOB_TECH_DispoId__c = listPlanning[0].Id;
            listCase[0].Expert__c = listAccount[5].Id;
            listCase[0].NOB_BodyShop__c = listAccount[2].Id;
            //listCase[0].NOB_ScenarioCode__c = '36';
            listCase[0].PFR_TECH_EngineerClaimNR__c = 'CH1';
            listCase[2].NOB_TECH_DispoId__c= listPlanning[2].id;
        

            insert listCase;

            //create Work Order
            ListWorkOrder = new List<WorkOrder>{
                TestFactory.createWorkOrder('Nouveau', listCase[0].Id),
                TestFactory.createWorkOrder('Nouveau', listCase[2].Id)
                // TestFactory.createWorkOrder('Nouveau', listCase[1].Id)
            };
            String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
            ListWorkOrder[0].recordTypeId = recordTypeWo;
            
           
            // Message Log
            listMessageLog = new List<NOB_DarvaMessageLog__c>{ 
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'SD40',NOB_MessageSubType__c ='Type 2' , /*NOB_Status__c = 'New',*/NOB_Status__c='New',NOB_Case__c = listCase[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'Genesys',NOB_MessageSubType__c ='CreateTask' , NOB_Status__c = 'New',NOB_Case__c = listCase[0].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE,NOB_MessageSubType__c ='Type 2' ,NOB_Status__c='New' ,NOB_Case__c=listCase[0].Id, NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'SD40',NOB_MessageSubType__c ='Type 2' , /*NOB_Status__c = 'New',*/NOB_Status__c='New',NOB_Case__c = listCase[2].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = 'Genesys',NOB_MessageSubType__c ='CreateTask' , NOB_Status__c = 'New',NOB_Case__c = listCase[2].Id , NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_MessageType__c = NOB_AP00_Constants.DARVA_MESSAGE_LOG_MESSAGE_TYPE_ICE,NOB_MessageSubType__c ='Type 2' ,NOB_Status__c='New' ,NOB_Case__c=listCase[2].Id, NOB_ActionType__c= 'New')
                    
            };
                
                
           String docfinRT = Schema.SObjectType.PFR_FinancialDocument__c.getRecordTypeInfosByName().get('Chiffrage').getRecordTypeId();
            docFin = new List<PFR_FinancialDocument__c>{
               new PFR_FinancialDocument__c(recordTypeId= docfinRT ,PFR_FinancialDocumentFrom__c=listAccount[5].Id,PFR_ExclVATTotalAmount__c=10, 
                                            PFR_DocumentStatus__c='VL', PFR_Case__c = listCase[0].id,
                                            PFR_VATAmount__c =10,PFR_InclVATTotalAmount__c = 10, PFR_FinDocDateOfIssue__c = system.today())
            };
             insert docFin;
            
            
            lstDarvaTag = new List<NOB_DARVA_Tag__c>{
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '123', NOB_TAGLVL2__c = '123', NOB_TAGLVL1__c = '123', NOB_CaseID__c = listCase[0].Id, PFR_ParentTagOccurence__c = 123, PFR_ParentTag__c = 'parent', NOB_Occurrence_number__c = 123),
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '456', NOB_TAGLVL2__c = '456', NOB_TAGLVL1__c = '456', NOB_CaseID__c = listCase[0].Id, PFR_ParentTagOccurence__c = 456, PFR_ParentTag__c = 'parent2', NOB_Occurrence_number__c = 456)
            };//to create
            insert lstDarvaTag;
            RelatioCompte =  new List <NOB_AccountRelationship__c>{
                new NOB_AccountRelationship__c(NOB_Compte__c =listAccount[0].Id , NOB_Bodyshop__c = listAccount[2].Id, NOB_Type__c = 'Réparateur - Assureur')

            };
            insert RelatioCompte;
            
            TauxNeg = new list<NOB_TauxNeg__c>{
                new NOB_TauxNeg__c (NOB_RelationCompte__c=RelatioCompte[0].Id, NOB_StartDate__c = System.today())
            };
                TauxNeg[0].NOB_DSP__c=3;
            TauxNeg[0].NOB_T1__c=3;
            TauxNeg[0].NOB_T2__c=3;
            TauxNeg[0].NOB_T3__c=3;
            TauxNeg[0].NOB_TauxMecanique__c=3;
            TauxNeg[0].NOB_TI1__c=3;
            TauxNeg[0].NOB_TI2__c=3;
            TauxNeg[0].NOB_TI3__c=3;
            TauxNeg[0].NOB_TP__c=3;
			 insert TauxNeg;
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
             string jsonResponse  = '{"mis_statut":"Annulé","mis_raison":"Annulé","Id":"5001l0000061xM4AAI","cch_id_fournisseur":""}';
        
         Test.setMock(HttpCalloutMock.class, new IceHttpMockResponse(500,'error',jsonResponse));
            insert ListWorkOrder;
            insert listMessageLog;
             listPlanning[0].NOB_WorkOrder__c = ListWorkOrder.get(0).id;
			NOB_AP51_DarvaWS.buildDocumentFinancier(docFin.get(0));
            NOB_AP51_DarvaWS.buildTag(lstDarvaTag.get(0));
            NOB_AP51_DarvaWS.buildWorkOrder(ListWorkOrder.get(0));
            NOB_AP51_DarvaWS.buildDocumentFinanciers(listCase[0].id);
            NOB_AP51_DarvaWS.buildNegRates(TauxNeg[0]);
            Map<String,Object> mapdispo = NOB_AP51_DarvaWS.buildDispo(listPlanning[0]);
            
            
            NOB_AP51_DarvaWS.getPreviousBodyshop(listCase[0].id, ListWorkOrder.get(0).Id,listCase[0].PFR_TECH_EngineerClaimNR__c);
            Test.stopTest();
            List<Case> listCaseInserted = [SELECT Id, NOB_TECH_RulePB_CaseWithoutRepairer__c from Case WHERE Id = :listCase[1].Id];
            List<Task> listTask = [SELECT Id from Task WHERE WhatId = :listCaseInserted[0].Id];

        }
        
    }

    @isTest
    public static void onAfterUpdateTest(){
        System.runAs(userAdmin){
            Test.startTest();
            insert ListWorkOrder;
            insert listMessageLog;
            
			listPlanning[0].NOB_WorkOrder__c = ListWorkOrder[0].id;
            update listPlanning;
            //List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_Status__c, NOB_MessageSubType__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c where Nob_WorkOrder__c in:ListWorkOrder order by createddate desc limit 1];
            List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id, NOB_Status__c, NOB_MessageSubType__c,NOB_JsonResponse__c from NOB_DarvaMessageLog__c];
            listNOB_DarvaMessageLog[0].nob_workorder__c = ListWorkOrder[0].id;
            listNOB_DarvaMessageLog[3].nob_workorder__c = null;
            List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLogToUpdate = new List<NOB_DarvaMessageLog__c>();
            for(NOB_DarvaMessageLog__c dl : listNOB_DarvaMessageLog){ 
                dl.NOB_Status__c = 'New';
                listNOB_DarvaMessageLogToUpdate.add(dl);
            }
            
            update listNOB_DarvaMessageLogToUpdate; 
            Test.stopTest();
            /*List<Case> listCaseInserted = [SELECT Id, NOB_TECH_RulePB_CaseWithoutRepairer__c from Case WHERE Id = :listCase[1].Id];
            List<Task> listTask = [SELECT Id from Task WHERE WhatId = :listCaseInserted[0].Id];
            System.debug('listTask'+listTask);*/
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
    
     public with sharing class IceHttpMockResponse  implements HttpCalloutMock  {
        protected Integer code;
        protected String status;
        protected String body;

        public IceHttpMockResponse(Integer code, String status, String body) {
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
    @isTest
        public static void DoSendMsg(){
            System.runAs(userAdmin){
                Test.startTest();
                ListWorkOrder[1].NOB_Reparateur__c = listAccount[2].id;
                insert ListWorkOrder;

     
                insert listMessageLog;
                
                
                listPlanning[2].nob_workOrder__c= ListWorkOrder[1].id;
                update listPlanning;
                listCase[2].NOB_TECH_DispoId__c = null;
                update listCase;
        
                NOB_AP51_DarvaWS.doSendMessage(listMessageLog[3].id,listMessageLog[3].Nob_WorkOrder__c, listMessageLog[3].NOB_Case__c);
                String s = NOB_AP51_DarvaWS.getComment(listCase[2]);
                Test.stopTest();
                
                
            }
        
        }
}