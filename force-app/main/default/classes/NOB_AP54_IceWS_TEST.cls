/**
 * @description       : 
 * @author            : ARA
 * @group             : 
 * @last modified on  : 01-25-2021
 * @last modified by  : ARA
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   01-05-2021   ARA   Initial Version
**/
@isTest
public with sharing class NOB_AP54_IceWS_TEST {

    static User userAdmin;
    static List<Contact> listContact;
    static List<Account> listAccount;
    static List<NOB_Planning__c> listPlanning;
    static List<NOB_DarvaMessageLog__c> listMessageLog;
    static List<WorkOrder> ListWorkOrder;
    static List<Case> listCase;
    static PFR_WsCredential__c config;

    static{
        userAdmin = TestFactory.createPrefikarUser('ScUserTest');
        // userAdmin.BypassValidationRules__c = true;
        insert userAdmin;

        System.runAs(userAdmin){
            //create custom setting for endpoint
            config = new PFR_WsCredential__c();
            config.Name= 'ICE';
            config.NOB_ClientId__c = '1234568gfa74';
            config.NOB_ClientSecret__c = '644765796';
            config.NOB_Endpoint__c = 'TestingICE';
            insert config;

            //create account
            listAccount = new List<Account>{
                TestFactory.createInsurerAccount('Test 1','Nord'),
                TestFactory.createInsurerAccount('Test 2','Bourgogne'),
                TestFactory.createPrefikarBodyAccount('Test 3', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarBodyAccount('Test 4', 'Réseau Premium', '44057565200035','Actif'),
                TestFactory.createPrefikarManageBodyAccount('Test 5', 'Hors Réseau', '44057565200035')
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
            listCase[1].NOB_TECH_DispoId__c = listPlanning[1].Id;
            listCase[1].NOB_BodyShop__c = listAccount[3].Id;
            insert listCase;

            //create Work Order
            ListWorkOrder = new List<WorkOrder>{
                TestFactory.createWorkOrder('Nouveau', listCase[0].Id),
                TestFactory.createWorkOrder('Nouveau', listCase[1].Id)

            };
            insert ListWorkOrder;
            // Message Log
            ListMessageLog = new List<NOB_DarvaMessageLog__c>{ 
                new NOB_DarvaMessageLog__c(NOB_JsonResponse__c = '', NOB_MessageType__c = 'ICE',NOB_MessageSubType__c ='setMission' , NOB_Status__c = 'New',NOB_Case__c = listCase[0].Id,NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_JsonResponse__c = '', NOB_MessageType__c = 'ICE',NOB_MessageSubType__c ='setAnnulationMission' , NOB_Status__c = 'New',NOB_Case__c = listCase[1].Id,NOB_ActionType__c= 'New'),
                new NOB_DarvaMessageLog__c(NOB_JsonResponse__c = '', NOB_MessageType__c = 'ICE',NOB_MessageSubType__c ='setAnnulationMission' , NOB_Status__c = 'New',/*NOB_Case__c = listCase[1].Id ,*/ NOB_ActionType__c= 'New')
            };
            insert listMessageLog;

        }
    }
   
    @IsTest
    static void setMissionTest(){
        
        Test.startTest();
        System.runAs(userAdmin){
            string jsonRequest  = '{"vrp_mode_transfert":"AXA - SAD","vrp_date_debut":"2020-12-26T09:00:00Z","voi_modele":"c4","voi_marque":"Peugeot","voi_immat":"dc-09","orr_vrp_id":false,"orr_roulant":1,"orr_franchise_variable":0,"orr_franchise_min":0,"orr_franchise_max":0,"orr_franchise_fixe":0,"orr_cause":"","mis_num_sinistre":"434567ccsd","mis_emetteur":"AXA Assurance","mis_dt_sinistre":"2020-12-07T12:00:00Z","exp_tel":"","exp_cabinet":"","cli_ville2":"","cli_ville":"Cormeilles-en-Parisis","cli_tel1":"9876543210","cli_tel":"0622618131","cli_prenom":"Luc","cli_pay":"FR","cli_nom":"Muir","cli_gsm":"1234567890","cli_code_postal":"95240","cli_adresse":"39 Rue de Montigny","enterprise_id":"5001l0000061xUYAAY","cch_id_fournisseur":""}';
        
        Test.setMock(HttpCalloutMock.class, new IceHttpMockResponse(200,'OK',jsonRequest));
        NOB_AP54_IceWS.doSendMessage(listMessageLog[0].Id);
            
        }
        Test.stopTest();
        List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id,NOB_JsonResponse__c,NOB_Status__c FROm NOB_DarvaMessageLog__c WHERE NOB_Case__c = :listCase[0].Id];
        String result = listNOB_DarvaMessageLog[2].NOB_Status__c;
System.debug('@@listNOB_DarvaMessageLogset'+listNOB_DarvaMessageLog);
        // Assertion
        System.assertEquals('Sent', result);
    } 

    @IsTest
    static void setAnnulationMissionTest(){
        
        Test.startTest();
        System.runAs(userAdmin){
            string jsonRequest  = '{"mis_statut":"Annulé","mis_raison":"Annulé","enterprise_id":"5001l000005fBrbAAE","cch_id_fournisseur":""}';
        
        Test.setMock(HttpCalloutMock.class, new IceHttpMockResponse(200,'OK',jsonRequest));
        NOB_AP54_IceWS.doSendMessage(listMessageLog[1].Id);
            
        }
        Test.stopTest();
        List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id,NOB_JsonResponse__c,NOB_Status__c FROm NOB_DarvaMessageLog__c WHERE NOB_Case__c = :listCase[1].Id];
        String result = listNOB_DarvaMessageLog[2].NOB_Status__c;
System.debug('@@listNOB_DarvaMessageLogannu'+listNOB_DarvaMessageLog);
        // Assertion
        System.assertEquals('Sent', result);    
    } 
    @isTest
    public static void catchExeptionTest(){
        Test.startTest();
        System.runAs(userAdmin){
            string jsonRequest  = '{"vrp_mode_transfert":"","vrp_date_debut":"2021-01-16T12:00:00Z","voi_modele":"wwwww","voi_marque":"Renault","voi_immat":"wwww","orr_vrp_id":false,"orr_roulant":1,"orr_franchise_variable":0,"orr_franchise_min":0,"orr_franchise_max":0,"orr_franchise_fixe":0,"orr_cause":"","mis_num_sinistre":"wwwww","mis_emetteur":"Areas","mis_dt_sinistre":"2021-01-06T12:00:00Z","exp_tel":"","exp_cabinet":"","cli_ville2":"","cli_ville":"Cormeilles-en-Parisis","cli_tel1":"9876543210","cli_tel":"0622618131","cli_prenom":"Luc","cli_pay":"FR","cli_nom":"Muir","cli_gsm":"1234567890","cli_code_postal":"95240","cli_adresse":"39 Rue de Montigny","enterprise_id":"5001l000006KcLOAA0","cch_id_fournisseur":""}';
        
        Test.setMock(HttpCalloutMock.class, new IceHttpMockResponse(500,'error',jsonRequest));
        NOB_AP54_IceWS.doSendMessage(listMessageLog[2].Id);
        
        }
        Test.stopTest();
        List<NOB_DarvaMessageLog__c> listNOB_DarvaMessageLog = [SELECT Id,NOB_JsonResponse__c,NOB_Status__c FROm NOB_DarvaMessageLog__c WHERE NOB_Case__c = null];
        String result = listNOB_DarvaMessageLog[0].NOB_Status__c;

        // Assertion
        System.assertEquals('Error', result);
    }
    // Mock class
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
}