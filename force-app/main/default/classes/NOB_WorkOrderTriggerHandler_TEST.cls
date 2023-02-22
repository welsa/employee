/*
 @File Name          : NOB_WorkOrderTriggerHandler_TEST
 @Description        : Test class for NOB_WorkOrderTriggerHandler
 @Author             : HMO
 @Group              : 
 @Last Modified By   : ARA
 @Last Modified On   : 01-26-2021
 @Modification Log   : 
 ==============================================================================
  Ver         Date                     Author      Modification
 ==============================================================================
  1.0    20/11/2020, 15:32     HMO      1.0
*/
@isTest
public without sharing class NOB_WorkOrderTriggerHandler_TEST {
    static User userAdmin;
    static Account accBodyshop;
    static List<Account> gesReseaureparateur;
    static List<Account> listAccAssureur;
    static List<Case> lstCases;
    static List<WorkOrder> lstWorkOrder;
    static NOB_DarvaWSConfig__c config;
    static List<NOB_DarvaMessageLog__c> messageLog;
    static List<Contact> listContactAssure;
    static NOB_Planning__c planning;
    static NOB_AccountPricebook__c catalogueCompte;
    static List<NOB_SMSLog__c> smsLog;
    static List<NOB_DARVA_Tag__c> lstDarvaTag;
    static list<NOB_AccountRelationship__c> lstRelationCompte;
    static list<NOB_TauxNeg__c> lstTauxNeg;
    static List<Task> listTask;

    static{
        userAdmin = new User();
        accBodyshop = new Account();
        lstCases = new List<Case>();
        lstWorkOrder = new List<WorkOrder>();
        config = new NOB_DarvaWSConfig__c();
        messageLog = new List<NOB_DarvaMessageLog__c>();
        listContactAssure = new List<Contact>();
        planning = new NOB_Planning__c();
        catalogueCompte = new NOB_AccountPricebook__c();
        smsLog = new List<NOB_SMSLog__c>();
        lstDarvaTag = new List<NOB_DARVA_Tag__c>();


        userAdmin = TestFactory.createUser('adminUser');
        // userAdmin.BypassValidationRules__c = true;
        // userAdmin.BypassWorkflows__c = true;
        userAdmin.NOB_isPrefikar__c = true;
        insert userAdmin;

        System.runAs(userAdmin){
            NOB_SMSLogConfig__c SMSLogconfig = new NOB_SMSLogConfig__c();
            SMSLogconfig.Name = 'Config 1';
            SMSLogconfig.NOB_ClientId__c = '10d0e1adc5c149ca8d6eae19dc38e247';
            SMSLogconfig.NOB_ClientSecret__c = '8387887837';
            SMSLogconfig.NOB_Endpoint__c = 'test';
            SMSLogconfig.Etape3DA__c = 'Testing';
            SMSLogconfig.Etape3AXA__c = 'Bonjour,RDV confirmé le {0} entre {1} et {2} avec notre garage joignable au {3}.Service A Domicile (test axa)';
            insert SMSLogconfig;

            listAccAssureur = new List<Account>{TestFactory.createInsurerAccount('accAssureur','Nord'),TestFactory.createInsurerAccount('accAssureur1','Bourgogne')};
            listAccAssureur[0].Nob_CTICampaignNumber__c = 'Test';
            listAccAssureur[1].Nob_CTICampaignNumber__c = 'Test1';
			listAccAssureur[0].ReferenceNumber__c = 'FR0121237264';
            listAccAssureur[1].ReferenceNumber__c = 'FR0121237464';
            insert listAccAssureur;

            accBodyshop = TestFactory.createPrefikarBodyAccount('accReparateur', 'Hors réseau','Test','Actif'); //need to change based on cls
            accBodyshop.NOB_SiretHeadquarters__c = '31049995900891';
            accBodyshop.BillingCity = 'Paris';
            accBodyshop.BillingCountry = 'France';
            accBodyshop.BillingStreet = 'Chemin endans';
            accBodyshop.BillingPostalCode = '3070';
            accBodyshop.NOB_NetworkType__c = 'Réseau Platinium';
            // accBodyshop.NOB_Statut__c = 'Actif';
            accBodyshop.ContactEmail__c = 'test@test.com';
            accBodyshop.VATNumber__c = 'vat245686';
            accBodyshop.ReferenceNumber__c = 'FR0123456789';
            accBodyshop.ASEntity__c = 'ASFR1';
            accBodyshop.ExpertSubstitutionMethod__c = 'Forced';
            insert accBodyshop;

            //create Gestionnaire de réseau de réparateur
            gesReseaureparateur = new List<Account>{
                TestFactory.createPrefikarManageBodyAccount('Test 5', 'Réseau Premium', '44057565200035')
            };
            gesReseaureparateur[0].ReferenceNumber__c = 'FR0121456789';
            insert gesReseaureparateur;

            listContactAssure.add(TestFactory.createInsuredContact('contact', 'Assuree', listAccAssureur[0].Id,'Nord'));
            listContactAssure.add(TestFactory.createInsuredContact('contact1', 'Assuree1', listAccAssureur[1].Id,'Bourgogne'));
            insert listContactAssure;

            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[0].Id, listAccAssureur[0].Id, 'KIA', 'Eltrix','12345asd','test1',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR1234','Body','Réparation'));
            lstCases.add(TestFactory.createCaseStandard('Nouvelle', listContactAssure[1].Id, listAccAssureur[1].Id, 'BMW', 'X6','128765sdd','test2',Datetime.newInstance(System.today().year(),
            System.today().month()-1, 
            System.today().day(), 17, 00, 0),'AR16534','Body','Réparation'));
            lstCases[0].NOB_ScenarioCode__c = '36';
            lstCases[0].PFR_TECH_EngineerClaimNR__c = 'testing';
            insert lstCases;

            String recordTypeWo =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id));
            lstWorkOrder.add(TestFactory.createWorkOrder('Nouvelle', lstCases[1].Id));
            lstWorkOrder[0].recordTypeId = recordTypeWo;
            lstWorkOrder[0].PFR_ExcludeFG__c = false;
            lstWorkOrder[0].NOB_Reparateur__c =accBodyshop.Id;
            lstWorkOrder[1].recordTypeId = recordTypeWo;
            lstWorkOrder[1].PFR_ExcludeFG__c = false;
            // insert lstWorkOrder;

            planning = TestFactory.createPlanning(accBodyshop.Id);
            planning.NOB_WorkOrder__c = lstWorkOrder[0].Id;
            planning.NOB_StartDate__c = Datetime.newInstance(System.today().year(),
            System.today().month(), System.today().day()+1, 14, 30, 0);
            planning.NOB_EndDate__c = Datetime.newInstance(System.today().year(),
            System.today().month(), System.today().day()+1, 15, 30, 0);
            insert planning;

            lstCases[0].NOB_TECH_DispoId__c = planning.Id;
            lstCases[0].NOB_BodyShop__c = accBodyshop.Id;
            update lstCases;

            catalogueCompte = new NOB_AccountPricebook__c(Name = 'testCatalogue', NOB_Account__c = listAccAssureur[0].Id);
            insert catalogueCompte; // need to change based on conditions

            messageLog = new List<NOB_DarvaMessageLog__c>{
                new NOB_DarvaMessageLog__c(NOB_JsonResponse__c = '{"message":"{\n  \"message\": \"Success\"\n}","status":"success"}', NOB_MessageType__c = 'SD32', NOB_Status__c = 'New'),
                new NOB_DarvaMessageLog__c(NOB_JsonResponse__c = '{"status":"error","error":"invalid phone"}', NOB_MessageType__c = 'SD40', NOB_Status__c = 'Error')
            };
            insert messageLog;

            config = new NOB_DarvaWSConfig__c(Name = 'configTest', NOB_ClientId__c = 'test', NOB_ClientSecret__c = 'test', NOB_Endpoint__c = 'test');
            insert config;

            // smsLog = new List<NOB_SMSLog__c>{
            //     // new NOB_SMSLog__c(NOB_Case__c = lstCases[0].Id, NOB_Statut__c = 'To be send', NOB_Contact__c = listContactAssure[0].Id, NOB_Subject__c = 'Etape_3',NOB_WorkOrder__c = lstWorkOrder[0].Id),
            //     new NOB_SMSLog__c(NOB_Case__c = lstCases[0].Id, NOB_Statut__c = 'To be send', NOB_Contact__c = listContactAssure[0].Id, NOB_Subject__c = 'Etape_3',NOB_WorkOrder__c = lstWorkOrder[0].Id)
            // };
            // insert smsLog;

            lstDarvaTag = new List<NOB_DARVA_Tag__c>{
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '123', NOB_TAGLVL2__c = '123', NOB_TAGLVL1__c = '123', NOB_CaseID__c = lstCases[0].Id, PFR_ParentTagOccurence__c = 123, PFR_ParentTag__c = 'parent', NOB_Occurrence_number__c = 123),
                new NOB_DARVA_Tag__c(NOB_Valeur__c = '456', NOB_TAGLVL2__c = '456', NOB_TAGLVL1__c = '456', NOB_CaseID__c = lstCases[0].Id, PFR_ParentTagOccurence__c = 456, PFR_ParentTag__c = 'parent2', NOB_Occurrence_number__c = 456)
            };//to create
            insert lstDarvaTag;

            lstRelationCompte = new List<NOB_AccountRelationship__c>{
                TestFactory.createRelationCompte(accBodyshop.Id, listAccAssureur[0].Id, 'Réparateur - Assureur')
            };
            insert lstRelationCompte;

            lstTauxNeg = new List <NOB_TauxNeg__c>{
                TestFactory.createTauxNeg(lstRelationCompte[0].Id, Date.newInstance(System.today().year(), System.today().month()-2, System.today().day()), Date.newInstance(System.today().year(), System.today().month()+2, System.today().day()))
            };
            insert lstTauxNeg;
            listTask = new List<Task>{
                TestFactory.createTask(lstCases[1])
            };
            insert listTask;
        }
    }

    // @isTest
    // public static void onAfterInsertTest(){
    //     System.runAs(userAdmin){
    //         Test.startTest();
    //             lstWorkOrder[0].Status = 'Nouvelle';
    //             update lstWorkOrder;
    //         Test.stopTest();

    //         List<WorkOrder> lstUpdatedWo = [SELECT Id FROM WorkOrder WHERE Id =:lstWorkOrder[0].Id];
    //         System.assertEquals(1, lstUpdatedWo.size());
    //     }
    // }

    @isTest
    public static void handleBeforeInsertTest(){
        // String rtWO =  Schema.SObjectType.workOrder.getRecordTypeInfosByName().get('Ordre d\'Execution').getRecordTypeId();
        // WorkOrder wo = TestFactory.createWorkOrder('Nouvelle', lstCases[0].Id);
        // wo.recordTypeId = rtWO;

        System.runAs(userAdmin){
            Test.startTest();
            insert lstWorkOrder;

            smsLog = new List<NOB_SMSLog__c>{
                // new NOB_SMSLog__c(NOB_Case__c = lstCases[0].Id, NOB_Statut__c = 'To be send', NOB_Contact__c = listContactAssure[0].Id, NOB_Subject__c = 'Etape_3',NOB_WorkOrder__c = lstWorkOrder[0].Id),
                new NOB_SMSLog__c(NOB_Case__c = lstCases[0].Id, NOB_Statut__c = 'To be send', NOB_Contact__c = listContactAssure[0].Id, NOB_Subject__c = 'Etape_3',NOB_WorkOrder__c = lstWorkOrder[0].Id)
            };
            insert smsLog;


            Test.stopTest();
            List<WorkOrder> lstWoInsrted = [SELECT Id FROM WorkOrder];
            System.assertEquals(2, lstWoInsrted.size());

        }
    }
    @isTest
    public static void onAfterUpdateTest(){

        Test.startTest();
        System.runAs(userAdmin){

            insert lstWorkOrder;

            smsLog = new List<NOB_SMSLog__c>{
                // new NOB_SMSLog__c(NOB_Case__c = lstCases[0].Id, NOB_Statut__c = 'To be send', NOB_Contact__c = listContactAssure[0].Id, NOB_Subject__c = 'Etape_3',NOB_WorkOrder__c = lstWorkOrder[0].Id),
                new NOB_SMSLog__c(NOB_Case__c = lstCases[0].Id, NOB_Statut__c = 'To be send', NOB_Contact__c = listContactAssure[0].Id, NOB_Subject__c = 'Etape_3',NOB_WorkOrder__c = lstWorkOrder[0].Id)
            };
            insert smsLog;

            
            lstWorkOrder[1].Status = 'Canceled';
            lstWorkOrder[1].NOB_CancelationReason__c = 'Changement de réparateur';
            update lstWorkOrder;
        }
        Test.stopTest();
        List<WorkOrder> lstWOUpdated = [SELECT Id,Status FROM WorkOrder WHERE Id =:lstWorkOrder[1].Id];
            System.assertEquals('Canceled', lstWOUpdated[0].Status);
    }

}